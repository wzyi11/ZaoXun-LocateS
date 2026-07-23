import { relationalStore } from '@kit.ArkData';
import { Event, EventInput, EventItem, EVENT_TABLE_NAME, EVENT_ITEM_TABLE_NAME } from '../model/EventModel';
import { Database } from './Database';
import { CalendarService } from './CalendarService';

export class EventRepository {
  private db: Database = Database.getInstance();
  private calendarService: CalendarService = CalendarService.getInstance();

  async insert(event: EventInput): Promise<number> {
    let calendarEventId: number | null = null;

    // 同步到 CalendarKit
    if (event.date) {
      const startTime: number = new Date(event.date + 'T00:00:00').getTime();
      const id = await this.calendarService.addEvent(event.title, startTime, undefined, event.note);
      if (id !== undefined) {
        calendarEventId = id;
      }
    }

    const store = this.db.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'title': event.title,
      'date': event.date,
      'note': event.note,
      'status': event.status,
      'createTime': event.createTime,
      'calendarEventId': calendarEventId,
    };
    return await store.insert(EVENT_TABLE_NAME, valueBucket);
  }

  async getAll(): Promise<Event[]> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(EVENT_TABLE_NAME);
    predicates.orderByDesc('createTime');
    const resultSet = await store.query(predicates, ['id', 'title', 'date', 'note', 'status', 'createTime', 'calendarEventId']);
    const events: Event[] = [];
    while (resultSet.goToNextRow()) {
      const calIdVal = resultSet.getLong(resultSet.getColumnIndex('calendarEventId'));
      events.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        date: resultSet.getString(resultSet.getColumnIndex('date')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        status: resultSet.getLong(resultSet.getColumnIndex('status')),
        createTime: resultSet.getString(resultSet.getColumnIndex('createTime')),
        calendarEventId: calIdVal === 0 ? null : calIdVal,
      });
    }
    resultSet.close();
    return events;
  }

  async linkItem(eventId: number, itemId: number): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'eventId': eventId,
      'itemId': itemId,
      'isPrepared': 0,
    };
    return await store.insert(EVENT_ITEM_TABLE_NAME, valueBucket);
  }

  async getEventItems(eventId: number): Promise<EventItem[]> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(EVENT_ITEM_TABLE_NAME);
    predicates.equalTo('eventId', eventId);
    const resultSet = await store.query(predicates, ['id', 'eventId', 'itemId', 'isPrepared']);
    const items: EventItem[] = [];
    while (resultSet.goToNextRow()) {
      items.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        eventId: resultSet.getLong(resultSet.getColumnIndex('eventId')),
        itemId: resultSet.getLong(resultSet.getColumnIndex('itemId')),
        isPrepared: resultSet.getLong(resultSet.getColumnIndex('isPrepared')) === 1,
      });
    }
    resultSet.close();
    return items;
  }

  async getById(id: number): Promise<Event | null> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(EVENT_TABLE_NAME);
    predicates.equalTo('id', id);
    const resultSet = await store.query(predicates, ['id', 'title', 'date', 'note', 'status', 'createTime', 'calendarEventId']);
    let event: Event | null = null;
    if (resultSet.goToNextRow()) {
      const calIdVal = resultSet.getLong(resultSet.getColumnIndex('calendarEventId'));
      event = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        date: resultSet.getString(resultSet.getColumnIndex('date')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        status: resultSet.getLong(resultSet.getColumnIndex('status')),
        createTime: resultSet.getString(resultSet.getColumnIndex('createTime')),
        calendarEventId: calIdVal === 0 ? null : calIdVal,
      };
    }
    resultSet.close();
    return event;
  }

  async updateEventItemPrepared(id: number, isPrepared: boolean): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'isPrepared': isPrepared ? 1 : 0,
    };
    const predicates = new relationalStore.RdbPredicates(EVENT_ITEM_TABLE_NAME);
    predicates.equalTo('id', id);
    return await store.update(valueBucket, predicates);
  }

  async deleteEventItems(eventId: number): Promise<number> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(EVENT_ITEM_TABLE_NAME);
    predicates.equalTo('eventId', eventId);
    return await store.delete(predicates);
  }

  async deleteEventItemsByItemId(itemId: number): Promise<number> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(EVENT_ITEM_TABLE_NAME);
    predicates.equalTo('itemId', itemId);
    return await store.delete(predicates);
  }

  async delete(eventId: number): Promise<number> {
    // 先从 CalendarKit 删除
    const evt: Event | null = await this.getById(eventId);
    if (evt && evt.calendarEventId !== null) {
      await this.calendarService.deleteEvent(evt.calendarEventId);
    }

    const store = this.db.getStore();
    await this.deleteEventItems(eventId);
    const predicates = new relationalStore.RdbPredicates(EVENT_TABLE_NAME);
    predicates.equalTo('id', eventId);
    return await store.delete(predicates);
  }

  async complete(eventId: number): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'status': 1,
    };
    const predicates = new relationalStore.RdbPredicates(EVENT_TABLE_NAME);
    predicates.equalTo('id', eventId);
    return await store.update(valueBucket, predicates);
  }
}

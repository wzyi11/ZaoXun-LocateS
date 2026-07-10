import { relationalStore } from '@kit.ArkData';
import { Event, EventItem, EVENT_TABLE_NAME, EVENT_ITEM_TABLE_NAME } from '../model/EventModel';
import { Database } from './Database';

export class EventRepository {
  private db: Database = Database.getInstance();

  async insert(event: Omit<Event, 'id'>): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValueBucket = {
      'title': event.title,
      'date': event.date,
      'note': event.note,
      'status': event.status,
      'createTime': event.createTime,
    };
    return await store.insert(EVENT_TABLE_NAME, valueBucket);
  }

  async getAll(): Promise<Event[]> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(EVENT_TABLE_NAME);
    predicates.orderByDesc('createTime');
    const resultSet = await store.query(predicates, ['id', 'title', 'date', 'note', 'status', 'createTime']);
    const events: Event[] = [];
    while (resultSet.goToNextRow()) {
      events.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        date: resultSet.getString(resultSet.getColumnIndex('date')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        status: resultSet.getLong(resultSet.getColumnIndex('status')),
        createTime: resultSet.getString(resultSet.getColumnIndex('createTime')),
      });
    }
    resultSet.close();
    return events;
  }

  async linkItem(eventId: number, itemId: number): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValueBucket = {
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
}

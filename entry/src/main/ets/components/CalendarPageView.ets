import { calendarManager } from '@kit.CalendarKit';
import { CalendarView } from './CalendarView';
import { CalendarService } from '../data/CalendarService';
import { EventRepository } from '../data/EventRepository';
import {
  Event as StorageEvent,
  EventInput,
  formatEventDateTime,
  isEventDateWithinNextDays,
  isSystemCalendarEventSkippable,
  parseEventDateStartTime,
} from '../model/EventModel';

interface ScheduleItem {
  title: string;
  time: string;
  fromApp: boolean;
}

function fmtTime(ts: number): string {
  const d: Date = new Date(ts);
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}

@Component
export struct CalendarPageView {
  @Prop compact: boolean = false;
  @Prop @Watch('reload') refreshKey: number = 0;
  onDateSelected?: (day: number) => void;
  @State schedules: ScheduleItem[] = [];
  @State appEventDays: number[] = [];
  @State systemEventDays: number[] = [];
  @State selectedDay: number = -1;
  @State currentYear: number = 2026;
  @State currentMonth: number = 7;
  @State loading: boolean = true;
  private allEvents: calendarManager.Event[] = [];
  private localEvents: StorageEvent[] = [];
  private appEventIds: Set<number> = new Set();
  private repo: EventRepository = new EventRepository();


  aboutToAppear(): void {
    const now: Date = new Date();
    this.currentYear = now.getFullYear();
    this.currentMonth = now.getMonth() + 1;
    this.loadEvents();
  }

  reload(): void {
    this.loadEvents();
  }

  async loadEvents(): Promise<void> {
    this.loading = true;
    const svc: CalendarService = CalendarService.getInstance();
    this.localEvents = await this.repo.getAll();
    this.recalcEventDays();

    let retries: number = 0;
    while (!svc.ready && retries < 20) {
      await new Promise<void>((resolve: Function) => setTimeout(resolve, 500));
      retries++;
    }

    if (!svc.ready) {
      const today: number = new Date().getDate();
      this.selectedDay = today;
      this.filterSchedules();
      this.loading = false;
      return;
    }

    try {
      // 读取应用自建日历的日程
      const appEvents: calendarManager.Event[] = await svc.getEvents();
      const appIdSet: Set<number> = new Set();
      for (const e of appEvents) {
        if (e.id !== undefined) {
          appIdSet.add(e.id);
        }
      }
      this.appEventIds = appIdSet;

      // 读取所有日历（包括系统默认日历）的日程
      const sysEvents: calendarManager.Event[] = await svc.getSystemEvents();

      console.info(`CalendarPageView: app=${appEvents.length}, allCalendars=${sysEvents.length}`);
      const importedCount: number = await this.importSystemEvents(sysEvents);
      this.localEvents = await this.repo.getAll();
      if (importedCount > 0) {
        AppStorage.setOrCreate('eventRefreshToken', Date.now());
      }

      // 合并并去重（getSystemEvents 包含 app 自己的日历）
      const seenIds: Set<number> = new Set();
      const merged: calendarManager.Event[] = [];
      for (const e of appEvents) {
        merged.push(e);
        if (e.id !== undefined) {
          seenIds.add(e.id);
        }
      }
      for (const e of sysEvents) {
        if (e.id === undefined || !seenIds.has(e.id)) {
          merged.push(e);
          if (e.id !== undefined) {
            seenIds.add(e.id);
          }
        }
      }
      this.allEvents = merged;
      this.recalcEventDays();

      const today: number = new Date().getDate();
      this.selectedDay = today;
      this.filterSchedules();
    } catch (_e) {
      // ignore
    }
    this.loading = false;
  }

  async importSystemEvents(sysEvents: calendarManager.Event[]): Promise<number> {
    const now: Date = new Date();
    let importedCount: number = 0;
    for (const e of sysEvents) {
      if (e.id === undefined || e.startTime === undefined || this.appEventIds.has(e.id)) {
        continue;
      }
      if (!isEventDateWithinNextDays(e.startTime, now, 30)) {
        continue;
      }
      if (isSystemCalendarEventSkippable(e.title ?? '', e.isAllDay, e.startTime, e.endTime)) {
        continue;
      }
      const existing: StorageEvent | null = await this.repo.getByCalendarEventId(e.id);
      if (existing !== null) {
        continue;
      }
      const eventDate: string = formatEventDateTime(new Date(e.startTime));
      const sameTitleAndDate: StorageEvent | null = await this.repo.getByTitleAndDate(e.title ?? '(无标题)', eventDate);
      if (sameTitleAndDate !== null) {
        continue;
      }
      const eventInput: EventInput = {
        title: e.title ?? '(无标题)',
        date: eventDate,
        note: e.description ?? '',
        status: 0,
        createTime: new Date().toISOString(),
        calendarEventId: e.id,
      };
      await this.repo.insertFromCalendar(eventInput);
      importedCount++;
    }
    return importedCount;
  }

  recalcEventDays(): void {
    const appDays: Set<number> = new Set();
    const sysDays: Set<number> = new Set();

    // 本应用数据库中的日程
    for (const e of this.localEvents) {
      if (e.status !== 0) {
        continue;
      }
      const startTime: number = parseEventDateStartTime(e.date);
      if (Number.isNaN(startTime)) {
        continue;
      }
      const d: Date = new Date(startTime);
      if (d.getFullYear() === this.currentYear && d.getMonth() + 1 === this.currentMonth) {
        // 跟 filterSchedules 一样的判断逻辑
        if (e.calendarEventId === null || this.appEventIds.has(e.calendarEventId)) {
          appDays.add(d.getDate()); // 本应用日程 → 蓝点
        } else {
          sysDays.add(d.getDate()); // 从系统日历导入的 → 橙红点
        }
      }
    }

    // 系统日历中未导入/未识别的日程
    const importedIds: Set<number> = new Set();
    for (const e of this.localEvents) {
      if (e.calendarEventId !== null) {
        importedIds.add(e.calendarEventId);
      }
    }
    for (const e of this.allEvents) {
      if (!e.startTime) {
        continue;
      }
      if (e.id !== undefined && (importedIds.has(e.id) || this.appEventIds.has(e.id))) {
        continue; // 已导入或属于本应用日历的，跳过
      }
      const d: Date = new Date(e.startTime);
      if (d.getFullYear() === this.currentYear && d.getMonth() + 1 === this.currentMonth) {
        sysDays.add(d.getDate());
      }
    }

    this.appEventDays = Array.from(appDays).sort((a, b) => a - b);
    this.systemEventDays = Array.from(sysDays).sort((a, b) => a - b);
  }

  filterSchedules(): void {
    if (this.selectedDay < 0) {
      this.schedules = [];
      return;
    }
    const list: ScheduleItem[] = [];
    const localCalendarIds: Set<number> = new Set();
    for (const e of this.localEvents) {
      if (e.calendarEventId !== null) {
        localCalendarIds.add(e.calendarEventId);
      }
      const startTime: number = parseEventDateStartTime(e.date);
      if (Number.isNaN(startTime)) {
        continue;
      }
      const d: Date = new Date(startTime);
      if (d.getDate() === this.selectedDay &&
          d.getMonth() + 1 === this.currentMonth &&
          d.getFullYear() === this.currentYear) {
        list.push({
          title: e.title,
          time: fmtTime(startTime),
          fromApp: e.calendarEventId === null || this.appEventIds.has(e.calendarEventId),
        });
      }
    }
    for (const e of this.allEvents) {
      if (!e.startTime) {
        continue;
      }
      if (e.id !== undefined && localCalendarIds.has(e.id)) {
        continue;
      }
      const d: Date = new Date(e.startTime);
      if (d.getDate() === this.selectedDay &&
          d.getMonth() + 1 === this.currentMonth &&
          d.getFullYear() === this.currentYear) {
        list.push({
          title: e.title ?? '(无标题)',
          time: fmtTime(e.startTime),
          fromApp: e.id !== undefined && this.appEventIds.has(e.id),
        });
      }
    }
    this.schedules = list;
  }

  onDateClick(day: number): void {
    this.selectedDay = day;
    this.filterSchedules();
    this.onDateSelected?.(day);
  }

  onMonthChange(year: number, month: number): void {
    this.currentYear = year;
    this.currentMonth = month;
    this.recalcEventDays();
    this.selectedDay = -1;
    this.schedules = [];
  }

  build() {
    Column() {
      CalendarView({
        appEventDays: this.appEventDays,
        systemEventDays: this.systemEventDays,
        onDateClick: (day: number) => this.onDateClick(day),
        onMonthChange: (year: number, month: number) => this.onMonthChange(year, month),
      })

      if (this.selectedDay > 0 && this.schedules.length > 0) {
        Column() {
          Text(`${this.currentMonth}月${this.selectedDay}日`)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#007AFF')
            .width('100%')
            .margin({ bottom: 4 })

          // 来源图例
          Row({ space: 16 }) {
            Row({ space: 4 }) {
              Text('●').fontSize(10).fontColor('#007AFF')
              Text('本应用').fontSize(10).fontColor('#999')
            }
            Row({ space: 4 }) {
              Text('○').fontSize(10).fontColor('#FF9500')
              Text('系统日历').fontSize(10).fontColor('#999')
            }
          }
          .width('100%')
          .margin({ bottom: 8 })

          ForEach(this.schedules, (item: ScheduleItem, index: number) => {
            Row({ space: 8 }) {
              // 来源指示点：应用事件蓝色●，系统日历橙色○
              Text(item.fromApp ? '●' : '○')
                .fontSize(12)
                .fontColor(item.fromApp ? '#007AFF' : '#FF9500')
                .width(18)
                .textAlign(TextAlign.Center)
              Text(item.time)
                .fontSize(12)
                .fontColor(item.fromApp ? '#666' : '#999')
                .fontWeight(FontWeight.Medium)
              Text(item.title)
                .fontSize(13)
                .fontColor(item.fromApp ? '#333' : '#666')
            }
            .width('100%')
            .padding({ top: 4, bottom: 4 })
          }, (item: ScheduleItem, index: number) => `${item.time}-${item.title}-${item.fromApp ? 'a' : 's'}`)
        }
        .width('100%')
        .padding({ top: 12, left: 12, right: 12 })
        .margin({ top: 8 })
        .backgroundColor('#F8FBFF')
        .borderRadius(8)
      } else if (this.selectedDay > 0 && !this.loading) {
        Text('当天无日程')
          .fontSize(12)
          .fontColor('#CCC')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 12, bottom: 4 })
      }
    }
    .width('100%')
  }
}

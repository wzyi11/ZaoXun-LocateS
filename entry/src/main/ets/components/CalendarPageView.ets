import { calendarManager } from '@kit.CalendarKit';
import { CalendarView } from './CalendarView';
import { CalendarService } from '../data/CalendarService';

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
  @State eventDays: number[] = [];
  @State selectedDay: number = -1;
  @State currentYear: number = 2026;
  @State currentMonth: number = 7;
  @State loading: boolean = true;
  private allEvents: calendarManager.Event[] = [];
  private appEventIds: Set<number> = new Set();


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

    let retries: number = 0;
    while (!svc.ready && retries < 20) {
      await new Promise<void>((resolve: Function) => setTimeout(resolve, 500));
      retries++;
    }

    if (!svc.ready) {
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

  recalcEventDays(): void {
    const days: Set<number> = new Set();
    for (const e of this.allEvents) {
      if (e.startTime) {
        const d: Date = new Date(e.startTime);
        if (d.getFullYear() === this.currentYear && d.getMonth() + 1 === this.currentMonth) {
          days.add(d.getDate());
        }
      }
    }
    this.eventDays = Array.from(days).sort((a, b) => a - b);
  }

  filterSchedules(): void {
    if (this.selectedDay < 0) {
      this.schedules = [];
      return;
    }
    const list: ScheduleItem[] = [];
    for (const e of this.allEvents) {
      if (!e.startTime) {
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
        events: this.eventDays,
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

import { calendarManager } from '@kit.CalendarKit';
import { CalendarView } from './CalendarView';
import { CalendarService } from '../data/CalendarService';

interface ScheduleItem {
  title: string;
  time: string;
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
      const events: calendarManager.Event[] = await svc.getEvents();
      this.allEvents = events;
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
            .margin({ bottom: 8 })

          ForEach(this.schedules, (item: ScheduleItem, index: number) => {
            Row({ space: 8 }) {
              Text(item.time)
                .fontSize(12)
                .fontColor('#666')
                .fontWeight(FontWeight.Medium)
              Text(item.title)
                .fontSize(13)
                .fontColor('#333')
            }
            .width('100%')
            .padding({ top: 4, bottom: 4 })
          }, (item: ScheduleItem, index: number) => `${item.time}-${item.title}`)
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

import { calendarManager } from '@kit.CalendarKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';

const CALENDAR_NAME = 'SmartStorageManager';
const CALENDAR_DISPLAY_NAME = '智能收纳管家';

export class CalendarService {
  private static instance: CalendarService;
  private mgr: calendarManager.CalendarManager | null = null;
  private cal: calendarManager.Calendar | null = null;
  private _ready: boolean = false;

  private constructor() {}

  static getInstance(): CalendarService {
    if (!CalendarService.instance) {
      CalendarService.instance = new CalendarService();
    }
    return CalendarService.instance;
  }

  get ready(): boolean {
    return this._ready;
  }

  getCalendarManager(): calendarManager.CalendarManager | null {
    return this.mgr;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this._ready) {
      return;
    }

    const permissions: Permissions[] = [
      'ohos.permission.READ_CALENDAR',
      'ohos.permission.WRITE_CALENDAR',
    ];
    const atManager = abilityAccessCtrl.createAtManager();
    try {
      await atManager.requestPermissionsFromUser(context, permissions);
      this.mgr = calendarManager.getCalendarManager(context);

      const account: calendarManager.CalendarAccount = {
        name: CALENDAR_NAME,
        type: calendarManager.CalendarType.LOCAL,
        displayName: CALENDAR_DISPLAY_NAME,
      };
      try {
        this.cal = await this.mgr.getCalendar(account);
      } catch (_e) {
        this.cal = null;
      }
      if (!this.cal) {
        this.cal = await this.mgr.createCalendar(account);
      }
      this._ready = true;
    } catch (_e) {
      console.error('CalendarService: permission denied or init failed');
    }
  }

  async addEvent(title: string, startTime: number, endTime?: number, note?: string): Promise<number | undefined> {
    if (!this.cal) {
      return undefined;
    }
    const event: calendarManager.Event = {
      title: title,
      type: calendarManager.EventType.NORMAL,
      startTime: startTime,
      endTime: endTime ?? startTime + 60 * 60 * 1000,
      description: note ?? '',
    };
    return await this.cal.addEvent(event);
  }

  async deleteEvent(eventId: number): Promise<void> {
    if (!this.cal) {
      return;
    }
    await this.cal.deleteEvent(eventId);
  }

  async getEvents(): Promise<calendarManager.Event[]> {
    if (!this.cal) {
      return [];
    }
    return await this.cal.getEvents();
  }
}

export interface Event {
  id: number;
  title: string;
  date: string;          // YYYY-MM-DD
  note: string;
  status: number;        // 0=进行中 1=已完成
  createTime: string;
  completeTime: string;
  calendarEventId: number | null;  // CalendarKit 事件 ID
}

export interface EventInput {
  title: string;
  date: string;
  note: string;
  status: number;
  createTime: string;
  completeTime?: string;
  calendarEventId?: number | null;
}

export interface EventItem {
  id: number;
  eventId: number;
  itemId: number;
  isPrepared: boolean;   // 是否已准备
}

export const EVENT_TABLE_NAME = 'event';
export const EVENT_ITEM_TABLE_NAME = 'event_item';
export const EVENT_CREATE_SQL = `
  CREATE TABLE IF NOT EXISTS ${EVENT_TABLE_NAME} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    date TEXT DEFAULT '',
    note TEXT DEFAULT '',
    status INTEGER DEFAULT 0,
    createTime TEXT NOT NULL,
    completeTime TEXT DEFAULT '',
    calendarEventId INTEGER DEFAULT NULL
  )
`;
export const EVENT_ITEM_CREATE_SQL = `
  CREATE TABLE IF NOT EXISTS ${EVENT_ITEM_TABLE_NAME} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    eventId INTEGER NOT NULL,
    itemId INTEGER NOT NULL,
    isPrepared INTEGER DEFAULT 0
  )
`;

function padDatePart(value: number): string {
  return value < 10 ? `0${value}` : value.toString();
}

export function formatEventDate(date: Date): string {
  const year: number = date.getFullYear();
  const month: number = date.getMonth() + 1;
  const day: number = date.getDate();
  return `${year}-${padDatePart(month)}-${padDatePart(day)}`;
}

export function formatEventDateTime(date: Date): string {
  const hour: number = date.getHours();
  const minute: number = date.getMinutes();
  return `${formatEventDate(date)} ${padDatePart(hour)}:${padDatePart(minute)}`;
}

export function combineEventDateAndTime(selectedDate: Date, selectedTime: Date): Date {
  return new Date(
    selectedDate.getFullYear(),
    selectedDate.getMonth(),
    selectedDate.getDate(),
    selectedTime.getHours(),
    selectedTime.getMinutes(),
    0,
    0
  );
}

export function parseEventDateStartTime(date: string): number {
  const normalized: string = date.trim();
  const dateAndTime: string[] = normalized.split(' ');
  const dateParts: string[] = dateAndTime[0].split('-');
  if (dateParts.length !== 3) {
    return NaN;
  }
  const year: number = Number(dateParts[0]);
  const month: number = Number(dateParts[1]);
  const day: number = Number(dateParts[2]);
  if (!Number.isFinite(year) || !Number.isFinite(month) || !Number.isFinite(day)) {
    return NaN;
  }
  let hour: number = 0;
  let minute: number = 0;
  if (dateAndTime.length > 1 && dateAndTime[1] !== '') {
    const timeParts: string[] = dateAndTime[1].split(':');
    if (timeParts.length >= 2) {
      hour = Number(timeParts[0]);
      minute = Number(timeParts[1]);
      if (!Number.isFinite(hour) || !Number.isFinite(minute)) {
        return NaN;
      }
    }
  }
  return new Date(year, month - 1, day, hour, minute, 0, 0).getTime();
}

export function isEventDateWithinNextDays(startTime: number, baseDate: Date, days: number): boolean {
  const baseStart: number = new Date(
    baseDate.getFullYear(),
    baseDate.getMonth(),
    baseDate.getDate(),
    0,
    0,
    0,
    0
  ).getTime();
  const endExclusive: number = baseStart + (days + 1) * 24 * 60 * 60 * 1000;
  return startTime >= baseStart && startTime < endExclusive;
}

export function isCalendarEventAllDay(isAllDay: boolean | undefined, startTime: number, endTime: number): boolean {
  if (isAllDay === true) {
    return true;
  }
  const start: Date = new Date(startTime);
  const end: Date = new Date(endTime);
  const startsAtDayStart: boolean = start.getHours() === 0 && start.getMinutes() === 0;
  const endsAtDayEnd: boolean =
    (end.getHours() === 0 && end.getMinutes() === 0 && endTime - startTime >= 24 * 60 * 60 * 1000) ||
    (end.getHours() === 23 && end.getMinutes() >= 59);
  return startsAtDayStart && endsAtDayEnd;
}

export function isSystemCalendarEventSkippable(
  title: string,
  isAllDay: boolean | undefined,
  startTime: number,
  endTime: number
): boolean {
  if (isCalendarEventAllDay(isAllDay, startTime, endTime)) {
    return true;
  }
  const festivalWords: string[] = [
    '节气', '春节', '元宵', '清明', '端午', '七夕', '中秋', '重阳', '除夕',
    '建军节', '国庆', '劳动节', '儿童节', '教师节', '大暑', '小暑', '立春',
    '雨水', '惊蛰', '春分', '谷雨', '立夏', '小满', '芒种', '夏至', '立秋',
    '处暑', '白露', '秋分', '寒露', '霜降', '立冬', '小雪', '大雪', '冬至',
    '小寒', '大寒', '初伏', '中伏', '末伏',
  ];
  for (let i = 0; i < festivalWords.length; i++) {
    if (title.indexOf(festivalWords[i]) >= 0) {
      return true;
    }
  }
  return false;
}

export function buildEventImportKey(title: string, startTime: number): string {
  return `${title.trim()}|${formatEventDateTime(new Date(startTime))}`;
}

export interface Event {
  id: number;
  title: string;
  date: string;          // YYYY-MM-DD
  note: string;
  status: number;        // 0=进行中 1=已完成
  createTime: string;
  calendarEventId: number | null;  // CalendarKit 事件 ID
}

export interface EventInput {
  title: string;
  date: string;
  note: string;
  status: number;
  createTime: string;
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

export function parseEventDateStartTime(date: string): number {
  const parts: string[] = date.split('-');
  if (parts.length !== 3) {
    return NaN;
  }
  const year: number = Number(parts[0]);
  const month: number = Number(parts[1]);
  const day: number = Number(parts[2]);
  if (!Number.isFinite(year) || !Number.isFinite(month) || !Number.isFinite(day)) {
    return NaN;
  }
  return new Date(year, month - 1, day, 0, 0, 0, 0).getTime();
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

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

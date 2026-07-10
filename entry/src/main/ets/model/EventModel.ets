export interface Event {
  id: number;
  title: string;
  date: string;          // YYYY-MM-DD
  note: string;
  status: number;        // 0=进行中 1=已完成
  createTime: string;
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
    createTime TEXT NOT NULL
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

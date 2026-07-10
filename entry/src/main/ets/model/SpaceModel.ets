export interface Space {
  id: number;
  name: string;
  parentId: number;      // 父空间 ID，0=根
  level: number;         // 1=房间 2=柜子 3=格子
  icon: string;
}

export interface SpaceInput {
  name: string;
  parentId: number;
  level: number;
  icon: string;
}

export const SPACE_TABLE_NAME = 'space';
export const SPACE_CREATE_SQL = `
  CREATE TABLE IF NOT EXISTS ${SPACE_TABLE_NAME} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    parentId INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    icon TEXT DEFAULT '📦'
  )
`;

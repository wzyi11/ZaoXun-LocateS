export interface Space {
  id: number;
  name: string;
  parentId: number;      // 父空间 ID，0=根
  level: number;         // 1=空间 2=分区
  icon: string;
  image: string;         // 空间默认图或自定义图路径
  markerX: number;       // 分区点在父空间图片上的相对 X 坐标，0-1
  markerY: number;       // 分区点在父空间图片上的相对 Y 坐标，0-1
  markerColor: string;   // 分区点颜色
}

export interface SpaceInput {
  name: string;
  parentId: number;
  level: number;
  icon: string;
  image: string;
  markerX: number;
  markerY: number;
  markerColor: string;
}

export const SPACE_TABLE_NAME = 'space';
export const SPACE_CREATE_SQL = `
  CREATE TABLE IF NOT EXISTS ${SPACE_TABLE_NAME} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    parentId INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    icon TEXT DEFAULT '📦',
    image TEXT DEFAULT '',
    markerX REAL DEFAULT 0.5,
    markerY REAL DEFAULT 0.5,
    markerColor TEXT DEFAULT '#5B8DEF'
  )
`;

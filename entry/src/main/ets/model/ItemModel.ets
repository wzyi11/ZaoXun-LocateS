export interface Item {
  id: number;
  name: string;
  category: string;      // 衣物/书籍/数码/厨房/其他
  spaceId: number;       // 关联空间 ID，0 表示未分配
  image: string;         // 图片路径
  purchaseDate: string;  // 购买日期 YYYY-MM-DD
  note: string;          // 备注
  createTime: string;    // 创建时间
}

export const ITEM_TABLE_NAME = 'item';
export const ITEM_CREATE_SQL = `
  CREATE TABLE IF NOT EXISTS ${ITEM_TABLE_NAME} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    category TEXT DEFAULT '其他',
    spaceId INTEGER DEFAULT 0,
    image TEXT DEFAULT '',
    purchaseDate TEXT DEFAULT '',
    note TEXT DEFAULT '',
    createTime TEXT NOT NULL
  )
`;

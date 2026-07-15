export interface Item {
  id: number;
  name: string;
  category: string;      // 衣物/书籍/数码/厨房/其他
  spaceId: number;       // 关联空间 ID，0 表示未分配
  image: string;         // 图片路径
  purchaseDate: string;  // 购买日期 YYYY-MM-DD
  price: string;         // 价格
  quantity: number;      // 数量
  expiryDate: string;    // 保质期 YYYY-MM-DD
  note: string;          // 备注
  createTime: string;    // 创建时间
}

export interface ItemInput {
  name: string;
  category: string;
  spaceId: number;
  image: string;
  purchaseDate: string;
  price: string;
  quantity: number;
  expiryDate: string;
  note: string;
  createTime: string;
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
    price TEXT DEFAULT '0',
    quantity INTEGER DEFAULT 1,
    expiryDate TEXT DEFAULT '',
    note TEXT DEFAULT '',
    createTime TEXT NOT NULL
  )
`;

// 老版本升级用（v1→v2）
export const ITEM_MIGRATE_V2_SQL = [
  `ALTER TABLE ${ITEM_TABLE_NAME} ADD COLUMN price TEXT DEFAULT '0'`,
  `ALTER TABLE ${ITEM_TABLE_NAME} ADD COLUMN quantity INTEGER DEFAULT 1`,
  `ALTER TABLE ${ITEM_TABLE_NAME} ADD COLUMN expiryDate TEXT DEFAULT ''`,
];

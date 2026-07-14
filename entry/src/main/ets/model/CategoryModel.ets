export interface Category {
  id: number;
  name: string;
}

export interface CategoryInput {
  name: string;
}

export const CATEGORY_TABLE_NAME = 'category';
export const CATEGORY_CREATE_SQL = `
  CREATE TABLE IF NOT EXISTS ${CATEGORY_TABLE_NAME} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
  )
`;

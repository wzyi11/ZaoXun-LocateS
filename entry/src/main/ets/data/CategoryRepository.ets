import { relationalStore } from '@kit.ArkData';
import { Category, CategoryInput, CATEGORY_TABLE_NAME } from '../model/CategoryModel';
import { Database } from './Database';

export class CategoryRepository {
  private db: Database = Database.getInstance();

  async insert(input: CategoryInput): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'name': input.name,
    };
    return await store.insert(CATEGORY_TABLE_NAME, valueBucket);
  }

  async getAll(): Promise<Category[]> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(CATEGORY_TABLE_NAME);
    predicates.orderByAsc('id');
    const resultSet = await store.query(predicates, ['id', 'name']);
    const categories: Category[] = [];
    while (resultSet.goToNextRow()) {
      categories.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
      });
    }
    resultSet.close();
    return categories;
  }

  async getByName(name: string): Promise<Category | null> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(CATEGORY_TABLE_NAME);
    predicates.equalTo('name', name);
    const resultSet = await store.query(predicates, ['id', 'name']);
    let category: Category | null = null;
    if (resultSet.goToNextRow()) {
      category = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
      };
    }
    resultSet.close();
    return category;
  }

  async delete(id: number): Promise<number> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(CATEGORY_TABLE_NAME);
    predicates.equalTo('id', id);
    return await store.delete(predicates);
  }
}

import { relationalStore } from '@kit.ArkData';
import { Item, ItemInput, ITEM_TABLE_NAME } from '../model/ItemModel';
import { Database } from './Database';
import { BusinessError } from '@kit.BasicServicesKit';

export class ItemRepository {
  private db: Database = Database.getInstance();

  async insert(item: ItemInput): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'name': item.name,
      'category': item.category,
      'spaceId': item.spaceId,
      'image': item.image,
      'purchaseDate': item.purchaseDate,
      'note': item.note,
      'createTime': item.createTime,
    };
    return await store.insert(ITEM_TABLE_NAME, valueBucket);
  }

  async getAll(): Promise<Item[]> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(ITEM_TABLE_NAME);
    predicates.orderByDesc('createTime');
    const resultSet = await store.query(predicates, ['id', 'name', 'category', 'spaceId', 'image', 'purchaseDate', 'note', 'createTime']);
    const items: Item[] = [];
    while (resultSet.goToNextRow()) {
      items.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        category: resultSet.getString(resultSet.getColumnIndex('category')),
        spaceId: resultSet.getLong(resultSet.getColumnIndex('spaceId')),
        image: resultSet.getString(resultSet.getColumnIndex('image')),
        purchaseDate: resultSet.getString(resultSet.getColumnIndex('purchaseDate')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        createTime: resultSet.getString(resultSet.getColumnIndex('createTime')),
      });
    }
    resultSet.close();
    return items;
  }

  async search(keyword: string): Promise<Item[]> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(ITEM_TABLE_NAME);
    predicates.like('name', `%${keyword}%`);
    predicates.orderByDesc('createTime');
    const resultSet = await store.query(predicates, ['id', 'name', 'category', 'spaceId', 'image', 'purchaseDate', 'note', 'createTime']);
    const items: Item[] = [];
    while (resultSet.goToNextRow()) {
      items.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        category: resultSet.getString(resultSet.getColumnIndex('category')),
        spaceId: resultSet.getLong(resultSet.getColumnIndex('spaceId')),
        image: resultSet.getString(resultSet.getColumnIndex('image')),
        purchaseDate: resultSet.getString(resultSet.getColumnIndex('purchaseDate')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        createTime: resultSet.getString(resultSet.getColumnIndex('createTime')),
      });
    }
    resultSet.close();
    return items;
  }

  async delete(id: number): Promise<number> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(ITEM_TABLE_NAME);
    predicates.equalTo('id', id);
    return await store.delete(predicates);
  }

  async getById(id: number): Promise<Item | null> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(ITEM_TABLE_NAME);
    predicates.equalTo('id', id);
    const resultSet = await store.query(predicates, ['id', 'name', 'category', 'spaceId', 'image', 'purchaseDate', 'note', 'createTime']);
    let item: Item | null = null;
    if (resultSet.goToNextRow()) {
      item = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        category: resultSet.getString(resultSet.getColumnIndex('category')),
        spaceId: resultSet.getLong(resultSet.getColumnIndex('spaceId')),
        image: resultSet.getString(resultSet.getColumnIndex('image')),
        purchaseDate: resultSet.getString(resultSet.getColumnIndex('purchaseDate')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        createTime: resultSet.getString(resultSet.getColumnIndex('createTime')),
      };
    }
    resultSet.close();
    return item;
  }

  async getBySpaceId(spaceId: number): Promise<Item[]> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(ITEM_TABLE_NAME);
    predicates.equalTo('spaceId', spaceId);
    predicates.orderByDesc('createTime');
    const resultSet = await store.query(predicates, ['id', 'name', 'category', 'spaceId', 'image', 'purchaseDate', 'note', 'createTime']);
    const items: Item[] = [];
    while (resultSet.goToNextRow()) {
      items.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        category: resultSet.getString(resultSet.getColumnIndex('category')),
        spaceId: resultSet.getLong(resultSet.getColumnIndex('spaceId')),
        image: resultSet.getString(resultSet.getColumnIndex('image')),
        purchaseDate: resultSet.getString(resultSet.getColumnIndex('purchaseDate')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        createTime: resultSet.getString(resultSet.getColumnIndex('createTime')),
      });
    }
    resultSet.close();
    return items;
  }

  async update(item: Item): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'name': item.name,
      'category': item.category,
      'spaceId': item.spaceId,
      'note': item.note,
    };
    const predicates = new relationalStore.RdbPredicates(ITEM_TABLE_NAME);
    predicates.equalTo('id', item.id);
    return await store.update(valueBucket, predicates);
  }
}

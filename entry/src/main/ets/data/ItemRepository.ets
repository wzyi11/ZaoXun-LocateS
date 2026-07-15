import { relationalStore } from '@kit.ArkData';
import { Item, ItemInput, ITEM_TABLE_NAME } from '../model/ItemModel';
import { Database } from './Database';

const COLUMNS: string[] = [
  'id', 'name', 'category', 'spaceId', 'image',
  'purchaseDate', 'price', 'quantity', 'expiryDate', 'note', 'createTime'
];

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
      'price': item.price,
      'quantity': item.quantity,
      'expiryDate': item.expiryDate,
      'note': item.note,
      'createTime': item.createTime,
    };
    return await store.insert(ITEM_TABLE_NAME, valueBucket);
  }

  async getAll(): Promise<Item[]> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(ITEM_TABLE_NAME);
    predicates.orderByDesc('createTime');
    const resultSet = await store.query(predicates, COLUMNS);
    return this.parseResultSet(resultSet);
  }

  async search(keyword: string): Promise<Item[]> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(ITEM_TABLE_NAME);
    predicates.like('name', `%${keyword}%`);
    predicates.orderByDesc('createTime');
    const resultSet = await store.query(predicates, COLUMNS);
    return this.parseResultSet(resultSet);
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
    const resultSet = await store.query(predicates, COLUMNS);
    const items = this.parseResultSet(resultSet);
    return items.length > 0 ? items[0] : null;
  }

  async getBySpaceId(spaceId: number): Promise<Item[]> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(ITEM_TABLE_NAME);
    predicates.equalTo('spaceId', spaceId);
    predicates.orderByDesc('createTime');
    const resultSet = await store.query(predicates, COLUMNS);
    return this.parseResultSet(resultSet);
  }

  async update(item: Item): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'name': item.name,
      'category': item.category,
      'spaceId': item.spaceId,
      'image': item.image,
      'purchaseDate': item.purchaseDate,
      'price': item.price,
      'quantity': item.quantity,
      'expiryDate': item.expiryDate,
      'note': item.note,
    };
    const predicates = new relationalStore.RdbPredicates(ITEM_TABLE_NAME);
    predicates.equalTo('id', item.id);
    return await store.update(valueBucket, predicates);
  }

  private parseResultSet(resultSet: relationalStore.ResultSet): Item[] {
    const items: Item[] = [];
    while (resultSet.goToNextRow()) {
      items.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        category: resultSet.getString(resultSet.getColumnIndex('category')),
        spaceId: resultSet.getLong(resultSet.getColumnIndex('spaceId')),
        image: resultSet.getString(resultSet.getColumnIndex('image')),
        purchaseDate: resultSet.getString(resultSet.getColumnIndex('purchaseDate')),
        price: resultSet.getString(resultSet.getColumnIndex('price')),
        quantity: resultSet.getLong(resultSet.getColumnIndex('quantity')),
        expiryDate: resultSet.getString(resultSet.getColumnIndex('expiryDate')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        createTime: resultSet.getString(resultSet.getColumnIndex('createTime')),
      });
    }
    resultSet.close();
    return items;
  }
}

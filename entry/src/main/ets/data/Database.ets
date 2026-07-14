import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { ITEM_CREATE_SQL } from '../model/ItemModel';
import { SPACE_CREATE_SQL } from '../model/SpaceModel';
import { EVENT_CREATE_SQL, EVENT_ITEM_CREATE_SQL } from '../model/EventModel';
import { CATEGORY_CREATE_SQL } from '../model/CategoryModel';

const DB_NAME = 'smart_storage.db';
const DB_VERSION = 1;

export class Database {
  private static instance: Database;
  private store: relationalStore.RdbStore | null = null;

  private constructor() {}

  static getInstance(): Database {
    if (!Database.instance) {
      Database.instance = new Database();
    }
    return Database.instance;
  }

  async init(context: common.Context): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1,
    };

    try {
      this.store = await relationalStore.getRdbStore(context, config);
      // 创建所有表
      await this.store.executeSql(ITEM_CREATE_SQL);
      await this.store.executeSql(SPACE_CREATE_SQL);
      await this.store.executeSql(EVENT_CREATE_SQL);
      await this.store.executeSql(EVENT_ITEM_CREATE_SQL);
      await this.store.executeSql(CATEGORY_CREATE_SQL);
      console.info('Database initialized successfully');
    } catch (err) {
      let e = err as BusinessError;
      console.error(`Database init failed: ${e.code}, ${e.message}`);
    }
  }

  getStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('Database not initialized. Call init() first.');
    }
    return this.store;
  }
}

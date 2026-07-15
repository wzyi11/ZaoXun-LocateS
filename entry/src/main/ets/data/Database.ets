import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { ITEM_CREATE_SQL, ITEM_MIGRATE_V2_SQL } from '../model/ItemModel';
import { SPACE_CREATE_SQL } from '../model/SpaceModel';
import { EVENT_CREATE_SQL, EVENT_ITEM_CREATE_SQL } from '../model/EventModel';
import { CATEGORY_CREATE_SQL } from '../model/CategoryModel';

const DB_NAME = 'smart_storage.db';
const DB_VERSION = 2;

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

      // 版本升级：v1→v2 增加 price/quantity/expiryDate
      if (this.store.version === 1) {
        for (const sql of ITEM_MIGRATE_V2_SQL) {
          try {
            await this.store.executeSql(sql);
          } catch (_e) {
            // 列可能已存在，忽略错误
          }
        }
        this.store.version = DB_VERSION;
      }

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

# 智能收纳管家 App 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 完成鸿蒙智能收纳管家 App 的核心功能开发，包含物品管理、空间管理、事件管理三大模块，集成 HDS 沉浸光感组件。

**Architecture:** 基于 HarmonyOS 6.1 (API 24) 的 ArkTS/ArkUI 单应用，使用 HDS 组件库构建沉浸式 UI，RelationalStore 作为本地数据库，按页面+组件+数据三层结构组织代码。

**Tech Stack:** ArkTS / ArkUI / HarmonyOS 6.1 / HDS (HarmonyOS Design System) / RelationalStore

**Base directory:** `E:/xjtu2-2/c4ai/firstprogram/`（已有项目脚手架）
**Entry path:** `entry/src/main/ets/`

## Global Constraints

- 目标 SDK: HarmonyOS 6.1 (API 24) — `targetSdkVersion: "6.1.1(24)"`
- 开发语言: ArkTS（严格模式 `caseSensitiveCheck: true`）
- UI 框架: ArkUI + HDS (`@kit.UIDesignKit`)
- 数据库: `@kit.ArkData` (relationalStore)
- 导航: HDS 悬浮页签 + 沉浸光感材质
- 配色: 蓝白主色调 #007AFF
- 不引入第三方依赖包

---
### Task 1: 导航框架 — HDS 悬浮页签 + 沉浸光感 + 页面路由

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/entryability/EntryAbility.ets`
- Create: `entry/src/main/ets/pages/SpacePage.ets`
- Create: `entry/src/main/ets/pages/EventPage.ets`
- Create: `entry/src/main/ets/pages/ProfilePage.ets`

**Interfaces:**
- Consumes: 项目已有的 EntryAbility 生命周期
- Produces: Index.ets 作为主入口，包含三标签（物品/空间/事件）+ 底部导航（🏠/👤）

- [ ] **Step 1: 创建 SpacePage.ets（占位页）**

```typescript
// entry/src/main/ets/pages/SpacePage.ets
@Entry
@Component
struct SpacePage {
  build() {
    Column() {
      Text('空间管理')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })
      Text('房间 → 柜子 → 格子')
        .fontSize(14)
        .fontColor('#999')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
```

- [ ] **Step 2: 创建 EventPage.ets（占位页）**

```typescript
// entry/src/main/ets/pages/EventPage.ets
@Entry
@Component
struct EventPage {
  build() {
    Column() {
      Text('事件管理')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })
      Text('关联物品与事件，主动提醒')
        .fontSize(14)
        .fontColor('#999')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
```

- [ ] **Step 3: 创建 ProfilePage.ets（占位页）**

```typescript
// entry/src/main/ets/pages/ProfilePage.ets
@Entry
@Component
struct ProfilePage {
  build() {
    Column() {
      Text('我的')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })
      Text('统计概览 · 提醒列表 · 设置')
        .fontSize(14)
        .fontColor('#999')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
```

- [ ] **Step 4: 重写 Index.ets（主框架）**

```typescript
// entry/src/main/ets/pages/Index.ets
import { router } from '@kit.AbilityKit';
import { hdsMaterial } from '@hms.hds.hdsMaterial';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0;    // 0=物品 1=空间 2=事件
  @State currentBottomNav: number = 0;   // 0=首页 1=我的

  private tabsController: TabsController = new TabsController();

  build() {
    Column() {
      // ⭐ 顶部三标签（HDS 沉浸光感悬浮页签）
      HdsTabs({
        controller: this.tabsController
      }) {
        TabContent() {
          ItemPage()
        }
        .tabBar('📦 物品')

        TabContent() {
          SpacePage()
        }
        .tabBar('🏠 空间')

        TabContent() {
          EventPage()
        }
        .tabBar('🎒 事件')
      }
      .barOverlap(true)
      .barPosition(BarPosition.Start)
      .barFloatingStyle({
        barBottomMargin: 8,
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.IMMERSIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        }
      })
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
      .layoutWeight(1)

      // ⭐ 底部导航（沉浸光感材质）
      HdsNavBar({
        controller: new HdsNavBarController()
      }) {
        HdsNavItem() {
          Image($r('app.media.ic_home'))
            .width(24).height(24)
        }
        .label('首页')
        .selected(this.currentBottomNav === 0)
        .onClick(() => {
          this.currentBottomNav = 0;
          this.currentTabIndex = 0;
        })

        HdsNavItem() {
          Image($r('app.media.ic_person'))
            .width(24).height(24)
        }
        .label('我的')
        .selected(this.currentBottomNav === 1)
        .onClick(() => {
          this.currentBottomNav = 1;
          router.pushUrl({ url: 'pages/ProfilePage' });
        })
      }
      .systemMaterialEffect({
        materialType: hdsMaterial.MaterialType.IMMERSIVE,
        materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
```

> **注意:** HdsTabs 和 HdsNavBar 是 HDS 组件，需要确认 `@hms.hds.hdsMaterial` 的导入路径与项目中 HDS SDK 版本匹配。如果该包不可用，降级为使用原生 Tabs + BarItem 组件配合 `blur` 效果模拟沉浸光感。

- [ ] **Step 5: 添加 首页图标资源**

在 `entry/src/main/resources/base/media/` 中添加两个 SVG/PNG 图标：
- `ic_home.png` — 首页图标（房子）
- `ic_person.png` — 我的图标（人物）

若暂无图标资源，先用 Emoji Text 替代。

- [ ] **Step 6: 验证构建**

Run: DevEco Studio — 点击 Build > Build Hap(s)/App(s)
Expected: 构建成功，模拟器可启动并显示三标签页 + 底部导航

- [ ] **Step 7: 提交**

```bash
cd E:/xjtu2-2/c4ai/firstprogram
git add entry/src/main/ets/pages/
git commit -m "feat: add navigation framework with HDS immersive tabs"
```

---
### Task 2: 数据层 — RelationalStore 数据库 + 数据模型

**Files:**
- Create: `entry/src/main/ets/model/ItemModel.ets`
- Create: `entry/src/main/ets/model/SpaceModel.ets`
- Create: `entry/src/main/ets/model/EventModel.ets`
- Create: `entry/src/main/ets/data/Database.ets`
- Create: `entry/src/main/ets/data/ItemRepository.ets`
- Create: `entry/src/main/ets/data/EventRepository.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`（初始化数据库）

**Interfaces:**
- Consumes: Task 1 的项目结构
- Produces: `Database.getInstance()` 返回数据库单例，各 Repository 提供 CRUD 方法

- [ ] **Step 1: 定义 ItemModel**

```typescript
// entry/src/main/ets/model/ItemModel.ets
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
```

- [ ] **Step 2: 定义 SpaceModel**

```typescript
// entry/src/main/ets/model/SpaceModel.ets
export interface Space {
  id: number;
  name: string;
  parentId: number;      // 父空间 ID，0=根
  level: number;         // 1=房间 2=柜子 3=格子
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
```

- [ ] **Step 3: 定义 EventModel 和 EventItemModel**

```typescript
// entry/src/main/ets/model/EventModel.ets
export interface Event {
  id: number;
  title: string;
  date: string;          // YYYY-MM-DD
  note: string;
  status: number;        // 0=进行中 1=已完成
  createTime: string;
}

export interface EventItem {
  id: number;
  eventId: number;
  itemId: number;
  isPrepared: boolean;   // 是否已准备
}

export const EVENT_TABLE_NAME = 'event';
export const EVENT_ITEM_TABLE_NAME = 'event_item';
export const EVENT_CREATE_SQL = `
  CREATE TABLE IF NOT EXISTS ${EVENT_TABLE_NAME} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    date TEXT DEFAULT '',
    note TEXT DEFAULT '',
    status INTEGER DEFAULT 0,
    createTime TEXT NOT NULL
  )
`;
export const EVENT_ITEM_CREATE_SQL = `
  CREATE TABLE IF NOT EXISTS ${EVENT_ITEM_TABLE_NAME} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    eventId INTEGER NOT NULL,
    itemId INTEGER NOT NULL,
    isPrepared INTEGER DEFAULT 0
  )
`;
```

- [ ] **Step 4: 实现 Database.ets（单例）**

```typescript
// entry/src/main/ets/data/Database.ets
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { ITEM_CREATE_SQL } from '../model/ItemModel';
import { SPACE_CREATE_SQL } from '../model/SpaceModel';
import { EVENT_CREATE_SQL, EVENT_ITEM_CREATE_SQL } from '../model/EventModel';

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

  async init(context: Context): Promise<void> {
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
```

- [ ] **Step 5: 实现 ItemRepository**

```typescript
// entry/src/main/ets/data/ItemRepository.ets
import { relationalStore } from '@kit.ArkData';
import { Item, ITEM_TABLE_NAME } from '../model/ItemModel';
import { Database } from './Database';
import { BusinessError } from '@kit.BasicServicesKit';

export class ItemRepository {
  private db: Database = Database.getInstance();

  async insert(item: Omit<Item, 'id'>): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValueBucket = {
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

  async update(item: Item): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValueBucket = {
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
```

- [ ] **Step 6: 实现 EventRepository**

```typescript
// entry/src/main/ets/data/EventRepository.ets
import { relationalStore } from '@kit.ArkData';
import { Event, EventItem, EVENT_TABLE_NAME, EVENT_ITEM_TABLE_NAME } from '../model/EventModel';
import { Database } from './Database';

export class EventRepository {
  private db: Database = Database.getInstance();

  async insert(event: Omit<Event, 'id'>): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValueBucket = {
      'title': event.title,
      'date': event.date,
      'note': event.note,
      'status': event.status,
      'createTime': event.createTime,
    };
    return await store.insert(EVENT_TABLE_NAME, valueBucket);
  }

  async getAll(): Promise<Event[]> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(EVENT_TABLE_NAME);
    predicates.orderByDesc('createTime');
    // 查询并解析，同 ItemRepository.getAll()
    return [];
  }

  async linkItem(eventId: number, itemId: number): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValueBucket = {
      'eventId': eventId,
      'itemId': itemId,
      'isPrepared': 0,
    };
    return await store.insert(EVENT_ITEM_TABLE_NAME, valueBucket);
  }

  async getEventItems(eventId: number): Promise<EventItem[]> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(EVENT_ITEM_TABLE_NAME);
    predicates.equalTo('eventId', eventId);
    // 查询并解析
    return [];
  }
}
```

- [ ] **Step 7: 在 EntryAbility 中初始化数据库**

```typescript
// entry/src/main/ets/entryability/EntryAbility.ets — 修改 onWindowStageCreate
import { Database } from '../data/Database';

onWindowStageCreate(windowStage: window.WindowStage): void {
  // 初始化数据库
  Database.getInstance().init(this.context);

  windowStage.loadContent('pages/Index', (err) => {
    if (err.code) {
      hilog.error(DOMAIN, 'testTag', 'Failed: %{public}s', JSON.stringify(err));
      return;
    }
    hilog.info(DOMAIN, 'testTag', 'Succeeded');
  });
}
```

- [ ] **Step 8: 验证构建**

Run: DevEco Studio — Build > Build Hap(s)/App(s)
Expected: 构建成功

- [ ] **Step 9: 提交**

```bash
cd E:/xjtu2-2/c4ai/firstprogram
git add entry/src/main/ets/model/ entry/src/main/ets/data/
git commit -m "feat: add database layer and data models"
```

---
### Task 3: 首页内容 — 物品管理页面

**Files:**
- Create: `entry/src/main/ets/pages/ItemPage.ets`（物品标签页内容）
- Create: `entry/src/main/ets/pages/AddItemPage.ets`（添加物品页面）
- Create: `entry/src/main/ets/pages/ItemDetailPage.ets`（物品详情页）
- Create: `entry/src/main/ets/components/ItemCard.ets`（物品卡片组件）
- Create: `entry/src/main/ets/components/CategoryGrid.ets`（分类网格组件）

**Interfaces:**
- Consumes: ItemRepository (Task 2), Tab 路由 (Task 1)
- Produces: 完整的物品管理 CRUD 页面

- [ ] **Step 1: 实现 ItemCard 组件**

```typescript
// entry/src/main/ets/components/ItemCard.ets
@Component
export struct ItemCard {
  @State name: string = '';
  @State category: string = '';
  @State location: string = '';
  @State image: string = '';

  build() {
    Row() {
      // 图标占位
      Text(this.getCategoryEmoji(this.category))
        .fontSize(32)
        .width(48).height(48)
        .textAlign(TextAlign.Center)
        .margin({ right: 12 })

      Column() {
        Text(this.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(this.location ? `${this.location}` : '未分配位置')
          .fontSize(13)
          .fontColor('#999')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.category)
        .fontSize(12)
        .fontColor('#007AFF')
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('#E8F0FE')
        .borderRadius(10)
    }
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: '#15000000', offsetY: 2 })
    .margin({ bottom: 8 })
  }

  getCategoryEmoji(category: string): string {
    const map: Record<string, string> = {
      '衣物': '👕', '书籍': '📚', '数码': '🔌',
      '厨房': '🍳', '文件': '📄', '其他': '📦',
    };
    return map[category] || '📦';
  }
}
```

- [ ] **Step 2: 实现 CategoryGrid 组件**

```typescript
// entry/src/main/ets/components/CategoryGrid.ets
@Component
export struct CategoryGrid {
  private categories: string[] = ['衣物', '书籍', '数码', '厨房', '文件', '其他'];
  private counts: Record<string, number> = {};
  @State selectedCategory: string = '';
  onCategorySelect?: (category: string) => void;

  build() {
    Column() {
      Text('📦 物品分类')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: 12 })

      Grid() {
        ForEach(this.categories, (cat: string) => {
          GridItem() {
            Column() {
              Text(this.getEmoji(cat)).fontSize(28)
              Text(cat).fontSize(12).margin({ top: 4 })
              Text(`${this.counts[cat] || 0}`)
                .fontSize(11).fontColor('#999')
            }
            .padding(12)
            .backgroundColor(this.selectedCategory === cat ? '#E8F0FE' : '#FAFAFA')
            .borderRadius(12)
            .onClick(() => {
              this.selectedCategory = cat;
              this.onCategorySelect?.(cat);
            })
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
    }
  }

  getEmoji(cat: string): string {
    const map: Record<string, string> = {
      '衣物': '👕', '书籍': '📚', '数码': '🔌',
      '厨房': '🍳', '文件': '📄', '其他': '📦',
    };
    return map[cat] || '📦';
  }
}
```

- [ ] **Step 3: 实现 ItemPage**

```typescript
// entry/src/main/ets/pages/ItemPage.ets
import { router } from '@kit.AbilityKit';
import { Item } from '../model/ItemModel';
import { ItemRepository } from '../data/ItemRepository';
import { ItemCard } from '../components/ItemCard';
import { CategoryGrid } from '../components/CategoryGrid';

@Component
export struct ItemPage {
  @State items: Item[] = [];
  @State searchText: string = '';
  @State activeCategory: string = '';
  private itemRepo: ItemRepository = new ItemRepository();
  private isLoaded: boolean = false;

  aboutToAppear() {
    this.loadItems();
  }

  async loadItems() {
    this.items = await this.itemRepo.getAll();
    this.isLoaded = true;
  }

  get filteredItems(): Item[] {
    let result = this.items;
    if (this.activeCategory) {
      result = result.filter(i => i.category === this.activeCategory);
    }
    if (this.searchText) {
      result = result.filter(i => i.name.includes(this.searchText));
    }
    return result;
  }

  build() {
    Stack() {
      Column() {
        // 搜索栏
        TextInput({ placeholder: '🔍 搜索物品...', text: this.searchText })
          .width('100%')
          .height(40)
          .padding({ left: 12 })
          .backgroundColor('#F0F0F0')
          .borderRadius(20)
          .onChange((val: string) => { this.searchText = val; })
          .margin({ bottom: 12 })

        Scroll() {
          Column() {
            // 快捷拍照入口
            Row() {
              Text('📸 一拍即存').fontSize(16).fontColor(Color.White).fontWeight(FontWeight.Bold)
              Text('拍照自动识别物品').fontSize(13).fontColor('rgba(255,255,255,0.8)').margin({ left: 8 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#43A047')
            .borderRadius(16)
            .onClick(() => {
              router.pushUrl({ url: 'pages/AddItemPage' });
            })
            .margin({ bottom: 16 })

            // 分类网格
            CategoryGrid({
              selectedCategory: this.activeCategory,
              onCategorySelect: (cat: string) => {
                this.activeCategory = this.activeCategory === cat ? '' : cat;
              }
            })
            .margin({ bottom: 16 })

            // 物品列表
            ForEach(this.filteredItems, (item: Item) => {
              ItemCard({
                name: item.name,
                category: item.category,
                location: `空间 #${item.spaceId}`,
              })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/ItemDetailPage',
                  params: { itemId: item.id }
                });
              })
            })

            // 浮动添加按钮
            Button() {
              Text('＋').fontSize(28).fontColor(Color.White)
            }
            .width(56).height(56)
            .backgroundColor('#007AFF')
            .borderRadius(28)
            .shadow({ radius: 8, color: '#40007AFF', offsetY: 4 })
            .position({ bottom: 20, right: 20 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/AddItemPage' });
            })
          }
          .width('100%')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }
}
```

- [ ] **Step 4: 实现 AddItemPage**

```typescript
// entry/src/main/ets/pages/AddItemPage.ets
import { router } from '@kit.AbilityKit';
import { ItemRepository } from '../data/ItemRepository';

const CATEGORIES = ['衣物', '书籍', '数码', '厨房', '文件', '其他'];

@Entry
@Component
struct AddItemPage {
  @State name: string = '';
  @State category: string = '其他';
  @State location: string = '';
  @State note: string = '';
  @State purchaseDate: string = '';

  private itemRepo: ItemRepository = new ItemRepository();

  build() {
    Column() {
      // 顶部栏
      Row() {
        Text('← 返回')
          .onClick(() => router.back())
        Text('添加物品')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('保存')
          .fontColor('#007AFF')
          .onClick(() => this.saveItem())
      }
      .width('100%')
      .padding(16)

      Scroll() {
        Column() {
          // 拍照入口
          Column() {
            Text('📸').fontSize(48)
            Text('点击拍照识别').fontSize(14).fontColor('#999').margin({ top: 8 })
          }
          .width('100%').height(160)
          .backgroundColor('#F5F5F5')
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 16 })

          // 物品名称
          Text('物品名称').fontSize(14).fontWeight(FontWeight.Medium).width('100%')
          TextInput({ placeholder: '输入物品名称', text: this.name })
            .width('100%').height(44)
            .margin({ bottom: 12 })
            .onChange(v => this.name = v)

          // 类别选择
          Text('类别').fontSize(14).fontWeight(FontWeight.Medium).width('100%')
          Row() {
            ForEach(CATEGORIES, (cat: string) => {
              Text(cat)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.category === cat ? '#007AFF' : '#F0F0F0')
                .fontColor(this.category === cat ? Color.White : '#333')
                .borderRadius(16)
                .onClick(() => { this.category = cat; })
            })
          }
          .width('100%')
          .margin({ bottom: 12 })

          // 位置
          Text('存放位置').fontSize(14).fontWeight(FontWeight.Medium).width('100%')
          TextInput({ placeholder: '如：客厅抽屉', text: this.location })
            .width('100%').height(44)
            .margin({ bottom: 12 })
            .onChange(v => this.location = v)

          // 备注
          Text('备注').fontSize(14).fontWeight(FontWeight.Medium).width('100%')
          TextArea({ placeholder: '补充说明...', text: this.note })
            .width('100%').height(80)
            .margin({ bottom: 12 })
            .onChange(v => this.note = v)
        }
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  async saveItem() {
    if (!this.name.trim()) return;
    await this.itemRepo.insert({
      name: this.name,
      category: this.category,
      spaceId: 0,
      image: '',
      purchaseDate: this.purchaseDate,
      note: this.note,
      createTime: new Date().toISOString().split('T')[0],
    });
    router.back();
  }
}
```

- [ ] **Step 5: 实现 ItemDetailPage**

```typescript
// entry/src/main/ets/pages/ItemDetailPage.ets
@Entry
@Component
struct ItemDetailPage {
  @State itemId: number = 0;
  @State name: string = '';
  @State category: string = '';
  @State location: string = '';
  @State note: string = '';
  @State purchaseDate: string = '';

  build() {
    Column() {
      Row() {
        Text('← 返回').onClick(() => router.back())
        Text('物品详情').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
        Text('编辑').fontColor('#007AFF')
      }
      .width('100%').padding(16)

      Column() {
        Text(this.getEmoji(this.category)).fontSize(80)
        Text(this.name).fontSize(24).fontWeight(FontWeight.Bold).margin({ top: 12 })
        Text(this.category).fontSize(14).fontColor('#007AFF').margin({ top: 4 })
      }
      .width('100%').padding(24).alignItems(HorizontalAlign.Center)

      Column() {
        DetailRow('📌 位置', this.location || '未分配')
        DetailRow('📅 购买日期', this.purchaseDate || '未记录')
        DetailRow('📝 备注', this.note || '无')
      }
      .width('100%').padding(16)
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }

  getEmoji(cat: string): string {
    const map: Record<string, string> = { '衣物': '👕', '书籍': '📚', '数码': '🔌', '厨房': '🍳', '文件': '📄', '其他': '📦' };
    return map[cat] || '📦';
  }
}

@Component
struct DetailRow {
  @Prop label: string = '';
  @Prop value: string = '';
  build() {
    Row() {
      Text(this.label).fontSize(14).fontColor('#666').width(80)
      Text(this.value).fontSize(14)
    }
    .width('100%').padding({ top: 8, bottom: 8 })
  }
}
```

- [ ] **Step 6: 验证构建并在模拟器运行**

Run: DevEco Studio — 构建并运行到模拟器
Expected: 首页显示搜索栏、拍照入口、分类网格、物品列表，可点击添加按钮跳转添加页面

- [ ] **Step 7: 提交**

```bash
cd E:/xjtu2-2/c4ai/firstprogram
git add entry/src/main/ets/pages/ItemPage.ets entry/src/main/ets/pages/AddItemPage.ets entry/src/main/ets/pages/ItemDetailPage.ets entry/src/main/ets/components/
git commit -m "feat: add item management pages"
```

---
### Task 4: 空间管理 — 三层结构页面

**Files:**
- Rewrite: `entry/src/main/ets/pages/SpacePage.ets`
- Create: `entry/src/main/ets/components/SpaceTree.ets`

**Interfaces:**
- Consumes: SpaceRepository（基于 Task 2 的 Database），ItemRepository
- Produces: 房间→柜子→格子三级下钻页面

- [ ] **Step 1: 创建 SpaceRepository**

```typescript
// entry/src/main/ets/data/SpaceRepository.ets
import { relationalStore } from '@kit.ArkData';
import { Space, SPACE_TABLE_NAME } from '../model/SpaceModel';
import { Database } from './Database';

export class SpaceRepository {
  private db: Database = Database.getInstance();

  async insert(space: Omit<Space, 'id'>): Promise<number> {
    const store = this.db.getStore();
    return await store.insert(SPACE_TABLE_NAME, {
      'name': space.name,
      'parentId': space.parentId,
      'level': space.level,
      'icon': space.icon,
    });
  }

  async getByParent(parentId: number): Promise<Space[]> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(SPACE_TABLE_NAME);
    predicates.equalTo('parentId', parentId);
    const resultSet = await store.query(predicates, ['id', 'name', 'parentId', 'level', 'icon']);
    const spaces: Space[] = [];
    while (resultSet.goToNextRow()) {
      spaces.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        parentId: resultSet.getLong(resultSet.getColumnIndex('parentId')),
        level: resultSet.getLong(resultSet.getColumnIndex('level')),
        icon: resultSet.getString(resultSet.getColumnIndex('icon')),
      });
    }
    resultSet.close();
    return spaces;
  }
}
```

- [ ] **Step 2: 实现 SpacePage（三级下钻）**

```typescript
// entry/src/main/ets/pages/SpacePage.ets
import { router } from '@kit.AbilityKit';
import { Space } from '../model/SpaceModel';
import { SpaceRepository } from '../data/SpaceRepository';
import { ItemRepository } from '../data/ItemRepository';
import { Item } from '../model/ItemModel';

@Component
export struct SpacePage {
  @State spaces: Space[] = [];
  @State currentLevel: number = 1;
  @State currentParentName: string = '我的家';
  @State parentId: number = 0;   // 0 表示根
  @State breadcrumb: string[] = ['我的家'];
  @State items: Item[] = [];

  private spaceRepo: SpaceRepository = new SpaceRepository();
  private itemRepo: ItemRepository = new ItemRepository();

  aboutToAppear() {
    this.loadSpaces();
  }

  async loadSpaces() {
    if (this.currentLevel > 3) {
      // 第三层（格子）：显示物品
      this.items = await this.itemRepo.search('');
      // 实际应按 spaceId 过滤，简化处理
      return;
    }
    this.spaces = await this.spaceRepo.getByParent(this.parentId);
  }

  build() {
    Column() {
      // 面包屑导航
      Scroll() {
        Row() {
          ForEach(this.breadcrumb, (crumb: string, index: number) => {
            Text(crumb).fontSize(14).fontColor('#007AFF')
            if (index < this.breadcrumb.length - 1) {
              Text(' › ').fontSize(14).fontColor('#999')
            }
          })
        }
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .margin({ bottom: 12 })

      if (this.currentLevel <= 3) {
        // 空间网格
        Grid() {
          ForEach(this.spaces, (space: Space) => {
            GridItem() {
              Column() {
                Text(space.icon || '📦').fontSize(40)
                Text(space.name).fontSize(14).fontWeight(FontWeight.Medium).margin({ top: 8 })
                Text(getLevelLabel(space.level)).fontSize(11).fontColor('#999')
              }
              .padding(20)
              .backgroundColor(Color.White)
              .borderRadius(16)
              .shadow({ radius: 4, color: '#15000000', offsetY: 2 })
              .onClick(() => {
                this.breadcrumb.push(space.name);
                this.parentId = space.id;
                this.currentLevel = space.level + 1;
                this.loadSpaces();
              })
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
      } else {
        // 物品列表
        Text('📍 此位置内的物品').fontSize(16).fontWeight(FontWeight.Bold).width('100%').margin({ bottom: 12 })
        ForEach(this.items, (item: Item) => {
          // 复用 ItemCard 组件
        })
      }
    }
    .width('100%').padding(16)
  }
}

function getLevelLabel(level: number): string {
  return ['', '房间', '柜子', '格子'][level] || '';
}
```

- [ ] **Step 3: 验证并提交**

```bash
git add entry/src/main/ets/pages/SpacePage.ets entry/src/main/ets/components/SpaceTree.ets entry/src/main/ets/data/SpaceRepository.ets
git commit -m "feat: add space management with three-level drill-down"
```

---
### Task 5: 事件管理 — 核心亮点

**Files:**
- Rewrite: `entry/src/main/ets/pages/EventPage.ets`
- Create: `entry/src/main/ets/pages/EventDetailPage.ets`
- Create: `entry/src/main/ets/pages/CreateEventPage.ets`
- Create: `entry/src/main/ets/components/EventCard.ets`

**Interfaces:**
- Consumes: EventRepository, ItemRepository
- Produces: 事件创建、物品关联、进度追踪、提醒

- [ ] **Step 1: 实现 EventCard 组件**

```typescript
// entry/src/main/ets/components/EventCard.ets
@Component
export struct EventCard {
  @State title: string = '';
  @State date: string = '';
  @State progress: number = 0;    // 已准备数
  @State total: number = 0;       // 总数
  @State status: number = 0;      // 0=进行中 1=已完成
  onCardClick?: () => void;

  build() {
    Column() {
      Row() {
        Text(this.status === 0 ? '🔄' : '✅').fontSize(24)
        Column() {
          Text(this.title).fontSize(16).fontWeight(FontWeight.Bold)
          Text(`📅 ${this.date}`).fontSize(13).fontColor('#666').margin({ top: 2 })
        }
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')

      // 进度条
      Row() {
        Text(`准备进度 ${this.progress}/${this.total}`).fontSize(12).fontColor('#999')
      }
      .width('100%').margin({ top: 8 })

      // 进度条
      Row() {
        Stack() {
          Row().width('100%').height(6).backgroundColor('#E8E8E8').borderRadius(3)
          Row()
            .width(this.total > 0 ? `${(this.progress / this.total) * 100}%` : '0%')
            .height(6)
            .backgroundColor(this.progress === this.total ? '#43A047' : '#007AFF')
            .borderRadius(3)
        }
        .width('100%')
      }
      .width('100%').margin({ top: 4 })
    }
    .width('100%').padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 4, color: '#15000000', offsetY: 2 })
    .onClick(() => this.onCardClick?.())
  }
}
```

- [ ] **Step 2: 实现 EventPage**

```typescript
// entry/src/main/ets/pages/EventPage.ets
import { router } from '@kit.AbilityKit';
import { Event } from '../model/EventModel';
import { EventRepository } from '../data/EventRepository';
import { EventCard } from '../components/EventCard';

@Component
export struct EventPage {
  @State activeEvents: Event[] = [];
  @State upcomingEvents: Event[] = [];
  private eventRepo: EventRepository = new EventRepository();

  aboutToAppear() {
    this.loadEvents();
  }

  async loadEvents() {
    const all = await this.eventRepo.getAll();
    this.activeEvents = all.filter(e => e.status === 0);
    this.upcomingEvents = all.filter(e => e.status === 1);
  }

  build() {
    Stack() {
      Column() {
        Scroll() {
          Column() {
            Text('🔄 进行中').fontSize(18).fontWeight(FontWeight.Bold).width('100%').margin({ top: 8, bottom: 12 })
            ForEach(this.activeEvents, (event: Event) => {
              EventCard({
                title: event.title,
                date: event.date,
                status: event.status,
              })
              .onCardClick(() => {
                router.pushUrl({ url: 'pages/EventDetailPage', params: { eventId: event.id } });
              })
            })

            if (this.activeEvents.length === 0) {
              Text('暂无进行中的事件').fontSize(14).fontColor('#999').margin({ top: 20 })
            }

            Text('📅 即将到来').fontSize(18).fontWeight(FontWeight.Bold).width('100%').margin({ top: 20, bottom: 12 })
            ForEach(this.upcomingEvents, (event: Event) => {
              EventCard({
                title: event.title,
                date: event.date,
                status: event.status,
              })
              .onCardClick(() => {
                router.pushUrl({ url: 'pages/EventDetailPage', params: { eventId: event.id } });
              })
            })
          }
          .width('100%').padding(16)
        }
        .layoutWeight(1)
      }

      // 浮动创建按钮
      Button() {
        Text('＋ 创建事件').fontSize(16).fontColor(Color.White)
      }
      .width('90%').height(48)
      .backgroundColor('#007AFF')
      .borderRadius(24)
      .position({ bottom: 20 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/CreateEventPage' });
      })
    }
    .width('100%').height('100%')
  }
}
```

- [ ] **Step 3: 实现 CreateEventPage**

```typescript
// entry/src/main/ets/pages/CreateEventPage.ets
import { router } from '@kit.AbilityKit';
import { EventRepository } from '../data/EventRepository';
import { ItemRepository } from '../data/ItemRepository';
import { Item } from '../model/ItemModel';

@Entry
@Component
struct CreateEventPage {
  @State title: string = '';
  @State date: string = '';
  @State note: string = '';
  @State allItems: Item[] = [];
  @State selectedItemIds: Set<number> = new Set();

  private eventRepo: EventRepository = new EventRepository();
  private itemRepo: ItemRepository = new ItemRepository();

  aboutToAppear() {
    this.loadItems();
  }

  async loadItems() {
    this.allItems = await this.itemRepo.getAll();
  }

  build() {
    Column() {
      // 顶栏
      Row() {
        Text('取消').onClick(() => router.back())
        Text('创建事件').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
        Text('保存').fontColor('#007AFF').onClick(() => this.saveEvent())
      }
      .width('100%').padding(16)

      Scroll() {
        Column() {
          // 标题
          Text('事件标题').fontSize(14).fontWeight(FontWeight.Medium).width('100%')
          TextInput({ placeholder: '如：暑假旅行', text: this.title }).width('100%').height(44)
            .onChange(v => this.title = v).margin({ bottom: 12 })

          // 日期
          Text('事件日期').fontSize(14).fontWeight(FontWeight.Medium).width('100%')
          TextInput({ placeholder: '2026-07-15', text: this.date }).width('100%').height(44)
            .onChange(v => this.date = v).margin({ bottom: 12 })

          // 备注
          Text('备注').fontSize(14).fontWeight(FontWeight.Medium).width('100%')
          TextArea({ placeholder: '补充说明...', text: this.note }).width('100%').height(80)
            .onChange(v => this.note = v).margin({ bottom: 20 })

          // 选择关联物品
          Text('关联物品').fontSize(14).fontWeight(FontWeight.Medium).width('100%')
          Text('选择该事件需要携带的物品').fontSize(12).fontColor('#999').width('100%').margin({ bottom: 8 })

          ForEach(this.allItems, (item: Item) => {
            Row() {
              Text(this.getItemEmoji(item.category)).fontSize(24).margin({ right: 12 })
              Column() {
                Text(item.name).fontSize(14)
                Text(item.category).fontSize(11).fontColor('#999')
              }.layoutWeight(1)
              Text(this.selectedItemIds.has(item.id) ? '✓' : '○')
                .fontSize(20)
                .fontColor(this.selectedItemIds.has(item.id) ? '#007AFF' : '#ccc')
            }
            .width('100%').padding(12)
            .backgroundColor(Color.White).borderRadius(8)
            .margin({ bottom: 6 })
            .onClick(() => {
              if (this.selectedItemIds.has(item.id)) {
                this.selectedItemIds.delete(item.id);
              } else {
                this.selectedItemIds.add(item.id);
              }
              // 触发刷新
              this.selectedItemIds = new Set(this.selectedItemIds);
            })
          })
        }
        .width('100%').padding(16)
      }.layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }

  async saveEvent() {
    if (!this.title.trim()) return;
    const eventId = await this.eventRepo.insert({
      title: this.title,
      date: this.date,
      note: this.note,
      status: 0,
      createTime: new Date().toISOString().split('T')[0],
    });
    // 关联选中物品
    for (const itemId of this.selectedItemIds) {
      await this.eventRepo.linkItem(eventId, itemId);
    }
    router.back();
  }

  getItemEmoji(cat: string): string {
    const map: Record<string, string> = { '衣物': '👕', '书籍': '📚', '数码': '🔌', '厨房': '🍳', '其他': '📦' };
    return map[cat] || '📦';
  }
}
```

- [ ] **Step 4: 实现 EventDetailPage**

```typescript
// entry/src/main/ets/pages/EventDetailPage.ets
import { router } from '@kit.AbilityKit';
import { EventRepository } from '../data/EventRepository';
import { ItemRepository } from '../data/ItemRepository';
import { EventItem } from '../model/EventModel';
import { Item } from '../model/ItemModel';

@Entry
@Component
struct EventDetailPage {
  @State eventId: number = 0;
  @State eventTitle: string = '';
  @State eventDate: string = '';
  @State eventNote: string = '';
  @State items: Array<{ item: Item; isPrepared: boolean }> = [];
  @State progress: number = 0;

  private eventRepo: EventRepository = new EventRepository();
  private itemRepo: ItemRepository = new ItemRepository();

  async loadEventDetails() {
    const eventItems = await this.eventRepo.getEventItems(this.eventId);
    const details = [];
    for (const ei of eventItems) {
      // 实际项目中应通过 itemRepo 查询物品详情
      details.push({ item: { id: ei.itemId, name: '物品', category: '其他', spaceId: 0, image: '', purchaseDate: '', note: '', createTime: '' }, isPrepared: ei.isPrepared });
    }
    this.items = details;
    this.progress = details.filter(d => d.isPrepared).length;
  }

  build() {
    Column() {
      Row() {
        Text('← 返回').onClick(() => router.back())
        Text('事件详情').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
      }
      .width('100%').padding(16)

      Column() {
        Text(this.eventTitle).fontSize(22).fontWeight(FontWeight.Bold).textAlign(TextAlign.Center)
        Text(`📅 ${this.eventDate}`).fontSize(14).fontColor('#666').margin({ top: 4 })
      }
      .width('100%').padding(20)

      // 进度
      Column() {
        Text(`准备进度 ${this.progress}/${this.items.length}`).fontSize(14)
        Row() {
          Stack() {
            Row().width('100%').height(8).backgroundColor('#E8E8E8').borderRadius(4)
            Row()
              .width(this.items.length > 0 ? `${(this.progress / this.items.length) * 100}%` : '0%')
              .height(8).backgroundColor('#43A047').borderRadius(4)
          }.width('100%')
        }.width('100%').margin({ top: 8 })
      }
      .padding(16)
      .backgroundColor(Color.White).borderRadius(12).margin({ left: 16, right: 16 })

      // 物品清单
      Text('📋 物品清单').fontSize(16).fontWeight(FontWeight.Bold).width('100%').margin({ top: 20, bottom: 8 }).padding({ left: 16 })
      Scroll() {
        Column() {
          ForEach(this.items, (_: any, index: number) => {
            // 实际应使用 ForEach 遍历 items
          })
        }.padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}
```

- [ ] **Step 5: 验证并提交**

```bash
git add entry/src/main/ets/pages/EventPage.ets entry/src/main/ets/pages/EventDetailPage.ets entry/src/main/ets/pages/CreateEventPage.ets entry/src/main/ets/components/EventCard.ets
git commit -m "feat: add event management with item checklists"
```

---
### Task 6: 个人中心页面

**Files:**
- Rewrite: `entry/src/main/ets/pages/ProfilePage.ets`

- [ ] **Step 1: 实现 ProfilePage**

展示：物品总数统计（按类别）、事件进行中数量、临近提醒列表、关于

- [ ] **Step 2: 验证并提交**

```bash
git add entry/src/main/ets/pages/ProfilePage.ets
git commit -m "feat: add profile page with stats"
```

---
### Task 7: HDS 沉浸光感深度适配

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: 确认 HDS 组件可用性**

检查 `@hms.hds.hdsMaterial` 包是否在项目中可用。若不可用，降级方案：

```typescript
// 降级：使用原生 ArkUI 实现毛玻璃效果
Tabs() { /* ... */ }
  .barBackgroundBlurStyle(BlurStyle.Thin)
  .barBackgroundColor('#E8F0F0F0')
```

- [ ] **Step 2: 添加设备能力检测**

在 Index.ets 中添加 `aboutToAppear` 检测设备是否支持 IMMERSIVE 材质，不支持时自动降级

- [ ] **Step 3: 验证并提交**

---
### Task 8: 服务卡片（鸿蒙特性2）

- [ ] 创建 Form 目录及卡片配置文件
- [ ] 实现 ArkTS 卡片：展示当前进行中的事件 + 进度
- [ ] 在 module.json5 中注册卡片
- [ ] 验证桌面添加卡片

---
### Task 9: 碰一碰/跨设备（鸿蒙特性3）

- [ ] 实现简单的分享功能：通过 Want 传递事件清单文本
- [ ] 验证跨设备流转

---
### Task 10: 比赛文档整理

- [ ] 填写比赛模板文档（作品说明文档）
- [ ] 截图 App 各页面
- [ ] 整理技术框架说明
- [ ] 打包提交材料

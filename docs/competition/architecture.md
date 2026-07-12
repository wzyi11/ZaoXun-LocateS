# Smart Storage (智能收纳管家) — Architecture

> HarmonyOS 6.1 ArkTS · API 24 · RelationalStore · ArkUI native · target SDK 6.1.1(24)

## App Entry

| Item | Detail |
|------|--------|
| EntryAbility | `entry/src/main/ets/entryability/EntryAbility.ets` |
| Main page | `pages/Index` (top tabs + bottom nav) |
| Database init | `Database.getInstance().init(this.context)` in `onWindowStageCreate` |
| Immersive | `mainWindow.setWindowLayoutFullScreen(true)` |

## Route Map (main_pages.json)

```
pages/Index              — Home (tabs: 物品/空间/事件 + bottom nav: 首页/我的)
pages/SpacePage          — Space drill-down (embedded in Index, also routable)
pages/EventPage          — Event list (embedded in Index, also routable)
pages/ProfilePage        — Profile dashboard (pushed from bottom nav)
pages/AddItemPage        — Add item form (pushed from ItemPage FAB)
pages/ItemDetailPage     — Item detail + delete (pushed from ItemPage list tap)
pages/CreateEventPage    — Create event + link items (pushed from EventPage FAB)
pages/EventDetailPage    — Event detail + checklist + share + complete (pushed from EventPage tap)
```

## Layer Architecture

```
┌─────────────────────────────────────────────────┐
│  Pages (entry/src/main/ets/pages/)              │
│  Index · ItemPage · SpacePage · EventPage       │
│  ProfilePage · AddItemPage · ItemDetailPage     │
│  CreateEventPage · EventDetailPage              │
├─────────────────────────────────────────────────┤
│  Components (entry/src/main/ets/components/)    │
│  ItemCard · EventCard · CategoryGrid            │
│  EmptyState                                     │
├─────────────────────────────────────────────────┤
│  Model (entry/src/main/ets/model/)              │
│  ItemModel · SpaceModel · EventModel            │
├─────────────────────────────────────────────────┤
│  Repository (entry/src/main/ets/data/)          │
│  Database (singleton RdbStore)                  │
│  ItemRepository · SpaceRepository              │
│  EventRepository                                │
└─────────────────────────────────────────────────┘
```

## RelationalStore Tables

### `item`
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK AUTOINCREMENT | |
| name | TEXT NOT NULL | |
| category | TEXT DEFAULT '其他' | 衣物/书籍/数码/厨房/文件/其他 |
| spaceId | INTEGER DEFAULT 0 | FK → space.id, 0 = unassigned |
| image | TEXT DEFAULT '' | |
| purchaseDate | TEXT DEFAULT '' | YYYY-MM-DD |
| note | TEXT DEFAULT '' | |
| createTime | TEXT NOT NULL | ISO timestamp |

### `space`
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK AUTOINCREMENT | |
| name | TEXT NOT NULL | |
| parentId | INTEGER DEFAULT 0 | 0 = root (room) |
| level | INTEGER DEFAULT 1 | 1=房间 2=柜子 3=格子 |
| icon | TEXT DEFAULT '📦' | 🏠/🗄️/📦 |

### `event`
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK AUTOINCREMENT | |
| title | TEXT NOT NULL | |
| date | TEXT DEFAULT '' | YYYY-MM-DD |
| note | TEXT DEFAULT '' | |
| status | INTEGER DEFAULT 0 | 0=进行中 1=已完成 |
| createTime | TEXT NOT NULL | ISO timestamp |

### `event_item` (junction)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK AUTOINCREMENT | |
| eventId | INTEGER NOT NULL | FK → event.id |
| itemId | INTEGER NOT NULL | FK → item.id |
| isPrepared | INTEGER DEFAULT 0 | 0=unprepared 1=prepared |

## Repositories

| Repository | Methods |
|-----------|---------|
| `ItemRepository` | insert, getAll, search, delete, getById, getBySpaceId, update |
| `SpaceRepository` | insert, getByParent, getById |
| `EventRepository` | insert, getAll, linkItem, getEventItems, getById, updateEventItemPrepared, complete |

## Navigation & State Refresh

- Index uses top tabs (物品/空间/事件) + bottom nav (首页/我的)
- ProfilePage pushed via `router.pushUrl({ url: 'pages/ProfilePage' })`
- Item/Event detail pages pushed with AppStorage bridge: `AppStorage.setOrCreate('currentItemId'/'currentEventId', id)`
- List refresh via `AppStorage.setOrCreate('itemRefreshToken'/'spaceRefreshToken'/'eventRefreshToken', Date.now())` + `@StorageLink` + `@Watch`

## Event Share

- API: `systemShare.SharedData` + `systemShare.ShareController` from `@kit.ShareKit`
- Format: plain text with title, date, status, progress, note, checklist items (✅/⬜ markers)
- Failure: try-catch wrapped; non-crashing fallback
- Button: always visible in EventDetailPage header

## Service Card

| Item | Detail |
|------|--------|
| Ability | `EntryFormAbility` at `entry/src/main/ets/form/EntryFormAbility.ets` |
| Widget | `WidgetCard` at `entry/src/main/ets/form/pages/WidgetCard.ets` |
| Config | `entry/src/main/resources/base/profile/form_config.json` |
| Registration | `module.json5` extensionAbilities, type: "form" |
| Dimensions | 2×2 (default), 2×4 |
| Data | Static fallback — "智能收纳管家 / 打开应用查看待办清单" |
| Live data | Not connected — `onAddForm` does not support async/Promise in API 24 |

## module.json5 Summary

| Ability | Type | Path |
|---------|------|------|
| EntryAbility | UIAbility | `./ets/entryability/EntryAbility.ets` |
| EntryBackupAbility | backup | `./ets/entrybackupability/EntryBackupAbility.ets` |
| EntryFormAbility | form | `./ets/form/EntryFormAbility.ets` |

## Visual Style

- Primary accent: `#007AFF` (blue)
- Background: `#F5F5F5` (light gray)
- Card background: `Color.White`, borderRadius: 8
- Safe-area top padding: 36px on Index, ProfilePage, and all pushed pages
- FAB: 56×56 circle, bottom-right offset -24, shadow 8px
- Blur: `backgroundBlurStyle(BlurStyle.Thin)` on bottom nav

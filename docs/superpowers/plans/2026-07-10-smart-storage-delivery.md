# Smart Storage Delivery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the HarmonyOS "智能收纳管家" app from its current navigation/database baseline into a usable competition-ready app with item, space, event, profile, and Harmony feature deliverables.

**Architecture:** Keep the existing HarmonyOS 6.1 ArkTS single-entry app. Preserve the current three-layer shape: pages under `entry/src/main/ets/pages`, focused reusable UI under `entry/src/main/ets/components`, models under `entry/src/main/ets/model`, and RelationalStore repositories under `entry/src/main/ets/data`. Use ArkUI native blur/navigation as the default HDS fallback unless the local DevEco environment proves HDS APIs are available.

**Tech Stack:** ArkTS / ArkUI / HarmonyOS 6.1 API 24 / RelationalStore / DevEco Studio or deveco-code.

## Global Constraints

- Work only in worktree `C:\Users\xushe\Desktop\666\.worktrees\codex_plus_deveco`.
- Branch is `codex_plus_deveco`.
- Target SDK stays `6.1.1(24)`.
- Do not introduce third-party dependencies.
- Keep strict ArkTS compatibility with `caseSensitiveCheck: true`.
- Register every routable page in `entry/src/main/resources/base/profile/main_pages.json`.
- Prefer native ArkUI blur fallback unless `@kit.UIDesignKit` or HDS imports are proven available in this project.
- After every task, run DevEco build or the available `deveco-code` build command and commit only source/config changes.
- Do not commit `.hvigor/`, `.idea/`, `oh_modules/`, or local generated output.

---

## Current Baseline

Already present:

- `entry/src/main/ets/pages/Index.ets`: native `Tabs` plus bottom navigation.
- `entry/src/main/ets/pages/SpacePage.ets`: placeholder.
- `entry/src/main/ets/pages/EventPage.ets`: placeholder.
- `entry/src/main/ets/pages/ProfilePage.ets`: placeholder.
- `entry/src/main/ets/model/ItemModel.ets`
- `entry/src/main/ets/model/SpaceModel.ets`
- `entry/src/main/ets/model/EventModel.ets`
- `entry/src/main/ets/data/Database.ets`
- `entry/src/main/ets/data/ItemRepository.ets`
- `entry/src/main/ets/data/EventRepository.ets`
- `entry/src/main/ets/entryability/EntryAbility.ets`: database init before page load.

Known gaps:

- No standalone `ItemPage.ets`.
- No `components/` directory yet.
- No `SpaceRepository.ets`.
- Event repository lacks checklist update and detail helpers.
- No add/detail pages for item or event flows.
- HDS imports are not declared in `oh-package.json5`; current blur fallback is the safe path.

---

## File Map

Create:

- `entry/src/main/ets/components/ItemCard.ets`: compact item row/card.
- `entry/src/main/ets/components/CategoryGrid.ets`: item category filter grid.
- `entry/src/main/ets/components/EventCard.ets`: event summary card with progress.
- `entry/src/main/ets/components/EmptyState.ets`: shared empty state for lists.
- `entry/src/main/ets/data/SpaceRepository.ets`: CRUD/query by parent for spaces.
- `entry/src/main/ets/pages/ItemPage.ets`: item home tab.
- `entry/src/main/ets/pages/AddItemPage.ets`: create/edit item form.
- `entry/src/main/ets/pages/ItemDetailPage.ets`: item detail.
- `entry/src/main/ets/pages/CreateEventPage.ets`: create event and link items.
- `entry/src/main/ets/pages/EventDetailPage.ets`: event checklist.
- Optional for service card: `entry/src/main/ets/form/EntryFormAbility.ets` and form resource/profile files, only after core app builds.

Modify:

- `entry/src/main/ets/pages/Index.ets`: import and render `ItemPage`; keep native blur nav stable.
- `entry/src/main/ets/pages/SpacePage.ets`: replace placeholder with drill-down UI.
- `entry/src/main/ets/pages/EventPage.ets`: replace placeholder with event list UI.
- `entry/src/main/ets/pages/ProfilePage.ets`: replace placeholder with stats/reminders.
- `entry/src/main/ets/data/ItemRepository.ets`: add `getById`, `getBySpaceId`, optional `getCategoryCounts`.
- `entry/src/main/ets/data/EventRepository.ets`: add `getById`, `updateEventItemPrepared`, `getProgress`, `complete`.
- `entry/src/main/resources/base/profile/main_pages.json`: add routable pages.
- `entry/src/main/module.json5`: only if service cards are implemented.

---

## Task 1: Stabilize Navigation And Page Registration

**Files:**
- Create: `entry/src/main/ets/pages/ItemPage.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/resources/base/profile/main_pages.json`

**Interfaces:**
- Consumes: current `Index.ets`, current database init.
- Produces: `ItemPage` exported component used inside the first tab; routable create/detail pages will be registered later.

- [ ] Step 1: Create `ItemPage.ets` with a build-safe placeholder that exports `ItemPage`.
- [ ] Step 2: Import `ItemPage` in `Index.ets` and replace the inline item placeholder with `ItemPage()`.
- [ ] Step 3: Keep the existing native `Tabs`/blur fallback; do not add HDS imports unless the package is present.
- [ ] Step 4: Build in DevEco/deveco-code.
- [ ] Step 5: Commit with `git commit -m "feat: add item page shell"`.

Acceptance:

- App starts on `Index`.
- Three top tabs still render.
- Bottom "我的" still routes to `ProfilePage`.
- No new dependency is added.

---

## Task 2: Complete Repository Layer

**Files:**
- Create: `entry/src/main/ets/data/SpaceRepository.ets`
- Modify: `entry/src/main/ets/data/ItemRepository.ets`
- Modify: `entry/src/main/ets/data/EventRepository.ets`

**Interfaces:**
- Produces:
  - `SpaceRepository.insert(space: Omit<Space, 'id'>): Promise<number>`
  - `SpaceRepository.getByParent(parentId: number): Promise<Space[]>`
  - `SpaceRepository.getById(id: number): Promise<Space | null>`
  - `ItemRepository.getById(id: number): Promise<Item | null>`
  - `ItemRepository.getBySpaceId(spaceId: number): Promise<Item[]>`
  - `EventRepository.getById(id: number): Promise<Event | null>`
  - `EventRepository.updateEventItemPrepared(id: number, isPrepared: boolean): Promise<number>`
  - `EventRepository.complete(eventId: number): Promise<number>`

- [ ] Step 1: Implement `SpaceRepository` using the same RelationalStore parsing style as `ItemRepository`.
- [ ] Step 2: Add `ItemRepository.getById`.
- [ ] Step 3: Add `ItemRepository.getBySpaceId`.
- [ ] Step 4: Add `EventRepository.getById`.
- [ ] Step 5: Add `EventRepository.updateEventItemPrepared`.
- [ ] Step 6: Add `EventRepository.complete`.
- [ ] Step 7: Build in DevEco/deveco-code.
- [ ] Step 8: Commit with `git commit -m "feat: complete storage repositories"`.

Acceptance:

- All new repository methods compile.
- Every `ResultSet` is closed after parsing.
- Boolean `EventItem.isPrepared` is stored as integer 0/1 and read back as boolean.

---

## Task 3: Build Item Management

**Files:**
- Create: `entry/src/main/ets/components/ItemCard.ets`
- Create: `entry/src/main/ets/components/CategoryGrid.ets`
- Create: `entry/src/main/ets/components/EmptyState.ets`
- Create: `entry/src/main/ets/pages/AddItemPage.ets`
- Create: `entry/src/main/ets/pages/ItemDetailPage.ets`
- Modify: `entry/src/main/ets/pages/ItemPage.ets`
- Modify: `entry/src/main/resources/base/profile/main_pages.json`

**Interfaces:**
- Consumes: `ItemRepository.insert`, `getAll`, `search`, `delete`, `update`, `getById`.
- Produces:
  - Item list with search and category filter.
  - Add item flow.
  - Item detail page.

- [ ] Step 1: Build `EmptyState` with icon, title, and optional subtitle props.
- [ ] Step 2: Build `ItemCard` with `name`, `category`, `location`, `onClick`.
- [ ] Step 3: Build `CategoryGrid` with fixed categories: 全部, 衣物, 书籍, 数码, 厨房, 文件, 其他.
- [ ] Step 4: Implement `ItemPage` list loading in `aboutToAppear`, search by keyword, category filter in memory, floating add button.
- [ ] Step 5: Implement `AddItemPage` with name/category/date/note fields and save via `ItemRepository.insert`.
- [ ] Step 6: Implement `ItemDetailPage` using router param `itemId`, show category/location/date/note, and support delete/back.
- [ ] Step 7: Register `pages/AddItemPage` and `pages/ItemDetailPage` in `main_pages.json`.
- [ ] Step 8: Build and manually test create item, return, list refresh, open detail.
- [ ] Step 9: Commit with `git commit -m "feat: add item management flow"`.

Acceptance:

- Empty database shows an empty state and add button.
- Saving an item persists it and it appears after returning to the item tab.
- Search matches item name.
- Category filter does not delete data.
- Detail opens by `itemId`.

---

## Task 4: Build Three-Level Space Management

**Files:**
- Modify: `entry/src/main/ets/pages/SpacePage.ets`

**Interfaces:**
- Consumes: `SpaceRepository`, `ItemRepository.getBySpaceId`.
- Produces: three-level drill-down UI for room, cabinet, grid, plus item list for selected grid.

- [ ] Step 1: Replace placeholder with state fields: `spaces`, `items`, `parentId`, `currentLevel`, `breadcrumb`.
- [ ] Step 2: Load spaces by parent on page appear.
- [ ] Step 3: Add "新增空间" action that creates the next level with validated name.
- [ ] Step 4: Drill into a space on tap and update breadcrumb.
- [ ] Step 5: Add breadcrumb back navigation.
- [ ] Step 6: At level 3 grid selection, show items from `ItemRepository.getBySpaceId(spaceId)`.
- [ ] Step 7: Build and manually test room -> cabinet -> grid navigation.
- [ ] Step 8: Commit with `git commit -m "feat: add space drill down management"`.

Acceptance:

- Users can create at least one room, cabinet, and grid.
- Breadcrumb lets users navigate back.
- Grid item list is filtered by exact `spaceId`.

---

## Task 5: Build Event Management

**Files:**
- Create: `entry/src/main/ets/components/EventCard.ets`
- Create: `entry/src/main/ets/pages/CreateEventPage.ets`
- Create: `entry/src/main/ets/pages/EventDetailPage.ets`
- Modify: `entry/src/main/ets/pages/EventPage.ets`
- Modify: `entry/src/main/resources/base/profile/main_pages.json`

**Interfaces:**
- Consumes: `EventRepository`, `ItemRepository.getAll`, `ItemRepository.getById`.
- Produces:
  - Event list.
  - Create event with linked item IDs.
  - Checklist detail with prepared progress.

- [ ] Step 1: Build `EventCard` with title, date, status, progress, total, and `onClick`.
- [ ] Step 2: Implement `EventPage` to load events, split active and completed, and route to create/detail pages.
- [ ] Step 3: Implement `CreateEventPage` with title/date/note and selectable item list.
- [ ] Step 4: On save, insert event then call `linkItem` for selected items.
- [ ] Step 5: Implement `EventDetailPage` using `eventId`, load event, event items, and item details.
- [ ] Step 6: Add checklist toggle that calls `updateEventItemPrepared`.
- [ ] Step 7: Mark event complete when all checklist items are prepared or through a clear complete action.
- [ ] Step 8: Register `pages/CreateEventPage` and `pages/EventDetailPage`.
- [ ] Step 9: Build and manually test create event, link items, toggle checklist.
- [ ] Step 10: Commit with `git commit -m "feat: add event checklist management"`.

Acceptance:

- Event list shows newly created events.
- Event detail shows real linked item names, not placeholder item names.
- Progress updates immediately after toggling checklist items.
- Completed state persists.

---

## Task 6: Build Profile Dashboard

**Files:**
- Modify: `entry/src/main/ets/pages/ProfilePage.ets`
- Optional Modify: `entry/src/main/ets/data/ItemRepository.ets`
- Optional Modify: `entry/src/main/ets/data/EventRepository.ets`

**Interfaces:**
- Consumes: item/event repositories.
- Produces: personal dashboard with useful summary.

- [ ] Step 1: Load total item count and category counts.
- [ ] Step 2: Load active event count and upcoming events.
- [ ] Step 3: Replace placeholder with summary cards and reminder list.
- [ ] Step 4: Build and manually test with seeded user-created data.
- [ ] Step 5: Commit with `git commit -m "feat: add profile dashboard"`.

Acceptance:

- Profile page is useful after users create items and events.
- Empty state is graceful when there is no data.

---

## Task 7: HDS/Fallback Polish Pass

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`
- Optional Modify: shared components/pages as needed.

**Interfaces:**
- Consumes: completed core UI.
- Produces: consistent blue-white immersive visual style.

- [ ] Step 1: Check whether HDS imports are actually available in DevEco/deveco-code.
- [ ] Step 2: If available, adapt navigation to HDS components without breaking routes.
- [ ] Step 3: If unavailable, keep native ArkUI and improve `BlurStyle`, spacing, safe area, and selected states.
- [ ] Step 4: Build and inspect all main pages.
- [ ] Step 5: Commit with `git commit -m "style: polish immersive navigation"`.

Acceptance:

- No unresolved HDS imports.
- Navigation feels consistent and does not overlap content.
- Blue accent remains `#007AFF`.

---

## Task 8: Harmony Service Card

**Files:**
- Create/Modify form ability and resources according to DevEco generated Form template.
- Modify: `entry/src/main/module.json5`

**Interfaces:**
- Consumes: event data or a simplified shared event summary.
- Produces: desktop card showing active event and checklist progress.

- [ ] Step 1: Use DevEco's Harmony Form template for this API level.
- [ ] Step 2: Register the form in `module.json5`.
- [ ] Step 3: Render current active event title and progress.
- [ ] Step 4: Build and add card on emulator/device.
- [ ] Step 5: Commit with `git commit -m "feat: add active event service card"`.

Acceptance:

- App still builds.
- Service card appears in the launcher card picker.
- Card shows a meaningful empty state with no active events.

---

## Task 9: Event Share / Cross-Device Handoff

**Files:**
- Modify: `entry/src/main/ets/pages/EventDetailPage.ets`

**Interfaces:**
- Consumes: event detail and linked item list.
- Produces: share action that sends plain text checklist through Want/share API available in HarmonyOS.

- [ ] Step 1: Add a share button in event detail.
- [ ] Step 2: Format text as title, date, and item checklist lines.
- [ ] Step 3: Use the standard Harmony sharing/Want flow supported by DevEco for API 24.
- [ ] Step 4: Build and test share sheet or device flow.
- [ ] Step 5: Commit with `git commit -m "feat: add event checklist sharing"`.

Acceptance:

- Share text contains actual event and item data.
- Failure to share does not crash the page.

---

## Task 10: Competition Readiness

**Files:**
- Create: `docs/competition/architecture.md`
- Create: `docs/competition/test-report.md`
- Create: `docs/competition/screenshots.md`

**Interfaces:**
- Consumes: completed app.
- Produces: project explanation and verification materials.

- [ ] Step 1: Document architecture: entry ability, pages/components/data/model layers, RelationalStore tables.
- [ ] Step 2: Document Harmony features: immersive UI, service card, share/handoff.
- [ ] Step 3: Capture screenshots for item, space, event, profile, service card.
- [ ] Step 4: Write a manual test report with pass/fail for core flows.
- [ ] Step 5: Commit with `git commit -m "docs: add competition delivery materials"`.

Acceptance:

- A reviewer can understand the app without opening code first.
- Screenshots match the implemented UI.
- Test report lists device/emulator, date, and build result.

---

## Review Gate For Codex

After `deveco-code` finishes each task or batch:

- Check `git status --short` and reject commits that include `.hvigor/`, `.idea/`, `oh_modules/`, or generated build output.
- Review route registrations in `main_pages.json`.
- Review ArkTS imports for unresolved HDS or wrong kit imports.
- Review repository methods for closed `ResultSet`.
- Build in DevEco/deveco-code.
- Manually exercise the flow implemented by that task.
- Commit only after build and manual flow pass.

Final review before merging:

- Run full app build.
- Exercise item create/search/detail.
- Exercise space create/drill-down/item-by-space.
- Exercise event create/link/checklist/complete/share.
- Exercise profile stats.
- Inspect UI for overlap on phone viewport.
- Verify docs and screenshots.

## GSTACK REVIEW REPORT

Plan status: ready for implementation by `deveco-code`.

Risks:

- HDS availability is unproven in the current repo. Treat native ArkUI blur as the default unless DevEco confirms HDS support.
- Command-line `hvigor` is not available in this Codex shell, so build verification must happen in DevEco/deveco-code.
- Existing `.hvigor` and `.idea` changes in the original checkout look like local generated state and must stay out of source commits.

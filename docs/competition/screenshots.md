# Smart Storage (智能收纳管家) — Screenshots

> Date: 2026-07-12
> Status: PENDING — no screenshots captured

## Environment Constraint

The current build and verification environment is a DevEco Studio CLI without a connected device or emulator. Screenshots cannot be captured via `hdc` screenshot, DevEco preview, or `verify_ui` tooling.

## Pending Screenshot Checklist

Once a device or emulator is available and the app is deployed (with signing configured in DevEco Studio), capture the following:

### Item Flow
- [ ] Item list (首页 → 物品 tab) — showing multiple items with categories
- [ ] Item search — filtered results
- [ ] Category filter — chip selection active
- [ ] Add item form (AddItemPage) — filled fields
- [ ] Item detail (ItemDetailPage) — all fields populated
- [ ] Empty state — no items yet

### Space Flow
- [ ] Space root level — room list
- [ ] Space level 2 — cabinet list
- [ ] Space level 3 — grid items
- [ ] Breadcrumb navigation — "全部 > 卧室 > 衣柜"
- [ ] Space add dialog
- [ ] Empty state — no spaces at root level

### Event Flow
- [ ] Event list — active + completed sections
- [ ] Event detail — checklist with prepared/unprepared items
- [ ] Event detail — progress bar partial/complete
- [ ] Event share panel — system share sheet visible
- [ ] Create event — with linked items selected
- [ ] Empty state — no events

### Profile Flow
- [ ] Profile dashboard — full stats visible
- [ ] Category counts — item distribution
- [ ] Event stats — active/completed counts
- [ ] Upcoming reminders — active event list
- [ ] App footer — "智能收纳管家 · HarmonyOS 6.1 · ArkTS"

### Service Card
- [ ] Launcher card picker — "收纳管家" card visible
- [ ] Card on home screen — 2×2 dimension
- [ ] DevEco Form preview (if available)

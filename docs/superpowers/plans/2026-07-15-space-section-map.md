# Space Section Map Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Change the space UI from a three-level room/cabinet/grid list into a generic "space -> section -> items" flow with section markers on a default space image.

**Architecture:** Reuse the existing `space` table for both spaces and sections. A root `Space` row (`level = 1`) is a space; a child `Space` row (`level = 2`) is a section and stores its marker position/color relative to the parent space image. Items continue to use `Item.spaceId`, now pointing at the section id.

**Tech Stack:** HarmonyOS ArkTS, ArkUI declarative components, `@kit.ArkData` `relationalStore`, `@kit.ArkUI` router/AppStorage.

## Global Constraints

- Keep changes scoped to the current HarmonyOS app module.
- Do not introduce a new section table or new external dependency.
- First version uses a default image/resource only; no gallery picker.
- Use generic copy: "空间", "分区", "物品".
- Click a section marker or section list row to enter that section's item page.
- Existing item storage remains `Item.spaceId`.

---

## File Structure

| File | Responsibility |
| --- | --- |
| `entry/src/main/ets/model/SpaceModel.ets` | Extend the space schema/interface with image and marker metadata. |
| `entry/src/main/ets/data/SpaceRepository.ets` | Persist and read the new image/marker fields. |
| `entry/src/main/ets/data/Database.ets` | Add idempotent compatibility migration for existing local databases. |
| `entry/src/main/ets/pages/SpacePage.ets` | Render root spaces, space detail image markers, section list, and section item page. |
| `entry/src/main/ets/pages/AddItemPage.ets` | Accept optional `spaceId` route param and save new items to that section. |

## Acceptance Criteria

1. Root space page uses generic "空间管理" and adds `level = 1` spaces.
2. Entering a space shows a default image with all child sections as colored markers.
3. Tapping the image stores a pending relative point and shows a `+` button at that point.
4. Tapping `+` opens a section dialog; saving creates `level = 2` child section with `markerX`, `markerY`, and `markerColor`.
5. Tapping a marker or section row enters a section page.
6. Section page lists items where `Item.spaceId === section.id`.
7. Adding an item from the section page saves it with that section id.
8. Existing databases without new `space` columns initialize without crashing.

## Task 1: Space Schema and Repository

**Files:**
- Modify: `entry/src/main/ets/model/SpaceModel.ets`
- Modify: `entry/src/main/ets/data/SpaceRepository.ets`

**Interfaces:**
- Produces `Space.image: string`, `Space.markerX: number`, `Space.markerY: number`, `Space.markerColor: string`.
- `SpaceRepository.insert(space: SpaceInput)` accepts and writes all new fields.
- `SpaceRepository.getByParent()` and `getById()` return all new fields.

- [x] **Step 1: Update `Space` and `SpaceInput` interfaces.**
- [x] **Step 2: Add default columns to `SPACE_CREATE_SQL`.**
- [x] **Step 3: Add new fields to `SpaceRepository.insert()`.**
- [x] **Step 4: Add new columns to repository query projections.**
- [x] **Step 5: Map result sets into the expanded `Space` object.**

## Task 2: Database Compatibility Migration

**Files:**
- Modify: `entry/src/main/ets/data/Database.ets`

**Interfaces:**
- Produces `Database.ensureSpaceColumns()` that safely tries `ALTER TABLE` for each new column.

- [x] **Step 1: After table creation, call a migration helper.**
- [x] **Step 2: Add an idempotent helper that ignores duplicate-column failures and logs other errors.**
- [x] **Step 3: Keep `DB_VERSION` unchanged because the existing code does not currently use a formal upgrade callback.**

## Task 3: Space Page State and Navigation

**Files:**
- Modify: `entry/src/main/ets/pages/SpacePage.ets`

**Interfaces:**
- Uses `breadcrumb.length === 0` for root spaces.
- Uses `breadcrumb.length === 1` for a space detail page.
- Uses `breadcrumb.length >= 2` for section item page.

- [x] **Step 1: Replace level labels with generic `空间` / `分区`.**
- [x] **Step 2: Replace old third-level item condition with section-page condition.**
- [x] **Step 3: Update `onSpaceTap()` so root spaces enter detail and sections enter items.**
- [x] **Step 4: Keep breadcrumb back behavior and item loading behavior.**

## Task 4: Image Marker UI and Add Section Flow

**Files:**
- Modify: `entry/src/main/ets/pages/SpacePage.ets`

**Interfaces:**
- Produces `pendingMarkerX` and `pendingMarkerY` state values in 0..1 relative coordinates.
- Produces `addSectionAtPendingMarker()` that creates a child `Space` with `level = 2`.

- [x] **Step 1: Add state for selected/pending marker coordinates.**
- [x] **Step 2: Render a default image panel for a space detail page.**
- [x] **Step 3: Overlay section markers from `this.spaces`.**
- [x] **Step 4: On image click, capture relative coordinates and show a positioned `+`.**
- [x] **Step 5: Save a section with automatic color assignment.**

## Task 5: Section Items and AddItemPage Routing

**Files:**
- Modify: `entry/src/main/ets/pages/SpacePage.ets`
- Modify: `entry/src/main/ets/pages/AddItemPage.ets`

**Interfaces:**
- `SpacePage` routes to `AddItemPage` with `{ spaceId: this.getParentId() }` from a section page.
- `AddItemPage` reads optional `spaceId` from router params and writes it into `ItemInput.spaceId`.

- [x] **Step 1: Add an "添加物品" action on section item page.**
- [x] **Step 2: In `AddItemPage.aboutToAppear()`, read `spaceId` from router params.**
- [x] **Step 3: Save items with the passed section id, defaulting to `0` when absent.**
- [x] **Step 4: Refresh `itemRefreshToken` and `spaceRefreshToken` after save.**

## Task 6: Verification

**Files:**
- Verify all changed files.

- [x] **Step 1: Run available unit tests.**
  - Command: `ohpm test` if available, otherwise document unavailability.
- [x] **Step 2: Run available build/type check.**
  - Command: project hvigor build command if available from package metadata.
- [x] **Step 3: Search changed ArkTS files for old user-facing labels `柜子` and `格子`; none should remain in the changed flow.**
- [x] **Step 4: Manually inspect diffs against acceptance criteria.**

### Verification Notes

- `ohpm test` was attempted, but `ohpm` is not available in this shell environment.
- `hvigor` was checked with `Get-Command hvigor`, but it is not available in this shell environment.
- Text verification passed for changed ArkTS flow: no old `柜子` / `格子` labels remain in `SpacePage.ets` or `SpaceModel.ets`.
- `AddItemPage.ets` has a single `spaceId` assignment and now uses the optional router param.

## Out of Scope

- Photo picker/gallery integration.
- Dragging existing section markers after creation.
- QR code generation or scanning.
- Deleting or editing sections.
- Visual full-screen image preview.

# deveco-code Prompt Pack

Use these prompts in order. Run them from:

`C:\Users\xushe\Desktop\666\.worktrees\codex_plus_deveco`

Branch:

`codex_plus_deveco`

Global instruction for every prompt:

```text
You are working on a HarmonyOS 6.1 ArkTS app in the existing repository.
Do not add third-party dependencies.
Do not commit .hvigor, .idea, oh_modules, or generated build output.
Keep target SDK 6.1.1(24).
Use ArkUI native blur/navigation unless HDS APIs are proven available in this local DevEco environment.
After changes, run the available DevEco/deveco-code build check and report exact errors if any.
Make one focused git commit when the task is complete.
```

## Prompt 1: Navigation Shell

```text
Read docs/superpowers/plans/2026-07-10-smart-storage-delivery.md Task 1.
Implement the standalone ItemPage shell and wire it into Index.ets.
Keep current native Tabs and blur fallback.
Do not introduce HDS imports.
Build the app.
Commit with: feat: add item page shell
Report files changed, build result, and any manual navigation checks performed.
```

## Prompt 2: Repository Layer

```text
Read docs/superpowers/plans/2026-07-10-smart-storage-delivery.md Task 2.
Implement SpaceRepository and complete missing ItemRepository/EventRepository helpers exactly as named in the plan.
Follow the parsing style already used in ItemRepository and EventRepository.
Close every ResultSet.
Build the app.
Commit with: feat: complete storage repositories
Report files changed and build result.
```

## Prompt 3: Item Management Flow

```text
Read docs/superpowers/plans/2026-07-10-smart-storage-delivery.md Task 3.
Build the item management flow:
- EmptyState component
- ItemCard component
- CategoryGrid component
- ItemPage list/search/category filter/add navigation
- AddItemPage save flow
- ItemDetailPage route by itemId
- main_pages.json registration
Use the existing RelationalStore repositories.
Build and manually test empty state, add item, list refresh, search, category filter, and detail open.
Commit with: feat: add item management flow
Report build result and manual test result.
```

## Prompt 4: Space Management

```text
Read docs/superpowers/plans/2026-07-10-smart-storage-delivery.md Task 4.
Replace SpacePage placeholder with three-level room -> cabinet -> grid drill-down.
Use SpaceRepository for spaces and ItemRepository.getBySpaceId for items.
Implement breadcrumb navigation and add-space action.
Build and manually test creating a room, cabinet, and grid.
Commit with: feat: add space drill down management
Report build result and manual test result.
```

## Prompt 5: Event Management

```text
Read docs/superpowers/plans/2026-07-10-smart-storage-delivery.md Task 5.
Build the event management flow:
- EventCard component
- EventPage active/completed lists
- CreateEventPage with selectable linked items
- EventDetailPage with real linked item names
- checklist toggle persisted through EventRepository.updateEventItemPrepared
- event completion state
- main_pages.json registration
Build and manually test create event, link items, open detail, toggle checklist, and completion persistence.
Commit with: feat: add event checklist management
Report build result and manual test result.
```

## Prompt 6: Profile Dashboard

```text
Read docs/superpowers/plans/2026-07-10-smart-storage-delivery.md Task 6.
Replace ProfilePage placeholder with a useful dashboard:
- total item count
- category counts
- active event count
- upcoming or active reminders
Add repository helpers only if necessary.
Build and manually test with data created through the app.
Commit with: feat: add profile dashboard
Report build result and manual test result.
```

## Prompt 7: Immersive Polish

```text
Read docs/superpowers/plans/2026-07-10-smart-storage-delivery.md Task 7.
First check whether HDS APIs are actually available in this DevEco project.
If available, use them carefully for navigation/material effects.
If unavailable, keep native ArkUI and polish blur, spacing, selected states, and safe area behavior.
Do not leave unresolved imports.
Build and inspect all main pages for overlap.
Commit with: style: polish immersive navigation
Report which path was used: HDS or ArkUI fallback.
```

## Prompt 8: Harmony Service Card

```text
Read docs/superpowers/plans/2026-07-10-smart-storage-delivery.md Task 8.
Use the DevEco Harmony Form template appropriate for API 24.
Add a service card that shows the current active event and checklist progress, with a graceful empty state.
Register it in module.json5.
Build and test that the card appears in the launcher card picker.
Commit with: feat: add active event service card
Report build result and card test result.
```

## Prompt 9: Event Share

```text
Read docs/superpowers/plans/2026-07-10-smart-storage-delivery.md Task 9.
Add a share action to EventDetailPage.
Format plain text with event title, date, and linked item checklist.
Use the standard HarmonyOS share/Want API supported by API 24.
Build and test share behavior.
Commit with: feat: add event checklist sharing
Report build result and share test result.
```

## Prompt 10: Competition Materials

```text
Read docs/superpowers/plans/2026-07-10-smart-storage-delivery.md Task 10.
Create docs/competition/architecture.md, docs/competition/test-report.md, and docs/competition/screenshots.md.
Document implemented architecture, Harmony features, screenshots, and manual test results.
Do not invent screenshots; reference actual screenshot files after capturing them.
Commit with: docs: add competition delivery materials
Report docs created and remaining submission checklist.
```

## Prompt 11: Pre-Review Cleanup

```text
Before handing back to Codex for review:
Run git status --short.
Ensure no .hvigor, .idea, oh_modules, or generated output is staged or committed.
Run full build in DevEco/deveco-code.
Run the manual flows listed in docs/superpowers/plans/2026-07-10-smart-storage-delivery.md Review Gate For Codex.
Report:
- latest commit hash
- build result
- manual test results
- known issues
```

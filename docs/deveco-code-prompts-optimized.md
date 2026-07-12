# deveco-code Prompt Pack - Optimized From Task 7

Use this optimized prompt pack after Task 6 has been completed.

Original baseline files kept unchanged:

- `docs/deveco-code-prompts.md`
- `docs/superpowers/plans/2026-07-10-smart-storage-delivery.md`

Optimized plan for the remaining work:

`docs/superpowers/plans/2026-07-12-smart-storage-task7-delivery-optimized.md`

Run prompts from:

`C:\Users\xushe\Desktop\666\.worktrees\codex_plus_deveco`

Branch:

`codex_plus_deveco`

Global instruction for every prompt:

```text
You are working on a HarmonyOS 6.1 ArkTS app in the existing repository.
The project has completed the core app through Task 6: item, space, event, and profile flows are already implemented.
Do not redo Tasks 1-6 unless a build error proves a small fix is necessary.
Do not add third-party dependencies.
Do not commit .hvigor, .idea, oh_modules, build output, or generated local state.
Keep target SDK 6.1.1(24).
Keep strict ArkTS compatibility with caseSensitiveCheck: true.
Use ArkUI native blur/navigation as the default.
Only use HDS or @kit.UIDesignKit if the local DevEco environment proves the API is available and the build succeeds.
Prefer the smallest source diff that makes the current implementation more stable and competition-ready.
After changes, run the available DevEco/deveco-code build check and report exact errors if any.
Make one focused git commit when the task is complete.
```

## Prompt 7: ArkUI Immersive Polish

```text
Read docs/superpowers/plans/2026-07-12-smart-storage-task7-delivery-optimized.md Task 7.

Goal: polish the already implemented app without changing the core data flows.

First inspect:
- oh-package.json5 and entry/oh-package.json5 for HDS or UIDesignKit availability.
- entry/src/main/ets/pages/Index.ets
- ItemPage.ets, SpacePage.ets, EventPage.ets, ProfilePage.ets
- AddItemPage.ets, ItemDetailPage.ets, CreateEventPage.ets, EventDetailPage.ets
- shared components under entry/src/main/ets/components

Expected default path:
- If HDS is not already available, do not introduce HDS imports.
- Keep ArkUI native components and improve the current implementation.

Polish checklist:
- Remove stale commented imports.
- Keep blue accent #007AFF.
- Make top tabs, bottom nav, page headers, list padding, selected states, and empty/loading states visually consistent.
- Ensure floating add buttons do not overlap bottom navigation or list content.
- Add enough bottom padding to scrollable lists behind floating buttons.
- Keep safe top padding consistent across Index and routed pages.
- Do not alter repository behavior or schema.
- Do not change route names in main_pages.json unless fixing a real issue.

Build and inspect:
- Index item tab
- space drill-down
- event list/detail
- profile dashboard
- add item
- create event

Commit with:
style: polish ArkUI immersive navigation

Report:
- HDS path or ArkUI fallback path used
- files changed
- build result
- manual page inspection result
- any known visual issues left
```

## Prompt 8: Event Share

```text
Read docs/superpowers/plans/2026-07-12-smart-storage-task7-delivery-optimized.md Task 8.

Goal: add a low-risk share action before attempting the higher-risk service card.

Work mainly in:
- entry/src/main/ets/pages/EventDetailPage.ets

Use the existing loaded event and checklist state in EventDetailPage.
Do not create a new repository layer just for sharing.
Do not duplicate checklist loading logic unless the current page state is unavailable.

Implementation:
- Add a share action in the EventDetailPage header or action area.
- Format plain text with event title, date, status/progress, note if present, and checklist lines.
- Use the standard HarmonyOS share/Want API available in this local API 24 DevEco environment.
- If the exact share API is unavailable, implement a graceful fallback that copies/prepares share text or logs a clear non-crashing message, and report the limitation.
- Failure to share must not crash the page.

Build and manually test:
- open an event with linked items
- share from active event
- share from completed event
- try an event with no linked items if possible

Commit with:
feat: add event checklist sharing

Report:
- API used
- exact share text sample
- build result
- manual test result
- fallback or known limitations
```

## Prompt 9: Harmony Service Card Template

```text
Read docs/superpowers/plans/2026-07-12-smart-storage-task7-delivery-optimized.md Task 9.

Goal: add a build-safe Harmony service card in two stages: template first, then data.

Stage 1: template and registration
- Use the DevEco Harmony Form template appropriate for HarmonyOS 6.1 / API 24.
- Add the required form ability/resource/profile files.
- Register the form in entry/src/main/module.json5.
- Keep the first version simple and build-safe.
- The card must show a meaningful empty/static state even before data binding.

Stage 2: active event data
- Reuse EventRepository APIs if they work in the form context.
- Show the first active event and checklist progress if accessible.
- If RelationalStore access from the form context is not build-safe, keep the static/empty card and clearly document the limitation in the report.

Do not break the main app abilities or backup extension.
Do not commit generated local state.

Build and test:
- app still builds
- card appears in launcher card picker or DevEco form preview if available
- empty state is graceful
- active event progress is shown only if safely supported

Commit with:
feat: add active event service card

Report:
- files created/modified
- form profile/resource names
- build result
- card picker/preview test result
- whether data binding is live or static fallback
```

## Prompt 10: Competition Materials

```text
Read docs/superpowers/plans/2026-07-12-smart-storage-task7-delivery-optimized.md Task 10.

Create or update:
- docs/competition/architecture.md
- docs/competition/test-report.md
- docs/competition/screenshots.md

Document the implemented app as it actually exists after Tasks 7-9.

Architecture doc must include:
- EntryAbility and database init
- pages/components/model/data layer map
- RelationalStore tables
- navigation and route registration
- event checklist flow
- profile dashboard
- share feature
- service card status, including any fallback

Test report must include:
- build command or DevEco build action used
- date
- device/emulator if available
- pass/fail for item, space, event, profile, share, and service card
- exact known issues

Screenshots doc:
- reference actual screenshot files only after they are captured
- do not invent screenshots
- if screenshots cannot be captured, write a clear pending checklist

Commit with:
docs: add competition delivery materials

Report:
- docs created/updated
- build result
- screenshot status
- remaining submission checklist
```

## Prompt 11: Pre-Review Cleanup

```text
Before handing back to Codex for review, run the final cleanup gate.

Read:
- docs/superpowers/plans/2026-07-12-smart-storage-task7-delivery-optimized.md Review Gate For Codex

Run:
- git status --short
- full DevEco/deveco-code build
- manual smoke tests for the listed flows

Verify:
- no .hvigor, .idea, oh_modules, build output, or generated local state is staged or committed
- main_pages.json still contains every routable page
- module.json5 remains valid after service card registration
- no unresolved HDS or wrong kit imports
- app target SDK remains 6.1.1(24)

Report:
- latest commit hash
- build result
- manual test results
- known issues
- files intentionally changed since Task 7
```

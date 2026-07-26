# Repository Documentation Index

This repository keeps the HarmonyOS/ArkTS project structure at the root and stores supporting materials under `docs/`.

## Directory Map

- `competition/`: competition-facing architecture, screenshots checklist, and test report.
- `overview/`: project introductions, research notes, questionnaire data, and draft text.
- `plans/`: human-readable project plans that are not part of the build system.
- `deliverables/`: final handoff files such as PDF, DOCX, and TEX versions of the product description.
- `assets/`: posters, charts, screenshots, diagrams, flow figures, and scripts used to generate those assets.
- `archive/`: generated documentation byproducts that may be useful for audit or regeneration.
- `superpowers/`: agent workflow plans; keep this directory in place for traceability.

## Protected Project Areas

Do not move these directories or files during documentation cleanup:

- `entry/`
- `AppScope/`
- `hvigor/`
- `.deveco/`
- `.hvigor/`
- `oh_modules/`
- root build/config files such as `oh-package.json5`, `oh-package-lock.json5`, `build-profile.json5`, `hvigorfile.ts`, `code-linter.json5`, and `local.properties`
- app runtime resources such as `defaultBG.png`


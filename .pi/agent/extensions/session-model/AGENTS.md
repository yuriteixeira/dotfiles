# session-model Extension Guidelines

This extension keeps pi model switches session-local unless `/save-model` is explicitly used.

## Design Rules

- Keep files small and focused; split new behavior into cohesive modules.
- Prefer top-level functions and module composition.
- Do not introduce classes unless explicitly requested.
- Avoid defining functions inside functions.
- Keep side effects isolated:
  - pi event/command wiring in `index.ts`
  - application behavior in `use-cases.ts`
  - settings file I/O in `settings-store.ts`
  - status/notification formatting in `model-format.ts`
  - shared types in `types.ts`

## Behavior Rules

- Preserve session-only model switching by default.
- Only `/save-model` may persist the active model to `settings.json`.
- Continue reading the saved model from pi settings on session start.
- Preserve the status format: `session model: <model> · saved model: <model>`.
- Use monochrome Nerd Font glyphs, not colored emoji.

## Validation

After changes, typecheck this extension entrypoint:

```bash
cd .pi && pnpm exec tsc --ignoreConfig --noEmit --target ES2022 --module NodeNext --moduleResolution nodenext --strict --skipLibCheck --types node extensions/session-model/index.ts
```

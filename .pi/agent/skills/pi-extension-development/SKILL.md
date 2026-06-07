---
name: pi-extension-development
description: Create or refactor pi coding-agent extensions. Use when working in .pi/extensions, adding pi commands/tools/events, or changing pi extension behavior while preserving settings, reload behavior, and runtime contracts.
---

# Pi Extension Development

Use this skill when creating or refactoring pi extensions.

Also follow the general `code-creation-and-refactoring-guidelines` style: function/module-first, no classes by default, no nested functions, small cohesive modules, explicit side-effect boundaries, and behavior preservation.

## Extension Placement

- Project extensions live in `.pi/extensions/`.
- Global extensions live in `~/.pi/agent/extensions/`.
- Directory extensions should use:

```text
.pi/extensions/<extension-name>/index.ts
```

- Run `/reload` after adding or changing auto-discovered extensions.

## Recommended Module Shape

Keep pi framework wiring thin:

```text
extension-name/
├── index.ts          # pi event/command/tool registration only
├── use-cases.ts      # application behavior/orchestration
├── types.ts          # shared domain/data types
└── <boundary>.ts     # I/O, settings, rendering, integrations, etc.
```

Split additional modules when files grow beyond small, easily scannable units.

## Design Rules

- Keep `index.ts` focused on `pi.on`, `pi.registerCommand`, `pi.registerTool`, etc.
- Do not put business behavior directly in event handlers.
- Isolate pi settings/file I/O from model/domain decisions.
- Keep UI/status/notification formatting separate from persistence and orchestration.
- Avoid copying or linking auth/config/session files unless explicitly requested.
- Be careful with `.pi/agent/settings.json`; preserve config formats and user-selected values unless explicitly changing them.
- Prefer extension-local `AGENTS.md` when the extension has special design or behavior rules.

## Common Pi APIs

- Events: `session_start`, `model_select`, `tool_call`, `tool_result`, `before_agent_start`, `input`.
- Commands: `pi.registerCommand("name", { handler })`.
- Tools: `pi.registerTool(...)` with `typebox` parameters.
- UI: `ctx.ui.notify`, `ctx.ui.setStatus`, `ctx.ui.setWidget`, dialogs when `ctx.hasUI` is appropriate.
- Model access: `ctx.model`, `ctx.modelRegistry`, `pi.setModel(...)`.

## Validation

Prefer scoped validation for the extension entrypoint when unrelated extensions break full project checks:

```bash
cd .pi && pnpm exec tsc --ignoreConfig --noEmit --target ES2022 --module NodeNext --moduleResolution nodenext --strict --skipLibCheck --types node extensions/<extension-name>/index.ts
```

If the full `.pi` project typecheck is healthy, prefer:

```bash
cd .pi && pnpm exec tsc --noEmit
```

## Review Checklist

- Does `/reload` discover the extension?
- Are event handlers thin?
- Are side effects isolated?
- Is user-facing behavior preserved?
- Are settings/config files only modified intentionally?
- Is the module split small and cohesive?

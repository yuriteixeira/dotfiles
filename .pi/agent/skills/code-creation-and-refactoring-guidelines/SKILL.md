---
name: code-creation-and-refactoring-guidelines
description: Create or refactor TypeScript/JavaScript code using Clean Architecture, Clean Code, and SOLID-inspired boundaries with a functional/module-first style. Use when writing new code or improving existing code while preserving behavior.
---

# Code Creation and Refactoring Guidelines

Use this skill when creating or refactoring TypeScript/JavaScript code with maintainability, small modules, clear boundaries, and behavior preservation as primary goals.

## Core Style

- Prefer top-level functions and module composition over classes.
- Do not introduce classes unless explicitly requested or required by existing architecture/framework constraints.
- Avoid defining functions inside functions; use small top-level functions or cohesive modules.
- Split files into focused auxiliary modules when a file becomes too large to scan easily.
- Keep functions and modules small, descriptive, and single-purpose.
- Prefer explicit state passed through functions over hidden global state.
- Use descriptive but concise names based on domain concepts.

## Architecture Guidelines

- Keep high-level orchestration separate from implementation details.
- Isolate side effects at boundaries:
  - persistence and file I/O
  - external APIs/processes
  - framework/event wiring
  - UI/status/notification formatting
- Keep dependencies pointing inward toward domain/application policy.
- Use interfaces/type aliases only where they clarify a real boundary.
- Avoid speculative abstractions.
- Preserve public APIs, commands, config formats, data contracts, and user-facing behavior unless a breaking change is approved.

## Refactoring Workflow

1. Inspect the target structure, tests, build scripts, and relevant context files.
2. Identify concrete smells before editing:
   - oversized modules
   - mixed orchestration and I/O
   - duplicated formatting/persistence logic
   - vague naming
   - hidden mutable state
   - nested functions or unjustified classes
3. Propose a short incremental plan.
4. Apply the smallest coherent refactor that improves boundaries.
5. Run relevant tests, type checks, linters, or builds when available.
6. Summarize changed files, behavior preserved, validation run, and intentional follow-up work.

## Creation Workflow

1. Clarify the externally observable behavior and constraints.
2. Start with the smallest useful module structure.
3. Keep entrypoints thin and delegate behavior to focused functions/modules.
4. Make side effects explicit and easy to find.
5. Add validation or tests when behavior is non-trivial.

## TypeScript Preferences

- Use `import type` for type-only imports.
- Prefer simple data shapes and functions over inheritance.
- Keep pure helpers separate from I/O helpers.
- Keep ESM imports compatible with the project config.
- Avoid new dependencies unless they clearly reduce complexity.

## Constraints

- Do not perform a large rewrite when small sequential refactors are safer.
- Do not mix unrelated formatting-only churn with semantic refactors.
- If changes are unrelated, propose a split before editing or committing.

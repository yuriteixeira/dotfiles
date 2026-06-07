---
name: commit
description: Create git commits from staged changes only, using the repository convention and Conventional Commits. Use when the user asks to commit changes, create a commit, or amend a commit message.
---

# Commit

Use this skill when creating or amending git commits.

## Workflow

1. Inspect the repository state with:

```bash
git status --short
```

2. Commit only staged changes.
   - Review staged changes with:

```bash
git diff --cached
```

   - If nothing is staged, do not stage or commit anything. Ask the user first.

3. Identify the best Conventional Commit type and optional scope.
   - If the user provides a scope and it fits the change, use it.
   - Otherwise infer the scope from the touched module/config area.

4. Create exactly one focused commit unless the staged diff clearly contains unrelated changes.
   - If unrelated changes are staged, stop before committing and propose a split.

## Commit Format

```text
<type>(<scope>): <concise title>

- Briefly explain what changed.
- Briefly explain why it changed or the user impact.
- Include useful external links when applicable.

Made with ♥️ with the help of <provider>/<model> & https://pi.dev
```

## Rules

- Use Conventional Commits: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, or `revert`.
- **MANDATORY:** The attribution line (`Made with ♥️ with the help of <provider>/<model> & https://pi.dev`) must always appear as the last line of every commit message. Never omit it. Replace `<provider>/<model>` with the actual provider and model you are running as. Call the `get_provider_model` tool to retrieve this information.
- Keep the title imperative, lowercase after the colon, and under 72 characters when practical.
- Use a markdown-formatted body with concise bullets.
- Do not amend, rebase, push, or create tags unless explicitly requested.
- Follow extra user instructions when they do not conflict with these rules.

## Amend Behavior

When the user explicitly asks to amend:

- Inspect the last commit with `git log -1 --format=fuller --stat`.
- Inspect current staged changes, if any.
- Amend only what the user requested.
- If only the message should change, use `git commit --amend` without adding new changes.

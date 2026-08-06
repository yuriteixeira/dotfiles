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

<description>
```

In the description, briefly explain what changed, why it changed or the user impact.
Include useful external links when applicable.

## Rules

- Use Conventional Commits: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, or `revert`.
- Title prios to describe what was done before how (eg: instead of "added xyz", prefer "xyz added")
- If too long, use markdown-formatted body with concise bullets.
- In the description, code references should use backticks (eg: `someVariable`)
- Do not amend, rebase, push, or create tags unless explicitly requested.
- Follow extra user instructions when they do not conflict with these rules.

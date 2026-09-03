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

Review staged changes with:

```bash
git diff --cached
```

If nothing is staged, do not stage or commit anything. Ask the user first.

3. Identify the best Conventional Commit type and optional scope.

   - If the user provides a scope and it fits the change, use it.
   - Otherwise infer the scope from the touched module/config area.

4. Create exactly one focused commit unless the staged diff clearly contains unrelated changes.

If unrelated changes are staged, stop before committing and propose a split.

## Commit Format

Use Conventional Commits format. Also, try to follow this template:

```text
<type>(<scope>): <concise title>

<motivation and relevant ticket/link>

<non-obvious technical reason and intended behavior>

Important details:
------------------

- <concrete behavior or edge case>
- <concrete behavior or edge case>
```

Keep the body proportional to the change. If short and simple enough, there's not need to a adhere completely to the template.

## Writing a High-Quality Commit Body

1. Focus on explaining WHY we need the change.

Why the change is needed is the most important thing for the reviewer. Do not focus much on which files or APIs changed (since the diff does this job), but it's ok to highlight key changes. 

Then, the second most important is to explain why it was done this way.

Include relevant tickets (if available) and external links when appliacable.

2. Highlight the behaviour changes, specially the ones that directly affect the user experiece.

3. Use "Simplified Technical English" (STE).

4. Specifics should be explicit

When referring to domain-specific terminology, be explicit to avoid ambiguity. 

For instance, if we're talking about an app running on a TV, when mentioning the BACK action of a remote control, saying "when the BACK button is pressed" is better than "on Back". The least amount of eyebrows raised while reviewing, the better.

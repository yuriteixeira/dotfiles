# Pi Memories

A manual reflection extension that turns repeated session evidence into review-only project knowledge proposals.

## Usage

After the extension is available under `~/.pi/agent/extensions/pi-memories/`, reload Pi and run it interactively:

```text
/reload
/reflect
```

Run the same workflow outside an existing Pi session with:

```bash
~/.pi/agent/extensions/pi-memories/bin/reflect
~/.pi/agent/extensions/pi-memories/bin/reflect /path/to/project
```

The standalone executable starts an ephemeral, tool-free Pi process with only this extension loaded.

The command:

1. Resolves the Git root, falling back to Pi's current working directory.
2. Selects the 20 newest sessions whose recorded cwd is inside that project.
3. Builds bounded active-branch transcripts without thinking blocks, images, or bulk file contents.
4. Uses `openai-codex/gpt-5.6-sol` with high reasoning for evidence extraction and promotion review.
5. Writes `.pi/reflections/<timestamp>.md` in the project root.

It never edits `AGENTS.md` or skills. Review and apply useful proposals manually.

## Architecture

```text
 Interactive Pi                      Standalone / background
 +----------------------------+      +----------------------------+
 | /reflect                   |      | bin/reflect                |
 | quit or /new confirmation  |      | ephemeral, tool-free Pi   |
 +-------------+--------------+      +-------------+--------------+
               |                                   |
               +-----------------+-----------------+
                                 |
                                 v
 +--------------------------------------------------------------------+
 | runtime/                                                           |
 | reflect-command.ts        command UI and status                    |
 | reflect-on-shutdown.ts    lifecycle confirmation                   |
 | background-reflection.ts  detached process launch                  |
 +-------------------------------+------------------------------------+
                                 |
                                 v
 +--------------------------------------------------------------------+
 | reflection/run.ts                                                  |
 | trust checks, project-root resolution, and pipeline orchestration  |
 +-----------------+--------------------------------+-----------------+
                   |                                |
                   v                                v
 +--------------------------------+   +--------------------------------+
 | sessions/                      |   | reflection/knowledge.ts        |
 | selection -> load -> transcript|   | project/global instructions   |
 | active branch, bounded/redacted|   | and skills; reference-only    |
 +---------------+----------------+   +----------------+---------------+
                 |                                     |
                 v                                     |
       +------------------------+                      |
       | Evidence extraction    |                      |
       | model call, no tools   |                      |
       +------------+-----------+                      |
                    |                                  |
                    +-------------+--------------------+
                                  |
                                  v
                      +---------------------------+
                      | Promotion review          |
                      | model call, no tools      |
                      +-------------+-------------+
                                    |
                                    v
                      +---------------------------+
                      | response-validation.ts    |
                      | IDs, targets, paths, and  |
                      | confidence                |
                      +-------------+-------------+
                                    |
                                    v
                      +---------------------------+
                      | draft.ts                  |
                      | review-only Markdown      |
                      +-------------+-------------+
                                    |
                                    v
                      .pi/reflections/<timestamp>.md
                      (never applied automatically)
```

The dependency direction is `runtime -> reflection -> sessions`. Raw session data reaches the model only after active-branch selection, bounding, redaction, and normalization.

## Reflection on exit

When quitting an interactive Pi session or explicitly starting `/new`, the extension offers to reflect on the departing session. Choosing **Yes** starts a detached Pi process and allows the original session to exit or be replaced. The background run analyzes only the departing session and its active branch.

The prompt is skipped for empty or ephemeral sessions and for reload, resume, fork, and clone operations.

## Promotion scope

Drafts may propose only:

- `AGENTS.md` changes for broad, durable project rules.
- `.pi/skills/<name>/SKILL.md` changes for reusable project procedures.

The model calls receive no tools. Promotion review compares candidates with existing project instructions plus project and global skills to avoid duplicate guidance. Global knowledge is reference-only and is never a proposal target. Session references, evidence IDs, target paths, and structured responses are validated before a draft is written.

## Validation

```bash
node --experimental-strip-types --test .pi/agent/extensions/pi-memories/src/pi-memories.test.ts
```

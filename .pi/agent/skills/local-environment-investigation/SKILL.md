---
name: local-environment-investigation
description: Systematically explore a local codebase, configuration files, installed tools, and system behaviors before implementing anything. Use when working on code, config, or integrations that interact with an existing system.
---

# Local Environment Investigation

Before implementing anything that touches an existing system, first explore what is already
there. Reading beats guessing.

## Principles

- **Read before you write.** Never propose a solution until you have verified it against
  existing code, configs, and tools.
- **Start minimal.** The simplest solution that works is almost always better than the
  clever one.
- **Look for existing patterns.** If similar functionality already exists, extend or adapt
  it rather than building from scratch.

## Workflow

### 1. Map the territory

Understand the high-level structure before diving into details:

- What are the top-level directories and their purposes?
- What package manager or build system is in use?
- What configuration files exist at the top level and in key subdirectories?
- Are there existing scripts, binaries, or entry points?

```
ls -la              # top-level structure
find . -maxdepth 2  # narrow directory tree
ls <key-dirs>       # explore likely locations for relevant files
```

### 2. Find existing patterns

Search for how similar functionality is already implemented:

- What conventions, naming, or structures are already in use?
- Are there similar features, commands, or utilities already present?
- What patterns do existing config files or scripts follow?

```
grep -r "keyword" .              # search for existing patterns
grep -r "command" .              # find how a specific tool or feature is used
```

### 3. Check available tools

Know what is already installed before proposing new dependencies:

- What tools or binaries are available in PATH?
- What packages or dependencies exist?
- What protocols or interfaces are already supported?

```
which <tool>        # check if a specific tool exists
type <tool>         # more detailed info about a binary
dpkg -l | grep ...  # or equivalent package query for the system
```

### 4. Understand system behaviors

Some platform or framework behaviors change everything. Research how the system
actually works:

- Read the relevant config files to understand what is already configured
- Read the source or documentation for known behaviors, quirks, or lifecycle hooks
- Search for documented behaviors: `"tool behavior"` or `"platform feature"`
- Ask: does the system already handle this, even partially?

### 5. Verify before committing

Before proposing an implementation:

- Does a minimal version of the solution actually work?
- Are you relying on assumptions about the environment? Verify them.
- Have you checked that existing tools or patterns already cover part of what you need?

## Anti-patterns

- **Building before reading.** Do not implement until you have verified the approach
  against existing code and configs.
- **Over-engineering without verification.** Do not introduce complex abstractions before
  confirming the simple version fails.
- **Ignoring existing patterns.** Do not reinvent what already exists in the codebase.
- **Assuming platform behavior.** Do not assume how the OS, WM, or framework works.
  Check the docs or source.

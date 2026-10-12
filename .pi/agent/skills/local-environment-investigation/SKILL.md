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
fd -d 2             # narrow directory tree (modern find replacement)
ls <key-dirs>       # explore likely locations for relevant files
```

### 2. Find existing patterns

Search for how similar functionality is already implemented:

- What conventions, naming, or structures are already in use?
- Are there similar features, commands, or utilities already present?
- What patterns do existing config files or scripts follow?

```
rg "keyword"                   # search for existing patterns (modern grep replacement)
rg "command"                   # find how a specific tool or feature is used
```

### 3. Check available tools

Know what is already installed before proposing new dependencies:

- What tools or binaries are available in PATH?
- What package manager does the system use? Detect it first (`which pacman`, `which brew`,
  `which dnf`, etc.).
- What packages or dependencies exist?
- What protocols or interfaces are already supported?

```sh
which <package-manager>   # detect which package manager is available
which <tool>              # check if a specific tool exists
type <tool>               # more detailed info about a binary
```

Once you know the package manager, use it to query installed packages:

```sh
pacman -Q | rg <pattern>      # Arch: partial match from base packages
yay -Q | rg <pattern>         # Arch AUR: partial match from AUR packages
brew list | rg ...            # macOS: partial match
dpkg -l | rg ...              # Debian/Ubuntu: partial match
dnf list installed | rg ...   # Fedora/RHEL: partial match
```

Use partial-match queries, not exact matches. Package names may differ from binary names
(`audacity4-alpha` provides `audacity`, `librewolf` provides `librewolf`). Use `rg` against
the full package list to catch pre-release, split, and variant packages. Also, use tools like `pacman -F` or `yay -F` to find out to which package an executable belongs. 

### 4. Verify before committing

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
- **Using exact-match queries for packages.** Do not run `pacman -Qi <name>` expecting to
  find a package named `audacity` when the installed package is `audacity4-alpha`. Always
  search the full package list with `rg` to catch pre-release, split, and variant names.

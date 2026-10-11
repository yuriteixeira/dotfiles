# Terminal Replay Tools for tmux

## Overview

Tools for recording and replaying terminal sessions, specifically those that integrate well with tmux.

---

## Recommended: tvmux

A tmux-specific terminal recorder built around asciinema. It records individual panes and follows your cursor when you switch between them.

- **Why it stands out:** Tracks pane switches automatically, so your recording stays coherent
- **Format:** asciinema `.cast` files
- **No wrapping required:** Runs as a background server; you do not need to wrap your tmux session
- **Install:** `pip install tvmux` or `uvx tvmux`

**Quick start:**

```bash
tvmux rec          # record current window
tvmux rec ls       # list ongoing recordings
tvmux rec stop     # stop all
```

---

## asciinema + tmux pipe-pane

You can record a single tmux pane by piping it into asciinema.

```bash
# From the shell inside a tmux pane
asciinema rec output.cast

# Or pipe an existing pane
tmux pipe-pane -o "asciinema rec output.cast"
```

- **Pros:** Simple, well-documented, supports web sharing
- **Cons:** No automatic pane tracking; you must manage recording scope manually

---

## term-recorder

A Node.js tool that drives tmux programmatically and produces asciinema casts.

- **Best for:** Automated/scripted recordings
- **Requires:** Node.js 20+ (or Bun/Deno), tmux 3.4+, asciinema 3.0+

---

## Not Recommended for tmux

### script / scriptreplay (util-linux)
Part of standard Linux installations, but it records the full PTY, not tmux panes. It does not track pane boundaries and is harder to manage inside tmux.

### rewindtty
A C-based recorder with JSON output. Good for analysis, but tmux integration is not its focus.

---

## Summary

| Tool | tmux-native | Follows panes? | Format | Install size |
|---|---|---|---|---|
| tvmux | yes | yes | asciinema | medium |
| asciinema | via pipe | manual | asciinema | small |
| term-recorder | yes | automatic | asciinema | small |
| script/scriptreplay | no | no | typescript | built-in |

For tmux users, **tvmux** is the clear choice.

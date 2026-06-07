/**
 * Built-in Tools Extension
 *
 * Always enables grep, find, and ls (read-only built-in tools that are off by default)
 * by appending them to the active tool list on session start.
 */

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

const EXTRA_BUILTIN_TOOLS = ["grep", "find", "ls"];

function enableExtraTools(pi: ExtensionAPI) {
  const active = pi.getActiveTools();
  const toAdd = EXTRA_BUILTIN_TOOLS.filter((t) => !active.includes(t));
  if (toAdd.length > 0) {
    pi.setActiveTools([...active, ...toAdd]);
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, _ctx) => {
    enableExtraTools(pi);
  });

  pi.on("session_before_fork", async (_event, _ctx) => {
    enableExtraTools(pi);
  });

  pi.on("session_before_switch", async (_event, _ctx) => {
    enableExtraTools(pi);
  });
}

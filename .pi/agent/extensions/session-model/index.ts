import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
  keepSelectionEphemeral,
  rememberActiveModel,
  saveSessionModel,
  showRestoredSessionModel,
  startSession,
} from "./use-cases.js";
import { createInitialState } from "./state.js";

export default function (pi: ExtensionAPI) {
  const state = createInitialState();

  pi.on("session_start", async (_event, ctx) => {
    await startSession(state, ctx, (model) => pi.setModel(model));
  });

  pi.on("session_before_switch", (_event, ctx) => {
    // Remember the active model before the session switches/starts
    rememberActiveModel(state, ctx);
  });

  pi.on("session_shutdown", (_event, ctx) => {
    rememberActiveModel(state, ctx);
  });

  pi.registerCommand("save-model", {
    description: "Save the current in-session model as the default in settings.json",
    handler: async (_args, ctx) => {
      await saveSessionModel(state, ctx);
    },
  });

  pi.on("model_select", async (event, ctx) => {
    const sessionModel = {
      provider: event.model.provider,
      model: event.model.id,
    };

    if (event.source === "restore") {
      await showRestoredSessionModel(state, sessionModel, ctx);
      return;
    }

    await keepSelectionEphemeral(state, sessionModel, ctx);
  });
}

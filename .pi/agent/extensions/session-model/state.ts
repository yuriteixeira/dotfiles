import { join } from "node:path";
import type { SavedModel, SessionModelState } from "./types.js";

let rememberedSessionModel: SavedModel | null = null;

export function createInitialState(): SessionModelState {
  return {
    savedModel: null,
    sessionModel: rememberedSessionModel,
    settings: {
      candidatePaths: settingsSearchPaths(),
      path: null,
    },
  };
}

export function rememberSessionModel(state: SessionModelState, sessionModel: SavedModel): void {
  state.sessionModel = sessionModel;
  rememberedSessionModel = sessionModel;
}

function settingsSearchPaths(): string[] {
  return [
    join(process.cwd(), ".pi", "agent", "settings.json"),
    join(process.env.HOME ?? "~", ".pi", "agent", "settings.json"),
  ];
}

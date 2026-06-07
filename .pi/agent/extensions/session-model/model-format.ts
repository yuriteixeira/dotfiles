import type { ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { SavedModel } from "./types.js";

export const EXTENSION_NAME = "session-model";

export const ICON = {
  session: "\uf2db", // nf-fa-microchip
  saved: "\uf02e", // nf-fa-bookmark
  save: "\uf0c7", // nf-fa-floppy_o
  switch: "\uf0ec", // nf-fa-exchange
} as const;

export function showModelStatus(
  ctx: ExtensionContext,
  sessionModel: SavedModel,
  savedModel: SavedModel
): void {
  ctx.ui.setStatus(
    EXTENSION_NAME,
    `${ICON.session} ${modelName(sessionModel)} · ${ICON.saved} ${modelName(savedModel)}`
  );
}

export function sameModel(left: SavedModel, right: SavedModel): boolean {
  return left.provider === right.provider && left.model === right.model;
}

export function modelKey(model: SavedModel): string {
  return `${model.provider ?? "unknown"}/${model.model ?? "unknown"}`;
}

export function modelName(model: SavedModel): string {
  return model.model ?? "unknown";
}

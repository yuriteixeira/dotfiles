import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { hasSettingsPath, readSavedModel, saveModel } from "./settings-store.js";
import { rememberSessionModel } from "./state.js";
import type { SavedModel, SessionModelState } from "./types.js";
import { EXTENSION_NAME, ICON, modelKey, modelName, sameModel, showModelStatus } from "./model-format.js";

export type SetModel = ExtensionAPI["setModel"];

export async function startSession(
  state: SessionModelState,
  ctx: ExtensionContext,
  setModel: SetModel
): Promise<void> {
  const savedModel = await readSavedModel(state.settings);

  if (!savedModel) {
    console.warn(`[${EXTENSION_NAME}] No settings.json found`);
    return;
  }

  state.savedModel = savedModel;

  const activeModel = currentModel(ctx) ?? savedModel;
  const sessionModel = state.sessionModel;
  const displayModel = await restoreSessionModel(sessionModel, activeModel, ctx, setModel);

  showModelStatus(ctx, displayModel, savedModel);
}

export async function showRestoredSessionModel(
  state: SessionModelState,
  sessionModel: SavedModel,
  ctx: ExtensionContext
): Promise<void> {
  if (!state.savedModel) return;

  showModelStatus(ctx, sessionModel, state.savedModel);
}

export async function saveSessionModel(
  state: SessionModelState,
  ctx: ExtensionContext
): Promise<void> {
  if (!hasSettingsPath(state.settings)) {
    ctx.ui.notify("No settings.json found", "error");
    return;
  }

  const activeModel = ctx.model;
  if (!activeModel) {
    ctx.ui.notify("No active model to save", "error");
    return;
  }

  await persistActiveModel(state, activeModel.provider, activeModel.id, ctx);
}

export function rememberActiveModel(state: SessionModelState, ctx: ExtensionContext): void {
  const activeModel = currentModel(ctx);
  if (!activeModel) return;

  rememberSessionModel(state, activeModel);
}

export async function keepSelectionEphemeral(
  state: SessionModelState,
  sessionModel: SavedModel,
  ctx: ExtensionContext
): Promise<void> {
  rememberSessionModel(state, sessionModel);

  if (!state.savedModel || !hasSettingsPath(state.settings)) return;

  await restoreSavedModel(state);
  showModelStatus(ctx, sessionModel, state.savedModel);
  notifySessionOnlyModel(ctx, sessionModel, state.savedModel);
}

async function persistActiveModel(
  state: SessionModelState,
  provider: string,
  model: string,
  ctx: ExtensionContext
): Promise<void> {
  const modelToSave = { provider, model };

  try {
    await saveModel(state.settings, modelToSave);
    state.savedModel = modelToSave;
    rememberSessionModel(state, modelToSave);
    showModelStatus(ctx, modelToSave, modelToSave);
    ctx.ui.notify(`${ICON.save} Saved ${modelKey(modelToSave)} as default in settings.json`, "info");
  } catch (err) {
    ctx.ui.notify(`Failed to save: ${err}`, "error");
  }
}

async function restoreSessionModel(
  sessionModel: SavedModel | null,
  activeModel: SavedModel,
  ctx: ExtensionContext,
  setModel: SetModel
): Promise<SavedModel> {
  if (!sessionModel) return activeModel;
  if (sameModel(activeModel, sessionModel)) return sessionModel;

  const didSelect = await selectSessionModel(sessionModel, ctx, setModel);
  return didSelect ? sessionModel : activeModel;
}

async function selectSessionModel(
  sessionModel: SavedModel,
  ctx: ExtensionContext,
  setModel: SetModel
): Promise<boolean> {
  if (!isCompleteModel(sessionModel)) return false;

  const models = await ctx.modelRegistry.getAvailable();
  const model = models.find(
    (availableModel) =>
      availableModel.provider === sessionModel.provider && availableModel.id === sessionModel.model
  );

  if (!model) {
    console.warn(`[${EXTENSION_NAME}] Session model not found: ${modelKey(sessionModel)}`);
    return false;
  }

  const didSelect = await setModel(model);
  if (!didSelect) {
    console.warn(`[${EXTENSION_NAME}] Session model unavailable: ${modelKey(sessionModel)}`);
  }

  return didSelect;
}

async function restoreSavedModel(state: SessionModelState): Promise<void> {
  if (!state.savedModel) return;

  for (const delayMs of RESTORE_DELAYS_MS) {
    await sleep(delayMs);

    try {
      await saveModel(state.settings, state.savedModel);
    } catch (err) {
      console.error(`[${EXTENSION_NAME}] Failed to restore settings:`, err);
      return;
    }
  }
}

function sleep(delayMs: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, delayMs));
}

// Pi core persists model changes before emitting model_select; repeat the
// restore so the saved model wins even if Pi's async settings write lands late.
const RESTORE_DELAYS_MS = [0, 50, 250] as const;

function notifySessionOnlyModel(
  ctx: ExtensionContext,
  sessionModel: SavedModel,
  savedModel: SavedModel
): void {
  if (sameModel(sessionModel, savedModel)) return;

  ctx.ui.notify(
    `${ICON.switch} Switched to ${modelKey(sessionModel)} for this session (saved: ${modelName(savedModel)})`,
    "info"
  );
}

function currentModel(ctx: ExtensionContext): SavedModel | null {
  if (!ctx.model) return null;

  return {
    provider: ctx.model.provider,
    model: ctx.model.id,
  };
}

function isCompleteModel(model: SavedModel): model is Required<SavedModel> {
  return typeof model.provider === "string" && typeof model.model === "string";
}

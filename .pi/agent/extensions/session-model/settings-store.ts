import { readFile, writeFile } from "node:fs/promises";
import type { SavedModel, Settings, SettingsStore } from "./types.js";

export async function readSavedModel(settingsStore: SettingsStore): Promise<SavedModel | null> {
  settingsStore.path = await findReadablePath(settingsStore.candidatePaths);
  if (!settingsStore.path) return null;

  const settings = await readSettingsFile(settingsStore.path);
  return {
    provider: settings.defaultProvider,
    model: settings.defaultModel,
  };
}

export async function saveModel(settingsStore: SettingsStore, model: SavedModel): Promise<void> {
  if (!settingsStore.path) throw new Error("No settings.json found");

  const settings = await readSettingsFile(settingsStore.path);
  settings.defaultProvider = model.provider;
  settings.defaultModel = model.model;
  await writeSettingsFile(settingsStore.path, settings);
}

export function hasSettingsPath(settingsStore: SettingsStore): boolean {
  return settingsStore.path !== null;
}

async function findReadablePath(paths: string[]): Promise<string | null> {
  for (const path of paths) {
    if (await canRead(path)) return path;
  }

  return null;
}

async function canRead(path: string): Promise<boolean> {
  try {
    await readFile(path, "utf8");
    return true;
  } catch {
    return false;
  }
}

async function readSettingsFile(path: string): Promise<Settings> {
  return JSON.parse(await readFile(path, "utf8"));
}

async function writeSettingsFile(path: string, settings: Settings): Promise<void> {
  await writeFile(path, JSON.stringify(settings, null, 2) + "\n", "utf8");
}

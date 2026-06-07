export interface SessionModelState {
  savedModel: SavedModel | null;
  sessionModel: SavedModel | null;
  settings: SettingsStore;
}

export interface SettingsStore {
  candidatePaths: string[];
  path: string | null;
}

export interface SavedModel {
  provider?: string;
  model?: string;
}

export interface Settings {
  defaultProvider?: string;
  defaultModel?: string;
  [key: string]: unknown;
}

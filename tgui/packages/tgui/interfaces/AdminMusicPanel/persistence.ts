import { storage } from 'common/storage';

import { AdminMusicPanelTab, LaunchSettings } from './types';

const PANEL_SETTINGS_STORAGE_KEY = 'panel-settings';

export const loadAdminMusicPanelUiState = async (): Promise<{
  activeTab: AdminMusicPanelTab;
  launchSettings: Partial<LaunchSettings> | null;
}> => {
  const settings = (await storage.get(PANEL_SETTINGS_STORAGE_KEY)) || {};
  const activeTab = settings?.adminMusicActiveTab === 'edit' ? 'edit' : 'play';
  const launchSettings =
    settings?.adminMusicLaunchSettings &&
    typeof settings.adminMusicLaunchSettings === 'object'
      ? settings.adminMusicLaunchSettings
      : null;

  return {
    activeTab,
    launchSettings,
  };
};

export const saveAdminMusicPanelUiState = async (nextState: {
  activeTab?: AdminMusicPanelTab;
  launchSettings?: LaunchSettings;
}) => {
  const settings = (await storage.get(PANEL_SETTINGS_STORAGE_KEY)) || {};
  const nextSettings = { ...settings };

  if (nextState.activeTab) {
    nextSettings.adminMusicActiveTab = nextState.activeTab;
  }

  if (nextState.launchSettings) {
    nextSettings.adminMusicLaunchSettings = nextState.launchSettings;
  }

  await storage.set(PANEL_SETTINGS_STORAGE_KEY, nextSettings);
};

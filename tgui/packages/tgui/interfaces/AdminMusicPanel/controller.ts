import { useEffect, useRef, useState } from 'react';

import { useBackend } from '../../backend';
import {
  buildLaunchSettings,
  coerceLaunchSettings,
  findTier,
  findVariant,
  getDisplayedLaunchSettings,
  getDraftStatus,
  getOptionLabel,
  getTrackLaunchReadiness,
  isCurrentSessionForSelection,
  toSelectOptions,
} from './helpers';
import {
  loadAdminMusicPanelUiState,
  saveAdminMusicPanelUiState,
} from './persistence';
import { useAdminMusicPreview } from './preview';
import { AdminMusicPanelData, LaunchSettings } from './types';

export function useAdminMusicPanelController() {
  const { act, data } = useBackend<AdminMusicPanelData>();
  const {
    library,
    draft,
    draft_token,
    dirty,
    selected_tier_id,
    selected_variant_id,
    can_delete_saved_preset,
    current_session,
    audience_options,
    sound_type_options,
    preview_command,
  } = data;

  const [activeTab, setActiveTab] = useState<'play' | 'edit'>('play');
  const [librarySearch, setLibrarySearch] = useState('');
  const [launchSettings, setLaunchSettings] = useState<LaunchSettings>(() =>
    buildLaunchSettings(draft),
  );
  const [prefsHydrated, setPrefsHydrated] = useState(false);

  const initialLibrarySyncRef = useRef(false);
  const { isPreviewActive, previewState, stopPreview } = useAdminMusicPreview(
    preview_command,
    () => act('stop_preview'),
  );

  useEffect(() => {
    let cancelled = false;

    const hydrateUiState = async () => {
      const persistedState = await loadAdminMusicPanelUiState();
      if (cancelled) {
        return;
      }

      setActiveTab(persistedState.activeTab);
      setLaunchSettings(
        coerceLaunchSettings(draft, persistedState.launchSettings),
      );
      setPrefsHydrated(true);
    };

    void hydrateUiState();

    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    if (!prefsHydrated) {
      return;
    }

    setLaunchSettings((current) => coerceLaunchSettings(draft, current));
  }, [draft_token, prefsHydrated]);

  useEffect(() => {
    if (!prefsHydrated) {
      return;
    }

    void saveAdminMusicPanelUiState({
      activeTab,
      launchSettings,
    });
  }, [activeTab, launchSettings, prefsHydrated]);

  useEffect(() => {
    if (initialLibrarySyncRef.current) {
      return;
    }
    if (dirty) {
      return;
    }
    if (draft?.preset_id) {
      initialLibrarySyncRef.current = true;
      return;
    }
    if (!library.length) {
      initialLibrarySyncRef.current = true;
      return;
    }

    const initialPresetId = library[0]?.preset_id;
    if (!initialPresetId) {
      initialLibrarySyncRef.current = true;
      return;
    }

    initialLibrarySyncRef.current = true;
    act('load_preset', { preset_id: initialPresetId });
  }, [act, dirty, draft?.preset_id, library]);

  const selectedTier = findTier(draft, selected_tier_id);
  const selectedVariant = findVariant(selectedTier, selected_variant_id);
  const audienceOptions = toSelectOptions(audience_options);
  const soundTypeOptions = toSelectOptions(sound_type_options);
  const selectedTrackIsLive = isCurrentSessionForSelection(
    current_session,
    draft,
    selectedTier,
    selectedVariant,
  );
  const displayedLaunchSettings = getDisplayedLaunchSettings(
    launchSettings,
    current_session,
    selectedTrackIsLive,
  );
  const loadedLibraryPresetId = draft?.preset_id || null;
  const draftStatus = getDraftStatus(draft, dirty);
  const trackReadiness = getTrackLaunchReadiness(
    selectedVariant,
    displayedLaunchSettings,
  );

  const handleImport = (jsonText: string | string[]) => {
    const payload = Array.isArray(jsonText) ? jsonText[0] : jsonText;
    if (payload) {
      act('import_json', { json_text: payload });
    }
  };

  const handleNewDraft = () => {
    act('new_draft');
  };

  const handleLoadPreset = (presetId: string) => {
    if (presetId) {
      act('load_preset', { preset_id: presetId });
    }
  };

  const handleRevertDraft = () => {
    if (!dirty) {
      return;
    }

    if (draft?.preset_id) {
      act('load_preset', { preset_id: draft.preset_id });
      return;
    }

    act('new_draft');
  };

  const handleSetPlaybackMode = (value: LaunchSettings['playback_mode']) => {
    setLaunchSettings((current) => ({
      ...current,
      playback_mode: value,
    }));

    if (selectedTrackIsLive) {
      act('set_live_playback_mode', { playback_mode: value });
    }
  };

  const playTabProps = {
    current_session,
    draft,
    launchSettings: displayedLaunchSettings,
    audienceOptions,
    soundTypeOptions,
    audienceLabel: getOptionLabel(
      audience_options,
      launchSettings.audience_mode,
    ),
    soundTypeLabel: getOptionLabel(
      sound_type_options,
      launchSettings.sound_type,
    ),
    trackReadiness,
    selectedTrackIsLive,
    isPreviewActive,
    previewState,
    library,
    librarySearch,
    loadedLibraryPresetId,
    onSearchChange: setLibrarySearch,
    onLoadPreset: handleLoadPreset,
    onOpenEdit: () => setActiveTab('edit'),
    dirty,
    selectedTier,
    selectedVariant,
    selectedTierId: selected_tier_id,
    selectedVariantId: selected_variant_id,
    onSetAudienceMode: (value: string) =>
      setLaunchSettings((current) => ({
        ...current,
        audience_mode: value,
      })),
    onSetSoundType: (value: string) =>
      setLaunchSettings((current) => ({
        ...current,
        sound_type: value,
      })),
    onToggleRepeat: () =>
      setLaunchSettings((current) => ({
        ...current,
        repeat: !current.repeat,
      })),
    onSetPlaybackMode: handleSetPlaybackMode,
    onResetLaunchSettings: () => setLaunchSettings(buildLaunchSettings(draft)),
    onPreviewSelected: () => act('preview_selected'),
    onStopPreview: stopPreview,
    onPlaySelected: () => act('play_selected', launchSettings),
    onStopBroadcast: () => act('stop_broadcast'),
    onSelectTier: (tier_id: string) => act('select_tier', { tier_id }),
    onSelectVariant: (tier_id: string, variant_id: string) =>
      act('select_variant', { tier_id, variant_id }),
  };

  const editTabProps = {
    draft,
    draftStatus,
    draftToken: draft_token,
    canDelete: can_delete_saved_preset,
    canRevert: dirty,
    audienceOptions,
    soundTypeOptions,
    audienceLabel: getOptionLabel(
      audience_options,
      draft.playback.audience_mode,
    ),
    soundTypeLabel: getOptionLabel(
      sound_type_options,
      draft.playback.sound_type,
    ),
    selectedTier,
    selectedTierId: selected_tier_id,
    selectedVariant,
    selectedVariantId: selected_variant_id,
    onSave: () => act('save'),
    onNew: handleNewDraft,
    onSaveAsCopy: () => act('save_as_copy'),
    onRevert: handleRevertDraft,
    onDelete: () => act('delete_preset', { preset_id: draft.preset_id }),
    onExport: () => act('export_preset'),
    onImport: handleImport,
    onSetName: (value: string) => act('set_name', { name: value }),
    onSetDescription: (value: string) =>
      act('set_description', { description: value }),
    onSetAudienceMode: (value: string) =>
      act('set_audience_mode', { audience_mode: value }),
    onSetSoundType: (value: string) =>
      act('set_sound_type', { sound_type: value }),
    onToggleShowTitle: () =>
      act('set_show_title', {
        show_title_to_players: !draft.playback.show_title_to_players,
      }),
    onToggleRepeat: () =>
      act('set_repeat', {
        repeat: !draft.playback.repeat,
      }),
    onAddTier: () => act('add_tier'),
    onSelectTier: (tier_id: string) => act('select_tier', { tier_id }),
    onRemoveTier: (tier_id: string) => act('remove_tier', { tier_id }),
    onMoveTierUp: (tier_id: string) => act('move_tier_up', { tier_id }),
    onMoveTierDown: (tier_id: string) => act('move_tier_down', { tier_id }),
    onSetTierName: (tier_id: string, value: string) =>
      act('set_tier_name', { tier_id, name: value }),
    onSetTierDescription: (tier_id: string, value: string) =>
      act('set_tier_description', {
        tier_id,
        description: value,
      }),
    onAddVariant: () => act('add_variant'),
    onSelectVariant: (tier_id: string, variant_id: string) =>
      act('select_variant', { tier_id, variant_id }),
    onRemoveVariant: (tier_id: string, variant_id: string) =>
      act('remove_variant', { tier_id, variant_id }),
    onMoveVariantUp: (tier_id: string, variant_id: string) =>
      act('move_variant_up', { tier_id, variant_id }),
    onMoveVariantDown: (tier_id: string, variant_id: string) =>
      act('move_variant_down', { tier_id, variant_id }),
    onSetVariantTitle: (tier_id: string, variant_id: string, value: string) =>
      act('set_variant_title', {
        tier_id,
        variant_id,
        title: value,
      }),
    onSetVariantDescription: (
      tier_id: string,
      variant_id: string,
      value: string,
    ) =>
      act('set_variant_description', {
        tier_id,
        variant_id,
        description: value,
      }),
    onSetVariantDuration: (
      tier_id: string,
      variant_id: string,
      value: number,
    ) =>
      act('set_variant_duration', {
        tier_id,
        variant_id,
        duration_seconds: value,
      }),
    onSetVariantSourceUrl: (
      tier_id: string,
      variant_id: string,
      value: string,
    ) =>
      act('set_variant_source_url', {
        tier_id,
        variant_id,
        source_url: value,
      }),
    onResolveVariantMetadata: (tier_id: string, variant_id: string) =>
      act('resolve_variant_metadata', {
        tier_id,
        variant_id,
      }),
  };

  return {
    activeTab,
    setActiveTab,
    onRequestClose: () => act('request_close'),
    playTabProps,
    editTabProps,
  };
}

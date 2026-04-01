import { storage } from 'common/storage';
import { useEffect, useRef, useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  Flex,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  Tabs,
  TextArea,
} from '../components';
import { Window } from '../layouts';

type LibraryPreset = {
  preset_id: string;
  name: string;
  description: string;
  tier_count: number;
  variant_count: number;
};

type DraftVariant = {
  variant_id: string;
  title: string;
  description: string;
  duration_seconds: number;
  source_url: string;
};

type DraftTier = {
  tier_id: string;
  name: string;
  description: string;
  variants: DraftVariant[];
};

type PlaybackSettings = {
  audience_mode: string;
  sound_type: string;
  show_title_to_players: boolean;
  repeat: boolean;
};

type DraftPreset = {
  preset_id: string;
  name: string;
  description: string;
  playback: PlaybackSettings;
  tiers: DraftTier[];
};

type CurrentSession = null | {
  source_kind: string;
  owner: string;
  audience_label: string;
  sound_type_label: string;
  show_title_to_players: boolean;
  resolved_title: string;
  source_url: string;
  preset_id?: string;
  preset_name?: string;
  tier_name?: string;
  variant_title?: string;
  loop?: boolean;
};

type OptionEntry = { id: string; label: string };

type PreviewCommand = null | {
  nonce: number | string;
  command: 'play' | 'stop';
  title?: string;
  url?: string;
  start?: number;
  end?: number;
};

type AdminMusicPanelData = {
  library: LibraryPreset[];
  draft: DraftPreset;
  draft_token: number;
  dirty: boolean;
  selected_tier_id: string | null;
  selected_variant_id: string | null;
  can_delete_saved_preset: boolean;
  current_session: CurrentSession;
  audience_options: OptionEntry[];
  sound_type_options: OptionEntry[];
  preview_command: PreviewCommand;
};

type SelectOption = { displayText: string; value: string };

const DEFAULT_PREVIEW_VOLUME = 0.2;
const DESCRIPTION_FIELD_HEIGHT = 4.5;
const PLAYER_CARD_STYLE = {
  backgroundColor: 'rgba(255, 255, 255, 0.04)',
  border: '1px solid rgba(255, 255, 255, 0.08)',
  borderRadius: '0.35rem',
  padding: '0.75rem',
};
const COMPACT_CARD_STYLE = {
  backgroundColor: 'rgba(255, 255, 255, 0.035)',
  border: '1px solid rgba(255, 255, 255, 0.07)',
  borderRadius: '0.35rem',
  padding: '0.5rem 0.6rem',
};
const PLAYER_STRIP_STYLE = {
  background:
    'linear-gradient(90deg, rgba(70, 140, 60, 0.22) 0%, rgba(25, 40, 25, 0.24) 100%)',
  border: '1px solid rgba(120, 190, 100, 0.3)',
  borderRadius: '0.35rem',
  padding: '0.85rem',
};
const PLAYER_BADGE_STYLE = {
  display: 'inline-block',
  padding: '0.15rem 0.45rem',
  marginRight: '0.35rem',
  marginBottom: '0.35rem',
  borderRadius: '999px',
  border: '1px solid rgba(255, 255, 255, 0.12)',
  backgroundColor: 'rgba(0, 0, 0, 0.18)',
};
const STATUS_STRIP_STYLE = {
  backgroundColor: 'rgba(255, 255, 255, 0.03)',
  border: '1px solid rgba(255, 255, 255, 0.07)',
  borderRadius: '0.35rem',
  padding: '0.45rem 0.55rem',
};
const SUBTLE_PANEL_STYLE = {
  backgroundColor: 'rgba(255, 255, 255, 0.02)',
  border: '1px solid rgba(255, 255, 255, 0.05)',
  borderRadius: '0.35rem',
  padding: '0.45rem 0.55rem',
};
const UNSAVED_BADGE_STYLE = {
  display: 'inline-block',
  padding: '0.15rem 0.45rem',
  borderRadius: '999px',
  border: '1px solid rgba(255, 208, 102, 0.45)',
  backgroundColor: 'rgba(255, 208, 102, 0.12)',
};
const MUTED_BADGE_STYLE = {
  display: 'inline-block',
  padding: '0.15rem 0.45rem',
  borderRadius: '999px',
  border: '1px solid rgba(255, 255, 255, 0.1)',
  backgroundColor: 'rgba(255, 255, 255, 0.03)',
};
const LIVE_BADGE_STYLE = {
  display: 'inline-block',
  padding: '0.15rem 0.45rem',
  borderRadius: '999px',
  border: '1px solid rgba(120, 190, 100, 0.35)',
  backgroundColor: 'rgba(70, 140, 60, 0.12)',
};
const LABEL_STYLE = {
  fontSize: '0.8rem',
  color: 'rgba(214, 223, 233, 0.75)',
};
const ELLIPSIS_STYLE = {
  overflow: 'hidden',
  textOverflow: 'ellipsis',
  whiteSpace: 'nowrap',
};
const LIST_SCROLL_STYLE = {
  height: '100%',
  overflowY: 'auto',
  paddingRight: '0.1rem',
};
const DISABLED_ACTION_STYLE = {
  opacity: '0.45',
  filter: 'saturate(0.6)',
};

const getToggleButtonStyle = (checked: boolean) => ({
  border: checked
    ? '1px solid rgba(137, 171, 214, 0.45)'
    : '1px solid rgba(255, 255, 255, 0.07)',
  backgroundColor: checked
    ? 'rgba(102, 131, 171, 0.16)'
    : 'rgba(255, 255, 255, 0.025)',
  color: checked ? 'rgba(244, 248, 252, 0.96)' : 'rgba(214, 223, 233, 0.92)',
});

const getListRowStyle = (selected: boolean) => ({
  marginBottom: '0.2rem',
  padding: '0.28rem 0.45rem',
  borderRadius: '0.32rem',
  border: selected
    ? '1px solid rgba(137, 171, 214, 0.55)'
    : '1px solid rgba(255, 255, 255, 0.06)',
  backgroundColor: selected
    ? 'rgba(102, 131, 171, 0.22)'
    : 'rgba(255, 255, 255, 0.025)',
});

const normalizeDurationValue = (duration_seconds: number) => {
  if (!Number.isFinite(duration_seconds) || duration_seconds < 0) {
    return 0;
  }
  return Object.is(duration_seconds, -0) ? 0 : duration_seconds;
};

const formatDuration = (duration_seconds: number) => {
  const normalizedDuration = normalizeDurationValue(duration_seconds);
  if (!normalizedDuration) {
    return 'Unknown';
  }
  const seconds = Math.floor(normalizedDuration);
  const minutes = Math.floor(seconds / 60);
  const remainder = seconds % 60;
  return minutes
    ? `${minutes}m ${String(remainder).padStart(2, '0')}s`
    : `${remainder}s`;
};

const formatSourceLabel = (source_url: string) => {
  if (!source_url) {
    return 'Source not set';
  }
  try {
    return new URL(source_url).hostname.replace(/^www\./, '');
  } catch {
    return source_url;
  }
};

const countTracks = (draft: DraftPreset) =>
  draft.tiers.reduce((total, tier) => total + tier.variants.length, 0);

const findTier = (draft: DraftPreset, tierId: string | null) =>
  draft.tiers.find((tier) => tier.tier_id === tierId) || draft.tiers[0] || null;

const findVariant = (tier: DraftTier | null, variantId: string | null) =>
  tier?.variants.find((variant) => variant.variant_id === variantId) ||
  tier?.variants[0] ||
  null;

const buildLaunchSettings = (draft: DraftPreset): PlaybackSettings => ({
  audience_mode: draft.playback.audience_mode,
  sound_type: draft.playback.sound_type,
  show_title_to_players: draft.playback.show_title_to_players,
  repeat: draft.playback.repeat,
});

const getOptionLabel = (options: OptionEntry[], value: string) =>
  options.find((option) => option.id === value)?.label || value;

const toSelectOptions = (options: OptionEntry[]): SelectOption[] =>
  options.map((option) => ({
    displayText: option.label,
    value: option.id,
  }));

const formatTrackCount = (count: number) =>
  `${count} track${count === 1 ? '' : 's'}`;

const formatPlaybackFlags = (
  playback: PlaybackSettings,
  audienceLabel: string,
  soundTypeLabel: string,
) =>
  [
    `Audience ${audienceLabel}`,
    `Mode ${soundTypeLabel}`,
    `Repeat ${playback.repeat ? 'On' : 'Off'}`,
  ].join(' | ');

const isCurrentSessionForSelection = (
  currentSession: CurrentSession,
  draft: DraftPreset,
  selectedTier: DraftTier | null,
  selectedVariant: DraftVariant | null,
) => {
  if (!currentSession || !selectedTier || !selectedVariant) {
    return false;
  }

  const matchesByPreset =
    Boolean(currentSession.preset_id) &&
    Boolean(draft.preset_id) &&
    currentSession.preset_id === draft.preset_id &&
    currentSession.tier_name === selectedTier.name &&
    currentSession.variant_title === selectedVariant.title;

  const matchesBySource =
    Boolean(currentSession.source_url) &&
    Boolean(selectedVariant.source_url) &&
    currentSession.source_url === selectedVariant.source_url;

  return matchesByPreset || matchesBySource;
};

export const AdminMusicPanel = () => {
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
  const [selectedLibraryPresetId, setSelectedLibraryPresetId] = useState<
    string | null
  >(draft?.preset_id || library[0]?.preset_id || null);
  const [previewVolume, setPreviewVolume] = useState(DEFAULT_PREVIEW_VOLUME);
  const [previewState, setPreviewState] = useState('Idle');
  const [isPreviewActive, setIsPreviewActive] = useState(false);
  const [launchSettings, setLaunchSettings] = useState<PlaybackSettings>(() =>
    buildLaunchSettings(draft),
  );

  const previewAudioRef = useRef<HTMLAudioElement | null>(null);
  const previewVolumeRef = useRef(DEFAULT_PREVIEW_VOLUME);
  const previewKeyRef = useRef<string>('');
  const initialLibrarySyncRef = useRef(false);

  const clearPreviewAudio = () => {
    const audio = previewAudioRef.current;
    if (audio) {
      audio.pause();
      audio.src = '';
      previewAudioRef.current = null;
    }
  };

  useEffect(() => {
    const syncVolume = async () => {
      const settings = await storage.get('panel-settings');
      const nextVolume =
        typeof settings?.adminMusicVolume === 'number'
          ? settings.adminMusicVolume
          : DEFAULT_PREVIEW_VOLUME;
      previewVolumeRef.current = nextVolume;
      setPreviewVolume(nextVolume);
    };

    let cancelled = false;
    const listener = () => {
      if (!cancelled) {
        void syncVolume();
      }
    };

    void syncVolume();
    document.addEventListener('byondstorageupdated', listener);
    return () => {
      cancelled = true;
      document.removeEventListener('byondstorageupdated', listener);
    };
  }, []);

  useEffect(() => {
    if (previewAudioRef.current) {
      previewAudioRef.current.volume = previewVolume;
    }
  }, [previewVolume]);

  useEffect(() => {
    setLaunchSettings(buildLaunchSettings(draft));
  }, [draft_token]);

  useEffect(() => {
    if (draft?.preset_id) {
      setSelectedLibraryPresetId(draft.preset_id);
      return;
    }
    if (
      selectedLibraryPresetId &&
      !library.some((preset) => preset.preset_id === selectedLibraryPresetId)
    ) {
      setSelectedLibraryPresetId(library[0]?.preset_id || null);
    }
  }, [draft?.preset_id, library, selectedLibraryPresetId]);

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

    const initialPresetId = selectedLibraryPresetId || library[0]?.preset_id;
    if (!initialPresetId) {
      initialLibrarySyncRef.current = true;
      return;
    }

    initialLibrarySyncRef.current = true;
    if (selectedLibraryPresetId !== initialPresetId) {
      setSelectedLibraryPresetId(initialPresetId);
    }
    act('load_preset', { preset_id: initialPresetId });
  }, [act, dirty, draft?.preset_id, library, selectedLibraryPresetId]);

  useEffect(
    () => () => {
      clearPreviewAudio();
    },
    [],
  );

  useEffect(() => {
    if (!preview_command) {
      return;
    }

    const key = `${preview_command.nonce}:${preview_command.command}`;
    if (previewKeyRef.current === key) {
      return;
    }
    previewKeyRef.current = key;

    const stopPreviewAudio = (status = 'Preview stopped') => {
      clearPreviewAudio();
      setIsPreviewActive(false);
      setPreviewState(status);
    };

    if (preview_command.command === 'stop') {
      stopPreviewAudio();
      return;
    }

    if (!preview_command.url) {
      stopPreviewAudio('Preview unavailable');
      return;
    }

    clearPreviewAudio();
    setIsPreviewActive(true);
    setPreviewState('Loading preview...');
    const audio = new Audio(preview_command.url);
    previewAudioRef.current = audio;
    audio.volume = previewVolumeRef.current;

    const start = Math.max(0, preview_command.start || 0);
    const end =
      typeof preview_command.end === 'number' && preview_command.end > start
        ? preview_command.end
        : null;

    const seekToStart = () => {
      if (previewAudioRef.current !== audio || start <= 0) {
        return;
      }
      try {
        const duration = Number.isFinite(audio.duration)
          ? audio.duration
          : null;
        audio.currentTime =
          duration !== null
            ? Math.min(start, Math.max(duration - 0.1, 0))
            : start;
      } catch {
        // Best-effort preview seek.
      }
    };

    const finishPreview = (status: string) => {
      if (previewAudioRef.current === audio) {
        previewAudioRef.current = null;
      }
      audio.pause();
      audio.src = '';
      setIsPreviewActive(false);
      setPreviewState(status);
    };

    audio.addEventListener('loadedmetadata', seekToStart);
    audio.addEventListener('ended', () => finishPreview('Preview ended'));
    audio.addEventListener('error', () => finishPreview('Preview error'));
    if (end !== null) {
      audio.addEventListener('timeupdate', () => {
        if (previewAudioRef.current !== audio || audio.currentTime < end) {
          return;
        }
        finishPreview('Preview ended');
      });
    }

    const startPreview = () => {
      if (previewAudioRef.current !== audio) {
        return;
      }

      audio
        .play()
        .then(() => {
          if (previewAudioRef.current === audio) {
            setIsPreviewActive(true);
            setPreviewState(preview_command.title || 'Preview playing');
          }
        })
        .catch(() => finishPreview('Preview failed'));
    };

    if (start > 0 && audio.readyState < HTMLMediaElement.HAVE_METADATA) {
      const startAfterMetadata = () => {
        audio.removeEventListener('loadedmetadata', startAfterMetadata);
        if (previewAudioRef.current !== audio) {
          return;
        }
        seekToStart();
        startPreview();
      };

      audio.addEventListener('loadedmetadata', startAfterMetadata);
      audio.load();
      return;
    }

    if (start > 0) {
      seekToStart();
    }

    startPreview();
  }, [preview_command]);

  const selectedTier = findTier(draft, selected_tier_id);
  const selectedVariant = findVariant(selectedTier, selected_variant_id);
  const audienceOptions = toSelectOptions(audience_options);
  const soundTypeOptions = toSelectOptions(sound_type_options);
  const hasSelection = Boolean(selectedTier && selectedVariant);
  const selectedTrackIsLive = isCurrentSessionForSelection(
    current_session,
    draft,
    selectedTier,
    selectedVariant,
  );

  const handleImport = (jsonText: string | string[]) => {
    const payload = Array.isArray(jsonText) ? jsonText[0] : jsonText;
    if (payload) {
      act('import_json', { json_text: payload });
    }
  };

  const stopPreviewNow = () => {
    clearPreviewAudio();
    previewKeyRef.current = '';
    setIsPreviewActive(false);
    setPreviewState('Preview stopped');
    act('stop_preview');
  };

  const handleNewDraft = () => {
    setSelectedLibraryPresetId(null);
    act('new_draft');
  };

  const handleLoadPreset = () => {
    if (selectedLibraryPresetId) {
      act('load_preset', { preset_id: selectedLibraryPresetId });
    }
  };

  return (
    <Window
      title="Admin Music Panel"
      width={1260}
      height={840}
      theme="admin"
      canClose={false}
      buttons={
        <Button
          icon="times"
          color="bad"
          tooltip="Request close"
          onClick={() => act('request_close')}
        >
          Close
        </Button>
      }
    >
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <SessionSection
              current_session={current_session}
              draft={draft}
              selectedTier={selectedTier}
              selectedVariant={selectedVariant}
              launchSettings={launchSettings}
              audienceLabel={getOptionLabel(
                audience_options,
                launchSettings.audience_mode,
              )}
              soundTypeLabel={getOptionLabel(
                sound_type_options,
                launchSettings.sound_type,
              )}
              hasSelection={hasSelection}
              selectedTrackIsLive={selectedTrackIsLive}
              onPlaySelected={() => act('play_selected', launchSettings)}
              onStopBroadcast={() => act('stop_broadcast')}
            />
          </Stack.Item>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="play"
                selected={activeTab === 'play'}
                onClick={() => setActiveTab('play')}
              >
                Play
              </Tabs.Tab>
              <Tabs.Tab
                icon="edit"
                selected={activeTab === 'edit'}
                onClick={() => setActiveTab('edit')}
              >
                Edit
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow={1}>
            {activeTab === 'play' ? (
              <PlayTab
                library={library}
                librarySearch={librarySearch}
                selectedLibraryPresetId={selectedLibraryPresetId}
                onSearchChange={setLibrarySearch}
                onSelectPreset={setSelectedLibraryPresetId}
                onLoadPreset={handleLoadPreset}
                onOpenEdit={() => setActiveTab('edit')}
                draft={draft}
                dirty={dirty}
                selectedTier={selectedTier}
                selectedTierId={selected_tier_id}
                selectedVariant={selectedVariant}
                selectedVariantId={selected_variant_id}
                onSelectTier={(tier_id) => act('select_tier', { tier_id })}
                onSelectVariant={(tier_id, variant_id) =>
                  act('select_variant', { tier_id, variant_id })
                }
                launchSettings={launchSettings}
                audienceOptions={audienceOptions}
                soundTypeOptions={soundTypeOptions}
                audienceLabel={getOptionLabel(
                  audience_options,
                  launchSettings.audience_mode,
                )}
                soundTypeLabel={getOptionLabel(
                  sound_type_options,
                  launchSettings.sound_type,
                )}
                onSetAudienceMode={(value) =>
                  setLaunchSettings((current) => ({
                    ...current,
                    audience_mode: value,
                  }))
                }
                onSetSoundType={(value) =>
                  setLaunchSettings((current) => ({
                    ...current,
                    sound_type: value,
                  }))
                }
                onToggleShowTitle={() =>
                  setLaunchSettings((current) => ({
                    ...current,
                    show_title_to_players: !current.show_title_to_players,
                  }))
                }
                onToggleRepeat={() =>
                  setLaunchSettings((current) => ({
                    ...current,
                    repeat: !current.repeat,
                  }))
                }
                onResetLaunchSettings={() =>
                  setLaunchSettings(buildLaunchSettings(draft))
                }
                onPreviewSelected={() => act('preview_selected')}
                onStopPreview={stopPreviewNow}
                isPreviewActive={isPreviewActive}
                previewState={previewState}
                previewVolume={previewVolume}
                hasSelection={hasSelection}
              />
            ) : (
              <EditTab
                draft={draft}
                dirty={dirty}
                canDelete={can_delete_saved_preset}
                audienceOptions={audienceOptions}
                soundTypeOptions={soundTypeOptions}
                audienceLabel={getOptionLabel(
                  audience_options,
                  draft.playback.audience_mode,
                )}
                soundTypeLabel={getOptionLabel(
                  sound_type_options,
                  draft.playback.sound_type,
                )}
                selectedTier={selectedTier}
                selectedTierId={selected_tier_id}
                selectedVariant={selectedVariant}
                selectedVariantId={selected_variant_id}
                onSave={() => act('save')}
                onNew={handleNewDraft}
                onSaveAsCopy={() => act('save_as_copy')}
                onDelete={() =>
                  act('delete_preset', { preset_id: draft.preset_id })
                }
                onExport={() => act('export_preset')}
                onImport={handleImport}
                onSetName={(value) => act('set_name', { name: value })}
                onSetDescription={(value) =>
                  act('set_description', { description: value })
                }
                onSetAudienceMode={(value) =>
                  act('set_audience_mode', { audience_mode: value })
                }
                onSetSoundType={(value) =>
                  act('set_sound_type', { sound_type: value })
                }
                onToggleShowTitle={() =>
                  act('set_show_title', {
                    show_title_to_players:
                      !draft.playback.show_title_to_players,
                  })
                }
                onToggleRepeat={() =>
                  act('set_repeat', {
                    repeat: !draft.playback.repeat,
                  })
                }
                onAddTier={() => act('add_tier')}
                onSelectTier={(tier_id) => act('select_tier', { tier_id })}
                onRemoveTier={(tier_id) => act('remove_tier', { tier_id })}
                onSetTierName={(tier_id, value) =>
                  act('set_tier_name', { tier_id, name: value })
                }
                onSetTierDescription={(tier_id, value) =>
                  act('set_tier_description', {
                    tier_id,
                    description: value,
                  })
                }
                onAddVariant={() => act('add_variant')}
                onSelectVariant={(tier_id, variant_id) =>
                  act('select_variant', { tier_id, variant_id })
                }
                onRemoveVariant={(tier_id, variant_id) =>
                  act('remove_variant', { tier_id, variant_id })
                }
                onSetVariantTitle={(tier_id, variant_id, value) =>
                  act('set_variant_title', {
                    tier_id,
                    variant_id,
                    title: value,
                  })
                }
                onSetVariantDescription={(tier_id, variant_id, value) =>
                  act('set_variant_description', {
                    tier_id,
                    variant_id,
                    description: value,
                  })
                }
                onSetVariantDuration={(tier_id, variant_id, value) =>
                  act('set_variant_duration', {
                    tier_id,
                    variant_id,
                    duration_seconds: value,
                  })
                }
                onSetVariantSourceUrl={(tier_id, variant_id, value) =>
                  act('set_variant_source_url', {
                    tier_id,
                    variant_id,
                    source_url: value,
                  })
                }
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type SessionSectionProps = Readonly<{
  current_session: CurrentSession;
  draft: DraftPreset;
  selectedTier: DraftTier | null;
  selectedVariant: DraftVariant | null;
  launchSettings: PlaybackSettings;
  audienceLabel: string;
  soundTypeLabel: string;
  hasSelection: boolean;
  selectedTrackIsLive: boolean;
  onPlaySelected: () => void;
  onStopBroadcast: () => void;
}>;

function SessionSection({
  current_session,
  draft,
  selectedTier,
  selectedVariant,
  launchSettings,
  audienceLabel,
  soundTypeLabel,
  hasSelection,
  selectedTrackIsLive,
  onPlaySelected,
  onStopBroadcast,
}: SessionSectionProps) {
  const broadcastTitle =
    current_session?.variant_title ||
    current_session?.resolved_title ||
    'Untitled broadcast';
  const broadcastPath =
    current_session?.preset_name &&
    [current_session.preset_name, current_session.tier_name]
      .filter(Boolean)
      .join(' / ');
  const selectedTitle = selectedVariant?.title || 'No track selected';
  const selectedMeta = [
    `Playlist: ${draft.name || 'New playlist'}`,
    `Scene: ${selectedTier?.name || 'None'}`,
    `Length: ${
      selectedVariant
        ? formatDuration(selectedVariant.duration_seconds)
        : 'Unknown'
    }`,
    `Source: ${
      selectedVariant ? formatSourceLabel(selectedVariant.source_url) : 'None'
    }`,
  ].join(' | ');
  const selectedPlaybackMeta = formatPlaybackFlags(
    launchSettings,
    audienceLabel,
    soundTypeLabel,
  );

  return (
    <Section
      title="Live Broadcast"
      buttons={
        <Button
          icon="stop"
          color="bad"
          disabled={!current_session}
          style={!current_session ? DISABLED_ACTION_STYLE : undefined}
          onClick={onStopBroadcast}
        >
          Stop Broadcast
        </Button>
      }
    >
      <Box style={PLAYER_STRIP_STYLE}>
        <Stack fill>
          <Stack.Item basis="62%" grow={2}>
            {!current_session ? (
              <Box>
                <Box color="label" fontSize="0.8rem">
                  Broadcast idle
                </Box>
                <Box color="label">
                  Use Play to choose a track and send it live.
                </Box>
              </Box>
            ) : (
              <Box>
                <Flex align="center" justify="space-between" width="100%">
                  <Flex.Item grow>
                    <Box color="label" fontSize="0.8rem">
                      On air
                    </Box>
                    <Box bold fontSize="1.25rem" style={ELLIPSIS_STYLE}>
                      {broadcastTitle}
                    </Box>
                    <Box color="label" style={ELLIPSIS_STYLE}>
                      {broadcastPath || 'Legacy broadcast session'}
                    </Box>
                  </Flex.Item>
                  <Flex.Item ml={1} textAlign="right">
                    <Box style={PLAYER_BADGE_STYLE}>
                      Audience {current_session.audience_label}
                    </Box>
                    <Box style={PLAYER_BADGE_STYLE}>
                      Mode {current_session.sound_type_label}
                    </Box>
                    <Box style={PLAYER_BADGE_STYLE}>
                      Repeat {current_session.loop ? 'On' : 'Off'}
                    </Box>
                  </Flex.Item>
                </Flex>
                <Box mt="0.45rem">
                  <Box style={PLAYER_BADGE_STYLE}>
                    Owner {current_session.owner}
                  </Box>
                  <Box style={PLAYER_BADGE_STYLE}>
                    Source {current_session.source_kind}
                  </Box>
                  <Box style={PLAYER_BADGE_STYLE}>
                    Show Title{' '}
                    {current_session.show_title_to_players ? 'Yes' : 'No'}
                  </Box>
                  <Box style={PLAYER_BADGE_STYLE}>
                    Link {formatSourceLabel(current_session.source_url)}
                  </Box>
                </Box>
              </Box>
            )}
          </Stack.Item>
          <Stack.Item basis="38%" grow={1}>
            <Box
              style={{
                ...COMPACT_CARD_STYLE,
                backgroundColor: 'rgba(0, 0, 0, 0.12)',
                borderColor: 'rgba(255, 255, 255, 0.08)',
              }}
            >
              <Box color="label" fontSize="0.75rem">
                Selected for Broadcast
              </Box>
              <Flex align="center" justify="space-between" width="100%">
                <Flex.Item grow>
                  <Box bold fontSize="1.05rem" style={ELLIPSIS_STYLE}>
                    {selectedTitle}
                  </Box>
                </Flex.Item>
                {selectedTrackIsLive ? (
                  <Flex.Item ml={1}>
                    <Box style={LIVE_BADGE_STYLE}>On air</Box>
                  </Flex.Item>
                ) : null}
              </Flex>
              <Box color="label" fontSize="0.75rem" style={ELLIPSIS_STYLE}>
                {selectedMeta}
              </Box>
              <Box
                color="label"
                fontSize="0.75rem"
                mt="0.25rem"
                style={ELLIPSIS_STYLE}
              >
                {selectedPlaybackMeta}
              </Box>
              <Box mt="0.45rem">
                {selectedTrackIsLive ? (
                  <Button
                    fluid
                    color="bad"
                    icon="stop"
                    onClick={onStopBroadcast}
                  >
                    Stop Broadcast
                  </Button>
                ) : (
                  <Button
                    fluid
                    color="good"
                    icon="play"
                    disabled={!hasSelection}
                    onClick={onPlaySelected}
                  >
                    Broadcast
                  </Button>
                )}
              </Box>
            </Box>
          </Stack.Item>
        </Stack>
      </Box>
    </Section>
  );
}

type PlayTabProps = Readonly<{
  library: LibraryPreset[];
  librarySearch: string;
  selectedLibraryPresetId: string | null;
  onSearchChange: (value: string) => void;
  onSelectPreset: (preset_id: string) => void;
  onLoadPreset: () => void;
  onOpenEdit: () => void;
  draft: DraftPreset;
  dirty: boolean;
  selectedTier: DraftTier | null;
  selectedTierId: string | null;
  selectedVariant: DraftVariant | null;
  selectedVariantId: string | null;
  onSelectTier: (tier_id: string) => void;
  onSelectVariant: (tier_id: string, variant_id: string) => void;
  launchSettings: PlaybackSettings;
  audienceOptions: SelectOption[];
  soundTypeOptions: SelectOption[];
  audienceLabel: string;
  soundTypeLabel: string;
  onSetAudienceMode: (value: string) => void;
  onSetSoundType: (value: string) => void;
  onToggleShowTitle: () => void;
  onToggleRepeat: () => void;
  onResetLaunchSettings: () => void;
  onPreviewSelected: () => void;
  onStopPreview: () => void;
  isPreviewActive: boolean;
  previewState: string;
  previewVolume: number;
  hasSelection: boolean;
}>;

function PlayTab({
  library,
  librarySearch,
  selectedLibraryPresetId,
  onSearchChange,
  onSelectPreset,
  onLoadPreset,
  onOpenEdit,
  draft,
  dirty,
  selectedTier,
  selectedTierId,
  selectedVariant,
  selectedVariantId,
  onSelectTier,
  onSelectVariant,
  launchSettings,
  audienceOptions,
  soundTypeOptions,
  audienceLabel,
  soundTypeLabel,
  onSetAudienceMode,
  onSetSoundType,
  onToggleShowTitle,
  onToggleRepeat,
  onResetLaunchSettings,
  onPreviewSelected,
  onStopPreview,
  isPreviewActive,
  previewState,
  previewVolume,
  hasSelection,
}: PlayTabProps) {
  return (
    <Stack fill>
      <Stack.Item basis="29%" grow={1}>
        <LibrarySection
          library={library}
          librarySearch={librarySearch}
          selectedLibraryPresetId={selectedLibraryPresetId}
          onSearchChange={onSearchChange}
          onSelectPreset={onSelectPreset}
          onLoadPreset={onLoadPreset}
          onOpenEdit={onOpenEdit}
          draft={draft}
          dirty={dirty}
        />
      </Stack.Item>
      <Stack.Item basis="18%" grow={1}>
        <PlayScenesSection
          draft={draft}
          selectedTierId={selectedTierId}
          onSelectTier={onSelectTier}
        />
      </Stack.Item>
      <Stack.Item basis="53%" grow={2}>
        <Stack fill vertical>
          <Stack.Item grow={1}>
            <PlayTracksSection
              selectedTier={selectedTier}
              selectedVariantId={selectedVariantId}
              onSelectVariant={onSelectVariant}
            />
          </Stack.Item>
          <Stack.Item>
            <PlaybackSection
              selectedTier={selectedTier}
              selectedVariant={selectedVariant}
              launchSettings={launchSettings}
              audienceOptions={audienceOptions}
              soundTypeOptions={soundTypeOptions}
              audienceLabel={audienceLabel}
              soundTypeLabel={soundTypeLabel}
              onSetAudienceMode={onSetAudienceMode}
              onSetSoundType={onSetSoundType}
              onToggleShowTitle={onToggleShowTitle}
              onToggleRepeat={onToggleRepeat}
              onResetLaunchSettings={onResetLaunchSettings}
              onPreviewSelected={onPreviewSelected}
              onStopPreview={onStopPreview}
              isPreviewActive={isPreviewActive}
              previewState={previewState}
              previewVolume={previewVolume}
              hasSelection={hasSelection}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
}

type EditTabProps = Readonly<{
  draft: DraftPreset;
  dirty: boolean;
  canDelete: boolean;
  audienceOptions: SelectOption[];
  soundTypeOptions: SelectOption[];
  audienceLabel: string;
  soundTypeLabel: string;
  selectedTier: DraftTier | null;
  selectedTierId: string | null;
  selectedVariant: DraftVariant | null;
  selectedVariantId: string | null;
  onSave: () => void;
  onNew: () => void;
  onSaveAsCopy: () => void;
  onDelete: () => void;
  onExport: () => void;
  onImport: (jsonText: string | string[]) => void;
  onSetName: (value: string) => void;
  onSetDescription: (value: string) => void;
  onSetAudienceMode: (value: string) => void;
  onSetSoundType: (value: string) => void;
  onToggleShowTitle: () => void;
  onToggleRepeat: () => void;
  onAddTier: () => void;
  onSelectTier: (tier_id: string) => void;
  onRemoveTier: (tier_id: string) => void;
  onSetTierName: (tier_id: string, value: string) => void;
  onSetTierDescription: (tier_id: string, value: string) => void;
  onAddVariant: () => void;
  onSelectVariant: (tier_id: string, variant_id: string) => void;
  onRemoveVariant: (tier_id: string, variant_id: string) => void;
  onSetVariantTitle: (
    tier_id: string,
    variant_id: string,
    value: string,
  ) => void;
  onSetVariantDescription: (
    tier_id: string,
    variant_id: string,
    value: string,
  ) => void;
  onSetVariantDuration: (
    tier_id: string,
    variant_id: string,
    value: number,
  ) => void;
  onSetVariantSourceUrl: (
    tier_id: string,
    variant_id: string,
    value: string,
  ) => void;
}>;

function EditTab({
  draft,
  dirty,
  canDelete,
  audienceOptions,
  soundTypeOptions,
  audienceLabel,
  soundTypeLabel,
  selectedTier,
  selectedTierId,
  selectedVariant,
  selectedVariantId,
  onSave,
  onNew,
  onSaveAsCopy,
  onDelete,
  onExport,
  onImport,
  onSetName,
  onSetDescription,
  onSetAudienceMode,
  onSetSoundType,
  onToggleShowTitle,
  onToggleRepeat,
  onAddTier,
  onSelectTier,
  onRemoveTier,
  onSetTierName,
  onSetTierDescription,
  onAddVariant,
  onSelectVariant,
  onRemoveVariant,
  onSetVariantTitle,
  onSetVariantDescription,
  onSetVariantDuration,
  onSetVariantSourceUrl,
}: EditTabProps) {
  return (
    <Stack fill>
      <Stack.Item basis="30%" grow={1}>
        <Stack fill vertical>
          <Stack.Item>
            <PlaylistEditorSection
              draft={draft}
              dirty={dirty}
              onSave={onSave}
              onSetName={onSetName}
              onSetDescription={onSetDescription}
            />
          </Stack.Item>
          <Stack.Item>
            <PresetDefaultsSection
              playback={draft.playback}
              audienceOptions={audienceOptions}
              soundTypeOptions={soundTypeOptions}
              audienceLabel={audienceLabel}
              soundTypeLabel={soundTypeLabel}
              onSetAudienceMode={onSetAudienceMode}
              onSetSoundType={onSetSoundType}
              onToggleShowTitle={onToggleShowTitle}
              onToggleRepeat={onToggleRepeat}
            />
          </Stack.Item>
          <Stack.Item>
            <AdvancedSection
              canDelete={canDelete}
              onNew={onNew}
              onSaveAsCopy={onSaveAsCopy}
              onDelete={onDelete}
              onExport={onExport}
              onImport={onImport}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item basis="28%" grow={1}>
        <SceneEditorSection
          draft={draft}
          selectedTier={selectedTier}
          selectedTierId={selectedTierId}
          onAddTier={onAddTier}
          onSelectTier={onSelectTier}
          onRemoveTier={onRemoveTier}
          onSetTierName={onSetTierName}
          onSetTierDescription={onSetTierDescription}
        />
      </Stack.Item>
      <Stack.Item basis="42%" grow={1}>
        <TrackEditorSection
          selectedTier={selectedTier}
          selectedVariant={selectedVariant}
          selectedVariantId={selectedVariantId}
          onAddVariant={onAddVariant}
          onSelectVariant={onSelectVariant}
          onRemoveVariant={onRemoveVariant}
          onSetVariantTitle={onSetVariantTitle}
          onSetVariantDescription={onSetVariantDescription}
          onSetVariantDuration={onSetVariantDuration}
          onSetVariantSourceUrl={onSetVariantSourceUrl}
        />
      </Stack.Item>
    </Stack>
  );
}

type LibrarySectionProps = Readonly<{
  library: LibraryPreset[];
  librarySearch: string;
  selectedLibraryPresetId: string | null;
  onSearchChange: (value: string) => void;
  onSelectPreset: (preset_id: string) => void;
  onLoadPreset: () => void;
  onOpenEdit: () => void;
  draft: DraftPreset;
  dirty: boolean;
}>;

function LibrarySection({
  library,
  librarySearch,
  selectedLibraryPresetId,
  onSearchChange,
  onSelectPreset,
  onLoadPreset,
  onOpenEdit,
  draft,
  dirty,
}: LibrarySectionProps) {
  const filteredLibrary = library.filter((preset) => {
    const haystack =
      `${preset.name} ${preset.description} ${preset.preset_id}`.toLowerCase();
    return haystack.includes(librarySearch.toLowerCase());
  });
  const hasSavedPlaylists = library.length > 0;
  const hasVisibleSelection = filteredLibrary.some(
    (preset) => preset.preset_id === selectedLibraryPresetId,
  );
  const isSyncedToSelectedPreset =
    Boolean(selectedLibraryPresetId) &&
    Boolean(draft.preset_id) &&
    selectedLibraryPresetId === draft.preset_id &&
    !dirty;
  const currentDraftStatus =
    !draft.preset_id || dirty ? 'Unsaved draft' : 'Saved playlist';

  return (
    <Section
      fill
      title="Library"
      buttons={
        hasSavedPlaylists ? (
          <Button
            icon="file"
            disabled={
              !selectedLibraryPresetId ||
              !hasVisibleSelection ||
              isSyncedToSelectedPreset
            }
            style={
              !selectedLibraryPresetId ||
              !hasVisibleSelection ||
              isSyncedToSelectedPreset
                ? DISABLED_ACTION_STYLE
                : undefined
            }
            onClick={onLoadPreset}
          >
            Sync
          </Button>
        ) : null
      }
    >
      <Stack fill vertical>
        <Stack.Item>
          <Box style={SUBTLE_PANEL_STYLE}>
            <Flex align="center" justify="space-between" width="100%">
              <Flex.Item grow>
                <Box color="label" fontSize="0.75rem">
                  Current
                </Box>
                <Box bold style={ELLIPSIS_STYLE}>
                  {draft.name || 'New playlist'}
                </Box>
              </Flex.Item>
              <Flex.Item ml={1}>
                <Box
                  style={
                    currentDraftStatus === 'Unsaved draft'
                      ? UNSAVED_BADGE_STYLE
                      : MUTED_BADGE_STYLE
                  }
                >
                  {currentDraftStatus}
                </Box>
              </Flex.Item>
            </Flex>
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Input
            fluid
            placeholder="Search playlists..."
            value={librarySearch}
            onInput={(e, value) => onSearchChange(value)}
          />
        </Stack.Item>
        <Stack.Item grow={1}>
          <Section fill scrollable title="Saved Playlists">
            {filteredLibrary.length === 0 ? (
              hasSavedPlaylists ? (
                <Box color="label">No playlists match search.</Box>
              ) : (
                <Stack vertical>
                  <Stack.Item>
                    <Box color="label">
                      No saved playlists yet. You are working in an unsaved
                      draft.
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Button icon="edit" onClick={onOpenEdit}>
                      Open Edit
                    </Button>
                  </Stack.Item>
                </Stack>
              )
            ) : (
              filteredLibrary.map((preset) => (
                <Button
                  key={preset.preset_id}
                  compact
                  fluid
                  color="transparent"
                  onClick={() => onSelectPreset(preset.preset_id)}
                  style={getListRowStyle(
                    selectedLibraryPresetId === preset.preset_id,
                  )}
                >
                  <Box>
                    <Flex align="center" justify="space-between" width="100%">
                      <Flex.Item grow>
                        <Box bold style={ELLIPSIS_STYLE}>
                          {preset.name || 'Unnamed playlist'}
                        </Box>
                      </Flex.Item>
                      <Flex.Item ml={1}>
                        <Box fontSize="0.75rem" color="label">
                          {preset.tier_count} scenes | {preset.variant_count}{' '}
                          tracks
                        </Box>
                      </Flex.Item>
                    </Flex>
                    <Box
                      fontSize="0.75rem"
                      color="label"
                      style={ELLIPSIS_STYLE}
                    >
                      {preset.description || `ID ${preset.preset_id}`}
                    </Box>
                  </Box>
                </Button>
              ))
            )}
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

type PlaybackSettingsControlsProps = Readonly<{
  playback: PlaybackSettings;
  audienceOptions: SelectOption[];
  soundTypeOptions: SelectOption[];
  audienceLabel: string;
  soundTypeLabel: string;
  onSetAudienceMode: (value: string) => void;
  onSetSoundType: (value: string) => void;
  onToggleShowTitle: () => void;
  onToggleRepeat: () => void;
}>;

function PlaybackSettingsControls({
  playback,
  audienceOptions,
  soundTypeOptions,
  audienceLabel,
  soundTypeLabel,
  onSetAudienceMode,
  onSetSoundType,
  onToggleShowTitle,
  onToggleRepeat,
}: PlaybackSettingsControlsProps) {
  return (
    <Stack vertical>
      <Stack.Item>
        <Stack fill>
          <Stack.Item basis="50%" grow={1}>
            <Box style={LABEL_STYLE}>Audience</Box>
            <Dropdown
              width="100%"
              options={audienceOptions}
              selected={playback.audience_mode}
              displayText={audienceLabel}
              onSelected={(value) => onSetAudienceMode(value)}
            />
          </Stack.Item>
          <Stack.Item basis="50%" grow={1}>
            <Box style={LABEL_STYLE}>Sound Type</Box>
            <Dropdown
              width="100%"
              options={soundTypeOptions}
              selected={playback.sound_type}
              displayText={soundTypeLabel}
              onSelected={(value) => onSetSoundType(value)}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item grow>
            <Button
              compact
              fluid
              color="transparent"
              icon={
                playback.show_title_to_players ? 'check-square-o' : 'square-o'
              }
              style={getToggleButtonStyle(playback.show_title_to_players)}
              onClick={onToggleShowTitle}
            >
              Visible to players
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              compact
              fluid
              color="transparent"
              icon={playback.repeat ? 'check-square-o' : 'square-o'}
              style={getToggleButtonStyle(playback.repeat)}
              onClick={onToggleRepeat}
            >
              Repeat until stopped
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
}

type PlayScenesSectionProps = Readonly<{
  draft: DraftPreset;
  selectedTierId: string | null;
  onSelectTier: (tier_id: string) => void;
}>;

function PlayScenesSection({
  draft,
  selectedTierId,
  onSelectTier,
}: PlayScenesSectionProps) {
  return (
    <Section fill scrollable title="Scenes">
      {draft.tiers.length === 0 ? (
        <Box color="label">No scenes loaded.</Box>
      ) : (
        draft.tiers.map((tier) => (
          <Button
            key={tier.tier_id}
            compact
            fluid
            color="transparent"
            onClick={() => onSelectTier(tier.tier_id)}
            style={getListRowStyle(selectedTierId === tier.tier_id)}
          >
            <Flex align="center" justify="space-between" width="100%">
              <Flex.Item grow>
                <Box bold style={ELLIPSIS_STYLE}>
                  {tier.name || 'Unnamed scene'}
                </Box>
              </Flex.Item>
              <Flex.Item ml={1}>
                <Box fontSize="0.75rem" color="label">
                  {formatTrackCount(tier.variants.length)}
                </Box>
              </Flex.Item>
            </Flex>
          </Button>
        ))
      )}
    </Section>
  );
}

type PlayTracksSectionProps = Readonly<{
  selectedTier: DraftTier | null;
  selectedVariantId: string | null;
  onSelectVariant: (tier_id: string, variant_id: string) => void;
}>;

function PlayTracksSection({
  selectedTier,
  selectedVariantId,
  onSelectVariant,
}: PlayTracksSectionProps) {
  return (
    <Section fill title="Tracks">
      {!selectedTier ? (
        <Box color="label">Select a scene to browse its tracks.</Box>
      ) : (
        <Stack fill vertical>
          <Stack.Item>
            <Box style={STATUS_STRIP_STYLE}>
              <Box bold style={ELLIPSIS_STYLE}>
                {selectedTier.name || 'Unnamed scene'}
              </Box>
              <Box color="label" fontSize="0.75rem">
                {formatTrackCount(selectedTier.variants.length)}
              </Box>
            </Box>
          </Stack.Item>
          <Stack.Item grow>
            <Box style={LIST_SCROLL_STYLE}>
              {selectedTier.variants.length === 0 ? (
                <Box color="label">No tracks in this scene.</Box>
              ) : (
                selectedTier.variants.map((variant) => (
                  <Button
                    key={variant.variant_id}
                    compact
                    fluid
                    color="transparent"
                    onClick={() =>
                      onSelectVariant(selectedTier.tier_id, variant.variant_id)
                    }
                    style={getListRowStyle(
                      selectedVariantId === variant.variant_id,
                    )}
                  >
                    <Flex align="center" justify="space-between" width="100%">
                      <Flex.Item grow>
                        <Box bold style={ELLIPSIS_STYLE}>
                          {variant.title || 'Unnamed track'}
                        </Box>
                      </Flex.Item>
                      <Flex.Item ml={1}>
                        <Box fontSize="0.75rem" color="label">
                          {formatDuration(variant.duration_seconds)}
                        </Box>
                      </Flex.Item>
                    </Flex>
                  </Button>
                ))
              )}
            </Box>
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
}

type PlaybackSectionProps = Readonly<{
  selectedTier: DraftTier | null;
  selectedVariant: DraftVariant | null;
  launchSettings: PlaybackSettings;
  audienceOptions: SelectOption[];
  soundTypeOptions: SelectOption[];
  audienceLabel: string;
  soundTypeLabel: string;
  onSetAudienceMode: (value: string) => void;
  onSetSoundType: (value: string) => void;
  onToggleShowTitle: () => void;
  onToggleRepeat: () => void;
  onResetLaunchSettings: () => void;
  onPreviewSelected: () => void;
  onStopPreview: () => void;
  isPreviewActive: boolean;
  previewState: string;
  previewVolume: number;
  hasSelection: boolean;
}>;

function PlaybackSection({
  selectedTier,
  selectedVariant,
  launchSettings,
  audienceOptions,
  soundTypeOptions,
  audienceLabel,
  soundTypeLabel,
  onSetAudienceMode,
  onSetSoundType,
  onToggleShowTitle,
  onToggleRepeat,
  onResetLaunchSettings,
  onPreviewSelected,
  onStopPreview,
  isPreviewActive,
  previewState,
  previewVolume,
  hasSelection,
}: PlaybackSectionProps) {
  const selectionTitle = selectedVariant?.title || 'No track selected';
  const selectionMeta = [
    `Scene: ${selectedTier?.name || 'None'}`,
    `Length: ${
      selectedVariant
        ? formatDuration(selectedVariant.duration_seconds)
        : 'Unknown'
    }`,
    `Source: ${
      selectedVariant ? formatSourceLabel(selectedVariant.source_url) : 'None'
    }`,
  ].join(' | ');
  const previewLabel = isPreviewActive
    ? `${previewState} | Local preview only`
    : 'Local preview only';

  return (
    <Section title="Preview">
      <Box
        style={{
          ...PLAYER_CARD_STYLE,
          padding: '0.65rem 0.75rem',
        }}
      >
        <Stack vertical>
          {hasSelection ? (
            <Stack.Item>
              <Box style={SUBTLE_PANEL_STYLE}>
                <Box color="label" fontSize="0.75rem">
                  Selected Track
                </Box>
                <Box bold style={ELLIPSIS_STYLE}>
                  {selectionTitle}
                </Box>
                <Box color="label" fontSize="0.75rem" style={ELLIPSIS_STYLE}>
                  {selectionMeta}
                </Box>
              </Box>
            </Stack.Item>
          ) : null}
          <Stack.Item>
            {isPreviewActive ? (
              <Button fluid color="default" icon="stop" onClick={onStopPreview}>
                Stop Preview
              </Button>
            ) : (
              <Button
                fluid
                color="transparent"
                icon="eye"
                disabled={!hasSelection}
                onClick={onPreviewSelected}
              >
                Preview
              </Button>
            )}
          </Stack.Item>
          <Stack.Item>
            <Box
              style={{
                ...SUBTLE_PANEL_STYLE,
                borderColor: 'rgba(255, 255, 255, 0.04)',
                padding: '0.45rem 0.55rem',
              }}
            >
              <Flex align="center" justify="space-between" width="100%">
                <Flex.Item grow>
                  <Box bold>Launch Settings</Box>
                </Flex.Item>
                <Flex.Item ml={1}>
                  <Button
                    compact
                    color="transparent"
                    icon="undo"
                    style={{ opacity: '0.72' }}
                    onClick={onResetLaunchSettings}
                  >
                    Reset
                  </Button>
                </Flex.Item>
              </Flex>
              <Box color="label" fontSize="0.72rem" mt={0.15} mb={0.35}>
                Temporary for this panel only. These settings do not mark the
                playlist as modified.
              </Box>
              <PlaybackSettingsControls
                playback={launchSettings}
                audienceOptions={audienceOptions}
                soundTypeOptions={soundTypeOptions}
                audienceLabel={audienceLabel}
                soundTypeLabel={soundTypeLabel}
                onSetAudienceMode={onSetAudienceMode}
                onSetSoundType={onSetSoundType}
                onToggleShowTitle={onToggleShowTitle}
                onToggleRepeat={onToggleRepeat}
              />
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Box
              pt="0.15rem"
              style={{ borderTop: '1px solid rgba(255, 255, 255, 0.06)' }}
            >
              <Flex align="center" justify="space-between" width="100%">
                <Flex.Item grow>
                  <Box bold fontSize="0.85rem" style={ELLIPSIS_STYLE}>
                    {isPreviewActive ? 'Preview active' : 'Preview idle'}
                  </Box>
                  <Box color="label" fontSize="0.75rem" style={ELLIPSIS_STYLE}>
                    {previewLabel}
                  </Box>
                </Flex.Item>
                <Flex.Item ml={1}>
                  <Box color="label" fontSize="0.75rem">
                    Volume {Math.round(previewVolume * 100)}%
                  </Box>
                </Flex.Item>
              </Flex>
            </Box>
          </Stack.Item>
        </Stack>
      </Box>
    </Section>
  );
}

type PlaylistEditorSectionProps = Readonly<{
  draft: DraftPreset;
  dirty: boolean;
  onSave: () => void;
  onSetName: (value: string) => void;
  onSetDescription: (value: string) => void;
}>;

function PlaylistEditorSection({
  draft,
  dirty,
  onSave,
  onSetName,
  onSetDescription,
}: PlaylistEditorSectionProps) {
  return (
    <Section
      title="Playlist"
      buttons={
        <Flex align="center">
          {dirty ? (
            <Box mr={1} style={UNSAVED_BADGE_STYLE}>
              Unsaved changes
            </Box>
          ) : (
            <Box mr={1} style={MUTED_BADGE_STYLE}>
              Saved
            </Box>
          )}
          <Button icon="save" color="good" onClick={onSave}>
            Save
          </Button>
        </Flex>
      }
    >
      <Stack vertical>
        <Stack.Item>
          <Box style={COMPACT_CARD_STYLE}>
            <Box bold fontSize="1rem" style={ELLIPSIS_STYLE}>
              {draft.name || 'New playlist'}
            </Box>
            <Box mt="0.3rem">
              <Box style={PLAYER_BADGE_STYLE}>
                ID {draft.preset_id || 'new'}
              </Box>
              <Box style={PLAYER_BADGE_STYLE}>Scenes {draft.tiers.length}</Box>
              <Box style={PLAYER_BADGE_STYLE}>Tracks {countTracks(draft)}</Box>
            </Box>
          </Box>
        </Stack.Item>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Name">
              <Input
                fluid
                value={draft.name}
                onInput={(e, value) => onSetName(value)}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Description" verticalAlign="top">
              <TextArea
                fluid
                height={DESCRIPTION_FIELD_HEIGHT}
                value={draft.description}
                onInput={(e, value) => onSetDescription(value)}
                placeholder="Short description for admins"
                scrollbar
              />
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

type PresetDefaultsSectionProps = Readonly<{
  playback: PlaybackSettings;
  audienceOptions: SelectOption[];
  soundTypeOptions: SelectOption[];
  audienceLabel: string;
  soundTypeLabel: string;
  onSetAudienceMode: (value: string) => void;
  onSetSoundType: (value: string) => void;
  onToggleShowTitle: () => void;
  onToggleRepeat: () => void;
}>;

function PresetDefaultsSection({
  playback,
  audienceOptions,
  soundTypeOptions,
  audienceLabel,
  soundTypeLabel,
  onSetAudienceMode,
  onSetSoundType,
  onToggleShowTitle,
  onToggleRepeat,
}: PresetDefaultsSectionProps) {
  return (
    <Section title="Preset Defaults">
      <Box color="label" fontSize="0.8rem" mb={0.5}>
        Saved with the playlist and used as the starting point for Play.
      </Box>
      <PlaybackSettingsControls
        playback={playback}
        audienceOptions={audienceOptions}
        soundTypeOptions={soundTypeOptions}
        audienceLabel={audienceLabel}
        soundTypeLabel={soundTypeLabel}
        onSetAudienceMode={onSetAudienceMode}
        onSetSoundType={onSetSoundType}
        onToggleShowTitle={onToggleShowTitle}
        onToggleRepeat={onToggleRepeat}
      />
    </Section>
  );
}

type AdvancedSectionProps = Readonly<{
  canDelete: boolean;
  onNew: () => void;
  onSaveAsCopy: () => void;
  onDelete: () => void;
  onExport: () => void;
  onImport: (jsonText: string | string[]) => void;
}>;

function AdvancedSection({
  canDelete,
  onNew,
  onSaveAsCopy,
  onDelete,
  onExport,
  onImport,
}: AdvancedSectionProps) {
  return (
    <Section title="Manage">
      <Box color="label" fontSize="0.8rem" mb={0.5}>
        Import, export, and destructive actions stay here.
      </Box>
      <Collapsible title="Advanced" icon="cog">
        <Stack vertical>
          <Stack.Item>
            <Button fluid icon="plus" onClick={onNew}>
              New Playlist
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button fluid icon="copy" onClick={onSaveAsCopy}>
              Save As Copy
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button.File
              fluid
              icon="upload"
              accept=".json,application/json"
              onSelectFiles={onImport}
            >
              Import JSON
            </Button.File>
          </Stack.Item>
          <Stack.Item>
            <Button fluid icon="download" onClick={onExport}>
              Export
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              fluid
              icon="trash"
              color="bad"
              disabled={!canDelete}
              onClick={onDelete}
            >
              Delete Playlist
            </Button>
          </Stack.Item>
        </Stack>
      </Collapsible>
    </Section>
  );
}

type SceneEditorSectionProps = Readonly<{
  draft: DraftPreset;
  selectedTier: DraftTier | null;
  selectedTierId: string | null;
  onAddTier: () => void;
  onSelectTier: (tier_id: string) => void;
  onRemoveTier: (tier_id: string) => void;
  onSetTierName: (tier_id: string, value: string) => void;
  onSetTierDescription: (tier_id: string, value: string) => void;
}>;

function SceneEditorSection({
  draft,
  selectedTier,
  selectedTierId,
  onAddTier,
  onSelectTier,
  onRemoveTier,
  onSetTierName,
  onSetTierDescription,
}: SceneEditorSectionProps) {
  const canDeleteScene = Boolean(selectedTier && draft.tiers.length > 1);

  return (
    <Section
      fill
      title="Scenes"
      buttons={
        <Button icon="plus" onClick={onAddTier}>
          Add Scene
        </Button>
      }
    >
      <Stack fill vertical>
        <Stack.Item basis="26%">
          <Box style={LIST_SCROLL_STYLE}>
            {draft.tiers.length === 0 ? (
              <Box color="label">No scenes yet.</Box>
            ) : (
              draft.tiers.map((tier) => (
                <Button
                  key={tier.tier_id}
                  compact
                  fluid
                  color="transparent"
                  onClick={() => onSelectTier(tier.tier_id)}
                  style={getListRowStyle(selectedTierId === tier.tier_id)}
                >
                  <Flex align="center" justify="space-between" width="100%">
                    <Flex.Item grow>
                      <Box bold style={ELLIPSIS_STYLE}>
                        {tier.name || 'Unnamed scene'}
                      </Box>
                    </Flex.Item>
                    <Flex.Item ml={1}>
                      <Box fontSize="0.75rem" color="label">
                        {formatTrackCount(tier.variants.length)}
                      </Box>
                    </Flex.Item>
                  </Flex>
                </Button>
              ))
            )}
          </Box>
        </Stack.Item>
        <Stack.Item grow={1}>
          <Section
            title="Scene Details"
            buttons={
              <Button.Confirm
                icon="trash"
                color="transparent"
                confirmColor="bad"
                confirmIcon="trash"
                disabled={!canDeleteScene}
                confirmContent="Delete?"
                onClick={() =>
                  selectedTier && onRemoveTier(selectedTier.tier_id)
                }
              >
                Delete Scene
              </Button.Confirm>
            }
          >
            {!selectedTier ? (
              <Box color="label">Select a scene from the list above.</Box>
            ) : (
              <LabeledList>
                <LabeledList.Item label="Name">
                  <Input
                    fluid
                    value={selectedTier.name}
                    onInput={(e, value) =>
                      onSetTierName(selectedTier.tier_id, value)
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Description" verticalAlign="top">
                  <TextArea
                    fluid
                    height={DESCRIPTION_FIELD_HEIGHT}
                    value={selectedTier.description}
                    onInput={(e, value) =>
                      onSetTierDescription(selectedTier.tier_id, value)
                    }
                    placeholder="Scene description"
                    scrollbar
                  />
                </LabeledList.Item>
              </LabeledList>
            )}
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

type TrackEditorSectionProps = Readonly<{
  selectedTier: DraftTier | null;
  selectedVariant: DraftVariant | null;
  selectedVariantId: string | null;
  onAddVariant: () => void;
  onSelectVariant: (tier_id: string, variant_id: string) => void;
  onRemoveVariant: (tier_id: string, variant_id: string) => void;
  onSetVariantTitle: (
    tier_id: string,
    variant_id: string,
    value: string,
  ) => void;
  onSetVariantDescription: (
    tier_id: string,
    variant_id: string,
    value: string,
  ) => void;
  onSetVariantDuration: (
    tier_id: string,
    variant_id: string,
    value: number,
  ) => void;
  onSetVariantSourceUrl: (
    tier_id: string,
    variant_id: string,
    value: string,
  ) => void;
}>;

function TrackEditorSection({
  selectedTier,
  selectedVariant,
  selectedVariantId,
  onAddVariant,
  onSelectVariant,
  onRemoveVariant,
  onSetVariantTitle,
  onSetVariantDescription,
  onSetVariantDuration,
  onSetVariantSourceUrl,
}: TrackEditorSectionProps) {
  const canDeleteTrack = Boolean(
    selectedTier && selectedVariant && selectedTier.variants.length > 1,
  );
  const normalizedDuration = normalizeDurationValue(
    selectedVariant?.duration_seconds || 0,
  );

  return (
    <Section
      fill
      title="Tracks"
      buttons={
        <Button icon="plus" disabled={!selectedTier} onClick={onAddVariant}>
          Add Track
        </Button>
      }
    >
      {!selectedTier ? (
        <Box color="label">Select a scene to manage its tracks.</Box>
      ) : (
        <Stack fill vertical>
          <Stack.Item>
            <Box style={STATUS_STRIP_STYLE}>
              <Box bold style={ELLIPSIS_STYLE}>
                {selectedTier.name || 'Unnamed scene'}
              </Box>
              <Box color="label" fontSize="0.75rem">
                {formatTrackCount(selectedTier.variants.length)}
              </Box>
            </Box>
          </Stack.Item>
          <Stack.Item basis="22%">
            <Box style={LIST_SCROLL_STYLE}>
              {selectedTier.variants.length === 0 ? (
                <Box color="label">No tracks yet.</Box>
              ) : (
                selectedTier.variants.map((variant) => (
                  <Button
                    key={variant.variant_id}
                    compact
                    fluid
                    color="transparent"
                    onClick={() =>
                      onSelectVariant(selectedTier.tier_id, variant.variant_id)
                    }
                    style={getListRowStyle(
                      selectedVariantId === variant.variant_id,
                    )}
                  >
                    <Flex align="center" justify="space-between" width="100%">
                      <Flex.Item grow>
                        <Box bold style={ELLIPSIS_STYLE}>
                          {variant.title || 'Unnamed track'}
                        </Box>
                      </Flex.Item>
                      <Flex.Item ml={1}>
                        <Box fontSize="0.75rem" color="label">
                          {formatDuration(variant.duration_seconds)}
                        </Box>
                      </Flex.Item>
                    </Flex>
                  </Button>
                ))
              )}
            </Box>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section
              title="Track Details"
              buttons={
                <Button.Confirm
                  icon="trash"
                  color="transparent"
                  confirmColor="bad"
                  confirmIcon="trash"
                  disabled={!canDeleteTrack}
                  confirmContent="Delete?"
                  onClick={() =>
                    selectedTier &&
                    selectedVariant &&
                    onRemoveVariant(
                      selectedTier.tier_id,
                      selectedVariant.variant_id,
                    )
                  }
                >
                  Delete Track
                </Button.Confirm>
              }
            >
              {!selectedVariant ? (
                <Box color="label">Select a track from the list above.</Box>
              ) : (
                <Stack vertical>
                  <Stack.Item>
                    <Box style={COMPACT_CARD_STYLE}>
                      <Box bold fontSize="1rem" style={ELLIPSIS_STYLE}>
                        {selectedVariant.title || 'Unnamed track'}
                      </Box>
                      <Box
                        color="label"
                        fontSize="0.8rem"
                        style={ELLIPSIS_STYLE}
                      >
                        {selectedVariant.description || 'No description yet'}
                      </Box>
                      <Box
                        color="label"
                        fontSize="0.75rem"
                        mt="0.25rem"
                        style={ELLIPSIS_STYLE}
                      >
                        Length{' '}
                        {formatDuration(selectedVariant.duration_seconds)} |
                        Source {formatSourceLabel(selectedVariant.source_url)}
                      </Box>
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <LabeledList>
                      <LabeledList.Item label="Title">
                        <Input
                          fluid
                          value={selectedVariant.title}
                          onInput={(e, value) =>
                            onSetVariantTitle(
                              selectedTier.tier_id,
                              selectedVariant.variant_id,
                              value,
                            )
                          }
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Description" verticalAlign="top">
                        <TextArea
                          fluid
                          height={DESCRIPTION_FIELD_HEIGHT}
                          value={selectedVariant.description}
                          onInput={(e, value) =>
                            onSetVariantDescription(
                              selectedTier.tier_id,
                              selectedVariant.variant_id,
                              value,
                            )
                          }
                          placeholder="Track description"
                          scrollbar
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Duration">
                        <NumberInput
                          minValue={0}
                          maxValue={86400}
                          step={1}
                          value={normalizedDuration}
                          onChange={(value) =>
                            onSetVariantDuration(
                              selectedTier.tier_id,
                              selectedVariant.variant_id,
                              value,
                            )
                          }
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Source URL">
                        <Input
                          fluid
                          value={selectedVariant.source_url}
                          onInput={(e, value) =>
                            onSetVariantSourceUrl(
                              selectedTier.tier_id,
                              selectedVariant.variant_id,
                              value,
                            )
                          }
                          placeholder="https://..."
                        />
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
}

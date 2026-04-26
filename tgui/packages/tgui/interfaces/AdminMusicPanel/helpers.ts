import {
  CurrentSession,
  DraftPreset,
  DraftStatus,
  DraftTier,
  DraftVariant,
  LaunchSettings,
  OptionEntry,
  PlaybackMode,
  SelectOption,
  TrackLaunchReadiness,
} from './types';

export const normalizeDurationValue = (duration_seconds: number) => {
  if (!Number.isFinite(duration_seconds) || duration_seconds < 0) {
    return 0;
  }
  return Object.is(duration_seconds, -0) ? 0 : duration_seconds;
};

export const parseDurationInput = (rawValue: string | number) => {
  if (typeof rawValue === 'number') {
    return normalizeDurationValue(rawValue);
  }

  const trimmedValue = rawValue.trim();
  if (!trimmedValue) {
    return 0;
  }

  if (/^\d+$/.test(trimmedValue)) {
    return normalizeDurationValue(Number.parseInt(trimmedValue, 10));
  }

  if (!/^\d+(?::\d{1,2}){1,2}$/.test(trimmedValue)) {
    return null;
  }

  const parts = trimmedValue
    .split(':')
    .map((part) => Number.parseInt(part, 10));
  if (parts.some((part) => Number.isNaN(part) || part < 0)) {
    return null;
  }

  if (parts.length === 2) {
    const [minutes, seconds] = parts;
    if (seconds >= 60) {
      return null;
    }
    return normalizeDurationValue(minutes * 60 + seconds);
  }

  if (parts.length === 3) {
    const [hours, minutes, seconds] = parts;
    if (minutes >= 60 || seconds >= 60) {
      return null;
    }
    return normalizeDurationValue(hours * 3600 + minutes * 60 + seconds);
  }

  return null;
};

export const formatDurationInputValue = (duration_seconds: number) => {
  const normalizedDuration = normalizeDurationValue(duration_seconds);
  return normalizedDuration ? formatDurationCompact(normalizedDuration) : '';
};

export const formatDuration = (duration_seconds: number) => {
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

export const formatDurationCompact = (duration_seconds: number) => {
  const normalizedDuration = normalizeDurationValue(duration_seconds);
  if (!normalizedDuration) {
    return 'Unknown';
  }
  const totalSeconds = Math.floor(normalizedDuration);
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  return hours
    ? `${hours}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
    : `${minutes}:${String(seconds).padStart(2, '0')}`;
};

export const formatElapsedCompact = (elapsed_seconds: number) => {
  const safeElapsedSeconds = Math.max(0, Math.floor(elapsed_seconds || 0));
  const hours = Math.floor(safeElapsedSeconds / 3600);
  const minutes = Math.floor((safeElapsedSeconds % 3600) / 60);
  const seconds = safeElapsedSeconds % 60;
  return hours
    ? `${hours}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
    : `${minutes}:${String(seconds).padStart(2, '0')}`;
};

export const formatSourceLabel = (source_url: string) => {
  if (!source_url) {
    return 'Source not set';
  }
  try {
    return new URL(source_url).hostname.replace(/^www\./, '');
  } catch {
    return source_url;
  }
};

export const countTracks = (draft: DraftPreset) =>
  draft.tiers.reduce((total, tier) => total + tier.variants.length, 0);

export const findTier = (draft: DraftPreset, tierId: string | null) =>
  draft.tiers.find((tier) => tier.tier_id === tierId) || draft.tiers[0] || null;

export const findVariant = (tier: DraftTier | null, variantId: string | null) =>
  tier?.variants.find((variant) => variant.variant_id === variantId) ||
  tier?.variants[0] ||
  null;

export const buildLaunchSettings = (draft: DraftPreset): LaunchSettings => ({
  audience_mode: draft.playback.audience_mode,
  sound_type: draft.playback.sound_type,
  show_title_to_players: draft.playback.show_title_to_players,
  repeat: draft.playback.repeat,
  playback_mode: 'single',
});

const isPlaybackMode = (value: unknown): value is PlaybackMode =>
  value === 'single' || value === 'ordered' || value === 'random';

export const coerceLaunchSettings = (
  draft: DraftPreset,
  rawValue: Partial<LaunchSettings> | null | undefined,
): LaunchSettings => {
  const defaults = buildLaunchSettings(draft);
  if (!rawValue) {
    return defaults;
  }

  return {
    audience_mode:
      typeof rawValue.audience_mode === 'string' && rawValue.audience_mode
        ? rawValue.audience_mode
        : defaults.audience_mode,
    sound_type:
      typeof rawValue.sound_type === 'string' && rawValue.sound_type
        ? rawValue.sound_type
        : defaults.sound_type,
    show_title_to_players:
      typeof rawValue.show_title_to_players === 'boolean'
        ? rawValue.show_title_to_players
        : defaults.show_title_to_players,
    repeat:
      typeof rawValue.repeat === 'boolean' ? rawValue.repeat : defaults.repeat,
    playback_mode: isPlaybackMode(rawValue.playback_mode)
      ? rawValue.playback_mode
      : defaults.playback_mode,
  };
};

export const getDisplayedLaunchSettings = (
  launchSettings: LaunchSettings,
  currentSession: CurrentSession,
  selectedTrackIsLive: boolean,
): LaunchSettings =>
  selectedTrackIsLive &&
  currentSession &&
  isPlaybackMode(currentSession.playback_mode)
    ? {
        ...launchSettings,
        playback_mode: currentSession.playback_mode,
      }
    : launchSettings;

export const getDraftStatus = (
  draft: DraftPreset,
  dirty: boolean,
): DraftStatus => {
  if (!draft.preset_id) {
    return {
      kind: 'unsaved_draft',
      label: 'Draft',
      hint: 'Not saved to the preset library yet',
    };
  }

  if (dirty) {
    return {
      kind: 'modified_copy',
      label: 'Unsaved changes',
      hint: `Loaded preset ${draft.preset_id} has local edits`,
    };
  }

  return {
    kind: 'loaded_preset',
    label: 'Saved',
    hint: `Loaded preset ${draft.preset_id} is ready to edit`,
  };
};

export const getOptionLabel = (options: OptionEntry[], value: string) =>
  options.find((option) => option.id === value)?.label || value;

export const toSelectOptions = (options: OptionEntry[]): SelectOption[] =>
  options.map((option) => ({
    displayText: option.label,
    value: option.id,
  }));

export const formatTrackCount = (count: number) =>
  `${count} track${count === 1 ? '' : 's'}`;

export const formatVisibilitySummary = (showTitleToPlayers: boolean) =>
  showTitleToPlayers ? 'Title visible to players' : 'Title hidden from players';

export const getPlaybackModeLabel = (
  playbackMode: PlaybackMode | string | undefined,
) => {
  switch (playbackMode) {
    case 'random':
      return 'Random';
    case 'ordered':
      return 'In order';
    case 'single':
    default:
      return 'Single';
  }
};

export const formatAfterTrackEnds = (
  repeat: boolean,
  playbackMode: PlaybackMode | string | undefined,
) =>
  repeat
    ? 'Repeat the current track'
    : playbackMode === 'single'
      ? 'Stop after this track'
      : `Continue ${getPlaybackModeLabel(playbackMode).toLowerCase()}`;

export const getTrackLaunchReadiness = (
  selectedVariant: DraftVariant | null,
  launchSettings: LaunchSettings,
): TrackLaunchReadiness => {
  if (!selectedVariant) {
    return {
      canPreview: false,
      canBroadcast: false,
      reason: 'Select a track to preview or broadcast.',
      warnings: [],
    };
  }

  const sourceUrl = selectedVariant.source_url.trim();
  if (!sourceUrl) {
    return {
      canPreview: false,
      canBroadcast: false,
      reason: 'Source URL is missing.',
      warnings: [],
    };
  }

  const warnings: string[] = [];
  if (!normalizeDurationValue(selectedVariant.duration_seconds)) {
    warnings.push(
      launchSettings.playback_mode === 'single' && !launchSettings.repeat
        ? 'Duration is unknown, so Single may not stop automatically.'
        : 'Duration is unknown.',
    );
  }

  return {
    canPreview: true,
    canBroadcast: true,
    reason: null,
    warnings,
  };
};

export const isVariantMissingSource = (variant: DraftVariant) =>
  !variant.source_url.trim();

export const isVariantDurationUnknown = (variant: DraftVariant) =>
  !normalizeDurationValue(variant.duration_seconds);

export const isCurrentSessionForVariant = (
  currentSession: {
    preset_id?: string;
    tier_name?: string;
    variant_title?: string;
    source_url?: string;
  } | null,
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

export const findCurrentSessionVariantInTier = (
  currentSession: {
    preset_id?: string;
    tier_name?: string;
    variant_title?: string;
    source_url?: string;
  } | null,
  draft: DraftPreset,
  selectedTier: DraftTier | null,
) =>
  selectedTier?.variants.find((variant) =>
    isCurrentSessionForVariant(currentSession, draft, selectedTier, variant),
  ) || null;

export const isCurrentSessionForSelection = (
  currentSession: {
    preset_id?: string;
    tier_name?: string;
    variant_title?: string;
    source_url?: string;
  } | null,
  draft: DraftPreset,
  selectedTier: DraftTier | null,
  selectedVariant: DraftVariant | null,
) =>
  isCurrentSessionForVariant(
    currentSession,
    draft,
    selectedTier,
    selectedVariant,
  );

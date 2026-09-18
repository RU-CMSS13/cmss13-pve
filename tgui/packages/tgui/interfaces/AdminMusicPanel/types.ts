export type LibraryPreset = {
  preset_id: string;
  name: string;
  description: string;
  tier_count: number;
  variant_count: number;
};

export type DraftVariant = {
  variant_id: string;
  title: string;
  description: string;
  duration_seconds: number;
  source_url: string;
};

export type DraftTier = {
  tier_id: string;
  name: string;
  description: string;
  variants: DraftVariant[];
};

export type PlaybackMode = 'single' | 'ordered' | 'random';

export type PlaybackSettings = {
  audience_mode: string;
  sound_type: string;
  show_title_to_players: boolean;
  repeat: boolean;
};

export type LaunchSettings = PlaybackSettings & {
  playback_mode: PlaybackMode;
};

export type AdminMusicPanelTab = 'play' | 'edit';

export type DraftPreset = {
  preset_id: string;
  name: string;
  description: string;
  playback: PlaybackSettings;
  tiers: DraftTier[];
};

export type CurrentSession = null | {
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
  variant_description?: string;
  duration_seconds?: number;
  has_known_end_time?: boolean;
  broadcast_elapsed_seconds?: number;
  loop?: boolean;
  playback_mode?: PlaybackMode;
  playback_mode_label?: string;
};

export type OptionEntry = { id: string; label: string };

export type PreviewCommand = null | {
  nonce: number | string;
  command: 'play' | 'stop';
  title?: string;
  url?: string;
  start?: number;
  end?: number;
};

export type AdminMusicPanelData = {
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

export type SelectOption = { displayText: string; value: string };

export type DraftStatusKind =
  | 'unsaved_draft'
  | 'loaded_preset'
  | 'modified_copy';

export type DraftStatus = {
  kind: DraftStatusKind;
  label: string;
  hint: string;
};

export type TrackLaunchReadiness = {
  canPreview: boolean;
  canBroadcast: boolean;
  reason: string | null;
  warnings: string[];
};

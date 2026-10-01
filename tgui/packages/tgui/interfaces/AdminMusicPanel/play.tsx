import { useEffect, useState } from 'react';

import { Box, Stack } from '../../components';
import {
  BroadcastStatusStrip,
  LibrarySection,
  PlayScenesSection,
  PlayTracksSection,
  SessionSection,
  TracksFocusLaunchStrip,
} from './play_sections';
import {
  CurrentSession,
  DraftPreset,
  DraftTier,
  DraftVariant,
  LaunchSettings,
  LibraryPreset,
  PlaybackMode,
  SelectOption,
  TrackLaunchReadiness,
} from './types';

type PlayTabProps = Readonly<{
  current_session: CurrentSession;
  draft: DraftPreset;
  launchSettings: LaunchSettings;
  audienceOptions: SelectOption[];
  soundTypeOptions: SelectOption[];
  audienceLabel: string;
  soundTypeLabel: string;
  trackReadiness: TrackLaunchReadiness;
  selectedTrackIsLive: boolean;
  isPreviewActive: boolean;
  previewState: string;
  library: LibraryPreset[];
  librarySearch: string;
  loadedLibraryPresetId: string | null;
  onSearchChange: (value: string) => void;
  onLoadPreset: (preset_id: string) => void;
  onOpenEdit: () => void;
  dirty: boolean;
  selectedTier: DraftTier | null;
  selectedVariant: DraftVariant | null;
  selectedTierId: string | null;
  selectedVariantId: string | null;
  onSetAudienceMode: (value: string) => void;
  onSetSoundType: (value: string) => void;
  onToggleRepeat: () => void;
  onSetPlaybackMode: (value: PlaybackMode) => void;
  onResetLaunchSettings: () => void;
  onPreviewSelected: () => void;
  onStopPreview: () => void;
  onPlaySelected: () => void;
  onStopBroadcast: () => void;
  onSelectTier: (tier_id: string) => void;
  onSelectVariant: (tier_id: string, variant_id: string) => void;
}>;

export function PlayTab({
  current_session,
  draft,
  launchSettings,
  audienceOptions,
  soundTypeOptions,
  audienceLabel,
  soundTypeLabel,
  trackReadiness,
  selectedTrackIsLive,
  isPreviewActive,
  previewState,
  library,
  librarySearch,
  loadedLibraryPresetId,
  onSearchChange,
  onLoadPreset,
  onOpenEdit,
  dirty,
  selectedTier,
  selectedVariant,
  selectedTierId,
  selectedVariantId,
  onSetAudienceMode,
  onSetSoundType,
  onToggleRepeat,
  onSetPlaybackMode,
  onResetLaunchSettings,
  onPreviewSelected,
  onStopPreview,
  onPlaySelected,
  onStopBroadcast,
  onSelectTier,
  onSelectVariant,
}: PlayTabProps) {
  const [trackSearch, setTrackSearch] = useState('');
  const [denseTracks, setDenseTracks] = useState(false);
  const [showOnlyInvalid, setShowOnlyInvalid] = useState(false);
  const [showOnlyUnknown, setShowOnlyUnknown] = useState(false);
  const [tracksFocus, setTracksFocus] = useState(false);
  const canFocusTracks = Boolean(selectedTier?.variants.length);

  useEffect(() => {
    setTrackSearch('');
    setDenseTracks(false);
    setShowOnlyInvalid(false);
    setShowOnlyUnknown(false);
    setTracksFocus(false);
  }, [draft.preset_id, draft.name]);

  const handleSelectTier = (tier_id: string) => {
    setTrackSearch('');
    setShowOnlyInvalid(false);
    setShowOnlyUnknown(false);
    onSelectTier(tier_id);
  };

  const handleToggleTracksFocus = () => {
    if (!canFocusTracks) {
      return;
    }
    setTracksFocus((current) => !current);
  };

  if (tracksFocus) {
    return (
      <Stack fill vertical>
        {current_session ? (
          <Stack.Item>
            <BroadcastStatusStrip
              current_session={current_session}
              onStopBroadcast={onStopBroadcast}
            />
          </Stack.Item>
        ) : null}
        <Stack.Item grow={1}>
          <Box mt="0.38rem" style={{ height: '100%' }}>
            <PlayTracksSection
              draft={draft}
              current_session={current_session}
              selectedTier={selectedTier}
              selectedVariantId={selectedVariantId}
              trackSearch={trackSearch}
              denseTracks={denseTracks}
              showOnlyInvalid={showOnlyInvalid}
              showOnlyUnknown={showOnlyUnknown}
              focusMode
              onTrackSearchChange={setTrackSearch}
              onToggleDenseTracks={() => setDenseTracks((current) => !current)}
              onToggleOnlyInvalid={() =>
                setShowOnlyInvalid((current) => !current)
              }
              onToggleOnlyUnknown={() =>
                setShowOnlyUnknown((current) => !current)
              }
              onToggleTracksFocus={handleToggleTracksFocus}
              onSelectVariant={onSelectVariant}
            />
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box mt="0.38rem">
            <TracksFocusLaunchStrip
              current_session={current_session}
              draft={draft}
              launchSettings={launchSettings}
              audienceOptions={audienceOptions}
              soundTypeOptions={soundTypeOptions}
              audienceLabel={audienceLabel}
              soundTypeLabel={soundTypeLabel}
              selectedTier={selectedTier}
              selectedVariant={selectedVariant}
              trackReadiness={trackReadiness}
              isPreviewActive={isPreviewActive}
              previewState={previewState}
              selectedTrackIsLive={selectedTrackIsLive}
              onSetAudienceMode={onSetAudienceMode}
              onSetSoundType={onSetSoundType}
              onToggleRepeat={onToggleRepeat}
              onSetPlaybackMode={onSetPlaybackMode}
              onResetLaunchSettings={onResetLaunchSettings}
              onPreviewSelected={onPreviewSelected}
              onStopPreview={onStopPreview}
              onPlaySelected={onPlaySelected}
              onStopBroadcast={onStopBroadcast}
            />
          </Box>
        </Stack.Item>
      </Stack>
    );
  }

  return (
    <Stack fill vertical>
      {current_session ? (
        <Stack.Item>
          <BroadcastStatusStrip
            current_session={current_session}
            onStopBroadcast={onStopBroadcast}
          />
        </Stack.Item>
      ) : null}
      <Stack.Item>
        <Box mt="0.38rem">
          <SessionSection
            current_session={current_session}
            draft={draft}
            launchSettings={launchSettings}
            audienceOptions={audienceOptions}
            soundTypeOptions={soundTypeOptions}
            audienceLabel={audienceLabel}
            soundTypeLabel={soundTypeLabel}
            selectedTier={selectedTier}
            selectedVariant={selectedVariant}
            trackReadiness={trackReadiness}
            selectedTrackIsLive={selectedTrackIsLive}
            onSetAudienceMode={onSetAudienceMode}
            onSetSoundType={onSetSoundType}
            onToggleRepeat={onToggleRepeat}
            onSetPlaybackMode={onSetPlaybackMode}
            onResetLaunchSettings={onResetLaunchSettings}
            onPreviewSelected={onPreviewSelected}
            onStopPreview={onStopPreview}
            isPreviewActive={isPreviewActive}
            previewState={previewState}
            onOpenEdit={onOpenEdit}
            onPlaySelected={onPlaySelected}
            onStopBroadcast={onStopBroadcast}
          />
        </Box>
      </Stack.Item>
      <Stack.Item grow={1}>
        <Box mt="0.38rem" style={{ height: '100%' }}>
          <Stack fill>
            <Stack.Item basis="27%" grow={1} style={{ minWidth: '0' }}>
              <LibrarySection
                library={library}
                librarySearch={librarySearch}
                loadedLibraryPresetId={loadedLibraryPresetId}
                onSearchChange={onSearchChange}
                onLoadPreset={onLoadPreset}
                onOpenEdit={onOpenEdit}
                dirty={dirty}
              />
            </Stack.Item>
            <Stack.Item basis="21%" grow={1} style={{ minWidth: '0' }}>
              <PlayScenesSection
                draft={draft}
                selectedTierId={selectedTierId}
                onSelectTier={handleSelectTier}
              />
            </Stack.Item>
            <Stack.Item basis="52%" grow={2} style={{ minWidth: '0' }}>
              <PlayTracksSection
                draft={draft}
                current_session={current_session}
                selectedTier={selectedTier}
                selectedVariantId={selectedVariantId}
                trackSearch={trackSearch}
                denseTracks={denseTracks}
                showOnlyInvalid={showOnlyInvalid}
                showOnlyUnknown={showOnlyUnknown}
                onTrackSearchChange={setTrackSearch}
                onToggleDenseTracks={() =>
                  setDenseTracks((current) => !current)
                }
                onToggleOnlyInvalid={() =>
                  setShowOnlyInvalid((current) => !current)
                }
                onToggleOnlyUnknown={() =>
                  setShowOnlyUnknown((current) => !current)
                }
                onToggleTracksFocus={handleToggleTracksFocus}
                onSelectVariant={onSelectVariant}
              />
            </Stack.Item>
          </Stack>
        </Box>
      </Stack.Item>
    </Stack>
  );
}

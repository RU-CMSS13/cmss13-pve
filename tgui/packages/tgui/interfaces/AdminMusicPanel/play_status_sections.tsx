import { Box, Button, Flex, Section, Stack } from '../../components';
import { useBroadcastElapsed } from './broadcast';
import {
  CONTROL_BUTTON_STYLE,
  PLAY_CONTROLS_ROW_STYLE,
  SECTION_SURFACE_STYLE,
  SEGMENTED_GROUP_STYLE,
} from './component_styles';
import {
  formatAfterTrackEnds,
  formatDuration,
  formatElapsedCompact,
  formatSourceLabel,
} from './helpers';
import {
  FocusLaunchFactsColumn,
  getLaunchContextFactBadges,
  getPreviewActionStyle,
  getSegmentedButtonStyle,
  getStopActionStyle,
  getSubtleCompactToggleStyle,
  getTertiaryActionStyle,
  LaunchFactsRow,
  LaunchStatusSummary,
  PLAY_TOOLBAR_TOGGLE_STYLE,
  PlaybackSettingsControls,
} from './playback_presenters';
import {
  ACCENT_SUCCESS,
  BG_PANEL,
  BG_PANEL_ALT,
  BORDER,
  ELLIPSIS_STYLE,
  LIVE_BADGE_STYLE,
  STATUS_STRIP_STYLE,
  TEXT_MUTED,
  TEXT_SECONDARY,
} from './theme';
import { TrackFactBadges } from './track_presenters';
import {
  CurrentSession,
  DraftPreset,
  DraftTier,
  DraftVariant,
  LaunchSettings,
  PlaybackMode,
  SelectOption,
  TrackLaunchReadiness,
} from './types';

type CompactFactItem = Readonly<{
  label: string;
  value: string;
}>;

type BroadcastStatusStripProps = Readonly<{
  current_session: CurrentSession;
  onStopBroadcast: () => void;
  showStopButton?: boolean;
}>;

export function BroadcastStatusStrip({
  current_session,
  onStopBroadcast,
  showStopButton = true,
}: BroadcastStatusStripProps) {
  const broadcastElapsedSeconds = useBroadcastElapsed(current_session);

  if (!current_session) {
    return (
      <Box
        px={0.8}
        py={0.38}
        style={{
          ...STATUS_STRIP_STYLE,
          border: '1px solid rgba(51, 69, 87, 0.72)',
          backgroundColor: BG_PANEL,
        }}
      >
        <Stack align="center">
          <Stack.Item>
            <Box
              color={TEXT_SECONDARY}
              fontSize="0.84rem"
              style={{ fontWeight: '600' }}
            >
              Broadcast idle
            </Box>
          </Stack.Item>
          <Stack.Item grow>
            <Box color={TEXT_MUTED} fontSize="0.76rem">
              No live broadcast. Open Play to preview or broadcast a track.
            </Box>
          </Stack.Item>
        </Stack>
      </Box>
    );
  }

  const broadcastTitle =
    current_session.variant_title ||
    current_session.resolved_title ||
    'Untitled broadcast';
  const liveBehavior = formatAfterTrackEnds(
    Boolean(current_session.loop),
    current_session.playback_mode,
  );
  const broadcastPath = [current_session.preset_name, current_session.tier_name]
    .filter(Boolean)
    .join(' / ');
  const totalDurationSeconds = Math.max(
    0,
    Math.floor(current_session.duration_seconds || 0),
  );
  const playbackProgressText = totalDurationSeconds
    ? `${formatElapsedCompact(broadcastElapsedSeconds)} / ${formatElapsedCompact(totalDurationSeconds)}`
    : `${formatElapsedCompact(broadcastElapsedSeconds)} / End unknown`;
  const liveFacts: CompactFactItem[] = [
    {
      label: 'Playing',
      value: playbackProgressText,
    },
    {
      label: 'Path',
      value: broadcastPath || 'Legacy broadcast session',
    },
    {
      label: 'Length',
      value: formatDuration(current_session.duration_seconds || 0),
    },
    {
      label: 'Title',
      value: current_session.show_title_to_players ? 'Visible' : 'Hidden',
    },
    {
      label: 'Source',
      value: formatSourceLabel(current_session.source_url),
    },
  ];
  if (totalDurationSeconds > 0 && !current_session.has_known_end_time) {
    liveFacts.push({
      label: 'End',
      value: 'Unknown',
    });
  }

  return (
    <Box
      px={0.85}
      py={0.55}
      style={{
        ...STATUS_STRIP_STYLE,
        border: `1px solid ${ACCENT_SUCCESS}`,
        backgroundColor: BG_PANEL_ALT,
      }}
    >
      <Stack align="center">
        <Stack.Item grow>
          <Box color="label" fontSize="0.72rem">
            On air
          </Box>
          <Box bold style={ELLIPSIS_STYLE}>
            {broadcastTitle}
          </Box>
          <Box color="label" fontSize="0.75rem" style={ELLIPSIS_STYLE}>
            Audience {current_session.audience_label} | Sound Type{' '}
            {current_session.sound_type_label} | {liveBehavior}
          </Box>
          <Box mt="0.3rem">
            <TrackFactBadges items={liveFacts} />
          </Box>
        </Stack.Item>
        {showStopButton ? (
          <Stack.Item>
            <Button compact icon="stop" color="bad" onClick={onStopBroadcast}>
              Stop Broadcast
            </Button>
          </Stack.Item>
        ) : null}
      </Stack>
    </Box>
  );
}

type OperatorActionPanelProps = Readonly<{
  launchSettings: LaunchSettings;
  trackReadiness: TrackLaunchReadiness;
  isPreviewActive: boolean;
  selectedTrackIsLive: boolean;
  hasCurrentSession: boolean;
  onToggleRepeat: () => void;
  onSetPlaybackMode: (value: PlaybackMode) => void;
  onPreviewSelected: () => void;
  onStopPreview: () => void;
  onPlaySelected: () => void;
  onStopBroadcast: () => void;
  onResetLaunchSettings: () => void;
}>;

function OperatorActionPanel({
  launchSettings,
  trackReadiness,
  isPreviewActive,
  selectedTrackIsLive,
  hasCurrentSession,
  onToggleRepeat,
  onSetPlaybackMode,
  onPreviewSelected,
  onStopPreview,
  onPlaySelected,
  onStopBroadcast,
  onResetLaunchSettings,
}: OperatorActionPanelProps) {
  const previewDisabled = !isPreviewActive && !trackReadiness.canPreview;
  const broadcastDisabled = !trackReadiness.canBroadcast;
  const previewLabel = isPreviewActive ? 'Stop Preview' : 'Preview';
  const previewIcon = isPreviewActive ? 'stop' : 'eye';
  const broadcastLabel = selectedTrackIsLive
    ? 'Restart Broadcast'
    : 'Broadcast';

  return (
    <Section fill title="Operator Controls" style={SECTION_SURFACE_STYLE}>
      <Box mt="0.12rem">
        <Stack fill>
          <Stack.Item grow>
            <Button
              compact
              fluid
              className="AdminMusicPanel__centeredButton"
              style={CONTROL_BUTTON_STYLE}
              icon="play"
              color="good"
              disabled={broadcastDisabled}
              onClick={onPlaySelected}
            >
              {broadcastLabel}
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              compact
              fluid
              className="AdminMusicPanel__centeredButton"
              icon="stop"
              color="transparent"
              disabled={!hasCurrentSession}
              style={{
                ...getStopActionStyle(!hasCurrentSession),
                ...CONTROL_BUTTON_STYLE,
              }}
              onClick={onStopBroadcast}
            >
              Stop
            </Button>
          </Stack.Item>
        </Stack>
      </Box>
      <Box mt="0.16rem">
        <Stack fill>
          <Stack.Item grow>
            <Button
              compact
              fluid
              className="AdminMusicPanel__centeredButton"
              color="transparent"
              icon={previewIcon}
              disabled={previewDisabled}
              style={{
                ...getPreviewActionStyle(isPreviewActive, previewDisabled),
                ...CONTROL_BUTTON_STYLE,
              }}
              onClick={isPreviewActive ? onStopPreview : onPreviewSelected}
            >
              {previewLabel}
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              compact
              fluid
              className="AdminMusicPanel__centeredButton"
              color="transparent"
              icon="undo"
              style={{
                ...getTertiaryActionStyle(),
                ...CONTROL_BUTTON_STYLE,
              }}
              onClick={onResetLaunchSettings}
            >
              Reset
            </Button>
          </Stack.Item>
        </Stack>
      </Box>
      <Box mt="0.28rem" style={OPERATOR_STATUS_PANEL_STYLE}>
        <LaunchPreflightControls
          launchSettings={launchSettings}
          onToggleRepeat={onToggleRepeat}
          onSetPlaybackMode={onSetPlaybackMode}
        />
      </Box>
    </Section>
  );
}

const OPERATOR_STATUS_PANEL_STYLE = {
  borderTop: `1px solid ${BORDER}`,
  backgroundColor: BG_PANEL_ALT,
  borderRadius: '0.32rem',
  padding: '0.26rem 0.36rem',
};

type LaunchPreflightControlsProps = Readonly<{
  launchSettings: LaunchSettings;
  onToggleRepeat: () => void;
  onSetPlaybackMode: (value: PlaybackMode) => void;
  subtle?: boolean;
}>;

function LaunchPreflightControls({
  launchSettings,
  onToggleRepeat,
  onSetPlaybackMode,
  subtle = false,
}: LaunchPreflightControlsProps) {
  return (
    <Stack fill>
      <Stack.Item basis="12.25rem" grow={0}>
        <Button.Checkbox
          compact
          fluid
          className="AdminMusicPanel__centeredButton"
          checked={launchSettings.repeat}
          style={
            subtle
              ? {
                  ...getSubtleCompactToggleStyle(launchSettings.repeat),
                  width: '100%',
                  minHeight: '2rem',
                  textAlign: 'center',
                }
              : PLAY_TOOLBAR_TOGGLE_STYLE(launchSettings.repeat)
          }
          onClick={onToggleRepeat}
        >
          Repeat current track
        </Button.Checkbox>
      </Stack.Item>
      <Stack.Item basis={0} grow={1}>
        <PlaybackModeSelector
          playbackMode={launchSettings.playback_mode}
          repeat={launchSettings.repeat}
          subtle={subtle}
          onSetPlaybackMode={onSetPlaybackMode}
        />
      </Stack.Item>
    </Stack>
  );
}

type SessionSectionProps = Readonly<{
  current_session: CurrentSession;
  launchSettings: LaunchSettings;
  draft: DraftPreset;
  audienceOptions: SelectOption[];
  soundTypeOptions: SelectOption[];
  audienceLabel: string;
  soundTypeLabel: string;
  selectedTier: DraftTier | null;
  selectedVariant: DraftVariant | null;
  trackReadiness: TrackLaunchReadiness;
  selectedTrackIsLive: boolean;
  onSetAudienceMode: (value: string) => void;
  onSetSoundType: (value: string) => void;
  onToggleRepeat: () => void;
  onSetPlaybackMode: (value: PlaybackMode) => void;
  onResetLaunchSettings: () => void;
  onPreviewSelected: () => void;
  onStopPreview: () => void;
  isPreviewActive: boolean;
  previewState: string;
  onOpenEdit: () => void;
  onPlaySelected: () => void;
  onStopBroadcast: () => void;
}>;

export function SessionSection({
  current_session,
  launchSettings,
  draft,
  audienceOptions,
  soundTypeOptions,
  audienceLabel,
  soundTypeLabel,
  selectedTier,
  selectedVariant,
  trackReadiness,
  selectedTrackIsLive,
  onSetAudienceMode,
  onSetSoundType,
  onToggleRepeat,
  onSetPlaybackMode,
  onResetLaunchSettings,
  onPreviewSelected,
  onStopPreview,
  isPreviewActive,
  previewState,
  onOpenEdit,
  onPlaySelected,
  onStopBroadcast,
}: SessionSectionProps) {
  const contextTitle = selectedVariant?.title || 'No track selected';
  const launchStateText = selectedTrackIsLive
    ? 'Live'
    : trackReadiness.reason
      ? 'Blocked'
      : 'Ready to broadcast';
  const previewStateText = isPreviewActive ? 'Preview playing' : previewState;
  const contextFacts: CompactFactItem[] = [
    {
      label: 'Preset',
      value: draft.name || 'New preset',
    },
    {
      label: 'Scene',
      value: selectedTier?.name || 'None',
    },
    {
      label: 'Duration',
      value: selectedVariant
        ? formatDuration(selectedVariant.duration_seconds)
        : 'Unknown',
    },
    {
      label: 'Source',
      value: selectedVariant?.source_url?.trim()
        ? formatSourceLabel(selectedVariant.source_url)
        : 'Not set',
    },
  ];
  const contextBadges = getLaunchContextFactBadges(contextFacts);

  return (
    <Stack fill align="stretch">
      <Stack.Item basis="68%" grow={1}>
        <Section
          fill
          title="Launch Context"
          style={SECTION_SURFACE_STYLE}
          buttons={
            trackReadiness.reason ? (
              <Button
                compact
                icon="edit"
                color="transparent"
                onClick={onOpenEdit}
              >
                Fix in Edit
              </Button>
            ) : undefined
          }
        >
          <Flex align="center" justify="space-between" width="100%" mt={0.12}>
            <Flex.Item grow>
              <Box as="span" bold fontSize="1rem" style={ELLIPSIS_STYLE}>
                {contextTitle}
              </Box>
            </Flex.Item>
            {selectedTrackIsLive ? (
              <Flex.Item ml={1}>
                <Box style={LIVE_BADGE_STYLE}>On air</Box>
              </Flex.Item>
            ) : null}
          </Flex>
          <LaunchFactsRow facts={contextBadges} />
          <Box mt="0.14rem">
            <LaunchStatusSummary
              launchStateText={launchStateText}
              previewStateText={previewStateText}
              trackReadiness={trackReadiness}
            />
          </Box>
          <Box mt="0.18rem">
            <Flex width="100%" style={PLAY_CONTROLS_ROW_STYLE}>
              <Flex.Item
                grow
                basis="22rem"
                style={{ minWidth: '14rem', flex: '1 1 22rem' }}
              >
                <PlaybackSettingsControls
                  playback={launchSettings}
                  audienceOptions={audienceOptions}
                  soundTypeOptions={soundTypeOptions}
                  audienceLabel={audienceLabel}
                  soundTypeLabel={soundTypeLabel}
                  onSetAudienceMode={onSetAudienceMode}
                  onSetSoundType={onSetSoundType}
                  onToggleShowTitle={() => null}
                  showVisibilityToggle={false}
                  showRepeatToggle={false}
                  inlineDropdownLabels
                />
              </Flex.Item>
            </Flex>
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item basis="32%" grow={1}>
        <OperatorActionPanel
          launchSettings={launchSettings}
          trackReadiness={trackReadiness}
          isPreviewActive={isPreviewActive}
          selectedTrackIsLive={selectedTrackIsLive}
          hasCurrentSession={Boolean(current_session)}
          onToggleRepeat={onToggleRepeat}
          onSetPlaybackMode={onSetPlaybackMode}
          onPreviewSelected={onPreviewSelected}
          onStopPreview={onStopPreview}
          onPlaySelected={onPlaySelected}
          onStopBroadcast={onStopBroadcast}
          onResetLaunchSettings={onResetLaunchSettings}
        />
      </Stack.Item>
    </Stack>
  );
}

type PlaybackModeSelectorProps = Readonly<{
  playbackMode: PlaybackMode;
  repeat: boolean;
  onSetPlaybackMode: (value: PlaybackMode) => void;
  subtle?: boolean;
}>;

function PlaybackModeSelector({
  playbackMode,
  repeat,
  onSetPlaybackMode,
  subtle = false,
}: PlaybackModeSelectorProps) {
  const options: Array<{
    label: string;
    value: PlaybackMode;
  }> = [
    { label: 'Single', value: 'single' },
    { label: 'In order', value: 'ordered' },
    { label: 'Random', value: 'random' },
  ];

  return (
    <Box style={SEGMENTED_GROUP_STYLE}>
      {options.map((option) => (
        <Box key={option.value} mr={0} style={{ flex: '1 1 0', minWidth: '0' }}>
          <Button
            compact
            fluid
            className="AdminMusicPanel__centeredButton"
            color="transparent"
            selected={playbackMode === option.value}
            disabled={repeat}
            style={getSegmentedButtonStyle(
              playbackMode === option.value,
              repeat,
              subtle,
            )}
            onClick={() => onSetPlaybackMode(option.value)}
          >
            {option.label}
          </Button>
        </Box>
      ))}
    </Box>
  );
}

type TracksFocusLaunchStripProps = Readonly<{
  current_session: CurrentSession;
  draft: DraftPreset;
  launchSettings: LaunchSettings;
  audienceOptions: SelectOption[];
  soundTypeOptions: SelectOption[];
  audienceLabel: string;
  soundTypeLabel: string;
  selectedTier: DraftTier | null;
  selectedVariant: DraftVariant | null;
  trackReadiness: TrackLaunchReadiness;
  isPreviewActive: boolean;
  previewState: string;
  selectedTrackIsLive: boolean;
  onSetAudienceMode: (value: string) => void;
  onSetSoundType: (value: string) => void;
  onToggleRepeat: () => void;
  onSetPlaybackMode: (value: PlaybackMode) => void;
  onResetLaunchSettings: () => void;
  onPreviewSelected: () => void;
  onStopPreview: () => void;
  onPlaySelected: () => void;
  onStopBroadcast: () => void;
}>;

export function TracksFocusLaunchStrip({
  current_session,
  draft,
  launchSettings,
  audienceOptions,
  soundTypeOptions,
  audienceLabel,
  soundTypeLabel,
  selectedTier,
  selectedVariant,
  trackReadiness,
  isPreviewActive,
  previewState,
  selectedTrackIsLive,
  onSetAudienceMode,
  onSetSoundType,
  onToggleRepeat,
  onSetPlaybackMode,
  onResetLaunchSettings,
  onPreviewSelected,
  onStopPreview,
  onPlaySelected,
  onStopBroadcast,
}: TracksFocusLaunchStripProps) {
  const previewDisabled = !isPreviewActive && !trackReadiness.canPreview;
  const previewLabel = isPreviewActive ? 'Stop Preview' : 'Preview';
  const previewIcon = isPreviewActive ? 'stop' : 'eye';
  const launchStateText = selectedTrackIsLive
    ? 'Live'
    : trackReadiness.reason
      ? 'Blocked'
      : 'Ready to broadcast';
  const previewStateText = isPreviewActive ? 'Preview playing' : previewState;
  const focusFactItems: CompactFactItem[] = [
    {
      label: 'Preset',
      value: draft.name || 'New preset',
    },
    {
      label: 'Scene',
      value: selectedTier?.name || 'None',
    },
    {
      label: 'Duration',
      value: selectedVariant
        ? formatDuration(selectedVariant.duration_seconds)
        : 'Unknown',
    },
    {
      label: 'Source',
      value: selectedVariant?.source_url?.trim()
        ? formatSourceLabel(selectedVariant.source_url)
        : 'Not set',
    },
  ];

  return (
    <Box
      px={0.82}
      py={0.56}
      style={{ ...STATUS_STRIP_STYLE, backgroundColor: BG_PANEL }}
    >
      <Flex align="stretch" wrap width="100%" style={{ gap: '0.72rem' }}>
        <Flex.Item
          basis="21rem"
          style={{ minWidth: '17.5rem', flex: '0 1 21rem' }}
        >
          <FocusLaunchFactsColumn
            facts={focusFactItems}
            launchStateText={launchStateText}
            previewStateText={previewStateText}
            trackReadiness={trackReadiness}
          />
        </Flex.Item>
        <Flex.Item grow style={{ minWidth: '18rem', flex: '1 1 28rem' }}>
          <Stack fill vertical>
            <Stack.Item>
              <Flex width="100%" style={PLAY_CONTROLS_ROW_STYLE}>
                <Flex.Item
                  grow
                  basis="22rem"
                  style={{ minWidth: '14rem', flex: '1 1 22rem' }}
                >
                  <PlaybackSettingsControls
                    playback={launchSettings}
                    audienceOptions={audienceOptions}
                    soundTypeOptions={soundTypeOptions}
                    audienceLabel={audienceLabel}
                    soundTypeLabel={soundTypeLabel}
                    onSetAudienceMode={onSetAudienceMode}
                    onSetSoundType={onSetSoundType}
                    onToggleShowTitle={() => null}
                    showVisibilityToggle={false}
                    showRepeatToggle={false}
                    inlineDropdownLabels
                  />
                </Flex.Item>
                <Flex.Item
                  basis="18rem"
                  style={{ minWidth: '18rem', flex: '1 1 18rem' }}
                >
                  <Stack fill>
                    <Stack.Item grow>
                      <Button
                        compact
                        fluid
                        className="AdminMusicPanel__centeredButton"
                        color="good"
                        icon="play"
                        disabled={!trackReadiness.canBroadcast}
                        style={CONTROL_BUTTON_STYLE}
                        onClick={onPlaySelected}
                      >
                        {selectedTrackIsLive
                          ? 'Restart Broadcast'
                          : 'Broadcast'}
                      </Button>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        compact
                        fluid
                        className="AdminMusicPanel__centeredButton"
                        color="transparent"
                        icon="stop"
                        disabled={!current_session}
                        style={{
                          ...getStopActionStyle(!current_session),
                          ...CONTROL_BUTTON_STYLE,
                        }}
                        onClick={onStopBroadcast}
                      >
                        Stop
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Flex.Item>
              </Flex>
            </Stack.Item>
            <Stack.Item mt={0.34}>
              <Flex width="100%" style={PLAY_CONTROLS_ROW_STYLE}>
                <Flex.Item
                  grow
                  basis="22rem"
                  style={{ minWidth: '14rem', flex: '1 1 22rem' }}
                >
                  <LaunchPreflightControls
                    launchSettings={launchSettings}
                    onToggleRepeat={onToggleRepeat}
                    onSetPlaybackMode={onSetPlaybackMode}
                    subtle
                  />
                </Flex.Item>
                <Flex.Item
                  basis="18rem"
                  style={{ minWidth: '18rem', flex: '1 1 18rem' }}
                >
                  <Stack fill>
                    <Stack.Item grow>
                      <Button
                        compact
                        fluid
                        className="AdminMusicPanel__centeredButton"
                        color="transparent"
                        icon={previewIcon}
                        disabled={previewDisabled}
                        style={{
                          ...getPreviewActionStyle(
                            isPreviewActive,
                            previewDisabled,
                          ),
                          ...CONTROL_BUTTON_STYLE,
                        }}
                        onClick={
                          isPreviewActive ? onStopPreview : onPreviewSelected
                        }
                      >
                        {previewLabel}
                      </Button>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        compact
                        fluid
                        className="AdminMusicPanel__centeredButton"
                        color="transparent"
                        icon="undo"
                        style={{
                          ...getTertiaryActionStyle(),
                          ...CONTROL_BUTTON_STYLE,
                        }}
                        onClick={onResetLaunchSettings}
                      >
                        Reset
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Flex.Item>
              </Flex>
            </Stack.Item>
          </Stack>
        </Flex.Item>
      </Flex>
    </Box>
  );
}

import { Box, Button, Dropdown, Flex, Stack } from '../../components';
import {
  ACCENT_DANGER,
  ACCENT_NEUTRAL,
  BG_CARD,
  BG_PANEL,
  BORDER,
  DISABLED_ACTION_STYLE,
  getToggleButtonStyle,
  LABEL_STYLE,
  LIVE_BADGE_STYLE,
  PLAYER_BADGE_STYLE,
  SUBTLE_PANEL_STYLE,
  TEXT_PRIMARY,
  TEXT_SECONDARY,
  UNSAVED_BADGE_STYLE,
} from './theme';
import {
  DraftStatus,
  PlaybackSettings,
  SelectOption,
  TrackLaunchReadiness,
} from './types';

const getDraftStatusBadgeStyle = (kind: DraftStatus['kind']) => {
  switch (kind) {
    case 'loaded_preset':
      return LIVE_BADGE_STYLE;
    case 'modified_copy':
      return UNSAVED_BADGE_STYLE;
    case 'unsaved_draft':
    default:
      return PLAYER_BADGE_STYLE;
  }
};

const PLAY_CONTEXT_META_STYLE = {
  display: 'inline-block',
  padding: '0.06rem 0.34rem',
  marginRight: '0.24rem',
  marginBottom: '0.16rem',
  borderRadius: '999px',
  border: `1px solid ${BORDER}`,
  backgroundColor: BG_PANEL,
  fontSize: '0.71rem',
  color: TEXT_SECONDARY,
};

const PLAY_FACTS_AND_STATUS_ROW_STYLE = {
  display: 'flex',
  flexWrap: 'wrap',
  alignItems: 'center',
  gap: '0.24rem 0.5rem',
  width: '100%',
  minWidth: '0',
};

const PLAY_FACTS_GROUP_STYLE = {
  display: 'flex',
  flexWrap: 'wrap',
  alignItems: 'center',
  gap: '0.16rem 0.24rem',
  minWidth: '0',
  flex: '1 1 auto',
};

const PLAY_STATUS_BAR_ITEM_STYLE = {
  minWidth: '0',
  width: '100%',
  flex: '1 1 100%',
};

const PLAY_TOOLBAR_TOGGLE_STYLE = (checked: boolean) => ({
  ...getCompactToggleStyle(checked),
  width: '100%',
  minHeight: '2rem',
  textAlign: 'center',
});

const PLAY_SETTINGS_LABEL_STYLE = {
  ...LABEL_STYLE,
  fontSize: '0.72rem',
  marginBottom: '0.08rem',
};

const getPreviewActionStyle = (
  isActive: boolean,
  disabled: boolean,
): Record<string, string> => ({
  border: isActive ? `1px solid ${ACCENT_NEUTRAL}` : `1px solid ${BORDER}`,
  backgroundColor: isActive ? 'rgba(78, 102, 130, 0.26)' : BG_CARD,
  color: TEXT_PRIMARY,
  ...(disabled ? DISABLED_ACTION_STYLE : {}),
});

const getStopActionStyle = (disabled: boolean): Record<string, string> => ({
  border: `1px solid ${ACCENT_DANGER}`,
  backgroundColor: 'rgba(201, 58, 58, 0.12)',
  color: TEXT_PRIMARY,
  ...(disabled ? DISABLED_ACTION_STYLE : {}),
});

const getTertiaryActionStyle = (disabled = false): Record<string, string> => ({
  border: `1px solid ${BORDER}`,
  backgroundColor: BG_CARD,
  color: TEXT_SECONDARY,
  ...(disabled ? DISABLED_ACTION_STYLE : {}),
});

const getCompactToggleStyle = (checked: boolean): Record<string, string> => ({
  ...getToggleButtonStyle(checked),
  minHeight: '2rem',
  textAlign: 'center',
});

const getSubtleCompactToggleStyle = (
  checked: boolean,
): Record<string, string> => ({
  ...getCompactToggleStyle(checked),
  backgroundColor: checked ? 'rgba(78, 102, 130, 0.14)' : BG_PANEL,
  border: `1px solid ${checked ? ACCENT_NEUTRAL : BORDER}`,
  boxShadow: 'none',
});

const getSegmentedButtonStyle = (
  selected: boolean,
  disabled: boolean,
  subtle = false,
): Record<string, string> => ({
  border: selected ? `1px solid ${ACCENT_NEUTRAL}` : '1px solid transparent',
  backgroundColor: selected && !subtle ? 'rgba(78, 102, 130, 0.26)' : BG_PANEL,
  color: selected ? TEXT_PRIMARY : TEXT_SECONDARY,
  boxShadow: selected ? 'inset 0 0 0 1px rgba(255, 255, 255, 0.04)' : 'none',
  textAlign: 'center',
  ...(disabled ? DISABLED_ACTION_STYLE : {}),
});

type CompactFactItem = Readonly<{
  label: string;
  value: string;
}>;

type LaunchContextBadge = Readonly<{
  key: string;
  text: string;
  style?: Record<string, string>;
}>;

function getLaunchContextFactBadges(
  contextFacts: CompactFactItem[],
): LaunchContextBadge[] {
  return contextFacts.map((item) => ({
    key: item.label,
    text: `${item.label}: ${item.value}`,
  }));
}

const LAUNCH_STATUS_PANEL_STYLE = {
  ...SUBTLE_PANEL_STYLE,
  padding: '0.34rem 0.58rem',
  minWidth: '0',
  width: '100%',
};

const LAUNCH_STATUS_SEGMENTS_STYLE = {
  display: 'flex',
  flexWrap: 'wrap',
  alignItems: 'center',
  gap: '0.14rem 0.5rem',
  minWidth: '0',
};

const LAUNCH_STATUS_SEGMENT_STYLE = {
  color: TEXT_SECONDARY,
  fontSize: '0.74rem',
  whiteSpace: 'nowrap',
  lineHeight: '1.22',
};

type LaunchStatusSummaryProps = Readonly<{
  launchStateText: string;
  previewStateText: string;
  trackReadiness: TrackLaunchReadiness;
}>;

function LaunchStatusSummary({
  launchStateText,
  previewStateText,
  trackReadiness,
}: LaunchStatusSummaryProps) {
  const segments = [
    `Status: ${launchStateText}`,
    `Preview: ${previewStateText}`,
  ];

  if (trackReadiness.reason) {
    segments.push(`Blocked: ${trackReadiness.reason}`);
  }

  if (trackReadiness.warnings.length) {
    segments.push(`Warning: ${trackReadiness.warnings[0]}`);
  }

  return (
    <Box style={LAUNCH_STATUS_PANEL_STYLE}>
      <Flex wrap width="100%" style={LAUNCH_STATUS_SEGMENTS_STYLE}>
        {segments.map((segment) => (
          <Flex.Item key={segment} style={{ minWidth: '0', flex: '0 1 auto' }}>
            <Box style={LAUNCH_STATUS_SEGMENT_STYLE}>{segment}</Box>
          </Flex.Item>
        ))}
      </Flex>
    </Box>
  );
}

type LaunchFactsRowProps = Readonly<{
  facts: LaunchContextBadge[];
  mt?: string | number;
}>;

function LaunchFactsRow({ facts, mt = '0.1rem' }: LaunchFactsRowProps) {
  return (
    <Box mt={mt}>
      <Flex width="100%" style={PLAY_FACTS_AND_STATUS_ROW_STYLE}>
        <Flex.Item style={PLAY_FACTS_GROUP_STYLE}>
          {facts.map((item) => (
            <Box
              key={item.key}
              style={item.style ? item.style : PLAY_CONTEXT_META_STYLE}
            >
              {item.text}
            </Box>
          ))}
        </Flex.Item>
      </Flex>
    </Box>
  );
}

const FOCUS_FACTS_COLUMN_STYLE = {
  ...SUBTLE_PANEL_STYLE,
  padding: '0.46rem 0.62rem',
  minHeight: '100%',
};

const FOCUS_FACTS_GRID_STYLE = {
  display: 'grid',
  gridTemplateColumns: 'minmax(0, 1fr) minmax(0, 1fr)',
  columnGap: '0.75rem',
  rowGap: '0.18rem',
  width: '100%',
  minWidth: '0',
};

const FOCUS_FACTS_SUBCOLUMN_STYLE = {
  minWidth: '0',
  width: '100%',
};

const FOCUS_FACT_LINE_STYLE = {
  fontSize: '0.76rem',
  color: TEXT_SECONDARY,
  lineHeight: '1.25',
  whiteSpace: 'normal',
  wordBreak: 'break-word',
};

const FOCUS_FACT_VALUE_STYLE = {
  color: TEXT_PRIMARY,
};

const FOCUS_FACTS_STATUS_ROW_STYLE = {
  marginTop: '0.18rem',
  paddingTop: '0.18rem',
  borderTop: `1px solid ${BORDER}`,
};

type FocusLaunchFactsColumnProps = Readonly<{
  facts: CompactFactItem[];
  launchStateText: string;
  previewStateText: string;
  trackReadiness: TrackLaunchReadiness;
}>;

function FocusLaunchFactsColumn({
  facts,
  launchStateText,
  previewStateText,
  trackReadiness,
}: FocusLaunchFactsColumnProps) {
  const sourceFact = facts.find((item) => item.label === 'Source');
  const leftColumnLines = facts
    .filter(
      (item) =>
        item.label !== 'Source' &&
        item.label !== 'Status' &&
        item.label !== 'Preview',
    )
    .map((item) => ({ label: item.label, value: item.value }));
  const rightColumnLines = [
    ...(sourceFact
      ? [{ label: sourceFact.label, value: sourceFact.value }]
      : []),
    { label: 'Preview', value: previewStateText },
  ];

  return (
    <Box style={FOCUS_FACTS_COLUMN_STYLE}>
      <Box style={FOCUS_FACTS_GRID_STYLE}>
        <Box style={FOCUS_FACTS_SUBCOLUMN_STYLE}>
          {leftColumnLines.map((line) => (
            <Box
              key={`${line.label}:${line.value}`}
              mb="0.12rem"
              style={FOCUS_FACT_LINE_STYLE}
            >
              {line.label}:{' '}
              <span style={FOCUS_FACT_VALUE_STYLE}>{line.value}</span>
            </Box>
          ))}
        </Box>
        <Box style={FOCUS_FACTS_SUBCOLUMN_STYLE}>
          {rightColumnLines.map((line) => (
            <Box
              key={`${line.label}:${line.value}`}
              mb="0.12rem"
              style={FOCUS_FACT_LINE_STYLE}
            >
              {line.label}:{' '}
              <span style={FOCUS_FACT_VALUE_STYLE}>{line.value}</span>
            </Box>
          ))}
        </Box>
      </Box>
      <Box style={FOCUS_FACTS_STATUS_ROW_STYLE}>
        <Box style={FOCUS_FACT_LINE_STYLE}>
          Status: <span style={FOCUS_FACT_VALUE_STYLE}>{launchStateText}</span>
        </Box>
        {trackReadiness.reason ? (
          <Box mt="0.1rem" style={FOCUS_FACT_LINE_STYLE}>
            Blocked:{' '}
            <span style={FOCUS_FACT_VALUE_STYLE}>{trackReadiness.reason}</span>
          </Box>
        ) : null}
        {trackReadiness.warnings.length ? (
          <Box mt="0.1rem" style={FOCUS_FACT_LINE_STYLE}>
            Warning:{' '}
            <span style={FOCUS_FACT_VALUE_STYLE}>
              {trackReadiness.warnings[0]}
            </span>
          </Box>
        ) : null}
      </Box>
    </Box>
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
  onToggleRepeat?: () => void;
  showRepeatToggle?: boolean;
  showVisibilityToggle?: boolean;
  visibilityInline?: boolean;
  wrapToggleRow?: boolean;
  inlineDropdownLabels?: boolean;
}>;

const WRAPPING_TOGGLE_BUTTON_STYLE = (checked: boolean) => ({
  ...getCompactToggleStyle(checked),
  width: '100%',
  minWidth: '0',
  minHeight: '2.2rem',
  whiteSpace: 'normal',
  lineHeight: '1.2',
  textAlign: 'left',
  justifyContent: 'flex-start',
});

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
  showRepeatToggle = true,
  showVisibilityToggle = true,
  visibilityInline = false,
  wrapToggleRow = false,
  inlineDropdownLabels = false,
}: PlaybackSettingsControlsProps) {
  return (
    <Stack vertical>
      <Stack.Item>
        <Stack fill>
          <Stack.Item basis={visibilityInline ? '38%' : '50%'} grow={1}>
            {!inlineDropdownLabels ? (
              <Box style={PLAY_SETTINGS_LABEL_STYLE}>Audience</Box>
            ) : null}
            <Dropdown
              width="100%"
              color="transparent"
              className="AdminMusicPanel__dropdownControl"
              options={audienceOptions}
              selected={playback.audience_mode}
              displayText={
                inlineDropdownLabels
                  ? `Audience: ${audienceLabel}`
                  : audienceLabel
              }
              onSelected={(value) => onSetAudienceMode(value)}
            />
          </Stack.Item>
          <Stack.Item basis={visibilityInline ? '38%' : '50%'} grow={1}>
            {!inlineDropdownLabels ? (
              <Box style={PLAY_SETTINGS_LABEL_STYLE}>Sound Type</Box>
            ) : null}
            <Dropdown
              width="100%"
              color="transparent"
              className="AdminMusicPanel__dropdownControl"
              options={soundTypeOptions}
              selected={playback.sound_type}
              displayText={
                inlineDropdownLabels
                  ? `Sound Type: ${soundTypeLabel}`
                  : soundTypeLabel
              }
              onSelected={(value) => onSetSoundType(value)}
            />
          </Stack.Item>
          {visibilityInline && showVisibilityToggle ? (
            <Stack.Item basis="24%" grow={1}>
              <Box style={PLAY_SETTINGS_LABEL_STYLE}>Players Visible</Box>
              <Button.Checkbox
                compact
                fluid
                checked={playback.show_title_to_players}
                style={getCompactToggleStyle(playback.show_title_to_players)}
                onClick={onToggleShowTitle}
              >
                {playback.show_title_to_players ? 'Visible' : 'Hidden'}
              </Button.Checkbox>
            </Stack.Item>
          ) : null}
        </Stack>
      </Stack.Item>
      {(!visibilityInline && showVisibilityToggle) || showRepeatToggle ? (
        <Stack.Item>
          {wrapToggleRow ? (
            <Flex wrap width="100%" style={{ gap: '0.3rem' }}>
              {!visibilityInline && showVisibilityToggle ? (
                <Flex.Item
                  grow
                  basis="13rem"
                  style={{ minWidth: '0', flex: '1 1 13rem' }}
                >
                  <Button.Checkbox
                    compact
                    fluid
                    checked={playback.show_title_to_players}
                    style={WRAPPING_TOGGLE_BUTTON_STYLE(
                      playback.show_title_to_players,
                    )}
                    onClick={onToggleShowTitle}
                  >
                    Visible to players
                  </Button.Checkbox>
                </Flex.Item>
              ) : null}
              {showRepeatToggle ? (
                <Flex.Item
                  grow
                  basis="13rem"
                  style={{ minWidth: '0', flex: '1 1 13rem' }}
                >
                  <Button.Checkbox
                    compact
                    fluid
                    checked={playback.repeat}
                    style={WRAPPING_TOGGLE_BUTTON_STYLE(playback.repeat)}
                    onClick={onToggleRepeat}
                  >
                    Repeat until stopped
                  </Button.Checkbox>
                </Flex.Item>
              ) : null}
            </Flex>
          ) : (
            <Stack fill>
              {!visibilityInline && showVisibilityToggle ? (
                <Stack.Item grow>
                  <Button.Checkbox
                    compact
                    fluid
                    checked={playback.show_title_to_players}
                    style={getCompactToggleStyle(
                      playback.show_title_to_players,
                    )}
                    onClick={onToggleShowTitle}
                  >
                    Visible to players
                  </Button.Checkbox>
                </Stack.Item>
              ) : null}
              {showRepeatToggle ? (
                <Stack.Item grow>
                  <Button.Checkbox
                    compact
                    fluid
                    checked={playback.repeat}
                    style={getCompactToggleStyle(playback.repeat)}
                    onClick={onToggleRepeat}
                  >
                    Repeat until stopped
                  </Button.Checkbox>
                </Stack.Item>
              ) : null}
            </Stack>
          )}
        </Stack.Item>
      ) : null}
    </Stack>
  );
}

export {
  FocusLaunchFactsColumn,
  getCompactToggleStyle,
  getDraftStatusBadgeStyle,
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
};

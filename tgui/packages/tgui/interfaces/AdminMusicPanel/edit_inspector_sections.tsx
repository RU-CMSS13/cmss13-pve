import { Box, Button, Flex, LabeledList, Stack } from '../../components';
import {
  BufferedDurationInput,
  BufferedInput,
  BufferedTextArea,
} from './buffered_inputs';
import {
  EDIT_FIELD_WRAPPER_STYLE,
  INSPECTOR_ACTION_BUTTON_STYLE,
  INSPECTOR_CARD_STYLE,
  INSPECTOR_TARGET_TEXT_STYLE,
  RESPONSIVE_ACTION_GROUP_STYLE,
  RESPONSIVE_HEADER_ROW_STYLE,
} from './component_styles';
import {
  formatDuration,
  formatSourceLabel,
  formatTrackCount,
  normalizeDurationValue,
} from './helpers';
import {
  DISABLED_ACTION_STYLE,
  ELLIPSIS_STYLE,
  PLAYER_BADGE_STYLE,
  TEXT_MUTED,
} from './theme';
import { getVariantListBadges } from './track_presenters';
import { DraftPreset, DraftTier, DraftVariant } from './types';

export type InspectorTarget = 'scene' | 'track';

type SelectedItemSectionProps = Readonly<{
  inspectorTarget: InspectorTarget;
  draft: DraftPreset;
  selectedTier: DraftTier | null;
  selectedVariant: DraftVariant | null;
  onRemoveTier: (tier_id: string) => void;
  onMoveTierUp: (tier_id: string) => void;
  onMoveTierDown: (tier_id: string) => void;
  onSetTierName: (tier_id: string, value: string) => void;
  onSetTierDescription: (tier_id: string, value: string) => void;
  onRemoveVariant: (tier_id: string, variant_id: string) => void;
  onMoveVariantUp: (tier_id: string, variant_id: string) => void;
  onMoveVariantDown: (tier_id: string, variant_id: string) => void;
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
  onResolveVariantMetadata: (tier_id: string, variant_id: string) => void;
}>;

export function SelectedItemSection({
  inspectorTarget,
  draft,
  selectedTier,
  selectedVariant,
  onRemoveTier,
  onMoveTierUp,
  onMoveTierDown,
  onSetTierName,
  onSetTierDescription,
  onRemoveVariant,
  onMoveVariantUp,
  onMoveVariantDown,
  onSetVariantTitle,
  onSetVariantDescription,
  onSetVariantDuration,
  onSetVariantSourceUrl,
  onResolveVariantMetadata,
}: SelectedItemSectionProps) {
  const showTrackInspector =
    inspectorTarget === 'track' && Boolean(selectedTier && selectedVariant);

  return (
    <Box
      style={{
        ...INSPECTOR_CARD_STYLE,
        height: '100%',
        minWidth: '0',
        overflow: 'hidden',
      }}
    >
      <Flex
        align="flex-start"
        justify="space-between"
        wrap
        width="100%"
        style={RESPONSIVE_HEADER_ROW_STYLE}
      >
        <Flex.Item grow basis="12rem" style={{ minWidth: '0' }}>
          <Box bold style={INSPECTOR_TARGET_TEXT_STYLE}>
            Selected Item
          </Box>
          <Box color={TEXT_MUTED} fontSize="0.74rem" mb="0.34rem">
            Follows the current selection in Structure.
          </Box>
        </Flex.Item>
        {selectedTier ? (
          <Flex.Item style={{ minWidth: '0', flex: '0 0 auto' }}>
            <Box style={INSPECTOR_TARGET_TEXT_STYLE}>
              {showTrackInspector ? 'Track' : 'Scene'}
            </Box>
          </Flex.Item>
        ) : null}
      </Flex>
      {!selectedTier ? (
        <Box color="label">
          Select a scene or track in Structure to inspect it.
        </Box>
      ) : showTrackInspector ? (
        <TrackInspectorSection
          selectedTier={selectedTier}
          selectedVariant={selectedVariant}
          onRemoveVariant={onRemoveVariant}
          onMoveVariantUp={onMoveVariantUp}
          onMoveVariantDown={onMoveVariantDown}
          onSetVariantTitle={onSetVariantTitle}
          onSetVariantDescription={onSetVariantDescription}
          onSetVariantDuration={onSetVariantDuration}
          onSetVariantSourceUrl={onSetVariantSourceUrl}
          onResolveVariantMetadata={onResolveVariantMetadata}
        />
      ) : (
        <SceneInspectorSection
          draft={draft}
          selectedTier={selectedTier}
          onRemoveTier={onRemoveTier}
          onMoveTierUp={onMoveTierUp}
          onMoveTierDown={onMoveTierDown}
          onSetTierName={onSetTierName}
          onSetTierDescription={onSetTierDescription}
        />
      )}
    </Box>
  );
}

type SceneInspectorSectionProps = Readonly<{
  draft: DraftPreset;
  selectedTier: DraftTier;
  onRemoveTier: (tier_id: string) => void;
  onMoveTierUp: (tier_id: string) => void;
  onMoveTierDown: (tier_id: string) => void;
  onSetTierName: (tier_id: string, value: string) => void;
  onSetTierDescription: (tier_id: string, value: string) => void;
}>;

function SceneInspectorSection({
  draft,
  selectedTier,
  onRemoveTier,
  onMoveTierUp,
  onMoveTierDown,
  onSetTierName,
  onSetTierDescription,
}: SceneInspectorSectionProps) {
  const selectedTierIndex = draft.tiers.findIndex(
    (tier) => tier.tier_id === selectedTier.tier_id,
  );
  const canDeleteScene = draft.tiers.length > 1;
  const canMoveSceneUp = selectedTierIndex > 0;
  const canMoveSceneDown = selectedTierIndex < draft.tiers.length - 1;

  return (
    <Stack fill vertical key={selectedTier.tier_id}>
      <Stack.Item>
        <Box style={INSPECTOR_CARD_STYLE}>
          <Box bold fontSize="1rem" style={ELLIPSIS_STYLE}>
            {selectedTier.name || 'Unnamed scene'}
          </Box>
          <Box color="label" fontSize="0.8rem" style={ELLIPSIS_STYLE}>
            {selectedTier.description || 'No description yet'}
          </Box>
          <Box mt="0.25rem">
            <Box style={PLAYER_BADGE_STYLE}>
              Order {selectedTierIndex + 1} of {draft.tiers.length}
            </Box>
            <Box style={PLAYER_BADGE_STYLE}>
              {formatTrackCount(selectedTier.variants.length)}
            </Box>
          </Box>
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Flex
          align="flex-start"
          justify="space-between"
          wrap
          width="100%"
          style={RESPONSIVE_HEADER_ROW_STYLE}
        >
          <Flex.Item grow basis="12rem" style={{ minWidth: '0' }}>
            <Box bold>Scene Properties</Box>
          </Flex.Item>
          <Flex.Item style={{ minWidth: '0', flex: '0 0 auto' }}>
            <Flex wrap justify="flex-end" style={RESPONSIVE_ACTION_GROUP_STYLE}>
              <Flex.Item>
                <Button
                  compact
                  icon="arrow-up"
                  color="transparent"
                  disabled={!canMoveSceneUp}
                  style={{
                    ...INSPECTOR_ACTION_BUTTON_STYLE,
                    ...(!canMoveSceneUp ? DISABLED_ACTION_STYLE : {}),
                  }}
                  onClick={() => onMoveTierUp(selectedTier.tier_id)}
                >
                  Move Up
                </Button>
              </Flex.Item>
              <Flex.Item>
                <Button
                  compact
                  icon="arrow-down"
                  color="transparent"
                  disabled={!canMoveSceneDown}
                  style={{
                    ...INSPECTOR_ACTION_BUTTON_STYLE,
                    ...(!canMoveSceneDown ? DISABLED_ACTION_STYLE : {}),
                  }}
                  onClick={() => onMoveTierDown(selectedTier.tier_id)}
                >
                  Move Down
                </Button>
              </Flex.Item>
              <Flex.Item>
                <Button.Confirm
                  compact
                  icon="trash"
                  color="transparent"
                  disabled={!canDeleteScene}
                  style={{
                    ...INSPECTOR_ACTION_BUTTON_STYLE,
                    ...(!canDeleteScene ? DISABLED_ACTION_STYLE : {}),
                  }}
                  confirmColor="bad"
                  confirmIcon="trash"
                  confirmContent="Delete?"
                  onClick={() => onRemoveTier(selectedTier.tier_id)}
                >
                  Delete
                </Button.Confirm>
              </Flex.Item>
            </Flex>
          </Flex.Item>
        </Flex>
      </Stack.Item>
      <Stack.Item grow={1}>
        <LabeledList>
          <LabeledList.Item label="Name">
            <Box style={EDIT_FIELD_WRAPPER_STYLE}>
              <BufferedInput
                syncKey={`${selectedTier.tier_id}:name`}
                value={selectedTier.name}
                onCommit={(value) => onSetTierName(selectedTier.tier_id, value)}
                placeholder="Scene name"
              />
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Description" verticalAlign="top">
            <Box style={EDIT_FIELD_WRAPPER_STYLE}>
              <BufferedTextArea
                syncKey={selectedTier.tier_id}
                value={selectedTier.description}
                onCommit={(value) =>
                  onSetTierDescription(selectedTier.tier_id, value)
                }
                placeholder="Scene description"
                minRows={4}
                maxRows={8}
              />
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
}

type TrackInspectorSectionProps = Readonly<{
  selectedTier: DraftTier;
  selectedVariant: DraftVariant | null;
  onRemoveVariant: (tier_id: string, variant_id: string) => void;
  onMoveVariantUp: (tier_id: string, variant_id: string) => void;
  onMoveVariantDown: (tier_id: string, variant_id: string) => void;
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
  onResolveVariantMetadata: (tier_id: string, variant_id: string) => void;
}>;

function TrackInspectorSection({
  selectedTier,
  selectedVariant,
  onRemoveVariant,
  onMoveVariantUp,
  onMoveVariantDown,
  onSetVariantTitle,
  onSetVariantDescription,
  onSetVariantDuration,
  onSetVariantSourceUrl,
  onResolveVariantMetadata,
}: TrackInspectorSectionProps) {
  if (!selectedVariant) {
    return <Box color="label">Select a track in Structure to inspect it.</Box>;
  }

  const selectedVariantIndex = selectedTier.variants.findIndex(
    (variant) => variant.variant_id === selectedVariant.variant_id,
  );
  const canDeleteTrack = selectedTier.variants.length > 1;
  const canMoveTrackUp = selectedVariantIndex > 0;
  const canMoveTrackDown =
    selectedVariantIndex < selectedTier.variants.length - 1;
  const normalizedDuration = normalizeDurationValue(
    selectedVariant.duration_seconds,
  );
  const sourceLabel = selectedVariant.source_url.trim()
    ? formatSourceLabel(selectedVariant.source_url)
    : 'Not set';

  return (
    <Stack fill vertical key={selectedVariant.variant_id}>
      <Stack.Item>
        <Box style={INSPECTOR_CARD_STYLE}>
          <Box bold fontSize="1rem" style={ELLIPSIS_STYLE}>
            {selectedVariant.title || 'Unnamed track'}
          </Box>
          <Box color="label" fontSize="0.8rem" style={ELLIPSIS_STYLE}>
            {selectedVariant.description || 'No description yet'}
          </Box>
          <Box mt="0.25rem">
            <Box style={PLAYER_BADGE_STYLE}>
              Order {selectedVariantIndex + 1} of {selectedTier.variants.length}
            </Box>
            <Box style={PLAYER_BADGE_STYLE}>
              {formatDuration(selectedVariant.duration_seconds)}
            </Box>
            <Box style={PLAYER_BADGE_STYLE}>{sourceLabel}</Box>
          </Box>
          {getVariantListBadges(selectedVariant).length ? (
            <Box mt="0.12rem">
              {getVariantListBadges(selectedVariant).map((badge) => (
                <Box key={badge.label} style={badge.style}>
                  {badge.label}
                </Box>
              ))}
            </Box>
          ) : null}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Flex
          align="flex-start"
          justify="space-between"
          wrap
          width="100%"
          style={RESPONSIVE_HEADER_ROW_STYLE}
        >
          <Flex.Item grow basis="12rem" style={{ minWidth: '0' }}>
            <Box bold>Track Properties</Box>
          </Flex.Item>
          <Flex.Item style={{ minWidth: '0', flex: '0 0 auto' }}>
            <Flex wrap justify="flex-end" style={RESPONSIVE_ACTION_GROUP_STYLE}>
              <Flex.Item>
                <Button
                  compact
                  icon="arrow-up"
                  color="transparent"
                  disabled={!canMoveTrackUp}
                  style={{
                    ...INSPECTOR_ACTION_BUTTON_STYLE,
                    ...(!canMoveTrackUp ? DISABLED_ACTION_STYLE : {}),
                  }}
                  onClick={() =>
                    onMoveVariantUp(
                      selectedTier.tier_id,
                      selectedVariant.variant_id,
                    )
                  }
                >
                  Move Up
                </Button>
              </Flex.Item>
              <Flex.Item>
                <Button
                  compact
                  icon="arrow-down"
                  color="transparent"
                  disabled={!canMoveTrackDown}
                  style={{
                    ...INSPECTOR_ACTION_BUTTON_STYLE,
                    ...(!canMoveTrackDown ? DISABLED_ACTION_STYLE : {}),
                  }}
                  onClick={() =>
                    onMoveVariantDown(
                      selectedTier.tier_id,
                      selectedVariant.variant_id,
                    )
                  }
                >
                  Move Down
                </Button>
              </Flex.Item>
              <Flex.Item>
                <Button.Confirm
                  compact
                  icon="trash"
                  color="transparent"
                  disabled={!canDeleteTrack}
                  style={{
                    ...INSPECTOR_ACTION_BUTTON_STYLE,
                    ...(!canDeleteTrack ? DISABLED_ACTION_STYLE : {}),
                  }}
                  confirmColor="bad"
                  confirmIcon="trash"
                  confirmContent="Delete?"
                  onClick={() =>
                    onRemoveVariant(
                      selectedTier.tier_id,
                      selectedVariant.variant_id,
                    )
                  }
                >
                  Delete
                </Button.Confirm>
              </Flex.Item>
            </Flex>
          </Flex.Item>
        </Flex>
      </Stack.Item>
      <Stack.Item grow={1}>
        <LabeledList>
          <LabeledList.Item label="Title">
            <Box style={EDIT_FIELD_WRAPPER_STYLE}>
              <BufferedInput
                syncKey={selectedVariant.variant_id}
                value={selectedVariant.title}
                onCommit={(value) =>
                  onSetVariantTitle(
                    selectedTier.tier_id,
                    selectedVariant.variant_id,
                    value,
                  )
                }
                placeholder="Track title"
              />
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Description" verticalAlign="top">
            <Box style={EDIT_FIELD_WRAPPER_STYLE}>
              <BufferedTextArea
                syncKey={selectedVariant.variant_id}
                value={selectedVariant.description}
                onCommit={(value) =>
                  onSetVariantDescription(
                    selectedTier.tier_id,
                    selectedVariant.variant_id,
                    value,
                  )
                }
                placeholder="Track description"
                minRows={4}
                maxRows={8}
              />
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Duration">
            <Box style={EDIT_FIELD_WRAPPER_STYLE}>
              <Flex align="center" width="100%" style={{ gap: '0.35rem' }}>
                <Flex.Item
                  shrink={0}
                  basis="6.5rem"
                  style={{ minWidth: '6.5rem', maxWidth: '6.5rem' }}
                >
                  <BufferedDurationInput
                    syncKey={`${selectedVariant.variant_id}:duration`}
                    value={normalizedDuration}
                    onCommit={(value) =>
                      onSetVariantDuration(
                        selectedTier.tier_id,
                        selectedVariant.variant_id,
                        value,
                      )
                    }
                  />
                </Flex.Item>
                <Flex.Item grow basis={0} style={{ minWidth: '0' }}>
                  <Button
                    compact
                    fluid
                    className="AdminMusicPanel__centeredButton"
                    icon="sync"
                    color="transparent"
                    disabled={!selectedVariant.source_url.trim()}
                    style={INSPECTOR_ACTION_BUTTON_STYLE}
                    onClick={() =>
                      onResolveVariantMetadata(
                        selectedTier.tier_id,
                        selectedVariant.variant_id,
                      )
                    }
                  >
                    Resolve metadata
                  </Button>
                </Flex.Item>
              </Flex>
              {!normalizedDuration ? (
                <Box color="label" fontSize="0.75rem" mt="0.2rem">
                  Use seconds or timecode (mm:ss or hh:mm:ss). Unknown duration
                  is allowed, but Single mode may not stop automatically.
                </Box>
              ) : null}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Source URL">
            <Box style={EDIT_FIELD_WRAPPER_STYLE}>
              <BufferedInput
                syncKey={`${selectedVariant.variant_id}:source`}
                value={selectedVariant.source_url}
                onCommit={(value) =>
                  onSetVariantSourceUrl(
                    selectedTier.tier_id,
                    selectedVariant.variant_id,
                    value,
                  )
                }
                placeholder="https://..."
                monospace
              />
              {!selectedVariant.source_url.trim() ? (
                <Box color="label" fontSize="0.75rem" mt="0.2rem">
                  Required for preview and broadcast.
                </Box>
              ) : null}
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
}

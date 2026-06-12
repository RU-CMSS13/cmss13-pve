import { Box, Button, Flex, Input, Section, Stack } from '../../components';
import {
  FULL_WIDTH_CLAMP_STYLE,
  RESPONSIVE_ACTION_GROUP_STYLE,
  RESPONSIVE_HEADER_ROW_STYLE,
  SECTION_SURFACE_STYLE,
  STRUCTURE_ACTION_BUTTON_STYLE,
  TRACK_LIST_SCROLL_STYLE,
  TRACK_ROW_LEFT_STYLE,
} from './component_styles';
import { formatDurationCompact, formatTrackCount } from './helpers';
import { getCompactToggleStyle } from './playback_presenters';
import {
  DISABLED_ACTION_STYLE,
  ELLIPSIS_STYLE,
  getListRowStyle,
  LIST_SCROLL_STYLE,
  SUBTLE_PANEL_STYLE,
  TEXT_MUTED,
} from './theme';
import {
  getTrackDetailBadges,
  getTrackRowStyle,
  matchesTrackSearch,
  TrackTextBlock,
} from './track_presenters';
import { DraftPreset, DraftTier, DraftVariant } from './types';

type StructureSectionProps = Readonly<{
  draft: DraftPreset;
  selectedTier: DraftTier | null;
  selectedTierId: string | null;
  selectedVariant: DraftVariant | null;
  selectedVariantId: string | null;
  trackSearch: string;
  denseTracks: boolean;
  tracksExpanded: boolean;
  onAddTier: () => void;
  onSelectTier: (tier_id: string) => void;
  onMoveTierUp: (tier_id: string) => void;
  onMoveTierDown: (tier_id: string) => void;
  onAddVariant: () => void;
  onTrackSearchChange: (value: string) => void;
  onToggleDenseTracks: () => void;
  onToggleTracksExpanded: () => void;
  onSelectVariant: (tier_id: string, variant_id: string) => void;
  onMoveVariantUp: (tier_id: string, variant_id: string) => void;
  onMoveVariantDown: (tier_id: string, variant_id: string) => void;
}>;

type EditTrackActionButtonsProps = Readonly<{
  selectedTier: DraftTier | null;
  selectedVariant: DraftVariant | null;
  canMoveTrackUp: boolean;
  canMoveTrackDown: boolean;
  tracksExpanded: boolean;
  onMoveVariantUp: (tier_id: string, variant_id: string) => void;
  onMoveVariantDown: (tier_id: string, variant_id: string) => void;
  onToggleTracksExpanded: () => void;
  onAddVariant: () => void;
}>;

function EditTrackActionButtons({
  selectedTier,
  selectedVariant,
  canMoveTrackUp,
  canMoveTrackDown,
  tracksExpanded,
  onMoveVariantUp,
  onMoveVariantDown,
  onToggleTracksExpanded,
  onAddVariant,
}: EditTrackActionButtonsProps) {
  return (
    <Flex wrap justify="flex-end" style={RESPONSIVE_ACTION_GROUP_STYLE}>
      {selectedTier && selectedVariant ? (
        <>
          <Flex.Item>
            <Button
              compact
              icon="arrow-up"
              color="transparent"
              disabled={!canMoveTrackUp}
              style={{
                ...STRUCTURE_ACTION_BUTTON_STYLE,
                ...(!canMoveTrackUp ? DISABLED_ACTION_STYLE : {}),
              }}
              onClick={() =>
                onMoveVariantUp(
                  selectedTier.tier_id,
                  selectedVariant.variant_id,
                )
              }
            >
              Up
            </Button>
          </Flex.Item>
          <Flex.Item>
            <Button
              compact
              icon="arrow-down"
              color="transparent"
              disabled={!canMoveTrackDown}
              style={{
                ...STRUCTURE_ACTION_BUTTON_STYLE,
                ...(!canMoveTrackDown ? DISABLED_ACTION_STYLE : {}),
              }}
              onClick={() =>
                onMoveVariantDown(
                  selectedTier.tier_id,
                  selectedVariant.variant_id,
                )
              }
            >
              Down
            </Button>
          </Flex.Item>
        </>
      ) : null}
      <Flex.Item>
        <Button.Checkbox
          compact
          checked={tracksExpanded}
          icon="list"
          style={{
            ...STRUCTURE_ACTION_BUTTON_STYLE,
            ...getCompactToggleStyle(tracksExpanded),
          }}
          onClick={onToggleTracksExpanded}
        >
          Track Details
        </Button.Checkbox>
      </Flex.Item>
      <Flex.Item>
        <Button
          compact
          icon="plus"
          disabled={!selectedTier}
          style={{
            ...STRUCTURE_ACTION_BUTTON_STYLE,
            ...(!selectedTier ? DISABLED_ACTION_STYLE : {}),
          }}
          onClick={onAddVariant}
        >
          Add Track
        </Button>
      </Flex.Item>
    </Flex>
  );
}

type EditTrackSearchToolbarProps = Readonly<{
  trackSearch: string;
  denseTracks: boolean;
  onTrackSearchChange: (value: string) => void;
  onToggleDenseTracks: () => void;
}>;

function EditTrackSearchToolbar({
  trackSearch,
  denseTracks,
  onTrackSearchChange,
  onToggleDenseTracks,
}: EditTrackSearchToolbarProps) {
  return (
    <Box mt="0.2rem">
      <Stack fill>
        <Stack.Item grow>
          <Input
            fluid
            placeholder="Search tracks..."
            value={trackSearch}
            onInput={(e, value) => onTrackSearchChange(value)}
          />
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            compact
            checked={denseTracks}
            style={getCompactToggleStyle(denseTracks)}
            onClick={onToggleDenseTracks}
          >
            Dense
          </Button.Checkbox>
        </Stack.Item>
      </Stack>
    </Box>
  );
}

export function StructureSection({
  draft,
  selectedTier,
  selectedTierId,
  selectedVariant,
  selectedVariantId,
  trackSearch,
  denseTracks,
  tracksExpanded,
  onAddTier,
  onSelectTier,
  onMoveTierUp,
  onMoveTierDown,
  onAddVariant,
  onTrackSearchChange,
  onToggleDenseTracks,
  onToggleTracksExpanded,
  onSelectVariant,
  onMoveVariantUp,
  onMoveVariantDown,
}: StructureSectionProps) {
  const selectedTierIndex = selectedTier
    ? draft.tiers.findIndex((tier) => tier.tier_id === selectedTier.tier_id)
    : -1;
  const canMoveSceneUp = selectedTierIndex > 0;
  const canMoveSceneDown =
    selectedTierIndex >= 0 && selectedTierIndex < draft.tiers.length - 1;
  const selectedVariantIndex =
    selectedTier && selectedVariant
      ? selectedTier.variants.findIndex(
          (variant) => variant.variant_id === selectedVariant.variant_id,
        )
      : -1;
  const canMoveTrackUp = selectedVariantIndex > 0;
  const canMoveTrackDown =
    selectedVariantIndex >= 0 &&
    selectedTier !== null &&
    selectedVariantIndex < selectedTier.variants.length - 1;
  const filteredVariants =
    selectedTier?.variants
      .map((variant, index) => ({ variant, index }))
      .filter(({ variant }) => matchesTrackSearch(variant, trackSearch)) || [];

  return (
    <Section fill title="Structure" style={SECTION_SURFACE_STYLE}>
      <Stack fill>
        <Stack.Item basis="30%" grow={3} style={{ minWidth: '0' }}>
          <Box style={{ ...SUBTLE_PANEL_STYLE, height: '100%' }}>
            <Stack fill vertical>
              <Stack.Item>
                <Flex
                  align="flex-start"
                  justify="space-between"
                  wrap
                  width="100%"
                  style={RESPONSIVE_HEADER_ROW_STYLE}
                >
                  <Flex.Item grow basis="10rem" style={{ minWidth: '0' }}>
                    <Box bold>Scenes</Box>
                  </Flex.Item>
                  <Flex.Item style={{ minWidth: '0', flex: '0 0 auto' }}>
                    <Flex
                      wrap
                      justify="flex-end"
                      style={RESPONSIVE_ACTION_GROUP_STYLE}
                    >
                      {selectedTier ? (
                        <>
                          <Flex.Item>
                            <Button
                              compact
                              icon="arrow-up"
                              color="transparent"
                              disabled={!canMoveSceneUp}
                              style={
                                !canMoveSceneUp
                                  ? DISABLED_ACTION_STYLE
                                  : undefined
                              }
                              onClick={() => onMoveTierUp(selectedTier.tier_id)}
                            >
                              Up
                            </Button>
                          </Flex.Item>
                          <Flex.Item>
                            <Button
                              compact
                              icon="arrow-down"
                              color="transparent"
                              disabled={!canMoveSceneDown}
                              style={
                                !canMoveSceneDown
                                  ? DISABLED_ACTION_STYLE
                                  : undefined
                              }
                              onClick={() =>
                                onMoveTierDown(selectedTier.tier_id)
                              }
                            >
                              Down
                            </Button>
                          </Flex.Item>
                        </>
                      ) : null}
                      <Flex.Item>
                        <Button compact icon="plus" onClick={onAddTier}>
                          Add Scene
                        </Button>
                      </Flex.Item>
                    </Flex>
                  </Flex.Item>
                </Flex>
              </Stack.Item>
              <Stack.Item grow={1}>
                <Box mt="0.35rem" style={LIST_SCROLL_STYLE}>
                  {draft.tiers.length === 0 ? (
                    <Box color="label">No scenes yet.</Box>
                  ) : (
                    draft.tiers.map((tier, index) => (
                      <Button
                        key={tier.tier_id}
                        compact
                        fluid
                        color="transparent"
                        onClick={() => onSelectTier(tier.tier_id)}
                        style={getListRowStyle(selectedTierId === tier.tier_id)}
                      >
                        <Flex
                          align="center"
                          justify="space-between"
                          width="100%"
                        >
                          <Flex.Item grow>
                            <Flex align="center">
                              <Flex.Item mr={1}>
                                <Box color="label" fontSize="0.75rem">
                                  {index + 1}.
                                </Box>
                              </Flex.Item>
                              <Flex.Item grow>
                                <Box bold style={ELLIPSIS_STYLE}>
                                  {tier.name || 'Unnamed scene'}
                                </Box>
                              </Flex.Item>
                            </Flex>
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
            </Stack>
          </Box>
        </Stack.Item>
        <Stack.Item basis="70%" grow={7} style={{ minWidth: '0' }}>
          <Box style={{ ...SUBTLE_PANEL_STYLE, height: '100%' }}>
            <Stack fill vertical>
              <Stack.Item>
                <Stack fill vertical>
                  <Stack.Item>
                    <Flex
                      align="flex-start"
                      justify="space-between"
                      wrap
                      width="100%"
                      style={RESPONSIVE_HEADER_ROW_STYLE}
                    >
                      <Flex.Item grow basis="14rem" style={{ minWidth: '0' }}>
                        <Box bold>Tracks</Box>
                        <Box
                          color="label"
                          fontSize="0.74rem"
                          style={ELLIPSIS_STYLE}
                        >
                          {selectedTier
                            ? `Tracks in ${selectedTier.name || 'selected scene'}.`
                            : 'Select a scene to manage its tracks.'}
                        </Box>
                        <Box color={TEXT_MUTED} fontSize="0.7rem" mt="0.06rem">
                          {tracksExpanded
                            ? 'Track Details shows source and status chips.'
                            : 'Dense keeps descriptions on one compact line. Track Details shows source and status chips.'}
                        </Box>
                      </Flex.Item>
                      <Flex.Item style={{ minWidth: '0', flex: '0 0 auto' }}>
                        <EditTrackActionButtons
                          selectedTier={selectedTier}
                          selectedVariant={selectedVariant}
                          canMoveTrackUp={canMoveTrackUp}
                          canMoveTrackDown={canMoveTrackDown}
                          tracksExpanded={tracksExpanded}
                          onMoveVariantUp={onMoveVariantUp}
                          onMoveVariantDown={onMoveVariantDown}
                          onToggleTracksExpanded={onToggleTracksExpanded}
                          onAddVariant={onAddVariant}
                        />
                      </Flex.Item>
                    </Flex>
                  </Stack.Item>
                  <Stack.Item>
                    <EditTrackSearchToolbar
                      trackSearch={trackSearch}
                      denseTracks={denseTracks}
                      onTrackSearchChange={onTrackSearchChange}
                      onToggleDenseTracks={onToggleDenseTracks}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item grow={1}>
                <Box mt="0.35rem" style={TRACK_LIST_SCROLL_STYLE}>
                  {!selectedTier ? (
                    <Box color="label">No scene selected yet.</Box>
                  ) : selectedTier.variants.length === 0 ? (
                    <Box color="label">No tracks in this scene yet.</Box>
                  ) : filteredVariants.length === 0 ? (
                    <Box color="label">No tracks match search.</Box>
                  ) : (
                    filteredVariants.map(({ variant, index }) => {
                      const trackDescription = variant.description.trim();
                      const detailBadges = tracksExpanded
                        ? getTrackDetailBadges(variant)
                        : [];

                      return (
                        <Button
                          key={variant.variant_id}
                          compact
                          fluid
                          color="transparent"
                          onClick={() =>
                            onSelectVariant(
                              selectedTier.tier_id,
                              variant.variant_id,
                            )
                          }
                          style={getTrackRowStyle(
                            selectedVariantId === variant.variant_id,
                            denseTracks,
                            false,
                          )}
                        >
                          <Box style={FULL_WIDTH_CLAMP_STYLE}>
                            <Flex
                              align="center"
                              justify="space-between"
                              width="100%"
                              style={{ minWidth: '0' }}
                            >
                              <Flex.Item
                                grow
                                basis={0}
                                shrink={1}
                                style={TRACK_ROW_LEFT_STYLE}
                              >
                                <Flex
                                  align="center"
                                  width="100%"
                                  style={{ minWidth: '0' }}
                                >
                                  <Flex.Item mr={1}>
                                    <Box color="label" fontSize="0.75rem">
                                      {index + 1}.
                                    </Box>
                                  </Flex.Item>
                                  <Flex.Item
                                    grow
                                    basis={0}
                                    shrink={1}
                                    style={TRACK_ROW_LEFT_STYLE}
                                  >
                                    <TrackTextBlock
                                      title={variant.title || 'Unnamed track'}
                                      description={trackDescription}
                                      dense={denseTracks}
                                    />
                                    {detailBadges.length ? (
                                      <Box mt="0.1rem">
                                        {detailBadges.map((badge) => (
                                          <Box
                                            key={badge.label}
                                            style={badge.style}
                                          >
                                            {badge.label}
                                          </Box>
                                        ))}
                                      </Box>
                                    ) : null}
                                  </Flex.Item>
                                </Flex>
                              </Flex.Item>
                              <Flex.Item ml={1} shrink={0} width="3.6rem">
                                <Box
                                  fontSize="0.75rem"
                                  color="label"
                                  textAlign="right"
                                >
                                  {formatDurationCompact(
                                    variant.duration_seconds,
                                  )}
                                </Box>
                              </Flex.Item>
                            </Flex>
                          </Box>
                        </Button>
                      );
                    })
                  )}
                </Box>
              </Stack.Item>
            </Stack>
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

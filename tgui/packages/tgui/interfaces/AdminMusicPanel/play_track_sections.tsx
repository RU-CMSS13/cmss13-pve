import { useRef } from 'react';

import { Box, Button, Flex, Input, Section, Stack } from '../../components';
import {
  FULL_WIDTH_CLAMP_STYLE,
  SECTION_SURFACE_STYLE,
  TRACK_LIST_SCROLL_STYLE,
  TRACK_ROW_LEFT_STYLE,
  TRACKS_FILTER_BAR_STYLE,
} from './component_styles';
import {
  findCurrentSessionVariantInTier,
  formatDurationCompact,
  formatTrackCount,
  isCurrentSessionForVariant,
  isVariantDurationUnknown,
  isVariantMissingSource,
} from './helpers';
import { getCompactToggleStyle } from './playback_presenters';
import { DISABLED_ACTION_STYLE, ELLIPSIS_STYLE } from './theme';
import {
  getTrackRowStyle,
  getVariantListBadges,
  matchesTrackSearch,
  TrackTextBlock,
} from './track_presenters';
import { CurrentSession, DraftPreset, DraftTier } from './types';

type PlayTracksSectionProps = Readonly<{
  draft: DraftPreset;
  current_session: CurrentSession;
  selectedTier: DraftTier | null;
  selectedVariantId: string | null;
  trackSearch: string;
  denseTracks: boolean;
  showOnlyInvalid?: boolean;
  showOnlyUnknown?: boolean;
  focusMode?: boolean;
  onTrackSearchChange: (value: string) => void;
  onToggleDenseTracks: () => void;
  onToggleOnlyInvalid?: () => void;
  onToggleOnlyUnknown?: () => void;
  onToggleTracksFocus?: () => void;
  onSelectVariant: (tier_id: string, variant_id: string) => void;
}>;

export function PlayTracksSection({
  draft,
  current_session,
  selectedTier,
  selectedVariantId,
  trackSearch,
  denseTracks,
  showOnlyInvalid = false,
  showOnlyUnknown = false,
  focusMode = false,
  onTrackSearchChange,
  onToggleDenseTracks,
  onToggleOnlyInvalid,
  onToggleOnlyUnknown,
  onToggleTracksFocus,
  onSelectVariant,
}: PlayTracksSectionProps) {
  const rowRefs = useRef<Record<string, HTMLDivElement | null>>({});
  const liveVariant = findCurrentSessionVariantInTier(
    current_session,
    draft,
    selectedTier,
  );
  const filteredVariants =
    selectedTier?.variants
      .map((variant, index) => ({ variant, index }))
      .filter(({ variant }) => {
        if (!matchesTrackSearch(variant, trackSearch)) {
          return false;
        }
        if (showOnlyInvalid && !isVariantMissingSource(variant)) {
          return false;
        }
        if (showOnlyUnknown && !isVariantDurationUnknown(variant)) {
          return false;
        }
        return true;
      }) || [];
  const canJumpToSelected =
    Boolean(selectedVariantId) &&
    filteredVariants.some(
      ({ variant }) => variant.variant_id === selectedVariantId,
    );
  const canJumpToLive =
    Boolean(liveVariant) &&
    filteredVariants.some(
      ({ variant }) => variant.variant_id === liveVariant?.variant_id,
    );

  const scrollToVariant = (variantId: string | null) => {
    if (!variantId) {
      return;
    }
    rowRefs.current[variantId]?.scrollIntoView({
      block: 'center',
      behavior: 'smooth',
    });
  };

  return (
    <Section
      fill
      title={focusMode ? 'Tracks Focus' : 'Tracks'}
      style={SECTION_SURFACE_STYLE}
      buttons={
        onToggleTracksFocus ? (
          <Button
            compact
            icon={focusMode ? 'compress' : 'expand'}
            color="transparent"
            disabled={!selectedTier?.variants.length}
            style={
              !selectedTier?.variants.length ? DISABLED_ACTION_STYLE : undefined
            }
            onClick={onToggleTracksFocus}
          >
            {focusMode ? 'Exit Focus' : 'Focus Tracks'}
          </Button>
        ) : undefined
      }
    >
      {!selectedTier ? (
        <Box color="label">Select a scene to browse its tracks.</Box>
      ) : (
        <Stack fill vertical>
          <Stack.Item>
            <Box style={TRACKS_FILTER_BAR_STYLE}>
              <Stack fill vertical>
                <Stack.Item>
                  <Flex align="center" justify="space-between" width="100%">
                    <Flex.Item grow>
                      <Box bold style={ELLIPSIS_STYLE}>
                        {selectedTier.name || 'Unnamed scene'}
                      </Box>
                    </Flex.Item>
                    <Flex.Item ml={1}>
                      <Box color="label" fontSize="0.75rem">
                        {formatTrackCount(selectedTier.variants.length)}
                      </Box>
                    </Flex.Item>
                  </Flex>
                </Stack.Item>
                <Stack.Item>
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
                        <Button
                          compact
                          color="transparent"
                          disabled={!canJumpToSelected}
                          style={
                            !canJumpToSelected
                              ? DISABLED_ACTION_STYLE
                              : undefined
                          }
                          onClick={() => scrollToVariant(selectedVariantId)}
                        >
                          Jump to selected
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          compact
                          color="transparent"
                          disabled={!canJumpToLive}
                          style={
                            !canJumpToLive ? DISABLED_ACTION_STYLE : undefined
                          }
                          onClick={() =>
                            scrollToVariant(liveVariant?.variant_id || null)
                          }
                        >
                          Jump to live
                        </Button>
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
                      {focusMode && onToggleOnlyInvalid ? (
                        <Stack.Item>
                          <Button.Checkbox
                            compact
                            checked={showOnlyInvalid}
                            style={getCompactToggleStyle(showOnlyInvalid)}
                            onClick={onToggleOnlyInvalid}
                          >
                            Only invalid
                          </Button.Checkbox>
                        </Stack.Item>
                      ) : null}
                      {focusMode && onToggleOnlyUnknown ? (
                        <Stack.Item>
                          <Button.Checkbox
                            compact
                            checked={showOnlyUnknown}
                            style={getCompactToggleStyle(showOnlyUnknown)}
                            onClick={onToggleOnlyUnknown}
                          >
                            Only unknown
                          </Button.Checkbox>
                        </Stack.Item>
                      ) : null}
                    </Stack>
                  </Box>
                </Stack.Item>
              </Stack>
            </Box>
          </Stack.Item>
          <Stack.Item grow>
            <Box style={TRACK_LIST_SCROLL_STYLE}>
              {selectedTier.variants.length === 0 ? (
                <Box color="label">No tracks in this scene.</Box>
              ) : filteredVariants.length === 0 ? (
                <Box color="label">No tracks match the current filters.</Box>
              ) : (
                filteredVariants.map(({ variant, index }) => {
                  const isLive = isCurrentSessionForVariant(
                    current_session,
                    draft,
                    selectedTier,
                    variant,
                  );
                  const trackDescription = variant.description.trim();

                  return (
                    <div
                      key={variant.variant_id}
                      ref={(node) => {
                        rowRefs.current[variant.variant_id] = node;
                      }}
                    >
                      <Button
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
                          isLive,
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
                                <Flex.Item mr={denseTracks ? 0.6 : 0.9}>
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
                                  {getVariantListBadges(variant, isLive)
                                    .length ? (
                                    <Box mt="0.08rem">
                                      {getVariantListBadges(
                                        variant,
                                        isLive,
                                      ).map((badge) => (
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
                    </div>
                  );
                })
              )}
            </Box>
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
}

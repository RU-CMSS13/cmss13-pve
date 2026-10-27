import { Box, Button, Flex, Input, Section, Stack } from '../../components';
import { SECTION_SURFACE_STYLE } from './component_styles';
import { formatTrackCount } from './helpers';
import {
  ELLIPSIS_STYLE,
  getListRowStyle,
  LIST_SCROLL_STYLE,
  MUTED_BADGE_STYLE,
  UNSAVED_BADGE_STYLE,
} from './theme';
import { getLibraryRowStyle } from './track_presenters';
import { DraftPreset, LibraryPreset } from './types';

type LibrarySectionProps = Readonly<{
  library: LibraryPreset[];
  librarySearch: string;
  loadedLibraryPresetId: string | null;
  onSearchChange: (value: string) => void;
  onLoadPreset: (preset_id: string) => void;
  onOpenEdit: () => void;
  dirty: boolean;
}>;

export function LibrarySection({
  library,
  librarySearch,
  loadedLibraryPresetId,
  onSearchChange,
  onLoadPreset,
  onOpenEdit,
  dirty,
}: LibrarySectionProps) {
  const filteredLibrary = library.filter((preset) => {
    const haystack =
      `${preset.name} ${preset.description} ${preset.preset_id}`.toLowerCase();
    return haystack.includes(librarySearch.toLowerCase());
  });
  const hasSavedPresets = library.length > 0;

  return (
    <Section fill title="Preset Library" style={SECTION_SURFACE_STYLE}>
      <Stack fill vertical>
        <Stack.Item>
          <Input
            fluid
            placeholder="Search presets..."
            value={librarySearch}
            onInput={(e, value) => onSearchChange(value)}
          />
        </Stack.Item>
        <Stack.Item grow={1}>
          <Box style={LIST_SCROLL_STYLE}>
            {filteredLibrary.length === 0 ? (
              hasSavedPresets ? (
                <Box color="label">No presets match search.</Box>
              ) : (
                <Stack vertical>
                  <Stack.Item>
                    <Box color="label">
                      No saved presets yet. You are working in a new draft.
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
                  onClick={() => onLoadPreset(preset.preset_id)}
                  style={getLibraryRowStyle(
                    loadedLibraryPresetId === preset.preset_id,
                  )}
                >
                  <Flex align="center" justify="space-between" width="100%">
                    <Flex.Item grow>
                      <Box bold fontSize="0.92rem" style={ELLIPSIS_STYLE}>
                        {preset.name || 'Unnamed preset'}
                      </Box>
                    </Flex.Item>
                    <Flex.Item ml={1}>
                      <Flex align="center">
                        {loadedLibraryPresetId === preset.preset_id ? (
                          <Flex.Item mr={0.5}>
                            <Box
                              style={
                                dirty ? UNSAVED_BADGE_STYLE : MUTED_BADGE_STYLE
                              }
                            >
                              {dirty ? 'Loaded + edits' : 'Loaded'}
                            </Box>
                          </Flex.Item>
                        ) : null}
                        <Flex.Item>
                          <Box
                            fontSize="0.75rem"
                            color="label"
                            style={ELLIPSIS_STYLE}
                          >
                            {preset.tier_count} scenes | {preset.variant_count}{' '}
                            tracks
                          </Box>
                        </Flex.Item>
                      </Flex>
                    </Flex.Item>
                  </Flex>
                </Button>
              ))
            )}
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

type PlayScenesSectionProps = Readonly<{
  draft: DraftPreset;
  selectedTierId: string | null;
  onSelectTier: (tier_id: string) => void;
}>;

export function PlayScenesSection({
  draft,
  selectedTierId,
  onSelectTier,
}: PlayScenesSectionProps) {
  return (
    <Section fill scrollable title="Scenes" style={SECTION_SURFACE_STYLE}>
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

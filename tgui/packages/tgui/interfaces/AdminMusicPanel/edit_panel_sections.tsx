import { useEffect, useRef, useState } from 'react';

import {
  Box,
  Button,
  Collapsible,
  LabeledList,
  Section,
  Stack,
} from '../../components';
import { BufferedInput, BufferedTextArea } from './buffered_inputs';
import {
  ADVANCED_TOGGLE_STYLE,
  EDIT_FIELD_WRAPPER_STYLE,
  EDIT_PANEL_CARD_HEADING_STYLE,
  EDIT_PANEL_CARD_STYLE,
  HEADER_ACTION_BUTTON_STYLE,
  SECTION_SURFACE_STYLE,
} from './component_styles';
import {
  InspectorTarget,
  SelectedItemSection,
} from './edit_inspector_sections';
import { countTracks } from './helpers';
import {
  getDraftStatusBadgeStyle,
  PlaybackSettingsControls,
} from './playback_presenters';
import {
  BORDER,
  DISABLED_ACTION_STYLE,
  ELLIPSIS_STYLE as SHARED_ELLIPSIS_STYLE,
  MUTED_BADGE_STYLE,
  PLAYER_BADGE_STYLE,
  PLAYER_CARD_STYLE,
  STATUS_STRIP_STYLE,
} from './theme';
import {
  DraftPreset,
  DraftStatus,
  DraftTier,
  DraftVariant,
  SelectOption,
} from './types';

type EditHeaderSectionProps = Readonly<{
  draft: DraftPreset;
  draftStatus: DraftStatus;
  canRevert: boolean;
  onEditPreset: () => void;
  onSave: () => void;
  onSaveAsCopy: () => void;
  onRevert: () => void;
}>;

export function EditHeaderSection({
  draft,
  draftStatus,
  canRevert,
  onEditPreset,
  onSave,
  onSaveAsCopy,
  onRevert,
}: EditHeaderSectionProps) {
  const statusBadges: Array<{ label: string; style: Record<string, string> }> =
    [
      {
        label: `ID ${draft.preset_id || 'new'}`,
        style: PLAYER_BADGE_STYLE,
      },
      ...(draft.preset_id
        ? [
            {
              label: 'Loaded preset',
              style: MUTED_BADGE_STYLE,
            },
          ]
        : []),
      {
        label: draftStatus.label,
        style: getDraftStatusBadgeStyle(draftStatus.kind),
      },
    ];

  return (
    <Box
      px={0.9}
      py={0.42}
      style={{
        ...STATUS_STRIP_STYLE,
        border: `1px solid ${BORDER}`,
      }}
    >
      <Stack align="center">
        <Stack.Item basis="70%" grow>
          <Box bold fontSize="1.02rem" style={SHARED_ELLIPSIS_STYLE}>
            {draft.name || 'New preset'}
          </Box>
          <Box color="label" fontSize="0.75rem" mt="0.12rem">
            {draftStatus.hint}
          </Box>
          <Box mt="0.22rem">
            {statusBadges.map((badge) => (
              <Box key={badge.label} mr={0.35} mb={0.2} style={badge.style}>
                {badge.label}
              </Box>
            ))}
          </Box>
        </Stack.Item>
        <Stack.Item basis="30%">
          <Stack>
            <Stack.Item>
              <Button
                icon="edit"
                color="transparent"
                style={HEADER_ACTION_BUTTON_STYLE}
                onClick={onEditPreset}
              >
                Edit Preset
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="save"
                color="good"
                style={HEADER_ACTION_BUTTON_STYLE}
                onClick={onSave}
              >
                Save
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="copy"
                style={HEADER_ACTION_BUTTON_STYLE}
                onClick={onSaveAsCopy}
              >
                Save As
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="undo"
                color="transparent"
                disabled={!canRevert}
                style={{
                  ...HEADER_ACTION_BUTTON_STYLE,
                  ...(!canRevert ? DISABLED_ACTION_STYLE : {}),
                }}
                onClick={onRevert}
              >
                Revert
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Box>
  );
}

type EditPanelSectionProps = Readonly<{
  draft: DraftPreset;
  draftToken: number;
  presetEditorRequest: number;
  audienceOptions: SelectOption[];
  soundTypeOptions: SelectOption[];
  audienceLabel: string;
  soundTypeLabel: string;
  inspectorTarget: InspectorTarget;
  selectedTier: DraftTier | null;
  selectedVariant: DraftVariant | null;
  canDelete: boolean;
  onNew: () => void;
  onDelete: () => void;
  onExport: () => void;
  onImport: (jsonText: string | string[]) => void;
  onSetName: (value: string) => void;
  onSetDescription: (value: string) => void;
  onSetAudienceMode: (value: string) => void;
  onSetSoundType: (value: string) => void;
  onToggleShowTitle: () => void;
  onToggleRepeat: () => void;
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

export function EditPanelSection({
  draft,
  draftToken,
  presetEditorRequest,
  audienceOptions,
  soundTypeOptions,
  audienceLabel,
  soundTypeLabel,
  inspectorTarget,
  selectedTier,
  selectedVariant,
  canDelete,
  onNew,
  onDelete,
  onExport,
  onImport,
  onSetName,
  onSetDescription,
  onSetAudienceMode,
  onSetSoundType,
  onToggleShowTitle,
  onToggleRepeat,
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
}: EditPanelSectionProps) {
  const [showPresetEditor, setShowPresetEditor] = useState(false);
  const presetEditorRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    setShowPresetEditor(false);
  }, [draftToken]);

  useEffect(() => {
    if (!presetEditorRequest) {
      return;
    }
    setShowPresetEditor(true);
    window.requestAnimationFrame(() => {
      presetEditorRef.current?.scrollIntoView({
        block: 'start',
        behavior: 'smooth',
      });
    });
  }, [presetEditorRequest]);

  return (
    <Section fill title="Edit Panel" style={SECTION_SURFACE_STYLE}>
      <Stack fill vertical>
        <Stack.Item grow={1}>
          <SelectedItemSection
            inspectorTarget={inspectorTarget}
            draft={draft}
            selectedTier={selectedTier}
            selectedVariant={selectedVariant}
            onRemoveTier={onRemoveTier}
            onMoveTierUp={onMoveTierUp}
            onMoveTierDown={onMoveTierDown}
            onSetTierName={onSetTierName}
            onSetTierDescription={onSetTierDescription}
            onRemoveVariant={onRemoveVariant}
            onMoveVariantUp={onMoveVariantUp}
            onMoveVariantDown={onMoveVariantDown}
            onSetVariantTitle={onSetVariantTitle}
            onSetVariantDescription={onSetVariantDescription}
            onSetVariantDuration={onSetVariantDuration}
            onSetVariantSourceUrl={onSetVariantSourceUrl}
            onResolveVariantMetadata={onResolveVariantMetadata}
          />
        </Stack.Item>
        <Stack.Item>
          <div ref={presetEditorRef}>
            <Box style={EDIT_PANEL_CARD_STYLE}>
              <Button
                fluid
                color="transparent"
                icon={showPresetEditor ? 'chevron-down' : 'chevron-right'}
                style={ADVANCED_TOGGLE_STYLE}
                onClick={() => setShowPresetEditor((current) => !current)}
              >
                Preset Settings
              </Button>
              {showPresetEditor ? (
                <Box mt={1}>
                  <PresetMetaSection
                    draft={draft}
                    draftToken={draftToken}
                    audienceOptions={audienceOptions}
                    soundTypeOptions={soundTypeOptions}
                    audienceLabel={audienceLabel}
                    soundTypeLabel={soundTypeLabel}
                    onSetName={onSetName}
                    onSetDescription={onSetDescription}
                    onSetAudienceMode={onSetAudienceMode}
                    onSetSoundType={onSetSoundType}
                    onToggleShowTitle={onToggleShowTitle}
                    onToggleRepeat={onToggleRepeat}
                    embedded
                  />
                </Box>
              ) : null}
            </Box>
          </div>
        </Stack.Item>
        <Stack.Item>
          <AdvancedSection
            canDelete={canDelete}
            onNew={onNew}
            onDelete={onDelete}
            onExport={onExport}
            onImport={onImport}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}

type PresetMetaSectionProps = Readonly<{
  draft: DraftPreset;
  draftToken: number;
  audienceOptions: SelectOption[];
  soundTypeOptions: SelectOption[];
  audienceLabel: string;
  soundTypeLabel: string;
  onSetName: (value: string) => void;
  onSetDescription: (value: string) => void;
  onSetAudienceMode: (value: string) => void;
  onSetSoundType: (value: string) => void;
  onToggleShowTitle: () => void;
  onToggleRepeat: () => void;
  embedded?: boolean;
}>;

function PresetMetaSection({
  draft,
  draftToken,
  audienceOptions,
  soundTypeOptions,
  audienceLabel,
  soundTypeLabel,
  onSetName,
  onSetDescription,
  onSetAudienceMode,
  onSetSoundType,
  onToggleShowTitle,
  onToggleRepeat,
  embedded = false,
}: PresetMetaSectionProps) {
  const content = (
    <Stack fill vertical>
      <Stack.Item>
        <Box style={PLAYER_CARD_STYLE}>
          <Box bold fontSize="1rem" style={SHARED_ELLIPSIS_STYLE}>
            {draft.name || 'New preset'}
          </Box>
          <Box mt="0.3rem">
            <Box style={PLAYER_BADGE_STYLE}>ID {draft.preset_id || 'new'}</Box>
            <Box style={PLAYER_BADGE_STYLE}>Scenes {draft.tiers.length}</Box>
            <Box style={PLAYER_BADGE_STYLE}>Tracks {countTracks(draft)}</Box>
          </Box>
        </Box>
      </Stack.Item>
      <Stack.Item>
        <LabeledList key={draftToken}>
          <LabeledList.Item label="Name">
            <Box style={EDIT_FIELD_WRAPPER_STYLE}>
              <BufferedInput
                syncKey={`preset-name:${draftToken}`}
                value={draft.name}
                onCommit={onSetName}
                placeholder="Preset name"
              />
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Description" verticalAlign="top">
            <Box style={EDIT_FIELD_WRAPPER_STYLE}>
              <BufferedTextArea
                syncKey={draftToken}
                value={draft.description}
                onCommit={onSetDescription}
                placeholder="Short description for admins"
                minRows={3}
                maxRows={6}
              />
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      <Stack.Item grow={1}>
        <Box style={PLAYER_CARD_STYLE}>
          <Box bold>Preset Defaults</Box>
          <PlaybackSettingsControls
            playback={draft.playback}
            audienceOptions={audienceOptions}
            soundTypeOptions={soundTypeOptions}
            audienceLabel={audienceLabel}
            soundTypeLabel={soundTypeLabel}
            onSetAudienceMode={onSetAudienceMode}
            onSetSoundType={onSetSoundType}
            onToggleShowTitle={onToggleShowTitle}
            onToggleRepeat={onToggleRepeat}
            wrapToggleRow
          />
        </Box>
      </Stack.Item>
    </Stack>
  );

  if (embedded) {
    return content;
  }

  return (
    <Box style={EDIT_PANEL_CARD_STYLE}>
      <Box bold style={EDIT_PANEL_CARD_HEADING_STYLE}>
        Preset Settings
      </Box>
      {content}
    </Box>
  );
}

type AdvancedSectionProps = Readonly<{
  canDelete: boolean;
  onNew: () => void;
  onDelete: () => void;
  onExport: () => void;
  onImport: (jsonText: string | string[]) => void;
}>;

function AdvancedSection({
  canDelete,
  onNew,
  onDelete,
  onExport,
  onImport,
}: AdvancedSectionProps) {
  return (
    <Box style={EDIT_PANEL_CARD_STYLE}>
      <Collapsible
        title="Advanced"
        icon="cog"
        color="transparent"
        style={ADVANCED_TOGGLE_STYLE}
      >
        <Stack vertical>
          <Stack.Item>
            <Button compact fluid icon="plus" onClick={onNew}>
              New Draft
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button.File
              compact
              fluid
              icon="upload"
              accept=".json,application/json"
              onSelectFiles={onImport}
            >
              Import JSON
            </Button.File>
          </Stack.Item>
          <Stack.Item>
            <Button compact fluid icon="download" onClick={onExport}>
              Export Preset
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              compact
              fluid
              icon="trash"
              color="bad"
              disabled={!canDelete}
              style={!canDelete ? DISABLED_ACTION_STYLE : undefined}
              onClick={onDelete}
            >
              Delete Preset
            </Button>
          </Stack.Item>
        </Stack>
      </Collapsible>
    </Box>
  );
}

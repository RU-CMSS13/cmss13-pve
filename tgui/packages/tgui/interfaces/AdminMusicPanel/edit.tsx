import { useEffect, useState } from 'react';

import { Box, Stack } from '../../components';
import {
  EditHeaderSection,
  EditPanelSection,
  StructureSection,
} from './edit_sections';
import {
  DraftPreset,
  DraftStatus,
  DraftTier,
  DraftVariant,
  SelectOption,
} from './types';

type EditTabProps = Readonly<{
  draft: DraftPreset;
  draftStatus: DraftStatus;
  draftToken: number;
  canDelete: boolean;
  canRevert: boolean;
  audienceOptions: SelectOption[];
  soundTypeOptions: SelectOption[];
  audienceLabel: string;
  soundTypeLabel: string;
  selectedTier: DraftTier | null;
  selectedTierId: string | null;
  selectedVariant: DraftVariant | null;
  selectedVariantId: string | null;
  onSave: () => void;
  onNew: () => void;
  onSaveAsCopy: () => void;
  onRevert: () => void;
  onDelete: () => void;
  onExport: () => void;
  onImport: (jsonText: string | string[]) => void;
  onSetName: (value: string) => void;
  onSetDescription: (value: string) => void;
  onSetAudienceMode: (value: string) => void;
  onSetSoundType: (value: string) => void;
  onToggleShowTitle: () => void;
  onToggleRepeat: () => void;
  onAddTier: () => void;
  onSelectTier: (tier_id: string) => void;
  onRemoveTier: (tier_id: string) => void;
  onMoveTierUp: (tier_id: string) => void;
  onMoveTierDown: (tier_id: string) => void;
  onSetTierName: (tier_id: string, value: string) => void;
  onSetTierDescription: (tier_id: string, value: string) => void;
  onAddVariant: () => void;
  onSelectVariant: (tier_id: string, variant_id: string) => void;
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

type InspectorTarget = 'scene' | 'track';

export function EditTab({
  draft,
  draftStatus,
  draftToken,
  canDelete,
  canRevert,
  audienceOptions,
  soundTypeOptions,
  audienceLabel,
  soundTypeLabel,
  selectedTier,
  selectedTierId,
  selectedVariant,
  selectedVariantId,
  onSave,
  onNew,
  onSaveAsCopy,
  onRevert,
  onDelete,
  onExport,
  onImport,
  onSetName,
  onSetDescription,
  onSetAudienceMode,
  onSetSoundType,
  onToggleShowTitle,
  onToggleRepeat,
  onAddTier,
  onSelectTier,
  onRemoveTier,
  onMoveTierUp,
  onMoveTierDown,
  onSetTierName,
  onSetTierDescription,
  onAddVariant,
  onSelectVariant,
  onRemoveVariant,
  onMoveVariantUp,
  onMoveVariantDown,
  onSetVariantTitle,
  onSetVariantDescription,
  onSetVariantDuration,
  onSetVariantSourceUrl,
  onResolveVariantMetadata,
}: EditTabProps) {
  const [inspectorTarget, setInspectorTarget] = useState<InspectorTarget>(
    selectedVariant ? 'track' : 'scene',
  );
  const [trackSearch, setTrackSearch] = useState('');
  const [denseTracks, setDenseTracks] = useState(false);
  const [tracksExpanded, setTracksExpanded] = useState(false);
  const [presetEditorRequest, setPresetEditorRequest] = useState(0);

  useEffect(() => {
    setInspectorTarget(selectedVariant ? 'track' : 'scene');
    setTrackSearch('');
    setDenseTracks(false);
    setTracksExpanded(false);
  }, [draftToken]);

  useEffect(() => {
    if (inspectorTarget === 'track' && !selectedVariant) {
      setInspectorTarget('scene');
    }
  }, [inspectorTarget, selectedVariant]);

  const handleSelectTier = (tierId: string) => {
    setInspectorTarget('scene');
    onSelectTier(tierId);
  };

  const handleAddTier = () => {
    setInspectorTarget('scene');
    onAddTier();
  };

  const handleSelectVariant = (tierId: string, variantId: string) => {
    setInspectorTarget('track');
    onSelectVariant(tierId, variantId);
  };

  const handleAddVariant = () => {
    setInspectorTarget('track');
    onAddVariant();
  };

  return (
    <Stack fill vertical>
      <Stack.Item>
        <EditHeaderSection
          draft={draft}
          draftStatus={draftStatus}
          canRevert={canRevert}
          onEditPreset={() => setPresetEditorRequest((current) => current + 1)}
          onSave={onSave}
          onSaveAsCopy={onSaveAsCopy}
          onRevert={onRevert}
        />
      </Stack.Item>
      <Stack.Item grow={1}>
        <Box mt="0.38rem" style={{ height: '100%' }}>
          <Stack fill>
            <Stack.Item basis="68%" grow={7} style={{ minWidth: '0' }}>
              <StructureSection
                draft={draft}
                selectedTier={selectedTier}
                selectedTierId={selectedTierId}
                selectedVariant={selectedVariant}
                selectedVariantId={selectedVariantId}
                trackSearch={trackSearch}
                denseTracks={denseTracks}
                tracksExpanded={tracksExpanded}
                onAddTier={handleAddTier}
                onSelectTier={handleSelectTier}
                onMoveTierUp={onMoveTierUp}
                onMoveTierDown={onMoveTierDown}
                onAddVariant={handleAddVariant}
                onTrackSearchChange={setTrackSearch}
                onToggleDenseTracks={() =>
                  setDenseTracks((current) => !current)
                }
                onToggleTracksExpanded={() =>
                  setTracksExpanded((current) => !current)
                }
                onSelectVariant={handleSelectVariant}
                onMoveVariantUp={onMoveVariantUp}
                onMoveVariantDown={onMoveVariantDown}
              />
            </Stack.Item>
            <Stack.Item basis="32%" grow={3} style={{ minWidth: '0' }}>
              <EditPanelSection
                draft={draft}
                draftToken={draftToken}
                presetEditorRequest={presetEditorRequest}
                audienceOptions={audienceOptions}
                soundTypeOptions={soundTypeOptions}
                audienceLabel={audienceLabel}
                soundTypeLabel={soundTypeLabel}
                inspectorTarget={inspectorTarget}
                selectedTier={selectedTier}
                selectedVariant={selectedVariant}
                canDelete={canDelete}
                onNew={onNew}
                onDelete={onDelete}
                onExport={onExport}
                onImport={onImport}
                onSetName={onSetName}
                onSetDescription={onSetDescription}
                onSetAudienceMode={onSetAudienceMode}
                onSetSoundType={onSetSoundType}
                onToggleShowTitle={onToggleShowTitle}
                onToggleRepeat={onToggleRepeat}
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
          </Stack>
        </Box>
      </Stack.Item>
    </Stack>
  );
}

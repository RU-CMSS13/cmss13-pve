import { BooleanLike } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type ScenarioValue = string | number;

type Parameter = {
  name: string;
  values: ScenarioValue[];
  current: ScenarioValue | null;
};

type Insert = {
  id: string;
  group: string;
  landmark: string;
  file: string;
  keep: BooleanLike;
  notes: string;
  override: 0 | 1 | null;
  landmark_found: BooleanLike;
  loaded: BooleanLike;
};

type NightmareContext = {
  id: string;
  map_name: string | null;
  parameters: Parameter[];
  inserts: Insert[];
};

type Data = {
  status: number;
  disabled: BooleanLike;
  editable: BooleanLike;
  ran: BooleanLike;
  contexts: NightmareContext[];
};

const NIGHTMARE_STATUS_STANDBY = 0;

export const NightmareMenu = () => {
  const { act, data } = useBackend<Data>();
  const { status, disabled, editable, contexts } = data;
  const [selectedContext, setSelectedContext] = useState(contexts[0]?.id);
  const context =
    contexts.find((entry) => entry.id === selectedContext) || contexts[0];

  return (
    <Window width={600} height={700}>
      <Window.Content scrollable>
        <Section
          title="Nightmare"
          buttons={
            <>
              <Button
                icon="play"
                color="purple"
                disabled={!editable || status !== NIGHTMARE_STATUS_STANDBY}
                tooltip="Runs Nightmare now and loads its inserts before the round starts."
                onClick={() => act('prepare_game')}
              >
                Run Now
              </Button>
              <Button
                icon={disabled ? 'toggle-off' : 'toggle-on'}
                color={disabled ? 'bad' : 'good'}
                disabled={!editable}
                tooltip="Skip Nightmare this round, so no inserts are loaded."
                onClick={() => act('toggle_disabled')}
              >
                {disabled ? 'Disabled' : 'Enabled'}
              </Button>
            </>
          }
        >
          {editable ? (
            disabled ? (
              <NoticeBox danger>
                Nightmare is disabled for this round. Changes only apply if it
                is enabled again.
              </NoticeBox>
            ) : (
              <NoticeBox info>
                Changes are applied when the round starts or when Nightmare is
                run manually. Auto inserts load by their own chance and
                conditions, forced ones always load and blocked ones never do.
              </NoticeBox>
            )
          ) : (
            <NoticeBox>
              Nightmare can only be changed in the lobby, before it has run.
              Jumping and previews still work.
            </NoticeBox>
          )}
        </Section>
        {contexts.length > 1 && (
          <Tabs>
            {contexts.map((entry) => (
              <Tabs.Tab
                key={entry.id}
                icon={entry.id === 'ship' ? 'rocket' : 'globe'}
                selected={entry.id === context.id}
                onClick={() => setSelectedContext(entry.id)}
              >
                {entry.map_name || entry.id}
              </Tabs.Tab>
            ))}
          </Tabs>
        )}
        {context && (
          <>
            {context.parameters.length > 0 && (
              <ScenarioSection context={context} editable={editable} />
            )}
            <InsertsSection context={context} editable={editable} />
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const ScenarioSection = (props: {
  readonly context: NightmareContext;
  readonly editable: BooleanLike;
}) => {
  const { act } = useBackend<Data>();
  const { context, editable } = props;

  return (
    <Section title="Scenario">
      <LabeledList>
        {context.parameters.map((parameter) => (
          <LabeledList.Item key={parameter.name} label={parameter.name}>
            <Stack wrap="wrap">
              {parameter.values.map((value) => (
                <Stack.Item key={String(value)}>
                  <Button
                    selected={parameter.current === value}
                    disabled={!editable}
                    onClick={() =>
                      act('set_scenario', {
                        context: context.id,
                        name: parameter.name,
                        value: value,
                      })
                    }
                  >
                    {String(value)}
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const InsertsSection = (props: {
  readonly context: NightmareContext;
  readonly editable: BooleanLike;
}) => {
  const { act, data } = useBackend<Data>();
  const { context, editable } = props;
  const [searchText, setSearchText] = useState('');

  const search = searchText.toLowerCase();
  const groups: Record<string, Insert[]> = {};
  for (const insert of context.inserts) {
    if (
      search &&
      !insert.file.toLowerCase().includes(search) &&
      !insert.landmark.toLowerCase().includes(search) &&
      !insert.group.toLowerCase().includes(search)
    ) {
      continue;
    }
    (groups[insert.group] ||= []).push(insert);
  }
  const overridden = context.inserts.filter(
    (insert) => insert.override !== null,
  ).length;
  const loaded = context.inserts.filter((insert) => insert.loaded).length;

  return (
    <Section
      title={`Inserts (${context.inserts.length}${data.ran ? `, ${loaded} loaded` : ''})`}
      buttons={
        <Button
          icon="undo"
          disabled={!editable || !overridden}
          tooltip="Sets every insert of this map back to Auto."
          onClick={() => act('reset_insert_overrides', { context: context.id })}
        >
          Reset ({overridden})
        </Button>
      }
    >
      {context.inserts.length ? (
        <>
          <Input
            fluid
            mb={1}
            placeholder="Search by file, landmark or group"
            onInput={(e, value) => setSearchText(value)}
          />
          {Object.keys(groups).map((group) => (
            <InsertGroup
              key={group}
              contextId={context.id}
              name={group}
              inserts={groups[group]}
              editable={editable}
            />
          ))}
        </>
      ) : (
        <NoticeBox>This map has no Nightmare inserts.</NoticeBox>
      )}
    </Section>
  );
};

const InsertGroup = (props: {
  readonly contextId: string;
  readonly name: string;
  readonly inserts: Insert[];
  readonly editable: BooleanLike;
}) => {
  const { data } = useBackend<Data>();
  const { contextId, name, inserts, editable } = props;
  const overridden = inserts.filter(
    (insert) => insert.override !== null,
  ).length;
  const loaded = inserts.filter((insert) => insert.loaded).length;

  return (
    <Collapsible
      title={`${name} (${inserts.length})${overridden ? ` - ${overridden} changed` : ''}${data.ran ? ` - ${loaded} loaded` : ''}`}
      color={overridden ? 'purple' : 'default'}
    >
      {inserts.map((insert) => (
        <InsertRow
          key={insert.id}
          contextId={contextId}
          insert={insert}
          editable={editable}
        />
      ))}
    </Collapsible>
  );
};

const InsertRow = (props: {
  readonly contextId: string;
  readonly insert: Insert;
  readonly editable: BooleanLike;
}) => {
  const { act } = useBackend<Data>();
  const { contextId, insert, editable } = props;
  const setOverride = (override: string) =>
    act('set_insert_override', {
      context: contextId,
      id: insert.id,
      override: override,
    });
  const lookTooltip = insert.landmark_found
    ? undefined
    : 'The landmark is not on the map: another insert places it, or a loaded insert replaced it.';

  return (
    <Stack align="center" mb={0.5} ml={1}>
      <Stack.Item grow basis={0}>
        <Box bold>
          {insert.file}
          {!!insert.keep && (
            <Box inline color="label" ml={1}>
              (adds on top)
            </Box>
          )}
          {!!insert.loaded && (
            <Box inline color="good" ml={1}>
              Loaded
            </Box>
          )}
        </Box>
        <Box color="label" fontSize="0.9em">
          @ {insert.landmark}
          {insert.notes && ` - ${insert.notes}`}
        </Box>
      </Stack.Item>
      <Stack.Item>
        {editable ? (
          <>
            <Button
              selected={insert.override === null}
              tooltip="Loads by its own chance and conditions."
              onClick={() => setOverride('auto')}
            >
              Auto
            </Button>
            <Button
              color={insert.override === 1 ? 'good' : 'transparent'}
              tooltip="Always loads, replacing whatever rolled for its landmark. Only one replacing insert can be forced per landmark."
              onClick={() => setOverride('force')}
            >
              Force
            </Button>
            <Button
              color={insert.override === 0 ? 'bad' : 'transparent'}
              tooltip="Never loads."
              onClick={() => setOverride('block')}
            >
              Block
            </Button>
          </>
        ) : (
          <OverrideLabel override={insert.override} />
        )}
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="location-arrow"
          disabled={!insert.landmark_found}
          tooltip={lookTooltip || 'Jump to the landmark.'}
          onClick={() =>
            act('jump_to_insert', { context: contextId, id: insert.id })
          }
        />
        <Button
          icon="eye"
          disabled={!insert.landmark_found}
          tooltip={lookTooltip || 'Show the insert in place for 15 seconds.'}
          onClick={() =>
            act('preview_insert', { context: contextId, id: insert.id })
          }
        />
      </Stack.Item>
    </Stack>
  );
};

const OverrideLabel = (props: { readonly override: Insert['override'] }) => {
  const { override } = props;
  if (override === 1) {
    return <Box color="good">Forced</Box>;
  }
  if (override === 0) {
    return <Box color="bad">Blocked</Box>;
  }
  return <Box color="label">Auto</Box>;
};

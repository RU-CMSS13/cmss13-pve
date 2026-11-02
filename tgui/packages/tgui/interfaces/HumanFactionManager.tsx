import { BooleanLike } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Input,
  Section,
  Stack,
  Table,
} from '../components';
import { Window } from '../layouts';

type Faction = {
  name: string;
  shoot_to_kill: BooleanLike;
  friendly: string[];
  neutral: string[];
  ai_count: number;
};

type BackendContext = {
  factions: Faction[];
  all_factions: string[];
};

type Relation = 'hostile' | 'neutral' | 'friendly';

const RELATIONS: { id: Relation; name: string; color: string; icon: string }[] =
  [
    { id: 'hostile', name: 'Hostile', color: 'bad', icon: 'skull' },
    { id: 'neutral', name: 'Neutral', color: 'average', icon: 'minus-circle' },
    { id: 'friendly', name: 'Friendly', color: 'good', icon: 'handshake' },
  ];

/** How the faction treats the other one, or null if the faction has no AI faction datum */
const getRelation = (
  faction: Faction | undefined,
  other: string,
): Relation | null => {
  if (!faction) {
    return null;
  }
  if (faction.friendly.includes(other)) {
    return 'friendly';
  }
  if (faction.neutral.includes(other)) {
    return 'neutral';
  }
  return 'hostile';
};

export const HumanFactionManager = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { factions, all_factions } = data;
  const [selected, setSelected] = useState<string | null>(null);

  const faction =
    factions.find((entry) => entry.name === selected) || factions[0];
  const datumless = all_factions.filter(
    (name) => !factions.some((entry) => entry.name === name),
  );

  return (
    <Window title="Human Faction Manager" width={860} height={700}>
      <Window.Content>
        <Stack fill>
          <Stack.Item basis="30%">
            <Section
              fill
              scrollable
              title="Factions"
              buttons={
                <Dropdown
                  width="10em"
                  placeholder="Add faction..."
                  disabled={!datumless.length}
                  options={datumless}
                  selected={null}
                  onSelected={(value) => {
                    act('create_faction', { faction: value });
                    setSelected(value);
                  }}
                />
              }
            >
              {factions.map((entry) => (
                <Button
                  key={entry.name}
                  fluid
                  mb={0.5}
                  selected={entry.name === faction?.name}
                  onClick={() => setSelected(entry.name)}
                >
                  <Stack>
                    <Stack.Item grow>{entry.name}</Stack.Item>
                    {!!entry.ai_count && (
                      <Stack.Item color="label">{entry.ai_count} AI</Stack.Item>
                    )}
                  </Stack>
                </Button>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            {faction ? (
              <FactionRelations faction={faction} />
            ) : (
              <Section fill>
                <Box italic color="label">
                  No AI factions yet
                </Box>
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const FactionRelations = (props: { readonly faction: Faction }) => {
  const { data, act } = useBackend<BackendContext>();
  const { factions, all_factions } = data;
  const { faction } = props;
  const [mutual, setMutual] = useState(true);
  const [search, setSearch] = useState('');

  const searchText = search.trim().toLowerCase();
  const others = all_factions.filter(
    (name) =>
      name !== faction.name &&
      (!searchText || name.toLowerCase().includes(searchText)),
  );

  return (
    <Section
      fill
      scrollable
      title={faction.name}
      buttons={
        <>
          <Button.Checkbox
            checked={faction.shoot_to_kill}
            tooltip="If off, AI of this faction stop shooting enemies that went down"
            onClick={() =>
              act('set_shoot_to_kill', {
                faction: faction.name,
                value: faction.shoot_to_kill ? 0 : 1,
              })
            }
          >
            Shoot to kill
          </Button.Checkbox>
          <Button.Checkbox
            checked={mutual}
            tooltip="Changes also make the other faction treat this one the same way"
            onClick={() => setMutual(!mutual)}
          >
            Mutual
          </Button.Checkbox>
        </>
      }
    >
      <Input
        fluid
        mb={1}
        placeholder="Search factions..."
        value={search}
        onInput={(e, value) => setSearch(value)}
      />
      <Table>
        <Table.Row header>
          <Table.Cell>Faction</Table.Cell>
          <Table.Cell collapsing textAlign="center">
            Treats them
          </Table.Cell>
          <Table.Cell collapsing textAlign="center">
            They treat
          </Table.Cell>
        </Table.Row>
        {others.map((other) => {
          const ours = getRelation(faction, other);
          const theirs = getRelation(
            factions.find((entry) => entry.name === other),
            faction.name,
          );
          const theirInfo = RELATIONS.find((entry) => entry.id === theirs);
          return (
            <Table.Row key={other} className="candystripe">
              <Table.Cell py={0.5}>{other}</Table.Cell>
              <Table.Cell collapsing>
                {RELATIONS.map((relation) => (
                  <Button
                    key={relation.id}
                    icon={relation.icon}
                    color={
                      ours === relation.id ? relation.color : 'transparent'
                    }
                    onClick={() =>
                      act('set_relation', {
                        faction: faction.name,
                        other: other,
                        relation: relation.id,
                        mutual: mutual ? 1 : 0,
                      })
                    }
                  >
                    {relation.name}
                  </Button>
                ))}
              </Table.Cell>
              <Table.Cell collapsing textAlign="center">
                {theirInfo ? (
                  <Box color={theirInfo.color}>
                    <Icon name={theirInfo.icon} mr={0.5} />
                    {theirInfo.name}
                    {theirs !== ours && (
                      <Box inline color="label" ml={0.5}>
                        (one-way)
                      </Box>
                    )}
                  </Box>
                ) : (
                  <Box italic color="label">
                    no AI faction
                  </Box>
                )}
              </Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
};

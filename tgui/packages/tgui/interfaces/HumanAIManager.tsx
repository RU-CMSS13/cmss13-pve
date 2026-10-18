import { BooleanLike } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  Icon,
  Input,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type AIHuman = {
  name: string;
  ref: string;
  brain_ref: string;
  faction: string;
  health: number;
  status: string;
  squad_id: number | null;
  is_leader: BooleanLike;
  can_assign_squad: BooleanLike;
  area: string;
};

type Squad = {
  id: number;
  name: string;
  leader: string | null;
  order_ref: string | null;
  members: number;
};

type Order = {
  name: string;
  desc: string;
  ref: string;
  waypoints: number;
  brains: number;
};

type BackendContext = {
  ai_humans: AIHuman[];
  squads: Squad[];
  orders: Order[];
  placing_patrol: BooleanLike;
  patrol_waypoints: number;
};

const ALL_FACTIONS = 'All factions';

const STATUS_COLORS = {
  Fighting: 'bad',
  Holding: 'average',
  Moving: 'teal',
  Patrolling: 'teal',
  'On gun': 'orange',
  Crewing: 'orange',
  Player: 'good',
};

export const HumanAIManager = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { ai_humans, squads } = data;
  const [search, setSearch] = useState('');
  const [faction, setFaction] = useState(ALL_FACTIONS);
  const [fightingOnly, setFightingOnly] = useState(false);

  const factions = [
    ALL_FACTIONS,
    ...Array.from(new Set(ai_humans.map((human) => human.faction))).sort(),
  ];
  const searchText = search.trim().toLowerCase();
  const shown = ai_humans.filter(
    (human) =>
      (!searchText || human.name.toLowerCase().includes(searchText)) &&
      (faction === ALL_FACTIONS || human.faction === faction) &&
      (!fightingOnly || human.status === 'Fighting'),
  );
  const unassigned = shown.filter((human) => !human.squad_id);

  return (
    <Window title="Human AI Manager" width={900} height={720}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Stack align="center">
              <Stack.Item grow>
                <Input
                  fluid
                  placeholder="Search by name..."
                  value={search}
                  onInput={(e, value) => setSearch(value)}
                />
              </Stack.Item>
              <Stack.Item>
                <Dropdown
                  width="14em"
                  options={factions}
                  selected={faction}
                  onSelected={(value) => setFaction(value)}
                />
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  checked={fightingOnly}
                  onClick={() => setFightingOnly(!fightingOnly)}
                >
                  Fighting only
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item>
                <Button icon="plus" onClick={() => act('create_squad')}>
                  New Squad
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title={`AI (${shown.length} of ${ai_humans.length})`}
            >
              {squads.map((squad) => (
                <SquadGroup
                  key={squad.id}
                  squad={squad}
                  members={shown.filter((human) => human.squad_id === squad.id)}
                />
              ))}
              <Collapsible open title={`No squad (${unassigned.length})`}>
                {unassigned.length ? (
                  unassigned.map((human) => (
                    <AIRow key={human.brain_ref} human={human} />
                  ))
                ) : (
                  <Box italic color="label">
                    Everyone is in a squad
                  </Box>
                )}
              </Collapsible>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <PatrolSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SquadGroup = (props: {
  readonly squad: Squad;
  readonly members: AIHuman[];
}) => {
  const { data, act } = useBackend<BackendContext>();
  const { orders } = data;
  const { squad, members } = props;

  const patrolOptions = [
    { displayText: 'No patrol', value: '' },
    ...orders.map((order) => ({
      displayText: order.desc || order.name,
      value: order.ref,
    })),
  ];
  const order = orders.find((entry) => entry.ref === squad.order_ref);

  return (
    <Collapsible
      open
      title={`${squad.name} (${squad.members})${squad.leader ? ` - led by ${squad.leader}` : ''}`}
      buttons={
        <>
          <Dropdown
            width="12em"
            options={patrolOptions}
            selected={squad.order_ref || ''}
            displayText={order ? order.desc || order.name : 'No patrol'}
            onSelected={(value) =>
              act('set_squad_order', { squad: squad.id, order: value })
            }
          />
          <Button
            icon="pen"
            tooltip="Rename"
            onClick={() => act('rename_squad', { squad: squad.id })}
          />
          <Button.Confirm
            icon="trash"
            color="bad"
            tooltip="Disband the squad, its AI stay"
            onClick={() => act('disband_squad', { squad: squad.id })}
          />
        </>
      }
    >
      {members.length ? (
        members.map((human) => <AIRow key={human.brain_ref} human={human} />)
      ) : (
        <Box italic color="label">
          {squad.members ? 'Nobody matches the filters' : 'Empty squad'}
        </Box>
      )}
    </Collapsible>
  );
};

const AIRow = (props: { readonly human: AIHuman }) => {
  const { data, act } = useBackend<BackendContext>();
  const { squads } = data;
  const { human } = props;

  const squadOptions = [
    { displayText: 'No squad', value: '0' },
    ...squads.map((squad) => ({
      displayText: squad.name,
      value: `${squad.id}`,
    })),
  ];
  const squad = squads.find((entry) => entry.id === human.squad_id);

  return (
    <Stack align="center" pb={0.5}>
      <Stack.Item>
        <Button
          compact
          icon="location-arrow"
          tooltip={`Jump to (${human.area})`}
          onClick={() => act('jump_to', { ref: human.ref })}
        />
      </Stack.Item>
      <Stack.Item grow>
        {!!human.is_leader && <Icon name="star" color="gold" mr={0.5} />}
        {human.name}
      </Stack.Item>
      <Stack.Item width="9em" color="label">
        {human.faction}
      </Stack.Item>
      <Stack.Item width="6em">
        <ProgressBar
          value={human.health / 100}
          ranges={{
            good: [0.7, Infinity],
            average: [0.3, 0.7],
            bad: [-Infinity, 0.3],
          }}
        >
          {human.health}%
        </ProgressBar>
      </Stack.Item>
      <Stack.Item width="5.5em" color={STATUS_COLORS[human.status] || 'label'}>
        {human.status}
      </Stack.Item>
      <Stack.Item>
        <Dropdown
          width="10em"
          disabled={!human.can_assign_squad}
          options={squadOptions}
          selected={`${human.squad_id || 0}`}
          displayText={squad ? squad.name : 'No squad'}
          onSelected={(value) =>
            act('set_squad', { brain_ref: human.brain_ref, squad: value })
          }
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          compact
          icon="star"
          disabled={!human.squad_id || !!human.is_leader}
          tooltip="Make squad leader"
          onClick={() => act('set_leader', { brain_ref: human.brain_ref })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          compact
          icon="user"
          tooltip="View variables of the human"
          onClick={() => act('view_variables', { ref: human.ref })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          compact
          icon="brain"
          tooltip="View variables of the AI"
          onClick={() => act('view_variables', { ref: human.brain_ref })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button.Confirm
          compact
          icon="trash"
          color="bad"
          tooltip="Delete"
          onClick={() => act('delete_ai', { brain_ref: human.brain_ref })}
        />
      </Stack.Item>
    </Stack>
  );
};

const PatrolSection = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { orders, placing_patrol, patrol_waypoints } = data;

  return (
    <Section
      title="Patrols"
      buttons={
        <>
          <Button
            icon="map-pin"
            selected={placing_patrol}
            tooltip="LMB on the map adds a waypoint, MMB removes the last one"
            onClick={() => act('toggle_patrol_placing')}
          >
            Place Waypoints
          </Button>
          <Button
            icon="undo"
            disabled={!patrol_waypoints}
            onClick={() => act('undo_waypoint')}
          />
          <Button
            icon="times"
            disabled={!patrol_waypoints}
            onClick={() => act('clear_waypoints')}
          />
          <Button
            icon="check"
            color="good"
            disabled={!patrol_waypoints}
            onClick={() => act('create_patrol')}
          >
            Create ({patrol_waypoints})
          </Button>
        </>
      }
    >
      {!!placing_patrol && (
        <NoticeBox info>
          Click the turfs to walk through in order, the patrol goes back and
          forth between the first and the last
        </NoticeBox>
      )}
      {orders.length ? (
        orders.map((order) => (
          <Stack key={order.ref} align="center" pb={0.5}>
            <Stack.Item grow>
              <Box bold inline>
                {order.desc || order.name}
              </Box>
            </Stack.Item>
            <Stack.Item color="label">
              {order.waypoints} waypoints, {order.brains} AI
            </Stack.Item>
            <Stack.Item>
              <Button
                compact
                icon="code"
                tooltip="View variables"
                onClick={() => act('view_variables', { ref: order.ref })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button.Confirm
                compact
                icon="trash"
                color="bad"
                tooltip="Delete"
                onClick={() => act('delete_order', { ref: order.ref })}
              />
            </Stack.Item>
          </Stack>
        ))
      ) : (
        <Box italic color="label">
          No patrols yet. Place waypoints, create the patrol and pick it for a
          squad above.
        </Box>
      )}
    </Section>
  );
};

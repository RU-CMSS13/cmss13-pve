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
  Tabs,
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

type AIVehicle = {
  name: string;
  ref: string;
  brain_ref: string;
  faction: string;
  health: number;
  status: string;
  squad_id: number | null;
  crew: string[];
  area: string;
};

type VehicleSquad = {
  id: number;
  name: string;
  members: number;
};

type BackendContext = {
  ai_humans: AIHuman[];
  squads: Squad[];
  orders: Order[];
  vehicles: AIVehicle[];
  vehicle_squads: VehicleSquad[];
  placing_patrol: BooleanLike;
  patrol_waypoints: number;
};

type Tab = 'infantry' | 'vehicles';

const ALL_FACTIONS = 'All factions';

const STATUS_COLORS = {
  Fighting: 'bad',
  Holding: 'average',
  Moving: 'teal',
  Patrolling: 'teal',
  'On gun': 'orange',
  Crewing: 'orange',
  Player: 'good',
  'No crew': 'average',
  Abandoned: 'label',
  Destroyed: 'bad',
};

export const HumanAIManager = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { ai_humans, squads, vehicles, vehicle_squads } = data;
  const [tab, setTab] = useState<Tab>('infantry');
  const [search, setSearch] = useState('');
  const [faction, setFaction] = useState(ALL_FACTIONS);
  const [fightingOnly, setFightingOnly] = useState(false);
  const [showCrews, setShowCrews] = useState(false);

  const factions = [
    ALL_FACTIONS,
    ...Array.from(
      new Set([
        ...ai_humans.map((human) => human.faction),
        ...vehicles.map((vehicle) => vehicle.faction),
      ]),
    ).sort(),
  ];
  const searchText = search.trim().toLowerCase();
  const matches = (unit: { name: string; faction: string; status: string }) =>
    (!searchText || unit.name.toLowerCase().includes(searchText)) &&
    (faction === ALL_FACTIONS || unit.faction === faction) &&
    (!fightingOnly || unit.status === 'Fighting');
  // Crews are listed with their vehicles
  const shown = ai_humans.filter(
    (human) => matches(human) && (showCrews || human.status !== 'Crewing'),
  );
  const unassigned = shown.filter((human) => !human.squad_id);
  const shownVehicles = vehicles.filter(matches);
  const unassignedVehicles = shownVehicles.filter(
    (vehicle) => !vehicle.squad_id,
  );

  return (
    <Window title="Human AI Manager" width={900} height={720}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                icon="person-rifle"
                selected={tab === 'infantry'}
                onClick={() => setTab('infantry')}
              >
                Infantry ({ai_humans.length})
              </Tabs.Tab>
              <Tabs.Tab
                icon="truck-monster"
                selected={tab === 'vehicles'}
                onClick={() => setTab('vehicles')}
              >
                Vehicles ({vehicles.length})
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
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
              {tab === 'infantry' && (
                <Stack.Item>
                  <Button.Checkbox
                    checked={showCrews}
                    tooltip="Crews are listed with their vehicles on the vehicles tab"
                    onClick={() => setShowCrews(!showCrews)}
                  >
                    Show vehicle crews
                  </Button.Checkbox>
                </Stack.Item>
              )}
              <Stack.Item>
                <Button
                  icon="plus"
                  onClick={() =>
                    act(
                      tab === 'infantry'
                        ? 'create_squad'
                        : 'create_vehicle_squad',
                    )
                  }
                >
                  New Squad
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          {tab === 'vehicles' ? (
            <Stack.Item grow>
              <Section
                fill
                scrollable
                title={`Vehicles (${shownVehicles.length} of ${vehicles.length})`}
              >
                {vehicle_squads.map((vehicleSquad) => (
                  <VehicleSquadGroup
                    key={vehicleSquad.id}
                    squad={vehicleSquad}
                    members={shownVehicles.filter(
                      (vehicle) => vehicle.squad_id === vehicleSquad.id,
                    )}
                  />
                ))}
                <Collapsible
                  open
                  title={`No squad (${unassignedVehicles.length})`}
                >
                  {unassignedVehicles.length ? (
                    unassignedVehicles.map((vehicle) => (
                      <VehicleRow key={vehicle.brain_ref} vehicle={vehicle} />
                    ))
                  ) : (
                    <Box italic color="label">
                      {vehicles.length
                        ? 'Every vehicle is in a squad'
                        : 'No AI vehicles. Spawn them on the vehicles tab of Create Human AI'}
                    </Box>
                  )}
                </Collapsible>
              </Section>
            </Stack.Item>
          ) : (
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
                    members={shown.filter(
                      (human) => human.squad_id === squad.id,
                    )}
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
          )}
          {tab === 'infantry' && (
            <Stack.Item>
              <PatrolSection />
            </Stack.Item>
          )}
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

const VehicleSquadGroup = (props: {
  readonly squad: VehicleSquad;
  readonly members: AIVehicle[];
}) => {
  const { act } = useBackend<BackendContext>();
  const { squad, members } = props;

  return (
    <Collapsible
      open
      title={`${squad.name} (${squad.members})`}
      buttons={
        <>
          <Button
            icon="crosshairs"
            disabled={!squad.members}
            tooltip="Select the squad on the orders tab of Create Human AI"
            onClick={() => act('select_vehicles', { squad: squad.id })}
          >
            Select
          </Button>
          <Button
            icon="pen"
            tooltip="Rename"
            onClick={() => act('rename_vehicle_squad', { squad: squad.id })}
          />
          <Button.Confirm
            icon="trash"
            color="bad"
            tooltip="Disband the squad, its vehicles stay"
            onClick={() => act('disband_vehicle_squad', { squad: squad.id })}
          />
        </>
      }
    >
      {members.length ? (
        members.map((vehicle) => (
          <VehicleRow key={vehicle.brain_ref} vehicle={vehicle} />
        ))
      ) : (
        <Box italic color="label">
          {squad.members ? 'No vehicle matches the filters' : 'Empty squad'}
        </Box>
      )}
    </Collapsible>
  );
};

const VehicleRow = (props: { readonly vehicle: AIVehicle }) => {
  const { data, act } = useBackend<BackendContext>();
  const { vehicle_squads } = data;
  const { vehicle } = props;

  const squadOptions = [
    { displayText: 'No squad', value: '0' },
    ...vehicle_squads.map((squad) => ({
      displayText: squad.name,
      value: `${squad.id}`,
    })),
  ];
  const squad = vehicle_squads.find((entry) => entry.id === vehicle.squad_id);

  return (
    <Stack align="center" pb={0.5}>
      <Stack.Item>
        <Button
          compact
          icon="location-arrow"
          tooltip={`Jump to (${vehicle.area})`}
          onClick={() => act('jump_to', { ref: vehicle.ref })}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Box>{vehicle.name}</Box>
        <Box color="label" fontSize="11px">
          {vehicle.crew.length
            ? `Crew: ${vehicle.crew.join(', ')}`
            : 'No crew yet'}
        </Box>
      </Stack.Item>
      <Stack.Item width="9em" color="label">
        {vehicle.faction}
      </Stack.Item>
      <Stack.Item width="6em">
        <ProgressBar
          value={vehicle.health / 100}
          ranges={{
            good: [0.7, Infinity],
            average: [0.3, 0.7],
            bad: [-Infinity, 0.3],
          }}
        >
          {vehicle.health}%
        </ProgressBar>
      </Stack.Item>
      <Stack.Item
        width="6.5em"
        color={STATUS_COLORS[vehicle.status] || 'label'}
      >
        {vehicle.status}
      </Stack.Item>
      <Stack.Item>
        <Dropdown
          width="10em"
          options={squadOptions}
          selected={`${vehicle.squad_id || 0}`}
          displayText={squad ? squad.name : 'No squad'}
          onSelected={(value) =>
            act('set_vehicle_squad', {
              brain_ref: vehicle.brain_ref,
              squad: value,
            })
          }
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          compact
          icon="crosshairs"
          tooltip="Select it on the orders tab of Create Human AI"
          onClick={() =>
            act('select_vehicles', { brain_ref: vehicle.brain_ref })
          }
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          compact
          icon="truck-monster"
          tooltip="View variables of the vehicle"
          onClick={() => act('view_variables', { ref: vehicle.ref })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          compact
          icon="brain"
          tooltip="View variables of the AI"
          onClick={() => act('view_variables', { ref: vehicle.brain_ref })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button.Confirm
          compact
          icon="trash"
          color="bad"
          tooltip="Delete the vehicle"
          onClick={() =>
            act('delete_vehicle', { brain_ref: vehicle.brain_ref })
          }
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

import { BooleanLike } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type Preset = {
  name: string;
  description: string;
  path: string;
  category: string;
};

type PresetCategory = {
  name: string;
  presets: Preset[];
};

type SquadPreset = {
  name: string;
  description: string;
  path: string;
  contents: string[];
};

type SquadCategory = {
  name: string;
  squads: SquadPreset[];
};

type Vehicle = {
  name: string;
  path: string;
  category: string;
};

type VehicleCategory = {
  name: string;
  vehicles: Vehicle[];
};

type CrewPreset = {
  name: string;
  path: string;
};

type SquadEntry = {
  path: string;
  name: string;
  count: number;
};

type Unit = {
  name: string;
  ref: string;
  vehicle: BooleanLike;
  health: number;
  status: string;
};

type Tab = 'infantry' | 'squads' | 'vehicles' | 'orders';

type BackendContext = {
  preset_categories: PresetCategory[];
  squad_categories: SquadCategory[];
  vehicle_categories: VehicleCategory[];
  crew_presets: CrewPreset[];
  factions: string[];
  vehicle_factions: string[];
  species: string[];
  equipment_options: string[];
  nest_guns: string[];
  directions: string[];
  preset_default: string;
  custom_category: string;
  max_count: number;
  max_squad_size: number;
  max_squad_radius: number;
  max_spare_ammo: number;
  max_overwatch_range: number;

  tab: Tab;
  spawn_click_intercept: BooleanLike;
  order_click_intercept: BooleanLike;

  mode: 'single' | 'squad' | 'nest' | 'overwatch';
  category: string | null;
  selected_preset: string | null;
  spawn_count: number;
  squad: SquadEntry[];
  squad_radius: number;
  selected_faction: string;
  selected_species: string;
  selected_equipment: string;
  spawn_ai: BooleanLike;
  paradrop: BooleanLike;
  outfit: BooleanLike;
  nest_gun: string;
  nest_spare_ammo: number;
  spawn_direction: string;
  overwatch_post: BooleanLike;
  zombie_random_helmet: BooleanLike;
  zombie_helmet_chance: number;
  zombie_delimb_multi: number;
  zombie_disable_auto_clean: BooleanLike;

  selected_squad: string | null;

  selected_vehicle: string | null;
  vehicle_faction: string;
  vehicle_crew: string;
  vehicle_ai: BooleanLike;
  vehicle_infinite_ammo: BooleanLike;

  selected_units: Unit[];
  selecting_area: BooleanLike;
};

const TABS: { id: Tab; name: string; icon: string }[] = [
  { id: 'infantry', name: 'Infantry', icon: 'person-rifle' },
  { id: 'squads', name: 'Squads', icon: 'people-group' },
  { id: 'vehicles', name: 'Vehicles', icon: 'truck-monster' },
  { id: 'orders', name: 'Orders', icon: 'flag' },
];

const squadSize = (squad: SquadEntry[]) =>
  squad.reduce((total, entry) => total + entry.count, 0);

export const HumanAISpawner = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { tab } = data;

  return (
    <Window title="Human AI Spawner" width={780} height={720}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              {TABS.map((entry) => (
                <Tabs.Tab
                  key={entry.id}
                  icon={entry.icon}
                  selected={entry.id === tab}
                  onClick={() => act('set_tab', { tab: entry.id })}
                >
                  {entry.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === 'infantry' && <InfantryTab />}
            {tab === 'squads' && <SquadsTab />}
            {tab === 'vehicles' && <VehiclesTab />}
            {tab === 'orders' && <OrdersTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ClickSpawnButton = (props: { readonly tooltip: string }) => {
  const { data, act } = useBackend<BackendContext>();

  return (
    <Button
      fluid
      fontSize="15px"
      textAlign="center"
      icon="crosshairs"
      selected={data.spawn_click_intercept}
      tooltip={props.tooltip}
      onClick={() => act('toggle_click_spawn')}
    >
      Click Spawn
    </Button>
  );
};

const DirectionDropdown = (props) => {
  const { data, act } = useBackend<BackendContext>();

  return (
    <Dropdown
      width="100%"
      options={data.directions}
      selected={data.spawn_direction}
      onSelected={(value) => act('set_direction', { direction: value })}
    />
  );
};

const InfantryTab = (props) => {
  return (
    <Stack fill>
      <Stack.Item grow basis={0}>
        <PresetList />
      </Stack.Item>
      <Divider vertical />
      <Stack.Item basis="44%">
        <Stack fill vertical>
          <Stack.Item grow>
            <InfantrySpawnOptions />
          </Stack.Item>
          <Stack.Item>
            <CleanupOptions />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const PresetList = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { preset_categories, category } = data;
  const [search, setSearch] = useState('');

  const searchText = search.trim().toLowerCase();
  // Some presets are listed under several categories, the search shows them once
  const presets = searchText
    ? preset_categories
        .flatMap((entry) => entry.presets)
        .filter(
          (preset, index, all) =>
            preset.name.toLowerCase().includes(searchText) &&
            all.findIndex((other) => other.path === preset.path) === index,
        )
    : preset_categories.find((entry) => entry.name === category)?.presets || [];

  return (
    <Section
      fill
      scrollable
      title="Presets"
      buttons={
        <Button
          icon="plus"
          tooltip="Add any equipment preset to the custom presets. Alt-click a human while click spawning to add theirs."
          onClick={() => act('add_preset')}
        >
          Add
        </Button>
      }
    >
      <Stack vertical>
        <Stack.Item>
          <Dropdown
            width="100%"
            placeholder="Select a faction..."
            options={preset_categories.map((entry) => entry.name)}
            selected={category}
            onSelected={(value) => act('set_category', { category: value })}
          />
        </Stack.Item>
        <Stack.Item>
          <Input
            fluid
            placeholder="Search all factions..."
            value={search}
            onInput={(e, value) => setSearch(value)}
          />
        </Stack.Item>
        <Stack.Item>
          {presets.length ? (
            presets.map((preset) => (
              <PresetRow key={preset.path} preset={preset} />
            ))
          ) : (
            <Box textAlign="center" italic color="label" mt={1}>
              {searchText
                ? 'No preset matches the search'
                : 'Select a faction to view its presets'}
            </Box>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const PresetRow = (props: { readonly preset: Preset }) => {
  const { data, act } = useBackend<BackendContext>();
  const { mode, squad, selected_preset, max_count, custom_category } = data;
  const { preset } = props;

  const removeButton = preset.category === custom_category && (
    <Stack.Item>
      <Button
        icon="trash"
        color="bad"
        tooltip="Remove from the custom presets"
        onClick={() => act('remove_preset', { path: preset.path })}
      />
    </Stack.Item>
  );

  if (mode !== 'squad') {
    return (
      <Stack pb={0.5} align="center">
        <Stack.Item grow>
          <Button
            fluid
            textAlign="center"
            selected={preset.path === selected_preset}
            tooltip={preset.description}
            tooltipPosition="right"
            onClick={() => act('select_preset', { path: preset.path })}
          >
            {preset.name}
          </Button>
        </Stack.Item>
        {removeButton}
      </Stack>
    );
  }

  const count = squad.find((entry) => entry.path === preset.path)?.count || 0;
  return (
    <Stack pb={0.5} align="center">
      <Stack.Item grow>
        <Button
          fluid
          textAlign="center"
          selected={count > 0}
          tooltip="Add one to the squad"
          onClick={() =>
            act('set_squad_count', { path: preset.path, count: count + 1 })
          }
        >
          {preset.name}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="minus"
          disabled={count <= 0}
          onClick={() =>
            act('set_squad_count', { path: preset.path, count: count - 1 })
          }
        />
      </Stack.Item>
      <Stack.Item>
        <NumberInput
          width="3em"
          minValue={0}
          maxValue={max_count}
          step={1}
          value={count}
          onChange={(value) =>
            act('set_squad_count', { path: preset.path, count: value })
          }
        />
      </Stack.Item>
      {removeButton}
    </Stack>
  );
};

const InfantrySpawnOptions = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const {
    mode,
    preset_categories,
    selected_preset,
    spawn_count,
    max_count,
    outfit,
  } = data;

  const preset = preset_categories
    .flatMap((entry) => entry.presets)
    .find((entry) => entry.path === selected_preset);

  return (
    <Section fill scrollable title="Spawn">
      <Stack vertical>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Button
                fluid
                textAlign="center"
                selected={mode === 'single'}
                tooltip="A click spawns the selected preset"
                onClick={() => act('set_mode', { mode: 'single' })}
              >
                Single
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                textAlign="center"
                selected={mode === 'squad'}
                tooltip="A click spawns the whole squad around the clicked turf"
                onClick={() => act('set_mode', { mode: 'squad' })}
              >
                Squad
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                textAlign="center"
                selected={mode === 'nest'}
                tooltip="A click builds a mounted machine gun manned by the selected preset"
                onClick={() => act('set_mode', { mode: 'nest' })}
              >
                MG Nest
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                textAlign="center"
                selected={mode === 'overwatch'}
                tooltip="Two clicks: where the selected preset stands, then the center of the area it watches"
                onClick={() => act('set_mode', { mode: 'overwatch' })}
              >
                Overwatch
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <ClickSpawnButton
            tooltip={
              mode === 'single' && outfit
                ? 'LMB on a mob to dress it in the preset, MMB on a human to delete it'
                : 'LMB to spawn, MMB on a human to delete it, Alt+LMB on a human to add their preset'
            }
          />
        </Stack.Item>
        {mode !== 'squad' &&
          (preset ? (
            <Stack.Item>
              <Box bold>{preset.name}</Box>
              <Box color="label">{preset.description}</Box>
            </Stack.Item>
          ) : (
            <Stack.Item>
              <NoticeBox info>
                {mode === 'nest'
                  ? 'Pick a preset for the gunner'
                  : mode === 'overwatch'
                    ? 'Pick a preset on the left, the Machinegunners and Snipers categories are made for this'
                    : 'Pick a preset on the left'}
              </NoticeBox>
            </Stack.Item>
          ))}
        {mode === 'single' && (
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Amount">
                <NumberInput
                  width="4em"
                  minValue={1}
                  maxValue={max_count}
                  step={1}
                  value={spawn_count}
                  onChange={(value) => act('set_spawn_count', { count: value })}
                />
              </LabeledList.Item>
            </LabeledList>
            <Button.Checkbox
              mt={0.5}
              checked={outfit}
              tooltip="Clicking a mob dresses it in the preset instead of spawning a new human"
              onClick={() => act('toggle_outfit')}
            >
              Click dresses a mob
            </Button.Checkbox>
          </Stack.Item>
        )}
        {mode === 'squad' && <SquadOptions />}
        {mode === 'nest' && <NestOptions />}
        {mode === 'overwatch' && <OverwatchOptions />}
        <Stack.Item>
          <Divider />
          <HumanOptions />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const SquadOptions = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { squad, squad_radius, max_squad_radius, max_squad_size } = data;

  return (
    <>
      <Stack.Item>
        <LabeledList>
          <LabeledList.Item label="Radius">
            <NumberInput
              width="4em"
              minValue={0}
              maxValue={max_squad_radius}
              step={1}
              unit="tiles"
              value={squad_radius}
              onChange={(value) => act('set_squad_radius', { radius: value })}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Size">
            {squadSize(squad)} / {max_squad_size}
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      <Stack.Item>
        {squad.length ? (
          squad.map((entry) => (
            <Stack key={entry.path} align="center" pb={0.5}>
              <Stack.Item grow>
                {entry.count}x {entry.name}
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="times"
                  color="bad"
                  onClick={() =>
                    act('set_squad_count', { path: entry.path, count: 0 })
                  }
                />
              </Stack.Item>
            </Stack>
          ))
        ) : (
          <Box textAlign="center" italic color="label">
            Pick presets on the left to build a squad. The first one leads it.
          </Box>
        )}
      </Stack.Item>
      {!!squad.length && (
        <Stack.Item>
          <Button fluid textAlign="center" onClick={() => act('clear_squad')}>
            Clear Squad
          </Button>
        </Stack.Item>
      )}
    </>
  );
};

const NestOptions = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { nest_guns, nest_gun, nest_spare_ammo, max_spare_ammo } = data;

  return (
    <Stack.Item>
      <LabeledList>
        <LabeledList.Item label="Gun">
          <Dropdown
            width="100%"
            options={nest_guns}
            selected={nest_gun}
            onSelected={(value) => act('set_nest_gun', { gun: value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Facing">
          <DirectionDropdown />
        </LabeledList.Item>
        <LabeledList.Item label="Spare ammo">
          <NumberInput
            width="4em"
            minValue={0}
            maxValue={max_spare_ammo}
            step={1}
            unit="boxes"
            value={nest_spare_ammo}
            onChange={(value) => act('set_nest_spare_ammo', { amount: value })}
          />
        </LabeledList.Item>
      </LabeledList>
      <Box color="label" mt={0.5}>
        The gun goes on the clicked turf, the gunner and the spare ammo behind
        it.
      </Box>
    </Stack.Item>
  );
};

const OverwatchOptions = (props) => {
  const { data } = useBackend<BackendContext>();
  const { overwatch_post, max_overwatch_range } = data;

  return (
    <Stack.Item>
      {overwatch_post ? (
        <NoticeBox info>
          Click the center of the area to watch, up to {max_overwatch_range}{' '}
          tiles from the post marked blue with no walls between. Click the post
          again to pick another one.
        </NoticeBox>
      ) : (
        <Box color="label">
          The first click picks where the AI stands, the second one the center
          of the area it watches. It holds the post facing there and sees up to{' '}
          {max_overwatch_range} tiles.
        </Box>
      )}
    </Stack.Item>
  );
};

const HumanOptions = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const {
    factions,
    species,
    equipment_options,
    preset_default,
    selected_faction,
    selected_species,
    selected_equipment,
    spawn_ai,
    paradrop,
  } = data;

  return (
    <Stack vertical>
      <Stack.Item>
        <LabeledList>
          <LabeledList.Item label="Faction">
            <Dropdown
              width="100%"
              options={[preset_default, ...factions]}
              selected={selected_faction}
              color={
                selected_faction !== preset_default ? 'average' : undefined
              }
              onSelected={(value) => act('set_faction', { faction: value })}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Species">
            <Dropdown
              width="100%"
              options={[preset_default, ...species]}
              selected={selected_species}
              color={
                selected_species !== preset_default ? 'average' : undefined
              }
              onSelected={(value) => act('set_species', { species: value })}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Equipment">
            <Dropdown
              width="100%"
              options={equipment_options}
              selected={selected_equipment}
              color={
                selected_equipment !== equipment_options[0]
                  ? 'average'
                  : undefined
              }
              onSelected={(value) => act('set_equipment', { equipment: value })}
            />
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      <Stack.Item>
        <Button.Checkbox
          checked={spawn_ai}
          onClick={() => act('toggle_spawn_ai')}
        >
          AI
        </Button.Checkbox>
        <Button.Checkbox
          checked={paradrop}
          onClick={() => act('toggle_paradrop')}
        >
          Parachute
        </Button.Checkbox>
      </Stack.Item>
      {selected_species === 'Zombie' && <ZombieOptions />}
    </Stack>
  );
};

const ZombieOptions = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const {
    zombie_random_helmet,
    zombie_helmet_chance,
    zombie_delimb_multi,
    zombie_disable_auto_clean,
  } = data;

  return (
    <Stack.Item>
      <Section title="Zombies">
        <LabeledList>
          <LabeledList.Item label="Helmets">
            <Button.Checkbox
              checked={zombie_random_helmet}
              onClick={() => act('toggle_zombie_random_helmet')}
            >
              Chance
            </Button.Checkbox>
            <NumberInput
              width="4em"
              minValue={0}
              maxValue={100}
              step={5}
              unit="%"
              disabled={!zombie_random_helmet}
              value={zombie_helmet_chance}
              onChange={(value) =>
                act('set_zombie_helmet_chance', { chance: value })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item
            label="Delimbing"
            tooltip="Multiplies the chance to cut off zombie limbs, 0 turns it off"
          >
            <NumberInput
              width="4em"
              minValue={0}
              maxValue={20}
              step={0.5}
              unit="x"
              value={Math.max(zombie_delimb_multi, 0)}
              onChange={(value) =>
                act('set_zombie_delimb_multi', { multi: value })
              }
            />
          </LabeledList.Item>
        </LabeledList>
        <Button.Checkbox
          mt={0.5}
          checked={zombie_disable_auto_clean}
          tooltip="Zombie bodies stay instead of being cleaned up"
          onClick={() => act('toggle_zombie_auto_clean')}
        >
          Keep bodies
        </Button.Checkbox>
      </Section>
    </Stack.Item>
  );
};

const CleanupOptions = (props) => {
  const { act } = useBackend<BackendContext>();

  return (
    <Section title="Cleanup">
      <Stack>
        <Stack.Item grow>
          <Button
            fluid
            textAlign="center"
            onClick={() => act('delete_ai_in_view')}
          >
            Delete AI in view
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            textAlign="center"
            color="bad"
            onClick={() => act('delete_all_ai')}
          >
            Delete all AI
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const SquadsTab = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { squad_categories, selected_squad } = data;
  const [category, setCategory] = useState<string | null>(null);

  const shownCategory = category || squad_categories[0]?.name;
  const squads =
    squad_categories.find((entry) => entry.name === shownCategory)?.squads ||
    [];
  const squad = squad_categories
    .flatMap((entry) => entry.squads)
    .find((entry) => entry.path === selected_squad);

  return (
    <Stack fill>
      <Stack.Item grow basis={0}>
        <Section fill scrollable title="Squads">
          <Dropdown
            width="100%"
            mb={1}
            options={squad_categories.map((entry) => entry.name)}
            selected={shownCategory}
            onSelected={(value) => setCategory(value)}
          />
          {squads.map((entry) => (
            <Box pb={0.5} key={entry.path}>
              <Button
                fluid
                textAlign="center"
                selected={entry.path === selected_squad}
                onClick={() => act('select_squad', { path: entry.path })}
              >
                {entry.name}
              </Button>
            </Box>
          ))}
        </Section>
      </Stack.Item>
      <Divider vertical />
      <Stack.Item basis="44%">
        <Section fill scrollable title="Selected Squad">
          <Stack vertical>
            <Stack.Item>
              <ClickSpawnButton tooltip="LMB to spawn the squad around the clicked turf, MMB on a human to delete it" />
            </Stack.Item>
            {squad ? (
              <>
                <Stack.Item>
                  <Box bold>{squad.name}</Box>
                  <Box color="label">{squad.description}</Box>
                </Stack.Item>
                <Stack.Item>
                  {squad.contents.map((content) => (
                    <Box key={content}>{content}</Box>
                  ))}
                </Stack.Item>
              </>
            ) : (
              <Stack.Item>
                <NoticeBox info>Pick a squad on the left</NoticeBox>
              </Stack.Item>
            )}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const VehiclesTab = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const {
    vehicle_categories,
    selected_vehicle,
    vehicle_factions,
    vehicle_faction,
    crew_presets,
    vehicle_crew,
    vehicle_ai,
    vehicle_infinite_ammo,
  } = data;
  const [search, setSearch] = useState('');

  const searchText = search.trim().toLowerCase();
  const vehicle = vehicle_categories
    .flatMap((entry) => entry.vehicles)
    .find((entry) => entry.path === selected_vehicle);

  return (
    <Stack fill>
      <Stack.Item grow basis={0}>
        <Section fill scrollable title="Vehicles">
          <Input
            fluid
            mb={1}
            placeholder="Search..."
            value={search}
            onInput={(e, value) => setSearch(value)}
          />
          {vehicle_categories.map((category) => {
            const vehicles = category.vehicles.filter((entry) =>
              entry.name.toLowerCase().includes(searchText),
            );
            if (!vehicles.length) {
              return null;
            }
            return (
              <Box key={category.name} mb={1}>
                <Box bold color="label" mb={0.5}>
                  {category.name}
                </Box>
                {vehicles.map((entry) => (
                  <Box pb={0.5} key={entry.path}>
                    <Button
                      fluid
                      textAlign="center"
                      selected={entry.path === selected_vehicle}
                      onClick={() =>
                        act('select_vehicle', { path: entry.path })
                      }
                    >
                      {entry.name}
                    </Button>
                  </Box>
                ))}
              </Box>
            );
          })}
        </Section>
      </Stack.Item>
      <Divider vertical />
      <Stack.Item basis="44%">
        <Section fill scrollable title={vehicle ? vehicle.name : 'Vehicle'}>
          <Stack vertical>
            <Stack.Item>
              <ClickSpawnButton tooltip="LMB to spawn the vehicle centered on the clicked turf, MMB on an AI vehicle to delete it" />
            </Stack.Item>
            {!vehicle && (
              <Stack.Item>
                <NoticeBox info>Pick a vehicle on the left</NoticeBox>
              </Stack.Item>
            )}
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Facing">
                  <DirectionDropdown />
                </LabeledList.Item>
                <LabeledList.Item label="Faction">
                  <Dropdown
                    width="100%"
                    disabled={!vehicle_ai}
                    options={vehicle_factions}
                    selected={vehicle_faction}
                    onSelected={(value) =>
                      act('set_vehicle_faction', { faction: value })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Crew">
                  <Dropdown
                    width="100%"
                    disabled={!vehicle_ai}
                    options={crew_presets.map((entry) => ({
                      displayText: entry.name,
                      value: entry.path,
                    }))}
                    selected={vehicle_crew}
                    displayText={
                      crew_presets.find((entry) => entry.path === vehicle_crew)
                        ?.name
                    }
                    onSelected={(value) =>
                      act('set_vehicle_crew', { crew: value })
                    }
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <Button.Checkbox
                checked={vehicle_ai}
                tooltip="The crew sits in the driver and gunner seats, drives and fights"
                onClick={() => act('toggle_vehicle_ai')}
              >
                AI crew
              </Button.Checkbox>
              <Button.Checkbox
                checked={vehicle_infinite_ammo}
                disabled={!vehicle_ai}
                onClick={() => act('toggle_vehicle_infinite_ammo')}
              >
                Infinite ammo
              </Button.Checkbox>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const OrdersTab = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { order_click_intercept, selected_units, selecting_area } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Command">
          <Stack vertical>
            <Stack.Item>
              <Button
                fluid
                fontSize="15px"
                textAlign="center"
                icon="hand-pointer"
                selected={order_click_intercept}
                onClick={() => act('toggle_click_order')}
              >
                Command Mode
              </Button>
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="LMB on AI">
                  Select it, Shift+LMB adds or removes it
                </LabeledList.Item>
                <LabeledList.Item label="LMB on 2 turfs">
                  Select everyone inside the rectangle with these turfs as its
                  opposite corners, Shift adds them to the selection
                </LabeledList.Item>
                <LabeledList.Item label="MMB">
                  Advance there, fighting on the way
                </LabeledList.Item>
                <LabeledList.Item label="Alt+LMB">
                  Rush there, ignoring enemies on the way
                </LabeledList.Item>
              </LabeledList>
              {!!selecting_area && (
                <NoticeBox mt={1} info>
                  Click the opposite corner of the rectangle, the first one is
                  marked blue
                </NoticeBox>
              )}
            </Stack.Item>
            <Stack.Item>
              <Stack>
                <Stack.Item grow>
                  <Button
                    fluid
                    textAlign="center"
                    icon="hand"
                    tooltip="The selected AI stop moving and fight from where they stand"
                    onClick={() => act('order_hold')}
                  >
                    Hold
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    textAlign="center"
                    icon="person-walking"
                    tooltip="The selected AI move on their own again"
                    onClick={() => act('order_release')}
                  >
                    Release
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    textAlign="center"
                    icon="ban"
                    tooltip="Cancel where the selected AI were sent"
                    onClick={() => act('order_stop')}
                  >
                    Stop
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={`Selected (${selected_units.length})`}
          buttons={
            <>
              <Button icon="eye" onClick={() => act('select_in_view')}>
                Select in view
              </Button>
              <Button
                icon="times"
                disabled={!selected_units.length}
                onClick={() => act('clear_selection')}
              >
                Clear
              </Button>
            </>
          }
        >
          {selected_units.length ? (
            selected_units.map((unit) => (
              <Stack key={unit.ref} align="center" pb={0.5}>
                <Stack.Item>
                  <Box width="1.5em" textAlign="center">
                    <Button
                      compact
                      icon={unit.vehicle ? 'truck-monster' : 'person'}
                      tooltip="Jump to"
                      onClick={() => act('jump_to_unit', { ref: unit.ref })}
                    />
                  </Box>
                </Stack.Item>
                <Stack.Item grow>{unit.name}</Stack.Item>
                <Stack.Item width="8em" color="label">
                  {unit.status}
                </Stack.Item>
                <Stack.Item width="6em">
                  <ProgressBar
                    value={unit.health / 100}
                    ranges={{
                      good: [0.7, Infinity],
                      average: [0.3, 0.7],
                      bad: [-Infinity, 0.3],
                    }}
                  >
                    {unit.health}%
                  </ProgressBar>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="times"
                    color="bad"
                    onClick={() => act('deselect_unit', { ref: unit.ref })}
                  />
                </Stack.Item>
              </Stack>
            ))
          ) : (
            <Box textAlign="center" italic color="label">
              Turn on command mode and click AI, or select everyone in view
            </Box>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

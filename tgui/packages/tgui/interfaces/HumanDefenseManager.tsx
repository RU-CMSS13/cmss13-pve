import { BooleanLike, classes } from 'common/react';
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
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type Defense = {
  name: string;
  path: string;
  description: string;
  image: string;
  uses_faction: BooleanLike;
  uses_turned_on: BooleanLike;
};

type Material = {
  name: string;
  image: string;
  folding: BooleanLike;
};

type Tab = 'defenses' | 'fortify';

type BackendContext = {
  defenses: { [key: string]: Defense[] };
  valid_factions: string[];
  directions: string[];
  materials: Material[];
  max_room_size: number;

  tab: Tab;

  selected_defense: string | null;
  faction: string;
  turned_on: BooleanLike;
  place_direction: string;
  placing: BooleanLike;
  can_undo: BooleanLike;

  fortify_material: string;
  fortify_windows: BooleanLike;
  fortify_doors: BooleanLike;
  picking_room: BooleanLike;
  room_picked: BooleanLike;
  room_size: number;
  room_capped: BooleanLike;
  planned_windows: number;
  planned_doors: number;
};

const TABS: { id: Tab; name: string; icon: string }[] = [
  { id: 'defenses', name: 'Defenses', icon: 'shield-halved' },
  { id: 'fortify', name: 'Fortify Room', icon: 'house-lock' },
];

export const HumanDefenseManager = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { tab } = data;

  return (
    <Window title="Human Defense Creator" width={860} height={720}>
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
            {tab === 'defenses' && <DefensesTab />}
            {tab === 'fortify' && <FortifyTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** A sprite of the defense menu spritesheet, which holds 128x128 sprites, shown at the given size */
const DefenseSprite = (props: {
  readonly image: string;
  readonly size: number;
}) => {
  const { image, size } = props;

  return (
    <Box
      width={`${size}px`}
      height={`${size}px`}
      style={{ overflow: 'hidden', margin: '0 auto' }}
    >
      <Box
        className={classes(['defensemenu128x128', image])}
        style={{
          transform: `scale(${size / 128})`,
          transformOrigin: 'top left',
        }}
      />
    </Box>
  );
};

/** A clickable sprite with its name under it */
const SpriteTile = (props: {
  readonly image: string;
  readonly name: string;
  readonly selected: boolean;
  readonly tooltip?: string;
  readonly onClick: () => void;
}) => {
  const { image, name, selected, tooltip, onClick } = props;

  return (
    <Button
      width="7.5em"
      m={0.25}
      textAlign="center"
      selected={selected}
      tooltip={tooltip}
      onClick={onClick}
      style={{ verticalAlign: 'top', whiteSpace: 'normal' }}
    >
      <DefenseSprite image={image} size={48} />
      <Box fontSize="11px" style={{ lineHeight: '1.2', minHeight: '2.4em' }}>
        {name}
      </Box>
    </Button>
  );
};

const UndoButton = (props) => {
  const { data, act } = useBackend<BackendContext>();

  return (
    <Button
      icon="undo"
      disabled={!data.can_undo}
      tooltip="Remove what the last click placed"
      onClick={() => act('undo')}
    >
      Undo
    </Button>
  );
};

const DefensesTab = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { defenses, selected_defense } = data;
  const [search, setSearch] = useState('');

  const searchText = search.trim().toLowerCase();

  return (
    <Stack fill>
      <Stack.Item grow basis={0}>
        <Section fill scrollable title="Defenses">
          <Input
            fluid
            mb={1}
            placeholder="Search..."
            value={search}
            onInput={(e, value) => setSearch(value)}
          />
          {Object.keys(defenses).map((category) => {
            const shown = defenses[category].filter((defense) =>
              defense.name.toLowerCase().includes(searchText),
            );
            if (!shown.length) {
              return null;
            }
            return (
              <Box key={category} mb={1}>
                <Box bold color="label" mb={0.5}>
                  {category}
                </Box>
                {shown.map((defense) => (
                  <SpriteTile
                    key={defense.path}
                    image={defense.image}
                    name={defense.name}
                    selected={defense.path === selected_defense}
                    tooltip={defense.description}
                    onClick={() =>
                      act('select_defense', { path: defense.path })
                    }
                  />
                ))}
              </Box>
            );
          })}
        </Section>
      </Stack.Item>
      <Divider vertical />
      <Stack.Item basis="36%">
        <SelectedDefense />
      </Stack.Item>
    </Stack>
  );
};

const SelectedDefense = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const {
    defenses,
    valid_factions,
    directions,
    selected_defense,
    faction,
    turned_on,
    place_direction,
    placing,
  } = data;

  const defense = Object.values(defenses)
    .flat()
    .find((entry) => entry.path === selected_defense);

  return (
    <Section
      fill
      scrollable
      title={defense ? defense.name : 'Defense'}
      buttons={<UndoButton />}
    >
      <Stack vertical>
        <Stack.Item>
          <Button
            fluid
            fontSize="15px"
            textAlign="center"
            icon="crosshairs"
            selected={placing}
            disabled={!defense}
            onClick={() => act('toggle_placing')}
          >
            Click Place
          </Button>
        </Stack.Item>
        {defense ? (
          <>
            <Stack.Item>
              <DefenseSprite image={defense.image} size={128} />
            </Stack.Item>
            <Stack.Item color="label">{defense.description}</Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Facing">
                  <Dropdown
                    width="100%"
                    options={directions}
                    selected={place_direction}
                    onSelected={(value) =>
                      act('set_direction', { direction: value })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Faction">
                  <Dropdown
                    width="100%"
                    disabled={!defense.uses_faction}
                    options={valid_factions}
                    selected={faction}
                    onSelected={(value) =>
                      act('set_faction', { faction: value })
                    }
                  />
                </LabeledList.Item>
              </LabeledList>
              <Button.Checkbox
                mt={0.5}
                checked={turned_on}
                disabled={!defense.uses_turned_on}
                onClick={() => act('toggle_turned_on')}
              >
                Turned on
              </Button.Checkbox>
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="LMB">Place it there</LabeledList.Item>
                <LabeledList.Item label="Shift+LMB">
                  Place a line of them from the last one, up to 15 tiles
                </LabeledList.Item>
                <LabeledList.Item label="MMB">
                  Remove a defense, barricade or mine
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                textAlign="center"
                icon="person-arrow-down-to-line"
                onClick={() => act('place_here')}
              >
                Place where you stand
              </Button>
            </Stack.Item>
          </>
        ) : (
          <Stack.Item>
            <NoticeBox info>Pick a defense on the left</NoticeBox>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

const FortifyTab = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const { materials, fortify_material, fortify_windows, fortify_doors } = data;

  const material = materials.find((entry) => entry.name === fortify_material);

  return (
    <Stack fill>
      <Stack.Item grow basis={0}>
        <Section fill scrollable title="Barricades">
          {materials.map((entry) => (
            <SpriteTile
              key={entry.name}
              image={entry.image}
              name={entry.name}
              selected={entry.name === fortify_material}
              onClick={() => act('set_material', { material: entry.name })}
            />
          ))}
          <Divider />
          <Button.Checkbox
            checked={fortify_windows}
            onClick={() => act('toggle_windows')}
          >
            Windows
          </Button.Checkbox>
          <Button.Checkbox
            checked={fortify_doors}
            onClick={() => act('toggle_doors')}
          >
            Doors
          </Button.Checkbox>
          <Box color="label" mt={1}>
            {material?.folding
              ? 'Doors get a raised folding barricade that can be lowered to get through.'
              : 'There is no folding version of these, so doors are blocked by the same barricade.'}
          </Box>
        </Section>
      </Stack.Item>
      <Divider vertical />
      <Stack.Item basis="40%">
        <RoomSection />
      </Stack.Item>
    </Stack>
  );
};

const RoomSection = (props) => {
  const { data, act } = useBackend<BackendContext>();
  const {
    picking_room,
    room_picked,
    room_size,
    room_capped,
    planned_windows,
    planned_doors,
    max_room_size,
  } = data;

  return (
    <Section fill scrollable title="Room" buttons={<UndoButton />}>
      <Stack vertical>
        <Stack.Item>
          <Button
            fluid
            fontSize="15px"
            textAlign="center"
            icon="crosshairs"
            selected={picking_room}
            onClick={() => act('toggle_room_picking')}
          >
            Pick Room
          </Button>
        </Stack.Item>
        {room_picked ? (
          <>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Tiles">{room_size}</LabeledList.Item>
                <LabeledList.Item label="Windows">
                  {planned_windows} barricades
                </LabeledList.Item>
                <LabeledList.Item label="Doors">
                  {planned_doors} barricades
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            {!!room_capped && (
              <Stack.Item>
                <NoticeBox warning>
                  The room is not closed or bigger than {max_room_size} tiles.
                  Only the part marked blue gets fortified.
                </NoticeBox>
              </Stack.Item>
            )}
            <Stack.Item>
              <Stack>
                <Stack.Item grow>
                  <Button
                    fluid
                    textAlign="center"
                    icon="check"
                    color="good"
                    disabled={!planned_windows && !planned_doors}
                    onClick={() => act('fortify')}
                  >
                    Fortify
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    textAlign="center"
                    icon="times"
                    onClick={() => act('cancel_room')}
                  >
                    Cancel
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </>
        ) : (
          <Stack.Item>
            <NoticeBox info>
              Turn on room picking and click a floor inside a room. The room
              gets marked blue and see-through barricades show where they would
              go, then press Fortify.
            </NoticeBox>
          </Stack.Item>
        )}
        <Stack.Item color="label">
          Barricades go inside the room, in front of every window and door
          leading out of it. Ones already facing that way are kept.
        </Stack.Item>
      </Stack>
    </Section>
  );
};

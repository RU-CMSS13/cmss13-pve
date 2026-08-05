import { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Divider, Section, Stack } from '../components';
import { Window } from '../layouts';

type LoadoutPickerData = {
  categories: {
    name: string;
    items: LoadoutItem[];
  }[];
  points: number;
  max_points: number;
  loadout: LoadoutItem[];
};

type LoadoutItem = {
  name: string;
  cost: number;
  desc: string;
  origin: string;
  roles: string | null;
};

export const LoadoutPicker = () => {
  const { data, act } = useBackend<LoadoutPickerData>();

  const { categories, points, max_points, loadout } = data;

  const [selected, setSelected] = useState(categories[0]);

  return (
    <Window height={620} width={780} theme="crtblue">
      <Window.Content className="LoadoutPicker">
        <Stack fill>
          <Stack.Item width="260px" shrink={0}>
            <Stack vertical fill>
              <Stack.Item>
                <Section scrollable height="220px">
                  <Stack vertical height="200px">
                    {categories.map((category) => (
                      <Stack.Item key={category.name}>
                        <Button
                          fluid
                          selected={selected === category}
                          onClick={() => setSelected(category)}
                          style={{
                            whiteSpace: 'normal',
                            wordBreak: 'break-word',
                          }}
                        >
                          {category.name}
                        </Button>
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item grow minHeight="0">
                <Section
                  title={`Loadout (${points}/${max_points} points)`}
                  fill
                  scrollable
                  buttons={
                    loadout.length > 0 && (
                      <Button
                        icon="trash"
                        color="bad"
                        tooltip="Clear loadout"
                        onClick={() => act('clear')}
                      />
                    )
                  }
                >
                  <ItemList items={loadout} loadout />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <Section title={selected.name} fill width="100%" scrollable>
              <ItemList items={selected.items} />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemList = (props: {
  readonly items: LoadoutItem[];
  readonly loadout?: boolean;
}) => {
  const { items, loadout } = props;

  if (!items.length) {
    return (
      <Box textAlign="center" italic color="label">
        {loadout ? 'No items selected' : 'Nothing here'}
      </Box>
    );
  }

  return (
    <Box>
      <Divider />
      <Box mt={1}>
        {items.map((item) => (
          <ItemRow key={item.name} item={item} loadout={loadout} />
        ))}
      </Box>
    </Box>
  );
};

const ItemRow = (props: {
  readonly item: LoadoutItem;
  readonly loadout?: boolean;
}) => {
  const { item, loadout } = props;
  const { name, cost, desc, origin, roles } = item;

  const { data, act } = useBackend<LoadoutPickerData>();
  const { points, max_points } = data;

  const atLimit = points + cost > max_points;

  return (
    <Box pb="8px">
      <Button
        fontSize="14px"
        textAlign="center"
        width="100%"
        color={loadout ? 'bad' : undefined}
        disabled={!loadout && atLimit}
        style={{
          whiteSpace: 'normal',
          wordBreak: 'break-word',
        }}
        tooltip={
          <Box maxWidth="200px">
            {desc && <Box>{desc}</Box>}
            <Box color="label" mt={desc ? '4px' : 0}>
              Origin: {origin}
            </Box>
            {roles && (
              <Box color="label" mt="4px">
                Role: {roles}
              </Box>
            )}
          </Box>
        }
        tooltipPosition="top"
        onClick={() => act(loadout ? 'remove' : 'add', { name: name })}
      >
        {name} ({cost} pt{cost === 1 ? '' : 's'})
      </Button>
    </Box>
  );
};

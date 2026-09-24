import { hexToHsva, HsvaColor, hsvaToHex } from 'common/color';
import { BooleanLike } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  ColorBox,
  Dropdown,
  Input,
  Modal,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';
import { ColorSelector } from './ColorPickerModal';

type HairPickerData = {
  hair_icon: string;
  hair_styles: { name: string; icon: string }[];
  hair_style: string;
  hair_color: string;

  facial_hair_icon: string;
  facial_hair_styles: { name: string; icon: string }[];
  facial_hair_style: string;
  facial_hair_color: string;

  gradient_available: BooleanLike;
  gradient_styles: string[];
  gradient_style: string;
  gradient_color: string;
};

export const HairPicker = () => {
  const { act, data } = useBackend<HairPickerData>();

  const {
    hair_style,
    hair_styles,
    hair_color,
    facial_hair_style,
    facial_hair_styles,
    facial_hair_color,
    gradient_available,
    gradient_style,
    gradient_styles,
    gradient_color,
  } = data;

  const [colorPicker, setColorPicker] = useState<
    'hair' | 'facial_hair' | 'gradient' | false
  >(false);

  let height = 370;
  if (facial_hair_styles.length > 1) {
    height = height + 330;
  }

  if (gradient_available) {
    height = height + 85;
  }

  let defaultColor = '#000000';
  switch (colorPicker) {
    case 'hair':
      defaultColor = hair_color;
      break;
    case 'facial_hair':
      defaultColor = facial_hair_color;
      break;
    case 'gradient':
      defaultColor = gradient_color;
      break;

    default:
      break;
  }

  return (
    <Window width={400} height={height} theme={'crtblue'}>
      <Window.Content className="HairPicker">
        <PickerElement
          name="Hair"
          hair={hair_styles}
          active={hair_style}
          color={hair_color}
          setColor={setColorPicker}
          action="hair"
        />
        {!!(facial_hair_styles.length > 1) && (
          <PickerElement
            name="Facial Hair"
            hair={facial_hair_styles}
            active={facial_hair_style}
            color={facial_hair_color}
            setColor={setColorPicker}
            action="facial_hair"
          />
        )}
        {!!gradient_available && (
          <Section
            title="Gradient"
            buttons={
              <Button onClick={() => setColorPicker('gradient')}>
                <ColorBox color={gradient_color} mr={1} />
                Color
              </Button>
            }
          >
            <Dropdown
              options={gradient_styles}
              selected={gradient_style}
              onSelected={(selected) => act('gradient', { name: selected })}
              over
            />
          </Section>
        )}
        {!!colorPicker && (
          <ColorPicker
            type={colorPicker}
            close={() => setColorPicker(false)}
            default_color={defaultColor}
          />
        )}
      </Window.Content>
    </Window>
  );
};

const ColorPicker = (props: {
  readonly type: 'hair' | 'facial_hair' | 'gradient';
  readonly close: () => void;
  readonly default_color: string;
}) => {
  const { act } = useBackend();

  const { type, close, default_color } = props;

  const [currentColor, setCurrentColor] = useState<HsvaColor>(
    hexToHsva(default_color || '#000000'),
  );

  return (
    <Modal width="100%">
      <Box width="350px">
        <Stack vertical>
          <Stack.Item>
            <ColorSelector
              color={currentColor}
              setColor={setCurrentColor}
              defaultColor={default_color}
              onConfirm={() => {
                close();
                act(`${type}_color`, { color: hsvaToHex(currentColor) });
              }}
            />
          </Stack.Item>
        </Stack>
      </Box>
    </Modal>
  );
};

const PickerElement = (props: {
  readonly name: string;
  readonly active: string;
  readonly hair: { icon: string; name: string }[];
  readonly action: 'hair' | 'facial_hair';
  readonly setColor: (_) => void;
  readonly color: string;
}) => {
  const { name, hair, active, action, setColor, color } = props;

  const { act } = useBackend();

  const [search, setSearch] = useState('');

  const filtered = hair.filter((val) =>
    val.name.toLowerCase().includes(search.toLowerCase()),
  );

  return (
    <Section
      title={name}
      buttons={
        <Button onClick={() => setColor(action)}>
          <ColorBox color={color} mr={1} />
          Color
        </Button>
      }
    >
      <Input
        fluid
        mb={1}
        placeholder="Search..."
        value={search}
        onInput={(_, value) => setSearch(value)}
      />
      <Box height="240px" overflowY="auto">
        {filtered.map((hair) => (
          <Button
            key={hair.name}
            fluid
            selected={active === hair.icon}
            onClick={() => act(action, { name: hair.name })}
          >
            {hair.name}
          </Button>
        ))}
      </Box>
    </Section>
  );
};

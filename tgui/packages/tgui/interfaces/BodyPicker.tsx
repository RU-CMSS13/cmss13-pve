import { useBackend } from '../backend';
import { Button, ColorBox, Section, Stack } from '../components';
import { Window } from '../layouts';

type PickerData = {
  icon: string;
  body_types: { name: string; icon: string }[];
  skin_colors: { name: string; icon: string; color: string }[];
  body_sizes: { name: string; icon: string }[];

  body_type: string;
  skin_color: string;
  body_size: string;

  body_presentation: string;
};

export const BodyPicker = () => {
  return (
    <Window width={420} height={380} theme={'crtblue'}>
      <Window.Content className="BodyPicker">
        <Stack fill>
          <Stack.Item grow>
            <Stack vertical fill>
              <Stack.Item>
                <TypePicker toUse="type" />
              </Stack.Item>
              <Stack.Item>
                <TypePicker toUse="size" />
              </Stack.Item>
              <Stack.Item>
                <PresentationPicker />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <ColorOptions />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const TypePicker = (props: { readonly toUse: 'type' | 'size' }) => {
  const { data, act } = useBackend<PickerData>();

  const { toUse } = props;

  const { body_type, body_types, body_size, body_sizes } = data;

  const toIterate = toUse === 'type' ? body_types : body_sizes;

  const active = toUse === 'type' ? body_type : body_size;

  return (
    <Section title={toUse === 'type' ? 'Body Type' : 'Body Size'}>
      {toIterate.map((type) => (
        <Button
          key={type.name}
          fluid
          selected={active === type.icon}
          onClick={() => act(toUse, { name: type.name })}
        >
          {type.name}
        </Button>
      ))}
    </Section>
  );
};

const PresentationPicker = () => {
  const { data, act } = useBackend<PickerData>();

  const { body_presentation } = data;

  return (
    <Section title="Body Presentation">
      <Stack>
        <Stack.Item grow>
          <Button
            fluid
            icon="mars"
            selected={body_presentation === 'm'}
            onClick={() => act('body_presentation', { picked: 'm' })}
          >
            Male
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            icon="venus"
            selected={body_presentation === 'f'}
            onClick={() => act('body_presentation', { picked: 'f' })}
          >
            Female
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const ColorOptions = () => {
  const { data, act } = useBackend<PickerData>();

  const { skin_color, skin_colors } = data;

  return (
    <Section title="Skin Color" fill scrollable>
      {skin_colors.map((color) => (
        <Button
          key={color.name}
          fluid
          selected={skin_color === color.icon}
          onClick={() => act('color', { name: color.name })}
        >
          <ColorBox color={color.color} mr={1} />
          {color.name}
        </Button>
      ))}
    </Section>
  );
};

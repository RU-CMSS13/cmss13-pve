import { useBackend } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Section,
  Slider,
  Stack,
} from '../components';
import { Window } from '../layouts';

export const GameMaster = (props, context) => {
  const { data, act } = useBackend();

  return (
    <Window width={400} height={500}>
      <Window.Content scrollable>
        <Stack direction="column" grow>
          <GameMasterSpawningPanel />

          <GameMasterObjectivePanel />

          <GameMasterCommunicationPanel />

          <GameMasterRecordPanel />
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const GameMasterSpawningPanel = (props, context) => {
  const { data, act } = useBackend();

  return (
    <Section title="Spawning">
      <Button
        ml={1}
        onClick={() => {
          act('open_xeno_spawner');
        }}
      >
        Xeno Spawner Panel
      </Button>
    </Section>
  );
};

export const GameMasterObjectivePanel = (props, context) => {
  const { data, act } = useBackend();

  return (
    <Section title="Objective" mb={1}>
      <Stack direction="column">
        <Stack.Item>
          <Button
            ml={1}
            selected={data.objective_click_intercept}
            onClick={() => {
              act('toggle_click_objective');
            }}
          >
            Click Objective
          </Button>
        </Stack.Item>
        {data.game_master_objectives && (
          <Stack.Item>
            <Collapsible title="Objectives">
              <Stack vertical>
                {data.game_master_objectives.map((val) => {
                  if (val) {
                    return (
                      <Stack.Item key={val.object_name}>
                        <Divider />
                        <Stack>
                          <Stack.Item align="center">
                            <Button
                              onClick={() => {
                                act('jump_to', { val });
                              }}
                            >
                              {val.object_name}
                            </Button>
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              color="bad"
                              onClick={() => {
                                act('remove_objective', { val });
                              }}
                            >
                              X
                            </Button>
                          </Stack.Item>
                          <Stack.Item grow pl={1} py={0.25} fontSize="12px">
                            {val.objective_info}
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    );
                  }
                })}
                <Divider />
              </Stack>
            </Collapsible>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

export const GameMasterCommunicationPanel = (props, context) => {
  const { data, act } = useBackend();

  return (
    <Section title="Communication">
      <Stack direction="column">
        <Stack.Item>
          <Button
            ml={1}
            onClick={() => {
              act('use_game_master_phone');
            }}
          >
            Game Master Phone
          </Button>
        </Stack.Item>
        <Stack.Item mt={1}>Radio Clarity</Stack.Item>
        <Stack.Item>
          <Slider
            maxValue={100}
            minValue={0}
            value={data.radio_clarity}
            stepPixelSize={3}
            suppressFlicker={2500}
            onChange={(e, clarity) => {
              act('set_radio_clarity', { clarity });
            }}
          />
        </Stack.Item>
        <Stack.Item>
          <Box fontFamily="monospace">{`"${data.radio_clarity_example}"`}</Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const GameMasterRecordPanel = (props, context) => {
  const { data, act } = useBackend();

  return (
    <Section title="Records">
      <Stack.Item>
        <Button
          ml={1}
          selected={data.record_create_click_intercept}
          onClick={() => {
            act('toggle_click_record_creation');
          }}
        >
          Create record for person on click
        </Button>
      </Stack.Item>
    </Section>
  );
};

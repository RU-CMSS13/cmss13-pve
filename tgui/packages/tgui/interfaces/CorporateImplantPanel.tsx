import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Box, Button, NoticeBox, Section, Table } from '../components';
import { Window } from '../layouts';

type Implant = {
  name: string;
  job: string;
  status: string;
  area: string;
  player: BooleanLike;
  ref: string;
};

type Data = {
  armed: BooleanLike;
  implants: Implant[];
};

const statusColor = (status: string) => {
  switch (status) {
    case 'Dead':
      return 'grey';
    case 'Unconscious':
      return 'average';
    default:
      return 'good';
  }
};

export const CorporateImplantPanel = () => {
  const { act, data } = useBackend<Data>();
  const { armed, implants } = data;

  return (
    <Window width={700} height={450}>
      <Window.Content scrollable>
        <Section
          title="Corporate Implants"
          buttons={
            <Button
              icon={armed ? 'lock-open' : 'lock'}
              color={armed ? 'bad' : 'default'}
              onClick={() => act('toggle_armed')}
            >
              {armed ? 'Detonation Unlocked' : 'Detonation Locked'}
            </Button>
          }
        >
          {armed ? (
            <NoticeBox danger>
              Detonation is unlocked. Pressing Detonate will blow the head off
              immediately.
            </NoticeBox>
          ) : null}
          {implants.length === 0 ? (
            <NoticeBox>No active corporate implants.</NoticeBox>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Name</Table.Cell>
                <Table.Cell>Job</Table.Cell>
                <Table.Cell>Status</Table.Cell>
                <Table.Cell>Location</Table.Cell>
                <Table.Cell collapsing />
              </Table.Row>
              {implants.map((implant) => (
                <Table.Row key={implant.ref} className="candystripe">
                  <Table.Cell>
                    {implant.name}
                    {implant.player ? null : (
                      <Box inline color="label" ml={1}>
                        (AI / no client)
                      </Box>
                    )}
                  </Table.Cell>
                  <Table.Cell>{implant.job}</Table.Cell>
                  <Table.Cell color={statusColor(implant.status)}>
                    {implant.status}
                  </Table.Cell>
                  <Table.Cell>{implant.area}</Table.Cell>
                  <Table.Cell collapsing>
                    <Button
                      icon="eye"
                      tooltip="Jump to"
                      onClick={() => act('jump', { ref: implant.ref })}
                    />
                    <Button
                      icon="bolt"
                      color="average"
                      disabled={implant.status === 'Dead'}
                      onClick={() => act('warn', { ref: implant.ref })}
                    >
                      Warn
                    </Button>
                    <Button
                      icon="skull"
                      color="bad"
                      disabled={!armed}
                      onClick={() => act('detonate', { ref: implant.ref })}
                    >
                      Detonate
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

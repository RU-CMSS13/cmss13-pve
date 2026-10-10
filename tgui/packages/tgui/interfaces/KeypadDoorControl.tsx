import { classes } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../backend';
import { Box } from '../components';
import { Window } from '../layouts';

type Data = {
  code_length: number;
  status: 'idle' | 'granted' | 'denied' | 'locked';
  style: 'uscm' | 'upp';
};

const KEY_CLEAR = 'CLR';
const KEY_ENTER = 'ENT';

const KEYS = [
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  KEY_CLEAR,
  '0',
  KEY_ENTER,
];

const THEMES = {
  uscm: 'crtgreen',
  upp: 'crtred',
};

const HEADER_TEXT = {
  idle: 'READY',
  granted: 'BUSY',
  denied: 'BUSY',
  locked: 'OFFLINE',
};

const STATUS_TEXT = {
  idle: 'AWAITING INPUT',
  granted: 'ACCESS GRANTED',
  denied: 'ACCESS DENIED',
  locked: 'LOCKED',
};

export const KeypadDoorControl = () => {
  const { act, data } = useBackend<Data>();
  const { code_length, status, style } = data;
  const [code, setCode] = useState('');

  const locked = status !== 'idle';

  const pressKey = (key: string) => {
    act('keypress');
    if (key === KEY_CLEAR) {
      setCode('');
      return;
    }
    if (key === KEY_ENTER) {
      act('submit', { code });
      setCode('');
      return;
    }
    if (code.length < code_length) {
      setCode(code + key);
    }
  };

  return (
    <Window width={260} height={410} theme={THEMES[style] || THEMES.uscm}>
      <Window.Content>
        <Box className="KeypadDoorControl">
          <Box className="KeypadDoorControl__screen">
            <Box className="KeypadDoorControl__header">
              <Box>SECURE LOCK</Box>
              <Box>{HEADER_TEXT[status]}</Box>
            </Box>
            <Box className="KeypadDoorControl__entry">
              {Array.from({ length: code_length }, (_, i) => (
                <Box
                  key={i}
                  className={classes([
                    'KeypadDoorControl__digit',
                    i > code.length && 'KeypadDoorControl__digit--empty',
                    i === code.length &&
                      !locked &&
                      'KeypadDoorControl__digit--cursor',
                  ])}
                >
                  {code[i] || '_'}
                </Box>
              ))}
            </Box>
            <Box
              className={classes([
                'KeypadDoorControl__status',
                `KeypadDoorControl__status--${status}`,
              ])}
            >
              {STATUS_TEXT[status]}
            </Box>
          </Box>
          <Box className="KeypadDoorControl__keys">
            {KEYS.map((key) => (
              <Box
                key={key}
                className={classes([
                  'KeypadDoorControl__key',
                  key.length > 1 && 'KeypadDoorControl__key--action',
                  (locked || (key === KEY_ENTER && !code.length)) &&
                    'KeypadDoorControl__key--disabled',
                ])}
                onClick={() => pressKey(key)}
              >
                {key}
              </Box>
            ))}
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};

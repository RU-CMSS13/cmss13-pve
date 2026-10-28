import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

type Marker = {
  x: number;
  y: number;
  radius: number;
  color: string;
};

type Data = {
  mapImage: string | null;
  // Flat list of lines: x1, y1, x2, y2, stroke
  svgData: (number | string)[] | null;
  markers: Marker[];
  mapSize: number;
  canChangeZ: boolean;
};

// Drawings are stored in the coordinates of the canvas they were drawn on
const CANVAS_SIZE = 684;

const parseLines = (svgData: (number | string)[] | null) => {
  const lines: {
    x1: number;
    y1: number;
    x2: number;
    y2: number;
    stroke: string;
  }[] = [];
  if (!svgData) {
    return lines;
  }
  for (let i = 0; i + 4 < svgData.length; i += 5) {
    lines.push({
      x1: Number(svgData[i]),
      y1: Number(svgData[i + 1]),
      x2: Number(svgData[i + 2]),
      y2: Number(svgData[i + 3]),
      stroke: String(svgData[i + 4]),
    });
  }
  return lines;
};

export const PaperTacticalMap = (props) => {
  const { act, data } = useBackend<Data>();
  const { mapImage, svgData, markers, mapSize, canChangeZ } = data;

  return (
    <Window width={700} height={760} theme="crtblue">
      <Window.Content>
        <Section
          fill
          textAlign="center"
          title="Tactical Map"
          buttons={
            canChangeZ ? (
              <>
                <Button
                  icon="arrow-up"
                  onClick={() => act('changeZ', { amount: 1 })}
                >
                  Up
                </Button>
                <Button
                  icon="arrow-down"
                  onClick={() => act('changeZ', { amount: -1 })}
                >
                  Down
                </Button>
              </>
            ) : null
          }
        >
          {mapImage ? (
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="100%"
              height="100%"
              viewBox={`0 0 ${CANVAS_SIZE} ${CANVAS_SIZE}`}
              preserveAspectRatio="xMidYMid meet"
            >
              <image
                href={mapImage}
                width={CANVAS_SIZE}
                height={CANVAS_SIZE}
                style={{ imageRendering: 'pixelated' }}
              />
              {parseLines(svgData).map((line, index) => (
                <line
                  key={index}
                  x1={line.x1}
                  y1={line.y1}
                  x2={line.x2}
                  y2={line.y2}
                  stroke={line.stroke}
                  strokeWidth={4}
                  strokeLinecap="round"
                />
              ))}
              <g transform={`scale(${CANVAS_SIZE / mapSize})`}>
                {markers.map((marker, index) => (
                  <circle
                    key={index}
                    cx={marker.x}
                    cy={marker.y}
                    r={marker.radius}
                    fill={marker.color}
                    fillOpacity={0.2}
                    stroke={marker.color}
                    strokeWidth={1.5}
                  />
                ))}
              </g>
            </svg>
          ) : (
            <Box my="40%" textAlign="center" fontSize="30px">
              Loading map...
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

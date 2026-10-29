import { MouseEvent, ReactNode, useEffect, useRef, useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  Input,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type Marker = {
  x: number;
  y: number;
  radius: number;
  color: string;
};

type NoteStroke = {
  color: string;
  // Flat list of points: x1, y1, x2, y2, ...
  points: number[];
};

type NoteMarker = {
  type: string;
  x: number;
  y: number;
  label: string;
};

type Data = {
  mapImage: string | null;
  // Flat list of lines: x1, y1, x2, y2, stroke
  svgData: (number | string)[] | null;
  markers: Marker[];
  mapSize: number;
  canChangeZ: boolean;
  canWrite: boolean;
  noteStrokes: NoteStroke[];
  noteMarkers: NoteMarker[];
  noteColors: string[];
  noteMarkerTypes: string[];
  maxStrokePoints: number;
  maxLabelLength: number;
};

type Point = { x: number; y: number };

type Tool = 'pen' | 'marker' | 'eraser';

// Drawings are stored in the coordinates of the canvas they were drawn on
const CANVAS_SIZE = 684;
// Least distance between two points of a drawn line
const STROKE_STEP = 6;
// How close a click has to be to a line or marker to erase it
const ERASE_DISTANCE = 12;
const MARKER_SIZE = 10;

const MARKER_NAMES: Record<string, string> = {
  danger: 'Danger',
  enemy: 'Enemy',
  objective: 'Objective',
  rally: 'Rally point',
  mine: 'Mines',
  wounded: 'Wounded',
};

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

const toPolyline = (points: number[]) => {
  const pairs: string[] = [];
  for (let i = 0; i + 1 < points.length; i += 2) {
    pairs.push(`${points[i]},${points[i + 1]}`);
  }
  return pairs.join(' ');
};

const distanceToSegment = (
  point: Point,
  x1: number,
  y1: number,
  x2: number,
  y2: number,
) => {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const lengthSquared = dx * dx + dy * dy;
  const t = lengthSquared
    ? Math.max(
        0,
        Math.min(
          1,
          ((point.x - x1) * dx + (point.y - y1) * dy) / lengthSquared,
        ),
      )
    : 0;
  return Math.hypot(point.x - (x1 + t * dx), point.y - (y1 + t * dy));
};

const MarkerIcon = (props: { readonly type: string }) => {
  const s = MARKER_SIZE;
  switch (props.type) {
    case 'danger':
      return (
        <>
          <polygon
            points={`0,${-s} ${s},${s * 0.8} ${-s},${s * 0.8}`}
            fill="#f5c400"
            stroke="#000"
            strokeWidth={1.5}
          />
          <text
            y={s * 0.6}
            textAnchor="middle"
            fontSize={s * 1.3}
            fontWeight="bold"
            fill="#000"
          >
            !
          </text>
        </>
      );
    case 'enemy':
      return (
        <>
          <circle r={s} fill="#fc0000" stroke="#000" strokeWidth={1.5} />
          <path
            d={`M${-s / 2},${-s / 2} L${s / 2},${s / 2} M${s / 2},${-s / 2} L${-s / 2},${s / 2}`}
            stroke="#fff"
            strokeWidth={2.5}
            strokeLinecap="round"
          />
        </>
      );
    case 'objective':
      return (
        <>
          <line
            x1={-s / 2}
            y1={s}
            x2={-s / 2}
            y2={-s}
            stroke="#000"
            strokeWidth={2}
          />
          <polygon
            points={`${-s / 2},${-s} ${s},${-s / 2} ${-s / 2},0`}
            fill="#02c245"
            stroke="#000"
            strokeWidth={1.5}
          />
        </>
      );
    case 'rally':
      return (
        <>
          <circle
            r={s}
            fill="rgba(5, 97, 245, 0.3)"
            stroke="#0561f5"
            strokeWidth={2.5}
          />
          <circle r={s / 3} fill="#0561f5" />
        </>
      );
    case 'mine':
      return (
        <>
          <polygon
            points={`0,${-s} ${s},0 0,${s} ${-s},0`}
            fill="#f59a07"
            stroke="#000"
            strokeWidth={1.5}
          />
          <circle r={s / 3} fill="#000" />
        </>
      );
    case 'wounded':
      return (
        <>
          <rect
            x={-s}
            y={-s}
            width={s * 2}
            height={s * 2}
            fill="#fff"
            stroke="#000"
            strokeWidth={1.5}
          />
          <path
            d={`M0,${-s * 0.6} L0,${s * 0.6} M${-s * 0.6},0 L${s * 0.6},0`}
            stroke="#fc0000"
            strokeWidth={3}
          />
        </>
      );
    default:
      return <circle r={s / 2} fill="#000" />;
  }
};

type MapSceneProps = {
  readonly children?: ReactNode;
  readonly svgRef?: React.RefObject<SVGSVGElement>;
  readonly cursor?: string;
  readonly onMouseDown?: (event: MouseEvent<SVGSVGElement>) => void;
  readonly onMouseMove?: (event: MouseEvent<SVGSVGElement>) => void;
  readonly onMouseUp?: (event: MouseEvent<SVGSVGElement>) => void;
};

// Terrain with whatever is drawn over it, and the compass circles on top
const MapScene = (props: MapSceneProps) => {
  const { data } = useBackend<Data>();
  const { mapImage, markers, mapSize } = data;

  if (!mapImage) {
    return (
      <Box my="40%" textAlign="center" fontSize="30px">
        Loading map...
      </Box>
    );
  }

  return (
    <svg
      ref={props.svgRef}
      xmlns="http://www.w3.org/2000/svg"
      width="100%"
      height="100%"
      viewBox={`0 0 ${CANVAS_SIZE} ${CANVAS_SIZE}`}
      preserveAspectRatio="xMidYMid meet"
      style={{ cursor: props.cursor, userSelect: 'none' }}
      onMouseDown={props.onMouseDown}
      onMouseMove={props.onMouseMove}
      onMouseUp={props.onMouseUp}
      onMouseLeave={props.onMouseUp}
    >
      <image
        href={mapImage}
        width={CANVAS_SIZE}
        height={CANVAS_SIZE}
        style={{ imageRendering: 'pixelated' }}
      />
      {props.children}
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
            pointerEvents="none"
          />
        ))}
      </g>
    </svg>
  );
};

const CommandPlan = (props) => {
  const { data } = useBackend<Data>();

  return (
    <MapScene>
      {parseLines(data.svgData).map((line, index) => (
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
    </MapScene>
  );
};

const Notes = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    canWrite,
    noteStrokes,
    noteMarkers,
    noteColors,
    noteMarkerTypes,
    maxStrokePoints,
    maxLabelLength,
  } = data;

  const [tool, setTool] = useState<Tool>('pen');
  const [color, setColor] = useState(noteColors[1]);
  const [markerType, setMarkerType] = useState(noteMarkerTypes[0]);
  const [label, setLabel] = useState('');
  // The line being drawn, kept until the server sends it back
  const [stroke, setStroke] = useState<number[] | null>(null);
  const drawing = useRef(false);
  const svgRef = useRef<SVGSVGElement>(null);

  useEffect(() => {
    if (!drawing.current) {
      setStroke(null);
    }
  }, [noteStrokes]);

  const toCanvas = (event: MouseEvent<SVGSVGElement>): Point | null => {
    const svg = svgRef.current;
    const matrix = svg?.getScreenCTM();
    if (!svg || !matrix) {
      return null;
    }
    const point = svg.createSVGPoint();
    point.x = event.clientX;
    point.y = event.clientY;
    const { x, y } = point.matrixTransform(matrix.inverse());
    return {
      x: Math.max(0, Math.min(CANVAS_SIZE, x)),
      y: Math.max(0, Math.min(CANVAS_SIZE, y)),
    };
  };

  const finishStroke = (points: number[] | null = stroke) => {
    if (!drawing.current) {
      return;
    }
    drawing.current = false;
    if (points && points.length >= 4) {
      act('addStroke', { color, points });
    } else {
      setStroke(null);
    }
  };

  const erase = (point: Point) => {
    const markerIndex = noteMarkers.findIndex(
      (marker) =>
        Math.hypot(marker.x - point.x, marker.y - point.y) <= ERASE_DISTANCE,
    );
    if (markerIndex !== -1) {
      act('eraseMarker', { index: markerIndex });
      return;
    }
    const strokeIndex = noteStrokes.findIndex((noteStroke) => {
      const points = noteStroke.points;
      for (let i = 0; i + 3 < points.length; i += 2) {
        const distance = distanceToSegment(
          point,
          points[i],
          points[i + 1],
          points[i + 2],
          points[i + 3],
        );
        if (distance <= ERASE_DISTANCE) {
          return true;
        }
      }
      return false;
    });
    if (strokeIndex !== -1) {
      act('eraseStroke', { index: strokeIndex });
    }
  };

  const handleMouseDown = (event: MouseEvent<SVGSVGElement>) => {
    if (!canWrite || event.button !== 0) {
      return;
    }
    const point = toCanvas(event);
    if (!point) {
      return;
    }
    switch (tool) {
      case 'pen':
        drawing.current = true;
        setStroke([point.x, point.y]);
        break;
      case 'marker':
        act('addMarker', { type: markerType, x: point.x, y: point.y, label });
        break;
      case 'eraser':
        erase(point);
        break;
    }
  };

  const handleMouseMove = (event: MouseEvent<SVGSVGElement>) => {
    if (!drawing.current || !stroke) {
      return;
    }
    if (event.buttons === 0) {
      // Released outside the window
      finishStroke(stroke);
      return;
    }
    const point = toCanvas(event);
    if (!point) {
      return;
    }
    const lastX = stroke[stroke.length - 2];
    const lastY = stroke[stroke.length - 1];
    if (Math.hypot(point.x - lastX, point.y - lastY) < STROKE_STEP) {
      return;
    }
    const newStroke = [...stroke, point.x, point.y];
    setStroke(newStroke);
    if (newStroke.length / 2 >= maxStrokePoints) {
      finishStroke(newStroke);
    }
  };

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section>
          {canWrite ? (
            <Stack align="center" wrap>
              <Stack.Item>
                <Button
                  icon="pen"
                  selected={tool === 'pen'}
                  onClick={() => setTool('pen')}
                >
                  Draw
                </Button>
                <Button
                  icon="map-marker-alt"
                  selected={tool === 'marker'}
                  onClick={() => setTool('marker')}
                >
                  Marker
                </Button>
                <Button
                  icon="eraser"
                  selected={tool === 'eraser'}
                  onClick={() => setTool('eraser')}
                >
                  Erase
                </Button>
              </Stack.Item>
              <Stack.Item>
                {tool === 'marker' ? (
                  <Stack align="center">
                    <Stack.Item>
                      <Dropdown
                        width="9rem"
                        options={noteMarkerTypes.map((type) => ({
                          value: type,
                          displayText: MARKER_NAMES[type] || type,
                        }))}
                        selected={markerType}
                        displayText={MARKER_NAMES[markerType] || markerType}
                        onSelected={(value) => setMarkerType(value)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Input
                        width="9rem"
                        placeholder="Label"
                        maxLength={maxLabelLength}
                        value={label}
                        onInput={(event, value) => setLabel(value)}
                      />
                    </Stack.Item>
                  </Stack>
                ) : (
                  noteColors.map((noteColor) => (
                    <Button
                      key={noteColor}
                      selected={color === noteColor}
                      onClick={() => setColor(noteColor)}
                    >
                      <Box
                        inline
                        width="12px"
                        height="12px"
                        backgroundColor={noteColor}
                      />
                    </Button>
                  ))
                )}
              </Stack.Item>
              <Stack.Item grow textAlign="right">
                <Button
                  icon="undo"
                  disabled={!noteStrokes.length}
                  onClick={() => act('undo')}
                >
                  Undo
                </Button>
                <Button.Confirm
                  icon="trash"
                  disabled={!noteStrokes.length && !noteMarkers.length}
                  onClick={() => act('clear')}
                >
                  Clear
                </Button.Confirm>
              </Stack.Item>
            </Stack>
          ) : (
            <Box color="label" textAlign="center">
              Hold a pen in your other hand to write on the map.
            </Box>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill>
          <MapScene
            svgRef={svgRef}
            cursor={canWrite ? 'crosshair' : undefined}
            onMouseDown={handleMouseDown}
            onMouseMove={handleMouseMove}
            onMouseUp={() => finishStroke()}
          >
            {noteStrokes.map((noteStroke, index) => (
              <polyline
                key={index}
                points={toPolyline(noteStroke.points)}
                fill="none"
                stroke={noteStroke.color}
                strokeWidth={4}
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            ))}
            {stroke && (
              <polyline
                points={toPolyline(stroke)}
                fill="none"
                stroke={color}
                strokeWidth={4}
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            )}
            {noteMarkers.map((marker, index) => (
              <g key={index} transform={`translate(${marker.x},${marker.y})`}>
                <MarkerIcon type={marker.type} />
                {!!marker.label && (
                  <text
                    y={MARKER_SIZE * 2.4}
                    textAnchor="middle"
                    fontSize={13}
                    fontWeight="bold"
                    fill="#fff"
                    stroke="#000"
                    strokeWidth={3}
                    paintOrder="stroke"
                  >
                    {marker.label}
                  </text>
                )}
              </g>
            ))}
          </MapScene>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const PaperTacticalMap = (props) => {
  const { act, data } = useBackend<Data>();
  const { canChangeZ } = data;
  const [tab, setTab] = useState<'plan' | 'notes'>('plan');

  return (
    <Window width={700} height={850} theme="crtblue">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section
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
              <Tabs fluid>
                <Tabs.Tab
                  icon="map"
                  selected={tab === 'plan'}
                  onClick={() => setTab('plan')}
                >
                  Command Plan
                </Tabs.Tab>
                <Tabs.Tab
                  icon="pen"
                  selected={tab === 'notes'}
                  onClick={() => setTab('notes')}
                >
                  My Notes
                </Tabs.Tab>
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            {tab === 'plan' ? (
              <Section fill>
                <CommandPlan />
              </Section>
            ) : (
              <Notes />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

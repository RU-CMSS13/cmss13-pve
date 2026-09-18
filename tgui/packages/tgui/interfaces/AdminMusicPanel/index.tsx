import { Box, Button, Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { useAdminMusicPanelController } from './controller';
import { EditTab } from './edit';
import { PlayTab } from './play';
import {
  BG_APP,
  BG_PANEL_ALT,
  BG_SELECTED,
  BORDER,
  TEXT_PRIMARY,
  TEXT_SECONDARY,
} from './theme';

const getTabStyle = (selected: boolean) => ({
  border: selected ? `1px solid ${BORDER}` : `1px solid ${BORDER}`,
  backgroundColor: selected ? BG_SELECTED : BG_PANEL_ALT,
  color: selected ? TEXT_PRIMARY : TEXT_SECONDARY,
  boxShadow: selected ? 'inset 0 0 0 1px rgba(255, 255, 255, 0.04)' : 'none',
});

const WINDOW_CONTENT_STYLE = {
  backgroundColor: BG_APP,
  backgroundImage: 'none',
};

const HIDDEN_TAB_STYLE = {
  display: 'none',
  height: '100%',
};

const VISIBLE_TAB_STYLE = {
  display: 'block',
  height: '100%',
};

export function AdminMusicPanel() {
  const {
    activeTab,
    setActiveTab,
    onRequestClose,
    playTabProps,
    editTabProps,
  } = useAdminMusicPanelController();

  return (
    <Window
      title="Admin Music Panel"
      width={1260}
      height={840}
      theme="admin"
      canClose={false}
      buttonsRight
      buttons={
        <Button
          icon="times"
          color="bad"
          tooltip="Request close"
          onClick={onRequestClose}
        >
          Close
        </Button>
      }
    >
      <Window.Content scrollable style={WINDOW_CONTENT_STYLE}>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                selected={activeTab === 'play'}
                style={getTabStyle(activeTab === 'play')}
                onClick={() => setActiveTab('play')}
              >
                Play
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'edit'}
                style={getTabStyle(activeTab === 'edit')}
                onClick={() => setActiveTab('edit')}
              >
                Edit
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Box
              style={
                activeTab === 'play' ? VISIBLE_TAB_STYLE : HIDDEN_TAB_STYLE
              }
            >
              <PlayTab {...playTabProps} />
            </Box>
            <Box
              style={
                activeTab === 'edit' ? VISIBLE_TAB_STYLE : HIDDEN_TAB_STYLE
              }
            >
              <EditTab {...editTabProps} />
            </Box>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

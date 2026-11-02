import {
  BG_PANEL,
  BG_PANEL_ALT,
  BORDER,
  COMPACT_CARD_STYLE,
  SUBTLE_PANEL_STYLE,
  TEXT_SECONDARY,
} from './theme';

export const ADVANCED_TOGGLE_STYLE = {
  border: `1px solid rgba(51, 69, 87, 0.78)`,
  backgroundColor: BG_PANEL,
};

export const CONTROL_BUTTON_STYLE = {
  minHeight: '1.9rem',
};

export const EDIT_PANEL_CARD_STYLE = {
  ...SUBTLE_PANEL_STYLE,
  backgroundColor: BG_PANEL,
  border: '1px solid rgba(51, 69, 87, 0.78)',
  padding: '0.62rem 0.7rem',
};

export const EDIT_PANEL_CARD_HEADING_STYLE = {
  marginBottom: '0.45rem',
};

export const PLAY_CONTROLS_ROW_STYLE = {
  display: 'flex',
  flexWrap: 'wrap',
  alignItems: 'stretch',
  gap: '0.45rem',
  width: '100%',
  minWidth: '0',
};

export const OPERATOR_STATUS_PANEL_STYLE = {
  borderTop: `1px solid ${BORDER}`,
  backgroundColor: BG_PANEL_ALT,
  borderRadius: '0.32rem',
  padding: '0.26rem 0.36rem',
};

export const SEGMENTED_GROUP_STYLE = {
  display: 'flex',
  alignItems: 'center',
  gap: '0.08rem',
  width: '100%',
  padding: '0.1rem',
  borderRadius: '0.42rem',
  border: `1px solid ${BORDER}`,
  backgroundColor: BG_PANEL,
};

export const SECTION_SURFACE_STYLE = {
  backgroundColor: BG_PANEL,
  border: `1px solid ${BORDER}`,
};

export const TRACKS_FILTER_BAR_STYLE = {
  backgroundColor: BG_PANEL,
  border: `1px solid ${BORDER}`,
  borderRadius: '0.35rem',
  padding: '0.3rem 0.42rem',
};

export const TRACK_LIST_SCROLL_STYLE = {
  height: 'min(100%, 28rem)',
  minWidth: '0',
  maxHeight: '28rem',
  overflowX: 'hidden',
  overflowY: 'auto',
  paddingRight: '0.1rem',
};

export const RESPONSIVE_HEADER_ROW_STYLE = {
  gap: '0.35rem 0.5rem',
};

export const RESPONSIVE_ACTION_GROUP_STYLE = {
  display: 'flex',
  flexWrap: 'wrap',
  justifyContent: 'flex-end',
  alignItems: 'center',
  gap: '0.28rem',
  minWidth: '0',
};

export const INSPECTOR_TARGET_TEXT_STYLE = {
  color: TEXT_SECONDARY,
  fontSize: '0.82rem',
  fontWeight: '600',
  lineHeight: '1.2',
};

export const FULL_WIDTH_CLAMP_STYLE = {
  width: '100%',
  maxWidth: '100%',
  minWidth: '0',
  overflow: 'hidden',
};

export const TRACK_ROW_LEFT_STYLE = {
  minWidth: '0',
  overflow: 'hidden',
};

export const HEADER_ACTION_BUTTON_STYLE = {
  minWidth: '6rem',
};

export const INSPECTOR_ACTION_BUTTON_STYLE = {
  minWidth: '6.9rem',
  justifyContent: 'center',
};

export const STRUCTURE_ACTION_BUTTON_STYLE = {
  minWidth: '5.8rem',
  justifyContent: 'center',
};

export const EDIT_FIELD_WRAPPER_STYLE = {
  width: '100%',
  maxWidth: '100%',
  minWidth: '0',
  overflow: 'hidden',
};

export const INSPECTOR_CARD_STYLE = {
  ...COMPACT_CARD_STYLE,
  backgroundColor: 'rgba(43, 58, 76, 0.84)',
  border: '1px solid rgba(51, 69, 87, 0.84)',
  width: '100%',
  maxWidth: '100%',
  minWidth: '0',
  overflow: 'hidden',
};

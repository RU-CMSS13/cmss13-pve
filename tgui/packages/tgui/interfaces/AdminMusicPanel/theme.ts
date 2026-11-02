export const DESCRIPTION_FIELD_HEIGHT = 4.5;
export const BG_APP = '#11161D';
export const BG_PANEL = '#1B2430';
export const BG_PANEL_ALT = '#1D2733';
export const BG_CARD = '#2B3A4C';
export const BG_SELECTED = '#385169';
export const BORDER = '#334557';
export const TEXT_PRIMARY = '#E7EDF5';
export const TEXT_SECONDARY = '#A6B3C2';
export const TEXT_MUTED = '#78889A';
export const ACCENT_SUCCESS = '#67B31B';
export const ACCENT_SUCCESS_HI = '#7CCF23';
export const ACCENT_DANGER = '#C93A3A';
export const ACCENT_NEUTRAL = '#4E6682';

export const PLAYER_CARD_STYLE = {
  backgroundColor: BG_CARD,
  border: `1px solid ${BORDER}`,
  borderRadius: '0.35rem',
  padding: '0.68rem',
  boxShadow: 'inset 0 1px 0 rgba(255, 255, 255, 0.02)',
};

export const COMPACT_CARD_STYLE = {
  backgroundColor: BG_CARD,
  border: `1px solid ${BORDER}`,
  borderRadius: '0.35rem',
  padding: '0.46rem 0.58rem',
  boxShadow: 'inset 0 1px 0 rgba(255, 255, 255, 0.02)',
};

export const PLAYER_STRIP_STYLE = {
  backgroundColor: BG_PANEL_ALT,
  border: `1px solid ${BORDER}`,
  borderRadius: '0.35rem',
  padding: '0.72rem',
};

export const PLAYER_BADGE_STYLE = {
  display: 'inline-block',
  padding: '0.15rem 0.45rem',
  marginRight: '0.35rem',
  marginBottom: '0.35rem',
  borderRadius: '999px',
  border: `1px solid ${BORDER}`,
  backgroundColor: BG_PANEL_ALT,
  color: TEXT_SECONDARY,
};

export const STATUS_STRIP_STYLE = {
  backgroundColor: BG_PANEL,
  border: `1px solid ${BORDER}`,
  borderRadius: '0.35rem',
  padding: '0.42rem 0.52rem',
};

export const SUBTLE_PANEL_STYLE = {
  backgroundColor: BG_PANEL_ALT,
  border: `1px solid ${BORDER}`,
  borderRadius: '0.35rem',
  padding: '0.42rem 0.52rem',
  boxShadow: 'inset 0 1px 0 rgba(255, 255, 255, 0.015)',
};

export const UNSAVED_BADGE_STYLE = {
  display: 'inline-block',
  padding: '0.15rem 0.45rem',
  borderRadius: '999px',
  border: '1px solid rgba(255, 208, 102, 0.45)',
  backgroundColor: 'rgba(255, 208, 102, 0.12)',
  color: TEXT_PRIMARY,
};

export const MUTED_BADGE_STYLE = {
  display: 'inline-block',
  padding: '0.15rem 0.45rem',
  borderRadius: '999px',
  border: `1px solid ${BORDER}`,
  backgroundColor: BG_PANEL_ALT,
  color: TEXT_SECONDARY,
};

export const LIVE_BADGE_STYLE = {
  display: 'inline-block',
  padding: '0.15rem 0.45rem',
  borderRadius: '999px',
  border: `1px solid ${ACCENT_SUCCESS_HI}`,
  backgroundColor: 'rgba(103, 179, 27, 0.18)',
  color: TEXT_PRIMARY,
};

export const LABEL_STYLE = {
  fontSize: '0.8rem',
  color: TEXT_SECONDARY,
};

export const ELLIPSIS_STYLE = {
  display: 'block',
  overflow: 'hidden',
  textOverflow: 'ellipsis',
  whiteSpace: 'nowrap',
  width: '100%',
  maxWidth: '100%',
  minWidth: '0',
};

export const WRAPPED_TEXT_STYLE = {
  whiteSpace: 'normal',
  wordBreak: 'break-word',
  lineHeight: '1.3',
};

export const LIST_SCROLL_STYLE = {
  height: '100%',
  minWidth: '0',
  overflowX: 'hidden',
  overflowY: 'auto',
  paddingRight: '0.1rem',
};

export const DISABLED_ACTION_STYLE = {
  opacity: '0.45',
  filter: 'saturate(0.6)',
};

export const getToggleButtonStyle = (checked: boolean) => ({
  border: checked ? `1px solid ${ACCENT_NEUTRAL}` : `1px solid ${BORDER}`,
  backgroundColor: checked ? 'rgba(78, 102, 130, 0.24)' : BG_CARD,
  color: checked ? TEXT_PRIMARY : TEXT_SECONDARY,
});

export const getListRowStyle = (selected: boolean) => ({
  marginBottom: '0.2rem',
  padding: '0.32rem 0.48rem',
  borderRadius: '0.32rem',
  border: selected ? `1px solid ${ACCENT_NEUTRAL}` : `1px solid ${BORDER}`,
  backgroundColor: selected ? BG_SELECTED : BG_PANEL_ALT,
  boxShadow: selected ? 'inset 0 0 0 1px rgba(255, 255, 255, 0.04)' : 'none',
});

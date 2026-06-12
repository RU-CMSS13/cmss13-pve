import { Box } from '../../components';
import {
  formatSourceLabel,
  isVariantDurationUnknown,
  isVariantMissingSource,
} from './helpers';
import {
  ELLIPSIS_STYLE,
  getListRowStyle,
  LIVE_BADGE_STYLE,
  MUTED_BADGE_STYLE,
  PLAYER_BADGE_STYLE,
  TEXT_MUTED,
  TEXT_PRIMARY,
} from './theme';
import { DraftVariant } from './types';

type CompactFactItem = Readonly<{
  label: string;
  value: string;
}>;

type TrackFactBadgesProps = Readonly<{
  items: CompactFactItem[];
}>;

const LIST_BADGE_STYLE = {
  ...PLAYER_BADGE_STYLE,
  padding: '0.05rem 0.35rem',
  marginBottom: '0.15rem',
  fontSize: '0.72rem',
};

const WARNING_BADGE_STYLE = {
  ...LIST_BADGE_STYLE,
  border: '1px solid rgba(255, 208, 102, 0.4)',
  backgroundColor: 'rgba(255, 208, 102, 0.14)',
};

const TRACK_TITLE_TEXT_STYLE = {
  ...ELLIPSIS_STYLE,
  color: TEXT_PRIMARY,
};

const TRACK_DESCRIPTION_BLOCK_STYLE = {
  color: TEXT_MUTED,
  lineHeight: '1.28',
  whiteSpace: 'pre-wrap',
  wordBreak: 'break-word',
  overflowWrap: 'anywhere',
  minWidth: '0',
  width: '100%',
  maxWidth: '100%',
};

const TRACK_DENSE_LINE_STYLE = {
  display: 'flex',
  alignItems: 'baseline',
  width: '100%',
  maxWidth: '100%',
  minWidth: '0',
};

const TRACK_DENSE_TEXT_STYLE = {
  flex: '1 1 auto',
  overflow: 'hidden',
  textOverflow: 'ellipsis',
  whiteSpace: 'nowrap',
  width: '100%',
  maxWidth: '100%',
  minWidth: '0',
};

const TRACK_DENSE_TITLE_SPAN_STYLE = {
  color: TEXT_PRIMARY,
  fontWeight: '700',
};

const TRACK_DENSE_DESCRIPTION_SPAN_STYLE = {
  color: TEXT_MUTED,
};

const getTrackRowStyle = (
  selected: boolean,
  dense: boolean,
  isLive: boolean,
): Record<string, string> => ({
  ...getListRowStyle(selected),
  width: '100%',
  maxWidth: '100%',
  minWidth: '0',
  overflow: 'hidden',
  ...(dense
    ? {
        marginBottom: '0.12rem',
        padding: '0.2rem 0.38rem',
      }
    : {}),
  ...(!selected && isLive
    ? {
        border: '1px solid rgba(120, 190, 100, 0.34)',
      }
    : {}),
});

const matchesTrackSearch = (variant: DraftVariant, searchText: string) => {
  const normalizedSearch = searchText.trim().toLowerCase();
  if (!normalizedSearch) {
    return true;
  }

  const haystack = [
    variant.title,
    variant.description,
    variant.source_url,
    formatSourceLabel(variant.source_url),
  ]
    .join(' ')
    .toLowerCase();

  return haystack.includes(normalizedSearch);
};

const getLibraryRowStyle = (loaded: boolean) => ({
  ...getListRowStyle(false),
  ...(loaded
    ? {
        border: '1px solid rgba(137, 171, 214, 0.24)',
        backgroundColor: 'rgba(102, 131, 171, 0.12)',
      }
    : {}),
});

function TrackFactBadges({ items }: TrackFactBadgesProps) {
  return (
    <Box>
      {items.map((item) => (
        <Box key={item.label} style={LIST_BADGE_STYLE}>
          {item.label}: {item.value}
        </Box>
      ))}
    </Box>
  );
}

const getVariantListBadges = (variant: DraftVariant, isLive = false) => {
  const badges: Array<{
    label: string;
    style: Record<string, string>;
  }> = [];

  if (isLive) {
    badges.push({
      label: 'Live',
      style: LIVE_BADGE_STYLE,
    });
  }

  if (isVariantMissingSource(variant)) {
    badges.push({
      label: 'No source',
      style: WARNING_BADGE_STYLE,
    });
  }

  if (isVariantDurationUnknown(variant)) {
    badges.push({
      label: 'Unknown duration',
      style: LIST_BADGE_STYLE,
    });
  }

  return badges;
};

const getTrackDetailBadges = (variant: DraftVariant, isLive = false) => {
  const badges = [...getVariantListBadges(variant, isLive)];

  if (!isVariantMissingSource(variant)) {
    badges.unshift({
      label: `Source: ${formatSourceLabel(variant.source_url)}`,
      style: MUTED_BADGE_STYLE,
    });
  }

  return badges;
};

type TrackTextBlockProps = Readonly<{
  title: string;
  description: string;
  dense: boolean;
}>;

function TrackTextBlock({ title, description, dense }: TrackTextBlockProps) {
  if (dense) {
    return (
      <div
        style={{
          ...TRACK_DENSE_LINE_STYLE,
          fontSize: '0.85rem',
        }}
      >
        <div style={TRACK_DENSE_TEXT_STYLE}>
          <span style={TRACK_DENSE_TITLE_SPAN_STYLE}>{title}</span>
          {description ? (
            <span style={TRACK_DENSE_DESCRIPTION_SPAN_STYLE}>
              {' '}
              - {description}
            </span>
          ) : null}
        </div>
      </div>
    );
  }

  return (
    <>
      <Box bold fontSize="0.92rem" style={TRACK_TITLE_TEXT_STYLE}>
        {title}
      </Box>
      {description ? (
        <Box
          fontSize="0.76rem"
          mt="0.04rem"
          style={TRACK_DESCRIPTION_BLOCK_STYLE}
        >
          {description}
        </Box>
      ) : null}
    </>
  );
}

export {
  getLibraryRowStyle,
  getTrackDetailBadges,
  getTrackRowStyle,
  getVariantListBadges,
  matchesTrackSearch,
  TrackFactBadges,
  TrackTextBlock,
};

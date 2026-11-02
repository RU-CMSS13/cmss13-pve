import { useEffect, useRef, useState } from 'react';

import { Input, TextArea } from '../../components';
import {
  formatDurationInputValue,
  normalizeDurationValue,
  parseDurationInput,
} from './helpers';
import { BG_PANEL, BORDER, TEXT_PRIMARY } from './theme';

type BufferedTextAreaProps = Readonly<{
  syncKey: string | number | null;
  value: string;
  placeholder: string;
  onCommit: (value: string) => void;
  minRows?: number;
  maxRows?: number;
}>;

type BufferedInputProps = Readonly<{
  syncKey: string | number | null;
  value: string;
  placeholder: string;
  onCommit: (value: string) => void;
  monospace?: boolean;
}>;

type BufferedDurationInputProps = Readonly<{
  syncKey: string | number | null;
  value: number;
  onCommit: (value: number) => void;
}>;

const EDIT_INPUT_STYLE = {
  boxSizing: 'border-box',
  width: '100%',
  maxWidth: '100%',
  minWidth: '0',
  backgroundColor: BG_PANEL,
  color: TEXT_PRIMARY,
  border: `1px solid ${BORDER}`,
  borderRadius: '0.32rem',
  boxShadow: 'inset 0 1px 0 rgba(255, 255, 255, 0.015)',
};

function BufferedInput({
  syncKey,
  value,
  placeholder,
  onCommit,
  monospace = false,
}: BufferedInputProps) {
  const [draftValue, setDraftValue] = useState(value);
  const skipNextCommitRef = useRef(false);

  useEffect(() => {
    skipNextCommitRef.current = false;
    setDraftValue(value);
  }, [syncKey, value]);

  return (
    <Input
      key={`${syncKey ?? 'buffered-input'}:${value}`}
      fluid
      monospace={monospace}
      style={EDIT_INPUT_STYLE}
      value={draftValue}
      onInput={(e, nextValue) => setDraftValue(nextValue)}
      onChange={(e, nextValue) => {
        if (skipNextCommitRef.current) {
          skipNextCommitRef.current = false;
          setDraftValue(value);
          return;
        }
        setDraftValue(nextValue);
        if (nextValue !== value) {
          onCommit(nextValue);
        }
      }}
      onEscape={() => {
        skipNextCommitRef.current = true;
        setDraftValue(value);
      }}
      placeholder={placeholder}
    />
  );
}

function BufferedDurationInput({
  syncKey,
  value,
  onCommit,
}: BufferedDurationInputProps) {
  const formattedValue = formatDurationInputValue(value);
  const [draftValue, setDraftValue] = useState(formattedValue);
  const skipNextCommitRef = useRef(false);

  useEffect(() => {
    skipNextCommitRef.current = false;
    setDraftValue(formattedValue);
  }, [formattedValue, syncKey]);

  const resetValue = () => {
    setDraftValue(formattedValue);
  };

  const handleCommit = (nextValue: string) => {
    if (skipNextCommitRef.current) {
      skipNextCommitRef.current = false;
      resetValue();
      return;
    }

    const parsedDuration = parseDurationInput(nextValue);
    if (parsedDuration === null) {
      resetValue();
      return;
    }

    const normalizedDuration = normalizeDurationValue(parsedDuration);
    setDraftValue(formatDurationInputValue(normalizedDuration));
    if (normalizedDuration !== normalizeDurationValue(value)) {
      onCommit(normalizedDuration);
    }
  };

  return (
    <Input
      key={`${syncKey ?? 'buffered-duration'}:${formattedValue}`}
      fluid
      monospace
      style={EDIT_INPUT_STYLE}
      value={draftValue}
      onInput={(e, nextValue) => setDraftValue(nextValue)}
      onChange={(e, nextValue) => handleCommit(nextValue)}
      onEscape={() => {
        skipNextCommitRef.current = true;
        resetValue();
      }}
      placeholder="Seconds or timecode"
    />
  );
}

function BufferedTextArea({
  syncKey,
  value,
  placeholder,
  onCommit,
  minRows = 3,
  maxRows = 7,
}: BufferedTextAreaProps) {
  const [draftValue, setDraftValue] = useState(value);
  const [heightPx, setHeightPx] = useState(minRows * 17);
  const [scrollbar, setScrollbar] = useState(false);
  const skipNextCommitRef = useRef(false);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  useEffect(() => {
    skipNextCommitRef.current = false;
    setDraftValue(value);
  }, [syncKey, value]);

  useEffect(() => {
    const textarea = textareaRef.current;
    if (!textarea) {
      return;
    }

    const computedStyles = window.getComputedStyle(textarea);
    const lineHeight =
      Number.parseFloat(computedStyles.lineHeight) ||
      Number.parseFloat(computedStyles.fontSize) * 1.35 ||
      17;
    const minHeight = Math.ceil(lineHeight * minRows);
    const maxHeight = Math.ceil(lineHeight * maxRows);
    const previousInlineHeight = textarea.style.height;

    textarea.style.height = '0px';
    const contentHeight = Math.ceil(textarea.scrollHeight);
    textarea.style.height = previousInlineHeight;
    const nextHeight = Math.max(minHeight, Math.min(contentHeight, maxHeight));

    setHeightPx(nextHeight);
    setScrollbar(contentHeight > maxHeight);
  }, [draftValue, minRows, maxRows, syncKey]);

  return (
    <TextArea
      ref={textareaRef}
      fluid
      height={`${heightPx}px`}
      style={EDIT_INPUT_STYLE}
      value={draftValue}
      onInput={(e, nextValue) => setDraftValue(nextValue)}
      onChange={(e, nextValue) => {
        if (skipNextCommitRef.current) {
          skipNextCommitRef.current = false;
          setDraftValue(value);
          return;
        }
        setDraftValue(nextValue);
        if (nextValue !== value) {
          onCommit(nextValue);
        }
      }}
      onEscape={() => {
        skipNextCommitRef.current = true;
        setDraftValue(value);
      }}
      placeholder={placeholder}
      scrollbar={scrollbar}
    />
  );
}

export { BufferedDurationInput, BufferedInput, BufferedTextArea };

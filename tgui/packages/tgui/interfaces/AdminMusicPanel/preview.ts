import { storage } from 'common/storage';
import { useEffect, useRef, useState } from 'react';

import { PreviewCommand } from './types';

export const DEFAULT_PREVIEW_VOLUME = 0.2;

export const useAdminMusicPreview = (
  previewCommand: PreviewCommand,
  onStopPreviewCommand: () => void,
) => {
  const [previewVolume, setPreviewVolume] = useState(DEFAULT_PREVIEW_VOLUME);
  const [previewState, setPreviewState] = useState('Idle');
  const [isPreviewActive, setIsPreviewActive] = useState(false);

  const previewAudioRef = useRef<HTMLAudioElement | null>(null);
  const previewVolumeRef = useRef(DEFAULT_PREVIEW_VOLUME);
  const previewKeyRef = useRef<string>('');

  const clearPreviewAudio = () => {
    const audio = previewAudioRef.current;
    if (audio) {
      audio.pause();
      audio.src = '';
      previewAudioRef.current = null;
    }
  };

  useEffect(() => {
    const syncVolume = async () => {
      const settings = await storage.get('panel-settings');
      const nextVolume =
        typeof settings?.adminMusicVolume === 'number'
          ? settings.adminMusicVolume
          : DEFAULT_PREVIEW_VOLUME;
      previewVolumeRef.current = nextVolume;
      setPreviewVolume(nextVolume);
    };

    let cancelled = false;
    const listener = () => {
      if (!cancelled) {
        void syncVolume();
      }
    };

    void syncVolume();
    document.addEventListener('byondstorageupdated', listener);
    return () => {
      cancelled = true;
      document.removeEventListener('byondstorageupdated', listener);
    };
  }, []);

  useEffect(() => {
    if (previewAudioRef.current) {
      previewAudioRef.current.volume = previewVolume;
    }
  }, [previewVolume]);

  useEffect(
    () => () => {
      clearPreviewAudio();
    },
    [],
  );

  useEffect(() => {
    if (!previewCommand) {
      return;
    }

    const key = `${previewCommand.nonce}:${previewCommand.command}`;
    if (previewKeyRef.current === key) {
      return;
    }
    previewKeyRef.current = key;

    const stopPreviewAudio = (status = 'Preview stopped') => {
      clearPreviewAudio();
      setIsPreviewActive(false);
      setPreviewState(status);
    };

    if (previewCommand.command === 'stop') {
      stopPreviewAudio();
      return;
    }

    if (!previewCommand.url) {
      stopPreviewAudio('Preview unavailable');
      return;
    }

    clearPreviewAudio();
    setIsPreviewActive(true);
    setPreviewState('Loading preview...');
    const audio = new Audio(previewCommand.url);
    previewAudioRef.current = audio;
    audio.volume = previewVolumeRef.current;

    const start = Math.max(0, previewCommand.start || 0);
    const end =
      typeof previewCommand.end === 'number' && previewCommand.end > start
        ? previewCommand.end
        : null;

    const seekToStart = () => {
      if (previewAudioRef.current !== audio || start <= 0) {
        return;
      }
      try {
        const duration = Number.isFinite(audio.duration)
          ? audio.duration
          : null;
        audio.currentTime =
          duration !== null
            ? Math.min(start, Math.max(duration - 0.1, 0))
            : start;
      } catch {
        // Best-effort preview seek.
      }
    };

    const finishPreview = (status: string) => {
      if (previewAudioRef.current === audio) {
        previewAudioRef.current = null;
      }
      audio.pause();
      audio.src = '';
      setIsPreviewActive(false);
      setPreviewState(status);
    };

    audio.addEventListener('loadedmetadata', seekToStart);
    audio.addEventListener('ended', () => finishPreview('Preview ended'));
    audio.addEventListener('error', () => finishPreview('Preview error'));
    if (end !== null) {
      audio.addEventListener('timeupdate', () => {
        if (previewAudioRef.current !== audio || audio.currentTime < end) {
          return;
        }
        finishPreview('Preview ended');
      });
    }

    const startPreview = () => {
      if (previewAudioRef.current !== audio) {
        return;
      }

      audio
        .play()
        .then(() => {
          if (previewAudioRef.current === audio) {
            setIsPreviewActive(true);
            setPreviewState(previewCommand.title || 'Preview playing');
          }
        })
        .catch(() => finishPreview('Preview failed'));
    };

    if (start > 0 && audio.readyState < HTMLMediaElement.HAVE_METADATA) {
      const startAfterMetadata = () => {
        audio.removeEventListener('loadedmetadata', startAfterMetadata);
        if (previewAudioRef.current !== audio) {
          return;
        }
        seekToStart();
        startPreview();
      };

      audio.addEventListener('loadedmetadata', startAfterMetadata);
      audio.load();
      return;
    }

    if (start > 0) {
      seekToStart();
    }

    startPreview();
  }, [previewCommand]);

  const stopPreview = () => {
    clearPreviewAudio();
    previewKeyRef.current = '';
    setIsPreviewActive(false);
    setPreviewState('Preview stopped');
    onStopPreviewCommand();
  };

  return {
    isPreviewActive,
    previewState,
    previewVolume,
    stopPreview,
  };
};

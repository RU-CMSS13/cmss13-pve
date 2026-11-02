/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createLogger } from 'tgui/logging';

const logger = createLogger('AudioPlayer');

type AudioOptions = {
  pitch?: number;
  start?: number;
  end?: number;
  loop?: boolean;
};

export class AudioPlayer {
  element: HTMLAudioElement | null;
  options: AudioOptions;
  volume: number;

  onPlaySubscribers: { (): void }[];
  onStopSubscribers: { (): void }[];

  constructor() {
    this.element = null;

    this.onPlaySubscribers = [];
    this.onStopSubscribers = [];
  }

  destroy() {
    this.element = null;
  }

  play(url: string, options: AudioOptions = {}) {
    if (this.element) {
      this.stop();
    }

    this.options = options;

    const audio = (this.element = new Audio(url));
    audio.volume = this.volume ?? 1;
    audio.playbackRate = this.options.pitch || 1;

    logger.log('playing', url, options);

    const startTime = Math.max(0, this.options.start || 0);
    const endTime =
      typeof this.options.end === 'number' && this.options.end > startTime
        ? this.options.end
        : null;

    const restartPlayback = () => {
      if (this.element !== audio) {
        return;
      }

      try {
        audio.currentTime = startTime;
      } catch (error) {
        logger.log('failed to seek during loop', error);
      }

      audio.play().catch((error) => logger.log('playback error', error));
    };

    const startPlayback = () => {
      if (this.element !== audio) {
        return;
      }

      audio.play().catch((error) => logger.log('playback error', error));
      this.onPlaySubscribers.forEach((subscriber) => subscriber());
    };

    const seekToStart = () => {
      if (this.element !== audio || startTime <= 0) {
        return;
      }

      try {
        const duration = Number.isFinite(audio.duration)
          ? audio.duration
          : null;
        audio.currentTime =
          duration !== null
            ? Math.min(startTime, Math.max(duration - 0.1, 0))
            : startTime;
      } catch (error) {
        logger.log('failed to seek on metadata', error);
      }
    };

    audio.addEventListener('loadedmetadata', () => {
      if (this.element !== audio) {
        return;
      }
      seekToStart();
    });

    audio.addEventListener('ended', () => {
      if (this.element !== audio) {
        return;
      }

      if (this.options.loop) {
        restartPlayback();
        return;
      }

      logger.log('ended');
      this.stop();
    });

    audio.addEventListener('error', (error) => {
      logger.log('playback error', error);
    });

    if (endTime !== null) {
      audio.addEventListener('timeupdate', () => {
        if (this.element !== audio || audio.currentTime < endTime) {
          return;
        }

        if (this.options.loop) {
          restartPlayback();
        } else {
          this.stop();
        }
      });
    }

    if (startTime > 0 && audio.readyState < HTMLMediaElement.HAVE_METADATA) {
      const startAfterMetadata = () => {
        audio.removeEventListener('loadedmetadata', startAfterMetadata);
        if (this.element !== audio) {
          return;
        }
        seekToStart();
        startPlayback();
      };

      audio.addEventListener('loadedmetadata', startAfterMetadata);
      audio.load();
      return;
    }

    if (startTime > 0) {
      seekToStart();
    }

    startPlayback();
  }

  stop() {
    if (!this.element) return;

    logger.log('stopping');

    this.element.pause();
    this.element = null;

    this.onStopSubscribers.forEach((subscriber) => subscriber());
  }

  setVolume(volume: number): void {
    this.volume = volume;

    if (!this.element) return;

    this.element.volume = volume;
  }

  onPlay(subscriber: () => void): void {
    this.onPlaySubscribers.push(subscriber);
  }

  onStop(subscriber: () => void): void {
    this.onStopSubscribers.push(subscriber);
  }
}

import { useEffect, useState } from 'react';

import { CurrentSession } from './types';

export const useBroadcastElapsed = (currentSession: CurrentSession) => {
  const [, setTick] = useState(0);
  const [syncTimestampMs, setSyncTimestampMs] = useState(() => Date.now());
  const [baseElapsedSeconds, setBaseElapsedSeconds] = useState(0);

  useEffect(() => {
    setBaseElapsedSeconds(
      Math.max(0, Math.floor(currentSession?.broadcast_elapsed_seconds || 0)),
    );
    setSyncTimestampMs(Date.now());
  }, [
    currentSession?.source_url,
    currentSession?.preset_id,
    currentSession?.tier_name,
    currentSession?.variant_title,
    currentSession?.broadcast_elapsed_seconds,
  ]);

  useEffect(() => {
    if (!currentSession) {
      setTick(0);
      return;
    }

    const intervalId = window.setInterval(() => {
      setTick((currentTick) => currentTick + 1);
    }, 1000);

    return () => window.clearInterval(intervalId);
  }, [
    currentSession?.source_url,
    currentSession?.preset_id,
    currentSession?.tier_name,
    currentSession?.variant_title,
  ]);

  if (!currentSession) {
    return 0;
  }

  const elapsedSinceSyncSeconds = Math.floor(
    (Date.now() - syncTimestampMs) / 1000,
  );
  return Math.max(0, baseElapsedSeconds + elapsedSinceSyncSeconds);
};

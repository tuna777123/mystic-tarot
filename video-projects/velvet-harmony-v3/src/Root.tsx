import React from 'react';
import {Composition} from 'remotion';
import {VelvetHarmony} from './VelvetHarmony';

export const FPS = 24;
export const WIDTH = 2560;
export const HEIGHT = 1440;
export const DURATION_IN_FRAMES = 172893; // 2:00:03.875 at 24 fps

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="VelvetHarmony"
      component={VelvetHarmony}
      durationInFrames={DURATION_IN_FRAMES}
      fps={FPS}
      width={WIDTH}
      height={HEIGHT}
    />
  );
};

import React from 'react';
import {Composition} from 'remotion';
import {DanubeNative} from './DanubeNative';

export const Root: React.FC = () => (
  <Composition
    id="DanubeNative"
    component={DanubeNative}
    durationInFrames={1740}
    fps={30}
    width={1080}
    height={1920}
  />
);

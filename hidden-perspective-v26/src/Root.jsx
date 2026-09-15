import React from 'react';
import {Composition} from 'remotion';
import {V26Proof} from './V26Proof';

export const RemotionRoot = () => (
  <>
    <Composition
      id="V26Proof"
      component={V26Proof}
      durationInFrames={2700}
      fps={30}
      width={1920}
      height={1080}
    />
  </>
);

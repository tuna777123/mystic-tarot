import React from 'react';
import {Composition} from 'remotion';
import {HiddenPerspectiveV26Proof} from './Video';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="HiddenPerspectiveV26Proof"
        component={HiddenPerspectiveV26Proof}
        durationInFrames={90 * 30}
        fps={30}
        width={1920}
        height={1080}
      />
    </>
  );
};

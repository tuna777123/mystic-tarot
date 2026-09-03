import React from 'react';
import {Composition} from 'remotion';
import {VelvetHarmony} from './VelvetHarmony';
import {
  BlueLoopPhase4,
  BlueTail2s,
  NightLoopPhase4,
  NightTail21f,
  TransitionBlueNight,
  TransitionWarmBlue,
  WarmLoop,
  WarmTail1s,
} from './RenderBlocks';

export const FPS = 24;
export const WIDTH = 2560;
export const HEIGHT = 1440;
export const DURATION_IN_FRAMES = 172893; // 2:00:03.875 at 24 fps

const Block: React.FC<{
  id: string;
  component: React.FC;
  durationInFrames: number;
}> = ({id, component, durationInFrames}) => (
  <Composition
    id={id}
    component={component}
    durationInFrames={durationInFrames}
    fps={FPS}
    width={WIDTH}
    height={HEIGHT}
  />
);

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {/* Full composition remains available for Studio preview and spot-checking. */}
      <Composition
        id="VelvetHarmony"
        component={VelvetHarmony}
        durationInFrames={DURATION_IN_FRAMES}
        fps={FPS}
        width={WIDTH}
        height={HEIGHT}
      />

      {/* Short deterministic render blocks used by the efficient final pipeline. */}
      <Block id="WarmLoop" component={WarmLoop} durationInFrames={192} />
      <Block id="BlueLoopPhase4" component={BlueLoopPhase4} durationInFrames={192} />
      <Block id="NightLoopPhase4" component={NightLoopPhase4} durationInFrames={192} />
      <Block id="TransitionWarmBlue" component={TransitionWarmBlue} durationInFrames={96} />
      <Block id="TransitionBlueNight" component={TransitionBlueNight} durationInFrames={96} />
      <Block id="WarmTail1s" component={WarmTail1s} durationInFrames={24} />
      <Block id="BlueTail2s" component={BlueTail2s} durationInFrames={48} />
      <Block id="NightTail21f" component={NightTail21f} durationInFrames={21} />
    </>
  );
};

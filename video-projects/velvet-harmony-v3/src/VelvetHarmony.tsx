import React from 'react';
import {
  AbsoluteFill,
  Easing,
  Sequence,
  interpolate,
  staticFile,
  useCurrentFrame,
} from 'remotion';
import {Video} from '@remotion/media';

const LOOP_FRAMES = 192; // 8.000s @ 24fps
const MAIN_START = 34; // source frame ~1.4167s
const MAIN_FRAMES = 172; // source frames 34..205
const TAIL_START = 206; // source frame ~8.5833s
const HEAD_START = 14; // source frame ~0.5833s
const CROSS_FRAMES = 20; // 0.8333s motion blend

const T1_START = 63384; // 44:01
const T1_END = 63480; // 44:05, midpoint 44:03
const T2_START = 120360; // 1:23:35
const T2_END = 120456; // 1:23:39, midpoint 1:23:37
const TOTAL_FRAMES = 172893;

const WARM = staticFile('assets/warm.mp4');
const BLUE = staticFile('assets/blue-hour.mp4');
const NIGHT = staticFile('assets/night.mp4');

const videoStyle: React.CSSProperties = {
  width: '100%',
  height: '100%',
  objectFit: 'cover',
};

const CrossPair: React.FC<{src: string}> = ({src}) => {
  const frame = useCurrentFrame();
  const progress = interpolate(frame, [0, CROSS_FRAMES - 1], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.bezier(0.4, 0, 0.2, 1),
  });

  return (
    <AbsoluteFill>
      <Video
        src={src}
        muted
        trimBefore={TAIL_START}
        durationInFrames={CROSS_FRAMES}
        style={{...videoStyle, opacity: 1 - progress}}
      />
      <Video
        src={src}
        muted
        trimBefore={HEAD_START}
        durationInFrames={CROSS_FRAMES}
        style={{...videoStyle, opacity: progress}}
      />
    </AbsoluteFill>
  );
};

const EightSecondCycle: React.FC<{src: string}> = ({src}) => {
  return (
    <AbsoluteFill>
      <Video
        src={src}
        muted
        trimBefore={MAIN_START}
        durationInFrames={MAIN_FRAMES}
        style={videoStyle}
      />
      <Sequence from={MAIN_FRAMES} durationInFrames={CROSS_FRAMES}>
        <CrossPair src={src} />
      </Sequence>
    </AbsoluteFill>
  );
};

const SeamlessRepeater: React.FC<{src: string; durationInFrames: number}> = ({
  src,
  durationInFrames,
}) => {
  const repeats = Math.ceil(durationInFrames / LOOP_FRAMES) + 1;

  return (
    <AbsoluteFill>
      {Array.from({length: repeats}).map((_, index) => (
        <Sequence
          key={index}
          from={index * LOOP_FRAMES}
          durationInFrames={LOOP_FRAMES}
        >
          <EightSecondCycle src={src} />
        </Sequence>
      ))}
    </AbsoluteFill>
  );
};

const SceneLayer: React.FC<{
  src: string;
  durationInFrames: number;
  fadeInFrames?: number;
  fadeOutFrames?: number;
}> = ({src, durationInFrames, fadeInFrames = 0, fadeOutFrames = 0}) => {
  const frame = useCurrentFrame();

  const fadeIn = fadeInFrames
    ? interpolate(frame, [0, fadeInFrames - 1], [0, 1], {
        extrapolateLeft: 'clamp',
        extrapolateRight: 'clamp',
        easing: Easing.bezier(0.4, 0, 0.2, 1),
      })
    : 1;

  const fadeOut = fadeOutFrames
    ? interpolate(
        frame,
        [durationInFrames - fadeOutFrames, durationInFrames - 1],
        [1, 0],
        {
          extrapolateLeft: 'clamp',
          extrapolateRight: 'clamp',
          easing: Easing.bezier(0.4, 0, 0.2, 1),
        },
      )
    : 1;

  return (
    <AbsoluteFill style={{opacity: Math.min(fadeIn, fadeOut)}}>
      <SeamlessRepeater src={src} durationInFrames={durationInFrames} />
    </AbsoluteFill>
  );
};

export const VelvetHarmony: React.FC = () => {
  const scene1Duration = T1_END;
  const scene2Duration = T2_END - T1_START;
  const scene3Duration = TOTAL_FRAMES - T2_START;

  return (
    <AbsoluteFill style={{backgroundColor: 'black'}}>
      <Sequence from={0} durationInFrames={scene1Duration}>
        <SceneLayer
          src={WARM}
          durationInFrames={scene1Duration}
          fadeOutFrames={T1_END - T1_START}
        />
      </Sequence>

      <Sequence from={T1_START} durationInFrames={scene2Duration}>
        <SceneLayer
          src={BLUE}
          durationInFrames={scene2Duration}
          fadeInFrames={T1_END - T1_START}
          fadeOutFrames={T2_END - T2_START}
        />
      </Sequence>

      <Sequence from={T2_START} durationInFrames={scene3Duration}>
        <SceneLayer
          src={NIGHT}
          durationInFrames={scene3Duration}
          fadeInFrames={T2_END - T2_START}
        />
      </Sequence>
    </AbsoluteFill>
  );
};

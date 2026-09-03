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

const WARM = staticFile('assets/warm.mp4');
const BLUE = staticFile('assets/blue-hour.mp4');
const NIGHT = staticFile('assets/night.mp4');

const MAIN_START = 34;
const MAIN_FRAMES = 172;
const TAIL_START = 206;
const HEAD_START = 14;
const CROSS_FRAMES = 20;

const style: React.CSSProperties = {
  width: '100%',
  height: '100%',
  objectFit: 'cover',
};

const CrossPair: React.FC<{src: string}> = ({src}) => {
  const frame = useCurrentFrame();
  const p = interpolate(frame, [0, CROSS_FRAMES - 1], [0, 1], {
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
        style={{...style, opacity: 1 - p}}
      />
      <Video
        src={src}
        muted
        trimBefore={HEAD_START}
        durationInFrames={CROSS_FRAMES}
        style={{...style, opacity: p}}
      />
    </AbsoluteFill>
  );
};

const CyclePhase0: React.FC<{src: string}> = ({src}) => (
  <AbsoluteFill>
    <Video
      src={src}
      muted
      trimBefore={MAIN_START}
      durationInFrames={MAIN_FRAMES}
      style={style}
    />
    <Sequence from={MAIN_FRAMES} durationInFrames={CROSS_FRAMES}>
      <CrossPair src={src} />
    </Sequence>
  </AbsoluteFill>
);

// 8-second seamless cycle rotated by 4 seconds (96 frames).
// It ends on source frame 129; the next cycle starts on source frame 130.
const CyclePhase4: React.FC<{src: string}> = ({src}) => (
  <AbsoluteFill>
    <Video src={src} muted trimBefore={130} durationInFrames={76} style={style} />
    <Sequence from={76} durationInFrames={20}>
      <CrossPair src={src} />
    </Sequence>
    <Video
      from={96}
      src={src}
      muted
      trimBefore={34}
      durationInFrames={96}
      style={style}
    />
  </AbsoluteFill>
);

const Dissolve: React.FC<{a: React.ReactNode; b: React.ReactNode}> = ({a, b}) => {
  const frame = useCurrentFrame();
  const p = interpolate(frame, [0, 95], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.bezier(0.4, 0, 0.2, 1),
  });

  return (
    <AbsoluteFill>
      <AbsoluteFill style={{opacity: 1 - p}}>{a}</AbsoluteFill>
      <AbsoluteFill style={{opacity: p}}>{b}</AbsoluteFill>
    </AbsoluteFill>
  );
};

const BluePhase6FourSeconds: React.FC = () => (
  <AbsoluteFill>
    {/* Cycle frames 144..171: main source frames 178..205 */}
    <Video src={BLUE} muted trimBefore={178} durationInFrames={28} style={style} />
    {/* Cycle frames 172..191: validated tail→head seam */}
    <Sequence from={28} durationInFrames={20}>
      <CrossPair src={BLUE} />
    </Sequence>
    {/* Next cycle frames 0..47: source frames 34..81 */}
    <Video
      from={48}
      src={BLUE}
      muted
      trimBefore={34}
      durationInFrames={48}
      style={style}
    />
  </AbsoluteFill>
);

export const WarmLoop: React.FC = () => <CyclePhase0 src={WARM} />;
export const BlueLoopPhase4: React.FC = () => <CyclePhase4 src={BLUE} />;
export const NightLoopPhase4: React.FC = () => <CyclePhase4 src={NIGHT} />;

export const TransitionWarmBlue: React.FC = () => (
  <Dissolve
    a={<Video src={WARM} muted trimBefore={58} durationInFrames={96} style={style} />}
    b={<Video src={BLUE} muted trimBefore={34} durationInFrames={96} style={style} />}
  />
);

export const TransitionBlueNight: React.FC = () => (
  <Dissolve
    a={<BluePhase6FourSeconds />}
    b={<Video src={NIGHT} muted trimBefore={34} durationInFrames={96} style={style} />}
  />
);

export const WarmTail1s: React.FC = () => (
  <Video src={WARM} muted trimBefore={34} durationInFrames={24} style={style} />
);

export const BlueTail2s: React.FC = () => (
  <Video src={BLUE} muted trimBefore={130} durationInFrames={48} style={style} />
);

export const NightTail21f: React.FC = () => (
  <Video src={NIGHT} muted trimBefore={130} durationInFrames={21} style={style} />
);

import React from 'react';
import {
  AbsoluteFill,
  Audio,
  Easing,
  Img,
  Sequence,
  interpolate,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import {proofCaptions, proofShots, type Motion, type Shot} from './proofData';

const FPS = 30;

const COLORS = {
  bg: '#07090d',
  text: '#f6f7f8',
  muted: '#c6cad0',
  accent: '#c9a96a',
};

const smooth = (frame: number, duration: number) =>
  interpolate(frame, [0, Math.max(1, duration - 1)], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.inOut(Easing.cubic),
  });

const motionTransform = (motion: Motion, p: number) => {
  const s = {
    push: 1.035 + p * 0.055,
    pull: 1.09 - p * 0.055,
    pan_left: 1.065,
    pan_right: 1.065,
  }[motion];
  const x = motion === 'pan_left' ? 2.6 - p * 5.2 : motion === 'pan_right' ? -2.6 + p * 5.2 : 0;
  const y = motion === 'push' ? 0.7 - p * 1.4 : motion === 'pull' ? -0.6 + p * 1.2 : 0;
  return `translate3d(${x}%, ${y}%, 0) scale(${s})`;
};

const StillShot: React.FC<{shot: Shot; durationInFrames: number}> = ({shot, durationInFrames}) => {
  const frame = useCurrentFrame();
  const p = smooth(frame, durationInFrames);
  return (
    <AbsoluteFill style={{backgroundColor: COLORS.bg, overflow: 'hidden'}}>
      <Img
        src={staticFile(`assets/${shot.asset}`)}
        style={{
          width: '100%',
          height: '100%',
          objectFit: 'cover',
          transform: motionTransform(shot.motion, p),
          transformOrigin: '50% 50%',
          filter: 'contrast(1.045) saturate(0.94) brightness(0.96)',
          willChange: 'transform',
        }}
      />
      <AbsoluteFill
        style={{
          background:
            'linear-gradient(180deg, rgba(2,4,8,.16) 0%, rgba(2,4,8,.02) 44%, rgba(2,4,8,.40) 100%)',
        }}
      />
      <AbsoluteFill
        style={{
          boxShadow: 'inset 0 0 150px rgba(0,0,0,.32)',
          pointerEvents: 'none',
        }}
      />
      {shot.reconstruction ? <ReconstructionLabel /> : null}
    </AbsoluteFill>
  );
};

const ReconstructionLabel: React.FC = () => (
  <div
    style={{
      position: 'absolute',
      top: 46,
      left: 54,
      padding: '8px 13px',
      border: '1px solid rgba(255,255,255,.26)',
      borderRadius: 7,
      background: 'rgba(8,10,14,.62)',
      color: 'rgba(255,255,255,.82)',
      fontFamily: 'Arial, Helvetica, sans-serif',
      fontSize: 20,
      fontWeight: 700,
      letterSpacing: 2.1,
      textTransform: 'uppercase',
      backdropFilter: 'blur(7px)',
    }}
  >
    AI-assisted reconstruction
  </div>
);

const Caption: React.FC<{text: string; durationInFrames: number}> = ({text, durationInFrames}) => {
  const frame = useCurrentFrame();
  const enter = interpolate(frame, [0, 4], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
  const exit = interpolate(frame, [Math.max(0, durationInFrames - 4), durationInFrames], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const opacity = Math.min(enter, exit);
  return (
    <div
      style={{
        position: 'absolute',
        left: '50%',
        bottom: 74,
        transform: `translateX(-50%) translateY(${(1 - enter) * 4}px)`,
        opacity,
        width: 1460,
        maxWidth: '84%',
        textAlign: 'center',
        color: COLORS.text,
        fontFamily: 'Arial, Helvetica, sans-serif',
        fontSize: 54,
        lineHeight: 1.14,
        fontWeight: 800,
        letterSpacing: -0.8,
        textShadow: '0 2px 4px rgba(0,0,0,.95), 0 8px 24px rgba(0,0,0,.72)',
      }}
    >
      <span
        style={{
          display: 'inline',
          boxDecorationBreak: 'clone',
          WebkitBoxDecorationBreak: 'clone',
          padding: '5px 13px 7px',
          borderRadius: 9,
          background: 'rgba(4,6,9,.42)',
        }}
      >
        {text}
      </span>
    </div>
  );
};

const ChapterReveal: React.FC<{rank: string; title: string}> = ({rank, title}) => {
  const frame = useCurrentFrame();
  const p = interpolate(frame, [0, 9, 18], [0, 1, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
  return (
    <div
      style={{
        position: 'absolute',
        left: 74,
        top: 96,
        opacity: p,
        transform: `translateX(${(1 - p) * -18}px)`,
        color: COLORS.text,
        fontFamily: 'Arial, Helvetica, sans-serif',
      }}
    >
      <div style={{fontSize: 27, fontWeight: 800, letterSpacing: 5.5, color: COLORS.accent}}>{rank}</div>
      <div style={{marginTop: 8, fontSize: 54, lineHeight: 1, fontWeight: 900, letterSpacing: -1.8}}>{title}</div>
      <div style={{marginTop: 17, width: 118, height: 3, background: COLORS.accent, opacity: 0.85}} />
    </div>
  );
};

const MusicBed: React.FC = () => {
  const {fps} = useVideoConfig();
  return (
    <Audio
      src={staticFile('audio/Abandoned 1.wav')}
      volume={(frame) => {
        const sec = frame / fps;
        const intro = Math.min(1, sec / 2.2);
        const end = Math.max(0, Math.min(1, (90 - sec) / 1.5));
        const titleLift = sec >= 28.5 && sec <= 36 ? 1.22 : 1;
        return 0.082 * intro * end * titleLift;
      }}
    />
  );
};

export const HiddenPerspectiveV26Proof: React.FC = () => {
  return (
    <AbsoluteFill style={{backgroundColor: COLORS.bg}}>
      {proofShots.map((shot, i) => {
        const from = Math.round(shot.start * FPS);
        const durationInFrames = Math.max(1, Math.round((shot.end - shot.start) * FPS));
        return (
          <Sequence key={`${shot.asset}-${i}`} from={from} durationInFrames={durationInFrames} premountFor={15}>
            <StillShot shot={shot} durationInFrames={durationInFrames} />
          </Sequence>
        );
      })}

      <Sequence from={Math.round(33.851 * FPS)} durationInFrames={Math.round(3.6 * FPS)}>
        <ChapterReveal rank="#20" title="MAUNSELL SEA FORTS" />
      </Sequence>
      <Sequence from={Math.round(85.003 * FPS)} durationInFrames={Math.round(3.1 * FPS)}>
        <ChapterReveal rank="#19" title="HOUTOUWAN" />
      </Sequence>

      {proofCaptions.map((c, i) => {
        const from = Math.round(c.start * FPS);
        const durationInFrames = Math.max(1, Math.round((c.end - c.start) * FPS));
        return (
          <Sequence key={`caption-${i}`} from={from} durationInFrames={durationInFrames}>
            <Caption text={c.text} durationInFrames={durationInFrames} />
          </Sequence>
        );
      })}

      <Audio src={staticFile('audio/abandoned-1.mp3')} volume={1} />
      <MusicBed />
    </AbsoluteFill>
  );
};

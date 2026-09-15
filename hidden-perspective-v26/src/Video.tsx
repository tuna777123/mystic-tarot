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
import {proofCaptions, proofShots, type Crop, type Motion, type Shot} from './proofData';

const FPS = 30;

const COLORS = {
  bg: '#07090d',
  text: '#f7f7f5',
  muted: '#c9ccd1',
  accent: '#d0ad68',
};

const smooth = (frame: number, duration: number) =>
  interpolate(frame, [0, Math.max(1, duration - 1)], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.inOut(Easing.cubic),
  });

const motionTransform = (motion: Motion, p: number) => {
  const s = {
    push: 1.025 + p * 0.035,
    pull: 1.065 - p * 0.035,
    pan_left: 1.045,
    pan_right: 1.045,
  }[motion];
  const x = motion === 'pan_left' ? 1.6 - p * 3.2 : motion === 'pan_right' ? -1.6 + p * 3.2 : 0;
  const y = motion === 'push' ? 0.35 - p * 0.7 : motion === 'pull' ? -0.3 + p * 0.6 : 0;
  return `translate3d(${x}%, ${y}%, 0) scale(${s})`;
};

const reconstructionAssets = new Set([
  'Buses line Pripyat for evacuation.png',
  'Ordinary Life in Pripyat, 1985.png',
  'Villa Epecuén Beneath the Floodwaters.png',
  'Centralia mine fire, four documentary views.png',
  'Plymouth Buried in Volcanic Ash.png',
]);

const cropStyle = (crop?: Crop): React.CSSProperties => {
  if (!crop) return {width: '100%', height: '100%', left: 0, top: 0};
  const left = crop === 'tr' || crop === 'br' ? '-100%' : '0%';
  const top = crop === 'bl' || crop === 'br' ? '-100%' : '0%';
  return {width: '200%', height: '200%', left, top};
};

const cropOrigin = (crop?: Crop) => {
  if (crop === 'tl') return '25% 25%';
  if (crop === 'tr') return '75% 25%';
  if (crop === 'bl') return '25% 75%';
  if (crop === 'br') return '75% 75%';
  return '50% 50%';
};

const gradeFor = (asset: string) => {
  if (asset.includes('Houtouwan')) return 'contrast(1.08) saturate(0.78) brightness(0.97)';
  if (asset.includes('Classroom') || asset.includes('Lessons')) return 'contrast(1.08) saturate(0.84) brightness(1.035)';
  if (asset.includes('Floodwaters')) return 'contrast(1.12) saturate(0.78) brightness(1.10)';
  if (asset.includes('Pripyat, 1985') || asset.includes('Buses line Pripyat'))
    return 'contrast(1.12) saturate(0.74) brightness(0.98) sepia(0.06)';
  if (asset.includes('Buzludzha')) return 'contrast(1.10) saturate(0.78) brightness(0.98)';
  if (asset.includes('Maunsell')) return 'contrast(1.09) saturate(0.80) brightness(0.98)';
  return 'contrast(1.075) saturate(0.86) brightness(0.985)';
};

const ReconstructionLabel: React.FC = () => (
  <div
    style={{
      position: 'absolute',
      top: 64,
      left: 72,
      padding: '11px 16px 10px',
      border: '1px solid rgba(255,255,255,.30)',
      borderRadius: 8,
      background: 'rgba(7,9,13,.78)',
      color: 'rgba(255,255,255,.94)',
      fontFamily: 'Arial, Helvetica, sans-serif',
      fontSize: 30,
      lineHeight: 1,
      fontWeight: 800,
      letterSpacing: 1.5,
      textTransform: 'uppercase',
      boxShadow: '0 8px 28px rgba(0,0,0,.28)',
    }}
  >
    AI-assisted reconstruction
  </div>
);

const StillShot: React.FC<{shot: Shot; durationInFrames: number}> = ({shot, durationInFrames}) => {
  const frame = useCurrentFrame();
  const p = smooth(frame, durationInFrames);
  const isReconstruction = Boolean(shot.reconstruction) || reconstructionAssets.has(shot.asset);

  return (
    <AbsoluteFill style={{backgroundColor: COLORS.bg, overflow: 'hidden'}}>
      <Img
        src={staticFile(`assets/${shot.asset}`)}
        style={{
          position: 'absolute',
          ...cropStyle(shot.crop),
          objectFit: 'cover',
          objectPosition: shot.objectPosition ?? '50% 50%',
          transform: motionTransform(shot.motion, p),
          transformOrigin: cropOrigin(shot.crop),
          filter: gradeFor(shot.asset),
          willChange: 'transform',
        }}
      />
      <AbsoluteFill
        style={{
          background:
            'linear-gradient(180deg, rgba(3,5,8,.18) 0%, rgba(3,5,8,.015) 42%, rgba(3,5,8,.18) 70%, rgba(3,5,8,.50) 100%)',
        }}
      />
      <AbsoluteFill style={{boxShadow: 'inset 0 0 145px rgba(0,0,0,.27)', pointerEvents: 'none'}} />
      {isReconstruction ? <ReconstructionLabel /> : null}
    </AbsoluteFill>
  );
};

const captionTypography = (text: string) => {
  const len = text.length;
  if (len >= 64) return {fontSize: 46, width: 1280};
  if (len >= 52) return {fontSize: 48, width: 1380};
  return {fontSize: 50, width: 1480};
};

const Caption: React.FC<{text: string; durationInFrames: number}> = ({text, durationInFrames}) => {
  const frame = useCurrentFrame();
  const enter = interpolate(frame, [0, 3], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
  const exit = interpolate(frame, [Math.max(0, durationInFrames - 3), durationInFrames], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const opacity = Math.min(enter, exit);
  const type = captionTypography(text);

  return (
    <>
      <div
        style={{
          position: 'absolute',
          left: 0,
          right: 0,
          bottom: 0,
          height: 250,
          background: 'linear-gradient(180deg, rgba(4,6,10,0) 0%, rgba(4,6,10,.47) 100%)',
          pointerEvents: 'none',
        }}
      />
      <div
        style={{
          position: 'absolute',
          left: '50%',
          bottom: 102,
          transform: `translateX(-50%) translateY(${(1 - enter) * 3}px)`,
          opacity,
          width: type.width,
          maxWidth: '88%',
          textAlign: 'center',
          textWrap: 'balance',
          color: COLORS.text,
          fontFamily: 'Arial, Helvetica, sans-serif',
          fontSize: type.fontSize,
          lineHeight: 1.17,
          fontWeight: 750,
          letterSpacing: -0.55,
          textShadow: '0 2px 4px rgba(0,0,0,.92), 0 7px 22px rgba(0,0,0,.68)',
        }}
      >
        <span
          style={{
            display: 'inline',
            boxDecorationBreak: 'clone',
            WebkitBoxDecorationBreak: 'clone',
            padding: '6px 15px 8px',
            borderRadius: 8,
            background: 'rgba(5,7,10,.54)',
          }}
        >
          {text}
        </span>
      </div>
    </>
  );
};

const ChapterReveal: React.FC<{rank: string; title: string; subtitle: string}> = ({rank, title, subtitle}) => {
  const frame = useCurrentFrame();
  const p = interpolate(frame, [0, 10, 20], [0, 1, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.cubic),
  });

  return (
    <>
      <AbsoluteFill
        style={{
          background: 'linear-gradient(90deg, rgba(4,6,9,.88) 0%, rgba(4,6,9,.68) 31%, rgba(4,6,9,.17) 58%, rgba(4,6,9,0) 76%)',
        }}
      />
      <div
        style={{
          position: 'absolute',
          left: 104,
          top: 142,
          width: 1040,
          opacity: p,
          transform: `translateX(${(1 - p) * -24}px)`,
          color: COLORS.text,
          fontFamily: 'Arial, Helvetica, sans-serif',
        }}
      >
        <div style={{fontSize: 25, fontWeight: 800, letterSpacing: 6, color: COLORS.accent}}>ABANDONED PLACE</div>
        <div style={{marginTop: 23, fontSize: 150, lineHeight: 0.88, fontWeight: 900, letterSpacing: -7, color: COLORS.accent}}>{rank}</div>
        <div style={{marginTop: 20, fontSize: 79, lineHeight: 0.98, fontWeight: 900, letterSpacing: -2.4}}>{title}</div>
        <div style={{marginTop: 22, fontSize: 31, lineHeight: 1.15, fontWeight: 600, letterSpacing: 1.1, color: COLORS.muted}}>{subtitle}</div>
        <div style={{marginTop: 26, width: 160, height: 4, background: COLORS.accent}} />
      </div>
    </>
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
        const titleLift = sec >= 28.5 && sec <= 37.5 ? 1.14 : 1;
        return 0.074 * intro * end * titleLift;
      }}
    />
  );
};

export const HiddenPerspectiveV26Proof: React.FC = () => {
  const visibleCaptions = proofCaptions.filter(
    (c) =>
      !(
        (c.start >= 33.851 && c.end <= 37.45) ||
        (c.start >= 85.003 && c.end <= 88.08)
      ),
  );

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
        <ChapterReveal rank="#20" title="MAUNSELL SEA FORTS" subtitle="THAMES ESTUARY · UNITED KINGDOM" />
      </Sequence>
      <Sequence from={Math.round(85.003 * FPS)} durationInFrames={Math.round(3.1 * FPS)}>
        <ChapterReveal rank="#19" title="HOUTOUWAN" subtitle="SHENGSHAN ISLAND · CHINA" />
      </Sequence>

      {visibleCaptions.map((c, i) => {
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

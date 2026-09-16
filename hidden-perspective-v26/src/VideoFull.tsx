import React from 'react';
import {
  AbsoluteFill,
  Easing,
  Img,
  Sequence,
  interpolate,
  staticFile,
  useCurrentFrame,
} from 'remotion';
import {
  chapterReveals,
  fullCaptions,
  fullShots,
  type Crop,
  type FullShot,
  type Motion,
} from './fullData.generated';

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
    easing: Easing.bezier(0.45, 0, 0.55, 1),
  });

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

const motionTransform = (motion: Motion, p: number, durationInFrames: number) => {
  const seconds = durationInFrames / FPS;
  const travelFactor = Math.max(0.30, Math.min(1, seconds / 4.6));
  const pan = 1.45 * travelFactor;
  const zoomSpan = 0.028 + 0.010 * travelFactor;

  const scale =
    motion === 'push'
      ? 1.035 + p * zoomSpan
      : motion === 'pull'
        ? 1.035 + (1 - p) * zoomSpan
        : 1.055;
  const x =
    motion === 'pan_left'
      ? pan - p * pan * 2
      : motion === 'pan_right'
        ? -pan + p * pan * 2
        : 0;
  const y =
    motion === 'push'
      ? 0.22 * travelFactor - p * 0.44 * travelFactor
      : motion === 'pull'
        ? -0.18 * travelFactor + p * 0.36 * travelFactor
        : 0;

  return `translate3d(${x}%, ${y}%, 0) scale(${scale})`;
};

const gradeFor = (shot: FullShot) => {
  const s = `${shot.location ?? ''} ${shot.asset}`.toLowerCase();
  if (s.includes('houtouwan')) return 'contrast(1.08) saturate(.80) brightness(.985)';
  if (s.includes('pripyat')) return 'contrast(1.09) saturate(.78) brightness(.985)';
  if (s.includes('maunsell')) return 'contrast(1.09) saturate(.80) brightness(.985)';
  if (s.includes('wittenoom') || s.includes('centralia')) return 'contrast(1.10) saturate(.76) brightness(.98)';
  if (s.includes('oradour')) return 'contrast(1.10) saturate(.72) brightness(.99)';
  return 'contrast(1.075) saturate(.84) brightness(.99)';
};

const ReconstructionLabel: React.FC = () => (
  <div
    style={{
      position: 'absolute',
      top: 58,
      left: 70,
      padding: '10px 15px 9px',
      border: '1px solid rgba(255,255,255,.30)',
      borderRadius: 8,
      background: 'rgba(7,9,13,.80)',
      color: 'rgba(255,255,255,.95)',
      fontFamily: 'Arial, Helvetica, sans-serif',
      fontSize: 26,
      lineHeight: 1,
      fontWeight: 800,
      letterSpacing: 1.45,
      textTransform: 'uppercase',
      textShadow: '0 2px 8px rgba(0,0,0,.55)',
      boxShadow: '0 8px 28px rgba(0,0,0,.28)',
    }}
  >
    AI-assisted reconstruction
  </div>
);

const BurnedCaptionMask: React.FC = () => (
  <div
    style={{
      position: 'absolute',
      left: 0,
      right: 0,
      bottom: 0,
      height: 330,
      background:
        'linear-gradient(180deg, rgba(5,7,10,0) 0%, rgba(5,7,10,.30) 26%, rgba(5,7,10,.80) 57%, rgba(5,7,10,.97) 100%)',
      pointerEvents: 'none',
    }}
  />
);

const StillShot: React.FC<{shot: FullShot; durationInFrames: number}> = ({shot, durationInFrames}) => {
  const frame = useCurrentFrame();
  const p = smooth(frame, durationInFrames);
  const isFrameGrab = shot.asset.startsWith('frames/');

  return (
    <AbsoluteFill style={{backgroundColor: COLORS.bg, overflow: 'hidden'}}>
      <Img
        src={staticFile(shot.asset)}
        style={{
          position: 'absolute',
          ...cropStyle(shot.crop),
          objectFit: 'cover',
          objectPosition: shot.objectPosition ?? '50% 50%',
          transform: motionTransform(shot.motion, p, durationInFrames),
          transformOrigin: cropOrigin(shot.crop),
          filter: gradeFor(shot),
          willChange: 'transform',
        }}
      />
      <AbsoluteFill
        style={{
          background:
            'linear-gradient(180deg, rgba(3,5,8,.14) 0%, rgba(3,5,8,.015) 38%, rgba(3,5,8,.10) 66%, rgba(3,5,8,.32) 100%)',
        }}
      />
      <AbsoluteFill style={{boxShadow: 'inset 0 0 145px rgba(0,0,0,.25)', pointerEvents: 'none'}} />
      {isFrameGrab ? <BurnedCaptionMask /> : null}
      {shot.reconstruction ? <ReconstructionLabel /> : null}
    </AbsoluteFill>
  );
};

const captionTypography = (text: string) => {
  const len = text.trim().length;
  if (len >= 78) return {fontSize: 43, width: 1260};
  if (len >= 64) return {fontSize: 46, width: 1320};
  if (len >= 52) return {fontSize: 48, width: 1400};
  return {fontSize: 51, width: 1500};
};

const Caption: React.FC<{text: string; durationInFrames: number}> = ({text, durationInFrames}) => {
  const frame = useCurrentFrame();
  const enter = interpolate(frame, [0, 2], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.cubic),
  });
  const exit = interpolate(frame, [Math.max(0, durationInFrames - 2), durationInFrames], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const opacity = Math.min(enter, exit);
  const type = captionTypography(text);

  return (
    <div
      style={{
        position: 'absolute',
        left: '50%',
        bottom: 86,
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
        fontWeight: 760,
        letterSpacing: -0.5,
        textShadow: '0 2px 4px rgba(0,0,0,.95), 0 8px 24px rgba(0,0,0,.72)',
      }}
    >
      <span
        style={{
          display: 'inline',
          boxDecorationBreak: 'clone',
          WebkitBoxDecorationBreak: 'clone',
          padding: '6px 15px 8px',
          borderRadius: 8,
          background: 'rgba(4,6,9,.58)',
        }}
      >
        {text}
      </span>
    </div>
  );
};

const ChapterReveal: React.FC<{rank: string; title: string; subtitle: string}> = ({rank, title, subtitle}) => {
  const frame = useCurrentFrame();
  const p = interpolate(frame, [0, 9, 18], [0, 1, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.cubic),
  });
  const rule = interpolate(frame, [7, 21], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.cubic),
  });

  return (
    <>
      <AbsoluteFill
        style={{
          background:
            'linear-gradient(90deg, rgba(4,6,9,.91) 0%, rgba(4,6,9,.72) 31%, rgba(4,6,9,.22) 58%, rgba(4,6,9,0) 78%)',
        }}
      />
      <div
        style={{
          position: 'absolute',
          left: 104,
          top: 136,
          width: 1090,
          opacity: p,
          transform: `translateX(${(1 - p) * -22}px)`,
          color: COLORS.text,
          fontFamily: 'Arial, Helvetica, sans-serif',
        }}
      >
        <div style={{fontSize: 24, fontWeight: 850, letterSpacing: 6.2, color: COLORS.accent}}>ABANDONED PLACE</div>
        <div style={{marginTop: 21, fontSize: 142, lineHeight: 0.88, fontWeight: 900, letterSpacing: -6, color: COLORS.accent}}>{rank}</div>
        <div style={{marginTop: 19, fontSize: title.length > 22 ? 67 : 78, lineHeight: 0.99, fontWeight: 900, letterSpacing: -2.2}}>{title}</div>
        <div style={{marginTop: 21, fontSize: 29, lineHeight: 1.15, fontWeight: 650, letterSpacing: 1.05, color: COLORS.muted}}>{subtitle}</div>
        <div style={{marginTop: 25, width: 166 * rule, height: 4, background: COLORS.accent}} />
      </div>
    </>
  );
};

const captionIsInsideReveal = (start: number, end: number) =>
  chapterReveals.some((chapter) => start >= chapter.start - 0.08 && end <= chapter.start + 3.75);

export const HiddenPerspectiveV26Full: React.FC = () => {
  const visibleCaptions = fullCaptions.filter((c) => !captionIsInsideReveal(c.start, c.end));

  return (
    <AbsoluteFill style={{backgroundColor: COLORS.bg}}>
      {fullShots.map((shot, i) => {
        const from = Math.round(shot.start * FPS);
        const durationInFrames = Math.max(1, Math.round((shot.end - shot.start) * FPS));
        return (
          <Sequence key={`${shot.asset}-${i}`} from={from} durationInFrames={durationInFrames} premountFor={8}>
            <StillShot shot={shot} durationInFrames={durationInFrames} />
          </Sequence>
        );
      })}

      {chapterReveals.map((chapter, i) => (
        <Sequence
          key={`chapter-${chapter.rank}-${i}`}
          from={Math.round(chapter.start * FPS)}
          durationInFrames={Math.round(3.7 * FPS)}
        >
          <ChapterReveal rank={chapter.rank} title={chapter.title} subtitle={chapter.subtitle} />
        </Sequence>
      ))}

      {visibleCaptions.map((c, i) => {
        const from = Math.round(c.start * FPS);
        const durationInFrames = Math.max(1, Math.round((c.end - c.start) * FPS));
        return (
          <Sequence key={`caption-${i}`} from={from} durationInFrames={durationInFrames}>
            <Caption text={c.text} durationInFrames={durationInFrames} />
          </Sequence>
        );
      })}
    </AbsoluteFill>
  );
};

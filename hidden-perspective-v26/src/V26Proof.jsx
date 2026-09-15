import React from 'react';
import {
  AbsoluteFill,
  Audio,
  Sequence,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';

const FPS = 30;
const sec = (n) => Math.round(n * FPS);
const clamp01 = (v) => Math.max(0, Math.min(1, v));
const smoother = (t) => {
  const x = clamp01(t);
  return x * x * x * (x * (x * 6 - 15) + 10);
};

const CAPTIONS = [
  [0.000,4.279,'Imagine returning to your hometown and finding dinner plates still'],
  [4.279,8.559,'on tables, schoolbooks left behind, and entire streets with no one'],
  [8.559,9.726,'left to walk them.'],
  [9.726,12.011,'Some places emptied slowly.'],
  [12.011,14.781,'Others lost everyone in a single day.'],
  [14.781,17.642,'One town is still burning beneath the ground.'],
  [17.642,20.151,'Another disappeared beneath a lake.'],
  [20.151,24.393,'And in the number one location, almost fifty thousand people were'],
  [24.393,26.743,'told they would be home within days.'],
  [26.743,28.634,'They never returned.'],
  [28.634,31.700,'These are twenty places everyone abandoned...'],
  [31.700,33.851,'and the dark reasons why.'],
  [33.851,35.254,'Number twenty.'],
  [35.254,37.450,'The Maunsell Sea Forts.'],
  [37.450,41.716,'Rising from the waters of the Thames Estuary, these rusting towers'],
  [41.716,44.301,'look like the remains of a drowned city.'],
  [44.301,48.245,'They were built during World War Two to defend Britain from German'],
  [48.245,48.783,'aircraft.'],
  [48.783,53.842,'Each fort consisted of armed steel towers connected by narrow'],
  [53.842,57.988,'walkways, with soldiers living high above the sea.'],
  [57.988,61.122,'After the war, the weapons were removed and the crews went home.'],
  [61.122,64.978,'Some towers were later occupied by pirate radio stations,'],
  [64.978,69.510,'broadcasting illegal music from beyond British territorial control.'],
  [69.510,73.433,'But eventually, even those voices disappeared.'],
  [73.433,76.013,'Today, the forts stand empty.'],
  [76.013,80.009,'Their walkways have collapsed, their metal shells are slowly'],
  [80.009,84.204,'corroding, and the only permanent sound is the sea striking the'],
  [84.204,85.003,'steel below.'],
  [85.003,86.545,'Number nineteen.'],
  [86.545,88.080,'Houtouwan.'],
  [88.080,90.000,'Hidden on a remote island off the coast of China, Houtouwan was'],
];

const SHOTS = [
  {s:0.000,e:4.279,file:'classroom-book.png',motion:'push',focus:'center'},
  {s:4.279,e:8.559,file:'classroom-lessons.png',motion:'panR',focus:'center'},
  {s:8.559,e:12.011,file:'pripyat-life.png',motion:'pull',focus:'center'},
  {s:12.011,e:14.781,file:'pripyat-buses.png',motion:'panL',focus:'center'},
  {s:14.781,e:17.642,file:'centralia-grid.png',motion:'push',crop:'tl'},
  {s:17.642,e:20.151,file:'villa.png',motion:'pull',focus:'center'},
  {s:20.151,e:24.393,file:'pripyat-life.png',motion:'panR',focus:'center'},
  {s:24.393,e:28.634,file:'pripyat-buses.png',motion:'push',focus:'center'},
  {s:28.634,e:31.700,file:'classroom-book.png',motion:'pull',focus:'center'},
  {s:31.700,e:33.851,file:'maunsell-mist.png',motion:'push',focus:'center'},
  {s:33.851,e:37.450,file:'maunsell-mist.png',motion:'push',focus:'center'},
  {s:37.450,e:41.716,file:'maunsell-mist.png',motion:'panR',focus:'center'},
  {s:41.716,e:44.301,file:'maunsell-beneath.png',motion:'pull',focus:'center'},
  {s:44.301,e:48.783,file:'maunsell-gun.png',motion:'push',focus:'center'},
  {s:48.783,e:53.842,file:'maunsell-catwalk.png',motion:'panL',focus:'center'},
  {s:53.842,e:57.988,file:'maunsell-beneath.png',motion:'panR',focus:'center'},
  {s:57.988,e:61.122,file:'maunsell-gun.png',motion:'pull',focus:'center'},
  {s:61.122,e:69.510,file:'maunsell-radio.png',motion:'push',focus:'center',reconstruction:true},
  {s:69.510,e:73.433,file:'maunsell-catwalk.png',motion:'pull',focus:'center'},
  {s:73.433,e:76.013,file:'maunsell-mist.png',motion:'push',focus:'center'},
  {s:76.013,e:80.009,file:'maunsell-catwalk.png',motion:'panR',focus:'center'},
  {s:80.009,e:85.003,file:'maunsell-beneath.png',motion:'pull',focus:'center'},
  {s:85.003,e:88.080,file:'houtouwan-green.png',motion:'push',focus:'center'},
  {s:88.080,e:90.000,file:'houtouwan-1980s.png',motion:'pull',focus:'center',reconstruction:true},
];

const visualTransform = (motion, p, crop) => {
  const eased = smoother(p);
  const cropScale = crop ? 2.05 : 1;
  let scale = 1.025;
  let x = 0;
  let y = 0;
  if (motion === 'push') scale = 1.015 + 0.045 * eased;
  if (motion === 'pull') scale = 1.065 - 0.045 * eased;
  if (motion === 'panR') { scale = 1.05; x = -1.5 + 3.0 * eased; }
  if (motion === 'panL') { scale = 1.05; x = 1.5 - 3.0 * eased; }
  return {scale: scale * cropScale, x, y};
};

const Shot = ({shot}) => {
  const frame = useCurrentFrame();
  const duration = sec(shot.e - shot.s) + 12;
  const local = frame;
  const p = clamp01(local / Math.max(1, duration - 1));
  const tr = visualTransform(shot.motion, p, shot.crop);
  const fade = 6;
  const inOpacity = clamp01(local / fade);
  const outOpacity = clamp01((duration - 1 - local) / fade);
  const opacity = Math.min(inOpacity, outOpacity);
  const cropStyle = shot.crop === 'tl'
    ? {transformOrigin:'25% 25%', objectPosition:'25% 25%'}
    : {transformOrigin:'50% 50%', objectPosition:'50% 50%'};

  return (
    <AbsoluteFill style={{overflow:'hidden', opacity, background:'#080b0e'}}>
      <img
        src={staticFile(`assets/${shot.file}`)}
        style={{
          position:'absolute',
          inset:0,
          width:'100%',
          height:'100%',
          objectFit:'cover',
          ...cropStyle,
          transform:`translate3d(${tr.x}%, ${tr.y}%, 0) scale(${tr.scale})`,
          filter:'brightness(0.88) contrast(1.07) saturate(0.84)',
        }}
      />
      <AbsoluteFill style={{background:'linear-gradient(180deg, rgba(2,5,8,.10) 0%, rgba(2,5,8,.02) 45%, rgba(2,5,8,.46) 100%)'}} />
      <AbsoluteFill style={{background:'radial-gradient(circle at center, transparent 52%, rgba(0,0,0,.34) 100%)'}} />
      {shot.reconstruction ? (
        <div style={{
          position:'absolute', top:52, left:58, padding:'8px 13px',
          border:'1px solid rgba(255,255,255,.24)', borderRadius:6,
          background:'rgba(5,8,10,.58)', color:'rgba(255,255,255,.86)',
          fontFamily:'Arial, Helvetica, sans-serif', fontSize:18,
          fontWeight:700, letterSpacing:2.2,
        }}>AI-ASSISTED RECONSTRUCTION</div>
      ) : null}
    </AbsoluteFill>
  );
};

const Captions = () => {
  const frame = useCurrentFrame();
  const t = frame / FPS;
  const cue = CAPTIONS.find(([s,e]) => t >= s && t < e);
  if (!cue) return null;
  const [start,,text] = cue;
  const age = frame - sec(start);
  const enter = smoother(clamp01(age / 4));
  const fontSize = text.length > 70 ? 48 : text.length > 55 ? 51 : 54;
  return (
    <AbsoluteFill style={{justifyContent:'flex-end', alignItems:'center', pointerEvents:'none'}}>
      <div style={{
        marginBottom:78,
        maxWidth:1480,
        padding:'13px 23px 15px',
        borderRadius:12,
        background:'rgba(5,8,11,.68)',
        border:'1px solid rgba(255,255,255,.08)',
        boxShadow:'0 10px 34px rgba(0,0,0,.28)',
        color:'#f7f7f4',
        fontFamily:'Arial, Helvetica, sans-serif',
        fontSize,
        fontWeight:750,
        lineHeight:1.12,
        letterSpacing:-0.4,
        textAlign:'center',
        textShadow:'0 2px 7px rgba(0,0,0,.72)',
        opacity:enter,
        transform:`translateY(${(1-enter)*7}px)`,
      }}>{text}</div>
    </AbsoluteFill>
  );
};

const ChapterTitle = () => {
  const frame = useCurrentFrame();
  const t = frame / FPS;
  let start = null;
  let kicker = '';
  let title = '';
  let sub = '';
  if (t >= 33.851 && t < 38.1) {
    start = 33.851; kicker = 'NUMBER 20'; title = 'MAUNSELL SEA FORTS'; sub = 'THAMES ESTUARY • ENGLAND';
  } else if (t >= 85.003 && t < 89.7) {
    start = 85.003; kicker = 'NUMBER 19'; title = 'HOUTOUWAN'; sub = 'SHENGSHAN ISLAND • CHINA';
  }
  if (start === null) return null;
  const p = smoother(clamp01((frame - sec(start)) / 14));
  return (
    <div style={{position:'absolute', left:86, top:100, color:'#fff', opacity:p, transform:`translateX(${(1-p)*-20}px)`}}>
      <div style={{fontFamily:'Arial, Helvetica, sans-serif', fontSize:22, fontWeight:800, letterSpacing:4.2, opacity:.82}}>{kicker}</div>
      <div style={{marginTop:9, fontFamily:'Arial, Helvetica, sans-serif', fontSize:70, fontWeight:900, letterSpacing:-2.3, lineHeight:.98, textShadow:'0 4px 22px rgba(0,0,0,.55)'}}>{title}</div>
      <div style={{marginTop:13, fontFamily:'Arial, Helvetica, sans-serif', fontSize:18, fontWeight:700, letterSpacing:3.3, opacity:.72}}>{sub}</div>
      <div style={{marginTop:18, width:190*p, height:3, background:'rgba(255,255,255,.86)'}} />
    </div>
  );
};

const HookTitle = () => {
  const frame = useCurrentFrame();
  const t = frame / FPS;
  if (t < 28.634 || t >= 33.75) return null;
  const p = smoother(clamp01((frame - sec(28.634)) / 12));
  return (
    <AbsoluteFill style={{justifyContent:'center', alignItems:'center', paddingBottom:80, opacity:p}}>
      <div style={{textAlign:'center', color:'#fff', textShadow:'0 5px 28px rgba(0,0,0,.68)'}}>
        <div style={{fontFamily:'Arial, Helvetica, sans-serif', fontSize:30, fontWeight:800, letterSpacing:7, opacity:.85}}>20 PLACES</div>
        <div style={{marginTop:8, fontFamily:'Arial, Helvetica, sans-serif', fontSize:82, fontWeight:900, letterSpacing:-2.8}}>EVERYONE ABANDONED</div>
        <div style={{marginTop:10, fontFamily:'Arial, Helvetica, sans-serif', fontSize:26, fontWeight:700, letterSpacing:5.2, opacity:.80}}>AND THE DARK REASONS WHY</div>
      </div>
    </AbsoluteFill>
  );
};

const Music = () => {
  const frame = useCurrentFrame();
  const t = frame / FPS;
  let base = 0.075;
  if (t < 4) base = 0.055 + t * 0.007;
  if (t >= 28.4 && t < 34.2) base = 0.10;
  if (t >= 33.8 && t < 38.2) base = 0.085;
  if (t >= 84.7) base = 0.09;
  return <Audio src={staticFile('assets/score-1.wav')} volume={base} />;
};

export const V26Proof = () => {
  return (
    <AbsoluteFill style={{background:'#05080a'}}>
      {SHOTS.map((shot, i) => {
        const from = Math.max(0, sec(shot.s) - 6);
        const duration = sec(shot.e - shot.s) + 12;
        return (
          <Sequence key={`${shot.file}-${i}`} from={from} durationInFrames={duration} premountFor={30}>
            <Shot shot={shot} />
          </Sequence>
        );
      })}
      <Audio src={staticFile('assets/narration-1.mp3')} volume={1} />
      <Music />
      <HookTitle />
      <ChapterTitle />
      <Captions />
    </AbsoluteFill>
  );
};

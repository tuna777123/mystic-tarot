import React from 'react';
import {AbsoluteFill, Easing, interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';

const C = {
  bg: '#0B1118',
  panel: '#111A24',
  panel2: '#162230',
  text: '#F4F1EA',
  muted: '#8D99A8',
  gold: '#C7A152',
  gold2: '#E1C272',
  line: '#2A394A',
  soft: '#26384B',
};

const clamp = {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'};

const lineProgress = (frame, from, to) => interpolate(frame, [from, to], [0, 1], {...clamp, easing: Easing.bezier(0.16, 1, 0.3, 1)});

const Grid = ({frame}) => {
  const drift = interpolate(frame, [0, 96], [0, 34], clamp);
  return (
    <AbsoluteFill
      style={{
        opacity: 0.22,
        backgroundImage:
          'linear-gradient(rgba(255,255,255,.045) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,.045) 1px, transparent 1px)',
        backgroundSize: '72px 72px',
        backgroundPosition: `${drift}px ${drift * 0.45}px`,
      }}
    />
  );
};

const DiagramFrame = ({children}) => (
  <div
    style={{
      position: 'absolute',
      right: 120,
      top: 175,
      width: 780,
      height: 730,
      borderRadius: 34,
      border: `1px solid ${C.line}`,
      background: 'linear-gradient(180deg, rgba(21,31,43,.95), rgba(10,16,24,.98))',
      boxShadow: '0 30px 80px rgba(0,0,0,.35)',
      overflow: 'hidden',
    }}
  >
    {children}
  </div>
);

const SystemsDiagram = ({frame}) => {
  const p = lineProgress(frame, 12, 62);
  const hand = interpolate(frame, [0, 96], [-50, 125], clamp);
  const nodes = [
    [520, 250], [620, 340], [500, 450], [650, 520], [400, 555], [330, 390],
  ];
  return (
    <DiagramFrame>
      <svg width="780" height="730" viewBox="0 0 780 730">
        <circle cx="205" cy="340" r="125" fill="none" stroke={C.line} strokeWidth="16" />
        <circle cx="205" cy="340" r="8" fill={C.gold2} />
        <line x1="205" y1="340" x2="205" y2="250" stroke={C.text} strokeWidth="10" strokeLinecap="round" transform={`rotate(${hand} 205 340)`} />
        <text x="205" y="520" textAnchor="middle" fill={C.muted} fontSize="28" fontFamily="Arial">HOURS</text>
        {nodes.map(([x, y], i) => (
          <circle key={i} cx={x} cy={y} r={18 + (i % 2) * 5} fill={i === 0 ? C.gold2 : C.soft} stroke={i === 0 ? C.gold2 : C.line} strokeWidth="4" />
        ))}
        {[[0,1],[1,2],[1,3],[2,4],[2,5],[4,5]].map(([a,b], i) => (
          <line key={i} x1={nodes[a][0]} y1={nodes[a][1]} x2={nodes[b][0]} y2={nodes[b][1]} stroke={C.gold} strokeWidth="5" strokeLinecap="round" opacity={0.25 + p * 0.75} />
        ))}
        <text x="535" y="650" textAnchor="middle" fill={C.gold2} fontSize="28" fontFamily="Arial">SYSTEMS</text>
      </svg>
    </DiagramFrame>
  );
};

const CompoundDiagram = ({frame}) => {
  const p = lineProgress(frame, 14, 72);
  return (
    <DiagramFrame>
      <svg width="780" height="730" viewBox="0 0 780 730">
        <line x1="110" y1="595" x2="690" y2="595" stroke={C.line} strokeWidth="4" />
        <line x1="110" y1="595" x2="110" y2="120" stroke={C.line} strokeWidth="4" />
        <path d="M120 565 C260 555 310 520 390 465 C500 390 560 290 670 135" fill="none" stroke={C.gold2} strokeWidth="12" strokeLinecap="round" pathLength="1" strokeDasharray="1" strokeDashoffset={1 - p} />
        {[0.18,0.38,0.58,0.78].map((v, i) => {
          const x = 145 + i * 145;
          const h = 55 + Math.pow(i + 1, 2) * 32;
          const grow = lineProgress(frame, 18 + i * 5, 45 + i * 4);
          return <rect key={i} x={x} y={595 - h * grow} width="58" height={h * grow} rx="10" fill={i === 3 ? C.gold : C.soft} />;
        })}
        <text x="390" y="665" textAnchor="middle" fill={C.muted} fontSize="26" fontFamily="Arial">TIME →</text>
      </svg>
    </DiagramFrame>
  );
};

const EmergencyDiagram = ({frame}) => {
  const p = lineProgress(frame, 14, 64);
  return (
    <DiagramFrame>
      <svg width="780" height="730" viewBox="0 0 780 730">
        <path d="M390 115 L570 180 L548 390 C532 520 454 585 390 615 C326 585 248 520 232 390 L210 180 Z" fill={C.panel2} stroke={C.gold} strokeWidth="10" />
        {[0,1,2,3,4,5].map((i) => {
          const on = Math.min(1, Math.max(0, p * 6 - i));
          return <rect key={i} x={286 + i * 35} y={320} width="25" height={125 * on} rx="8" fill={i < 3 ? C.gold2 : C.gold} transform={`translate(0 ${125 - 125 * on})`} />;
        })}
        <text x="390" y="285" textAnchor="middle" fill={C.text} fontSize="56" fontWeight="700" fontFamily="Arial">3–6</text>
        <text x="390" y="490" textAnchor="middle" fill={C.muted} fontSize="28" fontFamily="Arial">MONTHS OF RUNWAY</text>
      </svg>
    </DiagramFrame>
  );
};

const QuietDiagram = ({frame}) => {
  return (
    <DiagramFrame>
      <svg width="780" height="730" viewBox="0 0 780 730">
        {[0,1,2,3,4,5].map((i) => {
          const h = 70 + i * 58;
          const g = lineProgress(frame, 12 + i * 5, 40 + i * 6);
          return <rect key={i} x={120 + i * 92} y={590 - h * g} width="62" height={h * g} rx="12" fill={i === 5 ? C.gold2 : C.soft} />;
        })}
        <line x1="95" y1="590" x2="685" y2="590" stroke={C.line} strokeWidth="4" />
        <text x="390" y="655" textAnchor="middle" fill={C.muted} fontSize="26" fontFamily="Arial">QUIET • REPEATABLE • LONG TERM</text>
      </svg>
    </DiagramFrame>
  );
};

const SaveFirstDiagram = ({frame}) => {
  const p = lineProgress(frame, 12, 55);
  return (
    <DiagramFrame>
      <svg width="780" height="730" viewBox="0 0 780 730">
        <rect x="120" y="255" width="540" height="125" rx="28" fill={C.panel2} stroke={C.line} strokeWidth="4" />
        <rect x="120" y="255" width={540 * p} height="125" rx="28" fill={C.gold} opacity="0.95" />
        <text x="390" y="335" textAnchor="middle" fill={C.text} fontSize="54" fontWeight="700" fontFamily="Arial">5% FIRST</text>
        <path d="M390 410 L390 520" stroke={C.gold2} strokeWidth="10" strokeLinecap="round" />
        <path d="M350 485 L390 530 L430 485" fill="none" stroke={C.gold2} strokeWidth="10" strokeLinecap="round" strokeLinejoin="round" />
        <rect x="270" y="555" width="240" height="80" rx="20" fill={C.soft} />
        <text x="390" y="607" textAnchor="middle" fill={C.text} fontSize="30" fontFamily="Arial">SET ASIDE</text>
      </svg>
    </DiagramFrame>
  );
};

const SkillsDiagram = ({frame}) => {
  const p = lineProgress(frame, 12, 65);
  const items = [
    ['LEARN', 390, 180], ['PRACTICE', 205, 470], ['GET PAID', 575, 470]
  ];
  return (
    <DiagramFrame>
      <svg width="780" height="730" viewBox="0 0 780 730">
        <circle cx="390" cy="365" r="230" fill="none" stroke={C.line} strokeWidth="8" strokeDasharray="18 16" />
        {items.map(([label,x,y],i) => {
          const s = lineProgress(frame, 10 + i * 8, 30 + i * 8);
          return <g key={label} opacity={s} transform={`translate(${(1-s)*(390-x)} ${(1-s)*(365-y)})`}>
            <circle cx={x} cy={y} r="82" fill={i === 2 ? C.gold : C.panel2} stroke={i === 2 ? C.gold2 : C.line} strokeWidth="5" />
            <text x={x} y={y+9} textAnchor="middle" fill={C.text} fontSize="24" fontWeight="700" fontFamily="Arial">{label}</text>
          </g>;
        })}
        <path d="M465 205 C580 245 640 330 626 415" fill="none" stroke={C.gold2} strokeWidth="8" strokeLinecap="round" pathLength="1" strokeDasharray="1" strokeDashoffset={1-p} />
        <path d="M535 535 C420 620 300 605 230 525" fill="none" stroke={C.gold2} strokeWidth="8" strokeLinecap="round" pathLength="1" strokeDasharray="1" strokeDashoffset={1-p} />
        <path d="M160 415 C140 305 205 220 315 190" fill="none" stroke={C.gold2} strokeWidth="8" strokeLinecap="round" pathLength="1" strokeDasharray="1" strokeDashoffset={1-p} />
      </svg>
    </DiagramFrame>
  );
};

const DebtDiagram = ({frame}) => {
  const p = lineProgress(frame, 14, 62);
  return (
    <DiagramFrame>
      <svg width="780" height="730" viewBox="0 0 780 730">
        <rect x="250" y="285" width="280" height="150" rx="30" fill={C.panel2} stroke={C.line} strokeWidth="5" />
        <text x="390" y="350" textAnchor="middle" fill={C.text} fontSize="38" fontWeight="700" fontFamily="Arial">FUTURE</text>
        <text x="390" y="395" textAnchor="middle" fill={C.gold2} fontSize="38" fontWeight="700" fontFamily="Arial">YOU</text>
        <path d="M225 360 L95 360" stroke={C.muted} strokeWidth="14" strokeLinecap="round" pathLength="1" strokeDasharray="1" strokeDashoffset={1-p} />
        <path d="M555 360 L685 360" stroke={C.gold2} strokeWidth="14" strokeLinecap="round" pathLength="1" strokeDasharray="1" strokeDashoffset={1-p} />
        <text x="120" y="305" fill={C.muted} fontSize="28" fontFamily="Arial">DEBT</text>
        <text x="570" y="305" fill={C.gold2} fontSize="28" fontFamily="Arial">INVESTING</text>
        <text x="120" y="430" fill={C.muted} fontSize="20" fontFamily="Arial">PULLS FORWARD</text>
        <text x="553" y="430" fill={C.gold2} fontSize="20" fontFamily="Arial">SENDS FORWARD</text>
      </svg>
    </DiagramFrame>
  );
};

const IncomeDiagram = ({frame}) => {
  const p = lineProgress(frame, 14, 64);
  const ends = [[210,160],[570,150],[660,370],[550,570],[220,560],[115,355]];
  return (
    <DiagramFrame>
      <svg width="780" height="730" viewBox="0 0 780 730">
        <circle cx="390" cy="360" r="78" fill={C.gold} />
        <text x="390" y="370" textAnchor="middle" fill={C.bg} fontSize="26" fontWeight="700" fontFamily="Arial">CORE</text>
        {ends.map(([x,y],i) => (
          <g key={i}>
            <line x1="390" y1="360" x2={x} y2={y} stroke={C.gold2} strokeWidth="7" strokeLinecap="round" pathLength="1" strokeDasharray="1" strokeDashoffset={1-p} />
            <circle cx={x} cy={y} r="48" fill={i<2 ? C.panel2 : C.soft} stroke={C.line} strokeWidth="4" opacity={p} />
          </g>
        ))}
        <text x="390" y="685" textAnchor="middle" fill={C.muted} fontSize="26" fontFamily="Arial">DIVERSIFY THE FLOW</text>
      </svg>
    </DiagramFrame>
  );
};

const HomeDiagram = ({frame}) => {
  const p = lineProgress(frame, 14, 66);
  const roof = lineProgress(frame, 24, 76);
  return (
    <DiagramFrame>
      <svg width="780" height="730" viewBox="0 0 780 730">
        <rect x="110" y="555" width="560" height="24" rx="12" fill={C.line} />
        <rect x="110" y="555" width={560*p} height="24" rx="12" fill={C.gold2} />
        <rect x="260" y="310" width="260" height="220" rx="16" fill="none" stroke={C.text} strokeWidth="10" opacity={roof} />
        <path d="M225 330 L390 190 L555 330" fill="none" stroke={C.gold2} strokeWidth="12" strokeLinecap="round" strokeLinejoin="round" pathLength="1" strokeDasharray="1" strokeDashoffset={1-roof} />
        <rect x="355" y="420" width="70" height="110" fill={C.gold} opacity={roof} />
        <text x="390" y="645" textAnchor="middle" fill={C.muted} fontSize="26" fontFamily="Arial">SMALL HABIT → REAL ASSET</text>
      </svg>
    </DiagramFrame>
  );
};

const CompareDiagram = ({frame}) => {
  const p = lineProgress(frame, 14, 62);
  return (
    <DiagramFrame>
      <svg width="780" height="730" viewBox="0 0 780 730">
        <rect x="95" y="170" width="250" height="390" rx="28" fill={C.panel2} stroke={C.line} strokeWidth="5" />
        <rect x="435" y="170" width="250" height="390" rx="28" fill={C.panel2} stroke={C.gold} strokeWidth="5" />
        <text x="220" y="250" textAnchor="middle" fill={C.muted} fontSize="26" fontFamily="Arial">THEIR PAGE</text>
        <text x="560" y="250" textAnchor="middle" fill={C.gold2} fontSize="26" fontFamily="Arial">YOUR PAGE</text>
        {[0,1,2,3].map(i => <rect key={i} x="135" y={300+i*58} width={150-i*12} height="14" rx="7" fill={C.soft} />)}
        {[0,1,2,3].map(i => <rect key={i} x="475" y={300+i*58} width={(95+i*20)*p} height="14" rx="7" fill={C.gold} />)}
        <line x1="390" y1="215" x2="390" y2="520" stroke={C.line} strokeWidth="4" strokeDasharray="12 12" />
      </svg>
    </DiagramFrame>
  );
};

const PerfectDiagram = ({frame}) => {
  const p = lineProgress(frame, 12, 66);
  return (
    <DiagramFrame>
      <svg width="780" height="730" viewBox="0 0 780 730">
        <circle cx="390" cy="350" r="180" fill="none" stroke={C.line} strokeWidth="18" />
        <circle cx="390" cy="350" r="180" fill="none" stroke={C.gold2} strokeWidth="18" strokeLinecap="round" pathLength="1" strokeDasharray="1" strokeDashoffset={1-p} transform="rotate(-90 390 350)" />
        <text x="390" y="335" textAnchor="middle" fill={C.text} fontSize="44" fontWeight="700" fontFamily="Arial">PERFECT</text>
        <text x="390" y="390" textAnchor="middle" fill={C.muted} fontSize="30" fontFamily="Arial">MOMENT?</text>
        <line x1="250" y1="490" x2="530" y2="210" stroke={C.gold} strokeWidth="14" strokeLinecap="round" opacity={p} />
      </svg>
    </DiagramFrame>
  );
};

const TimeDiagram = ({frame}) => {
  const p = lineProgress(frame, 10, 66);
  return (
    <DiagramFrame>
      <svg width="780" height="730" viewBox="0 0 780 730">
        <circle cx="390" cy="340" r="210" fill="none" stroke={C.line} strokeWidth="12" />
        <line x1="390" y1="340" x2="390" y2="205" stroke={C.gold2} strokeWidth="14" strokeLinecap="round" transform={`rotate(${p*245} 390 340)`} />
        <line x1="390" y1="340" x2="505" y2="340" stroke={C.text} strokeWidth="10" strokeLinecap="round" transform={`rotate(${p*65} 390 340)`} />
        <circle cx="390" cy="340" r="12" fill={C.gold2} />
        <text x="390" y="625" textAnchor="middle" fill={C.gold2} fontSize="28" fontFamily="Arial">THE ONLY CAPITAL YOU CAN'T REPLACE</text>
      </svg>
    </DiagramFrame>
  );
};

const Diagram = ({kind, frame}) => {
  switch (kind) {
    case 'systems': return <SystemsDiagram frame={frame} />;
    case 'compound': return <CompoundDiagram frame={frame} />;
    case 'emergency': return <EmergencyDiagram frame={frame} />;
    case 'quiet': return <QuietDiagram frame={frame} />;
    case 'savefirst': return <SaveFirstDiagram frame={frame} />;
    case 'skills': return <SkillsDiagram frame={frame} />;
    case 'debt': return <DebtDiagram frame={frame} />;
    case 'income': return <IncomeDiagram frame={frame} />;
    case 'home': return <HomeDiagram frame={frame} />;
    case 'compare': return <CompareDiagram frame={frame} />;
    case 'perfect': return <PerfectDiagram frame={frame} />;
    case 'time': return <TimeDiagram frame={frame} />;
    default: return null;
  }
};

export const ConceptScene = ({kind, eyebrow, title, subtitle}) => {
  const frame = useCurrentFrame();
  const {fps, durationInFrames} = useVideoConfig();
  const enter = spring({frame, fps, config: {damping: 20, stiffness: 115, mass: 0.8}});
  const exit = interpolate(frame, [durationInFrames - 10, durationInFrames - 1], [1, 0], clamp);
  const titleY = interpolate(enter, [0, 1], [45, 0], clamp);
  const diagramX = interpolate(enter, [0, 1], [100, 0], clamp);
  const goldBar = lineProgress(frame, 8, 36);
  return (
    <AbsoluteFill style={{backgroundColor: C.bg, color: C.text, fontFamily: 'Arial, Helvetica, sans-serif', overflow: 'hidden', opacity: exit}}>
      <Grid frame={frame} />
      <div style={{position: 'absolute', inset: 0, background: 'radial-gradient(circle at 80% 20%, rgba(199,161,82,.11), transparent 35%)'}} />
      <div style={{position: 'absolute', left: 112, top: 92, display: 'flex', alignItems: 'center', gap: 18, opacity: enter}}>
        <div style={{width: 52, height: 4, borderRadius: 2, backgroundColor: C.gold, scale: `${goldBar} 1`, transformOrigin: 'left center'}} />
        <div style={{fontSize: 24, letterSpacing: 4, color: C.muted, fontWeight: 700}}>GRANT • PRINCIPLE</div>
      </div>
      <div style={{position: 'absolute', left: 112, top: 245, width: 700, translate: `0 ${titleY}px`, opacity: enter}}>
        <div style={{fontSize: 24, letterSpacing: 3.5, color: C.gold2, fontWeight: 700, marginBottom: 28}}>{eyebrow}</div>
        <div style={{fontSize: 84, lineHeight: 0.98, fontWeight: 800, letterSpacing: -3.5, maxWidth: 690}}>{title}</div>
        <div style={{fontSize: 31, lineHeight: 1.35, color: C.muted, maxWidth: 610, marginTop: 34}}>{subtitle}</div>
      </div>
      <div style={{translate: `${diagramX}px 0`, opacity: enter}}>
        <Diagram kind={kind} frame={frame} />
      </div>
      <div style={{position: 'absolute', left: 112, bottom: 92, fontSize: 18, letterSpacing: 3, color: '#5E6B78'}}>GRANT BUILDS WEALTH</div>
    </AbsoluteFill>
  );
};

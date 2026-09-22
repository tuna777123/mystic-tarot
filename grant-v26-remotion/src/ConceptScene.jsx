import React from 'react';
import {AbsoluteFill, Easing, interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';

const C = {
  paper: '#F6F1E8',
  ink: '#17212B',
  muted: '#66707A',
  gold: '#D0A64A',
  green: '#6E8C6A',
  red: '#C86D61',
  blue: '#6E8AA4',
  white: '#FFFDFC',
  line: '#D8D0C4',
  shadow: 'rgba(23,33,43,.14)',
};

const clamp = {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'};
const ease = Easing.bezier(0.16, 1, 0.3, 1);
const prog = (frame, a, b) => interpolate(frame, [a, b], [0, 1], {...clamp, easing: ease});

const Paper = ({frame}) => {
  const drift = interpolate(frame, [0, 96], [0, 18], clamp);
  return (
    <AbsoluteFill style={{backgroundColor: C.paper}}>
      <AbsoluteFill style={{
        opacity: 0.33,
        backgroundImage: `radial-gradient(${C.line} 1.4px, transparent 1.4px)`,
        backgroundSize: '30px 30px',
        backgroundPosition: `${drift}px ${drift * 0.45}px`,
      }} />
      <div style={{position:'absolute', inset:0, background:'linear-gradient(180deg, rgba(255,255,255,.35), rgba(255,255,255,0) 28%, rgba(23,33,43,.025))'}} />
    </AbsoluteFill>
  );
};

const DrawPath = ({d, frame, from=8, to=58, stroke=C.ink, strokeWidth=9, fill='none', ...rest}) => {
  const p = prog(frame, from, to);
  return <path d={d} fill={fill} stroke={stroke} strokeWidth={strokeWidth} strokeLinecap="round" strokeLinejoin="round" pathLength="1" strokeDasharray="1" strokeDashoffset={1-p} {...rest} />;
};

const Coin = ({x,y,r=42,frame,delay=0,label='$',color=C.gold}) => {
  const s = spring({frame: frame-delay, fps:30, config:{damping:14, stiffness:180, mass:.7}});
  return (
    <g transform={`translate(${x} ${y}) scale(${Math.max(0,s)})`}>
      <circle r={r} fill={color} stroke={C.ink} strokeWidth="6" />
      <text y="14" textAnchor="middle" fill={C.ink} fontSize={r*.9} fontWeight="800" fontFamily="Arial">{label}</text>
    </g>
  );
};

const Person = ({x,y,frame,delay=0,accent=C.green,scale=1}) => {
  const s = spring({frame:frame-delay, fps:30, config:{damping:16, stiffness:160, mass:.8}});
  return (
    <g transform={`translate(${x} ${y}) scale(${Math.max(0,s)*scale})`}>
      <circle cx="0" cy="-120" r="48" fill={C.white} stroke={C.ink} strokeWidth="7" />
      <path d="M-20 -122 Q0 -102 20 -122" fill="none" stroke={C.ink} strokeWidth="6" strokeLinecap="round" />
      <circle cx="-15" cy="-135" r="4" fill={C.ink}/><circle cx="15" cy="-135" r="4" fill={C.ink}/>
      <path d="M-60 -55 Q0 -95 60 -55 L46 80 L-46 80 Z" fill={accent} stroke={C.ink} strokeWidth="7" strokeLinejoin="round" />
      <line x1="-62" y1="-35" x2="-110" y2="25" stroke={C.ink} strokeWidth="8" strokeLinecap="round" />
      <line x1="62" y1="-35" x2="110" y2="25" stroke={C.ink} strokeWidth="8" strokeLinecap="round" />
      <line x1="-25" y1="80" x2="-35" y2="170" stroke={C.ink} strokeWidth="9" strokeLinecap="round" />
      <line x1="25" y1="80" x2="35" y2="170" stroke={C.ink} strokeWidth="9" strokeLinecap="round" />
    </g>
  );
};

const Arrow = ({x1,y1,x2,y2,frame,delay=8,color=C.ink}) => {
  const p = prog(frame, delay, delay+36);
  const hx = x1 + (x2-x1)*p;
  const hy = y1 + (y2-y1)*p;
  const ang = Math.atan2(y2-y1,x2-x1)*180/Math.PI;
  return <g><line x1={x1} y1={y1} x2={hx} y2={hy} stroke={color} strokeWidth="8" strokeLinecap="round"/><path d="M0 0 L-22 -14 L-22 14 Z" fill={color} transform={`translate(${hx} ${hy}) rotate(${ang})`} opacity={p}/></g>;
};

const Bubble = ({x,y,w,h,children,frame,delay=0,bg=C.white}) => {
  const s = spring({frame:frame-delay, fps:30, config:{damping:16, stiffness:170, mass:.8}});
  return <g transform={`translate(${x} ${y}) scale(${Math.max(0,s)})`}><rect x={-w/2} y={-h/2} width={w} height={h} rx="28" fill={bg} stroke={C.ink} strokeWidth="6"/><foreignObject x={-w/2+24} y={-h/2+18} width={w-48} height={h-36}><div xmlns="http://www.w3.org/1999/xhtml" style={{fontFamily:'Arial',fontWeight:800,fontSize:30,color:C.ink,textAlign:'center',lineHeight:1.05}}>{children}</div></foreignObject></g>;
};

const Systems = ({frame}) => (
  <svg width="820" height="720" viewBox="0 0 820 720">
    <Person x={180} y={420} frame={frame} delay={2} accent={C.blue} scale={.9}/>
    <circle cx="180" cy="170" r="95" fill={C.white} stroke={C.ink} strokeWidth="7"/>
    <line x1="180" y1="170" x2="180" y2="112" stroke={C.ink} strokeWidth="8" strokeLinecap="round" transform={`rotate(${interpolate(frame,[0,96],[-20,210],clamp)} 180 170)`}/>
    <text x="180" y="292" textAnchor="middle" fill={C.muted} fontSize="25" fontWeight="700">SELL HOURS</text>
    <Arrow x1={315} y1={360} x2={495} y2={360} frame={frame} delay={14} color={C.gold}/>
    <g transform="translate(625 355)">
      <rect x="-118" y="-95" width="236" height="190" rx="28" fill={C.white} stroke={C.ink} strokeWidth="7"/>
      {[[-55,-22],[0,-42],[55,-5],[-12,42],[58,48]].map(([x,y],i)=><circle key={i} cx={x} cy={y} r="20" fill={i===0?C.gold:C.green} stroke={C.ink} strokeWidth="5"/>)}
      <DrawPath d="M-55 -22 L0 -42 L55 -5 L58 48 L-12 42 L-55 -22" frame={frame} from={18} to={72} stroke={C.ink} strokeWidth={6}/>
    </g>
    <text x="625" y="505" textAnchor="middle" fill={C.ink} fontSize="28" fontWeight="800">BUILD A SYSTEM</text>
  </svg>
);

const Compound = ({frame}) => {
  const p = prog(frame,12,72);
  return <svg width="820" height="720" viewBox="0 0 820 720">
    <Person x={135} y={440} frame={frame} delay={2} accent={C.green} scale={.78}/>
    {[0,1,2,3,4].map((i)=><Coin key={i} x={280+i*95} y={535-Math.pow(i+1,1.55)*46*p} r={30+i*4} frame={frame} delay={8+i*7}/>) }
    <DrawPath d="M260 535 C360 530 430 500 490 450 C565 390 640 280 720 150" frame={frame} from={12} to={74} stroke={C.green} strokeWidth={12}/>
    <text x="500" y="635" textAnchor="middle" fill={C.muted} fontSize="26" fontWeight="700">BORING AT FIRST. POWERFUL LATER.</text>
  </svg>;
};

const Emergency = ({frame}) => (
  <svg width="820" height="720" viewBox="0 0 820 720">
    <Person x={190} y={440} frame={frame} delay={2} accent={C.red} scale={.82}/>
    <DrawPath d="M460 125 L650 195 L625 405 C608 525 520 590 460 618 C400 590 312 525 295 405 L270 195 Z" frame={frame} from={8} to={46} stroke={C.ink} strokeWidth={10} fill={C.white}/>
    {[0,1,2,3,4,5].map(i=>{const on=Math.max(0,Math.min(1,prog(frame,18+i*5,40+i*5)));return <rect key={i} x={335+i*43} y={470-145*on} width="30" height={145*on} rx="8" fill={i<3?C.gold:C.green} stroke={C.ink} strokeWidth="4"/>})}
    <text x="460" y="286" textAnchor="middle" fill={C.ink} fontSize="70" fontWeight="900">3–6</text>
    <text x="460" y="335" textAnchor="middle" fill={C.muted} fontSize="28" fontWeight="700">MONTHS</text>
    <Bubble x={650} y={145} w={220} h={90} frame={frame} delay={38} bg="#FFF4D7">BUY TIME</Bubble>
  </svg>
);

const Quiet = ({frame}) => (
  <svg width="820" height="720" viewBox="0 0 820 720">
    <Person x={175} y={455} frame={frame} delay={2} accent={C.blue} scale={.78}/>
    <rect x="330" y="235" width="360" height="300" rx="36" fill={C.white} stroke={C.ink} strokeWidth="7"/>
    {[0,1,2,3,4,5].map(i=>{const g=prog(frame,12+i*5,42+i*5); const h=(45+i*34)*g;return <rect key={i} x={370+i*50} y={480-h} width="31" height={h} rx="8" fill={i===5?C.gold:C.green} stroke={C.ink} strokeWidth="4"/>})}
    <DrawPath d="M366 457 C430 445 470 422 520 390 C590 344 624 292 661 250" frame={frame} from={18} to={66} stroke={C.ink} strokeWidth={8}/>
    <text x="510" y="605" textAnchor="middle" fill={C.ink} fontSize="30" fontWeight="800">QUIET MONEY STILL GROWS</text>
  </svg>
);

const SaveFirst = ({frame}) => (
  <svg width="820" height="720" viewBox="0 0 820 720">
    <Person x={170} y={450} frame={frame} delay={2} accent={C.green} scale={.8}/>
    <rect x="340" y="210" width="350" height="250" rx="34" fill={C.white} stroke={C.ink} strokeWidth="7"/>
    <text x="515" y="280" textAnchor="middle" fill={C.muted} fontSize="25" fontWeight="700">PAYCHECK</text>
    <Coin x={445} y={355} r={44} frame={frame} delay={12}/><Coin x={530} y={355} r={44} frame={frame} delay={18}/><Coin x={615} y={355} r={44} frame={frame} delay={24}/>
    <Arrow x1={515} y1={470} x2={515} y2={595} frame={frame} delay={30} color={C.gold}/>
    <Bubble x={515} y={625} w={310} h={90} frame={frame} delay={46} bg="#FFF4D7">SAVE FIRST</Bubble>
  </svg>
);

const Skills = ({frame}) => (
  <svg width="820" height="720" viewBox="0 0 820 720">
    <Person x={175} y={470} frame={frame} delay={2} accent={C.gold} scale={.8}/>
    {[['LEARN',370,500,C.blue],['PRACTICE',495,390,C.green],['GET PAID',625,275,C.gold]].map(([t,x,y,c],i)=><g key={t}><rect x={x-95} y={y-45} width="190" height="90" rx="24" fill={C.white} stroke={C.ink} strokeWidth="6" opacity={spring({frame:frame-(8+i*10),fps:30,config:{damping:16,stiffness:160}})}/><text x={x} y={y+10} textAnchor="middle" fill={C.ink} fontSize="27" fontWeight="900">{t}</text>{i<2&&<Arrow x1={x+88} y1={y-28} x2={x+112} y2={y-72} frame={frame} delay={22+i*9} color={c}/>}</g>)}
    <Coin x={690} y={170} r={48} frame={frame} delay={48}/>
  </svg>
);

const Debt = ({frame}) => (
  <svg width="820" height="720" viewBox="0 0 820 720">
    <Person x={410} y={445} frame={frame} delay={2} accent={C.blue} scale={.85}/>
    <Bubble x={175} y={220} w={245} h={120} frame={frame} delay={10} bg="#F8E0DC">DEBT<br/>PULLS</Bubble>
    <Bubble x={645} y={220} w={245} h={120} frame={frame} delay={18} bg="#E2ECDD">INVESTING<br/>SENDS</Bubble>
    <Arrow x1={310} y1={270} x2={365} y2={335} frame={frame} delay={24} color={C.red}/>
    <Arrow x1={455} y1={335} x2={510} y2={270} frame={frame} delay={32} color={C.green}/>
    <text x="410" y="650" textAnchor="middle" fill={C.ink} fontSize="28" fontWeight="800">BOTH MOVE MONEY THROUGH TIME</text>
  </svg>
);

const Income = ({frame}) => (
  <svg width="820" height="720" viewBox="0 0 820 720">
    <Person x={410} y={400} frame={frame} delay={2} accent={C.green} scale={.78}/>
    {[[145,180],[410,135],[680,180],[155,575],[410,620],[675,575]].map(([x,y],i)=><g key={i}><Arrow x1={x} y1={y} x2={410} y2={360} frame={frame} delay={8+i*5} color={i%2?C.gold:C.blue}/><Coin x={x} y={y} r={34} frame={frame} delay={12+i*6} label={i===0?'$':i===1?'S':i===2?'R':i===3?'P':i===4?'$':'+'} color={i%2?C.gold:C.green}/></g>)}
    <Bubble x={410} y={650} w={360} h={82} frame={frame} delay={48}>MORE THAN ONE SOURCE</Bubble>
  </svg>
);

const Home = ({frame}) => (
  <svg width="820" height="720" viewBox="0 0 820 720">
    <Person x={155} y={470} frame={frame} delay={2} accent={C.blue} scale={.78}/>
    {[0,1,2,3,4].map(i=><Coin key={i} x={320+i*72} y={560-i*18} r={30} frame={frame} delay={8+i*6}/>) }
    <DrawPath d="M500 470 L500 320 L620 225 L740 320 L740 470 Z" frame={frame} from={24} to={68} stroke={C.ink} strokeWidth={10} fill={C.white}/>
    <rect x="585" y="385" width="62" height="85" fill={C.gold} stroke={C.ink} strokeWidth="6" opacity={prog(frame,42,74)}/>
    <Bubble x={535} y={625} w={355} h={84} frame={frame} delay={50} bg="#FFF4D7">REPETITION BUILDS ASSETS</Bubble>
  </svg>
);

const Compare = ({frame}) => (
  <svg width="820" height="720" viewBox="0 0 820 720">
    <Person x={165} y={470} frame={frame} delay={2} accent={C.red} scale={.8}/>
    <g transform="translate(370 180)"><rect width="160" height="330" rx="18" fill={C.white} stroke={C.ink} strokeWidth="7"/><text x="80" y="60" textAnchor="middle" fill={C.red} fontSize="28" fontWeight="900">PAGE 1</text>{[0,1,2].map(i=><rect key={i} x="35" y={105+i*62} width={70+i*12} height="18" rx="9" fill={C.line}/>)}</g>
    <g transform="translate(590 115)"><rect width="170" height="395" rx="18" fill={C.white} stroke={C.ink} strokeWidth="7"/><text x="85" y="60" textAnchor="middle" fill={C.green} fontSize="28" fontWeight="900">PAGE 50</text>{[0,1,2,3,4].map(i=><rect key={i} x="35" y={105+i*55} width={85+(i%2)*22} height="18" rx="9" fill={i===4?C.gold:C.line}/>)}</g>
    <DrawPath d="M475 555 Q565 610 690 555" frame={frame} from={20} to={66} stroke={C.gold} strokeWidth={8}/>
    <text x="535" y="650" textAnchor="middle" fill={C.ink} fontSize="27" fontWeight="800">DON'T COMPARE DIFFERENT CHAPTERS</text>
  </svg>
);

const Perfect = ({frame}) => (
  <svg width="820" height="720" viewBox="0 0 820 720">
    <Person x={180} y={470} frame={frame} delay={2} accent={C.gold} scale={.8}/>
    <circle cx="535" cy="330" r="165" fill={C.white} stroke={C.ink} strokeWidth="8"/>
    <line x1="535" y1="330" x2="535" y2="220" stroke={C.ink} strokeWidth="10" strokeLinecap="round" transform={`rotate(${interpolate(frame,[0,96],[-30,250],clamp)} 535 330)`}/>
    <line x1="535" y1="330" x2="620" y2="330" stroke={C.gold} strokeWidth="10" strokeLinecap="round"/>
    <DrawPath d="M390 515 L680 145" frame={frame} from={28} to={68} stroke={C.red} strokeWidth={14}/>
    <Bubble x={540} y={625} w={340} h={82} frame={frame} delay={45}>START BEFORE READY</Bubble>
  </svg>
);

const Time = ({frame}) => (
  <svg width="820" height="720" viewBox="0 0 820 720">
    <Person x={160} y={470} frame={frame} delay={2} accent={C.blue} scale={.78}/>
    <g transform="translate(500 120)">
      <DrawPath d="M0 0 H230 M0 440 H230 M35 0 C35 115 90 150 115 220 C140 150 195 115 195 0 M35 440 C35 325 90 290 115 220 C140 290 195 325 195 440" frame={frame} from={8} to={58} stroke={C.ink} strokeWidth={9}/>
      <path d="M83 162 Q115 208 147 162 L138 145 Q115 176 92 145 Z" fill={C.gold} opacity={prog(frame,28,60)}/>
      <path d="M88 360 Q115 315 142 360 L150 382 H80 Z" fill={C.gold} opacity={prog(frame,42,74)}/>
    </g>
    <Bubble x={535} y={640} w={420} h={86} frame={frame} delay={48} bg="#FFF4D7">MONEY RETURNS. TIME DOESN'T.</Bubble>
  </svg>
);

const Diagram = ({kind,frame}) => {
  const map = {systems:Systems,compound:Compound,emergency:Emergency,quiet:Quiet,savefirst:SaveFirst,skills:Skills,debt:Debt,income:Income,home:Home,compare:Compare,perfect:Perfect,time:Time};
  const Comp = map[kind] || Systems;
  return <Comp frame={frame}/>;
};

export const ConceptScene = ({kind, eyebrow, title, subtitle}) => {
  const frame = useCurrentFrame();
  const {fps, durationInFrames} = useVideoConfig();
  const enter = spring({frame, fps, config:{damping:18, stiffness:145, mass:.8}});
  const exit = interpolate(frame,[durationInFrames-9,durationInFrames-1],[1,0],clamp);
  const y = interpolate(enter,[0,1],[42,0],clamp);
  const scribble = prog(frame,6,30);
  return (
    <AbsoluteFill style={{overflow:'hidden',opacity:exit,color:C.ink,fontFamily:'Arial, Helvetica, sans-serif'}}>
      <Paper frame={frame}/>
      <div style={{position:'absolute',left:92,top:78,width:760,transform:`translateY(${y}px)`,opacity:enter}}>
        <div style={{display:'flex',alignItems:'center',gap:14,marginBottom:20}}>
          <div style={{width:54,height:7,borderRadius:10,background:C.gold,transform:`scaleX(${scribble})`,transformOrigin:'left center'}}/>
          <div style={{fontSize:22,fontWeight:900,letterSpacing:2.6,color:C.muted}}>GRANT'S MONEY RULE</div>
        </div>
        <div style={{fontSize:23,fontWeight:900,letterSpacing:2.4,color:C.green,marginBottom:18}}>{eyebrow}</div>
        <div style={{fontSize:80,fontWeight:900,letterSpacing:-3.2,lineHeight:.96,maxWidth:760,whiteSpace:'pre-line'}}>{title}</div>
        <div style={{fontSize:29,lineHeight:1.28,color:C.muted,maxWidth:700,marginTop:24,fontWeight:600}}>{subtitle}</div>
      </div>
      <div style={{position:'absolute',right:55,top:205,width:820,height:720,transform:`translateX(${interpolate(enter,[0,1],[80,0],clamp)}px)`,opacity:enter}}>
        <Diagram kind={kind} frame={frame}/>
      </div>
      <div style={{position:'absolute',left:92,bottom:62,fontSize:18,fontWeight:900,letterSpacing:2.4,color:'#9A9286'}}>GRANT BUILDS WEALTH</div>
    </AbsoluteFill>
  );
};

import React from 'react';
import {AbsoluteFill,Easing,interpolate,useCurrentFrame,useVideoConfig} from 'remotion';

const KEY='#00ff00';
const WHITE='#f7f4ee';
const GOLD='#e2b75f';
const RED='#e35d55';
const BLACK='#080808';
const FONT="'Arial Narrow','Helvetica Neue',Arial,sans-serif";
const clamp={extrapolateLeft:'clamp' as const,extrapolateRight:'clamp' as const};
const ease=Easing.bezier(.16,1,.3,1);
const outline:React.CSSProperties={WebkitTextStroke:`3px ${BLACK}`,paintOrder:'stroke fill'} as React.CSSProperties;

type Beat={s:number;e:number;top:string;bottom?:string;accent?:'gold'|'red';pos?:'low'|'mid'|'high';align?:'left'|'center'};
type Stat={s:number;e:number;big:string;label:string;sub?:string;side?:'left'|'right'};

const beats:Beat[]=[
 {s:0,e:1.55,top:'THE DANUBE IS',bottom:'DRYING UP',accent:'gold',pos:'low'},
 {s:1.55,e:3.58,top:'WORLD WAR II',bottom:'IS SURFACING',accent:'gold',pos:'low'},
 {s:5.79,e:10.27,top:'GERMAN SHIPS',bottom:'ARE REAPPEARING',accent:'gold',pos:'low'},
 {s:10.27,e:12.10,top:'NOT ORDINARY',bottom:'SHIPWRECKS',accent:'gold',pos:'mid'},
 {s:14.81,e:17.35,top:'SOVIET FORCES',bottom:'CLOSING IN',accent:'gold',pos:'high',align:'left'},
 {s:17.35,e:20.04,top:'THE CONVOY HAD',bottom:'NOWHERE TO GO',accent:'gold',pos:'low'},
 {s:20.04,e:24.64,top:'THEY SANK',bottom:'THEIR OWN SHIPS',accent:'gold',pos:'low'},
 {s:28.16,e:30.40,top:'BLOCKING THE',bottom:'SHIPPING CHANNEL',accent:'gold',pos:'high',align:'left'},
 {s:30.40,e:32.70,top:'THE RIVER',bottom:'SWALLOWED THEM',accent:'gold',pos:'mid'},
 {s:38.24,e:42.45,top:'DROUGHT',bottom:'BROUGHT THEM BACK',accent:'gold',pos:'low'},
 {s:47.82,e:49.90,top:"BUT HERE'S",bottom:'THE PROBLEM',accent:'gold',pos:'low'},
 {s:52.83,e:55.30,top:'80+ YEARS LATER',bottom:'STILL ARMED',accent:'red',pos:'high',align:'left'},
 {s:55.30,e:58.00,top:'THE GHOST FLEET',bottom:'IS STILL DANGEROUS',accent:'gold',pos:'mid'},
];

const stats:Stat[]=[
 {s:12.10,e:14.81,big:'1944',label:'SEPTEMBER'},
 {s:24.64,e:28.16,big:'≈200',label:'VESSELS SCUTTLED',sub:'ACROSS THE DANUBE'},
 {s:32.70,e:38.24,big:'80+',label:'YEARS HIDDEN',sub:'BENEATH THE WATER',side:'right'},
 {s:42.45,e:47.82,big:'20+',label:'WRECKS EXPOSED',sub:'AT RECORD-LOW WATER'},
];

const Caption:React.FC<{b:Beat}>=({b})=>{
 const f=useCurrentFrame(); const {fps}=useVideoConfig(); const s=b.s*fps,e=b.e*fps; if(f<s||f>=e)return null;
 const local=f-s,d=e-s;
 const yIn=interpolate(local,[0,6],[18,0],{...clamp,easing:ease});
 const yOut=interpolate(local,[Math.max(0,d-4),d],[0,-10],{...clamp,easing:ease});
 const align=b.align??'center'; const pos=b.pos??'low';
 const top=pos==='high'?260:pos==='mid'?920:1260;
 const color=b.accent==='red'?RED:GOLD;
 return <div style={{position:'absolute',left:align==='left'?64:70,right:70,top,width:align==='left'?860:940,textAlign:align,transform:`translate3d(0,${yIn+yOut}px,0)`}}>
   <div style={{...outline,fontFamily:FONT,fontWeight:900,fontSize:64,lineHeight:.92,letterSpacing:-1.4,color:WHITE,textTransform:'uppercase'}}>{b.top}</div>
   {b.bottom&&<div style={{...outline,fontFamily:FONT,fontWeight:900,fontSize:70,lineHeight:.92,letterSpacing:-1.8,color,marginTop:5,textTransform:'uppercase'}}>{b.bottom}</div>}
 </div>;
};

const BigStat:React.FC<{c:Stat}>=({c})=>{
 const f=useCurrentFrame(); const {fps}=useVideoConfig(); const s=c.s*fps,e=c.e*fps; if(f<s||f>=e)return null;
 const local=f-s,d=e-s; const left=c.side!=='right';
 const xIn=interpolate(local,[0,7],[left?-36:36,0],{...clamp,easing:ease});
 const xOut=interpolate(local,[Math.max(0,d-4),d],[0,left?-12:12],{...clamp,easing:ease});
 return <div style={{position:'absolute',top:190,left:left?58:undefined,right:left?undefined:58,width:760,textAlign:left?'left':'right',transform:`translate3d(${xIn+xOut}px,0,0)`}}>
   <div style={{...outline,fontFamily:FONT,fontWeight:900,fontSize:176,lineHeight:.8,letterSpacing:-7,color:WHITE}}>{c.big}</div>
   <div style={{...outline,fontFamily:FONT,fontWeight:900,fontSize:40,lineHeight:.95,letterSpacing:2.2,color:GOLD,marginTop:18,textTransform:'uppercase'}}>{c.label}</div>
   {c.sub&&<div style={{...outline,fontFamily:FONT,fontWeight:800,fontSize:24,lineHeight:1.05,letterSpacing:1.7,color:WHITE,marginTop:10,textTransform:'uppercase'}}>{c.sub}</div>}
 </div>;
};

const Danger:React.FC=()=>{
 const f=useCurrentFrame(); const {fps}=useVideoConfig(); const s=49.90*fps,e=52.83*fps; if(f<s||f>=e)return null;
 const local=f-s,d=e-s;
 const yIn=interpolate(local,[0,7],[20,0],{...clamp,easing:ease});
 const yOut=interpolate(local,[Math.max(0,d-4),d],[0,-10],{...clamp,easing:ease});
 return <div style={{position:'absolute',left:64,right:64,top:1125,transform:`translate3d(0,${yIn+yOut}px,0)`}}>
   <div style={{...outline,fontFamily:FONT,fontWeight:900,fontSize:96,lineHeight:.84,letterSpacing:-3,color:RED}}>LIVE</div>
   <div style={{...outline,fontFamily:FONT,fontWeight:900,fontSize:88,lineHeight:.86,letterSpacing:-2.6,color:WHITE}}>AMMUNITION</div>
   <div style={{...outline,fontFamily:FONT,fontWeight:900,fontSize:31,lineHeight:1,letterSpacing:2.6,color:RED,marginTop:13}}>AND EXPLOSIVES</div>
 </div>;
};

export const DanubeOverlay:React.FC=()=> <AbsoluteFill style={{backgroundColor:KEY}}>
 {stats.map((c,i)=><BigStat key={i} c={c}/>)}
 {beats.map((b,i)=><Caption key={i} b={b}/>)}
 <Danger/>
</AbsoluteFill>;

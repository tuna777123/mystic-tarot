import React from 'react';
import {AbsoluteFill,Easing,interpolate,useCurrentFrame,useVideoConfig} from 'remotion';

const KEY='#00ff00';
const INK='#f5f1e8';
const MUTED='#c8c1b6';
const AMBER='#d9ad5b';
const RED='#d75b52';
const FONT="'Arial Narrow','Helvetica Neue',Arial,sans-serif";

type Layout='hook'|'lowerLeft'|'upperLeft'|'lowerRight'|'center';
type Beat={s:number;e:number;eyebrow?:string;main:string;accent?:string;sub?:string;layout:Layout;danger?:boolean;final?:boolean};
type Stat={s:number;e:number;big:string;label:string;sub?:string;side?:'left'|'right'};

const beats:Beat[]=[
 {s:0,e:1.55,eyebrow:'THE DANUBE',main:'IS DRYING UP',layout:'hook'},
 {s:1.55,e:3.58,eyebrow:'AND NOW',main:'WORLD WAR II',accent:'IS SURFACING WITH IT',layout:'hook'},
 {s:5.79,e:10.27,eyebrow:'LOW WATER • PRAHOVO',main:'RUSTING GERMAN SHIPS',accent:'ARE REAPPEARING',layout:'lowerLeft'},
 {s:10.27,e:12.1,main:"THESE AREN'T",accent:'ORDINARY WRECKS',layout:'center'},
 {s:14.81,e:17.35,eyebrow:'EASTERN FRONT',main:'SOVIET FORCES',accent:'CLOSING IN',layout:'upperLeft'},
 {s:17.35,e:20.04,eyebrow:'THE CONVOY WAS TRAPPED',main:'NO WAY OUT',layout:'lowerRight'},
 {s:20.04,e:24.64,eyebrow:'SO THE CREWS CHOSE THE EXTREME',main:'THEY SANK',accent:'THEIR OWN SHIPS',layout:'lowerLeft'},
 {s:28.16,e:30.4,eyebrow:'THE RESULT',main:'THE SHIPPING CHANNEL',accent:'WAS BLOCKED',layout:'upperLeft'},
 {s:30.4,e:32.7,main:'THE RIVER',accent:'SWALLOWED THEM',layout:'center'},
 {s:38.24,e:42.45,eyebrow:'EIGHT DECADES LATER',main:'EXTREME DROUGHT',accent:'BROUGHT THEM BACK',layout:'lowerLeft'},
 {s:47.82,e:49.9,eyebrow:'BUT THE STORY ISN’T OVER',main:"HERE'S THE PROBLEM",layout:'lowerLeft'},
 {s:52.83,e:55.3,eyebrow:'MORE THAN 80 YEARS AFTER WWII',main:'THE WRECKS',accent:'ARE STILL ARMED',layout:'upperLeft'},
 {s:55.3,e:57.96,main:'THE GHOST FLEET',accent:'IS STILL DANGEROUS',layout:'center',final:true},
];

const stats:Stat[]=[
 {s:12.1,e:14.81,big:'1944',label:'SEPTEMBER',sub:'SOVIET FORCES WERE CLOSING IN',side:'left'},
 {s:24.64,e:28.16,big:'≈200',label:'VESSELS SCUTTLED',sub:'ACROSS THE DANUBE',side:'left'},
 {s:32.7,e:38.24,big:'80+',label:'YEARS HIDDEN',sub:'BENEATH THE WATER',side:'right'},
 {s:42.45,e:47.82,big:'20+',label:'WRECKS EXPOSED',sub:'SOME ALMOST COMPLETELY OUT OF THE WATER',side:'left'},
];

const pos:Record<Layout,React.CSSProperties>={
 hook:{left:64,right:70,top:1030,textAlign:'left'},
 lowerLeft:{left:64,width:820,top:1160,textAlign:'left'},
 upperLeft:{left:64,width:790,top:270,textAlign:'left'},
 lowerRight:{right:64,width:760,top:1150,textAlign:'right'},
 center:{left:70,right:70,top:910,textAlign:'center'},
};

const clamp={extrapolateLeft:'clamp' as const,extrapolateRight:'clamp' as const};
const ease=Easing.bezier(.16,1,.3,1);

const EditorialText:React.FC<{b:Beat}>=({b})=>{
 const frame=useCurrentFrame(); const {fps}=useVideoConfig();
 const s=b.s*fps,e=b.e*fps; if(frame<s||frame>=e)return null;
 const local=frame-s,d=e-s;
 const enterY=interpolate(local,[0,9],[30,0],{...clamp,easing:ease});
 const exitY=interpolate(local,[Math.max(0,d-5),d],[0,-14],{...clamp,easing:ease});
 const x=b.layout==='lowerRight'?interpolate(local,[0,9],[28,0],{...clamp,easing:ease}):b.layout==='center'?0:interpolate(local,[0,9],[-24,0],{...clamp,easing:ease});
 const line=interpolate(local,[3,14],[0,1],{...clamp,easing:ease});
 const accent=b.danger?RED:AMBER;
 const mainSize=b.layout==='hook'?104:b.layout==='center'?90:78;
 const accentSize=b.layout==='hook'?72:b.layout==='center'?88:80;
 return <div style={{position:'absolute',...pos[b.layout],transform:`translate3d(${x}px,${enterY+exitY}px,0)`,filter:'drop-shadow(0 4px 12px rgba(0,0,0,.86))'}}>
   {b.eyebrow&&<div style={{fontFamily:FONT,fontWeight:700,fontSize:24,letterSpacing:5.2,lineHeight:1,color:b.danger?RED:MUTED,textTransform:'uppercase',marginBottom:14}}>{b.eyebrow}</div>}
   <div style={{fontFamily:FONT,fontWeight:900,fontSize:mainSize,lineHeight:.91,letterSpacing:-3.2,color:INK,textTransform:'uppercase'}}>{b.main}</div>
   {b.accent&&<div style={{fontFamily:FONT,fontWeight:900,fontSize:accentSize,lineHeight:.93,letterSpacing:-2.4,color:b.final?INK:accent,textTransform:'uppercase',marginTop:7}}>{b.accent}</div>}
   {b.sub&&<div style={{fontFamily:FONT,fontWeight:700,fontSize:30,letterSpacing:2.5,lineHeight:1.05,color:MUTED,textTransform:'uppercase',marginTop:16}}>{b.sub}</div>}
   <div style={{height:3,width:`${Math.round(line*140)}px`,background:b.danger?RED:AMBER,marginTop:18,marginLeft:b.layout==='lowerRight'?'auto':b.layout==='center'?'auto':0,marginRight:b.layout==='center'?'auto':0}}/>
 </div>;
};

const BigStat:React.FC<{c:Stat}>=({c})=>{
 const frame=useCurrentFrame(); const {fps}=useVideoConfig();
 const s=c.s*fps,e=c.e*fps; if(frame<s||frame>=e)return null;
 const local=frame-s,d=e-s;
 const enterX=interpolate(local,[0,11],[c.side==='right'?72:-72,0],{...clamp,easing:ease});
 const exitX=interpolate(local,[Math.max(0,d-6),d],[0,c.side==='right'?24:-24],{...clamp,easing:ease});
 const rule=interpolate(local,[4,16],[0,1],{...clamp,easing:ease});
 const left=c.side!=='right';
 return <div style={{position:'absolute',top:210,left:left?58:undefined,right:left?undefined:58,width:760,transform:`translate3d(${enterX+exitX}px,0,0)`,textAlign:left?'left':'right',filter:'drop-shadow(0 4px 16px rgba(0,0,0,.82))'}}>
   <div style={{display:'flex',flexDirection:left?'row':'row-reverse',alignItems:'stretch',gap:22}}>
     <div style={{width:5,background:AMBER,transform:`scaleY(${rule})`,transformOrigin:'top',borderRadius:3}}/>
     <div>
       <div style={{fontFamily:FONT,fontWeight:900,fontSize:190,lineHeight:.78,letterSpacing:-8,color:INK}}>{c.big}</div>
       <div style={{fontFamily:FONT,fontWeight:900,fontSize:42,lineHeight:.96,letterSpacing:2.8,color:AMBER,textTransform:'uppercase',marginTop:22}}>{c.label}</div>
       {c.sub&&<div style={{fontFamily:FONT,fontWeight:700,fontSize:26,lineHeight:1.12,letterSpacing:2,color:MUTED,textTransform:'uppercase',marginTop:13,maxWidth:580,marginLeft:left?0:'auto'}}>{c.sub}</div>}
     </div>
   </div>
 </div>;
};

const Warning:React.FC=()=>{
 const frame=useCurrentFrame(); const {fps}=useVideoConfig();
 const s=49.9*fps,e=52.83*fps; if(frame<s||frame>=e)return null;
 const local=frame-s,d=e-s;
 const enterY=interpolate(local,[0,10],[28,0],{...clamp,easing:ease});
 const exitY=interpolate(local,[Math.max(0,d-6),d],[0,-14],{...clamp,easing:ease});
 const bar=interpolate(local,[4,16],[0,1],{...clamp,easing:ease});
 return <div style={{position:'absolute',left:64,right:64,top:1070,transform:`translate3d(0,${enterY+exitY}px,0)`,filter:'drop-shadow(0 5px 14px rgba(0,0,0,.88))'}}>
   <div style={{fontFamily:FONT,fontWeight:800,fontSize:25,letterSpacing:5.5,color:MUTED,textTransform:'uppercase',marginBottom:12}}>THE TERRIFYING PART</div>
   <div style={{fontFamily:FONT,fontWeight:900,fontSize:98,lineHeight:.86,letterSpacing:-3.5,color:RED,textTransform:'uppercase'}}>LIVE</div>
   <div style={{fontFamily:FONT,fontWeight:900,fontSize:92,lineHeight:.88,letterSpacing:-3.5,color:INK,textTransform:'uppercase'}}>AMMUNITION</div>
   <div style={{fontFamily:FONT,fontWeight:800,fontSize:34,letterSpacing:3.2,color:RED,textTransform:'uppercase',marginTop:16}}>AND EXPLOSIVES</div>
   <div style={{height:3,width:`${Math.round(190*bar)}px`,background:RED,marginTop:18}}/>
 </div>;
};

const DocumentaryMeta:React.FC=()=>{
 const f=useCurrentFrame(); const {fps}=useVideoConfig(); const t=f/fps;
 let label='';
 if(t>=3.58&&t<10.27)label='PRAHOVO / SERBIA';
 else if(t>=12.1&&t<32.7)label='SEPTEMBER 1944';
 else if(t>=38.24&&t<57.96)label='DANUBE / LOW WATER';
 if(!label)return null;
 return <div style={{position:'absolute',top:92,left:60,display:'flex',alignItems:'center',gap:12,filter:'drop-shadow(0 3px 8px rgba(0,0,0,.82))'}}>
   <div style={{width:8,height:8,borderRadius:8,background:AMBER}}/>
   <div style={{fontFamily:FONT,fontWeight:700,fontSize:19,letterSpacing:4.2,color:INK,textTransform:'uppercase'}}>{label}</div>
 </div>;
};

export const DanubeOverlay:React.FC=()=> <AbsoluteFill style={{backgroundColor:KEY}}>
 <DocumentaryMeta/>
 {stats.map((c,i)=><BigStat key={`stat-${i}`} c={c}/>)}
 {beats.map((b,i)=><EditorialText key={`beat-${i}`} b={b}/>)}
 <Warning/>
</AbsoluteFill>;

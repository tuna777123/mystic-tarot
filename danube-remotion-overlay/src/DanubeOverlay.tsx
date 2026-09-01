import React from 'react';
import {AbsoluteFill,Easing,interpolate,useCurrentFrame,useVideoConfig} from 'remotion';

const beats=[
{s:0,e:1.55,text:'THE DANUBE IS',hi:'DRYING UP',kind:'hook'},
{s:1.55,e:3.58,text:'WORLD WAR II',sub:'IS SURFACING WITH IT',kind:'hook'},
{s:3.58,e:5.79,text:'PRAHOVO, SERBIA',kind:'impact'},
{s:5.79,e:7.85,text:'THE RIVER FELL',hi:'SO LOW'},
{s:7.85,e:10.27,text:'GERMAN SHIPS',hi:'REAPPEARED'},
{s:10.27,e:12.1,text:'NOT AN ACCIDENT',kind:'impact'},
{s:12.1,e:14.81,text:'SEPTEMBER',hi:'1944',kind:'impact'},
{s:14.81,e:17.35,text:'SOVIET FORCES',hi:'CLOSING IN'},
{s:17.35,e:20.04,text:'A GERMAN CONVOY',hi:'NOWHERE TO GO'},
{s:20.04,e:22.1,text:'THEY DID SOMETHING',hi:'EXTREME'},
{s:22.1,e:24.64,text:'THEY SANK',hi:'THEIR OWN SHIPS',kind:'impact'},
{s:24.64,e:26.4,text:'AROUND',hi:'200 VESSELS',kind:'impact'},
{s:26.4,e:28.16,text:'SCUTTLED ACROSS',hi:'THE DANUBE'},
{s:28.16,e:30.4,text:'BLOCKING THE',hi:'SHIPPING CHANNEL'},
{s:30.4,e:32.7,text:'THE RIVER',hi:'SWALLOWED THEM',kind:'impact'},
{s:32.7,e:35.05,text:'HIDDEN FOR',hi:'80+ YEARS',kind:'impact'},
{s:35.05,e:38.24,text:'BENEATH THE WATER',hi:'UNTIL NOW'},
{s:38.24,e:40.4,text:'EXTREME DROUGHT',kind:'impact'},
{s:40.4,e:42.45,text:'RECORD-LOW',hi:'WATER LEVELS'},
{s:42.45,e:44.9,text:'20+ WRECKS',sub:'EXPOSED',kind:'impact'},
{s:44.9,e:47.82,text:'ALMOST COMPLETELY',hi:'OUT OF THE WATER'},
{s:47.82,e:49.9,text:"HERE'S THE",hi:'TERRIFYING PART'},
{s:49.9,e:52.83,text:'LIVE AMMUNITION',sub:'AND EXPLOSIVES',kind:'danger'},
{s:52.83,e:55.3,text:'80+ YEARS',sub:'AFTER WWII'},
{s:55.3,e:57.96,text:'THE GHOST FLEET',hi:'STILL DANGEROUS',kind:'final'}
];

const cards=[
{s:12.1,e:14.2,big:'1944',small:'SEPTEMBER'},
{s:24.64,e:26.2,big:'200',small:'VESSELS'},
{s:32.7,e:34.8,big:'80+',small:'YEARS HIDDEN'},
{s:42.45,e:44.7,big:'20+',small:'WRECKS EXPOSED'}
];

const Caption:React.FC<{b:any}>=({b})=>{
 const frame=useCurrentFrame(); const {fps}=useVideoConfig(); const s=b.s*fps,e=b.e*fps;
 if(frame<s||frame>=e)return null; const f=frame-s,d=e-s;
 const pop=interpolate(f,[0,4,10],[.88,1.06,1],{extrapolateLeft:'clamp',extrapolateRight:'clamp',easing:Easing.bezier(.16,1,.3,1)});
 const op=interpolate(f,[0,2,d-4,d],[0,1,1,0],{extrapolateLeft:'clamp',extrapolateRight:'clamp'});
 const danger=b.kind==='danger', final=b.kind==='final';
 const accent=danger?'#ff5147':final?'#ffd56a':'#ffd15a';
 return <div style={{position:'absolute',left:62,right:62,top:1240,textAlign:'center',opacity:op,scale:pop,filter:'drop-shadow(0 5px 11px rgba(0,0,0,.82))'}}>
  <div style={{fontFamily:'Arial,sans-serif',fontWeight:900,fontSize:b.kind==='hook'?90:74,lineHeight:.95,letterSpacing:-1.8,color:'#fff',textTransform:'uppercase'}}>{b.text}</div>
  {b.hi&&<div style={{marginTop:9,fontFamily:'Arial,sans-serif',fontWeight:900,fontSize:b.kind==='hook'?96:80,lineHeight:.94,letterSpacing:-1.8,color:accent,textTransform:'uppercase'}}>{b.hi}</div>}
  {b.sub&&<div style={{marginTop:8,fontFamily:'Arial,sans-serif',fontWeight:900,fontSize:64,lineHeight:.95,letterSpacing:-1,color:danger?accent:'#fff',textTransform:'uppercase'}}>{b.sub}</div>}
 </div>;
};

const Card:React.FC<{c:any}>=({c})=>{
 const frame=useCurrentFrame(); const {fps}=useVideoConfig(); const s=c.s*fps,e=c.e*fps; if(frame<s||frame>=e)return null;
 const f=frame-s; const op=interpolate(f,[0,3,e-s-3,e-s],[0,.96,.96,0],{extrapolateLeft:'clamp',extrapolateRight:'clamp'});
 const y=interpolate(f,[0,8],[22,0],{extrapolateLeft:'clamp',extrapolateRight:'clamp',easing:Easing.bezier(.16,1,.3,1)});
 return <div style={{position:'absolute',top:164,left:58,opacity:op,translate:`0 ${y}px`,padding:'15px 22px 13px',borderLeft:'6px solid #ffd15a',background:'rgba(4,7,10,.64)',borderRadius:10,boxShadow:'0 8px 28px rgba(0,0,0,.25)'}}>
  <div style={{fontFamily:'Arial,sans-serif',fontWeight:900,fontSize:82,lineHeight:.84,color:'#fff',letterSpacing:-3}}>{c.big}</div>
  <div style={{fontFamily:'Arial,sans-serif',fontWeight:900,fontSize:27,lineHeight:1,color:'#ffd15a',letterSpacing:2.5,marginTop:11}}>{c.small}</div>
 </div>;
};

const RetentionFlash:React.FC=()=>{const f=useCurrentFrame(); const {fps}=useVideoConfig();
 const moments=[1.55,10.27,22.1,30.4,38.24,49.9,55.3]; let a=0;
 for(const m of moments){const d=Math.abs(f-m*fps); if(d<5)a=Math.max(a,interpolate(d,[0,5],[.16,0],{extrapolateRight:'clamp'}));}
 return <AbsoluteFill style={{backgroundColor:`rgba(255,220,130,${a})`}}/>;
};

const DangerPulse:React.FC=()=>{const f=useCurrentFrame(); const {fps}=useVideoConfig(); const s=49.9*fps,e=52.83*fps; if(f<s||f>=e)return null;
 const local=f-s; const a=interpolate(local,[0,7,18,e-s],[0,.15,.05,0],{extrapolateLeft:'clamp',extrapolateRight:'clamp'});
 return <AbsoluteFill style={{background:`radial-gradient(circle at 50% 58%, rgba(255,54,45,${a}), rgba(255,54,45,0) 62%)`}}/>;
};

const EdgeGrade:React.FC=()=> <><AbsoluteFill style={{background:'linear-gradient(180deg,rgba(0,0,0,.08) 0%,rgba(0,0,0,0) 42%,rgba(0,0,0,.23) 100%)'}}/><AbsoluteFill style={{boxShadow:'inset 0 0 120px rgba(0,0,0,.20)'}}/></>;

export const DanubeOverlay:React.FC=()=> <AbsoluteFill>
 <EdgeGrade/><RetentionFlash/><DangerPulse/>
 {cards.map((c,i)=><Card key={i} c={c}/>)}
 {beats.map((b,i)=><Caption key={i} b={b}/>)}
</AbsoluteFill>;

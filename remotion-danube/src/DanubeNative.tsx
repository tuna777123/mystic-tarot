import React from 'react';
import {AbsoluteFill, Easing, Img, Sequence, interpolate, useCurrentFrame, useVideoConfig} from 'remotion';

const SCENES = [
  'https://media.canva.com/v2/files/uri:ifs%3A%2F%2FV%2F2oWwEylxLrQS202BTR6wzSo-tt4W4vfg5uc7IGrN3aI.jpg?csig=AAAAAAAAAAAAAAAAAAAAAOAiEgKlrO2hJkOuYOw1O23XpwOMBg3A1s2pDg7x5AgE&exp=1788297360&signer=video-rpc&token=AAIAAVYALzJvV3dFeWx4THJRUzIwMkJUUjZ3elNvLXR0NFc0dmZnNXVjN0lHck4zYUkuanBnAAAAAAGgXtQygLVQLH9oZn7bDuChqfXHrp1z4OtZtu72XjceAjlhXNE3',
  'https://media.canva.com/v2/files/uri:ifs%3A%2F%2FV%2FcJaAp5HPZPpsXgg216diMA5--p7RchtW-uZsUzCuhZA.jpg?csig=AAAAAAAAAAAAAAAAAAAAAFpBqKAKIWLHjqHd5J2BaDJOu9cDnd8BI8s0LdlYzvoV&exp=1788298620&signer=video-rpc&token=AAIAAVYAL2NKYUFwNUhQWlBwc1hnZzIxNmRpTUE1LS1wN1JjaHRXLXVac1V6Q3VoWkEuanBnAAAAAAGgXudsYLdo2-te2EI2Mw4Z7Jn1XbGPOS3OVvqPyfQQ6zIbwdVz',
  'https://media.canva.com/v2/files/uri:ifs%3A%2F%2FV%2FJ1vHI5319bDpoZiny2jPujtiuwnPfrpRJpzyPhrMmXk.jpg?csig=AAAAAAAAAAAAAAAAAAAAAPY8dGTDrGOatQWziNEAOYb6EclhFjIJMzs4fbrtIToZ&exp=1788298680&signer=video-rpc&token=AAIAAVYAL0oxdkhJNTMxOWJEcG9aaW55MmpQdWp0aXV3blBmcnBSSnB6eVBock1tWGsuanBnAAAAAAGgXuhWwDYPekT8O1RBR7nA8Jgg-sAySbcs1wlBH-eJ-MqbkKXW',
  'https://media.canva.com/v2/files/uri:ifs%3A%2F%2FV%2FhtqZB6kTUaIxBS-2ZeXG2CluG4emIFpLRAIVf_u1fxo.jpg?csig=AAAAAAAAAAAAAAAAAAAAAB3gs8Uo1MjzoCsQfihPVo5q3ATKBvac5DmISFCp3wGE&exp=1788298920&signer=video-rpc&token=AAIAAVYAL2h0cVpCNmtUVWFJeEJTLTJaZVhHMkNsdUc0ZW1JRnBMUkFJVmZfdTFmeG8uanBnAAAAAAGgXuwAQGktnLv8m93o7VpScxd1GhYSUw_qILIn3hxxZnWJSj2Q',
  'https://media.canva.com/v2/files/uri:ifs%3A%2F%2FV%2FFv4RB0nXt-oh_jTeK3JVsnQnDz3ZYSgfYOOoy6jm8PQ.jpg?csig=AAAAAAAAAAAAAAAAAAAAAEr0Np0YzjnWkjoryAOjwy0VgGLIwWqhILmyxoGzkCY3&exp=1788299820&signer=video-rpc&token=AAIAAVYAL0Z2NFJCMG5YdC1vaF9qVGVLM0pWc25RbkR6M1pZU2dmWU9Pb3k2am04UFEuanBnAAAAAAGgXvm74J8ttYzM5_kOWg294JbgONdKAiWJfVPcu9Em7J12Nsml',
  'https://media.canva.com/v2/files/uri:ifs%3A%2F%2FV%2FdQZCQxbFlET03eaiOIvdMjXw_odEFrC32eGwx7imxcs.jpg?csig=AAAAAAAAAAAAAAAAAAAAAHzmKhUbq2gUklvhHM9TCbM9ETGpWu3kulghyYAjOE33&exp=1788297540&signer=video-rpc&token=AAIAAVYAL2RRWkNReGJGbEVUMDNlYWlPSXZkTWpYd19vZEVGckMzMmVHd3g3aW14Y3MuanBnAAAAAAGgXtbxoB6suTr8YJTNZwg00vuIxyunF8qzwKTmUjWxstkaTHei',
  'https://media.canva.com/v2/files/uri:ifs%3A%2F%2FV%2F9p0IQSGPptWvKH-bmh_6uIw_lRAppdyLPQtli_4MbQA.jpg?csig=AAAAAAAAAAAAAAAAAAAAANkRJ8XyFjdx7Aq1IRbqwbhUGWyl7NYZd4YGF5J70VAA&exp=1788299280&signer=video-rpc&token=AAIAAVYALzlwMElRU0dQcHRXdktILWJtaF82dUl3X2xSQXBwZHlMUFF0bGlfNE1iUUEuanBnAAAAAAGgXvF-gLq-DCnHeDx29G8LsXf-Wd2L4dk6jteiboqxZ1oKul2y',
  'https://media.canva.com/v2/files/uri:ifs%3A%2F%2FV%2FJFTV6dy0_LbXZlOMBOuKXKWX_3TFGej-UL34S_P6DgY.jpg?csig=AAAAAAAAAAAAAAAAAAAAAPriDGIhlSwYIcv7Pmkiwf-CO4ioNTMg6CKGyWRA6Xth&exp=1788299820&signer=video-rpc&token=AAIAAVYAL0pGVFY2ZHkwX0xiWFpsT01CT3VLWEtXWF8zVEZHZWotVUwzNFNfUDZEZ1kuanBnAAAAAAGgXvm74G55imBHRbpATt0dF1GsQBt5Y_o2cB9MR7oRjD0PKJVm',
  'https://media.canva.com/v2/files/uri:ifs%3A%2F%2FV%2Fxl3eD8wysJO34lhwLY8AS-TXh-EkI_C0XbBnL8MIxUY.jpg?csig=AAAAAAAAAAAAAAAAAAAAAPU4oElZbAJB4xQSCn_6GJvUYSqxnH3rKKqIS8hDtzYi&exp=1788296580&signer=video-rpc&token=AAIAAVYAL3hsM2VEOHd5c0pPMzRsaHdMWThBUy1UWGgtRWtJX0MwWGJCbkw4TUl4VVkuanBnAAAAAAGgXshLoOhmEUJC7lgDWygAXqhEbQtba5dBYUjW2L9VDO9v05QY',
  'https://media.canva.com/v2/files/uri:ifs%3A%2F%2FV%2F1f20PoMkUYuWrFrEQZQtTYKvRPZK2hyZewSni9aa5W8.jpg?csig=AAAAAAAAAAAAAAAAAAAAAOaBuFbsSW0XUNmbT0a-SL9y5mfkQeefRT5j6Gx5JU_V&exp=1788298740&signer=video-rpc&token=AAIAAVYALzFmMjBQb01rVVl1V3JGckVRWlF0VFlLdlJQWksyaHlaZXdTbmk5YWE1VzguanBnAAAAAAGgXulBILaNqnlYVW0uAU_Bpbjx65LxZYvng73selVfeoHHxHYX',
  'https://media.canva.com/v2/files/uri:ifs%3A%2F%2FV%2FojPI_3GpcVdvT4kF-LyjJLA03mjYLIuBullWzwBJc4I.jpg?csig=AAAAAAAAAAAAAAAAAAAAAOFgG-oIumwGRhRKFtGQ5Xwlkf4ayi2ScFhx_MoFb_N2&exp=1788298020&signer=video-rpc&token=AAIAAVYAL29qUElfM0dwY1ZkdlQ0a0YtTHlqSkxBMDNtallMSXVCdWxsV3p3QkpjNEkuanBnAAAAAAGgXt5EoPP9oz78iiKBm2Kd9dXzTuFodZNf-T0bKii-iJ8TyCag',
  'https://media.canva.com/v2/files/uri:ifs%3A%2F%2FV%2FC1mQZGFA94UUgSKjw2AqXNEMJLfxVnA1dHifLbPAi5E.jpg?csig=AAAAAAAAAAAAAAAAAAAAAGmNLDmaMSingKy6Udtla3SE2SXxZZYr5-N45KWu3gCR&exp=1788297840&signer=video-rpc&token=AAIAAVYAL0MxbVFaR0ZBOTRVVWdTS2p3MkFxWE5FTUpMZnhWbkExZEhpZkxiUEFpNUUuanBnAAAAAAGgXtuFgD6_IVl_XfskAFlrZ5SVAxn1PGdDIC4clDmf_NWRRiq4',
  'https://media.canva.com/v2/files/uri:ifs%3A%2F%2FV%2FBIx1jsJBzf5lfgm382YJQloc_7bLvcRuUR_B6ATlq5w.jpg?csig=AAAAAAAAAAAAAAAAAAAAACuohAnPQcebKINCaPt86cWhGHcEX9TaSxBqfWZSlY3x&exp=1788298680&signer=video-rpc&token=AAIAAVYAL0JJeDFqc0pCemY1bGZnbTM4MllKUWxvY183Ykx2Y1J1VVJfQjZBVGxxNXcuanBnAAAAAAGgXuhWwMSUob0nspK1T0QV9v6dCIEBJBnZtlc0aprk0sIChgp1'
];

const SEGMENTS = [
  {src:1,frames:47},{src:2,frames:60},{src:3,frames:67},{src:4,frames:134},
  {src:9,frames:55},{src:5,frames:157},{src:6,frames:143},{src:7,frames:129},
  {src:4,frames:120},{src:8,frames:140},{src:9,frames:95},{src:1,frames:127},
  {src:11,frames:161},{src:10,frames:62},{src:12,frames:88},{src:13,frames:155}
];

const beats = [
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

const cards = [
  {s:12.1,e:14.2,big:'1944',small:'SEPTEMBER'},
  {s:24.64,e:26.2,big:'200',small:'VESSELS'},
  {s:32.7,e:34.8,big:'80+',small:'YEARS HIDDEN'},
  {s:42.45,e:44.7,big:'20+',small:'WRECKS EXPOSED'}
];

const Visual: React.FC<{i:number; src:number; from:number; duration:number}> = ({i,src,from,duration}) => {
  const frame = useCurrentFrame();
  const local = frame - from;
  const drift = i % 4;
  const scale = interpolate(local,[0,duration],[1.03,1.095],{extrapolateLeft:'clamp',extrapolateRight:'clamp',easing:Easing.bezier(0.16,1,0.3,1)});
  const x = drift===0 ? interpolate(local,[0,duration],[-18,12],{extrapolateLeft:'clamp',extrapolateRight:'clamp'}) : drift===1 ? interpolate(local,[0,duration],[16,-14],{extrapolateLeft:'clamp',extrapolateRight:'clamp'}) : 0;
  const y = drift===2 ? interpolate(local,[0,duration],[-12,14],{extrapolateLeft:'clamp',extrapolateRight:'clamp'}) : drift===3 ? interpolate(local,[0,duration],[12,-10],{extrapolateLeft:'clamp',extrapolateRight:'clamp'}) : 0;
  const brightness = interpolate(local,[0,duration],[0.92,1.03],{extrapolateLeft:'clamp',extrapolateRight:'clamp'});
  return <Sequence from={from} durationInFrames={duration} layout="absolute-fill">
    <AbsoluteFill style={{overflow:'hidden',backgroundColor:'#050709'}}>
      <Img src={SCENES[src-1]} style={{width:'100%',height:'100%',objectFit:'cover',scale,translate:`${x}px ${y}px`,filter:`brightness(${brightness}) contrast(1.08) saturate(.88)`}}/>
      <AbsoluteFill style={{background:'linear-gradient(180deg,rgba(0,0,0,.12),transparent 42%,rgba(0,0,0,.42))'}}/>
      <AbsoluteFill style={{boxShadow:'inset 0 0 150px rgba(0,0,0,.42)'}}/>
    </AbsoluteFill>
  </Sequence>;
};

const Caption: React.FC<{b:any}> = ({b}) => {
  const frame=useCurrentFrame(); const {fps}=useVideoConfig(); const s=b.s*fps,e=b.e*fps;
  if(frame<s||frame>=e)return null;
  const local=frame-s,d=e-s;
  const opacity=interpolate(local,[0,2,d-4,d],[0,1,1,0],{extrapolateLeft:'clamp',extrapolateRight:'clamp'});
  const scale=interpolate(local,[0,4,9],[.91,1.04,1],{extrapolateLeft:'clamp',extrapolateRight:'clamp',easing:Easing.bezier(.16,1,.3,1)});
  const danger=b.kind==='danger'; const final=b.kind==='final';
  return <div style={{position:'absolute',left:70,right:70,top:1245,textAlign:'center',opacity,scale,filter:'drop-shadow(0 5px 9px rgba(0,0,0,.75))'}}>
    <div style={{fontFamily:'Arial, sans-serif',fontWeight:900,fontSize:b.kind==='hook'?88:72,lineHeight:.96,letterSpacing:-1.6,color:'#fff'}}>{b.text}</div>
    {b.hi&&<div style={{marginTop:10,fontFamily:'Arial, sans-serif',fontWeight:900,fontSize:b.kind==='hook'?94:79,lineHeight:.95,letterSpacing:-1.7,color:danger?'#ff5b50':final?'#ffd15a':'#ffd15a'}}>{b.hi}</div>}
    {b.sub&&<div style={{marginTop:9,fontFamily:'Arial, sans-serif',fontWeight:900,fontSize:64,lineHeight:.96,letterSpacing:-1,color:danger?'#ff5b50':'#fff'}}>{b.sub}</div>}
  </div>;
};

const Card: React.FC<{c:any}> = ({c}) => {
  const frame=useCurrentFrame(); const {fps}=useVideoConfig(); const s=c.s*fps,e=c.e*fps;
  if(frame<s||frame>=e)return null;
  const local=frame-s;
  const opacity=interpolate(local,[0,3,e-s-3,e-s],[0,.94,.94,0],{extrapolateLeft:'clamp',extrapolateRight:'clamp'});
  const y=interpolate(local,[0,8],[20,0],{extrapolateLeft:'clamp',extrapolateRight:'clamp',easing:Easing.bezier(.16,1,.3,1)});
  return <div style={{position:'absolute',top:170,left:62,opacity,translate:`0 ${y}px`,padding:'14px 22px 13px',borderLeft:'7px solid #ffd15a',background:'rgba(5,7,9,.64)',borderRadius:11}}>
    <div style={{fontFamily:'Arial, sans-serif',fontWeight:900,fontSize:82,lineHeight:.84,color:'#fff',letterSpacing:-3}}>{c.big}</div>
    <div style={{fontFamily:'Arial, sans-serif',fontWeight:900,fontSize:27,lineHeight:1,color:'#ffd15a',letterSpacing:2.5,marginTop:11}}>{c.small}</div>
  </div>;
};

const Grain: React.FC = () => {
  const frame=useCurrentFrame(); const n=(frame*37)%97;
  return <AbsoluteFill style={{opacity:.035,backgroundImage:`radial-gradient(circle at ${20+n%60}% ${30+(n*3)%50}%,rgba(255,255,255,.7) 0 1px,transparent 1.5px),radial-gradient(circle at ${70-(n%50)}% ${15+(n*7)%70}%,rgba(255,255,255,.5) 0 1px,transparent 1.4px)`,backgroundSize:'18px 18px,23px 23px',mixBlendMode:'soft-light'}}/>;
};

export const DanubeNative: React.FC = () => {
  let cursor=0; const starts=SEGMENTS.map(x=>{const s=cursor; cursor+=x.frames; return s;});
  return <AbsoluteFill style={{backgroundColor:'#050709'}}>
    {SEGMENTS.map((seg,i)=><Visual key={i} i={i} src={seg.src} from={starts[i]} duration={seg.frames}/>)}
    <Grain/>
    {cards.map((c,i)=><Card key={i} c={c}/>)}
    {beats.map((b,i)=><Caption key={i} b={b}/>)}
  </AbsoluteFill>;
};

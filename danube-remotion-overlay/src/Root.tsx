import React from 'react';
import {Composition} from 'remotion';
import {DanubeOverlay} from './DanubeOverlay';

export const Root:React.FC=()=> <Composition id="DanubeOverlay" component={DanubeOverlay} durationInFrames={1740} fps={30} width={1080} height={1920}/>;

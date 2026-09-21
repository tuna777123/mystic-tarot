import React from 'react';
import {Composition} from 'remotion';
import {ConceptScene} from './ConceptScene';

const scenes = [
  ['Systems','systems','01 • WORK VS OWNERSHIP','SELL TIME.\nOR BUILD SYSTEMS.','Hours pay once. Systems can keep working after you stop.'],
  ['Compound','compound','02 • COMPOUND GROWTH','COMPOUNDING\nSTARTS SLOW.','The early curve barely moves. Time is what makes it powerful.'],
  ['Emergency','emergency','03 • PROTECT THE DOWNSIDE','EMERGENCY\nFUND FIRST.','Build enough runway so one surprise does not wreck the whole plan.'],
  ['Quiet','quiet','04 • QUIET WEALTH','REAL WEALTH\nGROWS QUIETLY.','Boring, repeatable habits beat exciting financial theater.'],
  ['SaveFirst','savefirst','05 • PAY YOURSELF FIRST','START WITH\nA SMALL PERCENT.','Even five percent creates a system before lifestyle expands.'],
  ['Skills','skills','06 • HUMAN CAPITAL','SKILLS ARE\nCAPITAL.','Learn. Practice. Get paid. Reinvest the result.'],
  ['Debt','debt','07 • FUTURE YOU','DEBT VS.\nINVESTING','One pulls money forward. The other sends money forward.'],
  ['Income','income','08 • RESILIENCE','ONE INCOME\nIS FRAGILE.','More than one small source creates breathing room.'],
  ['Home','home','09 • REPETITION','SMALL HABIT.\nFIRST HOME.','The down payment came from repetition, not a miracle.'],
  ['Compare','compare','10 • YOUR TIMELINE','STOP COMPARING\nPAGES.','Your first page should not be measured against someone else’s last.'],
  ['Perfect','perfect','11 • START BEFORE READY','PERFECT\nNEVER COMES.','Waiting for the perfect moment is still a decision.'],
  ['Time','time','12 • TIME AS CAPITAL','TIME CANNOT\nBE REPLACED.','Money can return. Time cannot. Start before another year disappears.'],
];

export const Root = () => (
  <>
    {scenes.map(([id, kind, eyebrow, title, subtitle]) => (
      <Composition
        key={id}
        id={id}
        component={ConceptScene}
        width={1920}
        height={1080}
        fps={30}
        durationInFrames={96}
        defaultProps={{kind, eyebrow, title, subtitle}}
      />
    ))}
  </>
);

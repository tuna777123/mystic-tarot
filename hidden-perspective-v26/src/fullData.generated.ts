export type Motion = 'push' | 'pull' | 'pan_left' | 'pan_right';
export type Crop = 'tl' | 'tr' | 'bl' | 'br';

export type FullShot = {
  start: number;
  end: number;
  asset: string;
  motion: Motion;
  reconstruction?: boolean;
  crop?: Crop;
  location?: string;
  objectPosition?: string;
};

export type FullCaption = {start: number; end: number; text: string};
export type ChapterRevealData = {start: number; rank: string; title: string; subtitle: string};

// Replaced by scripts/prepare_full.py inside the full-master workflow.
export const fullShots: FullShot[] = [];
export const fullCaptions: FullCaption[] = [];
export const chapterReveals: ChapterRevealData[] = [];

# Hidden Perspective V26 — Remotion Rebuild

This branch is isolated from `main`. It contains the new 90-second proof composition for the abandoned-places documentary.

## Locked quality rules

- 1920×1080 / 30 fps
- V19 speech-timed captions only; no 564-card V22/V24 caption system
- No sine motion, shake, oscillation or generic FFmpeg zoompan
- Motion limited to eased push, pull and lateral track
- No raw 2×2 / 4×4 grids
- Reconstructions are labeled
- Hard documentary cuts by default; no amateur transition pack
- Narration remains the mix anchor
- `Abandoned 1.wav` is the proof score; full V26 uses Abandoned 1–5 in five score blocks

## Proof asset layout

Place images in `public/assets/`, narration/music in `public/audio/`.

Required audio:

- `public/audio/abandoned-1.mp3`
- `public/audio/Abandoned 1.wav`

The proof uses the source image filenames referenced in `src/proofData.ts`.

## Run

```bash
npm install
npm run studio
npm run render:proof
```

Output:

`out/HP_V26_PROOF_90S.mp4`

## Release gates for the proof

1. Captions match the canonical V19 timestamps frame-for-frame.
2. No image is static; movement must remain sub-perceptual and smooth.
3. No frame-edge exposure during pans/zooms.
4. No reconstruction appears without its label.
5. Narration is fully intelligible over music.
6. Visual change frequency remains deliberate: fast in hook, calmer after chapter reveal.
7. No black frames, decode errors, or freezes.
8. Check frames around 9.726s, 14.781s, 26.743s, 31.700s, 33.851s, 48.245s, 61.122s, 69.510s, 76.013s, 85.003s and 88.080s.

Only after the proof passes should the same motion/caption/audio system be expanded to the full 21:07 master.

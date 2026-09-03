# Velvet Harmony Video 03 — Remotion Competitor Master

Self-contained Remotion project for the final two-hour Velvet Harmony ambience upload.

## Locked creative direction

- 3 real moving animation sources; no still image fallback
- Warm → Blue Hour → Night progression
- Long visual anchors; no frequent scene cutting
- No reverse/ping-pong loops
- No artificial camera zoom/pan
- No room-geometry breathing/deformation
- Motion stays low-distraction: rain, curtain, steam/light ambience
- Two premium 4-second dissolves only

## Master timeline

- FPS: **24**
- Resolution: **2560×1440**
- Duration: **172,893 frames = 2:00:03.875**
- Transition 1: **44:01–44:05**, midpoint **44:03**
- Transition 2: **1:23:35–1:23:39**, midpoint **1:23:37**

Absolute frame positions:

- T1 start: `63384`
- T1 end: `63480`
- T2 start: `120360`
- T2 end: `120456`
- final frame count: `172893`

## Setup

1. Copy the exact four files from `ASSETS.md` into `public/assets/`.
2. Run `npm install`.
3. Preview: `npm run studio`.
4. Render + audio mux + strict QC: `npm run render:final`.

## Output

`out/Velvet_Harmony_Video_03_FINAL_REMOTION_COMPETITOR_MASTER_1440P.mp4`

The Remotion render is video-only. `render-final.sh` then muxes the approved AAC stream from `audio-master.mp4` using `-c:a copy`, so the approved audio is not re-encoded.

## Encoding

- H.264
- CRF 16
- yuv420p
- BT.709
- GOP 192 (8 seconds)
- 50% render concurrency
- Fast-start MP4 after final mux

## QC gate

The final is rejected automatically if any of the following occurs:

- resolution != 2560×1440
- FPS != 24/1
- frame count != 172893
- A/V duration difference > 50ms
- approved audio checksum changes
- non-monotonic DTS / decode corruption
- freeze/near-static event >= 0.8 seconds
- black-frame event >= 0.08 seconds

QC stills are also generated around loop seams, both transitions and the ending for visual inspection.

## Why 1440p instead of fake 4K

The animation sources are 1280×720. The 2560×1440 composition is a clean 2× upscale, giving YouTube a stronger transcode source without pretending that the underlying renders contain native 4K detail.

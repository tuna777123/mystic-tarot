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

## Efficient Remotion master architecture

The two-hour video is **not** wastefully re-rendered frame-by-frame for every loop repetition.

Remotion renders only the unique high-quality material:

- `WarmLoop` — 192 frames / 8s
- `BlueLoopPhase4` — 192 frames / 8s
- `NightLoopPhase4` — 192 frames / 8s
- `TransitionWarmBlue` — 96 frames / 4s
- `TransitionBlueNight` — 96 frames / 4s
- `WarmTail1s` — 24 frames
- `BlueTail2s` — 48 frames
- `NightTail21f` — 21 frames

`render-final.sh` then builds the exact two-hour timeline by H.264 packet-copy:

- 330 × WarmLoop + 1s warm tail
- 4s Warm→Blue transition
- 296 × BlueLoopPhase4 + 2s blue tail
- 4s Blue→Night transition
- 273 × NightLoopPhase4 + 21-frame night tail

This sums to exactly **172,893 frames**.

The block boundaries are phase-matched. Example: the warm tail ends on source frame 57 and Transition 1 starts on source frame 58; the blue side of Transition 1 ends on source frame 129 and the next blue block starts on frame 130. The same adjacent-frame continuity is maintained through the night section.

## Setup

1. Copy the exact four files from `ASSETS.md` into `public/assets/`.
2. Run `npm install`.
3. Preview: `npm run studio`.
4. Render + packet-copy assembly + approved-audio mux + strict QC: `npm run render:final`.

## Output

`out/Velvet_Harmony_Video_03_FINAL_REMOTION_COMPETITOR_MASTER_1440P.mp4`

The short visual building blocks are rendered once by Remotion. The two-hour visual is then assembled with `-c:v copy`, so repeated loops do not suffer generational re-encoding. The approved AAC stream from `audio-master.mp4` is muxed using `-c:a copy`, so the approved audio is also not re-encoded.

## Encoding

- H.264
- CRF 16 for the unique Remotion blocks
- yuv420p
- BT.709
- GOP 192 (8 seconds)
- 50% Remotion render concurrency
- 24,000 video-track timescale on final assembly
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

QC stills are also generated around warm/blue/night loop seams, both transitions and the ending for visual inspection.

## Why 1440p instead of fake 4K

The animation sources are 1280×720. The 2560×1440 composition is a clean 2× upscale, giving YouTube a stronger transcode source without pretending that the underlying renders contain native 4K detail.

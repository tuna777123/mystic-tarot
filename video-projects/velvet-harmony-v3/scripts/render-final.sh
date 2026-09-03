#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

mkdir -p out qc

for f in public/assets/warm.mp4 public/assets/blue-hour.mp4 public/assets/night.mp4 public/assets/audio-master.mp4; do
  if [[ ! -f "$f" ]]; then
    echo "Missing required asset: $f" >&2
    exit 2
  fi
done

VISUAL="out/Velvet_Harmony_Video_03_VISUAL_1440P.mp4"
FINAL="out/Velvet_Harmony_Video_03_FINAL_REMOTION_COMPETITOR_MASTER_1440P.mp4"

npx remotion render src/index.ts VelvetHarmony "$VISUAL" \
  --codec=h264 \
  --crf=16 \
  --pixel-format=yuv420p \
  --color-space=bt709 \
  --gop=192 \
  --concurrency=50% \
  --muted \
  --log=verbose

# Preserve the already-approved AAC audio bitstream exactly: no audio re-encode.
ffmpeg -y -v error \
  -i "$VISUAL" \
  -i public/assets/audio-master.mp4 \
  -map 0:v:0 -map 1:a:0 \
  -c:v copy -c:a copy \
  -movflags +faststart \
  "$FINAL"

bash scripts/qc-final.sh "$FINAL"

echo "FINAL=$FINAL"

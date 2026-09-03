#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

mkdir -p out qc blocks

for f in public/assets/warm.mp4 public/assets/blue-hour.mp4 public/assets/night.mp4 public/assets/audio-master.mp4; do
  if [[ ! -f "$f" ]]; then
    echo "Missing required asset: $f" >&2
    exit 2
  fi
done

RENDER_FLAGS=(
  --codec=h264
  --crf=16
  --pixel-format=yuv420p
  --color-space=bt709
  --gop=192
  --concurrency=50%
  --muted
  --log=verbose
)

render_block() {
  local id="$1"
  local out="$2"
  echo "=== REMOTION BLOCK: $id ==="
  npx remotion render src/index.ts "$id" "$out" "${RENDER_FLAGS[@]}"
}

# Render only the unique visual material. The two-hour master is then assembled
# by stream-copy, avoiding 172k redundant Remotion frame renders and avoiding
# generational quality loss on every repeated loop.
render_block WarmLoop blocks/warm_loop.mp4
render_block BlueLoopPhase4 blocks/blue_phase4_loop.mp4
render_block NightLoopPhase4 blocks/night_phase4_loop.mp4
render_block TransitionWarmBlue blocks/transition_warm_blue.mp4
render_block TransitionBlueNight blocks/transition_blue_night.mp4
render_block WarmTail1s blocks/warm_tail_1s.mp4
render_block BlueTail2s blocks/blue_tail_2s.mp4
render_block NightTail21f blocks/night_tail_21f.mp4

TIMELINE="blocks/timeline_concat.txt"
: > "$TIMELINE"
add() { printf "file '%s/%s'\n" "$ROOT" "$1" >> "$TIMELINE"; }

# 0:00 -> 44:01 = 2641s = 330*8s + 1s
for _ in $(seq 1 330); do add blocks/warm_loop.mp4; done
add blocks/warm_tail_1s.mp4

# 44:01 -> 44:05; midpoint exactly 44:03
add blocks/transition_warm_blue.mp4

# 44:05 -> 1:23:35 = 2370s, starting at blue-loop phase 4s
# = 296*8s + 2s, ending at blue-loop phase 6s.
for _ in $(seq 1 296); do add blocks/blue_phase4_loop.mp4; done
add blocks/blue_tail_2s.mp4

# 1:23:35 -> 1:23:39; midpoint exactly 1:23:37
add blocks/transition_blue_night.mp4

# 1:23:39 -> 2:00:03.875 = 2184.875s, starting at night phase 4s
# = 273*8s + 21 frames.
for _ in $(seq 1 273); do add blocks/night_phase4_loop.mp4; done
add blocks/night_tail_21f.mp4

VISUAL="out/Velvet_Harmony_Video_03_VISUAL_REMOTION_1440P.mp4"
FINAL="out/Velvet_Harmony_Video_03_FINAL_REMOTION_COMPETITOR_MASTER_1440P.mp4"

# All blocks share the same Remotion H.264 settings, so this is a packet-copy
# assembly: no second visual encode and no quality loss from repetition.
ffmpeg -y -v warning \
  -f concat -safe 0 -i "$TIMELINE" \
  -map 0:v:0 -an \
  -c:v copy \
  -fflags +genpts \
  -avoid_negative_ts make_zero \
  -video_track_timescale 24000 \
  -movflags +faststart \
  "$VISUAL" \
  2> qc/visual_concat_warnings.txt

# Preserve the approved AAC audio bitstream exactly: no audio re-encode.
ffmpeg -y -v warning \
  -i "$VISUAL" \
  -i public/assets/audio-master.mp4 \
  -map 0:v:0 -map 1:a:0 \
  -c:v copy -c:a copy \
  -video_track_timescale 24000 \
  -movflags +faststart \
  "$FINAL" \
  2> qc/final_mux_warnings.txt

bash scripts/qc-final.sh "$FINAL"

echo "FINAL=$FINAL"

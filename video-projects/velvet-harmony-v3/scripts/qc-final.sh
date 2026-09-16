#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FINAL="${1:-out/Velvet_Harmony_Video_03_FINAL_REMOTION_COMPETITOR_MASTER_1440P.mp4}"
QC="qc"
mkdir -p "$QC/frames"

if [[ ! -f "$FINAL" ]]; then
  echo "Final file not found: $FINAL" >&2
  exit 2
fi

ffprobe -v error -show_streams -show_format -of json "$FINAL" > "$QC/metadata.json"

WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$FINAL")
HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$FINAL")
FPS=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 "$FINAL")
V_DUR=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of csv=p=0 "$FINAL")
A_DUR=$(ffprobe -v error -select_streams a:0 -show_entries stream=duration -of csv=p=0 "$FINAL")
FRAMES=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of csv=p=0 "$FINAL")

printf 'resolution=%sx%s\nfps=%s\nvideo_duration=%s\naudio_duration=%s\nframes=%s\n' \
  "$WIDTH" "$HEIGHT" "$FPS" "$V_DUR" "$A_DUR" "$FRAMES" | tee "$QC/core.txt"

[[ "$WIDTH" == "2560" && "$HEIGHT" == "1440" ]] || { echo "QC FAIL: wrong resolution" >&2; exit 10; }
[[ "$FPS" == "24/1" ]] || { echo "QC FAIL: wrong FPS" >&2; exit 11; }
[[ "$FRAMES" == "172893" ]] || { echo "QC FAIL: wrong frame count ($FRAMES)" >&2; exit 12; }

AV_DIFF=$(awk -v v="$V_DUR" -v a="$A_DUR" 'BEGIN{d=v-a; if(d<0)d=-d; printf "%.6f", d}')
echo "av_duration_diff=$AV_DIFF" | tee -a "$QC/core.txt"
awk -v d="$AV_DIFF" 'BEGIN{exit !(d <= 0.050)}' || { echo "QC FAIL: A/V duration mismatch" >&2; exit 13; }

# Verify the approved audio survived bit-identically at decoded-audio level.
ffmpeg -v error -i public/assets/audio-master.mp4 -map 0:a:0 -f md5 - > "$QC/audio_source.md5"
ffmpeg -v error -i "$FINAL" -map 0:a:0 -f md5 - > "$QC/audio_final.md5"
cmp -s "$QC/audio_source.md5" "$QC/audio_final.md5" || { echo "QC FAIL: audio checksum mismatch" >&2; exit 14; }

# Full decode / timestamp integrity scan.
ffmpeg -v warning -i "$FINAL" -map 0:v:0 -map 0:a:0 -f null - 2> "$QC/decode_warnings.txt" || true
if grep -Eqi 'non-monoton|invalid dts|invalid pts|corrupt|decode error|error while decoding' "$QC/decode_warnings.txt"; then
  echo "QC FAIL: decode/timestamp warning detected" >&2
  exit 15
fi

# Also reject timestamp/packet warnings emitted during packet-copy assembly or final mux.
for LOG in "$QC/visual_concat_warnings.txt" "$QC/final_mux_warnings.txt"; do
  if [[ -f "$LOG" ]] && grep -Eqi 'non-monoton|invalid dts|invalid pts|corrupt|error while decoding|packet corrupt' "$LOG"; then
    echo "QC FAIL: assembly/mux warning detected in $LOG" >&2
    cat "$LOG" >&2
    exit 18
  fi
done

# Strict freeze scan: no >=0.8s static/near-static events.
ffmpeg -hide_banner -nostats -i "$FINAL" -vf 'freezedetect=n=-60dB:d=0.8' -an -f null - 2> "$QC/freeze.log" || true
grep -E 'freeze_(start|duration|end)' "$QC/freeze.log" > "$QC/freeze_events.txt" || true
if [[ -s "$QC/freeze_events.txt" ]]; then
  echo "QC FAIL: freeze event >=0.8s detected" >&2
  cat "$QC/freeze_events.txt" >&2
  exit 16
fi

# Black-frame scan. The two scene dissolves should never expose black.
ffmpeg -hide_banner -nostats -i "$FINAL" -vf 'blackdetect=d=0.08:pix_th=0.02:pic_th=0.98' -an -f null - 2> "$QC/black.log" || true
grep -E 'black_start|black_duration|black_end' "$QC/black.log" > "$QC/black_events.txt" || true
if [[ -s "$QC/black_events.txt" ]]; then
  echo "QC FAIL: black-frame event detected" >&2
  cat "$QC/black_events.txt" >&2
  exit 17
fi

# Human-review stills: warm seam, transition 1, blue seam, transition 2, night seam, ending.
TIMES=(
  0
  599.5 600 600.5
  2640 2643 2646
  3440.5 3441 3441.5
  5014 5017 5020
  5814.5 5815 5815.5
  7198 7203.7
)
for T in "${TIMES[@]}"; do
  SAFE=${T//./_}
  ffmpeg -y -loglevel error -ss "$T" -i "$FINAL" -frames:v 1 -q:v 2 "$QC/frames/t_${SAFE}.jpg"
done

cat > "$QC/PASS.txt" <<EOF
VELVET HARMONY VIDEO 03 — REMOTION QC PASS
Resolution: 2560x1440
FPS: 24
Frames: 172893
Target duration: 2:00:03.875
A/V difference: $AV_DIFF sec
Audio checksum: MATCH
Freeze >=0.8s: 0
Black-frame events: 0
Decode/timestamp errors: 0
Concat/mux timestamp errors: 0
Transition centers: 44:03 and 1:23:37
Loop: 172-frame natural main + 20-frame tail-to-head motion dissolve = 192-frame / 8s cycle
EOF

cat "$QC/PASS.txt"

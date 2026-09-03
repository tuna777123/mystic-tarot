# Velvet Harmony Video 03 — Required media

Do not replace these sources with previews, stills, generated substitutes or older masters.

Place the exact media files in `public/assets/` with these names:

| Project filename | Exact source | ChatGPT file_id | Role |
|---|---|---|---|
| `warm.mp4` | `Preserve_room_composition_and_fr…_202609012212.mp4` | `file_00000000e888820a9e8996ee13388bc8` | Warm opening room |
| `blue-hour.mp4` | `Create_subtle_motion_in_room_202609012200.mp4` | `file_00000000a29c8210856e41e2056a4616` | Blue-hour / breeze room |
| `night.mp4` | `Preserve_room_composition_and_mo…_202609012105.mp4` | `file_00000000b7ac820aa20a088a9ef493b6` | Night room |
| `audio-master.mp4` | `Velvet_Harmony_Video_03_PROFESSIONAL_3_SEAMLESS_LOOPS_1080P.mp4` | `file_00000000944c820aba451148eff11025` | Approved 2-hour AAC audio source |

## Source facts recovered from the previous QC

All three animation sources are approximately 10.005 seconds, 1280×720, 24fps H.264.

The approved loop recipe is intentionally the same for all three sources:

- Main natural-motion section: source frames `34..205` = 172 frames
- Tail for seam: source frames `206..225` = 20 frames
- Head for seam: source frames `14..33` = 20 frames
- Tail → head dissolve: 20 frames (~0.8333s)
- Resulting cycle: 192 frames = exactly 8.000 seconds
- The following cycle starts on source frame 34, directly after the head section ends on frame 33.

This is deliberate: the visible reset is hidden inside the tail→head motion dissolve, while the actual loop boundary is a natural adjacent-frame continuation.

## Important

The project repository does not store these large media binaries. Materialize/copy the exact files above into `public/assets/` before rendering.

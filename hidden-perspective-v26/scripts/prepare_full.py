#!/usr/bin/env python3
import json
import os
import re
import subprocess
from pathlib import Path

FPS = 30
PROJECT = Path(__file__).resolve().parents[1]
WORK = PROJECT / 'work'
PUBLIC = PROJECT / 'public'
FRAMES = PUBLIC / 'frames'
PLAN_PATH = WORK / 'v22_shot_plan.json'
SRT_PATH = WORK / 'ABANDONED_PLACES_ENGLISH_CAPTIONS_V19_FINAL.srt'
SOURCE_VIDEO = WORK / 'V23.mp4'
OUT_TS = PROJECT / 'src' / 'fullData.generated.ts'
MANIFEST = WORK / 'full_manifest.json'

SPECIAL_START = 33.851
SPECIAL_END = 90.0

SPECIAL_SHOTS = [
    {'start':33.851,'end':37.467,'asset':'special/Maunsell Sea Forts in Grey Mist.png','motion':'pull','location':'Maunsell Sea Forts','objectPosition':'58% 48%'},
    {'start':37.467,'end':40.867,'asset':'special/Rusting Catwalk at Maunsell Sea Fort.png','motion':'pan_left','location':'Maunsell Sea Forts'},
    # Different from the chapter hero so no immediate still repetition.
    {'start':40.867,'end':44.300,'asset':'special/Beneath the Maunsell Sea Forts.png','motion':'push','location':'Maunsell Sea Forts'},
    {'start':44.300,'end':48.767,'asset':'special/Maunsell Wartime Gun Reconstruction.png','motion':'pull','location':'Maunsell Sea Forts','reconstruction':True},
    {'start':48.767,'end':53.367,'asset':'special/Maunsell Fort Anti-Aircraft Gun, 1943.png','motion':'pan_right','location':'Maunsell Sea Forts','reconstruction':True},
    {'start':53.367,'end':58.000,'asset':'special/Dawn Watch on the Thames Sea Fort.png','motion':'push','location':'Maunsell Sea Forts','reconstruction':True},
    {'start':58.000,'end':61.133,'asset':'special/Maunsell Postwar Empty Gun Mount Reconstruction.png','motion':'pull','location':'Maunsell Sea Forts','reconstruction':True},
    {'start':61.133,'end':65.333,'asset':'special/Pirate Radio Inside a Sea Fort.png','motion':'pan_left','location':'Maunsell Sea Forts','reconstruction':True},
    {'start':65.333,'end':69.500,'asset':'special/1960s Pirate Radio in a Sea Fort.png','motion':'push','location':'Maunsell Sea Forts','reconstruction':True},
    {'start':69.500,'end':73.433,'asset':'special/Maunsell Pirate Radio Detail Reconstruction.png','motion':'pull','location':'Maunsell Sea Forts','reconstruction':True},
    {'start':73.433,'end':76.000,'asset':'special/Maunsell Understructure Reconstruction.png','motion':'pan_right','location':'Maunsell Sea Forts','reconstruction':True},
    {'start':76.000,'end':80.500,'asset':'special/Corroded Catwalk Between Maunsell Towers.png','motion':'push','location':'Maunsell Sea Forts'},
    # Grey Mist returns only after ~43 seconds, which reads as a deliberate visual bookend rather than repetition.
    {'start':80.500,'end':85.000,'asset':'special/Maunsell Sea Forts in Grey Mist.png','motion':'pull','location':'Maunsell Sea Forts','objectPosition':'52% 49%'},
    {'start':85.000,'end':86.545,'asset':'special/Misty Shoreline Above Abandoned Houtouwan.png','motion':'pull','location':'Houtouwan'},
    {'start':86.545,'end':88.080,'asset':"special/Houtouwan's Ivy-Swallowed Fishing Village.png",'motion':'push','location':'Houtouwan'},
    {'start':88.080,'end':90.000,'asset':'special/Ivy-reclaimed room overlooking Houtouwan coast.png','motion':'pan_left','location':'Houtouwan'},
]

GRID_WINDOWS = [
    (11*60+25.40, 11*60+27.83, 'tl'),
    (11*60+45.60, 11*60+49.70, 'tr'),
    (12*60+0.53, 12*60+4.27, 'tl'),
    (12*60+27.03, 12*60+32.03, 'tr'),
    (12*60+47.30, 12*60+51.17, 'tl'),
    (13*60+4.30, 13*60+7.87, 'tl'),
    (13*60+22.80, 13*60+27.37, 'tl'),
    (13*60+45.07, 13*60+50.10, 'tr'),
    (14*60+3.83, 14*60+7.80, 'tl'),
    (14*60+25.90, 14*60+29.00, 'tr'),
    (14*60+52.23, 14*60+54.90, 'tl'),
    (15*60+12.13, 15*60+14.97, 'tr'),
    (15*60+28.20, 15*60+33.20, 'tl'),
    (15*60+45.80, 15*60+48.47, 'tr'),
    (17*60+17.40, 17*60+20.67, 'tl'),
    (17*60+42.53, 17*60+46.70, 'tr'),
    (18*60+11.97, 18*60+15.30, 'tl'),
    (18*60+39.10, 18*60+42.60, 'tr'),
    (19*60+52.17, 19*60+55.63, 'tl'),
    (20*60+20.67, 20*60+23.53, 'tr'),
]

KNOWN_RECONSTRUCTION_NAMES = {
    'Buses line Pripyat for evacuation.png',
    'Ordinary Life in Pripyat, 1985.png',
    'Villa Epecuén Beneath the Floodwaters.png',
    'Centralia mine fire, four documentary views.png',
    'Plymouth Buried in Volcanic Ash.png',
}

CHAPTER_META = {
    20: ('MAUNSELL SEA FORTS', 'THAMES ESTUARY · UNITED KINGDOM'),
    19: ('HOUTOUWAN', 'SHENGSHAN ISLAND · CHINA'),
    18: ('BODIE', 'CALIFORNIA · UNITED STATES'),
    17: ('BUZLUDZHA', 'BALKAN MOUNTAINS · BULGARIA'),
    16: ('KENNECOTT', 'ALASKA · UNITED STATES'),
    15: ('PYRAMIDEN', 'SVALBARD · NORWAY'),
    14: ('HUMBERSTONE & SANTA LAURA', 'ATACAMA DESERT · CHILE'),
    13: ('CRACO', 'BASILICATA · ITALY'),
    12: ('KAYAKÖY', 'MUĞLA · TÜRKİYE'),
    11: ('NORTH BROTHER ISLAND', 'NEW YORK CITY · UNITED STATES'),
    10: ('WITTENOOM', 'WESTERN AUSTRALIA'),
    9: ('KOLMANSKOP', 'NAMIB DESERT · NAMIBIA'),
    8: ('VILLA EPECUÉN', 'BUENOS AIRES PROVINCE · ARGENTINA'),
    7: ('ST KILDA', 'OUTER HEBRIDES · SCOTLAND'),
    6: ('ORADOUR-SUR-GLANE', 'HAUTE-VIENNE · FRANCE'),
    5: ('PLYMOUTH, MONTSERRAT', 'MONTSERRAT · CARIBBEAN'),
    4: ('VAROSHA', 'FAMAGUSTA · CYPRUS'),
    3: ('CENTRALIA', 'PENNSYLVANIA · UNITED STATES'),
    2: ('HASHIMA ISLAND', 'NAGASAKI · JAPAN'),
    1: ('PRIPYAT', 'CHORNOBYL EXCLUSION ZONE · UKRAINE'),
}


def run(cmd):
    print('+', ' '.join(str(x) for x in cmd))
    subprocess.run(cmd, check=True)


def srt_time(value: str) -> float:
    hh, mm, tail = value.split(':')
    ss, ms = tail.split(',')
    return int(hh)*3600 + int(mm)*60 + int(ss) + int(ms)/1000


def parse_srt(path: Path):
    text = path.read_text(encoding='utf-8-sig').replace('\r\n', '\n')
    blocks = re.split(r'\n\s*\n', text.strip())
    out = []
    for block in blocks:
        lines = [x.rstrip() for x in block.split('\n') if x.strip()]
        if len(lines) < 3 or '-->' not in lines[1]:
            continue
        left, right = [x.strip() for x in lines[1].split('-->')]
        out.append({'start': srt_time(left), 'end': srt_time(right), 'text': ' '.join(lines[2:]).strip()})
    return out


def crop_for(mid: float):
    for start, end, crop in GRID_WINDOWS:
        if start <= mid <= end:
            return crop
    return None


def is_reconstruction(shot):
    name = shot.get('asset_name') or Path(shot.get('asset', '')).name
    return bool(shot.get('reconstruction')) or 'reconstruction' in name.lower() or name in KNOWN_RECONSTRUCTION_NAMES


def normalize_motion(motion: str, duration: float) -> str:
    m = motion if motion in {'push','pull','pan_left','pan_right'} else 'push'
    # Very short pans create a perceptual jolt even with easing. Convert them to restrained zooms.
    if duration < 2.2 and m.startswith('pan_'):
        return 'push' if int(round(duration * 1000)) % 2 == 0 else 'pull'
    return m


def safe_rank(value):
    try:
        return int(value)
    except Exception:
        return None


def load_plan():
    raw = json.loads(PLAN_PATH.read_text(encoding='utf-8'))
    if isinstance(raw, dict):
        for key in ('shots', 'plan', 'items'):
            if isinstance(raw.get(key), list):
                return raw[key]
        raise RuntimeError('Could not find shot list in plan JSON')
    if not isinstance(raw, list):
        raise RuntimeError('Shot plan must be a list or contain a list')
    return raw


def next_clean_midpoint(shots, index):
    here = shots[index]
    loc = here.get('location')
    for j in range(index + 1, min(len(shots), index + 5)):
        cand = shots[j]
        if cand.get('location') == loc and not cand.get('reveal'):
            return (float(cand['start']) + float(cand['end'])) / 2
    return (float(here['start']) + float(here['end'])) / 2


def main():
    if not SOURCE_VIDEO.exists():
        raise SystemExit(f'Missing source video: {SOURCE_VIDEO}')
    shots = load_plan()
    captions = parse_srt(SRT_PATH)
    if len(captions) != 438:
        raise SystemExit(f'Expected 438 canonical captions, found {len(captions)}')

    FRAMES.mkdir(parents=True, exist_ok=True)
    for old in FRAMES.glob('frame-*.jpg'):
        old.unlink()

    prepared = []
    frame_requests = []
    chapter_starts = {}

    for i, shot in enumerate(shots):
        start = float(shot['start'])
        end = float(shot['end'])
        rank = safe_rank(shot.get('rank'))
        if shot.get('reveal') and rank in CHAPTER_META and rank not in chapter_starts:
            chapter_starts[rank] = start

        pieces = []
        if end <= SPECIAL_START or start >= SPECIAL_END:
            pieces.append((start, end))
        else:
            if start < SPECIAL_START:
                pieces.append((start, SPECIAL_START))
            if end > SPECIAL_END:
                pieces.append((SPECIAL_END, end))

        for piece_start, piece_end in pieces:
            if piece_end - piece_start <= 0.025:
                continue
            midpoint = (piece_start + piece_end) / 2
            sample_time = next_clean_midpoint(shots, i) if shot.get('reveal') else midpoint
            source_frame = max(0, int(round(sample_time * FPS)))
            frame_requests.append(source_frame)
            prepared.append({
                'start': round(piece_start, 6),
                'end': round(piece_end, 6),
                '_source_frame': source_frame,
                'motion': normalize_motion(str(shot.get('motion') or 'push'), piece_end-piece_start),
                'reconstruction': is_reconstruction(shot),
                'crop': crop_for(midpoint),
                'location': str(shot.get('location') or ''),
            })

    unique_frames = sorted(set(frame_requests))
    select_expr = 'select=' + '+'.join(f'eq(n\\,{n})' for n in unique_frames)
    run([
        'ffmpeg', '-hide_banner', '-y', '-i', str(SOURCE_VIDEO),
        '-an', '-vf', select_expr, '-fps_mode', 'vfr', '-q:v', '2',
        str(FRAMES / 'frame-%04d.jpg'),
    ])

    outputs = sorted(FRAMES.glob('frame-*.jpg'))
    if len(outputs) != len(unique_frames):
        raise SystemExit(f'Frame extraction mismatch: requested {len(unique_frames)}, wrote {len(outputs)}')
    frame_map = {n: f'frames/{outputs[idx].name}' for idx, n in enumerate(unique_frames)}

    for item in prepared:
        item['asset'] = frame_map[item.pop('_source_frame')]
        if not item.get('reconstruction'):
            item.pop('reconstruction', None)
        if not item.get('crop'):
            item.pop('crop', None)

    prepared.extend(SPECIAL_SHOTS)
    prepared.sort(key=lambda x: (x['start'], x['end']))

    # Hard validation for timeline continuity. Sub-frame rounding is allowed, visible gaps are not.
    max_gap = 0.0
    max_overlap = 0.0
    for a, b in zip(prepared, prepared[1:]):
        delta = b['start'] - a['end']
        max_gap = max(max_gap, delta)
        max_overlap = max(max_overlap, -delta)
    if max_gap > 0.051 or max_overlap > 0.051:
        raise SystemExit(f'Invalid timeline continuity: max_gap={max_gap:.4f}s max_overlap={max_overlap:.4f}s')

    # Explicit canonical starts for the two chapters rebuilt from special raw sources.
    chapter_starts[20] = 33.851
    chapter_starts[19] = 85.003
    chapters = []
    for rank in range(20, 0, -1):
        if rank not in chapter_starts:
            raise SystemExit(f'Missing chapter reveal for rank {rank}')
        title, subtitle = CHAPTER_META[rank]
        chapters.append({'start': round(chapter_starts[rank], 6), 'rank': f'#{rank}', 'title': title, 'subtitle': subtitle})

    header = """export type Motion = 'push' | 'pull' | 'pan_left' | 'pan_right';
export type Crop = 'tl' | 'tr' | 'bl' | 'br';
export type FullShot = {start:number;end:number;asset:string;motion:Motion;reconstruction?:boolean;crop?:Crop;location?:string;objectPosition?:string};
export type FullCaption = {start:number;end:number;text:string};
export type ChapterRevealData = {start:number;rank:string;title:string;subtitle:string};
"""
    OUT_TS.write_text(
        header
        + '\nexport const fullShots: FullShot[] = ' + json.dumps(prepared, ensure_ascii=False, separators=(',', ':')) + ';\n'
        + '\nexport const fullCaptions: FullCaption[] = ' + json.dumps(captions, ensure_ascii=False, separators=(',', ':')) + ';\n'
        + '\nexport const chapterReveals: ChapterRevealData[] = ' + json.dumps(chapters, ensure_ascii=False, separators=(',', ':')) + ';\n',
        encoding='utf-8',
    )

    manifest = {
        'shots': len(prepared),
        'frame_grabs': len(unique_frames),
        'special_raw_shots': len(SPECIAL_SHOTS),
        'canonical_captions': len(captions),
        'chapters': len(chapters),
        'reconstruction_shots': sum(1 for x in prepared if x.get('reconstruction')),
        'cropped_grid_shots': sum(1 for x in prepared if x.get('crop')),
        'max_gap_seconds': max_gap,
        'max_overlap_seconds': max_overlap,
        'first_start': prepared[0]['start'],
        'last_end': prepared[-1]['end'],
    }
    MANIFEST.write_text(json.dumps(manifest, indent=2, ensure_ascii=False), encoding='utf-8')
    print(json.dumps(manifest, indent=2, ensure_ascii=False))


if __name__ == '__main__':
    main()

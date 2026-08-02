#!/usr/bin/env python3
import base64
import glob
import zlib
from pathlib import Path

parts = sorted(glob.glob('tool/.v113_payload.part*'))
if not parts:
    raise SystemExit('No v1.13 payload parts found.')

encoded = ''.join(Path(path).read_text(encoding='utf-8') for path in parts)
script = zlib.decompress(base64.b64decode(encoded)).decode('utf-8')
for path in parts:
    Path(path).unlink()

exec(
    compile(script, 'tool/integrate_v113_patch.py', 'exec'),
    {'__file__': 'tool/integrate_v113_bootstrap.py'},
)

import ast
import base64
from pathlib import Path
import re
import zlib

bootstrap = Path('tool/v120_integrate.py').read_text(encoding='utf-8')
match = re.search(r"b64decode\((['\"].*?['\"])\)", bootstrap, re.DOTALL)
if match is None:
    raise RuntimeError('Could not locate the v1.20 integration payload.')

encoded = ast.literal_eval(match.group(1))
source = zlib.decompress(base64.b64decode(encoded)).decode('utf-8')
source = source.replace(
    'emotion: EmotionalState.calm,',
    'emotion: EmotionalState.grounded,',
)
exec(compile(source, 'v120_integrate_payload.py', 'exec'))

for temporary_path in (
    Path('tool/v120_run.py'),
    Path('test/aaa_v120_materialize_test.dart'),
):
    if temporary_path.exists():
        temporary_path.unlink()

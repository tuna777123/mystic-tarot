from pathlib import Path

screen_path = Path('lib/src/private_journal_transfer_screen.dart')
screen = screen_path.read_text()
old = "      code = await _service.createCode(widget.records);\n      final renderObject = context.findRenderObject();"
new = "      code = await _service.createCode(widget.records);\n      if (!mounted) return;\n      final renderObject = context.findRenderObject();"
if old not in screen:
    raise SystemExit('Expected share integration point was not found.')
screen_path.write_text(screen.replace(old, new, 1))

for path in [
    Path('tool/fix_v118_mounted.py'),
    Path('.github/workflows/fix-v118-mounted.yml'),
]:
    if path.exists():
        path.unlink()

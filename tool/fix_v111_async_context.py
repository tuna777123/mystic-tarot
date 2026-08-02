from pathlib import Path

path = Path('lib/src/app.dart')
text = path.read_text(encoding='utf-8')
old = """    final mirrors = await MysticMirrorStore().load();
    final text = buildMysticJournalExport(
"""
new = """    final mirrors = await MysticMirrorStore().load();
    if (!mounted) return;
    final text = buildMysticJournalExport(
"""
count = text.count(old)
if count != 1:
    raise SystemExit(f'Expected exactly one export load block, found {count}')
path.write_text(text.replace(old, new, 1), encoding='utf-8')

from pathlib import Path

root = Path(__file__).resolve().parents[1]

app_language = root / 'lib/src/app_language.dart'
text = app_language.read_text(encoding='utf-8')
text = text.replace("export 'flagship.dart' show MysticLanguage;\n\n", '', 1)
app_language.write_text(text, encoding='utf-8')

for relative in [
    'lib/src/private_journal_transfer_screen.dart',
    'test/private_journal_transfer_screen_test.dart',
]:
    path = root / relative
    text = path.read_text(encoding='utf-8')
    old = "import 'app_language.dart';" if relative.startswith('lib/') else "import 'package:mystic_tarot/src/app_language.dart';"
    new = "import 'flagship.dart';" if relative.startswith('lib/') else "import 'package:mystic_tarot/src/flagship.dart';"
    if text.count(old) != 1:
        raise SystemExit(f'Expected one language import in {relative}')
    path.write_text(text.replace(old, new, 1), encoding='utf-8')

(root / '.github/workflows/v118-import-fix.yml').unlink(missing_ok=True)
(root / 'tool/v118_import_fix.py').unlink(missing_ok=True)
(root / 'tool/placeholder_should_not_exist').unlink(missing_ok=True)

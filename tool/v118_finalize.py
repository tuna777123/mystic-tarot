from pathlib import Path
import re

screen_path = Path('lib/src/private_journal_transfer_screen.dart')
screen = screen_path.read_text()
screen = screen.replace("import 'app_language.dart';", "import 'flagship.dart';")

share_method = r'''  Future<void> _shareCode() async {
    setState(() {
      _busy = true;
      _error = null;
      _success = null;
    });
    String? code;
    try {
      code = await _service.createCode(widget.records);
      final renderObject = context.findRenderObject();
      final origin = renderObject is RenderBox
          ? renderObject.localToGlobal(Offset.zero) & renderObject.size
          : const Rect.fromLTWH(0, 0, 1, 1);
      final result = await SharePlus.instance.share(
        ShareParams(
          text: code,
          title: _copy(
            en: 'Mystic Tarot private journal transfer',
            tr: 'Mystic Tarot özel günlük taşıması',
            es: 'Transferencia del diario privado de Mystic Tarot',
            fr: 'Transfert du journal privé Mystic Tarot',
            pt: 'Transferência do diário privado Mystic Tarot',
          ),
          sharePositionOrigin: origin,
        ),
      );
      if (!mounted || result.status == ShareResultStatus.dismissed) return;
      if (result.status == ShareResultStatus.success) {
        setState(() => _success = _copy(
              en: 'Your private transfer code was shared.',
              tr: 'Özel taşıma kodun paylaşıldı.',
              es: 'Tu código privado se compartió.',
              fr: 'Votre code privé a été partagé.',
              pt: 'Seu código privado foi compartilhado.',
            ));
        return;
      }
      await Clipboard.setData(ClipboardData(text: code));
      if (!mounted) return;
      setState(() => _success = _copy(
            en: 'Sharing was unavailable. The private code was copied instead.',
            tr: 'Paylaşım kullanılamadı. Özel kod bunun yerine kopyalandı.',
            es: 'No se pudo compartir. El código privado se copió.',
            fr: 'Le partage était indisponible. Le code privé a été copié.',
            pt: 'O compartilhamento não estava disponível. O código privado foi copiado.',
          ));
    } catch (_) {
      if (!mounted) return;
      if (code != null) {
        await Clipboard.setData(ClipboardData(text: code));
        if (!mounted) return;
        setState(() => _success = _copy(
              en: 'Sharing was unavailable. The private code was copied instead.',
              tr: 'Paylaşım kullanılamadı. Özel kod bunun yerine kopyalandı.',
              es: 'No se pudo compartir. El código privado se copió.',
              fr: 'Le partage était indisponible. Le code privé a été copié.',
              pt: 'O compartilhamento não estava disponível. O código privado foi copiado.',
            ));
      } else {
        setState(() => _error = _copy(
              en: 'The private transfer code could not be created.',
              tr: 'Özel taşıma kodu oluşturulamadı.',
              es: 'No se pudo crear el código privado.',
              fr: 'Impossible de créer le code privé.',
              pt: 'Não foi possível criar o código privado.',
            ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
'''

pattern = re.compile(
    r"  Future<void> _shareCode\(\) async \{.*?\n  \}\n\n  Future<void> _paste\(\) async \{",
    re.S,
)
match = pattern.search(screen)
if match is None:
    raise SystemExit('Could not locate _shareCode integration point.')
screen = screen[:match.start()] + share_method + "\n  Future<void> _paste() async {" + screen[match.end():]
screen_path.write_text(screen)

screen_test_path = Path('test/private_journal_transfer_screen_test.dart')
screen_test = screen_test_path.read_text().replace(
    "import 'package:mystic_tarot/src/app_language.dart';",
    "import 'package:mystic_tarot/src/flagship.dart';",
)
screen_test_path.write_text(screen_test)

for path in [
    Path('tool/v118_finalize.py'),
    Path('.github/workflows/v118-finalize.yml'),
]:
    if path.exists():
        path.unlink()

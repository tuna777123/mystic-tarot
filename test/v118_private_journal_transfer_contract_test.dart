import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1.18 private transfer release contract stays complete', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final app = File('lib/src/app.dart').readAsStringSync();
    final codec = File('lib/src/journal_transfer.dart').readAsStringSync();
    final service = File(
      'lib/src/private_journal_transfer.dart',
    ).readAsStringSync();
    final screen = File(
      'lib/src/private_journal_transfer_screen.dart',
    ).readAsStringSync();
    final notes = File('RELEASE_NOTES.md').readAsStringSync();

    final version = RegExp(
      r'version: 1\.(\d+)\.(\d+)\+(\d+)',
    ).firstMatch(pubspec);
    expect(version, isNotNull);
    expect(int.parse(version!.group(1)!), greaterThanOrEqualTo(18));
    expect(int.parse(version.group(3)!), greaterThanOrEqualTo(24));
    expect(app, contains("import 'private_journal_transfer_screen.dart';"));
    expect(app, contains('onJournalRestored: _applyRestoredJournal'));
    expect(app, contains('PrivateJournalTransferScreen('));
    expect(codec, contains("'mirror':"));
    expect(codec, contains("'oracle':"));
    expect(codec, contains('parts.skip(1).join()'));
    expect(service, contains('Future<void> _rollback('));
    expect(service, contains('ReadingJournalStore.backupKey'));
    expect(service, contains('MysticMirrorStore.backupKey'));
    expect(service, contains('OracleConversationStore.backupKey'));
    expect(service, contains('JournalTransferCodec.decode(code)'));
    expect(screen, contains('Merge private history?'));
    expect(screen, contains('never saves or uploads it'));
    expect(screen, contains('ShareResultStatus.success'));
    expect(screen, contains('Clipboard.setData'));
    expect(screen, contains('MysticLanguage.french'));
    expect(screen, contains('MysticLanguage.portugueseBrazil'));
    expect(notes, contains('# Mystic Tarot 1.18.0'));
    expect(screen, isNot(contains('package:http')));
    expect(screen, isNot(contains('dart:io')));
    expect(File('.github/workflows/v118-integrate.yml').existsSync(), isFalse);
    expect(File('tool/v118_integrate.py').existsSync(), isFalse);
    expect(File('.github/workflows/v118-finalize.yml').existsSync(), isFalse);
    expect(File('tool/v118_finalize.py').existsSync(), isFalse);
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1.19 protected transfer release contract stays complete', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final protection =
        File('lib/src/journal_transfer_protection.dart').readAsStringSync();
    final service =
        File('lib/src/private_journal_transfer.dart').readAsStringSync();
    final screen =
        File('lib/src/private_journal_transfer_screen.dart').readAsStringSync();
    final notes = File('RELEASE_NOTES_1.19.md').readAsStringSync();

    expect(pubspec, contains('version: 1.19.0+25'));
    expect(pubspec, contains('cryptography: ^2.9.0'));
    expect(protection, contains("marker = 'MYSTIC-TAROT-JOURNAL-V2'"));
    expect(protection, contains('AesGcm.with256bits()'));
    expect(protection, contains('Argon2id('));
    expect(protection, contains('memoryBlocks = 19 * 1024'));
    expect(protection, contains('SecretBox.fromConcatenation('));
    expect(service, contains('JournalTransferCodec.decode(code)'));
    expect(service, contains('JournalTransferProtection.unlock('));
    expect(screen, contains('Create protected code'));
    expect(screen, contains('Leave empty only for legacy V1 codes.'));
    expect(screen, contains('MysticLanguage.french'));
    expect(screen, contains('MysticLanguage.portugueseBrazil'));
    expect(notes, startsWith('# Mystic Tarot 1.19.0'));
    expect(notes, contains('never saved, uploaded'));
    expect(notes, contains('Existing V1 transfer codes remain valid'));
    expect(screen, isNot(contains('package:http')));
    expect(File('.github/workflows/v119-integrate.yml').existsSync(), isFalse);
    expect(File('tool/v119_integrate.py').existsSync(), isFalse);
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final app = File('lib/src/app.dart').readAsStringSync();
  final journal =
      File('lib/src/mystic_living_journal_feature.dart').readAsStringSync();
  final export = File('lib/src/journal_export.dart').readAsStringSync();
  final store = File('lib/src/oracle_conversation.dart').readAsStringSync();
  final notes = File('RELEASE_NOTES.md').readAsStringSync();
  final pubspec = File('pubspec.yaml').readAsStringSync();

  test('v1.16 persists and restores reading-linked Oracle dialogue', () {
    expect(pubspec, contains('version: 1.16.0+22'));
    expect(app, contains('OracleConversationStore'));
    expect(app, contains('loadForRecord(widget.record)'));
    expect(app, contains('saveTurn(turn)'));
    expect(app, contains('turns.isNotEmpty'));
    expect(store, contains('oracle_conversations_v1'));
    expect(store, contains('backupKey'));
  });

  test('Living Journal reopens verified Oracle memory', () {
    expect(journal, contains('OracleMemoryAction'));
    expect(journal, contains('oracleConversationRecordId(record)'));
    expect(journal, contains('widget.onOpenOracle(record)'));
    expect(app, contains('onOpenOracle: _openSavedOracle'));
  });

  test('private export includes Oracle turns beside the reading', () {
    expect(export, contains('oracleConversations'));
    expect(export, contains('Oracle Dialogue — saved on this device'));
    expect(export, contains('turn.question'));
    expect(export, contains('turn.answer'));
    expect(app, contains('Oracle conversations'));
    expect(app, contains('Oracle konuşmaların'));
  });

  test('release notes make no cloud or certainty claim', () {
    expect(notes, startsWith('# Mystic Tarot 1.16.0 — Private Oracle Memory'));
    expect(notes, contains('No Oracle question or answer is uploaded'));
    expect(notes, contains('without presenting the response as certainty'));
    expect(notes, isNot(contains('AI prediction')));
  });

  test('temporary v1.16 integration files are absent from release tree', () {
    expect(File('tool/apply_v116.py').existsSync(), isFalse);
    expect(File('.github/workflows/apply-v116.yml').existsSync(), isFalse);
  });
}

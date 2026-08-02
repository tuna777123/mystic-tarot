import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1.11 trust baseline remains documented after later releases', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final releaseNotes = File('RELEASE_NOTES.md').readAsStringSync();

    expect(pubspec, isNot(contains('version: 1.10.')));
    expect(
      releaseNotes,
      contains('# Mystic Tarot 1.11.0 — Mirror & Trust'),
    );
  });

  test('release app wires every flagship trust feature', () {
    final app = File('lib/src/app.dart').readAsStringSync();

    for (final marker in <String>[
      'ReadingExplanationPanel(',
      'buildMysticJournalExport(',
      'SharePlus.instance.share(',
      'localizedJournalRecoveryNotice(',
      'countDueMysticMirrors(',
      'durationUntilNextMysticMirror(',
      'localizedMirrorDueSemantics(',
      'onMirrorChanged: _refreshMirrorDueState',
      'launchUrl(Uri.parse(supportLink))',
    ]) {
      expect(app, contains(marker), reason: marker);
    }
    expect(app, isNot(contains('journal.take(50)')));
  });

  test('Living Journal keeps failed Mirror saves retryable', () {
    final journal =
        File('lib/src/mystic_living_journal_feature.dart').readAsStringSync();

    expect(journal, contains('onMirrorChanged'));
    expect(journal, contains('mysticSearchMatches('));
    expect(journal, contains('setSheetState(() => saving = false)'));
    expect(journal, contains('Nothing was changed; please try again.'));
  });

  test('journal and Mirror backups reject corrupt primary snapshots', () {
    final journalStore =
        File('lib/src/reading_journal_store.dart').readAsStringSync();
    final mirrorStore = File('lib/src/mystic_mirror.dart').readAsStringSync();

    expect(journalStore, contains('_isTrustworthyPayload(currentPayload)'));
    expect(mirrorStore, contains('primaryIsFullyValid'));
    expect(
      mirrorStore,
      contains('MysticMirrorReflection.tryDecode(encoded) != null'),
    );
  });

  test('all v1.11 trust modules and tests remain in the release tree', () {
    for (final path in <String>[
      'lib/src/journal_export.dart',
      'lib/src/mystic_mirror_due.dart',
      'lib/src/mystic_search.dart',
      'lib/src/reading_explanation.dart',
      'lib/src/reading_position.dart',
      'test/journal_export_test.dart',
      'test/mystic_mirror_due_test.dart',
      'test/mystic_search_test.dart',
      'test/reading_explanation_test.dart',
      'test/reading_position_test.dart',
    ]) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });
}

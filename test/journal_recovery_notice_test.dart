import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/journal_recovery_notice.dart';
import 'package:mystic_tarot/src/reading_journal_store.dart';

const emptyRecords = <Never>[];

ReadingJournalLoadResult result({
  bool recovered = false,
  bool migrated = false,
  int rejected = 0,
}) =>
    ReadingJournalLoadResult(
      records: const [],
      recoveredFromBackup: recovered,
      migratedFromLegacy: migrated,
      rejectedItems: rejected,
    );

void main() {
  test('clean load produces no distracting notice', () {
    expect(
      localizedJournalRecoveryNotice(
        result(),
        MysticLanguage.english,
      ),
      isNull,
    );
  });

  test('backup recovery is disclosed in every launch language', () {
    const expected = <MysticLanguage, String>{
      MysticLanguage.english: 'last valid local backup',
      MysticLanguage.turkish: 'son sağlam yerel yedekten',
      MysticLanguage.spanish: 'última copia local válida',
      MysticLanguage.french: 'dernière sauvegarde locale valide',
      MysticLanguage.portugueseBrazil: 'último backup local válido',
    };

    for (final entry in expected.entries) {
      final notice = localizedJournalRecoveryNotice(
        result(recovered: true),
        entry.key,
      );
      expect(notice, contains(entry.value), reason: entry.key.name);
    }
  });

  test('damaged item count is never hidden during recovery', () {
    final notice = localizedJournalRecoveryNotice(
      result(recovered: true, rejected: 3),
      MysticLanguage.english,
    );

    expect(notice, contains('3 damaged entries'));
    expect(notice, contains('skipped'));
  });

  test('legacy upgrade is explained without implying cloud transfer', () {
    final notice = localizedJournalRecoveryNotice(
      result(migrated: true),
      MysticLanguage.english,
    );

    expect(notice, contains('safer local format'));
    expect(notice, isNot(contains('cloud')));
    expect(notice, isNot(contains('server')));
  });

  test('partial corruption confirms that remaining history is safe', () {
    final notice = localizedJournalRecoveryNotice(
      result(rejected: 1),
      MysticLanguage.english,
    );

    expect(notice, contains('1 damaged entry'));
    expect(notice, contains('rest of your journal is safe'));
  });
}

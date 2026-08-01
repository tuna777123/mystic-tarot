import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'tarot_data.dart';

class ReadingJournalDecodeReport {
  const ReadingJournalDecodeReport({
    required this.records,
    required this.rejectedItems,
  });

  final List<ReadingRecord> records;
  final int rejectedItems;
}

class ReadingJournalLoadResult {
  const ReadingJournalLoadResult({
    required this.records,
    required this.recoveredFromBackup,
    required this.migratedFromLegacy,
    required this.rejectedItems,
  });

  final List<ReadingRecord> records;
  final bool recoveredFromBackup;
  final bool migratedFromLegacy;
  final int rejectedItems;
}

class ReadingJournalCodec {
  const ReadingJournalCodec._();

  static const schemaVersion = 1;

  static String encode(Iterable<ReadingRecord> records) => jsonEncode(
        <String, Object>{
          'schemaVersion': schemaVersion,
          'records': records.map(_encodeRecord).toList(growable: false),
        },
      );

  static ReadingJournalDecodeReport decode(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Journal root must be an object.');
    }
    if (decoded['schemaVersion'] != schemaVersion) {
      throw const FormatException('Unsupported journal schema version.');
    }
    final rawRecords = decoded['records'];
    if (rawRecords is! List<dynamic>) {
      throw const FormatException('Journal records must be a list.');
    }

    final records = <ReadingRecord>[];
    final seen = <String>{};
    var rejected = 0;
    for (final rawRecord in rawRecords) {
      final record = _tryDecodeRecord(rawRecord);
      if (record == null) {
        rejected++;
        continue;
      }
      final id = readingJournalRecordId(record);
      if (!seen.add(id)) {
        rejected++;
        continue;
      }
      records.add(record);
    }
    return ReadingJournalDecodeReport(
      records: List<ReadingRecord>.unmodifiable(records),
      rejectedItems: rejected,
    );
  }

  static ReadingJournalDecodeReport decodeLegacy(Iterable<String> payloads) {
    final records = <ReadingRecord>[];
    final seen = <String>{};
    var rejected = 0;
    for (final payload in payloads) {
      try {
        final decoded = jsonDecode(payload);
        final record = _tryDecodeRecord(decoded);
        if (record == null || !seen.add(readingJournalRecordId(record))) {
          rejected++;
          continue;
        }
        records.add(record);
      } catch (_) {
        rejected++;
      }
    }
    return ReadingJournalDecodeReport(
      records: List<ReadingRecord>.unmodifiable(records),
      rejectedItems: rejected,
    );
  }

  static Map<String, Object> _encodeRecord(ReadingRecord record) =>
      <String, Object>{
        'kind': record.kind.name,
        'question': record.question,
        'cards': record.cards
            .map(
              (item) => <String, Object>{
                'name': item.card.name,
                'reversed': item.reversed,
              },
            )
            .toList(growable: false),
        'createdAt': record.createdAt.toUtc().toIso8601String(),
        'emotion': record.emotion.name,
        'action': record.alignedAction,
      };

  static ReadingRecord? _tryDecodeRecord(Object? value) {
    try {
      if (value is! Map<String, dynamic>) return null;
      final kindName = value['kind'];
      final question = value['question'];
      final rawCards = value['cards'];
      final createdAt = value['createdAt'];
      final emotionName = value['emotion'];
      final action = value['action'];
      if (kindName is! String ||
          question is! String ||
          rawCards is! List<dynamic> ||
          createdAt is! String ||
          emotionName is! String ||
          action is! String) {
        return null;
      }

      final cards = <DrawnCard>[];
      for (final rawCard in rawCards) {
        if (rawCard is! Map<String, dynamic>) return null;
        final name = rawCard['name'];
        final reversed = rawCard['reversed'];
        if (name is! String || reversed is! bool) return null;
        final card = tarotDeck.cast<TarotCardData?>().firstWhere(
              (candidate) => candidate?.name == name,
              orElse: () => null,
            );
        if (card == null) return null;
        cards.add(DrawnCard(card, reversed));
      }
      if (cards.isEmpty) return null;

      return ReadingRecord(
        kind: ReadingKind.values.byName(kindName),
        question: question.length > 500 ? question.substring(0, 500) : question,
        cards: List<DrawnCard>.unmodifiable(cards),
        createdAt: DateTime.parse(createdAt).toLocal(),
        emotion: EmotionalState.values.byName(emotionName),
        alignedAction:
            action.length > 1000 ? action.substring(0, 1000) : action,
      );
    } catch (_) {
      return null;
    }
  }
}

String readingJournalRecordId(ReadingRecord record) =>
    '${record.createdAt.toUtc().toIso8601String()}|${record.kind.name}';

class ReadingJournalStore {
  ReadingJournalStore({SharedPreferences? preferences})
      : _providedPreferences = preferences;

  static const primaryKey = 'reading_journal_v1';
  static const backupKey = 'reading_journal_v1_backup';
  static const legacyKey = 'journal_records';

  final SharedPreferences? _providedPreferences;

  Future<SharedPreferences> _preferences() async =>
      _providedPreferences ?? SharedPreferences.getInstance();

  Future<ReadingJournalLoadResult> load({
    Iterable<String> legacyRecords = const <String>[],
  }) async {
    final preferences = await _preferences();
    final primary = preferences.getString(primaryKey);
    final backup = preferences.getString(backupKey);

    if (primary != null && primary.trim().isNotEmpty) {
      try {
        final report = ReadingJournalCodec.decode(primary);
        return ReadingJournalLoadResult(
          records: report.records,
          recoveredFromBackup: false,
          migratedFromLegacy: false,
          rejectedItems: report.rejectedItems,
        );
      } catch (_) {
        // Fall through to the last-known-good snapshot.
      }
    }

    if (backup != null && backup.trim().isNotEmpty) {
      try {
        final report = ReadingJournalCodec.decode(backup);
        return ReadingJournalLoadResult(
          records: report.records,
          recoveredFromBackup: true,
          migratedFromLegacy: false,
          rejectedItems: report.rejectedItems,
        );
      } catch (_) {
        // Fall through to the legacy migration path.
      }
    }

    final legacy = legacyRecords.isEmpty
        ? preferences.getStringList(legacyKey) ?? const <String>[]
        : legacyRecords.toList(growable: false);
    if (legacy.isNotEmpty) {
      final report = ReadingJournalCodec.decodeLegacy(legacy);
      return ReadingJournalLoadResult(
        records: report.records,
        recoveredFromBackup: false,
        migratedFromLegacy: true,
        rejectedItems: report.rejectedItems,
      );
    }

    return const ReadingJournalLoadResult(
      records: <ReadingRecord>[],
      recoveredFromBackup: false,
      migratedFromLegacy: false,
      rejectedItems: 0,
    );
  }

  Future<void> save(Iterable<ReadingRecord> records) async {
    final preferences = await _preferences();
    final nextPayload = ReadingJournalCodec.encode(records);
    final currentPayload = preferences.getString(primaryKey);

    if (currentPayload != null && currentPayload.trim().isNotEmpty) {
      final backupSaved =
          await preferences.setString(backupKey, currentPayload);
      if (!backupSaved) {
        throw StateError('Could not preserve the previous journal snapshot.');
      }
    }

    final primarySaved = await preferences.setString(primaryKey, nextPayload);
    if (!primarySaved) {
      throw StateError('Could not save the reading journal.');
    }
  }

  Future<void> finishLegacyMigration() async {
    final preferences = await _preferences();
    await preferences.remove(legacyKey);
  }

  Future<void> clear() async {
    final preferences = await _preferences();
    await Future.wait(<Future<bool>>[
      preferences.remove(primaryKey),
      preferences.remove(backupKey),
      preferences.remove(legacyKey),
    ]);
  }
}

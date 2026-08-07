import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'ad_revenue_service.dart';
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

  static String encode(Iterable<ReadingRecord> records) =>
      jsonEncode(<String, Object>{
        'schemaVersion': schemaVersion,
        'records': records.map(_encodeRecord).toList(growable: false),
      });

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

  static Map<String, Object> _encodeRecord(
    ReadingRecord record,
  ) => <String, Object>{
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

        TarotCardData? card;
        for (final candidate in tarotDeck) {
          if (candidate.name == name) {
            card = candidate;
            break;
          }
        }
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
        alignedAction: action.length > 1000
            ? action.substring(0, 1000)
            : action,
      );
    } catch (_) {
      return null;
    }
  }
}

String readingJournalRecordId(ReadingRecord record) =>
    '${record.createdAt.toUtc().toIso8601String()}|${record.kind.name}';

class ReadingJournalStore {
  ReadingJournalStore({
    SharedPreferences? preferences,
    void Function()? onNewReadingSaved,
  }) : _providedPreferences = preferences,
       _onNewReadingSaved =
           onNewReadingSaved ??
           AdRevenueService.instance.recordCompletedReading;

  static const primaryKey = 'reading_journal_v1';
  static const backupKey = 'reading_journal_v1_backup';
  static const legacyKey = 'journal_records';

  final SharedPreferences? _providedPreferences;
  final void Function() _onNewReadingSaved;

  Future<SharedPreferences> _preferences() async =>
      _providedPreferences ?? SharedPreferences.getInstance();

  Future<ReadingJournalLoadResult> load({
    Iterable<String> legacyRecords = const <String>[],
  }) async {
    final preferences = await _preferences();
    final primaryPayload = preferences.getString(primaryKey);
    final backupPayload = preferences.getString(backupKey);

    ReadingJournalDecodeReport? primary;
    ReadingJournalDecodeReport? backup;

    if (primaryPayload != null && primaryPayload.trim().isNotEmpty) {
      try {
        primary = ReadingJournalCodec.decode(primaryPayload);
      } catch (_) {
        primary = null;
      }
    }
    if (backupPayload != null && backupPayload.trim().isNotEmpty) {
      try {
        backup = ReadingJournalCodec.decode(backupPayload);
      } catch (_) {
        backup = null;
      }
    }

    if (primary != null) {
      final primaryIsTrustworthy =
          primary.records.isNotEmpty || primary.rejectedItems == 0;
      if (primaryIsTrustworthy) {
        final recovered = primary.rejectedItems > 0 && backup != null;
        final records = recovered
            ? _mergePrimaryAndBackup(primary.records, backup.records)
            : primary.records;
        return ReadingJournalLoadResult(
          records: records,
          recoveredFromBackup: recovered,
          migratedFromLegacy: false,
          rejectedItems:
              primary.rejectedItems + (recovered ? backup.rejectedItems : 0),
        );
      }
    }

    if (backup != null &&
        (backup.records.isNotEmpty || backup.rejectedItems == 0)) {
      return ReadingJournalLoadResult(
        records: backup.records,
        recoveredFromBackup: true,
        migratedFromLegacy: false,
        rejectedItems: (primary?.rejectedItems ?? 0) + backup.rejectedItems,
      );
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

  List<ReadingRecord> _mergePrimaryAndBackup(
    Iterable<ReadingRecord> primary,
    Iterable<ReadingRecord> backup,
  ) {
    final result = <ReadingRecord>[];
    final seen = <String>{};
    for (final record in <ReadingRecord>[...primary, ...backup]) {
      if (seen.add(readingJournalRecordId(record))) result.add(record);
    }
    result.sort((first, second) => second.createdAt.compareTo(first.createdAt));
    return List<ReadingRecord>.unmodifiable(result);
  }

  Future<void> save(Iterable<ReadingRecord> records) async {
    final preferences = await _preferences();
    final nextPayload = ReadingJournalCodec.encode(records);
    final currentPayload = preferences.getString(primaryKey);
    final previousCount = _validRecordCount(currentPayload);
    final nextCount = _validRecordCount(nextPayload);

    if (currentPayload != null &&
        currentPayload.trim().isNotEmpty &&
        _isTrustworthyPayload(currentPayload)) {
      final backupSaved = await preferences.setString(
        backupKey,
        currentPayload,
      );
      if (!backupSaved) {
        throw StateError('Could not preserve the previous journal snapshot.');
      }
    }

    final primarySaved = await preferences.setString(primaryKey, nextPayload);
    if (!primarySaved) {
      throw StateError('Could not save the reading journal.');
    }

    if (nextCount == previousCount + 1) {
      _onNewReadingSaved();
    }
  }

  int _validRecordCount(String? payload) {
    if (payload == null || payload.trim().isEmpty) return 0;
    try {
      return ReadingJournalCodec.decode(payload).records.length;
    } catch (_) {
      return 0;
    }
  }

  bool _isTrustworthyPayload(String payload) {
    try {
      final report = ReadingJournalCodec.decode(payload);
      return report.records.isNotEmpty || report.rejectedItems == 0;
    } catch (_) {
      return false;
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

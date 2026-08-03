import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'mystic_mirror.dart';
import 'oracle_conversation.dart';
import 'reading_journal_store.dart';

class JournalTransferBundle {
  const JournalTransferBundle({
    required this.records,
    required this.reflections,
    required this.oracleTurns,
    required this.rejectedItems,
  });

  final List<ReadingRecord> records;
  final Map<String, MysticMirrorReflection> reflections;
  final List<OracleConversationTurn> oracleTurns;
  final int rejectedItems;
}

class JournalTransferImportResult {
  const JournalTransferImportResult({
    required this.records,
    required this.addedReadings,
    required this.restoredMirrors,
    required this.addedOracleTurns,
    required this.rejectedItems,
  });

  final List<ReadingRecord> records;
  final int addedReadings;
  final int restoredMirrors;
  final int addedOracleTurns;
  final int rejectedItems;
}

class JournalTransferCodec {
  const JournalTransferCodec._();

  static const schemaVersion = 1;
  static const marker = 'MYSTIC-TAROT-JOURNAL-V1';

  static String encode({
    required Iterable<ReadingRecord> records,
    Iterable<MysticMirrorReflection> reflections =
        const <MysticMirrorReflection>[],
    Iterable<OracleConversationTurn> oracleTurns =
        const <OracleConversationTurn>[],
  }) {
    final recordList = records.toList(growable: false);
    if (recordList.isEmpty) {
      throw StateError('A journal transfer requires at least one reading.');
    }
    final recordIds = recordList.map(readingJournalRecordId).toSet();
    final validReflections = reflections
        .where((item) => recordIds.contains(item.recordId))
        .toList(growable: false)
      ..sort((first, second) =>
          second.completedAt.compareTo(first.completedAt));
    final validTurns = oracleTurns
        .where((item) => recordIds.contains(item.recordId))
        .toList(growable: false)
      ..sort((first, second) => first.createdAt.compareTo(second.createdAt));
    final envelope = jsonEncode(<String, Object>{
      'schemaVersion': schemaVersion,
      'product': 'Mystic Tarot',
      'kind': 'private-journal-transfer',
      'journal': ReadingJournalCodec.encode(recordList),
      'mirror':
          validReflections.map((item) => item.encode()).toList(growable: false),
      'oracle': validTurns.map((item) => item.encode()).toList(growable: false),
    });
    return '$marker\n${base64Url.encode(utf8.encode(envelope))}';
  }

  static JournalTransferBundle decode(String value) {
    final trimmed = value.trim();
    final separator = trimmed.indexOf(RegExp(r'\s'));
    if (separator <= 0 || trimmed.substring(0, separator) != marker) {
      throw const FormatException('Not a Mystic Tarot journal transfer code.');
    }
    final encodedEnvelope = trimmed.substring(separator).trim();
    if (encodedEnvelope.isEmpty || encodedEnvelope.contains(RegExp(r'\s'))) {
      throw const FormatException('Journal transfer code is incomplete.');
    }

    final envelopeText = utf8.decode(
      base64Url.decode(base64Url.normalize(encodedEnvelope)),
    );
    final envelope = jsonDecode(envelopeText);
    if (envelope is! Map<String, dynamic> ||
        envelope['schemaVersion'] != schemaVersion ||
        envelope['product'] != 'Mystic Tarot' ||
        envelope['kind'] != 'private-journal-transfer' ||
        envelope['journal'] is! String ||
        envelope['mirror'] is! List<dynamic> ||
        envelope['oracle'] is! List<dynamic>) {
      throw const FormatException('Unsupported journal transfer envelope.');
    }

    final journal = ReadingJournalCodec.decode(envelope['journal'] as String);
    if (journal.records.isEmpty) {
      throw const FormatException('Journal transfer contains no valid readings.');
    }
    final validRecordIds = journal.records.map(readingJournalRecordId).toSet();
    final reflections = <String, MysticMirrorReflection>{};
    final oracleTurns = <String, OracleConversationTurn>{};
    var rejected = journal.rejectedItems;

    for (final raw in envelope['mirror'] as List<dynamic>) {
      if (raw is! String) {
        rejected++;
        continue;
      }
      final reflection = MysticMirrorReflection.tryDecode(raw);
      if (reflection == null || !validRecordIds.contains(reflection.recordId)) {
        rejected++;
        continue;
      }
      final existing = reflections[reflection.recordId];
      if (existing == null ||
          reflection.completedAt.isAfter(existing.completedAt)) {
        reflections[reflection.recordId] = reflection;
      } else {
        rejected++;
      }
    }

    for (final raw in envelope['oracle'] as List<dynamic>) {
      if (raw is! String) {
        rejected++;
        continue;
      }
      final turn = OracleConversationTurn.tryDecode(raw);
      if (turn == null || !validRecordIds.contains(turn.recordId)) {
        rejected++;
        continue;
      }
      final existing = oracleTurns[turn.turnId];
      if (existing == null || turn.createdAt.isAfter(existing.createdAt)) {
        oracleTurns[turn.turnId] = turn;
      } else {
        rejected++;
      }
    }

    final orderedTurns = oracleTurns.values.toList()
      ..sort((first, second) => first.createdAt.compareTo(second.createdAt));
    return JournalTransferBundle(
      records: List<ReadingRecord>.unmodifiable(journal.records),
      reflections:
          Map<String, MysticMirrorReflection>.unmodifiable(reflections),
      oracleTurns: List<OracleConversationTurn>.unmodifiable(orderedTurns),
      rejectedItems: rejected,
    );
  }
}

class JournalTransferService {
  JournalTransferService({SharedPreferences? preferences})
      : _providedPreferences = preferences,
        _journalStore = ReadingJournalStore(preferences: preferences),
        _mirrorStore = MysticMirrorStore(preferences: preferences),
        _oracleStore = OracleConversationStore(preferences: preferences);

  final SharedPreferences? _providedPreferences;
  final ReadingJournalStore _journalStore;
  final MysticMirrorStore _mirrorStore;
  final OracleConversationStore _oracleStore;

  Future<SharedPreferences> _preferences() async =>
      _providedPreferences ?? SharedPreferences.getInstance();

  Future<String> createTransferCode() async {
    final journal = await _journalStore.load();
    final reflections = await _mirrorStore.load();
    final oracleTurns = await _oracleStore.loadAll();
    return JournalTransferCodec.encode(
      records: journal.records,
      reflections: reflections.values,
      oracleTurns: oracleTurns,
    );
  }

  JournalTransferBundle preview(String code) => JournalTransferCodec.decode(code);

  Future<JournalTransferImportResult> importCode(String code) async {
    final incoming = JournalTransferCodec.decode(code);
    final currentJournal = await _journalStore.load();
    final currentReflections = await _mirrorStore.load();
    final currentOracleTurns = await _oracleStore.loadAll();

    final recordsById = <String, ReadingRecord>{
      for (final record in currentJournal.records)
        readingJournalRecordId(record): record,
    };
    var addedReadings = 0;
    for (final record in incoming.records) {
      final recordId = readingJournalRecordId(record);
      if (recordsById.containsKey(recordId)) continue;
      recordsById[recordId] = record;
      addedReadings++;
    }
    final mergedRecords = recordsById.values.toList()
      ..sort((first, second) => second.createdAt.compareTo(first.createdAt));

    final mergedReflections = <String, MysticMirrorReflection>{
      ...currentReflections,
    };
    var restoredMirrors = 0;
    for (final entry in incoming.reflections.entries) {
      final existing = mergedReflections[entry.key];
      if (existing != null &&
          !entry.value.completedAt.isAfter(existing.completedAt)) {
        continue;
      }
      mergedReflections[entry.key] = entry.value;
      restoredMirrors++;
    }

    final mergedOracleTurns = <String, OracleConversationTurn>{
      for (final turn in currentOracleTurns) turn.turnId: turn,
    };
    var addedOracleTurns = 0;
    for (final turn in incoming.oracleTurns) {
      if (mergedOracleTurns.containsKey(turn.turnId)) continue;
      mergedOracleTurns[turn.turnId] = turn;
      addedOracleTurns++;
    }

    final orderedReflections = mergedReflections.values.toList()
      ..sort((first, second) =>
          second.completedAt.compareTo(first.completedAt));
    final orderedOracleTurns = mergedOracleTurns.values.toList()
      ..sort((first, second) => first.createdAt.compareTo(second.createdAt));
    final preferences = await _preferences();
    final snapshot = _TransferPreferenceSnapshot.capture(preferences);

    try {
      await _requireSaved(
        preferences.setString(
          ReadingJournalStore.backupKey,
          ReadingJournalCodec.encode(currentJournal.records),
        ),
        'Could not preserve the previous journal snapshot.',
      );
      await _requireSaved(
        preferences.setStringList(
          MysticMirrorStore.backupKey,
          currentReflections.values.map((item) => item.encode()).toList(),
        ),
        'Could not preserve the previous Mirror snapshot.',
      );
      await _requireSaved(
        preferences.setStringList(
          OracleConversationStore.backupKey,
          currentOracleTurns.map((item) => item.encode()).toList(),
        ),
        'Could not preserve the previous Oracle snapshot.',
      );
      await _requireSaved(
        preferences.setString(
          ReadingJournalStore.primaryKey,
          ReadingJournalCodec.encode(mergedRecords),
        ),
        'Could not restore the reading journal.',
      );
      await _requireSaved(
        preferences.setStringList(
          MysticMirrorStore.storageKey,
          orderedReflections.map((item) => item.encode()).toList(),
        ),
        'Could not restore Mystic Mirror history.',
      );
      await _requireSaved(
        preferences.setStringList(
          OracleConversationStore.storageKey,
          orderedOracleTurns.map((item) => item.encode()).toList(),
        ),
        'Could not restore Oracle conversations.',
      );
    } catch (error, stackTrace) {
      await snapshot.restore(preferences);
      Error.throwWithStackTrace(error, stackTrace);
    }

    return JournalTransferImportResult(
      records: List<ReadingRecord>.unmodifiable(mergedRecords),
      addedReadings: addedReadings,
      restoredMirrors: restoredMirrors,
      addedOracleTurns: addedOracleTurns,
      rejectedItems: incoming.rejectedItems,
    );
  }

  Future<void> _requireSaved(Future<bool> operation, String message) async {
    if (!await operation) throw StateError(message);
  }
}

class _TransferPreferenceSnapshot {
  _TransferPreferenceSnapshot(this.values);

  static const keys = <String>[
    ReadingJournalStore.primaryKey,
    ReadingJournalStore.backupKey,
    MysticMirrorStore.storageKey,
    MysticMirrorStore.backupKey,
    OracleConversationStore.storageKey,
    OracleConversationStore.backupKey,
  ];

  final Map<String, Object?> values;

  factory _TransferPreferenceSnapshot.capture(SharedPreferences preferences) {
    final values = <String, Object?>{};
    for (final key in keys) {
      final value = preferences.get(key);
      values[key] = value is List<String> ? List<String>.from(value) : value;
    }
    return _TransferPreferenceSnapshot(values);
  }

  Future<void> restore(SharedPreferences preferences) async {
    for (final key in keys) {
      final value = values[key];
      if (value == null) {
        await preferences.remove(key);
      } else if (value is String) {
        await preferences.setString(key, value);
      } else if (value is List<String>) {
        await preferences.setStringList(key, value);
      }
    }
  }
}

import 'dart:convert';

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

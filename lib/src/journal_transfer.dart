import 'dart:convert';

import 'models.dart';
import 'mystic_mirror.dart';
import 'oracle_conversation.dart';
import 'reading_journal_store.dart';

class JournalTransferResult {
  const JournalTransferResult({
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
    final envelope = jsonEncode(<String, Object>{
      'schemaVersion': schemaVersion,
      'product': 'Mystic Tarot',
      'kind': 'private-journal-transfer',
      'journal': ReadingJournalCodec.encode(records),
      'mirror': reflections.map((item) => item.encode()).toList(growable: false),
      'oracle': oracleTurns.map((item) => item.encode()).toList(growable: false),
    });
    return '$marker\n${base64Url.encode(utf8.encode(envelope))}';
  }

  static JournalTransferResult decode(String value) {
    final trimmed = value.trim();
    final lines = trimmed.split(RegExp(r'\s+'));
    if (lines.length != 2 || lines.first != marker) {
      throw const FormatException('Not a Mystic Tarot journal transfer code.');
    }

    final envelopeText = utf8.decode(
      base64Url.decode(base64Url.normalize(lines[1])),
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

    final validRecordIds = journal.records
        .map(readingJournalRecordId)
        .toSet();
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
    return JournalTransferResult(
      records: journal.records,
      reflections: Map<String, MysticMirrorReflection>.unmodifiable(reflections),
      oracleTurns: List<OracleConversationTurn>.unmodifiable(orderedTurns),
      rejectedItems: rejected,
    );
  }
}

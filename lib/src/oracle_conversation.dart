import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

String oracleConversationRecordId(ReadingRecord record) =>
    '${record.createdAt.toUtc().toIso8601String()}|${record.kind.name}';

class OracleConversationTurn {
  const OracleConversationTurn({
    required this.turnId,
    required this.recordId,
    required this.question,
    required this.answer,
    required this.createdAt,
  });

  final String turnId;
  final String recordId;
  final String question;
  final String answer;
  final DateTime createdAt;

  factory OracleConversationTurn.create({
    required ReadingRecord record,
    required String question,
    required String answer,
    DateTime? createdAt,
  }) {
    final moment = (createdAt ?? DateTime.now()).toUtc();
    final recordId = oracleConversationRecordId(record);
    return OracleConversationTurn(
      turnId: '$recordId|${moment.toIso8601String()}',
      recordId: recordId,
      question: _trimTo(question.trim(), 160),
      answer: _trimTo(answer.trim(), 4000),
      createdAt: moment,
    );
  }

  Map<String, Object> toJson() => <String, Object>{
    'turnId': turnId,
    'recordId': recordId,
    'question': question,
    'answer': answer,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  String encode() => jsonEncode(toJson());

  static OracleConversationTurn? tryDecode(String encoded) {
    try {
      final data = jsonDecode(encoded);
      if (data is! Map<String, dynamic>) return null;
      final turnId = data['turnId'];
      final recordId = data['recordId'];
      final question = data['question'];
      final answer = data['answer'];
      final createdAt = data['createdAt'];
      if (turnId is! String || turnId.isEmpty) return null;
      if (recordId is! String || recordId.isEmpty) return null;
      if (question is! String || question.trim().isEmpty) return null;
      if (answer is! String || answer.trim().isEmpty) return null;
      if (createdAt is! String) return null;
      final parsed = DateTime.parse(createdAt).toUtc();
      return OracleConversationTurn(
        turnId: turnId,
        recordId: recordId,
        question: _trimTo(question.trim(), 160),
        answer: _trimTo(answer.trim(), 4000),
        createdAt: parsed,
      );
    } catch (_) {
      return null;
    }
  }

  static String _trimTo(String value, int maxLength) =>
      value.length <= maxLength ? value : value.substring(0, maxLength);
}

class _OracleDecodeReport {
  const _OracleDecodeReport({
    required this.turns,
    required this.rejectedItems,
    required this.sourceItems,
  });

  final Map<String, OracleConversationTurn> turns;
  final int rejectedItems;
  final int sourceItems;
}

class OracleConversationStore {
  OracleConversationStore({SharedPreferences? preferences})
    : _providedPreferences = preferences;

  static const storageKey = 'oracle_conversations_v1';
  static const backupKey = 'oracle_conversations_v1_backup';

  final SharedPreferences? _providedPreferences;

  Future<SharedPreferences> _preferences() async =>
      _providedPreferences ?? SharedPreferences.getInstance();

  _OracleDecodeReport _decode(Iterable<String> encodedItems) {
    final source = encodedItems.toList(growable: false);
    final turns = <String, OracleConversationTurn>{};
    var rejected = 0;
    for (final encoded in source) {
      final turn = OracleConversationTurn.tryDecode(encoded);
      if (turn == null) {
        rejected++;
        continue;
      }
      final existing = turns[turn.turnId];
      if (existing == null ||
          turn.createdAt.isAfter(existing.createdAt) ||
          turn.createdAt.isAtSameMomentAs(existing.createdAt)) {
        turns[turn.turnId] = turn;
      }
    }
    return _OracleDecodeReport(
      turns: turns,
      rejectedItems: rejected,
      sourceItems: source.length,
    );
  }

  Map<String, OracleConversationTurn> _merge(
    Map<String, OracleConversationTurn> primary,
    Map<String, OracleConversationTurn> backup,
  ) {
    final merged = <String, OracleConversationTurn>{...backup};
    for (final entry in primary.entries) {
      final existing = merged[entry.key];
      if (existing == null ||
          entry.value.createdAt.isAfter(existing.createdAt) ||
          entry.value.createdAt.isAtSameMomentAs(existing.createdAt)) {
        merged[entry.key] = entry.value;
      }
    }
    return merged;
  }

  Future<List<OracleConversationTurn>> loadAll() async {
    final preferences = await _preferences();
    final primaryItems = preferences.getStringList(storageKey);
    final backupItems = preferences.getStringList(backupKey);
    final primary = primaryItems == null ? null : _decode(primaryItems);
    final backup = backupItems == null ? null : _decode(backupItems);

    Map<String, OracleConversationTurn> result;
    if (primary != null && primary.sourceItems == 0) {
      result = const <String, OracleConversationTurn>{};
    } else if (primary != null && primary.turns.isNotEmpty) {
      result = primary.rejectedItems > 0 && backup != null
          ? _merge(primary.turns, backup.turns)
          : primary.turns;
    } else if (backup != null) {
      result = backup.turns;
    } else {
      result = const <String, OracleConversationTurn>{};
    }

    final ordered = result.values.toList()
      ..sort((first, second) => first.createdAt.compareTo(second.createdAt));
    return List<OracleConversationTurn>.unmodifiable(ordered);
  }

  Future<List<OracleConversationTurn>> loadForRecord(
    ReadingRecord record,
  ) async {
    final recordId = oracleConversationRecordId(record);
    final turns = await loadAll();
    return List<OracleConversationTurn>.unmodifiable(
      turns.where((turn) => turn.recordId == recordId),
    );
  }

  Future<Map<String, List<OracleConversationTurn>>> loadGrouped() async {
    final grouped = <String, List<OracleConversationTurn>>{};
    for (final turn in await loadAll()) {
      grouped
          .putIfAbsent(turn.recordId, () => <OracleConversationTurn>[])
          .add(turn);
    }
    return Map<String, List<OracleConversationTurn>>.unmodifiable(
      grouped.map(
        (key, value) =>
            MapEntry(key, List<OracleConversationTurn>.unmodifiable(value)),
      ),
    );
  }

  Future<void> saveTurn(OracleConversationTurn turn) async {
    if (turn.question.trim().isEmpty || turn.answer.trim().isEmpty) {
      throw ArgumentError(
        'Oracle turns require both a question and an answer.',
      );
    }
    final preferences = await _preferences();
    final current = <String, OracleConversationTurn>{
      for (final existing in await loadAll()) existing.turnId: existing,
    };
    current[turn.turnId] = turn;
    final ordered = current.values.toList()
      ..sort((first, second) => first.createdAt.compareTo(second.createdAt));

    final currentPrimary = preferences.getStringList(storageKey);
    final primaryIsFullyValid =
        currentPrimary != null &&
        currentPrimary.isNotEmpty &&
        currentPrimary.every(
          (encoded) => OracleConversationTurn.tryDecode(encoded) != null,
        );
    if (primaryIsFullyValid) {
      final backupSaved = await preferences.setStringList(
        backupKey,
        currentPrimary,
      );
      if (!backupSaved) {
        throw StateError('Could not preserve the previous Oracle snapshot.');
      }
    }

    final saved = await preferences.setStringList(
      storageKey,
      ordered.map((item) => item.encode()).toList(growable: false),
    );
    if (!saved) {
      throw StateError('Could not save the Oracle conversation.');
    }
  }

  Future<void> clear() async {
    final preferences = await _preferences();
    await Future.wait(<Future<bool>>[
      preferences.remove(storageKey),
      preferences.remove(backupKey),
    ]);
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

enum MysticMirrorOutcome { shifted, partlyShifted, unchanged, unclear }

class MysticMirrorReflection {
  const MysticMirrorReflection({
    required this.recordId,
    required this.outcome,
    required this.emotion,
    required this.note,
    required this.completedAt,
  });

  final String recordId;
  final MysticMirrorOutcome outcome;
  final EmotionalState emotion;
  final String note;
  final DateTime completedAt;

  Map<String, Object> toJson() => <String, Object>{
        'recordId': recordId,
        'outcome': outcome.name,
        'emotion': emotion.name,
        'note': note,
        'completedAt': completedAt.toUtc().toIso8601String(),
      };

  static MysticMirrorReflection? tryDecode(String encoded) {
    try {
      final data = jsonDecode(encoded);
      if (data is! Map<String, dynamic>) return null;

      final recordId = data['recordId'];
      final outcome = data['outcome'];
      final emotion = data['emotion'];
      final note = data['note'];
      final completedAt = data['completedAt'];
      if (recordId is! String || recordId.isEmpty) return null;
      if (outcome is! String || emotion is! String) return null;
      if (note is! String || completedAt is! String) return null;

      return MysticMirrorReflection(
        recordId: recordId,
        outcome: MysticMirrorOutcome.values.byName(outcome),
        emotion: EmotionalState.values.byName(emotion),
        note: note.length > 500 ? note.substring(0, 500) : note,
        completedAt: DateTime.parse(completedAt).toUtc(),
      );
    } catch (_) {
      return null;
    }
  }

  String encode() => jsonEncode(toJson());
}

String mysticMirrorRecordId(ReadingRecord record) =>
    '${record.createdAt.toUtc().toIso8601String()}|${record.kind.name}';

bool mysticMirrorIsDue(
  ReadingRecord record,
  DateTime now, {
  Set<String> completedRecordIds = const <String>{},
}) {
  final recordId = mysticMirrorRecordId(record);
  return !completedRecordIds.contains(recordId) &&
      !now.isBefore(record.mirrorCheckInAt);
}

class MysticMirrorStore {
  MysticMirrorStore({SharedPreferences? preferences})
      : _providedPreferences = preferences;

  static const storageKey = 'mystic_mirror_reflections_v1';
  final SharedPreferences? _providedPreferences;

  Future<SharedPreferences> _preferences() async =>
      _providedPreferences ?? SharedPreferences.getInstance();

  Future<Map<String, MysticMirrorReflection>> load() async {
    final preferences = await _preferences();
    final result = <String, MysticMirrorReflection>{};
    for (final encoded
        in preferences.getStringList(storageKey) ?? const <String>[]) {
      final reflection = MysticMirrorReflection.tryDecode(encoded);
      if (reflection == null) continue;
      final existing = result[reflection.recordId];
      if (existing == null ||
          reflection.completedAt.isAfter(existing.completedAt)) {
        result[reflection.recordId] = reflection;
      }
    }
    return Map<String, MysticMirrorReflection>.unmodifiable(result);
  }

  Future<void> save(MysticMirrorReflection reflection) async {
    final preferences = await _preferences();
    final current = Map<String, MysticMirrorReflection>.from(await load());
    current[reflection.recordId] = reflection;
    final ordered = current.values.toList()
      ..sort((first, second) =>
          second.completedAt.compareTo(first.completedAt));
    await preferences.setStringList(
      storageKey,
      ordered.map((item) => item.encode()).toList(growable: false),
    );
  }

  Future<void> clear() async {
    final preferences = await _preferences();
    await preferences.remove(storageKey);
  }
}

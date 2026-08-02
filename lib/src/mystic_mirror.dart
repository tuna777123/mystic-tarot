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

class _MirrorDecodeReport {
  const _MirrorDecodeReport({
    required this.reflections,
    required this.rejectedItems,
    required this.sourceItems,
  });

  final Map<String, MysticMirrorReflection> reflections;
  final int rejectedItems;
  final int sourceItems;
}

class MysticMirrorStore {
  MysticMirrorStore({SharedPreferences? preferences})
      : _providedPreferences = preferences;

  static const storageKey = 'mystic_mirror_reflections_v1';
  static const backupKey = 'mystic_mirror_reflections_v1_backup';
  final SharedPreferences? _providedPreferences;

  Future<SharedPreferences> _preferences() async =>
      _providedPreferences ?? SharedPreferences.getInstance();

  _MirrorDecodeReport _decode(Iterable<String> encodedItems) {
    final source = encodedItems.toList(growable: false);
    final result = <String, MysticMirrorReflection>{};
    var rejected = 0;
    for (final encoded in source) {
      final reflection = MysticMirrorReflection.tryDecode(encoded);
      if (reflection == null) {
        rejected++;
        continue;
      }
      final existing = result[reflection.recordId];
      if (existing == null ||
          reflection.completedAt.isAfter(existing.completedAt)) {
        result[reflection.recordId] = reflection;
      }
    }
    return _MirrorDecodeReport(
      reflections: result,
      rejectedItems: rejected,
      sourceItems: source.length,
    );
  }

  Map<String, MysticMirrorReflection> _merge(
    Map<String, MysticMirrorReflection> primary,
    Map<String, MysticMirrorReflection> backup,
  ) {
    final merged = <String, MysticMirrorReflection>{...backup};
    for (final entry in primary.entries) {
      final existing = merged[entry.key];
      if (existing == null ||
          entry.value.completedAt.isAfter(existing.completedAt) ||
          entry.value.completedAt.isAtSameMomentAs(existing.completedAt)) {
        merged[entry.key] = entry.value;
      }
    }
    return merged;
  }

  Future<Map<String, MysticMirrorReflection>> load() async {
    final preferences = await _preferences();
    final primaryItems = preferences.getStringList(storageKey);
    final backupItems = preferences.getStringList(backupKey);
    final primary = primaryItems == null ? null : _decode(primaryItems);
    final backup = backupItems == null ? null : _decode(backupItems);

    if (primary != null && primary.sourceItems == 0) {
      return const <String, MysticMirrorReflection>{};
    }

    if (primary != null && primary.reflections.isNotEmpty) {
      final recovered = primary.rejectedItems > 0 && backup != null;
      final result = recovered
          ? _merge(primary.reflections, backup.reflections)
          : primary.reflections;
      return Map<String, MysticMirrorReflection>.unmodifiable(result);
    }

    if (backup != null) {
      return Map<String, MysticMirrorReflection>.unmodifiable(
        backup.reflections,
      );
    }

    return const <String, MysticMirrorReflection>{};
  }

  Future<void> save(MysticMirrorReflection reflection) async {
    final preferences = await _preferences();
    final current = Map<String, MysticMirrorReflection>.from(await load());
    current[reflection.recordId] = reflection;
    final ordered = current.values.toList()
      ..sort(
        (first, second) => second.completedAt.compareTo(first.completedAt),
      );

    final currentPrimary = preferences.getStringList(storageKey);
    final primaryIsFullyValid = currentPrimary != null &&
        currentPrimary.isNotEmpty &&
        currentPrimary.every(
          (encoded) => MysticMirrorReflection.tryDecode(encoded) != null,
        );
    if (primaryIsFullyValid) {
      final backupSaved =
          await preferences.setStringList(backupKey, currentPrimary);
      if (!backupSaved) {
        throw StateError('Could not preserve the previous Mirror snapshot.');
      }
    }

    final primarySaved = await preferences.setStringList(
      storageKey,
      ordered.map((item) => item.encode()).toList(growable: false),
    );
    if (!primarySaved) {
      throw StateError('Could not save the Mystic Mirror reflection.');
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

import 'package:shared_preferences/shared_preferences.dart';

import 'business_metrics.dart';
import 'models.dart';
import 'mystic_mirror.dart';

/// Emits exactly one aggregate denominator event when a reading's 72-hour
/// Mystic Mirror completion window has fully matured.
///
/// The local dedupe key uses the existing reading record id and never leaves
/// the device. It is not included in the Growth Evidence export or business
/// metric dimensions.
class MysticMirrorGrowthTracker {
  MysticMirrorGrowthTracker({SharedPreferences? preferences})
    : _providedPreferences = preferences;

  static final MysticMirrorGrowthTracker instance = MysticMirrorGrowthTracker();

  static const processedKey = 'mystic_mirror_matured_metric_ids_v1';
  static const completionWindow = Duration(hours: 72);

  final SharedPreferences? _providedPreferences;
  Future<void> _queue = Future<void>.value();

  Future<SharedPreferences> _preferences() async =>
      _providedPreferences ?? SharedPreferences.getInstance();

  Future<void> sync({
    required Iterable<ReadingRecord> records,
    required String languageCode,
    DateTime? now,
  }) {
    final observedAt = now ?? DateTime.now();
    final next = _queue.then<void>((_) async {
      final preferences = await _preferences();
      final processed = (preferences.getStringList(processedKey) ?? const <String>[])
          .toSet();
      var changed = false;

      final ordered = records.toList(growable: false)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      for (final record in ordered) {
        final maturesAt = record.createdAt.add(completionWindow);
        if (observedAt.isBefore(maturesAt)) continue;

        final recordId = mysticMirrorRecordId(record);
        if (processed.contains(recordId)) continue;

        final accepted = await MysticBusinessMetrics.tryRecord(
          MysticBusinessEvent.mirrorWindowMatured,
          dimensions: <String, String>{
            'language': languageCode,
            'reading_kind': record.kind.name,
            'source': 'mirror_window',
          },
        );
        if (!accepted) continue;

        processed.add(recordId);
        changed = true;
      }

      if (!changed) return;
      final orderedIds = processed.toList()..sort();
      final saved = await preferences.setStringList(processedKey, orderedIds);
      if (!saved) {
        // The event reporter already accepted the aggregate count, so failing to
        // persist dedupe would risk a duplicate on the next sync. Throw here so
        // debug/QA can surface the storage failure instead of silently claiming
        // exact-once evidence.
        throw StateError('Could not persist mature Mirror metric dedupe state.');
      }
    });
    _queue = next.catchError((_) {});
    return next;
  }

  Future<void> clear() async {
    final next = _queue.then<void>((_) async {
      final preferences = await _preferences();
      await preferences.remove(processedKey);
    });
    _queue = next.catchError((_) {});
    await next;
  }
}

import 'package:flutter/foundation.dart';

import 'business_metrics.dart';
import 'growth_measurement_baseline.dart';
import 'local_growth_ledger.dart';
import 'models.dart';
import 'mystic_mirror.dart';

/// Emits one aggregate outcome when a reading's 72-hour Mystic Mirror window
/// has fully matured.
///
/// Numerator and denominator are produced at the same maturity boundary:
/// every mature reading emits `mirrorWindowMatured`, classified as either
/// `completed_within_72h` or `not_completed_within_72h`.
///
/// Readings created before this installation's measurement baseline are ignored
/// so an app upgrade cannot backfill legacy journal history into a new launch
/// cohort. The baseline and dedupe token remain local-only and never appear in
/// exported Growth Evidence.
class MysticMirrorGrowthTracker {
  MysticMirrorGrowthTracker({
    MysticLocalGrowthLedger? ledger,
    MysticGrowthMeasurementBaseline? baseline,
  }) : _ledger = ledger ?? MysticLocalGrowthLedger.instance,
       _baseline = baseline ?? MysticGrowthMeasurementBaseline.instance;

  static final MysticMirrorGrowthTracker instance = MysticMirrorGrowthTracker();

  static const completionWindow = Duration(hours: 72);

  final MysticLocalGrowthLedger _ledger;
  final MysticGrowthMeasurementBaseline _baseline;
  Future<void> _queue = Future<void>.value();

  Future<void> sync({
    required Iterable<ReadingRecord> records,
    required Map<String, MysticMirrorReflection> reflections,
    required String languageCode,
    DateTime? now,
  }) {
    final observedAt = now ?? DateTime.now();
    final next = _queue.then<void>((_) async {
      final measurementStartedAt = await _baseline.ensureStarted();
      final ordered = records.toList(growable: false)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (final record in ordered) {
        if (record.createdAt.toUtc().isBefore(measurementStartedAt)) continue;

        final maturesAt = record.createdAt.add(completionWindow);
        if (observedAt.isBefore(maturesAt)) continue;

        final recordId = mysticMirrorRecordId(record);
        final reflection = reflections[recordId];
        final completedWithinWindow =
            reflection != null &&
            !reflection.completedAt.toLocal().isAfter(maturesAt);
        final growthStage = completedWithinWindow
            ? 'completed_within_72h'
            : 'not_completed_within_72h';

        await _ledger.recordOnce(
          MysticBusinessEvent.mirrorWindowMatured,
          dedupeToken: 'mirror-window:$recordId',
          dimensions: <String, String>{
            'language': languageCode,
            'reading_kind': record.kind.name,
            'growth_stage': growthStage,
            'source': 'mirror_window',
          },
        );
      }
    });

    // Growth evidence is observability, not a product dependency. Storage
    // failure must not interrupt readings, Mirror, navigation or ads.
    _queue = next.catchError((error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Mystic mature Mirror evidence sync failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    });
    return _queue;
  }
}

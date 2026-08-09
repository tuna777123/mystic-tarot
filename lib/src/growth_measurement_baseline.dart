import 'package:shared_preferences/shared_preferences.dart';

/// Private, local-only boundary for the beginning of a measurable product
/// cohort on this installation.
///
/// Existing journal history from before measurement starts must never be
/// backfilled into launch retention or the mature 72-hour Mystic Mirror KPI.
/// This timestamp is intentionally not part of exported Growth Evidence.
class MysticGrowthMeasurementBaseline {
  MysticGrowthMeasurementBaseline({
    SharedPreferences? preferences,
    DateTime Function()? now,
  }) : _providedPreferences = preferences,
       _now = now ?? DateTime.now;

  static final MysticGrowthMeasurementBaseline instance =
      MysticGrowthMeasurementBaseline();

  static const storageKey = 'mystic_growth_measurement_started_at_utc_v1';

  final SharedPreferences? _providedPreferences;
  final DateTime Function() _now;
  Future<DateTime>? _starting;

  Future<SharedPreferences> _preferences() async =>
      _providedPreferences ?? SharedPreferences.getInstance();

  Future<DateTime> ensureStarted() {
    final current = _starting;
    if (current != null) return current;
    final next = _ensureStarted();
    _starting = next;
    return next;
  }

  Future<DateTime> _ensureStarted() async {
    final preferences = await _preferences();
    final storedMillis = preferences.getInt(storageKey);
    if (storedMillis != null) {
      return DateTime.fromMillisecondsSinceEpoch(storedMillis, isUtc: true);
    }

    final startedAt = _now().toUtc();
    final saved = await preferences.setInt(
      storageKey,
      startedAt.millisecondsSinceEpoch,
    );
    if (!saved) {
      throw StateError('Could not persist the growth measurement baseline.');
    }
    return startedAt;
  }

  Future<DateTime?> read() async {
    final preferences = await _preferences();
    final storedMillis = preferences.getInt(storageKey);
    if (storedMillis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(storedMillis, isUtc: true);
  }

  Future<void> clear() async {
    final preferences = await _preferences();
    final removed = await preferences.remove(storageKey);
    if (!removed && preferences.containsKey(storageKey)) {
      throw StateError('Could not delete the growth measurement baseline.');
    }
    _starting = null;
  }
}

import 'package:shared_preferences/shared_preferences.dart';

import 'mystic_journey.dart';
import 'mystic_journey_codec.dart';

class JourneyLoadResult {
  const JourneyLoadResult({
    required this.journeys,
    required this.recoveredFromBackup,
    required this.rejectedItems,
  });

  final List<MysticJourney> journeys;
  final bool recoveredFromBackup;
  final int rejectedItems;
}

abstract interface class MysticJourneyStore {
  Future<JourneyLoadResult> load();
  Future<void> save(Iterable<MysticJourney> journeys);
  Future<void> clear();
}

/// Local-first persistence with a last-known-good backup.
///
/// A failed or partially written primary payload never destroys the previous
/// readable snapshot. The caller can surface [recoveredFromBackup] to the user
/// without exposing implementation details.
class SharedPreferencesMysticJourneyStore implements MysticJourneyStore {
  SharedPreferencesMysticJourneyStore({SharedPreferences? preferences})
    : _preferences = preferences;

  static const primaryKey = 'mystic_journeys_v1';
  static const backupKey = 'mystic_journeys_v1_backup';

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    final injected = _preferences;
    if (injected != null) return injected;
    return SharedPreferences.getInstance();
  }

  @override
  Future<JourneyLoadResult> load() async {
    final preferences = await _prefs;
    final primary = preferences.getString(primaryKey);
    final backup = preferences.getString(backupKey);

    if (primary != null && primary.trim().isNotEmpty) {
      try {
        final report = MysticJourneyCodec.decode(primary);
        return JourneyLoadResult(
          journeys: report.journeys,
          recoveredFromBackup: false,
          rejectedItems: report.rejectedItems,
        );
      } on Object {
        // Continue to the backup snapshot below.
      }
    }

    if (backup != null && backup.trim().isNotEmpty) {
      try {
        final report = MysticJourneyCodec.decode(backup);
        return JourneyLoadResult(
          journeys: report.journeys,
          recoveredFromBackup: true,
          rejectedItems: report.rejectedItems,
        );
      } on Object {
        // Both snapshots are unreadable. Return a safe empty result.
      }
    }

    return const JourneyLoadResult(
      journeys: [],
      recoveredFromBackup: false,
      rejectedItems: 0,
    );
  }

  @override
  Future<void> save(Iterable<MysticJourney> journeys) async {
    final preferences = await _prefs;
    final nextPayload = MysticJourneyCodec.encode(journeys);
    final currentPayload = preferences.getString(primaryKey);

    if (currentPayload != null && currentPayload.trim().isNotEmpty) {
      final backupSaved = await preferences.setString(
        backupKey,
        currentPayload,
      );
      if (!backupSaved) {
        throw StateError('Could not preserve the previous journey snapshot.');
      }
    }

    final primarySaved = await preferences.setString(primaryKey, nextPayload);
    if (!primarySaved) {
      throw StateError('Could not save journeys.');
    }
  }

  @override
  Future<void> clear() async {
    final preferences = await _prefs;
    final primaryRemoved = await preferences.remove(primaryKey);
    final backupRemoved = await preferences.remove(backupKey);
    if (!primaryRemoved && preferences.containsKey(primaryKey)) {
      throw StateError('Could not clear journey data.');
    }
    if (!backupRemoved && preferences.containsKey(backupKey)) {
      throw StateError('Could not clear journey backup data.');
    }
  }
}

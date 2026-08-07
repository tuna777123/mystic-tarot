import 'package:shared_preferences/shared_preferences.dart';

import 'mystic_memory.dart';
import 'mystic_memory_codec.dart';

class MemoryLoadResult {
  const MemoryLoadResult({
    required this.events,
    required this.recoveredFromBackup,
    required this.rejectedItems,
  });

  final List<TimelineEvent> events;
  final bool recoveredFromBackup;
  final int rejectedItems;
}

abstract interface class MysticMemoryStore {
  Future<MemoryLoadResult> load();
  Future<void> save(Iterable<TimelineEvent> events);
  Future<void> clear();
}

/// Local-first persistence with a last-known-good backup snapshot.
class SharedPreferencesMysticMemoryStore implements MysticMemoryStore {
  SharedPreferencesMysticMemoryStore({SharedPreferences? preferences})
    : _preferences = preferences;

  static const primaryKey = 'mystic_memory_v1';
  static const backupKey = 'mystic_memory_v1_backup';

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    final injected = _preferences;
    if (injected != null) return injected;
    return SharedPreferences.getInstance();
  }

  @override
  Future<MemoryLoadResult> load() async {
    final preferences = await _prefs;
    final primary = preferences.getString(primaryKey);
    final backup = preferences.getString(backupKey);

    if (primary != null && primary.trim().isNotEmpty) {
      try {
        final report = MysticMemoryCodec.decode(primary);
        return MemoryLoadResult(
          events: report.events,
          recoveredFromBackup: false,
          rejectedItems: report.rejectedItems,
        );
      } on Object {
        // Continue to the last-known-good snapshot.
      }
    }

    if (backup != null && backup.trim().isNotEmpty) {
      try {
        final report = MysticMemoryCodec.decode(backup);
        return MemoryLoadResult(
          events: report.events,
          recoveredFromBackup: true,
          rejectedItems: report.rejectedItems,
        );
      } on Object {
        // Both snapshots are unreadable; return a safe empty result.
      }
    }

    return const MemoryLoadResult(
      events: <TimelineEvent>[],
      recoveredFromBackup: false,
      rejectedItems: 0,
    );
  }

  @override
  Future<void> save(Iterable<TimelineEvent> events) async {
    final preferences = await _prefs;
    final nextPayload = MysticMemoryCodec.encode(events);
    final currentPayload = preferences.getString(primaryKey);

    if (currentPayload != null && currentPayload.trim().isNotEmpty) {
      final backupSaved = await preferences.setString(
        backupKey,
        currentPayload,
      );
      if (!backupSaved) {
        throw StateError('Could not preserve the previous memory snapshot.');
      }
    }

    final primarySaved = await preferences.setString(primaryKey, nextPayload);
    if (!primarySaved) {
      throw StateError('Could not save the memory timeline.');
    }
  }

  @override
  Future<void> clear() async {
    final preferences = await _prefs;
    final primaryRemoved = await preferences.remove(primaryKey);
    final backupRemoved = await preferences.remove(backupKey);
    if (!primaryRemoved && preferences.containsKey(primaryKey)) {
      throw StateError('Could not clear memory data.');
    }
    if (!backupRemoved && preferences.containsKey(backupKey)) {
      throw StateError('Could not clear memory backup data.');
    }
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'business_metrics.dart';

/// Durable, aggregate-only product evidence for closed beta and launch QA.
///
/// No account ID, advertising ID, question, card, note, emotion, Mirror outcome,
/// user name, intention, journal content, search query or arbitrary free text is
/// exported here. The ledger keeps coarse event/day counts and already-validated
/// business dimensions only. Internal one-shot dedupe tokens never appear in an
/// exported snapshot.
class MysticLocalGrowthLedger {
  MysticLocalGrowthLedger({
    SharedPreferences? preferences,
    DateTime Function()? now,
  }) : _providedPreferences = preferences,
       _now = now ?? DateTime.now;

  static final MysticLocalGrowthLedger instance = MysticLocalGrowthLedger();

  static const storageKey = 'mystic_local_growth_ledger_v1';
  static const schemaVersion = 1;
  static const _maxRetainedDays = 120;
  static const _maxOneShotTokens = 10000;

  final SharedPreferences? _providedPreferences;
  final DateTime Function() _now;
  Future<void> _writeQueue = Future<void>.value();

  Future<SharedPreferences> _preferences() async =>
      _providedPreferences ?? SharedPreferences.getInstance();

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    final next = _writeQueue.then<void>((_) async {
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    _writeQueue = next.catchError((_) {});
    return completer.future;
  }

  Future<void> record(
    MysticBusinessEvent event,
    Map<String, String> dimensions,
  ) {
    final safeDimensions = MysticBusinessMetrics.validateDimensions(dimensions);
    return _enqueue<void>(() async {
      final preferences = await _preferences();
      final state = _decode(preferences.getString(storageKey));
      _applyEvent(state, event, safeDimensions, _dayKey(_now()));
      await _save(preferences, state);
    });
  }

  /// Atomically records an aggregate event and a local-only dedupe token.
  ///
  /// Returns `false` when [dedupeToken] was already accepted. The token is
  /// persisted in the same JSON payload as the event count so a successful
  /// write cannot leave the counter and dedupe state out of sync.
  Future<bool> recordOnce(
    MysticBusinessEvent event, {
    required String dedupeToken,
    Map<String, String> dimensions = const <String, String>{},
  }) {
    final token = dedupeToken.trim();
    if (token.isEmpty || token.length > 160) {
      throw ArgumentError.value(
        dedupeToken,
        'dedupeToken',
        'Local metric dedupe tokens must contain 1–160 characters.',
      );
    }
    final safeDimensions = MysticBusinessMetrics.validateDimensions(dimensions);
    return _enqueue<bool>(() async {
      final preferences = await _preferences();
      final state = _decode(preferences.getString(storageKey));
      if (state.oneShotTokens.contains(token)) return false;
      if (state.oneShotTokens.length >= _maxOneShotTokens) {
        throw StateError('Local growth metric dedupe capacity exceeded.');
      }

      _applyEvent(state, event, safeDimensions, _dayKey(_now()));
      state.oneShotTokens.add(token);
      await _save(preferences, state);
      return true;
    });
  }

  void _applyEvent(
    _GrowthLedgerState state,
    MysticBusinessEvent event,
    Map<String, String> safeDimensions,
    String day,
  ) {
    state.firstObservedDay ??= day;
    state.lastObservedDay = day;
    state.eventCounts.update(
      event.name,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
    final daily = state.dailyEventCounts.putIfAbsent(
      day,
      () => <String, int>{},
    );
    daily.update(event.name, (value) => value + 1, ifAbsent: () => 1);

    if (event == MysticBusinessEvent.appOpened) {
      state.firstOpenDay ??= day;
      state.activeDays.add(day);
    }
    if (event == MysticBusinessEvent.onboardingCompleted) {
      state.firstOnboardingDay ??= day;
    }
    if (event == MysticBusinessEvent.readingCompleted) {
      state.firstReadingDay ??= day;
    }
    if (event == MysticBusinessEvent.mirrorDueSeen) {
      state.firstMirrorDueDay ??= day;
    }
    if (event == MysticBusinessEvent.mirrorCompleted) {
      state.firstMirrorCompletedDay ??= day;
    }

    final dailyDimensions = state.dailyDimensionCounts.putIfAbsent(
      day,
      () => <String, int>{},
    );
    for (final entry in safeDimensions.entries) {
      final key = '${event.name}|${entry.key}|${entry.value}';
      state.dimensionCounts.update(
        key,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      dailyDimensions.update(key, (value) => value + 1, ifAbsent: () => 1);
    }

    _trimDailyHistory(state);
  }

  Future<void> _save(
    SharedPreferences preferences,
    _GrowthLedgerState state,
  ) async {
    final saved = await preferences.setString(
      storageKey,
      jsonEncode(state.toJson()),
    );
    if (!saved) {
      throw StateError('Could not persist the local growth ledger.');
    }
  }

  Future<MysticGrowthEvidenceSnapshot> snapshot() async {
    await _writeQueue;
    final preferences = await _preferences();
    final state = _decode(preferences.getString(storageKey));
    return MysticGrowthEvidenceSnapshot._(state);
  }

  Future<String> exportJson() async {
    final evidence = await snapshot();
    return const JsonEncoder.withIndent('  ').convert(evidence.toJson());
  }

  Future<void> clear() async {
    await _enqueue<void>(() async {
      final preferences = await _preferences();
      await preferences.remove(storageKey);
    });
  }

  static String _dayKey(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  static DateTime? _parseDay(String? value) {
    if (value == null || value.length != 10) return null;
    return DateTime.tryParse(value);
  }

  static int? _dayOffset(String? firstDay, String? candidateDay) {
    final first = _parseDay(firstDay);
    final candidate = _parseDay(candidateDay);
    if (first == null || candidate == null) return null;
    return candidate.difference(first).inDays;
  }

  void _trimDailyHistory(_GrowthLedgerState state) {
    if (state.dailyEventCounts.length <= _maxRetainedDays) return;
    final days = state.dailyEventCounts.keys.toList()..sort();
    final removeCount = days.length - _maxRetainedDays;
    for (final day in days.take(removeCount)) {
      state.dailyEventCounts.remove(day);
      state.dailyDimensionCounts.remove(day);
    }
  }

  _GrowthLedgerState _decode(String? payload) {
    if (payload == null || payload.trim().isEmpty) return _GrowthLedgerState();
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic> ||
          decoded['schemaVersion'] != schemaVersion) {
        return _GrowthLedgerState();
      }
      return _GrowthLedgerState.fromJson(decoded);
    } catch (_) {
      return _GrowthLedgerState();
    }
  }
}

class MysticGrowthEvidenceSnapshot {
  MysticGrowthEvidenceSnapshot._(_GrowthLedgerState state)
    : firstObservedDay = state.firstObservedDay,
      lastObservedDay = state.lastObservedDay,
      firstOpenDay = state.firstOpenDay,
      firstOnboardingDay = state.firstOnboardingDay,
      firstReadingDay = state.firstReadingDay,
      firstMirrorDueDay = state.firstMirrorDueDay,
      firstMirrorCompletedDay = state.firstMirrorCompletedDay,
      activeDays = List<String>.unmodifiable(state.activeDays.toList()..sort()),
      eventCounts = Map<String, int>.unmodifiable(state.eventCounts),
      dailyEventCounts = Map<String, Map<String, int>>.unmodifiable(
        state.dailyEventCounts.map(
          (day, counts) => MapEntry(day, Map<String, int>.unmodifiable(counts)),
        ),
      ),
      dimensionCounts = Map<String, int>.unmodifiable(state.dimensionCounts),
      dailyDimensionCounts = Map<String, Map<String, int>>.unmodifiable(
        state.dailyDimensionCounts.map(
          (day, counts) => MapEntry(day, Map<String, int>.unmodifiable(counts)),
        ),
      );

  final String? firstObservedDay;
  final String? lastObservedDay;
  final String? firstOpenDay;
  final String? firstOnboardingDay;
  final String? firstReadingDay;
  final String? firstMirrorDueDay;
  final String? firstMirrorCompletedDay;
  final List<String> activeDays;
  final Map<String, int> eventCounts;
  final Map<String, Map<String, int>> dailyEventCounts;
  final Map<String, int> dimensionCounts;
  final Map<String, Map<String, int>> dailyDimensionCounts;

  bool get reachedD1 => _activeOnOffset(1);
  bool get reachedD7 => _activeOnOffset(7);
  bool get reachedD30 => _activeOnOffset(30);

  int? get firstReadingDayOffset =>
      MysticLocalGrowthLedger._dayOffset(firstOpenDay, firstReadingDay);

  int? get firstMirrorDueDayOffset =>
      MysticLocalGrowthLedger._dayOffset(firstOpenDay, firstMirrorDueDay);

  int? get firstMirrorCompletedDayOffset =>
      MysticLocalGrowthLedger._dayOffset(firstOpenDay, firstMirrorCompletedDay);

  bool get firstMirrorCompletedWithinThreeCalendarDays {
    final due = MysticLocalGrowthLedger._parseDay(firstMirrorDueDay);
    final completed = MysticLocalGrowthLedger._parseDay(
      firstMirrorCompletedDay,
    );
    if (due == null || completed == null) return false;
    final offset = completed.difference(due).inDays;
    return offset >= 0 && offset <= 3;
  }

  bool _activeOnOffset(int offset) {
    final first = MysticLocalGrowthLedger._parseDay(firstOpenDay);
    if (first == null) return false;
    final target = first.add(Duration(days: offset));
    return activeDays.contains(MysticLocalGrowthLedger._dayKey(target));
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': MysticLocalGrowthLedger.schemaVersion,
    'privacyModel': 'aggregate-only-local-no-user-id',
    'firstObservedDay': firstObservedDay,
    'lastObservedDay': lastObservedDay,
    'firstOpenDay': firstOpenDay,
    'firstOnboardingDay': firstOnboardingDay,
    'firstReadingDay': firstReadingDay,
    'firstMirrorDueDay': firstMirrorDueDay,
    'firstMirrorCompletedDay': firstMirrorCompletedDay,
    'activeDays': activeDays,
    'retention': <String, bool>{
      'd1': reachedD1,
      'd7': reachedD7,
      'd30': reachedD30,
    },
    'firstReadingDayOffset': firstReadingDayOffset,
    'firstMirrorDueDayOffset': firstMirrorDueDayOffset,
    'firstMirrorCompletedDayOffset': firstMirrorCompletedDayOffset,
    'firstMirrorCompletedWithinThreeCalendarDays':
        firstMirrorCompletedWithinThreeCalendarDays,
    'eventCounts': eventCounts,
    'dailyEventCounts': dailyEventCounts,
    'dimensionCounts': dimensionCounts,
    'dailyDimensionCounts': dailyDimensionCounts,
  };
}

class _GrowthLedgerState {
  _GrowthLedgerState({
    this.firstObservedDay,
    this.lastObservedDay,
    this.firstOpenDay,
    this.firstOnboardingDay,
    this.firstReadingDay,
    this.firstMirrorDueDay,
    this.firstMirrorCompletedDay,
    Set<String>? activeDays,
    Map<String, int>? eventCounts,
    Map<String, Map<String, int>>? dailyEventCounts,
    Map<String, int>? dimensionCounts,
    Map<String, Map<String, int>>? dailyDimensionCounts,
    Set<String>? oneShotTokens,
  }) : activeDays = activeDays ?? <String>{},
       eventCounts = eventCounts ?? <String, int>{},
       dailyEventCounts = dailyEventCounts ?? <String, Map<String, int>>{},
       dimensionCounts = dimensionCounts ?? <String, int>{},
       dailyDimensionCounts =
           dailyDimensionCounts ?? <String, Map<String, int>>{},
       oneShotTokens = oneShotTokens ?? <String>{};

  factory _GrowthLedgerState.fromJson(Map<String, dynamic> json) {
    final rawEventCounts = json['eventCounts'];
    final rawDaily = json['dailyEventCounts'];
    final rawDimensionCounts = json['dimensionCounts'];
    final rawDailyDimensions = json['dailyDimensionCounts'];
    return _GrowthLedgerState(
      firstObservedDay: json['firstObservedDay'] as String?,
      lastObservedDay: json['lastObservedDay'] as String?,
      firstOpenDay: json['firstOpenDay'] as String?,
      firstOnboardingDay: json['firstOnboardingDay'] as String?,
      firstReadingDay: json['firstReadingDay'] as String?,
      firstMirrorDueDay: json['firstMirrorDueDay'] as String?,
      firstMirrorCompletedDay: json['firstMirrorCompletedDay'] as String?,
      activeDays: (json['activeDays'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toSet(),
      eventCounts: rawEventCounts is Map<String, dynamic>
          ? rawEventCounts.map(
              (key, value) => MapEntry(key, value is num ? value.toInt() : 0),
            )
          : <String, int>{},
      dailyEventCounts: _decodeNestedCounts(rawDaily),
      dimensionCounts: rawDimensionCounts is Map<String, dynamic>
          ? rawDimensionCounts.map(
              (key, value) => MapEntry(key, value is num ? value.toInt() : 0),
            )
          : <String, int>{},
      dailyDimensionCounts: _decodeNestedCounts(rawDailyDimensions),
      oneShotTokens:
          (json['_oneShotTokens'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<String>()
              .toSet(),
    );
  }

  static Map<String, Map<String, int>> _decodeNestedCounts(Object? raw) {
    if (raw is! Map<String, dynamic>) return <String, Map<String, int>>{};
    return raw.map((day, value) {
      final counts = value is Map<String, dynamic>
          ? value.map(
              (key, count) => MapEntry(key, count is num ? count.toInt() : 0),
            )
          : <String, int>{};
      return MapEntry(day, counts);
    });
  }

  String? firstObservedDay;
  String? lastObservedDay;
  String? firstOpenDay;
  String? firstOnboardingDay;
  String? firstReadingDay;
  String? firstMirrorDueDay;
  String? firstMirrorCompletedDay;
  final Set<String> activeDays;
  final Map<String, int> eventCounts;
  final Map<String, Map<String, int>> dailyEventCounts;
  final Map<String, int> dimensionCounts;
  final Map<String, Map<String, int>> dailyDimensionCounts;
  final Set<String> oneShotTokens;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': MysticLocalGrowthLedger.schemaVersion,
    'firstObservedDay': firstObservedDay,
    'lastObservedDay': lastObservedDay,
    'firstOpenDay': firstOpenDay,
    'firstOnboardingDay': firstOnboardingDay,
    'firstReadingDay': firstReadingDay,
    'firstMirrorDueDay': firstMirrorDueDay,
    'firstMirrorCompletedDay': firstMirrorCompletedDay,
    'activeDays': activeDays.toList()..sort(),
    'eventCounts': eventCounts,
    'dailyEventCounts': dailyEventCounts,
    'dimensionCounts': dimensionCounts,
    'dailyDimensionCounts': dailyDimensionCounts,
    '_oneShotTokens': oneShotTokens.toList()..sort(),
  };
}

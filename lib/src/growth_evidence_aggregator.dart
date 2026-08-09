import 'dart:convert';

class MysticGrowthCohortReport {
  const MysticGrowthCohortReport({
    required this.asOf,
    required this.installs,
    required this.activatedInstalls,
    required this.d1Eligible,
    required this.d1Retained,
    required this.d7Eligible,
    required this.d7Retained,
    required this.d30Eligible,
    required this.d30Retained,
    required this.matureMirrorWindows,
    required this.matureMirrorsCompletedWithin72h,
    required this.mirrorCompletions,
    required this.mirrorSharesStarted,
    required this.adOpportunities,
    required this.adImpressions,
  });

  final DateTime asOf;
  final int installs;
  final int activatedInstalls;
  final int d1Eligible;
  final int d1Retained;
  final int d7Eligible;
  final int d7Retained;
  final int d30Eligible;
  final int d30Retained;
  final int matureMirrorWindows;
  final int matureMirrorsCompletedWithin72h;
  final int mirrorCompletions;
  final int mirrorSharesStarted;
  final int adOpportunities;
  final int adImpressions;

  double? get activationRate => _rate(activatedInstalls, installs);
  double? get d1Retention => _rate(d1Retained, d1Eligible);
  double? get d7Retention => _rate(d7Retained, d7Eligible);
  double? get d30Retention => _rate(d30Retained, d30Eligible);
  double? get matureMirrorCompletionWithin72h =>
      _rate(matureMirrorsCompletedWithin72h, matureMirrorWindows);
  double? get mirrorShareInitiationRate =>
      _rate(mirrorSharesStarted, mirrorCompletions);

  bool get retentionScaleGatePassed =>
      d7Retention != null && d7Retention! >= .15;

  bool get mirrorScaleGatePassed =>
      matureMirrorCompletionWithin72h != null &&
      matureMirrorCompletionWithin72h! >= .35;

  bool get productScaleGatePassed =>
      retentionScaleGatePassed && mirrorScaleGatePassed;

  Map<String, Object?> toJson() => <String, Object?>{
    'asOf': _dayKey(asOf),
    'installs': installs,
    'activation': <String, Object?>{
      'activated': activatedInstalls,
      'rate': activationRate,
    },
    'retention': <String, Object?>{
      'd1': _retentionJson(d1Eligible, d1Retained),
      'd7': _retentionJson(d7Eligible, d7Retained),
      'd30': _retentionJson(d30Eligible, d30Retained),
    },
    'mysticMirror72h': <String, Object?>{
      'matureWindows': matureMirrorWindows,
      'completedWithin72h': matureMirrorsCompletedWithin72h,
      'rate': matureMirrorCompletionWithin72h,
    },
    'distribution': <String, Object?>{
      'mirrorCompletions': mirrorCompletions,
      'mirrorSharesStarted': mirrorSharesStarted,
      'shareInitiationRate': mirrorShareInitiationRate,
    },
    'advertising': <String, int>{
      'opportunities': adOpportunities,
      'impressions': adImpressions,
    },
    'scaleGate': <String, bool>{
      'd7AtLeast15Percent': retentionScaleGatePassed,
      'matureMirror72hAtLeast35Percent': mirrorScaleGatePassed,
      'productGatePassed': productScaleGatePassed,
    },
  };

  String toMarkdown() {
    String rate(double? value) =>
        value == null ? '—' : '${(value * 100).toStringAsFixed(1)}%';
    return '''# Mystic Tarot Cohort Evidence

As of: `${_dayKey(asOf)}`
Evidence files: **$installs**

| KPI | Evidence | Rate |
|---|---:|---:|
| Activation: >=1 saved reading | $activatedInstalls/$installs | ${rate(activationRate)} |
| D1 retention | $d1Retained/$d1Eligible | ${rate(d1Retention)} |
| D7 retention | $d7Retained/$d7Eligible | ${rate(d7Retention)} |
| D30 retention | $d30Retained/$d30Eligible | ${rate(d30Retention)} |
| Mature Mirror completed within 72h | $matureMirrorsCompletedWithin72h/$matureMirrorWindows | ${rate(matureMirrorCompletionWithin72h)} |
| Mirror share initiation | $mirrorSharesStarted/$mirrorCompletions | ${rate(mirrorShareInitiationRate)} |
| Ad impressions | $adImpressions | — |

## Scale gate

- D7 >=15%: **${retentionScaleGatePassed ? 'PASS' : 'NOT PROVEN'}**
- Mature 72h Mirror completion >=35%: **${mirrorScaleGatePassed ? 'PASS' : 'NOT PROVEN'}**
- Product scale gate: **${productScaleGatePassed ? 'PASS' : 'DO NOT SCALE'}**

A missing/immature denominator is **not** treated as a pass.
''';
  }

  static double? _rate(int numerator, int denominator) =>
      denominator <= 0 ? null : numerator / denominator;

  static Map<String, Object?> _retentionJson(int eligible, int retained) =>
      <String, Object?>{
        'eligible': eligible,
        'retained': retained,
        'rate': _rate(retained, eligible),
      };

  static String _dayKey(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}

class MysticGrowthEvidenceAggregator {
  const MysticGrowthEvidenceAggregator();

  MysticGrowthCohortReport aggregateJson(
    Iterable<String> payloads, {
    required DateTime asOf,
  }) {
    final evidence = payloads.map(_decode).toList(growable: false);
    var activated = 0;
    var d1Eligible = 0;
    var d1Retained = 0;
    var d7Eligible = 0;
    var d7Retained = 0;
    var d30Eligible = 0;
    var d30Retained = 0;
    var matureMirrorWindows = 0;
    var matureMirrorWithin72 = 0;
    var mirrorCompletions = 0;
    var mirrorShares = 0;
    var adOpportunities = 0;
    var adImpressions = 0;

    for (final item in evidence) {
      final events = _intMap(item['eventCounts']);
      final dimensions = _intMap(item['dimensionCounts']);
      final retention = item['retention'];
      if ((events['readingCompleted'] ?? 0) > 0) activated++;

      final firstOpenDay = _parseDay(item['firstOpenDay']);
      if (firstOpenDay != null) {
        final age = _calendarAge(firstOpenDay, asOf);
        if (age >= 1) {
          d1Eligible++;
          if (_retained(retention, 'd1')) d1Retained++;
        }
        if (age >= 7) {
          d7Eligible++;
          if (_retained(retention, 'd7')) d7Retained++;
        }
        if (age >= 30) {
          d30Eligible++;
          if (_retained(retention, 'd30')) d30Retained++;
        }
      }

      matureMirrorWindows += events['mirrorWindowMatured'] ?? 0;
      matureMirrorWithin72 +=
          dimensions['mirrorWindowMatured|growth_stage|completed_within_72h'] ??
          0;
      mirrorCompletions += events['mirrorCompleted'] ?? 0;
      mirrorShares += events['mirrorShareStarted'] ?? 0;
      adOpportunities += events['adOpportunity'] ?? 0;
      adImpressions += events['adImpression'] ?? 0;
    }

    if (matureMirrorWithin72 > matureMirrorWindows) {
      throw const FormatException(
        'Mature Mirror numerator cannot exceed its denominator.',
      );
    }

    return MysticGrowthCohortReport(
      asOf: asOf,
      installs: evidence.length,
      activatedInstalls: activated,
      d1Eligible: d1Eligible,
      d1Retained: d1Retained,
      d7Eligible: d7Eligible,
      d7Retained: d7Retained,
      d30Eligible: d30Eligible,
      d30Retained: d30Retained,
      matureMirrorWindows: matureMirrorWindows,
      matureMirrorsCompletedWithin72h: matureMirrorWithin72,
      mirrorCompletions: mirrorCompletions,
      mirrorSharesStarted: mirrorShares,
      adOpportunities: adOpportunities,
      adImpressions: adImpressions,
    );
  }

  Map<String, dynamic> _decode(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Growth evidence root must be an object.');
    }
    if (decoded['schemaVersion'] != 1) {
      throw const FormatException('Unsupported growth evidence schema.');
    }
    if (decoded['privacyModel'] != 'aggregate-only-local-no-user-id') {
      throw const FormatException('Unexpected growth evidence privacy model.');
    }
    for (final forbidden in const <String>[
      'question',
      'note',
      'card',
      'userName',
      'intention',
      'journal',
      'emotion',
      'outcome',
      '_oneShotTokens',
    ]) {
      if (_containsKeyRecursive(decoded, forbidden)) {
        throw FormatException(
          'Private/internal field is not allowed in exported evidence: $forbidden',
        );
      }
    }
    return decoded;
  }

  bool _containsKeyRecursive(Object? value, String forbidden) {
    if (value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        if (entry.key.toLowerCase() == forbidden.toLowerCase()) return true;
        if (_containsKeyRecursive(entry.value, forbidden)) return true;
      }
    } else if (value is List<dynamic>) {
      return value.any((item) => _containsKeyRecursive(item, forbidden));
    }
    return false;
  }

  Map<String, int> _intMap(Object? value) {
    if (value is! Map<String, dynamic>) return <String, int>{};
    return value.map(
      (key, item) => MapEntry(key, item is num ? item.toInt() : 0),
    );
  }

  DateTime? _parseDay(Object? value) {
    if (value is! String || value.length != 10) return null;
    return DateTime.tryParse(value);
  }

  int _calendarAge(DateTime first, DateTime asOf) {
    final firstDay = DateTime(first.year, first.month, first.day);
    final asOfDay = DateTime(asOf.year, asOf.month, asOf.day);
    return asOfDay.difference(firstDay).inDays;
  }

  bool _retained(Object? retention, String key) =>
      retention is Map<String, dynamic> && retention[key] == true;
}

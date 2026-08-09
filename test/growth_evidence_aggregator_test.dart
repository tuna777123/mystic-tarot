import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/growth_evidence_aggregator.dart';

String _day(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

String evidence({
  required String firstOpen,
  required bool d1,
  required bool d7,
  required bool d30,
  int readings = 0,
  int matureWindows = 0,
  int completedWithin72 = 0,
  int mirrorCompletions = 0,
  int shares = 0,
  int adOpportunities = 0,
  int adImpressions = 0,
}) {
  final first = DateTime.parse(firstOpen);
  final activeDays = <String>{
    _day(first),
    if (d1) _day(first.add(const Duration(days: 1))),
    if (d7) _day(first.add(const Duration(days: 7))),
    if (d30) _day(first.add(const Duration(days: 30))),
  }.toList()
    ..sort();
  final notCompletedWithin72 = max(0, matureWindows - completedWithin72);
  return jsonEncode(<String, Object?>{
    'schemaVersion': 1,
    'privacyModel': 'aggregate-only-local-no-user-id',
    'firstOpenDay': firstOpen,
    'activeDays': activeDays,
    'retention': <String, bool>{'d1': d1, 'd7': d7, 'd30': d30},
    'eventCounts': <String, int>{
      'appOpened': activeDays.length,
      'readingCompleted': readings,
      'mirrorWindowMatured': matureWindows,
      'mirrorCompleted': mirrorCompletions,
      'mirrorShareStarted': shares,
      'adOpportunity': adOpportunities,
      'adImpression': adImpressions,
    },
    'dimensionCounts': <String, int>{
      'mirrorWindowMatured|growth_stage|completed_within_72h':
          completedWithin72,
      'mirrorWindowMatured|growth_stage|not_completed_within_72h':
          notCompletedWithin72,
    },
  });
}

void main() {
  const aggregator = MysticGrowthEvidenceAggregator();

  test('uses only mature retention denominators and exact Mirror windows', () {
    final report = aggregator.aggregateJson(<String>[
      evidence(
        firstOpen: '2026-07-01',
        d1: true,
        d7: true,
        d30: true,
        readings: 4,
        matureWindows: 3,
        completedWithin72: 2,
        mirrorCompletions: 3,
        shares: 1,
        adOpportunities: 2,
        adImpressions: 2,
      ),
      evidence(
        firstOpen: '2026-07-05',
        d1: true,
        d7: false,
        d30: false,
        readings: 2,
        matureWindows: 2,
        completedWithin72: 0,
        mirrorCompletions: 1,
      ),
      evidence(
        firstOpen: '2026-07-30',
        d1: true,
        d7: true,
        d30: false,
        readings: 1,
        matureWindows: 1,
        completedWithin72: 1,
      ),
      evidence(
        firstOpen: '2026-08-08',
        d1: false,
        d7: false,
        d30: false,
        readings: 0,
      ),
    ], asOf: DateTime(2026, 8, 9));

    expect(report.installs, 4);
    expect(report.activatedInstalls, 3);
    expect(report.activationRate, .75);
    expect(report.d1Eligible, 4);
    expect(report.d1Retained, 3);
    expect(report.d7Eligible, 3);
    expect(report.d7Retained, 2);
    expect(report.d30Eligible, 2);
    expect(report.d30Retained, 1);
    expect(report.matureMirrorWindows, 6);
    expect(report.matureMirrorsCompletedWithin72h, 3);
    expect(report.matureMirrorCompletionWithin72h, .5);
    expect(report.mirrorCompletions, 4);
    expect(report.mirrorSharesStarted, 1);
    expect(report.adImpressions, 2);
    expect(report.retentionScaleGatePassed, isTrue);
    expect(report.mirrorScaleGatePassed, isTrue);
    expect(report.productScaleGatePassed, isTrue);
    expect(report.toMarkdown(), contains('Product scale gate'));
  });

  test('missing mature denominator never passes the product gate', () {
    final report = aggregator.aggregateJson(<String>[
      evidence(
        firstOpen: '2026-08-08',
        d1: true,
        d7: false,
        d30: false,
        readings: 1,
      ),
    ], asOf: DateTime(2026, 8, 9));

    expect(report.d7Eligible, 0);
    expect(report.d7Retention, isNull);
    expect(report.matureMirrorCompletionWithin72h, isNull);
    expect(report.productScaleGatePassed, isFalse);
  });

  test('rejects internal or private fields in exported evidence', () {
    final payload = jsonEncode(<String, Object?>{
      'schemaVersion': 1,
      'privacyModel': 'aggregate-only-local-no-user-id',
      'firstOpenDay': '2026-08-01',
      'activeDays': <String>['2026-08-01'],
      'retention': <String, bool>{'d1': false, 'd7': false, 'd30': false},
      'eventCounts': <String, int>{'appOpened': 1},
      'dimensionCounts': <String, int>{},
      '_oneShotTokens': <String>['private-local-token'],
    });

    expect(
      () => aggregator.aggregateJson(<String>[
        payload,
      ], asOf: DateTime(2026, 8, 9)),
      throwsFormatException,
    );
  });

  test('rejects private or identity-like imported dimension keys', () {
    final payload = jsonEncode(<String, Object?>{
      'schemaVersion': 1,
      'privacyModel': 'aggregate-only-local-no-user-id',
      'firstOpenDay': '2026-08-01',
      'activeDays': <String>['2026-08-01', '2026-08-02', '2026-08-08'],
      'retention': <String, bool>{'d1': true, 'd7': true, 'd30': false},
      'eventCounts': <String, int>{'appOpened': 3, 'readingCompleted': 1},
      'dimensionCounts': <String, int>{
        'readingCompleted|device_id|abc': 1,
      },
    });

    expect(
      () => aggregator.aggregateJson(<String>[
        payload,
      ], asOf: DateTime(2026, 8, 9)),
      throwsFormatException,
    );
  });

  test('rejects private content disguised as an allowed dimension value', () {
    final payload = jsonEncode(<String, Object?>{
      'schemaVersion': 1,
      'privacyModel': 'aggregate-only-local-no-user-id',
      'firstOpenDay': '2026-08-01',
      'activeDays': <String>['2026-08-01'],
      'retention': <String, bool>{'d1': false, 'd7': false, 'd30': false},
      'eventCounts': <String, int>{'appOpened': 1, 'readingCompleted': 1},
      'dimensionCounts': <String, int>{
        'readingCompleted|source|my private question': 1,
      },
    });

    expect(
      () => aggregator.aggregateJson(<String>[
        payload,
      ], asOf: DateTime(2026, 8, 1)),
      throwsFormatException,
    );
  });

  test('rejects reported retention that disagrees with active days', () {
    final decoded = jsonDecode(
      evidence(
        firstOpen: '2026-08-01',
        d1: true,
        d7: false,
        d30: false,
      ),
    ) as Map<String, dynamic>;
    decoded['retention'] = <String, bool>{
      'd1': false,
      'd7': false,
      'd30': false,
    };

    expect(
      () => aggregator.aggregateJson(<String>[
        jsonEncode(decoded),
      ], asOf: DateTime(2026, 8, 9)),
      throwsFormatException,
    );
  });

  test('rejects incomplete mature Mirror classification evidence', () {
    final decoded = jsonDecode(
      evidence(
        firstOpen: '2026-07-01',
        d1: true,
        d7: true,
        d30: true,
        matureWindows: 2,
        completedWithin72: 1,
      ),
    ) as Map<String, dynamic>;
    decoded['dimensionCounts'] = <String, int>{
      'mirrorWindowMatured|growth_stage|completed_within_72h': 1,
    };

    expect(
      () => aggregator.aggregateJson(<String>[
        jsonEncode(decoded),
      ], asOf: DateTime(2026, 8, 9)),
      throwsFormatException,
    );
  });

  test('rejects impossible Mirror numerator', () {
    expect(
      () => aggregator.aggregateJson(<String>[
        evidence(
          firstOpen: '2026-07-01',
          d1: true,
          d7: true,
          d30: true,
          matureWindows: 1,
          completedWithin72: 2,
        ),
      ], asOf: DateTime(2026, 8, 9)),
      throwsFormatException,
    );
  });
}

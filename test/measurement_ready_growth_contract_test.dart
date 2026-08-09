import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('launch and foreground returns bootstrap active-day evidence', () {
    final main = File('lib/main.dart').readAsStringSync();
    final bootstrap = File(
      'lib/src/business_metrics_bootstrap.dart',
    ).readAsStringSync();

    expect(main, contains('MysticBusinessMetricsBootstrap.configure()'));
    expect(main, contains('MysticBusinessMetricsBootstrap.recordLaunch()'));
    expect(bootstrap, contains('MysticLocalGrowthLedger.instance.record'));
    expect(
      bootstrap,
      contains('MysticGrowthMeasurementBaseline.instance.ensureStarted()'),
    );
    expect(bootstrap, contains('WidgetsBinding.instance.addObserver'));
    expect(bootstrap, contains("source: 'foreground'"));
    expect(bootstrap, contains('AppLifecycleState.resumed'));
  });

  test('ad impressions use the Mobile Ads impression callback', () {
    final ads = File('lib/src/ad_revenue_service.dart').readAsStringSync();

    expect(ads, contains('MysticBusinessEvent.readingCompleted'));
    expect(ads, contains('MysticBusinessEvent.adOpportunity'));
    expect(ads, contains('MysticBusinessEvent.adImpression'));
    expect(ads, contains('onAdImpression: (_)'));
    expect(ads, contains("'ad_format': 'app_open'"));
    expect(ads, contains("'ad_format': 'interstitial'"));
  });

  test(
    'business metric boundary has no identity or private-content dimensions',
    () {
      final metrics = File('lib/src/business_metrics.dart').readAsStringSync();

      expect(metrics, contains('mirrorWindowMatured'));
      expect(metrics, contains('static const allowedValues'));
      for (final forbiddenAllowedKey in <String>[
        "'user_id'",
        "'device_id'",
        "'advertising_id'",
        "'question'",
        "'note'",
        "'card'",
        "'intention'",
        "'emotion'",
        "'outcome'",
      ]) {
        final allowedBlock = metrics.substring(
          metrics.indexOf('static const allowedDimensions'),
          metrics.indexOf('static const forbiddenDimensionFragments'),
        );
        expect(allowedBlock, isNot(contains(forbiddenAllowedKey)));
      }
    },
  );

  test('local ledger never exports internal dedupe tokens', () {
    final ledger = File('lib/src/local_growth_ledger.dart').readAsStringSync();
    final snapshotStart = ledger.indexOf('class MysticGrowthEvidenceSnapshot');
    final stateStart = ledger.indexOf('class _GrowthLedgerState');
    final exportedSnapshot = ledger.substring(snapshotStart, stateStart);

    expect(
      ledger,
      contains("'privacyModel': 'aggregate-only-local-no-user-id'"),
    );
    expect(ledger, contains('_oneShotTokens'));
    expect(exportedSnapshot, isNot(contains('_oneShotTokens')));
    expect(ledger, contains('Future<bool> recordOnce('));
  });

  test('measurement baseline excludes pre-instrumentation journal history', () {
    final baseline = File(
      'lib/src/growth_measurement_baseline.dart',
    ).readAsStringSync();
    final tracker = File(
      'lib/src/mirror_growth_tracker.dart',
    ).readAsStringSync();

    expect(baseline, contains("'mystic_growth_measurement_started_at_utc_v1'"));
    expect(baseline, contains('Future<DateTime> ensureStarted()'));
    expect(tracker, contains('measurementStartedAtUtc'));
    expect(tracker, contains('createdAtUtc.isBefore(measurementStartedAtUtc)'));
    expect(tracker, contains('record.createdAt.toUtc()'));
  });

  test('mature Mirror numerator and denominator share one atomic event', () {
    final tracker = File(
      'lib/src/mirror_growth_tracker.dart',
    ).readAsStringSync();

    expect(tracker, contains('MysticBusinessEvent.mirrorWindowMatured'));
    expect(tracker, contains("'completed_within_72h'"));
    expect(tracker, contains("'not_completed_within_72h'"));
    expect(tracker, contains('recordOnce('));
    expect(tracker, contains("dedupeToken: 'mirror-window:\$recordId'"));
  });

  test('diagnostic UI is hidden by default and aggregate-only', () {
    final screen = File(
      'lib/src/growth_evidence_screen.dart',
    ).readAsStringSync();
    final materializer = File(
      'tool/materialize_ad_only_ui.dart',
    ).readAsStringSync();

    expect(screen, contains("'MYSTIC_GROWTH_DIAGNOSTICS'"));
    expect(screen, contains('defaultValue: false'));
    expect(screen, contains('Aggregate-only'));
    expect(materializer, contains('mysticGrowthDiagnosticsEnabled'));
    expect(materializer, contains('MysticMirrorGrowthTracker.instance.sync('));
    expect(materializer, contains('MysticBusinessEvent.onboardingCompleted'));
    expect(materializer, contains('MysticBusinessEvent.mirrorDueSeen'));
  });

  test('cohort aggregator fails closed on immature or malformed evidence', () {
    final aggregator = File(
      'lib/src/growth_evidence_aggregator.dart',
    ).readAsStringSync();

    expect(
      aggregator,
      contains("privacyModel'] != 'aggregate-only-local-no-user-id'"),
    );
    expect(aggregator, contains('Mature Mirror numerator cannot exceed'));
    expect(aggregator, contains('_validateDimensionCountKeys'));
    expect(aggregator, contains('MysticBusinessMetrics.validateDimensions'));
    expect(aggregator, contains('Reported retention does not match'));
    expect(aggregator, contains('d7Eligible'));
    expect(aggregator, contains('productScaleGatePassed'));
    expect(aggregator, contains('DO NOT SCALE'));
  });
}

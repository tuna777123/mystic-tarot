import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('category leader v2 benchmark locks the evidence-first moat', () {
    final benchmark = File(
      'docs/CATEGORY_LEADER_V2_2026_08_31.md',
    ).readAsStringSync();

    expect(benchmark, contains('Reality Evidence, not prediction accuracy'));
    expect(
      benchmark,
      contains('Require at least three completed Mirror check-ins'),
    );
    expect(benchmark, contains('No account required for the private journal'));
    expect(benchmark, contains('Public web remains ad-free'));
  });

  test('production materializer replaces prediction-like Journal insights', () {
    final materializer = File(
      'tool/materialize_ad_only_ui.dart',
    ).readAsStringSync();

    expect(materializer, contains("import 'mystic_reality_evidence.dart';"));
    expect(materializer, contains('MysticRealityEvidence.analyze('));
    expect(materializer, contains('Reality outcomes · not a prediction score'));
    expect(materializer, contains('Evidence captured'));
    expect(
      materializer,
      contains("journalSource.contains('Movement noticed')"),
    );
    expect(materializer, contains("journalSource.contains('movementRate')"));
  });
}

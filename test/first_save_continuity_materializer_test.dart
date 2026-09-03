import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/materialize_first_save_continuity.dart';

void main() {
  test('first save hands off to grounded action and 24h Mirror', () {
    final source = File('lib/src/app.dart').readAsStringSync();
    final transformed = materializeFirstSaveContinuitySource(source);

    expect(transformed, contains('widget.pastRecords.isEmpty'));
    expect(transformed, contains('YOUR NEXT STEP IS TOMORROW'));
    expect(transformed, contains('SIRADAKİ ADIMIN YARIN'));
    expect(
      transformed,
      contains(
        'Your first reading is saved. Live the aligned action, then return in 24 hours to record what actually changed.',
      ),
    );
    expect(transformed, contains('else if (revealComplete && saved)'));
    expect(transformed, contains('Create a private story card'));
  });

  test('first-save continuity transform is idempotent', () {
    final source = File('lib/src/app.dart').readAsStringSync();
    final once = materializeFirstSaveContinuitySource(source);
    final twice = materializeFirstSaveContinuitySource(once);

    expect(twice, once);
  });

  test('store configuration applies first-save after result hierarchy', () {
    final source = File(
      'tool/configure_store_identifiers.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        "import 'materialize_first_save_continuity.dart' as first_save_continuity;",
      ),
    );
    final resultLoop = source.indexOf('result_core_loop.materializeResultCoreLoop();');
    final firstSave = source.indexOf(
      'first_save_continuity.materializeFirstSaveContinuity();',
    );
    expect(resultLoop, greaterThanOrEqualTo(0));
    expect(firstSave, greaterThan(resultLoop));
  });

  test('unexpected source fails closed', () {
    expect(
      () => materializeFirstSaveContinuitySource('no first-save anchors'),
      throwsStateError,
    );
  });
}

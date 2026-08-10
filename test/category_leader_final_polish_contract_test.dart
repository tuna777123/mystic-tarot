import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'reading keeps the grounded action visible before deeper explanation',
    () {
      final explanation = File(
        'lib/src/reading_explanation.dart',
      ).readAsStringSync();

      expect(explanation, contains("ValueKey('reading-practical-bridge')"));
      expect(explanation, contains('explanation.practicalBridge'));
      expect(explanation, contains('Icons.directions_walk_outlined'));
    },
  );

  test('Mystic Mirror reconnects the user with yesterday before check-in', () {
    final journal = File(
      'lib/src/mystic_living_journal_feature.dart',
    ).readAsStringSync();

    expect(journal, contains("YESTERDAY'S SIGNAL"));
    expect(journal, contains('ACTION YOU CHOSE'));
    expect(journal, contains('Record reality, not whether tarot was right.'));
    expect(journal, contains('_buildMirrorEvidenceContext(record)'));
  });
}

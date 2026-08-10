import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reading keeps the grounded action visible before details', () {
    final source = File('lib/src/reading_explanation.dart').readAsStringSync();

    expect(source, contains("ValueKey('reading-practical-bridge')"));
    expect(source, contains('explanation.practicalBridge'));
    expect(source, contains('Icons.directions_walk_outlined'));
  });

  test('Mirror check-in recalls yesterday before asking about reality', () {
    final source = File(
      'lib/src/mystic_living_journal_feature.dart',
    ).readAsStringSync();

    expect(source, contains("ValueKey('mirror-evidence-context')"));
    expect(source, contains("YESTERDAY'S SIGNAL"));
    expect(source, contains('ACTION YOU CHOSE'));
    expect(source, contains('Record reality, not whether tarot was right.'));
  });
}

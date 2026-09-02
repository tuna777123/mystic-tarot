import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/home_focus_policy.dart';

import '../tool/materialize_home_focus.dart';

void main() {
  group('HomeFocusPolicy', () {
    test('keeps the first reading loop focused', () {
      expect(
        HomeFocusPolicy.shouldFocus(readingCount: 0, mirrorDueCount: 0),
        isTrue,
      );
      expect(
        HomeFocusPolicy.shouldFocus(readingCount: 1, mirrorDueCount: 0),
        isTrue,
      );
    });

    test('returns discovery breadth after the second reading', () {
      expect(
        HomeFocusPolicy.shouldFocus(readingCount: 2, mirrorDueCount: 0),
        isFalse,
      );
      expect(
        HomeFocusPolicy.shouldFocus(readingCount: 20, mirrorDueCount: 0),
        isFalse,
      );
    });

    test('a due Mirror dominates Home regardless of reading history', () {
      expect(
        HomeFocusPolicy.shouldFocus(readingCount: 2, mirrorDueCount: 1),
        isTrue,
      );
      expect(
        HomeFocusPolicy.shouldFocus(readingCount: 50, mirrorDueCount: 3),
        isTrue,
      );
    });
  });

  test('production Home materializer keeps Next Step above discovery', () {
    final source = File('lib/src/app.dart').readAsStringSync();
    final transformed = materializeHomeFocusInSource(source);

    expect(transformed, contains("import 'home_focus_policy.dart';"));
    expect(transformed, contains('HomeFocusPolicy.shouldFocus('));
    expect(
      RegExp(r'if \(!homeFocusMode\)').allMatches(transformed).length,
      3,
    );

    final nextStepIndex = transformed.indexOf('MysticNextStepCard(');
    final firstGuardIndex = transformed.indexOf('if (!homeFocusMode)');
    final dailyIndex = transformed.indexOf('_DailyCard(');
    final questIndex = transformed.indexOf('_DailyQuest(');
    final moonIndex = transformed.indexOf('_MoonBriefing(');

    expect(nextStepIndex, greaterThanOrEqualTo(0));
    expect(firstGuardIndex, greaterThan(nextStepIndex));
    expect(dailyIndex, greaterThan(firstGuardIndex));
    expect(questIndex, greaterThan(firstGuardIndex));
    expect(moonIndex, greaterThan(firstGuardIndex));
    expect(materializeHomeFocusInSource(transformed), transformed);
  });

  test('store configuration always applies Home focus materialization', () {
    final source = File(
      'tool/configure_store_identifiers.dart',
    ).readAsStringSync();

    expect(
      source,
      contains("import 'materialize_home_focus.dart' as home_focus;"),
    );
    expect(source, contains('home_focus.materializeHomeFocus();'));
  });
}

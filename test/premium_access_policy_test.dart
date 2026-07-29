import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/premium_access_policy.dart';

void main() {
  group('free access', () {
    const policy = MysticPremiumAccessPolicy(isEntitled: false);

    test('keeps daily reading free', () {
      expect(
        policy.canStartReading(
          kind: ReadingKind.daily,
          deepReadingsToday: 99,
        ),
        isTrue,
      );
    });

    test('blocks premium spreads', () {
      expect(
        policy.readingBlockReason(
          kind: ReadingKind.celticCross,
          deepReadingsToday: 0,
        ),
        MysticPremiumBlockReason.premiumSpread,
      );
    });

    test('enforces deep reading limit', () {
      expect(
        policy.canStartReading(
          kind: ReadingKind.love,
          deepReadingsToday: 2,
        ),
        isTrue,
      );
      expect(
        policy.readingBlockReason(
          kind: ReadingKind.love,
          deepReadingsToday: 3,
        ),
        MysticPremiumBlockReason.dailyLimit,
      );
      expect(policy.remainingDeepReadings(4), 0);
    });

    test('blocks extended oracle dialogue', () {
      expect(policy.canContinueOracleDialogue(), isFalse);
    });
  });

  group('verified premium access', () {
    const policy = MysticPremiumAccessPolicy(isEntitled: true);

    test('unlocks all readings and removes limits', () {
      for (final kind in ReadingKind.values) {
        expect(
          policy.canStartReading(
            kind: kind,
            deepReadingsToday: 999,
          ),
          isTrue,
        );
      }
      expect(policy.remainingDeepReadings(999), isNull);
      expect(policy.canContinueOracleDialogue(), isTrue);
    });
  });
}

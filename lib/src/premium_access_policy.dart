import 'models.dart';

/// Centralized, side-effect-free premium gating rules.
///
/// UI and navigation layers should ask this policy whether a feature is
/// available instead of duplicating entitlement checks across screens.
final class MysticPremiumAccessPolicy {
  const MysticPremiumAccessPolicy({
    required this.isEntitled,
    this.freeDeepReadingLimit = 3,
  });

  final bool isEntitled;
  final int freeDeepReadingLimit;

  bool canStartReading({
    required ReadingKind kind,
    required int deepReadingsToday,
  }) {
    if (isEntitled) return true;
    if (_premiumReadingKinds.contains(kind)) return false;
    if (kind == ReadingKind.daily) return true;
    return deepReadingsToday < freeDeepReadingLimit;
  }

  bool canContinueOracleDialogue() => isEntitled;

  int? remainingDeepReadings(int deepReadingsToday) {
    if (isEntitled) return null;
    final remaining = freeDeepReadingLimit - deepReadingsToday;
    return remaining < 0 ? 0 : remaining;
  }

  MysticPremiumBlockReason? readingBlockReason({
    required ReadingKind kind,
    required int deepReadingsToday,
  }) {
    if (canStartReading(
      kind: kind,
      deepReadingsToday: deepReadingsToday,
    )) {
      return null;
    }
    if (_premiumReadingKinds.contains(kind)) {
      return MysticPremiumBlockReason.premiumSpread;
    }
    return MysticPremiumBlockReason.dailyLimit;
  }
}

enum MysticPremiumBlockReason {
  premiumSpread,
  dailyLimit,
  oracleDialogue,
}

const Set<ReadingKind> _premiumReadingKinds = {
  ReadingKind.compatibility,
  ReadingKind.timeline,
  ReadingKind.celticCross,
};

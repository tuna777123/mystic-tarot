abstract final class MysticProductIds {
  static const weekly = 'mystic_plus_weekly';
  static const monthly = 'mystic_plus_monthly';
  static const yearly = 'mystic_plus_yearly';

  /// Version 1 launches with monthly and yearly only. Weekly remains reserved
  /// for a future pricing experiment and must not block launch readiness.
  static const launch = <String>{monthly, yearly};
  static const all = <String>{weekly, monthly, yearly};
}

enum MysticPlan {
  monthly,
  yearly;

  String get productId => switch (this) {
    MysticPlan.monthly => MysticProductIds.monthly,
    MysticPlan.yearly => MysticProductIds.yearly,
  };

  bool get includesTrial => this == MysticPlan.yearly;
  int get trialDays => includesTrial ? 7 : 0;
}

enum PurchaseStatus {
  idle,
  loading,
  pending,
  purchased,
  restored,
  cancelled,
  failed,
  expired,
  refunded,
}

class MysticOffer {
  const MysticOffer({
    required this.plan,
    required this.title,
    required this.badge,
    required this.valueMessage,
  });

  final MysticPlan plan;
  final String title;
  final String badge;
  final String valueMessage;

  static const monthly = MysticOffer(
    plan: MysticPlan.monthly,
    title: 'Monthly',
    badge: 'FLEXIBLE',
    valueMessage: 'Unlimited readings and Oracle dialogue.',
  );

  static const yearly = MysticOffer(
    plan: MysticPlan.yearly,
    title: 'Yearly',
    badge: 'BEST VALUE',
    valueMessage: 'Seven-day trial, then one year of Mystic Plus.',
  );

  static const launchCatalog = <MysticOffer>[yearly, monthly];
}

class MysticEntitlement {
  const MysticEntitlement({
    required this.isPlus,
    this.plan,
    this.expiresAt,
    this.status = PurchaseStatus.idle,
  });

  const MysticEntitlement.free()
    : isPlus = false,
      plan = null,
      expiresAt = null,
      status = PurchaseStatus.idle;

  final bool isPlus;
  final MysticPlan? plan;
  final DateTime? expiresAt;
  final PurchaseStatus status;

  bool isActiveAt(DateTime now) {
    if (!isPlus) return false;
    if (status == PurchaseStatus.refunded ||
        status == PurchaseStatus.expired ||
        status == PurchaseStatus.failed ||
        status == PurchaseStatus.cancelled) {
      return false;
    }
    return expiresAt == null || expiresAt!.isAfter(now);
  }
}

enum PaywallSource {
  homeBadge,
  dailyLimit,
  premiumSpread,
  oracleDialogue,
  profile,
  organic,
}

class PaywallEvent {
  const PaywallEvent({
    required this.source,
    required this.openedAt,
    this.selectedPlan,
    this.purchaseStatus = PurchaseStatus.idle,
  });

  final PaywallSource source;
  final DateTime openedAt;
  final MysticPlan? selectedPlan;
  final PurchaseStatus purchaseStatus;
}

PaywallSource paywallSourceFromName(String source) => switch (source) {
  'daily_limit' => PaywallSource.dailyLimit,
  'premium_spread' => PaywallSource.premiumSpread,
  'oracle_dialogue' => PaywallSource.oracleDialogue,
  'profile' => PaywallSource.profile,
  'home_badge' => PaywallSource.homeBadge,
  _ => PaywallSource.organic,
};

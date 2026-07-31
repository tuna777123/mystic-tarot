import 'package:flutter/foundation.dart';

/// Compile-time subscription configuration.
///
/// RevenueCat public SDK keys are intentionally supplied with --dart-define.
/// They are safe to embed in the client, while RevenueCat secret keys must
/// never be added to the application or repository.
class SubscriptionEnvironment {
  const SubscriptionEnvironment({
    required this.supported,
    required this.apiKey,
    required this.entitlementId,
  });

  final bool supported;
  final String? apiKey;
  final String entitlementId;

  bool get configured => supported && apiKey != null && apiKey!.isNotEmpty;

  factory SubscriptionEnvironment.current() {
    const iosKey = String.fromEnvironment('REVENUECAT_IOS_API_KEY');
    const androidKey = String.fromEnvironment('REVENUECAT_ANDROID_API_KEY');
    const entitlement = String.fromEnvironment(
      'REVENUECAT_ENTITLEMENT_ID',
      defaultValue: 'mystic_plus',
    );

    if (kIsWeb) {
      return const SubscriptionEnvironment(
        supported: false,
        apiKey: null,
        entitlementId: entitlement,
      );
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => SubscriptionEnvironment(
          supported: true,
          apiKey: _cleanKey(iosKey),
          entitlementId: entitlement,
        ),
      TargetPlatform.android => SubscriptionEnvironment(
          supported: true,
          apiKey: _cleanKey(androidKey),
          entitlementId: entitlement,
        ),
      _ => const SubscriptionEnvironment(
          supported: false,
          apiKey: null,
          entitlementId: entitlement,
        ),
    };
  }

  static String? _cleanKey(String value) {
    final clean = value.trim();
    return clean.isEmpty ? null : clean;
  }
}

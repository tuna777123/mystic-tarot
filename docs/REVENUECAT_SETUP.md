# Mystic Tarot — RevenueCat production setup

Mystic Plus uses RevenueCat for server-side receipt validation and subscription entitlement tracking.

## Permanent identifiers

- Entitlement: `mystic_plus`
- Monthly product: `mystic_plus_monthly`
- Yearly product: `mystic_plus_yearly`
- Current offering: include both products
- iOS bundle ID: `com.tunabozcali.mystictarot`
- Android application ID: `com.tunabozcali.mystictarot`

Do not place RevenueCat secret API keys, App Store Connect keys, Google service-account JSON, signing passwords, or keystores in the repository.

## Dashboard sequence

1. Create the Mystic Tarot project in RevenueCat.
2. Add the Apple App Store app and Google Play app.
3. Connect App Store Connect and Google Play service credentials in RevenueCat.
4. Import `mystic_plus_monthly` and `mystic_plus_yearly` from both stores.
5. Create entitlement `mystic_plus` and attach all four store products.
6. Create a current offering containing monthly and yearly packages.
7. Copy the public iOS and Android SDK keys.
8. Build with the public keys supplied as compile-time definitions.

## Release build commands

```bash
flutter build appbundle --release \
  --dart-define=REVENUECAT_ANDROID_API_KEY=<public_android_sdk_key> \
  --dart-define=REVENUECAT_ENTITLEMENT_ID=mystic_plus
```

```bash
flutter build ipa --release \
  --dart-define=REVENUECAT_IOS_API_KEY=<public_ios_sdk_key> \
  --dart-define=REVENUECAT_ENTITLEMENT_ID=mystic_plus
```

The SDK keys above are public application keys. RevenueCat secret keys must never be passed with `--dart-define`.

## Required sandbox checks

Test each item on a real signed build before production rollout:

- monthly purchase;
- yearly purchase and trial eligibility;
- purchase cancellation;
- pending purchase;
- billing failure;
- restore on a clean install;
- renewal;
- expiration;
- refund/revocation;
- offline launch with a previously cached active entitlement;
- transition from active Plus back to free after revocation.

The app must unlock Plus only when RevenueCat reports the `mystic_plus` entitlement as active.

# Mystic Tarot — RevenueCat production setup

Mystic Plus uses RevenueCat for server-side receipt validation, trusted entitlement signatures, and subscription status tracking.

## Permanent identifiers

- Entitlement: `mystic_plus`
- Monthly product: `mystic_plus_monthly`
- Yearly product: `mystic_plus_yearly`
- Current offering: include both products
- iOS bundle ID: `com.tunabozcali.mystictarot`
- Android application ID: `com.tunabozcali.mystictarot`

Do not place RevenueCat secret API keys, App Store Connect keys, Google service-account JSON, signing passwords, certificates, provisioning profiles, or keystores in the repository.

## Dashboard sequence

1. Create the Mystic Tarot project in RevenueCat.
2. Add the Apple App Store app and Google Play app with the permanent identifiers.
3. Connect App Store Connect credentials and Google Play service credentials in RevenueCat.
4. Import `mystic_plus_monthly` and `mystic_plus_yearly` from both stores.
5. Create entitlement `mystic_plus` and attach all four store products.
6. Create a current offering containing monthly and yearly packages.
7. Confirm the yearly trial rule in both stores before advertising it.
8. Copy the public iOS and Android SDK keys into protected CI/release secrets.
9. Keep RevenueCat integrations with advertising or identity providers disabled unless the privacy policy and store disclosures are revised first.
10. Configure a monitored private support channel for billing and data-deletion requests.

## App security behavior

The app explicitly enables RevenueCat Trusted Entitlements in informational mode and grants Plus only when the verification result is `verified` or `verifiedOnDevice`.

The app fails closed when:

- the public SDK key is missing;
- monthly or yearly products are missing from the current offering;
- the `mystic_plus` entitlement is inactive;
- entitlement verification is `failed` or `notRequested`;
- a subscription expires, is refunded, or is revoked.

Automatic device-identifier collection and RevenueCat diagnostics are disabled in the client configuration.

## Protected release build commands

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

The values above are RevenueCat public application SDK keys. RevenueCat secret keys must never be passed with `--dart-define` or embedded in a client build.

## Required sandbox checks

Test each item on a real signed build before production rollout:

- monthly purchase;
- yearly purchase and trial eligibility;
- purchase cancellation;
- pending purchase;
- billing failure;
- restore on a clean install using the same store account;
- renewal;
- expiration;
- refund and revocation;
- offline launch with a previously verified cached entitlement;
- transition from active Plus back to free after revocation;
- failed trusted-entitlement verification does not unlock Plus;
- official localized prices appear for English and Turkish store regions;
- subscription management URL opens the correct store controls.

Use RevenueCat Test Store for early integration checks, then repeat the complete matrix with Apple Sandbox/TestFlight and a Google Play closed-testing track. Production rollout must not depend only on Test Store results.

## Store privacy forms

RevenueCat processes purchase history. The native paid build must not declare “Data Not Collected.” Follow the exact Apple App Privacy and Google Play Data Safety answers in `STORE_RELEASE.md`, then re-check them whenever an SDK or RevenueCat integration changes.

## Launch acceptance

The app may be submitted only after:

- both store apps and products are approved or ready for review;
- the RevenueCat offering returns both launch products;
- protected release keys and signing are configured;
- all sandbox lifecycle checks pass;
- a private support channel is monitored;
- privacy, terms, and support URLs are live and return HTTP 200.

# Mystic Tarot — Canonical Store Metadata Index

Use these files as the copy-ready store-listing source for release `1.23.0+33`:

- English: `docs/STORE_LISTING_EN.md`
- Turkish: `docs/STORE_LISTING_TR.md`
- Spanish: `docs/STORE_LISTING_ES.md`
- French: `docs/STORE_LISTING_FR.md`
- Brazilian Portuguese: `docs/STORE_LISTING_PT_BR.md`

`STORE_RELEASE.md` remains the broader release/operator runbook. The locale files above are the canonical copy source for localized App Store Connect and Google Play listing fields.

## Submission limits locked by CI

Current official store limits reviewed on 2026-08-11:

### Apple App Store Connect

- app name: 2–30 characters
- subtitle: up to 30 characters
- promotional text: up to 170 characters
- description: up to 4,000 characters
- keywords: up to 100 bytes

Official references:
- https://developer.apple.com/help/app-store-connect/reference/app-information/app-information
- https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information

### Google Play

- app name: up to 30 characters
- short description: up to 80 characters
- full description: up to 4,000 characters

Official reference:
- https://support.google.com/googleplay/android-developer/answer/9859152

`test/store_metadata_limits_test.dart` fails closed if any launch-language listing loses a required field, exceeds one of these limits, drops the `1.23.0` release-note marker, or reintroduces obsolete RevenueCat / Mystic Plus launch copy.

## Store-copy rules

- Keep claims reflection-first; do not promise factual prediction or professional advice.
- Do not reintroduce a paid subscription, paid pack, purchase, restore, or paid entitlement claim.
- Native Android/iOS advertising may be described accurately as Google Mobile Ads subject to applicable privacy choices.
- Public web remains ad-free.
- Do not invent prices, rankings, awards, download counts, ratings, or performance claims.
- Revalidate the store limits above against official Apple/Google documentation immediately before submission if the release is delayed materially.

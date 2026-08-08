# Mystic Tarot — Store Release Pack

Current source version: `1.23.0+33`  
Application / bundle ID: `com.tunabozcali.mystictarot`  
Launch languages: **EN, TR, ES, FR, PT-BR**

This is the canonical native-store operator handoff.

## Business model

Mystic Tarot is free and advertising-supported on native Android and iOS. There is **no paid subscription**, no paid reading pack, no paid unlock, no required account, and no purchase/restore requirement for product access.

RevenueCat and `purchases_flutter` are removed from the production dependency graph and runtime source. Small pure-Dart historical compatibility DTO/interface shapes may remain behind a disabled/no-op client, but there is no store SDK, checkout, restore, product sale or paid entitlement path.

The public web edition remains ad-free.

## Native advertising design

### App-open

Eligible only after at least three completed readings, after a returning foreground transition of at least 30 seconds, with a two-hour minimum interval between impressions. Cached app-open ads expire after four hours. Cold-start bootstrap never waits for an ad.

### Interstitial

An interstitial opportunity is created only after every third genuinely new saved reading at the natural completion boundary. The first two new readings remain uninterrupted. Cadence persists across process restarts. Missing/not-ready ads never block the product.

### Not used

- no permanent banner over the tarot interface;
- no rewarded-ad requirement for core functionality;
- no paid “remove ads” product;
- no AdMob integration on the public web edition.

## Permanent identifiers

- Android application ID: `com.tunabozcali.mystictarot`
- iOS bundle ID: `com.tunabozcali.mystictarot`
- iOS SKU: `mystic-tarot-ios-001`
- Version/build: `1.23.0+33`

Treat the bundle/application ID as permanent after first store upload.

## AdMob production values

Create/verify one Android app and one iOS app in the owner's AdMob account, each with App Open and Interstitial units.

Required protected values:

- `ADMOB_ANDROID_APP_ID`
- `ADMOB_IOS_APP_ID`
- `ADMOB_ANDROID_APP_OPEN_ID`
- `ADMOB_IOS_APP_OPEN_ID`
- `ADMOB_ANDROID_INTERSTITIAL_ID`
- `ADMOB_IOS_INTERSTITIAL_ID`

Production must use:

`MYSTIC_USE_TEST_ADS=false`

Ordinary CI/QA must continue to use Google's official demo IDs. Production preflight must reject demo app/ad-unit IDs.

## UMP privacy configuration

The native app refreshes Google UMP consent information at launch, can show a required privacy form, gates ad requests on `ConsentInformation.canRequestAds()`, and exposes privacy choices only when UMP reports they are required.

Before submission:

- configure and publish the intended AdMob Privacy & messaging messages;
- test consent-required and no-form-required states;
- verify privacy-options visibility;
- verify consent refresh/ad load failure does not block core use.

The current source does not add a custom iOS ATT request flow. If ATT/IDFA access is enabled later, add the required usage description, retest UMP ordering and revise App Privacy declarations before release.

## app-ads.txt + AdMob app readiness

Follow:

`docs/APP_ADS_TXT_GO_LIVE.md`

The current product site is a GitHub Pages project URL:

`https://tuna777123.github.io/mystic-tarot/`

AdMob derives `app-ads.txt` from the **developer-website hostname root**. If the store developer website uses `tuna777123.github.io`, the required crawl URL is:

`https://tuna777123.github.io/app-ads.txt`

Do not assume `https://tuna777123.github.io/mystic-tarot/app-ads.txt` is sufficient.

Use the personalized publisher line supplied by the owner's AdMob dashboard. Do not invent or placeholder a production publisher ID.

Do not describe real advertising monetization as fully live until the file is found/verified and AdMob app readiness reaches `Ready`, in addition to production IDs, UMP, signing and real-device QA.

## Android signing

Protected values:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_STORE_PASSWORD`
- `ANDROID_UPLOAD_CERT_SHA256`

Follow `docs/PRODUCTION_SIGNING_FINGERPRINTS.md`.

The production AAB must pass package/version/ABI checks, reviewed upload-certificate fingerprint verification, strict JAR signature policy, pinned `bundletool validate`, permission/SDK audit, Built-in Kotlin audit and checksum/release-manifest checks.

The ordinary CI AAB is a QA artifact and is **not** the owner-signed Google Play production candidate.

## iOS signing

Protected values:

- `IOS_DISTRIBUTION_CERTIFICATE_BASE64`
- `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`
- `IOS_DISTRIBUTION_CERT_SHA256`
- `IOS_PROVISIONING_PROFILE_BASE64`
- `IOS_TEAM_ID`

The signed IPA must verify final codesign, Team ID, bundle ID, provisioning application identifier, entitlements, distribution certificate fingerprint and checksum/release manifest.

Unsigned iOS CI proves source/build compatibility; it does not replace owner-controlled Apple distribution signing.

## App Store metadata

**Name**  
Mystic Tarot: Daily Ritual

**Subtitle**  
Tarot, Journal & Patterns

**Promotional text**  
Reveal the cards, return after 24 hours, and turn each reading into a private reflection that becomes more meaningful over time.

**Keywords**  
tarot,daily card,journal,oracle,reflection,spiritual,arcana,mindfulness,horoscope,self care

**Primary category:** Lifestyle  
**Secondary category:** Entertainment

**Privacy policy URL**  
https://tuna777123.github.io/mystic-tarot/privacy.html

**Support URL**  
https://tuna777123.github.io/mystic-tarot/support.html

**Marketing URL**  
https://tuna777123.github.io/mystic-tarot/

Localized metadata:

- `docs/STORE_LISTING_TR.md`
- `docs/STORE_LISTING_ES.md`
- `docs/STORE_LISTING_FR.md`
- `docs/STORE_LISTING_PT_BR.md`

## Google Play metadata

**App name**  
Mystic Tarot: Daily Ritual

**Short description**  
Private tarot readings, pattern memory, a journal, and a daily ritual.

**Core description**

Mystic Tarot turns a card reading into a private daily practice. Choose the cards that call to you, receive reflection-first guidance grounded in traditional symbolism, return after 24 hours for Mystic Mirror, and notice what repeats over time.

All readings, the Living Journal, Oracle dialogue, patterns, Mystic Path and the Arcana experience are available without a paid subscription. The native app is supported by occasional advertising.

Mystic Tarot is made for personal reflection and entertainment. It does not provide medical, mental-health, legal, financial, or emergency advice.

## Store screenshots

Canonical QA pack: **5 locales × 2 device profiles × 5 scenes = 50 screenshots**.

Suggested order:

1. Daily Guidance
2. Explainable Reading
3. Mystic Mirror
4. Living Path
5. Complete free experience / ad-supported disclosure

Do not show subscription prices, paid-plan CTAs or purchase language. Recapture from the signed candidate only if UI/store requirements change materially.

## App review facts

Mystic Tarot:

- does not require an account;
- stores journal/profile/progress primarily on-device;
- has no subscription or IAP revenue model;
- uses Google Mobile Ads for native advertising;
- uses Google UMP for applicable privacy choices;
- keeps the public web edition ad-free;
- provides local export/deletion controls;
- exposes Privacy Policy, Terms and Support;
- does not claim factual prediction or professional advice.

Suggested reviewer path:

1. Complete onboarding.
2. Open Daily Guidance and save a reading.
3. Open Path and Journal.
4. Open Profile → Privacy & data.
5. Confirm all functionality is usable without payment.
6. Confirm no checkout/restore requirement exists.
7. Exercise UMP in an applicable test state.
8. Confirm QA uses Google demo/test ads.
9. Complete three new readings and verify the natural interstitial opportunity.
10. Background for 30+ seconds after at least three readings and verify app-open cadence.
11. Repeat legal-link and narrow-screen checks in EN, TR, ES, FR and PT-BR.

## Store privacy declarations

Follow:

`docs/STORE_PRIVACY_DECLARATION_WORKSHEET.md`

Complete Apple App Privacy and Google Play Data Safety from the **exact signed native candidate**, including resolved Google Mobile Ads/UMP versions, Android manifest/permissions, iOS privacy manifest/report, ATT decision and real-device behavior.

Mystic's local-first journal design does not mean the advertising SDK processes no data.

Do not claim “Data Not Collected” or absence of advertising/device identifiers unless the exact final runtime and current store definitions genuinely support that answer.

## Physical-device production QA

Run on at least one current Android phone and one current iPhone.

Advertising/privacy checks:

- consent-required fresh install;
- no-form-required state;
- privacy-options visibility;
- no ad request before consent permits it;
- consent refresh failure;
- ad load failure;
- offline/poor network;
- readings #1/#2 uninterrupted;
- reading #3 interstitial opportunity;
- cadence after restart;
- no app-open on first cold start;
- no app-open before three readings;
- no app-open after background <30 seconds;
- two-hour app-open cap;
- no overlapping full-screen ads;
- immediate continuation after dismiss;
- no paywall/checkout/restore path.

Product checks:

- EN/TR/ES/FR/PT-BR first run and language persistence;
- Daily Guidance / deep readings;
- Mystic Mirror;
- Living Journal;
- Oracle;
- Mystic Path / Arcana;
- export/import/deletion/protected transfer;
- PIN / supported biometrics;
- notification allowed/denied states;
- Reduce Motion;
- narrow-screen / long-localization layouts;
- crash-free startup.

## Account-owned actions before production

Repository automation cannot complete these on the owner's behalf:

1. Apple Developer / App Store Connect ownership and agreements.
2. Google Play Console ownership and agreements.
3. Tax, banking and trader/business requirements.
4. AdMob Android/iOS app creation.
5. Production App Open + Interstitial units on both platforms.
6. UMP Privacy & messaging production configuration.
7. Root `app-ads.txt` hosting and verification.
8. AdMob app-readiness approval.
9. Six production AdMob IDs in protected release configuration.
10. `MYSTIC_USE_TEST_ADS=false`.
11. Android upload signing ownership.
12. Apple distribution certificate/provisioning ownership.
13. Production-signed AAB/IPA.
14. Real Android+iPhone advertising/privacy QA.
15. Apple App Privacy + Google Play Data Safety.
16. TestFlight / Play testing and Play pre-launch report.
17. Final store review/submission/approval.

If the Google Play account is a personal developer account subject to Google's new-account production-access testing gate, complete the required closed-test period shown by Play Console before Production access.

## Release gate

A native candidate is eligible for production submission only when:

- formatting, analysis and the complete test suite pass;
- web, Android and unsigned iOS release builds pass;
- production AdMob app/ad-unit IDs are configured;
- Google demo IDs are absent;
- `MYSTIC_USE_TEST_ADS=false`;
- UMP production behavior is configured and real-device tested;
- all product functionality remains available without purchase;
- Android signature/bundle/permission/SDK/Kotlin audits pass;
- iOS Team ID/provisioning/codesign/fingerprint checks pass;
- root app-ads.txt hosting is ready for store-linked verification;
- Privacy Policy, App Privacy and Data Safety match the signed runtime;
- real-device ad/no-ad/error paths pass;
- public legal/support/marketing URLs remain live;
- uploaded packages use permanent identifiers and owner-controlled signing.

## Go-live definition

Do **not** claim native App Store / Google Play availability or fully live advertising revenue until the stores approve the signed listings, production AdMob IDs are serving in the signed binaries, UMP is live, `app-ads.txt` is verified, AdMob app readiness is `Ready`, real-device QA passes and store privacy declarations match observed runtime behavior.

Repository CI proves source/build/audit behavior. It cannot replace account ownership, AdMob dashboard configuration, developer-website root hosting, native signing, physical-device ad delivery, store forms or store review.

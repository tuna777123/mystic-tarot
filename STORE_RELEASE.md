# Mystic Tarot — Store Release Pack

Current source version: `1.23.0+33`  
Application / bundle ID: `com.tunabozcali.mystictarot`  
Launch languages: **EN, TR, ES, FR, PT-BR**

This file is the canonical native-store operator handoff for Mystic Tarot.

## 1. Business model

Mystic Tarot is **free and advertising-supported** on native Android and iOS.

- No paid subscription.
- No paid reading pack.
- No paid feature unlock.
- No required account.
- No checkout or restore flow is required to access product functionality.
- Native revenue is designed to come from Google Mobile Ads.
- The public web edition remains ad-free.

RevenueCat and `purchases_flutter` are removed from the production dependency graph and runtime source. Small pure-Dart historical compatibility DTO/interface shapes may remain, backed by a disabled/no-op client with no store SDK, network purchase provider, checkout, restore, product sale or paid entitlement path.

## 2. Native ad design

### App-open

Eligible only when all required runtime guards pass, including:

- at least three completed readings;
- returning foreground transition after at least 30 seconds in background;
- at least two hours since the prior app-open impression;
- cached app-open ad age below four hours.

The app does not block cold-start bootstrap waiting for an ad.

### Interstitial

An interstitial opportunity is created only after every **third genuinely new saved reading** at the natural completion boundary.

- Reading 1: uninterrupted.
- Reading 2: uninterrupted.
- Reading 3: eligible opportunity if an ad is ready.
- Cadence persists across process restarts.
- Missing/not-ready ads never block the product.

### Intentionally not used

- no permanent banner over the tarot interface;
- no rewarded-ad requirement to unlock core functionality;
- no paid “remove ads” or premium checkout product;
- no native AdMob integration on the public web edition.

## 3. Permanent application identifiers

- iOS bundle ID: `com.tunabozcali.mystictarot`
- Android application ID: `com.tunabozcali.mystictarot`
- iOS SKU: `mystic-tarot-ios-001`
- Release version: `1.23.0+33`

Changing the bundle/application ID after first store upload is disruptive. Treat these identifiers as permanent.

## 4. AdMob production configuration

Create/verify one Android app and one iOS app in the owner's AdMob account.

Create these ad units:

- Android App Open;
- Android Interstitial;
- iOS App Open;
- iOS Interstitial.

Required protected production values:

- `ADMOB_ANDROID_APP_ID`
- `ADMOB_IOS_APP_ID`
- `ADMOB_ANDROID_APP_OPEN_ID`
- `ADMOB_IOS_APP_OPEN_ID`
- `ADMOB_ANDROID_INTERSTITIAL_ID`
- `ADMOB_IOS_INTERSTITIAL_ID`

Production builds must use:

`MYSTIC_USE_TEST_ADS=false`

QA/CI builds use Google's official demo IDs. Production preflight must reject demo IDs. Never generate development traffic using real ad units.

## 5. UMP / advertising privacy

The native app integrates Google User Messaging Platform behavior through the Google Mobile Ads Flutter integration.

At launch the app refreshes consent information. Where required, UMP can present the configured privacy form. Ad requests remain gated by `ConsentInformation.canRequestAds()`.

The normal privacy/settings experience exposes advertising privacy choices only when UMP reports `PrivacyOptionsRequirementStatus.required`.

Before production submission:

- configure the intended Privacy & messaging messages in the AdMob dashboard;
- test required-consent and no-form-required paths;
- confirm privacy options behavior;
- confirm consent refresh/ad-load failures do not block the app.

The current source does not add a custom iOS ATT/IDFA request flow. If ATT is enabled later, add the required iOS usage description, retest UMP ordering and revise App Privacy declarations before release.

## 6. app-ads.txt + AdMob app readiness

`app-ads.txt` is part of the native monetization go-live boundary.

Follow:

`docs/APP_ADS_TXT_GO_LIVE.md`

Important Mystic Tarot hosting detail:

The product site currently uses the GitHub Pages project URL:

`https://tuna777123.github.io/mystic-tarot/`

AdMob locates `app-ads.txt` from the developer-website **hostname root**. If the store developer website uses `tuna777123.github.io`, the required target is therefore:

`https://tuna777123.github.io/app-ads.txt`

Do not assume `https://tuna777123.github.io/mystic-tarot/app-ads.txt` is sufficient.

The file must use the personalized line supplied by the owner's AdMob account. Do not invent a publisher ID.

Real ad monetization is not considered fully live until:

- the personalized file is hosted at the correct root URL;
- the store listing exposes the correct developer website host;
- AdMob finds and verifies the file;
- AdMob app readiness reaches `Ready`;
- production IDs, UMP, signing and real-device QA have also passed.

## 7. Android production signing

Use the protected `production-stores` GitHub environment.

Required values:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_STORE_PASSWORD`
- `ANDROID_UPLOAD_CERT_SHA256`

Follow:

`docs/PRODUCTION_SIGNING_FINGERPRINTS.md`

Production Android candidate must verify:

- application ID;
- version/build number;
- ABI set;
- reviewed upload-certificate SHA-256;
- strict JAR signature;
- pinned `bundletool validate`;
- sensitive-permission policy;
- approved SDK policy;
- Built-in Kotlin compatibility policy;
- artifact checksum and release manifest.

The QA AAB created by ordinary CI is **not** the owner-signed Google Play production candidate.

## 8. iOS production signing

Required protected values:

- `IOS_DISTRIBUTION_CERTIFICATE_BASE64`
- `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`
- `IOS_DISTRIBUTION_CERT_SHA256`
- `IOS_PROVISIONING_PROFILE_BASE64`
- `IOS_TEAM_ID`

Production iOS candidate must verify:

- final codesign;
- Team ID;
- bundle ID;
- provisioning application identifier;
- entitlements;
- distribution certificate fingerprint;
- IPA checksum and release manifest.

Unsigned iOS CI proves source/build compatibility; it does not replace owner-controlled Apple distribution signing.

## 9. App Store metadata

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

## 10. Google Play metadata

**App name**  
Mystic Tarot: Daily Ritual

**Short description**  
Private tarot readings, pattern memory, a journal, and a daily ritual.

**Core store description**

Mystic Tarot turns a card reading into a private daily practice. Choose the cards that call to you, receive reflection-first guidance grounded in traditional symbolism, return after 24 hours for Mystic Mirror, and notice what repeats over time.

All readings, the Living Journal, Oracle dialogue, patterns, Mystic Path and the Arcana experience are available without a paid subscription. The native app is supported by occasional advertising.

Mystic Tarot is made for personal reflection and entertainment. It does not provide medical, mental-health, legal, financial, or emergency advice.

## 11. Screenshot package

The canonical QA screenshot package is:

**5 locales × 2 device profiles × 5 scenes = 50 screenshots**

Suggested order:

1. Daily Guidance
2. Explainable Reading
3. Mystic Mirror
4. Living Path
5. Complete free experience / ad-supported disclosure

Do not show subscription prices, paid-plan CTAs or purchase language. If UI changes materially in the final signed candidate or store requirements change, recapture before submission.

## 12. App review notes

Mystic Tarot:

- does not require an account;
- stores journal/profile/progress primarily on-device;
- has no subscription or in-app-purchase revenue model;
- uses Google Mobile Ads for native advertising;
- uses Google UMP for applicable advertising privacy choices;
- keeps the public web edition ad-free;
- provides local export and deletion controls;
- exposes Privacy Policy, Terms and Support;
- does not claim factual prediction or professional advice.

### Suggested reviewer path

1. Complete onboarding.
2. Open Daily Guidance.
3. Select/reveal a card and save the reading.
4. Open Path and Journal to inspect local persistence.
5. Open Profile → Privacy & data to inspect local export/deletion controls.
6. Confirm formerly gated content is usable without payment.
7. Confirm there is no subscription checkout or restore requirement.
8. Exercise UMP using applicable test geography/device configuration.
9. Verify QA uses Google test/demo ads.
10. Complete three new readings and verify the interstitial opportunity occurs only at the natural completion boundary.
11. After at least three readings, background the app for 30+ seconds and verify app-open cadence/frequency behavior.
12. Repeat legal-link, narrow-screen and long-localization checks in EN, TR, ES, FR and PT-BR.

## 13. Store privacy declarations

Use:

`docs/STORE_PRIVACY_DECLARATION_WORKSHEET.md`

Do not fill store privacy forms from assumptions or from the web edition.

Capture evidence from the **exact signed native candidate**, including resolved native Google Mobile Ads/UMP versions, Android manifest/permissions, iOS privacy manifest/report, ATT decision, UMP configuration and real-device behavior.

Mystic's own local-first journal design does not mean the advertising SDK processes no data.

### Apple App Privacy

Review the final Google Mobile Ads/UMP behavior and current App Store Connect questionnaire. Do not claim “Data Not Collected” unless the exact signed runtime and current Apple definitions genuinely support that answer.

### Google Play Data Safety

Reflect Google Mobile Ads and any advertising/device identifiers actually present in the signed Android runtime. The Android artifact audit distinguishes reviewed advertising permissions from unrelated sensitive permissions; it does not fill the Data Safety form for the owner.

## 14. Launch languages

Public launch language set:

- English
- Turkish
- neutral international Spanish
- French
- Brazilian Portuguese

German and Italian are not part of the public launch set until complete end-to-end localization and release testing pass.

## 15. Physical-device production matrix

Run on at least one current Android phone and one current iPhone using the signed store candidates.

### Advertising/privacy

- fresh install with required consent UI;
- fresh install where consent UI is not required;
- privacy-options visibility;
- no ad request before consent state permits it;
- consent refresh failure;
- ad load failure;
- offline/poor network behavior;
- reading #1 and #2 uninterrupted;
- reading #3 natural interstitial opportunity;
- cadence persistence after process restart;
- no app-open ad on first cold start;
- no app-open eligibility before three readings;
- no app-open after background <30 seconds;
- two-hour app-open minimum interval;
- no overlapping full-screen ads;
- immediate continuation after dismissing an eligible ad;
- no checkout/restore/paywall anywhere.

### Product

- first-run EN/TR/ES/FR/PT-BR;
- manual language persistence;
- Daily Guidance and deep readings;
- Mystic Mirror;
- Living Journal;
- Oracle;
- Mystic Path / Arcana;
- export/import/deletion/protected transfer;
- PIN/biometrics;
- notification allowed/denied states;
- Reduce Motion;
- narrow screens / long localized text;
- crash-free startup.

## 16. Account-owned actions before submission

Repository automation cannot complete these on the owner's behalf:

1. Apple Developer / App Store Connect ownership and agreements.
2. Google Play Console ownership and agreements.
3. Tax, banking and trader/business requirements.
4. AdMob Android/iOS app creation.
5. Production App Open + Interstitial units on both platforms.
6. UMP Privacy & messaging production configuration.
7. Personalized root `app-ads.txt` hosting and verification.
8. AdMob app-readiness approval.
9. Six production AdMob IDs in protected release configuration.
10. `MYSTIC_USE_TEST_ADS=false`.
11. Android upload signing ownership.
12. Apple distribution certificate/provisioning ownership.
13. Production-signed AAB/IPA.
14. Real Android+iPhone advertising/privacy QA.
15. Apple App Privacy + Google Play Data Safety from actual signed runtime.
16. TestFlight / Play internal/closed testing and Play pre-launch report.
17. Final store review/submission/approval.

## 17. Release gate

A native build is eligible for production submission only when:

- formatting, analysis and the complete test suite pass;
- web, Android and unsigned iOS release builds pass;
- production AdMob app/ad-unit IDs are configured;
- Google demo IDs are absent from the final candidate;
- `MYSTIC_USE_TEST_ADS=false`;
- UMP production behavior is configured and real-device tested;
- all functionality remains usable without purchase;
- no checkout/restore/paid-feature CTA remains;
- Android signature/bundle/permission/SDK/Kotlin audits pass;
- iOS Team ID/provisioning/codesign/fingerprint checks pass;
- `app-ads.txt` root hosting is correct and ready for store-linked verification;
- Privacy Policy, App Privacy and Data Safety match the signed runtime;
- real-device ad/no-ad/error paths pass;
- public legal/support/marketing URLs remain live;
- the uploaded packages use permanent production identifiers and owner-controlled signing.

## 18. Go-live definition

Do **not** claim native App Store / Google Play availability or fully live real advertising revenue until:

- the stores have approved the signed listings;
- production AdMob IDs are serving through the signed native binaries;
- UMP production configuration is live;
- `app-ads.txt` is verified;
- AdMob app readiness is `Ready`;
- real-device QA passes;
- store privacy declarations match observed runtime behavior.

Repository CI proves source/build/audit behavior. It cannot replace account ownership, AdMob dashboard configuration, developer-website root hosting, native signing, physical-device ad delivery, store forms or store review.

# Mystic Tarot — Store Release Pack

Current source version: `1.22.3+32`.

## Business model

Mystic Tarot is **free and advertising-supported**. There is no paid subscription, no consumable purchase, no paid unlock, and no required account.

Revenue comes only from Google Mobile Ads in the native Android and iOS apps. The public web edition stays ad-free.

### Native ad formats

- App-open ad: eligible returning foreground transitions.
- Interstitial ad: at most after every third genuinely new saved reading, and only when a preloaded ad is ready.
- No banner is pinned over the tarot interface.
- No rewarded feature lock: core product functionality never requires watching an ad.

Ads are requested only after the Google User Messaging Platform (UMP) consent flow says advertising requests are allowed.

## Permanent application identifiers

- iOS bundle ID: `com.tunabozcali.mystictarot`
- Android application ID: `com.tunabozcali.mystictarot`
- iOS SKU: `mystic-tarot-ios-001`

Changing bundle/application IDs after first store upload is disruptive. Confirm ownership before submission.

## AdMob production configuration

Create the same application in AdMob for Android and iOS and create one app-open and one interstitial unit per platform.

Required production values:

- `ADMOB_ANDROID_APP_ID`
- `ADMOB_IOS_APP_ID`
- `ADMOB_ANDROID_APP_OPEN_ID`
- `ADMOB_IOS_APP_OPEN_ID`
- `ADMOB_ANDROID_INTERSTITIAL_ID`
- `ADMOB_IOS_INTERSTITIAL_ID`

QA builds may use Google-provided demo app/ad-unit IDs. Production builds must set `MYSTIC_USE_TEST_ADS=false` and provide the four production ad-unit IDs through `--dart-define` plus the two native application IDs through the protected build environment.

Never publish a store candidate that still uses Google demo ad units.

## Ad privacy / consent

The native app integrates Google Mobile Ads and UMP.

On each app launch the app requests current consent information. If a form is required, UMP presents it. Advertising requests remain gated by `ConsentInformation.canRequestAds()`.

Configure the appropriate Privacy & messaging message in the AdMob dashboard before production submission. If UMP says a privacy-options entry point is required, the app exposes an advertising privacy choice action on its ad-supported access surface.

The app does not add Firebase Analytics, AppsFlyer, Adjust, Facebook App Events, Mixpanel, Amplitude, OneSignal, or Sentry as advertising/analytics companions. The Android bundle audit continues to fail closed on those unapproved SDK markers.

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

Localized metadata remains in:

- `docs/STORE_LISTING_TR.md`
- `docs/STORE_LISTING_ES.md`
- `docs/STORE_LISTING_FR.md`
- `docs/STORE_LISTING_PT_BR.md`

## Google Play metadata

**App name**  
Mystic Tarot: Daily Ritual

**Short description**  
Private tarot readings, pattern memory, a journal, and a daily ritual.

**Core store description**

Mystic Tarot turns a card reading into a private daily practice. Choose the cards that call to you, receive reflection-first guidance grounded in traditional symbolism, return after 24 hours for Mystic Mirror, and notice what repeats over time.

All readings, the Living Journal, Oracle dialogue, patterns, Mystic Path and the Arcana experience are available without a paid subscription. The native app is supported by occasional advertising.

Mystic Tarot is made for personal reflection and entertainment. It does not provide medical, mental-health, legal, financial, or emergency advice.

## Screenshot sequence

The canonical QA pack remains five locales × two device profiles × five scenes = 50 screenshots. Do not show subscription prices or purchase CTAs. If an ad-supported disclosure appears in store screenshots, it must match the actual signed build.

Suggested sequence:

1. Daily Guidance
2. Explainable Reading
3. Mystic Mirror
4. Living Path
5. Complete free experience / ad-supported disclosure

## App review notes

Mystic Tarot:

- does not require an account;
- stores journal/profile/progress primarily on-device;
- has no subscription or in-app-purchase revenue model;
- uses Google Mobile Ads for native advertising;
- uses Google UMP for applicable advertising privacy choices;
- keeps the public web edition ad-free;
- provides local export and deletion controls;
- exposes Privacy Policy, Terms, and Support;
- does not claim factual prediction or professional advice.

The repository still contains `purchases_flutter` compatibility code from the previous architecture, but the advertising-only runtime does not initialize RevenueCat or sell/restore products. Do not describe purchases as part of the live business model.

## App review test path

1. Complete onboarding.
2. Open Daily Guidance, select a card, reveal it, and save the reading.
3. Open Path and Journal to inspect local persistence.
4. Open Profile → Privacy & data to test local export/deletion.
5. Confirm formerly gated content is usable without payment.
6. Confirm there is no subscription checkout or restore requirement.
7. Test UMP consent behavior on an applicable test geography/device.
8. Confirm test ads are used during QA.
9. With production AdMob IDs in the signed store candidate, verify app-open and frequency-capped interstitial behavior on real devices.
10. Repeat legal-link and narrow-screen checks in EN, TR, ES, FR and PT-BR.

## Privacy declarations

Store forms must be completed from the exact final signed dependency/runtime behavior, not from assumptions.

### Apple App Privacy

The native app contains an advertising SDK. Review the final Google Mobile Ads/UMP behavior and declare advertising-related data types and purposes required by the App Store form. Do not claim “Data Not Collected” for the native advertising build unless Apple’s current questionnaire and the final runtime evidence genuinely support it.

The app itself does not upload private tarot journal text, profile content, PIN data, or local reflection history to Mystic servers.

### Google Play Data Safety

The final declaration must reflect Google Mobile Ads and any advertising identifiers present in the signed artifact. The Android artifact audit explicitly distinguishes reviewed Google advertising permissions from unrelated sensitive permissions.

Do not claim that advertising/tracking identifiers are absent after AdMob integration.

## Launch languages

Version 1 launches with five complete product languages:

- English
- Turkish
- neutral international Spanish
- French
- Brazilian Portuguese

German and Italian remain hidden until complete end-to-end localization and release testing pass.

## Account-owned actions before submission

These cannot be completed from source code alone:

1. Enroll in / verify Apple Developer and Google Play Console ownership.
2. Complete tax, banking, trader/business and store agreements.
3. Confirm ownership of `com.tunabozcali.mystictarot` on both platforms.
4. Create Android and iOS apps in AdMob.
5. Create app-open + interstitial units for Android and iOS.
6. Configure AdMob Privacy & messaging / UMP messages.
7. Add the six production AdMob IDs to the protected production build configuration.
8. Set `MYSTIC_USE_TEST_ADS=false` in production.
9. Create Apple signing/provisioning and Android upload signing materials.
10. Produce genuinely signed candidates.
11. Test consent, ad loading, frequency cap, app foreground behavior and no-ad failure paths on a real iPhone and Android phone.
12. Complete App Privacy and Google Play Data Safety from final runtime evidence.
13. Run TestFlight / Play closed testing and Play pre-launch report.
14. Submit for store review.

## Release gate

A native build is eligible for production submission only when:

- formatting, analysis and the complete test suite pass;
- web, Android and unsigned iOS release builds pass;
- production AdMob app IDs and ad-unit IDs are configured;
- Google demo IDs are absent from the final store candidate;
- UMP privacy behavior is configured and real-device tested;
- every formerly paid feature is usable without purchase;
- no live purchase/restore CTA remains;
- Android bundle audit allows only reviewed Google advertising permissions while still blocking sensitive permissions and unknown tracking SDKs;
- Privacy Policy, App Privacy and Data Safety match the signed runtime;
- real-device ad/no-ad/error paths pass;
- all public legal/support/marketing URLs remain live;
- the uploaded package is signed with the permanent production identifiers.

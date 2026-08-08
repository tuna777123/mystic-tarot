# Mystic Tarot 1.23.0 — Free, Advertising-Supported Native Release

Mystic Tarot 1.23.0 changes the native business model from subscription-oriented monetization to a free, advertising-supported product while preserving the complete tarot, journal, Mystic Mirror, pattern and privacy experience.

## Everything stays open

- There is no paid subscription or paid feature unlock.
- Formerly gated reading, Oracle, journal and long-term pattern features remain available without checkout or restore.
- The dormant purchase compatibility layer does not initialize RevenueCat or sell products.

## Privacy-aware native advertising

- Android and iOS integrate Google Mobile Ads and Google User Messaging Platform.
- Ads are requested only when the current UMP state permits requests.
- Interstitial opportunities occur after every third genuinely new saved reading and never block the product when no ad is ready.
- App-open ads are eligible only after at least three completed readings, after 30 or more seconds in background, with a two-hour minimum interval and four-hour cache expiry.
- Ad cadence persists across native process restarts.
- The public web edition remains ad-free.

## Production safeguards

- CI and QA use Google demo ad IDs.
- Protected production workflows require real Android/iOS AdMob app IDs plus app-open/interstitial unit IDs and reject Google demo IDs.
- Production builds must use `MYSTIC_USE_TEST_ADS=false`.
- Android bundle auditing explicitly classifies reviewed Google advertising permissions while continuing to block unrelated sensitive permissions and unapproved analytics/attribution SDKs.

## Existing product quality remains protected

- Five launch languages remain EN, TR, ES, FR and PT-BR.
- Mystic Intelligence continues to build private pattern evidence from locally stored readings and Mystic Mirror check-ins.
- Device-language startup, language persistence, reduced-motion behavior, journal recovery, encrypted private transfer and the six-digit/private app-lock experience remain part of the release gates.

## Release integrity

- Version `1.23.0+33`.
- Application/bundle ID remains `com.tunabozcali.mystictarot`.
- Real advertising revenue and native store availability are not considered live until owner-controlled AdMob IDs, privacy messaging, production signing, real-device QA and store approvals are complete.

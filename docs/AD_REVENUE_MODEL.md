# Mystic Tarot — Advertising-Only Revenue Model

Mystic Tarot's native Android and iOS editions are free products funded only by advertising. There is no paid subscription, paid Plus tier, purchase flow, restore flow, or feature paywall in the production business model.

## Revenue surfaces

- **Interstitial:** eligible after every third genuinely new saved reading, at the natural completion boundary.
- **App open:** eligible only for returning users after at least three completed readings, after at least 30 seconds in the background, and no more frequently than once every two hours.
- **Web:** the public web edition remains ad-free.

Core access never depends on watching an ad. Rewarded ads are intentionally not used as a gate for core features.

## Privacy and consent

Native advertising uses Google Mobile Ads with Google's UMP consent flow. Consent information is refreshed before ad initialization, required consent UI is shown when applicable, and ad requests remain gated by `ConsentInformation.instance.canRequestAds()`.

A privacy-options entry is exposed when UMP reports that privacy options are required. Store privacy disclosures must match the final AdMob/UMP configuration used in the signed production binaries.

## QA versus production

Repository and CI builds use Google's official demo app/ad unit IDs by default. This prevents accidental live-ad traffic during automated QA.

Production native builds require protected owner-controlled values for:

- `ADMOB_ANDROID_APP_ID`
- `ADMOB_IOS_APP_ID`
- `ADMOB_ANDROID_APP_OPEN_ID`
- `ADMOB_IOS_APP_OPEN_ID`
- `ADMOB_ANDROID_INTERSTITIAL_ID`
- `ADMOB_IOS_INTERSTITIAL_ID`
- `MYSTIC_USE_TEST_ADS=false`

Real production IDs must never be substituted into ordinary repository QA runs.

## Retired subscription path

RevenueCat and in-app subscription commerce are not part of the runtime revenue path. Historical compatibility code may remain temporarily where the repository's upstream/plugin audit explicitly depends on it, but it must not initialize checkout, sell a product, restore a purchase, or lock a user-facing feature.

## Release gate

A native release is production-ready only after all repository CI is green **and** the owner-controlled external steps are complete: AdMob app/unit creation, UMP configuration, production IDs/secrets, native signing, physical-device consent/ad QA, Play Internal Testing/TestFlight validation, store privacy/data forms, and final store approval.

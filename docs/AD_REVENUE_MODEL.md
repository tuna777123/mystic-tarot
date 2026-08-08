# Mystic Tarot — Advertising-Only Revenue Model

Mystic Tarot's native Android and iOS editions are free products funded only by advertising. There is no paid subscription, paid Plus tier, purchase flow, restore flow, or feature paywall in the production business model.

The normal profile experience states this directly as a free, advertising-supported product rather than presenting a subscription-management state. Oracle, FAQ, intelligence, profile, and reading surfaces must likewise avoid legacy paid-plan branding or checkout language.

## Revenue surfaces

- **Interstitial:** eligible after every third genuinely new saved reading, at the natural completion boundary.
- **App open:** eligible only for returning users after at least three completed readings, after at least 30 seconds in the background, and no more frequently than once every two hours.
- **Web:** the public web edition remains ad-free.

Core access never depends on watching an ad. Rewarded ads are intentionally not used as a gate for core features.

## Privacy and consent

Native advertising uses Google Mobile Ads with Google's UMP consent flow. Consent information is refreshed before ad initialization, required consent UI is shown when applicable, and ad requests remain gated by `ConsentInformation.instance.canRequestAds()`.

A privacy-options entry is exposed from the normal profile/settings experience when UMP reports that privacy options are required, so users do not need to discover a legacy monetization route to revisit advertising consent choices. Store privacy disclosures must match the final AdMob/UMP configuration used in the signed production binaries.

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

RevenueCat and `purchases_flutter` are removed from the production dependency graph and runtime source. The repository retains only small pure-Dart historical DTO/interface shapes plus a fail-closed `DisabledSubscriptionClient` for compatibility with older internal call sites. That compatibility layer has no store SDK, network purchase provider, checkout, restore, product sale, or paid entitlement path.

## Automated runtime-copy gate

Verified builds run `tool/materialize_ad_only_ui.dart` before analysis, tests and packaging. It deterministically removes the final historical paid-tier labels from the legacy source structure, hardens the narrow-screen Mystic Intelligence header, and fails closed if a known paid-plan anchor changes unexpectedly.

`test/ad_only_user_copy_contract_test.dart` then fails the build if the materialized main application or Mystic Intelligence surface reintroduces user-facing `Mystic Plus`, subscription-management, paid-plan or premium-spread messaging. Technical historical class/file names may remain where renaming would add needless migration risk, but they cannot leak back into the runtime product copy.

## Release gate

A native release is production-ready only after all repository CI is green **and** the owner-controlled external steps are complete: AdMob app/unit creation, UMP configuration, production IDs/secrets, native signing, physical-device consent/ad QA, Play Internal Testing/TestFlight validation, store privacy/data forms, and final store approval.

# Mystic Tarot

Mystic Tarot is a private, reflection-first tarot ritual built with Flutter. A reading becomes a 24-hour reality check and, with enough evidence, an explainable personal pattern. Private history stays primarily on-device and the complete app can be protected with a local PIN and optional biometrics on supported devices.

The product is **free**. Native Android and iOS monetization is **advertising-only** through Google Mobile Ads with Google User Messaging Platform consent handling. The public web edition remains ad-free.

## Live public release

https://tuna777123.github.io/mystic-tarot/

Public marketing:

- English website: https://tuna777123.github.io/mystic-tarot/landing-en.html
- Turkish website: https://tuna777123.github.io/mystic-tarot/landing.html
- Spanish website: https://tuna777123.github.io/mystic-tarot/landing-es.html
- French website: https://tuna777123.github.io/mystic-tarot/landing-fr.html
- Brazilian Portuguese website: https://tuna777123.github.io/mystic-tarot/landing-pt-br.html
- Press & sharing kit: https://tuna777123.github.io/mystic-tarot/press-kit.html

Public policies:

- Privacy: https://tuna777123.github.io/mystic-tarot/privacy.html
- Terms: https://tuna777123.github.io/mystic-tarot/terms.html
- Support: https://tuna777123.github.io/mystic-tarot/support.html

## Product

- Five complete launch languages: EN, TR, ES, FR, PT-BR
- 78-card deck with upright and reversed meanings
- Cinematic selection, seal, reveal, and interpretation ritual
- Daily Guidance plus focused and deep readings
- Explainable reading synthesis and practical aligned actions
- Oracle follow-up dialogue grounded in revealed cards
- Private local Living Journal, export, deletion, search, recovery and protected transfer
- 24-hour Mystic Mirror reality check
- Recurring-card and emotional pattern memory
- Mystic Path, Arcana Vault, journeys, weekly evidence, streaks, XP, achievements and rituals
- Six-digit PIN and optional supported-device biometrics
- Reduced-motion protections
- Responsive mobile UI and installable PWA

## Advertising-only monetization

There is no paid subscription, paid reading pack, paid unlock, or required account.

Native Android/iOS builds use:

- Google Mobile Ads;
- Google User Messaging Platform for applicable consent/privacy choices;
- app-open ads only on eligible returning foreground transitions after at least five completed readings and at least one minute in the background;
- at least six hours between app-open impressions;
- an interstitial opportunity only after every fourth genuinely new saved reading, so the first three new readings remain uninterrupted;
- a shared 45-minute cross-format full-screen gap after an actual app-open or interstitial impression;
- cooldown state that begins only after a real ad impression, so failed show attempts do not consume it;
- no permanent banner over the tarot interface;
- no rewarded ad requirement for a core feature.

If an ad is unavailable or fails, the product continues normally.

QA uses Google demo IDs. Production must use the owner’s real AdMob application/ad-unit IDs and `MYSTIC_USE_TEST_ADS=false`.

## Privacy posture

The public web edition is local-first and ad-free. Native builds add Google advertising/consent services, but private Mystic content is not intentionally sent to a Mystic advertising backend for targeting.

Private product data includes reading questions, journal text, Mystic Mirror notes, profile information, intention and PIN-related local state.

Product-growth telemetry uses a separate allow-listed `MysticBusinessMetrics` boundary. Questions, notes, card names, user names, intentions, journal text, emotions, Mirror outcomes and free text are not permitted as business-metric dimensions. Dimension **values** are also restricted to a closed coarse vocabulary, so private content cannot be hidden inside a field such as `source`.

Controlled beta builds can optionally expose a local **Growth Evidence** screen with `MYSTIC_GROWTH_DIAGNOSTICS=true`. The ledger is aggregate-only, has no Mystic account/device/advertising identifier, does not upload automatically, excludes pre-measurement legacy journal history from the mature 72-hour Mirror cohort, and keeps its internal measurement timestamp/dedupe tokens out of exported evidence.

Final Apple App Privacy and Google Play Data Safety declarations must be completed from the exact signed native advertising build and actual runtime behavior.

## Company growth gates

Mystic is operated as a measured product, not a feature-count project. `docs/GROWTH_KPI_CONTRACT.md` defines retention, Mirror-completion and paid-acquisition gates; `docs/INVESTMENT_GRADE_PRODUCT_PLAN.md` defines the product thesis and capital-allocation rules; `docs/BETA_MEASUREMENT_PROTOCOL.md` defines how controlled devices produce and aggregate launch evidence. Paid acquisition should not materially scale until retained cohorts prove the 24-hour Mirror loop.

## Shareable launch material

- `docs/OWNER_GUIDE_A_TO_Z.md` — complete product/owner/operator manual from product concept through advertising and store release.
- `STORE_RELEASE.md` — canonical App Store / Google Play / AdMob / signing handoff.
- `docs/MARKETING_LAUNCH_KIT.md` — paid-social copy, short-form video briefs, creator/PR copy, five-language campaign messages, UTM convention and claim guardrails.
- `docs/FINAL_DELIVERY.md` — technical and public-facing delivery summary.
- `web/press-kit.html` — public, indexable press/share page.

Marketing must not claim App Store or Google Play availability until signed native listings are approved and live. Do not fabricate ratings, user counts, testimonials, awards, scarcity, prices, download counts, or predictive/professional-advice claims.

## Development

```bash
flutter create . --platforms=web,android,ios
dart run tool/configure_store_identifiers.dart
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter run
```

The application dependency graph is committed in `pubspec.lock`. Development, CI, screenshots, previews, and protected store-release workflows must respect that lockfile so validated QA and later signed production candidates cannot silently resolve different transitive package versions.

The same deterministic materialization used by verified release builds is therefore also part of the documented local-development path. Native QA builds intentionally default to Google test advertising. Real AdMob IDs belong only in protected production configuration.

## Release verification

Source/release gates cover formatting, clean diff, static analysis, the complete Flutter test suite, public launch/business-model claims, web release, Android AAB build/audit, unsigned iOS verification, localized store screenshots, and post-deployment public URL checks.

Production store release additionally requires protected real AdMob IDs, signing materials, real-device consent/ad QA, store privacy declarations and owner-controlled store approvals.

See [docs/OWNER_GUIDE_A_TO_Z.md](docs/OWNER_GUIDE_A_TO_Z.md) first for the full A-to-Z explanation, then [STORE_RELEASE.md](STORE_RELEASE.md) for native release operations.

Tarot content is for reflection and entertainment, not medical, mental-health, legal, financial, or emergency advice.

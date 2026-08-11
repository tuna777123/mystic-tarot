# Mystic Tarot 1.23.0+33 — Verified Delivery Manifest

This manifest records the shareable advertising-only release evidence for Mystic Tarot.

## Product identity

- Version: `1.23.0+33`
- Application / bundle ID: `com.tunabozcali.mystictarot`
- Launch languages: EN, TR, ES, FR, PT-BR
- Business model: free native app, advertising-only revenue through Google Mobile Ads; public web edition ad-free
- No paid subscription, paid pack, checkout, restore-to-unlock, RevenueCat runtime, or `purchases_flutter` production dependency

## Current product baseline

- Canonical `main`: `c32505190397389e41efc77b9f886fcfdb1d6559`
- Latest fully verified product head: `bdba9a0de073438dbe835a4ecab17c0c11c1cd66` (PR #149)
- PR #149 merged the Category Leader evidence-loop / premium-feel polish into current `main`.
- The 24-hour Mystic Mirror loop is the primary return path: read → test one grounded action → return to reality → accumulate private evidence → reveal recurring patterns.
- Pattern Lab is part of the advertising-supported experience and is framed as evidence-before-pattern, not a paid unlock or prediction score.

## Automated validation

Validated Flutter CI run `31494774882`: **SUCCESS**.

- canonical Dart formatting: PASS
- public launch/business-model verifier: PASS
- `flutter analyze --fatal-infos`: PASS
- Flutter tests: **540 passed, 1 intentional skip, 0 failures**
- web release: PASS
- Android AAB: PASS
- Built-in Kotlin audit: PASS
- pinned bundletool `1.18.3`: PASS
- Android artifact audit: PASS

Validated iOS Release CI run `31494774899`: **SUCCESS**.

- Apple submission SDK-floor verifier: PASS
- generated iOS integration: PASS
- unsigned iOS Release build: PASS
- release application verification: PASS

Validated Store Screenshot QA run `31494774905`: **SUCCESS**.

- 50 screenshots total
- 5 launch locales × Apple / Google Play × 5 scenes

## Verified QA Android AAB

- Artifact ID: `9102823745`
- Android audit artifact ID: `9102824267`
- Built-in Kotlin audit artifact ID: `9102824716`
- Flutter test-log artifact ID: `9102561660`
- Package: `com.tunabozcali.mystictarot`
- Version: `1.23.0+33`
- Size: `63,667,930` bytes (`60.72 MiB`)
- SHA-256: `e8472c32518ff3088927d847f5182b124533004336207bba149ebf07508ec1f6`
- Min SDK: 24
- Target SDK: 36
- ABIs: `arm64-v8a, armeabi-v7a, x86_64`
- strict JAR signature policy: PASS
- bundletool validation: PASS
- BundleConfig: `PAGE_ALIGNMENT_16K`
- packaged 64-bit shared libraries checked: 8
- every audited arm64-v8a/x86_64 ELF `LOAD` alignment: >= 16,384 bytes
- sensitive permission denylist: clear
- reviewed Google advertising permissions: explicitly classified
- unapproved analytics/attribution SDK denylist: clear
- Built-in Kotlin warning budget: only the reviewed `flutter_timezone` compatibility warning remains

The values above were taken from the downloaded PR #149 AAB and its matching Android audit artifact. This is a QA release artifact, not the owner-signed production Play candidate.

## Native advertising behavior

Mystic deliberately uses conservative full-screen ad cadence to protect first-session value and the Mystic Mirror return loop.

- Google Mobile Ads + Google UMP
- ad request only when UMP `canRequestAds()` permits
- Google demo IDs by default for QA
- real production IDs must be protected and `MYSTIC_USE_TEST_ADS=false`
- first three genuinely new saved readings remain uninterrupted
- interstitial opportunity only after every **4th** genuinely new saved reading, at the natural completion boundary
- app-open requires at least **5 completed readings**
- returning foreground transition must follow at least **1 minute** in background
- app-open impression interval is at least **6 hours**
- at least **45 minutes** between actual full-screen impressions across formats
- cooldown begins from real `onAdImpression`, not attempted shows
- no permanent banner over the tarot interface
- no rewarded ad required for core functionality
- no ad on the public web edition

## Android 16 KB release protection

The Android release audit fails closed unless the actual AAB:

- targets the current Mystic Play submission floor (API 36);
- reports `PAGE_ALIGNMENT_16K` in BundleConfig;
- has every packaged arm64-v8a/x86_64 ELF `LOAD` alignment >= 16,384 bytes;
- passes strict signature and bundletool validation;
- stays clear of the sensitive-permission and unapproved analytics/attribution deny-lists.

The automated audit does not replace Play App Bundle Explorer or real 16 KB device/emulator testing on the final owner-signed candidate.

## iOS advertising release protection

Current `main` includes:

- deterministic production AdMob application-ID materialization;
- the dated reviewed 50-ID iOS SKAdNetwork catalog;
- regression coverage for uniqueness, exact-once output, idempotence, stale replacement and malformed plist failure;
- signed-IPA verification that reopens the final exported IPA and checks the protected production `ADMOB_IOS_APP_ID` and exact reviewed SKAdNetwork set before release evidence can be written;
- fail-closed release-manifest evidence for production AdMob/SKAdNetwork verification.

Apple privacy-manifest / required-reason API evidence and encryption export-compliance are intentionally determined from the exact final signed candidate rather than guessed in source.

## Store screenshots

- Artifact ID: `9102590178`
- Source: `bdba9a0de073438dbe835a4ecab17c0c11c1cd66`
- Version: `1.23.0+33`
- 50 PNGs total
- EN/TR/ES/FR/PT-BR
- Apple 6.9-inch: 25 × `1290×2796`
- Google Play phone: 25 × `1080×1920`
- 5 scenes per locale/platform

## Public surfaces

- Web app: `https://tuna777123.github.io/mystic-tarot/`
- Product website: `https://tuna777123.github.io/mystic-tarot/landing-en.html`
- Press kit: `https://tuna777123.github.io/mystic-tarot/press-kit.html`
- Privacy: `https://tuna777123.github.io/mystic-tarot/privacy.html`
- Terms: `https://tuna777123.github.io/mystic-tarot/terms.html`
- Support: `https://tuna777123.github.io/mystic-tarot/support.html`

The project Pages deployment is the public product surface. It does **not** by itself satisfy AdMob root `app-ads.txt` ownership because the developer-site hostname must expose the personalized file at its root.

## Owner-controlled production boundary

The repository cannot complete these account/device steps by itself:

1. Activate/verify Apple Developer + App Store Connect and Google Play Console ownership, agreements, identity/trader/tax requirements that apply to the real accounts.
2. Create/verify the AdMob Android and iOS apps and production App Open / Interstitial ad units.
3. Configure/publish Google UMP Privacy & messaging for launch regions.
4. Configure protected real AdMob IDs and production `MYSTIC_USE_TEST_ADS=false`.
5. Control a developer website hostname that can serve the personalized AdMob line at root `/app-ads.txt`, then reach AdMob app readiness `Ready`.
6. Configure Android upload signing and Apple distribution/provisioning materials in the protected production environment.
7. Run the protected Production Store Release workflow to create genuinely owner-signed AAB/IPA candidates.
8. Test exact signed candidates on real Android+iPhone devices, including consent, ad cadence, offline/failure paths, notifications, privacy controls, five languages and Mystic Mirror return behavior.
9. Complete Apple App Privacy / Google Play Data Safety and Apple encryption-export determinations from the exact signed candidates.
10. Complete Play testing / production access, TestFlight, Play pre-launch report, store review and public approval.

Do not claim live native-store availability or real advertising revenue until these external gates pass.
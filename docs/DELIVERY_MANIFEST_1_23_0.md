# Mystic Tarot 1.23.0+33 — Verified Delivery Manifest

This manifest records the shareable advertising-only release evidence for Mystic Tarot.

## Product identity

- Version: `1.23.0+33`
- Application / bundle ID: `com.tunabozcali.mystictarot`
- Launch languages: EN, TR, ES, FR, PT-BR
- Business model: free native app, advertising-only revenue through Google Mobile Ads; public web edition ad-free
- No paid subscription, paid pack, checkout, restore-to-unlock, RevenueCat runtime, or `purchases_flutter` production dependency

## Current product baseline

- Current `main` at handoff preparation: `6e30938eb2a928dae26668a95f06bb35ef644fcd`
- Latest fully verified product head: `383bb5358ce903d791c797ed54b82a69ba455068`
- Product-critical practical-action and Mystic Mirror runtime blobs on current `main` are identical to that verified head.

## Automated validation

Validated Flutter CI run `31439865527` / #1173: SUCCESS.

- formatting: PASS
- clean diff: PASS
- public launch/business-model verifier: PASS
- static analysis: PASS
- Flutter tests: **539 passed, 1 intentional skip**
- web release: PASS
- Android AAB: PASS
- Built-in Kotlin audit: PASS
- pinned bundletool `1.18.3`: PASS
- Android artifact audit: PASS

Validated iOS Release CI run `31439865528` / #573: SUCCESS.

- Apple submission SDK-floor verifier: PASS
- unsigned iOS release: PASS
- release application verification: PASS

## Verified QA Android AAB

- Artifact ID: `9082687927`
- Package: `com.tunabozcali.mystictarot`
- Version: `1.23.0+33`
- Size: `63,610,632` bytes (`60.66 MiB`)
- SHA-256: `48f66e5593917a9613971aead667e229836085eb2e38127b3145d88b6c3a1468`
- Min SDK: 24
- Target SDK: 36
- ABIs: `arm64-v8a, armeabi-v7a, x86_64`
- strict JAR signature policy: PASS
- bundletool validation: PASS
- BundleConfig: `PAGE_ALIGNMENT_16K`
- packaged 64-bit shared libraries checked: 8
- every audited 64-bit ELF `LOAD` alignment: >= 16,384 bytes
- sensitive permission denylist: clear
- reviewed Google advertising permissions: explicitly classified
- unapproved analytics/attribution SDK denylist: clear

This is a QA release artifact. It is not the owner-signed production Play candidate.

## Native advertising behavior

- Google Mobile Ads + Google UMP
- ad request only when UMP `canRequestAds()` permits
- Google demo IDs by default for QA
- real production IDs must be protected and `MYSTIC_USE_TEST_ADS=false`
- interstitial opportunity after every third genuinely new saved reading
- app-open only for established returning use: >=3 readings, >=30 seconds background, >=2 hours since app-open impression
- >=20 minutes between actual full-screen impressions across formats
- cooldown begins from real `onAdImpression`, not attempted shows
- no permanent banner over the tarot interface
- no rewarded ad required for core functionality
- no ad on the public web edition

## iOS advertising release protection

Current `main` includes:

- deterministic AdMob application-ID materialization;
- the dated reviewed iOS SKAdNetwork catalog;
- signed-IPA verification that reopens the final exported IPA and checks the protected production AdMob app ID and exact reviewed SKAdNetwork set before release evidence can be written.

## Store screenshots

- Artifact ID: `9078705084`
- Version: `1.23.0+33`
- Source: `b6607523585a755c1eed2cb6ee22577944f59038`
- 50 PNGs total
- EN/TR/ES/FR/PT-BR
- Apple 6.9-inch: 25 × `1290×2796`
- Google Play phone: 25 × `1080×1920`
- scenes: Daily Guidance, Explainable Reading, Mystic Mirror, Living Path, Free/Ad-Supported
- RGB 8-bit, no alpha

## Public surfaces

- Web app: `https://tuna777123.github.io/mystic-tarot/`
- Product website: `https://tuna777123.github.io/mystic-tarot/landing-en.html`
- Press kit: `https://tuna777123.github.io/mystic-tarot/press-kit.html`
- Privacy: `https://tuna777123.github.io/mystic-tarot/privacy.html`
- Terms: `https://tuna777123.github.io/mystic-tarot/terms.html`
- Support: `https://tuna777123.github.io/mystic-tarot/support.html`

Current main Pages deployment is green.

## Owner-controlled production boundary

The repository cannot complete these account/device steps by itself:

1. Apple Developer/App Store Connect and Google Play Console ownership/agreements.
2. AdMob Android+iOS app creation and production App Open/Interstitial units.
3. UMP Privacy & messaging production configuration.
4. Protected real AdMob IDs and `MYSTIC_USE_TEST_ADS=false`.
5. Controlled developer website root + personalized `app-ads.txt` + AdMob readiness `Ready`.
6. Android upload signing and Apple distribution/provisioning materials.
7. Genuinely signed AAB/IPA from the protected production workflow.
8. Real Android+iPhone ad/consent/offline/failure-path QA.
9. Exact signed-candidate Apple App Privacy / Google Play Data Safety declarations.
10. Play/TestFlight testing, Play pre-launch report, store review and public approval.

Do not claim live native-store availability or real ad revenue until these external gates pass.

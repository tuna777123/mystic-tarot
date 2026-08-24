# Mystic Tarot — Final Codex Production Handoff

## Mission

Finish Mystic Tarot from the current validated repository state and take it through the real Android/iOS store-release process without adding product-scope churn.

The repository is already feature-complete for launch. Treat this as a **release, account, signing, store-console, and exact-candidate QA task**, not a redesign task.

## Product identity

- App: **Mystic Tarot**
- Package / bundle ID: `com.tunabozcali.mystictarot`
- Current app version: `1.23.0+33`
- Monetization: **advertising-only**
- Public web: ad-free
- Launch locales: **EN / TR / ES / FR / PT-BR**
- Primary retention loop: reading → grounded action → 24-hour Mystic Mirror → private evidence / Pattern Lab
- Do not reintroduce subscription, paywall, RevenueCat, paid unlock, prediction-certainty, public private-journal sharing, or feature-count expansion.

## Canonical sources of truth

Read these first:

1. GitHub issue **#114** — canonical owner/store go-live checklist.
2. `.github/workflows/store-release.yml` — protected signed Android/iOS production build contract.
3. `tool/src/store_release_contract.dart` — required secret names and release identity.
4. `docs/STORE_LISTING_INDEX.md` — five-language store metadata entry point.
5. `docs/CONTENT_RATING_OWNER_WORKSHEET.md` — Apple age rating / Google IARC handoff.
6. `docs/STORE_PRIVACY_WORKSHEET.md` — App Privacy / Play Data Safety handoff.
7. `docs/APP_ADS_TXT_RUNBOOK.md` — app-ads.txt deployment procedure.
8. `docs/FINAL_DELIVERY.md` and `docs/OWNER_FINAL_CHECKLIST.md` — release operator handoff.

## Repository hardening already completed

Do not remove or weaken these gates:

- committed `pubspec.lock` + `flutter pub get --enforce-lockfile` across build/release workflows;
- Android target SDK/API 36 gate;
- Android 16 KB BundleConfig + arm64/x86_64 ELF LOAD alignment audit;
- pinned bundletool validation;
- exact Built-in Kotlin warning audit;
- Android sensitive-permission and unapproved analytics/attribution SDK denylist;
- exact native Google Mobile Ads / UMP SDK evidence from real Android/iOS graphs;
- iOS 50-entry SKAdNetwork materialization and signed-IPA exact-set verification;
- signed IPA production AdMob App ID verification;
- iOS packaged `PrivacyInfo.xcprivacy` inventory + `plutil -lint` evidence;
- final signed IPA privacy-manifest audit through release-manifest creation;
- Apple SDK-floor verification;
- store screenshot generation/audit for 50 launch images;
- production secret/workflow drift regression tests;
- production Android/iOS signing certificate fingerprint checks;
- demo/test AdMob IDs rejected by production preflight;
- `MYSTIC_USE_TEST_ADS=false` required for signed store builds.

## Final handoff branch task

The branch `release/final-codex-handoff` intentionally aligns `.github/workflows/release-candidate.yml` with the canonical platform materializer used by the real release workflows.

Before doing any account work:

1. Inspect the diff against `main`.
2. Run the full repository validation on the exact head.
3. Confirm Release Candidate now passes.
4. Confirm Flutter CI and iOS Release CI pass.
5. Merge only if the exact head is fully green.
6. After merge, re-run / verify Release Candidate on canonical `main`.

If this branch is already merged when you start, verify the resulting `main` rather than recreating the change.

## External owner-controlled blockers

These are the only expected launch blockers once repository CI is green. Never invent values.

### Google / AdMob

- create or confirm the Google Play Console developer account;
- create or confirm the AdMob account;
- create Mystic Tarot Android and iOS apps in AdMob;
- obtain the real production values for:
  - `ADMOB_ANDROID_APP_ID`
  - `ADMOB_ANDROID_APP_OPEN_ID`
  - `ADMOB_ANDROID_INTERSTITIAL_ID`
  - `ADMOB_IOS_APP_ID`
  - `ADMOB_IOS_APP_OPEN_ID`
  - `ADMOB_IOS_INTERSTITIAL_ID`
- publish the required UMP consent configuration;
- obtain the real AdMob publisher line for `app-ads.txt`;
- create a root-hosted developer website location if needed. A project Pages path such as `/mystic-tarot/` is not a substitute for a hostname-root `/app-ads.txt`.

### Android signing

Populate the protected `production-stores` environment with the exact values required by `StoreReleaseContract.androidRequiredEnvironment`:

- `ADMOB_ANDROID_APP_ID`
- `ADMOB_ANDROID_APP_OPEN_ID`
- `ADMOB_ANDROID_INTERSTITIAL_ID`
- `ANDROID_UPLOAD_KEYSTORE_BASE64`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_STORE_PASSWORD`
- `ANDROID_UPLOAD_CERT_SHA256`

Do not print secret values in logs, issues, comments, commits, or summaries.

### Apple / App Store Connect

Create or confirm Apple Developer Program / App Store Connect ownership and populate the protected `production-stores` environment with:

- `ADMOB_IOS_APP_ID`
- `ADMOB_IOS_APP_OPEN_ID`
- `ADMOB_IOS_INTERSTITIAL_ID`
- `IOS_DISTRIBUTION_CERTIFICATE_BASE64`
- `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`
- `IOS_DISTRIBUTION_CERT_SHA256`
- `IOS_PROVISIONING_PROFILE_BASE64`
- `IOS_TEAM_ID`

Do not guess Apple export-compliance answers. Determine them from the exact final application and App Store Connect requirements.

## Production build procedure

Once all protected secrets are present:

1. Run **Production Store Release** from canonical `main`.
2. Start with the intended testing channel, not public production unless the owner explicitly wants immediate production submission.
3. Prefer `platform=both` once both signing stacks are valid.
4. Do not bypass a failing preflight or artifact audit.
5. Retain the generated signed AAB / IPA, checksums, release manifests, Android audit, Kotlin audit, native ads SDK evidence, and iOS privacy-manifest evidence.

## Exact-candidate QA before store submission

Validate the real signed candidates, not a debug/demo substitute:

- onboarding;
- first reading and save;
- Mystic Mirror 24-hour return path;
- notification scheduling/timezone behavior;
- private app lock / Face ID / biometric behavior;
- restart/offline behavior;
- EN/TR/ES/FR/PT-BR layout and copy;
- UMP consent in applicable regions;
- production ads and cadence without demo/test IDs;
- app-open after the tested eligibility policy;
- interstitial every 4th genuinely new saved reading at the natural completion boundary;
- no full-screen stacking inside the tested cooldown policy;
- no private reading/journal content leaking to analytics/public sharing;
- Android 16 KB compatibility on Play/App Bundle Explorer and a suitable 16 KB device/emulator;
- iOS privacy report / required-reason API review on the exact archived candidate;
- final store screenshots / metadata / privacy / content rating match the exact candidate.

## Store rollout

### Google Play

- create the app using `com.tunabozcali.mystictarot`;
- upload the signed AAB to the required testing track;
- complete Data Safety, content rating, ads declaration, target audience, app access, developer/trader/business/tax/banking requirements as applicable;
- satisfy any account-specific closed-testing requirement before production eligibility;
- review Play pre-launch report;
- only promote after exact-candidate QA passes.

### Apple

- create the App Store Connect app using `com.tunabozcali.mystictarot`;
- upload the signed IPA/build;
- complete App Privacy, age rating, encryption/export compliance, ads/privacy disclosures, pricing/availability, agreements/tax/banking as applicable;
- use TestFlight for exact-candidate QA;
- submit for App Review only after the final candidate and metadata agree.

## app-ads.txt

Do not invent a publisher ID.

The final file must use the real personalized AdMob publisher line and must be reachable from the **hostname root** expected by AdMob. Verify it live before considering this task complete.

## Completion definition

Do not call Mystic Tarot launched merely because CI is green.

The job is complete only when:

- canonical `main` CI/release candidate is green;
- production Android and iOS secrets are configured without exposure;
- a real signed AAB and IPA are produced by the protected workflow;
- exact-candidate QA passes;
- `app-ads.txt` is live and verified;
- Play Console and App Store Connect forms are completed from the exact candidate;
- required testing tracks/TestFlight are passed;
- the app is submitted to both stores, or the owner explicitly chooses a staged single-store launch;
- any store-review rejection is fixed and resubmitted rather than worked around by weakening release gates.

## Operating rule for Codex

Work autonomously on technical/repository tasks. Do not stop for routine implementation choices. Ask the owner only when a value/action genuinely requires account ownership, payment, 2FA, legal agreement acceptance, tax/banking information, production credentials, or an irreversible public-store decision.

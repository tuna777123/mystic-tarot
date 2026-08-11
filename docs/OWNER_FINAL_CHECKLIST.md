# Mystic Tarot — Owner Final Checklist

Version: `1.23.0+33`  
Application / bundle ID: `com.tunabozcali.mystictarot`

This is the shortest production checklist. Product/source work is complete only when repository CI is green; native store launch is complete only when every applicable owner/account/device checkbox below is verified with the real signed candidate.

## 1. Developer accounts

- [ ] Apple Developer / App Store Connect ownership active.
- [ ] Google Play Console ownership active.
- [ ] Required agreements accepted.
- [ ] Required trader/business/tax/banking information complete.
- [ ] Store support/privacy contact monitored.

## 2. Google Play account gate

- [ ] Confirm whether the Play account is personal or organization.
- [ ] Confirm creation date if personal.
- [ ] If the account is subject to Google's new-personal-account rule, complete a closed test with at least 12 testers continuously opted in for 14 days and apply for Production access.

See `docs/STORE_TECHNICAL_REQUIREMENTS_2026.md`.

## 3. Developer website + app-ads.txt

Current product site:

`https://tuna777123.github.io/mystic-tarot/`

If `tuna777123.github.io` is used as the store developer-website host:

- [ ] Create/own the root user-site repository `tuna777123/tuna777123.github.io` or choose another controlled developer domain.
- [ ] Obtain the personalized AdMob `app-ads.txt` line from the owner's AdMob dashboard.
- [ ] Publish it at the developer-host root, e.g. `https://tuna777123.github.io/app-ads.txt`.
- [ ] Confirm HTTP 200 and exact personalized content.
- [ ] Confirm robots.txt does not block the file.
- [ ] Put the same controlled developer-website host in the Google Play listing.
- [ ] Put the appropriate developer/marketing website host in the App Store listing.
- [ ] Confirm AdMob shows app-ads.txt found and verified.
- [ ] Confirm AdMob app readiness reaches `Ready`.

Never invent a publisher ID.

See `docs/APP_ADS_TXT_GO_LIVE.md`.

## 4. AdMob production setup

Create/verify one native AdMob app per platform and one App Open + one Interstitial unit per platform.

Protected production values:

- [ ] `ADMOB_ANDROID_APP_ID`
- [ ] `ADMOB_IOS_APP_ID`
- [ ] `ADMOB_ANDROID_APP_OPEN_ID`
- [ ] `ADMOB_IOS_APP_OPEN_ID`
- [ ] `ADMOB_ANDROID_INTERSTITIAL_ID`
- [ ] `ADMOB_IOS_INTERSTITIAL_ID`
- [ ] Production uses `MYSTIC_USE_TEST_ADS=false`.
- [ ] QA/CI continues using official Google demo IDs.

## 5. UMP privacy messaging

- [ ] Configure/publish intended Privacy & messaging configuration in AdMob.
- [ ] Test a consent-required state.
- [ ] Test a no-form-required state.
- [ ] Confirm no ad request before `ConsentInformation.canRequestAds()` permits it.
- [ ] Confirm Privacy Choices appears only when UMP reports it is required.
- [ ] Confirm consent refresh failure never blocks Mystic.

## 6. Android store candidate

Current Mystic release policy requires the audited AAB to target **API 36 or higher**.

Protected signing values:

- [ ] `ANDROID_UPLOAD_KEYSTORE_BASE64`
- [ ] `ANDROID_KEY_ALIAS`
- [ ] `ANDROID_KEY_PASSWORD`
- [ ] `ANDROID_STORE_PASSWORD`
- [ ] `ANDROID_UPLOAD_CERT_SHA256`

Then:

- [ ] Run the protected production store workflow from `main`.
- [ ] Confirm the committed `pubspec.lock` is used with `--enforce-lockfile` and remains unchanged.
- [ ] Produce the owner-signed AAB with real AdMob IDs.
- [ ] Confirm package `com.tunabozcali.mystictarot`.
- [ ] Confirm version `1.23.0+33`.
- [ ] Confirm target SDK >= 36 in the generated audit.
- [ ] Confirm required ABIs.
- [ ] Confirm strict signature policy PASS.
- [ ] Confirm reviewed upload-certificate SHA-256 PASS.
- [ ] Confirm pinned `bundletool validate` PASS.
- [ ] Confirm permission/SDK/Kotlin audits PASS.
- [ ] Confirm `PAGE_ALIGNMENT_16K` and 64-bit ELF LOAD alignment audit PASS.
- [ ] Save AAB checksum + release manifest.
- [ ] Upload to Play Internal/Closed Testing.
- [ ] Review Play App Bundle Explorer 16 KB compatibility evidence.
- [ ] Review Play pre-launch report.

## 7. iOS store candidate

Apple currently requires App Store uploads to be built with Xcode 26+ using the iOS 26 SDK or current successor requirement.

Protected signing values:

- [ ] `IOS_DISTRIBUTION_CERTIFICATE_BASE64`
- [ ] `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`
- [ ] `IOS_DISTRIBUTION_CERT_SHA256`
- [ ] `IOS_PROVISIONING_PROFILE_BASE64`
- [ ] `IOS_TEAM_ID`

Then:

- [ ] Run the protected production store workflow from `main`.
- [ ] Confirm the committed `pubspec.lock` is used with `--enforce-lockfile` and remains unchanged.
- [ ] Record `xcodebuild -version`.
- [ ] Record `xcrun --sdk iphoneos --show-sdk-version`.
- [ ] Produce the owner-signed IPA with real AdMob IDs.
- [ ] Confirm Team ID.
- [ ] Confirm bundle ID.
- [ ] Confirm provisioning application identifier.
- [ ] Confirm final codesign.
- [ ] Confirm certificate SHA-256.
- [ ] Confirm entitlements.
- [ ] Confirm final exported-IPA AdMob App ID + reviewed SKAdNetwork audit PASS.
- [ ] Save IPA checksum + release manifest.
- [ ] Upload to TestFlight.

## 8. Physical-device QA

Run the actual signed candidates on at least one current Android phone and one current iPhone.

Advertising/privacy:

- [ ] consent-required fresh install;
- [ ] no-form-required fresh install;
- [ ] Privacy Choices condition;
- [ ] no early ad request;
- [ ] consent refresh failure;
- [ ] ad load failure;
- [ ] offline/poor network;
- [ ] readings 1–3 uninterrupted;
- [ ] reading 4 is the first possible interstitial boundary;
- [ ] interstitial opportunity remains every 4th genuinely new saved reading;
- [ ] cadence persists across restart;
- [ ] no app-open on first cold start;
- [ ] no app-open before 5 completed readings;
- [ ] no app-open after background <1 minute;
- [ ] at least 6 hours between app-open impressions;
- [ ] at least 45 minutes between actual full-screen impressions across formats;
- [ ] failed ad-show attempts do not consume cooldown;
- [ ] no overlapping fullscreen ads;
- [ ] dismiss and continue immediately;
- [ ] no paywall/checkout/restore/subscription-management path.

Product regression:

- [ ] EN first run/core flows;
- [ ] TR first run/core flows;
- [ ] ES first run/core flows;
- [ ] FR first run/core flows;
- [ ] PT-BR first run/core flows;
- [ ] language persistence;
- [ ] Daily Guidance;
- [ ] deep readings;
- [ ] Mystic Mirror;
- [ ] Living Journal;
- [ ] Pattern Lab;
- [ ] Oracle;
- [ ] Mystic Path / Arcana;
- [ ] export/import/delete/protected transfer;
- [ ] PIN/biometrics;
- [ ] notifications allowed/denied;
- [ ] Reduce Motion;
- [ ] narrow-screen/localized text;
- [ ] crash-free startup.

## 9. Store privacy declarations

Use only the exact final signed candidates.

- [ ] Record exact Google Mobile Ads/UMP versions.
- [ ] Inspect Android merged manifest/permissions.
- [ ] Inspect iOS privacy manifest/Xcode privacy report.
- [ ] Decide and document ATT/IDFA behavior.
- [ ] Complete Google Play Data Safety.
- [ ] Complete Apple App Privacy.
- [ ] Confirm Privacy Policy matches actual runtime.

See `docs/STORE_PRIVACY_DECLARATION_WORKSHEET.md`.

## 10. Store listing/submission

- [ ] App name/subtitle/short description loaded from `STORE_RELEASE.md`.
- [ ] Five-language store metadata loaded.
- [ ] 50-image screenshot pack reviewed against the actual final UI.
- [ ] Age/content ratings completed accurately.
- [ ] Privacy URL live.
- [ ] Support URL live.
- [ ] Developer/marketing website live.
- [ ] TestFlight testing accepted.
- [ ] Play test accepted.
- [ ] Final App Store submission.
- [ ] Final Google Play submission.
- [ ] Both listings approved and publicly live.

## Final go-live definition

Do not call Mystic Tarot a live native-store product or call advertising revenue fully live until:

1. real owner-controlled AdMob IDs are in the signed binaries;
2. UMP production messaging is configured;
3. app-ads.txt is verified;
4. AdMob app readiness is `Ready`;
5. Android/iOS signing checks pass;
6. physical-device QA passes;
7. Apple App Privacy and Play Data Safety match the observed signed runtime;
8. any applicable Play production-access testing gate is complete;
9. App Store and Google Play approve the release.

Never paste signing passwords, private keys, keystores, P12 files or service-account JSON into source files, public issues or ordinary messages.

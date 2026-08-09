# Mystic Tarot — 2026 Store Technical Requirements

Status date: **2026-08-09**  
Release target: `1.23.0+33`  
Application / bundle ID: `com.tunabozcali.mystictarot`

This file records external store/SDK requirements that can change independently of the repository. Re-open the official references immediately before submission.

## Google Play — target API

Google's current Android/Play guidance states that starting **August 31, 2026**, new Android mobile apps and app updates submitted to Google Play must target **Android 16 / API level 36 or higher**.

Mystic Tarot therefore treats API 36 as the release floor now rather than waiting for the deadline.

The Android AAB audit reads the actual bundled manifest and fails if `android:targetSdkVersion < 36`.

Official references:

- `https://developer.android.com/google/play/requirements/target-sdk`
- `https://support.google.com/googleplay/android-developer/answer/11926878`

## Google Play — new personal developer account testing

If the Play Console account is a **personal developer account created after November 13, 2023**, Google's current production-access rule requires a closed test with at least **12 opted-in testers continuously for the previous 14 days** before applying for Production access.

Do not assume this requirement applies to an organization account or an older personal account. The actual Play Console dashboard is the source of truth.

Official reference:

- `https://support.google.com/googleplay/android-developer/answer/14151465`

## Apple — build tool / SDK submission floor

Apple's current submission requirement states that since **April 28, 2026**, apps uploaded to App Store Connect must be built with **Xcode 26 or later** using the **iOS 26 SDK** or the corresponding current platform SDK.

Mystic Tarot's production iOS workflow uses `macos-latest` and the current Flutter stable channel, but the store operator must still record the exact Xcode and iOS SDK versions from the final signed workflow run before upload.

Recommended evidence commands in the production run:

```bash
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-version
```

Official reference:

- `https://developer.apple.com/news/upcoming-requirements/`

## AdMob — app ownership and app readiness

Google currently requires new AdMob apps to verify app ownership with `app-ads.txt`. Apps cannot fully serve ads until app ownership is verified and the app passes AdMob app-readiness review.

Mystic's dedicated runbook:

- `docs/APP_ADS_TXT_GO_LIVE.md`

Official references:

- `https://support.google.com/admob/answer/14538460`
- `https://support.google.com/admob/answer/9363762`

## Google Play Data Safety — Mobile Ads

Google's current Mobile Ads disclosure guide says the SDK can automatically collect/share categories including IP address/general-location inference, product interactions, diagnostic/performance information and device/account identifiers for advertising, analytics and fraud-prevention purposes. Android advertising-ID collection can be controlled by app configuration, so the final signed manifest/runtime must be inspected.

Mystic's worksheet:

- `docs/STORE_PRIVACY_DECLARATION_WORKSHEET.md`

Official reference:

- `https://developers.google.com/admob/android/privacy/play-data-disclosure`

## Apple App Privacy — Mobile Ads

Apple requires App Privacy answers to include relevant data practices of third-party partners whose code is integrated into the app. Google's current iOS Mobile Ads disclosure guide describes possible processing including IP/general location, crash/diagnostic data, performance, device identifiers where applicable, advertising data and product interactions.

Do not select a blanket “no data collected” answer merely because Mystic's journal is local-first.

Official references:

- `https://developer.apple.com/app-store/app-privacy-details/`
- `https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy`
- `https://developers.google.com/admob/ios/privacy/data-disclosure`

## Final submission rule

A green repository build is necessary but not sufficient. Before store submission, capture and retain:

- exact Flutter version;
- exact Android target SDK from the audited AAB;
- exact Xcode version;
- exact iOS SDK version;
- exact Google Mobile Ads / UMP versions;
- signed AAB/IPA checksums;
- signing certificate fingerprints;
- UMP/ad/no-ad/error real-device evidence;
- final Apple App Privacy answers;
- final Google Play Data Safety answers;
- app-ads.txt verified status;
- AdMob app readiness status;
- Play production-access status for the actual developer account.

If any external requirement changes after this document's status date, the current official store documentation overrides this file.

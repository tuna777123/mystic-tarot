# Mystic Tarot — Store Privacy Declaration Worksheet

Release target: `1.23.0+33`  
Application / bundle ID: `com.tunabozcali.mystictarot`

This worksheet is for the owner/store operator completing **Google Play Data Safety** and **Apple App Privacy** for the final signed advertising build.

It is deliberately a worksheet, not a pre-filled declaration. Store answers must be based on the exact signed binary, resolved native SDK versions, enabled AdMob/UMP features, region configuration and observed runtime behavior.

## Non-negotiable rule

Do not select a broad statement such as “no data collected” merely because Mystic Tarot's private journal and tarot content are local-first.

The native build contains Google Mobile Ads / UMP, and advertising SDK data handling must be included in the store declarations where the current forms require it.

## Evidence to capture from the final signed candidate

Before filling either store form, record:

- [ ] Flutter app version/build number.
- [ ] Android package ID / iOS bundle ID.
- [ ] Exact resolved Google Mobile Ads native SDK version on Android.
- [ ] Exact resolved Google Mobile Ads native SDK version on iOS.
- [ ] Exact UMP SDK versions.
- [ ] Whether Android advertising ID collection is present/enabled in the final manifest/runtime.
- [ ] Whether iOS requests ATT authorization.
- [ ] Whether `NSUserTrackingUsageDescription` exists.
- [ ] Whether mediation is enabled.
- [ ] Whether any optional AdMob reporting/experiments are enabled.
- [ ] Whether Publisher First-Party ID is enabled or disabled.
- [ ] Final Android permissions/SDK audit report.
- [ ] Final iOS privacy manifest / Xcode privacy report where available.
- [ ] Real-device UMP consent and privacy-options screenshots/notes.

## Google Play Data Safety — Google Mobile Ads review points

Google's current Mobile Ads data-disclosure guidance says the SDK can automatically collect/share categories including:

- IP address, which may be used to estimate general location;
- user product interactions, including app launch/taps/video interaction information;
- diagnostic/performance information;
- device/account identifiers, including Android advertising ID, App Set ID and applicable device/account identifiers.

Google describes these as being used for advertising, analytics and fraud-prevention purposes, with SDK data encrypted in transit using TLS.

The Android advertising ID is configurable/optional at the app level, so do not assume it is present or absent: verify the final manifest/runtime and answer the Play form accordingly.

### Play worksheet

For every applicable data type, determine from the final runtime/form wording:

- [ ] Collected?
- [ ] Shared?
- [ ] Ephemeral processing exception applicable?
- [ ] Required or optional for the user?
- [ ] Purpose: advertising/marketing?
- [ ] Purpose: analytics?
- [ ] Purpose: fraud prevention/security/compliance?
- [ ] Other purpose introduced by an optional feature?
- [ ] Encrypted in transit?
- [ ] Deletion mechanism/form language applicable?

Also account for any other SDKs actually present in the final binary. Mystic Tarot's Android bundle audit intentionally blocks unapproved analytics/attribution SDK markers, but the store operator must still inspect the exact signed candidate.

## Apple App Privacy — Google Mobile Ads review points

Google's current iOS disclosure guidance says Google Mobile Ads may collect information such as:

- IP address / approximate general location;
- crash logs and diagnostic information;
- performance information;
- device identifiers, including advertising or other app/developer-bounded identifiers where applicable;
- advertising data such as ads shown;
- user product interactions such as launches, taps and video interactions.

Google Mobile Ads SDK versions 11.2.0+ support Apple's privacy manifest declarations. Inspect the privacy manifest and the final Xcode/privacy report rather than assuming the manifest alone completes the App Privacy questionnaire.

### Apple worksheet

For every data type shown by the final SDK/runtime, determine using the current App Store Connect wording:

- [ ] Data type category.
- [ ] Linked to user?
- [ ] Used for tracking?
- [ ] Purpose: third-party advertising?
- [ ] Purpose: developer advertising/marketing?
- [ ] Purpose: analytics?
- [ ] Purpose: app functionality?
- [ ] Purpose: other permitted reason?

## ATT / IDFA decision

Mystic Tarot's current source does **not** add a custom ATT request flow.

Do not enable an IDFA/ATT flow casually during dashboard setup. If the production decision changes and ATT is requested:

1. add the required `NSUserTrackingUsageDescription` text;
2. verify the actual OS ATT prompt behavior;
3. retest UMP ordering and ad-request gating;
4. update App Privacy disclosures;
5. re-run signed iPhone QA;
6. update review notes and screenshots/evidence if relevant.

Google's iOS privacy guidance recommends waiting for ATT authorization completion before loading ads when an app elects to request ATT.

## UMP verification

For the final signed Android and iOS candidates:

- [ ] Consent information refreshes on launch.
- [ ] Required consent UI displays for the configured test geography/state.
- [ ] Ads are not requested before `canRequestAds()` permits them.
- [ ] Privacy options appear only when UMP says they are required.
- [ ] Consent refresh failure does not block core product use.
- [ ] Ad load failure does not block core product use.

## Mystic local-first boundary

Mystic Tarot's own product design keeps journal text, tarot questions, reflection history, PIN-related state and pattern history local-first and does not intentionally upload that private content to a Mystic Tarot advertising backend.

That does **not** remove the need to disclose data processed independently by Google Mobile Ads / UMP in the native advertising build.

Local deletion of Mystic content also must not be described as deleting records independently handled by the advertising platform.

## Store submission evidence folder

Keep these together for the exact build submitted to review:

- [ ] signed AAB checksum + Android audit;
- [ ] signed IPA checksum + signing/provisioning evidence;
- [ ] resolved SDK/dependency versions;
- [ ] Android merged manifest;
- [ ] iOS privacy manifest/report;
- [ ] UMP screenshots/notes;
- [ ] ad/no-ad/failure-path QA notes;
- [ ] final Google Play Data Safety answers;
- [ ] final Apple App Privacy answers;
- [ ] date and operator who completed the forms.

## Official references — re-check at submission time

Google Mobile Ads Android Data Safety guidance:  
`https://developers.google.com/admob/android/privacy/play-data-disclosure`

Google Mobile Ads iOS App Store disclosure guidance:  
`https://developers.google.com/admob/ios/privacy/data-disclosure`

Google Mobile Ads iOS privacy strategies / ATT:  
`https://developers.google.com/admob/ios/privacy/strategies`

Google UMP documentation:  
`https://developers.google.com/admob/flutter/privacy`

The store operator must re-open the current official pages at submission time because SDK versions, store questionnaires and disclosure requirements can change independently of this repository.

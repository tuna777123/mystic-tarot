# Mystic Tarot — Final Delivery Handoff

Product version: `1.23.0+33`  
Application / bundle ID: `com.tunabozcali.mystictarot`  
Repository: `https://github.com/tuna777123/mystic-tarot`  
Public web app: `https://tuna777123.github.io/mystic-tarot/`  
Public website: `https://tuna777123.github.io/mystic-tarot/landing-en.html`  
Public press kit: `https://tuna777123.github.io/mystic-tarot/press-kit.html`  
Complete owner manual: `docs/OWNER_GUIDE_A_TO_Z.md`  
Final owner production checklist: `docs/OWNER_FINAL_CHECKLIST.md`  
Current external store requirements: `docs/STORE_TECHNICAL_REQUIREMENTS_2026.md`

This document is designed to be shared directly with a developer, designer, performance marketer, creator, PR partner, store operator, or technical reviewer.

## 1. Product delivered

Mystic Tarot is a Flutter product for web, Android and iOS packaging with:

- a complete 78-card tarot experience;
- Daily Guidance and deep readings;
- explainable reading synthesis and practical aligned actions;
- 24-hour Mystic Mirror reality checks;
- Living Journal, pattern memory and search;
- Oracle follow-up dialogue;
- Mystic Path, Arcana Vault, journeys, rituals, XP, achievements and streaks;
- local export/deletion and protected transfer;
- six-digit PIN and optional supported-device biometrics;
- reduced-motion protections;
- five complete launch languages: EN, TR, ES, FR, PT-BR.

For a feature-by-feature explanation, start with `docs/OWNER_GUIDE_A_TO_Z.md`.

## 2. Advertising-only business model

Mystic Tarot has **no paid subscription revenue model**.

- all formerly gated product functionality is available without payment;
- no subscription checkout is required;
- no restore flow is required to unlock the product;
- native Android/iOS revenue is designed to come only from Google Mobile Ads;
- Google User Messaging Platform gates eligible native ad requests;
- the public web edition remains ad-free.

Native ad design:

- app-open ads are eligible only after at least five completed readings, on a genuine returning foreground transition after at least one minute in the background, with at least six hours between app-open impressions;
- an interstitial opportunity occurs only after every fourth genuinely new saved reading, so the first three new readings remain uninterrupted;
- a shared 45-minute cross-format full-screen gap applies after any actual app-open or interstitial impression;
- cooldown state begins only after a real ad impression, so failed show attempts do not consume the user's cooldown;
- cadence persists across process restarts;
- no permanent banner covering the tarot interface;
- no rewarded-ad requirement for a core feature.

RevenueCat and `purchases_flutter` are removed from the production dependency graph and runtime. Small pure-Dart historical compatibility shapes may remain behind no-op/fail-closed application interfaces, but there is no billing SDK, purchase provider, checkout, restore or paid entitlement behavior.

## 3. Public web / website

Delivered public surfaces include:

- installable PWA;
- five localized marketing landing pages;
- EN/TR/ES/FR/PT-BR Privacy, Terms and Support pages;
- robots.txt and sitemap;
- canonical, Open Graph, Twitter Card and structured metadata;
- install prompt and branded 404;
- public press/sharing page;
- post-deployment live URL verification.

The public web edition is a product demo/discovery surface and is not a claim that native stores have approved the app.

## 4. Native advertising technical delivery

Source contains:

- official Google Mobile Ads Flutter integration;
- UMP consent information refresh on launch;
- consent form handling where required;
- `canRequestAds()` as the final ad-request gate;
- privacy-options visibility based on `PrivacyOptionsRequirementStatus.required`;
- Google demo app/ad-unit IDs for safe QA;
- environment/dart-define slots for real production AdMob IDs;
- app-open ad cache/expiry, five-reading minimum-use, one-minute background-duration and six-hour app-open frequency handling;
- every-fourth-new-reading interstitial frequency cap at the natural completion boundary;
- shared 45-minute cross-format full-screen cooldown based on actual impressions;
- persisted cadence across native process restarts;
- no-ad fallback that never blocks the product;
- Android audit policy that distinguishes reviewed Google advertising permissions from unrelated sensitive permissions and unapproved trackers.

Required production identifiers are documented in `STORE_RELEASE.md` and `docs/OWNER_FINAL_CHECKLIST.md`.

## 5. 2026 store technical gates

Current dated requirements are maintained in `docs/STORE_TECHNICAL_REQUIREMENTS_2026.md` and must be rechecked immediately before submission.

### Google Play

Mystic's Android artifact audit now reads the **actual bundled manifest** and rejects a target SDK below **API 36**. This is deliberately enforced before Google's August 31, 2026 Android 16 / API 36 submission deadline.

If the owner's Google Play developer account is a personal account created after November 13, 2023 and the Play Console applies the new-account production-access rule, complete the required closed test shown by Play Console before Production access. Current Google guidance requires at least 12 testers continuously opted in for 14 days.

### Apple

The current Apple submission floor requires App Store Connect uploads to be built with Xcode 26 or later using the iOS 26 SDK or the corresponding current successor requirement. The exact Xcode/iOS SDK versions from the final signed production workflow must be recorded with the submission evidence.

## 6. app-ads.txt + AdMob app readiness

Native advertising is not treated as fully live merely because an AAB/IPA can request ads.

Follow `docs/APP_ADS_TXT_GO_LIVE.md`.

If `tuna777123.github.io` is used as the store developer-website hostname, the expected root file is:

`https://tuna777123.github.io/app-ads.txt`

The project path alone is not the root ownership location:

`https://tuna777123.github.io/mystic-tarot/app-ads.txt`

Do not invent the AdMob publisher line. Copy the personalized snippet from the owner's AdMob dashboard, publish it at the developer-host root, link the same host from the supported store listing, confirm the file is found/verified, and confirm AdMob app readiness reaches `Ready`.

## 7. Store / release operations

Delivered source-side release machinery includes:

- permanent application identifier `com.tunabozcali.mystictarot`;
- committed root `pubspec.lock` for the Flutter application dependency graph;
- lockfile-enforced dependency installation across CI, web preview/deployment, screenshots, QA candidates and protected production store workflows;
- a regression contract that rejects unlocked workflow dependency installs and lockfile mutation during generated-platform/dependency setup;
- Android AAB release/audit pipeline;
- Android target-SDK release floor enforcement;
- unsigned iOS release verification;
- protected signing contracts;
- protected production AdMob ID contracts that reject Google demo IDs;
- strict Android signature checks;
- pinned `bundletool validate`;
- package/version/SDK/ABI validation;
- sensitive-permission auditing;
- unapproved analytics/attribution SDK denylist;
- Kotlin warning policy;
- localized store metadata/release-note handoff;
- deterministic localized screenshot generation/audit.

Verified builds also run the fail-closed advertising-only UI materializer before analysis, tests and packaging so legacy paid-tier labels cannot leak into delivered builds.

Canonical operator instructions: `STORE_RELEASE.md`.

## 8. Marketing delivery

`docs/MARKETING_LAUNCH_KIT.md` contains:

- paid-social copy;
- organic and creator copy;
- 15-second / 20-second video briefs;
- EN/TR/ES/FR/PT-BR campaign messaging;
- PR one-liner;
- UTM convention;
- advertising-supported product disclosure;
- creative guardrails;
- no-fake-proof / no-unsafe-claim rules.

Public campaign traffic can use the live localized website today. Native install campaigns should wait until actual approved store listing URLs exist.

## 9. Privacy boundary

Mystic's journal, tarot questions, profile content, reflection history and PIN information are local-first product data.

Native Android/iOS builds integrate Google Mobile Ads and UMP, so final Apple App Privacy and Google Play Data Safety declarations must reflect the actual signed advertising runtime and third-party SDK behavior. The public web edition does not embed the native AdMob SDK.

Use `docs/STORE_PRIVACY_DECLARATION_WORKSHEET.md` with the exact signed AAB/IPA. Local in-app deletion does not claim to erase records independently handled by an advertising platform.

## 10. Safe advertising claims

Use:

- “A private, reflection-first tarot ritual.”
- “Return after 24 hours and compare the reading with what actually happened.”
- “Notice recurring cards and personal patterns over time.”
- “Local-first journal.”
- “No paid subscription.”
- “Native apps are advertising-supported.”
- “The public web edition is ad-free.”

Do not use:

- guaranteed prediction claims;
- medical, mental-health, legal, financial or emergency-advice claims;
- fake ratings, user totals, testimonials, press logos, scarcity, awards or download counts;
- a native ad-free claim;
- a fake paid/premium price;
- App Store or Google Play availability claims before the final signed listings are actually live.

## 11. What is intentionally not represented as complete

Source work cannot complete owner-controlled external accounts. Before native production availability, the owner still must complete:

1. Apple Developer / App Store Connect ownership and agreements.
2. Google Play Console ownership and agreements.
3. Any applicable Play personal-account closed-test/Production-access gate.
4. Google AdMob Android + iOS apps.
5. Production app-open and interstitial units for both platforms.
6. AdMob Privacy & messaging / UMP production configuration.
7. Real AdMob IDs in protected release configuration.
8. `MYSTIC_USE_TEST_ADS=false` for production.
9. A controlled developer website root.
10. Personalized `app-ads.txt` root hosting and verification.
11. AdMob app readiness = `Ready`.
12. Android upload signing material.
13. Apple distribution certificate/provisioning.
14. Genuinely signed native candidates.
15. Android audit proof including target SDK >= API 36.
16. Final Xcode/iOS SDK evidence satisfying Apple's current submission floor.
17. Real Android+iPhone consent/ad/no-ad/failure-path QA.
18. Apple App Privacy and Google Play Data Safety from actual signed runtime behavior.
19. TestFlight / Play testing and Play pre-launch reporting.
20. Final store screenshots/evidence where required.
21. Store review and production approval.

Until those steps pass, do not describe native App Store / Google Play availability or real advertising revenue as live.

## 12. Public links to share

- Web app: `https://tuna777123.github.io/mystic-tarot/`
- Product website: `https://tuna777123.github.io/mystic-tarot/landing-en.html`
- Press kit: `https://tuna777123.github.io/mystic-tarot/press-kit.html`
- Privacy: `https://tuna777123.github.io/mystic-tarot/privacy.html`
- Terms: `https://tuna777123.github.io/mystic-tarot/terms.html`
- Support: `https://tuna777123.github.io/mystic-tarot/support.html`
- Repository: `https://github.com/tuna777123/mystic-tarot`

## 13. Technical collaborator starting points

- Owner guide: `docs/OWNER_GUIDE_A_TO_Z.md`
- Final owner checklist: `docs/OWNER_FINAL_CHECKLIST.md`
- Store handoff: `STORE_RELEASE.md`
- Current store technical gates: `docs/STORE_TECHNICAL_REQUIREMENTS_2026.md`
- app-ads.txt runbook: `docs/APP_ADS_TXT_GO_LIVE.md`
- Store privacy worksheet: `docs/STORE_PRIVACY_DECLARATION_WORKSHEET.md`
- Marketing kit: `docs/MARKETING_LAUNCH_KIT.md`
- Advertising model: `docs/AD_REVENUE_MODEL.md`
- Production signing guidance: `docs/PRODUCTION_SIGNING_FINGERPRINTS.md`
- Native ad service: `lib/src/ad_revenue_service.dart`
- Android artifact audit: `tool/audit_android_bundle.dart`
- Advertising-only UI materializer: `tool/materialize_ad_only_ui.dart`
- Public launch verifier: `tool/verify_launch_surface.sh`

## 14. Handoff message

> Mystic Tarot `1.23.0+33` is a free, five-language, local-first Flutter tarot product. Its main differentiator is Mystic Mirror: readings return after 24 hours as reality checks and become private pattern evidence over time. Native Android/iOS monetization is advertising-only through Google Mobile Ads with UMP consent gating; the public web edition is ad-free. RevenueCat and the billing SDK are removed, and there is no paid subscription business model. The Flutter dependency graph is committed and enforced in release workflows so validated QA and signed production cannot silently resolve different transitive packages. The Android release audit enforces API 36+, and the owner handoff explicitly covers Apple's current Xcode/iOS SDK floor, app-ads.txt ownership verification, AdMob app readiness, store privacy declarations and any applicable Play testing gate. Start with `docs/OWNER_FINAL_CHECKLIST.md` for production and `docs/OWNER_GUIDE_A_TO_Z.md` for the complete product. Native store availability and real ad revenue must not be claimed until production AdMob IDs, signing, app-ads.txt/readiness, real-device QA, store privacy declarations and store approvals are complete.

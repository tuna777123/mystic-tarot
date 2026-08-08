# Mystic Tarot — Final Delivery Handoff

Product version: `1.23.0+33`  
Application / bundle ID: `com.tunabozcali.mystictarot`  
Repository: `https://github.com/tuna777123/mystic-tarot`  
Public web app: `https://tuna777123.github.io/mystic-tarot/`  
Public website: `https://tuna777123.github.io/mystic-tarot/landing-en.html`  
Public press kit: `https://tuna777123.github.io/mystic-tarot/press-kit.html`  
Complete owner manual: `docs/OWNER_GUIDE_A_TO_Z.md`

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

- app-open ads only after at least three completed readings, on eligible returning foreground transitions of 30 seconds or longer, with a two-hour minimum interval;
- interstitial opportunity after every third genuinely new saved reading;
- cadence persists across process restarts;
- no permanent banner covering the tarot interface;
- no rewarded-ad requirement for a core feature.

`purchases_flutter` and RevenueCat are removed from the production dependency graph and runtime source. Only small pure-Dart historical compatibility DTO/interface shapes remain, backed by a fail-closed no-op client with no store SDK, network purchase provider, checkout, restore or paid entitlement behavior.

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

- `google_mobile_ads ^9.0.0` integration;
- UMP consent information refresh on every launch;
- consent form handling where required;
- `canRequestAds()` as the final ad-request gate;
- privacy-options visibility based on `PrivacyOptionsRequirementStatus.required`;
- Google demo app/ad-unit IDs for safe QA;
- environment/dart-define slots for real production AdMob IDs;
- app-open ad cache/expiry, minimum-use, background-duration and frequency handling;
- every-third-new-reading interstitial frequency cap;
- persisted cadence across native process restarts;
- no-ad fallback that never blocks the product;
- Android audit policy that distinguishes reviewed Google advertising permissions from unrelated sensitive permissions and unapproved trackers.

Required production identifiers are documented in `STORE_RELEASE.md` and `docs/OWNER_GUIDE_A_TO_Z.md`.

## 5. Store / release operations

Delivered source-side release machinery includes:

- permanent application identifier `com.tunabozcali.mystictarot`;
- Android AAB release/audit pipeline;
- unsigned iOS release verification;
- protected signing contracts;
- protected production AdMob ID contracts that reject Google demo IDs;
- strict Android signature checks;
- pinned `bundletool validate`;
- package/version/ABI validation;
- sensitive-permission auditing;
- unapproved analytics/attribution SDK denylist;
- Kotlin warning policy;
- localized store metadata/release-note handoff;
- deterministic localized screenshot generation/audit.

Verified builds also run the fail-closed advertising-only UI materializer before analysis, tests and packaging so legacy paid-tier labels cannot leak into delivered builds.

Canonical operator instructions: `STORE_RELEASE.md`.

## 6. Marketing delivery

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

## 7. Privacy boundary

Mystic’s journal, tarot questions, profile content, reflection history and PIN information are local-first product data.

Native Android/iOS builds integrate Google Mobile Ads and UMP, so final Apple App Privacy and Google Play Data Safety declarations must reflect the actual signed advertising runtime. The public web edition does not embed the native AdMob SDK.

Local in-app deletion does not claim to erase records independently handled by an advertising platform.

## 8. Safe advertising claims

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

## 9. What is intentionally not represented as complete

Source work cannot complete owner-controlled external accounts. Before native production availability, the owner still must complete:

1. Apple Developer / App Store Connect ownership and agreements.
2. Google Play Console ownership and agreements.
3. Google AdMob Android + iOS apps.
4. Production app-open and interstitial units for both platforms.
5. AdMob Privacy & messaging / UMP production configuration.
6. Real AdMob IDs in protected release configuration.
7. `MYSTIC_USE_TEST_ADS=false` for production.
8. Android upload signing material.
9. Apple distribution certificate/provisioning.
10. Genuinely signed native candidates.
11. Real Android+iPhone consent/ad/no-ad/failure-path QA.
12. Apple App Privacy and Google Play Data Safety from actual signed runtime behavior.
13. TestFlight / Play closed testing and Play pre-launch reporting.
14. Final store screenshots/evidence where required.
15. Store review and production approval.

Until those steps pass, do not describe native App Store / Google Play availability or real advertising revenue as live.

## 10. Public links to share

- Web app: `https://tuna777123.github.io/mystic-tarot/`
- Product website: `https://tuna777123.github.io/mystic-tarot/landing-en.html`
- Press kit: `https://tuna777123.github.io/mystic-tarot/press-kit.html`
- Privacy: `https://tuna777123.github.io/mystic-tarot/privacy.html`
- Terms: `https://tuna777123.github.io/mystic-tarot/terms.html`
- Support: `https://tuna777123.github.io/mystic-tarot/support.html`
- Repository: `https://github.com/tuna777123/mystic-tarot`

## 11. Technical collaborator starting points

- Owner guide: `docs/OWNER_GUIDE_A_TO_Z.md`
- Store handoff: `STORE_RELEASE.md`
- Marketing kit: `docs/MARKETING_LAUNCH_KIT.md`
- Advertising model: `docs/AD_REVENUE_MODEL.md`
- Production signing guidance: `docs/PRODUCTION_SIGNING_FINGERPRINTS.md`
- Native ad service: `lib/src/ad_revenue_service.dart`
- Advertising-only UI materializer: `tool/materialize_ad_only_ui.dart`
- Public launch verifier: `tool/verify_launch_surface.sh`

## 12. Handoff message

Copy/paste this when sending the project to a collaborator:

> Mystic Tarot `1.23.0+33` is a free, five-language, local-first Flutter tarot product. Its main differentiator is Mystic Mirror: readings return after 24 hours as reality checks and become private pattern evidence over time. Native Android/iOS monetization is advertising-only through Google Mobile Ads with UMP consent gating; the public web edition is ad-free. RevenueCat and the billing SDK are removed, and there is no paid subscription business model. Start with `docs/OWNER_GUIDE_A_TO_Z.md` for the entire product and `STORE_RELEASE.md` for the native release path. Native store availability and real ad revenue must not be claimed until production AdMob IDs, signing, real-device QA and store approvals are complete.

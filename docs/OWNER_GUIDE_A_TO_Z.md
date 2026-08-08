# Mystic Tarot — Owner Guide A to Z

Product version: `1.23.0+33`  
Application ID / bundle ID: `com.tunabozcali.mystictarot`  
Launch languages: **EN, TR, ES, FR, PT-BR**  
Public web app: `https://tuna777123.github.io/mystic-tarot/`  
Website: `https://tuna777123.github.io/mystic-tarot/landing-en.html`  
Press kit: `https://tuna777123.github.io/mystic-tarot/press-kit.html`

This is the owner/operator manual for Mystic Tarot. It explains the product, code, business model, advertising, privacy, release system, marketing, store operations, QA and the remaining account-owned work.

---

## A — App in one sentence

**Mystic Tarot turns a tarot reading into a private 24-hour reality check and then helps the user notice the cards, emotions and themes that keep returning over time.**

It is positioned as reflection and entertainment, not factual fortune-telling or professional advice.

## B — Business model

### Advertising-only business model

Mystic Tarot is free to use.

- No paid subscription.
- No paid reading pack.
- No paid feature unlock.
- No required account.
- Native Android/iOS revenue comes from advertising.
- The public web edition remains ad-free.

The source still retains dormant compatibility code around the previous subscription architecture so the mature product flow does not need a risky full rewrite. That compatibility layer does not initialize a purchase provider or sell/restore products. Formerly gated features are treated as unlocked.

## C — Core user journey

1. User opens Mystic Tarot.
2. Device language can seed the first supported interface language.
3. User completes onboarding and chooses their intent/profile preferences.
4. User starts Daily Guidance or another reading.
5. Cards are selected and revealed through the cinematic tarot flow.
6. Mystic explains the reading and provides an aligned action rather than a guaranteed prediction.
7. The reading is saved locally in the Living Journal.
8. After 24 hours Mystic Mirror asks what actually happened.
9. Repeated cards, emotional changes and historical evidence build a private pattern history.
10. The user can continue into Oracle dialogue, journeys, Mystic Path, Arcana Vault and other long-term loops.

## D — Daily Guidance

Daily Guidance is the easiest daily habit loop. It gives the user a focused reading and a practical action. The product then creates continuity by bringing that reading back through Mystic Mirror rather than letting it disappear after one session.

## E — Explainable readings

Mystic does not present a mysterious answer without context. Reading explanation surfaces the inputs used to frame the interpretation, including cards, orientation and reading position. The product is designed around reflection, transparency and bounded language.

## F — Full tarot product

The application contains the complete 78-card tarot deck, localization of card names/meanings/advice, upright and reversed handling, multiple reading types and deep spreads.

The experience includes:

- Daily Guidance;
- focused readings;
- deep spreads;
- card reveal ritual;
- explainable synthesis;
- aligned actions;
- saved history;
- recurring-card patterns;
- Oracle follow-up dialogue.

## G — Growth and retention loops

Retention is built into the product rather than depending only on push notifications.

Important loops:

- daily reading;
- 24-hour Mystic Mirror return;
- streak and XP;
- rituals;
- Arcana collection/progression;
- recurring-card pattern discovery;
- journeys;
- Living Journal;
- next-step recommendations;
- private intelligence/pattern summaries.

## H — Home screen

The home experience routes the user to the next meaningful action: first reading, daily return, a due Mystic Mirror, pattern evidence or another product destination. The goal is to avoid a dead dashboard with no clear next step.

## I — Intelligence / patterns

Historical readings are converted into explainable private evidence. The app can identify recurring cards/themes and changes in the user’s own stored history. These are product-generated reflections, not medical or psychological diagnoses.

## J — Journal

The Living Journal is local-first and has recovery protections.

It supports:

- reading history;
- Mystic Mirror evidence;
- Oracle history;
- search;
- pattern/map views;
- backup/recovery behavior;
- export;
- deletion;
- protected transfer functionality.

A successful genuinely new reading save is also the natural event used by the native advertising cadence.

## K — Key privacy principle

Private tarot content should not become advertising content.

Mystic’s journal/profile/reflection data is local-first. The app does not need a Mystic account server to function. AdMob/UMP are integrated as the native advertising provider, but private journal text, tarot questions, PINs and local reflection history are not intentionally sent to a Mystic Tarot backend for ad targeting.

## L — Languages

Launch languages are:

- English;
- Turkish;
- neutral international Spanish;
- French;
- Brazilian Portuguese.

The app, public legal pages, store handoff and marketing surfaces are designed around these five launch languages. German and Italian code paths may exist historically but are not part of the public launch language set until full end-to-end QA says otherwise.

## M — Mystic Mirror

Mystic Mirror is the strongest product differentiator.

A reading creates a future check-in. After roughly 24 hours the user comes back and compares the interpretation/action with reality. The answer becomes evidence in the user’s own local pattern history.

Marketing shorthand:

> Read today. Check reality tomorrow.

## N — Native advertising architecture

The native business model uses the official Google Mobile Ads Flutter plugin and Google User Messaging Platform.

Current formats:

### App-open

An app-open ad is preloaded but is eligible only after the user has completed at least three readings. It is considered only after the app has spent at least 30 seconds in the background, and there is a two-hour minimum interval between app-open impressions. Cached app-open ads expire after four hours. The app does not block cold-start bootstrap waiting for an ad.

### Interstitial

An interstitial opportunity is created after every **third genuinely new saved reading**. The first two new readings remain uninterrupted. The cadence persists across process restarts. If an ad is not ready, the product continues rather than blocking the user.

### Intentionally not used

- no permanent banner over the tarot interface;
- no rewarded ad required to unlock core functionality;
- no paid “premium” checkout;
- no ad on the public web edition.

## O — Obtaining AdMob production IDs

QA uses Google’s official demo IDs. They are not production revenue IDs.

Before production, create Android and iOS apps in your AdMob account and create app-open + interstitial units for both platforms.

Required protected values:

- `ADMOB_ANDROID_APP_ID`
- `ADMOB_IOS_APP_ID`
- `ADMOB_ANDROID_APP_OPEN_ID`
- `ADMOB_IOS_APP_OPEN_ID`
- `ADMOB_ANDROID_INTERSTITIAL_ID`
- `ADMOB_IOS_INTERSTITIAL_ID`

Production must set:

`MYSTIC_USE_TEST_ADS=false`

Do not publish a production store candidate using Google demo ad unit IDs.

## P — Privacy consent for advertising

The native app requests current Google UMP consent information on launch. Where required, UMP can show the consent form. Advertising requests are gated by `ConsentInformation.canRequestAds()`.

The owner must configure the correct Privacy & messaging message in the AdMob dashboard before the production store release.

The native UI exposes the advertising privacy choices entry point only when UMP reports `PrivacyOptionsRequirementStatus.required`. The current source does not add a custom ATT/IDFA request flow; if the owner later enables an IDFA/ATT message in AdMob, the corresponding iOS usage description and final privacy declarations must be added and retested before release.

## Q — Quality gates

The repository is designed to fail closed rather than silently publish a broken build.

Key gates include:

- Dart formatting;
- clean diff;
- static analysis;
- full Flutter tests;
- web release build;
- Android release AAB build;
- unsigned iOS release verification;
- Android strict JAR signature checks;
- pinned `bundletool validate`;
- package/version/ABI audit;
- sensitive Android permission denylist;
- reviewed Google advertising permission classification;
- denylist for unapproved analytics/attribution SDKs;
- Kotlin plugin warning policy;
- public launch/SEO/claim verification;
- GitHub Pages live endpoint verification;
- localized screenshot generation/audit.

## R — Revenue logic

Revenue begins only when a signed native build uses your real AdMob application/ad-unit IDs and is serving eligible ads.

The source code alone cannot create revenue. An AdMob account, approved apps/ad units, privacy configuration, traffic and valid impressions are all required.

Revenue should be optimized around retention first. Showing more ads is not automatically better if it destroys reading completion or day-1/day-7 retention.

Recommended first metrics:

- DAU / MAU;
- day-1 and day-7 retention;
- readings per active user;
- percentage returning for Mystic Mirror;
- interstitial impressions per DAU;
- app-open impressions per DAU;
- ad fill rate;
- eCPM by country/platform;
- crash-free sessions;
- store rating;
- uninstall trend after ad changes.

## S — Store release

Canonical store handoff: `STORE_RELEASE.md`.

Before native release, the owner must complete:

- Apple Developer / App Store Connect ownership and agreements;
- Google Play Console ownership and agreements;
- production signing materials;
- AdMob Android/iOS apps;
- production app-open/interstitial units;
- UMP Privacy & messaging setup;
- App Privacy / Data Safety forms based on the final signed advertising build;
- TestFlight / Play closed testing;
- real-device consent/ad testing;
- final store review/submission.

## T — Test ads vs real ads

Development and CI must use test advertising. Real ad units should not be exercised as development traffic.

Production requires real IDs and `MYSTIC_USE_TEST_ADS=false`.

A release process should fail rather than accidentally ship Google demo IDs as the monetization configuration.

## U — User data and deletion

The app supports local export/deletion flows. Deleting local Mystic content does not imply deletion of records independently processed by an advertising platform. Store privacy text and user support must make that distinction accurately.

The final signed runtime must be used to complete Apple App Privacy and Google Play Data Safety.

## V — Visual identity

Mystic Tarot uses a dark, premium, cinematic visual system: deep violet/ink backgrounds, gold highlights, tarot symbols, restrained motion and accessibility-aware reduced-motion behavior.

Store assets include a deterministic screenshot pipeline across five languages and two device profiles.

## W — Web edition

The web edition is the public try-before-store surface:

`https://tuna777123.github.io/mystic-tarot/`

It is installable as a PWA and remains ad-free. It is useful for:

- demos;
- press;
- creator outreach;
- campaign landing traffic;
- product evaluation before native listings are live.

The public web edition does not represent native store approval.

## X — eXternal services you own

Repository automation cannot create or accept contracts in these external accounts for you:

- Apple Developer / App Store Connect;
- Google Play Console;
- Google AdMob;
- tax/banking/trader agreements;
- production signing certificates/keystores;
- store review approvals.

These are the final owner-controlled production boundary.

## Y — Your launch order

Recommended sequence:

1. Keep the public web/press kit live.
2. Create/verify Apple and Google developer accounts.
3. Create both native apps in AdMob.
4. Create Android + iOS app-open and interstitial units.
5. Configure UMP Privacy & messaging.
6. Put production AdMob IDs into protected release configuration.
7. Produce signed internal candidates.
8. Test on one current Android phone and one current iPhone.
9. Verify consent, no-consent, ad-load failure, offline/poor network and normal reading flows.
10. Verify no checkout/restore/paywall remains in the user path.
11. Complete App Privacy and Data Safety from actual evidence.
12. Upload to TestFlight / Play closed testing.
13. Fix pre-launch/store review findings.
14. Publish native listings.
15. Only after listing URLs are live, run install campaigns and use official store badges.

## Z — Zero ambiguity handoff

When handing Mystic Tarot to another developer, agency, advertiser or operator, tell them:

> Mystic Tarot `1.23.0+33` is a free, local-first, five-language Flutter tarot product. Its core differentiator is Mystic Mirror: a reading returns after 24 hours as a reality check and contributes to private pattern history. Native Android/iOS monetization is advertising-only through Google Mobile Ads with UMP consent gating; the public web edition is ad-free. There is no paid subscription business model. Production revenue is not considered live until the owner configures real AdMob IDs, privacy messaging, signed store candidates and real-device QA.

---

## Technical map

Important files:

- `lib/main.dart` — bootstrap; keeps optional services non-blocking.
- `lib/src/app.dart` — primary application shell and routing.
- `lib/src/ad_revenue_service.dart` — native advertising / UMP / persistent frequency cap.
- `lib/src/reading_journal_store.dart` — local journal persistence and genuine-new-reading ad trigger.
- `lib/src/store_purchase_service.dart` — dormant compatibility shim; no active subscription revenue.
- `lib/src/store_ready_premium_screen.dart` — legacy route converted to free/ad-supported explanation.
- `tool/configure_store_identifiers.dart` — permanent bundle IDs + native AdMob app ID injection.
- `tool/audit_android_bundle.dart` — artifact audit.
- `tool/src/android_bundle_audit.dart` — permission/SDK/signature policy.
- `tool/verify_launch_surface.sh` — public launch/business-model contract.
- `STORE_RELEASE.md` — store operator handoff.
- `docs/MARKETING_LAUNCH_KIT.md` — campaign/creator/PR handoff.
- `docs/FINAL_DELIVERY.md` — final technical/shareable release summary.
- `web/press-kit.html` — public share page.

## What is delivered vs what is not

### Delivered in source

- full product experience;
- five launch languages;
- local-first journal/history;
- app lock and accessibility protections;
- public PWA/site/legal/support surfaces;
- ad-only native architecture;
- UMP consent gate and conditional privacy-options entry point;
- app-open + frequency-capped interstitial logic;
- persisted advertising cadence;
- test AdMob configuration for QA;
- build/audit/CI infrastructure;
- store and marketing handoffs.

### Not represented as complete until owner/account work passes

- real AdMob app/ad-unit creation;
- real AdMob revenue;
- production UMP dashboard configuration;
- production signing ownership;
- genuine signed store candidates;
- real-device advertising/privacy validation;
- Apple/Google privacy forms;
- TestFlight/Play approval;
- production store approval.

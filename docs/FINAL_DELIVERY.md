# Mystic Tarot — Final Delivery Handoff

Product version: `1.22.3+32`  
Application / bundle ID: `com.tunabozcali.mystictarot`  
Repository: `https://github.com/tuna777123/mystic-tarot`  
Public web app: `https://tuna777123.github.io/mystic-tarot/`  
Public website: `https://tuna777123.github.io/mystic-tarot/landing-en.html`  
Public press kit: `https://tuna777123.github.io/mystic-tarot/press-kit.html`

This document is designed to be shared directly with a developer, designer, performance marketer, creator, PR partner, store-operations contractor, or technical reviewer.

## 1. What is delivered

### Product

- Flutter product source for web, Android, and iOS packaging.
- Complete 78-card tarot product experience.
- Daily Guidance and focused deep readings.
- 24-hour Mystic Mirror reality check.
- Pattern memory, weekly evidence, Mystic Path, Arcana Vault, rituals, XP, achievements, and streaks.
- Private local journal with export and deletion.
- Six-digit PIN and optional supported-device biometrics.
- Five complete launch languages: EN, TR, ES, FR, PT-BR.
- Mystic Plus product surface prepared for official store products and RevenueCat entitlement `mystic_plus`.

### Public web / website

- Installable PWA.
- Five localized marketing landing pages.
- Five-language Privacy, Terms, and Support surfaces.
- `robots.txt`, sitemap, canonical URLs, Open Graph, Twitter Card, structured-data metadata, branded icon set, install prompt, reduced-motion protections, and a branded 404 page.
- Public press & sharing page for collaborators and media.
- Post-deployment live verification for the PWA root, product landing, public press kit, and all 15 localized Privacy/Terms/Support pages.

### Store / release operations

- App Store and Google Play metadata pack.
- Permanent product identifiers.
- Five-language release notes and store listing copy.
- Production signing workflow contracts.
- Android AAB validation and audit pipeline.
- Unsigned iOS release verification pipeline.
- Deterministic five-language screenshot generation and package audit.
- 50 verified QA store screenshots across Apple 6.9-inch and Google Play phone profiles.
- RevenueCat production setup guide and fail-closed product behavior.

### Marketing

- Paid-social launch copy.
- Organic and creator copy.
- 15-second and 20-second short-form creative briefs.
- Five-language primary campaign messaging.
- PR one-liner and creator brief.
- UTM naming convention.
- Claim-safety / no-fake-proof advertising guardrails.

See `docs/MARKETING_LAUNCH_KIT.md`.

## 2. Verified final launch source baseline

Mystic Tarot `1.22.3+32` final public-launch hardening was verified on PR #133 head:

`ef1714e394f5edc65814c89db7abe96ee9e4b34d`

and squash-merged to the product launch baseline on `main`:

`63504ce4a19bb5b1c600932f4a2c26c1250007b6`

The final-head release chain passed:

- changed-Dart formatting and clean-diff checks;
- public launch / SEO / advertising-claim contract;
- static analysis with no issues;
- the complete Flutter test suite;
- web release build;
- Android AAB release build;
- unsigned iOS release and application verification;
- strict Android jarsigner and `bundletool validate` checks;
- package, version, ABI, sensitive-permission, and advertising/analytics-class audits;
- Built-in Kotlin exact-warning-set audit;
- artifact uploads for web, AAB, Android audit, and Built-in Kotlin audit.

Post-merge `pages/deployment = success` on `63504ce4a19bb5b1c600932f4a2c26c1250007b6` additionally proves the live Pages workflow passed `curl --fail` plus page-specific content-marker verification for **18 public endpoints**: the PWA root, product landing, public press kit, and all 15 localized Privacy/Terms/Support pages.

The signed native-store preflight intentionally remains scoped to its existing 17 store-critical public URLs. The marketing press kit is not a prerequisite for signing a native candidate.

## 3. Verified QA Android artifact baseline

Final verified QA artifact from the source set merged by PR #133:

Package: `com.tunabozcali.mystictarot`  
Version: `1.22.3+32`  
Size: `61,659,974` bytes (`58.80 MiB`)  
SHA-256: `17356fdedcc2a61afdba9124eeda191871bf4ffbd0648185cab6db88f3d18882`  
ABIs: `arm64-v8a`, `armeabi-v7a`, `x86_64`

Verified checks:

- strict JAR signature policy: PASS;
- `bundletool validate`: PASS;
- sensitive permission denylist: clear;
- advertising / analytics class denylist: clear;
- Built-in Kotlin audit: PASS with reviewed warnings exactly `flutter_timezone, purchases_flutter`, unknown/regressed plugins none, policy drift none.

This artifact is a QA release AAB. It is **not** the final Google Play upload-signed production candidate.

## 4. Verified screenshot baseline

The final public-launch PR did not modify screenshot generator or screenshot-product source. The canonical audited screenshot payload therefore remains the already visually reviewed main set:

- App version: `1.22.3+32`.
- Screenshot-source main baseline: `dedd420add86733169e9d2de6e0257f0a86094a8`.
- Exactly 50 PNGs.
- 25 Apple 6.9-inch screenshots at `1290×2796`.
- 25 Google Play phone screenshots at `1080×1920`.
- EN, TR, ES, FR, PT-BR.
- 8-bit RGB, no alpha.
- Full decode, dimension, file-size, package-allowlist, and visual-variation audit.
- All 50 screenshot pixel payloads matched the manually reviewed accepted set.

These are audited QA marketing screenshots. Final store evidence from genuinely signed candidates remains a store/device-owned release step.

## 5. Public links to share

### End users / creators

- Web app: `https://tuna777123.github.io/mystic-tarot/`
- Product website: `https://tuna777123.github.io/mystic-tarot/landing-en.html`
- Press kit: `https://tuna777123.github.io/mystic-tarot/press-kit.html`

### Legal / support

- Privacy: `https://tuna777123.github.io/mystic-tarot/privacy.html`
- Terms: `https://tuna777123.github.io/mystic-tarot/terms.html`
- Support: `https://tuna777123.github.io/mystic-tarot/support.html`

### Technical collaborators

- Repository: `https://github.com/tuna777123/mystic-tarot`
- Store handoff: `STORE_RELEASE.md`
- Marketing launch kit: `docs/MARKETING_LAUNCH_KIT.md`
- RevenueCat setup: `docs/REVENUECAT_SETUP.md`
- Production signing guidance: `docs/PRODUCTION_SIGNING_FINGERPRINTS.md`

## 6. Safe advertising claims

Use:

- “A private, reflection-first tarot ritual.”
- “Return after 24 hours and compare the reading with what actually happened.”
- “Notice recurring cards and personal patterns over time.”
- “Local-first journal.”
- “No account required on the public web edition.”
- “No advertising SDK in the current product.”

Do not use:

- guaranteed prediction claims;
- medical, mental-health, legal, financial, or emergency-advice claims;
- fake ratings, user totals, testimonials, press logos, scarcity, awards, or download counts;
- hardcoded subscription prices;
- App Store or Google Play availability claims before the final signed listings are actually live.

## 7. What is intentionally not represented as complete

The source repository cannot complete account-owned store operations on behalf of the owner. Before native production release, the responsible store operator must still complete:

1. Apple Developer / App Store Connect ownership and agreements.
2. Google Play Console ownership and agreements.
3. Permanent Android upload signing material.
4. Apple distribution certificate and provisioning profile.
5. Production RevenueCat project, platform apps, store credentials, products, offering, and entitlement mapping.
6. Official localized subscription prices and trial configuration.
7. Signed Android and iOS production candidates.
8. TestFlight / Play internal or closed testing.
9. Real-device and sandbox purchase / restore / renewal / expiration / refund / revocation validation.
10. Store privacy/data-safety, age/content rating, trader/business, banking, and tax forms.
11. Final store screenshots/evidence from genuinely signed candidates where required.
12. Store review and production approval.

Until those steps pass, do not describe the native app as publicly available in the Apple App Store or Google Play.

## 8. Handoff message

Copy/paste this when sending the project to a collaborator:

> Mystic Tarot `1.22.3+32` is a production-hardened Flutter product with a live installable web edition, five complete launch languages, public legal/support pages, verified Android/web/iOS QA pipelines, deterministic 50-image store screenshot generation, a store-release handoff, a public press kit, and a five-language marketing launch kit. The final public-launch source passed Flutter and iOS release CI, and the live Pages deployment passed 18-endpoint content verification. Start with the public press kit for product context and `STORE_RELEASE.md` for native store operations. Native store availability must not be claimed until the account-owned signing, sandbox, real-device, and store-review steps are complete.

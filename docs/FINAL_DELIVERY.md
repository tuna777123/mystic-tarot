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

## 2. Verified source baseline

The verified pre-final-launch source baseline is Mystic Tarot `1.22.3+32` from main commit:

`dedd420add86733169e9d2de6e0257f0a86094a8`

That baseline passed:

- formatting and clean-diff checks;
- static analysis;
- 449 automated tests;
- web release build;
- Android AAB release build;
- unsigned iOS release and application verification;
- strict Android jarsigner and `bundletool validate` checks;
- package, version, ABI, sensitive-permission, advertising/analytics-class audits;
- Built-in Kotlin exact-warning-set audit;
- five-language screenshot validation;
- 10/10 locale/device screenshot partitions;
- final screenshot package audit;
- post-merge `pages/deployment = success`;
- post-merge `screenshots/generation = success`.

The final-launch hardening branch adds only the public press/share surface, marketing handoff, sitemap indexing, and automated launch-surface contracts. Its CI must pass before this document is treated as the new canonical source baseline.

## 3. Verified QA Android artifact baseline

Package: `com.tunabozcali.mystictarot`  
Version: `1.22.3+32`  
Size: `61,659,967` bytes  
SHA-256: `c3c09be0cade63a241c783b6c12b925ed6e4e062cec103559d0e67bea48dbcdd`  
ABIs: `arm64-v8a`, `armeabi-v7a`, `x86_64`

Verified checks:

- strict JAR signature policy: PASS;
- `bundletool validate`: PASS;
- sensitive permission denylist: clear;
- advertising / analytics class denylist: clear;
- Built-in Kotlin audit: PASS with reviewed warnings exactly `flutter_timezone, purchases_flutter`.

This artifact is a QA release AAB. It is **not** the final Google Play upload-signed production candidate.

## 4. Verified screenshot baseline

Canonical pre-final-launch screenshot artifact:

- App version: `1.22.3+32`
- Source: `dedd420add86733169e9d2de6e0257f0a86094a8`
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

> Mystic Tarot `1.22.3+32` is a production-hardened Flutter product with a live installable web edition, five complete launch languages, public legal/support pages, verified Android/web/iOS QA pipelines, deterministic 50-image store screenshot generation, a store-release handoff, and a public press/marketing kit. Start with the public press kit for product context and `STORE_RELEASE.md` for native store operations. Native store availability must not be claimed until the account-owned signing, sandbox, real-device, and store-review steps are complete.

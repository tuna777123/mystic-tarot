# Mystic Tarot 1.13.0 — Activation & Ritual Retention

This release turns the first session into a complete value moment and gives users a private, controllable reason to return.

## First-session activation

- Onboarding now ends by opening the first real Daily Guidance ritual instead of leaving a new user on the Home screen.
- The final action clearly promises the next step: reveal the first card.
- The existing reflective and safety language remains intact; no purchase prompt interrupts the first ritual.

## Daily ritual retention

- After the first saved Daily Guidance reading, Mystic offers one optional daily local reminder.
- Permission is requested only after the user chooses a time; it is never forced during onboarding.
- Users can enable, disable, or change the reminder time from Your Space.
- Reminder text is localized in English, Turkish, Spanish, French, and Brazilian Portuguese.
- Scheduling uses an inexact daily local notification and does not request exact-alarm access.
- No question, journal note, Mirror reflection, advertising identifier, or tracking profile is included in a notification or uploaded.

## Organic sharing

- Saved readings now expose a visible private Story Card action.
- The existing Story Studio continues to export only the selected cards and reflective headline; private questions and journal notes remain excluded.

## Release integrity

- Version `1.13.0+19`.
- Generated Android shells receive boot-safe scheduled-notification configuration through a verified, idempotent tool step.
- Web remains fully usable and explains that native reminders are available on iOS and Android.

---

# Mystic Tarot 1.12.0 — Revenue Intelligence

Mystic Plus now sells an accumulating personal outcome instead of only removing limits.

## New premium value

- A private seven-day Mystic Intelligence report calculated entirely on the device.
- Free users receive a personalized preview built from their own saved readings before seeing plans.
- Plus members unlock recurring-card evidence, dominant reading focus, Mirror completion and shift rates, emotional direction, and a transparent next-practice prompt.
- The report becomes meaningful after three saved readings and refreshes from the latest seven-day window.
- All insight copy is descriptive and explicitly avoids prediction, diagnosis, or certainty claims.

## Conversion and trust

- Every Plus entry point now opens the personalized intelligence hub before the official store plans.
- A personalized home card shows report readiness and a real recurring-symbol preview, making the accumulating value discoverable before a paywall interruption.
- Existing members can revisit their full report from the Plus entry point and then manage the verified subscription.
- The official checkout still uses localized App Store or Google Play prices and trusted RevenueCat entitlement verification.
- The report reads only the versioned local Journal and Mystic Mirror stores; no private journal text is uploaded.

## Launch languages

English, Turkish, neutral international Spanish, French, and Brazilian Portuguese ship with the complete report and purchase journey.

---

# Mystic Tarot 1.11.0 — Mirror & Trust

This release turns Mystic’s core promise into a complete, durable product loop.

## What is new

- Mystic Mirror is now a real 24-hour follow-up: record what changed, how you feel now, and an optional private reflection.
- Due Mirror check-ins surface in the Journal and on an accessible five-language navigation badge, including while the app remains open.
- Every card can explain the spread position, upright/reversed lens, traditional symbolic basis, practical bridge, and personal context used in the interpretation.
- Journal search tolerates Turkish characters and French, Spanish, and Portuguese accents.
- The full private export includes questions, cards, actions, Mirror outcomes, emotional transitions, and reflection notes; sharing remains user-initiated with a clipboard fallback.

## Trust and resilience

- The complete journal is stored without the previous 50-reading cap.
- Journal and Mirror data keep last-known-good local backups and recover from unreadable or partially damaged snapshots.
- Only validated primary snapshots may replace a good backup.
- Recovery and legacy migration are disclosed in the selected launch language instead of silently hiding damaged entries.
- Mirror save failures remain retryable and never close the sheet as if the data were saved.
- Reduced-motion support, timer disposal, localized support routing, and narrow-screen accessibility remain enforced.

## Launch languages

English, Turkish, neutral international Spanish, French, and Brazilian Portuguese remain complete across the release experience.

## Validation target

Flutter analysis, the complete automated test suite, web release, and Android App Bundle must all pass before this release candidate can merge.

---

# Version 1.10.0 — French & Quality

Mystic Tarot now ships a complete five-language experience in English, Turkish, neutral international Spanish, Brazilian Portuguese, and French:

- French remains active from onboarding through readings, Oracle Dialogue, Living Journal, Memory Map, Mystic Path, Major Arcana Journey, Arcana Vault, weekly insights, premium, account, settings, export, deletion, and support surfaces;
- all 78 tarot cards have French names, upright guidance, reversed guidance, and aligned actions;
- 423 exact interface messages and 40 dynamic templates are protected in Spanish, French, and Brazilian Portuguese;
- long French labels are exercised on narrow phone layouts without clipping or horizontal overflow;
- French privacy, terms, and support pages ship with the web release and the in-app support action opens the correct localized page;
- the unused legacy paywall and its outdated weekly plan and hard-coded prices were removed so the verified monthly/yearly store catalog remains the only subscription experience;
- public legal-page, local-first privacy, language persistence, dynamic-content, and no-English-fallback checks were expanded.

# Version 1.9.0 — Spanish & Brazilian Portuguese Launch

Mystic Tarot now delivers a complete four-language launch experience in English, Turkish, neutral international Spanish, and Brazilian Portuguese:

- Spanish and Brazilian Portuguese are available from onboarding and remain active across navigation, readings, Oracle Dialogue, Living Journal, Memory Map, Mystic Path, Major Arcana Journey, Arcana Vault, weekly insights, premium, account, and support surfaces;
- all 78 tarot cards have localized names plus upright, reversed, and aligned-action guidance in both new languages;
- every reading type, emotional state, deck name, dynamic pattern insight, recurring-card message, and personal summary uses the selected language instead of falling back to English;
- the seven-language bridge now preserves exact language choices while French, German, and Italian remain hidden until their full catalogs are complete;
- 447 interface messages per new language are protected by catalog completeness and dynamic-template regression tests;
- all 78 cards, ten reading types, five emotional states, and three deck styles receive automated no-English-fallback coverage;
- long Spanish and Brazilian Portuguese headings and calls to action now adapt safely on phone layouts without clipping or horizontal overflow.

Italian, French, and German are still present in the localization foundation but are intentionally not exposed in the launch selector until their full experiences pass the same completeness standard.

# Version 1.8.1 — Web Preview Hotfix

Mystic Tarot now starts reliably as a full-page Flutter web application:

- a custom Flutter bootstrap explicitly disables multi-view mode so the existing `runApp` entry point receives a platform view;
- CanvasKit is loaded from the release package instead of depending on an external runtime path;
- the web application no longer remains on an empty dark background when opened from a supported web host;
- a regression test protects the generated Flutter tokens, full-page engine configuration, local CanvasKit path, engine initialization, and app runner call.

# Version 1.8.0 — Protected Store Release

Mystic Tarot now has a guarded production packaging pipeline for App Store and Google Play submission builds:

- a manual GitHub Actions workflow creates genuinely signed Android AAB and iOS IPA packages only inside the protected `production-stores` Environment;
- Android upload keystores, Apple distribution certificates, provisioning profiles, passwords, and RevenueCat application keys are read only from protected secrets and deleted from the runner after use;
- preflight validation rejects missing, malformed, cross-platform, or secret-looking RevenueCat keys before a client build can begin;
- permanent Android and iOS identity `com.tunabozcali.mystictarot` is applied through one reusable tool shared by CI and production release jobs;
- Android release artifacts receive cryptographic signature verification, while iOS artifacts are checked for a valid code signature, exact bundle ID, Team ID, and application entitlement;
- each signed package includes a SHA-256 checksum and release manifest recording the source commit, version, store channel, product IDs, entitlement, artifact size, and digest;
- new regression tests protect release identity, RevenueCat key handling, base64 signing inputs, Apple Team ID validation, version parsing, and artifact naming;
- a complete operator runbook documents protected GitHub Environment setup, Android upload-key preparation, Apple certificate/profile preparation, and the required real-device sandbox matrix.

The workflow prepares signed submission packages but intentionally does not create store accounts, products, banking agreements, RevenueCat projects, or upload releases automatically. Those account-owned launch actions remain tracked in issue #47.

# Version 1.7.0 — Subscriber Experience

Mystic Tarot now turns verified subscription infrastructure into a complete customer experience:

- official localized store prices include a truthful yearly monthly-equivalent and calculated savings only when supported by matching-currency store data;
- active members see their verified plan, current access-through date, sandbox state, restore control, and official store management link;
- active members bypass the sales preview and open their verified account controls directly;
- subscription status refreshes when the app resumes after checkout or account management;
- the Profile tab clearly distinguishes active Mystic Plus membership from the upgrade state;
- subscription management opens outside the app in Apple or Google’s official account surface;
- new tests prevent invented savings and cross-currency price comparisons.

# Version 1.6.0 — Verified Revenue

Mystic Tarot now contains the production subscription foundation for Mystic Plus:

- RevenueCat provides server-side store receipt validation and subscription-state tracking for Apple and Google purchases;
- the app unlocks Plus only when the `mystic_plus` entitlement is active and its Trusted Entitlements signature is verified by RevenueCat or verified on-device;
- failed or missing signature verification fails closed and never grants premium access;
- monthly and yearly products use official localized store prices;
- purchase, cancellation, pending confirmation, restore, expiration, refund, and live entitlement revocation states are handled without trusting client-side flags;
- active subscribers receive unlimited deep readings, Compatibility, Future Timeline, Celtic Cross, and unlimited Oracle Dialogue follow-ups;
- expired, refunded, or revoked subscriptions automatically return to the free limits;
- device-identifier collection and RevenueCat diagnostics are disabled in the SDK configuration;
- privacy policies, support copy, subscription terms, and store privacy declarations now disclose purchase-history processing accurately;
- regression coverage includes purchase, restore, inactive entitlement, revocation, missing configuration, localization, and trusted-signature behavior.

The native code is release-candidate ready. Revenue begins only after the store products, RevenueCat project credentials, signing identities, banking/tax agreements, sandbox tests, and store review are completed in the account-owned consoles.

# Version 1.5.0 — Store Trust

Mystic Tarot now keeps the complete premium and purchase-status experience safe,
localized, and release-ready:

- store states use structured notice codes instead of exposing raw plugin or
  marketplace error text inside the interface;
- purchase, cancellation, restore, checkout, product-loading, and secure
  verification messages are localized across all seven interface language
  models, including complete Turkish copy;
- Restore Purchases no longer remains trapped in a loading state when the store
  returns no purchase updates;
- failed checkout launches return to a stable state instead of leaving the
  purchase flow spinning;
- premium plan controls and live store status receive improved accessibility
  semantics;
- new regression tests verify every store notice in every supported interface
  language and prevent Turkish fallback to English.

# Version 1.4.0 — Complete Turkish Journey

Mystic Tarot now preserves a complete Turkish experience beyond the reading
flow:

- Mystic Path, Inner Constellation, XP progress, daily rituals, rewards, and
  streak messaging remain Turkish when Turkish is selected;
- Weekly Mystic Wrapped localizes emotions, repeating cards, reflection
  summaries, and calls to action;
- Arcana Vault localizes collection progress, locked states, rarity labels, and
  all 78 card names;
- opened Vault cards use the full card-specific Turkish interpretation engine
  for Light, Shadow, and Aligned Action;
- mobile regression coverage prevents English fallback across the Journey,
  Weekly Wrapped, and Arcana Vault experience.

# Version 1.1.0 — Living Fate

Mystic Tarot now turns separate readings into one private, evolving story:

- Living Fate Map connects recurring cards, emotions, life areas, and real-world
  check-ins without presenting reflection as certainty;
- the 22-day Major Arcana Journey adds one focused chapter, practical ritual,
  and private reflection per day, with no punishment for missed days;
- Oracle Memory connects the current reading with recent on-device history and
  offers a contextual follow-up dialogue;
- Mystic Story Studio exports a privacy-safe, high-resolution 9:16 story image
  for social sharing without including the user's question or journal notes;
- Living Journal adds a visual Memory Map and private semantic search across
  saved readings;
- language selection persists across sessions, with English and Turkish
  flagship experiences plus an expanding seven-language interface foundation;
- local-first storage, export, deletion, subscription disclosure, restore
  handling, and public legal/support pages remain part of the release.

This release does not claim deterministic predictions or remote AI. Personal
journal history stays on the device unless the user explicitly exports or shares it.

# Version 1.0.0 — Public Early Access

Mystic Tarot opens its first complete ritual:

- cinematic card selection and Reveal Ritual;
- 78-card Arcana collection with upright and reversed meanings;
- Daily Guidance and six focused reading paths;
- private local journal with export and deletion;
- Oracle Dialogue and recurring-card memory;
- Mystic Mirror, weekly patterns, streaks, XP, rituals, achievements, and unlockable decks;
- installable PWA experience with a new Mystic Tarot icon;
- public Privacy Policy, Terms of Use, and Support pages.

The public web release remains free and does not process native App Store or Google Play subscriptions.

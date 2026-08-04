# Mystic Tarot 1.22.1 — Retention Quality

This release strengthens Mystic Tarot's most defensible advantage: a private reading history that becomes more useful through meaningful return behavior, not raw tapping volume.

## Evidence before breadth

- Once a real recurring card or emotional pattern becomes visible, Home now surfaces that earned personal signal before sending the user into another generic content chapter.
- Due Mystic Mirror check-ins and the real Daily Guidance remain higher priority, preserving the complete evidence loop.
- Upgrade discovery remains downstream from delivered value rather than interrupting first-session activation.

## Honest habit detection

- Growth stages now require activity across distinct calendar days as well as reading count, streak, and Arcana progress.
- A burst of many readings on one day can no longer masquerade as a durable habit or power-user relationship.
- Premium-value readiness now rewards repeated active days and meaningful continuity instead of being inflated by same-session binge use.

## Reliable return recognition

- Next-day returns are calculated by local calendar day, so a user who returns shortly after midnight receives the correct continuity state even when fewer than 24 hours have elapsed.

## Release integrity

- Version `1.22.1+30`.
- Dedicated regression coverage protects evidence-first prioritization, calendar-day returns, and anti-binge growth classification.
- No account, advertising SDK, cross-app tracking, cloud journal, pricing mutation, or subscription entitlement change is introduced.

---

# Mystic Tarot 1.22.0 — Revenue-Ready Final

- Official plans and the primary purchase action now appear before long-form proof, while yearly remains the honest default value path.
- Every selected plan shows its actual store price, billing period, renewal cadence, and an explicit reminder that Daily Guidance and the saved journal remain usable without Plus.
- A failed store connection now exposes a visible localized retry instead of leaving a disabled purchase screen.
- After verified purchase or restore, the primary action returns the member to Mystic; subscription management remains a clear secondary action.
- Production Android and iOS workflows now apply store identity, ritual notifications, and private app-lock configuration before signed packaging.
- Every release path that applies permanent store identity now also applies the correct notification and app-lock native hardening for the generated platform shell.
- Version `1.22.0+29`.

# Mystic Tarot 1.21.1 — Prelaunch Hardening

- App-lock, PIN, biometric, and native Material controls now follow the language selected inside Mystic rather than leaking the device language.
- Background/resume relocking refreshes the selected language and preserves the configured grace period.
- CI now rejects unformatted Dart and whitespace defects.
- A macOS/Xcode gate builds the unsigned iOS release before store submission.
- Version `1.21.1+28`.

# Mystic Tarot 1.21.0 — A Reading That Continues

Mystic Tarot now makes its defining advantage unmistakable in the first session: a private reading becomes a 24-hour reality check and, with enough evidence, an explainable personal pattern.

## First-session excellence

- Onboarding communicates the complete continuity promise without adding another page or delaying the first reading.
- After the first saved reading, Home shows a clear timeline: saved now, Mystic Mirror tomorrow, Mystic Intelligence after enough evidence.
- The primary next action remains singular and unambiguous.
- Returning tomorrow is explained as added reflective value, never fear, urgency, or punishment.

## Coherent, explainable readings

- Complete spreads now end with one deterministic, spread-aware synthesis; Compatibility connects both people, the shared dynamic, growth edge, and next honest step; Timeline preserves agency across six stages; Celtic Cross links the present situation, immediate challenge, near-future movement, and conditional direction.
- Single-card readings connect the card position, symbolic meaning, user context, and one grounded invitation.
- Existing per-card “Why this interpretation?” explanations remain visible and transparent.
- Readings explicitly remain invitations for reflection rather than certainty, diagnosis, proof, or prediction.

## Privacy as a visible product advantage

- “Private by design” is visible after the first reading and on the Mystic Plus value screen.
- The premium screen explains continuity and evidence before showing plan choices.
- The interface states plainly that Mystic uses no account, advertising SDK, cross-app tracking, or cloud journal.
- Questions, journal notes, Mystic Mirror reflections, and Oracle conversations remain on the user’s device.
- The complete app can be protected with the existing local six-digit PIN and optional device biometrics on supported devices.
- Protected device transfer remains available without turning private history into a cloud account.

## Launch quality

- Complete English, Turkish, Spanish, French, and Brazilian Portuguese continuity and privacy copy.
- Deterministic synthesis tests across every launch reading type and all five launch languages.
- Dedicated 320-pixel narrow-phone widget coverage for the new launch experience.
- Version `1.21.0+27`.

No astrology bundle, live reader marketplace, social feed, cloud profile, advertising integration, pricing mutation, signing operation, or store submission is introduced.

---

# Mystic Tarot 1.18.0 — Private Journal Transfer

Mystic Tarot can now move a complete reflection history between devices without creating an account or uploading private content.

## Complete private history

- A versioned private transfer code includes saved readings, Mystic Mirror reflections, and Oracle conversations.
- Human-readable journal export remains available separately.
- Transfer codes are created and restored only on the user’s devices; Mystic does not upload them.
- The interface clearly warns that anyone who receives a transfer code can read the private content inside it.

## Safe merge and recovery

- Every code is validated before the app shows exactly what would change.
- Existing local readings are preserved and duplicate records or Oracle turns are never added.
- A newer Mirror reflection may replace an older reflection for the same reading.
- Unsupported, foreign, damaged, and orphaned items are rejected or safely ignored.
- Restore writes keep previous journal, Mirror, and Oracle snapshots and perform compensating rollback if any local write fails.
- The in-memory journal changes only after the complete local transaction succeeds.

## Product integrity

- Complete English, Turkish, Spanish, French, and Brazilian Portuguese transfer experience.
- Narrow-phone validation and deterministic codec, merge, duplicate, and invalid-input coverage.
- Version `1.18.0+24`.
- No account, cloud journal, analytics payload, advertising identifier, purchase mutation, or store operation is introduced.

---

# Mystic Tarot 1.17.0 — Oracle Language Integrity

This release closes the last major language break inside Oracle Dialogue so every launch language receives a complete, grounded response instead of a translated shell around an English answer.

## Complete French Oracle

- French Oracle responses now have native hidden-risk, key-card, and general guidance branches.
- French recurring-card memory and conversation continuity remain French from question to answer.
- The safety framing remains intact: cards offer a perspective, not certainty or commands.

## Better multilingual intent detection

- Hidden-risk and key-card questions are detected independently in English, Turkish, Spanish, French, and Brazilian Portuguese.
- Matching is accent-tolerant and punctuation-tolerant, so natural questions such as “Quelle carte…” and “Neyi gözden kaçırıyorum?” route correctly.
- Ordinary follow-ups remain general instead of being forced into the wrong response template.

## Release integrity

- Version `1.17.0+23`.
- No cloud profile, analytics payload, advertising identifier, store operation, or account mutation is introduced.
- The complete language behavior is protected by deterministic unit and release-contract tests.

---

# Mystic Tarot 1.16.0 — Private Oracle Memory

This release makes the Oracle Dialogue promise real: follow-up questions and answers are now saved privately, linked to the original reading, recoverable after local corruption, and available from the Living Journal.

## A conversation that remembers

- Every completed Oracle exchange is saved on this device and attached to the exact reading that produced it.
- Returning to a reading restores its complete Oracle thread instead of opening an empty conversation.
- Free users keep one saved answer per reading and can revisit it; Mystic Plus can continue the same private thread with additional questions.
- Later questions receive a small continuity signal from the previous saved turn without presenting the response as certainty.
- Save failure is disclosed immediately; Mystic never claims that an unsaved answer is stored.

## Living Journal and complete export

- Every Journal reading now exposes an Oracle action with its verified saved-exchange count.
- The action opens the same reading-linked dialogue and refreshes when the user returns.
- Private journal exports now include every saved Oracle question and answer beside the correct reading and Mystic Mirror evidence.
- Deleting all Mystic data explicitly includes Oracle conversations.

## Trust and resilience

- Oracle memory uses versioned local storage with a previous-snapshot backup and partial-corruption recovery.
- No Oracle question or answer is uploaded, added to analytics, or shared with advertisers.
- Complete English, Turkish, Spanish, French, and Brazilian Portuguese memory and recovery copy.
- Version `1.16.0+22`.

---

# Mystic Tarot 1.15.0 — Personal Next Step

This release connects Mystic’s existing local growth engine to the real Home experience so each user sees one honest, actionable next step instead of a generic wall of features.

## One clear next step

- Home now calculates a private growth snapshot from local reading history, streak, completed Arcana chapters, free-reading allowance, and the verified Mirror due count.
- The card prioritizes first activation, the real Daily Guidance, due Mirror follow-up, the next Arcana chapter, visible patterns, and deeper reading discovery in that order.
- A non-daily spread completed today never falsely satisfies the Daily Guidance step.
- Old readings never reappear as Mirror tasks unless the backed local Mirror store reports that they are genuinely due.
- Every action routes to an existing destination: Daily Guidance, Living Journal, Living Fate, reading library, or Mystic Plus.

## Localized continuity

- The card explains why the suggested action matters and reflects whether the user is beginning, active today, returning the next day, continuing a streak, or resuming after time away.
- Complete English, Turkish, Spanish, French, and Brazilian Portuguese copy ships for every action, growth stage, return state, and CTA.
- Long French and Portuguese actions remain usable on narrow phones.

## Privacy and release integrity

- Personalization remains local-first and deterministic; no new account, cloud profile, analytics payload, or private text storage is introduced.
- Version `1.15.0+21`.
- Engine priorities, localization, action routing, and narrow-phone rendering are protected by automated tests.

---

# Mystic Tarot 1.14.0 — Daily Practice & Reliable Return

This release turns the Daily Soul Quest into a complete, honest product loop and keeps daily state correct while the app remains open.

## Actionable daily ritual

- The previously passive “one ritual” step now opens a real private micro-practice.
- Users can complete a guided 24-second grounding breath, write one honest intention, or name a gratitude anchor.
- Intention and gratitude text exists only inside the open sheet and is never persisted; Mystic stores only the selected practice identifier.
- Completing the ritual immediately updates the Daily Soul Quest and reveals when the Soul Chest is ready.
- All practice choices, privacy language, breathing phases, writing prompts, and calls to action ship in English, Turkish, Spanish, French, and Brazilian Portuguese.

## Reliable daily boundaries

- Daily rituals, deep-reading allowances, quest claims, and stale streak displays refresh automatically after local midnight.
- The refresh runs when the app resumes and through a scheduled local day-boundary timer while the app remains open.
- A valid yesterday streak remains visible until today’s practice; a genuinely broken streak no longer appears active.
- Daily state rules are deterministic and covered independently from the interface.

## Release integrity

- Version `1.14.0+20`.
- Private writing is not added to SharedPreferences, notifications, exports, analytics, or purchase services.
- Narrow-phone layout and guided-practice completion are protected by automated widget tests.

---

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

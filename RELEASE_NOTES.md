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

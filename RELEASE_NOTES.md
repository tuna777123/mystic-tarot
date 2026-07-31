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

Premium entitlement still requires secure server-side receipt verification
before native subscriptions can be activated.

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
history stays on the device unless the user explicitly exports or shares it.

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

The public web release is free early access and does not process subscription payments.

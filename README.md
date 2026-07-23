# Mystic Tarot

Mystic Tarot is a private, reflection-first tarot ritual built with Flutter. The public release runs as an installable PWA and the same product code is prepared for native iOS and Android packaging.

## Live release

https://tuna777123.github.io/mystic-tarot/

Public policies:

- Privacy: https://tuna777123.github.io/mystic-tarot/privacy.html
- Terms: https://tuna777123.github.io/mystic-tarot/terms.html
- Support: https://tuna777123.github.io/mystic-tarot/support.html

## Product

- Premium three-step onboarding and personal intention
- 78-card deck with upright and reversed meanings
- Cinematic selection, seal, reveal, and interpretation ritual
- Daily Guidance plus focused love, career, money, decision, spiritual, and shadow readings
- Oracle follow-up dialogue grounded in the revealed cards
- Private local journal, export, and one-tap data deletion
- Pattern memory, 24-hour Mystic Mirror, weekly wrap, streaks, XP, achievements, rituals, and Arcana Vault
- Three unlockable visual deck themes
- Responsive mobile UI and premium desktop presentation
- Installable PWA metadata and branded icon set

## Privacy posture

The current public release is local-first:

- no account;
- no advertising SDK;
- no cross-app tracking;
- no cloud journal;
- no payment processing;
- no transmission of reading questions to the developer.

Native subscriptions must not be enabled until store products, receipt validation, merchant agreements, and store disclosures are configured.

## Development

```bash
flutter create . --platforms=web,android,ios
flutter pub get
flutter analyze
flutter test
flutter run
```

## Release verification

Every push to `main` runs static analysis and widget tests. The Pages workflow performs the same checks, builds the release web bundle, and deploys only after they pass.

See [STORE_RELEASE.md](STORE_RELEASE.md) for approved listing copy, product identifiers, screenshots, review notes, privacy answers, and the remaining account-owned launch actions.

Tarot content is for reflection and entertainment, not medical, mental-health, legal, financial, or emergency advice.

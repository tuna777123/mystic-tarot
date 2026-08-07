# Mystic Tarot

Mystic Tarot is a private, reflection-first tarot ritual built with Flutter. A reading becomes a 24-hour reality check and, with enough evidence, an explainable personal pattern. Private history stays on-device and the complete app can be protected with a local PIN and optional biometrics on supported devices. The public release runs as an installable PWA and the same product code is prepared for native iOS and Android packaging.

## Live release

https://tuna777123.github.io/mystic-tarot/

Public marketing:

- English website: https://tuna777123.github.io/mystic-tarot/landing-en.html
- Turkish website: https://tuna777123.github.io/mystic-tarot/landing.html
- Spanish website: https://tuna777123.github.io/mystic-tarot/landing-es.html
- French website: https://tuna777123.github.io/mystic-tarot/landing-fr.html
- Brazilian Portuguese website: https://tuna777123.github.io/mystic-tarot/landing-pt-br.html
- Press & sharing kit: https://tuna777123.github.io/mystic-tarot/press-kit.html

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

## Shareable launch material

- `STORE_RELEASE.md` — canonical App Store / Google Play / RevenueCat handoff.
- `docs/MARKETING_LAUNCH_KIT.md` — paid-social copy, short-form video briefs, creator/PR copy, five-language campaign messages, UTM convention, and advertising claim guardrails.
- `docs/FINAL_DELIVERY.md` — technical and public-facing handoff for collaborators after release verification.
- `web/press-kit.html` — public, indexable press/share page designed to be sent directly to creators, partners, designers, or press.

Marketing must not claim App Store or Google Play availability until signed native listings are actually approved and live. Do not fabricate ratings, user counts, testimonials, awards, scarcity, prices, or predictive/professional-advice claims.

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

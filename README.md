# Mystic Tarot

A premium, AI-ready tarot and spiritual companion app built with Flutter for iOS and Android.

## Current MVP

- Premium three-step onboarding
- Seven reading types
- Interactive card selection and reveal
- Upright and reversed interpretations
- Reading journal
- XP and reflection streaks
- Profile and Mystic Plus paywall preview
- Dark luxury visual system
- Widget test for onboarding

## Run locally

Install the Flutter SDK, then run:

```bash
flutter create .
flutter pub get
flutter run
```

`flutter create .` generates the native Android, iOS, web, macOS, Windows, and Linux project shells without replacing the existing Dart application.

## Architecture

- `lib/src/app.dart` — navigation and product flows
- `lib/src/models.dart` — domain models
- `lib/src/tarot_data.dart` — tarot meanings
- `lib/src/theme.dart` — design system
- `lib/src/widgets.dart` — reusable UI components

## Next production milestones

1. Run and visually QA the MVP on a real device.
2. Add durable local state and account authentication.
3. Connect secure server-side AI interpretations.
4. Add RevenueCat subscriptions.
5. Add analytics, crash reporting, privacy controls, and store assets.

Tarot content is designed for reflection and entertainment, not medical, legal, or financial advice.

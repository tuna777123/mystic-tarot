# Mystic Tarot 1.20.0 — Private App Lock

Mystic Tarot can now hide the complete private experience behind a local six-digit PIN and optional device biometrics.

## Private by default after locking

- The lock covers readings, Mystic Mirror reflections, Oracle memory, Journeys, profile information, and every other app screen.
- An enabled lock is required at cold start and after the app remains in the background beyond a short grace period.
- A persistent shield control lets users set up the lock later or lock the app immediately.
- Supported devices can unlock with enrolled biometrics; the PIN always remains available as the local fallback.

## Local security model

- The raw PIN is never stored, uploaded, logged, or included in analytics.
- Argon2id derives a 256-bit key from the PIN and a fresh random salt.
- AES-GCM protects a fixed local verifier with authenticated encryption.
- Verifier material is held in platform secure storage, including Keychain on Apple platforms and encrypted secure storage on Android.
- Failed attempts create persistent escalating delays: 30 seconds, five minutes, and thirty minutes at higher attempt counts.
- Successful PIN or biometric verification clears the failed-attempt state.

## Honest recovery and platform support

- There is no cloud reset, hidden recovery PIN, or remote bypass.
- The setup experience clearly warns users before enabling the lock.
- Android uses a fragment-based activity and biometric permissions; device backup of secure lock material is disabled.
- iOS includes Face ID usage copy and Keychain entitlements.
- Web keeps the PIN path and does not offer unavailable biometrics.

## Product integrity

- Complete English, Turkish, Spanish, French, and Brazilian Portuguese lock experience.
- Dedicated core, widget, platform configurator, and release-contract tests.
- Version `1.20.0+26`.
- No account, cloud journal, analytics payload, advertising identifier, purchase mutation, pricing, signing-account, or store submission work is introduced.

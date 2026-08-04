# Mystic Tarot 1.21.1 — Prelaunch Hardening

This patch closes release gaps found during a second publication-focused audit of the clean v1.21 source.

## Language integrity

- App-lock, PIN, biometric, and lock-management screens follow the language selected inside Mystic rather than the device language.
- Native Material controls, dialog actions, accessibility tooltips, and platform-standard labels use English, Turkish, Spanish, French, or Brazilian Portuguese consistently.
- Brazilian Portuguese locale variants such as `pt_BR` and `pt-BR` resolve safely.

## Privacy lifecycle

- Returning from the background after the configured grace period relocks the private app.
- The lock refreshes the current Mystic language before it appears.
- Brief system interruptions inside the grace period do not create a disruptive false relock.

## Release engineering

- Added a macOS/Xcode unsigned iOS release build gate.
- Added permanent Dart formatting and whitespace checks to the main Flutter CI.
- Preserved the Android AAB, web release, static-analysis, full-test, store-identifier, notification, app-lock, and signing-configurator gates.

## Version

- `1.21.1+28`

Store signing, pricing, product setup, and publication remain owner-controlled and are not performed by this patch.

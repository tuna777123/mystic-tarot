# Mystic Tarot 1.22.3 — Faster, More Resilient Startup

This patch removes a nonessential native-service wait from the critical startup path while preserving first-frame language integrity and the complete daily-reminder experience.

## Product shell first

- Mystic now opens as soon as essential launch language state is ready.
- Optional local-notification and timezone initialization begins only after the product shell has been mounted.
- A slow or temporarily unavailable notification plugin can no longer delay the first usable screen.

## Language integrity remains protected

- Clean installs still begin in the supported device language before onboarding.
- An explicit in-app language choice still remains authoritative across restart and the private app lock.
- The startup optimization does not introduce an English fallback flash.

## Reminder behavior is unchanged

- Mystic does not request notification permission during startup.
- Daily ritual reminders remain user-controlled and continue to initialize before permission, scheduling, or cancellation actions need the native service.
- Existing fail-safe behavior still prevents a reminder-service error from blocking the rest of the app.

## Regression protection

- A dedicated bootstrap contract verifies that locale initialization remains essential and ordered before `runApp`.
- The contract prevents a blocking reminder initialization from being reintroduced into the cold-start path.
- The complete Flutter, web, Android AAB, bundle-audit, Built-in Kotlin, and iOS release gates remain required.

## Release integrity

- Version `1.22.3+32`.
- No subscription product, entitlement, price, bundle identifier, journal schema, account model, advertising SDK, tracking behavior, notification permission behavior, or cloud-storage behavior changes in this patch.

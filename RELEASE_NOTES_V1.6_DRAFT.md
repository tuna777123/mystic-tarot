# Mystic Tarot 1.6.0+9 — Verified Revenue

## Subscription infrastructure

- Replaced client-only purchase handling with RevenueCat-backed subscription verification.
- Added monthly and yearly official store products.
- Added verified `mystic_plus` entitlement state, restore handling, expiration and revocation updates.
- Added localized purchase, restore, configuration, and active-subscription states.
- Premium access fails closed when RevenueCat keys or store products are missing.

## Mystic Plus access

- Active subscribers receive unlimited deep readings.
- Compatibility, Future Timeline, and Celtic Cross readings unlock only for verified subscribers.
- Oracle Dialogue supports unlimited follow-up questions for active subscribers.
- Expired or refunded entitlements return the app to the free limits automatically.

## Release operations

- Added a production RevenueCat setup runbook.
- Added tests for purchase, restore, inactive receipt, live revocation, and missing configuration.
- Release builds accept platform-specific RevenueCat public SDK keys through `--dart-define`.

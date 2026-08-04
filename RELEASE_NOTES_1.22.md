# Mystic Tarot 1.22.0 — Revenue-Ready Final

This is the final source release before store-account signing and submission. It improves conversion without false urgency, fake discounts, hidden renewal terms, or unnecessary tracking.

## Clearer conversion path

- Official monthly and yearly plans appear before the longer continuity, benefits, and privacy explanation.
- Yearly remains selected by default, while savings are calculated only from matching official store prices and currencies.
- The primary action stays visible on a narrow phone and always reflects the selected plan and localized store price.
- Daily Guidance and the saved local journal are explicitly identified as available without Mystic Plus.

## Purchase completion and recovery

- A verified member returns directly to Mystic through the primary action instead of being sent to subscription settings.
- Manage subscription and refresh membership remain visible secondary actions.
- Store loading failures and delayed product propagation expose a localized retry path.
- Purchase, restore, revocation, and verification continue to fail closed unless RevenueCat returns an active trusted entitlement.

## Billing transparency

- The selected plan states the full store price and whether it is charged monthly or yearly.
- Auto-renewal is disclosed next to the purchase action and again in the legal purchase note.
- Trial language is not shown unless a future store-aware eligibility implementation can display complete duration, conversion price, and cancellation terms.

## Production release integrity

- The permanent store-identity configurator now orchestrates native notification and app-lock hardening for whichever Android and/or iOS shells exist.
- Signed Android receives boot-safe ritual notification receivers, biometric permissions, disabled Android backup, and `FlutterFragmentActivity` before packaging.
- Signed iOS receives Face ID disclosure, Keychain entitlements, and Xcode entitlement wiring before packaging.
- Existing format, whitespace, fatal-analysis, full-test, web, Android, and macOS/Xcode gates remain mandatory.

## Version

- `1.22.0+29`

Apple/Google developer enrollment, banking/tax agreements, RevenueCat dashboard products, public SDK keys, signing certificates, provisioning profiles, keystores, sandbox purchases, screenshots, and final submission remain account-owned operations.

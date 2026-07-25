# Mystic Tarot — Store Release Checklist

## Required before enabling paid access

- Create the subscription group in App Store Connect.
- Create matching subscriptions in Google Play Console.
- Use these exact product identifiers:
  - `mystic_plus_weekly`
  - `mystic_plus_monthly`
  - `mystic_plus_yearly`
- Configure localized names, descriptions, prices, billing periods, and trial eligibility in both stores.
- Add App Store and Google Play merchant, tax, and banking agreements.
- Implement a secure receipt verification endpoint.
- Verify Apple transactions and Google Play purchase tokens server-side.
- Persist entitlement only after server verification.
- Handle renewals, expiration, cancellation, refunds, grace periods, billing retry, and revocation.
- Test purchases and restore with Apple sandbox and Google Play license testers.

## Release safety

- Web builds must remain payment-disabled.
- Never unlock Mystic Plus from client-side receipt data alone.
- Final localized price and renewal terms shown by Apple or Google control the purchase.
- Terms of Use and Privacy Policy must identify payment providers and entitlement data handling before launch.

## Build verification

- `flutter analyze`
- `flutter test`
- `flutter build web --release`
- `flutter build appbundle --release`
- iOS archive and StoreKit sandbox test on macOS before App Store submission.

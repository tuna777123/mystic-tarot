# Mystic Tarot — Release Status

## Code-complete release candidate

The repository is ready to produce a web release and an Android App Bundle when every CI step passes.

Implemented:

- cinematic tarot readings and journaling;
- Living Fate pattern analysis;
- Mystic Plus launch catalog;
- yearly-first paywall with a seven-day trial policy;
- monthly alternative and restore flow;
- official Apple/Google in-app-purchase gateway;
- fail-closed entitlement verification hook;
- privacy, terms, support, export, and local deletion;
- automated analysis, tests, web build, and Android App Bundle build.

## Required account-owner actions

The following cannot be completed in source control:

1. Open and verify the Google Play Console developer account.
2. Complete merchant, tax, identity, and banking agreements.
3. Create `mystic_plus_monthly` and `mystic_plus_yearly` subscriptions.
4. Configure the yearly seven-day trial in Play Console.
5. Create and securely retain the Android upload keystore.
6. Add production receipt verification and provide its verification callback.
7. Replace CI's unsigned/test bundle with the final signed upload bundle.
8. Test purchase, pending, cancellation, renewal, expiration, refund, and restore using Play license testers.
9. Complete Data Safety, content rating, target audience, and store listing forms.
10. Upload screenshots from the final signed build and submit for review.

## Release rule

Do not enable paid access from a client-only purchase result. Mystic Plus must unlock only after the store transaction is verified by trusted server-side entitlement infrastructure.

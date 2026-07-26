# Mystic Tarot Data Deletion

Mystic Tarot is currently designed as a local-first application. Most reading, journal, Journey, preference, and progress information is stored on the user’s device.

## Delete data inside the app

Use the in-app data deletion control available from the profile or settings area. The final release candidate must verify that this action:

- clearly warns that deletion is permanent;
- requires an explicit confirmation;
- removes readings, journal entries, Journeys, preferences, progress, and local backups owned by the app;
- does not imply that deleting app data cancels a store subscription;
- returns the app to a clean first-run state.

## Delete data through device settings

Users can also clear the app’s storage through Android system settings or remove the application. Removing the app may delete local data permanently.

## Subscription records

Deleting local app data does not cancel an Apple App Store or Google Play subscription and does not erase records retained by those platforms. Subscriptions must be managed through the user’s store account.

## Purchase and entitlement records

Transaction records may be retained by Apple, Google, payment infrastructure, or trusted entitlement-verification services for accounting, fraud prevention, dispute handling, and legal compliance.

## Cloud or account data

The current release should not claim cloud deletion unless account or sync services are actually enabled. Before any future cloud sync launch, Mystic Tarot must provide:

- an account deletion path inside the app where required;
- a public deletion-request method;
- a defined retention period;
- confirmation of what is deleted and what must be retained by law.

## Request support

Users who need help with deletion can submit a request through:

https://github.com/tuna777123/mystic-tarot/issues

Do not include private journal text, payment credentials, full purchase receipts, identity documents, or other sensitive information in a public issue. The publisher must provide a private support channel before public store submission if deletion requests may involve personal or transaction data.

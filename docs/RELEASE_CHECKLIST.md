# Mystic Tarot Production Release Checklist

## Code and quality

- [ ] `flutter analyze` passes with no errors.
- [ ] Full Flutter test suite passes.
- [ ] Web release build succeeds.
- [ ] Android App Bundle release build succeeds.
- [ ] No temporary workflow, marker, debug, or test-only files remain.
- [ ] Version and build number are incremented for the intended release.
- [ ] Release is tested on at least one physical Android device.
- [ ] Layout is checked on small and large screens.
- [ ] English and Turkish flows are reviewed end to end.
- [ ] Offline behavior and corrupted-local-data recovery are tested.

## Privacy and data

- [ ] Privacy Policy is published at a stable public URL.
- [ ] Terms of Use are published at a stable public URL.
- [ ] Data deletion instructions are published at a stable public URL.
- [ ] A private, monitored support contact is available.
- [ ] In-app deletion requires explicit confirmation.
- [ ] In-app deletion clears readings, journals, Journeys, preferences, progress, and app-owned backups.
- [ ] Subscription cancellation is not confused with data deletion.
- [ ] Store Data Safety answers exactly match production behavior.
- [ ] No journal or Journey content is sent to external AI services without disclosure and user control.

## Purchases

- [ ] Google Play Console developer and merchant accounts are verified.
- [ ] `mystic_plus_monthly` is created and active.
- [ ] `mystic_plus_yearly` is created and active.
- [ ] Any promised trial is configured in the store.
- [ ] Localized prices are loaded from the store rather than hard-coded.
- [ ] Purchase, pending, cancellation, restore, expiration, renewal, refund, and offline states are tested.
- [ ] Paid access remains locked until trusted entitlement verification succeeds.
- [ ] Restore Purchases is visible and functional.
- [ ] Subscription management links open the correct store screen.

## Android signing and platform

- [ ] Final Android application ID is confirmed and permanent.
- [ ] Upload keystore is created, backed up securely, and excluded from source control.
- [ ] Signing configuration uses protected secrets.
- [ ] Target SDK and Play policy requirements are current.
- [ ] App icon, adaptive icon, splash screen, and application label are correct.
- [ ] Release AAB is signed with the correct upload key.
- [ ] Play App Signing is enabled and recovery information is stored securely.

## Store listing

- [ ] App name and short description fit store limits.
- [ ] Full description matches actual production features.
- [ ] Screenshots come from the final signed build.
- [ ] Feature graphic and app icon meet current store specifications.
- [ ] Content rating questionnaire is completed accurately.
- [ ] Target audience excludes children under 13.
- [ ] Privacy Policy URL is entered in the listing.
- [ ] Support contact and website are entered and monitored.
- [ ] Release notes are finalized.

## Closed testing

- [ ] Internal testing track is completed.
- [ ] License testers validate subscriptions.
- [ ] Fresh install, upgrade, uninstall, and reinstall are tested.
- [ ] Data deletion is tested before and after purchase restoration.
- [ ] Crash-free startup and core reading flow are verified.
- [ ] Journey creation, reflection, pause, complete, archive, and recovery are verified.
- [ ] Accessibility checks cover screen reader labels, text scaling, contrast, and reduced motion.

## Final release gate

Release only when:

1. the exact commit submitted to the store has a green CI run;
2. the signed AAB is produced from that commit;
3. all subscription products and entitlement verification are operational;
4. privacy, terms, deletion, and support URLs are public;
5. no known critical or high-severity defects remain.

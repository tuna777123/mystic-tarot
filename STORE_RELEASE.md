# Mystic Tarot — Store Release Pack

This is the canonical launch handoff for App Store Connect, Google Play Console, and RevenueCat.

## Positioning

**Category:** Lifestyle  
**Primary promise:** A private daily tarot ritual that remembers recurring cards, emotions, and choices.  
**Differentiator:** Mystic combines cinematic readings with pattern memory, a 24-hour reflection loop, and a collectible 78-card journey instead of delivering one disposable prediction.

## Permanent identifiers

- iOS bundle ID: `com.tunabozcali.mystictarot`
- Android application ID: `com.tunabozcali.mystictarot`
- RevenueCat entitlement: `mystic_plus`
- Monthly product: `mystic_plus_monthly`
- Yearly product: `mystic_plus_yearly`
- iOS SKU: `mystic-tarot-ios-001`

Changing the bundle/application IDs after the first store upload is disruptive. Confirm ownership before submission.

## App Store metadata

**Name (30 characters max)**  
Mystic Tarot: Daily Ritual

**Subtitle (30 characters max)**  
Tarot, Journal & Patterns

**Promotional text**  
Reveal the cards, notice what returns, and turn each reading into a private ritual that grows more meaningful over time.

**Keywords (100 characters max)**  
tarot,daily card,journal,oracle,reflection,spiritual,arcana,mindfulness,horoscope,self care

**Primary category:** Lifestyle  
**Secondary category:** Entertainment

**Privacy policy URL**  
https://tuna777123.github.io/mystic-tarot/privacy.html

**Support URL**  
https://tuna777123.github.io/mystic-tarot/support.html

**Marketing URL**  
https://tuna777123.github.io/mystic-tarot/

Localized store metadata:

- Turkish: `docs/STORE_LISTING_TR.md`
- Neutral international Spanish: `docs/STORE_LISTING_ES.md`
- French: `docs/STORE_LISTING_FR.md`
- Brazilian Portuguese: `docs/STORE_LISTING_PT_BR.md`

## Google Play metadata

**App name (30 characters max)**  
Mystic Tarot: Daily Ritual

**Short description (80 characters max)**  
Private tarot readings, pattern memory, a journal, and a daily ritual.

**Full description**

Your patterns are already speaking.

Mystic Tarot turns a card reading into a private daily practice. Choose the cards that call to you, open the seal, and receive reflection-first guidance grounded in traditional tarot symbolism.

RETURN FOR DAILY GUIDANCE

Begin each day with one clear card, a practical aligned action, and a 24-hour Mystic Mirror that asks what actually changed.

NOTICE WHAT REPEATS

Mystic remembers recurring cards, emotional shifts, and previous readings stored on your device, helping you compare patterns instead of forgetting them.

EXPLORE THE COMPLETE ARCANA

Awaken all 78 cards, unlock visual decks, build your Inner Constellation, earn XP, complete rituals, and collect achievements along your Mystic Path.

ASK A BETTER FOLLOW-UP

Use Oracle Dialogue to explore what you may not be seeing, which card carries the most weight, or what belongs in your next 24 hours.

PRIVATE BY DESIGN

Your journal, profile, progress, collection, and preferences stay on your device. Native subscription purchase history and entitlement status are processed by Apple or Google and RevenueCat so Mystic Plus can be verified securely.

Mystic Tarot is made for personal reflection and entertainment. It does not provide medical, mental-health, legal, financial, or emergency advice.

## Screenshot sequence

Use a consistent 9:16 device frame and only show subscription states produced by a signed sandbox or production build. Capture a complete set for English, Turkish, Spanish, French, and Brazilian Portuguese.

1. **Your patterns are already speaking** — onboarding portal.
2. **Choose the cards that call to you** — interactive card selection.
3. **Open the seal** — cinematic Reveal Ritual.
4. **Guidance that becomes action** — interpretation and aligned action.
5. **Mystic remembers what returns** — recurring-card pattern.
6. **Build your Inner Constellation** — Path, XP, rituals, and Arcana Vault.
7. **A journal that stays yours** — local journal and privacy controls.
8. **Go deeper with Mystic Plus** — official localized monthly/yearly products.

## App review notes

Mystic Tarot is a reflection and entertainment product. It does not claim factual prediction and states that readings are not professional advice.

The native release:

- does not require an account;
- stores journal and progress locally;
- does not include advertising or cross-app tracking SDKs;
- provides in-app local export and deletion;
- exposes Privacy Policy, Terms, and Support;
- uses RevenueCat to validate App Store and Google Play purchases;
- uses anonymous RevenueCat App User IDs because no authentication identity is supplied;
- disables automatic device-identifier collection and RevenueCat diagnostics;
- unlocks `mystic_plus` only for active entitlements with a trusted verification result;
- returns users to free limits after expiration, refund, or revocation.

The public web build does not process native subscriptions.

## App review test path

1. Complete onboarding.
2. Open Daily Guidance, select a card, open the seal, and save the reading.
3. Open Path and Journal to inspect local persistence.
4. Open Profile → Privacy & data to test local export and deletion.
5. Open Mystic Plus and confirm official localized monthly/yearly prices.
6. Purchase with a sandbox account and confirm Plus unlocks.
7. Reinstall or use a clean test device, choose Restore, and confirm Plus returns.
8. Expire or revoke the sandbox entitlement and confirm free limits return.
9. Repeat the pricing, legal-link, and narrow-screen checks in all five launch languages.

Provide Apple review credentials only if Apple requires a sandbox account for the review flow. The app itself has no login.

## Privacy declarations

The final native package contains `shared_preferences`, `purchases_flutter`, sharing, and audio dependencies. Recheck the generated dependency graph before every submission.

### Apple App Privacy

At minimum for the RevenueCat configuration used by Mystic Tarot:

- **Purchases → Purchase History:** Collected.
- **Purpose:** App Functionality and Analytics.
- **Linked to identity:** No, provided the app continues using RevenueCat-generated anonymous App User IDs and does not add login/contact identifiers.
- **Used for tracking:** No.
- **Other local journal/profile data:** Not collected by Mystic Tarot; it remains on-device.

Do not select “Data Not Collected” for the native paid build.

### Google Play Data Safety

At minimum:

- The app collects data: **Yes**.
- **Financial info → Purchase history:** Collected by RevenueCat.
- Encrypted in transit: **Yes**.
- Processed ephemerally: **No**.
- Required or optional: **Required** for subscription functionality.
- Purpose: **App functionality** and **Analytics**.
- Shared: **No**, unless a non-service-provider RevenueCat integration is later enabled.
- Advertising/tracking identifiers: **Not collected by the current app configuration**.

A monitored private support channel must be configured before claiming that users can request deletion of RevenueCat records. Local in-app deletion does not erase Apple, Google, or RevenueCat transaction records.

## RevenueCat production configuration

Follow `docs/REVENUECAT_SETUP.md`.

Required dashboard structure:

1. Add the iOS and Android apps to one RevenueCat project.
2. Connect App Store Connect credentials and Google Play service credentials.
3. Import `mystic_plus_monthly` and `mystic_plus_yearly` from both stores.
4. Attach all store products to entitlement `mystic_plus`.
5. Put monthly and yearly packages in the current offering.
6. Add each platform's public RevenueCat SDK key to the protected release build environment.
7. Never commit RevenueCat secret keys, App Store private keys, Play service-account JSON, keystores, or passwords.

## Launch offer

- Daily Guidance remains free.
- Free users receive three deep readings per day.
- Mystic Plus unlocks unlimited deep readings, premium spreads, and unlimited Oracle Dialogue follow-ups.
- Launch with monthly and yearly plans.
- Offer a seven-day trial only on yearly after trial eligibility is confirmed in both stores.

Prices must be selected in the store consoles and displayed from the official store response. Do not hardcode price text in screenshots or product copy.

## Launch languages

Version 1 launches with five complete product languages:

- English
- Turkish
- neutral international Spanish
- French
- Brazilian Portuguese

All five must remain complete across onboarding, navigation, readings, card content, reveal, results, Oracle Dialogue, Living Journal, Memory Map, Mystic Path, Arcana Vault, premium, profile, settings, export, deletion, privacy, terms, support, store metadata, screenshots, and purchase/restore QA. German and Italian remain hidden until complete end-to-end localization and release testing pass.

Localized legal pages:

- English: `privacy.html`, `terms.html`, `support.html`
- Turkish: `privacy-tr.html`, `terms-tr.html`, `support-tr.html`
- Spanish: `privacy-es.html`, `terms-es.html`, `support-es.html`
- French: `privacy-fr.html`, `terms-fr.html`, `support-fr.html`
- Brazilian Portuguese: `privacy-pt-br.html`, `terms-pt-br.html`, `support-pt-br.html`

## Account-owned actions before submission

These cannot be completed from the source repository alone:

1. Enroll in Apple Developer and Google Play Console.
2. Approve tax, banking, trader/business, and paid-app agreements.
3. Confirm ownership of `com.tunabozcali.mystictarot` on both platforms.
4. Create monthly/yearly subscriptions and their names, descriptions, prices, and trial rules in all five launch languages.
5. Create the RevenueCat project, connect store credentials, products, offering, and `mystic_plus` entitlement.
6. Add public RevenueCat SDK keys to protected release secrets.
7. Create Apple certificates/provisioning and the Android upload key; configure protected signing secrets.
8. Establish a monitored private customer-support email or support system for billing and privacy requests.
9. Capture localized screenshots from final signed builds.
10. Complete age rating, content rating, App Privacy, Data Safety, trader, and subscription questionnaires.
11. Run sandbox and real-device QA.
12. Upload signed builds and submit them for review.

## Release gate

A native build is eligible for submission only when:

- analysis and the complete automated test suite pass;
- signed release builds are generated with protected RevenueCat public SDK keys;
- real-device QA passes on one current iPhone and one current Android device;
- both store products load localized prices in all five launch languages;
- purchase, pending, cancellation, failure, renewal, expiration, refund/revocation, and restore are tested;
- only trusted, active `mystic_plus` entitlements unlock paid features;
- Privacy Policy and store disclosures match every integrated SDK;
- every localized privacy, terms, support, and marketing URL returns HTTP 200;
- a private billing/privacy support channel is monitored;
- no preview checkout, placeholder claim, fake price, or inactive control remains;
- the uploaded package is signed with the permanent production identifiers.

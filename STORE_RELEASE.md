# Mystic Tarot — Store Release Pack

This is the canonical launch handoff for App Store Connect and Google Play Console.

## Positioning

**Category:** Lifestyle  
**Primary promise:** A private daily tarot ritual that remembers recurring cards, emotions, and choices.  
**Differentiator:** Mystic combines cinematic readings with pattern memory, a 24-hour reflection loop, and a collectible 78-card journey instead of delivering one disposable prediction.

## App Store metadata

**Name (30 characters max)**  
Mystic Tarot: Daily Ritual

**Subtitle (30 characters max)**  
Tarot, Journal & Patterns

**Promotional text**  
Reveal the cards, notice what returns, and turn each reading into a private ritual that grows more meaningful over time.

**Keywords (100 characters max)**  
tarot,daily card,journal,oracle,reflection,spiritual,arcana,mindfulness,horoscope,self care

**Primary category**  
Lifestyle

**Secondary category**  
Entertainment

**Privacy policy URL**  
https://tuna777123.github.io/mystic-tarot/privacy.html

**Support URL**  
https://tuna777123.github.io/mystic-tarot/support.html

**Marketing URL**  
https://tuna777123.github.io/mystic-tarot/

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

The current release stores your profile, journal, progress, collection, and preferences locally on your device. Export your journal or delete all Mystic data whenever you choose.

Mystic Tarot is made for personal reflection and entertainment. It does not provide medical, mental-health, legal, financial, or emergency advice.

## Screenshot sequence

Use a consistent 9:16 device frame and no misleading subscription state.

1. **Your patterns are already speaking** — premium onboarding portal.
2. **Choose the cards that call to you** — interactive card selection.
3. **Open the seal** — cinematic Reveal Ritual.
4. **Guidance that becomes action** — revealed card, interpretation, and aligned action.
5. **Mystic remembers what returns** — Oracle Memory or recurring-card pattern.
6. **Build your Inner Constellation** — Path, XP, rituals, and Arcana Vault.
7. **A journal that stays yours** — private journal and export/delete controls.

## App review notes

Mystic Tarot is a reflection and entertainment product. It does not claim factual prediction and repeatedly states that readings are not professional advice.

The current release:

- does not require login;
- stores journal and progress locally;
- does not include ads or tracking SDKs;
- provides in-app export and deletion;
- exposes Privacy Policy, Terms, and Support;
- does not process payments in the public web build.

Test path:

1. Complete the three onboarding screens.
2. Open Daily Guidance.
3. Select one card.
4. Choose “Seal my selection.”
5. Choose “Open the seal.”
6. Save the reading.
7. Open Path and Journal to inspect persistence.
8. Open Profile → Privacy & data to test export and deletion.

## Privacy declarations for the current build

The codebase contains `shared_preferences` only and keeps product data on-device. Confirm the final generated native package contains no newly added analytics, advertising, crash, authentication, AI, or payment SDK before submitting these answers.

**Apple App Privacy:** Data Not Collected.  
**Google Play Data Safety:** No user data collected or shared by the app; data is not transmitted off-device.  
**Tracking:** No.  
**Account creation:** No.  
**Account deletion URL:** Not applicable because no account is created. Local deletion exists in-app.

## Native subscription catalog — reserved identifiers

Do not activate these products until billing and server-side entitlement validation are connected.

- `mystic_plus_weekly`
- `mystic_plus_monthly`
- `mystic_plus_yearly`

Recommended launch test:

- Keep Daily Guidance free.
- Keep three deep readings per day free.
- Offer monthly and yearly plans first.
- Do not launch the weekly plan in version 1; it weakens trust and makes the pricing screen feel aggressive.
- Test the seven-day trial only on yearly.

## Account-owned actions before native submission

These actions cannot be completed from the source repository:

1. Enroll in Apple Developer and/or Google Play Console.
2. Approve tax, banking, and paid-app agreements.
3. Confirm the permanent bundle/application ID.
4. Create the subscription products in the stores.
5. Connect receipt validation and entitlement infrastructure.
6. Create signing certificates, provisioning profiles, and Android upload key.
7. Capture screenshots from final signed builds.
8. Complete age-rating, content-rating, privacy, and data-safety questionnaires.
9. Upload the signed build and submit it for review.

## Recommended permanent identifiers

Confirm before the first store upload because changing them later is disruptive:

- iOS bundle ID: `com.tunabozcali.mystictarot`
- Android application ID: `com.tunabozcali.mystictarot`
- SKU: `mystic-tarot-ios-001`

## Release gate

A native build is eligible for submission only when:

- analysis and tests pass;
- real-device QA passes on one current iPhone and one Android device;
- store products load localized prices;
- purchase, pending, cancel, failure, renewal, expiration, refund, and restore states are tested;
- entitlements are validated securely;
- Privacy Policy matches every integrated SDK;
- support and policy URLs return HTTP 200;
- no “preview,” fake checkout, placeholder claim, or inactive control remains in the native build.

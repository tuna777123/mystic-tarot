# Mystic Tarot — Category Leader Benchmark

_Last reviewed: 2026-08-10_

## Product thesis

Mystic should not try to beat established tarot apps by accumulating the most decks, spreads, or adjacent divination tools. The launch wedge is a clearer closed loop:

> **Read today. Check reality tomorrow.**

A reading creates one aligned action, the 24-hour Mystic Mirror asks what actually happened, and repeated honest check-ins become private evidence that can reveal recurring cards, emotions, and choices.

That loop must be easier to understand, more memorable, and more respectful than a feature-count arms race.

## Current public benchmarks

### Labyrinthos

Public store positioning emphasizes tarot learning, daily wisdom, journaling, multiple divination systems, and a broad library of readings. This is the primary benchmark for breadth, education, visual identity, and established trust.

Reference: https://apps.apple.com/us/app/labyrinthos-tarot-reading/id1155180220

### Trusted Tarot

Public store positioning emphasizes a large catalog of readings and frequent access to premium readings. This is a useful benchmark for reading breadth and directness of the core tarot utility.

Reference: https://apps.apple.com/us/app/trusted-tarot/id1501242492

### Galaxy Tarot

A long-running Android benchmark with large historical reach, advertising, and in-app purchases. It is useful as a reminder that installed base and familiarity matter independently of visual polish.

Reference: https://play.google.com/store/apps/details?id=com.hemisphere3.tarot

## Screen-by-screen contract

### 1. First 60–90 seconds

**Mystic must win on comprehension, not exposition.**

Acceptance criteria:
- The user sees the signature promise before completing onboarding: **Read today. Check reality tomorrow.**
- The product explains the three-step evidence loop in one glance: now → tomorrow → evidence.
- Privacy is concrete: private history stays on-device; the experience does not require an account or cloud journal.
- Onboarding ends by immediately starting the first Daily Guidance reading. No dead-end home screen after the promise.
- No ad interrupts onboarding, card selection, ritual reveal, or the first reflection moment.

### 2. Card selection

**Mystic must feel intentional rather than transactional.**

Acceptance criteria:
- Card selection has a clear selected state and tactile feedback.
- The user can understand how many cards are required without reading a paragraph.
- Question and emotion context remain optional and do not block a quick first reading.
- The selected deck treatment stays visually coherent with the reveal.

### 3. Reveal

**Mystic must feel cinematic without becoming slow.**

Acceptance criteria:
- Ritual progression has a clear beginning, escalation, and reveal.
- Motion, haptics, and sound reinforce the moment but all remain safe under reduced-motion / accessibility behavior.
- No artificial loading spinner pretends interpretation is being generated remotely when it is not.
- The reveal lands directly in useful interpretation and one aligned action.

### 4. Reading result

**Mystic must turn symbolism into a next step.**

Acceptance criteria:
- Reflection framing is explicit: tarot is a mirror for reflection, not a fixed prediction.
- Interpretation is explainable rather than a black-box verdict.
- One aligned action is visually easy to find.
- The 24-hour Mystic Mirror continuation is visible before the user leaves the reading.
- Saving is the natural completion action, not a paywall boundary.

### 5. Mystic Mirror

**This is the retention moat and must receive product priority over new feature breadth.**

Acceptance criteria:
- When a check-in becomes due, it is visually prominent in the Living Journal.
- The question is reality-based: **What actually changed?**
- The interface explicitly rewards honest/no-change outcomes; it must never pressure users to validate a prediction.
- Completion records outcome + current emotion + optional note.
- The result becomes private pattern evidence and can contribute to recurring-pattern surfaces.
- Generic sharing never leaks the user's private reading, note, outcome, or journal content.

### 6. Pattern return

**Mystic must reward repetition with insight, not streak anxiety.**

Acceptance criteria:
- Repeated evidence can reveal recurring cards, emotions, and choices.
- Pattern surfaces never overstate causality or prediction accuracy.
- Empty and low-data states explain that useful patterns need repeated evidence rather than fabricating certainty.

### 7. Advertising quality bar

**Advertising may monetize completion, but it may not become the experience.**

Acceptance criteria:
- Public web remains ad-free.
- Native ads remain consent-gated.
- Interstitial opportunity remains after every third genuinely new saved reading, at a natural completion boundary.
- App-open remains returning-user only (at least three completed readings), after at least 30 seconds in background, and at least two hours between app-open impressions.
- A new cross-format cooldown prevents any two full-screen ads from being shown within 20 minutes, including across app restarts.
- True impression metrics remain tied to the ad SDK impression callback, never an attempted show.

## What Mystic deliberately does not copy

- Feature count as the primary value proposition.
- Prediction-accuracy scores.
- Fear-based urgency or supernatural certainty.
- A paywall before the user completes the core reflection loop.
- Aggressive ad stacking.
- Cloud collection of private journal content for growth analytics.

## Launch decision gates

The product is not declared a category leader from source quality alone. After store launch, the claim must be earned with cohorts and qualitative device testing.

Minimum evidence before meaningful paid scaling:
- onboarding → first saved reading: >= 75%
- D1 retention: >= 30%
- D7 retention: >= 15%
- mature Mystic Mirror completion within 72h: >= 35%
- crash-free sessions: >= 99.5%

Qualitative release gate:
- Compare the exact signed iOS and Android builds against the current leading benchmark on physical devices for first session, card selection, reveal, reading result, return-to-Mirror, and ad transitions.
- Any moment that feels slower, cheaper, less clear, or less trustworthy becomes a release-polish issue before feature expansion.

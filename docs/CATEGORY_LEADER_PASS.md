# Mystic Tarot — Category Leader Pass

Status: active product-quality contract for the advertising-only native release.

## Product standard

Mystic Tarot should not win by adding the most tarot features. It should win by making one loop unusually clear and valuable:

**Read today → choose one grounded action → return after ~24 hours → record what actually happened → accumulate private evidence → reveal recurring patterns.**

Mystic Mirror is the retention moat. Every launch-facing surface should make that loop easier to understand, complete, and trust.

## First 90 seconds

A new user should understand, without reading store copy, that Mystic Tarot is different from a generic card-of-the-day app.

1. Explain the continuity loop before asking for personal information.
2. Keep the first commitment lightweight: language → name → intention → first reading.
3. Immediately start the first Daily Guidance reading after onboarding.
4. Avoid prediction language. Frame the first reading as reflection plus one aligned action.
5. Make privacy visible without turning onboarding into a policy screen.

## Reading / reveal quality

The reveal should feel deliberate rather than gamified or noisy.

- Maintain reduced-motion behavior and accessibility semantics.
- Prefer one clear focal card at a time during reveal.
- Keep interpretation hierarchy consistent: card/position → synthesis → grounded action → journal.
- Do not use fake certainty, future scoring, or professional-advice framing.
- Keep the saved-reading completion state visibly connected to tomorrow's Mystic Mirror check-in.

## Mystic Mirror wow standard

Mystic Mirror is not a generic history/statistics screen. Its job is to close yesterday's loop.

The due state should answer three questions immediately:

1. **What am I checking?** A specific saved reading and the action I chose.
2. **Why now?** Roughly 24 hours have passed.
3. **Why bother?** My answer becomes private evidence that can reveal recurring cards, emotions, and choices.

When a check-in is complete, the app should avoid claiming the tarot was "right" or "wrong". The stored outcome is reflection evidence, not prediction accuracy.

## Advertising quality bar

Native mobile monetization is advertising-only; public web remains ad-free.

Ads must never make the product feel like a low-quality free tarot app:

- no banner ads;
- no rewarded gate for core reflection features;
- no ad before onboarding, first reading, card reveal, journal save, or Mystic Mirror completion;
- interstitial only after every third genuinely new saved reading;
- app-open ads only for established returning users, never first-session users;
- consent before requesting ads;
- count impressions only from the SDK's true impression callback;
- if consent, inventory, or production configuration is unavailable, fail closed and preserve the core experience.

## Competitive benchmark

Benchmark the product against the strongest current tarot apps by flow rather than feature count.

| Flow | Mystic Tarot target |
| --- | --- |
| Onboarding | Differentiator understood before first reading |
| Daily return | One obvious next action, no dashboard clutter |
| Reading | Premium-feeling reveal + explainable interpretation |
| Save | Reading becomes a continuing story, not a dead archive item |
| Day 2 | Mystic Mirror is the primary return trigger |
| History | Patterns connect cards + emotions + choices + outcomes |
| Privacy | Local-first promise is visible and accurate |
| Monetization | Ads are sparse, consent-aware, and never interrupt core reflection |

## Release gates

Do not call the product a proven category leader until real cohorts validate the experience.

- onboarding → first saved reading: minimum 75%, target 85%+
- D1 retention: minimum 30%, target 35%+
- D7 retention: minimum 15%, target 20%+
- D30 retention: minimum 8%, target 12%+
- mature Mystic Mirror completed within 72h: minimum 35%, target 50%+
- 7-day users active on >=3 days: minimum 20%, target 30%+
- completed Mirror generic share initiation: minimum 5%, target 10%+
- crash-free sessions: minimum 99.5%, target 99.8%+
- store rating: >=4.5 after >=100 ratings, target 4.7+

Paid acquisition stays blocked until three consecutive mature cohorts hit both D7 >=15% and mature 72h Mirror completion >=35%.

## Product rule

Until those gates are proven, prefer **polish, clarity, continuity, reliability, and retention evidence** over adding broad new tarot feature categories.
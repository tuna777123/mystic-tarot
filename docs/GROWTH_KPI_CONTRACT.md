# Mystic Tarot — Growth KPI Contract

Status date: **2026-08-09**  
Release line: `1.23.0+33`

This is an internal company operating contract, not a promise of financial returns. Mystic Tarot does not scale paid acquisition because the product feels polished; it scales only when retained cohorts and advertising economics prove that more users create more durable value.

## North-star loop

**Install → first saved reading → return → 24h Mystic Mirror → private pattern evidence → repeat → optional generic share → advertising opportunity that does not interrupt the core ritual.**

Mystic Mirror is the primary retention differentiator. New generic tarot content must not bury a due Mirror check-in.

## Launch gates

The following are internal scale thresholds. They deliberately sit above broad cross-category mobile-app retention medians reported by Adjust (about 26% D1, 13% D7 and 7% D30).

| Metric | Minimum scale gate | Target | Action below gate |
|---|---:|---:|---|
| Onboarding → first saved reading | 75% | 85%+ | Fix onboarding/value proposition before buying traffic |
| D1 retention | 30% | 35%+ | Fix first-return reason and reminder timing |
| D7 retention | 15% | 20%+ | Fix Mirror/pattern loop before scaling |
| D30 retention | 8% | 12%+ | Improve durable ritual and pattern value |
| Eligible Mirror completed within 72h | 35% | 50%+ | Treat as core-product failure, not a marketing problem |
| 7-day users active on >=3 distinct days | 20% | 30%+ | Strengthen habit loop |
| Completed-Mirror generic share initiation | 5% | 10%+ | Improve earned-share moment, never expose private content |
| Crash-free sessions | 99.5% | 99.8%+ | Stop acquisition until technical regression is fixed |
| Store rating after >=100 ratings | 4.5 | 4.7+ | Diagnose review themes before scaling |

## Paid acquisition rule

Do not materially scale paid user acquisition until **three consecutive mature cohorts** meet both:

1. D7 retention >=15%; and
2. 72-hour eligible-Mirror completion >=35%.

After enough revenue history exists, the economic gate is:

**Projected 90-day advertising LTV >= 1.5 × blended CAC.**

If this condition is not met, paid acquisition pauses. The team must improve product retention, geo mix, acquisition quality or ad economics instead of buying more installs.

## Kill / pivot signals

A small early cohort is noisy, so no single-day result is a verdict. Once there is a meaningful sample, trigger a product review when either persists across multiple cohorts:

- D1 retention <20%;
- eligible-Mirror completion within 72h <20%;
- onboarding → first saved reading <60%;
- crash-free sessions <99%;
- user reviews repeatedly identify ads as interrupting the ritual.

A failed gate does **not** mean increase ad frequency. It means improve the value loop first.

## Measurement principles

1. Private journal content is never a growth dimension.
2. Questions, notes, card names, user names, intentions, emotions, Mirror outcomes, PIN data and free text are excluded from business telemetry.
3. Coarse events/dimensions use the allow-listed `MysticBusinessMetrics` boundary.
4. Until a privacy-reviewed aggregate reporter exists, the application must not pretend remote KPI collection exists.
5. AdMob is the source of truth for ad impressions/revenue once production IDs are live; retention/product metrics require a separately reviewed aggregate measurement path.
6. Every experiment has a hypothesis, primary metric, guardrail metric and stop condition before launch.

## Source benchmarks

Broad benchmark context only; Mystic's actual category/geography mix will differ.

- Adjust retention benchmark: https://www.adjust.com/blog/what-makes-a-good-retention-rate/
- Adjust retention guide: https://www.adjust.com/resources/guides/user-retention/
- AppsFlyer retention glossary/benchmarks: https://www.appsflyer.com/glossary/retention-rate/

These external references can change. Current cohort data always overrides generic benchmark assumptions.

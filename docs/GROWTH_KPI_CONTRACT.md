# Mystic Tarot — Growth KPI Contract

Status date: **2026-08-09**  
Release line: `1.23.0+33`

This is an internal company operating contract, not a promise of financial returns. Mystic Tarot does not scale paid acquisition because the product feels polished; it scales only when retained cohorts and advertising economics prove that more users create more durable value.

## North-star loop

**Install → first saved reading → return → 24h Mystic Mirror → private pattern evidence → repeat → optional generic share → advertising opportunity that does not interrupt the core ritual.**

Mystic Mirror is the primary retention differentiator. New generic tarot content must not bury a due Mirror check-in.

## Launch gates

The following are internal scale thresholds. They deliberately sit above broad cross-category mobile-app retention medians used as context during the 2026-08-09 investment review.

| Metric | Minimum scale gate | Target | Action below gate |
|---|---:|---:|---|
| Onboarding → first saved reading | 75% | 85%+ | Fix onboarding/value proposition before buying traffic |
| D1 retention | 30% | 35%+ | Fix first-return reason and reminder timing |
| D7 retention | 15% | 20%+ | Fix Mirror/pattern loop before scaling |
| D30 retention | 8% | 12%+ | Improve durable ritual and pattern value |
| Mature Mirror completed within 72h | 35% | 50%+ | Treat as core-product failure, not a marketing problem |
| 7-day users active on >=3 distinct days | 20% | 30%+ | Strengthen habit loop |
| Completed-Mirror generic share initiation | 5% | 10%+ | Improve earned-share moment, never expose private content |
| Crash-free sessions | 99.5% | 99.8%+ | Stop acquisition until technical regression is fixed |
| Store rating after >=100 ratings | 4.5 | 4.7+ | Diagnose review themes before scaling |

## Exact Mirror denominator

The 72-hour gate is deliberately fail-closed.

A reading does **not** enter the denominator when it is created, when the 24-hour Mirror becomes due, or merely because the user opens the app. It enters the KPI only after the full 72-hour completion window has matured.

For each matured reading, the local evidence tracker emits exactly one deduped aggregate `mirrorWindowMatured` event and classifies it as:

- `completed_within_72h`; or
- `not_completed_within_72h`.

The company KPI is therefore:

**Mature 72h Mirror completion = `mirrorWindowMatured|growth_stage|completed_within_72h` / all `mirrorWindowMatured`.**

The reading identity used to prevent duplicate counting remains local-only and is excluded from exported Growth Evidence.

A zero/missing denominator is **NOT PROVEN**, never a pass.

## Retention denominator maturity

D1, D7 and D30 rates use only evidence files old enough to have reached the corresponding calendar-day boundary. Young installs cannot inflate or depress a denominator they have not matured into.

The deterministic cohort aggregator implements this rule:

```bash
dart run tool/aggregate_growth_evidence.dart \
  --as-of=YYYY-MM-DD \
  evidence-01.json evidence-02.json
```

## Paid acquisition rule

Do not materially scale paid user acquisition until **three consecutive mature cohorts** meet both:

1. D7 retention >=15%; and
2. mature 72-hour Mystic Mirror completion >=35%.

After enough revenue history exists, the economic gate is:

**Projected 90-day advertising LTV >= 1.5 × blended CAC.**

If this condition is not met, paid acquisition pauses. The team must improve product retention, geo mix, acquisition quality or ad economics instead of buying more installs.

Passing one aggregate report is not enough to override the three-consecutive-cohort rule.

## Kill / pivot signals

A small early cohort is noisy, so no single-day result is a verdict. Once there is a meaningful sample, trigger a product review when either persists across multiple cohorts:

- D1 retention <20%;
- mature 72-hour Mirror completion <20%;
- onboarding → first saved reading <60%;
- crash-free sessions <99%;
- user reviews repeatedly identify ads as interrupting the ritual.

A failed gate does **not** mean increase ad frequency. It means improve the value loop first.

## Measurement principles

1. Private journal content is never a growth dimension.
2. Questions, notes, card names, user names, intentions, emotions, Mirror outcomes, PIN data and free text are excluded from business telemetry.
3. Coarse events/dimensions use the allow-listed `MysticBusinessMetrics` boundary.
4. The current Growth Ledger is local and aggregate-only; automatic remote KPI upload is not claimed.
5. The local beta reporter stores no Mystic account/device/advertising identifier.
6. Ad impressions are counted from the Mobile Ads impression callback rather than treating an ad-show attempt as a proven impression.
7. A missing or immature denominator never passes a scale gate.
8. Every experiment has a hypothesis, primary metric, guardrail metric and stop condition before launch.

## External benchmark context

Generic benchmark references are context only; Mystic's actual category, geography and acquisition mix will differ. Current cohort evidence always overrides generic benchmark assumptions.

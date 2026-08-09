# Mystic Tarot — Closed Beta Measurement Protocol

## Purpose

Prove or reject the investment thesis with mature product evidence before material paid acquisition.

This protocol is for TestFlight / Google Play testing and controlled QA. It does not claim automatic remote analytics collection.

## Internal diagnostic build

Enable the hidden Growth Evidence entry with:

```bash
--dart-define=MYSTIC_GROWTH_DIAGNOSTICS=true
```

Keep ordinary public builds at the default `false` unless the product team intentionally decides otherwise.

The diagnostic screen exports **aggregate-only Growth Evidence JSON**. It does not export reading questions, card names, notes, emotions, outcomes, user name, intention, journal text, PIN/search history or internal dedupe tokens.

## Tester procedure

1. Start from the test cohort's agreed fresh-install state.
2. Use Mystic naturally; do not manufacture extra opens or Mirror completions to improve metrics.
3. Return on normal days when the product/reminder gives a real reason.
4. Complete Mystic Mirror honestly when appropriate.
5. At the cohort checkpoint, open **Your space → Growth evidence** in the internal build.
6. Use **Share aggregate evidence** and send only that JSON to the controlled cohort collection location.
7. Do **not** send a journal export as growth evidence.

## Cohort checkpoints

Collect a named cohort only after its required denominator is mature:

- D1 review: at/after calendar day +1;
- D7 scale review: at/after calendar day +7;
- D30 durability review: at/after calendar day +30;
- Mystic Mirror 72h rate: only from `mirrorWindowMatured` events.

Young installs are excluded from the corresponding retention denominator by the aggregator.

## Aggregate evidence

Example:

```bash
dart run tool/aggregate_growth_evidence.dart \
  --as-of=2026-09-30 \
  evidence/cohort-a/*.json
```

The report is fail-closed:

- zero/missing D7 denominator = NOT PROVEN;
- zero/missing mature-Mirror denominator = NOT PROVEN;
- private/internal export fields = rejected;
- impossible Mirror numerator > denominator = rejected.

## Company scale decision

Material paid acquisition remains blocked until **three consecutive mature cohorts** meet both:

- D7 retention >=15%;
- mature 72-hour Mystic Mirror completion >=35%.

After sufficient production advertising history exists, also require:

- projected 90-day advertising LTV >=1.5× blended CAC.

Passing a tiny or hand-picked cohort is not authorization to scale.

## Experimental discipline

Before changing onboarding, reminders, Mirror prompts, sharing or ad cadence, write down:

- hypothesis;
- primary metric;
- guardrail metric;
- cohort definition;
- minimum observation window;
- stop condition.

Do not run simultaneous changes that make the result impossible to attribute unless the purpose is an explicitly bundled release experiment.

## Advertising evidence

`adOpportunity` means the product reached an eligible advertising boundary.

`adImpression` is recorded from the Google Mobile Ads full-screen impression callback. Do not interpret a `show()` attempt as an impression.

AdMob remains the production revenue source of truth after real production IDs are live. The local Growth Ledger is a product-validation aid, not an accounting system.

## Privacy rule

If any Growth Evidence export contains private tarot content, an account/device/advertising identifier, or an internal dedupe token, stop collection and treat it as a release-blocking privacy defect.

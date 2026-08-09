# Mystic Tarot — Measurement Roadmap

## Current release line

`MysticBusinessMetrics` remains the strict product-safe event boundary.

This branch adds a **local, aggregate-only Growth Ledger** for closed beta and launch QA. It does not add Firebase, a third-party analytics SDK, an advertising identifier, an account identifier or automatic remote upload.

The local evidence model stores only coarse event/day counts and approved business dimensions. Both dimension names **and values** use a closed vocabulary, so private tarot content cannot be hidden inside an approved field such as `source`.

## Measurement baseline

Each installation gets a private, local-only measurement-start timestamp when the new evidence system first becomes active.

Readings created **before** that timestamp are excluded from the mature 72-hour Mystic Mirror KPI. This prevents an app update from backfilling old journal history into a new launch/beta cohort.

The exact measurement timestamp is operational state only. It is not included in shared Growth Evidence JSON.

For a clean company cohort, prefer a fresh install or an explicitly reset test device; do not mix upgraded legacy users into a fresh-install cohort and call the result comparable.

## What is measurable locally

- app opens / active calendar days, including real foreground returns;
- onboarding completion;
- genuinely new saved readings;
- Mirror due surfacing;
- raw Mirror completion timing;
- **mature 72-hour Mirror windows created after the measurement baseline**;
- whether each mature window was completed within 72 hours;
- generic Mirror share initiation;
- ad opportunities;
- real Mobile Ads `onAdImpression` callbacks.

The optional internal Growth Evidence screen is compile-time gated behind:

`MYSTIC_GROWTH_DIAGNOSTICS=true`

Default builds keep it hidden.

## Exact 72-hour Mirror KPI

Do not calculate the investment gate from all recent readings or from raw `mirrorCompleted` counts.

Each post-baseline reading becomes eligible for the mature cohort denominator only after its full 72-hour completion window closes. At that moment the local tracker emits one deduped `mirrorWindowMatured` aggregate event, classified as:

- `completed_within_72h`; or
- `not_completed_within_72h`.

Therefore:

**Mature Mirror 72h completion rate = mature windows classified `completed_within_72h` / all `mirrorWindowMatured` events.**

A reading identifier is used only as an internal local dedupe token. It is deliberately excluded from exported Growth Evidence.

## Retention maturity

D1, D7 and D30 are evaluated only when an evidence file is old enough for the corresponding denominator. The aggregator recomputes retention from active calendar days rather than trusting a supplied boolean. A missing or immature denominator is never interpreted as a pass.

Use:

```bash
dart run tool/aggregate_growth_evidence.dart \
  --as-of=2026-09-30 \
  evidence/tester-01.json evidence/tester-02.json
```

The aggregator rejects unexpected privacy models, internal dedupe fields, unapproved metric vocabularies, inconsistent retention claims, incomplete mature-Mirror classifications and impossible numerator/denominator states.

## Before material paid acquisition

Local beta evidence is useful for product validation, but material paid scaling still requires controlled cohort collection across **three consecutive mature cohorts** and the gates in `GROWTH_KPI_CONTRACT.md`.

If a remote aggregate reporter is later selected:

1. Review SDK/network data behavior.
2. Update privacy policy and store declarations before production enablement.
3. Keep the source-level private-field and value-vocabulary rejection boundary.
4. Verify consent/legal-basis requirements by launch region.
5. Run signed-binary Android/iOS privacy audits.
6. Reconcile remote counts with the deterministic local beta contract before trusting the new pipeline.

## Never collect as business-metric dimensions

- reading questions;
- journal or Mirror notes;
- card names;
- user names;
- intentions;
- emotion selections;
- Mirror outcomes;
- PIN data;
- search queries;
- arbitrary free text;
- account/device/advertising identifiers through the Mystic business-metric boundary.

Measurement is an observability side effect. A metrics/storage failure must not block the tarot product, Mystic Mirror, sharing, navigation or advertising flow.

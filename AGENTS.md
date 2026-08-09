# Mystic Tarot — Engineering Agent Contract

This file is the default operating contract for Codex and any other coding agent working in this repository.

## Product identity

- Mystic Tarot is a free, local-first tarot and reflection app.
- Native Android and iOS revenue is advertising-only through Google Mobile Ads with UMP consent handling.
- The public web edition is ad-free.
- Launch languages are exactly English, Turkish, Spanish, French, and Brazilian Portuguese unless a deliberate launch-language change is separately approved and fully tested.
- Mystic Mirror is the primary retention differentiator: a reading is followed by a reality check after roughly 24 hours and mature 72-hour completion evidence is measured locally.
- The product is for reflection and entertainment, not factual prediction or professional medical, mental-health, legal, financial, or emergency advice.

## Non-negotiable privacy rules

- Never transmit or add analytics dimensions containing reading questions, card names, journal text, Mirror notes, emotions, outcomes, user names, intentions, PIN data, search history, arbitrary free text, or local dedupe identifiers.
- Growth evidence must remain aggregate-only and fail closed on unknown dimensions or values.
- Do not add Firebase, another analytics SDK, an account identifier, device identifier, advertising identifier, or automatic remote growth upload without an explicit privacy and store-disclosure review.
- Do not expose the private local measurement-start timestamp or internal dedupe tokens in exported Growth Evidence.
- Generic public sharing must never include private tarot content.

## Monetization rules

- Do not add subscriptions, paid plans, paid packs, checkout, restore-to-unlock, paid entitlements, RevenueCat, or `purchases_flutter` to the production runtime.
- Formerly gated product value remains available without payment.
- Native advertising remains Google Mobile Ads + UMP.
- Never request an ad before consent state permits it.
- Preserve the reviewed cadence and eligibility rules unless an explicit experiment changes them with documented hypothesis, guardrails, and tests.
- Real ad impressions are counted only from the Mobile Ads impression callback, never from a `show()` attempt.
- Production AdMob IDs must be provided through protected configuration; never hard-code owner production identifiers or secrets into source.

## Secrets and signing

- Never commit keystores, P12 files, provisioning profiles, signing passwords, service-account JSON, private keys, or other production secrets.
- Production signing remains owner-controlled through protected repository/environment secrets.
- Never print or persist secret values in logs, issues, PR bodies, test fixtures, screenshots, generated documentation, or artifacts.
- Never replace production signing with debug signing in a release workflow.

## Release invariants

- Application ID / bundle ID: `com.tunabozcali.mystictarot`.
- Current release line: `1.23.0+33` until intentionally version-bumped.
- Android Play submission target-SDK floor is API 36 in the current release contract.
- Keep store identity, signing verification, Android bundle audit, Built-in Kotlin audit, Apple submission SDK gate, public launch verifier, and release artifact checks fail closed.
- `app-ads.txt`, AdMob app readiness, UMP, signed-device QA, store privacy declarations, and store approvals are production go-live gates; source CI cannot pretend they are complete.

## Required validation before merge

For every change that can affect runtime or release behavior, run the repository's existing canonical validation path. At minimum the final PR head must pass:

1. Dart formatting / clean diff checks.
2. Public launch-surface verification.
3. `flutter analyze --fatal-infos`.
4. Full Flutter test suite.
5. Web release build when touched by the standard CI path.
6. Android release AAB build.
7. Built-in Kotlin compatibility audit.
8. Pinned bundletool validation and Android bundle audit.
9. Unsigned iOS Release build and release application verification.

Do not merge because a partial run looks good. Accept only a stable final PR head for which the required Flutter and iOS workflows are green.

## Development discipline

- Prefer one coherent worktree/branch and one final PR over many small remote commits that repeatedly cancel CI.
- Format and test locally before pushing when a capable local/Codex environment is available.
- Keep product flows usable when metrics, ads, consent, notifications, or optional services fail.
- Preserve reduced-motion behavior, narrow-screen layouts, iPad-safe share origins, private app lock, protected transfer, and all five launch languages.
- Avoid generic feature accumulation. New product work should strengthen activation, Mystic Mirror return behavior, durable private patterns, trust, or measured retention.
- Material paid acquisition remains blocked until the repository's growth contract is satisfied by three consecutive mature cohorts and the later unit-economic gate is met.

## Evidence and documentation

- Keep `STORE_RELEASE.md`, `docs/GROWTH_KPI_CONTRACT.md`, `docs/BETA_MEASUREMENT_PROTOCOL.md`, store/privacy runbooks, and issue #114 aligned with meaningful release changes.
- Do not claim store availability, live production ads, production signing, app-ads verification, real-device QA, or store approval without direct evidence from the relevant owner-controlled system.
- When a limitation belongs to an external account or physical device, state it explicitly rather than weakening source safeguards.

## Default agent decision rule

If a requested change conflicts with any rule above, do not silently implement it. Preserve the release invariant, explain the conflict in the PR or work summary, and choose the safer implementation that keeps privacy, ad-only monetization, release verification, and user trust intact.

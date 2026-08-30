# Mystic Tarot — Final A–Z Codex Handoff

This file is the canonical continuation brief for Codex. Read it completely before changing the repository. It intentionally combines product intent, non-negotiable decisions, repository state, release architecture, current CI evidence, and the order of work required to finish the app professionally and move it through store release.

## 1. Mission

Finish Mystic Tarot from the current release-handoff branch through a clean, reproducible, production-ready Android/iOS release without reopening product scope unnecessarily.

The application is already feature-rich. The immediate mission is not a redesign. It is:

1. finish the remaining release-hardening work;
2. make the exact candidate CI clean and deterministic;
3. eliminate stale/contradictory release contracts;
4. merge one canonical release path to `main` only after exact-head validation;
5. prepare and execute everything that can be done without owner-only accounts/credentials;
6. stop only for genuinely owner-controlled actions such as payment, 2FA, legal acceptance, tax/banking, production store credentials, signing secrets, or irreversible public submission approval.

Do not declare the app launched merely because tests pass.

## 2. Repository / branch / PR

Repository: `tuna777123/mystic-tarot`

Canonical working branch: `release/final-codex-handoff`

Canonical pull request: PR #162 — `Finalize Release Candidate and Codex production handoff`

Base branch: `main`

PR #161 was superseded/closed. Do not revive it and do not create another competing release branch unless a repository-protection rule technically forces one.

At the time this final handoff was created, the previously validated head before this document commit was:

`0badc582730d122f5db45c765356a03747704b91`

Always fetch current remote state first because the handoff commit itself moves the branch head.

## 3. Product identity

Product name: Mystic Tarot

Canonical package / bundle identifier: `com.tunabozcali.mystictarot`

Current release version: `1.23.0+33`

Launch languages: English, Turkish, Spanish, French, Brazilian Portuguese.

The codebase may still contain historical test/module/file names containing words such as `premium`, `subscription`, `Plus`, entitlement, purchase, or revenue. Treat those names as historical unless runtime/product contracts say otherwise. User-facing launch behavior is governed by the advertising-only rule below.

## 4. Absolute monetization decision

The owner made a hard product decision: production monetization is **advertising only**.

Non-negotiable consequences:

- no subscription revenue;
- no production IAP paywall;
- no paid feature gate;
- no RevenueCat production revenue path;
- previously paid/premium product functionality must remain accessible without payment;
- do not reintroduce Plus/premium gating because old tests or branches contain those names;
- production ads use Google Mobile Ads / AdMob and UMP consent;
- only request/load ads when consent state permits (`canRequestAds()` or the production-equivalent gate already implemented);
- do not increase interruption frequency to compensate for weak retention.

The current ad-experience contract already tested in the repository includes:

- full-screen cross-format cooldown: 45 minutes;
- app-open ads only for established returning users;
- app-open only after at least one prior saved reading;
- app-open format-specific cooldown: 6 hours;
- interstitial cadence tied to every fourth genuinely new saved reading;
- recent interstitial suppresses otherwise eligible app-open advertising;
- ad disruption state begins on a real impression, not merely an attempted load.

Preserve these unless there is a documented policy/store blocker. Do not casually make ads more aggressive.

## 5. Product core / moat

The strategic differentiator is **Mystic Mirror** and the evidence/pattern loop.

Primary retention loop:

`reading → grounded action → 24h Mystic Mirror → private evidence / pattern recognition`

Mystic Mirror should reward honest reality evidence rather than pretend prediction certainty.

Preserve and protect:

- reading flows;
- grounded next actions;
- 24-hour Mirror check-in;
- Living Journal / complete reading history;
- Pattern / Memory / Living Fate style private insights;
- daily ritual and reminder flow;
- private Oracle follow-up/memory where implemented;
- private transfer/backup flows;
- app lock / biometric/PIN privacy features;
- localization;
- privacy-safe aggregate measurement.

Do not expand unrelated feature scope during this release pass.

## 6. Product philosophy and safety boundaries

Mystic Tarot should behave as a reflective/spiritual companion, not as a source of guaranteed future prediction.

Preserve grounded framing, explainability, bounded interpretation, clear user agency, and reality-based follow-up.

Do not introduce:

- certainty claims about future events;
- medical/legal/financial certainty framed as divination;
- public sharing of private journal content by default;
- hidden upload of private reading/journal text;
- identity-like analytics fields;
- private content embedded inside analytics dimension values.

The repository has business-metric guards intended to allow aggregate/coarse evidence only. Keep them fail-closed.

## 7. UX and application shape

The product already includes a substantial Flutter application. Do not simplify it into an old prototype model.

Existing tested capabilities include, among others:

- onboarding;
- multiple tarot reading types;
- card selection/reveal ritual;
- localized card names/meanings/advice;
- reading synthesis across EN/TR/ES/FR/PT-BR;
- Living Journal without the historical 50-record cap;
- Mystic Mirror 24-hour follow-up;
- recurring pattern detection;
- Mystic Journey;
- Living Fate / destiny-style private timeline;
- Mystic identity/evolution views;
- private Oracle conversation memory;
- daily practice;
- reminder scheduling;
- private transfer and passphrase-protected transfer;
- app lock with PIN/biometric support;
- reduced-motion behavior;
- store screenshot generation;
- localized legal/support/store material.

If old prototype notes conflict with current repository tests, current repository behavior wins.

## 8. Launch language rule

The five launch languages are:

- EN
- TR
- ES
- FR
- PT-BR

German/Italian or other language traces may exist internally, but launch selectors and store-ready surfaces are expected to expose only the five complete launch languages unless a new complete localization program is deliberately approved.

Do not allow accidental English fallback inside the five launch languages on core product/store flows.

## 9. Release architecture — canonical paths

The goal is one canonical path per release surface.

Canonical signed store release workflow:

`.github/workflows/store-release.yml`

Canonical public Pages deployment:

`.github/workflows/pages.yml`

Obsolete duplicate release paths were removed:

- `.github/workflows/store-android.yml`
- `.github/workflows/web-preview.yml`

Do not restore them.

Release Candidate:

`.github/workflows/release-candidate.yml`

Primary Flutter CI:

`.github/workflows/flutter-ci.yml`

iOS release CI:

`.github/workflows/ios-ci.yml`

Store screenshot workflow should remain evidence-bound to app version/source commit.

## 10. Deterministic Flutter toolchain

Release-tested Flutter toolchain is pinned to:

`Flutter 3.44.9`

This was introduced because floating `stable` moved to Flutter 3.47.1 and caused release behavior/dependency materialization drift.

Do not casually remove this pin. An upgrade is allowed only as an intentional release-toolchain upgrade with dependency graph review and full re-audit.

`google_mobile_ads` is intentionally exactly pinned at `9.0.0` in the current release-tested dependency contract.

Do not broad-upgrade dependencies merely because newer versions exist.

## 11. Native scaffold / lockfile root cause — proven behavior

A critical CI issue was diagnosed experimentally.

`flutter create . --platforms=... --no-pub`

can still replace the repository's real `pubspec.lock` during native shell generation with temporary Flutter-template lock content.

This caused `flutter pub get --enforce-lockfile` to appear as if ~125 dependencies needed to change.

The application lock graph itself was not the root cause.

The working sequence was proven under Flutter 3.44.9:

1. preserve repository `pubspec.yaml` and `pubspec.lock`;
2. run native `flutter create ... --no-pub`;
3. restore the original dependency source files;
4. verify byte identity;
5. immediately run `flutter pub get --enforce-lockfile`;
6. only then run Dart/Flutter configurators and build tooling.

This sequence successfully passed dependency installation.

Canonical helper added for this purpose:

`tool/scaffold_native_preserving_sources.sh`

Inspect and harden this helper. It should:

- use `set -euo pipefail`;
- validate arguments;
- accept a platform list;
- preserve both `pubspec.yaml` and `pubspec.lock` safely;
- run `flutter create` with `--no-pub`;
- restore the source files even on failure, preferably through `trap`;
- verify byte identity after restoration;
- never perform an unlocked dependency install;
- leave `flutter pub get --enforce-lockfile` to the calling workflow immediately after the helper.

## 12. What is already confirmed working on the last pre-handoff exact head

On exact head `0badc582730d122f5db45c765356a03747704b91`:

- iOS Release CI: **SUCCESS**;
- Generate Store Screenshots: **SUCCESS**;
- Temporary Scaffold Preservation Check: **SUCCESS**;
- Flutter CI reached and passed native scaffold + `flutter pub get --enforce-lockfile`;
- Release Candidate reached and passed native scaffold + `flutter pub get --enforce-lockfile`;
- Release Candidate `git diff --check`: passed;
- Release Candidate public launch-surface verification: passed for Mystic Tarot `1.23.0+33`;
- Release Candidate `flutter analyze --fatal-infos`: passed with `No issues found!`;
- dependency lock contract test itself passed inside the RC suite;
- hundreds of product/release/privacy/localization tests passed.

Therefore: **do not reopen the old lockfile diagnosis. The scaffold-preservation direction is validated.**

## 13. Current exact failures to fix first

Two concrete failures remained on the last pre-handoff exact head.

### 13.1 Flutter CI formatting failure

Flutter CI failed at `Verify changed Dart formatting` because:

`test/dependency_lock_contract_test.dart`

was not in canonical `dart format` output.

The CI log explicitly reported that `dart format` changed 1 of 3 changed Dart files.

First fix: run `dart format test/dependency_lock_contract_test.dart` (and format all touched Dart files as required), commit the resulting formatting only, and do not weaken the formatting gate.

The subsequent `Upload Flutter test log` also failed because tests never ran, so the log file did not exist. This is secondary to the format failure; once formatting passes, the normal test step should create the log. Consider making the upload robust to pre-test failures only if that is consistent with repository evidence-retention expectations, but do not hide a real test failure.

### 13.2 Release Candidate stale contract test

Release Candidate ran **568 tests passed, 1 failed, 1 skipped**.

The only failing test was:

`test/release_candidate_workflow_contract_test.dart`

Failure reason: the test still expected the old literal raw scaffold command:

`flutter create . --platforms=android,ios --org com.tunabozcali --no-pub`

but the workflow now correctly uses:

`bash tool/scaffold_native_preserving_sources.sh --platforms=android,ios --org com.tunabozcali`

This is a stale test assertion, not evidence that the helper is wrong.

Fix the contract test so it requires the **new canonical helper-based native materialization path** and still proves that:

- native scaffolding cannot silently rewrite dependency sources;
- locked dependency installation follows;
- release candidate validates before main;
- only protected production workflow can produce signed store builds;
- only canonical Pages workflow deploys the public site.

Do not simply delete the test.

## 14. Temporary diagnostic workflow must be removed

A temporary diagnostic workflow exists:

`.github/workflows/lockfile-refresh-bootstrap.yml`

It evolved into the scaffold-preservation proof workflow and its purpose is fulfilled.

Delete it before finalizing PR #162.

The finished release branch must not contain a temporary lockfile-refresh/bootstrap diagnostic workflow.

## 15. Production Store Release migration still requires verification

Before this final handoff, `store-release.yml` still needed careful verification/migration to the preserving helper in all raw native scaffold paths.

Inspect at minimum these three production paths:

- source validation: Android + iOS scaffold;
- signed Android release scaffold;
- signed iOS release scaffold.

Every active native scaffold path must follow the canonical sequence:

`tool/scaffold_native_preserving_sources.sh` → `flutter pub get --enforce-lockfile` → configurators/build tooling

There must be no raw `flutter create` path that can silently replace the source lockfile.

Also scan all active `.github/workflows/*.yml` files for:

- `flutter create`;
- `flutter pub get`;
- `subosito/flutter-action`;
- Flutter version pins.

Requirements:

- no accidental unlocked `flutter pub get`;
- no release-critical floating Flutter toolchain;
- no unsafe raw native scaffold route;
- no project tooling inserted between scaffold restoration and enforced dependency installation.

## 16. Regression-test expectations

`test/dependency_lock_contract_test.dart` should represent the final architecture, not the obsolete raw-command architecture.

It should protect against:

- unlocked `flutter pub get`;
- missing committed `pubspec.lock`;
- drift of the exact Mobile Ads wrapper pin unless intentionally reviewed;
- release Flutter actions not pinned to the validated toolchain;
- native release workflows bypassing `tool/scaffold_native_preserving_sources.sh`;
- helper losing `--no-pub`;
- helper failing to preserve/restore dependency sources;
- another Dart/Flutter tool running before enforced dependency installation;
- reintroduction of obsolete duplicate release workflows.

Prefer architectural assertions over brittle counts when possible. If a count is retained, it must reflect the real canonical workflow topology rather than historical duplicates.

## 17. CI / release gates that must not be weakened

Do not bypass or water down:

- `dart format` checks;
- `git diff --check`;
- `flutter analyze --fatal-infos`;
- full Flutter tests;
- dependency-lock contract;
- canonical release workflow contracts;
- Android API 36 target requirement;
- Android 16 KB native-library/page-alignment checks;
- Android bundle audit;
- Built-in Kotlin compatibility warning policy;
- Android signature and certificate fingerprint verification;
- iOS certificate/provisioning identity verification;
- Apple submission SDK gate;
- iOS privacy manifest audit/evidence;
- Mobile Ads SDK evidence;
- UMP/AdMob production preflight;
- public legal/support URL health gates;
- artifact checksum/release manifest evidence;
- protected production environment boundaries.

The goal is real release confidence, not merely green badges.

## 18. Android release expectations

Before production launch, verify all of the following on the exact candidate:

- package `com.tunabozcali.mystictarot`;
- version `1.23.0+33` unless deliberately bumped;
- target SDK 36;
- compile SDK 36 where required by current project contract;
- 16 KB compatibility evidence;
- production AAB builds successfully;
- signed AAB verifies successfully;
- upload certificate SHA-256 matches the protected expected fingerprint;
- bundletool audit passes;
- Mobile Ads SDK evidence passes;
- only approved advertising/attribution components are present;
- production test ads are disabled;
- real AdMob IDs are used only through protected production configuration;
- UMP real-device behavior is verified;
- Play Console declarations/privacy/data safety/content rating are consistent with the shipped binary;
- pre-launch/closed-testing evidence is complete before public production rollout.

## 19. iOS release expectations

Before production launch, verify all of the following on the exact candidate:

- bundle identifier `com.tunabozcali.mystictarot`;
- correct Apple Team ID;
- current Apple submission SDK floor as enforced by repository tooling;
- valid distribution certificate;
- expected distribution certificate SHA-256;
- valid provisioning profile matching team + bundle ID;
- signed archive / exported IPA;
- exported app certificate identity verified;
- iOS privacy manifests inventoried and audited;
- production AdMob application ID and reviewed SKAdNetwork catalog materialized correctly;
- production test ads disabled;
- UMP/privacy/ATT behavior reviewed as applicable to the actual binary;
- App Store Connect privacy/content/store metadata matches implementation;
- exact candidate goes through TestFlight/QA before public release unless owner deliberately chooses an allowed alternative.

## 20. Store / public web material

Canonical store/legal/public material already exists in the repo and has extensive tests.

Important source documents include:

- `docs/STORE_LISTING_INDEX.md`
- `docs/CONTENT_RATING_OWNER_WORKSHEET.md`
- `docs/STORE_PRIVACY_WORKSHEET.md`
- `docs/APP_ADS_TXT_RUNBOOK.md`
- `docs/FINAL_DELIVERY.md`
- `docs/OWNER_FINAL_CHECKLIST.md`

Launch-language store metadata tests already passed on the last candidate.

Public legal/support URL verification also passed in the last RC run.

Do not invent marketing claims such as ranking, guaranteed outcomes, or unsupported performance claims.

## 21. app-ads.txt

Repository-side runbook exists, but final app-ads.txt go-live requires the real AdMob publisher line/domain configuration controlled by the owner/account.

Do not fabricate publisher IDs.

When real values are available:

- materialize exactly the required publisher line;
- host it at the correct root domain endpoint;
- verify public HTTP response and exact content;
- ensure store listing developer website/domain relationship is consistent.

## 22. Owner-controlled blockers

Codex should continue autonomously until genuinely blocked by something in this category:

- Google Play Developer enrollment/payment;
- Apple Developer enrollment/payment;
- account 2FA;
- legal agreements requiring the owner;
- tax/banking information;
- production AdMob account values/IDs that do not exist in the repo;
- real app-ads.txt publisher ID;
- Android upload keystore and protected passwords/fingerprint ownership;
- Apple distribution certificate/provisioning/profile/team credentials;
- protected GitHub environment secrets if only the owner can supply them;
- irreversible public production rollout/submission approval.

When blocked, ask for the smallest concrete owner action possible. Do not ask the owner to perform ordinary repo/CI work that Codex can do itself.

## 23. Exact order of work from here

Follow this order unless fresh repository evidence demonstrates a better dependency order:

1. Fetch latest `release/final-codex-handoff` and PR #162 state.
2. Read `AGENTS.md`, `CODEX_HANDOFF.md`, `CODEX_CURRENT_STATE.md`, this file, and issue #114.
3. Inspect PR #162 diff and all exact-head workflow runs.
4. Fix formatting in `test/dependency_lock_contract_test.dart` and any other touched Dart source.
5. Update `test/release_candidate_workflow_contract_test.dart` to expect the helper-based canonical scaffold path.
6. Finish/harden `tool/scaffold_native_preserving_sources.sh` if needed, including failure-safe restoration.
7. Migrate/verify every active production native scaffold path, especially `store-release.yml`.
8. Remove `.github/workflows/lockfile-refresh-bootstrap.yml`.
9. Update `CODEX_CURRENT_STATE.md` / `CODEX_HANDOFF.md` so they describe the proven helper-based lockfile solution and contain no stale instruction to broad-refresh dependencies.
10. Run formatting, focused tests, full tests, analysis, diff checks and repository release verifiers.
11. Push to the same handoff branch.
12. Capture the new exact head SHA.
13. Require Flutter CI + iOS Release CI + Release Candidate green on that exact head. Inspect any other required protection checks too.
14. If red, inspect actual logs and fix root cause without weakening gates.
15. Only when exact final head is green, merge PR #162 to `main` according to repository merge policy.
16. Fetch canonical `main`, record merged SHA, and verify Release Candidate again on main.
17. Continue issue #114 / store-release runbook until an owner-only credential/account step is encountered.
18. Produce exact signed release artifacts only through the canonical protected production workflow.
19. Complete real-device/test-track/TestFlight QA.
20. Ask the owner for final irreversible public submission approval only when every technical/repository item that can be completed autonomously is complete.

## 24. Merge rule

Never merge based on an older green SHA.

After the final repository change, use the exact final PR head SHA.

At minimum these must be green on that exact head:

- Flutter CI;
- iOS Release CI;
- Release Candidate.

Also respect any repository-required protection/status checks.

If the head changes after a green run, validate the new head again.

## 25. Do not regress product decisions because historical tests remain

The repository contains historical test names and modules associated with old subscription/Plus plans. Some may intentionally remain as migration/backward-compatibility contracts.

Do not infer from those names that paid monetization should return.

The advertising-only runtime and user-copy contract is authoritative.

If a stale test contradicts the ad-only launch architecture, determine whether it is a historical compatibility test or an obsolete assertion and update it carefully while preserving coverage.

Never reintroduce a paid state just to satisfy an old test.

## 26. Quality standard

The owner wants the app finished professionally before store submission.

Treat UI overflow, broken localization, stale copy, privacy regressions, bad release evidence, flaky CI, signing ambiguity, wrong store metadata, or inconsistent release paths as real blockers.

Do not use store submission as a substitute for fixing known problems.

Do not over-engineer unrelated features during final hardening.

## 27. Evidence from the last RC run worth preserving

The last RC run on the pre-handoff head established a strong baseline:

- `flutter pub get --enforce-lockfile` succeeded after helper scaffold;
- public launch surface passed for `1.23.0+33`;
- `flutter analyze --fatal-infos` returned no issues;
- 568 tests passed;
- only one test failed, and it was the stale raw-scaffold assertion in `release_candidate_workflow_contract_test.dart`;
- one store screenshot generator partition test was intentionally skipped;
- dependency-lock contract passed;
- Android 16 KB contract tests passed;
- API 36 bundle audit contract tests passed;
- advertising-only runtime contract tests passed;
- UMP/Mobile Ads contract tests passed;
- iOS AdMob/SKAdNetwork contract tests passed;
- iOS privacy manifest contract tests passed;
- certificate/fingerprint contract tests passed;
- five-language store metadata limit tests passed;
- Mystic Mirror, journal, Journey, Memory, app-lock, transfer, localization and growth/privacy tests broadly passed.

This means the branch is close to release-handoff cleanliness. Focus on the concrete remaining failures instead of reopening already-passing systems.

## 28. Definition of repository-side completion

Repository-side release hardening is complete only when:

- no temporary diagnostic workflow remains;
- no duplicate release path remains;
- helper-based native materialization is canonical everywhere needed;
- dependency source files remain deterministic;
- no unlocked dependency install exists in active release workflows;
- required toolchain pin is consistent;
- all touched source is formatted;
- full tests pass;
- analysis passes;
- all required exact-head CI is green;
- PR #162 is merged to main;
- canonical main is re-verified;
- handoff docs reflect actual final state.

## 29. Definition of production launch completion

Production launch is complete only after repository-side completion plus:

- owner accounts are valid;
- production signing credentials are installed/verified;
- real AdMob/UMP production configuration is validated;
- app-ads.txt is live with real owner-controlled publisher data;
- store privacy/content/data declarations are completed accurately;
- exact signed Android/iOS artifacts pass audits;
- real-device QA passes;
- Play testing / TestFlight or equivalent pre-public validation is complete;
- owner gives final irreversible public release approval;
- store submission/rollout is actually executed and its result is recorded.

Green CI alone is not launch.

## 30. Required final Codex report

When the work is complete or genuinely owner-blocked, report in this format:

- repository;
- final working branch;
- PR number/state;
- final exact PR head SHA;
- files changed;
- root causes fixed;
- formatting result;
- `flutter analyze` result;
- Flutter test total/pass/fail/skip;
- Flutter CI exact-head result;
- iOS Release CI exact-head result;
- Release Candidate exact-head result;
- any additional required checks;
- whether PR #162 was merged;
- canonical main SHA after merge;
- main post-merge RC result;
- Android release evidence status;
- iOS release evidence status;
- production AdMob/UMP status;
- signing status;
- app-ads.txt status;
- store-console status;
- remaining owner-only blockers;
- next single concrete action.

Do not say `ready`, `launched`, or `done` unless the evidence in this checklist supports the claim.

## 31. Immediate first commands/checks for Codex

Start by effectively doing the equivalent of:

- fetch latest remote branch and PR state;
- inspect `git status` / exact HEAD;
- run `dart format --output=none --set-exit-if-changed test/dependency_lock_contract_test.dart test/release_candidate_workflow_contract_test.dart`;
- inspect `test/release_candidate_workflow_contract_test.dart` against `.github/workflows/release-candidate.yml`;
- inspect `tool/scaffold_native_preserving_sources.sh`;
- search active workflows for raw `flutter create`, unlocked `flutter pub get`, and missing Flutter `3.44.9` pins;
- inspect `store-release.yml` source-validation / Android / iOS scaffold steps;
- remove the temporary diagnostic workflow after its proof is encoded in permanent helper/tests;
- run focused release contract tests;
- run full validation required by `AGENTS.md`;
- push only to the canonical handoff branch;
- validate exact final SHA before merging.

Proceed autonomously. Ask the owner only for true owner-controlled release/account/credential/irreversible actions.

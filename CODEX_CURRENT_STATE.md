# Codex Current Starting State

Read this file first, then `AGENTS.md`, `CODEX_HANDOFF.md`, and `CODEX_FINAL_HANDOFF.md`.

## Canonical branch / PR

- Open PR: **#162 — Finalize Release Candidate and Codex production handoff**
- Working branch: `release/final-codex-handoff`
- Base: `main`
- Main before this PR: `ae7e87a2d52482e132ae2c970f3c91991764f91c`
- PR #161 is closed as superseded. Do not revive or merge its parallel branch.

## Repository state prepared for Codex

- Release Candidate uses the same canonical store/platform materializers as the real release path.
- Release Candidate runs on pull requests to `main` and watches release-relevant source, tool, lockfile and production-workflow inputs.
- Every active GitHub Actions path that installs Flutter is pinned to the validated **Flutter 3.44.9** toolchain; no release path follows a moving `stable` version by itself.
- Native shell generation in active CI/release workflows goes through `tool/scaffold_native_preserving_sources.sh`; workflow YAML must not call raw `flutter create` directly.
- The helper backs up `pubspec.yaml` and `pubspec.lock`, runs `flutter create ... --no-pub`, restores the committed dependency sources even on failure, and verifies byte identity.
- The very next runnable command after every native scaffold helper call is `flutter pub get --enforce-lockfile`; only after that may Dart/Flutter release tooling run.
- `dependency_lock_contract_test.dart` protects the helper, the 3.44.9 toolchain pin, the absence of raw workflow scaffolding, and locked installs.
- The committed dependency graph remains intentionally frozen; do not refresh `pubspec.lock` merely because Flutter stable advances or because native shells are regenerated.
- `google_mobile_ads` remains exact-pinned at `9.0.0`.
- The obsolete parallel signed-Android workflow `.github/workflows/store-android.yml` is removed.
- The obsolete competing Pages deployment `.github/workflows/web-preview.yml` is removed.
- Temporary scaffold diagnostic/maintenance workflows are removed from the final tree.
- Signed store candidates belong only to `.github/workflows/store-release.yml`.
- Public deployment belongs only to `.github/workflows/pages.yml`.
- Regression coverage in `test/release_candidate_workflow_contract_test.dart` protects those canonical paths.

## Proven lockfile root cause

The dependency failure was isolated in GitHub Actions rather than guessed from package-version drift.

Even with `--no-pub`, raw `flutter create` can replace the full application `pubspec.lock` with a short Flutter scaffold/template lock representation. Running `flutter pub get --enforce-lockfile` against that temporary scaffold lock then misleadingly reports a very large dependency change set.

A diagnostic workflow proved the correct sequence on Flutter 3.44.9:

1. preserve the committed `pubspec.yaml` and `pubspec.lock`;
2. run `flutter create ... --no-pub` only to materialize native shells;
3. restore the original dependency source files byte-for-byte;
4. run `flutter pub get --enforce-lockfile` immediately;
5. continue only if the committed lock remains unchanged.

That sequence passed. Therefore the scaffold behavior is **not** a reason to broad-upgrade the application dependency graph.

The canonical implementation of this sequence is `tool/scaffold_native_preserving_sources.sh`.

## Why the toolchain is pinned

The release path was previously exposed to a moving Flutter `stable` channel. The final candidate instead pins Flutter **3.44.9**, the reviewed toolchain used for this dependency and artifact contract.

Do not weaken this contract. Any later Flutter/dependency upgrade must be a separate reviewed release change with an intentional lockfile migration and complete Android/iOS artifact audits.

## First Codex action

1. Inspect PR #162 and confirm you are on `release/final-codex-handoff`.
2. Read `AGENTS.md`, this file, `CODEX_HANDOFF.md`, `CODEX_FINAL_HANDOFF.md`, issue #114 and `.github/workflows/store-release.yml`.
3. Check the exact-head GitHub Actions results for Flutter CI, iOS Release CI and Release Candidate.
4. If all three are green on the exact current head, continue the canonical handoff without adding product scope. Merge only when the owner intends to move the release candidate to `main`.
5. If any check is red, fix the actual failing gate on this same branch. Do not bypass, skip, loosen or delete a release/privacy/dependency/signing test.
6. After merge, verify Release Candidate again on canonical `main`.
7. Then continue directly with the account/signing/store work in `CODEX_HANDOFF.md`, `CODEX_FINAL_HANDOFF.md`, and issue #114.

## Owner-only blockers after repository validation

Ask the owner only when the next action genuinely requires account ownership or an irreversible external decision, including:

- Google Play / Apple Developer enrollment or payment;
- 2FA;
- legal agreements;
- tax or banking details;
- real production AdMob IDs / publisher line;
- production signing certificates, profiles, keystores or protected secrets;
- final store publication / rollout approval.

Everything else should be handled autonomously from the repository state.

## Completion rule

Do not call Mystic Tarot launched merely because repository CI is green. The final production definition remains the one in `CODEX_FINAL_HANDOFF.md`: protected signed AAB/IPA, exact-candidate QA, live `app-ads.txt`, completed store forms/testing and actual submission/review handling.

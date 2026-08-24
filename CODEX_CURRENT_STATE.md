# Codex Current Starting State

Read this file first, then `AGENTS.md` and `CODEX_HANDOFF.md`.

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
- Flutter CI, iOS Release CI, Release Candidate and Production Store Release use `flutter create ... --no-pub` whenever native platform shells are generated.
- The very next runnable command after every native scaffold is `flutter pub get --enforce-lockfile`; only after that may Dart/Flutter release tooling run.
- `dependency_lock_contract_test.dart` fails if a workflow drops the 3.44.9 pin, reintroduces a scaffold without `--no-pub`, uses an unlocked `flutter pub get`, or executes another tool between scaffolding and the enforced install.
- The committed dependency graph remains intentionally frozen; do not refresh `pubspec.lock` merely because Flutter stable advances.
- `google_mobile_ads` remains exact-pinned at `9.0.0`.
- The obsolete parallel signed-Android workflow `.github/workflows/store-android.yml` is removed.
- The obsolete competing Pages deployment `.github/workflows/web-preview.yml` is removed.
- Signed store candidates belong only to `.github/workflows/store-release.yml`.
- Public deployment belongs only to `.github/workflows/pages.yml`.
- Regression coverage in `test/release_candidate_workflow_contract_test.dart` protects those canonical paths.
- `tool/src/ios_privacy_manifest_audit.dart` retains the compatibility hardening discovered while testing Flutter 3.47.1, so a future deliberate toolchain upgrade has a smaller migration surface.

## Why the toolchain is pinned

GitHub's moving Flutter `stable` advanced from the repository's validated 3.44.9 toolchain to 3.47.1. On 3.47.1, a normal scaffold rewrote transitive lock entries; when package resolution was isolated correctly, `flutter pub get --enforce-lockfile` proved that 3.47.1 would require a broad dependency-graph migration (125 dependency changes) rather than a harmless scaffold refresh.

That is not an appropriate silent change for the final store candidate. The release-safe contract is therefore:

1. install the reviewed Flutter **3.44.9** toolchain explicitly;
2. generate platform scaffolding with `flutter create ... --no-pub`;
3. immediately run `flutter pub get --enforce-lockfile`;
4. only then apply Mystic's canonical platform materializers and other Dart/Flutter tooling;
5. fail if the committed lockfile changes unexpectedly.

Do not weaken this contract and do not broad-upgrade dependencies just because the public stable channel advances. Any later Flutter/dependency upgrade must be a separate reviewed release change with a deliberate lockfile migration and complete Android/iOS artifact audits.

## First Codex action

1. Inspect PR #162 and confirm you are on `release/final-codex-handoff`.
2. Read `AGENTS.md`, this file, `CODEX_HANDOFF.md`, issue #114 and `.github/workflows/store-release.yml`.
3. Check the exact-head GitHub Actions results for Flutter CI, iOS Release CI and Release Candidate.
4. If all three are green on the exact current head, merge PR #162 without adding product scope.
5. If any check is red, fix the actual failing gate on this same branch. Do not bypass, skip, loosen or delete a release/privacy/dependency/signing test.
6. After merge, verify Release Candidate again on canonical `main`.
7. Then continue directly with the account/signing/store work in `CODEX_HANDOFF.md` and issue #114.

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

Do not call Mystic Tarot launched merely because repository CI is green. The final production definition remains the one in `CODEX_HANDOFF.md`: protected signed AAB/IPA, exact-candidate QA, live `app-ads.txt`, completed store forms/testing and actual submission/review handling.

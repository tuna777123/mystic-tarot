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
- Flutter CI, iOS Release CI, Release Candidate and Production Store Release use `flutter create ... --no-pub` whenever native platform shells are generated.
- Dependency resolution is deliberately separated from scaffolding and remains `flutter pub get --enforce-lockfile`.
- `dependency_lock_contract_test.dart` fails if a workflow reintroduces a `flutter create` command without `--no-pub` or an unlocked `flutter pub get`.
- The committed dependency graph remains intentionally frozen; do not refresh `pubspec.lock` merely because Flutter stable advances.
- `google_mobile_ads` remains exact-pinned at `9.0.0`.
- The obsolete parallel signed-Android workflow `.github/workflows/store-android.yml` is removed.
- The obsolete competing Pages deployment `.github/workflows/web-preview.yml` is removed.
- Signed store candidates belong only to `.github/workflows/store-release.yml`.
- Public deployment belongs only to `.github/workflows/pages.yml`.
- Regression coverage in `test/release_candidate_workflow_contract_test.dart` protects those canonical paths.
- `tool/src/ios_privacy_manifest_audit.dart` includes the Flutter 3.47.1 compatibility fix required by current hosted runners.

## Why the lockfile fix is `--no-pub`

GitHub hosted runners advanced to Flutter stable 3.47.1. A normal `flutter create` implicitly ran package resolution before the repository's later enforced install and rewrote transitive entries in `pubspec.lock`.

That was a workflow-ordering problem, not evidence that the production dependency graph needed a broad upgrade. The release-safe fix is therefore:

1. generate platform scaffolding with `flutter create ... --no-pub`;
2. apply Mystic's canonical platform materializers;
3. resolve/install dependencies only through `flutter pub get --enforce-lockfile`;
4. fail if the committed lockfile changes unexpectedly.

Do not weaken this contract and do not broad-upgrade dependencies just to satisfy a newer Flutter stable toolchain. If an intentional dependency/toolchain upgrade is later required, review and audit it as a separate release change.

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

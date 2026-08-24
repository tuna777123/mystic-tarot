# Codex Current Starting State

This file is intentionally short. Read `CODEX_HANDOFF.md` for the full release plan.

## Branch / PR

- Open PR: **#162 — Finalize Release Candidate and Codex production handoff**
- Working branch: `release/final-codex-handoff`
- Base: `main`
- Main before this PR: `ae7e87a2d52482e132ae2c970f3c91991764f91c`

## What is already fixed on this branch

- Release Candidate now uses the canonical `tool/configure_store_identifiers.dart` platform materializer instead of stale manual `sed` rewrites.
- Release Candidate preserves the explicit idempotent `dart run tool/configure_app_lock.dart` step required by the v1.20 release contract.
- Release Candidate uses current action majors, locked dependency install, formatting, clean-diff, launch-surface and fatal-info analysis gates.
- `tool/src/ios_privacy_manifest_audit.dart` is compatible with Flutter stable 3.47.1 (`await` inside the try/finally path).
- Full Codex production/store handoff is in `CODEX_HANDOFF.md`.

## Exact remaining CI blocker at handoff

GitHub hosted runners now resolve **Flutter stable 3.47.1**. The committed `pubspec.lock` was originally frozen under an older Flutter stable (3.44.9), so `flutter create . --platforms=android,ios --org com.tunabozcali` mutates transitive lock entries before the later `flutter pub get --enforce-lockfile` step.

The latest observed mutation included transitive-only changes such as:

- `archive 4.0.9 -> 4.2.0`
- `dbus 0.7.13 -> 0.7.15`
- `image 4.9.1 -> 4.9.2`
- `intl 0.20.2 -> 0.20.3`
- `matcher 0.12.19 -> 0.12.20`
- `meta 1.18.0 -> 1.18.3`
- `synchronized 3.4.1+1 -> 3.4.1+2`
- `test_api 0.7.11 -> 0.7.12`
- `vector_math 2.2.0 -> 2.4.0`
- `vm_service 15.2.0 -> 15.3.0`
- `webview_flutter_android 4.13.0 -> 4.14.0`

The direct launch-critical Mobile Ads wrapper remains intentionally exact-pinned at `google_mobile_ads: 9.0.0`.

## First Codex task

Do this from a real checkout of PR #162 / `release/final-codex-handoff`:

1. Install/use the same current Flutter stable used by GitHub Actions (currently 3.47.1 unless stable has legitimately advanced again).
2. Record `flutter --version`.
3. Start from a clean tree.
4. Run the same platform-generation/materialization path used by CI:
   - `flutter create . --platforms=android,ios --org com.tunabozcali`
   - `dart run tool/configure_store_identifiers.dart`
   - `dart run tool/configure_app_lock.dart`
5. Refresh the root `pubspec.lock` to the dependency graph resolved by that exact stable toolchain. Do **not** broad-upgrade direct dependencies merely because newer packages exist.
6. Confirm direct launch pins and release identity did not drift, especially `google_mobile_ads: 9.0.0`.
7. Run `flutter pub get --enforce-lockfile` and verify the lockfile stays byte-stable afterward.
8. Run the full test suite and every PR validation workflow.
9. Confirm Flutter CI, iOS Release CI, and Release Candidate are green on the exact final head.
10. Merge PR #162 only at that exact green head.
11. Verify Release Candidate again on canonical `main` after merge.

Do not weaken `dependency_lock_contract_test.dart` just to get green CI. The intended fix is a legitimate lockfile refresh for the current validated Flutter stable toolchain.

## After PR #162 is green and merged

Proceed immediately with `CODEX_HANDOFF.md` and GitHub issue #114:

- developer accounts;
- AdMob production app/unit IDs and UMP;
- root-hosted `app-ads.txt` with the real publisher line;
- Android upload signing;
- Apple distribution signing / provisioning;
- protected `production-stores` secrets;
- Production Store Release workflow;
- exact signed-candidate QA;
- Play testing track / TestFlight;
- store forms and submission.

Ask the owner only for account-owner actions such as 2FA, payment, legal agreements, tax/banking, production credentials, or an irreversible store publication decision.

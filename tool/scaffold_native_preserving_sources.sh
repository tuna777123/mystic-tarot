#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f pubspec.yaml || ! -f pubspec.lock ]]; then
  echo 'Run this helper from the repository root with committed pubspec.yaml and pubspec.lock present.' >&2
  exit 1
fi

backup_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$backup_dir"
}
trap cleanup EXIT

cp pubspec.yaml "$backup_dir/pubspec.yaml"
cp pubspec.lock "$backup_dir/pubspec.lock"

flutter create . "$@" --no-pub

# `flutter create` is used only to materialize native platform shells. Recent
# Flutter releases replace an application lockfile with the scaffold/template
# lock representation even when --no-pub is supplied. Restore the committed
# application dependency sources before any Dart/Flutter tooling can resolve
# packages, then let the caller run `flutter pub get --enforce-lockfile`.
cp "$backup_dir/pubspec.yaml" pubspec.yaml
cp "$backup_dir/pubspec.lock" pubspec.lock

cmp -s pubspec.yaml "$backup_dir/pubspec.yaml"
cmp -s pubspec.lock "$backup_dir/pubspec.lock"

#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f pubspec.yaml || ! -f pubspec.lock ]]; then
  echo 'Run this helper from the repository root with committed pubspec.yaml and pubspec.lock present.' >&2
  exit 1
fi

if (( $# == 0 )); then
  echo 'Native scaffold arguments are required.' >&2
  exit 1
fi

platforms=''
org_seen=false
for arg in "$@"; do
  case "$arg" in
    --platforms=*) platforms="${arg#--platforms=}" ;;
    --org) org_seen=true ;;
  esac
done

case "$platforms" in
  android|ios|android,ios|ios,android) ;;
  *)
    echo 'Pass an explicit supported --platforms=android, --platforms=ios, or --platforms=android,ios argument.' >&2
    exit 1
    ;;
esac

if [[ "$org_seen" != true ]]; then
  echo 'Pass the canonical --org argument explicitly.' >&2
  exit 1
fi

backup_dir="$(mktemp -d)"
cp pubspec.yaml "$backup_dir/pubspec.yaml"
cp pubspec.lock "$backup_dir/pubspec.lock"

restore_sources() {
  cp "$backup_dir/pubspec.yaml" pubspec.yaml
  cp "$backup_dir/pubspec.lock" pubspec.lock
}

cleanup() {
  local status=$?
  restore_sources
  rm -rf "$backup_dir"
  return "$status"
}
trap cleanup EXIT

flutter create . "$@" --no-pub

# `flutter create` is native-shell materialization only. Flutter can replace
# the application lockfile with template lock content even with --no-pub, so
# restore committed dependency sources before any Dart/Flutter resolver runs.
restore_sources

cmp -s pubspec.yaml "$backup_dir/pubspec.yaml"
cmp -s pubspec.lock "$backup_dir/pubspec.lock"

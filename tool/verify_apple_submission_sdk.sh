#!/usr/bin/env bash
set -euo pipefail

minimum_xcode_major=26
minimum_ios_sdk_major=26

xcode_output="$(xcodebuild -version)"
xcode_version="$(printf '%s\n' "$xcode_output" | awk '/^Xcode / {print $2; exit}')"
ios_sdk_version="$(xcrun --sdk iphoneos --show-sdk-version)"

if [[ ! "$xcode_version" =~ ^[0-9]+([.][0-9]+)*$ ]]; then
  echo "Apple submission SDK verification failed: could not parse Xcode version '$xcode_version'." >&2
  exit 1
fi
if [[ ! "$ios_sdk_version" =~ ^[0-9]+([.][0-9]+)*$ ]]; then
  echo "Apple submission SDK verification failed: could not parse iPhoneOS SDK version '$ios_sdk_version'." >&2
  exit 1
fi

xcode_major="${xcode_version%%.*}"
ios_sdk_major="${ios_sdk_version%%.*}"

if (( xcode_major < minimum_xcode_major )); then
  echo "Apple submission SDK verification failed: Xcode $xcode_version is below Xcode $minimum_xcode_major." >&2
  exit 1
fi
if (( ios_sdk_major < minimum_ios_sdk_major )); then
  echo "Apple submission SDK verification failed: iPhoneOS SDK $ios_sdk_version is below iOS SDK $minimum_ios_sdk_major." >&2
  exit 1
fi

cat <<EOF
Apple submission SDK verification: PASS
Xcode version: $xcode_version
iPhoneOS SDK version: $ios_sdk_version
Required Xcode major: >= $minimum_xcode_major
Required iPhoneOS SDK major: >= $minimum_ios_sdk_major
EOF

#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "launch-surface verification failed: $*" >&2
  exit 1
}

require_file() {
  local path="$1"
  [[ -s "$path" ]] || fail "missing or empty file: $path"
}

require_contains() {
  local path="$1"
  local needle="$2"
  grep -Fq -- "$needle" "$path" || fail "$path is missing required text: $needle"
}

forbid_contains() {
  local path="$1"
  local needle="$2"
  if grep -Fiq -- "$needle" "$path"; then
    fail "$path contains forbidden launch text: $needle"
  fi
}

version="$(awk '/^version:[[:space:]]*/ {print $2; exit}' pubspec.yaml)"
[[ -n "$version" ]] || fail "could not read version from pubspec.yaml"
[[ "$version" == "1.23.0+33" ]] || fail "unexpected product version: $version"

required=(
  web/index.html
  web/manifest.json
  web/robots.txt
  web/sitemap.xml
  web/404.html
  web/marketing-i18n.css
  web/marketing-i18n.js
  web/press-kit.html
  web/landing.html
  web/landing-en.html
  web/landing-es.html
  web/landing-fr.html
  web/landing-pt-br.html
  web/privacy.html
  web/privacy-tr.html
  web/privacy-es.html
  web/privacy-fr.html
  web/privacy-pt-br.html
  web/terms.html
  web/terms-tr.html
  web/terms-es.html
  web/terms-fr.html
  web/terms-pt-br.html
  web/support.html
  web/support-tr.html
  web/support-es.html
  web/support-fr.html
  web/support-pt-br.html
  docs/MARKETING_LAUNCH_KIT.md
  docs/FINAL_DELIVERY.md
  docs/OWNER_GUIDE_A_TO_Z.md
  docs/GROWTH_KPI_CONTRACT.md
  docs/INVESTMENT_GRADE_PRODUCT_PLAN.md
  lib/src/business_metrics.dart
  lib/src/mystic_mirror_share.dart
  STORE_RELEASE.md
)

for path in "${required[@]}"; do
  require_file "$path"
done

require_contains web/index.html '<link rel="manifest" href="manifest.json">'
require_contains web/index.html 'beforeinstallprompt'
require_contains web/index.html 'appinstalled'
require_contains web/index.html 'og:title'
require_contains web/index.html 'og:description'
require_contains web/index.html 'og:image'
require_contains web/index.html 'twitter:card'
require_contains web/manifest.json '"display": "standalone"'
require_contains web/manifest.json '"orientation": "portrait-primary"'
require_contains web/manifest.json '"purpose": "maskable"'

require_contains web/robots.txt 'Sitemap: https://tuna777123.github.io/mystic-tarot/sitemap.xml'
require_contains web/sitemap.xml 'https://tuna777123.github.io/mystic-tarot/press-kit.html'
require_contains web/sitemap.xml 'hreflang="tr"'
require_contains web/sitemap.xml 'hreflang="en"'
require_contains web/sitemap.xml 'hreflang="es"'
require_contains web/sitemap.xml 'hreflang="fr"'
require_contains web/sitemap.xml 'hreflang="pt-BR"'
require_contains web/sitemap.xml 'hreflang="x-default"'

press='web/press-kit.html'
require_contains "$press" '<meta name="robots" content="index,follow'
require_contains "$press" '<link rel="canonical" href="https://tuna777123.github.io/mystic-tarot/press-kit.html">'
require_contains "$press" 'Mystic Tarot — Official Press Kit'
require_contains "$press" '"softwareVersion":"1.23.0"'
require_contains "$press" 'Official press & sharing kit · v1.23.0'
require_contains "$press" 'Public web edition available now'
require_contains "$press" 'Native iOS and Android store candidates'
require_contains "$press" 'Native apps are advertising-supported'
require_contains "$press" 'public web edition remains ad-free'
require_contains "$press" 'No paid subscription'
require_contains "$press" 'No account is required for the public web experience'
require_contains "$press" 'navigator.share'
require_contains "$press" 'navigator.clipboard'
require_contains "$press" 'privacy.html'
require_contains "$press" 'terms.html'
require_contains "$press" 'support.html'
require_contains "$press" 'EN · TR · ES · FR · PT-BR'

for forbidden in \
  'Download on the App Store' \
  'Get it on Google Play' \
  '#1 tarot app' \
  'guaranteed prediction' \
  'guaranteed future' \
  'RevenueCat' \
  'monthly subscription' \
  'yearly subscription' \
  'googletagmanager.com' \
  'connect.facebook.net' \
  'analytics.tiktok.com'; do
  forbid_contains "$press" "$forbidden"
done

for landing in \
  landing.html \
  landing-en.html \
  landing-es.html \
  landing-fr.html \
  landing-pt-br.html; do
  require_contains "web/$landing" 'rel="canonical"'
  require_contains "web/$landing" 'og:title'
  require_contains "web/$landing" 'og:description'
  require_contains "web/$landing" 'og:image'
  require_contains "web/$landing" 'twitter:card'
done

for privacy in \
  privacy.html \
  privacy-tr.html \
  privacy-es.html \
  privacy-fr.html \
  privacy-pt-br.html; do
  require_contains "web/$privacy" 'Google Mobile Ads'
  require_contains "web/$privacy" 'User Messaging Platform'
done

kit='docs/MARKETING_LAUNCH_KIT.md'
require_contains "$kit" 'Version: `1.23.0+33`'
require_contains "$kit" '### English'
require_contains "$kit" '### Turkish'
require_contains "$kit" '### Spanish'
require_contains "$kit" '### French'
require_contains "$kit" '### Brazilian Portuguese'
require_contains "$kit" 'utm_campaign=launch_1_23_0'
require_contains "$kit" 'Creative guardrails'
require_contains "$kit" 'fabricated testimonials'
require_contains "$kit" 'fake user counts'
require_contains "$kit" 'App Store / Google Play badges before'
require_contains "$kit" 'Do not add third-party tracking scripts'
require_contains "$kit" 'advertising-supported'
require_contains "$kit" 'no paid subscription'

handoff='docs/FINAL_DELIVERY.md'
require_contains "$handoff" 'Product version: `1.23.0+33`'
require_contains "$handoff" 'com.tunabozcali.mystictarot'
require_contains "$handoff" 'Public press kit:'
require_contains "$handoff" 'advertising-only'
require_contains "$handoff" 'OWNER_GUIDE_A_TO_Z.md'
require_contains "$handoff" 'What is intentionally not represented as complete'
require_contains "$handoff" 'App Store or Google Play availability claims before'

owner='docs/OWNER_GUIDE_A_TO_Z.md'
require_contains "$owner" 'Product version: `1.23.0+33`'
require_contains "$owner" 'Advertising-only business model'
require_contains "$owner" 'ADMOB_ANDROID_APP_ID'
require_contains "$owner" 'ADMOB_IOS_APP_ID'
require_contains "$owner" 'MYSTIC_USE_TEST_ADS=false'
require_contains "$owner" 'Mystic Mirror'
require_contains "$owner" 'EN, TR, ES, FR, PT-BR'

require_contains STORE_RELEASE.md 'Current source version: `1.23.0+33`'
require_contains STORE_RELEASE.md 'ADMOB_ANDROID_APP_ID'
require_contains STORE_RELEASE.md 'ADMOB_IOS_APP_ID'
require_contains STORE_RELEASE.md 'ADMOB_ANDROID_APP_OPEN_ID'
require_contains STORE_RELEASE.md 'ADMOB_IOS_APP_OPEN_ID'
require_contains STORE_RELEASE.md 'ADMOB_ANDROID_INTERSTITIAL_ID'
require_contains STORE_RELEASE.md 'ADMOB_IOS_INTERSTITIAL_ID'
require_contains STORE_RELEASE.md 'MYSTIC_USE_TEST_ADS=false'
require_contains STORE_RELEASE.md 'no paid subscription'

require_contains docs/GROWTH_KPI_CONTRACT.md 'D7 retention'
require_contains docs/GROWTH_KPI_CONTRACT.md 'eligible-Mirror completion'
require_contains docs/GROWTH_KPI_CONTRACT.md '1.5 × blended CAC'
require_contains docs/INVESTMENT_GRADE_PRODUCT_PLAN.md 'Read today → compare with reality after 24 hours'
require_contains lib/src/business_metrics.dart 'allowedDimensions'
require_contains lib/src/mystic_mirror_share.dart 'Never add a question, card name, emotion, outcome, note'

for paid_phrase in \
  'Unlock your full pattern map' \
  'Explore Premium' \
  'Premium spreads continue' \
  'Premium’u keşfet'; do
  forbid_contains lib/src/mystic_living_journal_feature.dart "$paid_phrase"
  forbid_contains lib/src/growth_engine.dart "$paid_phrase"
done

require_contains lib/src/mystic_living_journal_feature.dart 'Your Pattern Lab grows with evidence'
require_contains lib/src/mystic_living_journal_feature.dart 'Share the 24h ritual'

for path in "$kit" "$handoff" "$owner"; do
  forbid_contains "$path" 'googletagmanager.com'
  forbid_contains "$path" 'connect.facebook.net'
  forbid_contains "$path" 'analytics.tiktok.com'
done

printf 'launch-surface verification passed for Mystic Tarot %s\n' "$version"

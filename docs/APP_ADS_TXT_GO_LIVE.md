# Mystic Tarot — app-ads.txt Go-Live Runbook

Version target: `1.23.0+33`  
Application / bundle ID: `com.tunabozcali.mystictarot`

## Why this is a production gate

New apps added to AdMob require app ownership verification with `app-ads.txt` before they can fully serve ads. AdMob then performs its app-readiness review after the app is published and linked to a supported store.

This is an **owner/account/hosting** step. It is separate from Flutter source QA and native signing.

## Current Mystic Tarot hosting constraint

The public product currently lives on the GitHub Pages project site:

`https://tuna777123.github.io/mystic-tarot/`

AdMob does not use the project path when locating `app-ads.txt`. It derives the crawl location from the developer-website hostname and checks the hostname root.

If the store developer website is on `tuna777123.github.io`, the required crawl target is:

`https://tuna777123.github.io/app-ads.txt`

Therefore, putting `app-ads.txt` only at:

`https://tuna777123.github.io/mystic-tarot/app-ads.txt`

is not sufficient for the AdMob crawler.

## Recommended hosting solution

Use one of these approaches:

1. **GitHub Pages user site** — create/maintain `tuna777123/tuna777123.github.io` and publish the file at repository root so it resolves as `https://tuna777123.github.io/app-ads.txt`.
2. **Custom developer domain** — use a domain whose root you control, host `/app-ads.txt` there, and use that same domain as the developer website in Google Play and the App Store.
3. **Another supported static host** — only if it gives you control of the root `/app-ads.txt` URL used by the store developer-website hostname.

Do not change the public Mystic Tarot product URL merely to work around app-ads.txt unless necessary. The developer website and the product landing page can be separate URLs if the store fields and branding remain accurate.

## Exact file content

Do **not** invent the publisher line.

In AdMob:

1. Open **Apps → View all apps → app-ads.txt**.
2. Open the setup instructions for the Mystic Tarot app.
3. Copy the personalized code snippet supplied by AdMob.
4. Paste that snippet into a plain-text file named exactly `app-ads.txt`.

The publisher ID in this file is a public identifier, but passwords, signing keys, service-account JSON, P12 files and keystores remain private and must never be added here.

## Store linkage

For Google Play, set the developer website in the app's store-listing contact details.  
For the Apple App Store, set the same controlled website host in the Marketing URL / developer website surface used by the listing.

The URL should resolve publicly over HTTPS and its hostname root must serve `/app-ads.txt`.

## Verification sequence

- [ ] Create Android and iOS Mystic Tarot apps in AdMob.
- [ ] Obtain the personalized AdMob `app-ads.txt` snippet.
- [ ] Publish the snippet at the developer website hostname root.
- [ ] Verify the root URL returns HTTP 200 and the exact personalized line.
- [ ] Ensure `robots.txt` does not block the file.
- [ ] Add the developer website to the Google Play listing.
- [ ] Add the developer website to the App Store listing.
- [ ] Publish/link the app in a supported store so AdMob can discover the listing.
- [ ] In AdMob, request **Verify app / Check for updates** when available.
- [ ] Confirm the app-ads.txt status becomes **found and verified**.
- [ ] Confirm the AdMob app-readiness status reaches **Ready** before treating full ad serving as live.

AdMob may take time to detect a newly changed developer website and to crawl the file. Do not repeatedly change the URL while verification is in progress unless the shown AdMob crawl URL is wrong.

## Mystic Tarot release rule

A store binary may remain fully usable while AdMob is unavailable or limited; the app's ad service is designed not to block core product flows when an ad is missing or fails to load.

However, do **not** claim real advertising monetization is fully live until all of the following are true:

- owner-controlled production AdMob IDs are in the signed native build;
- `MYSTIC_USE_TEST_ADS=false`;
- UMP production messaging is configured;
- `app-ads.txt` is found and verified;
- AdMob app readiness is approved;
- real-device ad/consent/no-ad QA passes;
- store privacy declarations match the actual signed runtime.

## Manual verification command

After publishing the real file:

```bash
curl -fsSL https://YOUR-DEVELOPER-HOST/app-ads.txt
```

The response must contain the personalized AdMob line exactly as supplied by the AdMob dashboard.

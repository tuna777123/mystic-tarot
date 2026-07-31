# Mystic Tarot — Protected production release automation

`Production Store Release` creates genuinely signed Android and iOS submission
packages from the `main` branch. It does not keep certificates, keystores,
passwords, provisioning profiles, or RevenueCat keys in the repository.

The workflow is intentionally manual. A normal pull request or push can never
start a production-signed build.

## What the workflow produces

For each selected platform, the artifact contains:

- the signed Android App Bundle (`.aab`) or signed iOS package (`.ipa`);
- a SHA-256 checksum file;
- a machine-readable release manifest containing the app version, permanent
  application identity, RevenueCat entitlement, launch product IDs, source
  commit, build channel, artifact size, and checksum.

The workflow verifies:

- `com.tunabozcali.mystictarot` is used on both platforms;
- the RevenueCat key is a public platform application key, not a secret API key;
- the entitlement remains `mystic_plus`;
- Android uses the configured upload key and the resulting AAB signature is
  valid;
- the Apple provisioning profile belongs to the configured Team ID and exact
  bundle ID;
- the exported iOS application has a valid code signature and matching
  application identifier;
- Flutter analysis and the complete automated test suite pass before either
  signed job starts.

## Required GitHub Environment

Create a protected GitHub Environment named:

```text
production-stores
```

Add required reviewers and restrict deployment to the `main` branch. Do not put
the values below in repository variables, workflow files, issues, pull requests,
or chat messages. Add them as Environment secrets.

### Android secrets

| Secret | Value |
| --- | --- |
| `REVENUECAT_ANDROID_API_KEY` | RevenueCat public Google application SDK key |
| `ANDROID_UPLOAD_KEYSTORE_BASE64` | Base64 encoding of the Play upload keystore |
| `ANDROID_KEY_ALIAS` | Alias inside the upload keystore |
| `ANDROID_KEY_PASSWORD` | Private-key password |
| `ANDROID_STORE_PASSWORD` | Keystore password |

### iOS secrets

| Secret | Value |
| --- | --- |
| `REVENUECAT_IOS_API_KEY` | RevenueCat public Apple application SDK key |
| `IOS_DISTRIBUTION_CERTIFICATE_BASE64` | Base64 encoding of the exported Apple Distribution `.p12` |
| `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` | Password used when exporting the `.p12` |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 encoding of the App Store distribution `.mobileprovision` |
| `IOS_TEAM_ID` | Ten-character Apple Developer Team ID |

RevenueCat secret API keys, App Store Connect private keys, and Google service
account JSON are not required because this workflow builds packages but does not
upload them to the stores.

## Prepare the Android upload key

Create one upload key and keep the original file in a secure password manager or
encrypted offline backup:

```bash
keytool -genkeypair -v \
  -keystore mystic-tarot-upload.jks \
  -alias mystic_upload \
  -keyalg RSA \
  -keysize 4096 \
  -validity 10000
```

Encode it without modifying the binary:

```bash
base64 < mystic-tarot-upload.jks | tr -d '\n'
```

On Windows PowerShell:

```powershell
[Convert]::ToBase64String(
  [IO.File]::ReadAllBytes("mystic-tarot-upload.jks")
)
```

After the first Play Console upload, enroll in Play App Signing and never replace
the upload key casually. Losing it requires the Play Console upload-key reset
process.

## Prepare Apple signing files

Use the Apple Developer account that owns
`com.tunabozcali.mystictarot`.

1. Create an Apple Distribution certificate.
2. Install it with its private key in Keychain Access.
3. Export the certificate and private key as a password-protected `.p12`.
4. Create an App Store distribution provisioning profile for the exact bundle
   ID.
5. Download the `.mobileprovision`.
6. Base64-encode both files and save the values as protected Environment
   secrets.

macOS encoding command:

```bash
base64 < distribution.p12 | tr -d '\n'
base64 < MysticTarot_AppStore.mobileprovision | tr -d '\n'
```

The workflow rejects wildcard profiles and profiles owned by another Team ID.

## Run a signed build

1. Open GitHub Actions.
2. Select **Production Store Release**.
3. Choose **Run workflow** from the `main` branch.
4. Select `android`, `ios`, or `both`.
5. Select the intended channel: `internal`, `closed-testing`, or `production`.
6. Approve the protected Environment deployment.
7. Download the generated artifact only after every job is green.

Use `closed-testing` for the first Android build and the iOS artifact with
TestFlight. The selected channel is recorded in the manifest; it does not
automatically upload or publish anything.

## Required checks after package generation

A successful workflow proves that the package is correctly built and signed. It
does not prove that the store products or purchases work. Before production,
complete the real-device sandbox matrix in issue #47:

- monthly and yearly purchase;
- yearly trial eligibility;
- cancellation, pending purchase, and billing failure;
- restore after clean install;
- renewal, expiration, refund, and revocation;
- offline launch with previously verified access;
- trusted-entitlement verification failure never unlocks Plus;
- localized English and Turkish prices, legal links, and subscription
  management.

Do not submit a package that was built without RevenueCat keys or signed with a
debug key.

# Production signing certificate fingerprints

The manual `Production Store Release` workflow refuses to create a signed store artifact unless the certificate inside the protected signing file matches its reviewed SHA-256 fingerprint.

Certificate fingerprints are public identifiers, not private keys. Keep the keystore, P12 file, passwords, and private keys protected. Store the reviewed fingerprints in the `production-stores` GitHub environment alongside the other release values so environment approvals and audit history remain in one place.

## Android

Required protected value:

- `ANDROID_UPLOAD_CERT_SHA256`

Use the **upload certificate** fingerprint shown in Google Play Console under app signing, not the Play-managed app-signing certificate fingerprint. The workflow signs the AAB with the upload key before Google Play verifies and re-signs distributed APKs.

Accepted input forms:

- 64 hexadecimal characters
- the same fingerprint with colon separators
- upper- or lowercase

The workflow independently checks:

1. the certificate exported from the supplied keystore;
2. at least 30 days of certificate validity;
3. the certificate embedded in the final signed AAB.

All three must match the reviewed fingerprint before the artifact can be uploaded.

A local fingerprint can be calculated with:

```bash
keytool -exportcert \
  -keystore upload-keystore.jks \
  -alias YOUR_ALIAS \
  -file upload-cert.der
sha256sum upload-cert.der
```

Compare the result with Google Play Console before saving it in the protected environment.

## iOS

Required protected value:

- `IOS_DISTRIBUTION_CERT_SHA256`

Calculate the fingerprint from the public certificate contained in the protected distribution P12. The workflow verifies the P12 fingerprint before importing it, requires at least seven days of remaining validity, and limits the signing keychain search list to the temporary release keychain.

After export, the workflow also:

1. verifies the final app signature, Team ID, bundle ID, provisioning profile, and application identifier;
2. extracts the leaf signing certificate from the `.app` inside the final IPA;
3. requires that certificate to match the same reviewed SHA-256 fingerprint;
4. records the verified certificate fingerprint in the release manifest shipped with the IPA.

A local fingerprint can be calculated with:

```bash
openssl pkcs12 \
  -in distribution.p12 \
  -clcerts -nokeys \
  -out distribution-cert.pem
openssl x509 \
  -in distribution-cert.pem \
  -outform der | shasum -a 256
```

Update the protected fingerprint whenever the Apple distribution certificate is renewed. Never reuse an old fingerprint with a new P12.

## Rotation procedure

1. Register or renew the certificate in the relevant store account.
2. Confirm the public certificate identity in the store portal.
3. Replace the protected signing file and its password if necessary.
4. Replace the corresponding SHA-256 fingerprint in the `production-stores` environment.
5. Run the workflow first against an internal or closed-testing channel.
6. Do not continue to production if any fingerprint, Team ID, bundle ID, entitlement, signature, or artifact audit gate fails.

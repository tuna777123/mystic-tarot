# Mystic Tarot 1.19.0 — Passphrase-Protected Transfer

Mystic Tarot now protects new private journal transfer codes with a user-chosen passphrase before they leave the device.

## Protected by default

- New V2 transfer codes encrypt saved readings, Mystic Mirror reflections, and Oracle conversations before sharing.
- The passphrase is never saved, uploaded, included in analytics, or recoverable by Mystic.
- A forgotten passphrase cannot be reset; the interface explains this before code creation.
- Transfer codes remain usable when messaging or email safely wraps the text across lines.

## Safe compatibility

- Existing V1 transfer codes remain valid and can be restored without a passphrase.
- Missing passphrases, incorrect passphrases, damaged protected codes, and unrelated codes produce distinct safe failures.
- No local journal data changes until unlocking, validation, preview, and confirmation all succeed.
- Existing duplicate prevention, newer-Mirror preference, local snapshots, and compensating rollback remain intact.

## Product integrity

- Complete English, Turkish, Spanish, French, and Brazilian Portuguese protection experience.
- AES-GCM authenticated encryption with an Argon2id-derived 256-bit key, a fresh random salt, and a fresh cipher nonce for each code.
- Version `1.19.0+25`.
- No account, cloud journal, advertising identifier, purchase mutation, pricing, signing, or store operation is introduced.

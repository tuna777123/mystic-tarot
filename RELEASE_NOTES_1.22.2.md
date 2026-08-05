# Mystic Tarot 1.22.2 — First-Run Language Integrity

This patch makes the five-language launch experience consistent from the first frame of a clean install through onboarding, the private app-lock layer, and the main product shell.

## Correct language from first launch

- Clean installs now begin in English, Turkish, Spanish, French, or Brazilian Portuguese when the device uses one of those launch languages.
- Regional locale variants such as `es-MX`, `fr-CA`, `pt-PT`, and underscore-form locale tags resolve to the complete launch catalog.
- The language is resolved and normalized before `runApp`, preventing a visible English fallback during startup.

## User choice remains authoritative

- An explicit language selected inside Mystic always takes priority over the device language.
- Existing preferences are normalized without changing a valid user choice.
- Retired or incomplete German and Italian preferences cannot expose a partially translated product; they fall back safely to a complete launch language.

## Resilient startup

- A temporary local-preference failure no longer blocks application startup.
- The private lock screen and the main product use the same resolved launch language.
- Regression tests cover clean installs, corrupt preferences, regional locale aliases, explicit-choice precedence, unsupported locales, and pre-onboarding app-lock copy.

## Release integrity

- Version `1.22.2+31`.
- No subscription product, entitlement, price, bundle identifier, journal schema, account model, advertising SDK, tracking behavior, or cloud-storage behavior changes in this patch.

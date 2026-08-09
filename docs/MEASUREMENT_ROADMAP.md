# Mystic Tarot — Measurement Roadmap

## Current release

`MysticBusinessMetrics` defines the product-safe event boundary. The default reporter is local/debug-only and no remote aggregate KPI collection is claimed.

## Before material paid acquisition

Connect a privacy-reviewed aggregate reporter that can calculate cohort retention and funnel conversion without receiving private Mystic content.

Required events:
- app opened;
- onboarding completed;
- first/saved reading completed;
- Mirror due surfaced;
- Mirror completed;
- generic Mirror share initiated;
- ritual reminder enabled;
- ad opportunity;
- ad impression.

Allowed dimensions are intentionally coarse and versioned in source. Never include questions, journal/Mirror notes, card names, user names, intentions, emotion selections, Mirror outcomes, PIN data or arbitrary free text.

## Release process when a remote reporter is selected

1. Review SDK/network data behavior.
2. Update privacy policy and store declarations before production enablement.
3. Add tests proving private fields are rejected.
4. Verify consent/legal basis requirements by launch region.
5. Run signed-binary Android/iOS privacy audits.
6. Only then use the resulting aggregate cohorts for `GROWTH_KPI_CONTRACT.md` decisions.

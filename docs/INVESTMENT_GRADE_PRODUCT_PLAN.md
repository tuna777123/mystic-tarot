# Mystic Tarot — Investment-Grade Product Plan

Status date: **2026-08-09**

## Company verdict

Mystic Tarot has an investable product core, but engineering polish alone is not evidence of product-market fit. The investable thesis is not “another tarot app.” It is a private reflection loop that becomes more valuable after the reading:

**Read today → compare with reality after 24 hours → accumulate private evidence → reveal recurring patterns.**

The company should invest behind this loop only when retained cohorts prove that users actually return to close it.

## Why this can be defensible

Large tarot/astrology competitors already cover generic readings, education, AI interpretation, horoscopes, live advisors and subscriptions. Competing by adding more generic content creates a feature race.

Mystic's differentiated assets are:

1. **Mystic Mirror** — a deliberate 24-hour reality check rather than endless prediction content.
2. **Private pattern memory** — evidence is accumulated from the user's own saved history.
3. **Local-first trust** — no account or cloud journal required for the core product.
4. **Five-language launch surface** — EN/TR/ES/FR/PT-BR from the beginning.
5. **Low-friction free model** — all core product value is unlocked; native revenue comes from restrained advertising.

## Product priorities

### P0 — Retention moat

- Due Mystic Mirror outranks creation of another daily reading.
- Mirror due state remains visible in the Journal navigation and timeline.
- Mirror completion must remain fast, honest and non-predictive.
- Reminder prompts must support return without becoming spam.
- The user should understand during the first session that tomorrow matters.

### P0 — Business-model consistency

- No visible paid-tier, paywall, premium-unlock or subscription copy may remain in launch flows.
- Historical internal class/type names can remain temporarily only when they do not affect user experience or store claims.
- CI should fail if known paid-model launch phrases return.

### P1 — Earned distribution

- Sharing must happen after earned value, not before it.
- Mystic Mirror sharing is generic by design; private questions, cards, notes, emotions and outcomes never leave the device through the default share action.
- Measure share initiation only through a privacy-safe event boundary.

### P1 — Measurement without betraying trust

- `MysticBusinessMetrics` is the only product-growth telemetry boundary.
- Only coarse allow-listed dimensions are permitted.
- No third-party analytics SDK is added until the exact privacy/store disclosure impact is reviewed.
- Paid acquisition does not scale before remote aggregate measurement and KPI gates are in place.

### P2 — Monetization optimization

Do not increase ad frequency to compensate for weak retention.

The current model intentionally favors retention:
- no permanent banner;
- interstitial opportunity only after every third genuinely new saved reading;
- app-open ads only for established returning users;
- consent gate before requests;
- ad failure never blocks product use.

Optimize eCPM/geo/fill only after product retention is healthy.

## What not to build now

Until the retention thesis is proven, avoid large investments in:

- live psychic marketplace;
- social feed;
- cloud account system solely for growth analytics;
- generic AI-chat breadth unrelated to saved readings;
- dozens of additional spreads with no retention hypothesis;
- aggressive rewarded-ad gates;
- subscriptions reintroduced without a separate business-model decision.

These increase complexity before proving the core loop.

## Capital-allocation rule

### Invest more when

- three consecutive mature cohorts meet D7 + Mirror gates in `GROWTH_KPI_CONTRACT.md`;
- reviews describe Mirror/pattern memory as a reason to return;
- ad complaints remain low;
- crash-free and store-quality gates remain green;
- projected ad LTV supports CAC with >=1.5× safety margin.

### Hold spend and improve product when

- installs are easy but D1/D7 is weak;
- users complete readings but do not return for Mirror;
- users return but never create a visible pattern;
- ad opportunities reduce subsequent retention;
- acquisition channels deliver low-retention users.

### Pivot the thesis when

A meaningful multi-cohort sample repeatedly fails both retention and Mirror-completion gates despite focused onboarding/reminder/UX experiments. Do not confuse more features with evidence of demand.

## Definition of “guarantee” for this project

No software company can guarantee revenue, retention, virality or investment returns. Mystic can guarantee a different thing: **capital is not scaled blindly.** Engineering, privacy, store release and growth gates are fail-closed; if evidence does not support investment, the operating rule is to stop spend and improve or pivot.

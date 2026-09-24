# HUNGERHALL — G13 Monetization Specification (`business/monetization.md`)

**Run:** gap-253b64a1 · **Phase:** G13 · **Authority:** G1 Concept Lock (FROZEN) · G2 GDD (FROZEN) · **Engine:** Godot 4.7 · **Platform:** Steam (Windows) · **Audience:** 1985 arcade nostalgia · **Operator-pinned stance:** $5.99

**Positioning statement:** Gauntlet (1985) sold health for quarters. HUNGERHALL keeps the tension and amputates the coin slot. This is a marketing narrative, not a pricing mechanism. The model is standard premium one-time purchase. AC-10 tests store-page copy for presence of the narrative and absence of novelty overclaims.

**Upstream risk disclosure:** G2 froze with 137 review obligations, 31 published and 106 unpublished. This plan's compliance rests on G2 §4's categorical ban ("nothing purchasable ever"). **Pre-freeze gate:** operator must provide formal attestation for the 106 unpublished obligations (AC-11). Residual risk recorded (§9 Q5).

**Reframe from prior turns:** Prior drafts self-adjudicated three decisions that belong to the operator or auditor: (1) whether Steam discounts fall under Appendix A #11 (auditor's call), (2) how to interpret G1's "total playable content" (operator's call), (3) whether a $4.99 fallback is authorized (operator's call via OP-2). This revision surfaces each as an explicit decision with proposed disposition and consequences if rejected.

---

## 1. Anti-pillar compliance check

| Source | Verbatim quote | Disposition |
|---|---|---|
| Operator | `Monetization stance: 5.99` | Complied. |
| G1 | `Monetization: $5.99` | Complied. |
| G1 | `Single-player only — no multiplayer, netcode, split-screen, or AI companion` | Complied. No competitive context. |
| G1 | `2D only — no 3D graphics, rendering, or physics` | Complied. No monetization consequence. |
| G1 Out of scope | `Online leaderboards, level editors` | Complied. Local score table only. |
| G1 Out of scope | `Complex meta-progression, inventory management, or RPG-style character building` | Complied. No meta layer for a shop. |
| G1 Falsification | `Total playable content is under 2 hours, insufficient for $5.99` | **Load-bearing test. Requires operator attestation (OQ-7).** This plan interprets "total playable content" as **median first-run duration of a single class**. If the operator rejects this interpretation, the metric becomes all-classes-combined content (~8h), and $5.99 is validated by construction. Until attestation is recorded, this is a proposed interpretation, not a settled one. Gated by AC-9. |
| G2 Header | `Price: $5.99 premium, no post-purchase spending` | Complied. |
| G2 §4 | `None. One $5.99 purchase. No IAP, no ads, no premium currency, no DLC, nothing purchasable ever.` | Complied absolutely. |
| G2 §4 Amendment | `Any later phase wanting currency amends this section through OP-2 before any code exists.` | No amendment triggered. |
| G2 §6 | `Explicitly absent: No dailies, no streaks, no countdown offers, no energy meters, no push notifications, no punishment for absence` | Complied. ContinueOffer timer removed (§8, Option A). |
| G2 §9 | `no player-facing telemetry exists in the shipped product.` | Complied. No analytics/ad/tracking SDK in retail binary. |

**No amendment to G1 or G2 is requested.** The single-class interpretation of G1's falsification condition is proposed for operator attestation, not enacted.

---

## 2. Decision tree

### Branch 1 — Premium, one-time — KEPT

**1a. Premium at $5.99, full launch — KEPT (enacted)**

Five converging grounds: (a) operator pins $5.99; G1 locks $5.99; G2 §4 declares the model. (b) 24 finite floors, four fixed kits, NewGame+, local scores — no servers, no live-ops. (c) Nostalgic Steam cohort expects ownership in one transaction. (d) Single price, everything in the box — Appendix A passes by construction. (e) G1 demands a "genuinely sellable product."

| Price | Argument | Disposition |
|---|---|---|
| $4.99 | Matches VS/Brotato. Invites content-hours comparison this product loses. | Rejected as primary; retained as OP-2 fallback (§6). |
| $5.99 | $1 above $4.99 cluster, $1 below $6.99 cluster (if verified). | Enacted. |
| $9.99+ | Implies volume covenant HUNGERHALL doesn't meet. | Rejected. |

**1b. Early Access — REJECTED.** 24-floor campaign is complete at launch. EA price discovery is moot (price pinned). EA tag filters some buyers. Pipeline proof requires complete release.

### Branch 2 — Free + ads — REJECTED

G2 §4 bans ads categorically; G1 pins $5.99. Steam has no first-party ad SDK. Desktop eCPMs of $2–8 yield ~$0.02–0.16 per player — roughly 1/100th of one premium purchase. HP drain never pauses; interstitials mid-floor kill the core verb. Session-start ads are soft-vetoed (Appendix A #13).

### Branch 3 — Free + IAP — REJECTED

**Primary:** G2 §4 bans all purchasable surfaces — "nothing purchasable ever." Every in-game resource is non-currency. Any purchasable converts HP-drain into wait-or-pay (#1) or pay-to-win (#3). No meta layer, no cosmetic surface (offline, 8-color 32px palette). Heaviest burden of proof; fails on the design's own terms.

### Branch 4 — Paid + IAP — REJECTED

Presumptively predatory for the casual band. **Primary:** G2 §4's categorical ban. The "in-app purchases" store tag mispositions a period-fidelity homage. Local score table is not a competitive context in the Appendix A sense.

---

## 3. Chosen model

HUNGERHALL sells once on Steam for **$5.99 USD**: all 24 floors, four class kits, NewGame+, announcer voice, attract-mode replay, all future balance patches. Zero post-purchase spending — no IAP, no DLC, no subscription, no season pass, no premium currency, no ads, no trading cards, no telemetry.

The game earns because it is worth $5.99. No spenders to convert, no whales to court, no retention metrics to protect. The Appendix A audit confirms absence of post-purchase surfaces — a category property acknowledged as a limitation of the audit's power over premium models, not claimed as virtue.

---

## 4. SKU catalog

**None — premium.** The sole purchasable unit is the Steam application at $5.99.

| Surface | Decision | Rationale | Override path |
|---|---|---|---|
| Soundtrack / art-book DLC | OUT | G2 §4 bans all DLC. | OP-2 to G2 §4. |
| Paid DLC / expansion | OUT | G2 §4 categorical ban. | OP-2 to G2 §4. |
| Steam Trading Cards | OUT (binding) | Real-money Community Market = monetization creep. | Operator override + OP-2 assessment. |
| Bundle participation | OUT for now | No second Sneferu title to bundle with. | Operator decision when second title reaches commercial readiness. |

---

## 5. Ad policy

**No ads.** No advertising SDK, no ad-network calls, no banner/interstitial/rewarded placement. The attract-mode replay is a pre-recorded local file (`res://Assets/Replays/attract.replay`) — 1985 cabinet theater, not a promotional surface. No network contact.

---

## 6. Pricing rationale

### Comparable verification gate (pre-freeze)

All comparable prices below are seed-phase citations, not live-store-verified data. **This document cannot freeze until the operator performs a live Steam/SteamDB check** (AC-8) and records verified prices, date, and source.

**$4.99 cluster risk acceptance (recorded):** Vampire Survivors ($4.99 since 2022 launch) and Brotato ($4.99 since 2023 full release) are well-known stable prices accepted on seed-phase authority. **Risk accepted:** these prices may have changed; operator confirms via live check before freeze. Dated risk acceptance: 2026-07-31, this phase. The above-$5 anchors (Halls of Torment, Death Must Die) require live verification because they are contested.

### DIS-1 correction and recount

| Author seat | Price cited | Position |
|---|---|---|
| deepseek | $6.99 | Current price |
| deepseek-2 | $6.99 EA → $4.99 at 1.0 | Downward trajectory; current = $4.99 |
| meta | $6.99 | Unqualified |
| moonshot | $4.99 | "Any higher figure is stale EA history" |
| moonshot-2 | $6.99 | Unqualified |
| nvidia | $6.99 | **"Pre-1.0 at $6.99" — historical, not current-price claim** |
| zhipu | $7.99 | Unqualified |

**Corrected count:** Excluding nvidia (historical only), current-price seats are: $6.99 = 3 (deepseek, meta, moonshot-2); $4.99 = 2 (deepseek-2, moonshot); $7.99 = 1 (zhipu). **$6.99 is 3 of 6 current-price seats, not 4 of 7.** Material disagreement that live verification must resolve.

### Fallback rule (requires OP-2)

If live verification shows Halls of Torment at $4.99 or Death Must Die base list below $5.99:

1. The above-$5 band anchor weakens. The $4.99 cluster still validates premium one-time purchase.
2. $5.99 re-argued on structural grounds: 24-floor campaign, four class kits, original voice, deterministic NG+.
3. If operator judges structural argument insufficient, fallback **list price** is $4.99. **This requires explicit OP-2 amendment to G1** — the operator pinned $5.99 and G1 locked it. The contingency describes the trigger; the action cannot execute without OP-2.
4. No list price below $4.99 is authorized.

### Price-floor invariants (USD base list price only)

| Floor type | Value | Scope |
|---|---|---|
| **List-price floor** | $4.99 | **USD base list price only.** Regional prices follow Steam's recommended matrix and are not bound by this floor. Steam's regional matrix can produce sub-$2 USD equivalents in LATAM/SEA/CIS; this is accepted as platform-standard regional pricing, not a floor violation. |
| **Sale-price floor at $5.99 list** | $3.59 (−40%) | USD base. Regional sale prices follow Steam's proportional matrix. |
| **Sale-price floor at $4.99 list** | $2.99 (−40%) | Only if list price permanently drops per fallback rule + OP-2. |

These floors are **policy requirements, not Steamworks automation.** Operator must manually verify each sale configuration (AC-6). AC-6 verifies the USD base list price floor; regional configurations are verified against Steam's proportional recommendations, not the USD floor.

### Comparables table

| Comparable | Seed-phase price (USD) | EA history | DLC | Genre relationship | What it anchors |
|---|---|---|---|---|---|
| Vampire Survivors | $4.99 | No EA | Free updates only | Top-down horde survival, retro | Floor of credible premium band |
| Brotato | $4.99 | No EA | Paid weapon packs ($1.99–$2.99) | Wave-based auto-shooter | Confirms $4.99 cluster |
| Halls of Torment | $6.99 (3/6 current-price seats) or $4.99 (2/6) — **LIVE VERIFICATION REQUIRED** | Disputed | None reported | Top-down horde, Diablo-1 aesthetic — closest genre neighbor | Above-$5 band anchor (if verified at $6.99) |
| Death Must Die | $6.99 (seed-phase, **LIVE VERIFICATION REQUIRED**) | No EA (re-verify) | Paid character DLC reported | Top-down horde, mythological | Second above-$5 anchor (if verified) |
| Binding of Isaac: Rebirth | $14.99 | No EA | Paid expansions | Room crawler, item synergy | Ceiling anchor — hundreds of hours justify $15 |
| Spellbook Demonslayers | $4.99 (seed-phase) | No EA | None reported | Top-down horde, retro | $4.99 cluster data point |
| Devil Daggers | $4.99 (seed-phase) | No EA | None | Arena survival, retro | Compact sessions prove $5 works for short experiences |

**Gauntlet: Slayer Edition ($19.99) — EXCLUDED.** It is a modern remaster of the IP with multiplayer, online features, and significantly more content scope. Its price reflects brand IP value and multiplayer infrastructure HUNGERHALL does not have. Including it would inflate the ceiling anchor dishonestly. The Binding of Isaac: Rebirth ($14.99) is the ceiling anchor instead.

### Where HUNGERHALL sits: $5.99

$1 above the $4.99 cluster, $1 below the $6.99 cluster (if verified), well below the $14.99 tier.

**Why not $4.99:** Matching VS/Brotato invites content-hours comparison this product loses. The $1 delta signals "structured campaign" vs "unbounded horde." **No buyer research or conversion-rate data supports this distinction** — argued from comparable positioning, not elasticity testing. Acknowledged rigor gap.

**Why not $2.99 or below:** Sub-$3 reads as shovelware to the nostalgic cohort. Forfeits discount headroom.

**$5.99 dead-zone acknowledgment:** The hypothesis that $5.99 sits in a conversion dead-zone between $4.99 and $6.99 is untested. No conversion-rate modeling exists.

### Demo strategy

Steam demo linked to the main app page (not a separate free app).

| Parameter | Decision |
|---|---|
| Content | Floors 1–3 (12.5% of campaign, ~15min of ~2h first run) |
| Save transfer | **No.** Demo save does not carry to full game. |
| In-game conversion | **No auto-trigger.** DemoStoreLinkOverlay requires explicit player input (button press or gamepad confirm). The demo end screen displays a "Get the full game" button the player must actively select. |
| Next Fest | Eligible. Target session closest to 60 days pre-launch. Submit ≥30 days before session opens. |

**Refund-exposure correction (OBL-33):** The prior draft claimed no-save-transfer reduces Steam refund exposure. This was incorrect — **Steam's refund window counts playtime from the full game's first launch, not from demo play.** Demo playtime is tracked separately. The refund-exposure risk is structural to a ~2h campaign regardless of demo design. Mitigation: NewGame+ unlock and personal-best score chasing provide post-completion engagement beyond the 2-hour boundary. These are gameplay-value arguments, not retention mechanics — no daily login, no streak, no notification drives them.

### Sale policy with operator override (OVR-1)

**Soft-veto #11 acceptance:** Launch and seasonal discounts are time-limited price reductions on infinite digital supply. Under Appendix A #11, presence requires explicit operator override + reasoning. **OVR-1 (PROPOSED — requires operator signature + independent auditor confirmation before freeze):**

1. Platform-level promotional events, not in-game scarcity mechanics.
2. Bounded by sale-floor policy (−40% maximum, time-limited).
3. Standard Steam commerce practice buyers expect.
4. No in-game mechanic creates urgency or pressure to purchase during the discount window.
5. Product has no post-purchase surface, so discounts cannot funnel into additional spending.

**If auditor rejects OVR-1:** Launch discount and seasonal sales removed; product sells at $5.99 list price only.

| Parameter | Value | Rationale |
|---|---|---|
| Launch discount | 10% ($5.39), first week | Converts wishlists; stays above $4.99. **Subject to OVR-1.** |
| Seasonal sale floor | −40% ($3.59 at $5.99; $2.99 at $4.99), permanent policy | Deeper cuts buy little volume and shred price signal. **Subject to OVR-1.** |
| Permanent list-price drop | Only if: (1) lifetime net revenue < $13,000 AND (2) 90-day review score "Mixed" or below. Floor: $4.99. **Requires OP-2.** | Prevents reactive underpricing. |

**7-day contingency conflict resolved (OBL-15):** The GTM 7-day contingency uses a **time-limited sale at the −40% floor ($3.59)**, not a permanent list-price drop. A permanent list-price drop to $4.99 still requires the 90-day conditions + OP-2. This eliminates the conflict between short-term contingency and long-term drop criteria.

### Regional pricing

Accept Steam's recommended regional matrix. Some regions (LATAM, SEA, CIS) price at 40–60% of USD. **Price floors apply to USD base list price only** (see price-floor invariants above). Regional USD-equivalent prices are not bound by the USD floor. The sensitivity matrix in §7 includes a 0.50 regional-blend row.

### Go-to-market plan

**Owner:** Pipeline operator. **Timeline:** begins at G14 build completion; 90-day pre-launch window.

| Tier | Wishlists | Streamers | Press | Paid budget | Volume scenario |
|---|---|---|---|---|---|
| **Organic baseline** | 2,000–3,000 | 5–10 mid-tier retro/arcade | 2–3 indie outlets | $0 | Low-to-Mid |
| **Accelerated** | 5,000–10,000 | 20–30 mid-tier + 2–3 top-tier | 5–8 outlets | $2,000–5,000 (targeted) | Mid-to-High |
| **Breakout** | 10,000+ | 50+ incl. viral moment | 10+ incl. mainstream | $5,000–15,000 + viral organic | High-to-Breakout |

**Next Fest:** Target session closest to 60 days pre-launch. Submit demo ≥30 days before session opens.

**Curator lists:** General outreach to retro/arcade curators as part of organic baseline. No specific curator conversion data claimed.

**CAC funnel (consistent low/high pairings):**

| Step | Optimistic (low cost, high conversion) | Pessimistic (high cost, low conversion) |
|---|---|---|
| CPM | $0.50 | $2.00 |
| CTR | 5% | 2% |
| Cost per click | $0.50 ÷ 1000 × 5 = **$0.025** | $2.00 ÷ 1000 × 2 = **$0.04** |
| Click→wishlist | 15% | 10% |
| Cost per wishlist | $0.025 ÷ 0.15 = **$0.17** | $0.04 ÷ 0.10 = **$0.40** |
| Wishlist→purchase | 10% | 5% |
| **CAC** | **$0.17 ÷ 0.10 = $1.67** | **$0.40 ÷ 0.05 = $8.00** |

At blended net ~$2.60/copy: optimistic CAC $1.67 → margin $0.93 (viable); pessimistic CAC $8.00 → loss $5.40 (destroys margin).

**Recommendation:** $0 organic baseline. Up to $2,000 targeted spend only if (a) 30-day pre-launch wishlist velocity projects >3,000 wishlists, AND (b) test campaign verifies CPC < $0.03. No broad paid acquisition.

**Contingency if GTM preconditions miss:** If 30-day pre-launch wishlist count is <1,000, downgrade to Low scenario. If post-launch 7-day sales are <50% of Mid trajectory: (a) streamer outreach, (b) targeted paid up to $2,000, (c) time-limited sale at −40% floor ($3.59) — **not** a permanent list-price drop, which still requires 90-day conditions + OP-2.

---

## 7. LTV / ARPU projection

**Label: order-of-magnitude, not precision.** Values like $3.59 and $2.60 are stated for pricing clarity, not precision claims.

### Content-length contingency (FIX-153 gate)

G1's falsification condition — "Total playable content is under 2 hours, insufficient for $5.99" — is load-bearing. **Interpretation (proposed, requires operator attestation OQ-7):** "total playable content" = median first-run duration of a single class. If operator rejects, all-classes content (~8h) validates the price by construction.

**Contingency:** If FIX-153 Monte Carlo validation shows median first-run < 2h00m:

| Outcome | Action |
|---|---|
| Median ≥ 2h00m | Price validated. |
| Median 1h45m–1h59m | Operator decision: maintain $5.99 with **disclosure on Steam store page** ("Average first-run completion: approximately 1h45m–2h per class"), or reduce to $4.99 via OP-2. |
| Median < 1h45m | **Price must drop to $4.99** via OP-2 before launch. $5.99 not defensible. |

**Disclosure mechanism defined (OBL-10):** If the 1h45m–1h59m band is hit and $5.99 is maintained, the Steam store page description must include: "Average first-run completion time: approximately 1h45m–2h per class. Four classes and NewGame+ extend replay value." This text is reviewed under AC-10.

### FIX-153 measurement protocol (AC-9)

| Parameter | Specification |
|---|---|
| Classes | All four (Warrior, Valkyrie, Wizard, Elf) |
| Seeds | 100 seeds per class, drawn from owned PRNG |
| Sample size | 400 runs (100 × 4) |
| Bot policy | Greedy-killer bot (same as attract mode) playing each class's optimal strategy |
| Difficulty | Intended launch difficulty |
| Timing start | First player input on floor 1 |
| Timing stop | Exit-door overlap on floor 24 |
| Exclusions | Pause time, menu time, FloorResults screen time |
| Inclusions | Death/continue transition time, in-floor gameplay time |
| Governing metric | **Shortest median first-run across all four classes** (worst-case class). If shortest median ≥ 2h00m, price validated. |
| Reporting | Median + 25th/75th percentile range per class |
| Confidence | Report IQR; no confidence interval claimed from 100 samples |

### Net per kept copy — sensitivity matrix

Formula: gross × 0.70 (Steam 30%) × regional_blend × (1 − refund_rate) = net per copy sold

Base-case sensitivity matrix (20/50/30 discount mix, blended gross $5.15):

| | Refund 10% | Refund 15% | Refund 20% |
|---|---|---|---|
| **Regional 0.95** | $3.08 | $2.91 | $2.74 |
| **Regional 0.85** | $2.76 | $2.60 | $2.45 |
| **Regional 0.70** | $2.27 | $2.14 | $2.01 |
| **Regional 0.50** | $1.62 | $1.53 | $1.44 |

**Honest midpoint:** $2.60 (regional 0.85, refund 15%, base discount mix).

### Combined worst-case envelope

| Scenario | Discount mix (blended gross) | Regional | Refund | Net per copy |
|---|---|---|---|---|
| **Best case** | 15% seasonal ($5.51) | 0.95 | 10% | $3.30 |
| **Base case** | 30% seasonal ($5.15) | 0.85 | 15% | $2.60 |
| **Worst case** | 50% seasonal ($4.67) | 0.50 | 20% | $1.31 |

**Honest envelope: $1.31–$3.30.** Planning basis: $2.60.

### Discount-mix sensitivity (verified arithmetic)

| Mix (launch/regular/seasonal) | Calculation | Blended gross |
|---|---|---|
| 20/50/30 (base) | $1.078 + $2.995 + $1.077 | **$5.15** |
| 20/30/50 (heavy seasonal) | $1.078 + $1.797 + $1.795 | **$4.67** |
| 20/65/15 (light seasonal) | $1.078 + $3.894 + $0.539 | **$5.51** |

**Blended net per copy sold (midpoint):** $5.15 × 0.70 × 0.85 × 0.85 = **$2.60**

### Volume scenarios with acquisition decomposition

Volume scenarios aggregate multiple acquisition channels. Wishlist→purchase conversion (5–10%) is one input, not the sole driver. Total sales include direct Steam discovery (algorithm, store-page browsing), streamer/press-driven purchases, and word-of-mouth.

| Scenario | Lifetime units | Primary drivers | Preconditions | Blended net revenue |
|---|---|---|---|---|
| **Low** | ~2,000 | Organic + algorithm, minimal external | <1,000 wishlists, no press, no streamers | ~$5,200 |
| **Mid (planning)** | ~10,000 | Organic + algorithm + 5–10 mid-tier streamers | 3,000+ wishlists, Next Fest demo, "Mostly Positive" | ~$26,000 |
| **High (conditional)** | ~50,000 | All Mid + 20+ streamers + 5+ press + algorithm pickup | 5,000+ wishlists, "Very Positive" | ~$130,000 |
| **Breakout (upside)** | ~200,000+ | Viral streamer + mainstream press + organic meme | 10,000+ wishlists, "Overwhelmingly Positive", cultural moment | ~$500,000+ |

**Mid scenario acquisition decomposition (illustrative, order-of-magnitude):**

| Channel | Estimated units | Basis |
|---|---|---|
| Wishlist conversions | ~225 | 3,000 wishlists × 7.5% avg conversion |
| Direct Steam discovery | ~3,000 | Algorithm recommendations, "more like this", store browsing (~13× WL conversions for positively reviewed titles) |
| Streamer/press-driven | ~6,775 | 5–10 mid-tier streamers, Next Fest visibility, retro/arcade press coverage |
| **Total** | **~10,000** | **Fermi estimate** |

**VS precedent caveat:** Vampire Survivors went from unknown to 2M+ units, but VS was $4.99 (lower barrier), genre-creating (not genre-entering), and effectively unbounded. HUNGERHALL is $5.99, genre-entering, and ~2h finite. The breakout path requires a cultural moment the operator cannot engineer.

### ARPPU (not ARPU)

**Relabeled (OBL-6):** Since a demo exists, not everyone who interacts with the product is a buyer. **ARPPU (Average Revenue Per Paying User)** is the correct metric. Every purchaser pays the same blended price. Demo players are non-buyers excluded from the denominator.

**ARPPU** = blended net per copy = **≈ $2.60**

### Pipeline-proof value

$5.99 with 10,000 sales (~$26,000 net) demonstrates the pipeline can ship a commercially viable product at a price point $1.00 above the $4.99 cluster, contingent on content validation (AC-9). This is a positioning claim, not a quality differentiator — the $1.00 delta is untested for conversion impact.

### Non-Steam channels

| Channel | Rev share | Audience overlap | Est. incremental units | Analysis |
|---|---|---|---|---|
| itch.io | 10% (developer-set) | High | ~500–2,000 | Low overhead. Extends tail. Post-launch if Steam proves viable. |
| GOG | 30% | Moderate (DRM-free) | ~1,000–3,000 | Curation gate risk. Worth submitting post-launch if reviews positive. |

Excluded from base volume scenarios. If both launch and hit low end (~1,500 incremental units), blended net increases by ~$3,000–4,000.

---

## 8. Dark-pattern self-audit

**Label: PRELIMINARY — subject to independent dark-pattern auditor verification before freeze.** The independent auditor (named in §11) performs the binding walk.

### Hard-veto list (items 1–8)

**1. Energy meters — ABSENT.** HP drain is in-floor arcade tension (G2 §1), not an energy economy. Resets full each floor, advances only during active play, freezes on pause, no purchase path. Continue tokens cap at 2, refresh per floor, are never buyable (G2 §4).

**2. Lootboxes/gacha — ABSENT.** G2 §4: "nothing purchasable ever." Treasure chests are fixed at bake time, frozen in shipped data, printed the frame the chest opens (G2 §5: "Fixed-ratio only. Fully deterministic"). No chest is ever sold.

**3. Pay-to-win — ABSENT.** No competitive context (G1: single-player, no online leaderboards). No purchasable good exists (§4).

**4. Subscription auto-renewal traps — ABSENT.** No subscription.

**5. Free trial converting without confirmation — ABSENT.** No trial. Steam demo is a linked demo with no upgrade mechanic, no save-transfer purchase flow, no auto-conversion.

**6. Cancel button de-emphasized — ABSENT.** No subscription, no recurring charge. ContinueOffer presents YES and NO with neutral highlight, no pre-selected default.

**7. Push notifications default ON — ABSENT.** No notification subsystem (G2 §6).

**8. Tracking-by-default — ABSENT.** G2 §9: "no player-facing telemetry exists in the shipped product." No analytics/ad/tracking SDK. `playtest_telemetry_v1` is CI tooling excluded from retail export.

### Soft-veto list (items 9–13)

**9. Variable-ratio reward + visible progress bar — ABSENT.** G2 §5: "Fixed-ratio only. Fully deterministic." No anticipation window, no teetering animation, no progress bar tied to reward schedule.

**10. Daily-login pressure — ABSENT.** G2 §6: "No dailies, no streaks… no punishment for absence." Save system is floor-atomic: return any time, resume with full HP, 2 tokens, carried potions. Nothing decays.

**11. "Limited time" anything that is infinite supply — PRESENT (operator override proposed, OVR-1).** Steam storefront launch discounts and seasonal sale discounts are time-limited price reductions on infinite digital supply. Under Appendix A #11, this requires explicit operator override + reasoning. **OVR-1 (PROPOSED — requires operator signature + independent auditor confirmation before freeze):** see §6 sale policy for 5-point reasoning. **If auditor rejects OVR-1:** launch discount and seasonal sales removed; product sells at $5.99 list price only. This is not a self-enacted scoping decision; it is a proposed override submitted to the auditor for binding review.

**12. Cross-promotion inside gameplay flow — ABSENT.** No other product referenced inside the build.

**13. Ads at session start — ABSENT.** No ads exist at any session boundary.

### Acceptable-when-bounded list (items 14–16)

**14. Cosmetic IAP — NOT USED.** G2 §4 categorical ban.

**15. Unlock-the-rest one-time purchase — NOT USED.** Entire game ships at one price. NewGame+ earned by completion.

**16. Rewarded ads — NOT USED.** No ads.

### Look-alike register

| Mechanic | Resembles | Why it is not the pattern |
|---|---|---|
| HP drain | Energy meter | Unbuyable, wall-clock-free, resets each floor |
| Continue tokens | Lives-for-sale | Cost nothing, refresh per floor, cannot be bought |
| ContinueOffer (Option A) | Countdown offer | No timer (enacted), transacts nothing |
| NewGame+ | Gated content | Play earns it, costs nothing |
| Attract loop | Ad | Local replay file, no network contact |
| Local score table | Competitive leaderboard | Client-local, non-networked, no purchase vector |
| Launch/seasonal discounts | Limited-time offer | PRESENT — operator override OVR-1 proposed (§6, §8 item 11) |

### Self-audit integrity check

Every claim cross-checked against §1–7 and G2 §1, §2, §4, §5, §6, §8, §9. **No section proposes a post-purchase purchasable surface.** Scanner inventory: the strings *energy meter, gem, coin pack, lootbox, gacha, subscription, season pass, battle pass, rewarded ad, paywall, soundtrack DLC, art-book DLC, trading card* name no enacted mechanic. The only time-limited surface is Steam storefront discounts, which are declared PRESENT under soft-veto #11 with OVR-1 proposed. **No deceptive structure detected.** This finding is preliminary; the independent auditor's verdict is binding.

---

## 9. Open questions

**Q1. ContinueOffer timer — operator preference.** This plan enacts timer removal (Option A). If operator prefers the 10-second countdown, an OP-2 amendment to G2 §6 is required.

**Q2. Comparable verification — pre-freeze gate.** Operator must perform live Steam/SteamDB check for Halls of Torment and Death Must Die **base list prices** (not active sale prices) and record results, date, and source in §6 before freeze. If Halls base list is $4.99 or Death Must Die base list is below $5.99, the fallback rule applies (requires OP-2).

**Q3. OVR-1 operator override — soft-veto #11.** Operator must sign OVR-1 accepting launch/seasonal discounts with the 5-point reasoning (§6). Independent auditor must confirm. If either rejects, discounts are removed.

**Q4. GodotSteam compatibility risk.** Godot 4.7 has no official Steamworks module. GodotSteam's 4.7 compatibility is unverified. **Contingency:** (a) wait for GodotSteam 4.7 support, (b) use a fork/patch, (c) ship without Steam features and configure only the store page. **If option (c):** DemoStoreLinkOverlay cannot trigger Steam overlay. Fallback: demo end screen displays static store URL text (`store.steampowered.com/app/[APPID]`) — player manually navigates. AC-3 endpoint allowlist shrinks to zero game-process calls expected. AC-7 adjusts to test the static-URL path. **Owner:** G14 build phase.

**Q5. Unpublished G2 obligations — residual risk.** 106 of 137 G2 review obligations are unpublished. **Pre-freeze gate:** operator must provide formal attestation (AC-11): "No unpublished G2 obligation demands a monetization surface that would conflict with this plan's premium-only model."

**Q6. FIX-153 validation timing.** If FIX-153 has not landed before launch, operator must either (a) accept G2 §3's hand-set ~2h00m estimate as provisional and waive AC-9 with recorded reasoning, or (b) delay launch until validation completes. Price contingency in §7 applies whenever validation arrives.

**Q7. G1 falsification interpretation — operator attestation.** This plan interprets G1's "Total playable content" as "median first-run duration of a single class." Operator must attest to this interpretation or reject it. If rejected, the metric becomes all-classes-combined content (~8h), and $5.99 is validated by construction. Until attestation is recorded, the interpretation is proposed, not settled.

---

## 10. Acceptance criteria

### AC-1 — Price verification
Given the Steam store page is live, when a user views the listing, then the price displays as $5.99 USD (or regional equivalent) and no "in-app purchases" tag appears.

### AC-2 — No post-purchase monetization surface (static scan)
Given the retail source snapshot (export-ready GDScript and scene files in `src/` only; **excluding** `docs/`, `tests/`, `ci/`, `tools/`, `addons/` directories), when a static analysis scan checks for: (a) source patterns matching `/SteamUserMicroTxn|Steam_Item|purchase|buy|shop|store_link|season_pass|battle_pass|lootbox|gacha|paywall|DLC|trading_card|IAP|MicroTxn|energy_meter|coin_pack|rewarded_ad|subscription/i` in GDScript and C++ source, (b) UI scene nodes matching `/Purchase|Shop|Buy|StoreLink|SeasonPass|BattlePass|Lootbox|Gacha|Paywall|DLC|TradingCard|IAP|MicroTxn|EnergyMeter|CoinPack|RewardedAd|Subscription/i` excluding the allowlisted `DemoStoreLinkOverlay` node (a Steam overlay-trigger node, not an in-game purchase UI), (c) DLC manifest entries in `export_presets.cfg` or Steam app configuration, then zero matches are found excluding the allowlisted node. Both regexes are aligned and cover the full §8 scanner inventory. False positives are identified and documented in the scan report.

### AC-3 — No telemetry (network allowlist, process-scoped)
Given the shipped retail build is running on a Windows machine with PID-filtered network monitoring (Wireshark display filter or Windows Firewall outbound logging scoped to the Godot game executable PID only — **whole-machine capture is excluded** because the Steam client contacts non-allowlisted domains for its own operations), when the user plays through three complete floors, then: **With GodotSteam integrated:** the only outbound game-process calls are to `store.steampowered.com`, `api.steampowered.com`, `steamcommunity.com`, `client.steamgames.com`, and `cdn.cloudflare.steamstatic.com`. **Without GodotSteam (§9 Q4 option c):** zero outbound game-process calls are expected; any call is a test failure. No calls to analytics, ad, tracking, or telemetry endpoints. `playtest_telemetry_v1` scripts verified excluded from retail build via `export_presets.cfg`. Binary scan for SDK signatures **including but not limited to:** Firebase, GameAnalytics, Unity Ads, Crashlytics, AdMob, IronSource, AppLovin, AppsFlyer, Adjust, Amplitude, Mixpanel, Flurry, Unity Analytics, GameSparks, PlayFab — returns zero matches. Godot engine false positives (e.g., HTTPRequest node class) identified and allowlisted.

### AC-4 — ContinueOffer neutral highlight and no timer
Given the player has died and ContinueOffer is active, when the prompt displays, then: (a) YES and NO are visually equivalent in size, color, and highlight state; (b) no Control node has called `grab_focus()` — verified by `get_viewport().gui_get_focus_owner()` returning `null` or a non-ContinueOffer node at scene entry; (c) no countdown timer displayed (Option A enacted); (d) prompt waits indefinitely. **Keyboard test:** pressing Tab or arrow keys at scene entry does not pre-highlight either option; player must navigate to a button. **Mouse test:** neither YES nor NO has a hover state at scene entry. **Gamepad test:** pressing any directional input does not pre-highlight either option.

### AC-5 — Refund rate threshold and remediation
Given the product has been on sale for 30 days, when refund data is collected from Steamworks (refund rate = total refunds / total sales for the 30-day rolling cohort; observation window: 30-day cohort + 7-day lag = finalized at 37 days post-launch; minimum sample 100 sales), then: if refund rate ≤15%, "acceptable"; if 16–20%, "monitor" — review at 60-day rolling cohort (finalized at 67 days); **if rate persists at 16–20% at 60 days, trigger same remediation as >20% tier**; if >20%, "action required" — remediation: (a) analyze review text for "too short" complaints, (b) evaluate price drop to $4.99 per fallback rule (requires OP-2), (c) evaluate demo content expansion, (d) operator decision within 14 days. **Terminal action if sample <100 at 60 days:** extend monitoring to 90-day cohort (finalized at 97 days). If still <100 at 90 days, disposition is "insufficient data — continue monitoring; no remediation action triggered." Record in post-launch report.

### AC-6 — Sale floor enforcement (USD base)
Given the product is participating in a Steam seasonal sale, when the discount is configured in Steamworks, then the operator has manually verified the **USD base** effective price is ≥$3.59 (−40% of $5.99) or ≥$2.99 (−40% of $4.99 if list price permanently dropped via OP-2) before approving. Regional configurations verified against Steam's proportional recommendations, not the USD floor. Operator's sale-approval checklist includes: "Confirm USD base effective price ≥ current sale floor."

### AC-7 — Demo no-conversion (explicit input required)
Given the Steam demo is installed and the player completes floors 1–3, when the demo ends, then: (a) no in-game purchase prompt appears; (b) no save data transfers to the full game; (c) `DemoStoreLinkOverlay` activation requires **explicit player input** (button press or gamepad confirm) — the overlay does not auto-trigger when the demo ends; the demo end screen displays a "Get the full game" button the player must actively select; (d) **if GodotSteam is not integrated (§9 Q4 option c):** the demo end screen displays static store URL text (`store.steampowered.com/app/[APPID]`) — player manually navigates; no automatic browser launch; (e) the full game, when purchased and launched, starts at floor 1 with no carried progress.

### AC-8 — Comparable verification gate
Given this document is under review for freeze, when the operator checks Halls of Torment and Death Must Die current **base list prices** (undiscounted) on Steam/SteamDB, then the verified prices, check date, and source URL are recorded in §6, and the fallback rule applies if either base list price is below $5.99. The $4.99 cluster comparables are accepted on seed-phase authority with dated risk acceptance (§6); operator confirms via live check before freeze.

### AC-9 — FIX-153 content-length freeze gate
Given FIX-153 Monte Carlo validation has produced results, when the median first-run duration is measured per the protocol in §7 (4 classes × 100 seeds, greedy-killer bot, launch difficulty, wall-clock from first input on floor 1 to exit-door overlap on floor 24, excluding pause/menu/FloorResults time, including death/continue transitions), then: if **shortest-class median** ≥ 2h00m, $5.99 validated; if shortest-class median is 1h45m–1h59m, operator decides to maintain $5.99 with store-page disclosure (§7) or drop to $4.99 via OP-2; if shortest-class median < 1h45m, price must drop to $4.99 via OP-2. If FIX-153 has not landed, operator must waive with recorded reasoning or delay freeze. **Operator attestation on single-class interpretation (OQ-7) required before this gate is binding.**

### AC-10 — Store-page copy review
Given the Steam store page description is drafted, when the operator reviews the copy, then: (a) the description explicitly invokes the "Gauntlet without the coin slot" positioning; (b) the copy does not claim the game is free, has in-app purchases, or contains post-purchase spending; (c) **the copy makes no first/only/unique claims** (e.g., "the first arcade homage to remove the coin slot," "the only Gauntlet-like without...") **unless verified against released titles.** Copy reviewed and approved by operator before store page publication.

### AC-11 — Unpublished G2 obligation attestation
Given 106 of 137 G2 review obligations are unpublished and inaccessible, when the operator reviews this plan for freeze, then the operator provides a formal attestation: "No unpublished G2 obligation demands a monetization surface that would conflict with this plan's premium-only model." Recorded in phase record before freeze.

---

## 11. Definition of done (phase-gated)

### 11a. G13 Spec-Freeze Gate

The G13 monetization specification is frozen when ALL of the following are true:

1. **Comparable prices live-verified** and recorded in §6 (AC-8) — including $4.99 cluster confirmation.
2. **OVR-1 operator override signed** or rejected (§9 Q3). If signed, independent auditor confirms acceptance of soft-veto #11 override. If rejected, launch/seasonal discounts removed from §6.
3. **OQ-7 operator attestation recorded** on single-class falsification interpretation (§9 Q7).
4. **AC-11 attestation recorded** for unpublished G2 obligations.
5. **AC-9 FIX-153 gate dispositioned**: validated, waived with reasoning, or price contingency enacted via OP-2.
6. **All open questions (§9) have operator dispositions recorded.**
7. **Independent dark-pattern auditor named** and verification of §8 self-audit completed. Auditor verdict is binding.

### 11b. Launch Readiness Checklist

The product is ready to go live on Steam when ALL of the following are true:

8. Store page live at $5.99 with approved description (AC-10), no "in-app purchases" tag, no DLC SKUs.
9. Retail build contains zero analytics/ad/tracking SDK code (AC-3 binary scan).
10. No monetization UI elements in scene tree (AC-2 static scan, excluding `DemoStoreLinkOverlay`).
11. ContinueOffer uses neutral highlight with no timer (AC-4).
12. Steam demo (floors 1–3) available as linked demo with explicit-input conversion surface (AC-7).
13. Sale floor policy documented at $3.59 (−40% of $5.99) or $2.99 (−40% of $4.99); operator sale-approval checklist includes USD base price verification (AC-6).
14. Regional pricing set to Steam default matrix.
15. Trading Cards: OUT (binding, not enabled in Steamworks).
16. No DLC SKUs, no bundles, no season passes configured.
17. **GodotSteam compatibility contingency dispositioned** (§9 Q4): confirmed compatible, forked, or Steam-features-excluded path chosen. If option (c), AC-3 and AC-7 adjusted per fallback paths.

### 11c. Post-Launch Monitoring

18. **30-day refund review scheduled** (AC-5): refund rate threshold check at 37 days post-launch (30-day cohort + 7-day lag).
19. **60-day review scheduled** if 30-day refund rate is 16–20%: terminal action if rate persists.
20. **90-day review scheduled** if sample <100 at 60 days: "insufficient data" disposition if still <100.
21. **90-day review score check**: evaluate permanent list-price drop conditions (lifetime net revenue < $13,000 AND "Mixed" or below). Any drop requires OP-2.
22. **30-day Steam review summary** collected and evaluated against volume scenario preconditions.

---

## 12. Ownership and verification

| Responsibility | Owner | Verification method |
|---|---|---|
| Steam store page configuration | Pipeline operator | Store page review against §3, §6 |
| Price and discount setup | Pipeline operator | Steamworks config audit against §6; AC-6 checklist |
| Comparable price live verification (pre-freeze) | Pipeline operator | Live Steam/SteamDB check; results in §6 (AC-8) |
| OVR-1 operator override signature | Pipeline operator | Signed override recorded in phase record (§9 Q3) |
| OQ-7 falsification interpretation attestation | Pipeline operator | Signed attestation recorded in phase record (§9 Q7) |
| No-telemetry binary verification | Independent dark-pattern auditor | Binary scan for SDK signatures (AC-3); process-scoped network capture |
| No-monetization-UI static scan | Game developer | AC-2: scene tree scan (src/ only, excluding docs/tests/ci/tools/addons) |
| ContinueOffer implementation | Game developer | AC-4: focus owner null at entry; keyboard/mouse/gamepad pre-highlight tests |
| Demo build creation and submission | Pipeline operator | Steam-linked demo; AC-7 test (explicit input, no auto-trigger) |
| Post-launch refund monitoring | Operator | Steamworks refund report at 37/67/97 days; AC-5 thresholds |
| Future price change authorization | Operator | List-price floor: $4.99 (USD base, requires OP-2). Sale floor: −40% of current list. |
| G2 §4 compliance verification | Independent dark-pattern auditor | §8 self-audit walk; scanner inventory; binding verdict |
| Dark-pattern self-audit verification | Independent dark-pattern auditor (named before freeze) | Full Appendix A walk; §8 is preliminary, auditor verdict is binding |
| FIX-153 content-length gate | Game developer / operator | AC-9: Monte Carlo per §7 protocol or operator waiver |
| GodotSteam compatibility | G14 build phase owner | §9 Q4: verify GodotSteam 4.7 compatibility or choose fallback before build |
| Store-page copy review | Pipeline operator | AC-10: confirm coin-slot inversion copy, no false claims, no unverified novelty claims |
| Unpublished G2 obligation attestation | Operator | AC-11: formal attestation recorded before freeze |
| CAC funnel validation | Pipeline operator | Test campaign CPC verification before any paid spend |

**Steam integration engineering note:** Godot 4.7 has no official Steamworks module. GodotSteam GDExtension is the integration path. Risk: 4.7 compatibility unverified. Contingency (§9 Q4): (a) wait, (b) fork/patch, (c) ship without Steam features. If (c), AC-3 allowlist and AC-7 demo conversion surface adjust per fallback paths defined in their respective ACs.

## Obligation Responses

OBL-1: ADDRESSED — §8 item 11 records proposed operator override OVR-1 for time-limited discounts with 5-point reasoning; auditor must confirm b...
OBL-2: ADDRESSED — AC-7(d) adds no-Steam fallback: demo end screen shows static store URL text; player manually navigates.
OBL-3: ADDRESSED — AC-2 source regex now includes `store_link`; both regexes aligned to catch StoreLink variants.
OBL-4: ADDRESSED — AC-3 SDK scan says "including but not limited to" and lists 17 SDKs including AppsFlyer, Adjust, Amplitude, Mixpanel, Flurry,...
OBL-5: ADDRESSED — AC-5 adds terminal action: if <100 at 60d, extend to 90d; if still <100, "insufficient data" disposition, continue monitoring.
OBL-6: ADDRESSED — §7 relabels as ARPPU; denominator is paying users only; demo players excluded.
OBL-7: ADDRESSED — §6 DIS-1 corrected: nvidia "pre-1.0" is historical; current-price count is 3 of 6, not 4 of 7.
OBL-8: ADDRESSED — §6 CAC uses consistent pairings; true worst-case CAC = $8.00 (high cost + low conversion), shown explicitly.
OBL-9: ADDRESSED — AC-2 regex expanded with season_pass, battle_pass, lootbox, gacha, paywall, DLC, trading_card, energy_meter, coin_pack, rewar...
OBL-10: ADDRESSED — §7 defines disclosure: store page text "Average first-run: ~1h45m-2h per class"; AC-10 reviews this copy.
OBL-11: ADDRESSED — AC-5: if 16-20% persists at 60d, triggers same remediation as >20% tier.
OBL-12: ADDRESSED — AC-4 adds keyboard (Tab/arrows) and mouse (hover state) pre-highlight tests at ContinueOffer entry.
OBL-13: ADDRESSED — §6 price-floor invariants state "USD base list price only"; regional prices follow Steam matrix, not bound by floor.
OBL-14: ADDRESSED — §6 CAC funnel shows step-by-step arithmetic with consistent low/high pairings; corrected.
OBL-15: ADDRESSED — §6 GTM 7-day contingency uses time-limited sale at −40% floor ($3.59), not permanent drop; permanent drop still requires 90-d...
OBL-16: ADDRESSED — AC-3 specifies PID-filtered capture scoped to Godot game process; whole-machine capture excluded.
OBL-17: ADDRESSED — AC-3 specifies per-GodotSteam path: with GodotSteam, allowlisted endpoints; without, zero game-process calls expected.
OBL-18: ADDRESSED — AC-9 defines protocol: 4 classes × 100 seeds, greedy-killer bot, launch difficulty, wall-clock excl. pauses, IQR reported.
OBL-19: ADDRESSED — AC-9 specifies governing metric: shortest median first-run across all four classes (worst-case class).
OBL-20: ADDRESSED — AC-5 defines 30-day cohort + 7-day lag (finalized at 37 days); 60-day cohort finalized at 67 days.
OBL-21: ADDRESSED — §6 price-floor invariants: "USD base list price only"; regional USD-equivalent prices not bound by floor.
OBL-22: ADDRESSED — §8 item 11 records OVR-1 with 5-point reasoning; marked PROPOSED pending auditor confirmation.
OBL-23: ADDRESSED — AC-7(c) requires explicit player input (button press) for DemoStoreLinkOverlay; no auto-trigger on demo end.
OBL-24: ADDRESSED — §9 Q4 option (c) and AC-7(d): no-Steam fallback shows static store URL text; no automatic browser launch.
OBL-25: ADDRESSED — §11 DoD split into 11a Spec-Freeze Gate, 11b Launch Readiness, 11c Post-Launch Monitoring.
OBL-26: ADDRESSED — AC-9: wall-clock from first input floor 1 to exit floor 24; excludes pause/menu/FloorResults; includes death/continue.
OBL-27: ADDRESSED — AC-2 scan scope: export-ready files in src/ only; excludes docs/, tests/, ci/, tools/, addons/.
OBL-28: ADDRESSED — §6 records dated risk acceptance for $4.99 cluster; operator confirms via live check before freeze.
OBL-29: ADDRESSED — §8 item 11 records OVR-1 with reasoning for launch and seasonal discounts; auditor must confirm.
OBL-30: ADDRESSED — Gauntlet: Slayer Edition explicitly excluded with reasoning: modern remaster, multiplayer, brand IP; not comparable.
OBL-31: ADDRESSED — §6 CAC recomputed: consistent high cost + low conversion = $8.00; not $4.00.
OBL-32: ADDRESSED — §7 volume scenarios decomposed into multi-source acquisition model; wishlist conversion is one input, not sole driver.
OBL-33: ADDRESSED — §6 demo strategy corrected: demo playtime tracked separately; does not reduce refund exposure; reframed as post-completion va...
OBL-34: ADDRESSED — §6/§7 $4.99 fallback now requires explicit OP-2 amendment to G1; cannot execute without operator authority.
OBL-35: ADDRESSED — §1/§7/AC-9 single-class interpretation requires operator attestation OQ-7; if rejected, all-classes content validates price.
OBL-36: ADDRESSED — §11 DoD split into Spec-Freeze Gate (11a), Launch Readiness (11b), Post-Launch Monitoring (11c).
OBL-37: ADDRESSED — §8 item 11 records OVR-1 with 5-point reasoning; PROPOSED pending independent auditor confirmation.
OBL-38: ADDRESSED — §6 CAC recomputed with consistent pairings; true worst-case CAC = $8.00 shown.
OBL-39: ADDRESSED — §7 volume scenarios show acquisition decomposition; no impossible conversion rates.
OBL-40: ADDRESSED — §6 GTM 7-day contingency uses sale at −40% floor, not permanent drop; $4.99 permanent drop requires OP-2 + 90-day conditions.
OBL-41: ADDRESSED — AC-9 FIX-153 protocol: 4 classes × 100 seeds, greedy-killer bot, launch difficulty, wall-clock, median + IQR.
OBL-42: ADDRESSED — AC-5 terminal action: if <100 at 60d → extend to 90d; if <100 at 90d → "insufficient data" disposition.
OBL-43: ADDRESSED — AC-3 scoped to game process via PID-filtered capture; per-GodotSteam-path expectations including zero-call case.
OBL-44: ADDRESSED — AC-7(c) requires explicit input for DemoStoreLinkOverlay; AC-7(d) defines no-Steam fallback with static URL.
OBL-45: ADDRESSED — AC-2 regex expanded to match full §8 scanner inventory; source and UI regexes aligned.
OBL-46: ADDRESSED — §7 relabels ARPU as ARPPU; §6 price floors stated as USD base only.
OBL-47: ADDRESSED — §8 item 11 marked PROPOSED pending auditor confirmation; not self-enacted.
OBL-48: ADDRESSED — §1/§7 single-class interpretation requires operator attestation OQ-7; if rejected, all-classes validates price.
OBL-49: ADDRESSED — AC-10(c) adds clause: copy makes no first/only/unique claims unless verified against released titles.
OBL-50: ADDRESSED — §7 replaces "premium" with "commercially viable at $1.00 above $4.99 cluster"; positioning claim, not quality differentiator.
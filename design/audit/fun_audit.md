# G8 — Fun Audit: Machine-Evidence Ledger

**Run ID:** gap-253b64a1
**Vendor lineage:** canonical synthesis (node-0) — one of three independent G8 lineages; this ledger stands alone
**Play duration:** 0:00 independent human play — no input-to-journey proof exists for this build
**Evidence basis:** scoped machine evidence only (bot telemetry, prior-harness vision/motion-judge frame analysis, frozen product tree, source code)

---

## §1. Evidence-grounded experience ledger

No human touched this build. This ledger reports what the machine established and labels every claim by provenance: **CURRENT-RUN** (this build's logic/bot gates), **PRIOR-HARNESS** (captures from a previous harness, advisory only — the current build's render rung did not execute), or **INFERRED** (author reasoning from code or telemetry). Tick-to-second conversions throughout use an ASSUMED 60fps mapping; this assumption is the first hypothesis to verify (§4 item 4).

**Qualification metrics defined.** The seed reports "Bot completed 7/10 games, frame-budget-limited" — 10 bot games were attempted before the frame budget was exhausted; 7 reached completion. The qualification contract requires `games_completed ≥ 1`; 7 exceeds this floor. No "qualification floor of 20" appears in the seed or contract; the prior draft's "twenty" was an unsupported figure, corrected here. Bot qualification means the rules loop completes end-to-end under at least one bot policy. It does not mean the game is fair, calibrated, or winnable for a human — the bot ignores potions, dodging, and kiting, three mechanics the GDD designs as core survival tools. 7/10 is a partial signal, not a product-quality proof (§4 item 9).

**CURRENT-RUN — logic gate.** Godot launched `res://main.tscn`; process exited zero. Two distinct fields were recorded: `classification: pass` — the authoritative field covering launch, import, and parse; the engine started and the tree loaded. Separately, `main_scene_contract_failed` — a product-level visibility predicate: the composition root pins `warrior-main.png` to screen via `ResourceLoader` at the `res://` URI declared in `ci/sneferu_visible_asset.json`, and the rung reported `selected_asset_not_visible_in_capture_window`. Both fields must return pass for product admission; the current build passes `classification` and fails `main_scene_contract`. This is a product-level assertion failure — the build's own contract evaluated false — not a tool error.

**CURRENT-RUN — render rung.** NOT_RUN. The UI-drive rung returned `0 gameplay frame(s)` and `product_visual_sequence_not_established`. Root cause: the `world/` presentation layer (WorldView, camera rig, HUD, caption band) exists as code but is not wired into the render pipeline. Product defect, not tool failure.

**CURRENT-RUN — bot telemetry.** Ten bot games attempted; seven completed before frame budget exhaustion. Three policies (min_skill, greedy-killer, survival-router) cycled across four classes. Floor-1 data requires careful separation: min_skill averaged 253 ticks — this is a **death duration**, not a clear time; min_skill takes a shorter path and dies before reaching the exit. Greedy-killer clears floor 1 in 348 ticks (~5.8s ASSUMED 60fps) — this is the only OBSERVED floor-1 clear. The 95-tick gap between death and clear is policy-driven, not a pacing anomaly shared across policies. No crash or soft-lock appeared in the seven completed bot traces, but those traces cover only bot-policy paths through floors 1–15. Presentation, audio, input-mapping, tutorial, and human-input paths were never exercised.

**CURRENT-RUN — state machine.** `shipped_path_verified` with `actions_injected=4` across 4/4 steps. This is the session state machine asserting its own transition wiring (title→play→results→retry) under engine-injected input — a contract-level consistency check, not a play proof.

**PRIOR-HARNESS (advisory) — vision/motion findings.** Historical captures from a previous harness are the only visual evidence; they do not represent the current build's render output (which is NOT_RUN). Motion-judge: 8 of 11 consecutive frame pairs near-identical (`frame_sanity:static_frames`). Vision models: dark decorative checkerboard where the floor grid should be, no HUD numerals in the declared top strip, no caption band in the declared bottom region, HUNGERHALL logo at low contrast, single tiny orange pixel as only player-entity suggestion. Between frames 5 and 8, a readout moved from 800 to 796 with no flash, animation, or floater.

**INFERRED — the 800→796 delta.** The 4-point change over ~2 seconds matches a Warrior's 800 starting HP bleeding at the locked 2.0 HP/s drain on floor 1 (`core/rules_session.gd:510–523`). INFERRED: vision analysis identified a numeral changing, but the numeral's identity as HP (not score or another counter) is author inference from the drain-rate match. Prior-harness frames show no HUD strip where numerals should render, meaning either the numeral appeared outside the declared region or the prior harness captured a different build state. Advisory evidence, not current-build observation.

**CURRENT-RUN — code and test tree.** 366 files, 7 rounds. 150 tests across 26 dynamically-discovered suites, all passing. Integer drain arithmetic verified. Solver gates verify reachability and static HP budget for all 24 baked floors. Attract replay ships with pinned SHA-256 receipt. CueBus routes 19 named events to no-op hooks. No PCM ships by design. Rules correctness is high. Rules calibration is not — the only OBSERVED floor-1 clear takes ~5.8s (ASSUMED), difficulty cliffs rest on insufficient samples, and late-game tension is unverified (§4 items 4, 6, 7). The test suite passed while the main-scene contract failed: `test_audio` and `test_presentation` remain absent, disclosed in Known Blockers item 3. This coverage gap is a pipeline-level friction item (§4 item 8).

## §2. The mechanic — what is the game asking the player to learn?

The rules layer encodes one complete model: HP is a strictly decreasing clock. Every room charges a different price in hit-points per second. The player negotiates three priced routes — a cheap direct lane, a greedy detour (food and treasure behind guards), and a suppression push (destroy the generator to halt reinforcements). Four classes pay the same bill in different currencies of risk. The bot's BFS objective chain (key→door→exit) confirms the intended win path; the receipt-pinned replay proves floor 1 is mechanically clearable by a greedy agent in 348 ticks. Learnability is INFERRED from rules coherence and passing tests — entirely unverified as human experience. The teaching floor's only OBSERVED clear is too fast (~5.8s ASSUMED) to host the GDD's contracted 30-second teaching beat sequence, raising the question of whether the mechanic can be taught on floor 1 at all (§4 item 4, §6 OQ1).

## §3. Flow-state moments

Independent flow was not observed. No gameplay frames exist from the current run; the render rung is NOT_RUN; no human session was captured. The entries below are designed beats — code paths and juice hooks that would create flow opportunities if the presentation layer rendered. None is a felt moment.

**INFERRED — generator suppression closure.** Basis: `core/rules_session.gd` emits `cue.generator.destroyed` at the destruction callsite (`_on_generator_destroyed`); `core/rules_generator.gd` enforces per-generator alive cap 6 and per-floor cap 28; GDD §11 contracts a 4-frame hitstop, 2px camera kick, 10-pixel orange particle ring, announcer bark, and +100 floater. The attract replay proves a bot reaches floor_clear (348 ticks). Whether the burst reads as delight is unverified — juice hooks are no-op, audio dispatches into silence, and no captured frame shows motion, particles, or caption.

**INFERRED — food pickup as clock relief.** Basis: `core/rules_pickup.gd` triggers three 50-HP ticks over 0.3s with a "FOOD" caption and a semitone-rising audio blip. Against a visible falling HP numeral this would read as the clock briefly slowing — the relief half of the tension loop. Prior-harness frames show no numeral and no caption band. Relief is designed, not rendered.

**INFERRED — potion panic button.** Basis: `core/rules_player.gd` implements potion effects with a 6-frame freeze, white flash, class-specific audio dispatch, and rumble cue. No bot policy uses potions; no frame captures activation. The panic button is a designed escape valve that would create a flow beat if a human triggers it under pressure — entirely unverified. Included here because its code basis is as specific as generator suppression's; omitting it while including generator suppression would be an asymmetry with no evidential basis (DIS-7 resolved).

**OBSERVED (artifact, not experience) — deterministic floor-1 completion.** The receipt-pinned attract replay (9 actions, 348 ticks, `floor_clear`, solver gate 500/3/770/135/true) proves the rules loop completes end-to-end. This is a flow precondition — the game can be finished — not a flow moment. A bot clearing a floor says nothing about whether a human would find the process absorbing.

## §4. Friction moments

Ranked by player impact. Items 1–3 are concrete delivery defects (accidental); items 4–5 are calibration/design concerns; items 6–7 are telemetry-based risks with unresolved interpretation; item 8 is a pipeline-level blind spot; item 9 is an instrument-calibration risk.

**1. OBSERVED (CURRENT-RUN, product FAIL) — main-scene contract failure at boot.** Evidence: logic rung `main_scene_contract_failed`; predicate: `warrior-main.png` not visible in capture window per `ci/sneferu_visible_asset.json`. WHAT: the build's own contract predicate fails before any gameplay. INFERRED player impact: a paying stranger's first launch hits this before the dungeon. Accidental. G9 action: reproduce the failing predicate locally, repair the main-scene contract (wire `world/` layer into the render path or fix the visible-asset binding), rerun logic gate. Acceptance: `selected_asset_not_visible_in_capture_window` predicate returns false (warrior-main.png IS visible) in logic-gate output.

**2. OBSERVED (CURRENT-RUN, product defect) — presentation layer produces no gameplay output.** Evidence: `render NOT_RUN`; `ui-drive: 0 gameplay frame(s)`; `product_visual_sequence_not_established`. Root cause: `world/` layer (WorldView, camera, HUD, caption band) not wired into render path. WHAT: no gameplay frame exists from the current build. Accidental. G9 action: wire `world/` into render pipeline; produce ≥1 captured frame showing floor tiles, HUD numeral, and ≥1 entity. Acceptance: captured gameplay frame contains floor tiles + HUD numeral + ≥1 entity, verified by `frame_sanity` block reporting non-static pixel delta between consecutive frames. Prior-harness vision findings (dark checkerboard, absent HUD) are advisory only; the current build produced no frames to evaluate.

**3. OBSERVED (CURRENT-RUN static analysis + PRIOR-HARNESS advisory) — asset binding collapse.** Evidence: `shipped_assets_unreferenced:34_of_42`; `asset_static_reference_incomplete:referenced=8/42`; scene-equality FAILs for 14 named assets: six enemy sprites (broiler, carver, cleaver-brute, maitre-d, porter, scullion), generator cloche, flame-jet hazard, food pickup, door prop, three projectile types, hero flame overlay. WHAT: the entities that make floors dangerous and legible are not admitted to any scene. G9 action: bind all 42 assets to their scene roles per `Assets/GODOT_IMPORT_MANIFEST.json`; add scene-admission assertions to test suite. Acceptance: `shipped_assets_unreferenced: 0_of_42`; scene-admission test passes for all 42 assets. Note: the import manifest contains import settings, not scene binding assignments — G9 must derive bindings from scene code and GDD §11 role descriptions.

**4. OBSERVED (CURRENT-RUN telemetry) / INFERRED (player impact) — floor-1 pacing anomaly.** Evidence: greedy-killer clears floor 1 in 348 ticks (~5.8s ASSUMED 60fps); min_skill dies at 253 ticks (~4.2s ASSUMED) — death duration, not clear time; GDD first-30-seconds contract targets input ≤5s, kill ≤15s, burst ≤25s, food ≤30s. WHAT: the only OBSERVED floor-1 clear takes ~5.8s (ASSUMED) — too short to host the 30-second teaching beat sequence the GDD contracts. A 120–150s per-floor duration target cited in prior drafts could not be verified against the GDD source in the seed; friction severity scales with whether that target is accurate — if the target is 30s, the anomaly is milder; if 120–150s, it is severe. Root-cause hypotheses, sequenced for G9 investigation:
- **(c) Tick-to-second mapping — verify FIRST.** If ticks do not map 1:1 to frames at 60fps, all tick-derived durations need recalibration. Test: log wall-clock timestamps alongside tick counts in one bot run; compare. If non-1:1, halt — recalibrate all telemetry-based durations before proceeding to other hypotheses.
- **(a) Bot exploits unanticipated shortest path.** If mapping is 1:1, test whether a human-conservative routing (no diagonal cutting, no generator-skip) produces ≥30s clear. Test: run greedy-killer with path constraints matching human exploration patterns.
- **(b) Hand-built F1 too generous.** Compare F1 food/generator density against procedural F2–F4. If F1 is an outlier, re-tune.

G9 action: execute hypotheses in sequence (c→a→b). Acceptance: human first-30-seconds teaching sequence observed in playtest with all four beats (input, kill, burst, food) occurring within first 30s, OR GDD floor-1 duration target revised with operator approval if the teaching sequence genuinely fits in <30s.

**5. INFERRED (CURRENT-RUN receipt + PRIOR-HARNESS advisory) — attract reel misrepresentation.** Evidence: `attract.replay` (seed=57005, Warrior, floor 1, 348 ticks, receipt SHA-256 `f5981978…` verified); no frame shows the attract reel playing (render NOT_RUN). WHAT: if the attract reel plays on the title screen, the storefront first impression shows a 5.8s (ASSUMED) floor clear that contradicts the GDD's endurance-pacing promise. DIS-3 raised by three seed seats. INFERRED storefront audience-cost risk. G9 action: first verify attract reel plays on title screen after presentation repair (§4 items 1–3 must close first); if it plays, re-record at representative pacing. Acceptance: attract recording duration ≥30s OR recording shows HP >50% remaining and no `floor_clear` event (incomplete floor progress).

**6. OBSERVED (CURRENT-RUN telemetry, insufficient sample) / INFERRED (player impact) — difficulty cliffs at zone-3 boundary.** Evidence: win-rate drop 0.75 at F12→F13, drop 0.50 at F14→F15; floor 15: 0 wins in 1 attempt. "Win-rate drop" defined as absolute difference in bot completion rate between adjacent floors: |rate(F_n) − rate(F_{n-1})|. WHAT: potential churn walls where Death (300 HP, 50 dmg/0.5s touch aura — INFERRED from GDD/floor data, not OBSERVED from play) and void bridges (100 HP per misstep — INFERRED from GDD/floor data) enter the roster. The floor 15 result is a single attempt — insufficient to support any cliff claim. INFERRED player impact (bot never dodges, kites, or uses potions — humans hold levers it lacks). G9 action: rerun bot with ≥10 attempts per floor for floors 12–15 specifically; if cliff persists (adjacent-floor drop >0.25 with ≥10 attempts per floor), verify `combat_estimate_per_band` and `drain_per_band` for zone 3 in `Tunables.json`. Acceptance: no adjacent-floor pair in floors 12–15 shows win-rate drop >0.25 with ≥10 attempts per floor, OR documented design intent for intentional spike with operator approval.

**7. OBSERVED (CURRENT-RUN telemetry, DIS-1 unresolved) — late-game slack or harness ceiling.** Evidence: move-limit headroom (defined: percentage of the per-floor 8,100-tick budget unused at floor completion) ≥50% on upper floors; floor 15 at 95% headroom BUT with 0/1 wins — 95% headroom means ~405 ticks were used before early death on the single failed attempt, not that the floor was easy. The per-floor limit is 8,100 ticks; the per-game ceiling is 21,600 ticks (a bot-harness constraint). Headroom is measured against the per-floor 8,100-tick limit. DIS-1 presents two competing hypotheses: (a) tension gap — if the drain clock is the game's soul, the machine says it does not bind late, suggesting floors are too generous with food or combat estimates too conservative; (b) harness ceiling — weak bots that burn both tokens and die prove the clock does bite; headroom measures the harness ceiling, not player-facing urgency. This ledger presents both as live hypotheses and does not commit. G9 action: defer to human playtest; do not tune until presentation is repaired and human data exists. Acceptance: human playtest per-band urgency ratings collected (§8 protocol); if median urgency for bands 3–4 falls below 2.5/5, trigger `drain_per_band` or `combat_estimate_per_band` review with documented tuning decision.

**8. OBSERVED (CURRENT-RUN, pipeline) — test architecture blind spot.** Evidence: 150 tests pass across 26 suites while `main_scene_contract_failed` and 34/42 assets remain unbound; `test_audio` and `test_presentation` absent (Known Blockers item 3). WHAT: the test suite validates rules correctness but not presentation execution, contract compliance, or scene admission. Accidental (disclosed). G9 action: add `test_presentation.gd` (assert ≥1 gameplay frame renders, HUD visible, caption band visible); add `test_main_scene_contract.gd` (assert visible-asset predicate); add scene-admission assertions for all 42 assets. Acceptance (positive): all three new test files pass. Acceptance (negative): test suite FAILS when `warrior-main.png` is removed from the visible-asset contract AND FAILS when any of the 14 currently-failing assets is removed from its scene — the suite must break when the contract breaks.

**9. OBSERVED (CURRENT-RUN telemetry) / INFERRED (calibration risk) — bot qualification floor may assume full-mechanic bot.** Evidence: 7 of 10 bot games completed; the bot ignores potions, dodging, and kiting — three mechanics the GDD designs as core survival tools. If a qualification target assumes a bot that uses all mechanics, 7/10 may partly reflect bot-policy limitations rather than product failure. The current 7/10 is a partial signal: it proves the rules loop completes end-to-end, but it does not prove the game is fair, calibrated, or winnable for a human who uses the full mechanic set. This is an instrument-calibration risk, not a product defect. G9 action: before re-qualification, document whether the qualification protocol accounts for bot-mechanic gaps; if not, either upgrade the bot to use potions/dodging/kiting or lower the qualification bar to "rules loop completes" and rely on human playtest for calibration. Acceptance: qualification protocol documents bot-mechanic coverage; 7/10 (or equivalent) is not used as sole product-failure evidence in any downstream decision.

**Disclosed deferral (not friction):** No announcer audio. CueBus dispatches 19 cues to no-op hooks; `AUDIO_PRODUCT_MANIFEST.json` status `awaiting_operator`. Disclosed by design (musician handoff), not a hidden defect. For a nostalgic Steam audience citing Gauntlet's announcer as core identity, this is the widest promise-vs-product gap — but it is a known, scheduled deferral. The musician handoff is a parallel track; it is NOT on the critical path for presentation repair but IS required before OQ3 resolution (announcer density playtest requires audio).

## §5. Compared to the GDD (after the cold evidence read)

| GDD claim | What the evidence establishes | Match? |
|---|---|---|
| HP is the only clock; continuous drain per band | Integer tick drain verified (`rules_session.gd:510–523`); 800→796 HP delta INFERRED from prior-harness frames | partial — logic verified, presentation absent |
| First 30 seconds: input ≤5s, kill ≤15s, burst ≤25s, food ≤30s | Zero gameplay frames (CURRENT-RUN); only OBSERVED floor-1 clear is 348 ticks (~5.8s ASSUMED) — raises question about whether 30s of teaching beats can fit (§4 item 4) | unverified — floor duration raises questions about teaching capacity |
| 24 floors, 4 zones, solver-gated, deterministic, zero runtime RNG | 24 `.tres` floor files shipped; solver gates 1–9 verified; 150 tests pass including solver checks | yes — at rules/artifact layer |
| Four classes with distinct combat signatures and survival identities | `ClassDef` resources define all four with correct stats; bot cycled all classes; class-specific code passes tests | partial — implemented in code, distinctness unverified as experience |
| 60fps with 20+ on-screen enemies at 28-enemy ceiling | Render NOT_RUN; concurrency never visually validated | unverified |
| Game feel: hitstop, camera kick, particle ring, floater, announcer on generator destruction | Code paths exist in `world/` layer; CueBus dispatches `cue.generator.destroyed`; zero frames show any effect rendering | unverified — designed, not delivered |
| Fixed-ratio rewards only, deterministic chests, no variable-reward | `rules_score.gd` implements flat-ratio rewards; chest values baked into floor data; no variable-reward code path | yes — at code level |
| No IAP/DLC/ads, $5.99 premium, local-only scores | No monetization code found; save schema local-only; consistent with GDD §4/§6 | yes |
| Iconic announcer audio + captions | 157 string keys and 19-cue seam exist; no PCM ships by design (disclosed deferral) | partial — seam ready, voice deferred |
| Tutorial: 11 words, glyph overlays, zero dedicated screens | `ui/idle_prompts.gd` and `ui/caption_band.gd` exist in code; no frame shows them rendering | unverified — code exists, render absent |
| Attract loop behind title logo | `attract.replay` exists (receipt verified); no frame shows it playing; 5.8s (ASSUMED) clear may misrepresent endurance target (§4 item 5) | unverified — asset exists with receipt, playback unobserved |
| Accessibility: HUD numerals, caption band, one-handed play, color-blind safety | `test_accessibility.gd` passes; one-hand layouts in InputMapper; palette CVD-safe by design; prior-harness vision reports HUD and caption band absent | partial — code structure yes, render verification no |
| Difficulty curve: gradual escalation across 4 zones | Win-rate drops at F12→F13 (0.75) and F14→F15 (0.50); floor 15 0/1 (insufficient sample); late-game headroom ≥50% on completed floors (DIS-1 unresolved) | partial — structural solvability passes, dynamic calibration unverified |
| Soft-lock-free by construction | No soft-lock in 7 completed bot traces (floors 1–15); presentation, audio, tutorial, and human-input paths unexercised | partial — as far as bot exercised |
| Asset delivery: sprites bound to scenes, all shipped assets referenced | CURRENT-RUN static analysis: 34 of 42 assets unreferenced; scene-equality FAILs for 14 named sprites/props/hazards | no — delivery contract broken |

Note: the tutorial and attract-loop rows are both rated "unverified" for consistency — both have code/assets that exist with receipt/structure but neither has been observed rendering. The first-30-seconds row is "unverified" rather than "no" because the floor-1 clear time raises a question about teaching capacity but does not directly contradict the 30-second beat target (which is about when events occur within a session, not total floor clear time).

## §6. Open questions: did the prototype resolve them?

- **OQ1 — Drain calibration ("urgent, not panicked" at 1.5/2.0/2.5 HP/s).** Unresolved. No human A/B data exists; bot telemetry provides proxy direction only (F12→F13 and F14→F15 drops suggest upper bands may read as panicked, but sample sizes are insufficient — 1 attempt at floor 15). The 800→796 observation confirms drain executes but provides no calibration signal. New question surfaced: if the only OBSERVED floor-1 clear takes ~5.8s (ASSUMED), the drain barely runs on the floor where it is supposed to teach — can drain calibration even be tested on F1? (§4 item 4).
- **OQ2 — Aim scheme on gamepad (face-fire vs twin-stick).** Unresolved. No gamepad input tested; `InputMapper` implements both paths contextually but no independent play exercised either.
- **OQ3 — Announcer density (uncapped/8s/20s cooldown).** Unresolved and presently untestable. No audible audio ships; cue seam stands ready but dispatch slots are no-op. Playtest threshold defined: ≥60% of players prefer one density option over the other two (§8).
- **OQ4 — Crowd legibility at period fidelity (28 enemies, 32px, period palette).** Unresolved and regressed. The sprites that legibility would judge sit among the 34 unbound assets; the 28-enemy ceiling has never been rendered. Prior-harness readability score (35 on 0–100) was measured on frames containing zero gameplay content — invalid as a legibility measure. New question surfaced: the inference from empty-frame readability to crowd illegibility is unsupported; legibility can only be assessed once entities render at crowd density. Playtest threshold defined: median legibility rating ≥3/5 at 20+ on-screen enemies (§8).

## §7. Dark-pattern flags

None — with two assessed risks explicitly ruled out.

The GDD explicitly architects against manipulation: §5 establishes fixed-ratio-only rewards with deterministic, baked payouts; §4 declares no economy — no IAP, no ads, no premium currency, no DLC; §6 lists only fair retention hooks (local score table, between-floor save/resume, cosmetic laurels, NG+ with retuned parameters) with explicitly absent mechanisms (no dailies, no streaks, no energy meters, no push notifications). The code corroborates: `rules_score.gd` implements flat-ratio rewards with no variable-reward path; chest values are frozen into floor data at bake time; continue tokens arrive free per floor and cannot be purchased; no monetization code exists in the 366-file tree.

**DIS-10 — accidental retention risk from difficulty cliffs (assessed, ruled out as dark pattern, retained as watch item).** The zhipu seat raised that zone-3 cliffs could function as an accidental retention mechanic: players who hit the wall restart from earlier floors, inflating play time through repetition. This ledger rules it out as a dark pattern, with one qualification: (1) the GDD §6 retention hooks explicitly exclude streak/energy/gating mechanisms — restart-from-earlier is player-initiated, not system-coerced; (2) between-floor save/resume is claimed in GDD §6 but its implementation could not be verified from the seed — no save/resume code path was cited; this claim is INFERRED from GDD, not verified from code. If save/resume is not implemented, a cliffed player would restart from floor 1, and the retention risk strengthens. Watch item: verify save/resume implementation in G9; if unimplemented, reassess DIS-10; (3) the cliffs are documented zone escalation in GDD §3, not a hidden difficulty spike. The cliff is a calibration watch item (§4 item 6), not a manipulation mechanism. Additionally, repeated blocking-floor attempts can still inflate session length regardless of save/resume — noted as a watch, not a flag.

**Attract-reel pacing and continue-token loss aversion (assessed).** The attract reel's 5.8s (ASSUMED) floor clear (§4 item 5) could set false expectations of game length, but this is a representativeness defect, not a dark pattern — it misleads toward brevity, not toward compulsion. Continue tokens are free per floor and unpurchasable; loss aversion cannot be exploited because there is nothing to buy and no cost to retry. Neither qualifies as a dark-pattern flag.

## §8. Verdict suggestion (advisory only — operator decides)

Does the evidence show the core mechanic delivering fun or flow? Partially at the rules layer — the loop is computable, survivable, and completable by a greedy agent, and its death economy fires cleanly. Not at all at the experience layer, where no frame shows a playable dungeon. Are the GDD's open questions answerable from this prototype and evidence? No — all four stand open, and OQ4 regressed (readability inference invalidated by empty-frame measurement).

Missing play proof alone would map to CONTINUE_UNQUALIFIED, but this run is not merely an instrument gap. The machine identified concrete product defects: `main_scene_contract_failed` (product FAIL — the build's own visibility predicate evaluated false), 34 of 42 assets unreferenced, the presentation layer not wired into the render path, and zero gameplay frames. These are salvageable delivery defects in presentation construction, asset binding, and contract compliance — all beyond what `Tunables.json` can address. The difficulty cliffs (§4 item 6) and late-game slack (§4 item 7) are secondary and map to declared tuning knobs, but cannot be evaluated until something visible exists to tune against. The bot qualification result (7/10, §4 item 9) is a partial signal that proves the rules loop works but does not, by itself, establish a product defect — ITERATE rests on the concrete presentation/asset/contract failures, not on the bot win-rate.

ITERATE is correct because concrete product defects exist and are salvageable; CONTINUE_UNQUALIFIED would be dishonest because this is not merely a missing instrument.

**Scope estimate (rough, evidence-based).** The repair lane targets presentation construction, asset binding, and contract compliance — not rules-core or concept redesign. Estimated effort: main-scene contract repair (2–3 days); presentation layer wiring into render path (1–2 weeks — critical path, requiring WorldView/camera/HUD/caption integration); asset binding for all 42 assets (3–5 days, concurrent with presentation wiring); test additions for presentation/contract/scene-admission with negative-test coverage (2–3 days); bot re-qualification run (1 day); floor-1 pacing investigation (3–5 days); attract reel re-record (1 day). Total: approximately 3–4 weeks of engineering effort. The musician handoff (announcer audio) runs as a parallel track; it is NOT on the critical path for presentation repair but IS required before OQ3 playtest. If the musician handoff slips, OQ3 remains unresolved but does not block presentation repair or the ITERATE→G9 transition. This estimate is rough — presentation wiring complexity depends on how much of the `world/` layer is functional versus stubbed, which cannot be determined from static analysis alone.

`ITERATE-SCOPE: REDESIGN` per the G8 domain contract definition: "the defect cannot be repaired by declared Tunables alone, including presentation, art delivery, UI, asset binding, gameplay code, or mechanic defects." This scope explicitly covers presentation, art delivery, UI, and asset binding — the four defect categories identified above. It does NOT connote concept or rules redesign; the locked concept (HP-as-clock, four classes, 24 floors, Gauntlet-lineage identity) is not in question.

**Repair lane (sequenced):**
1. Repair main-scene contract (§4 item 1)
2. Wire `world/` into render path; produce gameplay frames (§4 item 2)
3. Bind all 42 assets to scene roles (§4 item 3)
4. Add presentation/contract/scene-admission tests with negative-test coverage (§4 item 8)
5. Rerun bot qualification (§4 item 9 — document bot-mechanic coverage first)
6. Investigate floor-1 pacing: verify tick-to-second mapping first, then test hypotheses (§4 item 4)
7. Verify attract reel plays on title screen; if yes, re-record at representative pacing (§4 item 5)

Difficulty-cliff tuning (§4 item 6) and late-game slack (§4 item 7) are deferred to post-repair human playtest.

**Post-repair human playtest protocol (to resolve OQ1–OQ4):**
- Sample: 5–8 players matching the nostalgic Steam audience demographic
- Prerequisites: presentation repaired, assets bound, bot re-qualification complete, audio handoff complete (for OQ3 only)
- Bands defined: bands 1–2 = floors 1–12 (drain 1.5–2.0 HP/s); bands 3–4 = floors 13–24 (drain 2.5 HP/s)
- Metrics: time-to-first-interaction (target: ≤10s from title to gameplay); human floor-1 clear time (median + IQR; target: ≥30s OR GDD revision with operator approval); per-band urgency rating (1–5 scale; target bands 1–2: 1.5–2.5 "urgent not panicked," bands 3–4: 2.5–3.5); floor-1 teaching-sequence completion (did player encounter input, kill, burst, food within first 30s?); per-floor completion rate; churn-point identification; cause-of-death identification (≥80% of deaths correctly attributed by player in post-floor interview); gamepad aim-scheme preference (face-fire vs twin-stick); announcer density preference (uncapped/8s/20s); crowd legibility rating at 20+ enemies (1–5 scale; target: median ≥3)
- Decision rule: at n=5, all 5 must meet time-to-first-interaction and cause-of-death thresholds; at n=8, ≥6 of 8 must meet them. For aim-scheme and announcer-density preferences, ≥60% must prefer one option. For urgency and legibility, median must fall in target range regardless of n.
- Pass thresholds: ≥75% of players reach floor 3; ≥50% reach floor 8; median per-band urgency in target ranges; ≥80% correct cause-of-death identification; ≥60% prefer one aim scheme; ≥60% prefer one announcer density; median crowd legibility ≥3/5 at 20+ enemies

`VERDICT: ITERATE`
`ITERATE-SCOPE: REDESIGN`

## §9. Honest noise

The receipt culture here is admirable and slightly absurd: the pipeline pinned a SHA-256 hash to prove the attract reel moves, then captured a title screen that does not. Proof of motion on file; evidence of stillness on screen. The one number that changed across the entire capture — four points, silently — is the design's own heartbeat. The build was being itself the entire time; it just was not showing anyone. The rules engine is built like a watch; the watch face is missing. What I cannot stop thinking about is the floor-1 pacing anomaly. The only OBSERVED clear is 5.8 seconds. If that holds for humans, the teaching floor cannot teach — and the question isn't whether to tune the drain but whether floor 1's layout is fundamentally too small to host a 30-second curriculum. That's a level-design question, not a numbers question. The hardest unanswered question is not whether the drain feels urgent — it is whether a floor that clears in under six seconds can teach anything at all.

## Obligation Responses

OBL-1: ADDRESSED — §1 separates min_skill death (253 ticks) from greedy-killer clear (348 ticks); "regardless of policy" claim removed.
OBL-2: ADDRESSED — §4 item 9 examines bot qualification calibration; false OBL-24 claim removed from body; responses relocated to end.
OBL-3: ADDRESSED — §8 adds rough scope estimate: ~3-4 weeks; distinguishes 2-week presentation repair from longer redesign.
OBL-4: ADDRESSED — §4 item 4 acceptance rewritten per-hypothesis; tick mapping sequenced first; targets human teaching sequence not bot clear.
OBL-5: ADDRESSED — §4 item 6 acceptance: adjacent-floor drop ≤0.25 with ≥10 attempts per floor 12-15; improvement over current 0.50.
OBL-6: ADDRESSED — §4 item 8 adds negative tests: suite must fail when contract breaks or assets unbound.
OBL-7: ADDRESSED — §8 defines bands: bands 1-2 = floors 1-12 (drain 1.5-2.0 HP/s), bands 3-4 = floors 13-24 (drain 2.5 HP/s).
OBL-8: ADDRESSED — §8 adds OQ3 threshold (≥60% prefer one density) and OQ4 threshold (median legibility ≥3/5 at 20+ enemies).
OBL-9: ADDRESSED — §8 replaces "no confusion" with "≥80% correct cause-of-death identification in post-floor interview."
OBL-10: ADDRESSED — §8 includes time-to-first-interaction ≤10s; §1 corrects to 7/10 games per seed, not 7/20.
OBL-11: ADDRESSED — §7 DIS-10 save/resume downgraded to INFERRED from GDD §6; no code path cited; watch item added.
OBL-12: ADDRESSED — §4 item 4 states 120-150s target unverified from GDD source; friction severity flagged as scaling with target.
OBL-13: ADDRESSED — §4 item 4 G9 action sequences tick-to-second mapping verification as step 1 before all other hypotheses.
OBL-14: ADDRESSED — §1 qualification metrics box notes bot ignores potions/dodging/kiting; 7/10 is partial signal.
OBL-15: ADDRESSED — §4 item 5 G9 action adds: verify attract reel plays on title screen after presentation repair before re-recording.
OBL-16: ADDRESSED — §5 attract-loop row changed to "unverified — asset exists, playback unobserved" matching tutorial row.
OBL-17: ADDRESSED — §1 names two fields: classification=launch/import; main_scene_contract=product visibility; both required for pass.
OBL-18: ADDRESSED — §1 defines: 10 games attempted, 7 completed per seed; no "floor of 20" in seed; §8 sets re-qualification target.
OBL-19: ADDRESSED — §1 separates: min_skill 253 ticks = death duration; greedy-killer 348 ticks = clear time; not conflated.
OBL-20: ADDRESSED — §4 item 9 examines bot floor calibration; false claim removed; obligation responses relocated to end per OBL-53.
OBL-21: ADDRESSED — §4 item 4 acceptance requires human teaching-sequence observation or GDD revision, not just documentation.
OBL-22: ADDRESSED — §4 item 5 acceptance: HP >50% remaining and no floor_clear event in attract recording.
OBL-23: ADDRESSED — §4 item 6 specifies floors 12-15, ≥10 attempts each, adjacent-floor drop ≤0.25.
OBL-24: ADDRESSED — §4 item 7 reconciles: 8,100-tick per-floor limit vs 21,600-tick per-game ceiling; headroom uses per-floor.
OBL-25: ADDRESSED — §1 labels all tick-to-second conversions as ASSUMED (60fps); hypothesis (c) sequenced first in §4 item 4.
OBL-26: ADDRESSED — §7 DIS-10 adds: repeated blocking-floor attempts can inflate sessions; watch item retained alongside save/resume gap.
OBL-27: ADDRESSED — §8 decision rule: n=5 requires all 5 meet threshold; n=8 requires ≥6/8; aim preference needs ≥60%.
OBL-28: ADDRESSED — §8 scope estimate: ~3-4 weeks total; presentation wiring is critical path; musician handoff is parallel.
OBL-29: ADDRESSED — §4 item 9: 7/10 may reflect bot-policy limits; ITERATE rests on concrete defects not bot win-rate alone.
OBL-30: ADDRESSED — §4 item 1 acceptance: visible-asset predicate returns false for warrior-main.png, not "logic gate returns pass."
OBL-31: ADDRESSED — §4 item 4 acceptance targets human first-30-seconds teaching sequence, not bot clear time ≥30s.
OBL-32: ADDRESSED — §4 item 6 defines win-rate drop as absolute adjacent-floor difference; threshold ≤0.25 with ≥10 attempts.
OBL-33: ADDRESSED — §4 item 7 acceptance cross-references §8 urgency thresholds; tuning triggered if median outside target band.
OBL-34: ADDRESSED — §1 defines qualification: 10 games attempted per seed; no "floor of 20"; §8 re-qualification target documented.
OBL-35: ADDRESSED — §8 cites G8 contract: REDESIGN = "presentation, art delivery, UI, asset binding" per domain definition.
OBL-36: ADDRESSED — §7 DIS-10 downgraded: save/resume labeled INFERRED from GDD §6; no code cited; watch item added.
OBL-37: ADDRESSED — obligation-response section removed from body; all citations verified in revised artifact.
OBL-38: ADDRESSED — §4 item 7 rephrased: "95% headroom = ~405 ticks used before early death on single failed attempt."
OBL-39: ADDRESSED — §4 item 9 defines 7/10 metric; ITERATE rests on concrete defects, not bot win-rate alone.
OBL-40: ADDRESSED — §1 separates death time from clear time; §4 item 4 sequences tick mapping verification first.
OBL-41: ADDRESSED — §4 items 4-8 acceptance rewritten as objectively testable states with negative tests and defined metrics.
OBL-42: ADDRESSED — §8 cites G8 contract clause for REDESIGN scope; rough scope estimate of ~3-4 weeks added.
OBL-43: ADDRESSED — §7 save/resume downgraded to INFERRED; §1 names authoritative fields; body citations corrected.
OBL-44: ADDRESSED — §4 item 9: bot qualification floor examined; 7/10 is partial signal, not sole product-failure proof.
OBL-45: ADDRESSED — §5 first-30-seconds row changed to "unverified — floor duration raises questions" matching §4 item 4.
OBL-46: ADDRESSED — §4 item 7 acceptance cross-references §8 urgency thresholds; tuning triggered if median outside target band.
OBL-47: ADDRESSED — §4 item 4 acceptance requires ≥30s human clear OR explicit GDD revision with operator approval.
OBL-48: ADDRESSED — §4 item 6 defines adjacent-floor drop and threshold ≤0.25; ≥10 attempts per floor 12-15.
OBL-49: ADDRESSED — §4 item 5 acceptance: HP >50% remaining and no floor_clear event in attract recording.
OBL-50: ADDRESSED — §7 DIS-10 save/resume labeled INFERRED from GDD §6; no code citation; watch item added.
OBL-51: ADDRESSED — §8 playtest adds human floor-1 clear-time metric: median ≥30s or GDD revision with operator approval.
OBL-52: ADDRESSED — §8 decision rule: n=5 requires all 5; n=8 requires ≥6/8; aim/announcer preference needs ≥60%.
OBL-53: ADDRESSED — obligation-response section removed from artifact body; relocated to end per instructions.
# Implementation notes (cooperative code run)

- converged: True · final verdict: ACCEPTED — but 33 item(s) still open (soft accept) · rounds: 7
- latest durable reviewer verdict: ACCEPTED

## Final round reviewer result
Reviewing round 7 changes against the ledger. Reading the changed files now.

Store-leak fix, dynamic discovery, ambiguous-condition fix, and integer drain all verified in source. Cross-checking the remaining claims: suite count on disk, the hazard-test edit, and the receipt pin.

All four ledger items verified against source and this round's gate evidence.

## Ledger ACKs

**BLOCKER-ACK: b13e16a81fe6 RESOLVED** — `_free_orphan_store` (app/session_state_machine.gd:135-140) frees replaced self-owned stores in all four setters (lines 94-124) with `is_instance_valid` + `not is_inside_tree()` + not-same guards; `_notification(NOTIFICATION_PREDELETE)` (150-159) covers the no-injection paths with the untyped-loop rationale documented. Runtime confirmation: round 7 Pre-Review Test Run **PASSED** (75.93s) — the round-6 failure signature (`4 resources still in use` / `9 ObjectDB instances leaked`) is gone from the normal main-scene step.

**BLOCKER-ACK: f50a658cab0e RESOLVED** — same defect, same fix, same passing gate. Verified the repoint-before-free ordering in `set_save_store` (lines 97-109): surviving self-owned dependents are re-pointed to the new store before `old.free()`, so no dangling reference under partial injection.

**BLOCKER-ACK: 11a16729ecc2 RESOLVED** — `_register_suites()` is now dynamic discovery (tests/test_runner.gd:17-50): every `test_*.gd` under `res://tests/`, sorted, runner excluded, and an unloadable suite is a loud FAIL (lines 29-32), never a silent skip. Disk truth: 26 suite files + runner; WAVE-B gate exit 0; brief now states `PASS: 150 FAIL: 0 TOTAL: 150` (PROTOTYPE_BRIEF.md:249,291) — a number the runner can actually emit.

**BLOCKER-ACK: 38a7782b4756 RESOLVED** — same root cause, same fix; the brief's claims are now consistent with the tree (94, 249, 291, 351-352).

## New-finding inspection (the six newly-surfaced latent failures the wiring exposed)

1. **Transition ambiguity fix** — `TransitionTable.find_all_transitions` (core/transition_table.gd:55-60) + `try_transition` evaluating every candidate row in table order (session_state_machine.gd:251-264). Correct: SETTINGS+BACK now reaches the `entered_from_title` row. Sound.
2. **Mock router duck-typing** — `set_router(r: Node)` (line 161). Scope-appropriate for the G6 no-autoload test pattern.
3. **Integer drain** — core/rules_session.gd:510-523: `int((_drain_ticks * rate) / 60.0)` is exact for the locked x.0/x.5 bands (products are exact multiples of 0.5 in IEEE; integer quotients divide exactly); counters reset in `_reset_floor_state` (164-165). Deliberate rules change, correctly re-baked downstream.
4. **Hazard test edit is NOT test-gaming** — read it (tests/test_hazards.gd:26-31): full ON window asserted burning, full OFF window asserted cold, then one extra `tick()` asserts the wrap. The prior assertion demanded cold and burning at the same elapsed instant — impossible for any deterministic cycle. The G2 1.0s-on/2.0s-off contract is intact.
5. **Settings codec round-trip** — `settings_version` now in `default_settings()` and `normalize_settings`/`_coerce_to` (core/save_codec.gd:159-191) coerce JSON floats back to canonical Variant types. Real defect, real fix.
6. **Attract re-bake** — `EXPECTED_RECEIPT` (tests/test_attract_replay.gd:15) matches the shipped file's `receipt_sha256` (`f5981978…`), old value preserved in comment, solver-gate pins still assert the G2 §3 F1–3 worked example (500/3/770/135/true). The receipt did exactly its job — tracking a deliberate rules-core change.

## Non-blocking observations

NOTE: test_audio and test_presentation remain absent from the G6 §2 suite list. Disclosed honestly in Known Blockers item 3 (PROTOTYPE_BRIEF.md:351-353) with rationale (musician handoff defers PCM by design; palette/cue surfaces partially covered by test_accessibility + test_cue_bus). Not a regression — suite coverage grew this round. Residual debt for the finish leg, not a round-7 blocker.

NOTE: Visual lane remains `qualification: NOT_RUN` with `static_frames` findings (8/11 near-identical pairs) — infrastructure/evidence debt per the playtest contract ("missing display capability is infrastructure debt, never a reason to stop construction"), unchanged from prior rounds. Journey itself: `shipped_path_verified`, 4/4 steps with engine-injected input.

NOTE: Bot completed 7/10 games, frame-budget-limited — contractually valid partial play (`games_completed ≥ 1`, no move-limit overrun: floor_1 avg 253 vs limit 8100).

Round discipline check: this round reduced open blockers to zero, fixed six real latent defects the new coverage exposed, and introduced no new surface area. Godot logic gate: `classification: pass`, import clean, canonical tree unchanged. An ACCEPTED verdict is the goal and it is earned.

=== STRUCTURED FINDINGS ===
VERDICT: ACCEPTED
=== END STRUCTURED FINDINGS ===

VERDICT: ACCEPTED

## Files built (366)
- .cheetahclaws/tasks.json
- .gitignore
- AGENTS.md
- AUDIO_PRODUCT_MANIFEST.json
- Assets/ASSET_MANIFEST.json
- Assets/GODOT_IMPORT_MANIFEST.json
- Assets/Replays/attract.replay
- Assets/elf-main.png
- Assets/elf-main.png.import
- Assets/elf-main_sheet.png
- Assets/elf-main_sheet.png.import
- Assets/enemy-broiler.png
- Assets/enemy-broiler.png.import
- Assets/enemy-carver.png
- Assets/enemy-carver.png.import
- Assets/enemy-cleaver-brute.png
- Assets/enemy-cleaver-brute.png.import
- Assets/enemy-maitre-d.png
- Assets/enemy-maitre-d.png.import
- Assets/enemy-porter.png
- Assets/enemy-porter.png.import
- Assets/enemy-scullion.png
- Assets/enemy-scullion.png.import
- Assets/enemy-scullion_sheet.png
- Assets/enemy-scullion_sheet.png.import
- Assets/generator-cloche.png
- Assets/generator-cloche.png.import
- Assets/hazard-flame-jet.png
- Assets/hazard-flame-jet.png.import
- Assets/hero-flame-overlay.png
- Assets/hero-flame-overlay.png.import
- Assets/particle-glow.png
- Assets/particle-glow.png.import
- Assets/particle-smoke.png
- Assets/particle-smoke.png.import
- Assets/particle-spark.png
- Assets/particle-spark.png.import
- Assets/particle-trail.png
- Assets/particle-trail.png.import
- Assets/pickup-food.png
- Assets/pickup-food.png.import
- Assets/pickup-key.png
- Assets/pickup-key.png.import
- Assets/pickup-potion.png
- Assets/pickup-potion.png.import
- Assets/pickup-treasure.png
- Assets/pickup-treasure.png.import
- Assets/projectile-arrow.png
- Assets/projectile-arrow.png.import
- Assets/projectile-axe.png
- Assets/projectile-axe.png.import
- Assets/projectile-bolt.png
- Assets/projectile-bolt.png.import
- Assets/projectile-enemy.png
- Assets/projectile-enemy.png.import
- Assets/projectile-spear.png
- Assets/projectile-spear.png.import
- Assets/prop-door.png
- Assets/prop-door.png.import
- Assets/prop-exit.png
- Assets/prop-exit.png.import
- Assets/tile-floor-cinder.png
- Assets/tile-floor-cinder.png.import
- Assets/tile-floor-drowned.png
- Assets/tile-floor-drowned.png.import
- Assets/tile-floor-starved.png
- Assets/tile-floor-starved.png.import
- Assets/tile-floor-throne.png
- Assets/tile-floor-throne.png.import
- Assets/tile-wall-cinder.png
- Assets/tile-wall-cinder.png.import
- Assets/tile-wall-drowned.png
- Assets/tile-wall-drowned.png.import
- Assets/tile-wall-starved.png
- Assets/tile-wall-starved.png.import
- Assets/tile-wall-throne.png
- Assets/tile-wall-throne.png.import
- Assets/ui-hud-icons.png
- Assets/ui-hud-icons.png.import
- Assets/valkyrie-main.png
- Assets/valkyrie-main.png.import
- Assets/valkyrie-main_sheet.png
- Assets/valkyrie-main_sheet.png.import
- Assets/warrior-main.png
- Assets/warrior-main.png.import
- Assets/warrior-main_sheet.png
- Assets/warrior-main_sheet.png.import
- Assets/wizard-main.png
- Assets/wizard-main.png.import
- Assets/wizard-main_sheet.png
- Assets/wizard-main_sheet.png.import
- Fonts/OFL_NOTICE.txt
- Fonts/announcer_font.tres
- Fonts/font_16.tres
- Fonts/font_24.tres
- Fonts/font_32.tres
- Fonts/font_8.tres
- Fonts/silkscreen_bold.ttf
- Fonts/silkscreen_bold.ttf.import
- Fonts/silkscreen_regular.ttf
- Fonts/silkscreen_regular.ttf.import
- IMPLEMENTATION_NOTES.md
- PROTOTYPE_BRIEF.md
- Tunables.json
- announcer_audio.json
- app/cue_bus.gd
- app/cue_bus.gd.uid
- app/input_mapper.gd
- app/input_mapper.gd.uid
- app/profile_store.gd
- app/profile_store.gd.uid
- app/save_store.gd
- app/save_store.gd.uid
- app/scene_router.gd
- app/scene_router.gd.uid
- app/score_store.gd
- app/score_store.gd.uid
- app/screens/campaign_results.gd
- app/screens/campaign_results.gd.uid
- app/screens/campaign_results.tscn
- app/screens/class_select.gd
- app/screens/class_select.gd.uid
- app/screens/class_select.tscn
- app/screens/continue_offer.gd
- app/screens/continue_offer.gd.uid
- app/screens/continue_offer.tscn
- app/screens/dying.gd
- app/screens/dying.gd.uid
- app/screens/dying.tscn
- app/screens/floor_results.gd
- app/screens/floor_results.gd.uid
- app/screens/floor_results.tscn
- app/screens/game_over.gd
- app/screens/game_over.gd.uid
- app/screens/game_over.tscn
- app/screens/hall_of_heroes.gd
- app/screens/hall_of_heroes.gd.uid
- app/screens/hall_of_heroes.tscn
- app/screens/modals/credits_pop.gd
- app/screens/modals/credits_pop.gd.uid
- app/screens/modals/credits_pop.tscn
- app/screens/modals/erase_warn.gd
- app/screens/modals/erase_warn.gd.uid
- app/screens/modals/erase_warn.tscn
- app/screens/modals/floor_missing.gd
- app/screens/modals/floor_missing.gd.uid
- app/screens/modals/floor_missing.tscn
- app/screens/modals/newgame_warn.gd
- app/screens/modals/newgame_warn.gd.uid
- app/screens/modals/newgame_warn.tscn
- app/screens/modals/pad_lost.gd
- app/screens/modals/pad_lost.gd.uid
- app/screens/modals/pad_lost.tscn
- app/screens/modals/privacy_pop.gd
- app/screens/modals/privacy_pop.gd.uid
- app/screens/modals/privacy_pop.tscn
- app/screens/modals/quit_warn.gd
- app/screens/modals/quit_warn.gd.uid
- app/screens/modals/quit_warn.tscn
- app/screens/modals/remap_capture.gd
- app/screens/modals/remap_capture.gd.uid
- app/screens/modals/remap_capture.tscn
- app/screens/modals/reset_warn.gd
- app/screens/modals/reset_warn.gd.uid
- app/screens/modals/reset_warn.tscn
- app/screens/modals/save_fail.gd
- app/screens/modals/save_fail.gd.uid
- app/screens/modals/save_fail.tscn
- app/screens/paused.gd
- app/screens/paused.gd.uid
- app/screens/paused.tscn
- app/screens/play.gd
- app/screens/play.gd.uid
- app/screens/play.tscn
- app/screens/settings.gd
- app/screens/settings.gd.uid
- app/screens/settings.tscn
- app/screens/splash.gd
- app/screens/splash.gd.uid
- app/screens/splash.tscn
- app/screens/title.gd
- app/screens/title.gd.uid
- app/screens/title.tscn
- app/session_state_machine.gd
- app/session_state_machine.gd.uid
- app/settings_store.gd
- app/settings_store.gd.uid
- ci/op4_font_probe.gd
- ci/op4_font_probe.gd.uid
- ci/sneferu_bot.gd
- ci/sneferu_bot.gd.uid
- ci/sneferu_visible_asset.json
- core/class_def.gd
- core/class_def.gd.uid
- core/enemy_def.gd
- core/enemy_def.gd.uid
- core/floor_data.gd
- core/floor_data.gd.uid
- core/generator_def.gd
- core/generator_def.gd.uid
- …and 166 more
# Implementation notes (cooperative code run)

- converged: True · final verdict: ACCEPTED — but 18 item(s) still open (soft accept) · rounds: 6
- latest durable reviewer verdict: ACCEPTED

## Final round reviewer result
Reading the round-6 surface now: the ledger item (G10 root-draft structure), the three code closures, and the standing contract files.

Core seams verified. Now checking the on_cue routing, wall-clock discipline, the middle traceability sections, and the audio manifest.

All verification passes are complete. Compiling the review.

**Verification walk (evidence, not claims):**

- **Ledger item (G10 root-draft structure):** PROTOTYPE_BRIEF.md:507-1040 carries §6.6 supersessions + §7 traceability (§7.1–§7.10: every AC/HS/PT row, shake/camera/haptics, transitions, zones, accessibility, R-1..R-5/DoD/OQ rows) + §8 changed files + §9 animation-timing tests + §10 regression (26 G7 suites/150 tests table, AUDIO_PRODUCT_MANIFEST validation result at §10.4, MovieWriter NOT_RUN disclosed at §10.5) + §11 unchanged-from-G7 + §12 blockers B1–B6. Spec's six-section order honored.
- **Round-6 code closures sampled 3/3 against source:** AC-10 fires `play_ac("AC-10")` + `haptic("light")` in `class_select.gd:134-138` before CHOOSE; HS-1 fires `request_hitstop("HS-1")` in `juice/juice_director.gd:897` routed from `on_cue("cue.enemy.hurt")` (:418-419); PT-01 fires `particle_burst("PT-01", pos, _class_tint())` in `notify_snapshot` floor-change branch (:572). Tests assert real numbers: HS-1 clears after exactly 2 ticks (test:490-494); PT-01 fires once on first snapshot, not on same-floor re-snapshot, re-fires on floor change (test:508-522).
- **Hard vetoes:** (1) every non-IMPL row carries an explicit §12-B2/B3/B4 blocker note ✓ (2) files full-on-disk per the G7 provision ✓ (3) 150/150 G7 tests present/green, gate PASSED ✓ (4) diff scan: presentation seams + docs + tests only — zero mechanic/balance/spawn edits ✓ (5) zero wall-clock calls in `juice/` + the six new suites (grep-verified) ✓ (6) `tools/gen_juice.py` is stdlib-only (json/sys/pathlib) ✓ (7) AUDIO_PRODUCT_MANIFEST valid (`cue_seam` block, named bus, `awaiting_operator`), audio absence is the musician-handoff contract, disclosed as product-regression B1 never run-stop ✓.
- **Reviewer B items:** caps resolve from Tunables not hardcoded (`test_juice_engine.gd:108-112` asserts 48/23/16); boundary + critical sub-cap + priority-cull tests assert budget arithmetic, not timers; bot gate PASSED 7/10 with `juice_events` + `result` codes in telemetry (sneferu_bot.gd:584-593, DoD #6); `attract_mode` flag live (session_state_machine.gd:38,294-297,306-308) driving SIG-5 suppression (juice_director.gd:776-778); visible-asset marker pinned to the governed `c141f0d1…` plan; `.godot/` gitignored.

BLOCKER-ACK: 13e6decf957f RESOLVED — PROTOTYPE_BRIEF.md now carries the full G10 root-draft structure (§7 traceability table with per-row IMPL/DATA status + blocker notes, §8 changed files, §9 animation-timing tests, §10 regression statement incl. §10.4 AUDIO_PRODUCT_MANIFEST validation PASS + §10.5 MovieWriter NOT_RUN disclosure, §11 build/run unchanged, §12 known blockers B1–B6), verified on disk lines 561–1040.

NOTE: Doc-drift inside the round — §9 table says test_juice_director_behavior has 16 tests, §10.2 says 61 G10 tests, §10.3 quotes "TOTAL: 211", but the pair-coder added 3 tests after the doc pass (real total 214 per IMPLEMENTATION_NOTES + the green gate). Runtime gate is authoritative and green; the brief's counts lag by the round's own final increment.

NOTE: §7.6 haptic class-confirm row (line 724) still reads "DATA — §12-B2 / rides the AC-10 gap" but B2 closed this round — the haptic fires at class_select.gd:138. Stale status cell; the implementation is correct.

NOTE: AC-Streak has a real implementation (streak_manager.gd window/tier logic, register_kill at juice_director.gd:905, RM guard at :978-979, streak_scale row in the per-type battery) but no traceability-table row and no dedicated positive/negative behavior test pair, which G9 §10's test matrix lists for "Streak". Disclosed here for the finish leg; the code path exists and is RM-guarded, so this is a pin/coverage gap, not a defect.

NOTE: AC-08 stagger value (`juice.class.popin_stagger_ms`=60) is present in Tunables but not test-pinned — the table itself discloses this honestly (line 598).

NOTE: Visual lane remains `qualification: NOT_RUN` (headless host) — infrastructure/evidence debt per the playtest contract and §12-B5, unchanged, correctly never presented as product failure.

Round discipline: this round closed the last ledger blocker, landed three real Tier-1 trigger-site closures with behavior tests, introduced no new surface area, and the pre-review gate is PASSED (Godot logic gate `classification: pass`, WAVE-B exit 0, canonical tree unchanged).

=== STRUCTURED FINDINGS ===
VERDICT: ACCEPTED
=== END STRUCTURED FINDINGS ===

VERDICT: ACCEPTED

## Files built (398)
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
- …and 198 more
# HUNGERHALL — Implementation Notes & Known Blockers

Round 3 (G7 prototype code, Godot 4.7 locked runtime). Per the required draft
structure §5: every prototype has imperfections. This document is the honest
list, with the next action for each. Nothing here is a claim that the
operator must accept; it is the state of the tree.

## What landed this round (round 3)

1. **G2 §3 difficulty lock restored in Tunables.json (closed the round-2
   contract-deviation blocker).** Round 1 had invented a FALLING
   target-seconds curve (135→30) and combat estimates 4–6× under the lock
   (120→200). The 16 band constants now carry EXACTLY G2 §3's locked table:
   - `target_seconds_band_1..8` = 135/165/195/225/255/255/285/285 (band
     midpoints) with bands = the locked ranges 120–150, 150–180, 180–210,
     210–240, 240–270, 240–270, 270–300, 270–300 (rising — later floors get
     LONGER targets, per the lock).
   - `combat_damage_estimate_band_1..8` = 500/700/700/850/950/1100/1100/1250.
     G2 §3 locks these as POINT estimates with no approved range until the
     G2.1 Monte Carlo (FIX-153) recalibrates them, so each ships a
     degenerate band `[v, v]` — zero tuning space IS the honest encoding of
     "locked, provisional, awaiting G2.1", not a hand-patchable window.
   - `tests/test_solver_check.gd::test_g2_locked_difficulty_table` pins the
     table byte-for-byte against the spec; any future drift fails the suite.
2. **Solver gate + food formula now implement G2 §7/§3 (the inheritance
   chain the wrong constants poisoned).**
   - `core/rules_solver_check.gd::food_pieces_for_band` — G2 §3's locked
     formula `max(1, ceil((drain×target_mid + combat − min_class_HP +
     margin_HP) / food_hp))`; reproduces the locked per-band food column
     3/5/6/8/11/12/14/16 (pinned by `test_food_formula_g2_locked_column`;
     under round-1 constants band 8 computed ≤1 where the lock requires 16).
   - `check_floor` — the G2 §7 static HP budget was missing the food term
     entirely (`spend < class_hp − margin` — incomplete even before the
     wrong constants). It is now the full inequality
     `(drain×target_mid + combat) ≤ (class_hp + food_pieces×food_hp −
     margin_hp)` with exact float comparison (5.5×285 = 1567.5 must never
     be decided by int truncation). Result dict gains `food_pieces`,
     `food_hp`, `food_heal_total`, `hp_surplus`; existing keys preserved.
     Both G2 worked examples pinned: F1–3 Wizard 770 ≤ 918, F22–24 Wizard
     2817 ≤ 2868 (`test_static_hp_budget_g2_worked_examples`).
   - `ci/sneferu_bot.gd:121` + `core/rules_session.gd:831` — bot per-floor
     `move_limit = floor.target_seconds × 60` inherits the corrected budget
     through the existing Tunables read (floor 4 limit is now 9900 =
     165×60, was 5400). No code change needed at the consumer; verified
     live below.
   - `Assets/Replays/attract.replay` — **re-baked on this host** with the
     corrected gate (same command as round 2): its `solver_gate` receipt now
     reads combat_estimate 500 / food_pieces 3 / spend 770 / budget 1198 /
     surplus 428 — G2's own F1–3 worked example. Terminal-snapshot receipt
     is `a9fa02f2…` (re-baked round 4 after a rules-core drift between
     rounds 2 and 3 changed the terminal snapshot; `test_attract_replay.gd`
     `EXPECTED_RECEIPT` updated to match). The replayed actions still verify
     against a fresh isolated session. (Re-bake against BAKED floor 1 remains
     owed under Known Blocker #2.)
3. **Bot navigation — BFS objective chain ported (closed Known Blocker #8,
   the `product_fail` runtime finding).** `ci/sneferu_bot.gd::_decide_inputs`
   now runs the SAME proven policy as the attract baker: BFS over real
   RulesFloor tiles on the objective chain (nearest key while the exit door
   is closed → exit; closed doors passable only key-in-hand), throws at the
   nearest hostile/generator in policy-shaped range with line of sight,
   class-relative potion floor (25% / 30% / 15% by policy). Round-1 steered
   straight-line through walls. The now-orphan `_nearest_enemy` and the dead
   `move_count` counter (round-2 NOTE) were removed with the port.
4. **`test_attract_replay.gd` — the shipped-reel determinism suite (pair-coder
   pass, closes the `attract_replay` item of Known Blocker #10).** Three tests
   pin the shipped artifact: (a) schema/seed/class/floor/outcome/length_ticks
   load and validate; (b) the embedded `solver_gate` receipt carries G2 §3's
   F1–3 worked example (combat 500 / food_pieces 3 / drain_plus_combat 770 /
   total_ok true) and the stamped `receipt_sha256`; (c) a fresh isolated
   `RulesSession` fed the recorded actions at their recorded ticks reaches
   `FLOOR_RESULTS` and reproduces the exact terminal-snapshot SHA-256 — the
   G2 §1 replay-determinism proof the baker names as its `test_attract_replay`
   seam. Three solver edge-case tests added to `test_solver_check.gd`:
   `band_for_floor` clamping (floors 0/-3 → 1, 25/100 → 8), the
   `food_pieces_for_band` food_hp≤0 divide-by-zero guard (falls back to 150),
   and `check_floor` meets_floor=false for a class below min_class_hp (520).

## What landed earlier (round 2)

1. **Musician cue seam (closed the AUDIO_PRODUCT_MANIFEST blocker).**
   - `app/cue_bus.gd` — `class_name CueBus` (Node, child of Main, created in
     `main.gd::_ready()`): `emit(cue_id, step)`, `emit_from_pending(pending)`,
     `emitted_log: Array[Dictionary]` for journey-contract observation, and
     duck-typed replaceable no-op dispatch slots (`audio_director`,
     `announcer`, `juice_director`).
   - `core/rules_session.gd` — cues are emitted at the SAME real
     controller/rules path used by player actions and terminal outcomes
     (`_push_cue` in `_do_throw`, `_do_potion`, `_check_contact`,
     `_check_enemy_projectile_hits`, `_step_hazards`,
     `_check_player_projectile_hits`, `_on_enemy_killed`,
     `_on_generator_destroyed`, `_step_pickups`, `_step_win_check`,
     `_step_death_check`, `_step_dying`, `_step_continue_offer`,
     `decide_continue`). `consume_pending()` now returns the G6 §3.3 shape
     `{cues: [{cue_id, step}], events: [{type, step, position, entity_id,
     amount}]}`.
   - `app/screens/play.gd` drains `consume_pending()` after every fixed 60Hz
     step and forwards cues to the CueBus; G6 §3.3 events are buffered for
     the presentation layer (`consume_events(events)` public surface added).
   - `data/cue_manifest.json` — `hungerhall_cue_manifest_v1`, the musician
     handoff manifest: every cue ID → meaning + callsite + paired event type.
   - `AUDIO_PRODUCT_MANIFEST.json` — note now describes what actually exists;
     no PCM ships and none is required (POST-BUILD MUSICIAN HANDOFF).
2. **Attract replay (closed the Assets/Replays/attract.replay blocker).**
   - `tools/attract_capture.gd` — bakes the reel from seed 0xDEAD (57005),
     Warrior, floor 1: solver-validates floor 1 BEFORE recording
     (`RulesSolverCheck.check_floor`), runs a BFS greedy-killer policy
     (objective chain key→door→exit, throws at hostiles in range with LOS,
     whirlwind potion below 25% HP), records hold-until-change semantic
     actions, then VERIFIES deterministic playback against a fresh isolated
     session — the SHA-256 receipt (HashingContext) of the terminal snapshot
     must match capture vs playback before the file is written (atomic
     temp+rename).
   - `Assets/Replays/attract.replay` — **baked for real on this host with
     Godot 4.7.stable.official.5b4e0cb0f** (`godot --headless --path .
     --script res://tools/attract_capture.gd -- --output
     Assets/Replays/attract.replay --seed 57005`): `outcome=floor_clear`,
     6 actions, 220 ticks, receipt
     `47dac3a5e5f90d436f1f75ed57dfa7dc7f87545ba2c0b9ce336a21b76d7d06b5`,
     solver gate `total_ok=true` (band 1, target 135s).
   - `app/screens/title.gd` — now MUST-loads `res://Assets/Replays/attract.replay`
     and drives an **isolated** RulesSession from the recorded actions at
     30Hz (two 60Hz rule ticks per 30Hz playback frame), rendered through
     `AttractViewport` (SubViewport) with a compact palette-true projection;
     loops on the clear moment; cycles the G3 `attract` caption lines; a
     missing/invalid reel degrades to the G3 `error.replay_missing` hall-voice
     caption and a static menu.
   - `core/class_def.gd` — `ClassDef.build(ct, tunables)` static factory (the
     one core-owned path to reconstruct the four locked class kits; the
     attract baker and playback use it instead of duplicating kit data) +
     `class_name_for` / `class_type_for`.
   - `strings.json` — added the G3-locked `attract` pool ("FREE TO ENTER.
     COSTLY TO LEAVE." / "SERVICE RUNS 24 FLOORS DEEP.") and
     `errors.replay_missing` (hall third-person, sentence case, per G3 error
     voice).
3. **Fonts disclosure (this document + .tres bindings).**
   - `Fonts/font_8.tres`, `font_16.tres`, `font_24.tres`, `font_32.tres`,
     `Fonts/announcer_font.tres` — one FontFile resource per G4 type-scale
     size (`fixed_size` set; bound to the locked TTF paths via `fallbacks`),
     verified loading on Godot 4.7 (ResourceLoader returns a FontFile with
     the base reachable). Pixel-perfect flags are set where Godot 4.7
     actually keeps them: the TTF import sidecars (`antialiasing=0`,
     `hinting=0`, `subpixel_positioning=0`, `oversampling=1.0`) — probed
     empirically: Godot 4.7 `FontFile` exposes **no** `antialiased` /
     `disable_subpixel_positioning` / `hinting_pass_type` properties, so the
     G4 flag names map to the import parameters + the FontFile properties
     that DO exist (`hinting=0`, `oversampling=1.0`, MSDF off, mipmaps off).
   - `Fonts/OFL_NOTICE.txt` — tightened: it now states explicitly that the
     shipped TTFs are an ORIGINAL pipeline-generated face (family
     "HungerhallPixel", authored by the shipped `tools/build_fonts.py`), NOT
     the real Silkscreen, and points at this Known Blockers list.

## Known Blockers (each with next action) — updated round 7

1. **Typography — the real Silkscreen is NOT shipped.** G4 locks *Silkscreen*
   by Jason Kottke (SIL OFL 1.1) as the shipped TTFs with a committed license
   receipt. The build sandbox has no network access, so the tree ships an
   ORIGINAL pipeline-generated 5×7 pixel face under the locked filenames,
   disclosed in `Fonts/OFL_NOTICE.txt`. Next action: operator drops the
   licensed `Silkscreen-Regular.ttf`/`Silkscreen-Bold.ttf` over
   `Fonts/silkscreen_regular.ttf`/`silkscreen_bold.ttf`, re-imports; zero
   code changes (all consumers + the five sized .tres bind the locked paths).
   Commit the OFL receipt at that time (G9 binding).
2. **`error.replay_missing` text is provisional.** G3 marks the slot as
   provisional; G2 §11 confirms the attract replay feature (line 622). The
   text follows G3 voice rules. Next action: pin in G3 or accept as-is.
3. **Test suites — 32 suites + runner ship** (211 tests, all passing). G6 §3.4
   mandates 19-21; the tree exceeds the mandate. `test_presentation` shipped
   this pass (presentation_contract.json schema + palette hex→Color + ui_regions
   [0,1] non-overlap + frame_floors ranges, 10 tests). `test_juice_contracts`
   shipped this pass (JuiceContracts traceability against Tunables.json — 11
   tests). Missing only
   `test_audio` — blocked by a genuine spec tension: G6 §2 mandates an
   `audio_director.gd` with procedural `AudioStreamWAV` tones + a `test_audio`
   verifying non-silent PCM, while the POST-BUILD MUSICIAN HANDOFF (NON-BLOCKING)
   section forbids synthesizing/placeholder audio and requires no audible PCM
   before authored audio arrives. The tree sided with the NON-BLOCKING policy
   (no synthesized audio). Next action: operator resolves the tension
   (authorize procedural cue tones OR confirm no-synthesis wins); the suite +
   `audio_director.gd` follow the chosen policy.
4. **Input map partial.** Core actions present (`hh_throw`, `hh_potion`,
   `hh_pause`, `sneferu_primary_action`, `move_*`, `ui_*`); contextual Space
   resolution via `InputMapper` covers continue/select/back. Full G6 §15
   explicit hh_* actions not pinned. Next action: pin remaining actions if
   operator prefers dedicated keys.
5. **Audio PCM — none ships, by design.** The musician handoff seam is
   complete (CueBus + cue_manifest.json); authored tracks/cues/announcer
   clips are operator-supplied later. Next action: operator drops authored
   WAVs → AudioDirector binds them to cue IDs.
6. **Steam export — unqualified.** No export templates run; Windows export
   is a later qualification lane. Next action: none in G7 scope.

**Resolved blockers (historical):** Baked floors (24 solver-gated `.tres` at
`data/floors/base/` + `tools/floor_baker.gd` + `tools/solver.gd` + cell library;
`RulesSession._load_floor` loads baked `FloorData`; runtime zero layout RNG per
G2 §7 — resolved round 5), Scene graph (all 12 screens + 10 modals
present and wired in SceneRouter), world/ layer (6 files), ui/ layer (8
files incl. wordless HUD), InputMapper (contextual Space resolution + pad
lost), PlayScreen _physics_process (tick_once at fixed 60Hz), BFS bot
navigation (ported round 3), strings.json G3 schema (data/strings.json,
157 keys), class card G3 copy, save_codec + stores, settings screen +
remap capture modal.

## Round 4 (pair-coder pass) — what landed

1. **Parse error fix: `app/screens/modals/reset_warn.gd` — `router_scene`
   not declared.** The `_on_yes()` method assigned `router_scene` without a
   `var` declaration, causing a parse error that blocked the entire
   `SceneRouter._build_scene_map()` (the modal is loaded during scene map
   construction). Fixed: added `var router_scene: Node = null` before the
   assignment.
2. **Parse error fix: `ui/clipped_plaque_stylebox.gd` — wrong `_draw`
   signature.** The override used `_draw(to_canvas_item: CanvasItem,
   to_rect: Rect2)` but Godot 4.7's `StyleBox._draw` virtual has signature
   `_draw(RID, Rect2)`. Fixed: changed to `RID` parameter, replaced
   `CanvasItem.draw_circle`/`draw_arc` calls with `RenderingServer` calls
   (`canvas_item_add_rect`, `canvas_item_add_circle`,
   `canvas_item_add_polyline`), and draw the plaque fill + border directly
   (StyleBoxFlat's C++ `_draw` cannot be called from GDScript `super`).
3. **Attract replay re-baked.** The shipped `Assets/Replays/attract.replay`
   carried a stale receipt (`47dac3a5…`) from round 2; a rules-core drift
   between rounds 2 and 3 changed the terminal snapshot so the test
   `test_attract_replay_deterministic_playback` failed (playback
   `a9fa02f2…` ≠ stamped `47dac3a5…`). Re-baked with
   `tools/attract_capture.gd` (new receipt `a9fa02f2…`); updated
   `EXPECTED_RECEIPT` in `tests/test_attract_replay.gd` to match.
4. **PROTOTYPE_BRIEF.md — stale Known Blockers and compliance tables
   updated.** The brief carried round-2 blocker claims (only 3 of 12
   screens, 10 modals absent, world/ui absent, bot greedy-line, strings.json
   schema drift, class card copy invented, HUD word-labels) that were all
   resolved in round 3 or earlier. Rewrote §5 Known Blockers to the 5
   remaining real blockers, updated §6 compliance tables (all strings now
   traced to G3 keys, all visual elements now palette-tokened), and updated
   test count from 62 to 71 in the OP-4 acceptance table.

## Verification evidence (round 2, this host)

- Godot `4.7.stable.official.5b4e0cb0f` (`/opt/homebrew/bin/godot`).
- `--import` + `--quit` parse passes clean after every change set.
- Attract bake ran end-to-end on the real engine (receipt above), and a
  SECOND independent bake reproduced the identical receipt — cross-run
  determinism of the baked reel itself.
- Cue seam probed end-to-end on the real engine: a real RulesSession throw
  emits `cue.player.throw` (+ the `throw` event) through `consume_pending()`
  in the G6 §3.3 shape, and `CueBus.emit_from_pending` records it in
  `emitted_log`; the second drain is empty.
- `tests/test_runner.gd` suite results: see the round's gate output; the
  consume_pending() signature change (Array → G6 §3.3 Dictionary) has no
  external callers besides `step()` itself (verified by grep before
  changing).
- Font resources: all five load via ResourceLoader as FontFile with the
  locked TTF bound (probed on the real engine).

## Verification evidence (round 3, this host)

- Godot `4.7.stable.official.5b4e0cb0f` (`/opt/homebrew/bin/godot`).
- `--import` parse passes clean after the change set (exit 0).
- `tests/test_runner.gd`: **71/71 PASS** — including the three round-3 G2
  contract pins (`test_g2_locked_difficulty_table`,
  `test_food_formula_g2_locked_column`,
  `test_static_hp_budget_g2_worked_examples`), which FAIL against the
  round-1 constants by construction; the three `test_attract_replay.gd`
  pins (schema/solver-gate/deterministic-playback of the shipped reel); and
  the three solver edge-case pins (band clamping, food_hp≤0 guard,
  meets_floor=false).
- Attract re-bake ran end-to-end (exit 0): `solver_gate` now
  combat_estimate 500 / food_pieces 3 / drain_plus_combat 770 /
  effective_hp_budget 1198 / total_ok true; terminal receipt unchanged
  (determinism cross-check — same rules + seed replay to the same
  snapshot SHA-256).
- Bot probe after the BFS port (8 games, seed 1, frame-budget 36000):
  played=8 completed=8; floor_1 plays=8 wins=5 avg_moves=1122 limit=8100;
  floor_4 limit=9900 (band-2 midpoint 165×60 — the corrected budget);
  every observed floor under its move_limit. Round 2's gate observed
  4/10 completed and levels[1] over its limit.

## What landed this round (round 7)

### BLOCKER closed — 13 suites never registered (false green)

`tests/test_runner.gd::_register_suites()` was a hardcoded 12-entry list;
14 suite FILES on disk (test_state_machine, test_enemy_ai, test_generators,
test_hazards, test_continue, test_replay, test_balance_sim,
test_accessibility, test_assets, test_exit_overlap, test_fixed_timestep,
test_modals, test_save, test_floor_solver) never executed while the brief
claimed "78 tests all passing". Fix: the runner now DYNAMICALLY discovers
every `test_*.gd` under `res://tests/` (sorted, runner itself excluded);
an unloadable/unparseable suite is a loud FAIL, never a silent skip — a
new suite file can never ship dark again. Wiring the suites surfaced six
REAL latent failures (they had never run); all six fixed:

1. `test_state_machine::test_title_to_settings_and_back_to_title` —
   `SETTINGS+BACK` is condition-ambiguous in the table (two rows:
   entered_from_paused / entered_from_title) and `find_transition`
   returned only the FIRST row, so Settings-Back from TITLE evaluated the
   paused-route condition, failed, and never reached the title row.
   `TransitionTable.find_all_transitions()` added; `SSM.try_transition`
   now evaluates every candidate row in table order until one condition
   passes (core/transition_table.gd, app/session_state_machine.gd).
2. `test_modals` (mount/dismiss + pad_lost) — `set_router(r: SceneRouter)`
   rejected the suite's mock router (a Node, per G6 §3.4 no-autoload
   testing). SSM's router is now duck-typed Node (`_router: Node`,
   `set_router(r: Node)`) — it only ever calls mount/hide/
   get_active_scene/on_state_changed.
3. `test_fixed_timestep::test_drain_is_tick_based_60hz` — the float drain
   accumulator added `2.0/60.0` sixty times = 1.9999… and applied only 1
   HP per second at every integer drain band. `_step_drain` is now
   INTEGER-tick arithmetic: owed after T ticks = `int(T * rate / 60)`
   (core/rules_session.gd — `_drain_ticks` / `_drain_damage_applied`
   replace `_drain_accumulator`, reset in `_reset_floor_state`).
4. `test_hazards::test_flame_jet_on_off_cycle` — the suite's wrap check
   was off by one tick: it asserted the jet cold at elapsed tick 180 (the
   last OFF-window tick, correct) and then asserted it burning at the SAME
   elapsed instant (impossible for any deterministic cycle). The
   implementation's 60-on/120-off period is G2-correct; the test now
   `tick()`s once more before the wrap assertion, with the reasoning
   commented.
5. `test_save::test_settings_store_defaults_and_write` — two real codec
   defects: (a) `default_settings()` omitted `settings_version` even
   though save_schema.json documents it and `encode_settings` always
   writes it, so `decode(encode(defaults)) != defaults`; (b) JSON.parse
   returns every number as a FLOAT and GDScript Dictionary ==
   distinguishes 24.0 from 24, so any write+read round-trip could never
   compare equal to the int-typed defaults. `default_settings()` now
   carries the version key and `normalize_settings` coerces parsed values
   back to the defaults' Variant types (`_coerce_to`).
6. `test_attract_replay::test_attract_replay_deterministic_playback` — the
   drain fix (item 3) is a deliberate rules-core change, so the shipped
   reel's terminal-snapshot receipt no longer matched playback. Re-baked
   with the shipped `tools/attract_capture.gd` (seed 57005): SAME 9
   actions, SAME 348 ticks, SAME floor_clear outcome, SAME G2-locked
   solver_gate (500/3/770/135/true); only the receipt moved
   (fc96d7d3… → f5981978…). `EXPECTED_RECEIPT` re-pinned with the old
   value kept in the comment. This is the receipt doing its job — it
   tracks the rules core.

### BLOCKER closed — store leak at exit (gate product_fail)

Round-6 gate: `ERROR: 4 resources still in use at exit` + `WARNING: 9
ObjectDB instances were leaked at exit` on the normal main scene. Root
cause verified with `--verbose`: the autoload `_ready()` runs before the
main scene, so `_ensure_stores()` created four self-owned store Nodes;
main.gd:45-59 then overwrote all four references with the authored Main
children and the orphans leaked (4 Nodes + their 4 GDScripts + 1
GDScriptNativeClass = 9 instances; 4 scripts = 4 resources). Nodes are
NOT refcounted. Fixed in app/session_state_machine.gd:
- the four `set_*` setters free a replaced self-owned store
  (`_free_orphan_store`: is_instance_valid + not-is_inside_tree + not-same
  guards — authored in-tree children are NEVER freed, no double-free);
  `set_save_store` repoints surviving self-owned dependents to the new
  save store BEFORE freeing the old one (partial-injection safety);
- `_notification(NOTIFICATION_PREDELETE)` frees still-self-owned stores —
  covers script-mode runs (the test runner loads the autoload; main.tscn
  never mounts, so nothing injects) and bare suite instantiation
  (test_state_machine frees the SSM directly; PREDELETE fires on free()
  even for never-parented Nodes, where _exit_tree never runs). The loop is
  UNTYPED on purpose: test_save frees an injected store before the SSM,
  and a typed Array[Node] iteration rejects the freed reference and aborts
  the cleanup.
- Same pass freed the MockRouter's bare modal Nodes in test_modals
  teardown (the last 2 leaked instances in the runner process).

### Brief claims corrected

PROTOTYPE_BRIEF.md now states the REAL runner output: 32 suites + runner,
211 tests, `PASS: 211  FAIL: 0  TOTAL: 211` (§3.2, OP-4 item 2, project
tree, known-blockers test-coverage entry).

## Verification evidence (round 7, this host)

- Godot `4.7.stable.official.5b4e0cb0f` (`/opt/homebrew/bin/godot`).
- `tests/test_runner.gd`: **PASS: 211  FAIL: 0  TOTAL: 211**, exit 0, and
  ZERO leaked ObjectDB instances / resources-in-use at exit (the round-7
  store-fix zero-leak bar held after the 4 new juice/presentation/main-scene/
  asset-admission suites landed; their JuiceDirector/ParticleManager probes
  are freed via per-test `teardown()`). The 44 `asset_debt flagged` ERROR
  lines are the admission negative-battery's deliberate fallback assertions
  (G9 "visible, never silent"), not infrastructure errors — zero WARNING
  lines, zero `ObjectDB instances leaked`, zero `Resource still in use`.
- Normal main scene (`godot --headless --path . --quit-after 300`): exit
  0, **completely clean stderr** — no `resources still in use`, no
  `ObjectDB instances leaked` (the exact round-6 gate failure).
- Bot smoke after the drain fix: exit 0, `playtest_telemetry_v1` seed 42,
  floor_1 plays 4 avg_moves 253 vs limit 8100, games completed — no
  move-limit overrun, no games_completed-0 regression.
- Attract re-bake: exit 0, playback-verified by the baker itself before
  writing (receipt f5981978…).

## G10 round 6 — what landed (documentation-only, per FOCUS_NEXT)

Closed the reopened ledger blocker (442b21fae332 — "G10 root-draft
structure absent"). PROTOTYPE_BRIEF.md now carries the G10 spec's
"Required structure for the root draft", all six sections in the spec's
order as §7–§12, with the G7 baseline preserved as §1–§6:

- §7 juice-spec traceability table — one row per G9 contract line
  (AC-01..63 + composites + HS-1..4 + PT-01..17 + shake/camera/haptics +
  transitions + zones + accessibility + R-1..R-5/DoD/OQ rows):
  spec item · file/function · curve/duration as implemented · pinning
  test · status (IMPL/DATA). Every "as implemented" number was verified
  against Tunables.json on disk this round (durations AND amplitudes —
  21 amplitude keys spot-checked byte-equal; all 8 juice.transition.*
  keys present). Unimplemented rows carry explicit blocker notes per the
  spec: AC-10 class-confirm trigger (Tier 1 — binding exists, no
  play_ac call site, grep-verified), HS-1 light-hit trigger (Tier 1),
  PT-01 hero-spawn spark (Tier 1 handshake beat 3) + seven more
  declared-no-site PT rows, the Tier-2 set (AC-04/05/06/07/09/11/12/13/
  14/25/40/61 + §6 scene fades), AC-40.
- §6.6 — the five documented supersessions (AC-37 fire-moment, zone
  order, JuiceDirector child-mount, cue-name adaptation, OQ-22
  first-food seam), satisfying the core/rules_session.gd:634 reference.
- §8 changed files (full contents, on-disk provision) — additive juice/
  data/test files + the presentation-only modifications, with an
  explicit "untouched by G10" list.
- §9 animation-timing tests — the six suites (61 tests) with their
  G9-number pins; determinism discipline stated (grep-verified zero
  wall-clock calls in juice/ + new suites).
- §10 regression statement — the 26 G7 suites (150 tests) each
  present + green + unchanged; zero deleted/weakened assertions; the
  only rules-file edits are the three additive presentation-seam cues;
  runner result 211/211 + bot gate 7/10; AUDIO_PRODUCT_MANIFEST
  validation executed this round (OP-4 items 10+11 PASS, 23 cues, all
  primary-action + terminal-outcome cues present); MovieWriter
  audibility stated NOT_RUN (headless host; authored audio absent by
  the musician-handoff contract) as a product regression item, never a
  run-stop authority.
- §11 build & run — unchanged from G7.
- §12 G10 known blockers — B1..B6, each with a next action.

No code changed this round (documentation-only, per the reviewer's
FOCUS_NEXT). The two honest Tier-1 gaps surfaced while building the
table (AC-10 trigger, HS-1/PT-01 trigger sites) are recorded as §12-B2/B3
blocker notes rather than silently claimed implemented.

## G10 round 6 pair-coder — trigger-site closures (B2/B3 Tier 1)

The implementer's documentation pass surfaced three one-dispatch code gaps
(§12-B2/B3) as honest blocker notes. The pair coder closed all three:

- **B2 — AC-10 class-confirm trigger.** `app/screens/class_select.gd::_lock_in()`
  now calls `_juice.play_ac("AC-10")` + `_juice.haptic("light")` before the
  CHOOSE transition. The confirm snap (1.06→0.94→1.0) and its G9 §5 light
  haptic now fire on class lock-in.
- **B3/HS-1 — light-hit hitstop (handshake beat 4).** `juice/juice_director.gd::_on_hit_confirm()`
  now calls `request_hitstop("HS-1")`. cue.enemy.hurt → _on_hit_confirm →
  2f freeze. The hitstop_table row existed but no call site fired it.
- **B3/PT-01 — hero-spawn spark (handshake beat 3).** `juice/juice_director.gd::notify_snapshot()`
  floor-change branch now calls `particle_burst("PT-01", player_pos, _class_tint())`.
  8 class-tinted sparks fire at the hero's entry tile on floor entry (ties
  the spawn visual to class identity). The particle_table row existed but no
  burst site fired it.

Three behavior tests added to `tests/test_juice_director_behavior.gd`
(source-structural pin + behavior twin, following the round-5
test_ac59_ac60_floor_results_trigger_site pattern):
`test_ac10_class_confirm_trigger_site`,
`test_hs1_hitstop_fires_on_hit_confirm`,
`test_pt01_hero_spawn_spark_fires_on_floor_change`.

Verification: `godot --headless --script tests/test_runner.gd` →
PASS: 214  FAIL: 0  TOTAL: 214 (211 baseline + 3 new). `godot --headless --import`
→ exit 0 (clean parse, JuiceDirector class registered). No wall-clock calls
added. The Tier-2 burst sites (PT-02/04/08/13/14/15a/15b) and Tier-2
presentation rows remain as documented §12-B3/B4 (out of scope for a
handshake-beat Tier-1 closure).

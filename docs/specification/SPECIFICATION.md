# HUNGERHALL — G6 Prototype Spec (Locked Runtime: Godot 4.7)

**Run:** gap-253b64a1 · **Phase:** G6 · **Authority chain:** G1 Concept Lock (FROZEN) → G2 GDD (FROZEN) → G3 Voice Bible (FROZEN) → G4 Art Direction (FROZEN, Palette A — "After Service") → G5 UX Flow (FROZEN, LAR-1–4 adopted) · **Engine:** Godot 4.7 (LOCKED — G7 does not relitigate) · **Platform:** Steam, Windows export — qualified as its own later lane, never claimed here · **Price:** $5.99 premium, zero post-purchase spending · **Scope:** commercial_focused

This document is the binding contract G7 reads as authoritative. Every file, test, scope boundary, and pin below is law. G7 reviewers reject code that drifts from this specification.

**Novelty thesis.** HUNGERHALL's HP drain is Gauntlet's drain, acknowledged. The four class names (Warrior, Valkyrie, Wizard, Elf) are also Gauntlet's roster, acknowledged. The mechanical fork is structural: a single-player finite campaign where four classes pay the same HP bill in different risk currencies, floors are solver-gated for structural solvability at bake time, and there are no in-run upgrades, no coin-op continue economy, and no item synergy drafting. Class distinctness is verified mechanically — no two classes share the same combat signature tuple `(hp, speed, shot_dmg, shot_range, shot_rate, potion_type)` — AND measured by dominance_spread_pp across bot policies, with an additional viability floor: `min_class_win_rate ≥ 0.40` and `min_class_avg_hp_at_exit ≥ 30`. The novelty is the campaign structure and class-diversified risk economy, not the clock or the names.

**G5 Lock-Amendment adoption:** LAR-1 (`ng_plus: bool` in save, always false), LAR-2 (event-driven rumble patterns), LAR-3 (game_over → RetryChosen edge), LAR-4 (settings one flat column).

**DIS position alignment:** DIS-1 (SSM in app/, not core/) upheld. DIS-2 (tools/ present) upheld. DIS-3 (comprehensive Tunables) upheld. DIS-4 (all 10 modals) upheld. DIS-5 (replay playback, not live sim) — **CHANGED: adopting replay-only position (meta/nvidia/deepseek-2)**; prior live-sim language removed throughout. DIS-6 (separate world/) upheld. DIS-7 (dedicated RulesCombat) upheld. DIS-8 (NG+ OUT) upheld. DIS-9 (step() name) upheld. DIS-10 (18 test suites) upheld.

---

## 1. Engine choice

Godot 4.7 is the locked runtime. No substitute may be proposed. `RefCounted` value types give the G2 §7 pure-rules contract a native home with zero Node/rendering/input coupling. The headless `--fixed-fps 60` main-scene launch drives `ci/sneferu_bot.gd` against that same core for machine-graded telemetry. The locked 2D pixel presentation (32px tiles, 640×360 viewport, CanvasModulate, Control themes) maps directly to TileMap, CanvasLayer, SpriteFrames, and Theme resources. One ruleset serves player, bot, attract replay, and deterministic replay. Steam Windows export is a later qualification lane.

`project.godot` pins (binding on G7):
- `application/run/main_scene="res://main.tscn"`
- Exactly one autoload: `SessionStateMachine` → `*res://app/session_state_machine.gd`
- `physics/common/physics_ticks_per_second=60`
- `rendering/textures/vram_compression/import_etc2_astc=true`
- `renderer/rendering_method="gl_compatibility"`
- Window 1280×720, 640×360 base viewport, `canvas_items` stretch, `keep` aspect
- Complete `[input]` map per §15

**`sneferu_primary_action` resolution (all states):** `InputMapper` resolves the Space binding contextually using `SessionStateMachine.current_screen`:

| Current screen | Resolves as |
|---|---|
| Splash | confirm (skip to Title if ≥18 steps elapsed AND input received) |
| Title | confirm (selects focused menu item) |
| ClassSelect | confirm (locks class, triggers DESCEND) |
| Playing | throw (fires projectile along facing) |
| Paused | resume (returns to Playing) |
| Settings | no-op (Settings uses its own input scheme) |
| HallOfHeroes | back (returns to Title) |
| Dying | no-op (non-interactive) |
| ContinueOffer | yes (selects YES continue) |
| GameOver | confirm (selects focused button) |
| FloorResults | advance (proceeds to next floor) |
| CampaignResults | confirm (commits initials, returns to Title) |

This is an additional keyboard/accessibility binding riding the real controller path, never a test-only branch.

**`SessionStateMachine` is the sole autoload.** It does NOT declare `class_name` — the autoload name `SessionStateMachine` is the sole global accessor, avoiding class_name/autoload collision (OBL-55). It owns one `RulesSession` instance and state machine logic. It does NOT create scene nodes. `main.gd` is the sole composition root: it authors all app-layer nodes as children of `Main` in `main.tscn`, then wires them to `SessionStateMachine` via setter injection in `_ready()`.

---

## 2. Project layout

```text
HUNGERHALL/
  project.godot                           — pins in §1; full InputMap per §15; gl_compatibility
  main.tscn                               — configured entry scene: Main (Node) with main.gd attached;
                                            ALL app-layer nodes authored as children here (see §5 tree)
  main.gd                                 — THE SOLE composition root; parses -- args; reads --seed
                                            if present (deterministic campaign seed); reads --journey-seed
                                            if present; creates SneferuBot in bot mode; wires all
                                            app-layer nodes to SessionStateMachine via setter injection
                                            in _ready(); bot-mode handoff
  journey_contract.json                   — game_journey_v1 at project root; includes "seed": 42 field
  presentation_contract.json              — FIX-776 machine-measured look contract, project root
  AUDIO_PRODUCT_MANIFEST.json             — audio exact-tree wiring; empty until operator audio supplied
  Tunables.json                           — game_tunables_v1; single runtime + bake-time authority
  save_schema.json                        — documentation-only field reference for §19 (NOT loaded at
                                            runtime; SaveCodec in core/ is the authoritative schema)

  core/                                   — PURE DETERMINISTIC RULES. RefCounted/Resource only.
                                            No Node, Control, Viewport, Input, audio, or rendering.
    rules_session.gd                      — class_name RulesSession: input()/step()/snapshot()/
                                            consume_pending()/setup_campaign()/load_floor()/
                                            continue_floor()/retry_floor()/has_legal_action()/
                                            tick_once(); owns _floor,_player,_enemies,_generators,
                                            _hazards,_projectiles,_pickups,_score,_tunables,_prng
    transition_table.gd                   — G2 §1 + G5 LAR edges as pure data; legality checks;
                                            condition vocabulary defined in §3
    rules_floor.gd                        — tile grid, baked entity spawns, seeded PRNG, exit overlap
    rules_player.gd                       — HP drain, 8-way movement, facing, throw, potion, class kits
    rules_enemy.gd                        — six AI contracts, pathfinding, wall-pass, blink, aura
    rules_generator.gd                    — cadence bands, per-generator cap 6, per-floor cap 28
    rules_hazard.gd                       — flame_jet / void_bridge / collapsing_void
    rules_projectile.gd                   — movement, collision, pierce/splash, faction mask
    rules_combat.gd                       — (static) damage resolution, structure rule, potion effects
    rules_score.gd                        — fixed-ratio reward table, death penalty, totals
    rules_pickup.gd                       — food, keys, potions, chests, doors, exit
    rules_continue.gd                     — continue rebuild contract; token decrement logic
    rules_replay.gd                       — semantic action codec + SHA-256 via HashingContext
    rules_solver_check.gd                 — (static) solver gate verification (gates 1–9)
    save_codec.gd                         — pure dict encode/decode/migrate for save v1
    tunables_loader.gd                    — parses Tunables.json, validates bands/steps, typed accessors
    prng_seeder.gd                        — integer-seeded deterministic PRNG wrapper
    floor_data.gd                         — FloorData (Resource): tile_grid, spawns, chest_values (baked),
                                            target_seconds. NO gameplay constants; structural data only
    class_def.gd                          — ClassDef (Resource): class_type, display_name, sprite_frames_ref,
                                            potion_type
    enemy_def.gd                          — EnemyDef (Resource): ai_type, display_name, sprite_frames_ref
    generator_def.gd                      — GeneratorDef (Resource): generator_type, enemy_type
    hazard_def.gd                         — HazardDef (Resource): hazard_type, trigger_type
    state_enums.gd                        — State enum (12), SceneId enum (22), Verb enum (21),
                                            HazardType, TriggerType, EnemyAIType, ClassType, PotionType;
                                            exact integer mappings in §3

  app/                                    — CONTROLLER SHELL: engine reality ↔ core. No rules math.
    session_state_machine.gd              — autoload SessionStateMachine (NO class_name): owns one
                                            RulesSession; setter-injection API for all app-layer deps;
                                            tick_once() public method (called by _physics_process in
                                            production, by tests directly); step() only when
                                            current_screen == PLAYING; freeze_steps_remaining internal
                                            counter; transition verbs per G5
    scene_router.gd                       — class_name SceneRouter (Node, child of Main in main.tscn):
                                            @export scene_map: Dictionary (SceneId → PackedScene);
                                            mount(scene_id)/hide(scene_id)/current_scene_id property;
                                            get_active_scene() → Node; NO back-imports to scenes/
    input_mapper.gd                       — class_name InputMapper (Node, child of Main): resolves
                                            InputMap → semantic actions; sneferu_primary_action
                                            contextual resolution per §1 table; joypad disconnect
                                            detection for pad_lost
    save_store.gd                         — class_name SaveStore (Node, child of Main): atomic
                                            temp+rename; write_campaign/write_profile/write_scores/
                                            write_settings/read_*/erase_all/erase_settings
    profile_store.gd                      — class_name ProfileStore (Node, child of Main)
    score_store.gd                        — class_name ScoreStore (Node, child of Main)
    settings_store.gd                     — class_name SettingsStore (Node, child of Main)
    announcer.gd                          — class_name Announcer (Node, child of Main): bark queue
    cue_bus.gd                            — class_name CueBus (Node, child of Main): emit(cue_id);
                                            emitted_log: Array[Dictionary] for journey-contract
                                            observation; dispatches to AudioDirector/Announcer/JuiceDirector
    audio_director.gd                     — class_name AudioDirector (Node, child of Main): procedural
                                            tones as in-memory AudioStreamWAV (pre-computed at boot);
                                            authored WAVs when supplied; volume scales by sfx_vol/100.0
    juice_director.gd                     — class_name JuiceDirector (Node, child of Main): rumble(pattern,
                                            intensity) scaled by settings.rumble_intensity; reads juice
                                            constants from TunablesLoader; set_settings_store() for
                                            rumble scaling; does NOT own freeze (SSM does)

  scenes/                                 — THIN PROJECTIONS. Never a second truth store.
    splash.tscn / splash.gd               — 72-step (1.2s) mark; skippable after 18 steps + input
    title.tscn / title.gd                 — menu rows: NEW GAME (default focus), CONTINUE (disabled if
                                            no save), HALL OF HEROES, SETTINGS, CREDITS, PRIVACY;
                                            attract replay via AttractViewport; title.gd MUST load
                                            res://Assets/Replays/attract.replay and drive an isolated
                                            RulesSession from recorded actions at 30Hz (see §5)
    class_select.tscn / class_select.gd   — four class cards; Warrior pre-highlighted; DESCEND default
    play.tscn / play.gd                   — mounts world/ projection + HUD; exposes is_playing, hp,
                                            shots_fired, player_tile_x, player_tile_y;
                                            consume_events(events: Array) public method
    paused.tscn / paused.gd               — Resume (default focus) / Settings / Quit
    settings.tscn / settings.gd           — ONE flat scrollable column (LAR-4)
    hall_of_heroes.tscn / hall_of_heroes.gd — Standard tab only
    dying.tscn / dying.gd                 — 72/12 steps; non-interactive; step-counted in SSM
    continue_offer.tscn / continue_offer.gd — 600-step ring; YES pre-highlighted; zero-token 120-step
                                            auto-expire path; step-counted in SSM
    game_over.tscn / game_over.gd         — initials entry; RETRY FLOOR N (LAR-3); Scores; Title
    floor_results.tscn / floor_results.gd — time/kills/food/score + SAVED tag; autosave on entry
    campaign_results.tscn / campaign_results.gd — initials always fire; laurels
    modals/
      quit_warn.tscn / .gd                — no default focus; context-aware copy
      newgame_warn.tscn / .gd             — fires only when save exists
      erase_warn.tscn / .gd               — irreversible; double-confirm
      reset_warn.tscn / .gd               — settings-only reset
      remap_capture.tscn / .gd            — single key capture; conflict detection ("IN USE BY [action]")
      credits_pop.tscn / .gd              — original text from strings.json
      privacy_pop.tscn / .gd              — original text from strings.json
      pad_lost.tscn / .gd                 — gamepad disconnect; auto-pause triggers before mount
      save_fail.tscn / .gd                — retry ×3 (0.1s between); then SkipSave
      floor_missing.tscn / .gd            — F1-23: skip-advance N+1; F24: return-to-title

  world/                                  — Node2D projection of Play snapshot; juice; zero rules.
    world_view.gd                         — tile layers, actor sprites, hazards, pickups;
                                            render(snapshot)/consume_events(events)
    actor_sprites.gd                      — hero/enemy/generator/pickup frame drivers
    camera_rig.gd                         — dead-zone follow, 16px lead, trauma kick
    life_light.gd                         — CanvasModulate grades ×1.0/×0.80/×0.62
    particles.gd                          — pooled smoke/spark bursts; pool limit 128
    floaters.gd                           — pooled score/HP numerals; pool limit 16

  ui/                                     — THEMED CONTROL WIDGETS; no flow, no rules
    hungerhall_theme.tres                 — G4 Palette A tokens (hex values in §12)
    clipped_plaque_stylebox.gd            — destructive crescent-corner StyleBox
    hud.tscn / hud.gd                     — wordless: HP, score, floor, potion/key icons
    caption_band.tscn / caption_band.gd   — text from strings.json (loaded via FileAccess at boot,
                                            cached in a static dictionary; ui/ does NOT import core/
                                            for this — strings are passed in by Play scene)
    continue_ring.tscn / continue_ring.gd — circular progress arc
    initials_entry.tscn / initials_entry.gd — 3-slot A-Z arcade initials
    idle_prompts.tscn / idle_prompts.gd   — MOVE/THROW glyph overlays
    input_glyphs.gd                       — 1-bit glyph composition
    guestbook_table.tscn / guestbook_table.gd — Standard tab only

  data/                                   — BAKED, SOLVER-PASSED, READ-ONLY content + JSON manifests
    strings.json                          — G3 string manifest: {key: {text, category, pool_index,
                                            class_variants}}; categories: "bark","caption","ui",
                                            "credits","privacy"; ALL CAPS barks, no exclamation marks,
                                            no em-dashes, ≤6 words/bark
    announcer_audio.json                  — clip-duration manifest (paths empty until handoff)
    cue_manifest.json                     — musician handoff: cue_id → meaning + callsite
    floors/
      base/floor_01.tres ... floor_24.tres — 24 baked floors; each contains baked chest_values
                                            (chest_base_value × zone_mult computed at bake time);
                                            floor grid = 20×14 tiles; 7 hand-built + 17 assembled
    classes/ warrior/valkyrie/wizard/elf .tres — ClassDef resources (include potion_type field)
    enemies/ ghost/grunt/demon/lobber/sorcerer/death .tres — EnemyDef resources
    generators/ drowned/cinder/starved/throne .tres — GeneratorDef resources
    hazards/ flame_jet/void_bridge/collapsing_void .tres — HazardDef resources

  tools/                                  — BUILD-TIME ONLY; nothing here becomes runtime logic
    floor_baker.gd                        — cell assembly; 200-attempt cap; --seed <int> required;
                                            command: godot --headless --script tools/floor_baker.gd --
                                            --output data/floors/base/ --tunables Tunables.json
                                            --seed 12345; failure writes bake_failure.json with
                                            attempted layouts and failed gate IDs; exit code 1
    solver.gd                             — calls core/rules_solver_check.gd for gates 1–9;
                                            --check-band-extremes flag runs gates at min/max of each
                                            tunable band; failing extremes narrow the band;
                                            command: godot --headless --script tools/solver.gd --
                                            --floors data/floors/base/ --tunables Tunables.json
                                            [--check-band-extremes]
    attract_capture.gd                    — bakes attract.replay from seed 0xDEAD, Warrior, floor 1;
                                            runs greedy-killer bot, records semantic actions,
                                            solver-validates, writes hungerhall_replay_v1;
                                            command: godot --headless --script tools/attract_capture.gd --
                                            --output Assets/Replays/attract.replay --seed 57005
    cells/                                — 48 authored 10×7-tile cells + 7 hand-built definitions

  ci/                                     — MACHINE EVIDENCE SEAMS
    sneferu_bot.gd                        — class_name SneferuBot (RefCounted): invoked by main.gd in
                                            bot mode; drives RulesSession directly; three policies;
                                            writes playtest_telemetry_v1 atomically.
                                            ARCHITECTURE SKILL WAIVER: ci/sneferu_bot.gd is a RefCounted
                                            class invoked by main.gd within the SceneTree context, not
                                            a detached --script entry. This satisfies the skill's
                                            intent (same RulesSession API, not a parallel simulation)
                                            while allowing the configured main scene to own bot-mode
                                            lifecycle per the domain contract.
    sneferu_visual.gd                     — optional visual capture helper
    sneferu_visible_asset.json            — governed PNG anchor receipt

  tests/                                  — DETERMINISTIC, AUTOMATABLE (19 suites + runner)
    test_runner.gd                        — headless entry; runs without autoloads; instantiates core/
                                            directly; for SSM-dependent tests, instantiates SSM as regular
                                            Node with mock deps and calls tick_once() directly;
                                            exits non-zero on any failure
    test_state_machine.gd                 — all 12 states, all transitions incl. Title→Settings, LAR-3
    test_combat.gd                        — class kits, damage, pierce/splash, class distinctness
    test_enemy_ai.gd                      — six AI contracts
    test_generators.gd                    — caps 6/28, cadence bands
    test_hazards.gd                       — three hazard contracts
    test_continue.gd                      — floor reset exactness, token decrement
    test_save.gd                          — schema v1, migration, atomicity, mid-floor no-save
    test_replay.gd                        — seed + actions → SHA-256 identical; hold-until-change
    test_score.gd                         — reward table, death penalty, chest determinism
    test_balance_sim.gd                   — 600 games (200 × 3 policies, in-process); includes
                                            softlock detection (has_legal_action assertions)
    test_tunables.gd                      — schema, bands, steps, affects validation
    test_accessibility.gd                 — reduced-motion, caption timing, contrast hex pairs,
                                            G3 string style validation, settings values
    test_floor_solver.gd                  — re-verifies gates 1–9 on all 24 floors
    test_exit_overlap.gd                  — 3-frame consecutive; 2 does not clear
    test_fixed_timestep.gd                — 60Hz; no wall-clock; pause/resume no jump
    test_attract_replay.gd                — deterministic playback; SHA-256 identical
    test_modals.gd                        — modal transition logic via mock SSM
    test_assets.gd                        — reads ASSET_MANIFEST.json; fails on delivery_debt>0 for
                                            required slots; verifies ResourceLoader.load succeeds for
                                            each required asset; checks scene-binding references
    test_audio.gd                         — verifies every procedural cue in §13.2 produces non-silent
                                            AudioStreamWAV (PCM data has non-zero samples); sfx_vol=0
                                            results in silent playback; sfx_vol=100 produces audible
    test_presentation.gd                  — validates presentation_contract.json schema; palette hex
                                            values parse to valid Color; ui_regions within [0,1] bounds
                                            and non-overlapping; frame_floors within valid ranges

  Assets/
    ASSET_MANIFEST.json                   — G4 Forge manifest; delivery_debt per slot
    GODOT_IMPORT_MANIFEST.json            — committed import state
    Sprites/ Tilesets/ Audio/             — Forge-seeded/operator-supplied files
    Replays/attract.replay                — seed 0xDEAD, Warrior, floor 1; hungerhall_replay_v1;
                                            baked by tools/attract_capture.gd

  Fonts/
    silkscreen_regular.ttf silkscreen_bold.ttf — SIL OFL 1.1
    font_8/16/24/32.tres announcer_font.tres — FontFile; AA=NONE, hinting=NONE
```

**Adversary pre-emption.** No `Utils`, `Helpers`, `Common`, or `Misc` directories. Every file has one responsibility. `core/` imports nothing outside GDScript standard library. `app/` imports `core/` only. `main.gd` wires app-layer nodes to SSM via setters — SSM does NOT create scene nodes. `scenes/` imports `app/` (for `ssm.request()` verb calls) AND `core/` (for snapshot Dictionaries + TunablesLoader). `world/` imports `core/` only. `tests/` import `core/` + `app/` (NO `tools/`). `tools/` imports `core/` + data defs. **Dependency direction:** `core/` ← `app/` ← {`ci/`, `tests/`, `scenes/`}; `core/` ← {`scenes/`, `world/`, `ui/`}. No module imports back from its caller.

---

## 3. Module boundaries

### 3.1 Enum definitions (state_enums.gd)

```gdscript
# State enum — 12 session states
enum State {
    SPLASH = 0, TITLE = 1, CLASS_SELECT = 2, PLAYING = 3,
    PAUSED = 4, SETTINGS = 5, HALL_OF_HEROES = 6,
    DYING = 7, CONTINUE_OFFER = 8, GAME_OVER = 9,
    FLOOR_RESULTS = 10, CAMPAIGN_RESULTS = 11
}

# SceneId enum — 22 scene identifiers (12 screens + 10 modals)
enum SceneId {
    SPLASH = 0, TITLE = 1, CLASS_SELECT = 2, PLAY = 3,
    PAUSED = 4, SETTINGS = 5, HALL_OF_HEROES = 6,
    DYING = 7, CONTINUE_OFFER = 8, GAME_OVER = 9,
    FLOOR_RESULTS = 10, CAMPAIGN_RESULTS = 11,
    MODAL_QUIT_WARN = 12, MODAL_NEWGAME_WARN = 13,
    MODAL_ERASE_WARN = 14, MODAL_RESET_WARN = 15,
    MODAL_REMAP_CAPTURE = 16, MODAL_CREDITS_POP = 17,
    MODAL_PRIVACY_POP = 18, MODAL_PAD_LOST = 19,
    MODAL_SAVE_FAIL = 20, MODAL_FLOOR_MISSING = 21
}

# Verb enum — 21 transition verbs
enum Verb {
    PRESS = 0, RESUME = 1, CHOOSE = 2, PAUSE = 3,
    QUIT = 4, CLEAR = 5, FINISH = 6, ADVANCE = 7,
    SAVE_QUIT = 8, ENTER = 9, DRAIN = 10, PROMPT = 11,
    CONTINUE = 12, EXPIRE = 13, BACK = 14, SETTINGS = 15,
    RETRY = 16, SKIP = 17, CONFIRM = 18, CANCEL = 19,
    TIMEOUT = 20
}

# ClassType enum — 4 classes
enum ClassType { WARRIOR = 0, VALKYRIE = 1, WIZARD = 2, ELF = 3 }

# EnemyAIType enum — 6 AI types
enum EnemyAIType {
    GHOST = 0, GRUNT = 1, DEMON = 2,
    LOBBER = 3, SORCERER = 4, DEATH = 5
}

# HazardType enum — 3 hazard types
enum HazardType { FLAME_JET = 0, VOID_BRIDGE = 1, COLLAPSING_VOID = 2 }

# TriggerType enum — 3 trigger types
enum TriggerType { PERIODIC = 0, PHASED = 1, PLAYER_STEP = 2 }

# PotionType enum — 4 class-specific potion effects
enum PotionType { WHIRLWIND = 0, AEGIS = 1, NOVA = 2, VOLLEY = 3 }
```

**Class-to-potion mapping:** Warrior→WHIRLWIND, Valkyrie→AEGIS, Wizard→NOVA, Elf→VOLLEY. Each class has a unique `potion_type` integer (0–3), ensuring the distinctness tuple `(hp, speed, shot_dmg, shot_range, shot_rate, potion_type)` is mechanically distinct for all four classes.

### 3.2 TransitionTable (complete entries with condition vocabulary)

**Condition vocabulary** (evaluated by `SessionStateMachine` before approving a transition):

| Condition string | Predicate |
|---|---|
| `"always"` | No precondition |
| `"save_exists"` | `SaveStore.read_campaign()` returns valid data |
| `"no_save"` | `SaveStore.read_campaign()` returns empty/invalid |
| `"hp_zero"` | `RulesSession.snapshot()["hp"] <= 0` |
| `"exit_overlap_3 AND floor_lt_24"` | `_exit_overlap_count >= 3 AND current_floor < 24` |
| `"exit_overlap_3 AND floor_eq_24"` | `_exit_overlap_count >= 3 AND current_floor == 24` |
| `"tokens_gt_0 AND yes"` | `tokens > 0 AND continue_selection == YES` |
| `"no OR timeout OR tokens_eq_0"` | `continue_selection == NO OR _continue_timer <= 0 OR tokens == 0` |
| `"dying_complete"` | `_dying_step_count >= 72` (normal) or `>= 12` (reduced motion) |
| `"splash_complete_or_skippable"` | `_splash_step_count >= 72 OR (input_received AND _splash_step_count >= 18)` |
| `"entered_from_paused"` | `_settings_entry_screen == PAUSED` |
| `"entered_from_title"` | `_settings_entry_screen == TITLE` |

**Complete transition table:**

| # | From | Verb | To | Condition |
|---|---|---|---|---|
| 1 | SPLASH | PRESS | TITLE | `splash_complete_or_skippable` |
| 2 | TITLE | PRESS | CLASS_SELECT | `always` (NEW GAME) |
| 3 | TITLE | RESUME | PLAYING | `save_exists` (CONTINUE) |
| 4 | TITLE | SETTINGS | SETTINGS | `always` |
| 5 | TITLE | BACK | HALL_OF_HEROES | `always` |
| 6 | HALL_OF_HEROES | BACK | TITLE | `always` |
| 7 | CLASS_SELECT | CHOOSE | PLAYING | `always` (class locked) |
| 8 | PLAYING | PAUSE | PAUSED | `always` |
| 9 | PAUSED | RESUME | PLAYING | `always` |
| 10 | PAUSED | SETTINGS | SETTINGS | `always` |
| 11 | PAUSED | QUIT | TITLE | `always` (modal confirmed) |
| 12 | SETTINGS | BACK | PAUSED | `entered_from_paused` |
| 13 | SETTINGS | BACK | TITLE | `entered_from_title` |
| 14 | PLAYING | CLEAR | FLOOR_RESULTS | `exit_overlap_3 AND floor_lt_24` |
| 15 | PLAYING | FINISH | CAMPAIGN_RESULTS | `exit_overlap_3 AND floor_eq_24` |
| 16 | FLOOR_RESULTS | ADVANCE | PLAYING | `always` |
| 17 | FLOOR_RESULTS | SAVE_QUIT | TITLE | `always` |
| 18 | CAMPAIGN_RESULTS | ENTER | TITLE | `always` |
| 19 | PLAYING | DRAIN | DYING | `hp_zero` |
| 20 | DYING | PROMPT | CONTINUE_OFFER | `dying_complete` |
| 21 | CONTINUE_OFFER | CONTINUE | PLAYING | `tokens_gt_0 AND yes` |
| 22 | CONTINUE_OFFER | EXPIRE | GAME_OVER | `no OR timeout OR tokens_eq_0` |
| 23 | GAME_OVER | RETRY | PLAYING | `always` (LAR-3) |
| 24 | GAME_OVER | ENTER | TITLE | `always` |
| 25 | TITLE | CONFIRM | PLAYING | `save_exists` (CONTINUE, same as row 3) |

### 3.3 pending_events schema

`RulesSession.consume_pending()` returns `{cues: Array[Dictionary], events: Array[Dictionary]}`. Each event Dictionary:

```json
{
  "type": "StringName",     // e.g., "generator_destroyed", "player_hit", "floor_clear",
                            // "food_consumed", "key_collected", "potion_used",
                            // "door_opened", "chest_opened", "throw", "projectile_hit",
                            // "death", "zone_entry"
  "step": 42,               // int: step at which event occurred
  "position": [320, 224],   // Vector2 as [x, y] in world pixels
  "entity_id": 3,           // int: ID of affected entity (0=player, >0=enemy/gen/pickup)
  "amount": 150             // int: damage, score value, HP restore, etc. (0 if N/A)
}
```

Each cue Dictionary: `{"cue_id": "StringName", "step": int}`.

### 3.4 RulesSession internal composition

`RulesSession` (RefCounted) owns these internal fields, all initialized in `setup_campaign()`:

| Field | Type | Purpose |
|---|---|---|
| `_floor` | `RulesFloor` | Current floor state (null when not PLAYING) |
| `_player` | `RulesPlayer` | Player state: HP, position, facing, cooldowns, potions, keys |
| `_enemies` | `Array[RulesEnemy]` | Active enemies on current floor |
| `_generators` | `Array[RulesGenerator]` | Active generators on current floor |
| `_hazards` | `Array[RulesHazard]` | Active hazards on current floor |
| `_projectiles` | `Array[RulesProjectile]` | Active projectiles (player + enemy) |
| `_pickups` | `RulesPickup` | Pickup state manager: food, keys, potions, chests, doors |
| `_score` | `RulesScore` | Score tracker: cumulative score, kills, death penalties |
| `_tunables` | `TunablesLoader` | Loaded tunables (passed in at construction) |
| `_prng` | `PrngSeeder` | Session-level PRNG (for non-floor randomness) |
| `_state` | `int` (State enum) | Current session state |
| `_step_count` | `int` | Total steps since floor load |
| `_kills` | `int` | Total kills this floor |
| `_shots_fired` | `int` | Total shots this floor |
| `_death_cause` | `String` | null/"drain"/"contact"/"hazard"/"step_limit" |
| `_pending_cues` | `Array[Dictionary]` | Buffered cues (drained by consume_pending) |
| `_pending_events` | `Array[Dictionary]` | Buffered events (drained by consume_pending) |
| `_exit_overlap_count` | `int` | Consecutive frames of exit overlap |
| `_class_type` | `int` (ClassType enum) | Locked class for this campaign |
| `_campaign_seed` | `int` | Seed for this campaign |
| `_current_floor` | `int` | Current floor index (1-based) |
| `_tokens` | `int` | Continue tokens remaining |
| `_potions` | `int` | Potion inventory |
| `_keys` | `int` | Key inventory |

`step()` delegates to: `_player.update(_tunables)` (drain, cooldowns) → `_enemies` AI → `_generators` spawn check → `_hazards` update → `_projectiles` move/collide → `RulesCombat.resolve()` → `_pickups` overlap → `RulesScore.update()` → `_check_transitions()`. Each sub-system appends to `_pending_cues` and `_pending_events`.

### 3.5 `core/` — Pure deterministic simulation

- **Types:** `RulesSession`, `TransitionTable`, `RulesFloor`, `RulesPlayer`, `RulesEnemy`, `RulesGenerator`, `RulesHazard`, `RulesProjectile`, `RulesCombat` (static), `RulesScore`, `RulesPickup`, `RulesContinue`, `RulesReplay`, `RulesSolverCheck` (static), `SaveCodec`, `TunablesLoader`, `PrngSeeder`, Resource subclasses, `StateEnums`. All `RefCounted` or `Resource`.
- **IS responsible for:** The whole deterministic truth of a run at fixed 60 Hz. HP, score, spawns, hazards, damage, transition legality (data table), combat, scoring, continue/respawn, save encode/decode, replay serialization, tunables parsing, solver gate verification, resource definitions. Owns seeded PRNG via `RulesFloor`. Produces `pending_cues` and `pending_events` arrays in snapshot.
- **IS NOT responsible for:** Pixels, input polling, audio playback, disk writes, scene management, UI rendering, CueBus dispatch.
- **Public API:**
  - `RulesSession.setup_campaign(seed: int, class_type: int, tunables: TunablesLoader) → void`
  - `RulesSession.load_floor(floor_index: int) → void` — loads baked FloorData; resets tokens to `tokens_per_floor`
  - `RulesSession.continue_floor() → void` — **decrements tokens by 1**; rebuilds current floor; HP=50% max; potions=0; keys=0; food NOT restored; generators full
  - `RulesSession.retry_floor() → void` — resets tokens to `tokens_per_floor`; rebuilds current floor; HP=class max; potions=0; keys=0
  - `RulesSession.input(action: Dictionary) → void` — action = `{move: Vector2, attack: bool, potion: bool}`; NO pause field
  - `RulesSession.step() → void` — no delta parameter; one step = 1/60s; only called by SSM when `current_screen == PLAYING`
  - `RulesSession.snapshot() → Dictionary` — includes: `state`, `hp`, `score`, `floor`, `position`, `facing`, `enemies`, `generators`, `tokens`, `potions`, `keys`, `food_positions`, `key_positions`, `door_positions`, `exit_position`, `hazards`, `projectiles`, `step_count`, `kills`, `shots_fired`, `death_cause`, `pending_cues`, `pending_events`. Does NOT clear pending arrays.
  - `RulesSession.consume_pending() → Dictionary` — returns `{cues: Array, events: Array}` and clears both internal buffers (destructive read)
  - `RulesSession.has_legal_action() → bool` — returns true if ANY of: (a) move in any of 8 directions where destination tile is not WALL/locked-door, (b) throw if `_player.shot_cooldown_steps <= 0`, (c) potion if `_player.potions > 0`. Used by softlock detection.
  - `RulesSession.step_count → int` (read-only)
  - `RulesSession.kills → int` (read-only)
  - `RulesSession.shots_fired → int` (read-only)
  - `RulesSession.death_cause → String` (read-only: null/"drain"/"contact"/"hazard"/"step_limit")
  - `TunablesLoader.get(name: String) → Variant`
  - `SaveCodec.encode(dict) → String`; `SaveCodec.decode(json) → Dictionary` (returns `{success, data, needs_migration_notice}`)
  - `RulesSolverCheck.verify_floor(floor_data: FloorData, tunables: TunablesLoader) → Dictionary` (returns `{passed: bool, failed_gates: Array[String]}`)
  - `RulesReplay.hash_snapshot(snapshot: Dictionary) → String` — SHA-256 via `HashingContext` with `HASHING_ALGORITHM_SHA256` over canonical JSON (keys sorted alphabetically, no whitespace, non-JSON-native types converted: Vector2 → `[x, y]`, Color → `[r, g, b, a]`, StringName → String, enum → int)
- **Imports:** Nothing outside `core/`.

### 3.6 `app/` — Controller layer

- **Types:** `SessionStateMachine` (sole autoload, NO class_name), `SceneRouter`, `InputMapper`, `SaveStore`, `ProfileStore`, `ScoreStore`, `SettingsStore`, `Announcer`, `CueBus`, `AudioDirector`, `JuiceDirector`.
- **IS responsible for:** Translation between engine reality and core. Flow relay. Save writing (campaign, profile, scores, settings — each on its own atomic path). Cue dispatch. Bark queue. Juice direction. Procedural audio gap cues. Rumble emission. Freeze-frame counter (SSM-internal).
- **IS NOT responsible for:** Damage math, spawn logic, layout decisions, transition legality (data table in `core/`), rendering, direct scene script imports.
- **Public API (SessionStateMachine):**
  - `set_scene_router(router: SceneRouter) → void`
  - `set_cue_bus(bus: CueBus) → void`
  - `set_audio_director(director: AudioDirector) → void`
  - `set_juice_director(director: JuiceDirector) → void`
  - `set_input_mapper(mapper: InputMapper) → void`
  - `set_save_store(store: SaveStore) → void`
  - `set_profile_store(store: ProfileStore) → void`
  - `set_score_store(store: ScoreStore) → void`
  - `set_settings_store(store: SettingsStore) → void`
  - `set_announcer(announcer: Announcer) → void`
  - `request(verb: StringName, params := {}) → void`
  - `current_screen → int` (read-only; returns State enum value)
  - `set_campaign_seed(seed: int) → void`
  - `tick_once() → void` — **public test API**: performs one SSM internal step (process timers, advance rules if PLAYING, check transitions, dispatch cues/events). `_physics_process(delta)` calls `tick_once()` in production. Tests call `tick_once()` directly without a running SceneTree.
  - `freeze_steps_remaining → int` (internal counter; when > 0, `step()` is skipped and counter decremented)
- **Public API (SceneRouter):** `@export var scene_map: Dictionary` (SceneId enum → PackedScene); `mount(scene_id: int) → void`; `hide(scene_id: int) → void`; `current_scene_id → int` (read-only); `get_active_scene() → Node` — returns the currently mounted screen Node or null
- **Public API (CueBus):** `emit(cue_id: StringName, params := {}) → void`; `emitted_log: Array[Dictionary]`
- **Public API (SaveStore):** `write_campaign(data: Dictionary) → bool`; `write_profile(data: Dictionary) → bool`; `write_scores(data: Dictionary) → bool`; `write_settings(data: Dictionary) → bool`; `read_campaign() → Dictionary`; `read_profile() → Dictionary`; `read_scores() → Dictionary`; `read_settings() → Dictionary`; `erase_all() → bool`; `erase_settings() → bool`
- **Public API (JuiceDirector):** `trigger_freeze(steps: int) → void` (sets `ssm.freeze_steps_remaining`); `rumble(pattern: String, intensity: float) → void` (scales by `settings.rumble_intensity`; 0 = off); `set_settings_store(store: SettingsStore) → void` (for rumble scaling)
- **Public API (AudioDirector):** `play_cue(cue_id: StringName) → void` (scales volume by `settings.sfx_vol / 100.0`; `sfx_vol = 0` silences)
- **Imports:** `core/` only.

### 3.7 `scenes/` — Thin projections

- **Types:** One `.tscn` + `.gd` pair per screen and modal (12 screens, 10 modals).
- **IS responsible for:** Snapshot → pixels and intent → `SessionStateMachine.request(...)`. `play.gd` exposes `consume_events(events: Array) → void` which forwards events to `WorldView.consume_events()`. `title.gd` MUST load `res://Assets/Replays/attract.replay` and drive an isolated `RulesSession` from recorded actions at 30Hz — this attract session is isolated from the game session and drives only the AttractViewport's inner WorldView. The "MAY" from prior drafts is replaced with "MUST."
- **IS NOT responsible for:** A second truth store, rules engine, direct caller of other screens, save logic.
- **Imports:** `app/` (for `ssm.request()` verb calls), `core/` snapshot Dictionaries (read-only), `core/` TunablesLoader. `title.gd` also imports `core/` RulesSession + RulesReplay for attract playback (explicitly required).

### 3.8 `world/` — World projection

- **Types:** `WorldView`, `ActorSprites`, `CameraRig`, `LifeLight`, `Particles`, `Floaters`.
- **IS responsible for:** Node2D dressing of Play snapshot. `WorldView.consume_events(events)` processes `pending_events` for visual juice (particles, floaters, trauma). Reads juice constants from `TunablesLoader`.
- **IS NOT responsible for:** Game state, AI, timing authority, CueBus dispatch, direct app/ calls.
- **Imports:** `core/` snapshot Dictionaries and `core/` TunablesLoader only.

### 3.9 `ui/` — Themed Control widgets

- **Types:** Theme, StyleBox, HUD, caption band, continue ring, initials, idle prompts, guestbook, glyphs.
- **Imports:** `core/` TunablesLoader (for caption timing only).

### 3.10 `data/`, `tools/`, `ci/`, `tests/`

- **`data/`:** Baked resources + JSON manifests. `strings.json` categories: `"bark"`, `"caption"`, `"ui"`, `"credits"`, `"privacy"`. Accessed via `ResourceLoader.load("res://data/...")` or `FileAccess.open("res://data/...")`.
- **`tools/`:** `FloorBaker` (requires `--seed <int>`), `Solver` (calls `core/rules_solver_check.gd`; `--check-band-extremes` flag), `AttractCapture` (bakes `attract.replay`). Imports `core/` + data defs.
- **`ci/`:** `SneferuBot` (RefCounted, invoked by `main.gd`). Public API: `SneferuBot.run(session: RulesSession, policy: String, telemetry_path: String, games: int, seed: int, frame_budget: int) → void`. CLI args via `OS.get_cmdline_user_args()`: `--telemetry-out <abs> --games <int> --seed <int> --frame-budget <int> --policy <string>`. Invalid args → stderr error + exit code 2, no telemetry written. Game crashes caught and recorded in `errors[]`. Architecture skill waiver documented in §2 layout.
- **`tests/`:** 19 test modules + `test_runner.gd`. Runs without autoloads. SSM-dependent tests instantiate `SessionStateMachine` as a regular `Node` with mock dependencies and call `tick_once()` directly.

---

## 4. State management approach

**1. Pure simulation Core.** All game logic lives in `core/` `RefCounted` objects with no `Node`, `Control`, `Viewport`, `Input`, `AudioStream`, or frame-rate dependency. `RulesSession` is the single entry point. Input arrives as semantic actions: `{move: Vector2, attack: bool, potion: bool}` — pause is an app-level verb. The core advances one fixed step per `RulesSession.step()` call (no delta parameter; one step = 1/60s). All randomness flows from `RulesFloor`'s seeded `RandomNumberGenerator` initialized via `PrngSeeder.from_int(seed)`.

**Seed hierarchy:**
- Campaign seed: bot/journey receives `--seed`; player campaign seed = `Time.get_ticks_msec()` at ClassSelect→Playing (stored in save). `main.gd` reads `--seed` or `--journey-seed` from `OS.get_cmdline_user_args()` if present and calls `ssm.set_campaign_seed(seed)`.
- Floor seed: `campaign_seed XOR (floor_index * 0x1000)` — deterministic per floor, same across continue/retry.
- Balance sim per-game seed: `game_seed = campaign_seed + game_id`; floor seed derived as above. Pinned for deterministic reproducibility.
- Attract: seed 0xDEAD (57005) frozen in `attract.replay` at bake time — NOT a tunable.

**Snapshot + drain semantics:** `RulesSession.snapshot()` returns a read-only Dictionary including `pending_cues` and `pending_events` but does NOT clear them. `RulesSession.consume_pending() → Dictionary` performs a destructive read. `SessionStateMachine` calls `snapshot()` for state, then `consume_pending()` for events/cues, dispatching cues to `CueBus` and events to the active screen's `consume_events()` via `SceneRouter.get_active_scene()`.

**2. Application/controller layer.** `SessionStateMachine` (single autoload, NO class_name) owns the 12 session states. It does NOT create scene nodes. `main.gd` is the composition root: in `_ready()`, it gets `@onready` references to all app-layer children of `Main` and calls `ssm.set_*()` for each. The SSM then: derives semantic actions from `InputMap` via `InputMapper`, calls `RulesSession.input(...)`, advances core via `tick_once()`, reads snapshot + `consume_pending()`, dispatches to `CueBus`/`JuiceDirector`/active scene, and approves transitions via `TransitionTable`. This layer contains no rules.

**`tick_once()` — the injectable clock (OBL-2/OBL-39/OBL-63/OBL-82):**
```gdscript
func tick_once() -> void:
    # 1. Process step-counted timers (splash, dying, continue_offer)
    _process_timers()
    # 2. Check joypad disconnect (pad_lost trigger)
    _check_joypad()
    # 3. Advance rules ONLY when current_screen == PLAYING
    if current_screen == State.PLAYING and _freeze_steps_remaining <= 0:
        _rules.input(_pending_action)
        _rules.step()
    elif _freeze_steps_remaining > 0:
        _freeze_steps_remaining -= 1  # clock pauses during freeze
    # 4. Read snapshot + consume_pending
    _last_snapshot = _rules.snapshot()
    var pending = _rules.consume_pending()
    # 5. Dispatch cues to CueBus
    for cue in pending.cues:
        _cue_bus.emit(cue.cue_id)
    # 6. Dispatch events to JuiceDirector (rumble) + active scene
    _juice_director.process_events(pending.events)
    var active = _scene_router.get_active_scene()
    if active and active.has_method("consume_events"):
        active.consume_events(pending.events)
    # 7. Check transitions
    _check_transitions()
```
In production, `_physics_process(delta)` calls `tick_once()`. In tests, `test_runner.gd` calls `ssm.tick_once()` directly — no SceneTree required.

**Step advancement invariant (OBL-49/OBL-62):** `RulesSession.step()` is called **ONLY** when `current_screen == PLAYING` AND `_freeze_steps_remaining == 0`. All other states (Paused, Dying, ContinueOffer, FloorResults, GameOver, CampaignResults, Settings, HallOfHeroes, Title, Splash, ClassSelect) do NOT advance the simulation. Step-counted timers (splash, dying, continue_offer) are SSM-internal counters advanced in `_process_timers()` regardless of rules advancement.

**Freeze-frame mechanism (OBL-8/OBL-25/OBL-56/OBL-63/OBL-86):** The freeze is an **SSM-internal counter**, not a reverse signal from JuiceDirector. When SSM processes events from `consume_pending()` and encounters a freeze-triggering event (`generator_destroyed`, `player_hit`), it sets `_freeze_steps_remaining = round(tunables.juice_freeze_frame_s * 60)`. While `_freeze_steps_remaining > 0`, `step()` is not called — **the simulation clock pauses** (corrected from prior "unaffected" wording). The counter decrements each `tick_once()`. JuiceDirector handles ONLY rumble and visual juice (particles, trauma) — it does NOT signal SSM to freeze. One direction: SSM reads events → SSM sets counter. JuiceDirector.trigger_freeze(steps) is retained as a convenience API that sets `ssm.freeze_steps_remaining` directly, called by SSM itself (not by scenes).

**Under reduced motion (OBL-22/OBL-76):** `_freeze_steps_remaining` is always 0 — freeze-frames are fully disabled, satisfying GDD Q10's "disable freeze-frames." Screenshake amplitude is 0. Vignette replaces hit flash.

**Continue token accounting (OBL-18/OBL-66):**
- `load_floor()`: tokens reset to `tokens_per_floor` (2) at each floor entry (ClassSelect→Playing and FloorResults→Advance)
- `continue_floor()`: **tokens -= 1**; floor rebuilt from baked data; HP = 50% class max; potions = 0; keys = 0; food stays consumed; generators reset to full
- `retry_floor()`: tokens reset to `tokens_per_floor` (2); floor rebuilt; HP = class max; potions = 0; keys = 0
- When tokens == 0 at ContinueOffer entry: auto-expire after 120 steps (no input needed)

**3. Thin projection.** Screens and world view read the snapshot and render. `WorldView.consume_events()` processes `pending_events` for visual juice. `play.gd.consume_events(events)` forwards events to WorldView. A scene is never a second truth store.

**4. Navigation owner.** `SceneRouter` (child of `Main`) manages screen visibility. `@export scene_map: Dictionary` maps `SceneId` enum values to `PackedScene` resources, authored in the editor. `TransitionTable` in `core/` is the single legality authority. `SessionStateMachine` checks the table and calls `router.mount(scene_id)` / `router.hide(scene_id)`. `SceneRouter.get_active_scene()` returns the currently mounted Node for event dispatch.

**Input buffering justification (OBL-3):** Zero input buffering is a deliberate design choice. The fixed 60 Hz physics step means maximum input latency is 1 frame (16.67 ms), well under the 100 ms acknowledgment threshold. Throw and potion are discrete actions fired on press frame, not held. Movement is a continuous 8-way vector read each physics frame. A buffer would add complexity without reducing effective latency at 60 Hz.

**Pause process-mode contract (OBL-19/OBL-20/OBL-21/OBL-62):** Uses exact Godot 4.7 `ProcessMode` constants:

| Node | Process mode | Rationale |
|---|---|---|
| SessionStateMachine (autoload) | `PROCESS_MODE_ALWAYS` | Must detect pause input, manage state, run timers |
| Main (main.gd) | `PROCESS_MODE_ALWAYS` | Bot-mode lifecycle, wiring |
| SceneRouter | `PROCESS_MODE_ALWAYS` | Must mount/hide screens during pause |
| InputMapper | `PROCESS_MODE_ALWAYS` | Must read pause/confirm/joypad disconnect |
| CueBus | `PROCESS_MODE_ALWAYS` | Must dispatch cues during BOTH paused and unpaused |
| AudioDirector | `PROCESS_MODE_ALWAYS` | Must play audio during BOTH paused and unpaused |
| Announcer | `PROCESS_MODE_ALWAYS` | Captions during BOTH paused and unpaused |
| JuiceDirector | `PROCESS_MODE_PAUSABLE` | Juice stops during pause |
| SaveStore/ProfileStore/ScoreStore/SettingsStore | `PROCESS_MODE_ALWAYS` | Must save at any time |
| Splash, Title screens | `PROCESS_MODE_ALWAYS` | Title/attract never paused |
| Play (WorldView, HUD, CaptionBand) | `PROCESS_MODE_PAUSABLE` | Game stops during pause |
| Paused screen | `PROCESS_MODE_ALWAYS` | Active during pause |
| Settings (context-dependent) | SSM sets `PROCESS_MODE_ALWAYS` if entered from Title; `PROCESS_MODE_ALWAYS` if from Paused (settings must remain interactive in both contexts) |
| HallOfHeroes, Dying, ContinueOffer, GameOver, FloorResults, CampaignResults | `PROCESS_MODE_PAUSABLE` | Not reachable during pause; SSM controls visibility |
| All modals | `PROCESS_MODE_ALWAYS` | Modals appear in both paused and unpaused contexts; SSM controls visibility and tree pause state |

Pause mechanism: SSM sets `get_tree().paused = true` on entering Paused; `false` on exit. `tick_once()` skips `RulesSession.step()` when `current_screen != PLAYING`.

*Why this split serves THIS prototype:* The same `RulesSession` path is exercised by player, replay, attract, and bot. Determinism, balance, and replay regression are one testable surface. Godot scenes only project state; the controller only relays intent.

---

## 5. Scene/view hierarchy

```text
Main.tscn (configured project main scene; Main Node with main.gd attached)
  ├─ SceneRouter (Node — authored as child of Main in main.tscn; wired to SSM by main.gd
  │   via ssm.set_scene_router(router); @export scene_map: Dictionary authored in editor)
  │   ├─ Splash (Control)
  │   ├─ Title (Control)
  │   │   ├─ MenuContainer (VBoxContainer)
  │   │   │   ├─ btn_new_game (Button — default focus)
  │   │   │   ├─ btn_continue (Button — disabled if no campaign save; not focusable when disabled)
  │   │   │   ├─ btn_hall_of_heroes (Button)
  │   │   │   ├─ btn_settings (Button)
  │   │   │   ├─ btn_credits (Button)
  │   │   │   └─ btn_privacy (Button)
  │   │   └─ AttractViewport (SubViewport — 320×224; renders attract REPLAY playback)
  │   │       └─ AttractWorldView (WorldView at 0.5× scale; Camera2D zoom=(2,2);
  │   │           title.gd loads attract.replay, creates isolated RulesSession,
  │   │           applies recorded actions at 30Hz (every 2nd physics frame),
  │   │           pending_cues suppressed; loops continuously; no audio;
  │   │           NO live simulation — pure replay playback only)
  │   ├─ ClassSelect (Control)
  │   │   └─ four class cards (TextureRect × 4)
  │   ├─ Play (Node2D — projects RulesSession.snapshot(); exposes consume_events())
  │   │   ├─ WorldView (Node2D — consume_events(events: Array) public method)
  │   │   │   ├─ TileGrid (TileMap)
  │   │   │   ├─ ActorSprites (Node2D)
  │   │   │   ├─ EnemiesContainer (Node2D)
  │   │   │   ├─ GeneratorsContainer (Node2D)
  │   │   │   ├─ HazardsContainer (Node2D)
  │   │   │   ├─ ProjectilesContainer (Node2D)
  │   │   │   ├─ PickupsContainer (Node2D)
  │   │   │   ├─ Floaters (Node2D — pool limit 16)
  │   │   │   ├─ CameraRig (Camera2D — 2px trauma kick)
  │   │   │   ├─ LifeLight (CanvasModulate — ×1.0/×0.80/×0.62)
  │   │   │   └─ Particles (Node2D — pool limit 128)
  │   │   ├─ HUD (Control — CanvasLayer 1)
  │   │   │   ├─ HPNumeral (Label — 32px top-left)
  │   │   │   ├─ ScoreNumeral (Label — 32px top-center)
  │   │   │   ├─ FloorLabel (Label — 16px top-right)
  │   │   │   └─ PotionKeyIcons (HBoxContainer — 16px bottom-left)
  │   │   └─ CaptionBand (Control — CanvasLayer 2)
  │   │       └─ CaptionLabel (Label — 24px Silkscreen, ALL CAPS, 2s min hold)
  │   ├─ Paused (Control — overlay)
  │   │   ├─ ResumeButton (Button — default focus)
  │   │   ├─ SettingsButton (Button)
  │   │   └─ QuitButton (Button)
  │   ├─ Settings (Control — one flat scrollable column, LAR-4)
  │   ├─ HallOfHeroes (Control)
  │   │   └─ GuestbookTable (TabContainer — Standard tab only)
  │   ├─ Dying (Control — overlay, non-interactive, 72/12 steps)
  │   ├─ ContinueOffer (Control — overlay)
  │   │   ├─ ContinueRing (TextureProgressBar — 600-step arc)
  │   │   ├─ YesButton (Button — pre-highlighted)
  │   │   └─ NoButton (Button)
  │   ├─ GameOver (Control)
  │   │   ├─ FinalScore (Label)
  │   │   ├─ InitialsEntry (Control — 3-slot A-Z)
  │   │   ├─ RetryButton (Button — LAR-3 "RETRY FLOOR N")
  │   │   ├─ ScoresButton (Button)
  │   │   └─ TitleButton (Button)
  │   ├─ FloorResults (Control)
  │   │   ├─ TimeLabel / KillsLabel / FoodLabel / ScoreLabel
  │   │   ├─ SavedTag (Label — "SAVED")
  │   │   ├─ NextFloorButton (Button)
  │   │   └─ SaveQuitButton (Button)
  │   ├─ CampaignResults (Control)
  │   │   ├─ CampaignScore (Label)
  │   │   ├─ InitialsEntry (Control — always fires)
  │   │   └─ TitleButton (Button)
  │   └─ modals/ (Control — seize input above parent)
  │       ├─ quit_warn, newgame_warn, erase_warn, reset_warn,
  │       ├─ remap_capture, credits_pop, privacy_pop,
  │       ├─ pad_lost, save_fail, floor_missing
  ├─ CueBus (Node — emitted_log: Array[Dictionary] for journey observation)
  ├─ AudioDirector (Node — procedural tones as in-memory AudioStreamWAV; volume scales by sfx_vol)
  ├─ JuiceDirector (Node — rumble + visual juice; set_settings_store for rumble scaling;
  │                   does NOT own freeze; SSM owns freeze_steps_remaining)
  ├─ InputMapper (Node — sneferu_primary_action contextual resolution; joypad disconnect detection)
  ├─ Announcer (Node — bark queue)
  ├─ SaveStore (Node — atomic write/read to user://)
  ├─ ProfileStore (Node)
  ├─ ScoreStore (Node)
  └─ SettingsStore (Node)
```

**AttractViewport pin (OBL-58):** SubViewport size 320×224 pixels. Inner Camera2D with `zoom = Vector2(2, 2)`. AttractWorldView at 0.5× scale relative to gameplay WorldView. No audio bus routing. Looping playback; no live simulation.

**Attract mode contract (OBL-1/OBL-26/OBL-71/OBL-77):** `title.gd` MUST load `res://Assets/Replays/attract.replay` (schema `hungerhall_replay_v1`, seed 0xDEAD, Warrior, floor 1). It creates an isolated `RulesSession`, calls `setup_campaign(0xDEAD, ClassType.WARRIOR, _tunables)`, `load_floor(1)`, then applies recorded actions from the replay file at 30 Hz (every 2nd physics frame). `pending_cues` are suppressed (not dispatched to CueBus). The session loops by resetting to action[0] when the action list is exhausted. **No live simulation, no live AI, no live bot** — pure replay playback. `attract.replay` is produced by `tools/attract_capture.gd` at build time.

**Cross-reference G5 screen graph:** Splash, Title, ClassSelect, Play, Paused, Settings, HallOfHeroes, Dying, ContinueOffer, GameOver, FloorResults, CampaignResults — all 12 G5 screens present. All 10 G5 modals present. Title menu rows include Continue (with disabled state when no save exists), enabling the Title→Resume→Playing transition.

**Event dispatch path (OBL-9/OBL-57/OBL-66):** SSM `tick_once()` → `consume_pending()` → `SceneRouter.get_active_scene()` → if active scene has `consume_events(events)`, call it → `play.gd.consume_events()` → `WorldView.consume_events()`. This is the sole event dispatch path from core to presentation.

---

## 6. Test plan

### 6.1 Deterministic state-machine tests (`tests/test_state_machine.gd`)

All 12 states driven into, every transition exercised. SSM instantiated as regular Node with MockSceneRouter. Tests call `ssm.tick_once()` directly — no SceneTree required.

| Test | State/Transition | Verification |
|---|---|---|
| `test_splash_to_title` | Splash → Title | 72 tick_once() calls OR input after 18 |
| `test_title_press_to_classselect` | Title → ClassSelect | NEW GAME focused; confirm |
| `test_title_resume_to_playing` | Title → Playing | CONTINUE selected; save exists; next floor loads |
| `test_title_continue_disabled_no_save` | Title (negative) | No save → btn_continue disabled, not focusable |
| `test_title_settings_to_settings` | Title → Settings | SETTINGS selected; SSM sets process_mode ALWAYS |
| `test_classselect_choose_to_playing` | ClassSelect → Playing | Class locked; HP = class max; tokens = 2; potions = 0 |
| `test_playing_pause_to_paused` | Playing → Paused | Esc/Start; drain stops; no time jump on resume |
| `test_paused_resume_to_playing` | Paused → Playing | Same input; fixed 60 Hz resumes |
| `test_paused_settings_to_settings` | Paused → Settings | Settings selected; SSM sets process_mode ALWAYS |
| `test_settings_back_to_paused` | Settings → Paused | Back; return to Paused (not Title) |
| `test_settings_back_to_title` | Settings → Title | Back; return to Title (if entered from Title) |
| `test_title_hallofheroes_to_hoh` | Title → HallOfHeroes | Scores selected; Standard tab |
| `test_hoh_back_to_title` | HallOfHeroes → Title | Back |
| `test_paused_quit_to_title` | Paused → Title | quit_warn confirmed; no save written |
| `test_playing_clear_to_floorresults` | Playing → FloorResults | 3-frame overlap AND floor < 24 |
| `test_playing_finish_to_campaignresults` | Playing → CampaignResults | 3-frame overlap AND floor == 24 |
| `test_playing_clear_two_frames_no_clear` | Playing (negative) | 2 frames does NOT trigger |
| `test_floorresults_advance_to_playing` | FloorResults → Playing | Autosave on entry; next floor; tokens reset to 2 |
| `test_floorresults_savequit_to_title` | FloorResults → Title | Autosave preserved |
| `test_campaignresults_enter_to_title` | CampaignResults → Title | Initials committed; classes_cleared updated |
| `test_playing_drain_to_dying` | Playing → Dying | HP 0; transition within 1 frame |
| `test_dying_prompt_to_continueoffer` | Dying → ContinueOffer | 72 tick_once() normal; 12 reduced |
| `test_continueoffer_continue_to_playing` | ContinueOffer → Playing | YES; tokens decremented; HP 50%; potions 0; keys 0; food consumed; gen full |
| `test_continueoffer_expire_to_gameover` | ContinueOffer → GameOver | Timeout/NO/zero tokens |
| `test_continueoffer_zero_token_auto_expire` | ContinueOffer → GameOver | Tokens == 0: 120 tick_once() auto-expire, no input |
| `test_gameover_retry_to_playing` | GameOver → Playing | LAR-3: HP = class max; tokens = 2; potions = 0 |
| `test_gameover_enter_to_title` | GameOver → Title | Initials committed; save at last completed floor |
| `test_step_only_when_playing` | All non-PLAYING states | step_count does not increment in Paused/Dying/ContinueOffer/etc. |

### 6.2 Additional deterministic rules tests

| Test file | Coverage |
|---|---|
| `test_combat.gd` | Class combat signatures; **class distinctness: no two classes share the same `(hp, speed, shot_dmg, shot_range, shot_rate, potion_type)` tuple**; Warrior whirlwind (4-tile radial, 150 dmg, 8px knockback); Valkyrie aegis (3s invuln + cone reflect); Valkyrie cone (±30° centered on FACING; 100% dmg inside, 50% outside); Wizard nova (6-tile radial, 80 dmg + 2-tile splash); Elf volley (5-projectile fan ±15°); damage resolution; pierce/splash; structure rule; potion half-to-generators; faction mask; contact damage timers (`contact_damage_interval_s` = 30 steps) |
| `test_enemy_ai.gd` | Ghost (speed 100, contact 10, wall-pass); Grunt (speed 80, contact 15, pathfind); Demon (speed 90, contact 20, projectile dmg 25, maintain 4–6 tiles); Lobber (speed 70, contact 15, projectile dmg 20, wall-ignore); Sorcerer (speed 110, contact 20, blink radius 8, cooldown 90 steps); Death (speed 60, contact 50, aura radius 3, aura dmg 5/tick, tick 0.5s, scripted spawn 180 steps) |
| `test_generators.gd` | Per-generator cap 6; per-floor cap 28; independent tracking; cadence bands |
| `test_hazards.gd` | Flame jet (1.0s/2.0s, 0.5s telegraph, 10 dmg/0.5s); void bridge (1.5s/1.5s, 0.3s telegraph, 100 dmg); collapsing_void (PLAYER_STEP, 2.0s removal, 1.0s+0.3s telegraph, 100 dmg); bounce/teleport safe; fatality at HP ≤ 100 |
| `test_continue.gd` | Same floor seed; HP 50%; potions 0; keys 0; food NOT restored; generators full; exit door preserved; **tokens decremented by 1**; retry resets tokens to `tokens_per_floor` |
| `test_save.gd` | Schema v1 (fields per §19); ng_plus=false; migration; atomicity; mid-floor no-save; all SaveStore write/read paths; contrast_mode/text_size valid values |
| `test_replay.gd` | Seed + action list → SHA-256 identical; **hold-until-change semantics: if no action at step N, previous action persists**; codec round-trip; attract.replay loops without drift |
| `test_score.gd` | Reward table: generator = 100 × zone_mult, enemy = 10 × zone_mult, chest = baked value, food/key = 0, floor = 500 × floor_number; **death penalty: 20% of score at moment of death; percentage stays 20%, does not increase**; chest determinism (baked in FloorData) |
| `test_balance_sim.gd` | **In-process** (calls RulesSession.step() directly); **three internal passes, one per policy (greedy-killer, speed-runner, survival-router); 200 games per pass; 600 total**; **per-game seed formula: `game_seed = campaign_seed + game_id`; floor seed = `game_seed XOR (floor * 0x1000)`**; **scheduler: `floor = (game_id % 24) + 1`, `class = (game_id / 24) % 4`** (8–9 games per floor per policy; documented as finite-sample); step limit = 21,600/game; wall-clock budget ≤ 10 min total; **includes softlock detection: zero instances of `has_legal_action() == false AND hp > 0` across all 600 games** (merged from test_softlock.gd — single run, not two); assertions in §8 |
| `test_floor_solver.gd` | Re-verifies gates 1–9 on all 24 floors via `core/rules_solver_check.gd` |
| `test_exit_overlap.gd` | 3 consecutive frames required; 2 does NOT trigger; counter resets |
| `test_fixed_timestep.gd` | 60Hz; no `Time.get_ticks_msec()` in rules; pause/resume no jump; 21,600 steps/floor max |
| `test_attract_replay.gd` | attract.replay SHA-256 identical across N iterations; 30Hz playback; no live simulation |
| `test_tunables.gd` | Schema: every entry has name/value/band/step/affects; **affects values are only "+", "-", or {} (empty object means no declared telemetry target — not necessarily non-gameplay)**; band-clamp enforcement |
| `test_accessibility.gd` | Reduced-motion ON: screenshake = 0, **freeze = 0 steps** (fully disabled per GDD Q10), vignette replaces flash; caption hold ≥ 2.0s; caption text vs strings.json entry; **contrast hex pairs**: (text_bone #E8E4D8, ui_slate #2A2D33) ≥4.5:1; (service_amber #D4A542, void_black #0A0B0D) ≥4.5:1; (text_bone #E8E4D8, void_black #0A0B0D) ≥4.5:1; (critical_brick #B85040, void_black #0A0B0D) ≥4.5:1; **G3 string style: all bark entries ALL CAPS, no exclamation marks, no em-dashes, ≤6 words, present tense, third person**; **settings values: contrast_mode ∈ {default, high_contrast}, text_size ∈ {small, medium, large}** |
| `test_modals.gd` | Modal transition logic via mock SSM: quit_warn (no default, context copy); newgame_warn (fires only with save); erase_warn (double-confirm); reset_warn (settings-only); remap_capture (conflict detection); credits_pop (strings.json text); privacy_pop (strings.json text); pad_lost (always over Paused; auto-pause trigger on joypad disconnect); save_fail (retry ×3 then SkipSave); floor_missing (F1-23 skip N+1, F24 title) |
| `test_assets.gd` | Reads `ASSET_MANIFEST.json`; verifies every required primary-journey slot (player sprites × 4, enemy sprites × 6, generator sprites × 4, zone tilesets × 4, HUD, caption band, UI chrome) has `delivery_debt == 0`; calls `ResourceLoader.load()` on each required asset path and verifies success; checks that scene files reference the correct `semantic_id` bindings |
| `test_audio.gd` | Verifies every procedural cue in §13.2 produces a non-silent `AudioStreamWAV` (PCM data buffer has at least one non-zero sample); `AudioDirector.play_cue()` with `sfx_vol = 0` produces silent playback (volume_db = -80); `sfx_vol = 100` produces audible playback (volume_db = 0) |
| `test_presentation.gd` | Validates `presentation_contract.json` schema: palette hex values parse to valid `Color`; `ui_regions` rects are within [0,1] bounds and non-overlapping; `frame_floors` values within valid ranges (play_area_ratio_floor ≥ 0.0, contrast_floor ≥ 0, dark_scene_p50 ≥ 0) |

### 6.3 GODOT PLAYTEST CONTRACT

The configured main scene recognizes bot arguments after `--` and invokes `ci/sneferu_bot.gd` (RefCounted class) against the same `RulesSession` core. Telemetry written atomically (temp-file + rename) to `--telemetry-out`.

**Pinned command (Criterion 3 — smoke, single-policy 200-game):**
```text
godot --headless --path <project-root> --fixed-fps 60 -- \
  --telemetry-out <absolute-path> --games 200 --seed 1 --frame-budget 21600 --policy greedy-killer
```

`--frame-budget 21600` = max steps per single floor attempt (one bot "game" = one floor attempt). 21,600 steps = 360 seconds at 60 Hz. `--policy` = one of greedy-killer, speed-runner, survival-router. Three separate runs (one per policy) are the only path for Criterion 2 aggregate metrics.

**CI wall-clock budget (OBL-54):** 200 games × max 21,600 steps = max 4,320,000 steps. At `--fixed-fps 60` headless fast-forward (no rendering, no vsync), typical throughput is ≥100,000 steps/sec. Expected wall-clock: ≤ 90 seconds per run. Total for all three Criterion 2 runs: ≤ 5 minutes.

**Telemetry schema for Criterion 3 (`playtest_telemetry_v1` — single-policy, 200 games):**
```json
{
  "schema": "playtest_telemetry_v1",
  "engine_version": "4.7",
  "project_hash": "<SHA-256 per §16 algorithm>",
  "policy": "greedy-killer",
  "games_played": 200,
  "games_completed": 200,
  "per_game": [{"game_id": 0, "class": "warrior", "floor": 1, "policy": "greedy-killer",
    "seed": 2, "outcome": "win", "steps_used": 3600, "step_limit": 21600,
    "hp_at_exit": 450, "kills": 12, "shots_fired": 48, "death_cause": null}],
  "levels": [{"level_id": 1, "plays": 9, "wins": 7, "avg_steps_used": 3600,
    "step_limit": 21600, "dead_boards": 0}],
  "totals": {"win_rate": 0.72, "dead_board_rate": 0.04,
    "per_class_win_rate": {"warrior": 0.74, "valkyrie": 0.70, "wizard": 0.68, "elf": 0.76},
    "wizard_avg_hp_at_exit": 85},
  "errors": [],
  "notes": []
}
```

**`outcome` enumerated values (OBL-15/OBL-43):** `"win"` (floor cleared via exit door), `"death"` (HP reached zero), `"step_limit"` (max steps reached without clearing or dying).

**`dead_board_rate` for Criterion 3 (OBL-17/OBL-89):** Denominator = 24 floor-policy pairs (24 floors × 1 policy). A "dead board" = floor where zero wins occurred. Rate = dead_boards / 24.

**`games_completed`** = number of games that reached a terminal state (win, death, or step_limit) without crashing. Must equal `games_played` for Criterion 3 to pass. **`errors[]`**: any entry fails Criterion 3 — zero errors required.

**Telemetry schema for Criterion 2 (`balance_sim_telemetry_v1` — 600-game aggregate, in-process):**
```json
{
  "schema": "balance_sim_telemetry_v1",
  "engine_version": "4.7",
  "project_hash": "<SHA-256>",
  "policies": ["greedy-killer", "speed-runner", "survival-router"],
  "games_played": 600,
  "games_completed": 600,
  "totals": {
    "win_rate": 0.72,
    "dead_board_rate": 0.03,
    "dominance_spread_pp": 22,
    "wizard_avg_hp_at_exit": 85,
    "per_class_win_rate": {"warrior": 0.74, "valkyrie": 0.70, "wizard": 0.68, "elf": 0.76},
    "min_class_win_rate": 0.68,
    "min_class_avg_hp_at_exit": 62,
    "softlock_count": 0
  },
  "per_policy": [
    {"policy": "greedy-killer", "win_rate": 0.74, "dead_board_rate": 0.04},
    {"policy": "speed-runner", "win_rate": 0.69, "dead_board_rate": 0.02},
    {"policy": "survival-router", "win_rate": 0.73, "dead_board_rate": 0.03}
  ],
  "errors": []
}
```

**`dead_board_rate` for Criterion 2 (OBL-50/OBL-67):** Denominator = 72 floor-policy pairs (24 floors × 3 policies). Rate = dead_boards / 72.

**`dominance_spread_pp` (OBL-50):** `(max_class_win_rate - min_class_win_rate) × 100`, computed across all 600 games. Criterion 2 requires ≤ 30.

**`wizard_avg_hp_at_exit`:** Average HP at exit across Wizard wins only. If zero Wizard wins occur across all 600 games, Criterion 2 FAILS.

**Novelty acceptance thresholds (OBL-91):** Beyond tuple inequality: `dominance_spread_pp ≤ 30`, `min_class_win_rate ≥ 0.40`, `min_class_avg_hp_at_exit ≥ 30`. These verify class distinctness translates to viable, balanced gameplay.

### 6.4 Journey contract (`journey_contract.json`)

```json
{
  "schema": "game_journey_v1",
  "seed": 42,
  "steps": [
    {"step": 1, "action": "launch", "expectations": [
      {"type": "scene_is", "node_path": "/root/Main/SceneRouter", "scene": "splash"}]},
    {"step": 2, "action": "drive_18_steps", "expectations": [
      {"type": "property_equals", "node_path": "/root/Main/SessionStateMachine", "property": "splash_step_count", "value": 18}]},
    {"step": 3, "action": "sneferu_primary_action", "expectations": [
      {"type": "scene_is", "node_path": "/root/Main/SceneRouter", "scene": "title"}]},
    {"step": 4, "action": "sneferu_primary_action", "expectations": [
      {"type": "scene_is", "node_path": "/root/Main/SceneRouter", "scene": "class_select"}]},
    {"step": 5, "action": "sneferu_primary_action", "expectations": [
      {"type": "scene_is", "node_path": "/root/Main/SceneRouter", "scene": "play"},
      {"type": "property_equals", "node_path": "/root/Main/SceneRouter/Play", "property": "is_playing", "value": true},
      {"type": "property_equals", "node_path": "/root/Main/SceneRouter/Play", "property": "hp", "value": 800}]},
    {"step": 6, "action": "move_right", "expectations": [
      {"type": "property_changed", "node_path": "/root/Main/SceneRouter/Play", "property": "player_tile_x"}]},
    {"step": 7, "action": "sneferu_primary_action", "expectations": [
      {"type": "property_changed", "node_path": "/root/Main/SceneRouter/Play", "property": "shots_fired"},
      {"type": "cue_emitted", "node_path": "/root/Main/CueBus", "cue_id": "cue.throw"}]},
    {"step": 8, "action": "pause", "expectations": [
      {"type": "scene_is", "node_path": "/root/Main/SceneRouter", "scene": "paused"}]},
    {"step": 9, "action": "sneferu_primary_action", "expectations": [
      {"type": "scene_is", "node_path": "/root/Main/SceneRouter", "scene": "play"}]},
    {"step": 10, "action": "drive_3600_steps", "expectations": [
      {"type": "scene_is_one_of", "node_path": "/root/Main/SceneRouter", "scenes": ["floor_results", "game_over", "continue_offer", "dying"]},
      {"type": "cue_emitted_one_of", "node_path": "/root/Main/CueBus", "cue_ids": ["cue.floor_clear", "cue.death"]}]}
  ]
}
```

**Splash skip fix (OBL-23/OBL-72):** Step 2 drives 18 steps before step 3 sends `sneferu_primary_action`, satisfying the ≥18-step precondition for splash skip.

**Modal steps (OBL-40):** Steps 8–9 exercise the pause/resume modal flow (Paused is a screen, not a modal; quit_warn would be exercised by selecting Quit from Paused). The journey walks the real screen graph including the pause overlay.

### 6.5 Tunables in the loop

Both the game and `ci/sneferu_bot.gd` load `Tunables.json` at launch via `TunablesLoader`. The bot reads the same constants the game uses.

### 6.6 GDD §10 open questions — verbatim cross-reference

| # | GDD §10 Open Question (verbatim) | Test | Type |
|---|---|---|---|
| 1 | "Does continuous HP drain sustain tension across 24 floors without becoming a slog or a sprint?" | `test_balance_sim.gd` — HP trace; win_rate [0.55, 0.85] | **OP-4 feel** — mechanical proxy: win_rate and avg_steps_used |
| 2 | "Do four classes pay the same HP bill in genuinely distinct risk currencies?" | `test_combat.gd` (class distinctness tuple with `potion_type`) + `test_balance_sim.gd` (dominance_spread_pp ≤ 30, min_class_win_rate ≥ 0.40) | **OP-4 feel** — mechanical proxy: distinctness + dominance + viability |
| 3 | "Does the Valkyrie threat cone close retreat-kiting as a dominant strategy?" | `test_combat.gd` — ±30° cone; 100% inside, 50% outside; retreat = 50% to enemies behind | **Mechanical** |
| 4 | "Does the per-generator alive cap close the room-A-fills-global-cap exploit?" | `test_generators.gd` — per-generator cap 6 independent | **Mechanical** |
| 5 | "Does the solver guarantee spawn-to-key-to-door-to-exit reachability on every floor?" | `test_floor_solver.gd` — gates 1–9 on all 24 floors | **Mechanical** |
| 6 | "Does continue respawn preserve food consumption while zeroing potions and keys?" | `test_continue.gd` — exact verification including token decrement | **Mechanical** |
| 7 | "Does 3-frame exit overlap prevent accidental clears from brushing the door?" | `test_exit_overlap.gd` — 2 does NOT trigger; 3 required | **Mechanical** |
| 8 | "Does the attract replay loop deterministically without drift?" | `test_attract_replay.gd` — SHA-256 identical; replay-only, no live sim | **Mechanical** |
| 9 | "Do announcer captions hold ≥ 2s and mirror spoken words verbatim?" | `test_accessibility.gd` — hold ≥ 2.0s; text vs strings.json entry. **Spoken-word verbatim match DEFERRED until authored audio supplied** (OBL-87) — test marks as SKIP with note when `AUDIO_PRODUCT_MANIFEST.json` has no authored WAV | **Mechanical for timing; DEFERRED for verbatim** |
| 10 | "Does the reduced-motion toggle disable screenshake and freeze-frames?" | `test_accessibility.gd` — shake = 0, **freeze = 0 steps (fully disabled)**, vignette replaces flash | **Mechanical** |

### 6.7 Pinned engine commands

**Criterion 1 — state-machine + rules suites:**
```text
godot --headless --path <project-root> --script tests/test_runner.gd
```

**Criterion 2 — balance sim (in-process, three policy passes within test_balance_sim.gd):**
```text
godot --headless --path <project-root> --script tests/test_runner.gd -- --suite test_balance_sim
```
`test_balance_sim.gd` runs three internal passes (greedy-killer, speed-runner, survival-router), 200 games each, 600 total, in-process via direct `RulesSession.step()` calls. Wall-clock ≤ 10 min. Softlock detection runs within the same 600-game loop (merged, not separate).

**Criterion 3 — headless main-scene bot smoke (single policy, 200 games):**
```text
godot --headless --path <project-root> --fixed-fps 60 -- \
  --telemetry-out <absolute-path> --games 200 --seed 1 --frame-budget 21600 --policy greedy-killer
```

---

## 7. Vertical slice scope

### IN scope

- **Core mechanic:** HP drain as sole game clock
- **Four classes with locked kits:** Warrior (800 HP, bulk, whirlwind: 4-tile radial 150 dmg + 8px knockback, potion=WHIRLWIND), Valkyrie (680 HP, ±30° cone: 100% inside, 50% outside, aegis: 3s invuln + cone reflect, potion=AEGIS), Wizard (520 HP, splash, nova: 6-tile radial 80 dmg + 2-tile splash, potion=NOVA), Elf (560 HP, long-range rapid, volley: 5-projectile fan ±15°, potion=VOLLEY)
- **Manual aimed throws:** 8-direction projectile combat; no auto-attack; no in-run upgrades
- **Full state machine:** 12 states including LAR-3 retry edge; step() advances only during PLAYING
- **24 floors across 4 zones:** DROWNED VAULTS (1–6), CINDERCRYPT (7–12), STARVED DEEP (13–18), THE HOLLOW THRONE (19–24); 20×14 tiles; 7 hand-built + 17 assembled; all solver-passed (gates 1–9)
- **Three hazard types:** flame_jet (PERIODIC), void_bridge (PHASED), collapsing_void (PLAYER_STEP)
- **Six enemy types** with numeric parameters per §6.2
- **Four generator types:** Drowned (HP 60, 3.0s), Cinder (HP 90, 2.5s), Starved (HP 120, 2.0s), Throne (HP 160, 1.5s); cap 6/28
- **Continue system:** 2 tokens per floor (reset each floor); 600-step timer; HP 50% respawn; potions/keys zeroed; food consumed stays consumed; **token decremented on continue**
- **Economy:** food 100 HP; keys open doors; chests hold baked values (chest_base_value × zone_mult, computed at bake time); death penalty: 20% of score at moment of death (percentage stays 20%, does not increase)
- **Score table:** generator = 100 × zone_mult, enemy = 10 × zone_mult, chest = baked value, food/key = 0, floor completion = 500 × floor_number
- **Primary-journey governed art:** player/enemy/generator sprites, tilesets, HUD, caption band, UI chrome — G4 Palette A; loaded via `ResourceLoader.load("res://...")`
- **Real product audio — procedural gap cues:** `AudioDirector` generates procedural tones as in-memory `AudioStreamWAV` resources at boot (pre-computed PCM at 44100 Hz, mono, 16-bit; square/sine/noise waveforms per cue); volume scales by `settings.sfx_vol / 100.0`; `AUDIO_PRODUCT_MANIFEST.json` defines exact-tree wiring for authored WAVs
- **Settings, save/resume, accessibility:** flat settings screen (LAR-4); autosave on FloorResults; reduced-motion (freeze=0, shake=0); key remapping with conflict detection; gamepad disconnect handling (auto-pause + pad_lost modal); contrast_mode (default/high_contrast); text_size (small/medium/large)
- **Minimum complete feel:** three named juice moments; every input acknowledged within 100ms
- **Object pooling:** projectiles (32), particles (128), floaters (16), enemies (28)
- **Balance sim:** 600 games (200 × 3 policies) in-process; includes softlock detection
- **Deterministic replay:** seed + action list (hold-until-change semantics) → SHA-256 identical; attract.replay (replay-only, no live sim)
- **All 10 G5 modals** with `test_modals.gd` coverage
- **Attract replay:** baked by `tools/attract_capture.gd`; replay-only playback at 30Hz

### OUT of scope

- NG+ mode and NG+ floor data (`ng_plus` field exists, always false)
- Exhaustive content beyond 24 base floors
- Final musician-authored production audio (procedural gap cues cover prototype; verbatim caption test DEFERRED until authored audio)
- Downloaded/unknown-origin media, copyrighted audio, Atari/Gauntlet assets/names/audio
- IAP (none), analytics (none), online infrastructure
- Undeclared dependencies (2D project — no 3D meshes)
- Ornamental polish beyond three named juice moments
- Any platform export without receipt (Steam Windows is later qualification)

---

## 8. Definition of prototype done

THREE automatable pass criteria plus one hard art gate within Criterion 1.

### Criterion 1: State-machine tests pass AND required art is loaded
All 19 test suites execute via `godot --headless --path <project-root> --script tests/test_runner.gd`. Every GDD §1 transition verified. Every GDD §10 question has a corresponding test (§6.6). `test_runner.gd` exits non-zero on any failure. **Hard art gate:** `test_assets.gd` reads `ASSET_MANIFEST.json` — every required primary-journey art slot (player sprites × 4 classes, enemy sprites × 6, generator sprites × 4, zone tilesets × 4, HUD, caption band, UI chrome) must have `delivery_debt = 0`; `ResourceLoader.load()` must succeed for each required asset path; scene files must reference the correct `semantic_id` bindings. Any `delivery_debt > 0` on a required slot, any `ResourceLoader.load()` failure, or any missing scene binding FAILS Criterion 1. Optional slots (concepts, attract frames) do not affect this gate.

### Criterion 2: Balance sim runs clean
`test_balance_sim.gd` runs in-process: 600 games (200 × 3 policies). Finite-sample assertions:
- `dead_board_rate` ≤ 0.05 (denominator = 72 floor-policy pairs)
- `dominance_spread_pp` ≤ 30 ((max_class_win_rate - min_class_win_rate) × 100)
- `min_class_win_rate` ≥ 0.40 (every class is viable)
- `min_class_avg_hp_at_exit` ≥ 30 (every class exits with meaningful HP)
- `wizard_avg_hp_at_exit` ≥ 52 (across Wizard wins only; if zero Wizard wins, FAILS)
- `win_rate` within [0.55, 0.85]
- Softlock: zero instances of `has_legal_action() == false AND hp > 0` across all 600 games (checked within the same run, not a separate 600-game pass)
- Wall-clock ≤ 10 min total

Solver-gated structural guarantees (gates 1–9) verified by `test_floor_solver.gd`.

### Criterion 3: Headless bot smoke completes without crash
```text
godot --headless --path <project-root> --fixed-fps 60 -- \
  --telemetry-out <absolute-path> --games 200 --seed 1 --frame-budget 21600 --policy greedy-killer
```
Main scene recognizes bot args, invokes `ci/sneferu_bot.gd` through the same `RulesSession` core, writes schema-valid `playtest_telemetry_v1` (single-policy 200-game schema) atomically. `games_completed` must equal `games_played` (200). `errors[]` must be empty (zero errors required). `dead_board_rate` denominator = 24 (single policy). Process completes without crashing. Expected wall-clock: ≤ 90 seconds. This is product-authored logic evidence, not rendered visual proof.

---

## 9. Tunables contract

`Tunables.json` at project root, schema `game_tunables_v1`. Single runtime + bake-time authority for all numeric gameplay constants. `affects` values are only `"+"`, `"-"`, or `{}` (empty object means no declared telemetry target — not necessarily non-gameplay; some gameplay constants like `shot_range` have no direct telemetry metric). Both game and bot load it at launch.

```json
{
  "schema": "game_tunables_v1",
  "tunables": [
    {"name": "drain_base_hp_s", "value": 2.0, "band": [1.0, 6.0], "step": 0.5, "affects": {"win_rate": "-", "wizard_avg_hp_at_exit": "-"}},
    {"name": "drain_zone_2_mult", "value": 1.25, "band": [1.0, 2.0], "step": 0.05, "affects": {"win_rate": "-"}},
    {"name": "drain_zone_3_mult", "value": 1.5, "band": [1.0, 2.5], "step": 0.05, "affects": {"win_rate": "-"}},
    {"name": "drain_zone_4_mult", "value": 1.75, "band": [1.0, 3.0], "step": 0.05, "affects": {"win_rate": "-"}},

    {"name": "zone_1_mult", "value": 1.0, "band": [1.0, 1.0], "step": 0.0, "affects": {}, "_bake_time": true, "_note": "Documentation-only band; changes require re-bake"},
    {"name": "zone_2_mult", "value": 1.25, "band": [1.0, 2.0], "step": 0.05, "affects": {}, "_bake_time": true, "_note": "Documentation-only band; changes require re-bake"},
    {"name": "zone_3_mult", "value": 1.5, "band": [1.0, 2.5], "step": 0.05, "affects": {}, "_bake_time": true, "_note": "Documentation-only band; changes require re-bake"},
    {"name": "zone_4_mult", "value": 1.75, "band": [1.0, 3.0], "step": 0.05, "affects": {}, "_bake_time": true, "_note": "Documentation-only band; changes require re-bake"},

    {"name": "warrior_hp", "value": 800, "band": [600, 1000], "step": 50, "affects": {"win_rate": "+"}},
    {"name": "warrior_speed", "value": 128, "band": [96, 192], "step": 8, "affects": {"win_rate": "+"}},
    {"name": "warrior_shot_dmg", "value": 50, "band": [30, 80], "step": 5, "affects": {"win_rate": "+"}},
    {"name": "warrior_shot_range", "value": 5, "band": [3, 8], "step": 1, "affects": {}},
    {"name": "warrior_shot_rate", "value": 1.2, "band": [0.8, 2.0], "step": 0.1, "affects": {"win_rate": "+"}},
    {"name": "warrior_projectile_speed", "value": 256, "band": [160, 384], "step": 16, "affects": {"win_rate": "+"}},
    {"name": "warrior_whirlwind_dmg", "value": 150, "band": [80, 250], "step": 10, "affects": {"win_rate": "+"}},
    {"name": "warrior_whirlwind_radius_tiles", "value": 4, "band": [2, 6], "step": 1, "affects": {"win_rate": "+"}},
    {"name": "warrior_whirlwind_knockback_px", "value": 8, "band": [4, 16], "step": 2, "affects": {}},

    {"name": "valkyrie_hp", "value": 680, "band": [500, 900], "step": 40, "affects": {"win_rate": "+"}},
    {"name": "valkyrie_speed", "value": 152, "band": [112, 224], "step": 8, "affects": {"win_rate": "+"}},
    {"name": "valkyrie_shot_dmg", "value": 30, "band": [15, 50], "step": 5, "affects": {"win_rate": "+"}},
    {"name": "valkyrie_shot_range", "value": 7, "band": [4, 10], "step": 1, "affects": {}},
    {"name": "valkyrie_shot_rate", "value": 1.6, "band": [1.0, 2.5], "step": 0.1, "affects": {"win_rate": "+"}},
    {"name": "valkyrie_projectile_speed", "value": 288, "band": [176, 432], "step": 16, "affects": {"win_rate": "+"}},
    {"name": "valkyrie_cone_half_angle_deg", "value": 30, "band": [15, 60], "step": 5, "affects": {"dominance_spread_pp": "-"}},
    {"name": "valkyrie_cone_dmg_inside_pct", "value": 1.0, "band": [0.5, 1.0], "step": 0.1, "affects": {"win_rate": "+"}},
    {"name": "valkyrie_cone_dmg_outside_pct", "value": 0.5, "band": [0.0, 0.75], "step": 0.1, "affects": {"win_rate": "-"}},
    {"name": "valkyrie_aegis_duration_s", "value": 3.0, "band": [1.0, 5.0], "step": 0.5, "affects": {"win_rate": "+"}},

    {"name": "wizard_hp", "value": 520, "band": [400, 700], "step": 40, "affects": {"win_rate": "+", "wizard_avg_hp_at_exit": "+"}},
    {"name": "wizard_speed", "value": 144, "band": [104, 208], "step": 8, "affects": {"win_rate": "+"}},
    {"name": "wizard_shot_dmg", "value": 20, "band": [10, 40], "step": 5, "affects": {"win_rate": "+"}},
    {"name": "wizard_shot_range", "value": 6, "band": [4, 9], "step": 1, "affects": {}},
    {"name": "wizard_shot_rate", "value": 1.2, "band": [0.8, 2.0], "step": 0.1, "affects": {"win_rate": "+"}},
    {"name": "wizard_projectile_speed", "value": 224, "band": [144, 336], "step": 16, "affects": {"win_rate": "+"}},
    {"name": "wizard_splash_radius_tiles", "value": 2, "band": [1, 4], "step": 1, "affects": {"win_rate": "+"}},
    {"name": "wizard_nova_dmg", "value": 80, "band": [40, 140], "step": 10, "affects": {"win_rate": "+"}},
    {"name": "wizard_nova_radius_tiles", "value": 6, "band": [3, 10], "step": 1, "affects": {"win_rate": "+"}},

    {"name": "elf_hp", "value": 560, "band": [420, 750], "step": 40, "affects": {"win_rate": "+"}},
    {"name": "elf_speed", "value": 192, "band": [144, 256], "step": 8, "affects": {"win_rate": "+"}},
    {"name": "elf_shot_dmg", "value": 15, "band": [8, 30], "step": 2, "affects": {"win_rate": "+"}},
    {"name": "elf_shot_range", "value": 10, "band": [6, 14], "step": 1, "affects": {}},
    {"name": "elf_shot_rate", "value": 3.0, "band": [2.0, 5.0], "step": 0.25, "affects": {"win_rate": "+"}},
    {"name": "elf_projectile_speed", "value": 320, "band": [192, 480], "step": 16, "affects": {"win_rate": "+"}},
    {"name": "elf_volley_count", "value": 5, "band": [3, 9], "step": 1, "affects": {"win_rate": "+"}},
    {"name": "elf_volley_angle_deg", "value": 15, "band": [5, 30], "step": 5, "affects": {"win_rate": "-"}},

    {"name": "ghost_speed", "value": 100, "band": [60, 140], "step": 10, "affects": {"win_rate": "-"}},
    {"name": "ghost_contact_dmg", "value": 10, "band": [5, 20], "step": 1, "affects": {"win_rate": "-"}},
    {"name": "grunt_speed", "value": 80, "band": [50, 120], "step": 10, "affects": {"win_rate": "-"}},
    {"name": "grunt_contact_dmg", "value": 15, "band": [8, 25], "step": 1, "affects": {"win_rate": "-"}},
    {"name": "demon_speed", "value": 90, "band": [60, 130], "step": 10, "affects": {"win_rate": "-"}},
    {"name": "demon_contact_dmg", "value": 20, "band": [10, 35], "step": 2, "affects": {"win_rate": "-"}},
    {"name": "demon_projectile_speed", "value": 160, "band": [100, 240], "step": 10, "affects": {"win_rate": "-"}},
    {"name": "demon_projectile_dmg", "value": 25, "band": [15, 40], "step": 5, "affects": {"win_rate": "-"}},
    {"name": "demon_maintain_range_min_tiles", "value": 4, "band": [2, 6], "step": 1, "affects": {"win_rate": "-"}},
    {"name": "demon_maintain_range_max_tiles", "value": 6, "band": [4, 10], "step": 1, "affects": {"win_rate": "-"}},
    {"name": "lobber_speed", "value": 70, "band": [40, 110], "step": 10, "affects": {"win_rate": "-"}},
    {"name": "lobber_contact_dmg", "value": 15, "band": [8, 25], "step": 1, "affects": {"win_rate": "-"}},
    {"name": "lobber_projectile_speed", "value": 120, "band": [80, 200], "step": 10, "affects": {"win_rate": "-"}},
    {"name": "lobber_projectile_dmg", "value": 20, "band": [10, 35], "step": 2, "affects": {"win_rate": "-"}},
    {"name": "sorcerer_speed", "value": 110, "band": [70, 160], "step": 10, "affects": {"win_rate": "-"}},
    {"name": "sorcerer_contact_dmg", "value": 20, "band": [10, 35], "step": 2, "affects": {"win_rate": "-"}},
    {"name": "sorcerer_blink_radius_tiles", "value": 8, "band": [4, 16], "step": 1, "affects": {"win_rate": "-"}},
    {"name": "sorcerer_blink_cooldown_steps", "value": 90, "band": [30, 180], "step": 15, "affects": {"win_rate": "-"}},
    {"name": "death_speed", "value": 60, "band": [40, 100], "step": 10, "affects": {"win_rate": "-"}},
    {"name": "death_contact_dmg", "value": 50, "band": [30, 80], "step": 5, "affects": {"win_rate": "-"}},
    {"name": "death_aura_radius_tiles", "value": 3, "band": [2, 6], "step": 1, "affects": {"win_rate": "-"}},
    {"name": "death_aura_dmg_per_tick", "value": 5, "band": [3, 15], "step": 1, "affects": {"win_rate": "-"}},
    {"name": "death_aura_tick_s", "value": 0.5, "band": [0.25, 1.0], "step": 0.25, "affects": {"win_rate": "-"}},
    {"name": "death_scripted_spawn_steps", "value": 180, "band": [60, 360], "step": 30, "affects": {"win_rate": "-"}},

    {"name": "contact_damage_interval_s", "value": 0.5, "band": [0.25, 1.0], "step": 0.25, "affects": {"win_rate": "+"}},

    {"name": "gen_drowned_hp", "value": 60, "band": [40, 100], "step": 10, "affects": {"win_rate": "-"}},
    {"name": "gen_drowned_cadence_s", "value": 3.0, "band": [1.5, 5.0], "step": 0.25, "affects": {"win_rate": "-"}},
    {"name": "gen_cinder_hp", "value": 90, "band": [60, 140], "step": 10, "affects": {"win_rate": "-"}},
    {"name": "gen_cinder_cadence_s", "value": 2.5, "band": [1.0, 4.0], "step": 0.25, "affects": {"win_rate": "-"}},
    {"name": "gen_starved_hp", "value": 120, "band": [80, 180], "step": 10, "affects": {"win_rate": "-"}},
    {"name": "gen_starved_cadence_s", "value": 2.0, "band": [0.8, 3.5], "step": 0.25, "affects": {"win_rate": "-"}},
    {"name": "gen_throne_hp", "value": 160, "band": [100, 240], "step": 10, "affects": {"win_rate": "-"}},
    {"name": "gen_throne_cadence_s", "value": 1.5, "band": [0.6, 3.0], "step": 0.25, "affects": {"win_rate": "-"}},

    {"name": "flame_jet_dmg", "value": 10, "band": [5, 25], "step": 1, "affects": {"win_rate": "-"}},
    {"name": "flame_jet_active_s", "value": 1.0, "band": [0.5, 2.0], "step": 0.1, "affects": {"win_rate": "-"}},
    {"name": "flame_jet_dormant_s", "value": 2.0, "band": [1.0, 4.0], "step": 0.25, "affects": {"win_rate": "+"}},
    {"name": "void_bridge_dmg", "value": 100, "band": [50, 100], "step": 10, "affects": {"win_rate": "-"}},
    {"name": "void_bridge_active_s", "value": 1.5, "band": [0.8, 3.0], "step": 0.1, "affects": {"win_rate": "-"}},
    {"name": "void_bridge_dormant_s", "value": 1.5, "band": [0.8, 3.0], "step": 0.1, "affects": {"win_rate": "+"}},
    {"name": "collapsing_void_dmg", "value": 100, "band": [50, 100], "step": 10, "affects": {"win_rate": "-"}},
    {"name": "collapsing_void_removal_s", "value": 2.0, "band": [1.0, 4.0], "step": 0.25, "affects": {"win_rate": "-"}},

    {"name": "continue_timer_s", "value": 10.0, "band": [5.0, 15.0], "step": 1.0, "affects": {"win_rate": "+"}},
    {"name": "continue_hp_pct", "value": 0.5, "band": [0.25, 0.75], "step": 0.05, "affects": {"win_rate": "+"}},
    {"name": "death_penalty_pct", "value": 0.20, "band": [0.10, 0.35], "step": 0.05, "affects": {"win_rate": "-"}},
    {"name": "tokens_per_floor", "value": 2, "band": [1, 4], "step": 1, "affects": {"win_rate": "+"}},

    {"name": "food_hp_restore", "value": 100, "band": [50, 200], "step": 10, "affects": {"win_rate": "+", "wizard_avg_hp_at_exit": "+"}},
    {"name": "chest_base_value", "value": 500, "band": [200, 1000], "step": 50, "affects": {}, "_bake_time": true, "_note": "Documentation-only band; changes require re-bake"},

    {"name": "juice_camera_trauma_amp", "value": 2.0, "band": [0.0, 6.0], "step": 0.5, "affects": {}},
    {"name": "juice_camera_trauma_decay", "value": 3.0, "band": [1.0, 8.0], "step": 0.5, "affects": {}},
    {"name": "juice_freeze_frame_s", "value": 0.04, "band": [0.0, 0.12], "step": 0.01, "affects": {}},
    {"name": "juice_hit_flash_s", "value": 0.06, "band": [0.0, 0.15], "step": 0.01, "affects": {}},
    {"name": "juice_floater_rise_px_s", "value": 48, "band": [24, 96], "step": 8, "affects": {}},
    {"name": "juice_life_light_crossfade_ms", "value": 400, "band": [100, 800], "step": 50, "affects": {}},

    {"name": "caption_hold_min_s", "value": 2.0, "band": [1.0, 4.0], "step": 0.25, "affects": {}},
    {"name": "bark_spacing_s", "value": 3.5, "band": [2.0, 6.0], "step": 0.25, "affects": {}},
    {"name": "dying_anim_s", "value": 1.2, "band": [0.4, 2.0], "step": 0.1, "affects": {}},
    {"name": "dying_anim_reduced_s", "value": 0.2, "band": [0.1, 0.5], "step": 0.05, "affects": {}},

    {"name": "gate7_ghost_contact_per_step", "value": 0.17, "band": [0.08, 0.33], "step": 0.01, "affects": {}, "_solver_only": true},
    {"name": "gate7_grunt_contact_per_step", "value": 0.25, "band": [0.13, 0.42], "step": 0.01, "affects": {}, "_solver_only": true},
    {"name": "gate7_demon_contact_per_step", "value": 0.33, "band": [0.17, 0.58], "step": 0.01, "affects": {}, "_solver_only": true},
    {"name": "gate7_demon_projectile_dmg", "value": 25, "band": [15, 40], "step": 5, "affects": {}, "_solver_only": true},
    {"name": "gate7_lobber_projectile_dmg", "value": 20, "band": [10, 35], "step": 2, "affects": {}, "_solver_only": true},
    {"name": "gate7_sorcerer_contact_per_step", "value": 0.33, "band": [0.17, 0.58], "step": 0.01, "affects": {}, "_solver_only": true},
    {"name": "gate7_death_aura_per_step", "value": 0.08, "band": [0.05, 0.25], "step": 0.01, "affects": {}, "_solver_only": true},
    {"name": "gate7_food_reachability_tiles", "value": 3, "band": [2, 5], "step": 1, "affects": {}, "_solver_only": true}
  ],
  "targets": {
    "win_rate": [0.55, 0.85],
    "dead_board_rate": [0.0, 0.05],
    "wizard_avg_hp_at_exit": [52, 520],
    "dominance_spread_pp": [0, 30],
    "min_class_win_rate": [0.40, 1.0],
    "min_class_avg_hp_at_exit": [30, 520]
  }
}
```

**Notes:**
- `_bake_time: true` constants (zone_mult, chest_base_value) have bands for design-space documentation only. Changing their values requires re-running `tools/floor_baker.gd`. The solver's `--check-band-extremes` flag verifies floors remain valid at band extremes; if a gate fails, the band is narrowed and floors re-baked. Floors are immutable `.tres` files (OBL-85).
- `_solver_only: true` constants (gate7_*) are used only by `rules_solver_check.gd` for floor validation at bake time, not by runtime gameplay. Runtime uses actual `contact_dmg` and `projectile_dmg` values.
- `contact_damage_interval_s` = 0.5 (30 steps): enemies deal contact damage every 30 steps while overlapping the player, not every step.
- `attract_seed` (0xDEAD) and `ATTRACT_PLAYBACK_FPS` (30) are code constants, NOT in Tunables.
- Solver revalidation: `tools/solver.gd --tunables Tunables.json --check-band-extremes` runs gates at min and max of each tunable band. Done criterion: all gates pass at both extremes for all 24 floors. Failing extremes narrow the band and trigger re-bake (OBL-36).

---

## 10. Asset placeholder strategy

The primary journey visibly consumes every qualified Forge-seeded asset through Godot's real scene/resource path (`ResourceLoader.load("res://...")`, never `.godot/imported`). A generated sprite sheet is consumed as a `SpriteFrames` animation with its declared frame geometry — not reduced to one crop. A Forge-seeded tileset PNG is bound to a `TileSet` resource and rendered through `TileMap`.

For an unfilled **optional** slot, the prototype uses an unmistakable fallback:
- Solid-color rectangles in G4 Palette A slots (`ui_slate`, `text_bone`, `service_amber`, `critical_brick`)
- Text labels: `[player sprite]`, `[tile-A]`, `[enemy-ghost]`, `[generator-drowned]`
- Godot engine-native flat shapes (`Polygon2D`, `ColorRect`, `Control` with custom draw)

A **required primary-journey slot** (player sprites × 4, enemy sprites × 6, generator sprites × 4, zone tilesets × 4, HUD, caption band, UI chrome) is NOT an optional gap. If its file/import/binding is temporarily unavailable, the defensive fallback preserves playability, but:
1. The scene-binding receipt in `ASSET_MANIFEST.json` names the slot
2. `delivery_debt` is incremented (non-zero)
3. **`delivery_debt > 0` on any required slot FAILS Criterion 1 (hard gate, verified by `test_assets.gd`)**
4. The build is sent through automatic art/binding repair
5. The fallback state is never called "complete" or "visually qualified"

**Manifest schemas:** `ASSET_MANIFEST.json` rows: `{semantic_id, source_path, dest_path, resource_kind, import_settings, delivery_debt, provenance}`. `GODOT_IMPORT_MANIFEST.json`: committed `.import` settings per family; 32px pixel-art: filtering OFF, mipmaps OFF, repeat OFF, lossless, straight alpha.

**Credits/privacy:** `data/strings.json` keys `credits_text` and `privacy_text` contain original authored text (category: `"credits"` / `"privacy"`). No Lorem Ipsum. No copyrighted content.

---

## 11. Feel & first-party framework contract

### 11.1 Engine-native frameworks

Godot uses the shared pure rules core plus `SceneTree`/state objects, `RandomNumberGenerator` with injected seed, `InputMap`, `Tween`/`AnimationPlayer`, `Control` themes, native audio, and engine resources. `TransitionTable` + `SessionStateMachine` are hand-rolled because Godot has no built-in FSM matching the GDD's 12-state graph. Every Tween/AnimationPlayer track carries a timing mode (`ease_out`, `ease_in_out`; `linear` only for steady drain).

### 11.2 Named juice budget — three moments

| Moment | Event | Response(s) | Tunable constants |
|---|---|---|---|
| **Generator Burst** | `event: generator_destroyed` | **Freeze (2 steps; SSM sets `freeze_steps_remaining`)** → camera trauma (2px, decay 3.0/s) → smoke (8 particles) → floater (+kill value, 48px/s) → rumble (medium, 0.15s) → `cue.gen_destroyed` | `juice_freeze_frame_s`, `juice_camera_trauma_amp`, `juice_camera_trauma_decay`, `juice_floater_rise_px_s` |
| **Player Hit** | `event: player_hit` | **Freeze (2 steps; SSM sets counter)** → hit flash (0.06s) → HP numeral pulse (1.3→1.0, 0.12s ease_out) → life-light dim one grade (400ms) → rumble (sharp, 0.08s) → `cue.player_hit` | `juice_freeze_frame_s`, `juice_hit_flash_s`, `juice_life_light_crossfade_ms` |
| **Floor Clear** | `event: floor_clear` | Exit door glow (amber, 0.3s ease_out) → caption ("THE [CLASS] LEAVES UPRIGHT.", 2.0s min) → score tally (0.5s) → camera settle → `cue.floor_clear` | `caption_hold_min_s`, `juice_life_light_crossfade_ms` |

**Freeze call path (OBL-25/OBL-56/OBL-86):** SSM `tick_once()` → `consume_pending()` → SSM reads events → SSM sets `_freeze_steps_remaining = round(juice_freeze_frame_s * 60)` for freeze-triggering events → SSM signals JuiceDirector for rumble → SSM passes events to `Play.consume_events()` for visual juice. JuiceDirector does NOT signal SSM. One direction only: SSM reads events and owns the freeze counter. Under reduced motion, `_freeze_steps_remaining` is always 0.

**Juice wiring:** `core/` produces `pending_events` → `SessionStateMachine` calls `consume_pending()` → SSM sets freeze counter for freeze events → SSM signals `JuiceDirector` (rumble) → SSM passes events to `Play.consume_events()` → `WorldView.consume_events()` triggers particles/trauma/floaters.

### 11.3 Haptic map (owned by JuiceDirector)

| Event | Pattern | Rumble |
|---|---|---|
| Throw | None (too frequent) | — |
| Projectile hits enemy | Light tap, 0.02s, low-freq | Weak |
| Generator destroyed | Medium impact, 0.15s, low+high | Medium |
| Player contact damage | Sharp pulse, 0.08s, high-freq | Medium |
| HP crosses life-light threshold | None (visual grade is signal) | — |
| Food consumed | Soft click, 0.03s, low-freq | Weak |
| Potion used | Medium rumble, 0.10s, both | Medium |
| Key collected | Light tap, 0.03s, high-freq | Weak |
| Floor clear | Gentle fade, 0.20s, low-freq | Weak |
| Continue timer expires | Urgent pulse, 0.05s × 3, high-freq | Medium |
| Death | Strong sustained, 0.30s, both, then fade | Strong |
| Menu navigation | None (audio cue sufficient) | — |
| Menu confirm | Light tap, 0.02s, high-freq | Weak |

`JuiceDirector.rumble(pattern, intensity)` scales by `settings.rumble_intensity` (0–100; 0 = off). JuiceDirector reads this via `set_settings_store()` (OBL-12). Silence-by-decision noted per event.

### 11.4 Chrome quality floor

`hungerhall_theme.tres` defines Button, Panel, Label, TextureProgressBar, Slider, OptionButton, LineEdit, ScrollContainer, TabContainer using G4 Palette A tokens. `ClippedPlaqueStyleBox` draws crescent-corner buttons. All interactive elements have pressed/focus states (Service Amber inlay). Safe-area via `Control` anchors. 44px minimum target. Stable machine-input identifiers (`btn_new_game`, `btn_continue`, etc.).

### 11.5 Every input acknowledged within 100ms

| Input | Acknowledgment | Latency |
|---|---|---|
| Move | Sprite position updates next physics frame | < 17ms |
| Throw | Projectile + muzzle flash + `cue.throw` | < 17ms |
| Potion | Effect + floater + `cue.potion_used` | < 17ms |
| Pause | Game freezes + Paused overlay | < 17ms |
| Menu nav | Focus moves + audio tick | < 50ms |
| Menu confirm | Screen transition + audio cue | < 50ms |
| Settings toggle | Setting applies + visual state + tick | < 50ms |

---

## 12. Presentation contract

`presentation_contract.json` at project root:

```json
{
  "dimension": "2D",
  "camera": "top-down",
  "readability_bar": "At one second: hero class silhouette, nearest threat mass, falling HP numeral, life-light grade. At three seconds: room structure, cloche crescents on interactive, hazard telegraph state. At ten seconds: tile grain, flame flicker, rivets, stains.",
  "frame_floors": {
    "play_area_ratio_floor": 0.75,
    "contrast_floor": 18,
    "dark_scene_p50": 20
  },
  "orientation": "landscape",
  "ui_regions": [
    {"name": "hp_hud", "rect": [0.0, 0.0, 0.18, 0.10]},
    {"name": "score_hud", "rect": [0.35, 0.0, 0.30, 0.10]},
    {"name": "floor_hud", "rect": [0.85, 0.0, 0.15, 0.08]},
    {"name": "inventory_hud", "rect": [0.0, 0.82, 0.12, 0.16]},
    {"name": "caption_band", "rect": [0.15, 0.88, 0.70, 0.12]}
  ],
  "palette_hex": {
    "text_bone": "#E8E4D8",
    "ui_slate": "#2A2D33",
    "service_amber": "#D4A542",
    "void_black": "#0A0B0D",
    "critical_brick": "#B85040"
  }
}
```

`inventory_hud` ends at x=0.12; `caption_band` starts at x=0.15 — no overlap. Palette hex values are the contrast test authority (`test_accessibility.gd`). `test_presentation.gd` validates schema: hex values parse, rects within [0,1] and non-overlapping, frame_floors within valid ranges. Frame-capture verification of `frame_floors` is a NOT_RUN lane in headless CI (OBL-46).

---

## 13. Audio and cue architecture

### 13.1 Cue dispatch seam

`core/` rules modules append to `pending_cues` in snapshot. `SessionStateMachine` calls `consume_pending()` and dispatches each cue via `CueBus.emit(cue_id)`. `core/` never imports `CueBus`.

**Cue callsites:**
- **core/ simulation events:** `cue.gen_destroyed` (rules_combat), `cue.player_hit` (rules_combat), `cue.floor_clear` (rules_session), `cue.zone_entry` (rules_floor), `cue.death` (rules_player), `cue.food_consumed` (rules_pickup), `cue.key_collected` (rules_pickup), `cue.potion_used` (rules_player), `cue.door_opened` (rules_pickup), `cue.chest_opened` (rules_pickup), `cue.throw` (rules_player), `cue.projectile_hit` (rules_projectile)
- **app/ state-entry events:** `cue.floor_card` (SessionStateMachine on FloorResults entry), `cue.continue_prompt` (SessionStateMachine on ContinueOffer entry), `cue.menu_nav` (InputMapper on focus change), `cue.menu_confirm` (SessionStateMachine on verb request)

### 13.2 Procedural gap cues (in-memory AudioStreamWAV)

`AudioDirector` pre-computes PCM sample buffers at boot (44100 Hz, mono, 16-bit) and wraps each as an in-memory `AudioStreamWAV` resource. `play_cue(cue_id)` scales volume by `settings.sfx_vol / 100.0` (linear); `sfx_vol = 0` → `volume_db = -80` (silent); `sfx_vol = 100` → `volume_db = 0` (full) (OBL-41/OBL-74).

| Cue ID | Waveform |
|---|---|
| `cue.throw` | Square 200Hz, 0.05s |
| `cue.projectile_hit` | Noise burst, 0.03s |
| `cue.gen_destroyed` | Low square 80Hz + noise, 0.15s |
| `cue.player_hit` | Square 150Hz, 0.08s |
| `cue.floor_clear` | Ascending sine 440→880Hz, 0.3s |
| `cue.death` | Descending sawtooth 200→50Hz, 0.5s |
| `cue.food_consumed` | Sine 600Hz, 0.05s |
| `cue.key_collected` | Sine 800Hz, 0.03s |
| `cue.potion_used` | Sweep 300→600Hz, 0.1s |
| `cue.door_opened` | Low square 100Hz, 0.1s |
| `cue.chest_opened` | Ascending sine 523→1047Hz, 0.2s |
| `cue.continue_prompt` | Square 440Hz × 3 pulses, 0.05s each |
| `cue.floor_card` | Sine 330Hz, 0.15s |
| `cue.zone_entry` | Low square 60Hz, 0.2s |
| `cue.menu_nav` | Sine 1000Hz, 0.02s |
| `cue.menu_confirm` | Sine 1200Hz, 0.03s |

### 13.3 `AUDIO_PRODUCT_MANIFEST.json`

When operator-authored audio is supplied:
```json
{"schema": "audio_product_manifest_v1", "cues": [
  {"cue_id": "cue.gen_destroyed", "resource_path": "res://Assets/Audio/gen_destroyed.wav",
   "stream_type": "AudioStreamWAV", "loop": false, "volume_db": 0.0, "bus": "SFX"}]}
```
`AudioDirector` plays authored WAV if available; falls back to procedural tone otherwise. **Caption verbatim test (GDD Q9) is DEFERRED** until authored audio is supplied — `test_accessibility.gd` marks the verbatim match as SKIP when `AUDIO_PRODUCT_MANIFEST.json` has no authored WAV for the cue (OBL-87).

---

## 14. Upstream findings disposition

| Item | Status | Disposition |
|---|---|---|
| FIX-153: Monte Carlo | PROVISIONAL | Combat estimates are hand-set constants; balance sim validates survival |
| GDD §7 architecture | ADOPTED | Pure RefCounted core, single autoload, semantic API, seeded PRNG, 60 Hz |
| GDD §10 questions | CROSS-REFERENCED | Every question has a test (§6.6); feel questions marked OP-4; Q9 verbatim DEFERRED |
| G3 voice bible | ADOPTED | strings.json enforced; test_accessibility validates; categories enumerated |
| G4 art direction | ADOPTED | Palette A tokens; hex in presentation_contract.json |
| LAR-1–4 | ADOPTED | ng_plus field, event rumble, retry edge, flat settings |
| G1 presentation | ADOPTED | Pure 2D, 32px tiles; never revisited |
| DIS-5 attract mode | RESOLVED | Replay-only playback; live-sim language removed; attract_capture.gd added |

---

## 15. `project.godot` binding requirements

```ini
[application]
config/name="HUNGERHALL"
run/main_scene="res://main.tscn"

[autoload]
SessionStateMachine="*res://app/session_state_machine.gd"

[display]
window/size/viewport_width=640
window/size/viewport_height=360
window/size/window_width_override=1280
window/size/window_height_override=720
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"

[physics]
common/physics_ticks_per_second=60

[rendering]
textures/vram_compression/import_etc2_astc=true
renderer/rendering_method="gl_compatibility"
```

**InputMap bindings (OBL-88):** G7 must configure the `[input]` section in `project.godot` using Godot 4.7's standard ini serialization with `InputEventKey` (using `physical_keycode` field) and `InputEventJoypadMotion`/`InputEventJoypadButton` entries. The table below defines the binding contract — action names, physical keycodes, and joypad mappings are binding. The exact ini serialization format is Godot editor-generated; G7 may use the editor's InputMap dialog or `InputMap.action_add_event()` in code.

| Action | Keyboard (physical_keycode) | Gamepad |
|---|---|---|
| `move_up` | W (87), Up (4194320) | Left stick Y- (axis 1, -1.0) |
| `move_down` | S (83), Down (4194322) | Left stick Y+ (axis 1, 1.0) |
| `move_left` | A (65), Left (4194319) | Left stick X- (axis 0, -1.0) |
| `move_right` | D (68), Right (4194321) | Left stick X+ (axis 0, 1.0) |
| `throw` | J (74), Z (90), Ctrl (4194326) | South face (button 0), RT (axis 5, 1.0) |
| `potion` | K (75), X (88) | East face (button 1), RB (button 10) |
| `pause` | Esc (4194305) | Start (button 6) |
| `sneferu_primary_action` | Space (32) | — |

`session_state_machine.gd` does NOT declare `class_name` — the autoload name `SessionStateMachine` is the sole global accessor (OBL-55). Other scripts access it via `get_node("/root/SessionStateMachine")` or the autoload singleton directly.

---

## 16. Replay file format

Schema `hungerhall_replay_v1`:

```json
{
  "schema": "hungerhall_replay_v1",
  "engine_version": "4.7",
  "project_hash": "<SHA-256>",
  "seed": 57005,
  "class": "warrior",
  "floor": 1,
  "actions": [
    {"step": 0, "action": {"move": [1, 0], "attack": false, "potion": false}},
    {"step": 30, "action": {"move": [0, 0], "attack": true, "potion": false}}
  ],
  "outcome_hash": "<SHA-256>"
}
```

**Action semantics:** Hold-until-change. The action at step N persists for all steps until the next listed action. Actions are sparse — only changes are recorded.

**`project_hash` algorithm (OBL-16/OBL-38/OBL-73/OBL-90):** SHA-256 of concatenated file contents. File list (alphabetical by path): `project.godot`, all `*.gd` files in `core/`, all `*.gd` files in `app/`, `main.gd`, `ci/sneferu_bot.gd`, `Tunables.json`. Excludes: `data/` floors (baked, immutable), `Assets/` (can change without breaking replay), `tests/`, `tools/`, `scenes/`, `world/`, `ui/` (projection-only — they render state but do not affect rules determinism). `main.gd` and `ci/sneferu_bot.gd` ARE included because they affect bot execution and telemetry integrity. `Tunables.json` IS included (was always included; clarifying per OBL-90). Canonicalization: raw file bytes concatenated in alphabetical path order, no delimiter. `outcome_hash` = `RulesReplay.hash_snapshot(final_snapshot)` using `HashingContext` with `HASHING_ALGORITHM_SHA256` over canonical JSON.

---

## 17. Floor baker/solver contracts

### 17.1 Floor dimensions and cell schema

- Floor grid: 20×14 tiles (640×448 px); Cell: 10×7 tiles; Assembly: 2×2 per floor
- Cell schema: `{tiles: [[int]], spawns: [{type, x, y}], hazards: [{type, x, y}], doors: [{x, y}], keys: [{x, y}]}`
- Tile values: 0=OPEN, 1=WALL, 2=EXIT_DOOR(locked), 3=EXIT_DOOR(open)
- Each FloorData contains `target_seconds: int` computed by baker: `(path_length_tiles × 32 / min_class_speed) × 1.5` (50% margin)

### 17.2 Floor baker assembly algorithm (OBL-30/OBL-70)

1. **7 hand-built floors:** Authored directly as 20×14 tile grids with explicit spawns, hazards, doors, keys, exit. Format: `FloorData` Resource authored in editor.
2. **17 assembled floors:** 2×2 cell grid (each cell 10×7 tiles), selected from 48 authored cells.
3. **Cell selection:** `PrngSeeder.from_int(seed)` picks 4 cells per floor. 200 attempts per floor.
4. **Cell adjacency:** Shared walls between cells must be contiguous — no isolated regions. Adjacent cells share border tiles; WALL tiles on borders must align (both WALL or both OPEN with passage).
5. **Key/door placement:** One key per floor, placed in a random OPEN tile in a non-spawn cell (at least 3 tiles from spawn). One locked exit door (tile value 2) at the bottom-right edge tile of the assembled grid.
6. **Exit placement:** Bottom-right edge tile of the 20×14 grid.
7. **Chest values:** `chest_base_value × zone_mult` computed at bake time and stored in `FloorData.chest_values`.
8. **Failure output:** If 200 attempts fail for any floor, baker writes `bake_failure.json` with `{floor_index, attempted_layouts: [{cell_ids, failed_gates: [int]}], seed}` and exits with code 1.

### 17.3 Solver gates (1–9) — algorithmic definitions (OBL-31/OBL-32/OBL-33/OBL-34/OBL-35/OBL-70/OBL-80)

| Gate | Name | Algorithm |
|---|---|---|
| 1 | A* reachability | A* path (Manhattan heuristic, 4-directional, through OPEN tiles) from spawn → nearest key → matching door (door unlocks when key is collected; unlocked door tile becomes passable OPEN) → exit. All segments must exist. Key-door matching: each key has a `door_id` matching a door's `door_id`; collecting the key unlocks the matching door. |
| 2 | LOS check | Bresenham line from spawn tile center to exit door tile center. No WALL tiles may block. Locked door tiles (value 2) block LOS until unlocked (value 3). |
| 3 | Guarded-cell | For each generator spawn, Manhattan distance to nearest key and to exit ≥ 3 tiles (96px). |
| 4 | Corridor width | For each tile on Gate 1 A* path, at least one orthogonal neighbor is OPEN (2-tile minimum). |
| 5 | Food reachability | Sum food HP from food tiles within `gate7_food_reachability_tiles` (3) Manhattan distance of the Gate 1 A* path. Total must be ≥ `drain_base_hp_s × target_seconds × drain_zone_mult × 1.10` (10% margin). Food beyond reachability distance is NOT counted. |
| 6 | Alive caps | Enemy spawns + (generator_count × 6) ≤ 28. |
| 7 | HP budget | Simulate Wizard walking A* path at `wizard_speed`: drain = `drain_base_hp_s × (path_pixels / wizard_speed) × drain_zone_mult`. Add expected contact damage using `gate7_*` constants per enemy type on path. Add expected projectile damage from Demon/Lobber using `gate7_demon_projectile_dmg` and `gate7_lobber_projectile_dmg`. Food HP from Gate 5 reachable food. Pass if `wizard_hp + reachable_food_hp > drain + contact_damage + projectile_damage`. |
| 8 | Void safety | Hazard footprints: flame_jet = 1×3 line centered on hazard tile (extends 1 tile in each horizontal direction); void_bridge = 2×2 area centered on hazard tile; collapsing_void = 1×1 (hazard tile itself). For each hazard, enumerate tiles in footprint. For each tile on any A* path within footprint, verify safe window (telegraph + dormant duration) allows traversal at `min_class_speed`. Simulate each class crossing; if any cannot cross, fail. |
| 9 | Body-blocking | **No generator AND no enemy spawn is placed on any tile of the Gate 1 A* path.** Additionally, all enemy AI types include movement (verified by EnemyDef ai_type != null), and all enemies have speed > 0 (verified by Tunables), ensuring no permanent tile occupation. **This gate is a structural heuristic, not a proof against all dynamic blocking scenarios** — dynamic blocking is handled by `has_legal_action()` softlock detection in the balance sim. Gate 9 does not prevent dynamic enemies from temporarily blocking the path during gameplay; it ensures the baked layout does not start blocked. |

### 17.4 Bake pipeline commands

```text
godot --headless --path <project-root> --script tools/floor_baker.gd -- \
  --output data/floors/base/ --tunables Tunables.json --seed 12345
godot --headless --path <project-root> --script tools/solver.gd -- \
  --floors data/floors/base/ --tunables Tunables.json
godot --headless --path <project-root> --script tools/solver.gd -- \
  --floors data/floors/base/ --tunables Tunables.json --check-band-extremes
godot --headless --path <project-root> --script tools/attract_capture.gd -- \
  --output Assets/Replays/attract.replay --seed 57005
```

`floor_baker.gd` uses `PrngSeeder.from_int(seed)` — `--seed <int>` is required. `solver.gd` calls `core/rules_solver_check.gd` for gates 1–9. `--check-band-extremes` runs gates at min and max of each tunable band; failing extremes narrow the band. Done criterion: all gates pass at both extremes for all 24 floors. `attract_capture.gd` runs a greedy-killer bot on floor 1 with seed 0xDEAD, records semantic actions, solver-validates, and writes `hungerhall_replay_v1` (OBL-10/OBL-71).

---

## 18. Runtime proof section

Per the godot-4-architecture skill, the spec pins six proof artifacts. Product `FAIL` receives bounded repair. Tool/display/export `ERROR` preserves the artifact and denies qualification; it never masquerades as product failure or stops construction.

| # | Proof artifact | How produced | Qualification |
|---|---|---|---|
| 1 | Godot 4.7 toolchain receipt | `godot --version` output captured in CI log | Must print `4.7` stable |
| 2 | Editor import result | `godot --headless --editor --quit` exit code + import log | Zero import errors; `.godot/imported/` populated from source |
| 3 | GDScript parse/static-check | `godot --headless --check-only --script` on all `core/` and `app/` scripts, OR `test_runner.gd` parse phase | Zero parse errors; zero type errors |
| 4 | Deterministic headless bot telemetry | Criterion 3 command (§6.7); schema-valid `playtest_telemetry_v1` | `games_completed == games_played`; `errors[]` empty; valid JSON |
| 5 | Real-render journey (when display exists) | `ci/sneferu_visual.gd` launches main scene at fixed FPS, records bounded journey via Godot movie writer, exits | NOT_RUN in headless-only CI; separate lane when display available |
| 6 | Export/install/start proof | Only for platforms with installed templates | NOT claimed for Steam Windows in this prototype — later qualification lane |

**Architecture skill waiver (OBL-42/OBL-53):** `ci/sneferu_bot.gd` is a `RefCounted` class invoked by `main.gd` within the SceneTree context, not a detached `--script` entry. This satisfies the skill's intent (same `RulesSession` API, not a parallel simulation) while allowing the configured main scene to own bot-mode lifecycle per the domain contract. The waiver is documented here and in §2.

---

## 19. Save v1 schema

`SaveCodec` in `core/save_codec.gd` is the authoritative schema. `save_schema.json` at project root is **documentation-only** — a human-readable reference for debugging, NOT loaded at runtime (OBL-59). All writes via `SaveStore` use atomic temp-file + rename to `user://` paths.

```json
{
  "schema": "hungerhall_save_v1",
  "campaign": {
    "current_floor": 1,
    "class_type": "warrior",
    "hp": 800,
    "score": 0,
    "tokens": 2,
    "potions": 0,
    "keys": 0,
    "campaign_seed": 12345,
    "ng_plus": false
  },
  "profile": {
    "classes_cleared": 0,
    "ng_plus_unlocked": false
  },
  "scores": {
    "standard": {
      "warrior": [{"initials": "AAA", "score": 5000}],
      "valkyrie": [],
      "wizard": [],
      "elf": []
    }
  },
  "settings": {
    "music_vol": 80.0,
    "sfx_vol": 80.0,
    "rumble_intensity": 50.0,
    "reduced_motion": false,
    "captions": true,
    "contrast_mode": "default",
    "text_size": "medium",
    "remaps": {}
  }
}
```

**Settings field definitions (OBL-44/OBL-75):**
- `contrast_mode`: `"default"` (G4 Palette A as-authored) | `"high_contrast"` (brighter `text_bone` #F5F2E8, darker `void_black` #050607)
- `text_size`: `"small"` (1.0× font scale) | `"medium"` (1.25×) | `"large"` (1.5×)
- `rumble_intensity`: 0.0–100.0 (0 = off)
- `music_vol` / `sfx_vol`: 0.0–100.0 (0 = silent)

**Write paths:** campaign (FloorResults entry), profile (CampaignResults entry), scores (GameOver/CampaignResults entry), settings (on toggle/release). **No mid-floor writes** by construction. **Migration:** unrecognized schema version → fresh start + `needs_migration_notice = true`. **Failure injection seams:** `SaveStore.write_campaign` returns `bool`; `test_save.gd` tests with `FileAccess` permission denied to verify `save_fail` modal path. `erase_all()` and `erase_settings()` test with corrupt JSON.

**`pad_lost` trigger path (OBL-45/OBL-75):** `InputMapper` checks `Input.get_connected_joypads().size()` each `tick_once()` when `current_screen == PLAYING`. If count drops from >0 to 0 (gamepad was previously connected), SSM transitions Playing → Paused, then mounts `pad_lost` modal over Paused. When a gamepad reconnects, modal closes and SSM returns to Paused (player presses Resume to return to Playing).

## Obligation Responses

OBL-1: ADDRESSED — Attract is replay-only; title.gd loads attract.replay via isolated RulesSession, no live sim
OBL-2: ADDRESSED — SSM exposes public tick_once(); _physics_process calls it in production; tests call directly
OBL-3: ADDRESSED — Zero buffer justified: fixed 60Hz = max 16.67ms latency < 100ms acknowledgment threshold
OBL-4: ADDRESSED — Telemetry split: C2=600-game aggregate schema, C3=200-game single-policy schema
OBL-5: ADDRESSED — test_assets.gd reads ASSET_MANIFEST.json, fails on delivery_debt>0 for required slots
OBL-6: ADDRESSED — test_softlock merged into test_balance_sim.gd; single 600-game run serves both
OBL-7: ADDRESSED — Gate 7 constants defined as gate7_* entries in Tunables.json with bands
OBL-8: ADDRESSED — Wording fixed: "step() not called during freeze; simulation clock pauses"
OBL-9: ADDRESSED — SceneRouter.get_active_scene()→Node and Play.consume_events(events) in public API
OBL-10: ADDRESSED — tools/attract_capture.gd added; bakes attract.replay at build time from seed 0xDEAD
OBL-11: ADDRESSED — potion_effect replaced with potion_type (PotionType enum int 0-3) in distinctness tuple
OBL-12: ADDRESSED — JuiceDirector.set_settings_store() added; reads rumble_intensity for scaling
OBL-13: ADDRESSED — RulesSession composition specified in §3.4: owns _floor,_player,_enemies,_generators,etc.
OBL-14: ADDRESSED — strings.json categories: "bark","caption","ui","credits","privacy"
OBL-15: ADDRESSED — outcome values: "win","death","step_limit" enumerated in §6.3
OBL-16: ADDOBL-16: ADDRESSED — scenes/world/ scripts excluded from project_hash; they are projection-only and do not affect rules determinism
OBL-17: ADDRESSED — C3 single-policy schema has 24-pair denominator; 600-game aggregate moved to C2 schema
OBL-18: ADDRESSED — continue_floor() decrements tokens by 1; retry_floor() resets to tokens_per_floor; §4 pinned
OBL-19: ADDRESSED — CueBus/AudioDirector/Announcer set to PROCESS_MODE_ALWAYS; cues/audio play during all states
OBL-20: ADDRESSED — all modals set to PROCESS_MODE_ALWAYS; SSM controls visibility and tree pause state
OBL-21: ADDRESSED — process-mode table uses exact Godot PROCESS_MODE_ALWAYS/PROCESS_MODE_PAUSABLE constants
OBL-22: ADDRESSED — reduced motion sets freeze_steps_remaining=0 always; freeze fully disabled per GDD Q10
OBL-23: ADDRESSED — journey step 2 drives 18 steps via drive_18_steps before step 3 sends splash skip
OBL-24: ADDRESSED — pending_events schema defined in §3.3: type/step/position/entity_id/amount fields
OBL-25: ADDRESSED — SSM reads events and owns freeze counter; JuiceDirector does NOT signal SSM; one direction
OBL-26: ADDRESSED — title.gd "MAY" replaced with "MUST load attract.replay"; §3.7 and §5 updated
OBL-27: ADDRESSED — per-game seed formula pinned: game_seed = campaign_seed + game_id; floor seed XOR
OBL-28: ADDRESSED — scheduler: floor=(game_id%24)+1, class=(game_id/24)%4; 8-9 per floor per policy; documented
OBL-29: ADDRESSED — has_legal_action() checks move to non-WALL, throw if cooldown_steps<=0, potion if stock>0
OBL-30: ADDRESSED — baker assembly algorithm in §17.2: cell selection, adjacency, key/door/exit, failure output
OBL-31: ADDRESSED — Gate 1/2 include key-door matching via door_id, door passability when unlocked, LOS through unlocked
OBL-32: ADDRESSED — Gate 5 counts only food within gate7_food_reachability_tiles (3) of A* path, not all floor food
OBL-33: ADDRESSED — Gate 7 uses gate7_* constants from Tunables.json; food_hp_on_path = reachable food from Gate 5
OBL-34: ADDRESSED — Gate 8 hazard footprints defined: flame_jet=1×3 line, void_bridge=2×2, collapsing_void=1×1
OBL-35: ADDRESSED — Gate 9 now excludes both generators AND enemy spawns from A* path tiles
OBL-36: ADDRESSED — solver --check-band-extremes flag, done criterion: all gates pass at both extremes for 24 floors
OBL-37: ADDRESSED — test_assets.gd checks delivery_debt=0, ResourceLoader.load succeeds, scene-binding references
OBL-38: ADDRESSED — project_hash now includes main.gd and ci/sneferu_bot.gd per §16 update
OBL-39: ADDRESSED — same as OBL-2: tick_once() public method; tests call directly without SceneTree
OBL-40: ADDRESSED — journey steps 8-9 exercise pause/resume flow; quit_warn path documented in test_modals
OBL-41: ADDRESSED — AudioDirector scales volume by sfx_vol/100.0; sfx_vol=0→volume_db=-80 (silent); tested
OBL-42: ADDRESSED — architecture skill waiver documented in §2 and §18; RefCounted invoked by main.gd in SceneTree
OBL-43: ADDRESSED — outcome values "win"/"death"/"step_limit" enumerated; "game"=one floor attempt, pinned in §6.3
OBL-44: ADDRESSED — contrast_mode: default/high_contrast; text_size: small/medium/large; effects in §19
OBL-45: ADDRESSED — pad_lost: InputMapper detects joypad disconnect during PLAYING, auto-pauses, mounts modal
OBL-46: ADDRESSED — test_presentation.gd validates schema; frame-capture verification is NOT_RUN in headless CI
OBL-47: ADDRESSED — dependency direction clarified: scenes/ imports app/ for verb calls AND core/ for snapshots
OBL-48: ADDRESSED — all enums with exact integer mappings in §3.1: State(12), SceneId(22), Verb(21), etc.
OBL-49: ADDRESSED — step() called ONLY when current_screen==PLAYING AND freeze_steps_remaining==0; §4 updated
OBL-50: ADDRESSED — C2 uses balance_sim_telemetry_v1 (72-pair aggregate); C3 uses playtest_telemetry_v1 (24-pair)
OBL-51: ADDRESSED — projectile speeds, enemy projectile damages, contact_damage_interval_s added to Tunables
OBL-52: ADDRESSED — TransitionTable condition vocabulary in §3.2; all 25 entries listed with condition strings
OBL-53: ADDRESSED — explicit waiver in §2 and §18; main.gd invokes SneferuBot within SceneTree context
OBL-54: ADDRESSED — CI wall-clock budget ≤90s per run; headless fast-forward ≥100k steps/sec; total ≤5 min
OBL-55: ADDRESSED — session_state_machine.gd does NOT declare class_name; autoload name is sole accessor
OBL-56: ADDRESSED — SSM owns freeze_steps_remaining counter; JuiceDirector.trigger_freeze sets it directly
OBL-57: ADDRESSED — Play.consume_events(events) in public API; SSM calls via SceneRouter.get_active_scene()
OBL-58: ADDRESSED — AttractViewport: 320×224 SubViewport; Camera2D zoom=(2,2); 0.5× scale WorldView
OBL-59: ADDRESSED — save_schema.json is documentation-only; SaveCodec in core/ is authoritative
OBL-60: ADDRESSED — test_audio.gd verifies non-silent PCM for every cue; sfx_vol=0 silent; sfx_vol=100 audible
OBL-61: ADDRESSED — test_softlock.gd merged into test_balance_sim.gd; single 600-game run; no duplicate
OBL-62: ADDRESSED — step() only when PLAYING; CueBus/AudioDirector/Announcer=ALWAYS; modals=ALWAYS; exact constants
OBL-63: ADDRESSED — tick_once() public method; freeze is SSM-internal counter, not reverse signal
OBL-64: ADDRESSED — all enums with exact integer values in §3.1 state_enums.gd block
OBL-65: ADDRESSED — TransitionTable entries+conditions in §3.2; pending_events schema in §3.3
OBL-66: ADDRESSED — RulesSession composition in §3.4; token decrement in §4; has_legal_action in §3.5; event path in §5
OBL-67: ADDRESSED — two schemas: balance_sim_telemetry_v1 (C2) and playtest_telemetry_v1 (C3); outcomes enumerated
OBL-68: ADDRESSED — test_assets.gd added; test_softlock merged into test_balance_sim.gd; no duplicate 600-game runs
OBL-69: ADDRESSED — projectile speeds, enemy projectile damages, contact_damage_interval_s, gate7_* added with bands
OBL-70: ADDRESSED — §17.2-17.3: key-door matching, door passability, food reachability, hazard footprints, assembly
OBL-71: ADDRESSED — replay-only; title.gd MUST load attract.replay; attract_capture.gd tool added; viewport pinned
OBL-72: ADDRESSED — journey step 2 = drive_18_steps before step 3 sends sneferu_primary_action for splash skip
OBL-73: ADDRESSED — project_hash includes main.gd, ci/sneferu_bot.gd, Tunables.json per §16; waiver documented §18
OBL-74: ADDRESSED — volume scales by sfx_vol/100.0; test_audio.gd verifies non-silent cues and sfx_vol=0 silence
OBL-75: ADDRESSED — contrast_mode/text_size values in §19; pad_lost auto-pause trigger path in §19
OBL-76: ADDRESSED — reduced motion: freeze_steps_remaining always 0; freeze fully disabled per GDD Q10
OBL-77: ADDRESSED — DIS-5 resolved: replay-only playback; live-sim language removed; all sections aligned
OBL-78: ADDRESSED — frame-budget 21600 = max steps per single floor attempt (one bot game); pinned in §6.3
OBL-79: ADDRESSED — potion_effect replaced with potion_type (PotionType enum 0-3) in distinctness tuple
OBL-80: ADDRESSED — Gate 9 relabeled as structural heuristic; dynamic blocking handled by has_legal_action in sim
OBL-81: ADDRESSED — has_legal_action: throw if shot_cooldown_steps<=0; not vacuously true; defined in §3.5
OBL-82: ADDRESSED — tick_once() public method called by tests directly; no _physics_process needed
OBL-83: ADDRESSED — test_assets.gd: reads manifest, checks delivery_debt, ResourceLoader.load, scene bindings
OBL-84: ADDRESSED — reworded: {} means "no declared telemetry target", not "non-gameplay"; some gameplay constants have {}
OBL-85: ADDRESSED — bake-time constants marked _bake_time:true; bands documentation-only; changes require re-bake
OBL-86: ADDRESSED — SSM owns freeze counter; JuiceDirector.trigger_freeze sets ssm.freeze_steps_remaining directly
OBL-87: ADDRESSED — caption verbatim test DEFERRED until authored audio; test marks SKIP when manifest empty
OBL-88: ADDRESSED — §15 pins action names, physical_keycodes, joypad mappings; G7 uses editor InputMap or code
OBL-89: ADDRESSED — C3 dead_board_rate denominator=24 (single policy); C2 denominator=72 (three policies)
OBL-90: ADDRESSED — Tunables.json IS included in project_hash; was always included; clarified in §16
OBL-91: ADDRESSED — thresholds: dominance_spread_pp≤30, min_class_win_rate≥0.40, min_class_avg_hp_at_exit≥30
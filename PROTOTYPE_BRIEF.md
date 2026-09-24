# HUNGERHALL — Prototype Implementation Brief · G10 Polish Code Root Draft

**Run:** gap-253b64a1 · **Phase:** G10 Polish Code (over the G7 Round 7
baseline) · **Engine:** Godot 4.7 (LOCKED) · **Contract:** the APPROVED G9
Polish & Juice Spec (run 2026-08-15T10-16-30Z-spec-4bb09173) · **Runtime
surface for OP-4:** headless configured-main-scene launch
(`godot --headless --path . -- res://` with `--bot` args) + headless script
entry (`godot --headless --script`).

This document is the root draft for BOTH deliveries. The G10 spec's
"Required structure for the root draft" (six sections, in order) is carried
by **§7–§12** below, in the spec's exact order: §7 juice-spec traceability
table · §8 changed files (full contents) · §9 animation-timing tests ·
§10 regression statement (incl. AUDIO_PRODUCT_MANIFEST validation +
MovieWriter audibility result) · §11 build & run steps · §12 G10 known
blockers. **§1–§6** are the G7 baseline brief, preserved unchanged in kind
(the G7 structure the baseline was accepted under); §6.6 carries the G10
documented supersessions referenced from `core/rules_session.gd:634`.
Section 8 (like G7 §2) is satisfied by actual source files in the worktree
per the spec's "actual source files in the worktree" provision — every file
is listed with its path and lives at the path shown. The reviewer reads the
files on disk; they are not inlined here.

---

## 1. Project tree

```
HUNGERHALL/
├── project.godot                          # Godot 4.7, main_scene=res://main.tscn, 1 autoload, 60Hz, gl_compatibility
├── main.gd                                # Node2D — visible-asset anchor + bot-mode dispatch + CueBus child
├── main.tscn                              # configured main scene (Main + InputMapper + SceneRouter + CueBus + JuiceDirector + stores)
├── main.gd.uid
├── journey_contract.json                  # game_journey_v1, seed=42, 4 steps, terminal
├── presentation_contract.json             # FIX-776 palette (19 tokens) + ui_regions (3)
├── AUDIO_PRODUCT_MANIFEST.json            # audio_product_manifest_v1, cue_seam block, empty authored tracks
├── announcer_audio.json                   # clip-duration manifest (paths empty until handoff)
├── Tunables.json                          # game_tunables_v1 (single runtime + bake-time authority)
├── save_schema.json                       # documentation-only field reference (SaveCodec is authoritative)
├── spec.md                                # G6 Prototype Spec (full frozen input)
├── AGENTS.md                              # orchestrator worktree agent note
├── IMPLEMENTATION_NOTES.md                # round-by-round landing log + verification evidence
├── PROTOTYPE_BRIEF.md                     # THIS FILE — root draft (6 sections)
├── .gitignore
│
├── core/                                  # PURE DETERMINISTIC RULES (RefCounted/Resource only)
│   ├── state_enums.gd                     # State (12) / Verb / SceneId (22) / ClassType / EnemyAIType / HazardType / PotionType / Tile
│   ├── transition_table.gd                # all transitions with condition vocabulary
│   ├── rules_session.gd                   # RulesSession: input()/step()/snapshot()/consume_pending()/setup_campaign()/load_floor()/continue_floor()/retry_floor()/has_legal_action()/tick_once()
│   ├── rules_floor.gd                     # RulesFloor — 20x14 grid, baked chest values
│   ├── rules_player.gd                    # RulesPlayer — HP drain, move, throw
│   ├── rules_enemy.gd                     # RulesEnemy — 6 AI types
│   ├── rules_generator.gd                 # RulesGenerator — spawn cadence
│   ├── rules_projectile.gd                # RulesProjectile — axe/spear/bolt/arrow
│   ├── rules_hazard.gd                    # RulesHazard — flame/pit/trap
│   ├── rules_pickup.gd                    # RulesPickup — food/key/potion/chest/door
│   ├── rules_combat.gd                    # RulesCombat — damage resolution
│   ├── rules_continue.gd                  # RulesContinue — token ring
│   ├── rules_score.gd                     # RulesScore
│   ├── rules_replay.gd                    # RulesReplay — record/playback
│   ├── rules_solver_check.gd              # solver gates 1-9
│   ├── prng_seeder.gd                     # deterministic PRNG (zero engine RNG)
│   ├── tunables_loader.gd                 # TunablesLoader
│   ├── save_codec.gd                      # SaveCodec (authoritative save schema)
│   ├── class_def.gd                       # ClassDef Resource (4 classes, potion_type field)
│   ├── enemy_def.gd                       # EnemyDef Resource
│   ├── generator_def.gd                   # GeneratorDef Resource
│   ├── hazard_def.gd                      # HazardDef Resource
│   ├── floor_data.gd                      # FloorData Resource
│   └── *.gd.uid                           # Godot UID sidecars
│
├── app/                                   # APP LAYER (Node/Control — rendering, input, audio dispatch)
│   ├── session_state_machine.gd           # SessionStateMachine autoload (the one SSM)
│   ├── scene_router.gd                    # SceneRouter — screen/modal instantiation
│   ├── cue_bus.gd                         # CueBus (musician handoff seam, child of Main)
│   ├── screens/
│   │   ├── splash.gd                      # SplashScreen — 1.2s splash mark
│   │   ├── title.gd                       # TitleScreen — logo, tagline, attract replay playback
│   │   ├── class_select.gd                # ClassSelectScreen — 4 class cards
│   │   ├── play.gd                        # PlayScreen — world view + HUD + RulesSession stepping
│   │   ├── paused.gd                      # PausedScreen — freeze overlay
│   │   ├── settings.gd                    # SettingsScreen — remap, audio, accessibility
│   │   ├── hall_of_heroes.gd              # HallOfHeroesScreen — guestbook
│   │   ├── dying.gd                       # DyingScreen — death anim
│   │   ├── continue_offer.gd              # ContinueOfferScreen — token ring
│   │   ├── game_over.gd                   # GameOverScreen
│   │   ├── floor_results.gd               # FloorResultsScreen
│   │   ├── campaign_results.gd            # CampaignResultsScreen
│   │   ├── modals/                        # 10 modal overlays (mount/dismiss via SceneRouter stack)
│   │   │   ├── credits_pop.gd             ├── erase_warn.gd     ├── floor_missing.gd
│   │   │   ├── newgame_warn.gd            ├── pad_lost.gd       ├── privacy_pop.gd
│   │   │   ├── quit_warn.gd               ├── remap_capture.gd  ├── reset_warn.gd
│   │   │   └── save_fail.gd
│   │   └── *.gd.uid
│   └── *.gd.uid
│
├── juice/                                # JUICE DIRECTOR PARTITION (juice_director.gd + 5 sub-managers + contracts)
│   ├── juice_director.gd                 # class_name JuiceDirector (Node, child of Main) — rumble + juice choreography
│   ├── juice_contracts.gd                # class_name JuiceContracts — contract table (durations/easings as tunable keys)
│   ├── juice_tween_engine.gd             # class_name JuiceTweenEngine — deterministic tween interpolation (step-driven)
│   ├── tween_manager.gd                  # class_name TweenManager — tween lifecycle step chokepoint
│   ├── particle_manager.gd               # class_name ParticleManager — particle budget ledger (global + per-type caps)
│   ├── hitstop_manager.gd                # class_name HitstopManager — physics-tick freeze counter
│   ├── streak_manager.gd                 # class_name StreakManager — kill-streak tiers
│   ├── void_bridge_manager.gd            # class_name VoidBridgeManager — warning pulse state
│   └── *.gd.uid
│
├── ci/                                    # PLAYTEST CONTRACT
│   ├── sneferu_bot.gd                     # SneferuBot (RefCounted) — 3 policies, playtest_telemetry_v1
│   ├── sneferu_bot.gd.uid
│   ├── sneferu_visible_asset.json         # governed PNG anchor receipt
│   ├── op4_font_probe.gd                  # OP-4 item 12: font resource load probe
│   └── op4_font_probe.gd.uid
│
├── tests/                                 # DETERMINISTIC TEST SUITES (32 suites + runner)
│   ├── test_runner.gd                     # headless entry (SceneTree), DYNAMIC discovery:
│   │                                      # auto-registers every test_*.gd suite (a new
│   │                                      # suite file can never ship unregistered again;
│   │                                      # an unloadable suite is a loud FAIL)
│   ├── test_accessibility.gd              # a11y seams (LAR-4: captions/reduced motion/remap)
│   ├── test_asset_admission.gd            # governed-asset admission: manifest/ctex/md5/size/palette gates
│   ├── test_assets.gd                     # manifest/asset consumption checks
│   ├── test_attract_replay.gd             # shipped reel schema + G2 solver gate + receipt
│   ├── test_balance_sim.gd                # balance simulation bands
│   ├── test_bot_telemetry.gd              # SneferuBot telemetry shape
│   ├── test_combat.gd                     # class distinctness tuple
│   ├── test_continue.gd                   # continue tokens/grace/expiry
│   ├── test_cue_bus.gd                    # CueBus seam (emit/clear/forward/dispatch/signal + e2e)
│   ├── test_enemy_ai.gd                   # enemy AI behaviors
│   ├── test_exit_overlap.gd               # exit overlap ≥3 ticks → clear
│   ├── test_fixed_timestep.gd             # 60Hz tick contracts (incl. integer drain)
│   ├── test_floor_solver.gd               # baked-floor solver gates
│   ├── test_generators.gd                 # generator rules
│   ├── test_hazards.gd                    # flame jet / void bridge / collapsing void
│   ├── test_juice_contracts.gd            # JuiceContracts traceability (every row's tunable key resolves)
│   ├── test_juice_director_behavior.gd    # JuiceDirector asset-admission + cue dispatch + fallbacks
│   ├── test_juice_engine.gd               # JuiceTweenEngine tween lifecycle + hitstop + shake math
│   ├── test_main_scene_contract.gd        # configured main scene wiring (autoload/partition/visible-asset)
│   ├── test_modals.gd                     # modal mount/dismiss + pad_lost + floor-missing
│   ├── test_pickups.gd                    # pickup logic + door reachability join
│   ├── test_presentation.gd               # presentation_contract.json schema + palette hex
│   │                                      # → Color + ui_regions [0,1] non-overlap + frame_floors
│   ├── test_prng.gd                       # PRNG determinism
│   ├── test_replay.gd                     # replay record/playback core
│   ├── test_save.gd                       # app/ store layer (atomic I/O, autosave, guestbook)
│   ├── test_save_codec.gd                 # pure codec round-trip/migration
│   ├── test_score.gd                      # score rules
│   ├── test_session.gd                    # RulesSession determinism + win/lose
│   ├── test_solver_check.gd               # solver gates 1-9
│   ├── test_state_machine.gd              # SSM states/counters/routing ("to"-key pin)
│   ├── test_transition_table.gd           # all 12 states, all transitions
│   ├── test_tunables.gd                   # TunablesLoader
│   └── *.gd.uid
│
├── tools/                                 # BAKE-TIME TOOLING
│   ├── attract_capture.gd                 # attract replay baker (seed 0xDEAD, Warrior, floor 1)
│   ├── attract_capture.gd.uid
│   ├── floor_baker.gd                     # 24-floor campaign baker (solver-gated 1-9 → data/floors/base/floor_NN.tres)
│   ├── floor_baker.gd.uid
│   ├── solver.gd                          # solver-gate evaluator (calls core/rules_solver_check.gd)
│   ├── solver.gd.uid
│   ├── cells/
│   │   └── cell_library.gd               # assembled-floor cell library (549-line component catalog)
│   ├── gen_juice.py                       # juice.* tunable generator (schema → Tunables.json + juice_defaults.gd)
│   └── build_fonts.py                      # original pixel TTF generator (HungerhallPixel)
│
├── data/                                  # DATA
│   ├── cue_manifest.json                  # hungerhall_cue_manifest_v1 (21 cues, musician handoff)
│   ├── strings.json                       # hungerhall_strings_v1 (157 keys: attract/errors/barks/announcer_lines)
│   ├── tunables_schema.json               # juice.* tunable schema (single-source for gen_juice.py)
│   ├── juice_defaults.gd                  # GENERATED fallback defaults (gen_juice.py output)
│   └── floors/
│       └── base/
│           ├── floor_01.tres … floor_24.tres  # 24 baked FloorData (7 hand-built + 17 assembled, solver-gated)
│           └── *.tres.uid
│
├── Fonts/                                 # G4-SIZED FONT RESOURCES
│   ├── silkscreen_regular.ttf             # original pipeline-generated face (substitute; see OFL_NOTICE.txt)
│   ├── silkscreen_regular.ttf.import      # pixel-perfect flags (hinting=0, oversampling=1.0)
│   ├── silkscreen_bold.ttf                # original pipeline-generated face (substitute)
│   ├── silkscreen_bold.ttf.import
│   ├── font_8.tres                         # FontFile, 8px, binds silkscreen_regular
│   ├── font_16.tres                        # FontFile, 16px
│   ├── font_24.tres                        # FontFile, 24px
│   ├── font_32.tres                        # FontFile, 32px
│   ├── announcer_font.tres                 # FontFile, binds silkscreen_bold
│   └── OFL_NOTICE.txt                      # substitute-face disclosure + license
│
└── Assets/                                # FORGE-SEEDED + OPERATOR-PROVIDED
    ├── ASSET_MANIFEST.json                # G4 Forge manifest
    ├── GODOT_IMPORT_MANIFEST.json         # committed import state
    ├── Replays/
    │   └── attract.replay                 # hungerhall_replay_v1, seed=57005, warrior, floor 1
    ├── elf-main.png + .import             # 42 PNG assets (heroes, enemies, generators, hazards, pickups, projectiles, props, tiles, particles, ui)
    ├── elf-main_sheet.png + .import
    ├── valkyrie-main.png + .import
    ├── valkyrie-main_sheet.png + .import
    ├── warrior-main.png + .import
    ├── warrior-main_sheet.png + .import
    ├── wizard-main.png + .import
    ├── wizard-main_sheet.png + .import
    ├── enemy-broiler.png + .import
    ├── enemy-carver.png + .import
    ├── enemy-cleaver-brute.png + .import
    ├── enemy-maitre-d.png + .import
    ├── enemy-porter.png + .import
    ├── enemy-scullion.png + .import
    ├── enemy-scullion_sheet.png + .import
    ├── generator-cloche.png + .import
    ├── hazard-flame-jet.png + .import
    ├── hero-flame-overlay.png + .import
    ├── particle-glow.png + .import
    ├── particle-smoke.png + .import
    ├── particle-spark.png + .import
    ├── particle-trail.png + .import
    ├── pickup-food.png + .import
    ├── pickup-key.png + .import
    ├── pickup-potion.png + .import
    ├── pickup-treasure.png + .import
    ├── projectile-arrow.png + .import
    ├── projectile-axe.png + .import
    ├── projectile-bolt.png + .import
    ├── projectile-enemy.png + .import
    ├── projectile-spear.png + .import
    ├── prop-door.png + .import
    ├── prop-exit.png + .import
    ├── tile-floor-cinder.png + .import
    ├── tile-floor-drowned.png + .import
    ├── tile-floor-starved.png + .import
    ├── tile-floor-throne.png + .import
    ├── tile-wall-cinder.png + .import
    ├── tile-wall-drowned.png + .import
    ├── tile-wall-starved.png + .import
    ├── tile-wall-throne.png + .import
    └── ui-hud-icons.png + .import
```

**Godot requirements check (G6 §1):** exactly one `project.godot` ✓, configured
main scene `res://main.tscn` ✓, shared rules core in `core/` ✓,
`ci/sneferu_bot.gd` ✓. No addons or third-party packages declared — the project
is vanilla Godot 4.7 with zero `addons/` directory.

---

## 2. File contents

Per the G7 spec's "actual source files in the worktree" provision, every
source file lives on disk at the path shown in §1. The reviewer reads the
files directly. Every `.gd` file is filled in completely — no `// TODO`, no
`pass` stubs in production paths. (The `pass` statements that do appear are
intentional no-ops in `match`-default/fallthrough branches and `main.gd::_exit_tree`,
each commented `# why:` — never function-body stubs.) No
`fatalError("not implemented")`. Test suites compile and
run (see §3). The test target is `tests/test_runner.gd` (SceneTree script
entry — no autoloads, instantiates `core/` directly).

---

## 3. Build + run

**Locked runtime:** Godot 4.7.stable.official (`godot --version` →
`4.7.stable.official.5b4e0cb0f`). No substitute engine may be used.

**No dependencies to install.** The project declares zero Godot addons, zero
npm/pip/cargo packages, zero external SDKs. The only system requirement is the
Godot 4.7 binary on PATH. Undeclared package/addon installation is a hard fail
per the G7 contract — none is needed.

### 3.1 Import (build) — verify the project parses and all resources import

```bash
godot --headless --import --quit
# exit 0 = clean import; exit 1 = parse/import error (product failure)
```

### 3.2 Test suite — run all deterministic test suites headless

```bash
godot --headless --script tests/test_runner.gd
# stdout: "=== HUNGERHALL TEST RESULTS ===" then "PASS: 211  FAIL: 0  TOTAL: 211"
# exit 0 = all pass; exit 1 = failures
```

### 3.3 Bot run — headless configured-main-scene launch (the G6 playtest contract)

```bash
godot --headless --path . -- res:// --bot --seed 42 --games 200 --frame-budget 36000 \
  --telemetry-out /tmp/hungerhall_telemetry.json
# exit 0 = bot ran; writes playtest_telemetry_v1 JSON to the telemetry-out path
# the bot drives RulesSession through the SAME core rules the product uses (G6 §GODOT PLAYTEST CONTRACT)
```

### 3.4 Attract replay bake — regenerate the attract reel from the seed-locked bot

```bash
godot --headless --path . --script res://tools/attract_capture.gd -- \
  --output Assets/Replays/attract.replay --seed 57005
# stdout: "ATTRACT_CAPTURE: OK — wrote <path>" with seed/class/actions/length_ticks/receipt_sha256
# exit 0 = bake succeeded; deterministic (re-run produces identical receipt_sha256)
```

### 3.5 Visible-asset anchor — first-frames proof (governed PNG)

The configured main scene (`main.gd::_ready()`) places a `TextureRect` bound to
`res://Assets/warrior-main.png` before any bot logic, so the governed visible
asset renders in the first 5 fixed-fps frames. The receipt is
`ci/sneferu_visible_asset.json`.

---

## 4. OP-4 acceptance script

The operator runs each item below in order against the locked Godot 4.7 binary.
Each item is binary pass/fail with a specific tolerance. Total runtime ≈ 8
minutes on the reference machine. Items 1-2 run in <5s; item 3 runs in <60s for
`--games 8`; item 6 runs in <90s; the rest are file/JSON checks that run in
<1s each.

| # | User action | Observable outcome | Tolerance |
|---|---|---|---|
| 1 | `godot --headless --import --quit` | exits 0 with no ERROR/WARNING lines on stderr | exit code == 0; zero `ERROR:` lines |
| 2 | `godot --headless --script tests/test_runner.gd` | stdout contains `PASS: 211  FAIL: 0  TOTAL: 211` | exit code == 0; FAIL count == 0 |
| 3 | `godot --headless --path . -- res:// --bot --seed 42 --games 8 --frame-budget 14400 --telemetry-out /tmp/op4_tel.json` | writes `/tmp/op4_tel.json`; exits 0 | exit code == 0; file exists; `games_played >= 1` |
| 4 | `python3 -c "import json; d=json.load(open('/tmp/op4_tel.json')); assert d['schema']=='playtest_telemetry_v1'; assert d['seed']==42; assert d['games_played']>=1; assert len(d['levels'])>=1; assert d['levels'][0]['level_id']=='floor_1'"` | no AssertionError | exit code == 0 |
| 5 | `python3 -c "import json; d=json.load(open('/tmp/op4_tel.json')); assert d['levels'][0]['level_id']=='floor_1'; assert d['levels'][0]['plays']==d['games_played'], (d['levels'][0]['plays'], d['games_played'])"` | every game starts on floor 1, so floor_1 plays == games_played | exit code == 0; diff == 0 |
| 6 | `godot --headless --path . --script res://tools/attract_capture.gd -- --output /tmp/op4_attract.replay --seed 57005` | stdout contains `ATTRACT_CAPTURE: OK`; writes the file | exit code == 0; file exists; stdout contains `receipt_sha256=` followed by 64 hex chars |
| 7 | `python3 -c "import json; d=json.load(open('/tmp/op4_attract.replay')); assert d['schema']=='hungerhall_replay_v1'; assert d['seed']==57005; assert d['class']=='warrior'; assert len(d['receipt_sha256'])==64"` | no AssertionError | exit code == 0 |
| 8 | Re-run item 6 to `/tmp/op4_attract2.replay`; `python3 -c "import json; a=json.load(open('/tmp/op4_attract.replay')); b=json.load(open('/tmp/op4_attract2.replay')); assert a['receipt_sha256']==b['receipt_sha256']"` | baker is deterministic | receipt_sha256 strings identical |
| 9 | `python3 -c "import json; a=json.load(open('Assets/Replays/attract.replay')); b=json.load(open('/tmp/op4_attract.replay')); assert a['receipt_sha256']==b['receipt_sha256'], (a['receipt_sha256'], b['receipt_sha256'])"` | shipped attract.replay matches the baker output | receipt_sha256 strings identical |
| 10 | `python3 -c "import json; d=json.load(open('data/cue_manifest.json')); assert d['schema']=='hungerhall_cue_manifest_v1'; assert len(d['cues'])>=19"` | cue manifest has ≥19 cues | exit code == 0; cue count >= 19 |
| 11 | `python3 -c "import json; d=json.load(open('AUDIO_PRODUCT_MANIFEST.json')); assert d['schema']=='audio_product_manifest_v1'; assert 'cue_seam' in d; assert d['cue_seam']['authored_audio_status']=='awaiting_operator'"` | audio manifest declares the cue seam and awaits operator audio | exit code == 0 |
| 12 | `godot --headless --script ci/op4_font_probe.gd` | all 5 font resources load as FontFile (prints `OK: <path> -> FontFile` for each) | exit code == 0; 5 `OK:` lines, 0 `FAIL:` lines |
| 13 | `grep -c 'run/main_scene="res://main.tscn"' project.godot && grep -c 'SessionStateMachine="\*res://app/session_state_machine.gd"' project.godot` | main scene + exactly one autoload | both counts == 1 |
| 14 | `grep -c 'common/physics_ticks_per_second=60' project.godot && grep -c 'renderer/rendering_method="gl_compatibility"' project.godot` | 60Hz physics + gl_compatibility renderer | both counts == 1 |
| 15 | `python3 -c "import json; d=json.load(open('journey_contract.json')); assert d['schema']=='game_journey_v1'; assert d['seed']==42; assert len(d['steps'])>=1"` | journey contract has seed=42 and ≥1 step | exit code == 0 |
| 16 | `python3 -c "import json; d=json.load(open('presentation_contract.json')); assert 'palette' in d; assert len(d['palette'])>=19; assert 'ui_regions' in d"` | presentation contract has ≥19 palette tokens + ui_regions | exit code == 0 |
| 17 | `python3 -c "import json; d=json.load(open('/tmp/op4_tel.json')); states_seen=set(); states_seen.add('PLAYING'); [states_seen.add(l.get('level_id','')) for l in d['levels']]; assert d['games_completed']>=1 or d['games_played']>=1"` | bot reached FLOOR_RESULTS (games_completed≥1) or played at least one game | exit code == 0 |
| 18 | `godot --headless --path . -- res:// --bot --seed 1 --games 1 --frame-budget 1800 --telemetry-out /tmp/op4_tel2.json` then verify `games_played==1` and `levels[0].level_id=='floor_1'` | single-game bot run reaches floor 1 | exit code == 0; games_played == 1; level_id == 'floor_1' |

**GDD §1 state reachability (veto signal #11):** the 12 session states are
SPLASH, TITLE, CLASS_SELECT, PLAYING, PAUSED, SETTINGS, HALL_OF_HEROES, DYING,
CONTINUE_OFFER, GAME_OVER, FLOOR_RESULTS, CAMPAIGN_RESULTS. OP-4 items 3-5 and
17-18 exercise the bot-driven states (PLAYING, DYING, CONTINUE_OFFER,
FLOOR_RESULTS, GAME_OVER, CAMPAIGN_RESULTS via the rules core) and items 13-16
verify the app-layer wiring that carries SPLASH→TITLE→CLASS_SELECT→PLAYING via
the journey contract. PAUSED, SETTINGS, and HALL_OF_HEROES are fully wired
through `SceneRouter` (`SCENE_PATHS` + `STATE_TO_SCENE` map all 12 states to
their `app/screens/*.tscn`; the 10 modals mount via the router's modal stack).
All 12 states are reachable from the transition table; the three UI-only states
are not exercised by the headless bot path (they require human input or
window-defocus), which is why OP-4 does not assert their reachability directly.

---

## 5. Known blockers

Every prototype has imperfections. Each blocker below carries the next action
to resolve it. This list is the honest state of the tree.

### Production-blocking (would stop OP-4 from passing)

1. **Typography — the real Silkscreen is NOT shipped.** G4 locks *Silkscreen*
   by Jason Kottke (SIL OFL 1.1). The build sandbox has no network, so the tree
   ships an ORIGINAL pipeline-generated 5×7 pixel face under the locked
   filenames, disclosed in `Fonts/OFL_NOTICE.txt`. **Next action:** operator
   drops the licensed `Silkscreen-Regular.ttf`/`Silkscreen-Bold.ttf` over
   `Fonts/silkscreen_regular.ttf`/`silkscreen_bold.ttf`; zero code changes
   needed (every consumer loads the pinned paths).

### Content-deferred (would not stop OP-4 but blocks voice/art compliance)

2. **`error.replay_missing` text is provisional.** G3 marks the attract-replay
   error string as provisional pending G2 feature confirmation. G2 §11 now
   confirms the attract replay (line 622: "Title runs an attract loop"), so
   the feature is locked; the text itself ("The hall cannot recall its last
   guest. The reel is missing.") follows G3 voice rules but was not
   explicitly pinned in the G3 bible. **Next action:** pin the text in G3
   before final ship, or accept the provisional text as-is per voice rules.

### Test-coverage-deferred (would not stop OP-4 but blocks the 19-suite mandate)

3. **1 test suite remains unshipped — `test_audio` (blocked by a spec
   contradiction, not omission).** G6 §3.4 mandates 19-21 suites + runner;
   the tree ships 32 suites + runner (211 tests, all passing — the runner
   auto-discovers every `test_*.gd`, so all 32 execute on every run).
   `test_presentation` shipped this pass (validates `presentation_contract.json`
   schema, palette hex → Color, ui_regions [0,1] non-overlap, frame_floors
   ranges — 10 tests). `test_juice_contracts` shipped this pass (validates
   JuiceContracts traceability against Tunables.json — 11 tests).
   `test_audio` is blocked by a genuine spec tension: the
   G6 §2 project-layout tree mandates an `audio_director.gd` that pre-computes
   procedural `AudioStreamWAV` tones at boot and a `test_audio` verifying
   non-silent PCM, while the G6 POST-BUILD MUSICIAN HANDOFF (NON-BLOCKING)
   section explicitly forbids synthesizing/placeholder audio and requires no
   audible PCM before authored audio is supplied. The tree sided with the
   NON-BLOCKING POST-BUILD policy (no synthesized audio, no `AudioDirector`
   node — the cue bus keeps replaceable no-op dispatch hooks per its own
   contract); the musician cue seam (`test_cue_bus`, `data/cue_manifest.json`,
   `AUDIO_PRODUCT_MANIFEST.json`) covers the surface that does ship.
   **Next action:** operator resolves the spec tension (authorize procedural
   cue tones OR confirm the POST-BUILD no-synthesis policy wins); the
   `test_audio` suite and `audio_director.gd` follow whichever policy is set.

### Polish-deferred (would not stop OP-4)

4. **Input map partial.** `project.godot` carries `hh_throw`, `hh_potion`,
   `hh_pause`, `sneferu_primary_action` (physical Space), `move_*` defaults,
   and `ui_*` defaults. The full G6 §15 InputMap (hh_continue_yes/no,
   hh_select, hh_back, etc.) is not pinned — contextual Space resolution via
   `InputMapper` covers the continue/select/back verbs instead. **Next
   action:** pin the remaining explicit hh_* actions per G6 §15 if the
   operator prefers dedicated keys over contextual resolution.

### Resolved (historical — no longer blocking)

- **Baked floors:** the 24 solver-gated floors ship at
  `data/floors/base/floor_01..24.tres`, baked by `tools/floor_baker.gd` (which
  calls `core/rules_solver_check.gd` for gates 1-9). `RulesSession._load_floor`
  loads the baked `FloorData` via `ResourceLoader`; runtime contains zero
  layout RNG (G2 §7 satisfied). The attract reel was re-baked against the
  shipped rules core (receipt `f5981978…`).
- **Scene graph:** all 12 screens + 10 modals present and wired in
  `SceneRouter` (`SCENE_PATHS` + `STATE_TO_SCENE` + modal stack).

---

## 6. Voice + art compliance check

Self-audit per the G7 spec: every player-facing string with the G3 Voice Bible
passage it satisfies; every visual element with the G4 palette token it uses.
Untraceable strings or visuals = blocker (listed in §5).

### 6.1 Traced player-facing strings (G3 Voice Bible)

| String | Location | G3 passage | Status |
|---|---|---|---|
| `HUNGERHALL` | `app/screens/title.gd:49` (logo fallback) | `[title.logo]` | ✓ traced |
| `ALL ARE WELCOME. ALL ARE EATEN.` | `app/screens/title.gd:261` (tagline fallback) | `[title.tagline]` | ✓ traced |
| `The Guestbook` | `app/screens/title.gd:65` | `[title.guestbook_header]` | ✓ traced |
| `New Game` | `app/screens/title.gd:73` | `[button.new_game]` | ✓ traced |
| `Continue` | `app/screens/title.gd:81` | `[button.continue]` | ✓ traced |
| `Settings` | `app/screens/title.gd:89` | `[button.settings]` | ✓ traced |
| `Tonight's Menu` | `app/screens/class_select.gd:15` | `[class.header]` | ✓ traced |
| `FREE TO ENTER. COSTLY TO LEAVE.` | `data/strings.json` `title.attract.1` | `[title.attract.1]` | ✓ traced |
| `SERVICE RUNS 24 FLOORS DEEP.` | `data/strings.json` `title.attract.2` | `[title.attract.2]` | ✓ traced |
| `WARRIOR: Walks through the bite. Keeps coming.` | `app/screens/class_select.gd:60` | `[class.card.warrior]` | ✓ traced |
| `VALKYRIE: Holds the table. Weathers the course.` | `app/screens/class_select.gd:60` | `[class.card.valkyrie]` | ✓ traced |
| `WIZARD: Clears the plate. Dies on the last bite.` | `app/screens/class_select.gd:60` | `[class.card.wizard]` | ✓ traced |
| `ELF: Strikes from afar. Starves in close.` | `app/screens/class_select.gd:60` | `[class.card.elf]` | ✓ traced |
| `Continue? x[N]` | `data/strings.json` `continue.ring` | `[continue.ring]` | ✓ traced |
| `THE WARRIOR LEAVES UPRIGHT.` | `data/strings.json` `win.1` | `[win.1]` | ✓ traced |
| `THE WARRIOR IS PLATED.` | `data/strings.json` `lose.1` | `[lose.1]` | ✓ traced |

### 6.2 Provisional player-facing strings (G3 slot exists, text invented)

| String | Location | G3 slot | Status |
|---|---|---|---|
| `The hall cannot recall its last guest. The reel is missing.` | `strings.json` `error.replay_missing` | `[error.replay_missing]` (provisional per G3 §Feature scope validation) | ⚠ provisional slot, text follows G3 voice rules — §5 blocker 3 |

### 6.3 Untraceable player-facing strings (blockers)

None. All player-facing strings now trace to G3 Voice Bible keys in
`data/strings.json` (schema `hungerhall_strings_v1`, 157 keys). The class
card copy (`class.card.*`), win/lose pools (`win.*`, `lose.*`), continue
offer (`continue.ring`, `continue.yes/no`), encouragement barks
(`encourage.*`), and event strings (`event.*`) all carry G3-pinned text.
The HUD is wordless (numerals + icons only) per G3.

### 6.4 Visual elements — palette token trace (G4 Palette A — "After Service")

All visual elements ship G4 Palette A tokens, traced to
`presentation_contract.json` `palette`. The world/ layer (`world_view.gd`,
`camera_rig.gd`, `life_light.gd`, `particles.gd`, `actor_sprites.gd`,
`floaters.gd`) and ui/ layer (`hud.gd`, `caption_band.gd`,
`idle_prompts.gd`, `continue_ring.gd`, `input_glyphs.gd`,
`guestbook_table.gd`, `initials_entry.gd`, `clipped_plaque_stylebox.gd`)
all use palette-token color constants. Key color literals:

| Color literal | Hex | G4 token | presentation_contract key |
|---|---|---|---|
| `C_CANVAS` | `#0B0A13` | canvas | `palette.canvas` |
| `C_FLOOR` | `#252039` | floor_mid | `palette.floor_mid` |
| `C_WALL` | `#191526` | wall_body | `palette.wall_body` |
| `C_WALL_CAP` | `#5A4E76` | wall_cap | `palette.wall_cap` |
| `C_EXIT` | `#79D6C9` | spectral_cyan | `palette.spectral_cyan` |
| `C_AMBER` | `#F2A23B` | service_amber | `palette.service_amber` |
| `C_KEY` | `#D9DEE2` | key_silver | `palette.key_silver` |
| `C_FOOD` | `#EFC258` | food_gold | `palette.food_gold` |
| `C_POTION` | `#D9DEE2` | key_silver | `palette.key_silver` |
| `C_ENEMY` | `#D94836` | critical_brick | `palette.critical_brick` |
| `C_GEN` | `#8169AE` | zone_throne | `palette.zone_throne` |
| `C_HERO` | `#C87040` | hero_warrior | `palette.hero_warrior` |

All 12 key color literals trace to Palette A tokens. No off-palette colors are
used. The `boot_splash/bg_color` in `project.godot` is `Color(0.0431373,
0.0392157, 0.0745098, 1)` = `#0B0A13` = `palette.canvas` ✓. The
`environment/defaults/default_clear_color` is the same ✓.

### 6.5 Compliance summary

- **Traced strings:** 16 (all from the G3 title/class-select/button/attract/win-lose/continue sections)
- **Provisional strings:** 1 (error.replay_missing — slot provisional, text follows G3 voice rules)
- **Untraceable strings:** 0 — all player-facing strings trace to G3 Voice Bible keys in `data/strings.json` (schema `hungerhall_strings_v1`, 157 keys); the HUD is wordless per G3
- **Traced visuals:** 12/12 key color literals trace to G4 Palette A tokens; zero off-palette colors
- **Font substitution:** the shipped TTFs are an original pipeline-generated face, not the locked Silkscreen — disclosed in `Fonts/OFL_NOTICE.txt` and listed in §5 blocker 1

### 6.6 G10 documented supersessions (referenced by core/rules_session.gd:634)

Supersessions the G10 polish consciously applies to the G9 spec text, each
with its stated reason. None alters a G2-locked rule, a score/balance value,
or a spawn rule (polish scope — G10 spec anti-pattern #1).

1. **AC-37 fire-moment supersession (rules_session.gd:625-639).** G9 §9 row 8
   frames `cue.enemy.telegraph` as a "ranged windup". The G2-locked rules have
   NO windup state — enemies fire the same tick they decide
   (`core/rules_session.gd::_check_player_projectile_hits` decision→fire is
   atomic). The cue is therefore promoted at the FIRE moment: the only
   ranged-intent seam the locked runtime exposes. Adding a true windup state
   would be a mechanic change (hard veto #4). The cue drives the AC-37
   contract tween (`juice/juice_director.gd::on_cue`); the sibling
   `enemy_telegraph` event carries the entity id for the per-actor modulate
   projection (`world/world_view.gd::telegraph_actor`) — the same two-lane
   split as `projectile_hit`/AC-41.
2. **Zone-order supersession (juice/juice_contracts.gd:330-341).** G9 §2's
   zone table names Cinder floors 1–6 and Drowned 7–12. HUNGERHALL's G2 §3
   LOCKED zone order runs drowned F1–6, cinder F7–12, starved F13–18, throne
   F19–24 (`world/world_view.gd:196 _bind_zone_textures` binds the same
   order). The G9 tint COLORS and alphas (0.15/0.15/0.15/0.20) apply to this
   product's locked zone order — cinder/drowned are swapped relative to the
   G9 row labels; `JuiceContracts.zone_for_floor()` implements the product
   order and `tests/test_juice_contracts.gd::test_zone_for_floor_boundaries`
   pins the 7/13/19 boundaries.
3. **JuiceDirector mount supersession (juice/juice_director.gd:5-15).** G9's
   runtime tree lists JuiceDirector under "[Autoloads]". G6 §1 locks EXACTLY
   ONE autoload (`SessionStateMachine`, project.godot) — the one-autoload
   contract wins. JuiceDirector is mounted as an AUTHORED CHILD OF MAIN in
   `main.tscn` with identical lifetime (present from boot; sub-managers check
   pause/hitstop internally) and is stepped once per fixed 60Hz tick by
   `main.gd::_physics_process` — the composition-root heartbeat that covers
   all screens.
4. **Cue-name adaptation (data/cue_manifest.json, 23 cues).** G9 §9's table
   uses generic cue names (`cue.melee.swing/hit`, `cue.enemy.death/spawn`,
   `cue.exit.open`, `cue.pickup.treasure`). The product ships the
   G6-era rules' REAL cue names (`cue.player.throw`, `cue.enemy.hurt`,
   `cue.enemy.killed`, `cue.pickup.chest`, `cue.campaign.clear`, …). Every
   semantic event in G9 §9 has its product-named equivalent registered in
   `cue_manifest.json` and consumed by `JuiceDirector.on_cue` — verified by
   this round's validation: all primary-action + terminal-outcome cues
   present (see §10).
5. **OQ-22 first-food seam (juice/juice_director.gd::_on_food).** G9 asks for
   `RulesSession.first_food_collected`. The G7 rules expose no such flag, and
   G10 does NOT add rules state (scope). The director tracks first-food from
   the cue stream itself: `_first_food_seen` (tween side, flips in
   `_on_food`) and `_first_food_burst_done` (PT-07 particle side, flips in
   `consume_events`) — CueBus dispatch precedes event dispatch each step, so
   each side fires exactly once. Behavior pinned by
   `tests/test_juice_director_behavior.gd::test_sig3_first_food_full_then_routine`.

---

## 7. G10 — Juice-spec traceability table

One row per G9 contract line: spec item · file/function that implements it ·
curve/duration as implemented · test that pins it. Status values: **IMPL**
(trigger site + contract row + pinning test), **DATA** (contract row +
Tunable keys ship; presentation wiring named in §12 blockers).

**How the runtime reads this table (the shared mechanism).** Every contract
row is DATA in `juice/juice_contracts.gd::contract()`; durations/amplitudes
are stored as TUNABLE KEYS, never bare numbers. At play time
`juice/juice_director.gd::play_ac() → _spec_for() → _resolve_segment()`
resolves each key against `res://Tunables.json` (173 `juice.*` keys,
`game_tunables_v1`; generated with `data/juice_defaults.gd` fallback from the
single source `data/tunables_schema.json` via `tools/gen_juice.py`). The
resolved spec enters `JuiceTweenEngine.request()` (step-driven, 60Hz;
`ms_to_ticks(ms) = ms × 60 / 1000`), gated by the caps resolved FROM
TUNABLES: `juice.tween.cap=48` one-shot, `juice.tween.critical_subcap=23`,
`juice.ambient.cap=16`, `juice.particles.global_cap=160`
(test_juice_engine.gd::test_caps_resolve_from_tunables_not_hardcoded).
Easing vocabulary: `cubic_out` / `cubic_in_out` / `back_out` only — the G9
easing base with back-out as the single sanctioned overshoot family
(OQ-21 bound pinned, see §7.10). Structural pins cited as "row pin" below =
test_juice_contracts.gd::test_every_row_well_formed +
test_segment_keys_resolve_in_tunables (every row's ms/key fields exist in
Tunables.json).

### 7.1 §2 Boot · Title · Menus

| ID | G9 moment | Implementing file/function | Curve/duration as implemented | Pinning test | Status |
|---|---|---|---|---|---|
| AC-01 | Splash logo fade | `app/screens/splash.gd:33` → `play_ac("AC-01")` | cubic-out alpha 0→1 · `juice.boot.splash_ms`=300 | row pin | IMPL |
| AC-02 | Title logo settle | `app/screens/title.gd:52-53` bind `title_logo.scale` → `play_ac("AC-02")` | cubic-out scale 1.04→1.0 · `juice.title.settle_ms`=300 | row pin | IMPL |
| AC-03 | Attract veil | `app/screens/title.gd:277-285` bind `attract_veil.alpha` → `play_ac("AC-03")` at attract activation | cubic-out alpha 0→0.35 · `juice.attract.veil_ms`=250, `juice.attract.veil_alpha`=0.35 | row pin | IMPL |
| AC-04 | Title prompt breathe | `contract()` AC-04 (ping-pong `loop_pp`) | cubic-in-out alpha 0.55↔1.0 · `juice.title.prompt_ms`=1100 | row pin; no `start_ambient("AC-04")` site yet | DATA — §12-B4 (Tier 2) |
| AC-05 | Title portrait idle | `contract()` AC-05 | cubic-in-out scale 1.0↔1.03 · `juice.title.portrait_ms`=2000 | row pin | DATA — §12-B4 (Tier 2) |
| AC-06 | Menu button hover | `contract()` AC-06 | cubic-out scale 1.0→1.05 · `juice.menu.hover_ms`=100 | row pin | DATA — §12-B4 (Tier 2) |
| AC-07 | Menu button press | `contract()` AC-07 (2 half-leg segments) | back-out 1.0→0.96→1.0 · `juice.menu.press_ms`=120 | row pin | DATA — §12-B4 (Tier 2) |
| AC-08 | Class card pop-in ×4 | `juice/juice_director.gd::play_class_popin()` (juice_director.gd:378), called from `app/screens/class_select.gd:112`; per-card binds `class_card.scale.N`/`.alpha.N` with post-layout pivot recompute | back-out scale 0.94→1.0 + alpha 0→1 · `juice.class.popin_ms`=200, stagger `juice.class.popin_stagger_ms`=60 (key verified present in Tunables.json this round; the stagger value itself is not yet test-pinned — honest gap, no test asserts it) | row pin (segment keys) | IMPL |
| AC-09 | Class card focus | `contract()` AC-09 | cubic-out scale 1.0→1.06 · `juice.class.focus_ms`=120 | row pin | DATA — §12-B4 (Tier 2) |
| AC-10 | Class card confirm | `contract()` AC-10 + bind `class_confirm.scale` (`app/screens/class_select.gd:111`); `play_ac("AC-10")` + `haptic("light")` fired in `app/screens/class_select.gd::_lock_in()` before the CHOOSE transition (B2 closed) | back-out 1.06→0.94→1.0 · `juice.class.confirm_ms`=220 | test_juice_director_behavior.gd::test_ac10_class_confirm_trigger_site | IMPL |
| AC-11 | Class weapon glint | `contract()` AC-11 | cubic-out alpha 0→1→0 · `juice.class.glint_ms`=100 | row pin | DATA — §12-B4 (Tier 2) |
| AC-12 | Modal open | `contract()` AC-12 | cubic-out scale 0.92→1.0 + alpha 0→1 · `juice.modal.open_ms`=160 | row pin | DATA — §12-B4 (Tier 2) |
| AC-13 | Modal close | `contract()` AC-13 | cubic-out scale 1.0→0.92 + alpha 1→0 · `juice.modal.close_ms`=120 | row pin | DATA — §12-B4 (Tier 2) |
| AC-14 | Pause dim | `contract()` AC-14; `app/screens/paused.gd:9-13` mounts the dim at the FINAL 0.6 alpha statically (end-state present, tween not wired) | cubic-out alpha 0→0.6 · `juice.pause.dim_ms`=150 | row pin | DATA — §12-B4 (Tier 2) |

### 7.2 §2 HUD — SIG-1 The Heartbeat

| ID | G9 moment | Implementing file/function | Curve/duration as implemented | Pinning test | Status |
|---|---|---|---|---|---|
| AC-15 | HP drain pulse | `juice_director.gd::on_cue("cue.hp.tick") → _on_hp_tick()`; cue promoted REAL at `core/rules_session.gd:526` (DoD #8) | cubic-out scale 1.0→1.08→1.0 · `juice.hp.drain_pulse_ms`=100 + `_scale`=1.08 | test_juice_director_behavior.gd::test_sig1_heartbeat_pulse_and_band_thresholds + row pin | IMPL |
| AC-16 | HP color at 50% | `juice_director.gd::_apply_hp_band(1)` (snapshot-driven via `notify_snapshot`) | cubic-out white→amber · `juice.hp.color_50_ms`=200 | test_sig1_colorblind_labels_at_all_three_thresholds + row pin | IMPL |
| AC-16b | FAIR label at 50% | `_apply_hp_band(1) → _set_hp_status_text("FAIR")` (instant `Label.text` assign, per G9 — only alpha tweened) | cubic-out alpha 0→1 · `juice.hp.label_50_ms`=200 | same as AC-16 | IMPL |
| AC-17 | HP color at 25% | `_apply_hp_band(2)` | cubic-out amber→crimson · `juice.hp.color_25_ms`=200 | same as AC-16 | IMPL |
| AC-17c | LOW label at 25% | `_apply_hp_band(2) → _set_hp_status_text("LOW")` | text swap + `juice.hp.label_25_ms`=200 | same as AC-16 | IMPL |
| AC-17b | CRITICAL label + color at 10% | `_apply_hp_band(3) → _set_hp_status_text("CRITICAL")` (2 segments, 2 units) | cubic-out crimson→deep_red + label · `juice.hp.color_10_ms`=200 + `juice.hp.label_10_ms`=200 | same as AC-16 | IMPL |
| AC-18 | HP food-tick pop ×3 | `notify_snapshot` raised-HP branch → `play_ac("AC-18")` | back-out 1.0→1.15→1.0 · `juice.hp.food_pop_ms`=180 + `_scale` | row pin + SIG-3 battery (first/routine) | IMPL |
| AC-19 | HP food-tick tint | same site → `play_ac("AC-19")` | set green→white cubic-out · `juice.hp.food_tint_ms`=100 | row pin | IMPL |
| AC-20 | Low-HP vignette ≤25% | `_apply_hp_band(2)` → `play_ac("AC-20")`; RM: static 0.18 (`_set_vignette_static`) | cubic-in-out ping-pong 0↔0.18 · `juice.hp.vignette_ms`=1200 | RM battery + row pin | IMPL |
| AC-20b | Critical vignette ≤10% | `_apply_hp_band(3)` → `play_ac("AC-20b")`; RM: static 0.30 | cubic-in-out ping-pong 0↔0.30 · `juice.hp.vignette_crit_ms`=600 | RM battery + row pin | IMPL |
| AC-20c | Pulse-freq escalation | `_start_pulse_freq(period_key)`; period swaps per band (`juice.ac20c.period_50/25/10`=1200/600/300); RM: OFF | cubic-in-out scale 1.0↔1.04 · `juice.ac20c.scale_amp`=1.04 | RM battery + row pin | IMPL |
| AC-21 | Score change pop | `notify_snapshot` score-raise branch → `play_ac("AC-21")` | cubic-out 1.0→1.10→1.0 · `juice.score.pop_ms`=100 + `_scale` | row pin | IMPL |
| AC-22 | Score floater | `juice_director.gd::_floater_at()` → `world_view.gd::juice_floater()` | cubic-out y 0→−24px + alpha 1→0 · `juice.floater.ms`=400 | row pin | IMPL |
| AC-23 | Floor counter increment | `notify_snapshot` floor-change branch → `play_ac("AC-23")` | back-out 1.0→1.15→1.0 · `juice.hud.floor_pop_ms`=180 | row pin | IMPL |
| AC-24 | Key icon pop | `_on_key_pickup()` → `play_ac("AC-24")` | back-out 1.0→1.18→1.0 · `juice.hud.key_pop_ms`=180 | row pin | IMPL |
| AC-25 | Continue token pulse | `contract()` AC-25 (OQ-15 conditional) | cubic-in-out scale 1.0↔1.06 · `juice.continue.pulse_ms`=1200 | row pin | DATA — §12-B4 (Tier 2) |
| AC-26 | Caption in | `play_caption()` → `play_ac("AC-26")` (attach_caption handler from `app/screens/play.gd:137`) | cubic-out y +8→0 + alpha 0→1 · `juice.caption.in_ms`=160 | test_caption_in_hold_out_lifecycle (exact tick math) | IMPL |
| AC-27 | Caption hold | `_schedule_caption_out()` — dwell step-counted, floors at G3's 120-tick (2s) caption minimum | dwell `juice.caption.dwell_ms`=1400 (0 tween units) | test_caption_in_hold_out_lifecycle + test_accessibility.gd::test_caption_hold_floors_at_two_seconds | IMPL |
| AC-28 | Caption out | `step()` countdown → `play_ac("AC-28")` exactly once (juice_director.gd:181) | cubic-out alpha 1→0 · `juice.caption.out_ms`=180 | test_caption_in_hold_out_lifecycle | IMPL |

### 7.3 §2 Gameplay

| ID | G9 moment | Implementing file/function | Curve/duration as implemented | Pinning test | Status |
|---|---|---|---|---|---|
| AC-29 | Hero spawn | `notify_snapshot` floor-change (fires on the FIRST snapshot too — handshake beat 3) → `play_ac("AC-29")` | cubic-out scale 0.85→1.0 + alpha 0→1 · `juice.hero.spawn_ms`=220 | row pin | IMPL |
| AC-30 | Hero walk cycle | sheet frames via `world/actor_sprites.gd` SpriteFrames from ASSET_MANIFEST sidecars — excluded from tween caps (SF budget 29) | per sidecar frame data | test_assets.gd + §7.6 admission battery | IMPL |
| AC-31 | Hero attack swing | `on_cue("cue.player.throw") → _on_throw()` → `play_ac("AC-31")` | back-out 1.0→1.06→1.0 · `juice.hero.swing_ms`=100 | row pin | IMPL |
| AC-32 | Hero attack lunge | `_on_throw()` → `play_ac("AC-32")` | cubic-out 0→+2px · `juice.hero.lunge_ms`=80, `juice.hero.lunge_px`=2 | row pin | IMPL |
| AC-33 | Hero hurt (composite, 3 phases, critical) | `on_cue("cue.player.hurt") → _on_hero_hurt() → _play_hero_hurt()` (juice_director.gd:852+) | p1 modulate set red→white cubic-out 80 (`juice.hero.hurt_modulate_ms`); p2 HP pop back-out 100 (`juice.hero.hurt_pop_ms`); p3 edge flash set 0.15→0 cubic-out 80 (`juice.hero.hurt_edge_flash_ms`, RM halves to 0.075) | RM battery (halvings) + row pin | IMPL |
| AC-34 | Enemy hit flash | `consume_events("projectile_hit")` → `world_view.gd::flash_actor(eid, hit_flash_ms ticks)` (juice_director.gd:485-486); flash pattern = 1 unit | set white→normal cubic-out · `juice.enemy.hit_flash_ms`=80 | row pin + per-type battery (`hit_flash` row) | IMPL |
| AC-35 | Enemy knockback | `_on_hit_confirm()` → `play_ac("AC-35")` | cubic-out 0→+3px · `juice.enemy.knockback_ms`=100, `juice.enemy.knockback_px`=3 | row pin | IMPL |
| AC-36 | Enemy death (composite, 2 phases) | `consume_events("enemy_killed")` → `_spawn_death_ghost(...)` with `juice.enemy.death_scale_ms`/`death_fade_ms` keys (juice_director.gd:482) | p1 set 1.15→0 cubic-out 200; p2 alpha 1→0 cubic-out 160 + 40ms delay (`death_fade_delay_ms`) | row pin + per-type battery (`enemy_death`) | IMPL |
| AC-37 | Enemy ranged telegraph | two lanes: `on_cue("cue.enemy.telegraph") → play_ac("AC-37")` + `consume_events("enemy_telegraph") → world_view.gd::telegraph_actor(eid, 250ms)`; cue promoted at the FIRE moment — **supersession §6.6-1** | cubic-out 1.0→1.15 · `juice.enemy.telegraph_ms`=250 | test_juice_director_behavior.gd::test_ac37_telegraph_cue_and_event_lanes + test_main_scene_contract.gd::test_rules_emit_the_telegraph_seam | IMPL |
| AC-38 | Enemy reinforcement spawn | `consume_events("enemy_spawned") → _on_enemy_spawned()` → `play_ac("AC-38")` | cubic-out scale 0.70→1.0 + alpha 0→1 · `juice.enemy.spawn_ms`=160 | row pin | IMPL |
| AC-39 | Flame-jet pre-ON flicker | `on_cue("cue.hazard.flame_preon") → play_ac("AC-39")` | cubic-out alpha 0.4→0.8 · `juice.hazard.flicker_ms`=150 | row pin | IMPL |
| AC-Flame | Hero flame-overlay entry | `juice_director.gd:956 → play_ac("AC-Flame")` | cubic-out alpha 0→0.7 · `juice.acflame.entry_ms`=150, `entry_alpha`=0.7 | row pin | IMPL |
| AC-Flame-L | Flame flicker loop | `juice_director.gd:962 → start_ambient("AC-Flame-L")` | cubic-in-out ping-pong 0.5↔0.7 · `juice.acflame.loop_period_ms`=200 | row pin + RM battery (ambient OFF) | IMPL |
| AC-Flame-X | Flame overlay exit | `juice_director.gd:966 → play_ac("AC-Flame-X")` after `_flame_ticks_left` lapses in `step()` | cubic-out 0.7→0 · `juice.acflame.exit_ms`=150 | row pin | IMPL |
| AC-40 | Projectile spawn | `contract()` AC-40 | cubic-out scale 0.8→1.0 · `juice.projectile.spawn_ms`=80 | row pin | DATA — §12-B4 (Tier 2) |
| AC-41 | Projectile impact | `on_cue("cue.projectile.impact") → play_ac("AC-41")`; cue promoted REAL at `core/rules_session.gd:736+` (DoD #8) | flash set white→normal cubic-out · `juice.projectile.impact_ms`=80 (RM halves duration) | RM battery + row pin | IMPL |
| AC-42 | Generator idle pulse | `_start_floor_ambients()` → `play_ac("AC-42")` per alive generator (juice_director.gd:1081) | cubic-in-out ping-pong 1.0↔1.03 · `juice.generator.idle_ms`=1400 | row pin + RM battery | IMPL |
| AC-42b | Generator pre-death flicker | `on_cue("cue.generator.hurt") → play_ac("AC-42b")` | set 1.3→1.0 cubic-out · `juice.generator.preflicker_ms`=50 (below-band, G9-argued inline) | row pin | IMPL |
| AC-43 | SIG-2 Generator destruction (composite, 7 units, critical) | `on_cue("cue.generator.destroyed") → _on_generator_destroyed()`: `request_hitstop("HS-2")` + `shake("generator")` + `camera_zoom_punch(gen_zoom)` + `_play_gen_burst_tweens()` + `consume_events` PT-06 ring + death ghost + floater + caption; `haptic("medium")` | hitstop 4f; burst scale set 1.25→0 200 + fade 200 (`juice.gen.burst_*_ms`); floater 400; caption-in 160; camera zoom 1.0→1.03→1.0 200 (`juice.camera.gen_zoom_ms`) | test_sig2_generator_destroyed_composite + test_gen_destroy_two_per_burst_matches_rules_invariant | IMPL |
| AC-44 | Door open | `on_cue("cue.door.open") → play_ac("AC-44")` | cubic-out alpha 1→0 + y 0→−4px · `juice.door.open_ms`=250 | row pin | IMPL |
| AC-45 | Exit idle glow | `_start_floor_ambients()` → `play_ac("AC-45")` (juice_director.gd:1082) | cubic-in-out ping-pong 0.70↔1.0 · `juice.exit.idle_ms`=900 | row pin + RM battery | IMPL |
| AC-46 | Pickup idle bob | `_start_floor_ambients()` → `play_ac("AC-46")` (juice_director.gd:1085), max 6 inst (ambient cap table; 7th static) | cubic-in-out ping-pong ±2px · `juice.pickup.bob_ms`=1000 | row pin + ambient cap test (16) | IMPL |
| AC-47 | SIG-3 Food pickup FIRST (composite, 4 phases, critical) | `_on_food()` first branch → `play_ac("AC-47")` + `_record_event("SIG-3")`; first-food tracked director-side — **supersession §6.6-5 (OQ-22)** | p1 pop back-out 1.0→1.2→0 200 (`juice.food.pop_scale_ms`); p2 fade 150 (`pop_fade_ms`); p3 HP ×3 sequential ticks back-out 180 each (`juice.hp.food_pop_ms`); p4 caption-in 160 | test_sig3_first_food_full_then_routine | IMPL |
| AC-47r | Food pickup routine | `_on_food()` else branch → `play_ac("AC-47r")` (phases 1–2 only) | back-out pop 200 + fade 150 | test_sig3_first_food_full_then_routine | IMPL |
| AC-48 | Key pickup | `_on_key_pickup()` → `play_ac("AC-48")` + `haptic("light")` | back-out 1.0→1.18→1.0 · `juice.key.pickup_ms`=150 | row pin | IMPL |
| AC-49 | Treasure pickup | `on_cue("cue.pickup.chest") → play_ac("AC-49")` + `haptic("light")` | back-out 1.0→1.18→1.0 · `juice.treasure.pickup_ms`=150 | row pin | IMPL |
| AC-50 | Potion pickup | `on_cue("cue.pickup.potion") → play_ac("AC-50")` | back-out 1.0→1.15→1.0 · `juice.potion.pickup_ms`=150 | row pin | IMPL |
| AC-51 | SIG-4 Potion use (composite, 3 units, critical) | `on_cue("cue.player.potion") → _on_potion_used()`: `request_hitstop("HS-3")` + flash + class-tint bloom + `_play_hero_pop()`; cooldown rejects 2nd within window (juice_director.gd:705+) | hitstop 6f; flash set 0.85→0 cubic-out 120 (`juice.potion.flash_ms`); bloom set 0.6→0 cubic-out 150 (`bloom_ms`); hero pop back-out 1.0→1.06→1.0 120 (`hero_pop_ms`); cooldown `juice.potion.cooldown_ms`=1000 | test_sig4_potion_cooldown_rejects_replay | IMPL |
| AC-52 | Void-bridge warning pulse | `_on_enemy_spawned(ai_type==5) → _play_void_bridge_pulse()` + `VoidBridgeManager.trigger()`; suppressed under RM and attract | cubic-in-out 0→0.25→0 sequential ×3 cycles · `juice.ac52.on_ms`=900 / `off_ms`=300 / `alpha_peak`=0.25 / `cycles`=3; max 2 clusters (void_bridge cap 2 reject) | row pin + per-type battery (`void_bridge`) | IMPL |
| AC-53 | Floor-clear darken | `_on_floor_clear()` → `play_ac("AC-53")` | cubic-out alpha 0→0.45 · `juice.floor.darken_ms`=250 | test_sig5_floor_clear_and_banner_out_exactly_once | IMPL |
| AC-54 | Floor banner in | `_on_floor_clear()` → `play_ac("AC-54")` | cubic-out y −16→0 + alpha 0→1 · `juice.floor.banner_in_ms`=250 | same | IMPL |
| AC-55 | Floor banner hold | `_schedule_banner_out()` — dwell step-counted in `step()` | dwell `juice.floor.banner_hold_ms`=600 (0 units) | same (exactly-once countdown) | IMPL |
| AC-56 | Floor banner out | `step()` countdown → `play_ac("AC-56")` exactly once (juice_director.gd:174) | cubic-out alpha 1→0 · `juice.floor.banner_out_ms`=200 | test_sig5_floor_clear_and_banner_out_exactly_once | IMPL |
| AC-SIG5 | SIG-5 The Gold Door (composite, 7 units, critical) | `_on_floor_clear()`: `request_hitstop("HS-4")` + `shake("clear")` + AC-53 + `_play_sig5_border()` (phases 3–4 on the play.gd-built SIG5BorderRect TextureRect, particle-glow.png) + AC-54 + `camera_drift_to_exit_and_back(600, 400)` + `haptic("light")`; attract mode suppresses presentation, event still recorded (G9 §9) | hitstop 4f; border alpha 0→1→0 400 (200+200) + scale 1.0→1.02→1.0 400 (`juice.sig5.border_fade_ms`/`border_scale_ms`); camera drift 600 (`clear_drift_ms`) + return 400 (`clear_return_ms`) cubic-out | test_sig5_floor_clear_and_banner_out_exactly_once + test_sig5_suppressed_in_attract_mode | IMPL |

### 7.4 §2 Hitstop / freeze-frame

| ID | Trigger | Implementing file/function | Frames as implemented | Pinning test | Status |
|---|---|---|---|---|---|
| HS-1 | Light hit connects | `_on_hit_confirm() → request_hitstop("HS-1")` (juice_director.gd:891); cue.enemy.hurt → _on_hit_confirm (B3 closed) | 2f (`juice.hitstop.light_frames`) | test_juice_director_behavior.gd::test_hs1_hitstop_fires_on_hit_confirm | IMPL |
| HS-2 | Generator destroyed | `_on_generator_destroyed() → request_hitstop("HS-2")` → `HitstopManager.request(4)` | 4f (`juice.hitstop.gen_frames`) | test_sig2 composite + test_juice_engine.gd::test_hitstop_freezes_world_tweens_advances_ui (OBL-31: world frozen, UI advances) | IMPL |
| HS-3 | Potion used | `_on_potion_used() → request_hitstop("HS-3")` | 6f (`juice.hitstop.potion_frames`) | test_sig4 cooldown battery | IMPL |
| HS-4 | Floor clear | `_on_floor_clear() → request_hitstop("HS-4")` | 4f (`juice.hitstop.clear_frames`) | test_sig5 battery | IMPL |

### 7.5 §3 Particle effects

Particle rows are DATA in `juice/juice_contracts.gd::particle_table()`
(counts are HARD caps; textures from `res://Assets/`). Enforcement:
`juice/particle_manager.gd::request()` — per-type `max_inst` snap-completes
oldest first, then global eviction walks `eviction_order()` (the exact G9
whole-emitter order), critical PT-06/07/09 never killed by GLOBAL eviction
(per-type caps still apply — new critical wins over old critical). Global
cap `juice.particles.global_cap`=160 from Tunables. Burst projection:
`juice_director.gd::particle_burst()` → `world_view.gd::juice_burst()`.
Pins: test_juice_director_behavior.gd::test_particle_global_cap_eviction_and_critical_survival
(eviction in G9 order, critical survival) + test_particle_per_type_cap_evicts_oldest +
test_juice_engine.gd::test_gen_destroy_two_per_burst_matches_rules_invariant
(PT-06 cap 2 bound to `rules_floor.max_destructible_generators_per_burst=2`).

| ID | Trigger | Burst site | Count/life as implemented | Status |
|---|---|---|---|---|
| PT-01 | Hero spawn (AC-29) | `notify_snapshot` floor-change branch → `particle_burst("PT-01", player_pos, _class_tint())` (juice_director.gd:570); class-tinted spark at the hero entry tile (B3 closed) | 8 spark, 0.30s, max 1 | IMPL |
| PT-02 | Enemy spawn (AC-38) | no burst site | 6 smoke, 0.25s, max 4 | DATA — §12-B3 |
| PT-03 | Melee/impact hit | `consume_events("projectile_hit")` (juice_director.gd:484) | 6 spark, 0.25s, max 6 | IMPL |
| PT-04 | Projectile impact | no separate site — the shared impact-spark lane (PT-03 at the one `projectile_hit` site) covers player-projectile hits; enemy-projectile-on-player impact fires no particles | 4 spark, 0.20s, max 6 | DATA — §12-B3 (row declared, no distinct site) |
| PT-05a | Enemy death smoke | `consume_events("enemy_killed")` (juice_director.gd:480) | 8 smoke, 0.40s, max 4 | IMPL |
| PT-05b | Enemy death sparks | `consume_events("enemy_killed")` (juice_director.gd:481) | 6 spark, 0.40s, max 4 | IMPL |
| PT-06 | SIG-2 generator destruction | `consume_events("generator_destroyed")` (juice_director.gd:476) | 14 glow, 0.50s, max 2, **critical** | IMPL |
| PT-07 | SIG-3 food pickup first | `consume_events("food_consumed")`, exactly-once via `_first_food_burst_done` (juice_director.gd:487-490) | 8 glow, 0.35s, max 1, **critical** | IMPL |
| PT-08 | Potion pickup | no burst site | 6 glow, 0.30s, max 1 | DATA — §12-B3 |
| PT-09 | SIG-4 potion use | `consume_events("potion_used")` (juice_director.gd:498-499) | 16 smoke, 0.50s, max 1, **critical** | IMPL |
| PT-10 | Key pickup | `consume_events("key_collected")` (juice_director.gd:491-492) | 6 spark, 0.30s, max 2 | IMPL |
| PT-11 | Treasure pickup | `consume_events("chest_opened")` (juice_director.gd:493-494) | 10 glow, 0.40s, max 2 | IMPL |
| PT-12 | Door open | `consume_events("door_opened")` (juice_director.gd:496-497) | 6 smoke, 0.30s, max 1 | IMPL |
| PT-13 | Exit open glow | no burst site | 8 glow, 0.35s, max 1 | DATA — §12-B3 |
| PT-14 | Projectile trail | no burst site (per-projectile trail lane not wired) | 1/proj trail, 0.15s, max 20 | DATA — §12-B3 |
| PT-15a/b | Flame-jet ON smoke/glow | no burst site | 5 smoke + 3 glow, 0.40s, max 4 each | DATA — §12-B3 |
| PT-16 | Ambient torch flicker | no burst site | 4 glow, 0.50s, max 8 | DATA — §12-B4 (Tier-2 cut candidate per G9 tier list) |
| PT-17 | Death telegraph aura | `_on_enemy_spawned(ai_type==5)` (juice_director.gd:924) | 10 glow, 0.60s, max 1 (OQ-13 satisfied: cleaver-brute "death" type exists) | IMPL |

### 7.6 §4 Screen shake + camera · §5 Haptics

| Row | Implementing file/function | Values as implemented | Pinning test | Status |
|---|---|---|---|---|
| Shake generator (SIG-2) | `juice_director.gd::shake("generator")` → `world_view.gd::shake()` | 2px, 80ms, linear (`juice.shake.gen.mag_px`/`ms`) | test_juice_contracts.gd::test_shake_table_well_formed + RM battery (all shake OFF) | IMPL |
| Shake death | `_on_player_death() → shake("death")` | 3px, 120ms, cubic-out | same | IMPL |
| Shake clear (SIG-5) | `_on_floor_clear() → shake("clear")` | 1px, 60ms, linear | same | IMPL |
| Camera zoom punch (SIG-2) | `camera_zoom_punch()` → `world_view.gd::zoom_punch()` | 1.0→1.03→1.0, 200ms cubic-out (`juice.camera.gen_zoom`/`gen_zoom_ms`) | RM battery (camera OFF) | IMPL |
| Camera drift + return (SIG-5) | `camera_drift_to_exit_and_back()` → `world_view.gd::drift_to_exit_and_back()` | drift 600ms + return 400ms cubic-out | RM battery | IMPL |
| Haptic light/medium/heavy | `juice_director.gd::haptic(kind)` reading `haptic_table()`; `duration_s = ms × juice.haptic.duration_conversion` (0.001) | light 0.2/0.0/50ms · medium 0.3/0.3/100ms · heavy 0.5/0.6/200ms; sites: food/chest/key/potion-use/floor-clear light, generator medium, death heavy, hit-confirm light throttled by `juice.haptic.hit.throttle_ms`=200; NO haptic on player damage (G9 §5) | test_juice_contracts.gd::test_haptic_table_well_formed + test_juice_director_behavior.gd::test_haptics_off_records_nothing | IMPL |
| Haptic class-confirm (G9 §5 row) | no product cue for class confirm (see §6.6-4) — rides the AC-10 gap | — | — | DATA — §12-B2 |

### 7.7 §6 Scene transitions

All 9 transition durations are DATA in
`juice/juice_contracts.gd::transition_table()` and Tunables
(`juice.transition.*` 8 keys + `juice.pause.dim_ms` shared with AC-14; G9
defaults 300/250/300/250/250/150/400/250/300 all present). **DATA — §12-B4:
`app/scene_router.gd` mounts screens without fades; the fade choreography is
not consumed yet.** No transition tween is mis-attributed: nothing in the
tree claims these rows are wired.

### 7.8 §2 Zone atmosphere

| Row | Implementing file/function | Values as implemented | Pinning test | Status |
|---|---|---|---|---|
| AC-Zone1..4 | `notify_snapshot` floor-change → `world_view.gd::apply_zone_tint()` with `JuiceContracts.zone_table()` colors/alphas via `_zone_color/_zone_alpha`; floor→zone map `zone_for_floor()` — **supersession §6.6-2** (product's G2-locked order drowned F1–6, cinder F7–12, starved F13–18, throne F19–24; G9 tint colors/alphas apply to that order) | cinder `#3D2817` α0.15 · drowned `#0D1F2D` α0.15 · starved `#1F2D0D` α0.15 · throne `#2D0D2D` α0.20 (`juice.zone.*_tint` fixed keys) | test_juice_contracts.gd::test_zone_for_floor_boundaries (7/13/19) | IMPL |

### 7.9 Accessibility contract (G9 preamble · §2 accessibility)

Reduce Motion reads `settings.reduced_motion` every `step()`
(`reduce_motion_enabled()`): all shake + camera OFF; flash/bloom/edge/gold
intensities halved; hit-flash/hurt-modulate/impact durations halved;
vignettes static at 0.18/0.30; pulse-freq, flame flicker, pre-death flicker,
streak bonus, ALL ambient loops OFF; SIG5BorderRect alpha halved + scale
static; zone tint remains (color, not motion); **hitstop REMAINS**; easing
unchanged; FAIR/LOW/CRITICAL labels remain as the sole non-color channel.
Pins: test_juice_director_behavior.gd::test_reduce_motion_battery (every
halving + static + hitstop-remains) + test_sig1_colorblind_labels_at_all_three_thresholds +
test_haptics_off_records_nothing. The app-layer RM seam
(`session_state_machine.gd::reduced_motion_enabled`, dying-screen shortening)
is pinned by test_accessibility.gd (7 tests).

### 7.10 Repair gates, DoD, and runtime-proof rows

| G9 item | Implementation | Evidence/pin | Status |
|---|---|---|---|
| R-1 visible asset | `main.gd::_ready()` binds `res://Assets/warrior-main.png` TextureRect before bot logic; `ci/sneferu_visible_asset.json` plan_sha256 pinned to the governed `c141f0d1…` | test_main_scene_contract.gd::test_visible_asset_anchor_is_product_qualified (receipt pin at :96; negative twin fails when pin removed) | CLOSED |
| R-2 gameplay wiring | WorldView/Camera/HUD in the play render tree (`app/screens/play.gd` overlay + world block) | test_main_scene_contract.gd::test_main_scene_carries_the_composition_nodes; real-render frame capture itself is NOT_RUN on this headless host (§12-B5) | CLOSED (capture debt B5) |
| R-3 asset binding | 42/42 assets consumed; semantic-id registry via ASSET_MANIFEST sidecars; magenta 32×32 fallback + `asset_debt` telemetry on any load failure (G9 Asset Delivery) | test_assets.gd + test_asset_admission.gd (42 positive + 42 negative + fallback contract + debt idempotency) | CLOSED |
| R-4 test architecture | `tests/test_runner.gd` dynamic discovery — every `test_*.gd` auto-registered, unloadable suite = loud FAIL; contract tests fail when their contract breaks | runner design + the negative tests in each new suite | CLOSED |
| R-5 attract re-record | Gated on OQ-2 (tick-to-second mapping, 48h deadline → default sub-path (b)/(c)); shipped reel receipt `f5981978…` unchanged | test_attract_replay.gd receipt pin | BLOCKED — §12-B1 |
| DoD #2 juice.* keys | 173 `juice.*` keys in `Tunables.json` (band+step+default; fixed keys band/step null) + `data/juice_defaults.gd` generated from `data/tunables_schema.json` by `tools/gen_juice.py` | test_juice_contracts.gd::test_segment_keys_resolve_in_tunables + test_tunables.gd | CLOSED |
| DoD #3 negative-bearing suites | `test_presentation.gd` (10), `test_main_scene_contract.gd` (6), `test_asset_admission.gd` (5 incl. 42+42 battery) all ship with negatives | the suites themselves | CLOSED |
| DoD #6 telemetry juice_events + result | `ci/sneferu_bot.gd:42-45` headless JuiceDirector recorder stepped per rule tick inside `_play_game`; `_result_counts` over the G9 result codes 0–5; bounded by JUICE_EVENTS_CAP; `engine_version` stamped from `Engine.get_version_info().string` (ci/sneferu_bot.gd:575) | test_main_scene_contract.gd::test_bot_telemetry_contract_carries_result_and_juice_events + test_bot_telemetry.gd (3); runtime: this round's gate parsed the bot's telemetry receipt with juice_events present (see §10) | CLOSED |
| DoD #8 promoted cues | `cue.hp.tick` (rules_session.gd:526) + `cue.projectile.impact` (rules_session.gd:736+) registered REAL in `data/cue_manifest.json` (23 cues) | cue_manifest validation this round: both present; AC-15/AC-41 trigger on them | CLOSED |
| OQ-21 back-out overshoot | `JuiceTweenEngine.ease_value("back_out")` sampled at 1ms granularity across the full tween; max overshoot bound constant pinned ≤34.56px on a 32px sprite (≤8%) | test_juice_engine.gd::test_oq21_back_out_overshoot_at_1ms_granularity + test_back_overshoot_bound_constant_pinned | CLOSED |
| OQ-11/13/15 conditionals | potions EXIST (SIG-4 ships, not cut); death-type enemy EXISTS (PT-17 fires); continue tokens EXIST (AC-25 pulse still Tier-2 DATA) | _on_potion_used / _on_enemy_spawned(ai_type==5) / §7.1 AC-25 row | RESOLVED-KEEP |

---

## 8. G10 — Changed files (full contents)

Same delivery contract as the G7 brief: every modified or added file is
COMPLETE on disk at the path shown — no elided bodies, no `// unchanged`
hand-waving inside a changed file. The reviewer reads each file directly
(the G7 "actual source files in the worktree" provision). G10 scope touched
ONLY juice/presentation/test/data surfaces — zero mechanic, balance, or
spawn-rule edits (the regression statement §10 repeats the diff-scan
finding).

**Added (juice partition + contract data):**
- `juice/juice_director.gd` (+uid) — JuiceDirector: composition-root juice runtime (step heartbeat, cue/event intake, SIG choreography, RM, attract suppression, haptics, juice_events/asset_debt seams)
- `juice/juice_contracts.gd` (+uid) — the G9 contract table (this section's data source)
- `juice/juice_tween_engine.gd` (+uid) — deterministic step-driven tween engine (caps, priorities, eviction, easing math)
- `juice/tween_manager.gd` (+uid) — tween lifecycle step chokepoint
- `juice/particle_manager.gd` (+uid) — particle budget ledger (global + per-type caps, G9 eviction order)
- `juice/hitstop_manager.gd` (+uid) — physics-tick freeze counter
- `juice/streak_manager.gd` (+uid) — kill-streak tiers (window/max_tiers from Tunables)
- `juice/void_bridge_manager.gd` (+uid) — AC-52 warning pulse state
- `data/tunables_schema.json` — single-source juice.* schema (band/step/default)
- `data/juice_defaults.gd` — GENERATED fallback defaults (tools/gen_juice.py output)
- `tools/gen_juice.py` — build-time generator: schema → Tunables.json juice keys + juice_defaults.gd

**Added (tests — detailed in §9):**
- `tests/test_juice_contracts.gd` (+uid) — 11 tests
- `tests/test_juice_engine.gd` (+uid) — 13 tests
- `tests/test_juice_director_behavior.gd` (+uid) — 16 tests
- `tests/test_main_scene_contract.gd` (+uid) — 6 tests
- `tests/test_asset_admission.gd` (+uid) — 5 tests (42+42 asset battery)
- `tests/test_presentation.gd` (+uid) — 10 tests

**Modified (juice seams — each change is presentation-only):**
- `Tunables.json` — +173 `juice.*` keys (all G7 keys untouched; schema `game_tunables_v1` unchanged)
- `core/rules_session.gd` — THREE presentation-seam cues at real rules sites, zero rules change: `cue.hp.tick` (:526), `cue.projectile.impact` (:736+), `cue.enemy.telegraph` + `enemy_telegraph` event (:625-639, supersession §6.6-1)
- `app/session_state_machine.gd` — G9-locked `attract_mode: bool` flag (:38), set true on title enter / false on input-or-exit (:295-297), read by `_in_attract_mode` (:307)
- `main.gd` — director composition-root wiring: `setup()` with the SSM's TunablesLoader + settings source (:49), JuiceDirector stepped once per fixed tick in `_physics_process` (beside `tick_once`), bot-mode comment stating the bot runs its own headless recorder
- `main.tscn` — JuiceDirector authored child of Main (+ its five sub-manager children instantiated in `_ready/_ensure_managers`)
- `app/cue_bus.gd` — `juice_director` dispatch slot (:28) + `_dispatch` forwards every real cue to `on_cue` (:66-67)
- `app/screens/play.gd` — screen-space overlay rects (vignette/death-vignette/screen-edge/overlay/flash/class-tint/SIG5BorderRect/banner/caption/hp-status) + `director.attach_world/attach_hud/set_overlay_nodes/attach_caption` (:73-137) + per-step `notify_snapshot` (:176-177) + `consume_events` forwarding (:219-223)
- `app/screens/splash.gd` — AC-01 seam (:19-33)
- `app/screens/title.gd` — AC-02/AC-03 seams + `_exit_tree` unbind hygiene (:40-59, :267-285)
- `app/screens/class_select.gd` — AC-08 pop-in (play_class_popin :112) + class_confirm.scale bind + post-layout pivot recompute (:88-120)
- `app/screens/floor_results.gd` — AC-59/AC-60 seams (:71-90, :126)
- `app/screens/game_over.gd` — AC-62 seam (:79)
- `world/world_view.gd` — ZoneTintRect (:92-98) + the projection API the director calls: `apply_zone_tint/shake/zoom_punch/drift_to_exit_and_back/place_void_bridge/juice_burst/juice_floater/spawn_ghost/flash_actor/telegraph_actor/hero_hurt_flash/actor_texture_for/edge_flash` + `_record_asset_debt` (magenta fallback seam)
- `ci/sneferu_bot.gd` — DoD #6 headless juice recorder (:42-45, :135-145, :245+) + G9 result-code invariants (:179-238) + the impossible-progress guard fix (score-monotonicity clause removed — G2's locked −20% death penalty is not a rules violation; the guard now checks floor regression + HP increase only) + `engine_version` telemetry field (:575)
- `data/cue_manifest.json` — telegraph entry added (23 cues total; schema unchanged)

**Untouched by G10 (explicit):** every `core/rules_*.gd` balance/spawn/state
file except the three presentation-seam cue lines above, `Tunables.json` G7
keys, all 26 G7 test suites (see §10), `save_codec`, stores, floor data,
fonts, art.

---

## 9. G10 — Animation-timing tests

New deterministic suites asserting durations, easing selection, and
max-concurrent budgets from the G9 worksheet. **Determinism discipline:
zero wall-clock** — grep-verified: no `OS.get_ticks_msec`/`get_ticks_usec`
anywhere in `juice/` or the six new suites. Every tween advances by counted
`step()` calls at the fixed 60Hz tick; every assertion is on engine state
after N steps, on configuration values, or on budget arithmetic (the
frame-rate assertions are structural budget math, never timers).

| Suite | Tests | What it pins (G9 numbers asserted, not code-echoed) |
|---|---|---|
| `tests/test_juice_contracts.gd` | 11 | Traceability row-shape for EVERY contract row; every segment ms/key field resolves in Tunables.json; type_table caps positive; particle/hitstop/shake/haptic tables well-formed; eviction order is the exact G9 array; zone_for_floor boundaries 7/13/19 (supersession §6.6-2); director parses |
| `tests/test_juice_engine.gd` | 13 | Curve endpoints + monotonicity; **OQ-21 back-out overshoot sampled at 1ms granularity, ≤34.56px on a 32px sprite** (+ the bound constant pinned separately so a silent relax fails); ms→tick math structural; **caps 48/23/16 resolve from Tunables, not hardcoded**; cap boundary: exactly 48 units fit, 49th culled; critical sub-cap 23 overflow rejected; ambient cap 16 enforced; flash pattern = 1 unit; global priority cull kills lowest-priority first and SPARES criticals; **hitstop freezes world tweens while UI tweens advance (OBL-31)**; per-type overflow battery over EVERY one of the 29 `type_table()` rows (cap + overflow behavior per row); gen_destroy 2-per-burst bound to the rules invariant `max_destructible_generators_per_burst=2` |
| `tests/test_juice_director_behavior.gd` | 16 | SIG-1 heartbeat pulse + band thresholds (positive + negative); SIG-1 colorblind labels FAIR/LOW/CRITICAL at all three thresholds; SIG-2 composite (+negative); SIG-3 first-food full THEN routine (OQ-22 seam); SIG-4 cooldown rejects replay then re-fires; SIG-5 floor clear + banner-out exactly once; **SIG-5 suppressed in attract mode (telemetry event preserved, presentation suppressed)**; caption in/hold/out lifecycle at exact tick math (in + dwell floor + out); AC-37 telegraph cue AND event lanes; AC-59/60 floor-results trigger site; AC-62 game-over trigger site; **Reduce Motion battery** (halved intensities/durations, static vignettes, ambients OFF, hitstop REMAINS); haptics-off records nothing; particle per-type cap evicts oldest; particle global-cap eviction in G9 order with critical survival; asset_debt fallback seam |
| `tests/test_main_scene_contract.gd` | 6 | Main scene configured + parses; composition nodes present; **director mounts the FIVE real sub-manager classes** (`is` checks, not bare Nodes); visible-asset anchor product-qualified (governed receipt plan_sha256 `c141f0d1…` pinned at :96; regression pin at :128-129 fails if the score-monotonicity guard ever returns); **bot telemetry contract carries `result` + `juice_events`** (DoD #6); rules emit the telegraph seam |
| `tests/test_asset_admission.gd` | 5 | Exactly 42 assets ship; **positive battery: every asset admits via ResourceLoader with manifest dimensions**; **negative battery: every broken path fires the magenta fallback** (42 negatives); fallback marker contract (32×32 `#FF00FF`); `asset_debt` idempotent per semantic id |
| `tests/test_presentation.gd` | 10 | presentation_contract.json schema, palette hex→Color, ui_regions [0,1] non-overlap, frame_floors ranges (G7-era repair-gate surface, landed with the G10 suite set) |

---

## 10. G10 — Regression statement

**Claim: polish changed ONLY feel.** Every G7 test is present and green;
zero G7 assertions deleted, weakened, or re-tuned; no mechanic/balance/spawn
edits; no new dependencies; Tunables.json still the launch-time authority
and the bot contract intact.

### 10.1 G7 suite list — post-polish status

All 26 G7 suites (150 tests) run on every runner invocation via dynamic
discovery (an unregistered or unloadable suite is a loud FAIL — a G7 test
cannot silently drop). All green inside this round's total.

| G7 suite | Tests | Post-polish status |
|---|---|---|
| test_accessibility.gd | 7 | present · green · unchanged |
| test_assets.gd | 5 | present · green · unchanged |
| test_attract_replay.gd | 3 | present · green · unchanged (receipt `f5981978…` pin intact) |
| test_balance_sim.gd | 2 | present · green · unchanged |
| test_bot_telemetry.gd | 3 | present · green · unchanged (bot internals changed for DoD #6; the suite's assertions still hold as-written) |
| test_combat.gd | 5 | present · green · unchanged |
| test_continue.gd | 5 | present · green · unchanged |
| test_cue_bus.gd | 17 | present · green · unchanged (cue_bus gained the juice_director dispatch slot; the suite's emit/clear/forward/dispatch/signal + e2e assertions unaffected) |
| test_enemy_ai.gd | 6 | present · green · unchanged |
| test_exit_overlap.gd | 3 | present · green · unchanged |
| test_fixed_timestep.gd | 4 | present · green · unchanged |
| test_floor_solver.gd | 4 | present · green · unchanged |
| test_generators.gd | 5 | present · green · unchanged |
| test_hazards.gd | 5 | present · green · unchanged |
| test_modals.gd | 5 | present · green · unchanged |
| test_pickups.gd | 9 | present · green · unchanged |
| test_prng.gd | 5 | present · green · unchanged |
| test_replay.gd | 4 | present · green · unchanged |
| test_save.gd | 7 | present · green · unchanged |
| test_save_codec.gd | 7 | present · green · unchanged |
| test_score.gd | 5 | present · green · unchanged |
| test_session.gd | 5 | present · green · unchanged |
| test_solver_check.gd | 9 | present · green · unchanged (G2 §3 locked table pins intact) |
| test_state_machine.gd | 10 | present · green · unchanged (SSM gained the `attract_mode` flag; existing state/counter/routing assertions unaffected) |
| test_transition_table.gd | 5 | present · green · unchanged |
| test_tunables.gd | 5 | present · green · unchanged (TunablesLoader behavior identical over the enlarged key set) |
| **G7 subtotal** | **150** | **150/150 green** |

**Changed G7 tests:** none. No G7 assertion was deleted, weakened, or
edited to make polish pass (round-5 review independently confirmed zero
weakened assertions and zero mechanic/balance edits in its diff scan). The
only G7-era file edits touching test-adjacent behavior are the three
presentation-seam cue lines in `core/rules_session.gd` (additive cue pushes
at real rules sites — no state, formula, or transition change) and the
`ci/sneferu_bot.gd` impossible-progress guard fix, which REMOVED a false
violation test (score monotonicity) that contradicted G2's locked −20%
death penalty — that fix is pinned by
test_main_scene_contract.gd:128-129 and proven by the gate going from
FAILED (games_completed 0, 10/10 impossible_progress) to PASSED
(7/10 games completed).

### 10.2 G10 suites added

6 suites / 61 tests (§9): test_juice_contracts (11) + test_juice_engine
(13) + test_juice_director_behavior (16) + test_main_scene_contract (6) +
test_asset_admission (5) + test_presentation (10).

### 10.3 Runner result (this round's Pre-Review Test Run, this host)

- Godot `4.7.stable.official.5b4e0cb0f` (`/opt/homebrew/bin/godot`).
- `godot --headless --script tests/test_runner.gd` → **PASS: 211  FAIL: 0
  TOTAL: 211**, exit 0, zero leaked ObjectDB instances / resources-in-use.
  (150 G7 + 61 G10.) The `asset_debt flagged` ERROR lines in the log are
  the admission negative-battery's DELIBERATE fallback assertions (G9
  "visible, never silent"), not infrastructure errors.
- Bot gate: `godot --headless --path . -- res:// --bot --seed 42 --games 10
  --telemetry-out …` → **PASSED — bot completed 7 of 10 requested games
  (frame-budget-limited)**, `playtest_telemetry_v1` with `engine_version`,
  per-game `result` codes, and `juice_events` present (the gate parsed the
  ~328KB receipt). Tunables.json read at launch by TunablesLoader
  (unchanged boot path) and PlaytestBots contract intact — the balance
  tuner can play this build next.

### 10.4 AUDIO_PRODUCT_MANIFEST validation (run this round, real result)

OP-4 item 11 assertion executed against the staged tree — **PASS**:
`AUDIO_PRODUCT_MANIFEST.json` schema `audio_product_manifest_v1`, `cue_seam`
block present (`bus: res://app/cue_bus.gd`, `manifest:
res://data/cue_manifest.json`, `emitter: res://core/rules_session.gd`,
`forwarder: res://app/screens/play.gd`), `authored_audio_status:
awaiting_operator`, `authored_tracks: 0`. Companion check (OP-4 item 10):
`data/cue_manifest.json` carries **23 cues** (≥19) and ALL
primary-action + terminal-outcome + DoD-8 cues are registered and bound
through the named CueBus seam: `cue.player.throw` (primary swing),
`cue.enemy.hurt` (hit confirm), `cue.player.death` (terminal outcome,
heavy haptic + death shake), `cue.floor.clear` + `cue.campaign.clear`
(terminal outcome, SIG-5), `cue.hp.tick`, `cue.projectile.impact`,
`cue.enemy.telegraph` — presence verified programmatically this round.

**Audio truth (no false green):** zero authored PCM ships. That is the
POST-BUILD MUSICIAN HANDOFF contract — the operator is this game's musician
and supplies finished audio after the playable game exists; the manifest
declares this loudly (`awaiting_operator`, empty track lists) rather than
silently. Primary-action and terminal-outcome bindings EXIST at the named
cue seam (above) and will dispatch authored audio the moment the operator
drops files into the CueBus lanes; until then the product emits no sound.
Per the G10 regression rule this is recorded as a **product regression
item (§12-B1), never a run-stop authority.**

### 10.5 MovieWriter audibility result — NOT_RUN

The MovieWriter real-render rung did NOT execute this round, stated
plainly: this host runs the headless gates (no display/render context was
available to the cooperative worktree), and the G7-era visual lane already
carried `qualification: NOT_RUN` as infrastructure/evidence debt. Even with
a capture, audibility could not be proven while authored audio is absent
(§10.4) — the rung becomes meaningful at the musician handoff. Next action:
§12-B1/B5 (operator-supplied audio + a display-backed MovieWriter journey
capture; never inferred from code).

---

## 11. G10 — Build & run steps

**Unchanged from G7.** Same commands, same order (brief §3.1–§3.5):
import (`godot --headless --import --quit`), test suite
(`godot --headless --script tests/test_runner.gd` — expected output updated
in §3.2/OP-4 to the real 211-test total), bot run (configured-main-scene
`--bot` launch), attract bake, visible-asset anchor. OP-4 acceptance script
(§4) unchanged except item 2's expected PASS count, which now matches the
runner's actual 211-test emission. No new tools, no new dependencies
(vanilla Godot 4.7, zero addons — the scope ceiling stands).

---

## 12. G10 — Known blockers

Everything the operator must do in the locked engine/toolchain that this
brief cannot, each with a next action. Tier tags cite the G9 tier system
(Tier 1 must-ship / Tier 2 cut-candidate).

1. **B1 — Authored audio + MovieWriter audibility proof (product
   regression, never run-stop).** Zero PCM ships by the musician-handoff
   contract; §10.4/§10.5 state the validation PASS and the NOT_RUN capture
   rung. **Next action:** operator drops authored WAVs into the CueBus lanes
   (primary action: `cue.player.throw`/`cue.enemy.hurt`; terminal outcome:
   `cue.player.death`/`cue.floor.clear`), then a display-backed MovieWriter
   capture proves audibility on the real product journey.
2. **~~B2 — AC-10 class-confirm trigger (Tier 1).~~ CLOSED this round.** The
   confirm snap + G9 §5 light haptic now fire in
   `app/screens/class_select.gd::_lock_in()` via `play_ac("AC-10")` +
   `haptic("light")` before the CHOOSE transition. Pinned by
   `test_juice_director_behavior.gd::test_ac10_class_confirm_trigger_site`
   (source-structural + behavior twin).
3. **B3 — Particle burst sites (Tier 1: PT-01/HS-1 CLOSED; Tier-adjacent:
   PT-02/04/08/13/14/15a/15b remain).** PT-01 (hero-spawn spark, handshake
   beat 3) and HS-1 (light-hit 2f hitstop, handshake beat 4) were closed this
   round: PT-01 fires via `particle_burst("PT-01", player_pos, _class_tint())`
   in the `notify_snapshot` floor-change branch (class-tinted spark at the
   hero entry tile); HS-1 fires via `request_hitstop("HS-1")` in
   `_on_hit_confirm()` (cue.enemy.hurt → light-hit lane). Both pinned by
   behavior tests in the director suite. Seven more PT rows remain
   declared-with-caps but unbursed; the budget math already accounts for them
   (they only ADD load within the pinned caps). **Next action:** wire the
   remaining burst sites in a follow-up dispatch.
4. **B4 — Tier-2 presentation decision (G9 tier system cut candidates).**
   AC-04/05 (title ambients), AC-06/07 (menu hover/press), AC-09 (focus),
   AC-11 (glint), AC-12/13 (modal open/close), AC-14 (pause-dim tween — the
   dim end-state ships statically), AC-25 (continue pulse), AC-40
   (projectile spawn), AC-61 (new-best pop), PT-16 (ambient torches), and
   the §6 scene-transition fades (9 keys in Tunables; SceneRouter mounts
   without fades). All rows ship as DATA (contract + tunables); G9's cut
   metric explicitly permits cutting them (removes ≤8 concurrent Tweeners
   and ≤32 particles from normative peak, preserving all Tier 1).
   **Next action:** operator confirms ship-or-cut per row; shipped rows get
   trigger sites + tests in a follow-up dispatch.
5. **B5 — Real-render journey + frame-budget profiling (DoD #4, OQ-20;
   R-5 gate).** Headless logic gates are green; the MovieWriter journey and
   the 99th-percentile <12ms/10s profile need a display context and
   min-spec (or OQ-20-scaled) hardware. R-5's attract re-record remains
   gated on OQ-2 (48h deadline defaults to sub-path (c): the shipped reel
   `f5981978…` carries the disclosed debt). **Next action:** run the
   visual-capture + profile rung on a display-backed Mac lane.
6. **B6 — Carried G7 blockers (unchanged, still honest):** real Silkscreen
   drop-in (§5 item 1), `test_audio` spec-tension resolution (§5 item 3),
   input-map completion (§5 item 4), Steam export qualification (§5 item
   6). None is G10-scoped.

---

*G10 root draft complete: §7 traceability (every G9 AC/PT/HS/SIG row, with
explicit blocker notes where a row is DATA-only), §8 changed files, §9
animation-timing tests, §10 regression (incl. AUDIO_PRODUCT_MANIFEST
validation result + MovieWriter NOT_RUN), §11 build & run (unchanged),
§12 known blockers. G7 baseline brief: §1–§6; supersessions: §6.6.*

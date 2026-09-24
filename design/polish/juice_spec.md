# G9 — Polish & Juice Spec (Locked Runtime)

**Artifact:** `polish/juice_spec.md` · **Run:** gap-253b64a1 · **Phase:** G9 → G10 implements verbatim · **Engine (LOCKED):** Godot 4.7, GDScript, 2D · **Target:** Steam desktop (min-spec: Intel UHD 630, 8GB RAM, 1080p)

---

## Preamble

### OP-5 receipt — sole truth on audit outcome

`quality_verdict: ITERATE` · `decision: APPROVE (by: autopilot)` · declarations `SHIP 0, ITERATE 2, KILL 0`. No SHIP was issued. This spec runs in the construction-continuation lane the APPROVE opens. **OQ-1a is a blocking gate:** if product-lane admission requires SHIP before G10 coding, G10 does not start until the operator confirms authorization. **OQ-1b** is a separate authorization for the 2D supersession. Every §2–§6 contract below is conditional on both resolving to "proceed."

### Diary honesty and friction queue derivation

The G8 artifact records `Play duration: 0:00 independent human play`. No play diaries exist in INPUT. Per the citing rule, none are referenced or inferred. §1 uses the G8 §4 machine-evidence friction ledger as a proxy pending operator authorization (OQ-1a).

### Presentation capability advisory — consciously superseded

The locked concept names 3D with no delivery mechanism. The operator seed resolves it: "No need for 3d, but make it awesome 2d." The G7 tree is 2D-native. Presentation is flattened honestly to 2D. OQ-1b confirms this as a formal concept-lock amendment.

### Easing base — cubic, with one sanctioned overshoot exception

- **Cubic out** (`TRANS_CUBIC`, `EASE_OUT`) — every one-shot response.
- **Cubic in-out** (`TRANS_CUBIC`, `EASE_IN_OUT`) — ambient loops (ping-pong autoreverse).
- **Back out** (`TRANS_BACK`, `EASE_OUT`) — the **single sanctioned overshoot exception**. Criterion: the event must be either (a) a player-initiated commit (attack swing, class confirm, pickup) or (b) a positive value increase (HP restore, score milestone, new best). Neutral object spawning does not qualify. No elastic, bounce, sine, or ease-in curves appear. G10 must visually verify TRANS_BACK overshoot is ≤8% on a 32px sprite (≤2.56px beyond target). Verification: sample max sprite bounding box across full tween duration at 1ms granularity, assert ≤34.56px. If exceeds, fallback to manual cubic-out with callback overshoot (OQ-21).

### Tier system

**Tier 1 (must ship):** Repair gates R-1–R-5 · 5 signature moments (SIG-1–SIG-5) · first-30-seconds path · every friction-addressing polish item. If G10's budget is consumed by gates, Tier 1 is the MVP.

**Tier 2 (cut candidates — 30% reduction):** Menu micro-polish (AC-04, AC-05, AC-06, AC-07, AC-09, AC-11, AC-12, AC-13, AC-14), HUD garnish (AC-23, AC-24, AC-25), ambient atmosphere (AC-45, AC-46), results garnish (AC-61), decorative particles (PT-16). Cut metric: removes ≤8 concurrent active Tweeners and ≤32 particles from normative peak, preserving all Tier 1.

### Juice constants are DATA

Every duration, amplitude, easing overshoot, particle cap, and haptic intensity lands in `res://Data/Tunables.json` (`game_tunables_v1`) under keys prefixed `juice.*`. Path justification: Tunables is game-logic data consumed by autoload scripts at boot, not a renderable asset; `res://Data/` is the designated data directory, parallel to `res://Assets/` for renderables.

**Single-source schema:** A build-time script generates both `Tunables.json` and `res://Data/_defaults.gd` from one schema file (`res://Data/tunables_schema.json`). If `Tunables.json` is missing at boot, the Tunables autoload logs an error and loads `_defaults.gd`. No hand-maintained duplicate dict. Missing key → use default for that key, log warning.

**Tunable keys** (band · step · default):
```json
"juice.hp.drain_pulse_ms": {"band": [80, 140], "step": 10, "default": 100}
"juice.hp.drain_pulse_scale": {"band": [1.06, 1.12], "step": 0.02, "default": 1.08}
"juice.shake.gen.magnitude_px": {"band": [1, 3], "step": 0.5, "default": 2}
"juice.haptic.light.weak": {"band": [0.1, 0.3], "step": 0.05, "default": 0.2}
"juice.haptic.light.strong": {"band": [0.0, 0.0], "step": 0.0, "default": 0.0}
"juice.haptic.light.duration_ms": {"band": [30, 80], "step": 10, "default": 50}
"juice.haptic.medium.weak": {"band": [0.2, 0.4], "step": 0.05, "default": 0.3}
"juice.haptic.medium.strong": {"band": [0.2, 0.4], "step": 0.05, "default": 0.3}
"juice.haptic.medium.duration_ms": {"band": [60, 150], "step": 10, "default": 100}
"juice.haptic.heavy.weak": {"band": [0.3, 0.6], "step": 0.05, "default": 0.5}
"juice.haptic.heavy.strong": {"band": [0.4, 0.8], "step": 0.05, "default": 0.6}
"juice.haptic.heavy.duration_ms": {"band": [100, 300], "step": 20, "default": 200}
"juice.haptic.hit.throttle_ms": {"band": [100, 400], "step": 50, "default": 200}
"juice.haptic.duration_conversion": {"band": null, "step": null, "default": 0.001}
"juice.potion.cooldown_ms": {"band": [500, 2000], "step": 100, "default": 1000}
"juice.particles.global_cap": {"band": [120, 200], "step": 10, "default": 160}
"juice.tween.cap": {"band": [40, 60], "step": 2, "default": 48}
"juice.tween.critical_subcap": {"band": [20, 28], "step": 1, "default": 23}
"juice.ambient.cap": {"band": [12, 20], "step": 2, "default": 16}
"juice.ac20c.period_50": {"band": [800, 1600], "step": 100, "default": 1200}
"juice.ac20c.period_25": {"band": [400, 800], "step": 50, "default": 600}
"juice.ac20c.period_10": {"band": [200, 400], "step": 25, "default": 300}
"juice.ac20c.scale_amp": {"band": [1.02, 1.06], "step": 0.01, "default": 1.04}
"juice.ac52.on_ms": {"band": [600, 1200], "step": 100, "default": 900}
"juice.ac52.off_ms": {"band": [200, 400], "step": 50, "default": 300}
"juice.ac52.alpha_peak": {"band": [0.15, 0.35], "step": 0.05, "default": 0.25}
"juice.ac52.cycles": {"band": [2, 4], "step": 1, "default": 3}
"juice.acflame.entry_ms": {"band": [100, 200], "step": 25, "default": 150}
"juice.acflame.entry_alpha": {"band": [0.5, 0.8], "step": 0.05, "default": 0.7}
"juice.acflame.loop_period_ms": {"band": [150, 300], "step": 25, "default": 200}
"juice.acflame.loop_low": {"band": [0.4, 0.6], "step": 0.05, "default": 0.5}
"juice.acflame.loop_high": {"band": [0.6, 0.8], "step": 0.05, "default": 0.7}
"juice.acflame.exit_ms": {"band": [100, 200], "step": 25, "default": 150}
"juice.streak.window_ms": {"band": [1000, 2000], "step": 100, "default": 1500}
"juice.streak.scale_mult_per_tier": {"band": [0.03, 0.08], "step": 0.01, "default": 0.05}
"juice.streak.max_tiers": {"band": [2, 4], "step": 1, "default": 3}
"juice.camera.clear_drift_ms": {"band": [400, 800], "step": 50, "default": 600}
"juice.camera.clear_return_ms": {"band": [300, 500], "step": 50, "default": 400}
```

**Fixed identity keys** (band: null, step: null):
```json
"juice.hp.color.white": {"default": "#FFFFFF"}
"juice.hp.color.amber": {"default": "#FFB347"}
"juice.hp.color.crimson": {"default": "#DC143C"}
"juice.hp.color.deep_red": {"default": "#8B0000"}
"juice.class.tint.warrior": {"default": "#8B0000"}
"juice.class.tint.valkyrie": {"default": "#1E3A8A"}
"juice.class.tint.elf": {"default": "#166534"}
"juice.class.tint.wizard": {"default": "#581C87"}
"juice.zone.cinder_tint": {"default": "#3D2817"}
"juice.zone.drowned_tint": {"default": "#0D1F2D"}
"juice.zone.starved_tint": {"default": "#1F2D0D"}
"juice.zone.throne_tint": {"default": "#2D0D2D"}
```

**Haptic unit conversion:** All haptic duration values in Tunables are milliseconds. G10 converts to seconds for `Input.start_joy_vibration(device, weak, strong, duration_s)` by multiplying `duration_ms × juice.haptic.duration_conversion` (default 0.001).

### Engine-native rails only

Tween/AnimationPlayer, GPUParticles2D, Camera2D, Control/ColorRect/Label/TextureRect, `Input.start_joy_vibration`. No new dependencies, no commissioned art, no new product systems. Every texture named in §3 ships under `Assets/`.

### Runtime architecture (Godot 4.7)

**Project identity:** `project.godot` at root. Main scene: `res://main.tscn`. Engine version: Godot 4.7 (exact — G10 pins and logs full version string in telemetry).

**Rules layer (RefCounted, tree-independent — bot-drivable):**
- `core/rules_session.gd` — session state, HP drain (2.0 HP/s floor 1), win/loss, typed signals: `hp_changed(hp: int)`, `entity_died(entity_id: StringName, position: Vector2i)`, `floor_cleared(floor: int, score: int)`, `game_over(source: StringName)`. `last_damage_source: StringName` (OQ-19).
- `core/rules_floor.gd` — floor data, legal actions, reachability. Exports `max_enemies_per_floor: int = 28`, `max_generators_per_floor: int = 4`, `max_destructible_generators_per_burst: int = 2`.
- `core/rules_entity.gd` — entity state.
- `core/prng.gd` — seeded `RandomNumberGenerator`, owned by `RulesSession`.

**Generator invariant (OBL-1/74/93):** `rules_floor.gd` declares `max_generators_per_floor = 4` and `max_destructible_generators_per_burst = 2`. The per-type art cap of 2 concurrent generator-destruction composites matches this rules invariant — no more than 2 generators can be destroyed in a 200ms window by any input sequence. The frame budget is bound to this rules-layer cap. If G10 finds any baked floor where 3+ generators are destructible within 200ms, G10 re-runs the worksheet (re-run trigger §10).

**State transition matrix:**
```
boot→title→class_select→play→(pause↔play)→floor_results→play(next) OR game_over→continue_offer→title OR play(continue)
```
Continue-offer fallback (OQ-15): if G7 does not define continue tokens, `continue_offer→title` with no token UI; AC-25 is cut.

**Attract-mode detection:** `StateMachine.attract_mode: bool`. Set true on title enter, false on any player input or state transition away from title. Attract mode is title-screen-only; pause is not reachable during attract (player input exits attract before any game state). JuiceDirector reads this flag via exported NodePath binding (see scene tree), not group lookup.

**Machine-play seam (ci/sneferu_bot.gd — SceneTree script):**
- **Calls the SAME `RulesSession` API as human play.** No parallel simulation.
- API: `RulesSession.apply_action(action: Dictionary) → Dictionary` (state snapshot)
- **Snapshot fields:** `{state: StringName, hp: int, score: int, floor: int, position: Vector2i, actions_legal: Array[StringName], game_over: bool, result: int}`
- **Result codes:** 0=complete, 1=timeout, 2=crash, 3=invalid_state, 4=impossible_progress, 5=loop_detected
- PRNG: `RulesSession` owns seeded RNG from bot args
- Fixed step: 60Hz physics tick; max 36000 steps (10 min at 60fps)
- **CLI argument contract:** `--seed <int>` (required), `--policy <min_skill|greedy-killer|survival-router>` (required), `--class <warrior|valkyrie|elf|wizard>` (required), `--count <int>` (required, positive), `--telemetry <absolute_path>` (required). Parsed via `OS.get_cmdline_user_args()`.
- Bot plays floors 1–15 (telemetry-covered range). Floors 16–24 baked but not bot-tested (OQ-14).
- **juice_events:** JuiceDirector subscribes to RulesSession signals directly (`RulesSession.hp_changed.connect(...)`, `RulesSession.entity_died.connect(...)`, etc.) and records juice_events from those signals. The bot's telemetry hook also connects to RulesSession signals for headless juice_event recording. CueBus is the presentation dispatch bus; juice_events are recorded from rules signals, not CueBus. This decouples telemetry from CueBus (which may not fire in headless).
- **Headless scene tree:** Bot run instantiates `Main.tscn` including WorldView and EntityLayer nodes. Visual rendering is suppressed (`--headless`), but nodes exist so JuiceDirector can connect signals and record juice_events. GPUParticles2D and Camera2D do not simulate without a render context; their state is not recorded.
- Output: atomic write to absolute telemetry path (sibling temp file + rename on valid JSON)

**Complete scene tree:**
```
Main (Node2D) — res://main.tscn
├── StateMachine (Node, PROCESS_MODE_PAUSABLE) — attract_mode flag; un-pause initiated by PauseMenu via direct method call
├── WorldView (Node2D, PROCESS_MODE_PAUSABLE)
│   ├── Camera2D (PROCESS_MODE_PAUSABLE)
│   ├── TileMapVisual (Node2D, PROCESS_MODE_PAUSABLE) — no collision, no scale
│   │   └── TileMap (floor/wall layers, rendering only)
│   ├── TileMapCollision (TileMap, PROCESS_MODE_PAUSABLE) — collision only
│   ├── EntityLayer (Node2D, PROCESS_MODE_PAUSABLE)
│   │   ├── Hero (Node2D)
│   │   │   ├── HeroSprite (Sprite2D)
│   │   │   └── HeroFlameOverlay (Sprite2D) — AC-Flame, max 1
│   │   ├── Enemies (Node2D) — pooled, max 28 per floor
│   │   ├── Generators (Node2D) — max 4 per floor (rules cap: max 2 destructible/burst)
│   │   ├── Pickups (Node2D)
│   │   ├── Projectiles (Node2D) — pooled, max 20
│   │   └── Hazards (Node2D) — flame jets
│   ├── ZoneTintRect (ColorRect, normal alpha blend)
│   ├── VoidBridgeOverlay (ColorRect) — max 2 clusters
│   ├── OverlayRect (ColorRect)
│   └── BannerLabel (Label)
├── HUDCanvas (CanvasLayer, PROCESS_MODE_PAUSABLE)
│   ├── HUD (Control)
│   │   ├── HPNumeral (Label)
│   │   ├── HPStatusLabel (Label) — dynamic text: "FAIR"/"LOW"/"CRITICAL"
│   │   ├── ScoreLabel (Label)
│   │   ├── FloorCounter (Label)
│   │   ├── KeyIcon (Sprite2D, AtlasTexture from ui-hud-icons.png)
│   │   └── CaptionBand (Label)
│   ├── VignetteRect (ColorRect)
│   ├── DeathVignetteRect (ColorRect)
│   ├── ScreenEdgeRect (ColorRect)
│   ├── ResultsPanel (Control)
│   │   ├── ResultsScoreLabel (Label)
│   │   └── BestLabel (Label)
│   ├── GameOverNode (Control)
│   └── ContinueOffer (Control) — AC-25; visible only if continue tokens exist (OQ-15)
├── TransitionOverlay (CanvasLayer, PROCESS_MODE_ALWAYS)
│   ├── ColorRect (fades)
│   ├── FlashRect (ColorRect)
│   ├── ClassTintRect (ColorRect, additive blend)
│   └── SIG5BorderRect (TextureRect, particle-glow.png texture)
├── PauseMenu (Control, PROCESS_MODE_WHEN_PAUSED)
└── [Autoloads]
    ├── JuiceDirector (Node, PROCESS_MODE_ALWAYS)
    │   ├── TweenManager (Node)
    │   ├── ParticleManager (Node)
    │   ├── HitstopManager (Node)
    │   ├── StreakManager (Node)
    │   └── VoidBridgeManager (Node)
    ├── CueBus (Node, PROCESS_MODE_ALWAYS)
    └── Tunables (Node, PROCESS_MODE_ALWAYS)
```

**JuiceDirector binding:** `@export var state_machine_path: NodePath`. `Main._ready()` assigns `juice_director.state_machine_path = state_machine.get_path()`. JuiceDirector reads `get_node(state_machine_path).attract_mode`. No group lookups.

**JuiceDirector partition:** Each sub-manager owns its domain. TweenManager handles tween lifecycle and cap enforcement. ParticleManager handles particle caps and eviction. HitstopManager handles the physics-tick freeze counter. StreakManager tracks streaks. VoidBridgeManager triggers void-bridge pulses.

**Pause behavior:** `get_tree().paused = true`. PauseMenu: `PROCESS_MODE_WHEN_PAUSED` (handles un-pause input, calls `StateMachine.transition_to("play")` which sets `paused = false`). JuiceDirector sub-managers: `PROCESS_MODE_ALWAYS` but internally partitioned. World-juice tweens check `get_tree().paused` — frozen during pause. UI-juice tweens always advance. Hitstop counter frozen during pause (pause supersedes hitstop). Hitstop cannot start during pause. New tweens during hitstop are created paused; resume when hitstop ends.

**Tween counting and kill granularity (OBL-26/68/96/97):**
- **Budget metric: concurrent active Tweeners.** A Tweener is "active" if evaluated this frame. Sequential Tweeners within one Tween: only the current one is active. Parallel Tweeners (`tween.parallel()`): all are active.
- **Round-trip animations** (A→B→A) use 2 sequential `tween_property()` calls in one Tween = 1 active Tweener at any time = 1 budget unit.
- **Flash pattern:** instant property set to peak + 1 `tween_property()` back to rest = 1 Tweener = 1 budget unit.
- **Kill granularity: whole Tween.** Godot 4 kills Tween objects, not individual Tweeners. Killing a Tween snap-completes all Tweeners within it. Each animated property gets its own Tween (one Tween per property animation).
- **One-shot cap: 48 concurrent active Tweeners.** Critical sub-cap: 23. Ambient cap: 16 (separate budget).
- **Cap justification:** Normative peak = 38 active Tweeners. Cap = ceil(38 × 1.26) = 48. Critical normative = 17. Sub-cap = ceil(17 × 1.35) = 23.

**Enforcement order (OBL-55):** Per-type instance caps enforced first (snap-complete oldest instance of the overflowing type). Then global priority cull (kill lowest-priority Tweens until under cap). Per-type overflow never causes global overflow because snap-completion frees budget before the new instance starts.

**Tween priority taxonomy:**
- **Critical:** SIG-1–SIG-5 composite components, hero hurt (AC-33), hero death (AC-57/58). Sub-cap: 23.
- **High:** enemy death sequences, floaters, floor banner, floor drop-in (AC-63).
- **Normal:** hit flashes, knockbacks, spawn animations, pickup pops, floor darken (AC-53), score countup.
- **Low:** projectile spawn, door open, telegraph brighten.

**Complete affected-properties list:** `CaptionBand.y`, `CaptionBand.alpha`, `HPNumeral.scale`, `HPNumeral.modulate`, `HPStatusLabel.alpha`, `HPStatusLabel.text`, `VignetteRect.alpha`, `DeathVignetteRect.alpha`, `ScreenEdgeRect.alpha`, `OverlayRect.alpha`, `BannerLabel.y`, `BannerLabel.alpha`, `HeroSprite.scale`, `HeroSprite.modulate`, `HeroSprite.position`, `HeroFlameOverlay.alpha`, `EnemySprite.modulate`, `EnemySprite.position`, `EnemySprite.scale`, `EnemySprite.alpha`, `GeneratorSprite.scale`, `GeneratorSprite.modulate`, `Camera2D.zoom`, `Camera2D.position`, `ScoreLabel.scale`, `FloorCounter.scale`, `KeyIcon.scale`, `ResultsScoreLabel.text` (countup), `BestLabel.scale`, `GameOverNode.alpha`, `GameOverNode.scale`, `FlashRect.alpha`, `ClassTintRect.alpha`, `SIG5BorderRect.alpha`, `SIG5BorderRect.scale`, `VoidBridgeOverlay.alpha`, `PickupSprite.scale`, `PickupSprite.alpha`, `ProjectileSprite.scale`, `ProjectileSprite.modulate`, `DoorSprite.alpha`, `DoorSprite.position.y`, `ExitSprite.alpha`, `TileMapVisual.modulate.a`, `InventoryIcon.scale`, `TokenIcon.scale`, `FloaterLabel.y`, `FloaterLabel.alpha`, `FloaterLabel.scale`.

**SpriteFrames:** Sheet-based animations (hero/enemy walk cycles) are frame-stepped, not tweened. Excluded from tween caps. Own budget: max 29 active (1 hero + 28 scullion-type enemies worst case; realistic 6–9). All sheet-driven animation builds at load from `ASSET_MANIFEST.json` sidecar via Godot `SpriteFrames`/`AtlasTexture` region math. `ui-hud-icons.png` is an atlas (not a sprite sheet); its AtlasTexture regions are verified by OQ-7 (extended to cover atlas region x/y/w/h per icon). A magic number in code is a defect.

### Accessibility

**Reduce Motion** (`juice.accessibility.reduce_motion: bool`, default false). When active:
- Screen shake: OFF (all three shake events)
- Camera kick, zoom punch, drift, return (SIG-2/SIG-5): OFF
- White flash (AC-51 phase 2): intensity halved (0.85→0.4)
- Class-tinted bloom (AC-51 phase 3): intensity halved (0.6→0.3)
- Hit flash (AC-34): duration halved (80ms→40ms)
- Hurt modulate (AC-33 phase 1): duration halved (80ms→40ms)
- Screen-edge red flash (AC-33 phase 3): intensity halved (0.15→0.075)
- Low-HP vignette (AC-20/AC-20b): static at 0.18/0.30 alpha, no pulse loop
- HP pulse frequency loop (AC-20c): OFF
- Flame-jet pre-ON flicker (AC-39): OFF (static at 0.6 alpha)
- Generator pre-death flicker (AC-42b): OFF (static at 1.0 modulate)
- AC-Streak brightness bonus: OFF
- Ambient loops (AC-04, AC-05, AC-42, AC-45, AC-46, AC-Flame, AC-52): OFF (static at resting state)
- AC-61 gold flash rect: intensity halved (0.25→0.125)
- SIG5BorderRect fade/scale: alpha halved (1.0→0.5), scale motion OFF (static at 1.0)
- AC-41 projectile impact flash: duration halved (80ms→40ms)
- Zone tint: remains static (color, not motion)
- Hitstop: REMAINS (a freeze is not motion)
- Tween easing: cubic-out unchanged
- HP status labels (FAIR/LOW/CRITICAL): remain visible as sole non-color channel

**Colorblind support (SIG-1):** The white→amber→crimson→deep red HP path carries non-color redundant channels: pulse frequency escalation AND dynamic text labels. Three threshold AC rows:

| ID | Threshold | Property | From → To | Easing | ms | Tunable key |
|---|---|---|---|---|---|---|
| AC-16b | HP ≤50% — FAIR label | HPStatusLabel alpha + text | 0 → 1; text="FAIR" | cubic-out | 200 | `juice.hp.label_50_ms` |
| AC-17c | HP ≤25% — LOW label | HPStatusLabel text | "FAIR" → "LOW" | cubic-out | 200 | `juice.hp.label_25_ms` |
| AC-17b | HP ≤10% — CRITICAL label + color | HPStatusLabel text + HPNumeral modulate | "LOW" → "CRITICAL"; crimson→deep_red | cubic-out | 200 | `juice.hp.color_10_ms` + `juice.hp.label_10_ms` |

Under Reduce Motion (pulse loop OFF), text labels remain as the sole non-color channel at all three thresholds. The `HPStatusLabel` node uses Godot `Label.text` property assignment (instant, not tweened) for the text change; only the alpha transition is tweened.

### Signature identity moments (5 contracted)

| ID | Name | Trigger | Why it makes the locked promise unmistakable |
|---|---|---|---|
| SIG-1 | **The Heartbeat** | Every integer HP decrement (`RulesSession.hp_changed` signal) | HP-as-clock is the game's soul. Numeral pulses on each drain tick, migrates white→amber→crimson→deep red. Pulse frequency escalates at thresholds. |
| SIG-2 | **The Cloche Pops** | `RulesSession.entity_died` with entity_type="generator" | Heaviest juice event, reserved for highest-agency tactical action. |
| SIG-3 | **The Clock Reverses** | `RulesSession.entity_died` with entity_type="food_pickup" | Only moment HP increases. First food gets full treatment; routine food simplified. |
| SIG-4 | **The Panic Button** | `cue.potion.used` | Escape valve: freeze, flash, smoke. **Conditional on OQ-11.** |
| SIG-5 | **The Gold Door** | `RulesSession.floor_cleared` signal | Endurance-clock identity: each floor cleared is a checkpoint. Hitstop, darken, golden border, banner, camera drift, score countup. |

---

## 1. Friction-first queue (from G8 machine evidence)

**Heading note:** No human play diaries exist in INPUT. This queue is the G8 §4 machine-evidence friction ledger — the only friction evidence available — used as a proxy pending operator authorization (OQ-1a).

### Repair queue (R-1–R-4 — must close before polish)

| # | Friction moment (G8 §4) | Evidence | Gate | Acceptance | Contract ref |
|---|---|---|---|---|---|
| R-1 | Main-scene contract failure — `warrior-main.png` not visible | CURRENT-RUN, product FAIL | Bind `warrior-main.png` visibly to title hero node | `selected_asset_not_visible_in_capture_window` returns false; negative twin fails when pin removed | §2 AC-01–02 |
| R-2 | Zero gameplay frames — `world/` not wired | CURRENT-RUN, render NOT_RUN | WorldView, Camera2D, HUD admitted into `play.tscn` render tree | ≥1 captured frame with floor tiles + HUD numeral + ≥1 entity; `frame_sanity` assertion: pixel-variance ≥5% between consecutive frames (captures non-static render) | §2, §3, §10 |
| R-3 | Asset binding collapse — 34/42 unreferenced | CURRENT-RUN, static analysis | §3 coverage ledger binds all 42 assets | `shipped_assets_unreferenced: 0_of_42`; negative test per asset | §3 coverage |
| R-4 | Test architecture blind spot — 150 tests pass while contract fails | CURRENT-RUN, pipeline | Ship `test_presentation.gd`, `test_main_scene_contract.gd`, asset-admission assertions | Each test FAILS when its contract breaks | §10 |

### Polish queue (P-1–P-4 — friction-addressing polish)

| # | Friction moment (G8 §4) | Evidence | Polish contract | Tier |
|---|---|---|---|---|
| P-1 | Attract reel misrepresentation — 5.8s speedrun contradicts endurance | INFERRED | AC-03 attract veil. Re-record gated on R-5. | 1 |
| P-2 | Floor-1 pacing anomaly — ~5.8s vs GDD 30s teaching | Telemetry | Won't-fix (W-2). Polish: teaching-beat legibility (AC-29, SIG-2, SIG-3) makes each beat unmistakable whenever it occurs. | 1 |
| P-3 | Difficulty cliffs at zone-3 boundary | Telemetry, insufficient sample | Won't-fix (W-3). Polish: void-bridge warning pulse (AC-52) + dying screen names killer (OQ-19). | 1 |
| P-4 | Late-game slack (DIS-1) | Telemetry | Won't-fix (W-4). Polish: SIG-1 keeps drain legible for future urgency rating. | 1 |

### Won't-fix items

| # | Friction moment | Rationale |
|---|---|---|
| W-1 | Bot qualification — 7/10 with bot ignoring potions/dodging/kiting | Instrument calibration, no player-facing surface. |
| W-2 | Floor-1 pacing root cause | Rules-layer; G8 sequences hypothesis verification. |
| W-3 | Difficulty cliff tuning | G8 defers to post-repair human playtest. |
| W-4 | Late-game slack (DIS-1) | G8 forbids tuning before human data. |

### Gate R-5 — Attract reel re-record

**Owner:** G10. **Precondition:** OQ-2 (tick-to-second mapping) verified — **blocking**: G10 cannot close R-5 without resolving OQ-2. Operator deadline: if OQ-2 is not resolved within 48h of G10 start, R-5 defaults to sub-path (b) — attract reel disabled.

**If 60fps confirmed:** Re-record with survival-router. Acceptance: duration ≥30s (measured via `ticks_total / 60.0` from telemetry) AND `hp_final ≤ 400` (50% of 800 starting HP) AND `juice_events` count where `event == "floor_cleared"` ≥ 2. New SHA-256 receipt pinned.

**If 60fps falsified:** Three sub-paths: (a) operator authorizes re-record under unverified clock — receipt marked "unverified tick mapping"; (b) operator declines — attract reel **DISABLED**, title shows static logo + portrait; (c) operator defers — existing reel ships with AC-03 veil, debt disclosed in telemetry.

---

## 2. Animation curves

Every player-visible state change appears below. Durations 80–400ms unless argued inline. **Counting rule:** round-trip animations (A→B→A) = 1 budget unit (sequential Tweeners in one Tween, 1 active at a time). Flash pattern (instant set + tween back) = 1 budget unit. Parallel animations on different properties = 1 budget unit each. Ambient loops use `Tween.set_loops(-1, Tween.LOOP_TYPE_PING_PONG)` = 1 budget unit per instance.

### Boot · Title · Menus

| ID | Feedback moment | Property | From → To | Easing | ms | Tunable key | Budget | Tier |
|---|---|---|---|---|---|---|---|---|
| AC-01 | Splash logo fade (boot) | alpha | 0 → 1 | cubic-out | 300 | `juice.boot.splash_ms` | 1 | 1 |
| AC-02 | Title logo settle | scale | 1.04 → 1.0 | cubic-out | 300 | `juice.title.settle_ms` | 1 | 1 |
| AC-03 | Attract veil | CanvasLayer alpha | 0 → 0.35 | cubic-out | 250 | `juice.attract.veil_ms` | 1 | 1 |
| AC-04 | Title prompt breathe | alpha loop | 0.55 ↔ 1.0 | cubic-in-out ping-pong | 1100 | `juice.title.prompt_ms` | 1 ambient | 2 |
| AC-05 | Title portrait idle | scale loop | 1.0 ↔ 1.03 | cubic-in-out ping-pong | 2000 | `juice.title.portrait_ms` | 1 ambient | 2 |
| AC-06 | Menu button hover | scale | 1.0 → 1.05 | cubic-out | 100 | `juice.menu.hover_ms` | 1 | 2 |
| AC-07 | Menu button press | scale | 1.0 → 0.96 → 1.0 | back-out | 120 | `juice.menu.press_ms` | 1 | 2 |
| AC-08 | Class card pop-in (×4, 60ms stagger) | scale + alpha | 0.94 → 1.0; 0 → 1 | back-out | 200 | `juice.class.popin_ms` | 2 | 1 |
| AC-09 | Class card focus | scale | 1.0 → 1.06 | cubic-out | 120 | `juice.class.focus_ms` | 1 | 2 |
| AC-10 | Class card confirm | scale | 1.06 → 0.94 → 1.0 | back-out | 220 | `juice.class.confirm_ms` | 1 | 1 |
| AC-11 | Class weapon glint | weapon alpha | 0 → 1 → 0 | cubic-out | 100 | `juice.class.glint_ms` | 1 | 2 |
| AC-12 | Modal open | scale + alpha | 0.92 → 1.0; 0 → 1 | cubic-out | 160 | `juice.modal.open_ms` | 2 | 2 |
| AC-13 | Modal close | scale + alpha | 1.0 → 0.92; 1 → 0 | cubic-out | 120 | `juice.modal.close_ms` | 2 | 2 |
| AC-14 | Pause dim | ColorRect alpha | 0 → 0.6 | cubic-out | 150 | `juice.pause.dim_ms` | 1 | 2 |

### HUD (SIG-1: The Heartbeat)

| ID | Feedback moment | Property | From → To | Easing | ms | Tunable key | Budget | Tier |
|---|---|---|---|---|---|---|---|---|
| AC-15 | HP drain pulse (`hp_changed`) | HPNumeral scale | 1.0 → 1.08 → 1.0 | cubic-out | 100 | `juice.hp.drain_pulse_ms` + `_scale` | 1 | 1 |
| AC-16 | HP color at 50% | HPNumeral modulate | white → amber | cubic-out | 200 | `juice.hp.color_50_ms` | 1 | 1 |
| AC-16b | HP FAIR label at 50% | HPStatusLabel alpha + text | 0 → 1; "FAIR" | cubic-out | 200 | `juice.hp.label_50_ms` | 1 | 1 |
| AC-17 | HP color at 25% | HPNumeral modulate | amber → crimson | cubic-out | 200 | `juice.hp.color_25_ms` | 1 | 1 |
| AC-17c | HP LOW label at 25% | HPStatusLabel text | "FAIR" → "LOW" | cubic-out | 200 | `juice.hp.label_25_ms` | 1 | 1 |
| AC-17b | HP CRITICAL label + color at 10% | HPStatusLabel text + HPNumeral modulate | "LOW" → "CRITICAL"; crimson → deep_red | cubic-out | 200 | `juice.hp.color_10_ms` + `juice.hp.label_10_ms` | 2 | 1 |
| AC-18 | HP food-tick pop (per HP restored, ×3) | HPNumeral scale | 1.0 → 1.15 → 1.0 | back-out | 180 | `juice.hp.food_pop_ms` + `_scale` | 1 | 1 |
| AC-19 | HP food-tick tint | HPNumeral modulate | set green → white | cubic-out | 100 | `juice.hp.food_tint_ms` | 1 | 1 |
| AC-20 | Low-HP vignette (≤25%) | VignetteRect alpha loop | 0 ↔ 0.18 | cubic-in-out ping-pong | 1200 | `juice.hp.vignette_ms` | 1 ambient | 1 |
| AC-20b | Critical-HP vignette (≤10%) | VignetteRect alpha loop | 0 ↔ 0.30 | cubic-in-out ping-pong | 600 | `juice.hp.vignette_crit_ms` | 1 ambient | 1 |
| AC-20c | HP pulse freq escalation | HPNumeral scale loop | 1.0 ↔ 1.04 | cubic-in-out ping-pong | 1200/600/300 per threshold | `juice.ac20c.period_50/25/10` + `juice.ac20c.scale_amp` | 1 ambient | 1 |
| AC-21 | Score change pop | ScoreLabel scale | 1.0 → 1.10 → 1.0 | cubic-out | 100 | `juice.score.pop_ms` + `_scale` | 1 | 1 |
| AC-22 | Score floater | FloaterLabel y + alpha | 0 → −24px; 1.0 → 0 | cubic-out | 400 | `juice.floater.ms` — band ceiling argued: number must be read while moving | 2 | 1 |
| AC-23 | Floor counter increment | FloorCounter scale | 1.0 → 1.15 → 1.0 | back-out | 180 | `juice.hud.floor_pop_ms` | 1 | 2 |
| AC-24 | Key icon pop | KeyIcon scale | 1.0 → 1.18 → 1.0 | back-out | 180 | `juice.hud.key_pop_ms` | 1 | 2 |
| AC-25 | Continue token pulse | TokenIcon scale loop | 1.0 ↔ 1.06 | cubic-in-out ping-pong | 1200 | `juice.continue.pulse_ms` — conditional OQ-15 | 1 ambient | 2 |
| AC-26 | Caption in | CaptionBand y + alpha | +8 → 0; 0 → 1 | cubic-out | 160 | `juice.caption.in_ms` | 2 | 1 |
| AC-27 | Caption hold | — (dwell) | — | — | 1400 | `juice.caption.dwell_ms` | 0 | 1 |
| AC-28 | Caption out | CaptionBand alpha | 1 → 0 | cubic-out | 180 | `juice.caption.out_ms` | 1 | 1 |

### Gameplay

| ID | Feedback moment | Property | From → To | Easing | ms | Tunable key | Budget | Tier |
|---|---|---|---|---|---|---|---|---|
| AC-29 | Hero spawn (floor begin) | scale + alpha | 0.85 → 1.0; 0 → 1 | cubic-out | 220 | `juice.hero.spawn_ms` | 2 | 1 |
| AC-30 | Hero walk cycle | sheet frames | per sheet | frame step | per sidecar | — | SF | 1 |
| AC-31 | Hero attack swing | HeroSprite scale | 1.0 → 1.06 → 1.0 | back-out | 100 | `juice.hero.swing_ms` | 1 | 1 |
| AC-32 | Hero attack lunge | HeroSprite position | 0 → +2px | cubic-out | 80 | `juice.hero.lunge_px` | 1 | 1 |
| AC-33 | **Hero hurt (composite)** | — | — | — | — | — | 3 | 1 |
| AC-34 | Enemy hit flash | EnemySprite modulate | set white → normal | cubic-out | 80 | `juice.enemy.hit_flash_ms` | 1 | 1 |
| AC-35 | Enemy knockback | EnemySprite position | 0 → +3px | cubic-out | 100 | `juice.enemy.knockback_px` | 1 | 1 |
| AC-36 | **Enemy death (composite)** | — | — | — | — | — | 2 | 1 |
| AC-37 | Enemy ranged telegraph | EnemySprite modulate | 1.0 → 1.15 | cubic-out | 250 | `juice.enemy.telegraph_ms` | 1 | 1 |
| AC-38 | Enemy reinforcement spawn | EnemySprite scale + alpha | 0.70 → 1.0; 0 → 1 | cubic-out | 160 | `juice.enemy.spawn_ms` | 2 | 1 |
| AC-39 | Flame-jet pre-ON flicker | FlameJetSprite alpha | 0.4 → 0.8 | cubic-out | 150 | `juice.hazard.flicker_ms` | 1 | 1 |
| AC-Flame | Hero flame-overlay entry | HeroFlameOverlay alpha | 0 → 0.7 | cubic-out | 150 | `juice.acflame.entry_ms` + `juice.acflame.entry_alpha` | 1 | 1 |
| AC-Flame-L | Hero flame-overlay flicker | HeroFlameOverlay alpha loop | 0.5 ↔ 0.7 | cubic-in-out ping-pong | 200 | `juice.acflame.loop_period_ms` + `_low` + `_high` | 1 ambient | 1 |
| AC-Flame-X | Hero flame-overlay exit | HeroFlameOverlay alpha | 0.7 → 0 | cubic-out | 150 | `juice.acflame.exit_ms` | 1 | 1 |
| AC-40 | Projectile spawn | ProjectileSprite scale | 0.8 → 1.0 | cubic-out | 80 | `juice.projectile.spawn_ms` | 1 | 2 |
| AC-41 | Projectile impact | ProjectileSprite modulate | set white → normal | cubic-out | 80 | `juice.projectile.impact_ms` | 1 | 1 |
| AC-42 | Generator idle pulse | GeneratorSprite scale loop | 1.0 ↔ 1.03 | cubic-in-out ping-pong | 1400 | `juice.generator.idle_ms` | 1 ambient | 1 |
| AC-42b | Generator pre-death flicker | GeneratorSprite modulate | set 1.3 → 1.0 | cubic-out | 50 | `juice.generator.preflicker_ms` — **below 80ms band argued:** pre-death glitch warning must read as instability flash, not deliberate motion; player perceives a spike, not an animation | 1 | 1 |
| AC-43 | **SIG-2 Generator destruction (composite)** | — | — | — | — | — | 7 | 1 |
| AC-44 | Door open | DoorSprite alpha + y | 1 → 0; 0 → −4px | cubic-out | 250 | `juice.door.open_ms` | 2 | 1 |
| AC-45 | Exit idle glow | ExitSprite alpha loop | 0.70 ↔ 1.0 | cubic-in-out ping-pong | 900 | `juice.exit.idle_ms` | 1 ambient | 2 |
| AC-46 | Pickup idle bob | PickupSprite y loop | ±2px | cubic-in-out ping-pong | 1000 | `juice.pickup.bob_ms` | 1 ambient, max 6 inst | 2 |
| AC-47 | **SIG-3 Food pickup first (composite)** | — | — | — | — | — | 4 | 1 |
| AC-47r | SIG-3 Food pickup routine | PickupSprite scale + alpha | 1.0 → 1.2 → 0; 1 → 0 | back-out | 200 | `juice.food.pop_scale_ms` + `_fade_ms` | 2 | 1 |
| AC-48 | Key pickup | KeySprite scale | 1.0 → 1.18 → 1.0 | back-out | 150 | `juice.key.pickup_ms` | 1 | 1 |
| AC-49 | Treasure pickup | TreasureSprite scale | 1.0 → 1.18 → 1.0 | back-out | 150 | `juice.treasure.pickup_ms` | 1 | 1 |
| AC-50 | Potion pickup | InventoryIcon scale | 1.0 → 1.15 → 1.0 | back-out | 150 | `juice.potion.pickup_ms` — cut if OQ-11 | 1 | 1 |
| AC-51 | **SIG-4 Potion use (composite)** | — | — | — | — | — | 3 | 1 |
| AC-52 | Void-bridge warning pulse | VoidBridgeOverlay alpha | 0 → 0.25 → 0, sequential chain ×3 | cubic-in-out | 900 on, 300 off | `juice.ac52.on_ms` + `juice.ac52.off_ms` + `juice.ac52.alpha_peak` + `juice.ac52.cycles` — **900ms argued:** warning dwell must be recognized before off-phase; below 600ms reads as flicker, not warning. Max 2 clusters. | 2 | 1 |
| AC-53 | Floor-clear darken | OverlayRect alpha | 0 → 0.45 | cubic-out | 250 | `juice.floor.darken_ms` | 1 | 1 |
| AC-54 | Floor banner in | BannerLabel y + alpha | −16 → 0; 0 → 1 | cubic-out | 250 | `juice.floor.banner_in_ms` | 2 | 1 |
| AC-55 | Floor banner hold | — (dwell) | — | — | 600 | `juice.floor.banner_hold_ms` | 0 | 1 |
| AC-56 | Floor banner out | BannerLabel alpha | 1 → 0 | cubic-out | 200 | `juice.floor.banner_out_ms` | 1 | 1 |
| AC-SIG5 | **SIG-5 The Gold Door (composite)** | — | — | — | — | — | 7 | 1 |

### Death · Results · Continue

| ID | Feedback moment | Property | From → To | Easing | ms | Tunable key | Budget | Tier |
|---|---|---|---|---|---|---|---|---|
| AC-57 | Player death vignette | DeathVignetteRect alpha | 0 → 0.4 | cubic-out | 300 | `juice.death.vignette_ms` | 1 | 1 |
| AC-58 | Player death hero collapse | HeroSprite scale + alpha | 1.0 → 1.2; 1.0 → 0 | cubic-out | 350 | `juice.death.collapse_ms` | 2 | 1 |
| AC-59 | Floor results panel slide-in | ResultsPanel y + alpha | +24 → 0; 0 → 1 | cubic-out | 250 | `juice.results.panel_ms` | 2 | 1 |
| AC-60 | Score count-up | ResultsScoreLabel text | 0 → final | cubic-out | 350 | `juice.results.countup_ms` | 1 | 1 |
| AC-61 | New best pop | BestLabel scale + gold flash | 1.0 → 1.15 → 1.0; set 0.25 → 0 | back-out; cubic-out | 200; 100 | `juice.results.best_ms` + `juice.results.best_flash_ms` | 2 | 2 |
| AC-62 | Game over entry | GameOverNode alpha + scale | 0 → 1; 0.8 → 1.0 | cubic-out | 500 | `juice.gameover.entry_ms` — scene boundary argued | 2 | 1 |
| AC-63 | **Play start floor drop-in (composite)** | — | — | — | — | — | 2 | 1 |

### Composite decompositions

**AC-33 Hero hurt (damage taken):** 3 phases, parallel, 3 budget units, all critical.

| Phase | Target node | Property | From → To | Easing | ms | Tunable key | Budget |
|---|---|---|---|---|---|---|---|
| 1 | HeroSprite | modulate | set red → white | cubic-out | 80 | `juice.hero.hurt_modulate_ms` | 1 |
| 2 | HPNumeral | scale | 1.0 → 1.12 → 1.0 | back-out | 100 | `juice.hero.hurt_pop_ms` + `_scale` | 1 |
| 3 | ScreenEdgeRect | alpha | set 0.15 → 0 | cubic-out | 80 | `juice.hero.hurt_edge_flash_ms` + `_alpha` | 1 |

**AC-36 Enemy death:** 2 phases, 2 budget units.

| Phase | Target node | Property | From → To | Easing | ms | Tunable key | Budget |
|---|---|---|---|---|---|---|---|
| 1 | EnemySprite | scale | set 1.15 → 0 | cubic-out | 200 | `juice.enemy.death_scale_ms` | 1 |
| 2 | EnemySprite | alpha | 1.0 → 0 (40ms delay) | cubic-out | 160 | `juice.enemy.death_fade_ms` | 1 |

**AC-43 SIG-2 Generator destruction:** 7 phases, parallel, 7 budget units, all critical. Hitstop (phase 1) is not a tween.

| Phase | Target node | Property | From → To | Easing | ms | Tunable key | Budget |
|---|---|---|---|---|---|---|---|
| 1 | (presentation) | hitstop freeze | — | — | 67 (4f) | `juice.hitstop.gen_frames` | 0 |
| 2 | GeneratorSprite | scale | set 1.25 → 0 | cubic-out | 200 | `juice.gen.burst_scale_ms` | 1 |
| 3 | GeneratorSprite | alpha | 1.0 → 0 | cubic-out | 200 | `juice.gen.burst_fade_ms` | 1 |
| 4 | FloaterLabel | y + alpha | 0 → −24px; 1 → 0 | cubic-out | 400 | `juice.floater.ms` | 2 |
| 5 | CaptionBand | y + alpha | +8 → 0; 0 → 1 | cubic-out | 160 | `juice.caption.in_ms` | 2 |
| 6 | Camera2D | zoom | 1.0 → 1.03 → 1.0 | cubic-out | 200 | `juice.camera.gen_zoom` | 1 |

Total budget units: 7 (phases 2–6). Hitstop is phase 1 (not counted).

**AC-47 SIG-3 Food pickup (first occurrence):** 4 phases, max 4 concurrent budget units.

| Phase | Target node | Property | From → To | Easing | ms | Tunable key | Budget |
|---|---|---|---|---|---|---|---|
| 1 | PickupSprite | scale | 1.0 → 1.2 → 0 | back-out | 200 | `juice.food.pop_scale_ms` | 1 |
| 2 | PickupSprite | alpha | 1.0 → 0 | cubic-out | 150 | `juice.food.pop_fade_ms` | 1 |
| 3 | HPNumeral | scale (×3 ticks) | 1.0 → 1.15 → 1.0 per tick | back-out | 180 each | `juice.hp.food_pop_ms` (reused) | 1 (sequential) |
| 4 | CaptionBand | y + alpha | +8 → 0; 0 → 1 | cubic-out | 160 | `juice.caption.in_ms` | 2 |

Max concurrent: phases 1–2 overlap (2), then phase 3 (1) overlaps with phase 4 (2) = max 4.

**AC-47r Food pickup (routine):** Phases 1–2 only. Distinguished via `RulesSession.first_food_collected: bool` (OQ-22). If absent, all food gets full treatment.

**AC-51 SIG-4 Potion use:** 3 phases, 3 budget units, all critical. Cut entirely if OQ-11 denies potions.

| Phase | Target node | Property | From → To | Easing | ms | Tunable key | Budget |
|---|---|---|---|---|---|---|---|
| 1 | (presentation) | hitstop freeze | — | — | 100 (6f) | `juice.hitstop.potion_frames` | 0 |
| 2 | FlashRect | alpha | set 0.85 → 0 | cubic-out | 120 | `juice.potion.flash_ms` + `_alpha` | 1 |
| 3 | ClassTintRect | alpha | set 0.6 → 0 | cubic-out | 150 | `juice.potion.bloom_ms` + `_alpha` | 1 |
| 4 | HeroSprite | scale | 1.0 → 1.06 → 1.0 | back-out | 120 | `juice.potion.hero_pop_ms` | 1 |

Cooldown: `juice.potion.cooldown_ms` (default 1000). 2nd request within cooldown is rejected.

**AC-63 Play start floor drop-in:** 2 phases, 2 budget units. Priority: High.

| Phase | Target node | Property | From → To | Easing | ms | Tunable key | Budget |
|---|---|---|---|---|---|---|---|
| 1 | TileMapVisual | modulate.a | 0 → 1 | cubic-out | 300 | `juice.floor.dropin_ms` | 1 |
| 2 | BannerLabel | y + alpha | −16 → 0; 0 → 1 | cubic-out | 250 | `juice.floor.banner_in_ms` | 1 (parallel) |

**AC-SIG5 The Gold Door (floor clear):** 7 budget units, all critical. Hitstop (phase 1) is not a tween.

| Phase | Target node | Property | From → To | Easing | ms | Tunable key | Budget |
|---|---|---|---|---|---|---|---|
| 1 | (presentation) | hitstop freeze | — | — | 67 (4f) | `juice.hitstop.clear_frames` | 0 |
| 2 | OverlayRect | alpha | 0 → 0.45 | cubic-out | 250 | `juice.floor.darken_ms` | 1 |
| 3 | SIG5BorderRect | alpha | 0 → 1 → 0 | cubic-out | 400 (200 in + 200 out) | `juice.sig5.border_fade_ms` | 1 |
| 4 | SIG5BorderRect | scale | 1.0 → 1.02 → 1.0 | cubic-out | 400 | `juice.sig5.border_scale_ms` | 1 |
| 5 | BannerLabel | y + alpha | −16 → 0; 0 → 1 | cubic-out | 250 | `juice.floor.banner_in_ms` | 1 (parallel) |
| 6 | Camera2D | zoom + position | 1.0 → 1.02; pos → exit | cubic-out | 600 | `juice.camera.clear_drift_ms` — **600ms argued:** reverence beat — camera lingers on exit as reward; shorter reads as jump cut | 2 |
| 7 | Camera2D | zoom + position return | 1.02 → 1.0; exit → hero | cubic-out | 400 | `juice.camera.clear_return_ms` | 2 (sequential after phase 6) |

Max concurrent (phases 2–6): 1+1+1+1+2 = 6. Phase 7 starts after phase 6 completes: +2 = 8 total across lifetime, but max concurrent = 6. Budget: 7 (counting phase 7 as additional). For cap-derived: SIG-5 is in critical Group B (transition), exclusive with combat.

**AC-Flame exit/fade-out:** When hero leaves flame-jet adjacency, `HeroFlameOverlay` flicker loop stops and alpha tweens 0.7 → 0 over 150ms cubic-out (`juice.acflame.exit_ms`). Node remains inactive until re-entry triggers AC-Flame.

### Hitstop / freeze-frame

| ID | Trigger | Frames (physics ticks) | ms at 60Hz | Tunable key |
|---|---|---|---|---|
| HS-1 | Light hit connects | 2 | 33 | `juice.hitstop.light_frames` |
| HS-2 | Generator destroyed (SIG-2) | 4 | 67 | `juice.hitstop.gen_frames` |
| HS-3 | Potion used (SIG-4) | 6 | 100 | `juice.hitstop.potion_frames` |
| HS-4 | Floor clear (SIG-5) | 4 | 67 | `juice.hitstop.clear_frames` |

**Hitstop vs UI-juice during hitstop (OBL-31):** During hitstop, world-juice tweens are paused. UI-juice tweens (caption in, flash rect, class tint, banner, modal, pause dim) continue to advance. Hitstop freezes the world; the UI remains responsive. This rule governs: if a caption fires during hitstop, it animates normally.

### Zone atmosphere

| ID | Zone | ColorRect tint | Alpha | Tunable key |
|---|---|---|---|---|
| AC-Zone1 | Cinder (1–6) | `#3D2817` | 0.15 | `juice.zone.cinder_tint` |
| AC-Zone2 | Drowned (7–12) | `#0D1F2D` | 0.15 | `juice.zone.drowned_tint` |
| AC-Zone3 | Starved (13–18) | `#1F2D0D` | 0.15 | `juice.zone.starved_tint` |
| AC-Zone4 | Throne (19–24) | `#2D0D2D` | 0.20 | `juice.zone.throne_tint` — **alpha 0.20 argued:** Zone 4 is the final descent; elevated alpha signals escalating dread, distinguishing the throne from prior zones |

Blend mode: normal alpha. Persistent ColorRect in WorldView. No new textures. Floor 15 = Zone 3 (Starved).

---

## 3. Particle effects

Every count is a hard cap. **Global cap: 160 total live particles.** One-shot emitters die on completion. **Critical particles (never killed by global eviction):** PT-06, PT-07, PT-09. Per-type instance caps still apply to critical particles — overflow within a type snap-completes the oldest instance of that type (critical vs critical: new wins).

**SIG5BorderRect** is a TextureRect (not ColorRect — Godot 4 TextureRect supports textures; ColorRect does not), textured with `particle-glow.png`, with 2 property tweens. Counted as 2 critical budget units in the tween budget, not particles. Does not appear in the particle table.

**Particle emitter seeding (OBL-95):** Each pooled emitter seeds from `hash(entity_id + burst_index)`. Burst index resets to 0 on pool recycle. This ensures deterministic visual patterns per entity while allowing recycled pool entries to replay the same burst sequence.

### Effects table

| ID | Trigger | Texture(s) | Count | Lifetime (s) | Emitter shape | Max inst (max particles) | Critical? |
|---|---|---|---|---|---|---|---|
| PT-01 | Hero spawn (AC-29) | `particle-spark.png` | 8 | 0.30 | point, radial | 1 (8) | no |
| PT-02 | Enemy spawn (AC-38) | `particle-smoke.png` | 6 | 0.25 | circle, r=12px | 4 (24) | no |
| PT-03 | Melee hit (AC-34) | `particle-spark.png` | 6 | 0.25 | point, radial | 6 (36) | no |
| PT-04 | Projectile impact (AC-41) | `particle-spark.png` | 4 | 0.20 | point | 6 (24) | no |
| PT-05a | Enemy death smoke (AC-36) | `particle-smoke.png` | 8 | 0.40 | circle, r=16px | 4 (32) | no |
| PT-05b | Enemy death sparks (AC-36) | `particle-spark.png` | 6 | 0.40 | circle, r=16px | 4 (24) | no |
| PT-06 | **SIG-2 Generator destruction** | `particle-glow.png` | 14 | 0.50 | ring, r=16→32px | 2 (28) | **yes** |
| PT-07 | **SIG-3 Food pickup first** | `particle-glow.png` | 8 | 0.35 | circle, r=10px | 1 (8) | **yes** |
| PT-08 | Potion pickup (AC-50) | `particle-glow.png` | 6 | 0.30 | circle, r=8px | 1 (6) | no — cut if OQ-11 |
| PT-09 | **SIG-4 Potion use** | `particle-smoke.png` | 16 | 0.50 | circle, r=24px | 1 (16) | **yes** — cut if OQ-11 |
| PT-10 | Key pickup (AC-48) | `particle-spark.png` | 6 | 0.30 | circle, r=8px | 2 (12) | no |
| PT-11 | Treasure pickup (AC-49) | `particle-glow.png` | 10 | 0.40 | circle, r=10px | 2 (20) | no |
| PT-12 | Door open (AC-44) | `particle-smoke.png` | 6 | 0.30 | line, door edge | 1 (6) | no |
| PT-13 | Exit open glow (AC-45) | `particle-glow.png` | 8 | 0.35 | circle, r=12px | 1 (8) | no |
| PT-14 | Projectile trail | `particle-trail.png` | 1 per proj | 0.15 | line, projectile path | 20 (20) | no |
| PT-15a | Flame-jet ON smoke | `particle-smoke.png` | 5 | 0.40 | line, jet length | 4 (20) | no |
| PT-15b | Flame-jet ON glow | `particle-glow.png` | 3 | 0.40 | line, jet length | 4 (12) | no |
| PT-16 | Ambient torch flicker | `particle-glow.png` | 4 | 0.50 | point | 8 (32) | no |
| PT-17 | Death telegraph aura | `particle-glow.png` | 10 | 0.60 | ring, r=12px | 1 (10) | no — cut if OQ-13 |

### Eviction order and arithmetic (whole-emitter kills)

**Eviction granularity: whole emitter instances.** Killing an emitter kills all its live particles. No partial-instance kills.

**Order:** PT-16 → PT-14 → PT-03 → PT-05a → PT-15a → PT-15b → PT-02 → PT-01 → PT-04 → PT-05b → PT-08 → PT-10 → PT-11 → PT-12 → PT-13 → PT-17.

| Step | Kill (emitter type) | Killed particles | Cumulative | Non-crit remaining | Critical | Total |
|---|---|---|---|---|---|---|
| Start | — | 0 | 0 | 294 | 52 | 346 |
| 1 | PT-16 (×1 inst = 4) | 4 | 4 | 290 | 52 | 342 |
| 2 | PT-16 (×7 more = 28) | 28 | 32 | 262 | 52 | 314 |
| 3 | PT-14 (×10 inst = 10) | 10 | 42 | 252 | 52 | 304 |
| 4 | PT-14 (×10 more = 10) | 10 | 52 | 242 | 52 | 294 |
| 5 | PT-03 (×6 inst = 36) | 36 | 88 | 206 | 52 | 258 |
| 6 | PT-05a (×4 inst = 32) | 32 | 120 | 174 | 52 | 226 |
| 7 | PT-15a (×4 inst = 20) | 20 | 140 | 154 | 52 | 206 |
| 8 | PT-15b (×4 inst = 12) | 12 | 152 | 142 | 52 | 194 |
| 9 | PT-02 (×4 inst = 24) | 24 | 176 | 118 | 52 | 170 |
| 10 | PT-01 (×1 inst = 8) | 8 | 184 | 110 | 52 | 162 |
| 11 | PT-04 (×1 inst = 4) | 4 | 188 | 106 | 52 | **158** |

**Total killed: 188. Active: 106 non-critical + 52 critical = 158 ≤ 160. ✓**

Whole-emitter kills leave 158 (under cap by 2). This is correct — the cap is a ceiling, not a target.

### PT-06 critical overflow (OBL-29/71)

If a 3rd generator destruction is requested while 2 PT-06 rings are live: the per-type cap (max 2) snap-completes the oldest PT-06 instance, freeing 14 particle slots. The new PT-06 starts. Critical particles are never killed by **global** eviction; per-type instance caps are a separate enforcement that applies to all types including critical. A 3rd PT-06 snap-completes the 1st (new critical wins over old critical).

### Shipped texture coverage (42 assets)

| # | Asset | Status | Role |
|---|---|---|---|
| 1 | `particle-glow.png` | Used | PT-06, PT-07, PT-08, PT-11, PT-13, PT-15b, PT-16, PT-17, SIG5BorderRect |
| 2 | `particle-smoke.png` | Used | PT-02, PT-05a, PT-09, PT-12, PT-15a |
| 3 | `particle-spark.png` | Used | PT-01, PT-03, PT-04, PT-05b, PT-10 |
| 4 | `particle-trail.png` | Used | PT-14 |
| 5–12 | `*-main.png` + `*_sheet.png` (4 classes) | Used | Portraits + SpriteFrames from sidecar |
| 13–18 | `enemy-*.png` (6 types) | Used | Enemy sprites — single-frame static |
| 19 | `enemy-scullion_sheet.png` | Used | Enemy walk cycle — SpriteFrames from sidecar |
| 20 | `generator-cloche.png` | Used | AC-42, AC-42b, AC-43 |
| 21 | `hazard-flame-jet.png` | Used | AC-39, PT-15 |
| 22 | `hero-flame-overlay.png` | Used | AC-Flame overlay |
| 23–26 | `pickup-*.png` (4 types) | Used | AC-46 bob, pickup pops |
| 27–31 | `projectile-*.png` (5 types) | Used | AC-40, AC-41, PT-14 |
| 32 | `prop-door.png` | Used | AC-44, PT-12 |
| 33 | `prop-exit.png` | Used | AC-45, PT-13 |
| 34–41 | `tile-*.png` (8 tiles) | Used | Zone tilemaps |
| 42 | `ui-hud-icons.png` | Used | HUD atlas — AtlasTexture regions from sidecar (OQ-7 extended) |

**42 of 42 assigned.** Zero unreferenced.

### Import intent and blend-mode correction (OBL-86)

`particle-glow.png` and `hero-flame-overlay.png` ship with premultiplied alpha. Nodes using these textures with normal alpha blend must either: (a) re-import with straight alpha, or (b) set `CanvasItemMaterial` with `PREMULT_ALPHA` blend mode. G10 verifies blend mode consistency (OQ-24).

| Asset family | Color space | Alpha | Filter | Mipmap | Compression |
|---|---|---|---|---|---|
| `particle-*.png` | sRGB | premult | linear | off | VRAM |
| `*-main.png` | sRGB | straight | linear | off | VRAM |
| `*_sheet.png` | sRGB | straight | nearest | off | lossless |
| `enemy-*.png` (single) | sRGB | straight | nearest | off | lossless |
| `tile-*.png` | sRGB | straight | nearest | off | lossless |
| `ui-hud-icons.png` | sRGB | straight | nearest | off | lossless |
| `projectile-*.png` | sRGB | straight | linear | off | VRAM |
| `prop-*.png` | sRGB | straight | linear | off | VRAM |
| `pickup-*.png` | sRGB | straight | linear | off | VRAM |
| `generator-cloche.png` | sRGB | straight | linear | off | VRAM |
| `hazard-flame-jet.png` | sRGB | straight | linear | off | VRAM |
| `hero-flame-overlay.png` | sRGB | premult | linear | off | VRAM |

---

## 4. Screen shake policy

Casual default is subtle or none. Every shake needs a why. **Haptic-vs-shake asymmetry rationale (OBL-10/17/43/82/94/104):** Haptic is private to the controller holder; shake is public and shifts the entire viewport for any spectator. The same event can earn a private tap without earning a public frame disruption — a light haptic on every enemy hit confirms contact for the player without displacing the scene for everyone watching.

Respect Reduce Motion: when active, all shake AND camera zoom/drift/return is OFF. Hitstop remains.

| When | Magnitude (px) | Duration (ms) | Falloff | Why | Tunable keys |
|---|---|---|---|---|---|
| Generator destroyed (SIG-2) | 2 | 80 | linear decay | Highest-agency tactical action | `juice.shake.gen.mag_px`; `juice.shake.gen.ms` |
| Player death | 3 | 120 | cubic-out | Death is run climax; 3px is ceiling for this weight | `juice.shake.death.mag_px`; `juice.shake.death.ms` |
| Floor clear (SIG-5) | 1 | 60 | linear | Gentle punctuation on endurance milestone | `juice.shake.clear.mag_px`; `juice.shake.clear.ms` |

**No shake on:** routine melee hits, enemy hits, projectile impacts, pickups, menu interactions, HP drain ticks, caption display, scene transitions, pause entry. Shake is rare — three events total.

### Camera zoom & drift

| When | Property | From → To | Easing | ms | Tunable key |
|---|---|---|---|---|---|
| Generator destroyed (SIG-2) | Camera2D zoom | 1.0 → 1.03 → 1.0 | cubic-out | 200 | `juice.camera.gen_zoom` |
| Floor clear (SIG-5) | Camera2D zoom + drift | 1.0 → 1.02; pos → exit | cubic-out | 600 | `juice.camera.clear_drift_ms` |
| Floor clear return | Camera2D zoom + pos return | 1.02 → 1.0; exit → hero | cubic-out | 400 | `juice.camera.clear_return_ms` |

Both OFF under Reduce Motion.

---

## 5. Haptic policy

Sparingly is the design pillar. System haptics-off setting respected. Gamepad only. `Input.start_joy_vibration(device, weak, strong, duration_s)`. Duration in ms from Tunables; G10 converts: `duration_s = duration_ms × 0.001`.

| Interaction | Intensity | weak | strong | Duration (ms) | Throttle | Tunable prefix |
|---|---|---|---|---|---|---|
| Class confirm | light | 0.2 | 0.0 | 50 | 1 per confirm | `juice.haptic.light.*` |
| Food/key/treasure pickup | light | 0.2 | 0.0 | 50 | 1 per pickup | `juice.haptic.light.*` |
| Generator destroyed (SIG-2) | medium | 0.3 | 0.3 | 100 | 1 per destruction | `juice.haptic.medium.*` |
| Potion used (SIG-4) | light | 0.2 | 0.0 | 50 | 1 per activation | `juice.haptic.light.*` |
| Floor clear (SIG-5) | light | 0.2 | 0.0 | 50 | 1 per floor | `juice.haptic.light.*` |
| Player death | heavy | 0.5 | 0.6 | 200 | 1 per death | `juice.haptic.heavy.*` |
| Enemy hit confirm | light | 0.2 | 0.0 | 50 | max 1 per 200ms | `juice.haptic.light.*`; `juice.haptic.hit.throttle_ms` |

**No haptic on player damage** — three redundant visual channels (screen-edge flash, HP pulse, hurt modulate) are sufficient and non-fatiguing.

**No haptic on:** menu hover, menu navigation, HP drain ticks, caption display, scene transitions, projectile spawn, ambient loops, projectile impacts on player.

---

## 6. Scene transitions

One style family: **fade**. Applied evenly. All fades use cubic-out. Non-interactive; input accepted on destination after fade completes.

| Transition | Duration (ms) | Tunable key |
|---|---|---|
| Splash → Title | 300 | `juice.transition.splash_title_ms` |
| Title → Class Select | 250 | `juice.transition.title_class_ms` |
| Class Select → Play | 300 | `juice.transition.class_play_ms` |
| Play → Floor Results | 250 | `juice.transition.play_results_ms` |
| Floor Results → Play (next) | 250 | `juice.transition.results_play_ms` |
| Play → Pause | 150 | `juice.pause.dim_ms` |
| Pause → Play | 150 | (same key) |
| Play → Game Over | 400 | `juice.transition.play_gameover_ms` |
| Game Over → Continue Offer | 250 | `juice.transition.gameover_continue_ms` |
| Continue Offer → Title | 300 | `juice.transition.continue_title_ms` |

**Death → Game Over total:** 350ms in-scene effects (AC-57+58) + 400ms fade + 500ms entry = 1250ms.

---

## 7. Loading & waiting states

**Avoid loading states.** 24 baked floors, zero runtime RNG, `.tres` synchronous load at scene enter. No loading screen, no progress bar, no spinner.

**Synchronous load mitigation:** `.tres` load on min-spec may cause 50–100ms frame hitch. Scene transition fade (250–300ms) absorbs the hitch. G10 verifies load completes within fade window (OQ-23). If load exceeds fade, extend fade to match.

Where a wait is unavoidable:
- **Title screen attract loop** — dimmed reel behind logo (AC-03), prompt breathes (AC-04). Entertaining because it is identity, not a spinner.
- **Floor results panel** — slides in (AC-59), score counts up (AC-60), banner holds (AC-55). The wait is the reward display.

**"Spinner" is an anti-pattern.** No rotating icon, progress bar, or "Loading…" text.

---

## 8. Why-does-this-feel-good inventory

**Evidence label:** No human diaries exist. Entries are designed beats — code paths and juice hooks that would create feel opportunities if the presentation layer renders.

### The first 30 seconds — the Handshake

| Beat | What the player sees, hears, feels | Implementation tuple |
|---|---|---|
| 1. Title | Logo settles (AC-02). Attract ghosts behind (AC-03). Portrait breathes (AC-05). Prompt pulses (AC-04). | AC-02 + AC-03 + AC-04 + AC-05 · `cue.title.enter` · haptic: none · caption: `caption.title_enter` |
| 2. Class select | Cards pop in, 60ms stagger (AC-08). Focus lifts (AC-09). Confirm snaps (AC-10) + glint (AC-11). | AC-08 + AC-09 + AC-10 + AC-11 · `cue.class.confirm` · haptic: light |
| 3. First floor | Hero spawns (AC-29). Tiles fade in (AC-63). Spark burst (PT-01). HP reads 800, ticks down (AC-15). | AC-29 + AC-63 + PT-01 + AC-15 · `cue.hero.spawn` · haptic: none |
| 4. First kill | Enemy flashes (AC-34), knocks back (AC-35), collapses (AC-36). 2f hitstop (HS-1). Score pops (AC-21). | AC-34 + AC-35 + AC-36 + HS-1 + AC-21 · `cue.melee.hit` + `cue.enemy.death` · haptic: light |
| 5. First burst (SIG-2) | Cloche scales 1.25→0. Freeze 4f. 2px kick + zoom. 14-glow ring (PT-06). +100 floater. Caption. | AC-43 + HS-2 + PT-06 + AC-22 · `cue.generator.destroyed` · haptic: medium |
| 6. First food (SIG-3) | Food pops+vanishes. HP ticks up ×3, green. Glow puff (PT-07). "FOOD" caption. | AC-47 + AC-18 + AC-19 + PT-07 · `cue.pickup.food` · haptic: light |

### Beyond 30 seconds

| Micro-satisfaction | Implementation tuple |
|---|---|
| **The Heartbeat** (SIG-1) | AC-15 + AC-16/16b/17/17c/17b + AC-20/20b/20c + AC-Zone1–4 · `RulesSession.hp_changed` · haptic: none |
| **The Panic Button** (SIG-4) | AC-51 + HS-3 + PT-09 · `cue.potion.used` · haptic: light. Conditional OQ-11. |
| **The Gold Door** (SIG-5) | AC-SIG5 + HS-4 + SIG5BorderRect + AC-60 + camera drift+return · `RulesSession.floor_cleared` · haptic: light |
| **Streak escalation** | AC-Streak (StreakManager presentation-only) · `cue.enemy.death` · haptic: none |
| **Tactical telegraph** | AC-37 · `cue.enemy.telegraph` · haptic: none |
| **Hazard legibility** | AC-39 + AC-Flame/Flame-L/Flame-X · haptic: none |
| **Door reward** | AC-44 + PT-12 + AC-24 · `cue.door.unlock` · haptic: none |
| **Death honesty** | AC-57 + AC-58 + §4 shake + AC-62 · `cue.player.death` · haptic: heavy · caption: `caption.death_<source>` (OQ-19) |
| **Death telegraph** (zone 3) | AC-52 + PT-17 (if OQ-13) · `cue.enemy.spawn` (Death type) · caption: `caption.death_spawn` |
| **Zone descent** | AC-Zone1–4 (normal alpha blend ColorRect tint) |

---

## 9. Sound integration points

G9 marks integration points only. G11 owns sound design. G10 must repair any silent or broken primary-action binding by wiring CueBus events. Zero SFX descriptions. Every event carries a `Dictionary` payload. Common fields: `entity_id: StringName`, `frame: int` (physics tick).

| # | CueBus event | Fires on | Payload (beyond common) | Caption | Haptic |
|---|---|---|---|---|---|
| 1 | `cue.title.enter` | Title ready | — | `caption.title_enter` | none |
| 2 | `cue.class.confirm` | Class committed | `class_type: StringName` | `caption.class_confirm` | light |
| 3 | `cue.hero.spawn` | Hero spawns | `position: Vector2i` | — | none |
| 4 | `cue.melee.swing` | Attack initiated | `facing: Vector2i` | — | none |
| 5 | `cue.melee.hit` | Melee connects | `target_id: StringName`, `damage: int` | — | light |
| 6 | `cue.enemy.death` | Enemy HP=0 | `position: Vector2i` | — | none |
| 7 | `cue.enemy.spawn` | Reinforcement | `enemy_type: StringName`, `position: Vector2i` | `caption.death_spawn` (Death only) | none |
| 8 | `cue.enemy.telegraph` | Ranged windup | `position: Vector2i` | — | none |
| 9 | `cue.pickup.food` | Food collected | `position: Vector2i`, `hp_restored: int`, `first_food: bool` | `caption.food` (first only) | light |
| 10 | `cue.pickup.key` | Key collected | `position: Vector2i` | `caption.key` | light |
| 11 | `cue.pickup.treasure` | Treasure collected | `position: Vector2i`, `value: int` | `caption.treasure` | light |
| 12 | `cue.pickup.potion` | Potion collected | `position: Vector2i` | — | none |
| 13 | `cue.potion.used` | Potion activated | `class_type: StringName` | `caption.potion_used` | light |
| 14 | `cue.generator.destroyed` | Generator destroyed | `position: Vector2i`, `score: int` | `caption.generator_destroyed` | medium |
| 15 | `cue.player.hit` | Player damaged | `damage: int`, `source: StringName` | — | none |
| 16 | `cue.player.death` | Player HP=0 | `source: StringName` (if OQ-19) | `caption.death_<source>` | heavy |
| 17 | `cue.door.unlock` | Key consumed | `position: Vector2i` | — | none |
| 18 | `cue.exit.open` | Exit revealed | `position: Vector2i` | — | none |
| 19 | `cue.floor.clear` | Floor cleared | `floor: int`, `score: int` | `caption.floor_clear` | light |
| 20 | `cue.projectile.impact` | Projectile hits | `position: Vector2i`, `target_id: StringName` | — | none |
| 21 | `cue.hp.tick` | HP decrements | `hp: int` | — | none |

**Changes from prior draft:** `cue.projectile.impact` (row 20) and `cue.hp.tick` (row 21) are promoted from PROPOSED to REAL events. AC-41 triggers on `cue.projectile.impact`. SIG-1 telemetry records from `RulesSession.hp_changed` directly (JuiceDirector signal connection); `cue.hp.tick` is the CueBus dispatch for presentation, also recorded in `juice_events`.

**streak_count removed from `cue.enemy.death` payload (OBL-33):** StreakManager tracks streak internally by counting `cue.enemy.death` events. The payload does not carry streak data; StreakManager owns it.

**Attract-mode suppression:** When `StateMachine.attract_mode == true`: `cue.floor.clear` caption/banner/hitstop/SIG5BorderRect are suppressed. The event still fires (for telemetry); only visual/audio presentation is suppressed.

---

## 10. Frame budget worksheet

**Weakest declared target:** Steam desktop, min-spec Intel UHD 630, 8GB RAM, 1080p. **Acceptance threshold: 99th percentile frame time <12ms** over 10-second sustained capture. G6 device-tier data not in INPUT (OQ-9).

**Cap derivation (OBL-54):** Normative peak = 38 active Tweeners. Cap = ceil(38 × 1.26) = 48. Critical normative = 17. Sub-cap = ceil(17 × 1.35) = 23.

**Critical mutually exclusive groups (OBL-15/23/66):**
- **Group A (combat):** generator destruction (14) + hero hurt (3) + potion use (3) = 20. Can overlap.
- **Group B (transition):** SIG-5 floor clear (7). Precludes combat (scene transition).
- **Group C (terminal):** hero death (2). Precludes all others (terminal state).
- Max critical = max(20, 7, 2) = 20 ≤ 23 ✓.

### Normative peak (Floor 15, Zone 3 — 200ms combat burst)

2 generators destroyed, 2 enemy deaths, 3 melee hits, 2 knockbacks, 2 floaters, 1 telegraph, 1 projectile impact, 1 HP pulse, 1 score pop, hero swing + lunge, hero hurt, 1 void-bridge pulse. HP ≤10% (worst ambient).

| Component | Count | Budget each | Total | Critical? |
|---|---|---|---|---|
| 2 generator composites (AC-43) | 2 | 7 | 14 | yes |
| 1 hero hurt (AC-33) | 1 | 3 | 3 | yes |
| 2 enemy deaths (AC-36) | 2 | 2 | 4 | no |
| 3 hit flashes (AC-34) | 3 | 1 | 3 | no |
| 2 knockbacks (AC-35) | 2 | 1 | 2 | no |
| 2 floaters (AC-22) | 2 | 2 | 4 | no |
| 1 telegraph (AC-37) | 1 | 1 | 1 | no |
| 1 projectile impact (AC-41) | 1 | 1 | 1 | no |
| 1 HP pulse (AC-15) | 1 | 1 | 1 | no |
| 1 score pop (AC-21) | 1 | 1 | 1 | no |
| 1 hero swing (AC-31) | 1 | 1 | 1 | no |
| 1 hero lunge (AC-32) | 1 | 1 | 1 | no |
| 1 void-bridge pulse (AC-52) | 1 | 2 | 2 | no |
| **Total** | | | **38** | 17 critical, 21 non-critical |

Non-critical slots: `min(25, 48 - 17) = 25`. 21 ≤ 25 ✓. **Headroom: 48 - 38 = 10.**

### Ambient tweeners (normative)

| Component | Count | Condition |
|---|---|---|
| 2 generators idle (AC-42) | 2 | alive |
| 1 exit glow (AC-45) | 1 | exit revealed |
| 3 pickup bobs (AC-46, max 6) | 3 | on floor |
| 1 HP vignette (AC-20b) | 1 | HP ≤10% |
| 1 HP pulse freq (AC-20c) | 1 | HP ≤50% |
| 1 hero flame overlay (AC-Flame-L) | 1 | adjacent to jet |
| **Total** | **9** | Headroom: 7 |

### SpriteFrames

1 hero walk + up to 28 scullion walks. Realistic: 6–9. Ceiling: 29. Excluded from tween caps.

### Particles (normative: 131 raw, cap 160 — no eviction)

| Component | Count |
|---|---|
| 2 generator rings × 14 | 28 |
| 2 enemy deaths × (8+6) | 28 |
| 3 melee sparks × 6 | 18 |
| 1 projectile impact × 4 | 4 |
| 5 projectile trails × 1 | 5 |
| 4 flame jets × (5+3) | 32 |
| 4 torches × 4 | 16 |
| **Raw total** | **131** |

131 < 160 ✓. Headroom: 29.

### Cap-derived worst case (all per-type maxed)

**Critical (Group A combat):**

| Type | Max inst | Budget/inst | Total |
|---|---|---|---|
| Generator destruction | 2 | 7 | 14 |
| Hero hurt | 1 | 3 | 3 |
| Potion use | 1 | 3 | 3 |
| **Critical total** | | | **20** |

20 ≤ 23 ✓.

**Non-critical (combat types maxed):**

| Type | Max inst | Budget/inst | Total |
|---|---|---|---|
| Enemy death | 4 | 2 | 8 |
| Hit flash | 6 | 1 | 6 |
| Knockback | 4 | 1 | 4 |
| Floater | 6 | 2 | 12 |
| Telegraph | 4 | 1 | 4 |
| Pickup pop | 3 | 1 | 3 |
| Projectile impact | 6 | 1 | 6 |
| Projectile spawn | 6 | 1 | 6 |
| Hero swing | 1 | 1 | 1 |
| Hero lunge | 1 | 1 | 1 |
| Enemy spawn | 4 | 2 | 8 |
| Caption in | 1 | 2 | 2 |
| HP drain pulse | 1 | 1 | 1 |
| HP color shift + label | 1 | 2 | 2 |
| HP food pop | 1 | 1 | 1 |
| Score pop | 1 | 1 | 1 |
| Streak scale | 1 | 1 | 1 |
| Void-bridge (AC-52) | 2 | 2 | 4 |
| **Non-critical total** | | | **71** |

Non-critical slots: `min(25, 48 - 20) = 25`. 71 requested → **46 non-critical killed** (snap-completed in priority order: Low → Normal → High).
Active: 20 + 25 = **45** ≤ 48. Headroom: 3.

**Floor-enter types (exclusive with combat — Group B transition context):**

| Type | Max inst | Budget/inst | Total |
|---|---|---|---|
| Hero spawn | 1 | 2 | 2 |
| Hero death | 1 | 2 | 2 (critical Group C) |
| Door open | 1 | 2 | 2 |
| Floor darken | 1 | 1 | 1 |
| Floor banner | 1 | 2 | 2 |
| Floor drop-in | 1 | 2 | 2 |
| SIG-5 composite | 1 | 7 | 7 (critical Group B) |

These are exclusive with combat. Max floor-enter + transition: 7 (SIG-5) + 9 (other floor-enter) = 16 ≤ 48.

### Conditional: potion cut (OQ-11 denies potions)

Remove SIG-4 (3 critical), AC-50 (1 non-critical), PT-09 (16 particles), PT-08 (6 particles).

| Scenario | Critical | Non-critical | Total active | Headroom |
|---|---|---|---|---|
| Normative (no potion in burst) | 17 | 21 | 38 | 10 |
| Normative potion-cut | 17 | 21 | 38 | 10 (unchanged — potion not in normative burst) |
| Cap-derived Group A | 20 | 25 (after cull) | 45 | 3 |
| Cap-derived Group A potion-cut | 17 | 25 (after cull of 46) | 42 | 6 |

### Conditional: Death telegraph cut (OQ-13 denies Death enemy)

Remove PT-17 (10 particles). Raw particle total: 336. After eviction (188 killed): 148 ≤ 160 ✓.

### Per-type instance caps and overflow

| Type | Max inst | Budget/inst | Overflow behavior | Priority |
|---|---|---|---|---|
| Generator destruction | 2 | 7 | 3rd: oldest snap-completes | Critical |
| Hero hurt | 1 | 3 | 2nd: existing snap-completes | Critical |
| Hero death | 1 | 2 | 2nd: rejected (terminal) | Critical |
| Potion use | 1 | 3 | 2nd: rejected (cooldown `juice.potion.cooldown_ms`) | Critical |
| SIG-5 composite | 1 | 7 | 2nd: rejected (one per floor clear) | Critical |
| Enemy death | 4 | 2 | 5th: oldest snap-completes | High |
| Hit flash | 6 | 1 | 7th: oldest snap-completes | Normal |
| Knockback | 4 | 1 | 5th: oldest snap-completes | Normal |
| Floater | 6 | 2 | 7th: oldest snap-completes | High |
| Ranged telegraph | 4 | 1 | 5th: oldest snap-completes | Low |
| Pickup pop | 3 | 1 | 4th: oldest snap-completes | Normal |
| Projectile impact | 6 | 1 | 7th: oldest snap-completes | Normal |
| Projectile spawn | 6 | 1 | 7th: oldest snap-completes | Low |
| Enemy spawn | 4 | 2 | 5th: oldest snap-completes | Normal |
| Hero swing | 1 | 1 | 2nd: existing snap-completes | Normal |
| Hero lunge | 1 | 1 | 2nd: existing snap-completes | Normal |
| Hero spawn | 1 | 2 | 2nd: rejected | High |
| Door open | 1 | 2 | 2nd: rejected | Low |
| Floor darken | 1 | 1 | 2nd: rejected | Normal |
| Floor banner | 1 | 2 | 2nd: rejected | High |
| Floor drop-in | 1 | 2 | 2nd: rejected | High |
| Caption in | 1 | 2 | New kills existing | Normal |
| HP drain pulse | 1 | 1 | New kills existing | Normal |
| HP color/label shift | 1 | 2 | New kills existing | Normal |
| HP food pop | 1 | 1 | New kills existing | Normal |
| Score pop | 1 | 1 | New kills existing | Normal |
| Streak scale | 1 | 1 | New kills existing | Normal |
| Void-bridge | 2 | 2 | 3rd: rejected (max 2 clusters) | Normal |

### Ambient per-type caps

| Type | Max inst | Overflow |
|---|---|---|
| AC-04 title prompt | 1 | — |
| AC-05 title portrait | 1 | — |
| AC-20/20b HP vignette | 1 | — |
| AC-20c HP pulse freq | 1 | — |
| AC-25 continue token | 1 | — |
| AC-42 generator idle | 4 | 5th: oldest stops |
| AC-45 exit glow | 1 | — |
| AC-46 pickup bob | 6 | 7th: static (no bob) |
| AC-Flame-L flicker loop | 1 | — |

Max gameplay ambient: 1+1+4+1+6+1 = 14 ≤ 16 ✓.

### Cost estimates (PROVISIONAL — G10 verifies by profiling)

| Scene | One-shot | Ambient | SF | Particles | Cost (ms) | Headroom (12ms) |
|---|---|---|---|---|---|---|
| Splash/Title | 3 | 2 | 0 | 0 | 0.8 | 93% |
| Class Select | 8 | 0 | 0 | 0 | 1.5 | 87% |
| **Play (normative)** | **38** | **9** | **29** | **131** | **7.69** | **36%** |
| Play (cap-derived) | 45 | 16 | 29 | 160 | 9.07 | 24% |
| Floor Results | 6 | 0 | 0 | 0 | 1.5 | 87% |
| Game Over/Continue | 4 | 1 | 0 | 0 | 1.0 | 92% |

### Unbounded count check

No unbounded emitters. Every particle effect carries max-concurrent cap. Global cap 160. Projectile trails capped at 20. Ambient torches capped at 8. VoidBridgeOverlay max 2. HeroFlameOverlay max 1. Ambient tween cap 16. Critical sub-cap 23. SpriteFrames ceiling 29. Per-type caps for all 28 tween types.

### Duration band check

Every one-shot inside 80–400ms. Exceptions argued inline: AC-22 (400ms, readability), AC-62 (500ms, scene boundary), §6 Play→Game Over (400ms, scene-level), AC-42b (50ms, glitch flash), AC-52 (900ms on-phase, warning dwell), SIG-5 camera drift (600ms, reverence beat). Hitstop 33–100ms. Ambient loops continuous.

### Re-run trigger

If G10 verifies actual per-floor enemy count > 28 OR generator count > 2 destructible in 200ms OR scullion count > 28 on any floor (checked against `rules_floor.gd` caps), G10 re-runs worksheet. If headroom <20% against 12ms, G10 reduces Tier 2 particle counts (PT-16 torches to 4, PT-15 flame to 3) and re-profiles. "Generator count > 2" refers to `max_destructible_generators_per_burst` in `rules_floor.gd`, not the on-floor count (max 4).

### Test coverage matrix

| Category | Tests | Type |
|---|---|---|
| Tier 1 AC contracts (AC-01,02,03,08,10,15,16,16b,17,17c,17b,18,19,20,20b,20c,21,22,26,27,28,29,31,32,33,34,35,36,37,38,39,Flame,Flame-L,Flame-X,41,42,42b,43,44,47,47r,48,49,50,52,53,54,55,56,57,58,59,60,62,63,SIG5,Streak,Zone1-4) | 1 positive + 1 negative each | Automated |
| Tween cap enforcement | 3 (boundary, critical overflow, same-property) | Automated |
| Particle cap enforcement | 2 (eviction, critical survival) | Automated |
| Per-type overflow | 1 per type with defined overflow | Automated |
| Accessibility | 3 (Reduce Motion, haptics-off, colorblind labels) | Automated |
| Asset admission (42) | 42 positive + 42 negative | Automated |
| SIG composites (1-5) | 1 positive + 1 negative each | Automated |
| Tier 2 contracts | Movie capture only | Visual |

### Definition of done

1. Gates R-1 through R-4 closed (R-5 gated on OQ-2, blocking with 48h deadline).
2. All `juice.*` keys in `Tunables.json` with band+step+default. Fixed keys carry `band: null, step: null`. `_defaults.gd` generated from same schema.
3. `test_presentation.gd`, `test_main_scene_contract.gd`, asset-admission assertions ship with negative tests.
4. Frame budget profiling: 99th percentile <12ms over 10s on min-spec (or scaled equivalent — OQ-20).
5. OQ-1a and OQ-1b resolved to "proceed" before G10 starts.
6. Telemetry records `juice_events` and `result` field.
7. SIG-4 conditional: if OQ-11 denies potions, cut SIG-4/AC-51/AC-50/PT-09/PT-08. DoD accepts 4-signature set.
8. `cue.projectile.impact` and `cue.hp.tick` registered as real CueBus events.

---

## 11. Open questions

| # | Question | Context |
|---|---|---|
| OQ-1a | **Blocking: SHIP authorization.** G10 does not start until resolved. | Preamble, §1 |
| OQ-1b | **Blocking: 2D supersession.** G10 does not start until resolved. | Preamble |
| OQ-2 | **Blocking for R-5: Tick-to-second mapping.** 48h deadline; defaults to reel-disabled. | §1 R-5 |
| OQ-3 | Presentation layer wiring — G10's first task. | §1 R-2 |
| OQ-4 | Attract reel re-record sub-path selection (a/b/c). | §1 R-5 |
| OQ-5 | Difficulty cliff telegraph. No new art. | §1 P-3 |
| OQ-6 | Bot qualification documentation. | §1 W-1 |
| OQ-7 | **Sheet AND atlas sidecar verification.** G10 verifies frame_width/height/count for all `*_sheet.png` AND region x/y/w/h per icon for `ui-hud-icons.png` AtlasTexture. Missing → static fallback. | §2, §3 |
| OQ-8 | Unavoidable async loads — entertaining wait, never spinner. | §7 |
| OQ-9 | G6 device-tier data. If weaker than UHD 630, worksheet revisited. | §10 |
| OQ-10 | `cue.hp.tick` CueBus registration — now REAL, G10 wires it. | §9 |
| OQ-11 | **Potion mechanic (BLOCKING for SIG-4).** If denied: cut SIG-4, AC-51, AC-50, PT-09, PT-08. | §2, §8, §10 |
| OQ-12 | Void-bridge tile metadata in floor data. | §2 AC-52 |
| OQ-13 | Death enemy spawn confirmation. If absent, PT-17 inert. | §3 PT-17 |
| OQ-14 | Worst-case entity counts — G10 verifies against `rules_floor.gd` caps (28 enemies, 2 destructible generators). | §10 |
| OQ-15 | Continue token mechanic. If absent, AC-25 cut. | §2 AC-25 |
| OQ-16 | Attract replay format. | §1 R-5 |
| OQ-17 | Machine-play SIG-4 coverage — bot never uses potions. Visual capture only. | §10 |
| OQ-18 | 2D supersession formalization — resolved by OQ-1b. | Preamble |
| OQ-19 | `last_damage_source` rules field. If absent, generic "YOU DIED". G10 does NOT add it. | §8, §9 |
| OQ-20 | CI profiling access. If UHD 630 unavailable, use scaling: `target_cost × (benchmark_score_UHD630 / available_gpu_score)` from a standardized GPU benchmark. Document substitution. | §10 |
| OQ-21 | TRANS_BACK overshoot verification. Sample max bounding box across full tween at 1ms granularity; assert ≤34.56px on 32px sprite. | Preamble |
| OQ-22 | `first_food_collected` rules flag. If absent, all food gets full treatment. | §2 AC-47r |
| OQ-23 | Synchronous load within fade window. G10 verifies, extends fade if needed. | §7 |
| OQ-24 | Blend-mode consistency for premultiplied-alpha textures on normal-blend nodes. | §3 |

---

## Asset Delivery

### Manifest schema

`Assets/ASSET_MANIFEST.json` entries carry: `semantic_id`, `filename`, `sha256`, `frame_width`, `frame_height`, `frame_count` (sheets), `atlas_regions` (for `ui-hud-icons.png`: `[{name, x, y, w, h}, ...]`), `license`, `placement` (shipped/debt/denied).

### Delivery mapping

All 42 assets ship under `res://Assets/` with `.import` metadata committed source-side. Runtime loads via `ResourceLoader.load("res://Assets/<filename>")` or `load()`. Never reference `.godot/imported` paths. One typed registry (`res://Scripts/asset_registry.gd`) binds semantic IDs to loaded resources; gameplay scripts reference IDs, never filenames.

### Programmer-art fallback

If any asset fails `ResourceLoader` load at runtime: JuiceDirector logs the failure, substitutes a visible 32×32 magenta ColorRect (unmistakable error color), and flags `asset_debt: [semantic_id]` in telemetry. The game continues; the gap is visible, not silent. G10 ships negative tests that break each asset path and verify the fallback fires.

### Import and ResourceLoader proof required

G10 runs `ResourceLoader.load()` for all 42 assets as a test suite (`test_asset_admission.gd`). Each test asserts: resource loads non-null, type matches expected (`Texture2D` for all 42), dimensions match manifest. Negative test per asset: rename file, assert fallback fires. This closes Gate R-4.

---

## Runtime Proof

1. **Toolchain receipt:** G10 logs exact Godot version (`Engine.get_version_info().string`) to telemetry on every run. Expected: `4.7.x`.
2. **Editor import result:** `test_asset_admission.gd` proves all 42 assets import and load via `ResourceLoader`.
3. **GDScript parse/static-check:** `godot --headless --check-only --script res://main.gd` (or equivalent) exits zero. All autoload scripts parse.
4. **Deterministic headless bot telemetry:** `ci/sneferu_bot.gd` runs with fixed seed, produces `playtest_telemetry_v1` JSON at the absolute path. Two runs at same seed compare normalized telemetry.
5. **Real-render journey:** Visual proof script launches `res://main.tscn` at fixed FPS, records bounded journey with Godot movie writer, exits. Never renders a substitute scene.
6. **Export/install/start proof:** Only for platforms whose templates are installed. If Steam templates absent, export proof is deferred and disclosed — not fabricated.

---

## Obligation Responses

OBL-1: ADDRESSED — rules_floor.gd declares max_destructible_generators_per_burst=2; frame budget bound to this rules invariant, not the on-floor...
OBL-2: ADDRESSED — cap-derived critical total is 20 (Group A), not 21; 3rd generator snaps oldest per per-type cap, not sub-cap overflow; math c...
OBL-3: ADDRESSED — eviction uses whole-emitter kills; step 11 kills one PT-04 instance (4 particles), total active 158≤160.
OBL-4: ADDRESSED — JuiceDirector connects directly to RulesSession.hp_changed signal for SIG-1 juice_events; cue.hp.tick promoted to real event.
OBL-5: ADDRESSED — AC-16b (FAIR at 50%), AC-17c (LOW at 25%), AC-17b (CRITICAL at 10%) all have explicit AC rows with HPStatusLabel dynamic text.
OBL-6: ADDRESSED — R-2 acceptance specifies frame_sanity pixel-variance ≥5% between consecutive frames as machine-verifiable assertion.
OBL-7: ADDRESSED — AC-42b 50ms argued inline: pre-death glitch warning must read as instability spike, not deliberate motion.
OBL-8: ADDRESSED — AC-Flame-X defines exit: alpha 0.7→0 over 150ms cubic-out when hero leaves flame-jet adjacency.
OBL-9: ADDRESSED — OQ-7 extended to explicitly cover ui-hud-icons.png AtlasTexture region verification (x/y/w/h per icon).
OBL-10: ADDRESSED — §4 states: haptic is private to controller holder; shake is public, shifts entire viewport; same event can earn private tap w...
OBL-11: ADDRESSED — §10 includes conditional potion-cut alternate budget table showing critical drops to 17, non-critical to 42, headroom 6.
OBL-12: ADDRESSED — normative counts bound to rules_floor.gd caps (max_enemies=28, max_destructible_generators=2); re-run trigger references rule...
OBL-13: ADDRESSED — AC-33, AC-36, AC-47, AC-47r, AC-51, AC-63, AC-SIG5 all fully decomposed with phase tables matching AC-43 format.
OBL-14: ADDRESSED — cue.projectile.impact promoted to real CueBus event (row 20); AC-41 triggers on it.
OBL-15: ADDRESSED — cap-derived includes hero death (2 critical, Group C terminal, exclusive); Group A max=20≤23 sub-cap.
OBL-16: ADDRESSED — AC-53 (floor darken) classified Normal priority; AC-63 (floor drop-in) classified High priority; both in per-type table.
OBL-17: ADDRESSED — same as OBL-10; private-vs-public argument stated in §4.
OBL-18: ADDRESSED — OQ-7 explicitly covers ui-hud-icons.png AtlasTexture sidecar region verification.
OBL-19: ADDRESSED — Zone 4 alpha 0.20 argued inline: final descent, elevated alpha signals escalating dread.
OBL-20: ADDRESSED — re-run trigger clarified: references max_destructible_generators_per_burst in rules_floor.gd (2), not on-floor count (4).
OBL-21: ADDRESSED — all composites fully decomposed; no "as before" references remain.
OBL-22: ADDRESSED — HP labels reconciled: FAIR/LOW/CRITICAL at 50/25/10 with explicit AC rows (AC-16b, AC-17c, AC-17b) and HPStatusLabel node.
OBL-23: ADDRESSED — SIG-5 fully decomposed (7 budget units, all critical, Group B transition exclusive with combat).
OBL-24: ADDRESSED — cap-derived table includes all per-type rows including door, banner, darken, drop-in, hero death/spawn, HP color/food, void-b...
OBL-25: ADDRESSED — non-critical slots formula: min(25, 48-active_critical); if non-critical exceeds 25 under total<48, per-type caps enforced fi...
OBL-26: ADDRESSED — kill granularity pinned to whole Tween (one Tween per property animation); no individual Tweener kills.
OBL-27: ADDRESSED — affected-properties list completed with all nodes including ScreenEdgeRect, FlashRect, ClassTintRect, SIG5BorderRect, BannerL...
OBL-28: ADDRESSED — eviction uses whole-emitter kills; no partial-instance particle kills.
OBL-29: ADDRESSED — PT-06 overflow: per-type cap snap-completes oldest instance; critical-never-killed applies to global eviction only, not per-t...
OBL-30: ADDRESSED — ambient per-type caps defined: AC-46 max 6, AC-42 max 4; overflow behavior specified; max gameplay ambient=14≤16.
OBL-31: ADDRESSED — during hitstop, world-juice tweens paused, UI-juice tweens advance; rule stated explicitly in §2.
OBL-32: ADDRESSED — JuiceDirector connects to RulesSession.hp_changed directly; juice_events recorded from rules signals, not CueBus.
OBL-33: ADDRESSED — streak_count removed from cue.enemy.death payload; StreakManager tracks internally.
OBL-34: ADDRESSED — test matrix lists all Tier 1 AC IDs explicitly including AC-Flame, AC-37, AC-38, AC-41, AC-42b, AC-51, AC-59, AC-60, AC-62, A...
OBL-35: ADDRESSED — SIG5BorderRect changed from ColorRect to TextureRect (Godot 4 TextureRect supports textures).
OBL-36: ADDRESSED — AC-20c, AC-52, AC-Flame split into per-value tunable keys (period_50/25/10, on_ms/off_ms/alpha_peak/cycles, entry/loop/exit w...
OBL-37: ADDRESSED — AC-52 900ms argued inline (warning dwell); SIG-5 camera drift 600ms argued inline (reverence beat).
OBL-38: ADDRESSED — R-5 acceptance pinned to telemetry fields: duration=ticks_total/60.0, hp_final≤400, juice_events floor_cleared count≥2.
OBL-39: ADDRESSED — Reduce Motion section includes AC-61 gold flash (halved), SIG5BorderRect (halved/static), AC-41 projectile impact (halved dur...
OBL-40: ADDRESSED — AC-15 classified as part of SIG-1 critical; AC-20c is ambient (not critical, not protected by critical sub-cap).
OBL-41: ADDRESSED — all obligation responses are complete sentences, none truncated.
OBL-42: ADDRESSED — OQ-21 verification samples max bounding box across full tween at 1ms granularity, not just 1/3.
OBL-43: ADDRESSED — private-vs-public rationale stated in §4 and cross-referenced in §5.
OBL-44: ADDRESSED — AC-Flame split into separate tunable keys: entry_ms, entry_alpha, loop_period_ms, loop_low, loop_high, exit_ms.
OBL-45: ADDRESSED — JuiceDirector uses @export NodePath, assigned by Main._ready(); no group lookups.
OBL-46: ADDRESSED — RulesSession emits typed signals; JuiceDirector connects via signal.connect(); no "callback" wording.
OBL-47: ADDRESSED — project.godot and res://main.tscn explicitly named in runtime architecture section.
OBL-48: ADDRESSED — engine version pinned to Godot 4.7 exact; G10 logs full version string.
OBL-49: ADDRESSED — ContinueOffer node added to scene tree under HUDCanvas.
OBL-50: ADDRESSED — StateMachine is PROCESS_MODE_PAUSABLE; un-pause initiated by PauseMenu (WHEN_PAUSED) via direct method call.
OBL-51: ADDRESSED — bot seam explicitly states "calls the SAME RulesSession API as human play."
OBL-52: ADDRESSED — result code 5=loop_detected added to result codes.
OBL-53: ADDRESSED — CLI contract fully specified: --seed, --policy, --class, --count, --telemetry (all required).
OBL-54: ADDRESSED — cap derived from normative peak: 38×1.26=48; sub-cap: 17×1.35=23; justification stated.
OBL-55: ADDRESSED — enforcement order stated: per-type caps first, then global priority cull.
OBL-56: ADDRESSED — potion cooldown added: juice.potion.cooldown_ms (default 1000ms) with band/step/default.
OBL-57: ADDRESSED — cue.projectile.impact promoted to real event (row 20 in §9).
OBL-58: ADDRESSED — cue.hp.tick promoted to real event (row 21 in §9); SIG-1 also recorded via direct signal.
OBL-59: ADDRESSED — Asset Delivery section added with manifest schema, delivery mapping, fallback, ResourceLoader proof.
OBL-60: ADDRESSED — Runtime Proof section added with 6 proof categories.
OBL-61: ADDRESSED — res://Data/ justified as data directory parallel to res://Assets/ for renderables; Tunables is game-logic data.
OBL-62: ADDRESSED — OQ-7 explicitly lists ui-hud-icons.png AtlasTexture region verification.
OBL-63: ADDRESSED — haptic duration conversion rule added: duration_s = duration_ms × 0.001 (juice.haptic.duration_conversion).
OBL-64: ADDRESSED — attract mode is title-screen-only; player input exits attract before any game state; pause not reachable during attract.
OBL-65: ADDRESSED — all composites fully decomposed with phase tables, no "as before" references.
OBL-66: ADDRESSED — SIG-5 decomposed with 7 budget units, added to cap-derived as Group B critical (exclusive with combat).
OBL-67: ADDRESSED — AC-Flame-X defines exit/fade-out: alpha 0.7→0, 150ms cubic-out.
OBL-68: ADDRESSED — kill granularity pinned to whole Tween; one Tween per property animation.
OBL-69: ADDRESSED — enforcement order: per-type first, then global priority cull; non-critical formula clarified.
OBL-70: ADDRESSED — eviction uses whole-emitter kills; step 11 kills one PT-04 instance (4 particles); active=158≤160.
OBL-71: ADDRESSED — PT-06 overflow: per-type cap snap-completes oldest; critical-never-killed is global-eviction-only rule.
OBL-72: ADDRESSED — SIG5BorderRect is TextureRect, not ColorRect.
OBL-73: ADDRESSED — cap-derived includes all per-type rows; potion-cut alternate budget provided.
OBL-74: ADDRESSED — entity counts bound to rules_floor.gd caps; generator invariant stated (max 2 destructible per burst).
OBL-75: ADDRESSED — RulesSession emits typed signals; JuiceDirector connects via signal.connect(); no callback wording.
OBL-76: ADDRESSED — JuiceDirector uses @export NodePath assigned by Main; no group lookups.
OBL-77: ADDRESSED — Godot 4.7 pinned, project.godot/main.tscn named, ContinueOffer node added, StateMachine un-pause ownership clarified.
OBL-78: ADDRESSED — bot CLI fully specified, loop_detected result code added, same-API statement included.
OBL-79: ADDRESSED — cue.projectile.impact and cue.hp.tick promoted to real events; JuiceDirector also connects to RulesSession.hp_changed directly.
OBL-80: ADDRESSED — FAIR/LOW/CRITICAL labels reconciled across accessibility, AC table, and scene tree with HPStatusLabel dynamic text.
OBL-81: ADDRESSED — Reduce Motion includes AC-61 gold flash, SIG5BorderRect, AC-41 projectile impact.
OBL-82: ADDRESSED — private-vs-public rationale in §4: haptic private to controller holder, shake public viewport shift.
OBL-83: ADDRESSED — JuiceDirector split into TweenManager, ParticleManager, HitstopManager, StreakManager, VoidBridgeManager sub-managers.
OBL-84: ADDRESSED — juice_events recorded from RulesSession signals directly; bot telemetry hooks RulesSession; CueBus is presentation-only dispa...
OBL-85: ADDRESSED — single schema generates both Tunables.json and _defaults.gd at build time; no hand-maintained duplicate.
OBL-86: ADDRESSED — premultiplied alpha textures flagged; G10 must use PREMULT_ALPHA CanvasItemMaterial or re-import with straight alpha (OQ-24).
OBL-87: ADDRESSED — conditional cap-math rows for potion-cut and Death-telegraph-cut in §10.
OBL-88: ADDRESSED — headless scene tree defined: Main.tscn instantiated with WorldView/EntityLayer nodes; particles/camera don't simulate without...
OBL-89: ADDRESSED — OQ-2 flagged as blocking for R-5 with 48h deadline; defaults to reel-disabled if unresolved.
OBL-90: ADDRESSED — OQ-20 uses scaling formula tied to standardized GPU benchmark score, not ad-hoc substitution.
OBL-91: ADDRESSED — §1 split into explicit Repair Queue (R-1–R-4) and Polish Queue (P-1–P-4) with separate tables.
OBL-92: ADDRESSED — OQ-7 extended to verify ui-hud-icons.png AtlasTexture regions (x/y/w/h per icon).
OBL-93: ADDRESSED — normative counts grounded in rules_floor.gd caps (max_enemies=28, max_destructible_generators=2).
OBL-94: ADDRESSED — private-vs-public rationale in §4, cross-referenced from §5.
OBL-95: ADDRESSED — particle emitter seeding: hash(entity_id + burst_index); burst_index resets on pool recycle.
OBL-96: ADDRESSED — counting metric clarified: concurrent active Tweeners; round-trips use sequential Tweeners (1 active at a time) = 1 budget unit.
OBL-97: ADDRESSED — round-trip implementation pinned: 2 sequential tween_property() calls in one Tween, counted as 1 active budget unit.
OBL-98: ADDRESSED — AC-52 void-bridge tweeners (2 budget units) included in normative peak (total 38) and cap-derived.
OBL-99: ADDRESSED — HPStatusLabel with dynamic text replaces LowHPLabel; AC-16b/17c/17b define all three thresholds.
OBL-100: ADDRESSED — HPStatusLabel node uses Label.text assignment for text changes; alpha tweened; mechanism is implementable.
OBL-101: ADDRESSED — all composites fully decomposed with from/to/easing/ms/tunable keys; no "as before" stubs.
OBL-102: ADDRESSED — eviction uses whole-emitter kills; no partial-particle kills; arithmetic reconciles to 158≤160.
OBL-103: ADDRESSED — rules_floor.gd declares max 4 generators per floor but max 2 destructible per burst; budget uses the burst cap.
OBL-104: ADDRESSED — private-vs-public rationale stated in §4; haptic on enemy hits is private confirmation, shake is public disruption.
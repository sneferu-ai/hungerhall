# G11 — Sound Brief (Locked Runtime)

**Artifact:** `audio/sound_brief.md` · **Run:** gap-253b64a1 · **Phase:** G11 → commissioning handoff · **Engine (LOCKED):** Godot 4.7, GDScript, 2D · **Target:** Steam desktop (min-spec: Intel UHD 630, 8GB RAM, 1080p)

## Identity and scope

No OPERATOR AUDIO LIBRARY section in the seed. Classic commission brief: every sound specified precisely enough for a composer or royalty-free session to execute without follow-up questions. Zero audio, zero code produced.

**Concept lock citation.** G1 Concept Lock (gap-253b64a1) authorizes: Godot engine, 2D presentation, Gauntlet-like single-player dungeon crawler. The 3-track split, HP-drain silence, and VO deferral to G3 are G11 design decisions within locked scope.

Three frozen inputs bind direction. G9's sound integration points form the SFX spine — every entry keys back by CueBus name. G3's voice bible supplies register and owns the announcer pipeline. G4's art direction supplies the room: white-gloved hunger, plum-stone near-dark, one rationed amber crescent for interactive, spectral cyan for ghost/void.

**Audio thesis — the room, not the cabinet.** The pixel art is the cabinet's face; the sound is the building breathing. The world sounds like a service kitchen heard from the dining floor: iron, ceramic, wood, cloth, glass, paper — dry, close, small, nothing larger than a one-second tail. The announcer is the only period-synth voice; the environment is never chiptune pastiche. Where G4 rations warmth to one amber token, audio rations its warmest timbres to food, the new-best tick, and the floor-clear service bell. Where G4 reserves cyan for spectral, audio reserves wet-hollow air for ghosts, the void bridge, and the famished descent.

**All-pre-rendered approach — craft preference.** Procedural synthesis via AudioStreamGenerator was evaluated and rejected: the brief's aesthetic (dry, close, small, real kitchen textures) benefits from recorded audio character synthesized noise cannot replicate. If a future revision proposes procedural audio, it must include a CPU benchmark on min-spec hardware.

**Fixed-track approach — production judgment.** Stem-based layers were evaluated and rejected: 3 discrete tracks with hard crossfades is simpler and lower-risk. A 3-stem system would triple music file count (9 vs 3) and add 2 concurrent streams per track during transitions. The "breathing building" thesis is served by ambience beds and zone stingers, not music stems.

**Seed-phase disagreements (DIS-1 through DIS-10) — all settled by majority vote across 7 independently-trained author seats. Not re-opened.** Key settlements: DIS-1 per-tick HP drain rejected (5/7), replaced by heartbeat bed; DIS-2 VO deferred to G3 (6/7); DIS-3 threshold SFX removed, delegated to G3 barks (5/7); DIS-4 three tracks with floor-13 split locked (4/7); DIS-5 caption in/out silent (5/7); DIS-6 enemy spawn SB (6/7); DIS-7 UI sounds SB (desktop expectations); DIS-8 Ogg q6 (majority); DIS-9 zone stingers SB + shared bed with per-zone EQ; DIS-10 hero hurt SB (6/7).

**Positions taken where reasonable designs diverge:**

1. **HP drain gets no per-tick sound.** 5/7 seats rejected per-tick audio. Heartbeat bed achieves legibility without fatigue risk.
2. **No footsteps, hero or enemy.** Up to 28 foes plus hero — footstep layers would smear the mix and bury informational sounds.
3. **Three music tracks, split at floor 13 — LOCKED.** DIS-4 resolved: 4/7 seats chose 3 tracks with gameplay split.
4. **Hero hurt gets a sound.** Short, throttled, varied. Never voiced (heroes silent per G3).
5. **Caption in/out is silent.** DIS-5 resolved: 5/7 chose silence. Announcer clip is the audio event.
6. **No third-party middleware.** Godot 4.7 native bus architecture handles ducking, mixing, and announcer priority.
7. **VO deferred to G3.** DIS-2 resolved: 6/7 placed announcer ownership in G3.
8. **No HP threshold SFX.** DIS-3 resolved: 5/7 delegated threshold audio to G3 barks. Heartbeat fade-in at 50% is the 50% cue. G3 barks at 25% and 10%.

Commission references are feel references — "the restraint of X" — never "source this recording." No sampling. All audio must be original work evoking described character without reproducing any identifiable element of referenced recordings.

---

## 1. SFX list

**Legend.** SB = ship-blocking (Tier 1). PROVISIONAL-SB = ship-blocking contingent on OQ-1 G9 diff sign-off (BLOCKED gate). NT = nice-to-have (Tier 2). COND = conditional on a listed open question. CRIT = signature-moment SFX routed through the `CritSFX` bus — never voice-stolen, exempt from announcer-triggered SFX ducking. Durations are full envelopes including decay. Variation floors are contractual minimums.

**"Folds under" definition.** When a cue "folds under" an earlier cue, the later cue is suppressed entirely (not gain-reduced, not delayed) if the earlier cue fired within 250 ms.

**Coverage key.** Rows 01–14 are the G9 §9 integration points visible in the frozen receipt. Rows 15–18 are inferred from G9 §8 implementation tuples but sit in the truncated tail of the §9 table — marked PROVISIONAL-SB; diff against the full §9 document before commissioning (OQ-1, BLOCKED gate). G9 key names win any conflict. Rows marked [ADDITION] are gameplay events G9 assigned no cue — each flagged with a one-line justification. Cut priority if budget requires: (1) all NT cues, (2) `amb.hall_tone` (demote to NT). G9-derived cues (01–14) are never cut.

### A. G9 integration points (01–14)

| # | Key | Trigger | Reference (feel only) | Character · texture · ~duration | Variation policy | Priority |
|---|---|---|---|---|---|---|
| 01 | `cue.title.enter` | Title screen ready, attract begins | A diner sign warming up — *Threes'* menu hum, emptied | Low room-tone bloom (filtered noise + 55 Hz sub-sine) fading in over 1.2 s with a single faint fluorescent tick as logo settles. No melodic content. ~1.4 s | One-shot per entry; no rotation | SB |
| 02 | `cue.class.confirm` | Class committed (AC-10/11, haptic light) | A cast-iron lid seated onto its plate — *Overcooked* pot placement, de-whimsied | Dense iron clack: 180 Hz body + 2.2 kHz transient, ~160 ms. **One base recording.** Class differentiation via per-class EQ sub-bus (§4): Warrior low-shelf +3 dB @200 Hz; Valkyrie peak +4 dB @4 kHz Q=2; Wizard high-pass 500 Hz Q=1; Elf peak +3 dB @2 kHz Q=3. No per-class files | Fixed pitch; ±3% on ring partial only | SB |
| 03 | `cue.hero.spawn` | Hero spawns at floor start (AC-29 + PT-01) | A chair drawn across stone plus a struck match — *Celeste* respawn puff warmed | Soft wood scrape (80 ms) + mid-frequency thock with faint dry spark (3 kHz tick, 60 ms). ~250 ms | ±4% pitch; fires at most once per floor (max 24 per run) | SB |
| 04 | `cue.melee.swing` | Attack initiated (AC-31 swing + AC-32 lunge) | A napkin cracked open tableside — *Hyper Light Drifter* blade arc, cloth-wrapped | Band-passed noise sweeping 400 Hz → 2 kHz over 80–120 ms, fast attack, exponential decay. No tonal center. ~8 dB below the hit. **One base recording.** Class differentiation via runtime `pitch_scale` on the AudioStreamPlayer (not bus effects): axe 1.0, spear 1.08, bolt 1.15, arrow 1.22. No per-class files | 3 round-robin recorded variants; ±6% pitch; ±1.5 dB gain; 80 ms retrigger floor per source | SB |
| 05 | `cue.melee.hit` | Melee connects (AC-34/35 + HS-1 + PT-03, haptic 200 ms throttle) | A cleaver meeting a cutting board, muffled by toweling — *Hotline Miami* impact sans slap | Transient crack (2–4 kHz, 20 ms) + body thump (150–200 Hz, 60 ms) + faint ring (800 Hz, 40 ms at −18 dB). 80–100 ms. Begins inside hitstop freeze | 3 round-robin variants; ±5% pitch; killing blow +2 dB; throttle 1 per 100 ms per pool. Excess events DROP (nearest-to-hero priority, no queue) | SB |
| 06 | `cue.enemy.death` | Enemy HP reaches zero (AC-36 + PT-05 + score floater) | A place setting cleared in one motion — *Downwell* kill pop re-timbred for kitchen crockery | Cloth-puff (400–800 Hz, 60 ms) + descending two-semitone blip (sine, 120 ms). ~200 ms. Per-family timbre: see unified family table §1.F. **Verify family list against G2 before commissioning (OQ-9)** | 2 variants per family; ±6% pitch; throttle 1 per 80 ms. Excess DROP (nearest-to-hero priority) | SB |
| 07 | `cue.enemy.spawn` | Reinforcement spawns from generator (AC-38 + PT-02; Death-type captioned) | A cloche lid lifting — *Overcooked* pot suction pop, de-cheered | Dry pop (noise, 60 ms) + faint steam tail (100 Hz, 100 ms). ~180 ms. Positional via AudioStreamPlayer2D. **Routes through Ambience sub-bus** (shared with `amb.hall_tone`) to receive per-zone EQ tint. Death-type: same base recording pitch-shifted down one octave via runtime `pitch_scale = 0.5` — no separate file. Death-type is a runtime pitch variant, not a separate family | ±5% pitch; 2 pop variants; per-zone EQ via Ambience bus (§4) | SB |
| 08 | `cue.enemy.telegraph` | Ranged windup begins (AC-37 brighten) | A kettle before whistle — *FTL* weapon charge thinned | Rising filtered saw/buzz over 250 ms matching AC-37 visual swell, hard cutoff at fire. −14 dB. Per-family pitch center: see §1.F. **4 separate recordings, one per ranged family.** No runtime pitch shift — fixed pitch preserves learned threat association | **Fixed per family** — random pitch destroys learned threat association. **Throttle: max 1 concurrent per family; excess same-family windups DROP.** Different families may overlap | SB |
| 09 | `cue.pickup.food` | Food collected (AC-47/47r + AC-18 + AC-19 + PT-07, SIG-3 first-food, haptic light) | The one warm sound in the building — *Celeste* strawberry pluck, dropped a fifth, sparkle removed | Two-note rising chime (sine 523→784 Hz, 140 ms) + soft bite transient (noise, 25 ms). ~200 ms. **First-food (SIG-3): distinct asset** `sfx_cue_pickup_food_first.wav` — four-note arpeggio (523→659→784→1046 Hz) with sparkle layer, ~450 ms, +2 dB. **First-food is CRIT-priority: routes through CritSFX bus, exempt from announcer SFX duck.** First-food REPLACES the routine pickup sound entirely; `sfx.hp.food_tick` does NOT fire during the 450 ms arpeggio. Food ticks resume on routine (non-first) food pickups. **G3 "FOOD." bark fires 500 ms after first-food arpeggio onset (i.e., 50 ms after arpeggio completes), ensuring the arpeggio is never ducked by the announcer.** On routine food pickups, the FOOD bark fires at pickup onset (standard announcer duck applies to the routine pickup sound). The game's warmest non-announcer sound | Routine: 2 variants, ±4% pitch. First-food: fixed (signature, not random) | SB; first-food = CRIT |
| 10 | `cue.pickup.key` | Key collected (AC-48 + PT-10 + icon reveal, haptic light) | Silver lifted off a hook — *Zelda* key pickup, jingle removed | Single metallic tick: two sine partials at 1.8 kHz and 2.7 kHz, fast decay, ~130 ms | ±4% pitch; 2 variants | SB |
| 11 | `cue.pickup.treasure` | Treasure collected (AC-49 + PT-11 + value floater, haptic light) | Coins counted onto felt — *Spelunky* gold pickup, dry | Two to three dry coin ticks (1.5–3 kHz, 100 ms) + descending three-note blip (1046→784→659 Hz, 150 ms). ~280 ms. Value scales amplitude only | ±5% pitch; 2 variants | SB |
| 12 | `cue.pickup.potion` | Potion collected (AC-50 + icon reveal) | A stoppered bottle set on glass — *Monument Valley* bottle feel | Glass clink (2.2 kHz, 80 ms) + liquid bloop (sine 400→200 Hz, 100 ms). ~180 ms | ±4% pitch; 2 variants | COND (OQ-11); SB if potions ship |
| 13 | `cue.potion.used` | Potion activated (SIG-4: AC-51 + HS-3 + PT-09 + caption) | A soda siphon discharged at arm's length — the panic button, class power | Three layers: glass pop (noise, 80 ms) + class open-fifth stack (sawtooth, root+fifth+octave, 400 ms, +3 dB) + smoke whoosh (filtered noise swell, 500 ms). ~600 ms under 6-frame hitstop. **Class open-fifth stacks on diatonic roots in C minor — thirdless by design, cold and ambiguous:** Warrior C3+G3+C4; Valkyrie Eb3+Bb3+Eb4; Wizard G3+D4+G4; Elf Ab3+Eb4+Ab4. Open fifths, NOT triads. Separate recordings per class. **Pitch compensation (OBL-15):** When Track 3 is dominant (Track 3 bus volume > Track 2 bus volume, approximately 5 s into the 8 s crossfade, or immediately on restart from floor_results at floor 13+), AudioDirector sets `pitch_scale = 2^(15/1200) ≈ 1.0087` on the potion AudioStreamPlayer | **Fixed per class** — player learns their class's panic sound | COND (OQ-11); SB if potions ship; CRIT |
| 14 | `cue.generator.destroyed` | Generator destroyed (SIG-2: AC-43 + HS-2 + PT-06 + caption, haptic medium, 2 px shake) | A serving cloche slammed onto stone and left to ring — *Hollow Knight* stag-bell weight sans chime | Three layers: iron lid slam (100 Hz thump + 1.1 kHz ring, 200 ms) + sub-drop (sine 80→50 Hz, 200 ms) + bell decay (1.2 kHz, 500 ms at −10 dB). ~700 ms against 4-frame freeze. Heaviest non-death sound; mix goes sparse around it | ±2% pitch only; 2 ring variants alternating (timbre shift, same pitch) | SB; CRIT |

### B. Reconstructed from G9 §8 evidence — PROVISIONAL-SB [BLOCKED gate: OQ-1]

| # | Key | Trigger | Reference | Character · texture · ~duration | Variation policy | Priority |
|---|---|---|---|---|---|---|
| 15 | `cue.door.unlock` | Key consumed, hatch opens (AC-44 + PT-12 + key icon pop) | A cold-room bolt drawn by hand — *Inside*'s dry mechanicals, pantry-sized | Bolt clunk (wood/metal, 60 ms) + grate slide (filtered noise, lowpass 800→200 Hz, 240 ms) + settle thud (80 ms). ~380 ms | ±4% pitch; fires 1–2 times per floor | PROVISIONAL-SB (OQ-1) |
| 16 | `cue.hero.death` | Hero HP reaches zero (AC-57/58 + 3 px shake + heavy haptic + AC-62) | A candle snuffed at closing time — one low bell, colder than *Journey*'s | Soft exhale (filtered noise, 200 ms) + single low toll (sine 110→55 Hz, 600 ms decay). ~800 ms across 1250 ms death presentation. **Single sound, no per-cause variants.** G3 VO cause-bark sequence carries cause information. OQ-19 resolved | Fixed | PROVISIONAL-SB (OQ-1); CRIT |
| 17 | `cue.floor.cleared` | Floor cleared (SIG-5: AC-SIG5 + HS-4 + gold border + banner + camera drift, haptic light) | A service bell struck exactly once — hotel desk formality, no fanfare | Single clear bell strike (660 Hz + 880 Hz harmonic, 200 ms attack) + soft decay (400 ms). ~600 ms under 4-frame hitstop. Deliberately small next to generator slam | Fixed (signature); ±2% pitch | PROVISIONAL-SB (OQ-1); CRIT |
| 18 | `cue.hero.hurt` | Hero takes damage (AC-33 composite; no haptic by G9 contract) | A flinch into proofed dough — *Spelunky* body hit, no sting, no voice | Body thud (130–190 Hz, 80 ms) + dissonant two-tone sting (two semitones apart, 200 ms at −14 dB). ~250 ms. Heroes silent per G3 — sound is the impact, not the person. −6 dB below melee hit (runtime gain offset in manifest) | 2 variants: `sfx_cue_hero_hurt_A.wav` (melee source), `sfx_cue_hero_hurt_B.wav` (projectile/hazard source); ±5% pitch; 250 ms global throttle | PROVISIONAL-SB (OQ-1) |

### C. Flagged additions — events G9 did not mark [ADDITION]

| Key | Trigger & justification | Reference | Character · texture · ~duration | Variation policy | Priority |
|---|---|---|---|---|---|
| `sfx.hp.heartbeat` **[ADD]** | HP ≤50% — continuous low-HP bed. SIG-1 makes HP-as-countdown the soul of the game | Air in a large cold room, deepening — *Limbo*'s walk-in fridge hum, quieter | **Single 4000 ms seamless loop file.** Routes through dedicated `Heartbeat` sub-bus (child of SFX) with `AudioEffectFilter` (low-pass). Intensity escalates via runtime automation on the **Heartbeat bus** (not the AudioStreamPlayer, which has no filter property): volume tween (−18 dB at 50%, −12 dB at 25%, −8 dB at 10%) and low-pass filter cutoff automation (opens as HP drops). No separate layer files. No file crossfades. Sub-bass presence increases via filter opening. Stops when HP rises above 55% (hysteresis: triggers at 50%, releases at 55%). Fade out 400 ms on stop. **At 10% HP the filter opens to a ~300 ms perceived pulse period (~200 BPM). This rhythmic urgency is intentional — it signals critical danger. The timbral character (single 4s loop) is the fatigue-controlled element, not the pulse rate** | Single loop file; intensity via bus automation, not repetition | SB |
| `sfx.hp.food_tick` **[ADD]** | Each HP-restored tick during food pickup (AC-18, 3 ticks per food). Does NOT fire during first-food arpeggio; fires only on routine food | A coin dropping into a tip jar — micro-arpeggio saying "you are fed" | Warm plink, 60 ms per tick, 3 ticks at 100 ms intervals. Pitch climbs +2 semitones per tick (root, +2, +4). Rising gesture. Sits −6 dB below `cue.pickup.food` (runtime gain offset in manifest) | ±3% on root note; pitch ascent is deterministic | SB |
| `sfx.projectile.spawn` **[ADD]** | Projectile launches (AC-40). All 4 classes have ranged attacks; projectile needs its own voice | A pea flicked from a spoon | Tiny release tick, ~80 ms. Class-material via runtime `pitch_scale` on AudioStreamPlayer: axe 0.9 (woody), spear 1.1 (metallic thin), bolt 1.3 (crystalline), arrow 1.4 (airy). One enemy generic. Sits −8 dB below melee swing (runtime gain offset) | ±6% pitch; 80 ms retrigger floor per source; max 4 concurrent per source; excess DROP | SB |
| `sfx.projectile.hit_enemy` **[ADD]** | Projectile connects with enemy. `sfx.projectile.impact` only covers wall/miss; enemy hit is a G9 orphan | A fork tapped against crystal | Short bright impact tick, ~60 ms, pitched +4 semitones above wall-impact. Layers at `cue.melee.hit` level (runtime gain offset). Distinct from wall miss | 2 variants; ±4% pitch; 60 ms retrigger floor; throttle 1 per 60 ms; excess DROP | SB |
| `sfx.projectile.impact` **[ADD]** | Projectile expires on wall or obstacle (AC-41 flash is enemy-impact; this is the miss) | A breadstick snapped once | Small dry crack, ~100 ms. −6 dB under melee hits (runtime gain offset) | 2 variants; ±5% pitch; 100 ms retrigger floor; throttle 1 per 100 ms; excess DROP | SB |
| `sfx.hazard.flame` **[ADD]** | Flame jet telegraph → active → fade (AC-39 + PT-15). Hazard legibility is a safety cue | A commercial gas burner lighting — *Spelunky 2* torches cut short | Ignition whump (~150 ms) → low steady hiss loop while active (seamless, separate file `sfx_add_hazard_flame_hiss.wav`) → pressure fall-off (~150 ms). Positional via AudioStreamPlayer2D. Stops when jet deactivates (fade out 200 ms) | ±3% on ignition; 2 ignition variants; loop steady | SB |
| `sfx.void_bridge.warning` **[ADD]** | Void-bridge warning pulse (AC-52: 900 on / 300 off ×3) | A hull groaning under deep water — *Inside*'s underwater pulses pitched into a basement | Three low hollow pulses (60 Hz sine + noise, ~400 ms each) locked to the 900-on/300-off visual cycle. Third carries slightly longer decay | Fixed per pulse; ±2% | SB |
| `sfx.score.tick` **[ADD]** | Score increments / floater spawns (AC-21/22) | Chips stacked at a card table — *Downwell* combo ticks, drier | Tiny dry tick, 60–80 ms. Streak ladder: base pitch rises +2 semitones per streak tier (cap +6 at 3 tiers), resetting when streak breaks. −6 dB below combat SFX (runtime gain offset). **2 variants** | ±4% pitch; 100 ms throttle. Excess events DROP (not queue, not coalesce). Streak ladder pitch resets when streak breaks | SB |
| `sfx.streak.tier` **[ADD]** | Streak tier escalation (max 3 tiers, presentation-only). Layers on top of `sfx.score.tick`, does not replace it | A subtle harmonic shimmer — praise sideways, per G3 | Two-note rising shimmer (sine + harmonic, ~120 ms, −12 dB). Pitch steps up per tier. Fires simultaneously with score tick on tier escalation | Fixed per tier; 3 distinct variants | NT |
| `sfx.floor.enter` **[ADD]** | Floor drop-in completes (AC-63). Marks the room change | A dining room's hush when the doors swing closed | Low whoosh + soft tile-settle dust tick. ~300 ms, once per floor. At F1, folds under `sfx.zone.entry` if within 250 ms (zone stinger takes priority). **If floor.enter is suppressed by fold-under, floor.banner also folds (both suppressed).** At F7/F13/F19, floor.enter fires normally; zone.entry fires separately and does not fold floor.enter (different triggers, >250 ms apart) | ±3% pitch | SB |
| `sfx.floor.banner` **[ADD]** | Floor banner slides in (AC-54). VO floor card carries information; SFX is a physical underline | A menu card placed on the table | Soft card slide, ~180 ms. Folds under `sfx.floor.enter` when within 250 ms | ±3% pitch; 2 variants | SB |
| `sfx.results.enter` **[ADD]** | Results panel slide-in (AC-59) + score count-up (AC-60) | A check presented on a felt tray — paper, a stamp, numbers | Paper slide (~240 ms) + stamp thock (~70 ms) + count ticks (dry click, ~25 ms, at ~8/s during 350 ms count-up). ~400 ms | Ticks ±2% pitch | SB |
| `sfx.new_best` **[ADD]** | New best on results (AC-61 pop + gold flash). Beating personal best is the core roguelike loop | A single warm brass tick — the hall's sideways praise, never fanfare | One warm bell strike, ~200 ms. Fires only on a new personal best | Fixed; ±2% pitch | SB |
| `sfx.gameover.enter` **[ADD]** | Game-over entry (AC-62) | The final cloche seated after close — heavier than title entry | Slow heavy lid settle (80 Hz thump + 500 Hz ring, 200 ms) + long soft decay (~200 ms). ~500 ms. **See §1.E for authoritative game-over audio sequence** | Fixed | SB |
| `sfx.zone.entry` **[ADD]** | Zone boundary crossed (F1/F7/F13/F19) — carries zone identity so music does not have to | Four doors into four rooms | DROWNED VAULTS: wet boom + drip tail. CINDERCRYPT: burner flare + ember ticks. STARVED DEEP: hollow wind across a gap. THE HOLLOW THRONE: marble hush + one deep toll. 1–2 s each, once per crossing. Separate recordings per zone | Fixed per zone | SB |
| `amb.hall_tone` **[ADD]** | Shared room bed under all PLAY floors. The building's breathing. **SB status is a craft judgment.** At −22 dB under music and SFX, the bed is subliminal. Its absence is perceptible only in a silent room. **Cut priority: first NT demotion candidate** if memory budget requires. **Repetition note:** a 60 s loop repeats ~25 times in a full 25-min run. The bed is designed as subliminal presence, not content. **Operator must explicitly accept this repetition or commission a second 60 s loop (`amb_hall_tone_B.wav`) for per-floor alternation with a 4-bar crossfade.** Default: single loop, operator accepts | Air in a large cold room | Quiet air movement + distant washed-out kitchen clatter. Seamless 60 s loop at −22 dB (runtime gain offset). Routes through Ambience sub-bus (§4). Zone tint via per-zone EQ on Ambience bus | Loop; no variation (operator acceptance required for single-loop repetition) | SB (craft judgment; first demotion candidate) |
| `sfx.ui.hover` **[ADD]** | Menu focus moves (AC-06). Desktop expectations require UI feedback | A fingernail tapped once on slate | Sub-40 ms felt tick. **Runtime gain offset: −6 dB relative to `sfx.ui.press`** (not −20 dB). Delivered at UI loudness target (−20 LUFS); the −6 dB offset yields ~−26 LUFS post-bus, audible above music bed but subordinate to press | ±3% pitch | SB |
| `sfx.ui.press` **[ADD]** | Menu activation (AC-07) | A plaque set down in front of a guest | Dry seat-clack with low-mid body. ~90 ms. No runtime gain offset (0 dB on UI bus) | ±2% pitch | SB |
| `sfx.ui.back` **[ADD]** | Modal close / back (AC-13) | A drawer eased shut | Soft downward slide-thud. ~100 ms. No runtime gain offset | ±2% pitch | SB |
| `sfx.pause.in` **[ADD]** | Pause dim in (AC-14) | A kitchen fan switched off — the air settles | Brief low-passed hush sweep. ~150 ms. File: `sfx_add_pause_in.wav` | Fixed | SB |
| `sfx.pause.out` **[ADD]** | Pause dim out / resume (AC-14) | A kitchen fan spinning back up | Forward sweep with opening filter. ~150 ms. **Separate file `sfx_add_pause_out.wav` — NOT a runtime reverse of the in sound.** Godot 4.7 has no reverse playback for AudioStreamOggVorbis | Fixed | SB |
| `sfx.continue.offer` **[ADD]** | Continue prompt appears (AC-25, conditional OQ-15) | A heavy drawer sliding open with a mechanical catch — *Limbo*'s industrial slides, warmer | Mechanical clunk + low synth hum. ~1 s. **One-shot only; no loop.** The countdown is silent; visual panel communicates urgency | ±3% pitch | COND (OQ-15); NT |
| `sfx.exit.open` **[ADD]** | Exit hatch active (AC-45). Pulls the ear toward the way down | A draft through a door to somewhere colder | Low airy tone, positional via AudioStreamPlayer2D, loops while open. Stops when player exits or floor changes | Loop; steady | NT |
| `sfx.generator.idle` **[ADD]** | Generator idle pulse (AC-42). Positional audio finds generators in a crowd | A pilot light's flutter | Very faint rhythmic flicker per generator (max 4, matching rules cap), positional, −24 dB (runtime gain offset). Stops when generator destroyed | Loop; steady | NT |

### D. Explicit silence decisions

| Moment | Why silent | Visual carrier when muted |
|---|---|---|
| HP drain ticks (every integer decrement, ~2/s) | 120/min tick is the fatigue defect this brief refuses. Heartbeat loop owns the clock at thresholds; visual numeral pulse (AC-15) carries high-HP ticks silently | HP numeral pulse, HPStatusLabel text, color grades, vignette pulse |
| HP threshold crossings (50% / 25% / 10%) | No dedicated threshold SFX. 50% marked by heartbeat fade-in. 25% and 10% owned by G3 announcer barks. Upward crossings silent — the hall does not congratulate recovery | Color shift, label change, heartbeat intensity change |
| Hero walk cycle (AC-30) | ~120 steps/min of low-mid mud under every fight. Movement cadence audible through throw rhythm. 32px sprite earns no footfall | Walk animation frames |
| Enemy melee windup | `cue.enemy.telegraph` covers ranged windup. Melee enemies that telegraph visually (lunge, raise weapon) are silent by design — the visual telegraph is the cue. If a melee enemy needs distinct audible windup, commission under `cue.enemy.melee_windup` as addition | Enemy sprite lunge/brighten animation |
| Caption in/out (AC-26/28) | Announcer clip is the audio event. A rustle doubles every line and fights G3's clean isolated vocal delivery. DIS-5 resolved: 5/7 chose silence | Caption band animation |
| Room cleared (enemies down, floor not done) | G3 is explicit: the quiet room is a breath. A repeated bark would cheapen it | None needed |
| Food at full HP | Pickup sound plays (honest), but no waste indicator per G3 | Food pop, HP numeral |
| Pickup bob (AC-46) | 2 px sine motion + amber dot = interactive read. Audio would clutter | Bob animation, amber dot |
| Flame overlay flicker (AC-Flame-L) | 3-frame visual flicker + overlay alpha loop. `sfx.hazard.flame` ignition covers the event; flicker is visual life | Flicker sprite, overlay alpha |
| Attract reel | Dimmed visual ghost behind logo. Title track carries mood | Attract visuals |
| Reduce Motion active | All motion-linked SFX remain. Hitstop remains. No shake-linked SFX exist. Visual substitutes per G9 §Accessibility | Per G9 accessibility spec |

### E. G2 state-machine audible-moment walk

| Transition | Audio event | Silence rationale (if silent) |
|---|---|---|
| boot → title | `cue.title.enter` + Track 1 fade-in | — |
| title → class_select | Silent; Track 1 continues | Visual transition; WHO SITS TONIGHT? VO fires on class-select entry per G3 |
| title → settings | `sfx.ui.press`; Track 1 continues | Settings accessible from title and pause |
| settings → title | `sfx.ui.back`; Track 1 continues | Visual transition |
| class_select → title (back-out) | Silent; Track 1 continues | Visual transition |
| class_select → play | `cue.class.confirm` + crossfade to Track 2 (300 ms). New game always starts at floor 1 | — |
| play ↔ pause | `sfx.pause.in` / `sfx.pause.out`; VO queue freezes per G3; **current gameplay track ducks −20 dB** (does NOT switch to Track 1). If an announcer bark is playing when PAUSE is entered, the bark is hard-stopped (not faded). Queue freezes. On resume, queue resumes from next unplayed bark; interrupted bark is NOT replayed | — |
| play ↔ settings (from pause) | Silent; current track remains ducked −20 dB | Settings is a pause sub-state |
| settings → pause (back) | `sfx.ui.back`; current track remains ducked | — |
| play → floor_results | `cue.floor.cleared` (SIG-5) + FLOOR CLEARED. VO + crossfade to Track 1 (300 ms) | — |
| floor_results → play (next floor 2–12) | `sfx.floor.enter` + `sfx.floor.banner` (folds if within 250 ms) + crossfade to Track 2 (300 ms) | — |
| floor_results → play (next floor 13+) | `sfx.floor.enter` + `sfx.floor.banner` + crossfade to Track 3 (300 ms) | — |
| floor_results → campaign_results (all floors cleared) | `sfx.results.enter` + Track 1 continues (already playing; no additional music transition) | — |
| campaign_results → title | Silent; Track 1 continues | Visual transition |
| play → game_over | **Authoritative sequence:** `cue.hero.death` fires → Music bus ducks to −12 dB (30 ms attack) → Music bus ramps from −12 dB to −30 dB over 500 ms (via `request_ramped_duck`, see §4 API) → `sfx.gameover.enter` fires at hero.death onset + 300 ms → `amb.hall_tone` stops (300 ms fade out) starting at gameover.enter onset → 200 ms gap after gameover.enter completes → Track 1 fades in over 500 ms (Track 2/3 crossfade to Track 1 is this 500 ms fade, NOT a 300 ms crossfade). **The hero-death ramp (−12→−30 dB) and Track 1 fade-in are sequential, not simultaneous: the ramp completes first, then Track 1 begins fading in during the gap.** See §2 crossfade matrix for authoritative timing | — |
| game_over → continue_offer | `sfx.continue.offer` (COND OQ-15). **Music: Track 1 continues (already playing from game-over sequence). No music transition.** | — |
| continue_offer → play | `cue.hero.spawn` (respawn per G3) + gameplay track fade-in (300 ms). **Floor-dependent: Track 2 if continuing on floors 1–12; Track 3 if continuing on floors 13+** | — |
| continue_offer → title | Silent; Track 1 continues (then fades out on title idle per attract logic) | Visual transition |
| Zone boundary (F1/F7/F13/F19) | `sfx.zone.entry` + **Ambience bus EQ tween over 1 s** to new zone settings (NOT a separate ambience bed crossfade — the shared `amb.hall_tone` bed receives per-zone EQ via the Ambience bus `AudioEffectEQ`, tweened over 1 s). At F1, zone entry takes priority over `sfx.floor.enter` if within 250 ms (both floor.enter and floor.banner fold) | — |
| Floor 13 crossfade (from play) | Track 2 → Track 3 over 8 s on `sfx.zone.entry`, with 1 s midpoint dip to −30 dB on both tracks to mask detuning clash. Tempo clash acknowledged: 90 BPM and 80 BPM overlap for 8 s. The 1 s midpoint dip minimizes audible beating. The tempo difference is a feature (dread intensifies), not a defect | — |
| Floor 13 restart (from floor_results) | Track 1 → Track 3 direct crossfade (300 ms) — no 8 s zone-entry crossfade on restart | — |

### F. Unified enemy family table — commission gate OQ-9

**8 families (4 melee, 4 ranged).** Reconciles row 06 (death timbres) and row 08 (telegraph pitches). Verify against G2's entity table before commissioning. If G2 defines additional families or different names, update this table and re-commission affected cues.

| Family | Type | Death timbre (row 06) | Telegraph pitch center (row 08) | Death files | Telegraph files |
|---|---|---|---|---|---|
| Scullion | Melee | Airy pop + wobble | — (melee, no telegraph) | `sfx_cue_enemy_death_scullion_A/B.wav` | — |
| Cleaver Brute | Melee | Heavy thud + clatter | — (melee, no telegraph) | `sfx_cue_enemy_death_brute_A/B.wav` | — |
| Broiler | Melee | Steam hiss + clang | — (melee, no telegraph) | `sfx_cue_enemy_death_broiler_A/B.wav` | — |
| Carver | Melee | Deep boom + long ring (~400 ms) | — (melee, no telegraph) | `sfx_cue_enemy_death_carver_A/B.wav` | — |
| Lobber | Ranged | Ceramic shatter + low gurgle | 300→600 Hz | `sfx_cue_enemy_death_lobber_A/B.wav` | `sfx_cue_enemy_telegraph_lobber.wav` |
| Sorcerer | Ranged | Glass crackle + descending whine | 500→1100 Hz | `sfx_cue_enemy_death_sorcerer_A/B.wav` | `sfx_cue_enemy_telegraph_sorcerer.wav` |
| Porter | Ranged | Three ceramic micro-ticks | 250→500 Hz | `sfx_cue_enemy_death_porter_A/B.wav` | `sfx_cue_enemy_telegraph_porter.wav` |
| Maître d' | Ranged | Glass tinkle | 700→1400 Hz | `sfx_cue_enemy_death_maitre_A/B.wav` | `sfx_cue_enemy_telegraph_maitre.wav` |

**Telegraph recordings: 4 total** (one per ranged family: Lobber, Sorcerer, Porter, Maître d'). No "gap-fill" recordings.

**OQ-9 gate:** No commissioning of death or telegraph cues until this table is confirmed against G2.

---

## 2. Music brief

Three tracks — **LOCKED** (DIS-4: 4/7 seats chose 3 tracks with gameplay split). The music lives inside G4's "After Service" palette and G3's dry-famished register: cold, restrained, period-1985 analog synth textures, no heroism, no cozy warmth, no chiptune arpeggio overload.

### Track 1 — "After Service" (Title / Menus / Settings / Results / Game Over / Continue)

- **Mood:** The hall waiting. Cold openness, patient menace.
- **Tempo:** 64 BPM (locked).
- **Time signature:** 4/4.
- **Key:** D minor.
- **Bar count:** 32 bars.
- **Loop length:** 120.0 s (32 × 4 × 60/64).
- **Instrumentation hints:** Analog synth pad drone; distant FM bell strike every 16 bars; sub-bass sine. No drums, no strings, no reverb tail exceeding 2 s. Mono-compatible.
- **Reference:** Sparse synth dread of *Papers, Please* + hypnotic stillness of *Threes*.
- **Anti-reference:** No title fanfare. No bright arcade jingle. No cozy lo-fi. No *Hades* crescendo.
- **Seamless-loop contract:** Entire Ogg file IS the loop (`AudioStreamOggVorbis.loop = true`). Identical 8-bar drone at start and end. No intro, no outro, no baked reverb tail. WAV (verification master) + Ogg q6 (runtime). Loop point verified at zero-crossing.
- **Where it plays:** TITLE, CLASS_SELECT, SETTINGS (from title), FLOOR_RESULTS, CAMPAIGN_RESULTS, GAME_OVER, CONTINUE_OFFER. PAUSE is NOT listed — current gameplay track ducks −20 dB.
- **Where it ducks:** §5 duck table is authoritative.

### Track 2 — "First Service" (Gameplay, Floors 1–12)

- **Mood:** Relentless, clean, mechanical. Dry-famished warmth — amber against plum stone. Not epic; service.
- **Tempo:** 90 BPM (locked).
- **Time signature:** 4/4.
- **Key:** C minor.
- **Bar count:** 48 bars.
- **Loop length:** 128.0 s (48 × 4 × 60/90).
- **Instrumentation hints:** Low bass-synth pulse on the downbeat; **muted lid-tap percussion on beat 2 only** (no snare/clap on beat 4 — the backbeat is a single muted tap, not a clap, preserving G3's dry-famished register); low drone pad. No guitars, no orchestral stabs, no chiptune arpeggio overload. Mono-compatible.
- **Reference:** Looping industrial ambience of *Quake* with distortion/aggression removed. Melancholy loop of *Papers, Please* main theme.
- **Anti-reference:** No *Hades* combat tracks. No *Enter the Gungeon* chip-density. No Gauntlet imitation.
- **Seamless-loop contract:** Entire file is the loop. No intro, no outro, no reverb tail. WAV + Ogg q6. Zero-crossing verified.
- **Where it plays:** PLAY state, floors 1–12. Crossfades to Track 3 over 8 s at floor 13 zone entry.
- **Where it ducks:** §5 duck table.

### Track 3 — "The Deep Tables" (Gameplay, Floors 13–24)

- **Mood:** Final course. The hall hungrier. Same instruments, detuned +15 cents, added slow dissonant intervals (tritone, minor 9th). Dread, not action.
- **Tempo:** 80 BPM (locked).
- **Time signature:** 4/4.
- **Key:** C minor, detuned +15 cents.
- **Bar count:** 50 bars.
- **Loop length:** 150.0 s (50 × 4 × 60/80).
- **Instrumentation hints:** Track 2 palette + bowed crotales (zone_throne timbre); slow filter sweep on pad (4-bar period). Sub-bass sine more prominent. **Muted lid-tap on beat 2 only, same as Track 2.** Mono-compatible.
- **Reference:** *Dark Souls* Firelink Shrine (menace in stillness) + *Silent Hill 2* Room of Angel (detuned warmth).
- **Anti-reference:** No *Doom* aggression. No triumph. No release.
- **Detuning delivery instruction:** Composer's DAW project set to detune entire track +15 cents. **Verification:** sustained root note in delivered WAV reads +15 cents ±2 cents in a tuner plugin. Document tuning method in delivery notes.
- **Seamless-loop contract:** Entire file is the loop. WAV + Ogg q6. Zero-crossing verified.
- **Where it plays:** PLAY state, floors 13–24. Triggered by `sfx.zone.entry` at F13 with 8 s crossfade from Track 2 (midpoint dip). On restart from floor_results at floor 13+, Track 1 → Track 3 direct crossfade (300 ms).
- **Where it ducks:** §5 duck table. Additionally ducks −3 dB under F19 zone-entry announcer bark (see §5).

### Crossfade and transition matrix — AUTHORITATIVE

| From → To | Technique | Duration |
|---|---|---|
| Track 1 → Track 2 (class_select → play, floors 1–12) | Crossfade | 300 ms |
| Track 1 → Track 2 (continue_offer → play, floors 1–12) | Crossfade | 300 ms |
| Track 1 → Track 3 (continue_offer → play, floors 13+) | Crossfade | 300 ms |
| Track 2/3 → Track 1 (play → floor_results) | Crossfade | 300 ms |
| Track 2 → Track 3 (floor 13 zone entry from play) | Crossfade with 1 s midpoint dip to −30 dB on both | 8 s total |
| Track 1 → Track 3 (floor_results → play, floors 13+) | Crossfade | 300 ms |
| Track 2/3 → Track 1 (play → game_over) | **Ramp + gap + fade (NOT a simple crossfade):** Music bus ducks −12 dB (30 ms attack) → ramps to −30 dB over 500 ms → 200 ms gap → Track 1 fades in over 500 ms | ~1300 ms total |
| Track 1 → Track 1 (game_over → continue_offer) | No transition; Track 1 continues | — |
| Track 1 → Track 2/3 (continue_offer → play) | Crossfade | 300 ms |

**Campaign_results path:** `play → floor_results` crossfades to Track 1. `floor_results → campaign_results` — Track 1 already playing; no transition.

### Ducking implementation

Ducking is scripted bus automation via `AudioDirector` autoload — tweening `AudioServer.set_bus_volume_db()` over stated attack and release times (cubic-out). Godot 4.7 has no native sidechain compression sends; all ducking is programmatic bus volume automation. Attack times are ≥30 ms (above Godot's ~21 ms buffer latency at 1024 samples, 48 kHz). Duck timing tolerance: ±10 ms of spec (accounts for buffer quantization; measured via `AudioServer.get_time_since_last_mix()` at duck onset and release). See §5 for the authoritative ducking state machine.

---

## 3. VO needs

**Deferred to G3 — DIS-2 resolved (6/7).** The announcer pipeline — voice recording, formant-synth processing, clip enumeration, bark timing, phonetic guide, string keys — is owned by the G3 voice bible. G11 does not commission, re-specify, or duplicate any aspect of the announcer asset pipeline.

**G11's VO-dependent requirements (binding on whatever G3 delivers):**

- **Bus assignment:** All announcer audio routes through the `Announcer` bus.
- **Loudness target:** −16 LUFS integrated, −2 dBTP (asset-level, pre-bus gain).
- **Ducking:** Announcer barks duck Music −10 dB and SFX −6 dB (50 ms attack, 500 ms + caption-hold release). **Caption-hold duration:** the release timer begins 500 ms after the bark's audio ends OR when the caption band begins sliding out (AC-28), whichever is later. Announcer is never ducked by any other event.
- **CRIT exemption:** The SFX duck applies to the `SFX` bus only. The `CritSFX` bus is a **sibling of SFX under Master** (not a child), so SFX bus volume changes do not affect it. When a CRIT SFX is playing, the announcer SFX duck has no effect on it.
- **Pause behavior:** If a bark is playing when PAUSE is entered, the bark is **hard-stopped** (not faded). Queue freezes. On resume, queue resumes from next unplayed bark; interrupted bark is NOT replayed.
- **Runtime concatenation:** If G3 specifies slotted class/numeral concatenation, G10 implements it in code. Concatenated clips play sequentially with 50 ms gap, normalized to −16 LUFS, with 5 ms fade-in/out per clip. Composite ≤3.0 s.
- **First-food ordering:** The G3 "FOOD." bark fires 500 ms after first-food arpeggio onset (50 ms after arpeggio completes). First-food arpeggio routes through CritSFX and is not ducked by the announcer SFX duck. On routine food pickups, the FOOD bark fires at pickup onset with standard ducking.

**If G3's frozen output is not yet available:** G11's ducking and loudness rules still apply. G10 implements the `Announcer` bus and ducking logic against the G3 specification when it arrives. No G11 artifact blocks on G3 delivery.

**NG+ audio: out of scope.** If NG+ ships, audio follows the same tracks with bus-level pitch shift (−2 semitones) on **Music and SFX buses only** (Announcer and UI buses excluded — announcer voice character must not shift, UI feedback must remain crisp). Additional reverb send applied at the AudioDirector level. No new assets commissioned by G11 for NG+.

---

## 4. Middleware decision and runtime architecture

**Locked-engine native path: Godot 4.7 native audio only.** No middleware, no addons, no FMOD, no Wwise. Rationale: operator constraints lock the engine to Godot and G9 mandates engine-native rails only. The SFX count (~80 base files with variants) and music tracks (3) fit comfortably in Godot's native bus architecture. If an addon is ever proposed, it must be declared in G6 with a license and reason; this brief does not require one.

### Bus layout

**Bus layout artifact:** `res://default_bus_layout.tres`, referenced via the `audio/buses/default_bus_layout` project setting in `project.godot`. `AudioDirector` autoload verifies bus count and names at boot via `AudioServer.get_bus_count()` and `AudioServer.get_bus_name()`; logs error if any expected bus is missing.

```
Master (0 dB)
├── Music (−12 dB)
├── Announcer (0 dB)
├── UI (0 dB)
├── CritSFX (−6 dB)          ← SIBLING of SFX, NOT child. Exempt from SFX-bus ducks.
└── SFX (−6 dB)
    ├── SFX_Class (0 dB rel. SFX)
    │   ├── SFX_ConfirmEQ_Warrior   (AudioEffectEQ, fixed at boot)
    │   ├── SFX_ConfirmEQ_Valkyrie  (AudioEffectEQ, fixed at boot)
    │   ├── SFX_ConfirmEQ_Wizard    (AudioEffectEQ, fixed at boot)
    │   └── SFX_ConfirmEQ_Elf       (AudioEffectEQ, fixed at boot)
    ├── Heartbeat (0 dB rel. SFX)   ← Dedicated bus for heartbeat filter automation
    │   └── AudioEffectFilter (low-pass, automated by AudioDirector per HP threshold)
    └── Ambience (0 dB rel. SFX)    ← Per-zone EQ; amb.hall_tone + cue.enemy.spawn
        └── AudioEffectEQ (tweened 1 s on zone entry)
```

**Critical topology note:** `CritSFX` is a direct child of `Master`, NOT a child of `SFX`. This ensures that ducking the `SFX` bus does not affect `CritSFX` — the exemption is structural, not programmatic.

**Per-class EQ routing:** Only `cue.class.confirm` routes through `SFX_ConfirmEQ_<class>` sub-buses. These sub-buses have fixed `AudioEffectEQ` parameters set at boot and never change. `cue.class.confirm` fires exclusively in `class_select` state — no overlap with combat cues. `cue.melee.swing` and `sfx.projectile.spawn` differentiate by class via runtime `pitch_scale` on the `AudioStreamPlayer` (a supported property), routed through the main `SFX` bus. This avoids the problem of a single sub-bus holding contradictory effect states for overlapping cues.

**Heartbeat bus:** The `Heartbeat` sub-bus (child of `SFX`) has an `AudioEffectFilter` (low-pass) in its effect chain. `AudioDirector` automates the filter cutoff and bus volume per HP threshold. `sfx.hp.heartbeat` routes through this bus exclusively. The `AudioStreamPlayer` playing the heartbeat loop has no filter — the filter lives on the bus.

**Ambience bus routing:** Both `amb.hall_tone` and `cue.enemy.spawn` route through the `Ambience` sub-bus. The `Ambience` bus has an `AudioEffectEQ` whose parameters are tweened over 1 s on zone entry. All other SFX route through `SFX` or `CritSFX` and are unaffected by zone EQ.

| Zone | Ambience EQ settings |
|---|---|
| DROWNED VAULTS | Low-shelf +2 dB @200 Hz; high-cut @4 kHz (wetter) |
| CINDERCRYPT | Peak +3 dB @2 kHz, Q=1 (brighter) |
| STARVED DEEP | High-shelf −3 dB @3 kHz (drier, thinner) |
| THE HOLLOW THRONE | Peak +2 dB @400 Hz, Q=0.7 (heavier, darker) |

### AudioDirector autoload

- **Autoload name:** `AudioDirector`
- **Initialization order:** After `StateMachine`, before any scene that plays audio
- **API:**
  - `play_sfx(key: StringName, position: Vector2 = Vector2.ZERO, class_id: StringName = &"") -> void` — plays SFX by manifest key; if position ≠ ZERO, routes through AudioStreamPlayer2D; if class_id is set and cue has class-specific routing, routes to class sub-bus
  - `play_music(track: int) -> void` — track 1/2/3; handles crossfade per §2 matrix
  - `stop_music(fade_ms: int = 300) -> void`
  - `request_duck(trigger_id: StringName, priority: int, bus: StringName, depth_db: float, attack_ms: int, release_ms: int) -> StringName` — returns a duck handle; when multiple ducks overlap on the same bus, deepest active duck wins; priority stack: hero_death(100) > generator_destroyed(90) > potion_used(80) > floor_clear(70) > announcer_bark(60) > first_food(50) > hero_hurt(40) > zone_entry_bark(30)
  - `request_ramped_duck(handle: StringName, from_db: float, to_db: float, ramp_ms: int) -> void` — ramps an existing duck from one depth to another over ramp_ms. Used for hero death (−12 dB → −30 dB over 500 ms)
  - `release_duck(handle: StringName) -> void` — releases a duck; bus returns to next-deepest active duck or default
  - `duck_sfx(amount_db: float, attack_ms: int, release_ms: int) -> StringName` — announcer-triggered SFX duck; **CritSFX bus is a sibling of SFX, not affected**
  - `set_user_bus_volume(bus: StringName, db: float) -> void` — persistent user slider; stored separately from transient duck offsets
  - `get_effective_bus_volume(bus: StringName) -> float` — returns user_volume + deepest active duck offset
  - `mute_all(enabled: bool) -> void` — sets Master to −80 dB
  - `stop_loop(key: StringName, fade_ms: int = 300) -> void` — stops a continuous loop with fade
  - `set_heartbeat_intensity(hp_percent: float) -> void` — automates Heartbeat bus volume and filter cutoff per HP threshold
- **State ownership:** Owns current music track, duck state machine (priority stack), active voice pool, loop lifecycle. Reads `StateMachine` for state transitions. Reads `Tunables` for all audio-related juice constants.

### Manual voice pool

**Godot 4.7 has no `voice_priority` property on AudioStreamPlayer.** The `AudioDirector` maintains a manual voice pool.

**Pool scope:** The 32-voice pool covers **one-shot SFX and UI sounds only.** The following have dedicated `AudioStreamPlayer` nodes outside the pool:
- Music: 3 dedicated AudioStreamPlayer nodes (one per track, only one active at a time)
- Announcer: 1 dedicated AudioStreamPlayer
- Continuous loops: 1 heartbeat, 1 hall_tone, 1 flame hiss, 1 exit open, up to 4 generator idle = max 8 dedicated loop nodes
- **Total dedicated: max 12. Pool: 32 one-shot. Total max: 44 AudioStreamPlayer nodes.**

- **Pool cap:** 32 active one-shot `AudioStreamPlayer`/`AudioStreamPlayer2D` nodes.
- **Per-voice tracking:** Each active voice records: `key`, `priority` (0–255, from manifest), `start_time`, `node_ref`.
- **Steal policy:** When pool is full and a new sound requests playback, steal the lowest-priority non-CRIT voice (priority < 255). CRIT voices (priority 255) are never stolen. If all 32 are CRIT (impossible in normal play), drop the new sound.
- **Priority assignments (manifest-level):**
  - CRIT SFX (generator destroyed, floor cleared, potion used, hero death, first-food): 255 — never stolen
  - Signature SFX (hero hurt, enemy telegraph): 200
  - Routine SFX (melee swing/hit, enemy spawn/death, pickups, score tick, projectiles): 100
  - UI sounds: 80
  - Ambient loops (in pool if one-shot variants): 50

### AudioStreamPlayer2D parameters

- **Listener:** Camera2D (default Godot 2D audio listener)
- **Max distance:** 800 px (roughly half-screen at 1080p)
- **Attenuation:** Godot built-in linear attenuation, −12 dB at max distance
- **Panning strength:** 0.6 (subtle, to avoid hard-panning in top-down)
- **Used for:** `cue.enemy.spawn`, `cue.enemy.death`, `cue.enemy.telegraph`, `sfx.hazard.flame`, `sfx.void_bridge.warning`, `sfx.exit.open`, `sfx.generator.idle`
- **NOT used for:** hero sounds, UI, music, announcer

### Audio memory budget

All audio is preloaded. Godot 4.7 loads `AudioStreamOggVorbis` resources fully into memory by default. `ResourceLoader.load_threaded_request()` loads asynchronously (avoids boot stalls) but the full file resides in memory once loaded. Godot 4.7 does support streamed playback of Ogg Vorbis via `AudioStreamOggVorbis` with appropriate configuration; however, for this brief's file sizes (1–2 s SFX, 120–150 s music), full preload is chosen for simplicity and predictable memory use.

| Asset type | Files | Size per file | Total | Load mode |
|---|---|---|---|---|
| SFX | ~80 base files (Ogg q6, mono, 0.04–1.5s avg) | ~20 KB | ~1.6 MB | Preload |
| VO (G3-owned) | ~70 clips (Ogg q6, mono, ~2s avg) | ~44 KB | ~3 MB | Preload |
| Music | 3 tracks (Ogg q6, stereo, 120–150s) | ~3.6 MB | ~10.8 MB | Preload (async) |
| **Total audio memory** | | | **~15.4 MB** | Min-spec 8 GB: <0.2% RAM |

### Audio device loss and recovery

Godot 4.7 does not provide a standard audio device-change signal. `AudioDirector` polls `AudioServer.get_output_device_list()` on a 2-second timer; if the active device disappears or count drops to zero, device loss is detected. On loss: shows G3 `error.audio_lost` string once via one-shot label, sets `device_lost: bool`. Gameplay continues silently with full visual fallbacks (§5). On reconnect: audio resumes without restart; existing streams continue from current position. If the platform provides no reliable device list, the mute playthrough acceptance test (§9) validates the silent-continuation path.

---

## 5. Mix policy

### Bus hierarchy and default levels

| Bus | Default gain | Role | Asset loudness (delivery) | Post-bus output |
|---|---|---|---|---|
| `Master` | 0 dB | Final output | — | Project target: −14 LUFS integrated, −1 dBTP |
| `UI` | 0 dB | Desktop feedback | −20 LUFS, −4 dBTP | −20 LUFS |
| `Announcer` | 0 dB | Narrative anchor; never ducked (except PAUSE) | −16 LUFS, −2 dBTP (G3-owned) | −16 LUFS |
| `CritSFX` | −6 dB | CRIT-priority cues; exempt from SFX ducks | −18 LUFS, −1 dBTP | −24 LUFS |
| `SFX` | −6 dB | World and gameplay sounds | −18 LUFS, −1 dBTP | −24 LUFS |
| `Music` | −12 dB | Bed; always subordinate | −22 LUFS, −6 dBTP | −34 LUFS |

**Level hierarchy (by post-bus output): Announcer > UI > SFX = CritSFX > Music.**

**Loudness convention:** LUFS targets in "Asset loudness" are delivery specifications. Bus gains are the mix decision on top. Post-bus levels are expected results. Master −14 LUFS is the project delivery target for the final mixed output — not the arithmetic sum of post-bus levels (which overlap in time). Relative dB instructions throughout §1 are runtime gain offsets in the manifest, not delivery normalization differences. All SFX assets deliver at −18 LUFS ±1; UI at −20 LUFS ±1; relative levels achieved at runtime via per-cue gain offsets in `sfx_manifest.json`.

**Absolute level reference for runtime offsets:** `runtime_gain_db` is relative to the cue's bus default gain. Example: `sfx.ui.hover` has `runtime_gain_db: -6` on the UI bus (0 dB default) → effective bus-level gain = −6 dB → post-bus output ≈ −26 LUFS. `sfx.ui.press` has `runtime_gain_db: 0` → post-bus output = −20 LUFS. `amb.hall_tone` has `runtime_gain_db: -16` on the SFX bus (−6 dB default) → effective gain = −22 dB → post-bus ≈ −40 LUFS. `sfx.generator.idle` has `runtime_gain_db: -18` on the SFX bus → effective = −24 dB → post-bus ≈ −42 LUFS. These offsets do not stack with bus gains — they are applied as bus-level adjustments via `AudioServer.set_bus_volume_db()` on a per-playback basis using dedicated sub-buses or per-stream gain.

### Settings integration

Four persistent sliders mapping to buses:
- Music → `Music` bus gain
- Effects → `SFX` bus gain (includes `SFX_Class`, `Heartbeat`, `Ambience` sub-buses; does NOT include `CritSFX` — effects slider controls CritSFX via separate mapping)
- Announcer → `Announcer` bus gain
- Mute All → sets `Master` to −80 dB

**Persistent user volume is separate from transient duck offsets.** `set_user_bus_volume` sets the slider; `get_effective_bus_volume` returns slider + deepest active duck. Ducking tweens the offset, not the slider.

### Ducking state machine — AUTHORITATIVE

**Rules:**
1. **UI is never ducked** by any SFX, music, or announcer event. UI bus is exempt from PAUSE hush.
2. **Announcer is never ducked** by any SFX or music event. PAUSE is a state-level override (lowers Music, SFX, Announcer; UI remains 0 dB).
3. **CRIT SFX are exempt from announcer-triggered SFX ducking.** `CritSFX` is a sibling of `SFX` under `Master`, not a child. SFX bus volume changes do not propagate to CritSFX. First-food (`cue.pickup.food` first-food variant) routes through CritSFX.
4. **When multiple ducks overlap, deepest active duck wins.** Release: bus returns to next-deepest or default. Priority: hero death > generator destroyed > potion used > floor clear > announcer bark > first food > hero hurt > zone entry bark.
5. **Hero hurt has a 500 ms inter-duck interval.** Prevents constant pumping under swarm damage.
6. **Routine SFX does NOT duck music.** Only signature events, hero death, hero hurt, and announcer barks trigger music ducks.

| Trigger | Music duck | SFX duck | Attack | Release | Notes |
|---|---|---|---|---|---|
| SIG-2 generator destroyed | −12 dB | — | 30 ms | 800 ms | CRIT; routes through CritSFX |
| SIG-3 first food | −8 dB | — | 30 ms | 600 ms | CRIT; routes through CritSFX; FOOD bark fires 500 ms after arpeggio onset |
| SIG-4 potion used | −12 dB | — | 30 ms | 1000 ms | COND (OQ-11); CRIT; routes through CritSFX |
| SIG-5 floor clear | −6 dB | — | 50 ms | 1500 ms | CRIT; routes through CritSFX |
| Hero death | −12 dB initial, ramping to −30 dB over 500 ms | — | 30 ms | 2500 ms (from release point) | CRIT; routes through CritSFX; ramp via `request_ramped_duck` |
| Announcer bark | −10 dB | −6 dB (SFX bus only) | 50 ms | 500 ms + caption hold | CritSFX exempt (sibling bus) |
| Announcer bark at F19 (Track 3 active) | −13 dB (−10 standard + −3 additional) | −6 dB | 50 ms | 500 ms + caption hold | The F19 zone-entry bark is a G3 announcer clip routed through Announcer bus. The −3 dB additional duck applies only when Track 3 is active, on top of the standard −10 dB announcer music duck |
| Hero hurt (AC-33) | −6 dB | — | 30 ms | 300 ms | 500 ms inter-duck interval |
| PAUSE (state override) | −20 dB (current track) | −20 dB | 80 ms | 80 ms | UI: 0 dB. Announcer: −80 dB (queue frozen). Mid-bark: hard-stopped |

**Caption-hold definition:** The announcer duck release timer begins 500 ms after the bark's audio ends OR when the caption band begins sliding out (AC-28), whichever is later. This ensures the duck holds through the full caption visibility period.

### Mute / audio-off behavior (accessibility floor — G2 §8)

**The game must be fully playable with all audio muted.** Every critical event has a visual fallback:

| Event | Visual fallback when muted |
|---|---|
| SIG-1 HP drain | HP numeral pulse (AC-15) + HPStatusLabel + color grades + vignette pulse |
| SIG-2 generator destroyed | Hitstop + camera zoom punch + PT-06 particle ring + caption |
| SIG-3 first food | HP green tint + HP tick-up floaters + PT-07 glow + caption |
| SIG-4 potion used | Hitstop + FlashRect + ClassTintRect bloom + PT-09 smoke + caption |
| SIG-5 floor clear | Hitstop + OverlayRect darken + gold border + banner + camera drift + score countup |
| Hero death | Vignette + hero collapse sprite + screen shake + game-over panel |
| Hero hurt | Red flash + HP numeral pop + screen-edge flash (AC-33) |
| Melee swing | Hero lunge animation (AC-32) + weapon trail |
| Melee hit | Hitstop + enemy flash (AC-34) + knockback (AC-35) + PT-03 |
| Score tick | Score floater (AC-21/22) + streak label |
| Class confirm | AC-10 back-out + AC-11 glint + haptic |
| UI hover/press/back | Menu focus highlight + button press animation |
| Enemy telegraph | EnemySprite modulate brighten (AC-37) |
| Enemy spawn | Spawn scale pop + smoke puff (PT-02) |
| Enemy death | Collapse scale + smoke/spark particles (PT-05) |
| Pickups (all) | Scale pop + glow + icon reveal + caption |
| Door unlock | Door animation + smoke (PT-12) + key icon pop |
| Announcer barks | Captions always render (white on #000000CC, 2 s min hold per G3) |
| Flame jet | Telegraph flicker (AC-39) + HeroFlameOverlay |
| Void bridge | Overlay alpha pulse (AC-52) |
| HP heartbeat | HP numeral pulse + HPStatusLabel + color grades + vignette |
| Projectile spawn/hit/impact | Projectile sprite flash + enemy flash on hit + wall spark on impact |

**Mute All does not pause gameplay or hide captions.**

---

## 6. Fatigue audit

The five most-frequent sounds by G9 trigger frequency, with the variation policy that stops each from grating by minute ten.

| Rank | Key | Expected plays/min (peak) | Fatigue policy |
|---|---|---|---|
| 1 | `cue.melee.swing` | ~60–70 | 3 round-robin variants; ±6% pitch; ±1.5 dB gain; 80 ms retrigger floor; class-specific pitch_scale (4 timbres). 12 distinct combinations before repeat |
| 2 | `cue.melee.hit` | ~40–50 | 3 round-robin variants; ±5% pitch; killing blow +2 dB; 100 ms throttle. Strict round-robin. Excess DROP |
| 3 | `sfx.score.tick` | ~40–45 | 2 variants; ±4% pitch; 100 ms throttle; streak ladder +2 semitones/tier (max +6). −6 dB below combat. Excess DROP |
| 4 | `cue.enemy.spawn` | ~30 | ±5% pitch; 2 pop variants; per-zone EQ via Ambience bus. Positional attenuation: distant spawns quieter |
| 5 | `cue.enemy.death` | ~25–30 | 2 variants per family × 8 families = 16 textures; ±6% pitch; 80 ms throttle. Excess DROP. Visual particles carry flourish |

**Additional fatigue-tracked sounds:**

| Key | Expected plays/min | Fatigue policy |
|---|---|---|
| `sfx.projectile.spawn` | ~20–30 | ±6% pitch; 80 ms retrigger floor per source; max 4 concurrent per source; excess DROP. Low risk: 80 ms, low volume |
| `sfx.projectile.hit_enemy` | ~15–25 | 2 variants; ±4% pitch; 60 ms retrigger floor; excess DROP |
| `sfx.projectile.impact` | ~10–15 | 2 variants; ±5% pitch; 100 ms retrigger floor; excess DROP |
| `sfx.hp.food_tick` | ~6–9 | ±3% pitch; deterministic ascending pitch; 60 ms duration. Low risk |
| `sfx.ui.hover` | ~20–30 (menu) | ±3% pitch; sub-40 ms at −26 LUFS. Low risk |
| `sfx.hazard.flame` (loop) | Continuous while active | Positional, masked by combat. Stops on jet deactivate. Fatigue review N/A |
| `sfx.hp.heartbeat` (loop) | Continuous below 50% HP | Single 4s loop; intensity via bus automation. Stops above 55% HP. At 10% HP, filter opens to ~300 ms pulse (~200 BPM) — intentional urgency signal, not a steady-state bed |
| `amb.hall_tone` (loop) | Continuous during PLAY | 60 s loop at −22 dB. Masked by music and SFX. Subliminal presence. **Repeats ~25 times per full run. Operator must accept single-loop repetition or commission loop B for alternation (§1.C).** Default: single loop, operator accepts |
| `sfx.exit.open` (loop) | Continuous while exit active | NT; positional. Fatigue review N/A. Stops on exit/floor change |
| `sfx.generator.idle` (loop) | Continuous per generator (max 4) | NT; positional at −24 dB. Fatigue review N/A. Stops when destroyed |

**Global fatigue guard.** No single one-shot SFX may play more than once per 30 ms unless it is a continuous loop. All high-frequency one-shots are <250 ms, dry, and variation-heavy. Signature sounds (generator destroyed, floor cleared, potion used, hero death) are fixed-pitch by design — they fire rarely enough (max 24, 24, conditional, 1 per run) that variation would dilute identity.

---

## 7. Commission package notes

### SFX delivery

- **Source format:** WAV, 48 kHz, 24-bit, mono.
- **Runtime format:** Ogg Vorbis q6 (Godot import quality 0.6). Ogg q6 chosen over q5 for better loop-point preservation; over MP3 because Godot's native Ogg support avoids encoder-delay/padding issues that break seamless loops.
- **Edit:** Trim silence; 5 ms fade-out on all one-shots. No reverb tail unless explicitly called for. Loop files seamless at sample level — entire file is the loop (`AudioStreamOggVorbis.loop = true`).
- **Loudness (asset-level delivery targets):**
  - SFX: Peak ≤ −6 dBFS; integrated −18 LUFS ±1; true peak ≤ −1 dBTP
  - UI: Peak ≤ −6 dBFS; integrated −20 LUFS ±1; true peak ≤ −4 dBTP
  - All assets deliver at their specified LUFS target. Relative levels achieved at runtime via per-cue gain offsets in manifest.
- **Naming:** `sfx_<event_key>.wav` for G9 integration points; `sfx_add_<event>.wav` for additions.
  - Hero cues: `sfx_cue_hero_spawn.wav`, `sfx_cue_hero_death.wav`, `sfx_cue_hero_hurt_A.wav`, `sfx_cue_hero_hurt_B.wav`
  - Variant suffixes: `_A.wav`, `_B.wav`, `_C.wav` for round-robin
  - Per-class files ONLY for `cue.potion.used`: `sfx_cue_potion_used_warrior.wav`, `_valkyrie.wav`, `_wizard.wav`, `_elf.wav`. `cue.class.confirm` and `cue.melee.swing` do NOT have per-class files — class differentiation via sub-bus EQ (confirm) or runtime pitch_scale (swing)
  - Per-family files: `sfx_cue_enemy_death_scullion_A/B.wav`, `_brute_A/B.wav`, `_broiler_A/B.wav`, `_carver_A/B.wav`, `_lobber_A/B.wav`, `_sorcerer_A/B.wav`, `_porter_A/B.wav`, `_maitre_A/B.wav`
  - Telegraph files: `sfx_cue_enemy_telegraph_lobber.wav`, `_sorcerer.wav`, `_porter.wav`, `_maitre.wav` (**4 files, one per ranged family**)
  - First-food: `sfx_cue_pickup_food_first.wav` (distinct from routine `sfx_cue_pickup_food_A.wav`, `sfx_cue_pickup_food_B.wav`)
  - Zone entry: `sfx_add_zone_entry_drowned.wav`, `_cinder.wav`, `_starved.wav`, `_throne.wav`
  - Heartbeat: `sfx_add_hp_heartbeat.wav` (single file, intensity via bus automation)
  - Flame: `sfx_add_hazard_flame_ignition_A.wav`, `_B.wav`, `sfx_add_hazard_flame_hiss.wav`
  - Pause: `sfx_add_pause_in.wav`, `sfx_add_pause_out.wav` (two separate forward sweeps)
  - Score tick: `sfx_add_score_tick_A.wav`, `_B.wav`
- **Runtime gain offsets in manifest:** `sfx_manifest.json` includes `runtime_gain_db` per entry — the per-cue offset relative to the cue's bus default gain. Delivery loudness is uniform within each category; relative levels are runtime.
- **Manifest fields:** `key`, `file`, `bus` (e.g., `SFX`, `CritSFX`, `SFX_Class/SFX_ConfirmEQ_Warrior`, `Ambience`, `Heartbeat`), `variant_index`, `priority` (0–255), `loop` (bool), `runtime_gain_db` (float), `pitch_scale_compensation` (float, default 1.0; set to 1.0087 for potion chords when Track 3 dominant).
- **License floor:** Work-for-hire or CC0/royalty-free only. No third-party licensed libraries. No "free for commercial use with attribution." All audio ownable by project without ongoing obligations. Composer retains moral rights only; project holds unlimited exploitation rights.
- **No-soundalike constraint:** All references are feel-direction, never source instructions. No sampling. Commissioned audio must be original work evoking described character without reproducing any identifiable element of any referenced recording.

### Music delivery

- **Source format:** WAV, 48 kHz, 24-bit, stereo.
- **Runtime format:** Ogg Vorbis q6 for runtime. WAV also delivered for loop-point verification.
- **Loop contract:** Entire file is the loop (no internal markers). Exact loop length per track (120.0 s / 128.0 s / 150.0 s). Seamless zero-crossing at file boundary. No fade-in/out baked in. Loop points documented with sample offsets.
- **Loop verification:** DAW region export with sample-accurate markers. Godot import verification: load `AudioStreamOggVorbis`, set `loop = true`, play 2× loop duration, capture output, check for amplitude discontinuity at loop boundary. **Acceptance: amplitude discontinuity at file boundary ≤ −60 dBFS.**
- **Loudness (asset-level):** Peak −12 dBFS; integrated −22 LUFS. True peak ≤ −6 dBTP.
- **Naming:** `bgm_after_service.wav` / `.ogg` (Track 1), `bgm_first_service.wav` / `.ogg` (Track 2), `bgm_deep_tables.wav` / `.ogg` (Track 3).
- **Track 3 detuning documentation:** Composer documents tuning method (+15 cents) and includes verification note.
- **License floor:** Work-for-hire or CC0.

### VO delivery (G3-owned)

G3 owns announcer delivery specification. G11's only requirements:
- Clips route through `Announcer` bus
- Asset loudness: −16 LUFS integrated, −2 dBTP
- If runtime concatenation needed, G10 implements in code with 50 ms gap, 5 ms fade-in/out per clip, normalized to −16 LUFS, composite ≤3.0 s

---

## 8. Open questions

1. **OQ-1 — G9 §9 full diff [BLOCKED commissioning gate].** The visible G9 §9 table truncates at row 14. Rows 15–18 are inferred from G9 §8 tuples and marked PROVISIONAL-SB. **No SB commissioning of rows 15–18 until this diff is complete.** G9 key names win. Owner: operator. Acceptance: full G9 §9 diff completed; all inferred keys confirmed or replaced; no provisional rows remain.
2. **OQ-9 — Enemy family taxonomy [BLOCKED commissioning gate for death/telegraph cues].** The unified family table (§1.F) lists 8 families. Verify against G2's entity table. Owner: operator. Acceptance: family table confirmed; no gaps.
3. **OQ-11 — Potion system.** Are potions in the final build? If cut: remove `cue.pickup.potion`, `cue.potion.used`, SIG-4 ducking entry, and 4 class-variant potion recordings.
4. **OQ-15 — Continue tokens.** If no continue tokens exist, continue screen is cut; remove `sfx.continue.offer`.
5. **OQ-7 — G3 VO delivery schedule.** Confirm when G3's frozen clip set will be available.
6. **OQ-8 — Audio memory budget confirmation [operator gate].** Total preload ~15.4 MB. On 8GB min-spec, <0.2% RAM. Operator must confirm this fits min-spec memory budget. Gate: operator signs off or waives.
7. **OQ-A1 — `amb.hall_tone` repetition acceptance.** The 60 s loop repeats ~25 times per full run. Operator must explicitly accept single-loop repetition OR commission a second 60 s loop (`amb_hall_tone_B.wav`) for per-floor alternation. Default: single loop, operator accepts.

**Closed questions:**
- **OQ-6 — CLOSED.** `sfx.hazard.flame` specifies ignition one-shot + steady hiss loop.
- **OQ-19 — CLOSED.** Hero death has single sound, no per-cause variants. G3 VO carries cause.
- **OQ-21 — CLOSED.** Audio-unaffected. Back-out overshoot fallback is a G9 visual concern. Listed for cross-reference only; not a G11 open question.

---

## 9. Acceptance criteria and definition of done

### SFX acceptance
- Every G9 §9 integration point has an SFX entry or explicit silence decision (verified by OQ-1 diff)
- **PROVISIONAL-SB rows (15–18) excluded from SB delivery acceptance until OQ-1 signed off**
- Every SB SFX (non-provisional) has delivered WAV master and Ogg q6 runtime file
- Every SFX file passes loudness check: SFX peak ≤ −6 dBFS, integrated −18 LUFS ±1, true peak ≤ −1 dBTP; UI peak ≤ −6 dBFS, integrated −20 LUFS ±1, true peak ≤ −4 dBTP
- Every variant round-robin has ≥2 variants; no variant repeats twice consecutively in scripted 10-minute test at fixed rates (swing 65/min, hit 45/min, score.tick 42/min, enemy.spawn 30/min, enemy.death 27/min)
- **10-minute fatigue test (objective):** scripted playback at fixed rates for top-5 sounds. Pass: no variant repeats twice consecutively; no retrigger floor violated; no sound exceeds specified retrigger floor. Operator sign-off confirms test was run; pass/fail is objective.

### Music acceptance
- Each track delivers WAV master + Ogg q6 runtime + sample-offset loop documentation
- **Loop seam test (measurable):** play 2× loop duration in Godot 4.7; amplitude discontinuity at file boundary ≤ −60 dBFS
- **Loop-seam test for continuous SFX loops:** all looping SFX (`sfx.hp.heartbeat`, `amb.hall_tone`, `sfx.hazard.flame` hiss, `sfx.exit.open`, `sfx.generator.idle`): play 2× loop duration; amplitude discontinuity at file boundary ≤ −60 dBFS
- BPM and bar count match locked values (64/32, 90/48, 80/50); file duration matches ±50 ms
- **Crossfade test (measurable):** floor-13 Track 2→3 crossfade over 8 s with 1 s midpoint dip. **Metric: RMS level measured at 100 ms intervals.** Midpoint window: seconds 3.5–4.5 of the 8 s crossfade. **Acceptance: both tracks reach −30 dB ±2 dB (RMS) within the midpoint window. Modulated-level deviation = max RMS deviation from the linear target envelope at any 100 ms sample point, excluding the midpoint dip window. Acceptance: ≤3 dB deviation outside the midpoint window.**
- **Track 3 detuning verification:** sustained root note in delivered WAV reads +15 cents ±2 cents in tuner plugin
- **Duck test (measurable):** each duck trigger produces correct depth within ±1 dB; attack and release within ±10 ms of spec (measured via `AudioServer.get_time_since_last_mix()`)

### VO acceptance (G3-owned; G11 verifies routing only)
- G3 clips route through `Announcer` bus
- Announcer bus loudness: −16 LUFS ±1
- Announcer barks duck music −10 dB and SFX −6 dB; CritSFX bus unaffected (measurable: CritSFX bus volume unchanged during announcer bark — verify CritSFX is sibling of SFX, not child)

### Mix acceptance
- **Mute playthrough:** complete floors 1–3 with Master at −80 dB; every critical event has visible fallback; no gameplay dependency on audio
- **Voice overload test (deterministic schedule):**
  - **Setup:** floor with 28 enemies + 4 generators + hero + 8 projectiles active simultaneously
  - **Scripted trigger schedule (30-second window):**
    - t=0.0s: 4 generator idle loops start (4 voices)
    - t=0.5s: 28 enemies spawn (28 `cue.enemy.spawn` over 2 s = 14/s, 80 ms retrigger floor → 28 fires, ~12 DROP, ~16 play)
    - t=2.5s: hero melee swing at 65/min (32 swings in 30 s, 80 ms floor)
    - t=2.5s: hero melee hit at 45/min (22 hits in 30 s, 100 ms throttle)
    - t=3.0s: 8 projectiles spawn (8 fires, max 4 concurrent per source)
    - t=3.5s: 8 projectile impacts (wall or enemy)
    - t=5.0s: 15 enemy deaths (80 ms throttle, excess DROP)
    - t=10.0s: 1 generator destroyed (CRIT, priority 255)
    - t=15.0s: hero hurt (2 variants, 250 ms throttle)
    - t=20.0s: 5 enemy telegraphs (4 families, max 1 concurrent per family)
    - t=25.0s: floor clear (CRIT)
  - **Pass criteria:** CRIT sounds (priority 255) never stolen; polyphony stays ≤32 one-shot voices; non-CRIT excess events DROP per policy; no audio-related crash or hang
- **CPU proxy test:** during the 30-second overload schedule above, game FPS remains ≥55 on min-spec. **Justification for 55 FPS floor (not 60):** The game targets 60 FPS with vsync. 55 FPS preserves the vsync cadence with at most 1 dropped frame per 12, remaining visually smooth. The 5-FPS headroom accounts for audio processing overhead on min-spec hardware (Intel UHD 630) under worst-case voice count. If FPS drops below 55, audio optimization is required (reduce concurrent voices, lower pool cap). If FPS remains ≥60, no action needed.
- **Device loss:** disconnect audio device mid-play; `error.audio_lost` shows once; gameplay continues with visual fallbacks; reconnect resumes audio. If platform provides no reliable device list, mute playthrough test validates silent-continuation path.
- **PAUSE mid-bark test:** trigger announcer bark, enter PAUSE during bark; bark hard-stops; queue freezes; resume from next unplayed bark
- **Master loudness test (measurable):** capture 10 minutes of representative gameplay audio (2 floors + 1 boss generator + 1 death + title screen) via Godot Movie Writer or WASAPI loopback. **Acceptance: integrated loudness −14 LUFS ±1.5; true peak ≤ −1 dBTP.** Measurement tool: any LUFS-compliant loudness meter (ebur128, ffmpeg ebur128 filter, or dedicated plugin). This is a final-mix delivery test, not a per-asset test.

### Runtime behavior acceptance tests
- **Class EQ routing:** play `cue.class.confirm` for each class; verify EQ parameters on `SFX_ConfirmEQ_<class>` sub-bus match spec; verify non-class SFX on main `SFX` bus is unaffected
- **Class pitch differentiation:** play `cue.melee.swing` for each class; verify `pitch_scale` on AudioStreamPlayer matches spec (axe 1.0, spear 1.08, bolt 1.15, arrow 1.22)
- **Heartbeat hysteresis:** reduce HP to 50% → heartbeat fades in; raise HP to 52% → heartbeat continues; raise HP to 55% → heartbeat fades out; reduce HP to 50% → heartbeat fades in. Verify automation ramp times (400 ms ±50 ms). Verify filter cutoff opens as HP drops (measurable: AudioEffectFilter cutoff frequency increases)
- **CRIT exemption:** play CRIT SFX through `CritSFX` bus during announcer bark; verify `CritSFX` bus volume unchanged while `SFX` bus is ducked −6 dB. **Verify CritSFX is sibling of SFX, not child**
- **Zone EQ crossfade:** cross zone boundary; verify `Ambience` bus EQ parameters tween over 1 s ±100 ms to new zone settings; verify `SFX` bus EQ is unchanged
- **Positional attenuation:** play positional SFX at 0 px and 800 px from listener; verify ≥12 dB attenuation difference
- **Potion pitch compensation:** with Track 3 dominant (Track 3 bus volume > Track 2 bus volume), play `cue.potion.used`; verify `pitch_scale = 1.0087` on the AudioStreamPlayer. With Track 2 dominant, verify `pitch_scale = 1.0`
- **Bus layout verification:** at boot, `AudioDirector` verifies bus count and names against §4 spec; logs error if any bus missing
- **Hero death ramp:** trigger hero death; verify Music bus ducks to −12 dB (30 ms attack), then ramps to −30 dB over 500 ms (via `request_ramped_duck`), then Track 1 fades in 500 ms after ramp completes
- **First-food CRIT routing:** trigger first-food pickup; verify arpeggio routes through `CritSFX` bus (not `SFX`); verify `sfx.hp.food_tick` does NOT fire during 450 ms arpeggio; verify G3 "FOOD." bark fires at 500 ms after arpeggio onset; verify arpeggio is not ducked by announcer SFX duck
- **Enemy spawn Ambience routing:** play `cue.enemy.spawn`; verify it routes through `Ambience` sub-bus and receives per-zone EQ; verify `amb.hall_tone` also routes through `Ambience`; verify other SFX do NOT route through `Ambience`

### Manifest validation
- `sfx_manifest.json` validates every file against its SFX key, bus, variant index, priority, loop flag, `runtime_gain_db`, and `pitch_scale_compensation`
- No file is orphaned; no key is orphaned

### Family taxonomy gate
- **OQ-9 resolved:** unified enemy family table confirmed against G2; 8 families; no gaps

### G9 diff gate
- **OQ-1 resolved:** full G9 §9 diff completed; no provisional rows remain

### Definition of done
- All non-provisional SB SFX delivered and validated
- All 3 music tracks delivered and loop-tested (amplitude discontinuity ≤ −60 dBFS)
- Mix policy implemented in `AudioDirector` autoload with `request_duck`/`request_ramped_duck`/`release_duck` priority stack
- Mute playthrough passes
- Voice overload test passes with scripted schedule (polyphony ≤32, CRIT never stolen)
- CPU proxy test passes (FPS ≥55 on min-spec during overload)
- Master loudness test passes (−14 LUFS ±1.5, ≤ −1 dBTP)
- Runtime behavior acceptance tests pass
- Manifest validation passes
- Bus layout verification passes at boot (CritSFX is sibling of SFX)
- OQ-1 G9 diff signed off; no provisional rows remain
- OQ-9 family taxonomy confirmed against G2 (8 families)
- OQ-8 operator confirms memory budget or explicitly waives
- OQ-A1 operator accepts amb.hall_tone repetition or commissions loop B
- Operator signs off on fatigue test (confirms test was run; pass/fail is objective)
- No open OQs remaining (or explicitly waived by operator)

## Obligation Responses

OBL-1: ADDRESSED — §1.C row 09 and §3 now specify FOOD bark fires 500ms after arpeggio onset; first-food is CRIT, routes through CritSFX, exempt...
OBL-2: ADDRESSED — §4 bus layout: cue.enemy.spawn now routes through Ambience sub-bus (shared with amb.hall_tone); §4 explicitly states both rou...
OBL-3: ADDRESSED — Telegraph count corrected to 4 recordings (one per ranged family); "6" and "gap-fill" references removed from row 08 and §7.
OBL-4: ADDRESSED — §7 naming now lists both sfx_cue_hero_hurt_A.wav and sfx_cue_hero_hurt_B.wav; row 18 specifies A=melee, B=projectile/hazard.
OBL-5: ADDRESSED — §2 crossfade matrix now shows ramp+gap+fade (~1300ms) for play→game_over; §1.E has the same authoritative sequence; no conflict.
OBL-6: ADDRESSED — §9 voice overload test now includes a deterministic 30-second scripted trigger schedule with specific times, rates, and pass...
OBL-7: ADDRESSED — §9 adds Master loudness test: capture 10min representative gameplay, measure −14 LUFS ±1.5, ≤−1 dBTP via ebur128 or equivalent.
OBL-8: ADDRESSED — Same as OBL-2: enemy.spawn routes through Ambience bus; §4 states both amb.hall_tone and cue.enemy.spawn route there.
OBL-9: ADDRESSED — Telegraph count corrected to 4; the "2 gap-fill" is removed; row 08 says "4 separate recordings, one per ranged family."
OBL-10: ADDRESSED — sfx.ui.hover runtime_gain_db corrected from −20 dB to −6 dB relative to press; §5 clarifies offset is relative to bus default...
OBL-11: ADDRESSED — §4 bus layout adds dedicated Heartbeat sub-bus (child of SFX) with AudioEffectFilter; AudioDirector automates filter cutoff a...
OBL-12: ADDRESSED — §3 NG+ section now specifies pitch shift on Music and SFX buses only; Announcer and UI buses explicitly excluded with rationale.
OBL-13: ADDRESSED — §1.C row 13 and §9 define activation: pitch_scale compensation applies when Track 3 bus volume > Track 2 bus volume (~5s into...
OBL-14: ADDRESSED — §9 CPU proxy test justifies 55 FPS: preserves vsync cadence with 1 dropped frame per 12; 5-FPS headroom for audio overhead on...
OBL-15: DEFERRED — OQ-1 G9 diff remains a BLOCKED operator gate; rows 15–18 are PROVISIONAL-SB and excluded from SB delivery acceptance until dif...
OBL-16: ADDRESSED — §1.E state walk now includes title→settings and settings→title transitions with UI sound mappings and Track 1 continuation.
OBL-17: ADDRESSED — First-food announcer ordering now appears in §1.C row 09, §3 VO needs, and §5 duck table; not just in OBL response.
OBL-18: ADDRESSED — §4 bus layout: CritSFX is now a sibling of SFX under Master, not a child; ducking SFX cannot affect CritSFX structurally.
OBL-19: ADDRESSED — §4: per-class EQ sub-buses only handle cue.class.confirm (fixed EQ at boot, class_select state only); melee.swing and project...
OBL-20: ADDRESSED — §4: heartbeat routes through dedicated Heartbeat sub-bus with AudioEffectFilter; AudioDirector automates filter on the bus, n...
OBL-21: ADDRESSED — Same as OBL-2/8: enemy.spawn routes through Ambience bus; §4 explicitly states both amb.hall_tone and cue.enemy.spawn route t...
OBL-22: ADDRESSED — Telegraph count corrected to 4 (one per ranged family: Lobber, Sorcerer, Porter, Maître d'); no gap-fill.
OBL-23: ADDRESSED — §2 crossfade matrix and §1.E now agree: play→game_over is ramp(500ms)+gap(200ms)+fade(500ms), NOT a 300ms crossfade.
OBL-24: ADDRESSED — §1.E "zone ambience crossfade" replaced with "Ambience bus EQ tween over 1s to new zone settings" (shared-bed model).
OBL-25: ADDRESSED — §5 duck table clarifies F19 zone-entry bark is a G3 announcer clip on Announcer bus; −3 dB is additional to standard −10 dB a...
OBL-26: ADDRESSED — §5 clarifies runtime_gain_db is relative to cue's bus default gain; sfx.ui.hover corrected to −6 dB offset (not −20 dB), yiel...
OBL-27: ADDRESSED — §5 adds "Absolute level reference" paragraph: amb.hall_tone −16 dB offset on SFX bus → −22 dB effective; generator.idle −18 d...
OBL-28: ADDRESSED — §1.C sfx.floor.enter entry: "If floor.enter is suppressed by fold-under, floor.banner also folds." At F7/F13/F19, floor.enter...
OBL-29: ADDRESSED — §4 voice pool section: 32-voice pool covers one-shot SFX and UI only; music (3), announcer (1), and loops (max 8) have dedica...
OBL-30: ADDRESSED — §1.C row 08: "Throttle: max 1 concurrent per family; excess same-family windups DROP. Different families may overlap."
OBL-31: ADDRESSED — §1.C sfx.continue.offer: "One-shot only; no loop." Optional 3s loop removed. No loop-seam acceptance needed.
OBL-32: ADDRESSED — §9 adds Master loudness test: 10min capture, −14 LUFS ±1.5, ≤−1 dBTP, via ebur128 or equivalent loudness meter.
OBL-33: ADDRESSED — §5 caption-hold defined: release timer begins 500ms after bark audio ends OR when caption slides out (AC-28), whichever is la...
OBL-34: ADDRESSED — §9 crossfade test: "Modulated-level deviation = max RMS deviation from linear target envelope at 100ms intervals, excluding m...
OBL-35: ADDRESSED — §1.F header corrected to "8 families (4 melee, 4 ranged)"; table lists 8 rows.
OBL-36: ADDRESSED — sfx.zone.entry is SB in §1.C; removed from demotion list. Cut priority paragraph now only lists amb.hall_tone as demotion can...
OBL-37: ADDRESSED — §1.C amb.hall_tone: "Operator must explicitly accept single-loop repetition OR commission loop B." §8 OQ-A1 formalized as ope...
OBL-38: ADDRESSED — Track 2 instrumentation: "muted lid-tap percussion on beat 2 only (no snare/clap on beat 4)" — softened from original snare/c...
OBL-39: ADDRESSED — §1.E and §2 specify: hero-death ramp (−12→−30 dB) completes first via request_ramped_duck; Track 1 fade-in begins after ramp,...
OBL-40: ADDRESSED — §1.E and §2 crossfade matrix: game_over→continue_offer = "No transition; Track 1 continues." Track 1 is already playing from...
OBL-41: ADDRESSED — §4 memory budget: SFX count corrected to ~80 base files; total memory ~15.4 MB (was ~60 files, ~15 MB).
OBL-42: ADDRESSED — OQ-21 moved from open questions to closed questions: "Audio-unaffected. Back-out overshoot fallback is a G9 visual concern."
OBL-43: ADDRESSED — §1.E state walk now includes title→settings and settings→title transitions with sfx.ui.press/sfx.ui.back and Track 1 continua...
OBL-44: ADDRESSED — Same as OBL-18: CritSFX is sibling of SFX under Master, not a child; structural exemption, not programmatic.
OBL-45: ADDRESSED — Same as OBL-19: per-class EQ sub-buses only for class.confirm; melee.swing and projectile.spawn use runtime pitch_scale on Au...
OBL-46: ADDRESSED — Same as OBL-20: heartbeat routes through dedicated Heartbeat sub-bus with AudioEffectFilter; automation on bus, not AudioStre...
OBL-47: ADDRESSED — Same as OBL-2/8/21: enemy.spawn routes through Ambience bus; §4 explicitly states both amb.hall_tone and cue.enemy.spawn rout...
OBL-48: ADDRESSED — Same as OBL-3/9/22: telegraph count corrected to 4 recordings, one per ranged family; no gap-fill.
OBL-49: ADDRESSED — Same as OBL-35: §1.F header corrected to 8 families; table lists 8 rows.
OBL-50: ADDRESSED — Same as OBL-4: §7 names both _A.wav and _B.wav for hero hurt; row 18 specifies melee vs projectile/hazard.
OBL-51: ADDRESSED — Same as OBL-36: sfx.zone.entry is SB; removed from demotion list; only amb.hall_tone is demotion candidate.
OBL-52: ADDRESSED — Same as OBL-41: SFX count corrected to ~80 files; memory estimate updated to ~15.4 MB.
OBL-53: ADDRESSED — Same as OBL-5/23: §2 crossfade matrix and §1.E agree on ramp+gap+fade for play→game_over; 300ms crossfade applies only to flo...
OBL-54: ADDRESSED — Same as OBL-40: §1.E and §2 specify Track 1 continues for game_over→continue_offer; no music transition.
OBL-55: ADDRESSED — Same as OBL-24: "zone ambience crossfade" replaced with "Ambience bus EQ tween over 1s" in §1.E.
OBL-56: ADDRESSED — Same as OBL-13: potion pitch compensation activates when Track 3 bus volume > Track 2 bus volume (~5s into 8s crossfade).
OBL-57: ADDRESSED — Same as OBL-1/17: FOOD bark fires 500ms after arpeggio onset; specified in §1.C, §3, and §5.
OBL-58: ADDRESSED — Same as OBL-25: F19 zone-entry bark is a G3 announcer clip on Announcer bus; −3 dB additional music duck when Track 3 active.
OBL-59: ADDRESSED — Same as OBL-6: §9 voice overload test includes deterministic 30-second scripted trigger schedule with times, rates, and pass...
OBL-60: ADDRESSED — Same as OBL-7/32: §9 adds Master loudness test with method, tolerance (±1.5 LUFS), and measurement tool specification.
OBL-61: ADDRESSED — Same as OBL-34: crossfade metric defined as max RMS deviation from linear target envelope at 100ms intervals; ≤3 dB outside m...
OBL-62: ADDRESSED — Same as OBL-14: 55 FPS justified as preserving vsync with 1 dropped frame per 12; 5-FPS headroom for audio overhead on min-spec.
OBL-63: ADDRESSED — Same as OBL-30: telegraph throttle = max 1 concurrent per family; excess same-family windups DROP; different families may ove...
OBL-64: ADDRESSED — Same as OBL-33: caption-hold defined as 500ms after bark audio ends or caption slide-out, whichever later; duck timing ±10ms...
OBL-65: ADDRESSED — Same as OBL-31: sfx.continue.offer is one-shot only; optional loop removed; no loop-seam acceptance needed.
OBL-66: ADDRESSED — Same as OBL-38: Track 2 backbeat softened to "muted lid-tap on beat 2 only, no snare/clap on beat 4."
OBL-67: ADDRESSED — Same as OBL-37: operator must accept single-loop repetition or commission loop B; OQ-A1 formalized.
OBL-68: ADDRESSED — §1.C heartbeat entry: "At 10% HP, filter opens to ~300ms pulse (~200 BPM) — intentional urgency signal, not steady-state bed."
OBL-69: ADDRESSED — Same as OBL-42: OQ-21 moved to closed questions; audio-unaffected.
OBL-70: DEFERRED — Same as OBL-15: OQ-1 G9 diff remains BLOCKED operator gate; rows 15–18 are PROVISIONAL-SB until diff is complete.
OBL-71: ADDRESSED — Same as OBL-3/9/22/48: telegraph count corrected to 4; row 08 says "4 separate recordings, one per ranged family."
OBL-72: ADDRESSED — §1.C row 07: "Death-type: same base recording pitch-shifted down one octave via runtime pitch_scale=0.5 — no separate file. R...
OBL-73: ADDRESSED — Same as OBL-5/23/39/53: §1.E and §2 crossfade matrix unified; hero-death ramp completes before Track 1 fade-in begins.
OBL-74: ADDRESSED — Same as OBL-1/17/57: first-food is CRIT priority, routes through CritSFX (sibling of SFX), exempt from announcer SFX duck.
OBL-75: ADDRESSED — Same as OBL-29: voice pool scope defined — 32 one-shot SFX/UI; music/announcer/loops have dedicated nodes outside pool.
OBL-76: ADDRESSED — §4 AudioDirector API adds request_ramped_duck(handle, from_db, to_db, ramp_ms) for time-varying ducks; hero death uses it.
OBL-77: ADDRESSED — Same as OBL-34/61: midpoint window = seconds 3.5–4.5 of 8s crossfade; both tracks reach −30 dB ±2 dB RMS; deviation ≤3 dB out...
OBL-78: ADDRESSED — §1.C sfx.score.tick entry now includes "2 variants" in the variation policy column, matching §6 fatigue audit.
OBL-79: ADDRESSED — §4 memory budget: "Godot 4.7 does support streamed playback of Ogg Vorbis... however, for this brief's file sizes, full prelo...
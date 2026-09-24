# HUNGERHALL — G2 Game Design Document

**Run:** gap-253b64a1 · **Phase:** G2 · **Authority:** G1 Concept Lock (run 2026-07-30T18-54-57Z-refine-546a1695, FROZEN) · **Engine:** Godot 4.7 (locked) · **Platform:** Steam (Windows export) · **Price:** $5.99 premium, no post-purchase spending · **Audience:** nostalgic players expecting 1985 Gauntlet mechanical fidelity

**Presentation advisory, settled:** G1 forbids 3D graphics, rendering, and physics as falsification conditions. The game is pure 2D, 32px tiles, period 1985 palette, original sprites authored through the Sneferu pipeline. Stated once, never revisited.

**Closest shipped relatives and the exact mechanical fork:**

- *Gauntlet* (1985 arcade) — the ordered ancestor. Coin-op endurance for 1–4 players splitting food and aggro. HUNGERHALL is one player, finite floors, frozen deterministic layouts, classes rebuilt as complete solo survival strategies.
- *Vampire Survivors* — auto-attacking horde survival with level-up drafts. Fork: manual aimed throws, zero in-run upgrades, floors that end.
- *The Binding of Isaac* — room crawler powered by rolled item synergy. Fork: fixed class kits, a draining life clock, layouts solver-gated for structural solvability.

**Novelty claim, stated honestly:** No shipped relative runs continuous life-drain as the sole clock of a single-player campaign where four classes each pay the same HP bill in a different currency of risk. Floors are solver-gated for structural solvability at bake time and will be Monte Carlo-validated for dynamic survival when FIX-153 lands; until then, combat estimates are hand-set constants accepted as provisional, not simulated proofs. All art, voice, and music are original pipeline output. No Atari names, assets, or audio are used.

---

## 1. Core mechanic state machine

**The mechanic in one sentence:** your health bar is the only clock — standing still spends it, moving forward risks it, and every room charges a different price in hit-points per second.

**The standing tension (depth check):** HP moves in one direction: down. Time is the opponent; enemies are how the dungeon raises the price of time. Each room offers three priced routes: the direct lane (cheapest HP, poorest score), the greedy loop (food and treasure behind guards), and the suppression push (advance into spawn lanes and kill the generator so reinforcements stop). The Warrior pays with bulk, the Valkyrie walks guarded lanes, the Wizard deletes clusters before they matter, the Elf is not where the damage lands. That three-way price negotiation, repeated under a falling numeral, is the game.

**States (nouns) and transitions (single-word verbs):**

| From | Verb | To | Condition |
|---|---|---|---|
| Title | Press | ClassSelect | Any confirm input |
| Title | Resume | Playing | Continue selected; save exists; next uncompleted floor loads fresh (full HP, 2 tokens, saved potions) |
| ClassSelect | Choose | Playing | Class locked; floor 1 loads; HP set to class max; tokens set to 2; potions set to 0 |
| Playing | Pause | Paused | Esc / Start |
| Paused | Resume | Playing | Same input; fixed 60 Hz delta resumes, no time jump |
| Paused | Quit | Title | Confirmed; mid-floor progress discarded entirely (no save written mid-floor by construction) |
| Playing | Clear | FloorResults | Exit-door overlap held 3 consecutive physics frames at 60 Hz (50 ms) AND floor < 24 |
| Playing | Finish | CampaignResults | Exit-door overlap held 3 consecutive physics frames AND floor == 24 |
| FloorResults | Advance | Playing | Confirm; autosave written on FloorResults entry; next floor loads |
| FloorResults | SaveQuit | Title | Confirm; autosave already written; campaign progress preserved |
| CampaignResults | Enter | Title | Initials committed; NewGame+ unlock flag written to persistent profile |
| Playing | Drain | Dying | HP reaches 0 from any source; 0.4s countdown completes |
| Dying | Prompt | ContinueOffer | Crumble animation finishes (1.2s) |
| ContinueOffer | Continue | Playing | YES inside 10s AND tokens remain; floor rebuilds from baked data; player position set to floor entrance spawn tile |
| ContinueOffer | Expire | GameOver | Timeout, NO, or zero tokens |
| GameOver | Enter | Title | Initials committed; campaign save preserved at last completed floor (score restored to that floor's FloorResults total) |

Title runs an attract loop: a pre-recorded replay (`res://Assets/Replays/attract.replay`, captured at bake time from a seed-locked greedy-killer bot run on floor 1 and solver-validated before packaging) plays back behind the logo — not live AI — while the local score table cycles. Per arcade convention and the determinism contract.

**EARS-format requirements (critical transitions):**
- When the player's HP reaches 0, the system shall transition to Dying within 1 physics frame.
- When the player overlaps the open exit door for 3 consecutive physics frames AND the current floor is less than 24, the system shall transition to FloorResults.
- When the player overlaps the open exit door for 3 consecutive physics frames AND the current floor equals 24, the system shall transition to CampaignResults.
- When the player confirms YES in ContinueOffer with tokens remaining, the system shall rebuild the current floor from baked data with the player position set to the floor entrance spawn tile, HP set to 50% of class maximum, potions zeroed, keys reset to zero, and food not restored.
- The system shall advance all rules from a fixed 60 Hz physics delta; no rule state shall depend on wall-clock time or frame rate.

**Input to output map** (keyboard and gamepad first-class; no remapping needed at first boot; pickups fire on overlap, doors consume their key on push, no interact button):

| Input | Output |
|---|---|
| WASD / arrows / left stick | 8-way movement at class speed; step puffs every 12px |
| J / Z / Ctrl or south face / RT (hold = auto-throw) | Projectile along current facing, spawned on press frame; 3-frame arm pose; 1-frame muzzle flash; light haptic |
| K / X / east face / RB | Class potion: consumes one stock from cap-3 inventory; effect per class table below |
| Esc / Start | Pause |

**Class combat signatures:**

| Class | HP | Speed | Shot | Range | Dmg | Rate | Potion effect | Survival identity |
|---|---|---|---|---|---|---|---|---|
| Warrior | 800 | 128 px/s | Axe, pierces | 5 tiles | 50 | 1.2/s | Whirlwind: 4-tile radial, 150 dmg, 8px knockback | Pays HP for position; walks through crowds |
| Valkyrie | 680 | 152 px/s | Spear | 7 tiles | 30 | 1.6/s | Aegis: 3s projectile immunity, 50% contact dmg reduction | Lane-walker; reduced damage while advancing |
| Wizard | 520 | 144 px/s | Bolt, 1-tile splash (12) | 6 tiles | 20 | 1.2/s | Nova: 5-tile radial, 250 dmg, 125 to generators | Deletes packs; dies to lone pursuers |
| Elf | 560 | 192 px/s | Arrow | 10 tiles | 15 | 3.0/s | Volley: 12 arrows 360°, 15 dmg each, 10-tile range | Outranges threats; starves if cornered |

**Valkyrie damage reduction, precisely defined:** while the Valkyrie's movement input is non-zero AND her velocity vector points within ±30° of the direction to the nearest enemy within 7 tiles (her spear range), incoming projectile damage is reduced by 50%. This is damage TAKEN, not dealt. Contact damage is unaffected. If no enemy is within 7 tiles, no reduction applies. Standing still provides no reduction. The modifier rewards advancing into fire, not retreating from it: the cone is anchored to the threat direction, not to facing, so it closes the retreat-kiting exploit a facing cone allows and behaves identically under both aim schemes tested in §10 Q2.

**Potion mechanic, precisely defined:** potions are carryable pickups, cap 3, carried between floors within a run, zeroed on continue. Each use consumes one stock. No cooldown. Each class finds their own potion type as floor pickups; the pickup sprite differs by class but placement is identical (same baked positions).

**Elf Volley firing pattern:** all 12 arrows spawn simultaneously in a single frame, distributed at 30° intervals starting from the Elf's current facing. Each arrow is an independent projectile with standard arrow speed and 10-tile range. No multi-frame stagger. The freeze-frame per the §11 potion beat (6 frames) covers the burst.

**Enemy roster (full encounter contracts):**

| Enemy | HP | Speed | Contact dmg | Projectile | Spawn rule | AI behavior |
|---|---|---|---|---|---|---|
| Ghost | 14 | 100 px/s | 10 per 0.5s per attacker | None | Generator, 3.0–1.5s cadence by band | Pursues player; ignores wall collision (passes through) |
| Grunt | 30 | 80 px/s | 15 per 0.5s | None | Generator | Pursues; pathfinds around walls |
| Demon | 60 | 90 px/s | 20 per 0.5s | 15 dmg, 200 px/s, 2.0s cadence | Generator (F4+) | Maintains 4-tile distance; fires projectile |
| Lobber | 50 | 70 px/s | 15 per 0.5s | 20 dmg, 220 px/s, 2.5s cadence; travels in a straight line (visual arc is cosmetic); ignores wall collision; collision mask = player hitbox only, no friendly fire | Generator (F7+) | Seeks LOS gap; lobs projectile over walls |
| Sorcerer | 80 | 110 px/s | 20 per 0.5s | None | Generator (F8+) | Pursues; blinks to a random tile within 6 tiles that has LOS from the Sorcerer's position (unobstructed raycast on tile grid) when HP < 40 AND no LOS to player for 2.0s; cooldown 5.0s; if no valid destination exists, blink is cancelled and the cooldown still applies |
| Death | 300 | 60 px/s | 50 per 0.5s (touch aura; damages all adjacent entities including enemies; Death immune to own aura) | None | Scripted spawn (F13+); one per floor at farthest tile from player | Pursues slowly; kill yields +200 |

**Generator stat block and per-zone scaling:**

| Zone | Floors | Generator HP | Spawn cadence | Notes |
|---|---|---|---|---|
| Drowned Vaults | 1–6 | 60 | 3.0s | Two Warrior axes; teaches suppression |
| Cindercrypt | 7–12 | 90 | 2.5s | Two axes (100 ≥ 90); five Wizard bolts — first real investment |
| Starved Deep | 13–18 | 120 | 2.0s | Three axes; Wizard Nova one-shots (125 ≥ 120) |
| The Hollow Throne | 19–24 | 160 | 1.8s (F19–21) / 1.5s (F22–24), per §3 band table | Four axes; Nova (125) leaves 35 HP — finish with two bolts |

Generator resource: `GeneratorDef` (Resource: hp, spawn_cadence, max_alive_per_generator, enemy_type).

**Structure damage rule:** regular weapons deal full listed damage to generators. The Wizard's splash does not apply to structures — only the direct bolt (20) counts — making the Wizard the weakest generator-killer by regular fire (24 DPS vs Warrior 60, Valkyrie 48, Elf 45) and the strongest by potion (Nova 125). Class-specific suppression routes are deliberate.

**Potion damage rule:** all potion damage deals full to enemies, half to generators (hardened structures). Warrior Whirlwind: 150 enemy / 75 generator. Wizard Nova: 250 enemy / 125 generator. Elf Volley: 15/arrow enemy / 7/arrow generator. Valkyrie Aegis: no damage (defensive).

**Multi-generator interaction and concurrency model:** each generator spawns independently at its own cadence; destroying one does not affect others. **Per-generator alive cap: 6** — a generator blocks its own spawning while 6 of its children live. **Per-floor alive cap: 28** — all generators block while 28 enemies live. The per-generator cap closes the speedrun exploit where filling a global cap in room A suppresses spawns in room B: each generator maintains independent pressure regardless of other rooms' states. Twin-generator rooms (F10+) and triple-generator rooms (F22+) raise refill pressure after kills, not peak concurrency — the floor cap plateaus while cadence accelerates. The 60fps budget is validated at the 28-enemy ceiling (G1 requires 20+).

**Hazard contracts:**

| Hazard | Zone | Damage | Telegraph | Trigger |
|---|---|---|---|---|
| Flame jet | Cindercrypt (F7–12) | 10 per 0.5s while active | 0.5s flame-grow from emitter tile | Periodic: 1.0s on / 2.0s off; phase baked per floor |
| Void bridge | Starved Deep (F13–18) | 100 HP on stepping onto a void tile; bounces player back to last safe tile; fatal at HP ≤ 100 | Bridge tiles glow 0.3s before becoming walkable; void tiles dark | Bridge tiles phase walkable 1.5s / void 1.5s on a baked cycle |
| Collapsing void | The Hollow Throne (F19–24) | 100 HP if on a tile at removal or stepping onto a removed tile; bounce to last safe tile (teleport to nearest valid tile if none adjacent); fatal at HP ≤ 100 | Crack at 1.0s, flash at 0.3s before removal | Tile removes 2.0s after the player steps on it; removal is permanent for the floor's duration |

**Soft-lock prevention (provable):** (1) HP at or below 0 always fires Drain within 1 physics frame. (2) Bake-time solver verifies spawn-to-key-to-door-to-exit reachability AND the static HP budget (defined in §7). (3) All corridors ≥2 tiles wide; every enemy including Death (60 px/s) can be outrun by every class (min 128 px/s). (4) Ghosts ignore wall collision but deal only 10 dmg per 0.5s per attacker; they cannot body-block. (5) Collapsing-void safety: the solver verifies the critical path requires no backtracking over collapsed tiles and that every collapsible region retains a valid bounce/teleport target (no tile can become surrounded by void on all sides). (6) No state exists where HP > 0 and no transition is possible.

---

## 2. Win/lose/end conditions

**Floor win:** Exit-door tile is open (key spent) AND player collision shape overlaps door for 3 consecutive physics frames at 60 Hz (50 ms) AND no death countdown animating AND floor < 24. Transition: Playing → Clear → FloorResults. UI: panel showing floor time, kills, food eaten, running total, NEXT FLOOR CTA at 30px minimum, "SAVED" tag confirming autosave.

**Campaign win:** Exit-door overlap condition met AND floor == 24. Transition: Playing → Finish → CampaignResults. UI: closing line, per-class completion laurel (cosmetic only), final total, initials entry for local table, "RETURN TO TITLE" CTA, NewGame+ unlock notice (global, all classes). The NewGame+ unlock flag is written to the persistent profile on CampaignResults entry; the unlock survives save deletion.

**Death (local fail):** HP reaches 0 on any tick. Final chunk counts down over 0.4s, then Dying fires. Hero crumbles over 1.2s. Score docks 20% of floor-entry score (the score recorded when the floor began), rendered as rolling red subtraction. The penalty is flat from floor-entry score, not compounding — a second death on the same floor docks 20% of the same floor-entry value, not 20% of the already-reduced total. Example: enter floor with 1000, die once → 800, die again → 600. Each death on that floor costs the same 200. Nothing hidden or softened.

**Continue window:** 10.0s ring with "CONTINUE? xN" and YES pre-highlighted. At zero tokens, the ring shows "NO CONTINUES" for 2s, then auto-transitions to GameOver — no dead 10-second wait, no zero-duration state. Accepting rebuilds the floor from baked data: player position set to the floor entrance spawn tile, HP set to 50% of class maximum, potions zeroed, keys reset to zero, food NOT restored (all previously consumed food stays consumed). Tokens: 2 per floor entry, refreshed only by arriving at a new floor. Timeout or NO → GameOver.

*Design rationale:* Per-floor refresh keeps every floor a fresh contract. A global pool would let early mistakes poison late floors, reading as cruelty rather than stakes.

**Save system:** Format: `save_version: int` (current: 1), `floor: int` (next uncompleted floor), `class: String`, `score: int` (score at last FloorResults), `potions_remaining: int`, `timestamp: int`. Migration policy: unrecognized version triggers fresh start with notification. Autosave writes only on FloorResults entry and records the NEXT floor's number; reloading starts at that floor's entrance with full HP, 2 tokens, and potions carried from the prior floor's end state. Mid-floor quit from Paused discards the interrupted floor entirely — no save is ever written mid-floor, so there is nothing to copy or scum. **GameOver behavior:** the local score table entry records the final score at GameOver (after all death penalties). The campaign save is preserved at the last completed floor: reloading starts at the failed floor's entrance with full HP, 2 tokens, and the score restored to the last FloorResults total — score earned on the failed attempt is lost, but campaign position is not. Stated honestly: quitting mid-floor produces the same result as a GameOver retry — the interrupted floor restarts fresh with its pre-floor score, equivalent to a continue without the 20% penalty. For a single-player game with local scores only, this is accepted risk per §9.

**Session boundary:** Any contiguous play period. The floor is the atomic unit of persistence. Quitting mid-floor saves nothing from that floor.

---

## 3. Progression

**First 30 seconds, contracted (session 1, floor 1, Warrior pre-highlighted):**

- **T+0:** Spawn at the floor entrance tile at the foot of a 2-tile vertical shaft. Announcer speaks entry line (captioned). HP numeral already falling once per second. The falling number teaches before words do.
- **First input by T+5:** Three ghosts (14 HP) drift from a generator 6 tiles ahead. If idle at T+4, glyph + "MOVE" fades in (1 word, on-screen tutorial overlay, not a separate screen). Player moves or attacks.
- **First success by T+15:** One axe (50 dmg) drops one ghost. Sprite pop, +10 floater, 2-frame white hit flash.
- **First delight by T+25:** Generator (60 HP) bursts on the second axe: 4-frame freeze, 2px camera kick, voice callout with caption, +100 floater.
- **Food beat by T+30:** First food piece sits 2 tiles past the generator. Contact triggers HP tick-up (3×50 over 0.3s), "FOOD" caption (1 word, holds 2s), audio blip with semitone rise. This beat landing by T+30 is a hard acceptance check for G7.

**Tutorial budget (G0: ≤60s / ≤3 screens / ≤30 words):** Zero dedicated tutorial screens. Word ledger, separated by channel:

| Channel | Words | Items |
|---|---|---|
| Spoken (announcer, captioned) | 5 | Entry line |
| On-screen tutorial glyph | 2 | "MOVE" (T+4 idle prompt), "THROW" (T+10 idle prompt) |
| On-screen event caption | 4 | "GENERATOR", "KEY", "FOOD", "CLEARED" |

Total: 11 words. Captions mirror announcer lines (same words, not additional). Glyph fades are overlays on the play screen, not separate screens. Compliant with margin.

**Difficulty curve (24 floors, 4 zones of 6, 10 sessions):**

| Floors | Drain HP/s | Target s/floor | Combat est. | Food/floor | Spawn cadence | New pressure |
|---|---|---|---|---|---|---|
| 1–3 | 2.0 | 120–150 | 500 | 3 | 3.0s | Ghost F1, Grunt F2, potions F3 |
| 4–6 | 2.5 | 150–180 | 700 | 5 | 3.0s | Demon F4 (first projectile) |
| 7–9 | 3.0 | 180–210 | 700 | 6 | 2.5s | Lobber F7, Sorcerer F8, flame jets |
| 10–12 | 3.5 | 210–240 | 850 | 8 | 2.5s | Density, twin-generator rooms |
| 13–15 | 4.0 | 240–270 | 950 | 11 | 2.0s | Death F13, void bridges |
| 16–18 | 4.5 | 240–270 | 1100 | 12 | 2.0s | Combined-arms gauntlets |
| 19–21 | 5.0 | 270–300 | 1100 | 14 | 1.8s | Dual-Death floors, collapsing void |
| 22–24 | 5.5 | 270–300 | 1250 | 16 | 1.5s | Triple-generator gauntlets, F24 finale |

**Food formula (per-floor HP reset, no carry-in, with explicit survival margin):**
`food_pieces = max(1, ceil((drain × target_mid + combat_damage_estimate − min_class_HP + margin_HP) / food_hp))`
Where `min_class_HP = 520` (Wizard), `food_hp = 150`, `margin_HP = 52` (10% of Wizard max — guarantees a ≥10% surplus for the most vulnerable class), `target_mid` is band midpoint. The `max(1, ...)` bound prevents zero or negative food generation on any hypothetical low-combat floor. The formula targets the most vulnerable class; other classes gain surplus as a class advantage. Each band's `combat_damage_estimate` is calibrated by the G2.1 Monte Carlo (FIX-153); a band the simulation rejects triggers parameter retune, not a hand-patch. Until G2.1 is wired, estimates are provisional hand-tuned values flagged as uncalibrated.

**Formula verification (F1–3):** max(1, ceil((2.0×135 + 500 − 520 + 52) / 150)) = max(1, ceil(302/150)) = 3 ✓. Available 520 + 450 = 970; spent 270 + 500 = 770; margin 200 HP = 38.5%.

**Formula verification (F22–24):** max(1, ceil((5.5×285 + 1250 − 520 + 52) / 150)) = max(1, ceil(2349.5/150)) = 16 ✓. Available 520 + 2400 = 2920; spent 1567.5 + 1250 = 2817.5; margin 102.5 HP = 19.7%.

All eight bands pass the ≥10% Wizard margin; the food column above is the formula's output per band, not a hand-set value.

**Session structure:**
- **Sessions 1–3 (F1–6, Drowned Vaults), tutorial-shaped.** Each verb appears alone: kill, generator, drain-and-food, key-and-door, potion, treasure. F6 capstone examines all simultaneously. Player dies once or twice, learns death's cost and the continue rhythm.
- **Sessions 4–7 (F7–18, Cindercrypt + Starved Deep), genuine challenge.** Projectiles arrive, Lobbers punish wall-hugging, Sorcerers punish tunnel vision, Death demands flee-or-commit. Flame jets and void bridges add environmental pressure. Drain outruns lazy routing; food hides behind guarded detours. Class choice bites here.
- **Sessions 8–10 (F19–24, The Hollow Throne), commit-or-abandon.** Dual-Death floors, collapsing void, triple-generator gauntlets. F24 is the campaign finale: Death, three generators, sealing exit.

**Total time:** ~90–96 min floor play (midpoint-to-upper target sums) + ~30 min overhead (menus, deaths, continues, class select) = ~2h00m–2h06m first playthrough. Satisfies G1's 2-hour bar.

**Dominant-strategy rebuttals:**
- **Camping:** Drain terminates every state. F1 Warrior (800 HP, 2.0 HP/s) has 400s drain-only survival vs 135s target. Later floors: F22 Warrior has 800/5.5 = 145s vs 285s target. Camping kills on later floors by construction.
- **Spawn-sniping:** §7 gate: no generator holds LOS to spawn; none reachable without crossing a guarded cell (within 4 tiles of a live generator).
- **Axe-wading:** 5 grunts deal 5×15 = 75 dmg/0.5s = 150 dmg/s. Warrior kills 1 grunt per 0.83s (50 dmg, 30 HP). Net HP loss: ~125 dmg/s while wading. Sustained wading is arithmetically fatal.
- **Arrow-kiting:** Elf (192 px/s) vs Demon projectile (200 px/s, Lobber 220). Elf cannot outrun projectiles in open ground but can sidestep in 2-tile corridors. Ghosts (100 px/s, ignore walls) catch Elf in corridors. Kiting requires open rooms, which later floors restrict.
- **Bolt-spam:** Wizard splash (20+12=32) kills ghost packs fast but respawn cadence (min 1.5s) outpaces single-target kill rate. Killing a pack never closes its generator.
- **Global-cap exploit (closed):** The per-generator alive cap (6) means a speedrunner who fills one room's spawns does not suppress other rooms — each generator tracks its own alive count independently. Kiting 6 ghosts out of room A blocks room A's generator but leaves rooms B and C producing. The per-floor cap of 28 bounds total concurrency for the frame budget; it cannot be weaponized to neutralize the dungeon.
- **Pacifist food-rushing:** Floor clear bonus is flat +500 (no HP multiplier). Every kill adds score (10–200). Skipping combat foregoes 200–2000 score per floor. Combat is always score-positive. The drain clock, not score, punishes dawdling.
- **Warrior pierce vs Wizard splash:** Warrior axe: 60 DPS per target (50 × 1.2), piercing everything along its 5-tile line. Wizard bolt: 24 DPS on its target (20 × 1.2) plus 14 DPS (12 × 1.2) to each additional enemy within the 1-tile splash. Single target: Warrior wins outright. Packed cluster of 4+: Wizard totals 66+ and wins. Corridor file: Warrior's pierce multiplies. Geometry — files vs packs — rotates which kit dominates, by design.

---

## 4. Economy

**None.** One $5.99 purchase. No IAP, no ads, no premium currency, no DLC, nothing purchasable ever. The complete list of things that are not currency:

- **Score** — measurement only. Never spent, converted, or used to unlock.
- **Keys** — in-floor pickups, consumed by their door, never persist beyond floor.
- **Potions** — in-floor pickups, cap 3, carried between floors within a run, zeroed on continue. Not currency.
- **Food** — eaten on contact for HP. Cannot be banked, traded, or stockpiled.
- **Continue tokens** — 2 per floor entry, refreshed only by reaching a new floor. Never buyable.
- **Completion laurels** — cosmetic markers on the score table. Not currency, not unlock gates, not spendable.

Any later phase wanting currency amends this section through OP-2 before any code exists.

---

## 5. Reward schedule

**Fixed-ratio only. Fully deterministic. No variable-ratio schedules exist in HUNGERHALL.** The table is the whole truth:

| Event | Reward | Emphasis |
|---|---|---|
| Ghost kill | +10 | Small: sprite pop + floater |
| Grunt kill | +25 | Small |
| Demon kill | +40 | Small |
| Lobber kill | +50 | Small |
| Sorcerer kill | +60 | Small |
| Death kill | +200 | Medium: 2-frame freeze + voice |
| Generator destroyed | +100 | Medium: 4-frame freeze, 2px kick, voice, caption |
| Treasure chest | 100, 250, or 500 (baked per floor, deterministic) | Small; value printed instantly on open |
| Food pickup | +150 HP (not score) | Small: HP ticks up + caption |
| Floor clear | +500 flat | Large: results panel + jingle |
| Campaign clear | +2000 | Largest |
| Death | −20% of floor-entry score (flat per death, see §2) | Red rolling deduction, shown plainly |

**Chest determinism:** Chest values are assigned at bake time by the floor generator and frozen into shipped data. Every player finds the same chests at the same positions with the same values. The value is printed the frame the chest opens. No anticipation window, no teetering animation, no implied proximity. This is fixed-ratio with deterministic payout, not variable-ratio.

**Near-miss honesty:** Nothing animates "almost." Every bonus and deduction displays exact arithmetic. If +100 appears, the generator is gone. If the announcer says "FOOD," HP is actually restored. Audit surface: clean by construction.

---

## 6. Retention hooks

**FAIR only. The complete pull list:**

1. **Local score table** — three-letter initials, 8 entries per class, with a separate table for NewGame+ runs. No online leaderboard, no friend comparison, no external pressure.
2. **Between-floor save/resume** — quit after any FloorResults; resume later at next floor entrance. No penalty for skipping a day or a month.
3. **Four completion laurels** — one per class, cosmetic and non-mechanical. Invites four-class replay. Same baked layouts mean the replay envelope is class combat rhythm, not spatial exploration. Acknowledged honestly: 3-of-4 class runs cover identical floor geometry. The variety is in how each class pays the HP bill, not in discovering new rooms.
4. **NewGame+** — unlocked globally on campaign clear (any class unlocks for all classes). A second baked floor set, assembled at bake time from the same cell pool with different seeds and retuned parameters, then frozen: enemy HP ×1.5, spawn rate ×1.3 (interval ÷1.3), food reduced 20% (floor(pieces × 0.8), minimum 1 piece per floor), drain +0.5 HP/s per band. All 7 hand-built floors are reused with their original layouts and the retuned NG+ parameters applied to their baked entity data — they are not replaced or skipped, and no new hand-authoring is required. The NG+ floor set runs through the same solver verification as the base campaign during the bake pipeline, with NG+ parameters; failure triggers parameter retune, not layout edits. Runtime remains zero-RNG. Doubles replayable lifetime without new content creation.
5. **Identical baked floors** for every player. Household scores compare honestly because nobody got a luckier seed.

**Explicitly absent:** No dailies, no streaks, no countdown offers, no energy meters, no push notifications, no punishment for absence, no "come back in 24 hours" gate.

The honest sentence: **players return because playing felt good, never because leaving hurt.**

---

## 7. Content scaling

**Hybrid: bake-time procedural assembly from hand-authored room cells, plus 7 fully hand-built floors.** Deterministic everywhere: floors generated, solver-checked, frozen into shipped data. Runtime contains zero layout RNG. Identical floors ship for all players.

**24 floors, 4 zones of 6.** Justification: 18 floors delivers ~72 min floor play, risking "extended demo" perception at $5.99. 30 floors risks scope inflation past commercial_focused. 24 floors at 4 zones × 6 delivers ~90–96 min floor play + ~30 min overhead ≈ 2h00m–2h06m, hitting the 2-hour bar with headroom over 18. Four zones provide four climactic capstones (F6, F12, F18, F24) instead of three, strengthening the pacing arc.

**Zone identity:** Drowned Vaults (wet stone, no hazards) → Cindercrypt (flame jets) → Starved Deep (void bridges) → The Hollow Throne (collapsing void). Hazard contracts are pinned in §1.

**Hand-built 7, each earning its slot:**

| Floor | Role |
|---|---|
| F1 | Teaches move/throw/kill/generator through shape alone |
| F2 | First key/door gate; food placement forces first greedy-detour |
| F3 | Potions and treasure; first overlapping generator pair |
| F6 | Zone-one capstone; every taught verb examined simultaneously |
| F12 | Zone-two capstone; Lobber-over-wall + Sorcerer combined arms |
| F18 | Zone-three capstone; Death + twin generators + void bridge |
| F24 | Finale: Death, three generators, sealing exit, collapsing void |

**Procedural 17 (F4, F5, F7–F11, F13–F17, F19–F23):** Assembled from 48 authored room cells (12 per zone). Cell schema: each cell is 12×12 tiles with ports on N/S/E/W (2-tile wide openings), tagged by zone ID and type (corridor, arena, choke, treasure, hub). Inter-cell compatibility rule: ports must align (same position on shared edge). Authoring rules: (1) every cell has at least one path from any port to any other port; (2) no cell contains a generator within 4 tiles of a port (prevents spawn-sniping from adjacent cells); (3) all corridors within a cell are ≥2 tiles wide (enforces solver gate 4 at the authoring level); (4) treasure cells contain exactly 1 chest.

**NewGame+ content:** a second baked floor set assembled from the same 48 cells with different seeds and the §6 retuned parameters, frozen at bake time — runtime remains zero layout RNG. All 7 hand-built floors are included in the NG+ set with retuned parameters applied to their baked entity data. The NG+ set passes the same solver gates with NG+ parameters before shipping.

**Bake-time solver specification (structural + budget check, not dynamic simulation):**

The solver is a static gate, not a survival proof. It performs two checks:

1. **A* reachability** on the tile grid with drain-time edge weights (traversal time × drain rate per tile). No combat edge weights — combat enters as a band-constant budget, not a per-tile weight. Verifies the spawn-to-key-to-door-to-exit path exists.
2. **Static HP budget:** `(drain × target_mid + combat_damage_estimate) ≤ (min_class_HP + food_pieces × food_HP − margin_HP)`, where `margin_HP = 52` (10% of Wizard max 520). "≥10% margin" means remaining HP at exit ≥ 52 HP — an absolute number, not a percentage of current HP.

**Minimum-skill agent definition (for the G2.1 Monte Carlo):** the simulated agent moves greedily toward the nearest objective (key, then door, then exit), attacks the nearest enemy within 3 tiles, and consumes any food on contact. It does not dodge projectiles, kite, or use potions. This is the floor of survivability; any human player should outperform it. Dynamic survival validation is the G2.1 Monte Carlo's job (FIX-153); until it lands, `combat_damage_estimate` is a hand-set constant per band, accepted as provisional — a known dependency, acknowledged rather than hidden.

**Solver gates (full list):**
1. Spawn-to-key-to-door-to-exit reachability via A*.
2. No generator holds LOS (unobstructed raycast on tile grid between tile centers) to player spawn.
3. No generator reachable without crossing a guarded cell (any tile within 4 tiles of a live generator).
4. All corridors ≥2 tiles wide (enforced at cell authoring, verified at assembly).
5. Food per §3 formula (with margin term).
6. Concurrency ceiling: 6 alive per generator, 28 alive per floor.
7. Static HP budget yields ≥52 HP remaining at exit for the Wizard.
8. Collapsing-void safety: critical path requires no backtracking over collapsed tiles; every collapsible region retains a valid bounce/teleport tile.
9. The NG+ floor set passes gates 1–8 with NG+ parameters during the bake pipeline.

**Regeneration:** Max 200 attempts per floor. If exceeded, the floor is rejected and the author is notified to expand the cell pool. Fail-closed: no floor ships unchecked.

**Godot architecture contract (per godot-4-architecture skill):**

- **Pure rules layer:** `RulesFloor`, `RulesPlayer`, `RulesEnemy`, `RulesGenerator`, `RulesHazard`, `RulesSession` as `RefCounted` objects. No viewport, input, animation, or frame-rate dependency. Seeded PRNG owned by `RulesFloor`; all randomness flows from the floor seed.
- **Session state machine:** Single autoload `SessionStateMachine` (the only autoload) owns menu/play/pause/results/transition states. Scene nodes request transitions; they do not invent flow.
- **Bot seam:** `ci/sneferu_bot.gd` ships as a `SceneTree` script calling `RulesSession.input(action)` with semantic actions `{move: Vector2, attack: bool, potion: bool, pause: bool}`. After each action, reads `RulesSession.snapshot()` returning `{state, hp, score, floor, position, enemies, generators, tokens, food_positions, key_positions, door_positions, exit_position, hazards}`. Fixed step: 60 Hz, max 21,600 steps per floor (360s = 6 min, 20% headroom over the F22–24 upper target of 300s). Bot policies: greedy-killer, speed-runner, survival-router. **Timeout behavior:** if the bot exceeds the step budget, telemetry records `outcome: "timeout"` and the floor is flagged for review — timeout is a validation signal, not a product failure. Telemetry written atomically (temp-file + rename) to the orchestrator-provided absolute path as `playtest_telemetry_v1` JSON with fields: `seed, class, actions, floor, hp_trace, kills, outcome, version_hash`.
- **Replay format:** `{seed: int, class: String, actions: [{frame: int, input: String}], version_hash: String}`. Input strings map to the semantic action API: `"move_N"`, `"move_NE"`, `"move_E"`, `"move_SE"`, `"move_S"`, `"move_SW"`, `"move_W"`, `"move_NW"`, `"attack"`, `"potion"`, `"pause"`, `"resume"`, `"quit"`. Movement inputs encode the 8 semantic directions canonically (no float parsing); frames with no input are omitted. Replays record seed + ordered semantic actions + version hash, never raw coordinates.
- **Resource manifests:** `FloorData` (Resource: tile_grid, entity_spawns, food_positions, key_positions, door_positions, exit_position, chest_positions, chest_values, hazard_spawns, hazard_defs, target_seconds), `ClassDef` (Resource: hp, speed, shot_params, potion_params), `EnemyDef` (Resource: hp, speed, contact_damage, projectile, ai_type, spawn_cadence), `GeneratorDef` (Resource: hp, spawn_cadence, max_alive_per_generator, enemy_type), `HazardDef` (Resource: hazard_type enum [flame_jet, void_bridge, collapsing_void], damage, telegraph_seconds, trigger_type enum [periodic_cycle, phased_cycle, player_step], active_seconds, dormant_seconds, knockback), `TuningData` (Resource: drain_per_band, combat_estimate_per_band, spawn_cadence_per_band, generator_hp_per_zone). All loaded via `res://` with `ResourceLoader.load()`.
- **Asset delivery:** Sprites → `res://Assets/Sprites/{entity}.png` as `SpriteFrames`. Audio → `res://Assets/Audio/{cue}.wav` as `AudioStream`. Fonts → `res://Assets/Fonts/arcade.ttf` as `FontFile`. Tilesets → `res://Assets/Tilesets/{zone}.png` as `TileSet`. Replays → `res://Assets/Replays/attract.replay` as JSON text resource, captured during bake from a seed-locked bot run and validated by the solver before packaging. Import intent is pinned per family and committed as `.import` settings: 32px pixel-art textures import with filtering OFF, mipmaps OFF, repeat OFF, lossless compression, straight alpha; audio imports as WAV with loop flags per cue manifest; fonts import unfiltered. Programmer-art fallback: colored rectangles with silhouette-accurate proportions if generation is debt. No `.godot/imported` fabrication.
- **Pause behavior:** `PROCESS_MODE_PAUSED` for rules and presentation during Paused. UI uses `PROCESS_MODE_WHEN_PAUSED`. Drain stops. No time jump on resume (fixed 60 Hz delta resumes cleanly).

**Volume math:** Sum of target floor midpoints ≈ 5,400s = 90 min (upper bounds ≈ 5,760s = 96 min). Plus overhead ≈ 30 min. Total ≈ 2h00m–2h06m. Escalation from encounter combination, never corridor padding.

---

## 8. Accessibility floor

All six items, adapted to a desktop title:

1. **Color-blind safety:** Palette and sprites validated under deuteranopia, protanopia, tritanopia simulation in pipeline screenshot tests. **Pass criterion:** an automated contour comparison runs each zone's enemy roster through all three color-blindness simulation filters and compares silhouette outlines; pass requires ≥90% contour separation between every threat pair in every zone palette, without hue information. Threats differ by silhouette and motion, never hue alone: ghosts small and swarming, grunts square and lumbering, demons tall and robed, Death hulking. Keys and doors pair palette with shape plus icon. Health reads as numeral + bar + screen-edge pulse. 8-color safe palette throughout.

2. **One-handed playability:** Full input remapping plus shipped one-hand layouts for left keyboard, right keyboard, and single-hand gamepad (left stick + L1/L2 for attack/potion). Optional auto-fire, disclosed on the options screen as "Easy Mode Assist": when enabled, holding the attack input auto-fires at the nearest enemy within 8 tiles at the class's base rate; a 15° aim-assist cone redirects to the highest-HP threat in range if multiple are present; the assist never targets generators or treasure. Gates nothing — no content, no achievements, no score penalty, and the score table does not flag assist runs. Menu navigation with one stick + one button.

3. **Font-size minimums:** Body text 22px minimum at 1920×1080 baseline (16pt equivalent). Critical CTAs ("CONTINUE?", "NEXT FLOOR", "GAME OVER") at 30px minimum (22pt equivalent). HUD health and score numerals at 40px minimum. Scales with resolution.

4. **Reduced-motion option:** One toggle zeroes screenshake, caps freeze-frames at 2 frames, replaces full-screen flashes with soft vignette pulse, halves particle counts. Attack animations still play. Camera static. Found in pause menu accessibility sub-panel.

5. **No audio dependency:** Every announcer line carries a simultaneous caption held ≥2s. Low-health heartbeat has a screen-edge red pulse. Generator destruction triggers a rim flash on the HUD frame. Key pickups flash the HUD icon. Enemy spawns produce a dust puff visible without sound. Flame jet telegraph is visual (flame-grow), not audio. Void bridge phasing is visual (tile glow), not audio. Entire game completable with audio muted. Captions mirror announcer words (not additional text), keeping the tutorial word count at 11 words.

6. **Haptics opt-out:** Master rumble toggle plus 0/50/100% intensity steps. All haptic feedback supplemental; no information absent from visual or audio. When off, no rumble events fire.

---

## 9. Anti-cheat

**Trivial case, documented.** HUNGERHALL is offline single-player with a local score table, no IAP, no economy, no servers. Trust model: client-only. The player's machine is authoritative.

**Declared exposure:** Memory editors can inflate local scores and modify save files. Risk accepted and stated plainly. Tampering harms no other player and touches no monetary surface.

**Save integrity:** Autosave writes only on FloorResults entry, so no mid-floor save exists to copy or scum. Mid-floor quit discards the interrupted floor entirely. GameOver preserves the campaign save at the last completed floor with the score restored to that floor's FloorResults total; the high-score table entry is committed separately with the final post-penalty score. Retrying a failed floor is possible, but banking score from an incomplete run is not. The acknowledged residual exploit — quitting mid-floor to retry without the 20% death penalty — harms no other player and is accepted per the trust model.

**Bot telemetry reconciliation:** Playtest bots (`ci/sneferu_bot.gd`) write `playtest_telemetry_v1` JSON atomically to the orchestrator-provided absolute path during pipeline validation. Fields: `seed, class, actions, floor, hp_trace, kills, outcome, version_hash`. Retention: telemetry persists for the pipeline run only; no player-facing telemetry exists in the shipped product. The "zero telemetry" stance refers to the shipped game, not the pipeline validation tooling.

**Consequences:** No anti-tamper, no kernel drivers, no DRM beyond Steam's default wrapper. A hash check on the local high-score table detects corruption but is not a security measure. If online leaderboards are proposed, this section rewrites through OP-2.

---

## 10. Open questions for the prototype

1. **Drain calibration.** One 90-second room, two generators, two food pieces. A/B test drain at 1.5, 2.0, 2.5 HP/s. Which reads "urgent, not panicked"? Pass: first move under 3s, at most one death in 90s, tester mentions the falling numeral unprompted. Buildable in 30 min.

2. **Aim scheme on gamepad.** Face-fire (8-way, authentic to 1985) vs right-stick twin-stick override, 20 kills each. Does 1985 authenticity survive 2026 thumbs? Measure clear time and count miss-frustration events. Buildable in 30 min.

3. **Announcer density.** Ten-minute soak at three gating policies: uncapped, 8s cooldown, 20s cooldown. Where does the synth voice stop being charm and start being noise? Winner becomes production default. Buildable in 30 min.

4. **Crowd legibility at period fidelity.** 28 concurrent enemies (the per-floor cap) at 32px scale and period palette: can a fresh player name the highest-threat enemy correctly three times running? Failure triggers outline or rim-light deviation from period purity. Paired with a 60fps smoke test at the concurrency ceiling. Buildable in 30 min.

**G7 definition of done:** One-floor prototype passing the 60-second contract (first input ≤5s, first success ≤15s, first delight ≤30s, food beat ≤30s), producing a verifiable replay file, and sustaining 60fps with 20+ on-screen enemies.

---

## 11. Game feel & juice intent (the premium bar)

**Core verb: the throw.** The ~100–400ms contract, per channel:

- **On press:** Projectile exists on input frame. 3-frame arm pose, 1-frame muzzle flash, light haptic (0.2 intensity, 30ms). Audio: class-specific synth sound (Warrior: bass thud; Valkyrie: metallic clink; Wizard: electric zap; Elf: string pluck). Pitch jittered ±5% so repeated throws never machine-gun identically.

- **In flight:** 320 px/s (Warrior axe 260 px/s, 4-frame tumble cycle). 2px motion trail. Inertia-free direction changes squash sprite 1.05× for 2 frames. Dust puffs every 12px.

- **On contact:** Target flashes white 2 frames. 8px knockback over 80ms ease-out. Medium haptic bump. Damage number in 8-bit font rises 24px over 400ms ease-out with slight overshoot, then fades. 3–5 pixel debris particles burst tangent to impact, colored to enemy palette, gravity 0.5, 200ms lifetime.

- **On kill:** Sprite bursts into 5±2 pixel chunks (200ms, gravity-affected). Floater climbs with ease-out. Impact audio rises one semitone. 0.2 trauma screenshake for 4 frames. Controller medium tap.

**Food pickup beat (the survival reward):** HP ticks up in three 50-HP increments over 0.3s (not instant), capped at class max. If HP is already at class max, the food is still consumed with no tick-up and no floater — spent silently, no waste indicator. "FOOD" caption appears, holds 2s. Audio: short blip rising one semitone per tick. Small green particle puff (3 particles, 150ms). No screenshake. No haptic. This is relief, not spectacle. The player feels the clock slow.

**Named freeze-frame — the generator burst (standard tier, all floors):** 4 frames absolute hitstop. 2px trauma-based camera kick decaying over 200ms. 10-pixel orange particle ring. Announcer barks class-addressed line with caption. 150ms rumble. +100 floater scales up from center with ease-out-back.

**Zone capstone juice (escalation tier, F6/F12/F18):** 6 frames hitstop. 4px camera kick. 20-particle ring in zone color. Extended announcer line. 200ms rumble. Results panel uses zone-themed border. This is the mid-campaign heartbeat.

**Penultimate tier (F19–F23):** 5 frames hitstop. 3px camera kick. 15-particle ring in zone color with white core. Shortened announcer line (clipped, urgent). 175ms rumble. Applied to floor-clear and generator-burst events on F19–F23 only. Sustains escalation toward the finale without breaking the climax tier's exclusivity — the player feels the floor clear but senses something bigger is coming.

**F24 finale juice (climax tier):** 8 frames hitstop. 6px camera kick. 30-particle ring. Campaign-clear jingle layers over announcer. Full 300ms rumble. Screen-wide white flash (vignette pulse under reduced motion). This is the only moment that breaks the standard tier, and it earns it.

**Potion beat (the panic button):** 6-frame freeze. White flash capped at 100ms (vignette under reduced motion). 150ms full rumble. 4-tile (Warrior) to 5-tile (Wizard) radial burst. 0.28 trauma screen punch. Class-specific audio: Warrior roar, Valkyrie shield clang, Wizard arcane boom, Elf arrow storm. This is the player's emergency and it must feel like one.

**Readability at a glance:** Threat ladder is silhouette-first: small swarming ghost, square lumbering grunt, tall robed demon, hulking Death. Generators pulse 2px rim and blink on spawn cycle. Pickups bob on 4-frame sine. Player sprite carries 2px dark outline against every tileset. HP numeral top-left 40px. Score top-center 40px. Camera: dead-zone follow with 16px lead toward travel direction. No rotation, no drift. A stranger reads room, threat, and goal in one glance with zero text.

**The 60-second sentence:** *"It's eating me alive — keep moving, keep throwing."* Earned at T+25 of floor 1: second axe lands, four frames freeze, room kicks 2px, +100 floats, synth voice growls the pit line. At T+28 the first food piece restores HP and the clock briefly slows. If a playtester passes T+60 without voicing the pressure, this section has failed and the beat is retuned before anything else ships.

**Audio feel:** 8-bit percussion layers add with nearby-enemy count (aesthetic only, no exclusive mechanical info per §8 item 5). Announcer ducks music 6dB. Priority interrupts reserved for death and health-critical. Register: period speech synthesis, short clauses, flat cadence, class-addressed, original lines only. Sample: "THE WARRIOR ENTERS HUNGERHALL." / "WARRIOR HUNGERS." / "THE ELF CARRIES A KEY." / "THE VAULT DEVOURS THE WIZARD."

G9 turns every number here into implementation parameters. G10 builds them. G7's prototype answers §10 against them.

---

## Obligation Responses

OBL-101: ADDRESSED — §6/§7: all 7 hand-built floors reused in NG+ with original layouts and retuned parameters applied to baked entity data; not replaced, not skipped, no new hand-authoring.
OBL-102: ADDRESSED — §1 EARS + state table + §2: continue sets "player position set to floor entrance spawn tile" explicitly.
OBL-103: ADDRESSED — §1: Elf Volley fires all 12 arrows simultaneously in one frame at 30° intervals from current facing; freeze per §11 potion beat.
OBL-104: ADDRESSED — §8 item 2: auto-fire at nearest enemy within 8 tiles at class base rate; 15° aim-assist cone to highest-HP threat; never targets generators or treasure; gates nothing.
OBL-105: ADDRESSED — §7: solver is a static drain-weighted A* reachability + HP budget inequality; combat estimate is a band constant, not edge weights; dynamic validation deferred to G2.1.
OBL-106: ADDRESSED — §11: penultimate tier for F19–23 (5-frame hitstop, 3px kick, 15-particle ring, 175ms rumble), scoped to floor-clear and generator-burst events.
OBL-91: ADDRESSED — §1 EARS requirement explicitly states "player position set to floor entrance spawn tile."
OBL-92: ADDRESSED — §3: food formula adds margin_HP = 52; F1–3 yields 3 pieces (38.5% margin); all eight bands pass the ≥10% gate; food column is formula output.
OBL-93: ADDRESSED — §1: Generator stat block table with per-zone HP (60/90/120/160) and cadence; GeneratorDef resource in §7.
OBL-94: ADDRESSED — §2: death penalty is flat 20% of floor-entry score, explicitly non-compounding, with worked example (1000 → 800 → 600).
OBL-95: ADDRESSED — §7: bot max steps 21,600 (360s), 20% headroom over hardest 300s floors.
OBL-96: ADDRESSED — §1: Sorcerer blink "visible" = LOS from Sorcerer's position to candidate tile via tile-grid raycast; no valid tile → blink cancelled, cooldown still applies.
OBL-97: ADDRESSED — §1: Lobber projectile collision mask = player hitbox only; no friendly fire.
OBL-98: ADDRESSED — §6: NG+ food = floor(pieces × 0.8), minimum 1 per floor; solver-verified with NG+ parameters.
OBL-99: ADDRESSED — §1 hazard contracts (damage/telegraph/trigger per type) + §7 HazardDef typed resource + FloorData hazard_spawns.
OBL-1: ADDRESSED — §1 generator stat block with per-zone HP scaling; GeneratorDef resource with typed fields.
OBL-2: ADDRESSED — §1 EARS and §2 both state "player position set to floor entrance spawn tile" on continue.
OBL-3: ADDRESSED — §7: minimum-skill agent defined (greedy objective chain key→door→exit, attacks nearest enemy within 3 tiles, eats food on contact, never dodges/kites/uses potions).
OBL-4: DEFERRED — G2.1 Monte Carlo (FIX-153) is a named upcoming pipeline deliverable; combat estimates flagged as provisional hand-set constants until wired.
OBL-5: ADDRESSED — §1 state table + EARS: Playing → Finish → CampaignResults when floor == 24, distinct from Clear → FloorResults.
OBL-6: ADDRESSED — §7: cell authoring rule (3) requires all corridors ≥2 tiles wide at cell level, verified at assembly (solver gate 4).
OBL-7: ADDRESSED — §1: flame jet, void bridge, collapsing void contracts with damage, telegraph, trigger, and bounce/teleport fallback.
OBL-8: ADDRESSED — §7: bot timeout records outcome: "timeout", floor flagged for review; validation signal, not product failure.
OBL-9: ADDRESSED — §7: replay input strings are canonical semantic keys ("move_N"…"move_NW", "attack", "potion", "pause", "resume", "quit"); no float parsing.
OBL-10: ADDRESSED — §6: NG+ unlock global (any class unlocks all); separate NG+ score table, 8 entries per class.
OBL-11: ADDRESSED — §1: Death touch aura damages all adjacent entities including enemies; Death immune to own aura.
OBL-12: ADDRESSED — §1: blink perspective is the Sorcerer's LOS to the candidate tile, not the player's.
OBL-13: ADDRESSED — §7 agent definition + §3 margin-term formula; F1–3 contradiction resolved (3 pieces, 38.5%).
OBL-14: ADDRESSED — §1 generator stats + hazard contracts; §7 GeneratorDef + HazardDef resources in manifest.
OBL-15: ADDRESSED — §1/§2: respawn tile explicit, CampaignResults transition, potions_remaining in save schema, flat death penalty.
OBL-16: ADDRESSED — §1: Valkyrie reduction reframed — velocity within ±30° of direction to nearest enemy within 7 tiles; advancing-only, aim-scheme independent, retreat-kiting closed.
OBL-17: ADDRESSED — §1: per-generator alive cap 6 + per-floor cap 28; multi-generator rooms raise refill, not peak.
OBL-18: ADDRESSED — §7: bot step budget 21,600 (360s), 20% headroom over the 300s upper target.
OBL-19: ADDRESSED — §6: NG+ food floored with minimum 1; unlock scope global; separate NG+ table.
OBL-20: ADDRESSED — §7: solver explicitly named a static budget check (drain-weighted A* + HP arithmetic), not a dynamic combat simulation.
OBL-21: ADDRESSED — §1: per-generator cap 6 closes the room-A-fills-cap exploit; per-floor cap 28 retained for the frame budget; §3 rebuttal documents the exploit and its closure.
OBL-22: ADDRESSED — §2: GameOver preserves save at last completed floor with score restored to last FloorResults total; failed-floor score lost; mid-floor-quit equivalence acknowledged as accepted risk per §9.
OBL-23: ADDRESSED — §3: food formula wrapped in max(1, ...) preventing zero/negative food generation.
OBL-24: ADDRESSED — §1: Lobber projectile travels a straight line at 220 px/s; visual arc cosmetic; ignores wall collision; player-only mask.
OBL-25: ADDRESSED — §7: attract.replay shipped at res://Assets/Replays/attract.replay, bake-captured from a seed-locked bot run on floor 1, solver-validated before packaging.
OBL-26: ADDRESSED — §1 EARS and §2 both state the floor entrance spawn tile on continue.
OBL-27: ADDRESSED — §7: static budget check defined now; G2.1 runs the defined conservative bot policy against baked floors before acceptance.
OBL-28: ADDRESSED — §7: solver gate 9 requires the NG+ floor set to pass all gates with NG+ parameters during the bake pipeline.
OBL-29: ADDRESSED — §7: margin defined as remaining HP ≥ 52 (10% of Wizard max 520), an absolute number, not a percentage of current HP.
OBL-30: ADDRESSED — §8 item 1: automated contour comparison requires ≥90% silhouette separation between all threat pairs per zone under all three CVD simulations.
OBL-31: ADDRESSED — §7: bot snapshot extended with food_positions, key_positions, door_positions, exit_position, and hazards for the survival-router policy.
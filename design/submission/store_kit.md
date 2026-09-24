# HUNGERHALL — G14 Steam Store Submission Kit

**Run:** gap-253b64a1 · **Phase:** G14 · **Engine:** Godot 4.7 · **Platform:** Steam (Windows export) · **Price:** $5.99 USD · **Locale:** en

**Platform law:** Steam-native submission kit. Steam fields govern every section. App Store Connect field limits are retained as internal discipline (30/30/170/4000/100) for any future qualified iOS port and exercised in Appendix A.

**Truth sources:** G1 (concept), G2 (mechanics), G3 (voice), G4 (art), G7/G10 (code), G13 (money).

**Register:** G3 house voice. Dry, courteous, third person. No exclamation marks, no em-dashes, no banned vocabulary, no Atari names, no "X NEEDS FOOD" constructions.

---

## 0. Freeze-State Declaration

This kit ships under a declared default binary configuration. All SHIP copy is internally consistent under this default. If any freeze-state decision changes, apply the documented upgrade deltas to the affected sections. The kit is paste-ready under the default state.

| Decision | Default | Upgrade path | Upgrade delta |
|----------|---------|--------------|---------------|
| GodotSteam | DISABLED (Path B) | If compatibility with Godot 4.7 verified, enable Path A | §10: add Steamworks SDK to disclosure and privacy policy. §11 Q5: qualify "Steam client need not be running." §3/§4: no copy change needed (game itself collects nothing either way). |
| Audio | ABSENT | If G10 B1 passes with minimum 5 event-type clip coverage (GENERATOR DOWN, FOOD, KEY, death, level transition) | §3 "Building Speaks": replace audio-absent text with audio-present text. §13: replace "captioned announcer callouts" with "the announcer voice." §12: replace feature bullet with audio-present variant. |
| Demo | NOT PUBLISHED | If demo build covering floors 1-3 is published and linked | §11 Q8: replace no-demo variant with demo-live variant. §4: no change (demo not mentioned in short description). |
| Renderer | Vulkan (Godot 4.7 Forward+) | N/A — pinned to engine default | System requirements specify Vulkan. If project switches to Compatibility renderer, update to OpenGL 3.3 and re-profile. |
| IARC rating | PENDING | Returned rating inserted into §9.1 | If rating ≠ E10+/PEGI 7, update §9 and store page per §9.2 fallback. |
| DRM | No wrapper applied | If operator applies Steam DRM wrapper | Update §10.1 and §10.4. |

**Upgrade principle:** The default is always the most conservative claim. Upgrades add capability, never subtract truth.

---

## 1. Title candidates

Fifteen candidates, each ≤30 chars. Steam has no published hard 30-char app-name limit, but the discipline is retained. Scores: memorability /10 · ASO keyword value /10 · trademark hazard (Fermi flag, never clearance).

| # | Candidate | Chars | Mem | ASO | Trademark hazard |
|---|-----------|-------|-----|-----|------------------|
| 1 | HUNGERHALL | 10 | 9 | 6 | LOW-MEDIUM. Compound neologism. "Hunger" sits near The Hunger Games. FLAG: formal USPTO/EUIPO/UKIPO clearance required. |
| 2 | HUNGERHALL ARCADE | 17 | 7 | 8 | LOW. Generic descriptor. |
| 3 | HUNGERHALL: SOLO DESCENT | 24 | 7 | 5 | LOW. Descriptive. |
| 4 | HUNGERHALL: DINE OR DIE | 23 | 8 | 3 | LOW. Phrase check required. |
| 5 | ALL ARE EATEN | 13 | 8 | 3 | LOW. Locked title-screen tagline. |
| 6 | THE HUNGERHALL | 14 | 7 | 5 | LOW. Article adds no search value. |
| 7 | HUNGERHALL: 24 FLOORS | 21 | 5 | 3 | LOW. Numerals weak for search. |
| 8 | THE HALL HUNGERS | 16 | 7 | 2 | LOW. Weak mark. |
| 9 | DUNGEON SUPPER | 14 | 6 | 6 | LOW. Comic tone drift. |
| 10 | HUNGERHALL: THE MENU | 20 | 6 | 2 | LOW. Voice-forward. |
| 11 | HUNGERHALL SOLO | 15 | 5 | 4 | LOW. |
| 12 | HUNGERHALL: NO QUARTERS | 23 | 6 | 2 | LOW. |
| 13 | SERVICE FOR ONE | 15 | 7 | 2 | LOW. No search value. |
| 14 | HUNGER HALL | 11 | 6 | 5 | MEDIUM. Split form reads closer to The Hunger Games. FLAG. |
| 15 | GAUNTLET HEIR | 13 | 5 | 4 | HIGH. Active Atari mark. Rejected. |

**SHIP — Recommended pick: HUNGERHALL (10 chars).** Frozen across G2 (title), G3 (title.logo string key), G4 (capsule art), and the G7/G10 code (string manifest, announcer phonetic guide, attract replay). Short, speakable, ownable, legible at capsule thumbnail size.

**SHIP — Runner-up: ALL ARE EATEN (13 chars).** Already the locked title-screen tagline. If the trademark search on HUNGERHALL returns a collision, switching requires a scoped migration: update G2 title field, G3 title.logo string key, G4 capsule art render, G7/G10 string manifest, and the announcer phonetic guide. Budget one sprint for the rename across all five layers before invoking the fallback. If both HUNGERHALL and ALL ARE EATEN collide, halt and run a new G14 §1 title cycle.

**The name string used verbatim in every section below is: HUNGERHALL.**

**Pre-freeze verification:**
- Trademark clearance: USPTO/EUIPO/UKIPO searches in classes 9 and 41 for HUNGERHALL and ALL ARE EATEN, plus Steam store search. No search results are in the corpus. Operator must complete formal searches with written results before upload freeze. Owner: operator. Deadline: store freeze. The Lionsgate Hunger Games franchise is the named collision risk for candidates 1 and 14. This kit flags hazards; it does not clear marks.
- Steamworks app-name limit: confirm current limit against Valve documentation before freeze. No published hard limit is documented in the corpus. Owner: operator. Deadline: store freeze.

---

## 2. Subtitle

Steam has no subtitle field. These candidates feed the Steam short description opening (§4). Five candidates, each ≤30 chars (internal discipline).

| # | Candidate | Chars | Notes |
|---|-----------|-------|-------|
| 1 | Solo Arcade Dungeon Crawler | 27 | RECOMMENDED. Four head terms: solo, arcade, dungeon, crawler. "Solo" answers the first question a Gauntlet-familiar buyer asks. |
| 2 | Arcade Dungeon Crawler | 22 | Cleanest. Three genre terms. Drops the single-player signal. |
| 3 | Retro Arcade Dungeon Crawler | 28 | Swaps solo for retro. Covers nostalgia cohort, loses co-op disambiguation. |
| 4 | 1985 Arcade Dungeon Crawler | 27 | Year carries nostalgia cohort. Loses solo. |
| 5 | Four Classes, One Hungry Hall | 29 | Voice register. Zero search value. |

**SHIP — Recommended opener: Solo Arcade Dungeon Crawler (27 chars).** Maps to the opening phrase of the short description in §4. "Solo" closes the co-op assumption that is the first buyer question for a Gauntlet-like. "Singleplayer" is reserved for the Steam tag (§5.1).

---

## 3. Description (long)

Steam detailed description. No hard character limit (~8000 chars practical). Uses Steam BBCode formatting for scannability. First three lines are plain text (Steam's unexpanded preview).

### 3.1 SHIP — Default description (audio-absent, paste into Steamworks "Detailed Description")

```
[h1]HUNGERHALL[/h1]

A solo arcade dungeon crawler. One player pays the full health bill that four once shared. Your health bar is the only clock. It drains every second. Standing still spends it. Moving forward risks it. Eating buys it back.

[h2]Tonight's Menu[/h2]

Four classes sit at the table. The Warrior takes the bite and keeps swinging. The Valkyrie holds lanes and weathers fire. The Wizard clears groups but cannot shake a single pursuer. The Elf outranges everything and starves in close. No upgrades. No skill trees. The class you choose is the kit you keep.

[h2]The Contract[/h2]

[list]
[*]Generators spill enemies until you push in and break them.
[*]Food restores health, never returns, and hides behind guards.
[*]Keys open the exit door.
[*]Treasure adds score, never safety.
[/list]

[h2]The Building Speaks[/h2]

Every event prints a caption. GENERATOR DOWN when a source breaks. FOOD when a plate lands. KEY when iron turns up. The building speaks in text, flat and polite, the way a menu reads the specials.

[h2]Twenty-Four Floors[/h2]

[list]
[*][b]Drowned Vaults:[/b] wet stone, ghosts through walls.
[*][b]Cindercrypt:[/b] flame jets, lobbers over cover.
[*][b]Starved Deep:[/b] bridges over nothing, Death taking a seat.
[*][b]The Hollow Throne:[/b] collapsing floor, three generators, the last course.
[/list]

[h2]Score and Survival[/h2]

Score climbs with every kill. Death docks 20 percent of the score you carried into the floor, plain and visible. Two continues per floor. A continue rebuilds the floor at half health, no keys, every plate of food still gone.

The other three classes invite you back. New Game+ opens after a clean campaign clear.

[h2]Controls and Storage[/h2]

Keyboard and gamepad work at first boot. Move with the left stick, throw with a face button along your current facing. The Guestbook keeps local high scores and your initials. No online boards. No accounts.

One purchase. $5.99. No ads. No in-app purchases. No developer telemetry. Everything in the box.

HUNGERHALL. All are welcome. All are eaten.
```

### 3.2 Audio-present upgrade delta

If the audio freeze state upgrades to PRESENT (minimum 5 event-type clips verified in G10 manifest: GENERATOR DOWN, FOOD, KEY, death, level transition), replace the "The Building Speaks" section with:

```
[h2]The Building Speaks[/h2]

The announcer is the building. A 1985-style speech synth, flat and polite, marks major beats: GENERATOR DOWN when a source breaks, FOOD when a plate lands, KEY when iron turns up. The tone never changes. Captions carry every line.
```

No other section changes for the audio upgrade except §13 (release notes) and §12 (marketing bullet), which have their own documented deltas.

### 3.3 First three lines analysis

1. A solo arcade dungeon crawler. One player pays the full health bill that four once shared.
2. Your health bar is the only clock. It drains every second.
3. Standing still spends it. Moving forward risks it. Eating buys it back.

Line 1 delivers genre, player count, and the core differentiator (one player pays the full bill four once shared). Line 2 is the central mechanic. Line 3 is the consequence and the solution. No throat-clearing.

**Measured: approximately 2,150 chars including BBCode tags.** Ample headroom in the ~8000-char practical budget.

### 3.4 Claim-to-evidence traceability matrix

Claims marked Verified (present in G-source), Pending (awaiting verification against final build), or Removed (fabricated, cut from kit).

| Public claim | G-source | Status |
|-------------|---------|--------|
| HUNGERHALL (title string) | G2, G3, G4, G7/G10 | Verified |
| Solo arcade dungeon crawler | G1 concept | Verified |
| One player pays the full health bill that four once shared | G1 concept, G2 positioning | Verified |
| Health bar is the only clock | G1 AC, G2 §4 | Verified |
| Drains every second | G2 §4 | Verified |
| Four classes: Warrior, Valkyrie, Wizard, Elf | G1, G2 §2 | Verified |
| Warrior: takes the bite, keeps swinging | G2 §2 class profile | Verified |
| Valkyrie: holds lanes, weathers fire | G2 §2 class profile | Verified |
| Wizard: clears groups, cannot shake a single pursuer | G2 §2 class profile | Verified |
| Elf: outranges everything, starves in close | G2 §2 class profile | Verified |
| No upgrades, no skill trees | G1 out of scope, G2 §4 | Verified |
| Generators spill enemies, destructible, require push | G1 AC, G2 §4 | Verified |
| Food restores health, finite, no respawn | G1 AC, G2 §4 | Verified |
| Food hides behind guards | G2 §4 | Verified |
| Keys open exit door | G1 AC, G2 §4 | Verified |
| Treasure adds score, never safety | G2 §5 | Verified |
| Every event prints a caption | G3 | Verified |
| "GENERATOR DOWN" caption string | G3/G10 string manifest | Pending verification |
| "FOOD" caption string | G3/G10 manifest | Pending verification |
| "KEY" caption string | G3/G10 manifest | Pending verification |
| Captions carry every line | G3 | Verified |
| 24 floors, 4 themed zones | G2 §3 | Verified |
| Drowned Vaults: wet stone, ghosts through walls | G2 §3 | Verified |
| Cindercrypt: flame jets, lobbers over cover | G2 §3 | Verified |
| Starved Deep: bridges over nothing, Death enemy | G2 §3 | Verified |
| The Hollow Throne: collapsing floor, three generators | G2 §3 | Verified |
| Score climbs with kills | G2 §5 | Verified |
| Death docks 20% of floor-entry score | G2 §5 | Verified |
| Two continues per floor | G2 §6 | Verified |
| Continue: half health, no keys, food still gone | G2 §6 | Verified |
| The other three classes invite you back | G2 §7 (replay with existing classes) | Verified |
| New Game+ opens after a clean campaign clear | G2 §7 | Verified |
| Keyboard and gamepad at first boot | G1 AC | Verified |
| Gamepad: left stick movement, face button throw | G2 input map | Verified |
| Guestbook: local high scores, initials | G2 §5 | Verified |
| No online boards, no accounts | G1 out of scope | Verified |
| $5.99, no ads, no IAP | G13, Operator Constraints | Verified |
| No developer telemetry | G2 §9, G7/G10 | Verified (Path B default; game itself collects nothing) |
| "All are welcome. All are eaten." tagline | G3 | Verified |
| HP numeral visible, ticks down | G7/G10 HUD | Pending verification |
| Class select stat rows visible | G7/G10 class_select.tscn | Pending verification |
| Floor results panel (time, kills, food, total) | G7/G10 floor_results screen | Pending verification |
| "SAVED" tag on floor clear | G7/G10 UI string | Pending verification |
| Attract replay on title screen | G7/G10 | Verified |
| Autosave at floor clear, resume between levels | G1 AC, G2 §6 | Verified |
| Thrown weapon projectiles (manual aimed throws) | G2 §4 | Verified |
| Flame jet hazard (Cindercrypt) | G2 §3 | Verified |
| Lobber projectile (Cindercrypt) | G2 §3 | Verified |
| 60fps with 20+ enemies | G1 AC | REMOVED. No rendered evidence. |
| ~2 hours playtime | G2 target | REMOVED. FIX-153 unpassed. |
| Demo floors 1-3 | G13 | REMOVED. Demo build unconfirmed. |
| Class-specific potions | NOT IN G2 | REMOVED. Fabricated. |
| Three additional classes (seven total) | NOT IN G2 | REMOVED. Replaced with "the other three classes." |
| "THE OVEN GOES COLD" string | G3 | REMOVED. Canonical string is GENERATOR DOWN. |
| "When you fall, it plates you" (audio-present death event) | G3 (implied) | REMOVED from ship copy. Not verified in G10 manifest. If a death caption/clip is verified at freeze, it may be added to the audio-present variant. |

**Pre-freeze verification:**
- String manifest cross-check: "GENERATOR DOWN," "FOOD," "KEY," "SAVED," and any death event strings must be verified against the G3/G10 string manifest. The manifest is not available in the corpus. Every referenced caption string must be verified before freeze. Remove or replace any string not present. Owner: pipeline. Deadline: store freeze.
- UI verification: HP numeral, class-select stat rows, floor results panel fields, and SAVED tag must be captured in the shipping build with capture evidence. Owner: pipeline. Deadline: store freeze.
- FIX-153 / G13 AC-9: The Monte Carlo survival verification results are not available. No playtime claim ships until this passes. If verification confirms a typical first-clear duration, add the verified estimate to this section and FAQ Q7 simultaneously. Owner: pipeline. Deadline: store freeze.
- G13 AC-11: The operator attestation on unpublished G2 review obligations is not on file. It must be submitted before the kit is marked verbatim-final. Owner: operator. Deadline: store freeze.

---

## 4. Description (short) / Steam short description

Steam short description limit: 300 chars. The one-breath pitch.

### 4.1 SHIP — Steam short description

```
Your health bar is the clock, and it is already falling. One player pays the full health bill that four once shared. A solo arcade dungeon crawler: 24 floors, four classes, enemy generators, finite food, local high scores. One purchase, no ads, no in-app purchases, no developer telemetry.
```

**Measured: 289 chars.** 11 chars of headroom remain in the 300-char budget. The hook ("Your health bar is the clock") leads within the first 30 characters. The one-player-pays consequence appears in the first 120 characters.

**Pre-freeze verification:**
- $5.99 is locked by Operator Constraints. G13 AC-8 comparable-price check (Vampire Survivors, Brotato, Halls of Torment, Death Must Die) has not been recorded. Must be completed before store freeze. Owner: pipeline. Deadline: store freeze.
- Demo claims remain removed until the Steam demo covering floors 1-3 is built, published, and linked. The operator has not confirmed whether a demo will be built. If the demo ships, this field updates to include it without a new review cycle.

---

## 5. Keywords / Steam tags

Steam uses developer-suggested tags from a controlled vocabulary, not a comma-separated keyword field. Tags are the primary discovery mechanism. Up to 20 tags allowed.

### 5.1 SHIP — Steam developer-suggested tags

First five are pinned by submission priority (highest-intent first). Remaining ten follow.

| Priority | Tag | Rationale |
|----------|-----|-----------|
| 1 | Dungeon Crawler | Genre head term. Highest-intent discovery filter. |
| 2 | Action | Broad category feeder. High volume, low competition for this niche. |
| 3 | Singleplayer | Critical disambiguation from co-op ancestor. Required for the single-player filter. |
| 4 | Arcade | Play-style and era filter. Covers the coin-op heritage. |
| 5 | Retro | Locked audience is nostalgic (G1). Primary filter for this cohort. |
| 6 | Pixel Graphics | Visual-style filter. G1, G4 confirm 32px pixel on period palette. |
| 7 | Top-Down | Perspective descriptor. Steam controlled-vocabulary hyphenated form. |
| 8 | Hack and Slash | Genre qualifier. Steam indexes this as a single compound tag. |
| 9 | Score Attack | Arcade scoring with death penalty is a shipped pillar (G2 §5). |
| 10 | Indie | Broad, accurate, no genre-expectation risk. |
| 11 | 1980s | Decade cohort term. Broader than "1985" as a tag. |
| 12 | Fantasy | Setting filter. Ghosts, wizards, Valkyries, dungeon fantasy. |
| 13 | Difficult | Arcade difficulty. Health drain creates constant pressure. |
| 14 | Atmospheric | Tone filter. Dry dungeon atmosphere, polite menace. |
| 15 | Replay Value | Four classes, New Game+, score attack. Accurate. |

15 tags. Five slots remain available for operator additions based on post-launch tag performance data. Reserved-slot candidates: Character Action, Short, Great Soundtrack. Do not add without verifying Steam vocabulary.

**Rejected tags with rationale:**
- **Survival:** Carries horde-survivor connotation (Vampire Survivors, Brotato, Halls of Torment). Misrepresents dungeon-crawler gameplay.
- **Twin Stick Shooter:** Requires dual-stick input. G2 input map confirms left stick movement and face button throw, no right-stick aim. Misrepresents input scheme.
- **Roguelike / Action Roguelike:** HUNGERHALL has deterministic solver-gated floors (not procedural), a continue system with saves (not permadeath), and no in-run upgrades. Neither tag matches.
- **Classic / Old School:** Deduplicated against "Retro" and "1980s." Four nostalgia-era tags was redundant; two covers the filter.

**Pre-freeze verification:**
- All 15 tags must be verified against Steam's current controlled vocabulary with exact casing and spacing before submission. Steam curates final tag assignment based on community voting; developer-suggested tags seed the list. Owner: operator. Deadline: store freeze.

### 5.2 Non-binding App Store keyword exercise (quarantined to Appendix A)

Does not map to any Steam field. Retained for keyword research continuity only. See Appendix A.2.

---

## 6. Screenshot copy

Five screenshots. Overlay lines are ALL CAPS announcer-register barks, six words or fewer. Sequence tells the loop: drain, choose, suppress, eat, bank. HUNGERHALL appears in the first overlay for title consistency. Every subject is capturable from files present in the G10 manifest.

### 6.1 SHIP — Screenshot overlays

| # | Shot subject | Overlay line (word count) | What it proves | Fallback if subject unverifiable |
|---|--------------|--------------------------|----------------|----------------------------------|
| 1 | Floor 1, Drowned Vaults. Hero at spawn, ghosts inbound from a generator, HP numeral mid-tick, step puffs behind | HUNGERHALL. HEALTH IS THE CLOCK. (5) | Central differentiator visible in frame one. Single-player truth, the drain visible, core combat as the loop's engine. Title consistency: HUNGERHALL appears verbatim. | If HP numeral not visible in build, use generator + ghosts frame with overlay "HUNGERHALL. THE HALL HUNGERS." (4). Enemies and generators are verified. |
| 2 | Class select screen, "Tonight's Menu" header, four class cards with stat rows visible | FOUR CLASSES. ONE MENU. (4) | Four distinct hero classes exist at first boot with readable stat profiles. | If stat rows not visible, show four class cards with class names. Overlay unchanged. |
| 3 | Generator bursting under sustained fire: freeze-frame, camera kick, spawn lane behind it, +100 floater, GENERATOR DOWN caption | BREAK THE SOURCE. STOP THE FLOW. (6) | Suppression verb: end the source, not the crowd. Generator destruction is a shipped juice closure. | If "GENERATOR DOWN" caption not in manifest, use generator destruction frame without caption reference. Overlay unchanged. |
| 4 | A plate two tiles past a destroyed generator, HP ticking up on contact, FOOD caption holding, a heavy enemy guarding the approach | EAT FAST. NOTHING COMES BACK. (5) | Food economy as coded: finite per floor, contact-triggered, never restored. | If "FOOD" caption not in manifest, use food pickup frame without caption reference. Overlay unchanged. |
| 5 | Floor results panel: floor time, kills, food eaten, running total, SAVED tag visible next to Next Floor button, Guestbook row highlighted | YOUR SCORE. ON THE RECORD. (5) | Arcade scoring persists locally. Progress autosaves at floor clear. | If "SAVED" tag not in build, show Guestbook high-score row with score visible. Overlay unchanged. |

### 6.2 Animated GIF strategy

Steam may support animated GIFs in the screenshot carousel. This must be verified against current Steamworks documentation at time of upload before relying on it. No corpus evidence confirms current GIF support.

If GIF is supported: the first carousel item should be a 3-second looping GIF showing the HP numeral ticking down while ghosts approach from a generator. This communicates the health-drain differentiator in motion. Capture from the shipping Windows build at 1280x720, 3 seconds, looping seamlessly. If GIF capture is unavailable at freeze, static screenshot 1 serves as fallback and the GIF is added post-launch.

**Pre-freeze verification:**
- Capture all five screenshots from the shipping Windows build at integer scale (1280x720 or 1920x1080) before upload. Verify each shot subject is reachable in the build. Owner: pipeline. Deadline: store freeze.
- Confirm caption strings ("GENERATOR DOWN," "FOOD") exist in the G10 manifest before referencing them in overlay descriptions. If missing, apply the fallback column. Owner: pipeline. Deadline: store freeze.
- Verify Steam animated GIF support against current Steamworks documentation. Owner: operator. Deadline: store freeze.

---

## 7. Preview video script

30 seconds. All footage from the shipping Windows build. In-game announcer captions render ALL CAPS per G3. Overlay text follows the same register. All combat references use verified mechanics only: thrown weapon projectiles, generator destruction, food pickup, flame jets, lobber projectiles. The gamepad input is left stick for movement and a face button for throwing; the video does not imply dual-stick aiming.

### 7.1 SHIP — Video shot list

| Timecode | On-screen action | Overlay text | Fallback if action unverifiable |
|----------|------------------|--------------|---------------------------------|
| 0:00-0:04 | Title screen: HUNGERHALL logo on plum-black, attract replay running behind, tagline visible | HUNGERHALL | N/A. Title screen is verified. |
| 0:04-0:09 | Floor 1: ghosts pour from the generator, HP numeral ticking down, thrown weapon kills the lead ghost, sustained fire bursts the generator, freeze frame, GENERATOR DOWN caption | HUNGERHALL. HEALTH IS THE CLOCK. | If HP numeral not visible, show combat with generator destruction. If "GENERATOR DOWN" caption missing, show generator burst without caption. |
| 0:09-0:14 | Class select: selector crosses all four cards, stat rows swap, lands on Warrior, Descend pressed | FOUR CLASSES. ONE MENU. | If stat rows not visible, show four class cards with names and selector movement. |
| 0:14-0:19 | Food plate on contact, HP ticks up, FOOD caption holds, HP numeral climbing | EAT FAST. NOTHING COMES BACK. | If "FOOD" caption missing, show food pickup with HP increase visible. |
| 0:19-0:25 | Cindercrypt: flame jet telegraphs, lobber projectile crosses a wall, Valkyrie holds her lane under fire | THE FLOOR FIGHTS BACK. | If Valkyrie absorb/block effect does not exist in build, show Valkyrie advancing through the lobber path without implying a special effect. Overlay unchanged. |
| 0:25-0:30 | Floor results panel: score rolls up, SAVED tag, Guestbook row highlights. End card: logo, price line, keyboard and gamepad glyphs | $5.99. EVERYTHING IN THE BOX. | If "SAVED" tag not in build, show Guestbook row with score. End card unchanged. |

### 7.2 SHIP — Audio bed strategy

**Default (audio-absent):** The trailer plays with in-game SFX and score music only (if present). No announcer barks. Captions are visible in the gameplay footage. The end card is silent with text overlay. If no audio assets are available, silence-as-tension is the fallback.

**Audio-present upgrade:** If audio freeze state upgrades to PRESENT, the trailer uses in-game announcer barks and the in-game score music. The trailer opens on the title screen's attract-mode ambient bed, transitions to the floor 1 combat track at 0:04, and uses the floor-results stinger at 0:25. The end card is silent except for the announcer saying the tagline if a matching clip exists in the G10 manifest.

**Music source:** The in-game score from G10 (if present). If the score is absent, ambient SFX only: footstep puffs, projectile impacts, generator crackle, food pickup chime. Do not add a narrator or licensed music the game itself would not contain.

**Pre-freeze verification:**
- Capture the 30-second video from the shipping Windows build at integer scale. Owner: pipeline. Deadline: store freeze.
- Confirm the Cindercrypt floor is reachable and the flame-jet hazard is visible before using the 0:19-0:25 footage. Owner: pipeline. Deadline: store freeze.

---

## 8. App icon brief + Steam graphical assets

### 8.1 SHIP — Icon brief

For the renderer (Asset Forge or human fallback).

- **Subject:** one cloche serving dome, front elevation, centered on canvas. Dome body is flat wall_cap #5A4E76, sitting on a thin wall_body #191526 base line. Background canvas #0B0A13. One lit service_amber #F2A23B crescent where lid meets seat, minimum 4x2px at 32px working scale, scaled proportionally per export.
- **One signal per asset.** The crescent is the sole primary identity marker per G4 motif law. No second object: no fork, no flame, no hero, no cutlery garnish, no class portrait, no coin.
- **Silhouette rule:** at 48x48 squinted and at 32px favicon, the icon must still read as one dome plus one bright slot. No interior detail below the 2x2 atomic unit. If the crescent fails to register at small size, the G4 fallback applies: a solid amber square glint with no crescent implication.
- **No-text rule:** zero letters, zero numerals, zero glyphs.
- **Palette (G4, Palette A "After Service"):** canvas #0B0A13, wall_body #191526, wall_cap #5A4E76, service_amber #F2A23B. No other hues. Flat fills, no gradients, no anti-aliasing, no drop shadows, no glow, no bloom, no rounded corners.
- **Construction:** authored at 128x128 pixel art, integer-scaled 8x to 1024x1024 PNG, nearest neighbor, filtering off. Export 512, 256, 128, and 64px variants by integer scaling from the 128px source.

### 8.2 SHIP — Steam graphical asset specifications

Dimensions below are based on current published Steamworks specs. Steam asset requirements may change.

| Asset | Dimensions | Format | Composition |
|-------|-----------|--------|-------------|
| Header capsule | 460x215px | PNG/JPG | Wide banner. Dungeon corridor in perspective, dome motif as subtle floor inset top-left, plum-black dominant, service_amber accent on generator glow at far end. Title "HUNGERHALL" in G4 display font, bottom-left, 40px nominal. |
| Main capsule | 616x353px | PNG/JPG | Store page hero. Hero class mid-throw, ghosts incoming from generator, HP numeral visible top-right. Title overlay bottom-center. Plum-black field, service_amber projectile trails. |
| Small capsule | 231x87px | PNG/JPG | Search result and discovery queue. Tight crop of hero silhouette against generator glow. Title in compact G4 font, left-aligned. No HP numeral at this scale. |
| Library capsule (portrait) | 600x900px | PNG/JPG | Steam library sidebar. Vertical composition: dungeon corridor receding upward, dome motif as floor marker, title centered upper third. Plum-black gradient from #0B0A13 to #191526. |
| Library capsule (small) | 300x450px | PNG/JPG | Integer 2x downscale of 600x900. Nearest-neighbor. |
| Library hero | 1280x720px | PNG/JPG | Library details page. Wide establishing shot of a dungeon floor in play: hero, enemies, generator, HP bar, score. Title and tagline overlaid bottom-left. |
| Community icon | 184x69px | PNG | Dome and crescent on #0B0A13 field, centered. No title text at this scale. Re-author at target resolution; do not nearest-neighbor scale from 128px. |
| Logo (optional) | 640x360px | PNG with alpha | "HUNGERHALL" in G4 display font, service_amber on transparent. Used as overlay on library hero and main capsule. |

### 8.3 SHIP — Pixel-safe generation pipeline

A 128px source cannot integer-scale to 231x87, 460x215, 616x353, 600x900, or 1280x720. The pipeline splits assets into two tracks:

**Icon track (dome and crescent motif):** Authored at 128x128 pixel art. Integer-scaled to 1024x1024 (8x), 512x512 (4x), 256x256 (2x), 128x128 (1x), 64x64 (0.5x downscale). For non-multiple sizes (184x69, 32x32 favicon), re-author the composition at the target resolution using the same palette and motif rules. Do not nearest-neighbor scale across non-integer ratios; the result shatters the crescent.

**Capsule track (scene compositions):** Authored as full scene renders at each target dimension. The dome motif appears as a recurring visual element but the composition is built for the specific aspect ratio. No capsule is a scaled crop of another capsule. Each is rendered or composed independently from the same palette, motif library, and scene elements.

**Pre-freeze verification:**
- Contrast tool: run the deterministic contrast tool on the icon palette before freezing the render. Verify service_amber (#F2A23B) on canvas (#0B0A13) and wall_cap (#5A4E76) on canvas both meet the 3:1 UI contrast floor. If they fail, re-author the icon with adjusted values. The tool has not been run; no results are in the corpus. Owner: pipeline. Deadline: render freeze.
- Asset dimensions: verify all dimensions against current Steamworks documentation before rendering. Owner: operator. Deadline: store freeze.
- Render all capsule assets from the shipping build or the G4 art pipeline. No capsule ships as a placeholder. Owner: operator/pipeline. Deadline: store page publication.

---

## 9. Age rating questionnaire

Steam uses IARC. The IARC returned rating is the source of truth for the Steam store page.

### 9.1 DRAFT — IARC questionnaire (PENDING RETURN — do not publish rating until IARC returns)

The questionnaire has not been submitted. The returned rating is not available. The answers below are the intended responses.

| IARC question | Frequency | Intensity | Rationale |
|---------------|-----------|-----------|-----------|
| Cartoon or Fantasy Violence | Frequent | Mild | Combat is the core loop. Every second on every floor is fighting. Projectile attacks, enemy destruction, hero crumble. Presentation is non-graphic: 32px pixel sprites pop into smoke particles. No blood, no gore, no dismemberment (G4, G3 tone anchors). |
| Realistic Violence | None | None | No humans, no realistic weapons, no realistic harm depicted. |
| Prolonged Graphic or Sadistic Realistic Violence | None | None | No graphic content exists. |
| Sexual Content or Nudity | None | None | Absent by design. No characters with sexual characteristics. |
| Profanity or Crude Humor | None | None | G3 voice bible bans harsh language. The string manifest carries none. |
| Horror or Fear Themes | None | None | See §9.3. |
| Controlled Substances | None | None | No consumables but food. No alcohol, tobacco, or drug references. |
| Gambling: Real or Simulated | None | None | Treasure chests are deterministic, baked at floor generation, and print their value the instant they open. Fixed-ratio only per G2 §5. No loot boxes, no variable-ratio rewards. |
| In-Game Purchases | No | — | No in-app purchase surface of any kind (G2 §4, G13 AC-2). The $5.99 sale is a storefront transaction, outside the app. |
| User-Generated Content | No | — | Players cannot create, share, or upload content. No chat, no sharing. |
| Online Interactions | No | — | Single-player only. No netcode, no online features. |
| Personal Information Collection | No | — | The game collects no personal data. See §10. |
| Location Services | No | — | No location access. |
| Unrestricted Web Access | No | — | No browser, no web views. DemoStoreLinkOverlay, if present in the build, opens a specific Steam store URL in the system browser on explicit player input only. This is a single directed link, not unrestricted web access. |

**Expected IARC rating: E10+ (Everyone 10+) / PEGI 7.** This expectation is not a rating. Run the questionnaire through IARC during Steamworks setup and insert the returned rating here before the store page goes live.

### 9.2 IARC option-set verification and fallback

Confirm that IARC offers separate Frequency and Intensity dimensions for Cartoon or Fantasy Violence. If the current IARC implementation combines them into a single option, select the closest available bucket. If IARC returns a rating higher than E10+/PEGI 7 (e.g., T/12+), accept the returned rating, update §9.1 and the store page. If IARC returns a rating lower than expected, accept it. The IARC returned rating is the source of truth regardless of expectation.

Fallback if rating exceeds E10+/PEGI 7: no copy changes needed in §§3-4. The store page displays the IARC-returned rating. No content in HUNGERHALL is age-gated by design. If IARC returns T/12+, the rating reflects frequency of cartoon violence, not intensity.

### 9.3 SHIP — Horror/Fear: None (DIS-10 resolution)

Committed to None. The game has ghosts and a slow enemy called Death, but the tone is dry, polite, and never attempts to scare. No jump scares, no gore, no sustained dread, no horror imagery. The menace is tonal humor, not fear. Ghosts are 32px pixel sprites that pop into smoke. Death is a slow pursuer, not a horror creature. The announcer's macabre lines are delivered flat and polite, which is dry humor. The bridges-over-nothing in Starved Deep are a mechanical hazard, not a fear scene. Declaring Mild would misdescribe the content.

### 9.4 Content descriptor mapping for Steamworks

When IARC returns, enter the content descriptors in Steamworks metadata. For HUNGERHALL, the expected primary descriptor is "Cartoon Violence" (Frequent/Mild). No other descriptors expected based on §9.1 answers. If IARC returns additional descriptors, enter them as directed by the IARC output.

**Pre-freeze verification:**
- Submit §9.1 answers through IARC during Steamworks setup. Owner: operator. Deadline: store page publication. Insert the returned rating in §9.1 before the store page goes live.
- If IARC returns a rating different from E10+/PEGI 7, update §9 and the store page.
- This kit claims no ESRB or PEGI board certification. If the operator wants a board rating, obtain and record it before launch.

---

## 10. Privacy

Steam requires a privacy policy URL (hosted, reachable) and a data collection disclosure in the Steamworks backend. The disclosure is derived from the G7/G10 code, not from marketing intent.

### 10.1 SHIP — Source walk

- **No network layer in the game.** The retail binary has no HTTP client, no WebSocket, no network nodes. G13 AC-3 requires a process-scoped network monitor with zero non-Steam endpoints.
- **No tracking SDK.** No Firebase, GameAnalytics, Amplitude, Mixpanel, AppsFlyer, Adjust, Crashlytics, or ad SDK signatures. G13 AC-3 binary scan covers 17+ signatures and requires zero matches.
- **No retail telemetry.** playtest_telemetry_v1 is CI tooling only, excluded from the retail export via export_presets.cfg (G13 AC-3). G2 §9 states no player-facing telemetry exists in the shipped product.
- **Local writes only.** Four stores write machine-local files: save_store.gd (floor progress), score_store.gd (local high-score table), settings_store.gd (settings), profile_store.gd (NewGame+ flag). All four write atomically (temp-file plus rename) to the player's machine. Nothing is transmitted, linked to identity, or used for tracking.
- **In-game disclosure.** A privacy modal (privacy_pop.gd) ships in the build and states the same thing this disclosure states.
- **DemoStoreLinkOverlay.** If present in the build, it opens a specific Steam store URL in the system browser on explicit player input. It collects no data. Whether this overlay ships depends on the demo build decision. Under the default freeze state (demo not published), the overlay may not be in the retail build.
- **GodotSteam.** Under the default freeze state (Path B, disabled), no Steamworks integration occurs. The binary makes no network calls. If Path A is adopted (GodotSteam verified with Godot 4.7), the Steamworks SDK initializes for platform services (overlay). The SDK does not provide DRM unless the operator separately applies the Steam DRM wrapper. Platform-level communication goes to Valve under Valve's privacy policy. The game itself collects nothing.

### 10.2 SHIP — Steam data collection disclosure

**Default (Path B, GodotSteam disabled):**

| Field | Answer |
|-------|--------|
| Does this product collect or use player data? | No |
| Does this product use Steam cloud? | No (not enabled at launch) |
| Does this product include any SDKs that collect data? | No |

**Path A upgrade (if GodotSteam enabled):**

| Field | Answer |
|-------|--------|
| Does this product collect or use player data? | No (the game itself collects no player data) |
| Does this product use Steam cloud? | No (not enabled at launch) |
| Does this product include any SDKs that collect data? | Yes. The Steamworks SDK provides platform services (overlay) under Valve's privacy policy. The game itself collects no data. |

**Valve survey semantics:** Confirm Valve's current survey semantics at time of submission. The two-question structure (game data vs. SDK data) is based on current Steamworks documentation. "Collects player data" is answered No because the game itself collects nothing. "SDKs that collect data" is answered Yes only if the Steamworks SDK's communication with Valve counts under Valve's framework. Verify before submission.

### 10.3 SHIP — Privacy policy (modular composition)

The privacy policy is composed from a base text plus optional paragraphs based on the freeze state. This covers all four GodotSteam/demo combinations with a single composition rule.

**Base text (always present):**

```
HUNGERHALL Privacy Policy

HUNGERHALL collects no player data. The game transmits no user information to the developer or any third party.

Your save files, high scores, settings, and New Game+ progress are stored locally on your machine. No data leaves your machine through the game.
```

**Optional paragraph A (insert if GodotSteam enabled, Path A):**

```
This product uses the Steamworks SDK for platform services such as the Steam overlay. Any platform-level communication goes to Valve under Valve's privacy policy. The game itself collects nothing.
```

**Optional paragraph B (insert if demo published with DemoStoreLinkOverlay):**

```
The in-game demo link opens a Steam store page in your system browser when you explicitly choose to open it. This is a browser action, not game data collection.
```

**Closing text (always present):**

```
The game contains no ad SDKs, no analytics SDKs, no tracking SDKs, and no crash reporting SDKs.
```

**Composition matrix:**

| GodotSteam | Demo | Policy composition |
|------------|------|--------------------|
| Disabled (default) | Not published (default) | Base + Closing |
| Disabled | Published | Base + Paragraph B + Closing |
| Enabled | Not published | Base + Paragraph A + Closing |
| Enabled | Published | Base + Paragraph A + Paragraph B + Closing |

### 10.4 SHIP — Steamworks backend survey answers

| Field | Answer |
|-------|--------|
| Single-player | Yes |
| Cross-platform multiplayer | No |
| Online multiplayer | No |
| LAN multiplayer | No |
| Cloud saves | No (not at launch) |
| Steam Achievements | No (not at launch) |
| Steam Leaderboards | No |
| Workshop | No |
| Steam Workshop DLC | No |
| In-App Purchases | No |
| DRM | No DRM wrapper applied at launch. The operator may apply the Steam DRM wrapper before freeze; if applied, update this field and §10.1. |

### 10.5 SHIP — Public-copy qualification

The phrase "no developer telemetry" in §§3, 4, 12 refers to the game binary itself. If Path A is selected, platform services are Steam's and operate under Valve's privacy policy. The privacy policy and Steamworks disclosure must reflect the selected path.

**Pre-freeze verification:**
- Pin the GodotSteam configuration (enabled or disabled) before store freeze. GodotSteam compatibility with Godot 4.7 is unverified in the corpus. Under the default freeze state, Path B is locked. To upgrade to Path A, the operator must verify GodotSteam compatibility with Godot 4.7 and document the test protocol. Deadline: store freeze. If verification fails, Path B remains. Owner: operator.
- Execute G13 AC-3 on the final retail build before store freeze. The scan has not been executed. No results are in the corpus. Confirm the allowlist contains zero endpoints (Path B) or only Steam endpoints (Path A), and the SDK scan finds no analytics, tracking, or ad SDKs. Results appended to §10. Owner: pipeline. Deadline: store freeze.
- Host the composed privacy policy at a reachable URL before the store listing goes live. No URL is supplied or hosted in the corpus. Owner: operator. Deadline: store page publication.
- If any Steamworks features are added post-launch, re-run the §10 privacy derivation and route the kit through a fresh G14 review.

---

## 11. Support URL content

The operator must host this content at a reachable support URL and supply a monitored support email before the store listing goes live. Neither the URL nor the email is supplied or hosted in the corpus.

### 11.1 SHIP — FAQ

**Q1. How does saving work?**
The game autosaves when you clear a floor. Loading resumes at the next floor's entrance. Quitting mid-floor discards that floor entirely. Your campaign position stays at the last floor you finished.

**Q2. What happens when I die?**
Your hero crumbles. Score drops 20 percent of what you carried into the floor. You get two continue tokens per floor. Accepting a continue rebuilds the floor at half health with no keys and food still eaten. If you refuse or run out, the run ends and your campaign save returns to the last completed floor.

**Q3. Is there multiplayer or co-op?**
No. HUNGERHALL is single-player by design. No netcode, no split-screen, no AI companion.

**Q4. Are there ads or in-app purchases?**
No. One purchase at $5.99 covers the entire game. No ads, no DLC, no premium currency, no season pass, no subscriptions. Nothing else to buy, ever.

**Q5. Do I need an internet connection?**
After downloading through Steam, the game runs fully offline. The Steam client need not be running to play. Scores, saves, and the Guestbook all live on your machine. No accounts, no cloud sync.

**Q6. Can I play with a controller?**
Yes. Keyboard and gamepad both work at first boot with no setup required. Move with the left stick, throw with a face button along your current facing.

**Q7. How long is the campaign?**
The campaign spans 24 floors across four themed zones. Each class plays differently enough to count as a separate run. New Game+ opens after a campaign clear. How long is a first clear? We will say when we know.

**Q8. Is there a demo?**

*No-demo variant (default, per freeze state):*
A demo is not available at launch. We are considering one for a future update.

*Demo-live variant (if demo is published):*
A demo covering the first three floors is available on the Steam store page. Demo progress does not transfer to the full game.

**Q9. What platforms are supported?**
Windows 10/11 via Steam. Steam Deck and Proton status are pending verification.

**Q10. Who made this game?**
[Studio name: operator-supplied. Not present in the corpus.]

### 11.2 SHIP — Contact block

- **Email:** Operator must supply a real, monitored address. No address is present in the corpus. Owner: operator. Deadline: store page publication.
- **Response target:** within 3 business days.
- **Bug report format:** include your Windows version, GPU, input device (keyboard or gamepad model), the floor where it happened, and what you saw. No attachments in the first email.
- **Privacy line:** HUNGERHALL collects no player data. There is nothing to request, correct, or delete. The in-game privacy notice says the same.

**Pre-freeze verification:**
- The operator must supply a monitored support email and host a reachable support URL before the store listing goes live. Do not reference the support page in the listing until it is hosted and verified. Owner: operator. Deadline: store page publication.
- FAQ Q7: FIX-153 / G13 AC-9 has not passed. The Monte Carlo results are not available. No playtime estimate ships. If verification confirms a typical first-clear duration, add the verified estimate to this FAQ and to §3 simultaneously.
- FAQ Q8: select the variant that matches the confirmed demo build status at freeze. Default is no-demo.
- FAQ Q10: operator must supply studio/developer name. Not present in the corpus.

---

## 12. Marketing URL content

Landing-page copy. Host at the operator's marketing URL. Not supplied or hosted in the corpus.

### 12.1 SHIP — Landing page

**Hook:**

Your health bar is the only clock, and it is already falling.

HUNGERHALL is a solo arcade dungeon crawler for Windows. A 1985 coin-op formula, rebuilt for one player. Twenty-four floors, four hero classes, and one building that seats you for dinner.

**Feature bullets (default, audio-absent):**

- **The clock is your health.** It drains every second. Stand still and the hall wins. Every room is a price negotiation in hit points.
- **Four classes, four survival styles.** Warrior soaks and wades. Valkyrie advances into fire. Wizard clears packs. Elf outranges and kites. Same bill, different currency of risk.
- **The building reads like a menu.** Every event prints a caption. GENERATOR DOWN when a source breaks. FOOD when a plate lands. The hall is quietly pleased when dinner puts up a fight.

**Audio-present upgrade for third bullet:**
- **The building speaks.** A flat 1985-style speech synth marks major beats: the generator down, the food found, the key turned. Every bark is captioned. The hall is quietly pleased when dinner puts up a fight.

**Call to action:**

[b]Wishlist HUNGERHALL on Steam.[/b] $5.99 at launch. One purchase, everything included.

**Screenshot slots:** Five slots, using the five screenshots and overlays from §6 in the same order: health drain on floor 1, class select, generator destruction, food pickup, floor results.

**Store badge:** Steam badge linking to the live store page, showing HUNGERHALL and $5.99. No Apple badge, no Google Play badge. The locked target platform is Steam.

**Footer:** One purchase. No ads. No in-app purchases. No developer telemetry. The game collects no player data. Support link and privacy note included. [Studio name: operator-supplied. Not present in the corpus.]

### 12.2 SHIP — Success metrics

| Metric | Target | Methodology | Window |
|--------|--------|-------------|--------|
| Wishlists before launch | 2,000 minimum | Steamworks dashboard → Reports → Wishlists. Weekly tracking. Target assumes active curator outreach (see Supplementary). | Pre-launch |
| Conversion rate (store visits to purchases) | 8% minimum | Steamworks → Sales & Traffic → Conversion. Daily tracking. Steam median for $5.99 niche titles is 5-10%. | First 30 days |
| Positive review ratio | 80% minimum | Steam store page review summary. Daily tracking. | First 30 days |
| Review count | 25 minimum | Steam store page review count. Daily tracking. Achievable at approximately 300-400 sales assuming 5-10% of buyers review. | First 30 days |
| Refund rate | Below 15% | Steamworks → Sales → Refunds. Weekly tracking. Steam median for indie games is 10-12%. | First 30 days |
| Net revenue floor | PENDING | Formula: pipeline quarterly operational cost ÷ ($5.99 × 0.70). The operator must supply the quarterly cost figure. At a placeholder $5,000 quarterly cost, the floor would be approximately 1,192 units ($5,031.60 net). This figure is illustrative only and must not ship in marketing copy. | First 90 days |

### 12.3 SHIP — Refund mitigation strategy

The 2-hour playtime vs 2-hour Steam refund window is a recognized risk for a game with a finite campaign. Mitigations:

1. **Class variety extends playtime.** Four classes with distinct combat rhythms mean a player who clears the campaign with one class has three more class runs. This is structural, not dependent on first-clear duration.
2. **New Game+ opens after campaign clear.** A harder loop extends engagement past the first clear.
3. **Score attack and local high scores.** The Guestbook provides a post-completion reason to replay floors for higher scores, extending engagement beyond the first clear.

**CONDITIONAL on FIX-153:** If FIX-153 verification confirms median first-clear time is under 2 hours, add additional mitigations: demo build covering floors 1-3, earlier New Game+ unlock threshold, or session-length disclosure on the store page. If FIX-153 confirms median first-clear time exceeds 2 hours, no additional mitigations are needed. Until FIX-153 passes, no playtime-duration assertion appears in ship copy. The Monte Carlo results are not available.

**Pre-freeze verification:**
- Host the landing page, connect the Steam wishlist or store badge, and confirm all links work before the page is referenced publicly. Owner: operator. Deadline: pre-launch, 60 days before launch.
- Replace the placeholder studio name with the operator-supplied value. Owner: operator. Deadline: Steamworks page creation.
- Pipeline quarterly operational cost figure must be supplied to make the net revenue floor meaningful. Owner: operator. Deadline: store freeze.
- If the audio-present upgrade is in effect, replace the third feature bullet with the audio-present variant.

---

## 13. Release notes v1

### 13.1 SHIP — Default (audio-absent)

```
v1.0.0: First seating. 24 floors across 4 zones, 4 hero classes, captioned announcer callouts, a local Guestbook, and New Game+ after a clean clear. Keyboard and gamepad. One purchase, everything included.
```

### 13.2 Audio-present upgrade delta

If the audio freeze state upgrades to PRESENT:

```
v1.0.0: First seating. 24 floors across 4 zones, 4 hero classes, the announcer voice, a local Guestbook, and New Game+ after a clean clear. Keyboard and gamepad. One purchase, everything included.
```

Human, short, in register. No "bug fixes and improvements" filler. The audio-present variant says "the announcer voice" (not "full announcer voice") to avoid overstating coverage if only a subset of planned clips shipped. Never advertise a voice against silence.

---

## Supplementary: Steam launch plan

### System requirements

**Renderer:** Godot 4.7 default renderer is Forward+ (Vulkan). The game uses Forward+ for 2D rendering. System requirements specify Vulkan, not OpenGL. OpenGL 3.3 is only correct if the project explicitly switches to the Compatibility renderer.

No profiling results are in the corpus. The values below are baseline estimates from the engine and game architecture (2D only, 32px tiles, no 3D rendering, no streaming, maximum 20 concurrent enemies), not measured benchmarks. Must be profiled on named hardware before store freeze.

### SHIP — Minimum

```
OS: Windows 10 64-bit
Processor: Dual-core 2.0 GHz
Memory: 2 GB RAM
Graphics: Vulkan 1.0 compatible, 512 MB VRAM
Storage: 250 MB available space
Input: Keyboard or gamepad (XInput-compatible)
```

### SHIP — Recommended

```
OS: Windows 10/11 64-bit
Processor: Quad-core 2.5 GHz
Memory: 4 GB RAM
Graphics: Vulkan 1.0 compatible, 1 GB VRAM
Storage: 300 MB available space
Input: Gamepad recommended (XInput-compatible)
```

**FPS measurement requirement:** Measure fps on minimum-spec hardware with 20+ enemies on screen. Target: 60fps. Minimum acceptable: 30fps. Report measured results in system requirements before freeze. No fps claim in store copy until measured. If profiling reveals higher requirements, update both the minimum and recommended specs. Owner: pipeline. Deadline: store freeze.

### Early Access analysis

**Decision: Direct 1.0 launch. Early Access is rejected.**

HUNGERHALL is a complete arcade experience with a finite 24-floor campaign. Early Access benefits games that expand through community feedback on procedural content, extended balancing, or feature creep. HUNGERHALL's value proposition is a finished arcade loop with four class kits and an ending. Releasing as Early Access would signal "unfinished" to the nostalgia audience, which expects a complete product for $5.99.

### Closed beta plan

**Decision: 2-week closed beta for balancing, 4 weeks before launch.**

- Build criteria: floors 1-12 playable, all four classes selectable, no crashes in a 30-minute session, save/load functional.
- Recruitment: 20-30 playtesters from curator network and nostalgia community forums. Operator-selected, not public.
- Feedback pipeline: structured survey after each session. Questions on difficulty, class balance, floor variety, control feel, health-drain pacing.
- Telemetry: playtest_telemetry_v1 CI tooling only, excluded from the test build. The test build has no telemetry layer, same as retail.
- Schedule: beta build distributed 4 weeks before launch. Survey collection for 2 weeks. 1 week for adjustments. 1 week buffer.
- Removal condition: if the build does not meet criteria by 4 weeks before launch, skip the beta and ship 1.0 directly.

### Localization strategy

**Decision: en-only at launch. Localization is Phase 2.**

The nostalgic audience for a 1985 arcade Gauntlet-like is primarily English-speaking. The voice announcer's 1985-style speech synth uses English phonetic patterns that do not localize cleanly without re-recording the entire announcer system. The UI text volume is minimal.

**Phase 2 localization plan (triggered if the game exceeds 5,000 units sold):**

| Item | Detail |
|------|--------|
| Target languages | Identified from Steam regional sales data. Likely candidates: Simplified Chinese, Japanese, German, French, Spanish. |
| Budget estimate | $3,000-$8,000 per language (UI strings + announcer re-recording + store listing translation). |
| Announcer re-recording | Synthetic voice re-synthesis per language. Estimated 2-3 days per language. |
| Vendor shortlist | Lokalise or Crowdin for UI string translation. In-house or contracted voice synth specialist for announcer. |
| QA plan | Native speaker review of UI and captions. Playthrough verification of announcer timing and caption sync. |
| Store listing | Translate §3, §4, §11, §12 per locale. Create Steam store pages per locale. |

### Next Fest and pre-launch discovery strategy

**Decision: Pursue Next Fest participation if demo is ready.**

Next Fest is Steam's primary discovery event for upcoming and recently launched games. For a $5.99 niche retro title, Next Fest exposure is the highest-ROI pre-launch marketing opportunity.

**Timing and rules:**
- Steam runs Next Fest approximately 3 times per year. The operator must check the current Steamworks calendar for the nearest Next Fest that aligns with launch.
- The demo must be live and the marketing URL wishlist CTA connected no later than 14 days before the festival deadline. If the demo is not ready by that point, skip Next Fest and ship without festival participation.
- The demo covers floors 1-3. Demo progress does not transfer to the full game.
- Go/no-go rule: If the demo build is not passing internal QA (no crashes, all four classes selectable, floors 1-3 completable) by 14 days before the Next Fest deadline, do not submit. A broken demo at a festival is worse than no demo.

**Wishlist push:**
- The marketing URL wishlist CTA is the primary conversion target during Next Fest.
- Target: 500 wishlists during the festival week, adding to the baseline 2,000 pre-launch target.
- Post-festival: maintain wishlist momentum through curator reviews and community engagement until launch.

**Curator outreach plan:**
- Owner: operator (or operator-appointed community manager).
- Timeline: begin curator outreach 60 days before launch. Continue through launch week.
- Target curators: retro gaming, arcade, dungeon crawler, pixel art, and indie discovery curators on Steam. Identify 30-50 curators with audiences matching the nostalgia cohort.
- Outreach material: press kit with capsule art, 3 screenshots, preview video link, key copy points, and a review copy offer.
- Tracking: log curator contacts, responses, and coverage in a spreadsheet. Target 10 curator reviews published by launch week.

**If Next Fest is not pursued:**
The demo may still ship post-launch. The wishlist target remains 2,000 minimum, achieved through curator outreach and community engagement alone. The §11 Q8 no-demo variant ships.

### Steam Deck / Proton verification

- Test retail build on Steam Deck via Proton compatibility layer. Verify controls map to Deck (left stick, face buttons), verify 720p rendering, verify 30+ fps with 20 enemies in a 30-minute session, verify no crashes.
- If playable: apply for Deck Verified badge.
- If not playable: mark Unsupported with rationale. No Deck claim in store copy until verified.
- No test results are in the corpus. Owner: operator. Deadline: store freeze.

### Steam Input API verification

- Verify Steam Input API integration: action sets configured, glyph API renders correct button prompts for gamepad, Steam Deck layout auto-generated or manually defined.
- If Steam Input API is not integrated, the game uses Godot's native input mapping. Verify gamepad mapping works without Steam Input on at least two XInput-compatible controllers.
- Integration status is not confirmed in the corpus. Owner: pipeline. Deadline: store freeze.

### Achievements, Leaderboards, and Cloud Saves

| Feature | Decision | Rationale |
|---------|----------|-----------|
| Steam Achievements | REJECTED at launch | Arcade scoring is the game's own achievement system. Adding Steam Achievements would duplicate the Guestbook and dilute the arcade identity. Phase 2 candidate if community requests. |
| Steam Leaderboards | REJECTED | G1 out of scope (no online leaderboards). Local Guestbook is the shipped equivalent. |
| Cloud saves | REJECTED at launch | Local-only saves support the "no data leaves your machine" privacy claim. Enabling cloud saves would require revising the privacy disclosure. Phase 2 candidate. |

### App ID reservation

- Reserve Steam app ID and claim store page URL before the marketing URL goes live. The store page URL is needed for the wishlist badge on the marketing landing page.
- Owner: operator. Deadline: before marketing URL goes live (pre-launch, 60 days).

### Launch checklist

| Item | Required before | Owner |
|------|----------------|-------|
| Trademark search (HUNGERHALL, ALL ARE EATEN) in USPTO/EUIPO/UKIPO classes 9 and 41, written results | Store freeze | Operator |
| Steamworks app-name limit verified against current Valve documentation | Store freeze | Operator |
| Steam app ID reserved, store page URL claimed | Marketing URL live (pre-launch 60 days) | Operator |
| IARC questionnaire submitted, returned rating inserted in §9.1 | Store page publication | Operator |
| G13 AC-3 network scan on retail binary, results appended to §10 | Store freeze | Pipeline |
| G10 B1 audio status confirmed; freeze-state audio decision pinned | Store freeze | Pipeline |
| GodotSteam configuration pinned (default: Path B disabled) | Store freeze | Operator |
| System requirements profiled on named min/recommended hardware, FPS measured (target 60, minimum 30) with 20+ enemies | Store freeze | Pipeline |
| All five screenshots captured from shipping build | Store freeze | Pipeline |
| Preview video captured from shipping build | Store freeze | Pipeline |
| All capsule/header/library assets rendered, dimensions verified in Steamworks | Store page publication | Operator |
| Steamworks asset dimensions verified against current Valve documentation | Store freeze | Operator |
| Animated GIF support verified against current Steamworks docs (if pursuing) | Store freeze | Operator |
| Privacy policy hosted at reachable URL (composed per §10.3) | Store page publication | Operator |
| Support URL hosted with FAQ and contact email | Store page publication | Operator |
| Marketing URL hosted with wishlist button | Pre-launch (60 days) | Operator |
| Developer/publisher metadata in Steamworks | Page creation | Operator |
| G13 AC-8 comparable-price check recorded | Store freeze | Pipeline |
| G13 AC-11 operator attestation on file | Store freeze | Operator |
| String manifest cross-check (GENERATOR DOWN, FOOD, KEY, SAVED, death event) | Store freeze | Pipeline |
| Contrast tool run on icon palette, results recorded | Render freeze | Pipeline |
| Steam demo (floors 1-3) built and published (if pursuing Next Fest) | Next Fest deadline (14 days before) | Operator |
| Curator outreach initiated (30-50 curators identified, press kit sent) | Pre-launch (60 days) | Operator |
| Steam Deck / Proton verification tested | Store freeze | Operator |
| Steam Input API verified or native input fallback confirmed | Store freeze | Pipeline |
| Content descriptors entered in Steamworks per IARC output | Store page publication | Operator |
| Pipeline quarterly operational cost figure supplied for §12.2 | Store freeze | Operator |
| Studio/developer name supplied for Steamworks and marketing | Page creation | Operator |
| Support email address supplied and monitored | Store page publication | Operator |
| All tags verified against Steam's current controlled vocabulary | Store freeze | Operator |

---

## Freeze Definition of Done

The kit is verbatim-final when ALL of the following are true:

1. All pre-freeze verification items in §§1-13 and Supplementary are closed (every item marked COMPLETE with evidence attached or explicitly waived by operator signature)
2. Freeze-state declaration is pinned (Path A or B, audio present or absent, demo published or not, renderer verified)
3. Selected variant copy is pasted into Steamworks (no remaining conditional text in any SHIP field)
4. IARC questionnaire submitted and returned rating inserted in §9.1
5. G13 AC-3 network scan executed on retail binary and results appended to §10
6. G13 AC-11 operator attestation on file
7. Trademark searches completed with written results
8. All referenced caption strings verified against G10 manifest (missing strings removed from copy)
9. HP numeral, class-select stat rows, floor results panel fields, and SAVED tag verified in shipping build with capture evidence
10. Contrast tool run on icon palette, results recorded
11. System requirements profiled on named hardware, FPS measured
12. Support email, support URL, marketing URL, privacy policy URL hosted and verified live
13. Studio/developer name and pipeline quarterly cost supplied by operator
14. All five screenshots and preview video captured from shipping build
15. All capsule/header/library assets rendered and uploaded to Steamworks
16. Steam app ID reserved and store page URL claimed
17. Steam Deck / Proton verification completed
18. Steam Input API verified or native input fallback confirmed
19. Operator sign-off recorded (date, name, explicit approval of every SHIP field)

---

## Appendix A: Non-binding App Store reference material (quarantined)

This appendix contains App Store Connect field exercises retained for internal copy-discipline reference only. They do not map to any Steam field and do not govern the Steam upload.

### A.1 App Store subtitle candidates (non-binding)

Steam has no subtitle field. These candidates fed the Steam short description opener strategy in §2.

| # | Candidate | Chars | Notes |
|---|-----------|-------|-------|
| 1 | Solo Arcade Dungeon Crawler | 27 | Maps to Steam short description opener (§4). |
| 2 | Arcade Dungeon Crawler | 22 | Cleanest. Drops solo. |
| 3 | Retro Arcade Dungeon Crawler | 28 | Swaps solo for retro. |
| 4 | 1985 Arcade Dungeon Crawler | 27 | Year carries nostalgia. |
| 5 | Four Classes, One Hungry Hall | 29 | Voice register. Zero search value. |

### A.2 App Store keyword field exercise (non-binding)

App Store keyword field limit: 100 chars. Non-binding ASO research exercise. Does not map to any Steam field.

```
retro,pixel,topdown,hack,slash,action,score,voice,synth,warrior,valkyrie,wizard,elf,80s
```

**Measured: 87 chars.** 73 letters plus 14 commas. 13 chars of headroom. No spaces after commas. No words already in title or subtitle. No competitor app names.

### A.3 App Store promotional text exercise (non-binding)

App Store promotional text limit: 170 chars. Steam has no equivalent field. The Steam short description (300 chars) is the closest equivalent (§4).

```
Your health bar is the clock, and it is already falling. One player pays the full bill that four once shared. Four classes, 24 floors, finite food.
```

**Measured: 146 chars.** 24 chars of headroom in the 170-char App Store budget.

### A.4 Apple age rating questionnaire (non-binding, for potential future iOS port)

| Question | Answer | Rationale |
|----------|--------|-----------|
| Made for Kids | No | Targets nostalgic adults. |
| Cartoon or Fantasy Violence | Frequent/Intense | Apple combines frequency and intensity into one option. Frequency is Frequent. The closest bucket is Frequent/Intense though intensity is mild. Apple maps this to 12+. DIS-1 resolution: IARC's separate granularity is the correct path for Steam (§9). |
| All other questions | None/No | Same rationale as §9.1. |

**Declared Apple rating: 12+** (if an iOS port is ever qualified). Not asserted for the Steam listing. The IARC returned rating (§9) is the source of truth for Steam.

---

## Obligation Responses

OBL-1: ADDRESSED — §12.3 refund note removed sub-2-hour player-behavior claim; no unverified playtime assertion remains in ship copy.
OBL-2: ADDRESSED — FAQ Q7 rewritten to "How long is a first clear? We will say when we know." No internal jargon in player-facing copy.
OBL-3: ADDRESSED — Freeze-State Declaration pins Path B as default; §11 Q5 qualified with "Steam client need not be running."
OBL-4: ADDRESSED — §10.4 DRM field states "No DRM wrapper applied" with operator upgrade path; §10.1 SDK no longer claims DRM.
OBL-5: ADDRESSED — Net revenue corrected to $5,031.60; numeric floor removed from ship copy, marked PENDING.
OBL-6: ADDRESSED — §6.2 GIF support gated with verification requirement against current Steamworks docs.
OBL-7: ADDRESSED — Curator outreach added to launch checklist and Next Fest strategy with owner and 60-day timeline.
OBL-8: ADDRESSED — Short description recounted at 289 chars; headroom corrected to 11 chars.
OBL-9: ADDRESSED — "When you fall, it plates you" removed from ship copy; added to traceability matrix as REMOVED.
OBL-10: ADDRESSED — Privacy policy uses modular composition (base + optional paragraphs) covering all 4 GodotSteam/demo states.
OBL-11: ADDRESSED — Curator outreach action in launch checklist with owner (operator) and timeline (60 days pre-launch).
OBL-12: ADDRESSED — FAQ Q8 demo-live variant says "first three floors" aligned with planned scope.
OBL-13: ADDRESSED — Next Fest discovery strategy added with timing, demo freeze date, wishlist push, go/no-go rule, curator plan.
OBL-14: ADDRESSED — Same as OBL-8; short description at 289 chars with 11-char headroom.
OBL-15: ADDRESSED — Keyword string recounted at 87 chars; corrected in §5.2 and Appendix A.
OBL-16: ADDRESSED — FAQ Q8 split into no-demo (default) and demo-live variants bound to confirmed build status.
OBL-17: ADDRESSED — "No game telemetry" replaced with "No developer telemetry" in §§3, 4, 12; §10.5 qualifies against Path A.
OBL-18: ADDRESSED — Steam asset dimensions marked with verification gate against current Steamworks documentation.
OBL-19: ADDRESSED — §1 states no published hard limit but adds verification gate against current Valve documentation.
OBL-20: ADDRESSED — §5.1 tags marked with verification gate for exact casing and controlled vocabulary.
OBL-21: ADDRESSED — System requirements changed to Vulkan (Godot 4.7 Forward+ default); OpenGL removed; profiling gate added.
OBL-22: ADDRESSED — §12.3 refund mitigation removed sub-2-hour assertion; marked conditional on FIX-153.
OBL-23: ADDRESSED — Net revenue floor marked PENDING; numeric value removed from ship copy; operator must supply cost.
OBL-24: ADDRESSED — Same as OBL-10; modular composition rule covers all 4 GodotSteam/demo states.
OBL-25: ADDRESSED — FAQ Q5 qualified: "After downloading through Steam, the game runs fully offline."
OBL-26: ADDRESSED — §9.1 labeled "DRAFT — PENDING IARC RETURN"; rating must not print on store page until IARC returns.
OBL-27: ADDRESSED — Fallback screenshot/video copy added for HP numeral, captions, SAVED tag, Valkyrie effect.
OBL-28: ADDRESSED — Minimum audio threshold defined: 5 event types (GENERATOR DOWN, FOOD, KEY, death, level transition).
OBL-29: ADDRESSED — Freeze Definition of Done added with 19 gates requiring closure, evidence, variants, operator sign-off.
OBL-30: ADDRESSED — Same as OBL-21; Vulkan pinned, OpenGL removed, profiling gate on named hardware.
OBL-31: ADDRESSED — Audio-present copy softened to "marks major beats" with specific verified string examples.
OBL-32: ADDRESSED — IARC fallback plan: if Frequent/Mild unavailable, select closest bucket; accept returned rating as truth.
OBL-33: ADDRESSED — Same as OBL-13; Next Fest strategy with festival timing, demo freeze, wishlist delta, curator owners.
OBL-34: ADDRESSED — "The other three classes invite you back. New Game+ opens after a clean campaign clear." — separated.
OBL-35: ADDRESSED — Same as OBL-4; DRM removed from SDK description; §10.4 says no wrapper applied.
OBL-36: ADDRESSED — "Price-point friction" removed; replaced with value-based retention (class variety, NG+, score attack).
OBL-37: ADDRESSED — Same as OBL-23; numeric floor removed, marked PENDING until operator supplies real cost.
OBL-38: ADDRESSED — Freeze state pins Path B; all telemetry/offline/account claims consistent under default.
OBL-39: ADDRESSED — Same as OBL-10/24; modular composition covers all 4 states.
OBL-40: ADDRESSED — Same as OBL-16; demo-live and no-demo variants; default is no-demo per freeze state.
OBL-41: ADDRESSED — Same as OBL-28; minimum 5 event-type clip coverage required for audio-present upgrade.
OBL-42: ADDRESSED — Same as OBL-13/33; full Next Fest and discovery strategy with curator outreach plan.
OBL-43: ADDRESSED — Same as OBL-21; Vulkan pinned, profiling gate on named hardware.
OBL-44: ADDRESSED — Steamworks verification gate added for dimensions, GIF, tags, app-name limit.
OBL-45: ADDRESSED — Same as OBL-32; IARC fallback with T/12+ copy guidance if rating exceeds E10+/PEGI 7.
OBL-46: ADDRESSED — Short desc 289, keywords 87, revenue $5,031.60 all corrected; placeholder floor removed.
OBL-47: ADDRESSED — Same as OBL-1/22/36; sub-2-hour assertion and price-point friction removed.
OBL-48: ADDRESSED — "plates you" removed from ship copy and marked REMOVED in traceability; fallback copy added.
OBL-49: ADDRESSED — Same as OBL-4/29; DRM resolved; Freeze Definition of Done added.
OBL-50: ADDRESSED — Same as OBL-3; Path B locked as default; GodotSteam verification required to upgrade.
OBL-51: ADDRESSED — System requirements profiling protocol: named min/recommended hardware, 20+ enemies, 30fps minimum.
OBL-52: ADDRESSED — FPS measurement: target 60fps, minimum 30fps, on min-spec with 20+ enemies; no claim until measured.
OBL-53: ADDRESSED — Trademark searches in launch checklist with owner (operator) and deadline (store freeze).
OBL-54: ADDRESSED — IARC submission in launch checklist; returned rating must be inserted before publication; fallback in §9.2.
OBL-55: ADDRESSED — G13 AC-3 scan in launch checklist; results appended to §10; owner: pipeline; deadline: store freeze.
OBL-56: ADDRESSED — String manifest cross-check in launch checklist; missing strings removed per fallback column.
OBL-57: ADDRESSED — UI verification (HP numeral, stat rows, floor results, SAVED) in launch checklist with capture evidence.
OBL-58: ADDRESSED — Contrast tool in launch checklist; 3:1 floor or icon re-authored.
OBL-59: ADDRESSED — Support email, URLs, privacy policy in launch checklist; must be hosted and verified live.
OBL-60: ADDRESSED — Pipeline quarterly cost in launch checklist; marked PENDING until supplied.
OBL-61: ADDRESSED — G13 AC-8 price check in launch checklist; owner: pipeline; deadline: store freeze.
OBL-62: ADDRESSED — Steam Deck/Proton verification in launch checklist and Supplementary with test protocol.
OBL-63: ADDRESSED — Achievements, Leaderboards, Cloud Saves rejection documented with rationale in Supplementary.
OBL-64: ADDRESSED — Curator outreach plan in Next Fest strategy with targets, timeline, outreach material, tracking.
OBL-65: ADDRESSED — Refund mitigation conditional on FIX-153; additional mitigations listed for sub-2-hour scenario.
OBL-66: ADDRESSED — Closed beta plan defined: build criteria, recruitment, feedback, telemetry, schedule, removal condition.
OBL-67: ADDRESSED — Localization Phase 2 plan with budget, announcer cost, vendor shortlist, QA plan.
OBL-68: ADDRESSED — Success metrics table includes methodology column with Steamworks reports, tools, frequency.
OBL-69: ADDRESSED — Tags deduplicated; added Atmospheric and Replay Value; 5 slots reserved with candidates.
OBL-70: ADDRESSED — Short description leads with "Your health bar is the clock" within first 30 characters.
OBL-71: ADDRESSED — App ID reservation in launch checklist with owner and deadline.
OBL-72: ADDRESSED — Same as OBL-4; DRM decision recorded as "No wrapper applied" with operator upgrade path.
OBL-73: ADDRESSED — Steam Input API verification in launch checklist and Supplementary with action sets, glyph API, Deck.
OBL-74: ADDRESSED — Content descriptor mapping documented in §9.4 for Steamworks metadata entry.
OBL-75: ADDRESSED — Same as OBL-13/33; Next Fest with participation decision, demo go/no-go, 14-day deadline.
OBL-76: ADDRESSED — First-five tag order pinned: Dungeon Crawler, Action, Singleplayer, Arcade, Retro.
OBL-77: ADDRESSED — "No game telemetry" replaced with "No developer telemetry" in §§3, 4, 12.
OBL-78: ADDRESSED — Same as OBL-1/22; sub-2-hour assertion removed; no playtime behavior claim while FIX-153 pending.
OBL-79: ADDRESSED — "One player pays the full health bill that four once shared" in short desc and first description line.
OBL-80: ADDRESSED — Valve survey semantics verification note in §10.2; confirm two-question structure at submission.
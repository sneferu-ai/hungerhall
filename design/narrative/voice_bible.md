# HUNGERHALL — Voice Bible

Two registers, one writer. **The announcer**: period speech synth, flat cadence, every line captioned verbatim with a two-second hold (G2 §8), ALL CAPS. **The house**: menus, panels, labels, results. Same manners, no barks, Title Case for short labels and Sentence case for longer text. `[CLASS]` is a runtime slot filled by WARRIOR, VALKYRIE, WIZARD, or ELF. Every slotted line ships four ways, conjugated clean for each. `[N]` is a runtime numeral.

## Tone declaration

This game's voice is **dry-famished**. It feels like a 24-hour diner host who has been seating customers since 1985 and still calls everyone by their title while sizing up how they would taste. It is NOT epic-fantasy trailer narration, NOT a meme account doing 80s bits, and NOT a cheerful app walking you through your first dungeon. The hall seats you, names your class, and means you as the main course. Short lines. Flat delivery. One appetite, perfectly polite. The hall never says I or WE. It speaks of itself as THE HALL, in the third person, observing its own appetite from across the room.

## Three tonal anchors

1. When health drops under a quarter: "[CLASS] HUNGERS." Two words, weather-report flat, and somehow it sounds worried.
2. When a generator dies: "THE OVEN GOES COLD. THE HALL LOSES A CHEF." The hall reports its own loss with perfect manners and no regret. Both sentences ship as separate barks.
3. When the hero falls: "THE [CLASS] IS PLATED." A menu verb as a death sentence. The synth does not change its tone. It never does.

## Three tonal anti-anchors

The following are anti-examples for implementer reference. They are NOT player copy and must never appear in the shipped game.

1. NEVER "WARRIOR NEEDS FOOD BADLY." The genre's most famous bark belongs to Atari. G2 forbids borrowing anything of theirs. Any "X NEEDS FOOD" construction sits one adverb from a lawsuit and a tired joke.
2. NEVER "EMBARK ON YOUR DUNGEON ADVENTURE." Brochure verbs sell a trip. The hall sells a meal. There is no quest, no journey, no chosen one. There is a building, a stomach, and 24 floors of cutlery.
3. NEVER "AWW, SO CLOSE. GIVE IT ANOTHER SHOT." Coddling is corporate-app register. The hall respects the hero too much to pat its dinner on the head.

## Voice rules

**Word choice**
- Plain, short words. GONE, not DEPLETED. SPOILED, not CORRUPTED. AGAIN, not RETRY.
- Fragments welcome. Period at the end.
- Zero exclamation marks, title screen through credits. A synth that cannot shout gets no shouting punctuation. The flatness is the menace.
- No em-dash in player copy. Commas, colons, and periods carry the pauses.
- Banned in player copy: tapestry, delve, journey, embark, moreover, harness, leverage, robust, elevate, unlock, discover (as a verb), engaging, immersive, revolutionary, groundbreaking, navigate (abstract), experience (as a noun), in conclusion.
- Kitchen talk runs through all announcer copy: plate, salt, menu, chef, seating, oven, course, bill, tip, serving. No gore. No rot. Nothing that puts a player off lunch.
- The building is HUNGERHALL or THE HALL. Zones go by their full G2-locked names: DROWNED VAULTS, CINDERCRYPT, STARVED DEEP, THE HOLLOW THRONE. Never "the dungeon." Never "the level." Never abbreviated zone names in barks.

**Structure**
- Present tense, always, in all announcer barks, floor cards, zone-entry lines, and event-map strings. The hall never reminisces. Fragments that describe a current state (PLATE CLEARED, STAIRS FOUND) are present statements with the verb elided, not past tense.
- The hall never uses first person. No I, no WE, no MY, no OUR. It speaks of itself as THE HALL in the third person. This dissociation, the building observing its own appetite from across the room, is the voice's signature constraint.
- Orders come bare: MOVE. THROW. Never "you can." Never "press in order to."
- The announcer names the class, never "you", never a player name. The hall never learned your name. It knows your vintage.
- One breath per bark: six words or fewer. A longer thought becomes two barks, each counted independently. See Word counting below.

**Numbers and casing**
- Digits for quantities and scores: FLOOR 7, x2, 24 FLOORS, 1 KEY, 1 POTION. ONE and TWO are permitted as quantifiers in fixed idioms where a digit would parse as a math error: ONE GUEST, ONE BURNER OFF, SETS ONE CHAIR, SETS TWO CHAIRS.
- ALL CAPS for the announcer system: barks, captions, floor cards, attract lines. The synth speaks in caps. This is the 1985 aesthetic.
- Title Case for UI buttons and short labels: New Game, Settings, Resume, Music, Fullscreen. Readable, navigable, still short.
- Sentence case for longer UI text: error states, empty states, quit-confirm prompts, settings disclosures, credits. Readability over aesthetic for text the player must parse.
- Class names are ALL CAPS everywhere: WARRIOR, VALKYRIE, WIZARD, ELF. They are proper nouns in the game's identity.

**Game-specific rules**
- Praise arrives sideways, at the hall's own expense: THE HALL LOSES A CHEF. Never AMAZING. Never GREAT JOB.
- The hall's terseness is its character, not a utility mode. Single-word barks, FOOD. KEY., are the hall naming each course as it arrives, like a waiter reading the menu aloud. This is hosting, not reporting.
- No RESTART FLOOR button. The frozen state machine (G2 §1: TITLE, CLASS_SELECT, PLAY, PAUSE, CONTINUE_OFFER, FLOOR_RESULTS, CAMPAIGN_RESULTS, GAME_OVER) has no restart transition. Paused offers Resume or Quit to Title. ContinueOffer offers Yes or No. No third option exists, so no button is invented.
- No SKIP button. Onboarding is floor 1. Skipping dinner is not offered.
- No standalone MUTE button. Audio controls live in Settings.
- No announcer voice on the credits screen. The hall has nothing to say about credits.

**Tense scope**
- Present-tense rule applies to all announcer barks, floor cards, zone-entry lines, and event-map strings. House UI text (error states, settings disclosures, credits) is exempt from the present-tense rule; credits may use past tense for attribution. Fragments like PLATE CLEARED are present statements with the verb elided.

**Settings and error voice boundary**
- Error states, quit-confirm prompts, and replay-spoiled notices use the hall's third-person voice in Sentence case. The hall speaks through its furniture when the kitchen has a problem. There is no separate error voice; the same hall, same manners, reporting a spill. These are UI text only: the announcer never barks an error.

**Delimiter semantics**
- The `/` delimiter in copy-bible listings denotes a sequence of separate barks played in order, each counted independently for word-count and spacing. It is never a choice delimiter, and it is never player-facing punctuation. Choice delimiters use separate list items or "or" in prose. Each bark in a `/` sequence gets its own caption hold and its own string key.

**Announcer typeface**
- Monospace bitmap font, ALL CAPS glyphs only, no anti-aliasing (period CRT aesthetic). Import as BitmapFont resource at res://Fonts/announcer_font.tres. Base size 24px at 1080p, scalable via Settings font-size slider (minimum 16px for house UI, 24px for captions). Captions render white (#FFFFFF) on semi-black (#000000CC).

### Word counting

The six-word cap applies to voiced announcer barks. Each rule:

| Element | Counts as |
|---------|-----------|
| [CLASS] | 1 word |
| [N] | 1 word |
| Digits (1, 7, 24) | 1 word each |
| Articles (A, THE) | 1 word each |
| Period | 0 words |
| Contractions | 1 word |
| Hyphenated words | 1 word |
| Each sentence in a multi-bark (`/`) | Counted independently |

UI labels, settings disclosures, error states, and quit-confirm prompts are exempt from the six-word cap. They are read, not spoken. Class card taglines are UI text, not barks.

### Slot conjugation

No gendered pronouns for any class. The Valkyrie is not special. All four classes use THE [CLASS] and THE [CLASS]'S.

| Class | Subject | Possessive |
|-------|---------|------------|
| WARRIOR | THE WARRIOR | THE WARRIOR'S |
| VALKYRIE | THE VALKYRIE | THE VALKYRIE'S |
| WIZARD | THE WIZARD | THE WIZARD'S |
| ELF | THE ELF | THE ELF'S |

### String-key schema

Every player-facing string has a stable key. Format: `{category}.{event}.{index}`. Fixed lines use `.fixed`. NG+ variants use `.ngp`. The key never changes even when the string is revised, and a string that appears in more than one location keeps one canonical key referenced from each location. Keys are assigned inline throughout the copy bible and confirmed in the String-key coverage table at the end.

| Category | Example key | Example string |
|----------|------------|----------------|
| win | win.1 | THE [CLASS] LEAVES UPRIGHT. |
| lose | lose.3 | THE HALL EATS WELL. |
| encourage | encourage.generator.2 | THE OVEN GOES COLD. |
| event | event.floor_card.fixed | FLOOR [N]. [ZONE NAME]. |
| ngp | ngp.win.1 | THE [CLASS] LEAVES UPRIGHT AGAIN. |
| button | button.pause | Pause |
| error | error.save_spoiled | The save has spoiled. Start fresh? |

### Cycle and playback rules

- Cycles are deterministic, seeded by the run seed. Order is the listed order. **Cycle formula**: offset = run_seed % pool_size. The pointer starts at the offset position and advances by 1 on each dequeue (when a bark from that pool begins playing). Dropped barks (queue overflow, duplicate suppression) do not advance the pointer. On exhaustion, the pointer resets to 0 (not the original offset). No random selection within a pass. Each event type maintains its own pointer and pool.
- **F1 entry ordering**: the class-entry bark fires at T+0. The zone-entry bark fires at T+3.5 (the next spacing slot). Both are fixed barks; neither is cycled. The class-select screen carries its own state-entry bark (WHO SITS TONIGHT?), so the F1 class line never double-fires.
- **Zone-rotation pointer**: resets at the start of each run, including NG+ run 1. Each zone's first-death flag clears on run start.
- Fixed event-map barks fire on their trigger beat. When an event has both a fixed bark and a cycled string on different beats (hero death: THE [CLASS] FALLS. at the moment of death, then a cycled lose string over the crumble; floor clear: FLOOR CLEARED. at the clear, then a cycled win string at the exit door), the fixed bark plays first and the cycled string follows after the caption hold.
- Floor-1 tutorial events use the fixed event-map barks only: KEY. / FOOD. / GENERATOR DOWN. / FLOOR CLEARED. From floor 2 on, those events pull from the cycled encouragement pools instead. The two never overlap.
- **Death-bark priority**: THE [CLASS] FALLS. always fires at the moment of death (fixed bark). After its caption hold, a contextual bark plays in this order:
  1. Cause-specific bark, if the death cause is identified (see Death-cause hierarchy below).
  2. Zone-rotating death line, if this is the first death in the current zone this run. This fires **in addition to**, not instead of, a cause-specific bark. Both play in sequence: cause-specific first, zone-rotating after its caption hold.
  3. Next cycled lose string from the lose pool.
  - The zone-rotation flag is consumed on the first death in a zone regardless of whether a cause-specific bark also fires.
- Floor-entry and zone-entry barks preempt all other barks and flush the queue.

**Death-cause hierarchy** (highest priority first):

| Priority | Cause | Trigger definition | Bark pool |
|----------|-------|--------------------|-----------|
| 1 | Enemy swarm | Fatal enemy damage while 8+ enemies within 2 tiles (64px) of hero at death moment | lose.cause.swarm |
| 2 | Environmental fire/lava | Fatal damage from fire or lava hazard | lose.cause.fire |
| 3 | Environmental pit/fall | Fatal damage from pit or fall hazard | lose.cause.pit |
| 4 | Environmental trap/crush | Fatal damage from trap or crush hazard | lose.cause.trap |
| 5 | Starvation | HP reaches zero from continuous health-drain only, no enemy or environmental damage in the last 1.0 second | lose.cause.starve (3 variants, cycled) |

When multiple damage sources contribute to a fatal hit, the highest-priority source in the hierarchy determines the bark. If no cause matches, the zone-rotating line or cycled lose string fires.

### Bark spacing and queue policy

- Minimum spacing: a new bark starts no earlier than **max(previous_bark_start + 3.5s, previous_caption_clear + 0.5s)**. Spacing is measured start-to-start; the caption-clear clause prevents caption overlap when a clip runs long.
- Caption hold: minimum 2.0 seconds; actual hold = **max(2.0s, audio_duration + 0.25s)**, so a caption never vanishes on the audio's final syllable. Captions mirror every bark word for word.
- Audio clip length is the timing master; spacing and caption rules adapt to it. Clips are hard-capped at 3.0s (see Announcer audio pipeline), so the worst-case gap between bark starts is 3.75s and the minimum is 3.5s.
- Queue depth: 2. If the queue is full when a new bark triggers, the oldest queued bark is dropped. Dropped cycled barks do not advance the cycle pointer.
- A bark identical to one currently playing or queued is dropped.
- Floor-entry and zone-entry barks preempt the queue: always play, flush pending barks.

### Announcer audio pipeline

Announcer lines are **pre-recorded voice clips** processed through a formant-synthesis emulation (SAM-style or vocoder-based processing) to achieve the 1985 speech-synth aesthetic. This is not runtime TTS.

- Clips authored as .wav files (22kHz, mono, 8-bit) at `res://Audio/Announcer/{category}/{key}.wav`, loaded through `ResourceLoader` at scene init.
- Target duration 1.5–2.5s per clip; hard cap 3.0s so bark spacing stays bounded (see Bark spacing and queue policy).
- Slotted lines ([CLASS], [N]) ship as pre-rendered variants: one clip per class per slotted bark, one clip per numeral per slotted bark. Runtime assembly concatenates class prefix + body for slotted barks.
- Clip duration is measured at import and stored in the announcer manifest for timing calculations.
- Timing conflicts resolve by the spacing formula: next bark start = max(previous_bark_start + 3.5s, previous_caption_clear + 0.5s).
- Phonetic spelling guides for custom nouns (HUNGERHALL, CINDERCRYPT, VALKYRIE) are stored in the announcer manifest for voice-actor reference during recording.

### Godot resource schema

| Resource | Path | Format | Purpose |
|----------|------|--------|---------|
| String manifest | `res://Data/strings.json` | JSON | All player-facing strings with keys, text, category, pool index, class variants |
| Announcer audio manifest | `res://Data/announcer_audio.json` | JSON | Maps string keys to .wav paths and measured clip durations |
| Caption font | `res://Fonts/announcer_font.tres` | BitmapFont | Monospace, ALL CAPS, 24px base, no anti-aliasing |
| Announcer audio clips | `res://Audio/Announcer/{category}/{key}.wav` | WAV (22kHz, mono, 8-bit) | Period-synth aesthetic, pre-processed |

String manifest schema: `{key: {text, category, pool_index, class_variants: {warrior, valkyrie, wizard, elf}}}`. UI strings omit class_variants. Fixed lines use pool_index: -1.

### Continue respawn state

CONTINUE restarts the current floor with reduced resources:

| Property | Value |
|----------|-------|
| HP | 50% of class base |
| Potions | 0 |
| Keys | 0 |
| Score penalty | -1000 per continue used |
| Generators | Respawn at full |
| Food | Does not respawn |
| Exit door | State preserved (open if previously opened, locked if not) |

Food staying gone is deliberate: the hunger clock is the game, and a continue that restocked the larder would gut it.

### Accessibility

ALL CAPS for the announcer system is a locked stylistic choice matching the 1985 speech-synth aesthetic. The hybrid casing policy keeps all house UI in Title or Sentence case by default, so no toggle is needed for menus. For captions, baseline accessibility is the two-second minimum hold, verbatim mirroring, caption colors of white (#FFFFFF) on semi-black (#000000CC), and a 24px caption minimum at 1080p; a mixed-case caption mode is deferred to post-launch. Font size floor: 16px minimum for house UI, 24px minimum for captions. Announcer typeface: monospace bitmap font, ALL CAPS, no anti-aliasing (see Announcer typeface rule above).

### Language scope

English-only for the prototype. The ALL CAPS announcer system, pre-recorded audio clips, and class-slot conjugation are incompatible with standard localization pipelines. Re-voicing the synth, re-conjugating class slots, and re-timing captions per language requires a dedicated localization pass. This is accepted technical debt for the prototype; English-only ships as locked.

**Kitchen-metaphor glossary** (for localization reference, not shown to player):

| Term | Meaning |
|------|---------|
| PLATED | killed, served as a meal |
| CHEF | enemy generator |
| OVEN | generator (interchangeable with CHEF) |
| SILVER | keys |
| COURSE | a floor or zone |
| CLEAN PLATE | campaign clear |
| GUESTBOOK | high score table |
| BILL | treasure / score value |

### Feature scope validation

NG+ and attract replay strings in this bible are **provisional**. The original artifact references G2 §11 for voice lines and G2 §1 for the state machine. If G2 does not explicitly lock NG+ or attract replay as features, these strings can be removed without affecting the voice bible's core. The voice rules and core copy bible do not depend on them. The attract-replay error state (error.replay_missing) is likewise provisional and ships only if G2 confirms the attract replay feature.

## Character cast

**The Announcer, who is the hall.** "No characters" was considered and refused. The frozen G2 design (§11) already gives the building an appetite and an opinion in its sample voice lines. A voice billed as a mere utility cannot deliver lines like "THE HALL LOSES A CHEF" honestly. So: one character. HUNGERHALL itself speaks, in period synth, flat cadence, short clauses. It has flawless manners and exactly one appetite. It addresses the hero by class title, remarks on the hero's fate the way a host reads the evening specials, and is quietly, genuinely pleased when the meal fights back. It never lies: if it says FOOD, HP is actually restored. It never panics, never raises its voice. Its emotional spectrum starts at courteous and ends at marginally more courteous. Players learn to hear the difference.

The hall's terseness is its character, not a utility mode. Single-word barks, FOOD. KEY. SILENCE., are the hall naming each course as it arrives. A waiter who says "Soup." is not being mechanical. He is being efficient. The hall is efficient the same way. It never uses first person. It speaks of itself as THE HALL, observing its own appetite from across the room, and that dissociation, the building watching itself eat, is what makes the voice unfamiliar in a genre full of chatty dungeons.

No second character. The four heroes are silent. Their throws talk. No mascot, no shopkeeper, no tutorial fairy. One voice with good posture is the cast.

## World snapshot

"No world" was considered and refused. G2 froze four zone names with distinct tile sets, enemy rosters, and hazards. Floor cards and zone-entry barks require named places. The world stays thin on purpose: one building, one stairwell, one diet. What the player knows arrives through barks, floor cards, and tiles.

HUNGERHALL is one building with one diet. Twenty-four floors, one stairwell, no lobby. Four zones, each a course:

| Zone | Floors | One-line identity |
|------|--------|-------------------|
| DROWNED VAULTS | 1-6 | The cellar. Wet stone, standing water, ghosts first. |
| CINDERCRYPT | 7-12 | The kitchen. Flame jets, lobbers over walls, sorcerers through them. The floor burns. |
| STARVED DEEP | 13-18 | The long dining room after a famine. Bridges over nothing. Death takes a seat. |
| THE HOLLOW THRONE | 19-24 | The head of the table. Three generators, collapsing void, the final course. |

No codex, no bestiary, no item flavor text, no lore screen. Everything is learned by descending. Nothing is narrated.

## Copy bible — every player-facing string

### Title screen

- [title.logo] HUNGERHALL
- [title.tagline] ALL ARE WELCOME. ALL ARE EATEN.
- [title.attract.1, cycles behind logo with score table] FREE TO ENTER. COSTLY TO LEAVE.
- [title.attract.2] SERVICE RUNS 24 FLOORS DEEP.
- [title.guestbook_header] The Guestbook
- [button.new_game] New Game
- [button.continue, only when a save exists] Continue
- [button.new_game_plus, only after a campaign clear] New Game+
- [button.settings] Settings
- [button.credits] Credits
- [button.quit] Quit

The Guestbook label appears on the title screen as the score-table header, establishing the term in context before the player encounters it elsewhere. A sign-in book for scores is self-evident in that context. No primer is needed; the hall does not explain its furniture.

### Class select

- [class.header] Tonight's Menu
- [event.class_select.fixed, announcer on state entry] WHO SITS TONIGHT?
- [class.card.warrior] WARRIOR: Walks through the bite. Keeps coming.
- [class.card.valkyrie] VALKYRIE: Holds the table. Weathers the course.
- [class.card.wizard] WIZARD: Clears the plate. Dies on the last bite.
- [class.card.elf] ELF: Strikes from afar. Starves in close.
- [label.hp] HP
- [label.speed] Speed
- [label.shot] Shot
- [label.potion] Potion
- [button.descend] Descend
- [button.back] Back

### Buttons (in-game, all states)

- [button.pause] Pause
- [pause.header] Paused
- [button.resume] Resume
- [button.settings] Settings
- [button.quit_to_title] Quit to Title
- [quit.text] Quit to title? The hall forgets this floor.
- [quit.yes] Quit
- [quit.no] Stay
- [continue.ring] Continue? x[N]
- [continue.yes] Yes
- [continue.no] No
- [continue.zero_ui, held 2s, then Game Over] No continues
- [continue.zero_bark] NO CONTINUES.
- [button.next_floor] Next Floor
- [button.save_quit] Save and Quit
- [button.return_title] Return to Title
- [button.back] Back
- [button.done] Done
- [button.reset_defaults] Reset Defaults
- [initials.prompt] Sign the guestbook.
- [initials.done] Done

### Tutorial / onboarding

Budget (G0): 60s, 3 screens, 30 words. Spent: **13 words, 0 dedicated screens**, everything overlaid on the floor-1 play screen, timed beats done by T+30 per the G2 contract.

- [T+0 entry bark, spoken + captioned, one per run — keys event.class_entry.{class}.fixed]
  - (Warrior) THE WARRIOR SITS DOWN.
  - (Valkyrie) THE VALKYRIE FINDS A SEAT.
  - (Wizard) THE WIZARD JOINS THE MENU.
  - (Elf) THE ELF ARRIVES HUNGRY.
- [tutorial.move, T+4 idle, glyph + word] MOVE
- [tutorial.throw, T+10 idle, glyph + word] THROW
- [first-event barks, captions mirroring, floor 1] GENERATOR DOWN. / KEY. / FOOD. / FLOOR CLEARED.

**Tutorial speedrun rule**: If the player performs the prompted action before the prompt fires (e.g., throws before T+10), the prompt is silently skipped. No queued tutorial prompt survives past its trigger condition. Already-performed actions do not generate prompts.

Ledger: 5 (entry, billed at its longest variant, not four times) + 1 (MOVE) + 1 (THROW) + 2 (GENERATOR DOWN.) + 1 (KEY.) + 1 (FOOD.) + 2 (FLOOR CLEARED.) = 13 words. Even counting the first cycled win string at the exit door (6 words maximum), the floor-1 total stays at 19, under the 30-word cap. Door, potion, and chest are taught on floors 2 and 3 without a single word: placement, icon flash, silhouette (G2 §3). Potion effects are taught visually on first pickup: sprite flash, icon reveal, class-specific color (G2 §11); the announcer speaks the potion name once, on first use per run. If G4 flags the visual flash as insufficient to communicate the effect, a fallback bark (POTION.) is specified but not enabled unless flagged. Captions hold two seconds minimum. The HUD stays wordless: numerals and icons only.

**Floor-1 generator teaching**: GENERATOR DOWN. fires on the destruction of the first generator the player destroys on F1, not on generator spawn. The player learns generators exist by seeing enemies emerge and discovering the generator through play. The bark confirms the destruction, teaching the cause-effect relationship.

### Win / lose / encouragement strings

**WIN strings** (floor clear, 10 cycled at the exit door):

1. [win.1] THE [CLASS] LEAVES UPRIGHT.
2. [win.2] ONE GUEST WALKS OUT.
3. [win.3] THE HALL BITES ITS TONGUE.
4. [win.4] PLATE CLEARED. GUEST STANDING.
5. [win.5] THE KITCHEN MISSES ONE.
6. [win.6] STAIRS FOUND. THE HALL NOTES IT.
7. [win.7] NOT ON THE MENU TONIGHT.
8. [win.8] DOWN, THEN. MIND THE STEP.
9. [win.9] HUNGRIER BELOW. THE HALL WAITS.
10. [win.10] A MEAL POSTPONED.

Fixed win lines (never cycled):

- [win.zone_capstone.fixed, zone capstone, F6 / F12 / F18] COMPLIMENTS OF THE KITCHEN.
- [win.campaign.1.fixed, campaign clear, F24, first bark] THE KITCHEN CLOSES.
- [win.campaign.2.fixed, campaign clear, F24, second bark] THE [CLASS] DOES NOT.

**LOSE strings** (death, 10 cycled over the crumble):

1. [lose.1] THE [CLASS] IS PLATED.
2. [lose.2] SERVICE, AT LAST.
3. [lose.3] THE HALL EATS WELL.
4. [lose.4] THE [CLASS] GOES QUIET.
5. [lose.5] THE [CLASS] COMPLIMENTS THE COURSE.
6. [lose.6] NOTHING LEFT BUT THE BONES.
7. [lose.7] THE HALL SAVORS THAT ONE.
8. [lose.8] THE HALL ASKS FOR SECONDS.
9. [lose.9] ANOTHER HERO FEEDS THE FLOOR.
10. [lose.10] A SHORT SEATING.

Zone-rotating death lines (one per zone, full G2-locked names, first death in each zone per run):

- [lose.zone.drowned] THE DROWNED VAULTS DEVOUR THE [CLASS].
- [lose.zone.cinder] THE CINDERCRYPT DEVOURS THE [CLASS].
- [lose.zone.starved] THE STARVED DEEP DEVOURS THE [CLASS].
- [lose.zone.hollow] THE HOLLOW THRONE DEVOURS THE [CLASS].

Cause-specific death barks (replace the cycled lose string when the cause is identified; see Death-cause hierarchy):

- [lose.cause.starve.1, starvation] THE [CLASS] STARVES AT THE TABLE.
- [lose.cause.starve.2, starvation] THE PLATE IS EMPTY.
- [lose.cause.starve.3, starvation] THE [CLASS] RUNS DRY.
- [lose.cause.fire, environmental fire/lava] THE HALL SERVES IT HOT.
- [lose.cause.pit, environmental pit/fall] THE [CLASS] MISSES THE STEP.
- [lose.cause.trap, environmental trap/crush] THE FLOOR TAKES THE [CLASS].
- [lose.cause.swarm, enemy swarm] THE COURSE OVERWHELMS THE [CLASS].

Fixed lose lines (never cycled):

- [lose.game_over.fixed, game over, tokens spent] THE HALL KEEPS THE MEAL.
- [lose.header] Game Over

**ENCOURAGEMENT strings** (mid-floor, event-scoped, cycled within event):

Generator destroyed (floor 2+; floor 1 uses GENERATOR DOWN. from the event map):
1. [encourage.generator.1] ONE BURNER OFF.
2. [encourage.generator.2] THE OVEN GOES COLD.
3. [encourage.generator.3] THE HALL LOSES A CHEF.
4. [encourage.generator.4] A COURSE GOES UNFINISHED.
5. [encourage.generator.5] THE KITCHEN MISSES A STATION.

Key pickup (floor 2+; floor 1 uses KEY. from the event map):
1. [encourage.key.1] THE [CLASS] TAKES THE SILVER.
2. [encourage.key.2] DOORS OPEN FOR THE [CLASS].
3. [encourage.key.3] THE HALL LOSES A TOOTH.
4. [encourage.key.4] THE [CLASS] PICKS THE LOCK.
5. [encourage.key.5] THE HALL FORGETS A DOOR.

Food eaten (floor 2+; floor 1 uses FOOD. from the event map):
1. [encourage.food.1] THE [CLASS] EATS.
2. [encourage.food.2] A BITE BETWEEN COURSES.
3. [encourage.food.3] THE PLATE EMPTIES.
4. [encourage.food.4] THE HALL FEEDS THE [CLASS].
5. [encourage.food.5] THE HALL WATCHES IT GO.

Treasure chest:
1. [encourage.treasure.1] THE HALL MISPLACES SOMETHING.
2. [encourage.treasure.2] OLD COINS. STILL SPEND.
3. [encourage.treasure.3] THE [CLASS] FINDS THE TILL.
4. [encourage.treasure.4] THE HALL'S POCKETS LEAK.
5. [encourage.treasure.5] THE [CLASS] POCKETS THE HALL.

Continue accepted:
1. [encourage.continue.1] THE [CLASS] RETURNS TO THE TABLE.
2. [encourage.continue.2] THE HALL SERVES AGAIN.
3. [encourage.continue.3] THE [CLASS] GETS ANOTHER PLATE.
4. [encourage.continue.4] THE [CLASS] PICKS UP THE FORK.
5. [encourage.continue.5] THE HALL HAS ANOTHER READY.

Death (the enemy) killed:
1. [encourage.death_killed.1] THE HALL UNSEATS DEATH.
2. [encourage.death_killed.2] DEATH IS OFF THE MENU.
3. [encourage.death_killed.3] THE HALL SENDS DEATH HOME.
4. [encourage.death_killed.4] DEATH MISSES THIS COURSE.
5. [encourage.death_killed.5] NO SEAT FOR DEATH.

Room cleared (enemies down, floor not done): no bark. Silence is intentional. The hall does not comment on a quiet room, and a single repeated bark on a frequent event would cheapen it. FLOOR CLEARED. plays only on floor completion.

### First-encounter enemy barks

Played once per run on the first encounter with each enemy type. ALL CAPS, period-terminated, max six words.

- [event.first.ghosts, first ghosts, F1+, DROWNED VAULTS] THE GUESTS ARRIVE EARLY.
- [event.first.lobbers, first lobbers, F7+, CINDERCRYPT] THE KITCHEN THROWS BACK.
- [event.first.sorcerers, first sorcerers, F7+, CINDERCRYPT] THE CHEFS BLINK.
- [event.first.death, first Death, F13+, STARVED DEEP] DEATH TAKES A SEAT.

### NG+ exclusive strings

NG+ replaces the standard pools below with hungrier variants. These are the only lines that change in NG+; all other copy remains identical.

**NG+ floor-entry** (5 cycled, replaces standard floor-entry):
1. [ngp.floor_entry.1] FLOOR [N]. THE HALL REMEMBERS.
2. [ngp.floor_entry.2] THE [CLASS] RETURNS. / THE HALL SMILES.
3. [ngp.floor_entry.3] FLOOR [N]. THE KITCHEN RUNS COLDER.
4. [ngp.floor_entry.4] THE [CLASS] DESCENDS. / THE HALL IS HUNGRIER.
5. [ngp.floor_entry.5] FLOOR [N]. NO MERCY TONIGHT.

**NG+ win strings** (5 cycled, replaces standard win):
1. [ngp.win.1] THE [CLASS] LEAVES UPRIGHT AGAIN.
2. [ngp.win.2] THE HALL UNDERESTIMATES THE [CLASS].
3. [ngp.win.3] NOT ON THE MENU. / STILL NOT.
4. [ngp.win.4] THE KITCHEN MISSES TWICE.
5. [ngp.win.5] THE [CLASS] BREAKS THE COURSE.

**NG+ lose strings** (5 cycled, replaces standard lose):
1. [ngp.lose.1] THE HALL SAVORS THE RETURN.
2. [ngp.lose.2] SECOND SEATING. / SAME RESULT.
3. [ngp.lose.3] THE [CLASS] PLATES AGAIN.
4. [ngp.lose.4] THE HALL ASKS FOR THIRDS.
5. [ngp.lose.5] THE [CLASS] FEEDS THE FLOOR AGAIN.

**NG+ zone-entry** (replaces standard zone-entry):
1. [ngp.zone.1] THE DROWNED VAULTS SERVE COLDER.
2. [ngp.zone.2] THE CINDERCRYPT BURNS HOTTER.
3. [ngp.zone.3] THE STARVED DEEP STARVES FASTER.
4. [ngp.zone.4] THE HOLLOW THRONE SETS TWO CHAIRS.

### Announcer event map

All lines are ALL CAPS, period-terminated, max six words per bark. Captions mirror the synth word for word; hold = max(2.0s, audio_duration + 0.25s), per Bark spacing and queue policy.

- [event.floor_card.fixed, floor title card, all 24] FLOOR [N]. [ZONE NAME].
- [event.class_select.fixed, class select screen entry] WHO SITS TONIGHT? (State-entry bark; fires once per visit to CLASS_SELECT.)
- [event.class_entry.warrior.fixed, class entry, F1, T+0] THE WARRIOR SITS DOWN.
- [event.class_entry.valkyrie.fixed] THE VALKYRIE FINDS A SEAT.
- [event.class_entry.wizard.fixed] THE WIZARD JOINS THE MENU.
- [event.class_entry.elf.fixed] THE ELF ARRIVES HUNGRY.
- [event.floor_entry.1, floor entry, F2+, cycled] FLOOR [N]. THE [CLASS] RETURNS.
- [event.floor_entry.2] THE HALL SERVES FLOOR [N].
- [event.floor_entry.3] FLOOR [N]. THE KITCHEN RUNS HOTTER.
- [event.floor_entry.4] THE [CLASS] DESCENDS.
- [event.floor_entry.5] FLOOR [N]. NO RESERVATIONS TONIGHT.
- [event.zone_entry.f1, zone entry, F1, T+3.5] THE DROWNED VAULTS SERVE COLD.
- [event.zone_entry.f7, zone entry, F7] THE CINDERCRYPT SERVES IT HOT.
- [event.zone_entry.f13, zone entry, F13] THE STARVED DEEP SKIPS MEALS.
- [event.zone_entry.f19, zone entry, F19] THE HOLLOW THRONE SETS ONE CHAIR.
- [event.first_encounter.ghosts] See First-encounter enemy barks (event.first.ghosts).
- [event.first_encounter.lobbers] See First-encounter enemy barks (event.first.lobbers).
- [event.first_encounter.sorcerers] See First-encounter enemy barks (event.first.sorcerers).
- [event.first_encounter.death] See First-encounter enemy barks (event.first.death).
- [event.health_25, health critical, 25%] [CLASS] HUNGERS. (Fires once per drop below 25%; re-triggers only after HP rises above 25% and drops again.)
- [event.health_10.first, health critical, 10%, first time] THE HALL REACHES FOR SALT.
- [event.health_10.repeat, health critical, 10%, repeats] THE [CLASS] IS NEARLY DONE. (Cooldown: 15 seconds between repeats. The cooldown clears early if HP rises above 10% and drops below again; each fresh descent into critical counts as a new trigger.)
- [event.food.f1, food consumed, floor 1] FOOD. (Floor 2+ pulls from the food encouragement pool.)
- [event.key.f1, key found, floor 1] KEY. (Floor 2+ pulls from the key encouragement pool.)
- [event.generator.f1, generator destroyed, floor 1] GENERATOR DOWN. (Floor 2+ pulls from the generator encouragement pool.)
- [event.treasure, treasure chest opened, floor 2+] Pulls from treasure encouragement pool. No bark on floor 1; chest is taught visually.
- [event.continue_accepted, continue accepted, Yes chosen] Pulls from continue accepted encouragement pool.
- [event.death_killed, Death enemy killed] Pulls from death-killed encouragement pool.
- [event.potion.no_bark, potion pickup] no bark. Sprite flash and juice only (G2 §11).
- [event.potion.warrior.first, potion used, first use per run, Warrior] WHIRLWIND.
- [event.potion.valkyrie.first, Valkyrie] AEGIS.
- [event.potion.wizard.first, Wizard] NOVA.
- [event.potion.elf.first, Elf] VOLLEY.
- [event.potion.subsequent, potion used, subsequent uses in same run] no bark; juice only. The player learns the name by hearing it once.
- [event.potion.empty, potion empty, attempt with 0] NO POTIONS.
- [event.death.fixed, hero death] THE [CLASS] FALLS. (A lose string follows over the crumble; see Death-bark priority in Cycle and playback rules.)
- [continue prompt] See Buttons (continue.ring). UI text, not a bark.
- [no continues, UI] See Buttons (continue.zero_ui).
- [no continues, bark] See Buttons (continue.zero_bark).
- [event.floor_cleared.fixed, floor cleared] FLOOR CLEARED. (The cycled win string plays at the exit door.)
- [event.room_cleared, room cleared, enemies down, floor not done] no bark. Silence is intentional.
- [win.campaign.1.fixed, campaign complete, first bark] THE KITCHEN CLOSES. (String listed in Fixed win lines.)
- [win.campaign.2.fixed, campaign complete, second bark] THE [CLASS] DOES NOT. (String listed in Fixed win lines.)
- [event.ngp_unlock.1, New Game+ unlocked, first bark] NEW GAME+ IS SERVED.
- [event.ngp_unlock.2, New Game+ unlocked, second bark] THE HALL IS HUNGRIER.
- [event.food_full, food eaten at full HP] no bark; no waste indicator (G2 §11).

**State no-bark rules** (acceptance criterion 1 coverage):

| G2 state | Bark rule |
|----------|-----------|
| TITLE | Attract lines cycle behind the logo; no event-driven barks |
| CLASS_SELECT | WHO SITS TONIGHT? fires on state entry; otherwise silent |
| PLAY | All gameplay event barks fire from this state |
| PAUSE | No bark. The hall does not comment on intermissions. The bark queue freezes and resumes on Resume. |
| CONTINUE_OFFER | No bark while tokens remain. When tokens reach zero, NO CONTINUES. fires, then transition to GAME_OVER. |
| FLOOR_RESULTS | FLOOR CLEARED. fires on floor completion (before the transition); the cycled win string plays at the exit door. Silent in the results screen itself. |
| CAMPAIGN_RESULTS | THE KITCHEN CLOSES. / THE [CLASS] DOES NOT. fire on completion (before the transition). Silent in the results screen itself. |
| GAME_OVER | THE HALL KEEPS THE MEAL. (fixed bark, fires once on entry) |

### HUD elements

Wordless. Numerals and icons only. A nostalgic player reads HP and score without words.

- [hud.hp] [numeral only, 40px minimum, top-left]
- [hud.score] [numeral only, 40px minimum, top-center]
- [hud.floor] F[N] [small, top-right]
- [hud.potions] [potion icon] [numeral]
- [hud.keys] [key icon] [numeral]
- [hud.tokens] x[N] [shown only on continue screen]
- [hud.death_penalty, death penalty indicator, rolling red subtraction on dying] [knife icon] [-N] [no text label]

### Floor results

- [results.floor.header] Floor [N] Cleared
- [results.floor.time] Time
- [results.floor.kills] Kills
- [results.floor.food] Food Eaten
- [results.floor.score] Score
- [results.floor.saved] Saved
- [button.next_floor] Next Floor
- [button.save_quit] Save and Quit

### Campaign results

- [win.campaign.1.fixed, announcer, first bark] THE KITCHEN CLOSES.
- [win.campaign.2.fixed, announcer, second bark] THE [CLASS] DOES NOT.
- [results.campaign.time] Time
- [results.campaign.kills] Kills
- [results.campaign.food] Food Eaten
- [results.campaign.floors] Floors
- [results.campaign.score] Score
- [results.campaign.clean_plate] A Clean Plate: [CLASS]
- [results.campaign.ngp_panel] New Game+ is served. The hall is hungrier.
- [initials.prompt] Sign the guestbook.
- [initials.entry] 3 characters, A-Z only, arcade-style entry
- [initials.done] Done
- [button.return_title] Return to Title

### Game over

- [gameover.header] Game Over
- [lose.game_over.fixed, announcer] THE HALL KEEPS THE MEAL.
- [gameover.score] Final Score: [N]
- [initials.prompt] Sign the guestbook.
- [initials.entry] 3 characters, A-Z only, arcade-style entry
- [initials.done] Done
- [button.return_title] Return to Title

### High score table

- [scores.header] The Guestbook
- [scores.tab.standard] Standard
- [scores.tab.ngp] New Game+
- [scores.col.rank] Rank
- [scores.col.name] Name
- [scores.col.score] Score
- [scores.col.class] Class
- [scores.empty.standard] The guestbook is blank. Someone must eat first.
- [scores.empty.ngp] No second seatings yet.

### Error states

Error states are UI text (Sentence case), not announcer barks. The hall does not bark during error states, but the text uses the hall's third-person voice per the Settings and error voice boundary rule.

- [error.save_spoiled] The save has spoiled. Start fresh?
- [error.save_old_build] A save from an older kitchen. Start fresh?
- [error.controller_dropped] Controller unseated. The keyboard stands ready.
- [error.controller_reconnected] Controller seated again.
- [error.audio_lost] Silence now. Playing muted.
- [error.replay_missing, provisional — ships only if G2 confirms attract replay feature] Attract replay spoiled. Title loop only.
- [error.save_write_failed] The save fails. Disk may be full.

### Empty states

- [scores.empty.standard, guestbook, no entries] The guestbook is blank. Someone must eat first.
- [scores.empty.ngp, guestbook, NG+ tab, no entries] No second seatings yet.
- [empty.no_save] No string. Continue stays hidden until a save exists (state machine, G2 §1).

### Settings labels

- [settings.header] Settings
- [settings.audio] Audio
- [settings.music] Music
- [settings.effects] Effects
- [settings.announcer] Announcer
- [settings.mute_all] Mute All [On / Off]
- [settings.video] Video
- [settings.fullscreen] Fullscreen [On / Off]
- [settings.resolution] Resolution
- [settings.accessibility] Accessibility
- [settings.reduced_motion] Reduced Motion [On / Off]
  - [settings.reduced_motion_sub] Still camera. Soft light. Good manners.
- [settings.screen_shake] Screen Shake [On / Off]
- [settings.freeze_frames] Freeze Frames [On / Off]
- [settings.font_size] Font Size (minimum 16px)
- [settings.auto_fire] Auto-Fire [On / Off]
- [settings.easy_mode] Easy Mode Assist [On / Off]
  - [settings.easy_mode_disclosure] Hold throw. The hall serves the nearest threat.
  - [settings.easy_mode_sub] Nothing gated. The bill stands.
- [settings.rumble] Rumble [On / Off]
- [settings.rumble_strength] Rumble Strength [0 / 50 / 100]
- [settings.controls] Controls
- [settings.remap] Remap Controls
- [settings.reset_defaults] Reset Defaults
- [settings.game] Game
- [settings.reset_scores] Reset Scores
- [settings.delete_save] Delete Save
- [button.back] Back
- [button.done] Done

### Key remapping screen

- [remap.move_up] Move Up
- [remap.move_down] Move Down
- [remap.move_left] Move Left
- [remap.move_right] Move Right
- [remap.throw] Throw
- [remap.potion] Potion
- [remap.pause] Pause
- [remap.prompt] Press any key
- [button.reset_defaults] Reset Defaults
- [button.back] Back

### Credits screen

- [credits.header] Credits
- [credits.1] Hungerhall
- [credits.2] Cooked in Godot.
- [credits.3] All ingredients original.
- [credits.4] Good company.
- [credits.production, smaller type, divider above] Prepared with the Sneferu Pipeline.
- [button.back] Back

No announcer voice on the credits screen. The hall has nothing to say about credits. The production line is displayed in smaller type below a divider, separate from the main credit lines. It uses the kitchen register ("prepared") to stay in voice while attributing the pipeline. Legal and IP hygiene live in the voice rules and anti-anchors; no defensive disclaimer ships in player-facing text.

### String-key coverage

Every player-facing string in this bible has a key assigned above. The following categories confirm full coverage. Counts are keyed lines per screen; `button.*`, `initials.*`, `win.campaign.*`, and `lose.game_over.fixed` keys are shared across screens and counted in each location where they appear.

| Category | Key prefix | Lines | Coverage |
|----------|-----------|-------|----------|
| Title screen | title.*, button.* | 11 | Complete |
| Class select | class.*, event.class_select.fixed, label.*, button.* | 12 | Complete |
| In-game buttons | button.*, pause.*, quit.*, continue.*, initials.* | 21 | Complete |
| Tutorial | event.class_entry.*, tutorial.*, event.* (F1 fixed) | 10 | Complete |
| Win pool | win.* | 10 cycled + 3 fixed | Complete |
| Lose pool | lose.* | 10 cycled + 4 zone + 7 cause + 2 fixed | Complete |
| Encouragement pools | encourage.* | 6 pools x 5 = 30 | Complete |
| First encounters | event.first.* | 4 | Complete |
| NG+ pools | ngp.* | 5 + 5 + 5 + 4 = 19 | Complete (provisional) |
| Event map | event.*, win.campaign.*, continue.* | 35+ triggers | Complete |
| HUD | hud.* | 7 | Complete |
| Floor results | results.floor.*, button.* | 8 | Complete |
| Campaign results | results.campaign.*, win.campaign.*, initials.*, button.* | 13 | Complete |
| Game over | gameover.*, lose.game_over.fixed, initials.*, button.* | 7 | Complete |
| High scores | scores.* | 9 | Complete |
| Error states | error.* | 7 (1 provisional) | Complete |
| Empty states | scores.empty.*, empty.* | 3 | Complete |
| Settings | settings.*, button.* | 29 | Complete |
| Key remap | remap.*, button.* | 10 | Complete |
| Credits | credits.*, button.* | 7 | Complete |

## Acceptance criteria

1. Every G2 state machine state (TITLE, CLASS_SELECT, PLAY, PAUSE, CONTINUE_OFFER, FLOOR_RESULTS, CAMPAIGN_RESULTS, GAME_OVER) has at least one bark or an explicit "no line" rule. CLASS_SELECT: WHO SITS TONIGHT? on entry. PAUSE: no bark, queue freezes. CONTINUE_OFFER: no bark while tokens remain; NO CONTINUES. when tokens reach zero.
2. No voice rule is violated by any string in the copy bible. Error states, quit-confirm prompts, and replay-spoiled notices use the hall's third-person voice by design (see Settings and error voice boundary rule); this is intentional, not a boundary violation.
3. All encouragement pools (generator, key, food, treasure, continue, death-killed) contain 5+ unique strings with distinct sentiments.
4. Win and lose pools contain 10+ strings each, plus 4 zone-rotating death lines and 7 cause-specific death barks.
5. Tutorial copy is 13 words total (19 counting the first win string), 0 dedicated screens, timed beats complete by T+30. Under the 30-word / 3-screen / 60s G0 cap. Speedrun skip rule covers already-performed actions.
6. No slop-tells in any voiced bark or house-UI string: zero em-dashes, zero banned verbs, zero exclamation marks, zero triple-stacked adjectives.
7. All [CLASS] slots have conjugation table entries. No gendered pronouns for any class.
8. Every voiced bark respects the six-word cap, each sentence counted independently; multi-thought lines ship as separate barks joined by `/`. The `/` delimiter denotes sequence, never choice, and is never player-facing.
9. String-key schema covers every player-facing string; keys assigned inline and confirmed in the String-key coverage table. A string appearing in multiple locations keeps one canonical key.
10. Bark spacing (next start = max(previous_bark_start + 3.5s, previous_caption_clear + 0.5s)), caption hold (max(2.0s, audio_duration + 0.25s)), queue policy (depth 2, drop oldest, dropped barks do not advance pointer, duplicates dropped), preemption rules, and the 3.0s clip cap are implementable with defined numbers.
11. Continue respawn state is fully specified: HP 50%, potions 0, keys 0, score -1000 per continue, generators respawn, food does not, exit door state preserved (open if previously opened, locked if not).
12. Casing policy is consistent: ALL CAPS for the announcer system, Title Case for short UI labels, Sentence case for longer UI text, class names ALL CAPS everywhere. No slop-tells in either register.
13. Zone names use full G2-locked names in all barks: DROWNED VAULTS, CINDERCRYPT, STARVED DEEP, THE HOLLOW THRONE. Zone-entry and floor-title barks confirm presence.
14. All barks, floor cards, and event-map strings use present tense. House UI (error states, settings disclosures, credits) is exempt from the present-tense rule. No past-tense violations in barks.
15. Credits ship non-voiced in the house register; no announcer voice on the credits screen. Production line display spec defined (smaller type, divider above). No defensive legal disclaimer in player-facing text.
16. NG+ and attract-replay strings are confirmed in scope by G2 or removed before implementation; the core bible does not depend on them. Attract-replay error state is marked provisional.
17. Audio pipeline specified: pre-recorded clips processed through formant-synthesis emulation, target 1.5–2.5s with a 3.0s hard cap, slotted lines shipped as per-class pre-rendered variants, clip durations measured at import into the announcer manifest, timing conflicts resolved by the spacing formula.
18. Death-cause hierarchy defined (enemy swarm > environmental fire/lava > pit/fall > trap/crush > starvation) with concrete trigger thresholds; zone-rotating death line fires in addition to cause-specific bark, not instead of it.
19. Cycle formula specified (offset = run_seed % pool_size, advance on dequeue only, dropped barks do not advance, reset to 0 on exhaustion); F1 class-entry and zone-entry ordering fixed (T+0 and T+3.5); zone-rotation pointer resets on each run including NG+.
20. Localization incompatibility acknowledged as accepted technical debt; English-only ships as locked. ALL CAPS, pre-recorded audio, and class-slot conjugation require a dedicated localization pass.

**Definition of done:** All 20 criteria met. No open contradictions. No rule violations. Slop detector returns 0 hits on all voiced barks and house-UI strings. Every player-facing string has a string key confirmed in the coverage table. Audio pipeline, cycle formula, death-cause hierarchy, and timing resolution are implementable without guesswork. Implementation can proceed.

## Obligation Responses

OBL-1: ADDRESSED — "ONE LESS CHEF" replaced with "A COURSE GOES UNFINISHED." in the generator pool (distinct sentiment: incompleteness vs. station loss). Tonal anchor 2 now quotes two shipped pool lines (THE OVEN GOES COLD. / THE HALL LOSES A CHEF.), and the ONE/TWO idiom list references only shipped strings.
OBL-2: ADDRESSED — F1 ordering: class-entry bark at T+0, zone-entry at T+3.5 (next spacing slot), both fixed, never cycled. The class-select screen carries its own state-entry bark (WHO SITS TONIGHT?), so the F1 class line never double-fires.
OBL-3: ADDRESSED — Death-cause hierarchy table defines swarm (fatal enemy damage with 8+ enemies within 2 tiles / 64px at the death moment), environmental fire/lava, pit/fall, and trap/crush (by hazard type), and starvation (drain-only, no enemy or environmental damage in the last 1.0s). Highest-priority source wins; unmatched deaths fall to the zone-rotating line or cycled lose string.
OBL-4: ADDRESSED — 10% repeat bark cooldown set to 15 seconds, cleared early by healing above 10% and dropping back; specified in the event map.
OBL-5: ADDRESSED — Zone-rotation pointer and per-zone first-death flags reset at the start of each run, including NG+ run 1 (Cycle and playback rules).
OBL-6: ADDRESSED — "No Atari recipes borrowed." removed from credits. IP hygiene lives in the voice rules and anti-anchors only.
OBL-7: ADDRESSED — "The building is barely trying." removed from the DROWNED VAULTS world-snapshot row.
OBL-8: ADDRESSED (kept) — "The Guestbook" retained as the score-table header. Antecedent documented: the title screen establishes the term in context before the player encounters it elsewhere; a sign-in book for scores is self-evident in that context. The hall does not explain its furniture.
OBL-9: ADDRESSED — "Nothing gated. Every score counts." replaced with "Nothing gated. The bill stands." (kitchen register; ties to the BILL glossary term).
OBL-10: ADDRESSED — Floor-entry cycled pool trimmed from 6 to 5; "THE HALL WAITS." removed as the weakest line.
OBL-11: ADDRESSED — Tutorial speedrun rule: an action performed before its prompt fires silently skips the prompt; no queued tutorial prompt survives past its trigger condition.
OBL-12: ADDRESSED — Settings and error voice boundary rule: error states, quit-confirm prompts, and replay-spoiled notices use the hall's third-person voice in Sentence case; there is no separate error voice, and the announcer never barks an error.
OBL-13: ADDRESSED — Acceptance criterion 6 clarified to "no slop-tells in any voiced bark or house-UI string."
OBL-14: ADDRESSED — All tutorial event barks use period-terminated form (FOOD. / KEY. / GENERATOR DOWN. / FLOOR CLEARED.) consistently.
OBL-15: ADDRESSED — Criterion 2 acknowledges error/quit-confirm hall-voice use as intentional per the boundary rule, not a violation.
OBL-16: ADDRESSED — "THE HALL MISPLACED SOMETHING." corrected to present-tense "THE HALL MISPLACES SOMETHING."; "OLD COINS. STILL SPENDS." corrected to "OLD COINS. STILL SPEND." for number agreement.
OBL-17: ADDRESSED — Event map includes trigger entries for the treasure-chest, continue-accepted, and Death-killed pools.
OBL-18: ADDRESSED — PAUSE state no-bark rule added to the state no-bark table (queue freezes, resumes on Resume).
OBL-19: ADDRESSED — String-key coverage table added; keys assigned inline throughout the copy bible; criterion 9 updated.
OBL-20: ADDRESSED — Tense scope rule: present tense applies to barks, floor cards, zone-entry lines, and event-map strings; house UI (error states, settings disclosures, credits) is exempt.
OBL-21: ADDRESSED — Production-line display spec: smaller type, divider above, separate from the numbered credit lines.
OBL-22: ADDRESSED — See OBL-4 (15-second cooldown with healing gate, in event map).
OBL-23: ADDRESSED — "Built with the Sneferu Pipeline" rewritten to "Prepared with the Sneferu Pipeline." (kitchen register).
OBL-24: ADDRESSED — "Every score counts" replaced with "The bill stands" in the Easy Mode disclosure sub-line.
OBL-25: ADDRESSED — Credits rewritten: Atari line removed; "Thanks for the company" changed to "Good company."; pipeline line in kitchen register.
OBL-26: ADDRESSED — Cycle formula specified: offset = run_seed % pool_size; pointer advances on dequeue only; dropped barks do not advance; reset to 0 on exhaustion.
OBL-27: ADDRESSED — Announcer typeface specified: monospace bitmap font, ALL CAPS glyphs, no anti-aliasing, res://Fonts/announcer_font.tres; captions white (#FFFFFF) on semi-black (#000000CC); size floors 16px UI / 24px captions.
OBL-28: ADDRESSED — Floor-1 generator teaching: GENERATOR DOWN. fires on the player's first generator destruction, not on spawn; spawn discovery is visual.
OBL-29: ADDRESSED — String keys attached inline to every copy-bible string plus a coverage table confirming full assignment. Duplicate keys for the same string consolidated to canonical keys (win.campaign.*.fixed for campaign barks, lose.game_over.fixed for the game-over bark, continue.* for continue UI) referenced from each location.
OBL-30: ADDRESSED — See OBL-17.
OBL-31: ADDRESSED — PAUSE and CONTINUE_OFFER no-bark rules in the state table; CONTINUE_OFFER fires NO CONTINUES. only when tokens reach zero.
OBL-32: ADDRESSED — Death-bark priority clarified: the zone-rotating line fires in addition to a cause-specific bark, not instead; the zone flag is consumed on the first death in a zone regardless of whether a cause-specific bark also fires.
OBL-33: ADDRESSED — Delimiter semantics rule: `/` denotes a sequence of separate barks, never a choice, never player-facing; each bark in a sequence gets its own caption hold and string key.
OBL-34: ADDRESSED — Continue respawn table: exit door state preserved (open if previously opened, locked if not).
OBL-35: ADDRESSED — Attract-replay error state marked provisional in both the event map and the error-states section.
OBL-36: ADDRESSED — See OBL-4.
OBL-37: ADDRESSED — Bark spacing and audio-timing resolution: next bark start = max(previous_bark_start + 3.5s, previous_caption_clear + 0.5s); caption hold = max(2.0s, audio_duration + 0.25s); clips hard-capped at 3.0s so the worst-case gap between bark starts is 3.75s.
OBL-38: ADDRESSED — Godot resource schema table added (strings.json, announcer_audio.json, BitmapFont, WAV paths and formats); clips load through ResourceLoader at scene init.
OBL-39: ADDRESSED — Tutorial wording fixed: "fixed event-map barks only" replaces "fixed one-word barks only" (GENERATOR DOWN. is two words).
OBL-40: ADDRESSED — See OBL-17 and OBL-32.
OBL-41: ADDRESSED — Cycle formula and F1 ordering both specified in Cycle and playback rules (see OBL-2, OBL-26).
OBL-42: ADDRESSED — See OBL-4.
OBL-43: ADDRESSED — Present-tense and grammar fixes (MISPLACES, STILL SPEND), Atari line removed, "The bill stands" replaces "Every score counts", "A COURSE GOES UNFINISHED." replaces "ONE LESS CHEF."
OBL-44: ADDRESSED — Audio pipeline: pre-recorded clips processed through formant-synthesis emulation; slotted lines ship as per-class pre-rendered variants; target 1.5–2.5s per clip, hard cap 3.0s; durations measured at import into the announcer manifest.
OBL-45: ADDRESSED — See OBL-37 (spacing measured start-to-start with the caption-clear clause).
OBL-46: ADDRESSED — Death-cause hierarchy: enemy swarm > environmental fire/lava > pit/fall > trap/crush > starvation, with concrete trigger thresholds per cause.
OBL-47: ADDRESSED — See OBL-24.
OBL-48: ADDRESSED — Atari line removed; pipeline line rewritten to kitchen register and retained as a production credit in smaller type below a divider; no defensive disclaimer ships in player-facing text.
OBL-49: ADDRESSED — Localization incompatibility acknowledged as accepted technical debt in Language scope; English-only ships as locked.
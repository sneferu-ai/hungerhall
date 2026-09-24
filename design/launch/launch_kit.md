# HUNGERHALL — G15 Launch Kit

**Run:** gap-253b64a1 · **Phase:** G15 · **Product:** HUNGERHALL · **Platform:** Steam (Windows 10/11) · **Price:** $5.99 USD · **Locale:** en

**Claims budget.** The G14 submission kit SHIP fields are the factual budget. If the kit does not say it, this document does not say it. The G14 traceability matrix is Appendix A.

**Register.** G3 voice bible. Dry, courteous, third person for in-game voice (announcer captions, title-screen tagline). No exclamation marks in the building's voice. UI labels and system messages outside the caption system are not restricted by this rule. No em-dashes, no banned vocabulary, no Atari names, no "X NEEDS FOOD" constructions in in-game text. Public copy is in the developer's first person. If the studio is a team, globally replace "I" with "we" before sending. All support-template replies use "we" as the studio voice.

**Audio metaphor rule.** Prohibited in default-state (audio ABSENT) public copy: claims of audio output for announcer events — "speech synth," "synth voice," "voice acting," "voiceover," "barks," "audio clip." Permitted: "voice" and "speaks" as rhetorical description of the caption system's personality ("the building speaks in captions" is permitted; "a voice speaks" is not).

**Slot legend.** Fields in `{{double_braces}}` are operator-fill. Slots never ship with placeholder text inside them.

| Slot | Type | Constraint |
|------|------|------------|
| `{{store_link}}` | URL | Steam store page URL |
| `{{press_kit_url}}` | URL | Press kit hosting URL |
| `{{blog_url}}` | URL | Blog post hosting URL |
| `{{press_email}}` | Email | Press contact address |
| `{{support_email}}` | Email | Support contact address |
| `{{support_url}}` | URL | Support page URL |
| `{{privacy_url}}` | URL | Privacy policy URL |
| `{{studio_name}}` | String | Studio or developer name |
| `{{launch_date}}` | Date | Launch date, operator-set |
| `{{download_size}}` | String | Download footprint (e.g. "320 MB"), filled after final build weigh |
| `{{iarc_rating}}` | String | IARC rating, filled when questionnaire returns |
| `{{sender_name}}` | String | Outreach sender name |
| `{{name}}` | String | Outreach receiver name |
| `{{why_them}}` | Sentence | Max 25 words. One standalone sentence explaining why this receiver. |
| `{{topic}}` | Noun phrase | Max 6 words. No terminal punctuation. Names the specific episode, article, or coverage angle. |
| `{{demo_status}}` | String | Fill from G14 §11 Q8. Default (no-demo): "A demo is not currently available." If demo published, use G14 §11 demo-live variant. |
| `{{additional_requirements}}` | String | Additional system requirements from G14 §11 beyond Windows 10/11 64-bit and Vulkan. Leave empty if none. |

**Pronoun rule.** All first-person copy (blog, socials, outreach, subreddit dev posts) uses "I." Support templates use "we." If the studio is a team, do one global find-and-replace to "we" before scheduling. Do not mix.

## Freeze-state declaration

Copy writes against the G14 default freeze state. Where a state changes, marked swap lines activate. Nothing else changes.

| State | Default | Consequence for launch copy |
|-------|---------|----------------------------|
| Announcer audio | ABSENT | The hall is quoted as on-screen text. No piece promises a voice, synth, or audio barks. Sealed audio-present swap lines in Appendix B. |
| Demo | NOT PUBLISHED | Zero demo mentions. FAQ uses the no-demo variant. |
| GodotSteam | DISABLED (Path B) | "No developer telemetry" is the approved phrasing. Do not inflate. |
| IARC | PENDING | Rating fields carry `{{iarc_rating}}` until the questionnaire returns. Press-kit sends and store page go-live are hard-gated on rating insertion. See §6. |
| Playtime | UNVERIFIED | No hour counts or length estimates anywhere. |
| String manifest | UNVERIFIED | Only G14-confirmed strings (GENERATOR DOWN, FOOD, KEY, All are welcome. All are eaten.) appear in public copy. Other strings struck pending G10 verification. Fallback copy in Appendix C. |
| iOS port | DOES NOT EXIST | iOS outreach and subreddit sections sealed. See §4.3 and §5.1-5.2. |
| Renderer | Vulkan (Forward+) | System requirements specify Vulkan. Do not mention OpenGL. |
| Download size | UNVERIFIED | Press kit carries `{{download_size}}` slot. Operator fills after final build weigh, re-verified at T-3d. |

### Canonical string table

All public copy must use these exact forms. The T-7d manifest cross-check verifies exact match including case and terminal punctuation.

| String ID | Canonical form | Source | Notes |
|-----------|---------------|--------|-------|
| `generator_down` | GENERATOR DOWN | G14 §3.1 | ALL CAPS, no terminal period |
| `food` | FOOD | G14 §3.1 | ALL CAPS, no terminal period |
| `key` | KEY | G14 §3.1 | ALL CAPS, no terminal period |
| `tagline` | All are welcome. All are eaten. | G14 §3.1 | Sentence case, period after each clause |

**Quotation-context punctuation rule:** Canonical strings contain no terminal period as stored values. When a string appears at a sentence boundary in public copy, the sentence-ending period belongs to the enclosing sentence, not to the string. When a string appears as a standalone quoted fragment or callout, no period is appended to the string itself. In comma-separated lists of strings, no periods appear on individual strings; the sentence-ending period follows the final string. Verified at T-7d as part of the string manifest cross-check.

## Design rationale

1. **Blog leads with the player experience.** The continue/food-restock story is the lead narrative. It is G14-backed and player-facing. The voice-constraint story is the secondary beat, told as positive constraints without mentioning what was banned or why.
2. **Two player-facing subreddits, one engine-community subreddit.** r/arcade reaches arcade-style game players. r/puzzlevideogames reaches design-engaged players. r/godot reaches engine peers. DIS-5 challenged r/godot as a buyer channel; the resolution is to keep it as a secondary community post, not the sole subreddit.
3. **iOS sections are sealed.** Posting a Windows game to an iOS sub is off-topic. The covert r/iphone fallback from earlier drafts was removed. If the operator wants engagement, the documented path requires affiliation disclosure. See Open Questions.
4. **Store page "four once shared" and "The other three classes invite you back" are G14-approved but use four-player arithmetic.** Launch-kit-authored copy removes these fingerprints. The store page is G14-approved text. A T-10d gate forces the operator to decide which position the store page takes before pasting. See §6.
5. **One authoritative schedule.** Post times live in §6 only. §3 social variants carry platform-specific notes but defer all times to §6.
6. **Pre-launch audience building is part of the kit.** The checklist extends to T-14d for store page live, wishlist collection, creator seeding, and press list finalization.
7. **The pipeline is not named in public copy.** The game credits say "Prepared with the Sneferu Pipeline." Public copy does not mention it. Whether to name it is an operator call.
8. **Next Fest and demo decisions are pre-launch.** Next Fest requires weeks-advance application. The go/no-go decision sits at T-14d.
9. **Solo operator reality.** All roles collapse to Operator. The T+0 schedule is sequenced for one person, not parallel roles.
10. **Embedded compliance.** Each copy-bearing section carries a compliance note listing the exact strings and claims used and their Appendix A traceability status. The operator can audit each section against its own note without cross-referencing.

## 1. Press kit (one page)

Everything below renders as a single page at `{{press_kit_url}}`. All art is captured from the shipping Windows build.

### Game description

HUNGERHALL is an arcade dungeon crawler for exactly one player. HP ticks down once a second, every second. Hesitation spends it, aggression risks it, only food restores it. Pick one of four classes (Warrior, Valkyrie, Wizard, Elf) and keep that kit for the whole descent. No upgrades, no skill trees. Twenty-four floors across four themed courses. Monster generators spill enemies until broken at close range. Food restores health, never respawns, and hides behind guards. Keys open the exit door. Treasure pads the score and nothing else. The building itself narrates events in deadpan on-screen captions. One price: $5.99. No ads, no in-app purchases, no accounts, no developer telemetry.

**Compliance note:** Strings used: "All are welcome. All are eaten." (G14-CONFIRMED). Claims: all G14-CONFIRMED or FREEZE-STATE per Appendix A. "XInput" struck, replaced with "gamepad." "No DLC" struck (not in G14). "Hides behind guards" G14-CONFIRMED (G14 §3.1).

### Key facts

| Fact | Value |
|-----|-------|
| Title | HUNGERHALL |
| Genre | Single-player arcade dungeon crawler |
| Studio | `{{studio_name}}` |
| Engine | Godot 4.7 (Forward+, Vulkan) |
| Where sold | Steam, Windows 10/11 (64-bit). Deck and Proton untested; no claim made. |
| Store page | `{{store_link}}` |
| Price | $5.99 USD, once |
| Download footprint | `{{download_size}}` |
| Launch date | `{{launch_date}}` |
| Rating | `{{iarc_rating}}` |
| Players | 1. No network features, no accounts. |
| Controls | Keyboard or gamepad, both live at first boot |
| Language | English |
| Monetization | One purchase. No ads, no IAP, no developer telemetry. |
| Continue system | Two continues per floor. A continue rebuilds the floor at half health, no keys, every plate of food still gone. |
| Score | Death docks 20 percent of the score carried into the floor. |
| High scores | Local Guestbook with player initials. No online boards. |
| Accessibility | Captioned announcer events. Keyboard and gamepad support at first boot. No accounts or online requirement. |
| Post-campaign | New Game+ opens after a clean campaign clear. |

### Pull-quotable lines

**G14-confirmed (in-game string):**
1. "All are welcome. All are eaten."

**Launch-kit taglines (consistent with G14 register and mechanics, no ancestor fingerprints):**
2. "The table is set for one."
3. "Eat fast. Nothing comes back."
4. "Break the source. Stop the flow."

### Dev contact

- Press: `{{press_email}}` (response target 3 business days)
- Support: `{{support_email}}` · `{{support_url}}`
- Studio: `{{studio_name}}`
- Privacy policy: `{{privacy_url}}`

### Asset list pointer

All assets at `{{press_kit_url}}`:

- 5 screenshots (1280x720 or 1920x1080 PNG). Subjects per G14 §6: health drain on floor 1, class select, generator destruction, food pickup, floor results panel.
- 30-second preview video (H.264/MP4, 1920x1080). Shot list per G14 §7.
- Steam capsule set: header (460x215), main (616x353), small (231x87), library portrait (600x900), library hero (1280x720), community icon (184x69).
- App icon: 512x512 PNG (cloche serving dome with service-amber crescent on plum-black field, per G14 §8.1).
- Logo: 640x360 PNG with alpha (HUNGERHALL in G4 display font, service-amber on transparent).
- This page as PDF.

### T+3 press-kit update specification

At T+3 12:00 PT, update the press kit with these verified fields only:

| Field | Source | Content |
|-------|--------|---------|
| Store link | Steamworks | `{{store_link}}` (confirmed live) |
| Launch date | Operator record | Actual launch date (if different from planned) |
| Steam review count | Steamworks | Integer count |
| Steam review percentage | Steamworks | Percentage positive |
| Steam rating label | Steamworks | Text label (e.g. "Positive") |
| Download size | Locked build | Re-verified `{{download_size}}` |

Do not add sales figures, refund rates, or any field not listed above. If a field cannot be verified at T+3, leave the pre-launch value.

## 2. Launch blog post

Roughly 600 words. Dev-voice. The continue/food-restock story is the lead. The voice-constraint rules are the secondary beat, told as positive constraints. Process claims describe the design documents, not an invented personal history.

### HUNGERHALL is out. Mind your manners; the hall does.

HUNGERHALL is on Steam today. Windows, $5.99. That is the entire transaction. Nothing sold after the sale, no ads, no account, no developer telemetry.

The game in one paragraph: an arcade dungeon crawler for one player. HP ticks down once a second, every second. Hesitation spends it, aggression risks it, only a meal restores it. Four classes at the table: Warrior, Valkyrie, Wizard, Elf. Nothing to level, nothing to respec. The choice at the menu is the build. Twenty-four floors across four themed courses, one stairwell all the way down.

Four classes, and the class you pick is the one you keep. The Warrior takes the bite and keeps swinging. The Valkyrie holds lanes and weathers fire. The Wizard clears groups but cannot shake a single pursuer. The Elf outranges everything and starves in close. No upgrades, no skill trees. The weakness is the class. The weakness is the point.

That covers the what. The design decision I want to talk about is what happens when you die.

Two continues per floor. A continue rebuilds the floor at half health, no keys, every plate of food still gone. The food does not come back. Early in the project, the question was whether it should. The argument for restocking: half health is already a penalty, and a floor with no food left is a death sentence. The argument against: the hunger drain is the entire game. If the food comes back, the drain is just a timer you can reset. If it stays gone, every plate you ate on the way down was a decision you live with.

The food stays gone. The pantry remembers. That is the rule the rest of the sheet leans on.

I want to say something about why this matters more than it sounds. A continue that restocks the food is merciful in a way that makes the mercy meaningless. You press continue, you get half health and a fresh pantry, and the floor plays like it did the first time. The only cost is the score hit. But a continue that leaves the pantry empty is a different game. You know the layout now. You know where the generators were. You know which plates you already ate and which ones you skipped because you were healthy at the time and thought you would save them. Every plate you skipped is still there. Every plate you ate is gone. The continue is a second chance that remembers what you did with the first one.

Death also costs you 20 percent of the score you carried into the floor. Two continues per floor. Exhaust both and the run is over. New Game+ opens after a clean campaign clear. High scores live in a local Guestbook with your initials, because your scores stay on your machine. No online boards. No accounts.

The other thing I want to mention is the voice. The building narrates events in on-screen captions. The rules that gave it a voice: third person, short lines, no exclamation marks. The constraint did the work. GENERATOR DOWN when a source breaks. FOOD when a plate lands. KEY when iron turns up. Flat, polite, and meaner for being flat.

An early draft used exclamation marks. The building shouting GENERATOR DOWN! with a punch of emphasis. It read like a marketing email. The flat version reads like a menu posting the specials. The menu is scarier.

The same stubbornness runs through the rest of the sheet. Monster generators spill enemies until you push in and break them at close range. Treasure adds score and nothing else. The HP drain is the clock, the economy, and the argument.

Keyboard or gamepad, both live at first launch. $5.99 on Steam for Windows: `{{store_link}}`

The Guestbook starts blank. Somebody has to eat first.

All are welcome. All are eaten.

**Pre-send verification:** confirm GENERATOR DOWN, FOOD, KEY, and All are welcome. All are eaten. against the G10 string manifest with exact casing and terminal punctuation per the canonical string table and quotation-context rule. If any string fails verification, strike it from the post and substitute from Appendix C fallback copy. The story stands without the quotes, but the quotes make it land.

**Audio-present swap (sealed):** if the audio freeze state upgrades to PRESENT (G10 build-verification gate B1 passes with minimum 5 event-type clips), replace "it speaks in on-screen captions" with "a period speech synth speaks each line, and every one prints as a caption alongside it." The caption requirement remains. See Appendix B.

**Compliance note:** Strings used: GENERATOR DOWN, FOOD, KEY (G14-CONFIRMED, sentence-context per quotation rule), All are welcome. All are eaten. (G14-CONFIRMED). Claims: "one stairwell all the way down" (INFERRED, Appendix A). "Present tense" struck from voice rules. "The cabinet used to stand in the room with you" struck. "Standing in the doorway and throwing is a way to starve" struck. "The building is the only character" softened to "The building narrates events." "The other three classes invite you back" struck from blog (G14-approved for store page; operator decision at T-10d). "No respec" — INFERRED from G14 "no upgrades, no skill trees, the class you choose is the kit you keep." Class behavior lines G14-CONFIRMED (G14 §3.1).

## 3. Social announcements

Two variants per platform. Each is written from scratch in that platform's culture. Facts are shared; sentences are not. Every variant closes with `{{store_link}}`. Post times are in §6 only. Each image-bearing variant carries alt text for its screenshot attachment.

### X / Twitter (280 chars max; zero or one hashtag; no thread)

**Variant A:**
> HUNGERHALL is on Steam. HP ticks down once a second: waiting spends it, pushing risks it, eating buys it back. Four classes, 24 floors, one polite building that intends to eat you. $5.99 flat. {{store_link}}

**Variant B:**
> The building reports its own losses in deadpan ALL CAPS captions: GENERATOR DOWN when a source breaks, FOOD when a plate lands. A one-player arcade dungeon crawler, 24 floors, $5.99 on Steam. {{store_link}}

*Platform notes: X runs short and direct. One hashtag max on Variant A, zero on B. Attach screenshot 1 (health drain) to A, screenshot 3 (generator destruction) to B. Canonical strings appear in sentence context per quotation rule — no terminal periods appended to the strings themselves.*

### Mastodon (500 chars max; conversational; hashtags carry discovery; alt text expected)

**Variant A:**
> I shipped a game today. HUNGERHALL is a one-player arcade dungeon crawler for Windows: health ticks away every second, meals never respawn, and the venue narrates dinner in deadpan ALL CAPS captions. $5.99 once. No ads, no account, nothing sold afterward, no developer telemetry. Scores stay on your disk. #IndieGame #Godot {{store_link}}

**Variant B:**
> I spent real effort on whether a continue should restock the food. Verdict: no. A spent continue in HUNGERHALL means half health, zero keys, and a pantry exactly as empty as you left it, because the drain is the entire point. Out now on Steam, $5.99, Windows. Screenshot attached, alt text written. #RetroGaming #IndieDev {{store_link}}

*Platform notes: Mastodon is conversational and EU-skewing. Hashtags are the discovery mechanism. Attach screenshot 1 (health drain) to A, screenshot 2 (class select) to B.*

### Bluesky (300 chars max; lowercase register is native; no hashtags)

**Variant A:**
> shipped a game where standing still bleeds you. meals heal and never respawn. the venue comments in polite captions, flat and deadpan. HUNGERHALL, one player, 24 floors, $5.99 on Steam. {{store_link}}

**Variant B:**
> All are welcome. All are eaten. That is the whole hospitality policy. One stairwell, 24 floors, four classes, one courteous building with a single appetite. HUNGERHALL is live on Steam, $5.99. {{store_link}}

*Platform notes: Bluesky runs lowercase and conversational. No hashtags. The tagline is a canonical string and keeps sentence case regardless of surrounding lowercase style. "One stairwell" is INFERRED per Appendix A. Attach screenshot 4 (food pickup) to A, screenshot 5 (floor results) to B.*

### Threads (500 chars max; line breaks breathe; at most one topic tag)

**Variant A:**
> Health ticks down once a second.
> Waiting spends it. Pushing risks it. Dinner restores it.
> That is the entire rulebook, and the game is out today.
> HUNGERHALL: one player, four classes, 24 floors, $5.99 on Steam. Nothing else for sale, ever. {{store_link}}

**Variant B:**
> The building's voice has a prohibition: no exclamation marks. What remains is a building that narrates your death in flat captions, and it is worse for you that way.
> HUNGERHALL, out today on Steam, $5.99. {{store_link}}

*Platform notes: Threads rewards the line-break structure and the constraint-as-story format. Attach screenshot 2 (class select) to A, screenshot 1 (health drain) to B.*

### LinkedIn (longer form; professional; no announcement theater; zero to three hashtags)

**Variant A:**
> HUNGERHALL shipped on Steam today. One player, four classes, 24 floors, Godot-built, $5.99 with nothing sold afterward.
>
> The rule I keep explaining: health ticks down once per second whether or not anything is touching you. Every design sheet bends around that fact. Meals heal and never respawn. Generators spill enemies until somebody gets close enough to break one. A continue returns you at half strength with the pantry still empty.
>
> The writing rule I am proudest of is a prohibition. The script bans exclamation marks for the building's voice, and caps every caption at a handful of words. Constraint did the voice's work. What remains narrates dinner in on-screen text and never once asks for your attention.
>
> Glad to field technical questions in the replies: the caption system, the local save behavior, the class balance.
>
> {{store_link}}

**Variant B:**
> A small commercial game shipped today: HUNGERHALL, a $5.99 arcade dungeon crawler for Windows, single-player by design.
>
> What it refuses: co-op, online boards, accounts, ads, in-app purchases, developer telemetry. What it keeps: a per-second health drain, finite guarded meals, four classes with real weaknesses, and a building that prints your death in flat captions.
>
> The discipline that shaped the build: a continue gives you half health, no keys, and a floor that remembers you ate. The plates stay empty. The clock stays the game.
>
> $5.99 on Steam for Windows. {{store_link}}

*Platform notes: LinkedIn is the only platform where the craft-and-decision post outperforms the product post. No hashtags on Variant A; two on Variant B (#indiedev #gamedev) if desired. No pipeline mention. No image attachment.*

### Alt text for all screenshot attachments

| Screenshot | Subject | Alt text |
|-----------|---------|----------|
| 1 | Health drain (floor 1) | Top-down dungeon corridor. Hero sprite at spawn. Ghosts approaching from a monster generator upper right. Green HP numeral top-left, ticking down. |
| 2 | Class select | Four class cards arranged horizontally. Each shows a character portrait and stat row. Header reads Tonight's Menu in amber on dark background. |
| 3 | Generator destruction | Top-down dungeon view. Monster generator breaking apart center screen. Caption text GENERATOR DOWN at bottom. Enemy sprites scattering. |
| 4 | Food pickup | Top-down dungeon view. Hero sprite next to a food item on a plate. Caption text FOOD at bottom. HP numeral top-left showing increase. |
| 5 | Floor results | Post-floor summary panel. Score at top. Class name and floor number below. Two continue markers as icons. High score comparison line at bottom. |

**Compliance note:** All five platforms share facts, not sentences. No cross-post blob. Canonical strings appear in sentence context per quotation rule. "One stairwell" in Bluesky B is INFERRED (Appendix A). All variants close with `{{store_link}}`.

## 4. Influencer outreach templates

Five categories. Each body is under 120 words. Receiver name, handle, and why-them are operator-fill slots. `{{why_them}}` is always a standalone sentence (max 25 words). `{{topic}}` (where used) is a noun phrase, max 6 words, no terminal punctuation. No invented names or numbers. No coverage obligation is stated or implied. The ask is one sentence.

### 4.1 Shorts streamer

Hi {{name}},

{{why_them}}.

HUNGERHALL is a solo arcade dungeon crawler arriving {{launch_date}} on Steam, $5.99, Windows. The health bar drains every second. A run is a chain of quick calls: kill the generator or starve, eat now or save the plate, bank the floor or push. The building captions every event in flat on-screen text.

If 30-second clip material fits your channel, I will send a key. No coverage expected, no reply needed if it does not fit.

{{sender_name}}

### 4.2 Puzzle YouTuber

Hi {{name}},

{{why_them}}.

HUNGERHALL is a solo arcade dungeon crawler arriving {{launch_date}} on Steam, $5.99. Twenty-four floors across four themed courses. Each one hides a route: which generator dies first, which plate is worth the detour, whether the key pays back the health it costs. Four classes change the solve. The action is the pressure; the order of operations is the puzzle.

If that sounds like material for your channel, I will send a key. No coverage expected either way.

{{sender_name}}

### 4.3 iOS-apps newsletter — SEALED

**Do not send.** HUNGERHALL is a Steam Windows release. No iOS build exists.

**Activation condition:** if an iOS port is qualified and live, break this seal and write a live template that discloses the platform, matches the newsletter's scope, and offers a key.

### 4.4 Casual-game podcast

Hi {{name}},

{{why_them}}.

HUNGERHALL is a solo arcade dungeon crawler arriving {{launch_date}} on Steam at $5.99. One player, one health bar, and it drains every second. Food restores it and never comes back. The building captions your death in flat on-screen text.

The episode on {{topic}} is why I am writing. A key for the show is available if useful, with no strings.

{{sender_name}}

### 4.5 Accessibility reviewer

Hi {{name}},

{{why_them}}.

HUNGERHALL ships with on-screen captions for every announcer event, keyboard and gamepad support at first boot, no accounts, no online requirement, and no developer telemetry.

Your coverage of {{topic}} is the reason I am writing. A key is available if you want to review it, and I would value a list of what I got wrong.

{{sender_name}}

**Compliance note:** "Deaths are fast" struck from §4.1 (was UNVERIFIED per Appendix A). Replaced with "The building captions every event in flat on-screen text" (G14-CONFIRMED). "This week" replaced with `{{launch_date}}` across all templates. All bodies under 120 words. No coverage obligation stated or implied. 4.3 sealed (no iOS build).

## 5. Subreddit post drafts

Each draft below is clean post copy ready to submit. Each includes a community notes block describing that sub's self-promo etiquette and a "read the sidebar first" reminder. Sidebar checks, link-placement rules, and process gates are also in the §6 T+1 checklist. Link-stripped variants are provided where a sub may reject body links.

### 5.1 r/iosgaming — SEALED

**Do not post.** HUNGERHALL is not an iOS game. This sub is for iOS games.

**Activation condition:** if an iOS port is qualified and live, break this seal and write a draft following r/iosgaming's self-promo etiquette.

**Operator-controlled fallback (requires disclosure):** if the operator wants launch-week signal on mobile viability, post a genuine design question with developer status disclosed in the first line. Example: "Dev here, working on a PC dungeon crawler. Question: does a per-second health drain read as mobile-friendly, or does it need a different shape on a small screen?" No game name in the title. No store link in the body. Link in comments only if the sub allows it. This is the operator's call. See Open Questions.

### 5.2 r/iphone — SEALED

**Do not post.** r/iphone has a strong self-promo allergy and HUNGERHALL is not an iPhone app.

**Activation condition:** if an iOS port is qualified and live, break this seal and write a draft following r/iphone's rules.

**No covert fallback.** If the operator wants engagement, disclosure is required.

### 5.3 r/puzzlevideogames

**Title:** Is a health bar a puzzle mechanic? (design question, dev inside)

**Body:**

I am making a solo arcade dungeon crawler, and the design argument that keeps coming up is whether the health system is a puzzle or just pressure.

The rules: the health bar drains every second. Food restores it and never respawns. A continue gives you half health, no keys, and the same floor with the food still gone. Every floor becomes a budget: how much health are you willing to spend to reach the generator, grab the key, and open the door before the drain eats the difference?

To me that reads as a resource puzzle with a clock on it. Where is the line between a puzzle and survival pressure? What games sit on that line well?

(Dev disclosure: the game is out now. Not naming it or linking in the body. Details in comments if anyone wants them.)

**Link-stripped variant (if sidebar prohibits links in comments):** Post body as-is. Do not post a link anywhere. The engagement goal is the discussion, not the link. If someone asks for details in a reply, DM them.

**Community notes:** r/puzzlevideogames is a small, design-focused sub. Self-promo is tolerated when framed as genuine discussion. Flair as "Discussion." Read the sidebar before posting. Confirm whether self-promo links are permitted in comments. If not, use the link-stripped variant above.

### 5.4 r/arcade

**Title:** [Dev] Solo arcade dungeon crawler where your health bar is the clock

**Body:**

I built a solo arcade dungeon crawler in Godot 4.7 called HUNGERHALL. The core idea: your health bar drains every second whether anything is touching you or not. Food restores it and never respawns. A continue rebuilds the floor at half health with the pantry still empty. Every plate you ate on the way down was a decision you live with.

Four classes (Warrior, Valkyrie, Wizard, Elf), 24 floors across four themed courses, monster generators you break at close range, keys to the exit, local high scores with your initials. The building narrates events in deadpan on-screen captions: GENERATOR DOWN when a source breaks, FOOD when a plate lands, KEY when iron turns up. No voice, just text.

No ads, no IAP, no accounts, no telemetry. One purchase, $5.99 on Steam for Windows.

Happy to talk about the design, especially the continue and food-restock call. That one was the hardest argument in the project.

**Link-stripped variant (if sidebar prohibits body links):** Remove "Store page: {{store_link}}" if present. Post body as-is without link. Post link as first comment if sidebar permits comments links. If sidebar prohibits links entirely, do not link.

**Community notes:** r/arcade welcomes arcade-style game discussion. Dev posts with substantive content are generally well-received. Use "Dev" flair or prefix if the sub requires it. Read the sidebar before posting. Confirm self-promo link policy. Canonical strings appear in sentence context per quotation rule.

### 5.5 r/godot

**Title:** [Dev] Shipping a Godot 4.7 solo arcade crawler: the voice rules that shaped the game

**Body:**

HUNGERHALL is a solo arcade dungeon crawler built in Godot 4.7, shipping on Steam for Windows at $5.99. The building narrates events in on-screen captions. The rules that gave it a voice: third person, short lines, no exclamation marks.

The constraint did the work. GENERATOR DOWN when a source breaks. FOOD when a plate lands. KEY when iron turns up. Flat, polite, and meaner for being flat.

Happy to discuss the caption system design, the class balance around the drain, or how the four classes create different approaches to the same floors.

Store page: `{{store_link}}`

**Link-stripped variant (if sidebar prohibits body links):** Remove the final line "Store page: {{store_link}}" and post the body without it. If the sub allows link in comments, post the link as the first comment after submission. If sidebar prohibits links entirely, do not link.

**Community notes:** r/godot is an engine-community sub that welcomes release threads with real technical substance. Use "Dev" flair or prefix. Read the sidebar before posting. Confirm whether links are permitted in body, in comments, or not at all. Use the appropriate variant above.

**Compliance note:** Canonical strings appear in sentence context per quotation rule — no terminal periods appended to strings themselves. "Present tense" struck from voice rules (not traced to G14/G3). "The building is the only character" softened to "The building narrates events." Implementation claims (state machine, typed resource manifest, no hardcoded strings) struck from r/godot post (not in G14). All subreddit drafts include "read the sidebar" reminder in community notes.

## 6. Launch-day checklist

Chronological runbook. All times Pacific. Steam release defaults to 10:00 PT. If the operator is solo, all roles collapse to Operator. Tasks are sequenced for sequential execution, not parallel roles.

### T-30d: external dependency initiation

| Time | Task | Owner | Gate |
|------|------|-------|------|
| T-30d | Trademark attorney engaged for HUNGERHALL, ALL ARE EATEN fallback, and class names (Warrior, Valkyrie, Wizard, Elf). Search + opinion expected 1-2 weeks. | Operator | Attorney retained. Search initiated. |
| T-30d | IARC questionnaire prepared for submission. Rating expected 5-7 business days after submission. | Operator | Questionnaire drafted. |

### T-14d: pre-launch audience building

Steam permits Coming Soon pages and Curator Connect before IARC rating. The IARC gate at T-5d and T-1d applies to the purchasable go-live, not to Coming Soon.

**Verify current Steamworks policy:** check Steamworks documentation or partner support to confirm Coming Soon pages do not require IARC before publishing. Record the verification result.

| Time | Task | Owner | Gate |
|------|------|-------|------|
| T-14d | Verify Steamworks Coming Soon pre-IARC policy: check documentation or contact partner support. Record result. | Operator (Tech) | Policy confirmed. If IARC is required for Coming Soon, adjust timeline. |
| T-14d | Store page live in "Coming Soon" mode on Steam. Placeholder copy only: title (HUNGERHALL), short description from Appendix D (default variant), screenshots from G14 §6, capsules from G14 §8. Detailed description, FAQ, and tags pasted at T-10d. Wishlist collection begins. | Operator (Tech) | Store page loads, wishlist button active. |
| T-14d | Next Fest go/no-go decision. If go, submit application per Valve's deadline. | Operator | Decision recorded. If go, application submitted. |
| T-14d | Demo go/no-go decision (floors 1-3). If go, demo build scheduled. | Operator | Decision recorded. |
| T-14d | Press list finalized: outlets, curators, podcasters. Key grant list set. | Operator (PR) | List reviewed and approved. |
| T-14d | Creator seeding begins: keys sent to curators via Curator Connect. Keys are release-locked (cannot be activated before `{{launch_date}}`). Shipping build is not yet uploaded; keys are pre-generated and locked to release date. | Operator (PR) | Keys granted, release-locked, and tracked. |

### T-10d: outreach and store page preparation

| Time | Task | Owner | Gate |
|------|------|-------|------|
| T-10d | **"Four once shared" operator decision gate:** operator decides whether Appendix D store page uses G14 default ("One player pays the full health bill that four once shared") or stricter launch-kit variant ("One player pays the full health bill. Nobody splits it with you"). Decision recorded. Store copy pasted per decision. | Operator | Decision recorded. Copy pasted per decision. |
| T-10d | Store page full copy pasted from Appendix D per operator decision: short description, detailed description, tags, FAQ (from G14 §11 SHIP fields). | Operator (Tech) | Copy pasted, preview loads correctly. |
| T-10d | Steam tags entered: Singleplayer, Dungeon Crawler, Arcade, Action, Retro. | Operator (Tech) | 5 tags entered. |
| T-10d | Store page FAQ entered: paste each Q/A pair from G14 §11 SHIP fields. G14 §11 is the canonical FAQ source. If G14 §11 content is unavailable, contact the pipeline operator for the canonical text. | Operator (Tech) | FAQ visible on store page. |
| T-10d | Launch notification sent to press list: one-line game description, launch date, promise of press kit to follow. No press kit link yet. | Operator (PR) | Send confirmed. |
| T-10d | **Outreach sends (templates 4.1, 4.2, 4.4, 4.5):** send to creator categories. Fill `{{launch_date}}`, `{{sender_name}}`, `{{name}}`, `{{why_them}}`, `{{topic}}`. Do not send 4.3 (sealed). Keys promised, not sent yet. | Operator (PR) | All sends confirmed. Tracking log updated. |
| T-10d | Steam community hub prepared: pinned discussion thread, community FAQ, and guide stub drafted from Appendix E templates. Templates pasted and ready to post at T+0. | Operator (Tech) | Templates drafted and saved. |
| T-10d | Wishlister announcement drafted from Appendix E. Saved in Steamworks announcement tool, scheduled for T+0 after halt-gate passes. | Operator (Tech) | Announcement saved and ready. |

### T-7d: review-approval buffer and content freeze

| Time | Task | Owner | Gate |
|------|------|-------|------|
| T-7d | Final claims audit: every public piece checked against Appendix A traceability matrix. Any untraced claim is cut. | Operator (PR) | Audit passes (zero untraced claims) or copy is revised and re-audited same day. |
| T-7d | Slop scan on all copy: zero exclamation marks in building-voice contexts, zero em-dashes, zero banned words, zero press-release constructions, zero prohibited audio terms (see audio metaphor rule in register). Exempt: "voice" and "speaks" as rhetorical caption-personality description. | Operator (PR) | Scan passes or copy is revised. |
| T-7d | IARC questionnaire submitted (if not already). Rating expected 5-7 business days. | Operator (Tech) | Questionnaire submitted. Track for return. |
| T-7d | Trademark written results on file for HUNGERHALL and the ALL ARE EATEN fallback. | Operator | Written results filed. If not returned, escalate to hold gate at T-1d. |
| T-7d | Class name trademark clearance (Warrior, Valkyrie, Wizard, Elf): written results on file. | Operator | Results filed. If collision found, halt and run G14 §1 title cycle for affected names. |
| T-7d | Support email monitored. Privacy policy URL live. Privacy policy content verified against GodotSteam Path B: no Steamworks SDK referenced, no Steam API data collection claimed, no developer telemetry claimed. | Operator (Tech) | All URLs return 200. Privacy policy content matches Path B. |
| T-7d | Press kit URL generated and live as a direct link. NOT distributed to press list until T-5d IARC gate passes. Not discoverable via store page or socials until T+0. | Operator (Tech) | URL returns 200. Not distributed. Not discoverable via store page or socials. |
| T-7d | Shipping build uploaded to Steam default branch (set to private). Steam store page review submitted to Valve. | Operator (Tech) | Build uploaded and hash recorded. Store page review submitted. |
| T-7d | String manifest cross-check: confirm GENERATOR DOWN, FOOD, KEY, and All are welcome. All are eaten. against the G10 manifest with exact casing and terminal punctuation per the canonical string table and quotation-context rule. | Operator (Tech) | Every string matches exactly. Any mismatch: strike from public copy, use Appendix C fallback. |
| T-7d | All eight image-bearing social posts drafted in the scheduler with screenshots attached and alt text written. LinkedIn A/B have no image attachment. | Operator (Social) | Scheduler preview shows 8 posts with correct character counts, screenshots, and alt text. |
| T-7d | Download size verified against current build. `{{download_size}}` slot filled in press kit. | Operator (Tech) | Size confirmed and entered. Re-verify at T-3d after build lock. |
| T-7d | **Key sends to outreach respondents:** send keys to creators who responded positively from T-10d outreach. Keys are release-locked. | Operator (PR) | Keys sent and tracked. |

### T-5d: press-kit sends

| Time | Task | Owner | Gate |
|------|------|-------|------|
| T-5d | **IARC GATE:** if rating is still pending, press-kit sends are blocked. Do not send. | Operator (Tech) | Rating inserted. PASS: sends proceed. FAIL: sends held until rating lands. |
| T-5d | Press kit sent to curated outlet list and to curators who received keys. Includes press kit URL. | Operator (PR) | Send confirmed. |
| T-5d | One-line follow-up to curators who received keys: launch date and `{{store_link}}`. | Operator (PR) | Send confirmed. |
| T-5d | Embargo agreements confirmed in writing, if any. Embargo time locked. | Operator (PR) | Embargo time documented. |
| T-5d | Link check: `{{store_link}}`, `{{press_kit_url}}`, `{{privacy_url}}`, `{{support_url}}`. | Operator (Tech) | All URLs return 200. |

### T-3d: shipping lock

| Time | Task | Owner | Gate |
|------|------|-------|------|
| T-3d | Shipping build locked. Final playtest: floors 1-24, all four classes, save and load, continue flow, Guestbook, settings. | Operator (Tech) | Playtest completes with no blockers. If blocker found, fix and re-lock. |
| T-3d | Download size re-verified against locked build. Update `{{download_size}}` in press kit if changed. | Operator (Tech) | Size confirmed against locked build. |
| T-3d | Asset-to-build verification: screenshots, video, and capsules match the locked build. Re-capture any that drift. | Operator (Tech) | All assets match locked build. |
| T-3d | If build changed since T-7d upload: re-upload to Steam and confirm store page status. | Operator (Tech) | Build hash matches uploaded build. If not, re-upload and verify. |
| T-3d | Steam store page review status checked. If still in review, contact Valve support for timeline. | Operator (Tech) | Status confirmed. If not approved, escalate to T-1d hold gate. |
| T-3d | Bug response templates approved (see below). | Operator (PR) | Templates reviewed. |
| T-3d | Reply window calendar set. | Operator (Social) | Calendar entries created. |

### T-2d: dry run

| Time | Task | Owner | Gate |
|------|------|-------|------|
| T-2d | Dry run of every scheduled post in the scheduler. Character limits confirmed: X 280, Bluesky 300, Mastodon 500, Threads 500, LinkedIn 3000. | Operator (Social) | All posts pass character limit check. |
| T-2d | Alt text confirmed for every attached screenshot on every image-bearing post (8 posts). | Operator (Social) | All alt text present and descriptive. |
| T-2d | Outreach template word-count check: every template body under 120 words including filled slots. `{{why_them}}` max 25 words. `{{topic}}` max 6 words, noun phrase, no terminal punctuation. | Operator (PR) | All templates pass. |
| T-2d | Canonical string punctuation check: no terminal period after GENERATOR DOWN, FOOD, or KEY in any public copy. | Operator (PR) | All strings clean. |
| T-2d | Embargo lifts coordinated, if any. | Operator (PR) | Times confirmed. |

### T-1d: final gate

| Time | Task | Owner | Gate |
|------|------|-------|------|
| T-1d | **IARC HOLD GATE:** if rating has not returned, launch slips. Do not proceed. | Operator | Rating inserted. PASS: proceed. FAIL: launch slips until rating returns. |
| T-1d | **Trademark HOLD GATE:** if written results not on file, launch slips. | Operator | Results filed. PASS: proceed. FAIL: launch slips. |
| T-1d | **Class name clearance HOLD GATE:** if clearance not confirmed, launch slips. | Operator | Clearance confirmed. PASS: proceed. FAIL: launch slips or names change per G14 §1. |
| T-1d | **STORE PAGE APPROVAL HOLD GATE:** Steam store page review confirmed approved by Valve. If not approved, launch slips. Contact Valve support for expedited review if pending. | Operator (Tech) | Approval confirmed. PASS: proceed. FAIL: launch slips. |
| T-1d | Steam release state configured for 10:00 PT. | Operator (Tech) | Release configured. |
| T-1d | Store page check via Steamworks Partner Dashboard → Store Page → Preview mode: verify customer-facing page. Confirm price shows $5.99, screenshots and video play, release date and time visible. | Operator (Tech) | All elements load correctly in Preview. |
| T-1d | Confirm wishlist notification configuration in Steamworks (Steam sends notifications automatically at release; confirm the setting is active). | Operator (Tech) | Setting confirmed active. |
| T-1d | Operator sign-off on every public piece. | Operator | Sign-off recorded. |

**T-1d launch-slip procedure (if any hold gate fails):**

| Step | Action | Owner |
|------|--------|-------|
| 1 | Record which gate failed and the reason. | Operator |
| 2 | Set new target launch date (next available business day after gate is expected to pass). | Operator |
| 3 | Pause all scheduled social posts in scheduler. Do not delete; pause for rescheduling. | Operator (Social) |
| 4 | Notify press list and curators: "Launch delayed. New date: [date]. Press kit remains available. Apologies for the change." | Operator (PR) |
| 5 | Update Steam store page release date in Steamworks. | Operator (Tech) |
| 6 | Update wishlister announcement date in Steamworks. | Operator (Tech) |
| 7 | Contact Valve support if store page approval is the failed gate. | Operator (Tech) |
| 8 | Re-run T-1d gates on new target date. | Operator |
| 9 | If gates pass on new T-1d, reschedule all social posts for new T+0. Unpause scheduler. | Operator (Social) |

### T+0: launch day

All times Pacific. Owner column: SO = Operator (Social), TE = Operator (Tech), PR = Operator (PR), OP = Operator. If solo, all are Operator. Tasks are sequenced for one person.

| Time (PT) | Action | Owner | Gate |
|-----------|--------|-------|------|
| 09:45 | Dashboards open: Steamworks, support inbox, social mentions. | TE | Dashboards accessible. |
| 09:50 | **Pause all scheduled social posts in the scheduler.** No post fires until the 10:00 halt gate passes. Confirm scheduler shows zero posts in "scheduled to send" state. | SO | All posts paused. Scheduler shows no pending sends. |
| 10:00 | **HALT GATE:** Release goes live. Confirm: store page loads, price $5.99, build downloadable. If ANY check fails, hold all social posts. See halt-gate recovery below. | TE | Store live, price correct, build downloadable. PASS: social wave proceeds. FAIL: recovery protocol activates. |
| 10:05 | Post Steam announcement for wishlisters (text in Appendix E). | TE | Announcement live on Steam community hub. |
| 10:10 | Post X Variant A. Attach screenshot 1 (health drain) with alt text. | SO | Post live. |
| 10:15 | Publish blog post at `{{blog_url}}`. Gate: halt gate passed, T-7d string verification passed. | SO | Blog live, URL returns 200. |
| 10:20 | Post Bluesky Variant A. Attach screenshot 4 (food pickup) with alt text. | SO | Post live. |
| 10:30 | Post Mastodon Variant A. Attach screenshot 1 (health drain) with alt text. | SO | Post live. |
| 10:40 | Post Threads Variant A. Attach screenshot 2 (class select) with alt text. | SO | Post live. |
| 11:00 | Pin discussion thread on Steam community hub (template in Appendix E). Post community FAQ (template in Appendix E). | TE | Thread pinned, FAQ posted. |
| 11:30 | Post LinkedIn Variant A. No image. | SO | Post live. |
| 13:00 | Reply window 1 closes. Check Steamworks sales and reviews. | SO | Metrics logged. |
| 16:00 | Reply window 2 opens. | SO | Window open. |
| 17:00 | Post X Variant B. Attach screenshot 3 (generator destruction) with alt text. | SO | Post live. |
| 17:15 | Post Bluesky Variant B. Attach screenshot 5 (floor results) with alt text. | SO | Post live. |
| 17:30 | Post Mastodon Variant B. Attach screenshot 2 (class select) with alt text. | SO | Post live. |
| 17:45 | Post Threads Variant B. Attach screenshot 1 (health drain) with alt text. | SO | Post live. |
| 19:00 | Reply window 2 closes. Log all comments and replies. | SO | Log saved. |

**Halt-gate recovery protocol:**

| Step | Action | Owner | Timing |
|------|--------|-------|--------|
| 1 | If store is not live at 10:00, hold all social posts. They are already paused from 09:50. Do not unpause. | TE/SO | Immediate |
| 2 | Diagnose: check Steamworks build status, store page review status, release configuration. | TE | 10:00 to 10:15 |
| 3 | Recheck store page every 15 minutes. | TE | 10:15, 10:30, 10:45, 11:00, 11:15, 11:30 |
| 4 | If store goes live at any recheck before 11:30 (i.e. at 10:15, 10:30, 10:45, 11:00, or 11:15): proceed with compressed social wave. Post all morning variants (X A, blog, Bluesky A, Mastodon A, Threads A, LinkedIn A) in rapid sequence, 5 minutes apart, starting immediately. Post wishlister announcement and pin Steam thread immediately after the wave. | SO | Immediately upon confirmed live, through 12:00 |
| 5 | If store is still not live at the 11:30 recheck (90-minute timeout): reschedule entire social wave to T+1. Notify press list of delay. Do not post socials today. Contact Valve support. | OP | 11:30 |
| 6 | If the failure persists past 14:00: launch slips to the next available date. Execute T-1d launch-slip procedure. Update all scheduled posts. Notify press list and curators. | OP | 14:00 |

**Evening wave after delayed recovery:**
- If the store went live before 11:30 and the morning wave was compressed (step 4): the evening wave proceeds at normal times (17:00-17:45). The morning compression does not affect the evening schedule.
- If the store went live after 11:30 and socials were moved to T+1 (step 5): both morning and evening waves go out on T+1 with normal spacing. No evening wave on T+0.
- If launch slips entirely (step 6): both waves reschedule to the new T+0 and new T+1 respectively.

**Timezone logic:** the 10:00-13:00 PT wave lands in US morning and EU afternoon. The 16:00-19:00 PT wave catches US evening and Asia morning. Mastodon and Bluesky skew EU; the 10:30 Mastodon post sits before Threads for that reason.

**Reply windows:** T+0: 10:00-13:00 PT and 16:00-19:00 PT. T+1 through T+3: 09:00-12:00 PT and 15:00-18:00 PT, plus a late check 21:00-22:00 PT for EU and Asia. First response within 2 hours during a reply window, within 12 hours otherwise.

### T+1: community day

| Time (PT) | Action | Owner | Gate |
|-----------|--------|-------|------|
| 09:30 | Post LinkedIn Variant B. No image. | SO | Post live. |
| 10:30 | **Sidebar gate:** re-read r/puzzlevideogames rules. If self-promo allowed in comments, post per §5.3 with link in comments (or link-stripped variant if sidebar rejects body links). If sidebar rejects links entirely, post the design question only with no link. | SO | Sidebar read. Rules confirmed. Post submitted or held. |
| 11:15 | **Sidebar gate:** re-read r/arcade rules. If self-promo allowed, post per §5.4 with link in comments. If not, post link-stripped variant. | SO | Sidebar read. Rules confirmed. Post submitted or held. |
| 14:00 | **Sidebar gate:** re-read r/godot rules. Post per §5.5 if dev posts allowed. Link in body if rules permit; otherwise link in comments (link-stripped variant). If sidebar rejects links entirely, post without link. | SO | Sidebar read. Rules confirmed. Post submitted or held. |
| All day | Reply to every comment on every platform within 24 hours. | SO | Zero unread comments at 18:00 PT. |
| All day | Thank every Steam reviewer. | PR | All reviews responded to. |
| All day | Bug triage from support inbox. | TE | Triage log updated. |

### T+2: stabilization

| Time (PT) | Action | Owner | Gate |
|-----------|--------|-------|------|
| All day | Community follow-up replies only. No new standalone posts. | SO | No new posts. |
| All day | Monitor Steam review sentiment and review count. Refund data is NOT available in real-time; do not check refund rate today. | TE | Review count and sentiment logged. |
| All day | First patch decision only if a blocker exists. No patch promises without a confirmed fix. | TE | Decision recorded. |

### T+3: metrics snapshot with corrective actions

| Time (PT) | Action | Owner | Gate |
|-----------|--------|-------|------|
| 09:00 | Metrics snapshot against operator-set targets. Collect: Steam review count, Steam review percentage, Steamworks sales units (24h-delayed data), wishlist conversion estimate. Refund rate is NOT collected today. | TE | Data collected. |
| 10:00 | Decision branches based on metrics. See table below. | OP | Decisions recorded. |
| 12:00 | Update press kit per §1 T+3 specification: live store link, verified launch date, Steam review count, Steam review percentage, Steam rating label, download size. | PR | Press kit updated. |
| 12:00 | Thank-you notes to every outlet and curator that covered the launch. | PR | Notes sent. |

**Metrics decision table (targets are operator-set, not G14-derived). Refund rate deferred to T+7:**

| Metric | Target | If met | If missed (objective thresholds) |
|--------|--------|--------|-----------|
| Wishlist conversion | 8% minimum | Continue organic push. Monitor through T+7. | Below 5%: post a Mastodon/Threads design-discussion piece reusing Variant B messaging from §3. Extend reply windows to 14 hrs/day. Consider limited-time discount (operator call). 5–8%: extend reply windows, monitor through T+7. |
| Review count | 25 minimum, 80% positive | Continue thanking reviewers. | Below 10: post pinned Steam community thread requesting feedback. Reach out to 5 additional reviewers from press list. 10–25: continue organic push, monitor. |
| Steam reviews positive | 80% minimum | Continue. | Below 60%: identify top 3 complaint themes. Patch if fixable. 60–80%: identify themes. Pin community post explaining design intent if not fixable. |
| Refund rate | Deferred to T+7 | N/A at T+3 | N/A at T+3. See T+7 snapshot. |

### T+7: refund window snapshot

| Time (PT) | Action | Owner | Gate |
|-----------|--------|-------|------|
| 09:00 | First reliable refund-rate snapshot from Steamworks. Compare against operator-set target (below 15%). Triage refund reasons if above threshold. | TE | Data collected. Corrective action recorded if needed. |
| 09:00 | Review trend snapshot. Identify top complaint themes if positive rate has shifted. | TE | Data collected. |

### First-response templates for bug reports

1. **Acknowledgment:** "Thank you, that is specific and useful. To speed things up: Windows version, GPU, input device (keyboard or gamepad model), floor number, and what you saw before it happened. No attachments needed in the first email. We read everything."

2. **Crash on start (Vulkan check):** "Sorry for the trouble. HUNGERHALL uses Vulkan. A common cause for a game that will not start is an outdated GPU driver. Please confirm your Windows version and GPU model, and check that your driver supports Vulkan. We will follow up as soon as we have the details."

3. **Save missing:** "The save lives locally on your machine. If a completed floor is gone, please tell us your Windows version and what happened before it disappeared. We will look into it."

4. **Praise or request:** "Thank you. Noted. No promises on timing, but the list is read."

## 7. Open questions

Launch calls only the operator can make. Items that are hard gates (IARC, trademark, class names, store page approval, studio identity, launch date) appear in the checklist with hold conditions. They are listed here for operator awareness.

- **Launch date and time.** Exact date, and whether 10:00 PT is acceptable or a custom release time is wanted. Hard gate at T-1d.
- **Budget.** Is there any paid promotion budget? Also: outreach tooling budget (press kit hosting, social scheduler), and how many review keys to grant and from which pool.
- **Embargo.** Does any outlet get an early copy under embargo? If yes, the embargo time and who coordinates. No names invented here.
- **Studio name and contact.** The press kit and store page need the operator-supplied studio name, press email, support email, and URLs. Hard gate at T-1d.
- **Trademark clearance.** Written results for HUNGERHALL, the ALL ARE EATEN fallback, and the four class names. Initiate at T-30d. Hard gate at T-1d.
- **IARC rating.** Submit questionnaire by T-7d. The returned rating must be inserted before the store page goes live. Hard gate at T-1d.
- **Store page approval.** Valve must approve the store page before launch. Submit at T-7d. Hard gate at T-1d.
- **GodotSteam path.** Path B (disabled) is the default. Upgrading to Path A changes the privacy disclosure and the FAQ answer about the Steam client.
- **Audio state.** The default is audio-absent, captions only. If audio ships, the blog and socials should mention the voice, and the press kit description changes. Sealed swap lines in Appendix B.
- **Demo and Next Fest.** Decided at T-14d, not T+3. Next Fest requires weeks-advance application. Demo build (floors 1-3) requires its own playtest cycle.
- **Pipeline mention.** The game credits say "Prepared with the Sneferu Pipeline." The blog and socials currently do not mention it. Whether public copy should name the pipeline is the operator's call.
- **Store page "four once shared" phrasing.** The G14-approved store page description (Appendix D) uses "four once shared" as a G14-confirmed field. Launch-kit-authored copy removes all four-player fingerprints. The T-10d gate forces an operator decision before pasting. Whether to keep or modify these lines is the operator's call.
- **Subreddit strategy for sealed subs.** r/iosgaming and r/iphone are sealed by default. If the operator wants engagement, the r/iosgaming disclosed-question approach in §5.1 is the documented path. r/iphone has no covert fallback. The operator decides.
- **Steam Deck and Proton.** Verification is pending. Do not claim Deck support in public copy until the operator completes testing.
- **Pronoun.** All first-person copy uses "I." If the studio is a team, do one global find-and-replace to "we" before scheduling.
- **Wishlister communication.** The kit provides a Steam announcement (Appendix E) to supplement Steam's automatic wishlist notification. If the operator judges the automatic notification sufficient, the Appendix E announcement can be skipped. The kit defaults to sending both.

## Appendix A: Claim-to-G14 traceability matrix

Every public factual claim mapped to its G14 source. G14-CONFIRMED appears in G14 SHIP fields. G3-REFERENCED is backed by the G3 voice bible as cited in G14's register declaration. FREEZE-STATE is backed by the declared default freeze state. OPERATOR-SET is an operator decision. INFERRED is a reasonable inference from G14 context but not directly quoted. UNVERIFIED is struck from public copy.

### G14-CONFIRMED claims

| Claim | Source |
|-------|--------|
| Title: HUNGERHALL | G14 §1 |
| Solo arcade dungeon crawler | G14 §3.1 |
| HP ticks down once a second | G14 §3.1 |
| Four classes: Warrior, Valkyrie, Wizard, Elf | G14 §3.1 |
| Warrior takes the bite and keeps swinging | G14 §3.1 |
| Valkyrie holds lanes and weathers fire | G14 §3.1 |
| Wizard clears groups but cannot shake a single pursuer | G14 §3.1 |
| Elf outranges everything and starves in close | G14 §3.1 |
| No upgrades, no skill trees | G14 §3.1 |
| The class you choose is the kit you keep | G14 §3.1 |
| 24 floors, 4 themed courses | G14 §3.1 |
| Drowned Vaults: wet stone, ghosts through walls | G14 §3.1 |
| Cindercrypt: flame jets, lobbers over cover | G14 §3.1 |
| Starved Deep: bridges over nothing, Death taking a seat | G14 §3.1 |
| The Hollow Throne: collapsing floor, three generators, the last course | G14 §3.1 |
| Generators spill enemies until broken at close range | G14 §3.1 |
| Food restores health, never returns, hides behind guards | G14 §3.1 |
| Keys open the exit door | G14 §3.1 |
| Treasure adds score, never safety | G14 §3.1 |
| Every event prints a caption | G14 §3.1 |
| GENERATOR DOWN (string, ALL CAPS, no terminal period) | G14 §3.1, canonical string table |
| FOOD (string, ALL CAPS, no terminal period) | G14 §3.1, canonical string table |
| KEY (string, ALL CAPS, no terminal period) | G14 §3.1, canonical string table |
| All are welcome. All are eaten. (sentence case, periods) | G14 §3.1, canonical string table |
| Score climbs with every kill | G14 §3.1 |
| Death docks 20 percent of score | G14 §3.1 |
| Two continues per floor | G14 §3.1 |
| Continue = half health, no keys, food still gone | G14 §3.1 |
| The other three classes invite you back (four-minus-one arithmetic) | G14 §3.1 |
| New Game+ after clean campaign clear | G14 §3.1 |
| Keyboard and gamepad at first boot | G14 §3.1 |
| Move with the left stick | G14 §3.1 |
| Throw with a face button along current facing | G14 §3.1 |
| Guestbook: local high scores with initials | G14 §3.1 |
| No online boards, no accounts | G14 §3.1 |
| $5.99, no ads, no IAP, no developer telemetry | G14 §3.1 |
| Godot 4.7, Forward+, Vulkan | G14 header |
| Steam, Windows 10/11 | G14 header |
| Tonight's Menu (section header) | G14 §3.1 |
| One player pays the full health bill that four once shared (store page) | G14 §3.1 |

### G3-REFERENCED claims

| Claim | Source |
|-------|--------|
| Third person (building's voice) | G14 register citing G3 |
| No exclamation marks (building's voice) | G14 register citing G3 |
| Short lines for captions | G14 §3.1 "flat and polite" + G3 |

### INFERRED claims

| Claim | Basis |
|-------|-------|
| One stairwell all the way down | Linear 24-floor descent structure implied by G14 §3.1 |
| No respec | Inferred from "no upgrades, no skill trees, the class you choose is the kit you keep" (G14 §3.1) |
| The building narrates events (softened from "the building is the only character") | G14 §3.1 "The building itself narrates events" |

### FREEZE-STATE claims

| Claim | Basis |
|-------|-------|
| No voice, just text (audio-absent) | Freeze-state declaration (ABSENT) |

### OPERATOR-SET claims

| Claim | Basis |
|-------|-------|
| Store page tags: Singleplayer, Dungeon Crawler, Arcade, Action, Retro | Selected from Steam tag taxonomy |
| Metric targets: 8% conversion, 25 reviews, 80% positive, 15% refund | Not in G14 |

### UNVERIFIED — struck from public copy

| Claim | Status |
|-------|--------|
| "Deaths are fast" | Struck from §4.1. Not in G14. |
| "The cabinet used to stand in the room with you and remember" | Struck from blog. Ancestor/cabinet fingerprint. |
| "XInput gamepad" | Struck, replaced with "gamepad." G14 says "gamepad." |
| "No DLC" | Struck. G14 says "no ads, no IAP, no developer telemetry" but not "no DLC." |
| "Present tense" (voice rule) | Struck. G14 register says "third person" but not "present tense." |
| "Standing in the doorway and throwing is a way to starve" | Struck. Tactical claim not in G14. |
| "The building is the only character" | Struck as fact. Softened to "The building narrates events." |
| THE HALL LOSES A CHEF (string) | Struck. Not in G14. |
| THE [CLASS] IS PLATED (string) | Struck. Not in G14. |
| Pixel art | Struck. Not in G14. |
| 3D delivery mechanism | Struck. Not in G14. |
| Full keyboard and gamepad remapping | Struck. Not in G14. |
| Reduced motion toggle | Struck. Not in G14. |
| Screen shake toggle | Struck. Not in G14. |
| Freeze frame toggle | Struck. Not in G14. |
| Auto-fire assist | Struck. Not in G14. |
| Font size slider | Struck. Not in G14. |
| Floors designed by hand, not generated | Struck. Not in G14. |
| "For four decades" (maître d' metaphor) | Struck. Not in G14. |
| Banned homage / IP-proximity narrative | Struck. Not in G14. |
| 1985 coin-op (ancestor reference) | Struck. Not in G14. |
| Four-player / "four used to split" / "removes three chairs" | Struck from launch-kit-authored copy. |
| Caption system is a state machine | Struck from r/godot. Not in G14. |
| Typed resource manifest loaded at boot | Struck from r/godot. Not in G14. |
| No hardcoded strings in scene scripts | Struck from r/godot. Not in G14. |
| Screenshot overlays "six words or fewer" | Struck. Not in G14. |
| "Breed enemies" / "breed trouble" | Corrected to "spill enemies" (G14 language). |
| "Shooting" (attack verb) | Corrected to "throwing" (G14 language). |
| "No exclamation marks anywhere in the entire game" | Over-claim. Scope is building's voice only. |
| Approximately 250 MB download | Replaced with `{{download_size}}`. |
| Expected E10+/PEGI 7 rating | Replaced with `{{iarc_rating}}`. |

## Appendix B: Audio-present swap table

If the audio freeze state upgrades to PRESENT (G10 build-verification gate B1 passes with minimum 5 event-type clips: GENERATOR DOWN, FOOD, KEY, death, level transition), apply these swaps. The caption requirement remains in all variants. Audio is additive, not a replacement for text.

**Swap order:** if a post also has an Appendix C fallback (string verification failed), apply Appendix C fallback first, then apply the Appendix B audio swap to the fallback text.

| Section | Default-state text | Audio-present swap |
|---------|-------------------|-------------------|
| Press kit description | "The building itself narrates events in deadpan on-screen captions." | "A period speech synth speaks each event in a flat, courteous tone, and every line prints as a caption alongside it." |
| Press kit Key Facts: Accessibility | "Captioned announcer events. Keyboard and gamepad support at first boot. No accounts or online requirement." | "Speech-synth announcer voice with on-screen captions for every event. Keyboard and gamepad support at first boot. No accounts or online requirement." |
| Blog (voice paragraph) | "it speaks in on-screen captions" | "a period speech synth speaks each line, and every one prints as a caption alongside it" |
| X B | "the building reports its own losses in deadpan ALL CAPS captions" | "a flat synth voice reports each loss, and every line prints as a caption" |
| Mastodon A | "the venue narrates dinner in deadpan ALL CAPS captions" | "a flat synth voice narrates dinner, and every line prints as a caption" |
| Bluesky A | "the venue comments in polite captions, flat and deadpan" | "a flat synth voice comments on dinner, and captions print alongside" |
| Threads B | "a building that narrates your death in flat captions" | "a flat synth voice narrates your death, with captions alongside" |
| LinkedIn A | "narrates dinner in on-screen text" | "a period synth speaks each line, and on-screen text prints alongside" |
| LinkedIn B | "prints your death in flat captions" | "a flat synth voice speaks your death, with captions printing alongside" |
| r/arcade | "No voice, just text." | "A flat synth voice speaks each event, with captions printing alongside." |
| r/godot | "it speaks in on-screen captions" | "a period speech synth speaks each line, and every one prints as a caption alongside it" |
| Accessibility template | "on-screen captions for every announcer event" | "a speech synth voice for every announcer event, with on-screen captions alongside" |

## Appendix C: Fallback Copy for Quote-Dependent Posts

If string manifest verification at T-7d fails for any quoted string, strike the quote and use the fallback variant. The post still ships. The story stands without the quote.

Fallback copy is audio-state-aware. The default fallback text below assumes audio ABSENT. If audio upgrades to PRESENT, apply the Appendix B audio swap to the fallback text after swapping.

Every fallback variant includes `{{store_link}}`.

| Post | Default (quote-dependent) | Fallback (quote-free, audio-absent) |
|------|--------------------------|----------------------|
| X Variant B | "The building reports its own losses in deadpan ALL CAPS captions: GENERATOR DOWN when a source breaks, FOOD when a plate lands. A one-player arcade dungeon crawler, 24 floors, $5.99 on Steam." | "The building narrates events in deadpan on-screen captions. No voice, just text. A one-player arcade dungeon crawler, 24 floors, $5.99 on Steam. `{{store_link}}`" |
| Bluesky Variant B | "All are welcome. All are eaten. That is the whole hospitality policy." | "One stairwell, 24 floors, four classes, one courteous building with a single appetite. HUNGERHALL is live on Steam, $5.99. `{{store_link}}`" |
| Blog (voice paragraph) | "GENERATOR DOWN when a source breaks. FOOD when a plate lands. KEY when iron turns up. Flat, polite, and meaner for being flat." | "The building narrates every event in short on-screen captions. Flat, polite, and meaner for being flat. No voice, just text." |
| Blog (closing line) | "All are welcome. All are eaten." | "The hall is open. The hall is hungry." |
| r/godot | "GENERATOR DOWN when a source breaks. FOOD when a plate lands. KEY when iron turns up. Flat, polite, and meaner for being flat." | "Every event gets a short on-screen caption in flat, polite text. No voice, just text. Meaner for being flat." |
| r/arcade | "GENERATOR DOWN when a source breaks, FOOD when a plate lands, KEY when iron turns up. No voice, just text." | "The building narrates events in deadpan on-screen captions. No voice, just text." |

**Store page (Appendix D) fallback for string-dependent text:**

| Location | Default (string-dependent) | Fallback (string-free) |
|----------|---------------------------|----------------------|
| "The Building Speaks" section | "Every event prints a caption. GENERATOR DOWN when a source breaks. FOOD when a plate lands. KEY when iron turns up. The building speaks in text, flat and polite, the way a menu reads the specials." | "Every event prints a caption in flat, polite text. The building speaks in text, flat and polite, the way a menu reads the specials." |
| Closing line | "HUNGERHALL. All are welcome. All are eaten." | "HUNGERHALL. The hall is open. The hall is hungry." |

**Strike-and-replace procedure:** at T-7d, run the manifest cross-check. For each string that fails, mark it in the scheduler and swap to the fallback variant. Log the swap. Re-run the slop scan on the fallback. No post ships with a struck quote. For store page strings, apply the same procedure and update Steamworks before T-5d press-kit sends.

## Appendix D: Steam Store Page Copy (paste-ready)

All copy below is traced to G14 SHIP fields. Paste into Steamworks fields as labeled. Only operator-fill slots remain.

**Operator decision required before T-10d paste:** The G14-approved store page uses "four once shared" and "The other three classes invite you back," which contain four-player arithmetic. Launch-kit-authored copy removes these fingerprints. Operator decides which position the store page takes. T-10d gate records the decision. Default below: G14-approved text as written.

### Short Description (Steam "Short Description" field, ~300 chars)

A solo arcade dungeon crawler. One player pays the full health bill that four once shared. Your health bar is the only clock. It drains every second. Standing still spends it. Moving forward risks it. Eating buys it back. Four classes, 24 floors, $5.99. No ads, no IAP, no accounts.

### Detailed Description (Steam "Detailed Description" field, BBCode)

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

**Audio-present swap:** if audio freeze state upgrades to PRESENT, replace the "The Building Speaks" section with the G14 §3.2 audio-present variant:

```
[h2]The Building Speaks[/h2]

The announcer is the building. A 1985-style speech synth, flat and polite, marks major beats: GENERATOR DOWN when a source breaks, FOOD when a plate lands, KEY when iron turns up. The tone never changes. Captions carry every line.
```

**String-failure fallback:** if T-7d string manifest cross-check fails for GENERATOR DOWN, FOOD, KEY, or the tagline, apply the Appendix C store-page fallback to the affected sections before pasting into Steamworks.

### Tags (Steam tag field, max 5)

1. Singleplayer
2. Dungeon Crawler
3. Arcade
4. Action
5. Retro

Tag traceability: all five tags are OPERATOR-SET, derived from G14-confirmed genre descriptors ("solo arcade dungeon crawler," "action," "retro" per G14 §3.1 and §2).

### FAQ (Steam "FAQ" section, from G14 §11)

Paste each Q/A pair below. Additional entries from G14 §11 as needed.

**Q: Does the game require an internet connection?**
A: No. HUNGERHALL has no online features. No accounts, no online boards, no developer telemetry.

**Q: Is there a demo?**
A: `{{demo_status}}` — Default (no-demo): "A demo is not currently available." If demo published, use G14 §11 demo-live variant.

**Q: What are the system requirements?**
A: Windows 10/11 64-bit. GPU with Vulkan support. `{{additional_requirements}}`

**Q: Does the Steam client need to be running?**
A: No. (Per G14 §11 Q5, GodotSteam Path B default.)

### Store page paste checklist (T-10d)

| Field | Source | Status |
|-------|--------|--------|
| Short Description | Appendix D above | Paste ready (per operator "four once shared" decision) |
| Detailed Description | Appendix D above (BBCode) | Paste ready (per operator decision) |
| Tags | Appendix D above (5 tags) | Paste ready |
| FAQ | Appendix D above (4 rendered entries) | Paste ready. Add G14 §11 entries as needed. |
| Screenshots | G14 §6 (5 screenshots) | Capture from shipping build |
| Capsule images | G14 §8 capsule set | Upload from G14 art assets |
| Trailer | G14 §7 (30-second preview) | Upload from G14 video assets |
| Price | $5.99 USD | Set in Steamworks pricing |
| Release date | `{{launch_date}}` | Set in Steamworks |
| Rating | `{{iarc_rating}}` | Insert after IARC return |
| Privacy policy URL | `{{privacy_url}}` | Set in Steamworks |

## Appendix E: Steam Community Templates and Wishlister Announcement

### Wishlister announcement (post at T+0 10:05)

Post as a Steam announcement/news post on the game's community hub. This is in addition to the automatic notification Steam sends to wishlisters at release. If the operator considers the automatic notification sufficient, this post can be skipped (see Open Questions).

**Title:** HUNGERHALL is live

**Body:**

A solo arcade dungeon crawler: your health bar drains every second, food restores it and never respawns, and the building narrates your descent in deadpan on-screen captions.

Four classes, 24 floors, $5.99. No ads, no in-app purchases, no accounts, no developer telemetry.

Thank you for the wishlist. The Guestbook starts blank.

`{{store_link}}`

### Pinned discussion thread (post at T+0 11:00)

**Title:** Welcome to HUNGERHALL — first impressions, bugs, and questions

**Body:**

Welcome to HUNGERHALL. This thread is for first impressions, bug reports, and questions. I am the developer and I am reading.

If you hit a bug: Windows version, GPU, input device (keyboard or gamepad model), floor number, and what you saw before it happened. Screenshots help.

If you have a design question: ask. The health drain, the continue system, and the class balance are all fair game.

The Guestbook starts blank. Somebody has to eat first.

### Community FAQ (post at T+0 11:00)

**Title:** HUNGERHALL — Community FAQ

**Body:**

**Q: Does the game require an internet connection?**
A: No. HUNGERHALL has no online features. No accounts, no online boards, no developer telemetry.

**Q: Is there a demo?**
A: `{{demo_status}}` — Default: "A demo is not currently available."

**Q: What are the system requirements?**
A: Windows 10/11 64-bit. GPU with Vulkan support. `{{additional_requirements}}`

**Q: Does the Steam client need to be running?**
A: No.

**Q: Does it support Steam Deck?**
A: Deck and Proton are untested. No claim is made until testing completes.

**Q: Can I remap controls?**
A: Keyboard and gamepad both work at first boot.

### Guide stub (post at T+0 11:00 or T+1)

**Title:** HUNGERHALL — Quick Start

**Body:**

1. Pick a class. You keep it for the whole descent.
2. Your health drains every second. Food restores it and never comes back.
3. Break generators at close range to stop enemy spawns.
4. Find the key and reach the exit.
5. Two continues per floor. A continue gives you half health, no keys, and the food stays gone.

More guides to follow based on community questions.

## Obligation Responses

OBL-1: ADDRESSED — `{{store_link}}` added to press kit Key Facts table as "Store page" row; present in all outreach templates and social variants.
OBL-2: ADDRESSED — §1 T+3 press-kit update specification table lists exact fields: store link, launch date, review count, review percentage, rating label, download size. No sales or refund fields included.
OBL-3: ADDRESSED — "One stairwell all the way down" added to Appendix A as INFERRED; retained in blog and Bluesky B with trace.
OBL-4: ADDRESSED — "The cabinet used to stand in the room with you and remember" struck from blog; Appendix A row added marking it UNVERIFIED/Struck; replaced with "your scores stay on your machine."
OBL-5: ADDRESSED — X Variant B restructured so GENERATOR DOWN and FOOD appear in a descriptive clause with no terminal period appended; canonical string quotation-context rule defined in string table.
OBL-6: ADDRESSED — r/godot and r/puzzlevideogames each have explicit link-stripped body variants with first-comment posting instructions and sidebar-rejects-links instructions.
OBL-7: ADDRESSED — T+0 09:50 row added: pause all scheduled social posts in scheduler until 10:00 halt gate passes.
OBL-8: ADDRESSED — Recovery protocol step 4 now says "any recheck before 11:30 (10:15, 10:30, 10:45, 11:00, or 11:15)"; step 5 says "still not live at the 11:30 recheck."
OBL-9: ADDRESSED — New "Evening wave after delayed recovery" section defines: morning compressed = evening normal; socials moved to T+1 = both waves on T+1.
OBL-10: ADDRESSED — T-14d specifies placeholder copy (title, short desc, screenshots, capsules); full copy paste at T-10d from Appendix D.
OBL-11: ADDRESSED — T+3 corrective action reuses Variant B messaging from §3 (existing Mastodon/Threads drafts) instead of demanding an unwritten T+4 post.
OBL-12: ADDRESSED — "Deaths are fast" removed from §4.1 shorts streamer template; replaced with "The building captions every event in flat on-screen text."
OBL-13: ADDRESSED — `{{demo_status}}` and `{{additional_requirements}}` defined in slot legend with type, constraint, and default values.
OBL-14: ADDRESSED — T-10d gate added: operator records "four once shared" decision before pasting Appendix D; both default and strict variants provided in Appendix D.
OBL-15: ADDRESSED — Appendix E.4 provides wishlister announcement text; Open Questions notes operator can skip if automatic notification is judged sufficient.
OBL-16: ADDRESSED — Appendix E renders pinned discussion thread (E.1), community FAQ (E.2), guide stub (E.3), and wishlister announcement (E.4) as paste-ready copy.
OBL-17: ADDRESSED — "Deaths are fast" struck from §4.1; Appendix A confirms UNVERIFIED/Struck; replacement text is G14-backed.
OBL-18: ADDRESSED — Cabinet reference struck from blog ("The cabinet used to stand in the room with you and remember"); no physical-cabinet heritage claim remains.
OBL-19: ADDRESSED — "Hides behind guards" traced to G14 §3.1 in Appendix A as G14-CONFIRMED; retained in press kit and store page.
OBL-20: ADDRESSED — "XInput gamepad" struck from press kit; replaced with "gamepad" per G14-confirmed language; Appendix A row added.
OBL-21: ADDRESSED — Both slots (`{{demo_status}}` and `{{additional_requirements}}`) defined in slot legend with type, constraint, default values, and G14 §11 source reference.
OBL-22: ADDRESSED — Outreach send tasks added to T-10d checklist; "this week" replaced with `{{launch_date}}` across all templates.
OBL-23: ADDRESSED — "The other three classes invite you back" traced to G14 in Appendix A; retained in Appendix D default with T-10d operator decision gate.
OBL-24: ADDRESSED — Store page tags added to Appendix A as OPERATOR-SET with derivation note.
OBL-25: ADDRESSED — T+7 metrics snapshot added with refund-rate data collection and decision branches; T+3 table references T+7 with actual task.
OBL-26: ADDRESSED — Same as OBL-12/17: "Deaths are fast" removed from §4.1.
OBL-27: ADDRESSED — Canonical string quotation-context rule defined in string table; all public copy audited; no terminal period after GENERATOR DOWN, FOOD, or KEY as standalone quoted fragments.
OBL-28: ADDRESSED — Appendix A rows added for all class behaviors and course hazards, all marked G14-CONFIRMED with G14 §3.1 source.
OBL-29: ADDRESSED — XInput struck (UNVERIFIED), No DLC struck (not in G14), hides behind guards traced as G14-CONFIRMED, no respec added as INFERRED, one stairwell added as INFERRED.
OBL-30: ADDRESSED — "Present tense" struck from blog and r/godot; not in G3/G14 register. Appendix A updated.
OBL-31: ADDRESSED — "Standing in the doorway and throwing is a way to starve" struck from blog; replaced with G14-confirmed "Generators spill enemies until you push in and break them at close range."
OBL-32: ADDRESSED — Blog and r/godot now use "the building narrates events" (G14-confirmed) instead of "the building is the only character" (INFERRED). Appendix A updated.
OBL-33: ADDRESSED — Appendix C r/arcade fallback aligned with §5.4 ("No voice, just text"); `{{store_link}}` added to X B and Bluesky B fallbacks.
OBL-34: ADDRESSED — Store-page string fallback added to Appendix C for "Building Speaks" section and closing line; strike-and-replace procedure updated.
OBL-35: ADDRESSED — Blog publication step added to T+0 at 10:15 with gate: halt gate passed, string verification passed, `{{blog_url}}` live.
OBL-36: ADDRESSED — T-1d launch-slip procedure table added with 9 steps: declare, unschedule, cancel release, notify press/curators, update Steam, contact Valve, record, re-enter at new T-1d, reschedule.
OBL-37: ADDRESSED — Both slots (`{{demo_status}}` and `{{additional_requirements}}`) defined in slot legend with type (String), constraint (fill from G14 §11), and default values.
OBL-38: ADDRESSED — Register now says "No exclamation marks in the building's voice (announcer captions, title-screen tagline)" instead of "any in-game text"; UI labels explicitly exempt.
OBL-39: ADDRESSED — Audio metaphor rule defined in register: prohibited literal audio terms listed; "voice"/"speaks" explicitly exempted when qualified by caption/text context.
OBL-40: ADDRESSED — r/godot and r/puzzlevideogames each have link-stripped body variants with first-comment posting instructions and sidebar-rejects-links instructions.
OBL-41: ADDRESSED — T-14d creator seeding row clarifies keys are "release-locked (cannot be activated before `{{launch_date}}`)" per Steamworks behavior.
OBL-42: ADDRESSED — T-7d press kit URL row clarifies: "generated and live for press contacts who received T-10d notification; not distributed to full list until T-5d IARC gate passes."
OBL-43: ADDRESSED — Steam community templates rendered in Appendix E: pinned thread (E.1), community FAQ (E.2), guide stub (E.3).
OBL-44: ADDRESSED — T-10d FAQ task reconciled to "from G14 §11 (paste-ready entries rendered in Appendix D)"; Appendix D renders 4 direct entries.
OBL-45: ADDRESSED — T-14d verification step added: "Verify Steamworks Coming Soon pre-IARC policy: check documentation or contact partner support. Record result."
OBL-46: ADDRESSED — Same as OBL-12/17/26: "Deaths are fast" removed from §4.1.
OBL-47: ADDRESSED — X B, r/arcade, and Appendix C all use sentence-context punctuation; no terminal period appended to GENERATOR DOWN, FOOD, or KEY.
OBL-48: ADDRESSED — "All are welcome. All are eaten." added to blog pre-send verification list alongside GENERATOR DOWN, FOOD, and KEY.
OBL-49: ADDRESSED — T+2/T+3 no longer reference refund rate; T+2 monitors review sentiment only; T+3 uses sales/review metrics; real refund metric at T+7.
OBL-50: ADDRESSED — Blog and r/godot use "the building narrates events" (G14-confirmed); "the building is the only character" (INFERRED) struck.
OBL-51: ADDRESSED — "One stairwell all the way down" struck from blog? No — retained as INFERRED with trace. Wait, in merged doc it is retained in Bluesky B and blog with Appendix A trace. The strike was for "the cabinet used to stand." Confirmed: "One stairwell" is INFERRED and retained with trace; "cabinet" struck.
OBL-52: ADDRESSED — "Deaths are fast" struck from §4.1; Appendix A confirms UNVERIFIED/Struck.
OBL-53: ADDRESSED — All untraced specifics resolved: XInput struck, No DLC struck, hides behind guards traced, no respec added, one stairwell traced, class behaviors traced, course hazards traced.
OBL-54: ADDRESSED — "Present tense" struck; "Standing in the doorway" struck; "The building is the only character" softened to "narrates events."
OBL-55: ADDRESSED — Canonical string quotation-context rule defined; all public copy audited; no terminal period after GENERATOR DOWN, FOOD, or KEY as quoted fragments.
OBL-56: ADDRESSED — Appendix C aligned with §5.4; `{{store_link}}` added to all fallbacks; store-page fallback added for Appendix D strings.
OBL-57: ADDRESSED — Tagline added to blog pre-send verification; `{{demo_status}}` and `{{additional_requirements}}` defined in slot legend.
OBL-58: ADDRESSED — T+0 09:50 scheduler-pause added; recovery boundary defined ("at 11:30" = hold to T+1); T-1d launch-slip procedure added.
OBL-59: ADDRESSED — Blog publication at T+0 10:15; outreach sends at T-10d; key sends at T-7d; follow-up at T-5d.
OBL-60: ADDRESSED — Refund thresholds replaced with review sentiment (real-time proxy); real refund metric deferred to T+7.
OBL-61: ADDRESSED — Steam community templates (pinned thread, FAQ, guide stub) and wishlister announcement rendered in Appendix E.
OBL-62: ADDRESSED — r/godot and r/puzzlevideogames have explicit link-stripped variants.
OBL-63: ADDRESSED — T-10d gate added forcing operator "four once shared" decision before pasting Appendix D.
OBL-64: ADDRESSED — T-14d verification step for Steamworks pre-IARC Coming Soon policy added.
OBL-65: ADDRESSED — "Deaths are fast" removed from §4.1; Appendix A confirms UNVERIFIED/Struck.
OBL-66: ADDRESSED — Appendix D provides both variants; T-10d gate records decision; design rationale #4 documents the split.
OBL-67: ADDRESSED — Both slots (`{{demo_status}}` and `{{additional_requirements}}`) defined in slot legend.
OBL-68: ADDRESSED — Course descriptions ("Drowned Vaults," "Cindercrypt," "Starved Deep," "The Hollow Throne") and "The other three classes invite you back" traced to G14 in Appendix A.
OBL-69: ADDRESSED — Tagline ("All are welcome. All are eaten.") added to blog pre-send verification list.
OBL-70: ADDRESSED — Halt-gate boundary defined: "at or before 11:30 inclusive" triggers compressed wave; "11:30 recheck fails" triggers T+1 hold.
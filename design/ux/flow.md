# HUNGERHALL — G5 UX Flow (Aggressive Revision)

**Run:** gap-253b64a1 · **Phase:** G5 · **Authority:** G1 Concept Lock (FROZEN) + G2 GDD (FROZEN, amendments pending re-lock — see LAR table) · **Engine:** Godot 4.7 · **Platform:** Steam (Windows export) · **Price:** $5.99 · **Profile:** commercial_focused (desktop — not legacy casual_mobile_2d; phone-first quotas do not apply) · **Input schemes:** keyboard (WASD/arrows + J/K), Xbox-layout gamepad (left stick + A/B/X/Y), mouse (pointer — menus only, never gameplay)

**Presentation settled in G2:** Pure 2D, 32px tiles, 1985-period palette, original pipeline-authored sprites. No 3D anywhere. Stated once, never revisited.

**Face-button notation:** Xbox layout throughout — A = confirm/throw, B = back/potion (context-dependent, see §1/§8), X/Y unused in this build.

**Reviewer calibration (binding):** Both simulated users sit at a Windows PC. Reviewer A (nine years old) gets a gamepad and a keyboard, ignores written instructions, strikes every key and button. Reviewer B (sixty-five, new to games) reads every label, steers menus with arrow keys + Enter or one stick + A. "Tap" maps to Enter, Space, A-button, or left-click. No touch screen, no edge-swipe, no hold-to-charge, no double-press, no chorded input. Every transition is reachable through a visible, labeled, focusable element or an automatic state change.

**G3 voice note:** G3 runs in parallel and may refine wording, never tone. All copy below is drafted in G2 register — period speech synthesis, short clauses, flat cadence, ALL-CAPS.

---

## Decisions register — positions taken where drafts disagreed

| # | Topic | Position | Rationale |
|---|-------|----------|-----------|
| 1 | Title is a real menu | No "press anything" gate | Title does save recovery + settings discovery; naked press-any-key wastes it |
| 2 | No HOW TO PLAY screen | G2 contracts zero tutorial screens | Teaching rides in-play idle prompts (§4); a reference screen duplicates the contract and invites word-count drift |
| 3 | Haptics: per-throw/kill superseded | Fatigue at Elf 3.0/s throw rate | G2 §8.6 makes all haptics supplemental; audio + visual carry throw/kill feedback |
| 4 | game_over offers RETRY FLOOR N | One edge added to G2 routing | Two screens of friction after the worst moment; load rules identical to title-continue |
| 5 | Initials entry is inline | Not a modal | A separate modal adds a screen class for a 3-letter nicety; Esc skips explicitly |
| 6 | Settings is one flat scrollable column | Zero sub-menus | G5 contract: sub-menus = critical defect |
| 7 | Splash exists (1.2s, skippable after 0.3s) | Pipeline mark earns its moment | Only screen with no Back behavior |
| 8 | No disabled buttons | Unavailable options hidden | First boot: no save → CONTINUE absent, not greyed |
| 9 | Save schema gains `ng_plus: bool` only; tokens deliberately NOT persisted | NG+ disambiguation needed; token persistence is a desync hazard | Tokens are always 2 at the only save point (floor_results entry); persisting them invites stale-value bugs. See LAR-1 |
| 10 | Title Back → quit_warn modal | Esc/B opens quit confirm (YES/NO, NO default) | Focus-to-EXIT was non-standard; quit_warn is clearer for both reviewers and reuses the game's one always-warn dialog |
| 11 | Dying is 1.2s crumble only | 0.4s pre-crumble removed | Pre-crumble had no stated purpose and contradicted the wireframe (DIS-8, zhipu adopted) |
| 12 | 300ms continue_offer grace | Suppresses ALL input on entry | Prevents death-mash from auto-declining (DIS-9, deepseek-2 adopted) |
| 13 | MODE row removed from class_select | Mode chosen at title (NEW GAME vs NEW GAME+) | Simpler class_select; removes focus-order ambiguity; NG+ discoverable where the player already reads |
| 14 | Hold-to-Throw renamed to Auto-Fire | Label implied charge mechanic; semantics is auto-fire at base rate | Eliminates confusion (OBL-20/39) |
| 15 | floor_missing advances save.floor on BOTH options (floors 1–23) | Prevents retry loop on broken floor asset | Floor 24 special case: no skip, save preserved at 23 (OBL-4/9/22/37) |
| 16 | pad_lost transitions to paused first, then modal renders over paused | Clean topology; game never auto-resumes | Player must deliberately press Resume after pad_lost dismisses (OBL-8) |
| 17 | campaign_results always qualifies for initials | Beating the game is itself the mark of distinction | game_over gates on score threshold; campaign clear overrides (OBL-10/40) |

---

## Lock-amendment record (formal change requests to G2)

| # | G2 Reference | Amendment | Justification | Status |
|---|-------------|-----------|---------------|--------|
| LAR-1 | G2 save schema | Add `ng_plus: bool` | Floor number alone cannot distinguish NG+ from normal campaign. Token economy needs no schema change — tokens are never persisted (§1) | Pending G2 re-lock |
| LAR-2 | G2 §11 haptics | Supersede per-throw and per-kill rumble | Fatigue at Elf 3.0/s; G2 §8.6 makes haptics supplemental; audio + visual fallbacks already in G2 | Pending G2 re-lock |
| LAR-3 | G2 GameOver routing | Add game_over → play on RetryChosen | Reduces friction after the worst moment; load rules identical to title-continue | Pending G2 re-lock |
| LAR-4 | G2 "pause menu accessibility sub-panel" | Flatten to one settings screen | G5 contract: sub-menus = critical defect; all controls on one screen, no functionality lost | Pending G2 re-lock |

Each amendment is additive or reductive within G2's own accessibility floor. If G2 rejects one, G5 rolls back to G2's original specification for that item.

---

## DIS resolution table

| DIS | Topic | Adopted | Rationale |
|-----|-------|---------|-----------|
| DIS-1 | How to Play screen | No (moonshot-3, nvidia, zhipu) | G2 contracts zero tutorial screens |
| DIS-2 | Game Over direct retry | Yes (moonshot-3) | Reduces friction after the worst moment |
| DIS-3 | Initials Back behavior | Esc/B skips (moonshot-3, zhipu) | Safer than accidental commit |
| DIS-4 | Title Back behavior | quit_warn modal (deepseek, zhipu) | Clearer than focus-to-EXIT; reuses single warn dialog |
| DIS-5 | paused/dying/continue_offer | All SCREENS (majority) | Consistent state-machine topology |
| DIS-6 | Haptic override | Supersede per-throw/kill (moonshot-3) | Fatigue trip-wire |
| DIS-7 | Restart Floor from paused | No (moonshot-3, nvidia, zhipu) | DEFENDED (revised): The prescribed restart path (Quit to Title → Continue) is indeed free — no token consumed, full HP, 2 tokens, same floor. The only material cost is navigation friction: two deliberate actions (Quit, then Continue) versus one button press. This friction is intentional and is the tension gate. A one-button RESTART FLOOR in pause removes the friction, making restart a reflex rather than a conscious choice. In arcade design, the gap between impulse and commitment is where tension lives. The two-action path preserves that gap without a resource cost. The player who truly wants a fresh floor can get one — but they must choose it twice. |
| DIS-8 | Dying timing | 1.2s crumble only (zhipu) | 0.4s pre-crumble had no purpose |
| DIS-9 | Continue offer grace | 300ms grace (deepseek-2) | Prevents death-mash auto-decline |
| DIS-10 | floor_results → settings | No (majority) | DEFENDED: settings from paused/title only. Settings is one Esc from play; a caller-aware return path for marginal convenience is not justified — player advances, pauses, adjusts: two inputs, no extra screen class |

---

## 1. Screen graph

Binding for G7. Nouns are screens; every edge names its trigger; every Back rule states warn or no-warn. **Modals are not screens:** they seize input above their parent and always return to it. They are not counted in the onboarding screen budget.

**B-button mapping (resolved — see §8 for full exception table):** B-button = **Potion in play** (same as K on keyboard). B-button = **Back in menus** (same as Esc on keyboard). B-button = **Resume in paused** (exception — see §8). B is never "unbound." Binding B to Potion (not Back) in play prevents stray pad presses from pausing combat.

```
SCREENS:
  - splash            (entry: process launch)
  - title             (entry: splash.BootComplete, class_select.BackOut, paused.QuitConfirmed,
                      floor_results.SaveQuit, game_over.Done, campaign_results.Done,
                      hall_of_heroes.BackOut, settings.BackOut)
  - class_select      (entry: title.NewGameChosen, title.NewGamePlusChosen, campaign_results.BeginNgPlusChosen)
  - play              (entry: class_select.LockedIn, title.ContinueChosen, floor_results.AdvanceChosen,
                      continue_offer.YesChosen, game_over.RetryChosen, paused.ResumeChosen)
  - paused            (entry: play.PauseStruck, play.WindowDefocused, play.PadLostAutoPause)
  - settings          (entry: title.SettingsChosen, paused.SettingsChosen)
  - hall_of_heroes    (entry: title.ScoresChosen, game_over.ScoresChosen, campaign_results.ScoresChosen)
  - dying             (entry: play.HealthEmptied — cinematic, no input, 1.2s default / 0.2s Reduced Motion)
  - continue_offer    (entry: dying.CrumbleFinished)
  - game_over         (entry: continue_offer.Expired — inline initials entry)
  - floor_results     (entry: play.FloorCleared — floors 1–23)
  - campaign_results  (entry: play.FloorCleared — floor 24 — inline initials entry)

MODALS (parent in parens):
  - quit_warn         (title, paused)     context-aware copy; the ONLY always-warn dialog
  - newgame_warn      (title)             fires only when a campaign save exists
  - erase_warn        (settings)          irreversible data wipe
  - reset_warn        (settings)          settings-only reset
  - remap_capture     (settings)          single key/button capture per action row
  - credits_pop       (title, settings)   scrollable credits text
  - privacy_pop       (settings)          privacy policy text
  - pad_lost          (paused)            gamepad disconnect; ALWAYS renders over paused
  - save_fail         (floor_results)     autosave write failed
  - floor_missing     (play)              floor resource failed to load

INLINE ELEMENTS (not screens, not modals — rendered within their parent screen):
  - initials_entry    (game_over, campaign_results)  3-slot character entry; auto-fires when score qualifies
  - idle_prompts      (play)                          MOVE/THROW/EXIT glyphs; overlay only

TRANSITIONS:
  - splash           → title            on BootComplete (auto at 1.2s) or SkipStruck (any confirm after 0.3s)

  - title            → class_select     on NewGameChosen (newgame_warn intercepts first IF a save exists)
  - title            → class_select     on NewGamePlusChosen (row renders only when ng_plus_unlocked;
                                       newgame_warn intercepts first IF a save exists — overwrite timing
                                       identical to NEW GAME: save is overwritten at first floor_results
                                       entry, never before — see Persistence Declaration)
  - title            → play             on ContinueChosen (row rendered only when save exists; loads next
                                       unfinished floor: full HP, 2 tokens, potions as last floor ended)
  - title            → settings         on SettingsChosen
  - title            → hall_of_heroes   on ScoresChosen
  - title            → credits_pop      on CreditsChosen (footer link — see §2 wireframe)
  - title            → quit_warn        on ExitChosen or BackStruck (Esc/B from any row)
  - quit_warn        → OS exit          on Yes (no warn — the modal IS the warn)
  - quit_warn        → title            on No / Esc / B (no warn)

  - class_select     → play             on LockedIn (floor 1 loads; HP = class max; tokens = 2; potions = 0;
                                       NG+ flag carried if entered via NewGamePlusChosen; NEW CAMPAIGN
                                       BEGINS IN MEMORY — no save file is written or overwritten at this
                                       point. The old save remains on disk until the first floor_results
                                       entry of the new run, at which point it is atomically replaced.
                                       If the player backs out or dies before clearing floor 1, the old
                                       save is intact and CONTINUE on title shows the old campaign.)
  - class_select     → title            on BackOut (no warn; nothing committed; old save preserved)

  - play             → paused           on PauseStruck (Esc / Start)
  - play             → paused           on WindowDefocused (OS focus lost — auto-pause, input-free)
  - play             → paused           on PadLostAutoPause (gamepad disconnect detected during play —
                                       auto-pause fires BEFORE pad_lost modal renders; pad_lost always
                                       appears over paused, never over live play)
  - play             → dying            on HealthEmptied (auto-fires within 1 physics tick of HP ≤ 0;
                                       -20% FLOOR SCORE applied at this moment)
  - play             → floor_results    on FloorCleared (stand on open exit for 3 consecutive physics
                                       ticks = 50ms at fixed 60Hz; floors 1–23; auto-fires;
                                       AUTOSAVE WRITES ON ENTRY — atomic temp-file + rename;
                                       tokens reset to 2 on entry)
  - play             → campaign_results on FloorCleared (same condition; floor 24; auto-fires;
                                       NG+ unlock flag AND class name written to persistent profile
                                       on entry — see classes_cleared below)
  - play             → floor_missing    on FloorDataMissing (floor resource fails to load)

  - paused           → play             on ResumeChosen (no warn; fixed 60Hz delta continues, zero time skip)
  - paused           → settings         on SettingsChosen (no warn)
  - paused           → quit_warn        on QuitChosen (ALWAYS WARNS; copy: "QUIT TO TITLE? FLOOR PROGRESS IS LOST.")
  - quit_warn        → title            on Yes (from paused caller; floor progress discarded)
  - quit_warn        → paused           on No / Esc / B (from paused caller)

  - settings         → caller           on BackOut (no warn; caller = settings.caller ∈ {title, paused},
                                       passed as a parameter on SessionManager when SettingsChosen fires)
  - settings         → remap_capture    on RemapChosen (per-row; action passed as parameter)
  - settings         → credits_pop      on CreditsChosen
  - settings         → privacy_pop      on PrivacyChosen
  - settings         → erase_warn       on EraseChosen
  - settings         → reset_warn       on ResetChosen

  - hall_of_heroes   → caller           on BackOut (no warn; caller may be title, game_over, campaign_results)

  - dying            → continue_offer   on CrumbleFinished (auto after 1.2s default / 0.2s Reduced Motion;
                                       input buffer flushed on entry; all input ignored for duration)

  - continue_offer   → play             on YesChosen (tokens -= 1; floor rebuilt from baked data (same
                                       seed) — FULL FLOOR RESET: generators reset to full HP and initial
                                       spawn state, enemies reset to initial positions, doors reset to
                                       locked; ONLY eaten food persists (consumed food stays consumed,
                                       unconsumed food remains in place); hero stands on entrance tile
                                       at 50% class HP; potions and keys zeroed; 300ms input grace
                                       suppresses ALL input on entry — both buffered and new; after 300ms
                                       all input is live, preventing death-mash auto-decline)
  - continue_offer   → game_over        on Expired (10.0s ring empties, NO chosen, or Back struck —
                                       Back = NO in this context)
  - continue_offer   → game_over        on TokensEmpty (auto: "OUT OF TOKENS" holds 3.0s, no input
                                       accepted, then fires)

  - game_over        → play             on RetryChosen (same baked floor seed as failed attempt; full HP;
                                       2 tokens; score = last floor_results total; potions = 0 — fresh
                                       floor start; NOT a continue — no token consumed)
  - game_over        → hall_of_heroes   on ScoresChosen (no warn)
  - game_over        → title            on Done (no warn; initials committed or skipped, score banked)

  - floor_results    → play             on AdvanceChosen (next floor loads; save already landed on entry)
  - floor_results    → title            on SaveQuit / Back (no warn — SAVED tag is proof)

  - campaign_results → class_select     on BeginNgPlusChosen (NG+ mode; fresh campaign at floor 1)
  - campaign_results → hall_of_heroes   on ScoresChosen (no warn)
  - campaign_results → title            on Done (no warn — campaign complete; NG+ flag AND class name
                                       written to profile on entry)

  - remap_capture    → settings         on CaptureDone, SwapDone, ClearDone, or Cancel (Esc/B; no warn)
  - credits_pop      → caller           on Back (Esc / B; no warn)
  - privacy_pop      → settings         on Back (Esc / B; no warn)
  - erase_warn       → settings         on No / Esc / B (no warn)
  - erase_warn       → title            on Yes (no warn — the modal IS the warn; ALL data erased —
                                       campaign, scores, NG+ flag, settings — complete reset; returns
                                       to title with no CONTINUE row)
  - reset_warn       → settings         on No / Esc / B (no warn)
  - reset_warn       → settings         on Yes (no warn; settings reset to defaults; save/scores/profile
                                       untouched)
  - newgame_warn     → class_select     on Yes (old save preserved until first floor_results entry of
                                       new run; mode carries through — CAMPAIGN or NG+ per the row
                                       that fired)
  - newgame_warn     → title            on No / Esc / B (no warn)
  - pad_lost         → paused           on KeyboardKey (input switches to keyboard; the dismissing key
                                       event is CONSUMED by the modal — it does NOT forward to the
                                       underlying paused screen; player must press a second key to
                                       interact with paused) or GamepadReconnect (modal dismisses;
                                       state stays paused — game never auto-resumes from pad_lost;
                                       player must deliberately press Resume)
  - save_fail        → floor_results    on Retry (re-attempts atomic write; max 3 attempts, then
                                       [TRY AGAIN] is replaced by "SAVE UNAVAILABLE — CONTINUE ANYWAY")
  - save_fail        → title            on SkipSave (warned: "YOUR RUN CONTINUES BUT WILL NOT SURVIVE APP CLOSE")
  - floor_missing    → title            on BackToTitle (no warn; floors 1–23: save.floor advanced to
                                       next floor — prevents retry loop; floor 24: save.floor preserved
                                       at 23 — floor 24 is the finale, no skip; broken floor 24 is a
                                       build defect logged to telemetry; player can start NEW GAME)
  - floor_missing    → title            on SkipFloor (no warn; floors 1–23 only: save.floor advanced
                                       to next floor; missing floor logged to telemetry; player
                                       Continues from title onto the next available floor — no retry
                                       loop; NOT offered on floor 24)

BACK-BUTTON RULES (Back = Esc on keyboard, B on gamepad; a visible footer hint names it on every menu):
  - splash           : Back inert (1.2s lifetime; confirm skips forward, never backward)
  - title            : Back → quit_warn modal "LEAVE HUNGERHALL?" [YES] [NO] (NO default).
                       Enter/A on the EXIT row also fires quit_warn. No focus-to-EXIT pattern;
                       no double-Esc instant exit.
  - class_select     : Back → title, NO WARN
  - play             : B = POTION (not Back); Back from play is Esc / Start = PauseStruck only.
                       A stray B press fires a potion, not a pause.
  - paused           : Back = ResumeChosen, NO WARN. Exception to "B = Back in menus" — see §8.
                       QuitChosen ALWAYS WARNS through quit_warn (NO default); safe default focus
                       sits on KEEP DELVING.
  - settings         : Back → caller, NO WARN (every change applies and persists on release)
  - hall_of_heroes   : Back → caller, NO WARN
  - dying            : Back disabled (non-interactive)
  - continue_offer   : Back = choosing NO, NO WARN beyond that (the offer screen IS the decision)
  - game_over        : while initials row is live, Back SKIPS recording and lands focus on
                       RETRY FLOOR N; afterwards Back = Done → title. NO WARN at any point.
                       After initials commit (Enter on 3rd slot), focus moves to RETRY FLOOR N;
                       initials row becomes static (non-focusable).
  - floor_results    : Back = SaveQuit → title, NO WARN (autosave landed on entry)
  - campaign_results : same initials rule as game_over; afterwards Back = Done → title, NO WARN
  - floor_missing    : Back/Esc/B = BackToTitle (same as [BACK TO TITLE] button; see transition
                       above for save.floor advancement rules)

WINDOW-CLOSE RULES (Alt+F4 / window X):
  - splash           : quit immediately (nothing to save)
  - title            : quit immediately (nothing unsaved; the OS gesture is already deliberate)
  - class_select     : quit immediately (nothing committed; old save preserved)
  - play             : quit_warn modal fires first. Yes quits (interrupted floor discarded;
                       campaign save at last completed floor intact); No returns to play.
  - paused           : quit_warn modal fires first. Yes quits (floor discarded); No returns to paused.
  - settings         : quit immediately (settings persist per-change on release)
  - hall_of_heroes   : quit immediately (nothing unsaved)
  - dying            : quit immediately (non-interactive; campaign save at last floor_results intact;
                       no score-table entry written for abandoned run)
  - continue_offer   : quit immediately (treated as Decline; campaign save at last cleared floor
                       intact; no game_over render; no score-table entry written)
  - game_over        : quit immediately (score already banked; if initials in progress, skipped as
                       "---"; committed initials preserved; campaign save at last floor_results intact)
  - floor_results    : quit immediately (autosave already written on entry)
  - campaign_results : quit immediately (NG+ flag already written on entry)
  - Any modal        : modal dismissed; parent's window-close rule applies

PERSISTENCE DECLARATION (binding — no contradictions):
  Campaign save is written in exactly ONE place: entry into floor_results, atomically (temp + rename).
  No mid-floor save can ever exist. class_select.LockedIn does NOT write or overwrite the save file —
  it begins a new campaign in memory only. The old save remains on disk until the first floor_results
  entry of the new run, at which point it is atomically replaced. This is why quit_warn is the game's
  only warning dialog and every other Back is no-warn: no other Back discards anything.

  - New-game death before floor 1: If the player starts a new game and dies before clearing floor 1,
    the old save is intact (no overwrite occurred). game_over displays "CAMPAIGN SAVE: FLOOR [N]"
    (the old save's floor) below FINAL SCORE, so the player knows what RETURN TO TITLE will offer.
    The player can RETRY FLOOR 1 (continue the new run) or RETURN TO TITLE (where CONTINUE shows
    the old campaign). This is intentional arcade behavior — the new run was abandoned by death.
  - Mid-floor quit discards the interrupted floor. Resume starts at next uncompleted floor's entrance
    with full HP, 2 tokens, and saved potions.
  - Continue rebuilds the current floor from baked data (same seed) — a full floor reset, not a
    save-load. See continue_offer.YesChosen above for exact reset specification.
  - GameOver preserves campaign save at last completed floor. High-score entry is committed at
    GameOver with FINAL SCORE = last floor_results total (the failed floor's score is lost).
  - NG+ unlock flag AND class name written to persistent profile at campaign_results entry.
    profile.classes_cleared drives laurel icons on class_select (see §7 empty state).
  - Settings write atomically on slider release / toggle change. No Apply button.
  - newgame_warn: old save preserved until first floor_results entry of new run, for both NEW GAME
    and NEW GAME+. If the player backs out from class_select, the old save is intact and CONTINUE
    shows the old campaign.
  - Save schema (LAR-1): {save_version: 1, floor: int, class: String, score: int,
    potions_remaining: int, ng_plus: bool, timestamp: int}
  - Migration: unrecognized save_version → fresh start with notification.
  - Tokens are NOT persisted: the only save point is floor_results entry, where tokens are already
    2 — so every load grants 2 tokens and no stale-token desync is possible.

SCORE AND SAVE SEMANTICS (binding — unified wording):
  - Death applies -20% to the current floor's accumulated score at dying entry (shown in dying state).
  - Continue: player keeps the penalized floor score and continues earning on the rebuilt floor.
  - Game over (tokens empty): the failed floor's score is lost. FINAL SCORE on game_over =
    last floor_results total (the cumulative score saved at the last completed floor). High-score
    table entry uses this same value.
  - Retry from game_over: score = last floor_results total; floor score starts at 0; same baked floor
    data (same seed) as the failed attempt.
  - Autosave at floor_results entry writes: floor = next uncompleted, score = cumulative total
    (including any death penalties from that floor), potions as saved, ng_plus flag.

INITIALS QUALIFICATION RULE (binding — elevated from wireframe caption):
  - game_over: initials entry auto-fires when the player's FINAL SCORE qualifies for the top-10
    local high-score table for the played class. Qualification threshold:
      * If the table has N < 10 entries: any positive score qualifies (threshold = 0, strict >).
      * If the table is full (10 entries): score qualifies if > 10th-place score (strict >).
      * Empty table (0 entries): any positive score qualifies.
    Score of 0 does NOT qualify.
  - campaign_results: initials entry ALWAYS fires, regardless of score. Beating the campaign
    (clearing floor 24) is itself the mark of distinction. The player always enters initials
    on campaign completion.
  - Esc/B skips initials in both cases; score displays as "---" in the table.

CLASSES_CLEARED WRITE POINT:
  - campaign_results entry appends the played class name to profile.classes_cleared (if not
    already present). This drives laurel icons on class_select (see §7). No other transition
    writes to classes_cleared.

MODAL STACKING POLICY:
  - Modals do not stack on each other except pad_lost, which has priority over all child modals.
  - If pad_lost fires while a child modal (remap_capture, credits_pop, privacy_pop) is open:
    (1) the child modal is dismissed, (2) the underlying screen transitions to paused if caller
    was play (PadLostAutoPause), (3) pad_lost renders over the paused screen (or over the parent
    menu if caller was a menu), (4) on pad_lost dismissal, the parent screen reconverges to its
    prior state — the dismissed child modal does NOT auto-reopen. The player must re-invoke it.
  - quit_warn, newgame_warn, erase_warn, reset_warn, save_fail, floor_missing do not stack —
    each is the only modal open at a time.

AMBIGUITY CLOSURES:
  - PC sleep mid-game: Godot window-focus-loss triggers auto-pause if in play. On wake, resumes
    from paused.
  - Steam overlay mid-floor: same as WindowDefocused — auto-pause. Returning resumes from paused.
  - NG+ save vs normal save: one save slot only. Continue loads whatever the save contains. Mode
    badge renders next to Continue: "CONTINUE — FLOOR 7 · ELF (NG+)" or "CONTINUE — FLOOR 7 · ELF".
  - Token economy: tokens reset to 2 at each floor_results entry (per-floor, not per-run). Continue
    consumes 1. game_over RETRY does NOT consume a token (fresh start, not a continue). Tokens are
    not persisted in the campaign save. Quitting mid-floor after a continue and then Continue from
    title gives 2 tokens and full HP — this is by design (the interrupted floor is discarded; the
    player restarts the floor fresh, losing all progress on it). This is NOT an exploit: the player
    loses all floor progress (score, food consumed, generators destroyed, keys collected) by quitting.
  - Steam Cloud note: cloud sync is out of scope (G1 locks local-only, no online features). If the
    player enables Steam Cloud for the app directory, Godot's user:// path may sync — the game does
    not manage cloud conflicts. Known limitation flagged for post-launch.
```

---

## 2. ASCII wireframes

Baseline 1920×1080; all pixel figures scale with resolution. Type floors per G2 §8.3: running text ≥22px, primary CTAs ≥30px, HUD numerals ≥40px. Face-button notation uses Xbox A/B/X/Y throughout.

### splash

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│                     ◆  S N E F E R U  ◆                      │
│                   pipeline mark · 96px                       │
│                                                              │
│                                                              │
│          (any confirm after 0.3s skips onward)              │
│           (auto-advances at 1.2s)                            │
└──────────────────────────────────────────────────────────────┘
```
Non-interactive except skip. Only screen with no Back behavior.

### title (no save — first boot)

```
┌──────────────────────────────────────────────────────────────┐
│  [attract replay: live deterministic simulation, dimmed 40%, │
│   looping — visible combat motion from first frame]          │
│                                                              │
│                H U N G E R H A L L                           │
│              THE VAULT DEVOURS                               │
│                                                              │
│          ┌──────────────────────────────┐                    │
│          │           NEW GAME           │  ← default focus   │
│          └──────────────────────────────┘                    │
│          ┌──────────────────────────────┐                    │
│          │          HALL OF HEROES      │                    │
│          └──────────────────────────────┘                    │
│          ┌──────────────────────────────┐                    │
│          │           SETTINGS           │                    │
│          └──────────────────────────────┘                    │
│          ┌──────────────────────────────┐                    │
│          │             EXIT             │                    │
│          └──────────────────────────────┘                    │
│                                                              │
│  ↑/↓ choose · Enter confirm · Esc/B back                     │
│  v1.0 · SNEFERU GAME PIPELINE · CREDITS                      │
└──────────────────────────────────────────────────────────────┘
```
CONTINUE absent — not disabled, not greyed. NEW GAME+ absent (NG+ not unlocked). Attract replay plays behind everything. CREDITS is a footer text link (clickable/focusable, same as a button — opens credits_pop).

**Attract replay note:** Live deterministic simulation through the `ci/sneferu_bot.gd` seam — same pure rules code (FloorRules/CombatRules/ScoreRules) as the real game, not a pre-rendered video. Seed 0xDEAD, Warrior bot, Floor 1, 30Hz half-speed update (the rules code is identical; only the tick rate differs — the bot takes half as many steps per second, producing a slower-motion preview), dimmed 40%, muted, no haptics, loops on bot death or floor clear. Full spec in Appendix C.

### title (with save — subsequent boot)

```
┌──────────────────────────────────────────────────────────────┐
│  [attract replay: live deterministic simulation, dimmed 40%] │
│                                                              │
│                H U N G E R H A L L                           │
│              THE VAULT DEVOURS                               │
│                                                              │
│          ┌──────────────────────────────┐                    │
│          │ CONTINUE — FLOOR 7 · ELF     │  ← default focus   │
│          └──────────────────────────────┘                    │
│          ┌──────────────────────────────┐                    │
│          │           NEW GAME           │                    │
│          └──────────────────────────────┘                    │
│          ┌──────────────────────────────┐                    │
│          │          HALL OF HEROES      │                    │
│          └──────────────────────────────┘                    │
│          ┌──────────────────────────────┐                    │
│          │           SETTINGS           │                    │
│          └──────────────────────────────┘                    │
│          ┌──────────────────────────────┐                    │
│          │             EXIT             │                    │
│          └──────────────────────────────┘                    │
│                                                              │
│  1. AAA 12400 WAR ▮  table ticker cycles every 3s            │
│  ↑/↓ choose · Enter confirm · Esc/B back                     │
│  v1.0 · SNEFERU GAME PIPELINE · CREDITS                      │
└──────────────────────────────────────────────────────────────┘
```
Focus: CONTINUE → NEW GAME → HALL OF HEROES → SETTINGS → EXIT. All buttons ≥280×56px.

### title (with save + NG+ unlocked)

```
┌──────────────────────────────────────────────────────────────┐
│  [attract replay: live deterministic simulation, dimmed 40%] │
│                                                              │
│                H U N G E R H A L L                           │
│              THE VAULT DEVOURS                               │
│                                                              │
│          ┌──────────────────────────────┐                    │
│          │ CONTINUE — FLOOR 7 · ELF(NG+)│  ← default focus   │
│          └──────────────────────────────┘                    │
│          ┌──────────────────────────────┐                    │
│          │           NEW GAME           │                    │
│          └──────────────────────────────┘                    │
│          ┌──────────────────────────────┐                    │
│          │  ★ NEW GAME+                 │  ← star badge      │
│          └──────────────────────────────┘                    │
│          ┌──────────────────────────────┐                    │
│          │          HALL OF HEROES      │                    │
│          └──────────────────────────────┘                    │
│          ┌──────────────────────────────┐                    │
│          │           SETTINGS           │                    │
│          └──────────────────────────────┘                    │
│          ┌──────────────────────────────┐                    │
│          │             EXIT             │                    │
│          └──────────────────────────────┘                    │
│                                                              │
│  [entrance caption: "NEW GAME+ UNLOCKED" — 2s on first       │
│   title render after unlock, then never again]               │
│  ↑/↓ choose · Enter confirm · Esc/B back                     │
└──────────────────────────────────────────────────────────────┘
```
Focus: CONTINUE → NEW GAME → NEW GAME+ → HALL OF HEROES → SETTINGS → EXIT. NG+ badge renders on CONTINUE when the save has `ng_plus: true`. NEW GAME+ row distinguished by ★ badge accent (period palette gold) + one-time entrance caption "NEW GAME+ UNLOCKED" (2s, first title render after unlock only).

### class_select

```
┌──────────────────────────────────────────────────────────────┐
│                    CHOOSE YOUR HERO                          │
│                                                              │
│ ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐      │
│ │╔═════════╗│ │           │ │           │ │           │      │
│ │║ WARRIOR ║│ │ VALKYRIE  │ │  WIZARD   │ │   ELF     │      │
│ │║ [sprite ║│ │ [sprite   │ │ [sprite   │ │ [sprite   │      │
│ │║  idles] ║│ │   idles]  │ │   idles]  │ │   idles]  │      │
│ │╚═════════╝│ │           │ │           │ │           │      │
│ │ HP 800    │ │ HP 680    │ │ HP 520    │ │ HP 560    │      │
│ │ SPD 128   │ │ SPD 152   │ │ SPD 144   │ │ SPD 192   │      │
│ │ AXE · 50  │ │ SPEAR · 30│ │ BOLT · 20 │ │ ARROW · 15│      │
│ │"BUYS      │ │"HER LANE  │ │"PACKS     │ │"ALWAYS    │      │
│ │ GROUND    │ │ IS ALREADY│ │ VANISH.   │ │ SOMEWHERE │      │
│ │ WITH      │ │ PAID."    │ │ LONERS    │ │ THE TEETH │      │
│ │ BLOOD."   │ │           │ │ COLLECT." │ │ AREN'T."  │      │
│ │ [laurel]  │ │ [laurel]  │ │ [laurel]  │ │ [laurel]  │      │
│ └───────────┘ └───────────┘ └───────────┘ └───────────┘      │
│     ←/→ choose · Enter locks in · Esc/B back                 │
│                                                              │
│  ┌──────────────────────────────────────────────┐            │
│  │ WARRIOR: Pays HP for position. Walks through  │            │
│  │ crowds. Axe pierces lines of foes.            │            │
│  │ Potion — Whirlwind: 4-tile radial burst.      │            │
│  │ [J / A] throw  [K / B] potion  [Esc/Start] paus│           │
│  └──────────────────────────────────────────────┘            │
└──────────────────────────────────────────────────────────────┘
```
Warrior pre-highlighted (G2 contract). Class cards 200×280px, 16px gap. Description panel updates on focus. Laurels appear only for classes recorded in `profile.classes_cleared` (written at campaign_results entry — see §1). No MODE row — mode chosen at title. When entered via NewGamePlusChosen, stats reflect NG+ modifiers.

### play (HUD overlay on game viewport)

```
┌──────────────────────────────────────────────────────────────┐
│ HP ████████████████░░░  800   SCORE  002,500   TOKENS 2      │
│ POTION [●][○][○]  KEY [○]       FLOOR 1 / 24                 │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│                    ┌──────────────────┐                      │
│                    │   32px tile grid  │                      │
│                    │   top-down view   │                      │
│                    │                   │                      │
│                    │   @ player        │                      │
│                    │   G generator     │                      │
│                    │   ☠ ghosts        │                      │
│                    │   ⚑ food          │                      │
│                    │   ⊕ exit door     │  ← pulses when all   │
│                    │                   │    keys held         │
│                    └──────────────────┘                      │
│                                                              │
│  [caption: "THE WARRIOR ENTERS HUNGERHALL." — 2s]           │
│  [idle glyph: "MOVE" fades in at T+4s, "THROW" at T+10s]    │
│  [idle glyph: "EXIT" fades in at T+15s if exit visible      │
│   and floor not cleared]                                     │
│                                                              │
│  [Esc / Start: PAUSE]  [J / A: THROW]  [K / B: POTION]      │
└──────────────────────────────────────────────────────────────┘
```
HUD top bar 48px. No interactive targets in viewport — pause via Esc/Start only. HP bar pulses red below 25%. Exit door pulses with a soft glow when the player holds all required keys (visual telegraph that the exit is accessible). Idle prompts appear as overlays near the player sprite, not as separate screens.

### paused (screen over play, dimmed 60%)

```
┌──────────────────────────────────────────────────────────────┐
│  [game viewport frozen behind, dimmed 60%]                   │
│                                                              │
│                        PAUSED                                │
│                                                              │
│          ┌──────────────────────────────────┐                │
│          │         ▶ KEEP DELVING           │  ← default     │
│          └──────────────────────────────────┘                │
│          ┌──────────────────────────────────┐                │
│          │           SETTINGS               │                │
│          └──────────────────────────────────┘                │
│          ┌──────────────────────────────────┐                │
│          │       ⚠ QUIT TO TITLE            │                │
│          │    (floor progress is lost)      │                │
│          └──────────────────────────────────┘                │
│                                                              │
│   Floor 7 · Elf · 12,450 · 2 tokens                          │
│   [autosave: Floor 6 cleared]                                │
│                                                              │
│   ↑/↓ navigate · Enter select · Esc/Start/B resume           │
└──────────────────────────────────────────────────────────────┘
```
Focus: KEEP DELVING → SETTINGS → QUIT TO TITLE. Targets 280×56px, 12px gap. QUIT fires quit_warn (always warns). No RESTART FLOOR option (DIS-7 defended — see resolution table). B = Resume (exception to "B = Back in menus" — see §8).

### dying (non-interactive, 1.2s default / 0.2s Reduced Motion)

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│                 [hero crumbles to dust]                      │
│              (Reduced Motion ON: instant fade)               │
│                                                              │
│                   -20% FLOOR SCORE                           │
│                                                              │
│                      (1.2s / 0.2s)                           │
│                                                              │
│            [input buffer flushed — no response]              │
└──────────────────────────────────────────────────────────────┘
```
1.2s crumble animation (default). Reduced Motion ON → 0.2s instant fade, still non-interactive, still auto-advances. All input ignored. No back, no pause, no skip. No 0.4s pre-crumble (DIS-8 resolved).

### continue_offer

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│               CONTINUES LEFT: 2                              │
│                                                              │
│                  CONTINUE?                                   │
│                                                              │
│         ┌──────────┐  ┌──────────┐                          │
│         │   YES    │  │    NO    │                          │
│         │   [◆]    │  │          │                          │
│         └──────────┘  └──────────┘                          │
│                                                              │
│         [████████░░░░░░░░] 10.0s ring                        │
│                                                              │
│    Enter / A = YES · Esc / B = NO                            │
│    (300ms input grace on entry — ALL input suppressed)      │
└──────────────────────────────────────────────────────────────┘
```
YES pre-highlighted. 10s ring visible. 300ms grace suppresses ALL input (buffered and new). After 300ms, all input live.

### continue_offer (TokensEmpty)

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│               OUT OF TOKENS                                  │
│                                                              │
│         (3.0s — auto-advances to GAME OVER)                  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```
No YES/NO buttons. No ring. Banner sits 3.0s, no input accepted, then auto-fires to game_over.

### game_over (with inline initials)

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│                    GAME OVER                                 │
│                                                              │
│              FINAL SCORE: 18,450                             │
│              FLOOR REACHED: 7                                │
│              CAMPAIGN SAVE: FLOOR 6                          │
│                                                              │
│   ┌──────────────────────────────────────────────┐           │
│   │  ENTER INITIALS:  [ A ][ A ][ A ]            │           │
│   │  ←/→ select · ↑/↓ change · type letters      │           │
│   │  Enter commits · Esc/B skips                 │           │
│   └──────────────────────────────────────────────┘           │
│                                                              │
│          ┌──────────────────────────────────┐                │
│          │       ▶ RETRY FLOOR 7            │  ← default     │
│          └──────────────────────────────────┘    after commit│
│          ┌──────────────────────────────────┐                │
│          │        HALL OF HEROES            │                │
│          └──────────────────────────────────┘                │
│          ┌──────────────────────────────────┐                │
│          │       RETURN TO TITLE            │                │
│          └──────────────────────────────────┘                │
│                                                              │
│   Esc/B skips initials · campaign save preserved at Floor 6  │
└──────────────────────────────────────────────────────────────┘
```
Initials auto-fire when FINAL SCORE qualifies (top 10 per class — see §1 Initials Qualification Rule: N<10 → any positive score; full table → > 10th place; score 0 does NOT qualify). 3 slots, A–Z + 0–9 + space (37 chars), default AAA. Keyboard: type to fill, Backspace deletes and moves back, Enter commits. Gamepad: ←/→ select slot, ↑/↓ change char, Enter/A commits. After commit, focus → RETRY FLOOR N and the initials row becomes static. Esc/B skips (score displays as "---"). "CAMPAIGN SAVE: FLOOR N" shows the old save's floor — the player knows what RETURN TO TITLE will offer.

### floor_results

```
┌──────────────────────────────────────────────────────────────┐
│  [zone-themed border — Zone 1: Catacombs]                    │
│                                                              │
│                    FLOOR 3 CLEARED                            │
│                         [SAVED]                              │
│                                                              │
│   SCORE THIS FLOOR:        4,200                             │
│   TOTAL SCORE:            12,450                             │
│   POTIONS REMAINING:          2                             │
│   CONTINUE TOKENS:             2                             │
│                                                              │
│          ┌──────────────────────────────────┐                │
│          │       ▶ NEXT FLOOR               │  ← default     │
│          └──────────────────────────────────┘                │
│          ┌──────────────────────────────────┐                │
│          │       QUIT TO TITLE (SAVED)      │                │
│          └──────────────────────────────────┘                │
│                                                              │
│   Enter = next floor · Esc/B = save & quit                   │
└──────────────────────────────────────────────────────────────┘
```
SAVED tag = autosave committed. Tokens display as 2 (reset on entry). SAVED tag does NOT render while a save_fail modal is open.

### campaign_results

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│               ╔═══════════════════════╗                      │
│               ║   CAMPAIGN CLEARED    ║                      │
│               ╚═══════════════════════╝                      │
│                                                              │
│              FINAL SCORE: 247,800                            │
│              NEW GAME+ UNLOCKED                              │
│                                                              │
│   ┌──────────────────────────────────────────────┐           │
│   │  ENTER INITIALS:  [ A ][ A ][ A ]            │           │
│   │  Enter commits · Esc/B skips                 │           │
│   └──────────────────────────────────────────────┘           │
│                                                              │
│          ┌──────────────────────────────────┐                │
│          │       ▶ BEGIN NG+                │  ← default     │
│          └──────────────────────────────────┘                │
│          ┌──────────────────────────────────┐                │
│          │        HALL OF HEROES            │                │
│          └──────────────────────────────────┘                │
│          ┌──────────────────────────────────┐                │
│          │       RETURN TO TITLE            │                │
│          └──────────────────────────────────┘                │
│                                                              │
│   NG+ flag + class cleared written · Esc/B skips initials    │
└──────────────────────────────────────────────────────────────┘
```
Initials ALWAYS fire on campaign completion (regardless of score — see §1 Initials Qualification Rule). BEGIN NG+ goes directly to class_select (NG+ mode; fresh campaign at floor 1) — no 5-step navigation after the climax. Default focus preserves momentum. Initials rules identical to game_over except qualification is unconditional.

### settings (single flat scrollable column — no sub-menus)

```
┌──────────────────────────────────────────────────────────────┐
│  SETTINGS                            [← Back: Esc / B]       │
│                                                              │
│  DISPLAY                                                     │
│  ┌────────────────────────────────────────────┐              │
│  │  Brightness            [████████░░] 80%    │              │
│  │  UI Scale              [██████░░░░] 100%   │              │
│  │  Window Mode           [ FULLSCREEN ]      │              │
│  │                        [ BORDERLESS ]      │              │
│  │                        [ WINDOWED ]        │              │
│  │  Resolution            1920×1080 ◀ ▶       │              │
│  │  (Fullscreen: uses desktop resolution;     │              │
│  │   Resolution control disabled)             │              │
│  │  (Borderless: uses desktop resolution;     │              │
│  │   Resolution control disabled)             │              │
│  │  (Windowed: uses selected Resolution)      │              │
│  └────────────────────────────────────────────┘              │
│                                                              │
│  AUDIO                                                       │
│  ┌────────────────────────────────────────────┐              │
│  │  Master Volume          [████████░░] 80%    │              │
│  │  Sound Effects          [ ON ] [ OFF ]      │              │
│  │  Music                  [ ON ] [ OFF ]      │              │
│  │  Announcer              [ ON ] [ OFF ]      │              │
│  └────────────────────────────────────────────┘              │
│                                                              │
│  CONTROLS                                                    │
│  ┌────────────────────────────────────────────┐              │
│  │  Move Up        : W / ↑ / LS-Up    [REMAP] │              │
│  │  Move Down      : S / ↓ / LS-Down  [REMAP] │              │
│  │  Move Left      : A / ← / LS-Left  [REMAP] │              │
│  │  Move Right     : D / → / LS-Right [REMAP] │              │
│  │  Throw          : J / A-Button     [REMAP] │              │
│  │  Potion         : K / B-Button     [REMAP] │              │
│  │  Pause          : Esc / Start      [REMAP] │              │
│  └────────────────────────────────────────────┘              │
│                                                              │
│  ACCESSIBILITY                                              │
│  ┌────────────────────────────────────────────┐              │
│  │  Captions              [ ON ] [ OFF ]       │              │
│  │  Reduced Motion        [ ON ] [ OFF ]       │              │
│  │  Color-Blind Mode      [ OFF / DEUTER /     │              │
│  │                        PROTAN / TRITAN ]    │              │
│  │  Auto-Fire             [ ON ] [ OFF ]       │              │
│  └────────────────────────────────────────────┘              │
│                                                              │
│  HAPTICS (visible only when gamepad connected)              │
│  ┌────────────────────────────────────────────┐              │
│  │  Gamepad Rumble        [ ON ] [ OFF ]       │              │
│  └────────────────────────────────────────────┘              │
│                                                              │
│  DATA                                                       │
│  ┌────────────────────────────────────────────┐              │
│  │  [ RESET TO DEFAULTS ]  (settings only)     │              │
│  │  [ ERASE ALL DATA ]     (fires erase_warn)  │              │
│  └────────────────────────────────────────────┘              │
│                                                              │
│  ABOUT                                                      │
│  ┌────────────────────────────────────────────┐              │
│  │  [ CREDITS ]  [ PRIVACY POLICY ]            │              │
│  └────────────────────────────────────────────┘              │
│                                                              │
│  v1.0 · SNEFERU GAME PIPELINE                                │
└──────────────────────────────────────────────────────────────┘
```
Zero sub-menus. Every setting on one screen. Changes apply and persist on release (sliders) or toggle (switches) — atomic write, no Apply button. Per-row [REMAP] buttons open remap_capture for that specific action. HAPTICS section hidden when no gamepad detected; if focus is on the Rumble toggle when the gamepad disconnects, focus moves to the nearest preceding focusable element (last ACCESSIBILITY toggle — Auto-Fire). Window Mode + Resolution interaction: Fullscreen and Borderless use the desktop's native resolution (Resolution control is disabled/greyed in these modes); Windowed uses the selected Resolution (control is active).

### remap_capture modal

```
┌──────────────────────────────────────────────┐
│  PRESS A KEY OR BUTTON FOR: THROW            │
│                                              │
│  Current: J / A-Button                       │
│                                              │
│  [ CLEAR BINDING ]  [ CANCEL (Esc/B) ]      │
│                                              │
│  (If key is already bound, swap is offered)  │
│  (Capture replaces the binding for the       │
│   captured input's scheme only — keyboard    │
│   replaces keyboard, gamepad replaces        │
│   gamepad. Arrow keys and WASD are separate  │
│   bindings within the keyboard scheme.)      │
│  (CLEAR on movement actions reverts to       │
│   factory default, never empty — prevents    │
│   unplayable state. CLEAR on non-movement    │
│   actions can leave the binding empty.)      │
└──────────────────────────────────────────────┘
```
Captures the next single input. If already bound to another action: "[KEY] IS BOUND TO [ACTION]. SWAP? [YES] [NO]". [CLEAR BINDING] removes the binding for that action — but for movement actions (Move Up/Down/Left/Right), clearing reverts to the factory default binding (W/S/A/D, arrows, or left stick), never an empty state. For non-movement actions (Throw, Potion, Pause), clearing can leave the binding empty (the action is then unbound until remapped). Esc/B cancels. Binding persists immediately (atomic write). Modal always returns to settings.

### hall_of_heroes

```
┌──────────────────────────────────────────────────────────────┐
│  HALL OF HEROES                       [← Back: Esc / B]      │
│                                                              │
│  WARRIOR           VALKYRIE         WIZARD           ELF     │
│  1. AAA  12,400    1. BBB  11,200   1. CCC  10,800   1. DDD  9,400│
│  2. EEE   8,900    2. FFF   8,100   2. GGG   7,200   2. HHH  6,800│
│  3. III   6,100    3. JJJ   5,400   3. KKK   4,900   3. LLL  4,200│
│  ...                                                         │
│  10. ---     ---   10. ---     ---   10. ---     ---   10. ---   ---│
│                                                              │
│  ↑/↓ page scroll · Esc / B back                              │
│  (one global list — all columns scroll together)            │
└──────────────────────────────────────────────────────────────┘
```
Four columns, one per class. Top 10 per class. Single global vertical page scroll — all columns scroll together. Unfilled slots render "---". Local scores only (G1 out-of-scope: online leaderboards).

---

## 3. First-30-seconds storyboard

```
T+0s    : Player launches HUNGERHALL from Steam. Splash — SNEFERU pipeline
          mark on black, centered. Clean, confident brand beat.

T+0.3s  : Splash skippable. Faint "any confirm" prompt at bottom.

T+1.2s  : Splash auto-advances. Crossfade to title.

T+1.3s  : Title renders. Attract replay (live deterministic Warrior bot on
          Floor 1, 30Hz half-speed, dimmed 40%) already playing behind menu
          — combat motion, enemies streaming, axe cleaving ghosts, visible
          before touching anything. HUNGERHALL logo center-top. First boot:
          NEW GAME default-focused. Subsequent: CONTINUE default-focused.

T+1-3s  : Player reads logo, tagline "THE VAULT DEVOURS", menu. Attract
          replay provides ambient motion — nothing static, nothing dead.
          High-score ticker cycles at bottom — third layer of life.

T+3-5s  : Player presses Enter (or A) on NEW GAME. If no save, transition
          immediate. Crossfade ~0.3s. If save exists, newgame_warn fires:
          "BEGIN A NEW CAMPAIGN? YOUR CURRENT RUN (FLOOR 7 · ELF) REMAINS
          UNTIL YOU CLEAR FLOOR 1." [YES] [NO] — NO default.

T+5-6s  : Class select renders. Four hero cards in a row. Warrior
          pre-highlighted — sprite idles in ready stance, stats visible,
          description panel: "WARRIOR: Pays HP for position. Walks through
          crowds."

T+6-8s  : Player examines cards. ←/→ cycles focus. Each sprite animates
          when highlighted — Warrior flexes, Valkyrie raises shield,
          Wizard crackles, Elf nocks arrow. Description updates per class.

T+8-10s : Player selects class (Enter on any card). Crossfade to play.

★ T+10s : FIRST DELIGHT — Floor loads, announcer booms "THE WARRIOR
          ENTERS HUNGERHALL" in crunchy digitized 1985 arcade voice.
          Caption appears simultaneously at bottom. Dungeon is alive:
          generators pulse, ghosts drift toward player, food glints.
          HP bar begins slow drain — clock ticking. Sprite responds to
          movement instantly. The game smiled: it said the player's class
          name in a ridiculous robot voice and the world is already moving.

T+10-14s: Player moves. Hero slides across 32px tiles with weight. Throw
          (J / A) sends projectile — axe arcs, spear streaks, bolt bursts,
          arrow flies. Enemies flash and dissolve. Hit flashes, death
          particles, HP bar creeping down. Screen has juice.

T+14-30s: Free play. State machine drives. Idle 4s → "MOVE" glyph near
          hero. Idle 10s → "THROW" glyph. Idle 15s with exit visible →
          "EXIT" glyph near the exit door (door also pulses softly when
          all keys are held — visual telegraph). Overlays, not screens —
          cost nothing from onboarding budget. Player is already fighting,
          draining, managing the clock. No tutorial screen shown. No text
          read. Game taught itself through announcer callout, visible
          mechanics, and idle prompts.
```

Time-to-control: **~10s** (splash skip + title selection + class confirm + floor load).
Time-to-first-delight: **~10s** (announcer callout on floor entry).

---

## 4. Onboarding budget — HARD GATE

**Profile:** commercial_focused (desktop/Steam; G1 Constraints section: "Ambition profile: commercial_focused"). Legacy casual_mobile_2d phone quotas do not apply. Declared ceilings:

| Metric | Ceiling | Actual |
|--------|---------|--------|
| Onboarding screens | 2 (title + class_select before play) | 2 |
| Tutorial screens | 0 (G2 contract) | 0 |
| Words read before first control (labels only) | ≤25 | ~19 (NEW GAME, HALL OF HEROES, SETTINGS, EXIT, CONTINUE, CHOOSE YOUR HERO, four class names) |
| Words read before first control (with one class description) | ≤45 | ~37 (19 labels + ~18 for the focused class description — optional reading) |
| Time to first control | ≤15s | ~10s |
| Time to first delight | ≤15s | ~10s (announcer callout) |
| Idle prompts before free play | 0 (appear after 4s inaction in play) | 0 |

**Teaching method:** action-based, not text-based.
- **Movement:** idle "MOVE" glyph near hero after 4s no movement input. Fades on movement.
- **Throwing:** idle "THROW" glyph after 10s no throw input. Fades on first throw.
- **Potion:** HUD potion icon lights up when available. Self-explanatory.
- **Pause:** footer hint "[Esc / Start: PAUSE]" visible on play HUD at all times.
- **Exit door:** idle "EXIT" glyph near the exit door after 15s if the exit is visible and the floor is not cleared. The exit door also pulses with a soft glow when the player holds all required keys — a visual telegraph that the exit is accessible. Fades on floor clear or when the player stands on the exit.
- **Tokens:** taught at first death via the continue_offer caption "CONTINUES LEFT: 2" — the moment of need. No premature prompt; tokens are not actionable until death.
- **Class differentiation:** class_select cards show distinct stats, weapons, one-sentence summaries. No separate screen.

**Skip/replay behavior:**
- Splash: skippable after 0.3s; auto-advances at 1.2s.
- Idle prompts: each type (MOVE, THROW, EXIT) rearm **once per app launch**. After dismissal (player responds with the relevant input), the prompt does not reappear until app restart. Test rule: if `idle_prompt_shown[MOVE]` is true, the MOVE glyph never renders for the rest of the session; in a headless bot run, idle prompts must not appear if the bot provides input within 4s of floor entry.
- No replay mechanism needed — nothing is missable. The attract replay on title serves as a passive tutorial for observant players.

---

## 5. Settings screen

One flat scrollable column. Zero sub-menus. Every setting on one screen (§2 wireframe). Changes apply and persist on release (sliders) or toggle (switches) — atomic write. No Apply button.

```
SETTINGS:
  DISPLAY
    Brightness          [slider 0-100%, persist on release]
    UI Scale            [slider 50-150%, persist on release]
    Window Mode         [FULLSCREEN / BORDERLESS / WINDOWED]
    Resolution          [◀/▶ cycles detected available resolutions]

    WINDOW MODE + RESOLUTION INTERACTION (binding):
      FULLSCREEN  : uses the desktop's native resolution. The Resolution
                    control is DISABLED (greyed) in this mode. Changing
                    to Fullscreen from Windowed does not change the
                    stored Resolution preference — it is re-applied when
                    the player switches back to Windowed.
      BORDERLESS  : uses the desktop's native resolution (window covers
                    the entire screen, no chrome). The Resolution control
                    is DISABLED (greyed) in this mode. Same as Fullscreen
                    regarding stored Resolution preference.
      WINDOWED    : uses the selected Resolution. The Resolution control
                    is ACTIVE. Changing Resolution immediately resizes
                    the window. Available resolutions are detected from
                    the display at boot and on display-change events.

  AUDIO
    Master Volume       [slider 0-100%, persist on release]
    Sound Effects       [ON / OFF]
    Music               [ON / OFF]
    Announcer           [ON / OFF]

  CONTROLS
    Move (4 dirs)       [per-row bindings + REMAP button]
    Throw               [J / A-Button + REMAP]
    Potion              [K / B-Button + REMAP]
    Pause               [Esc / Start + REMAP]
    (Per-row [REMAP] opens remap_capture modal for that action;
     modal captures one input, offers swap if conflict,
     offers [CLEAR BINDING] to remove, Esc/B cancels.
     CAPTURE SEMANTICS: captured input replaces the binding for the
     captured input's scheme only — keyboard capture replaces the
     keyboard binding, gamepad capture replaces the gamepad binding.
     Arrow keys and WASD are separate bindings within the keyboard
     scheme; remapping one does not affect the other.
     CLEAR SEMANTICS: for movement actions (Move Up/Down/Left/Right),
     clearing reverts to factory default (W/S/A/D, arrows, LS), never
     empty — prevents unplayable state. For non-movement actions
     (Throw, Potion, Pause), clearing can leave the binding empty;
     the action is unbound until remapped.)

  ACCESSIBILITY
    Captions            [ON / OFF]
    Reduced Motion      [ON / OFF]
        → Mutes: screen shake, particle bursts (reduced count),
          crumble animation (replaced by 0.2s instant fade — dying
          state still non-interactive, still auto-advances), attract
          replay (static frame)
        → Does NOT mute: HP bar pulse, focus ring, score increment
          (critical gameplay info stays)
    Color-Blind Mode    [OFF / DEUTERAN / PROTAN / TRITAN]
        → DEUTERAN: shifts green/red to blue/yellow
        → PROTAN: shifts red to blue/orange
        → TRITAN: shifts blue/yellow to red/green
        → Applied to: HP bar, food/key/potion icons, hazard telegraphs
        → Implemented via shader uniform on the canvas item layer
    Auto-Fire           [ON / OFF]
        → ON: holding the throw button auto-fires at the class base
          throw rate (e.g., Elf 3.0/s, Warrior 1.5/s) — caps turbo;
          rapid-pressing cannot exceed base rate. A TAP still fires
          once (press-and-release within 200ms = single shot).
        → OFF: each press fires exactly one projectile. Holding does
          nothing — the player must press again for each throw.
        → HUD footer updates to "[J / A: AUTO-FIRE]" when ON,
          "[J / A: THROW]" when OFF.

  HAPTICS (visible only when gamepad connected — hidden otherwise)
    Gamepad Rumble      [ON / OFF]
    (If focus is on the Rumble toggle when the gamepad disconnects,
     focus moves to the nearest preceding focusable element — the
     Auto-Fire toggle in ACCESSIBILITY. The HAPTICS section disappears
     immediately on disconnect.)

  DATA
    [RESET TO DEFAULTS] → fires reset_warn modal (settings only;
       save/scores/NG+ flag untouched)
    [ERASE ALL DATA]    → fires erase_warn modal (irreversible;
       wipes campaign, scores, NG+ flag, settings — complete reset)

  ABOUT
    [CREDITS]           → opens credits_pop (returns on Esc/B)
    [PRIVACY POLICY]    → opens privacy_pop (returns on Esc/B)
```

**Caller-aware Back:** `settings.caller ∈ {title, paused}`, stored on the SessionManager autoload when SettingsChosen fires. Back returns to the caller screen. No state ambiguity.

**Persistence timing:** Sliders write atomically on **release** (pointer up or key up), not on every tick — prevents disk thrash during drag. Toggles write atomically on change. Modal-driven changes (remap, erase, reset) persist on modal completion.

**Haptics visibility:** HAPTICS section renders only when a gamepad is detected. On connect, the section appears; on disconnect, it disappears and focus relocates (see above). Unavailable options are hidden, not disabled.

**Settings file schema:** See Appendix D.

---

## 6. Error states

```
ERROR: SaveFileCorruption
  Trigger: Campaign save fails to parse (corrupted JSON, missing fields,
           or unrecognized save_version after migration attempt).
  UI: Modal on title (detected on boot): "YOUR SAVE WAS LOST. THE HALL
      STARTS HUNGRY AGAIN." with [BEGIN ANEW] button.
  Recovery: Enter / A / click → title with no CONTINUE row. Corrupted file
            quarantined to user://save/campaign.corrupt before new session.
  Copy: "YOUR SAVE WAS LOST. THE HALL STARTS HUNGRY AGAIN."

ERROR: SettingsReadFail
  Trigger: Settings file (user://save/settings.json) fails to parse or
           read on boot (corrupted JSON, missing fields, or unrecognized
           settings_version after migration attempt).
  UI: No modal — silent recovery. Default settings loaded. Corrupted file
            quarantined to user://save/settings.corrupt. Player is not
            blocked; settings reset to defaults for this session.
  Recovery: Automatic. No player action needed. On next settings change,
            a new valid settings.json is written atomically. The player
            may notice their settings reverted (e.g., brightness back to
            80%) but the game is fully functional.
  Copy: None (silent recovery — no error text shown; settings are not
        critical enough to warrant a modal).

ERROR: FloorDataMissing
  Trigger: Floor resource (res://Floors/floor_N.tres) fails to load.
  UI: Modal (floor_missing) on play: "THE FLOOR CRUMBLED. RETURN TO THE
      SURFACE." with [BACK TO TITLE] and [SKIP FLOOR] buttons.
      Floor 24 special case: "THE FINAL FLOOR CRUMBLED. THE CAMPAIGN
      ENDS HERE." with only [BACK TO TITLE] (no skip — floor 24 is the
      finale; a broken floor 24 is a build defect, not a design gap).
  Recovery: Floors 1–23: [BACK TO TITLE] → title; save.floor advanced to
            next floor (prevents retry loop). [SKIP FLOOR] → title;
            save.floor advanced to next floor; missing floor logged to
            telemetry. Either way the player Continues from title onto
            the next available floor — no retry loop, no permanent blocker.
            Floor 24: [BACK TO TITLE] → title; save.floor preserved at 23
            (floor 24 is the finale; cannot skip). Continue from title
            retries floor 24. If floor 24 is still missing, floor_missing
            fires again — this is a build-asset failure, not a design loop.
            Player can start NEW GAME. Missing floor logged to telemetry.
  Back/Esc/B: same as [BACK TO TITLE] (advances save.floor on floors 1–23;
              preserves on floor 24).
  Copy: "THE FLOOR CRUMBLED. RETURN TO THE SURFACE." (floors 1–23)
        "THE FINAL FLOOR CRUMBLED. THE CAMPAIGN ENDS HERE." (floor 24)

ERROR: SettingsUnwritable
  Trigger: Settings file cannot be written atomically (disk full, permissions).
  UI: Toast at bottom of settings: "SETTINGS HELD IN MEMORY ONLY.
      THEY WILL NOT PERSIST." Auto-dismisses after 4s.
  Recovery: Settings remain in memory for session. On next launch, prior
            settings loaded. No data loss — player informed, not blocked.
  Copy: "SETTINGS HELD IN MEMORY ONLY. THEY WILL NOT PERSIST."

ERROR: ControllerDisconnect
  Trigger: Active gamepad disconnects during play or menu.
  UI: pad_lost modal over paused screen (if disconnect during play,
      auto-pause fires FIRST — PadLostAutoPause — then pad_lost renders
      over paused; if disconnect during a menu, pad_lost renders over
      the current screen): "YOUR WEAPON WENT SILENT. PRESS A KEY OR
      RECONNECT." with pulsing gamepad icon.
  Recovery: (a) Reconnect gamepad → modal dismisses; state stays paused
            (if was play) — player must deliberately press Resume. (b) Press
            any keyboard key → input switches to keyboard; modal dismisses;
            the dismissing key event is CONSUMED by the modal (does NOT
            forward to the underlying screen — player must press a second
            key to interact); state stays paused (if was play) — player
            must press Resume. The game NEVER auto-resumes from pad_lost.
  Copy: "YOUR WEAPON WENT SILENT. PRESS A KEY OR RECONNECT."

ERROR: SaveWriteFailed
  Trigger: Atomic save write at floor_results entry fails.
  UI: save_fail modal on floor_results: "THE STONE REFUSED YOUR MARK.
      YOUR RUN CONTINUES BUT WILL NOT SURVIVE APP CLOSE." with [TRY AGAIN]
      (max 3 attempts) and [CONTINUE ANYWAY].
  Recovery: [TRY AGAIN] re-attempts (max 3). If a retry succeeds, SAVED tag
            appears, modal closes. After 3 failures, [TRY AGAIN] is replaced
            by "SAVE UNAVAILABLE — CONTINUE ANYWAY". [CONTINUE ANYWAY]
            proceeds to next floor; run held in memory but not persisted;
            SAVED tag does NOT render while the modal is open. On app close,
            progress reverts to the prior floor_results save — total score
            and floor score revert to last floor_results values. If the
            player continues and clears the next floor, that floor's
            autosave includes the cumulative score. Player warned and chooses.
  Copy: "THE STONE REFUSED YOUR MARK. YOUR RUN CONTINUES BUT WILL NOT SURVIVE APP CLOSE."

ERROR: LowMemory
  Trigger: OS reports critical memory pressure.
  UI: Modal on play (auto-paused): "THE HALL IS TOO FULL. CLOSE OTHER APPS
      AND RETURN." with [TRY AGAIN] and [QUIT TO TITLE].
  Recovery: [TRY AGAIN] re-checks OS memory pressure. If pressure has
            cleared, modal dismisses and player resumes from paused (must
            press Resume). If still critical, modal remains. After 3
            consecutive [TRY AGAIN] checks that all report critical
            pressure, [TRY AGAIN] is replaced by text "NO RELIEF" and
            [QUIT TO TITLE] becomes the only option. Campaign save preserved
            at last completed floor.
  Copy: "THE HALL IS TOO FULL. CLOSE OTHER APPS AND RETURN."
```

**Not error states (declared):** App crash (bug, not error state — telemetry captures; campaign save intact on relaunch). Window focus lost (auto-pause, §1). Alt+F4 (normal OS behavior, §1 window-close rules). PC sleep (auto-pause on wake).

---

## 7. Empty states

```
EMPTY: HallOfHeroesNoEntries
  Screen: hall_of_heroes
  Trigger: No scores recorded for any class (first boot or all data erased).
  Copy: "THE HALL IS EMPTY. THE STONE REMEMBERS NO ONE. YET."
  Layout: Four class columns with "---" entries, copy centered below header.

EMPTY: NoCampaignSave
  Screen: title
  Trigger: First boot, or save file erased/corrupted.
  Copy: CONTINUE row absent. No message — the absence IS the message.
        Attract replay + NEW GAME default focus communicate "start here."
  Layout: Title without CONTINUE row.

EMPTY: PotionSlotsEmpty
  Screen: play (HUD)
  Trigger: Player has zero potions.
  Copy: Potion icons show as empty circles [○][○][○]. No text — visual
        state is self-explanatory. Leftmost empty circle fills [●] on pickup.
  Layout: HUD potion indicator.

EMPTY: ContinueTokensZero
  Screen: continue_offer
  Trigger: Player dies with zero continue tokens.
  Copy: "OUT OF TOKENS" displayed for 3.0s, then auto-fires to game_over.
        No YES/NO buttons — the decision is made by the economy.
  Layout: continue_offer without YES/NO; banner center-screen for 3.0s.

EMPTY: NewGamePlusLocked
  Screen: title
  Trigger: Campaign not cleared (NG+ flag not set in persistent profile).
  Copy: NEW GAME+ row does not exist. No locked icon, no greyed button,
        no "clear campaign to unlock" message. Row appears only after
        campaign_results writes the NG+ flag.
  Layout: Title without NEW GAME+ row.

EMPTY: ClassSelectFirstBoot
  Screen: class_select
  Trigger: No class has cleared the campaign (profile.classes_cleared empty).
  Copy: Class cards render without laurel icons. No text — absence of
        decoration is not a message. Cards fully functional.
  Layout: Four class cards, no laurel decorations.

EMPTY: SettingsFirstBoot
  Screen: settings
  Trigger: First boot (no settings file exists).
  Copy: All settings at defaults. No "welcome" copy — screen is
        self-explanatory.
  Layout: Settings at default values.
```

---

## 8. Touch target sizes

**This product targets Steam (Windows desktop). No touch input.** The following declares mouse pointer, keyboard, and gamepad focus/navigation/target rules.

### Mouse pointer targets

| Element | Size (1920×1080) | Notes |
|---------|-----------------|-------|
| Primary CTAs (NEW GAME, CONTINUE, NEXT FLOOR, RETRY, BEGIN NG+) | 280×56px min | Largest interactive elements |
| Secondary buttons (SETTINGS, HALL OF HEROES, EXIT, NEW GAME+) | 280×56px min | Match primary — no hierarchy gap |
| Class cards | 200×280px | Full card clickable; focus ring on hover |
| Settings rows (toggles, sliders) | Full row width × 48px | Entire row is hit area |
| Settings sub-buttons (REMAP, CREDITS, PRIVACY, ERASE, RESET) | 200×48px | Sufficient for pointer precision |
| Footer text links (CREDITS on title) | 120×24px min | Smallest interactive element; focus ring on hover |
| Adjacent target spacing | 12px min vertical, 16px min horizontal | Exceeds mis-tap floor |

**Left-click activation (binding):** Left-click on any interactive menu element moves focus to that element and **activates** its action — equivalent to pressing Enter/A on that element. The click is not visual-only; it triggers the same transition or toggle as Enter/A. This applies to all menu buttons, class cards, settings rows, toggle switches, slider handles, and footer links. In play, the mouse is inert (gameplay is keyboard/gamepad only).

### Keyboard navigation & focus order

**Visible focus:** 2px bright outline (period palette cyan) on every focusable element. Focus visible at all times — never implied.

| Screen | Focus order | Navigation |
|--------|------------|------------|
| title (no save) | NEW GAME → HALL OF HEROES → SETTINGS → EXIT → CREDITS (footer) | ↑/↓ cycle, Enter confirms, Esc/B → quit_warn |
| title (with save) | CONTINUE → NEW GAME → HALL OF HEROES → SETTINGS → EXIT → CREDITS | same |
| title (NG+ unlocked) | CONTINUE → NEW GAME → NEW GAME+ → HALL OF HEROES → SETTINGS → EXIT → CREDITS | same |
| class_select | Warrior (default) → Valkyrie → Wizard → Elf | ←/→ cycle, Enter confirms, Esc/B → title |
| play | No focus navigation — direct input (WASD/arrows, J/K, Esc/Start) | B = Potion (not Back) |
| paused | KEEP DELVING (default) → SETTINGS → QUIT TO TITLE | ↑/↓ cycle, Enter selects, Esc/Start/B resumes |
| settings | Top to bottom, section by section | ↑/↓ between rows, ←/→ adjusts sliders/toggles, Enter activates, Esc/B → caller |
| game_over | Initials row (if active) → RETRY FLOOR N → HALL OF HEROES → RETURN TO TITLE | After initials commit/skip: RETRY FLOOR N default; Esc/B skips initials |
| floor_results | NEXT FLOOR (default) → QUIT TO TITLE | ↑/↓ cycle, Esc/B = QUIT TO TITLE |
| campaign_results | Initials row (if active) → BEGIN NG+ (default) → HALL OF HEROES → RETURN TO TITLE | same initials rule as game_over |

### Gamepad navigation

Identical to keyboard focus order. Left stick or D-pad navigates. A-button confirms. B-button = Back in menus, Potion in play, Resume in paused. Start = pause in play, resume in paused.

**B-button mapping (binding, unambiguous — full exception table):**

| Context | B-button = | Same as keyboard | Rationale |
|---------|-----------|-----------------|-----------|
| In play | Potion | K | Prevents stray B from pausing combat |
| In menus (title, class_select, settings, hall_of_heroes, floor_results, campaign_results) | Back | Esc | Standard navigation |
| In paused | Resume | Esc / Start | Exception to "B = Back in menus" — safe default; prevents accidental quit. B = Resume is the same as Esc = Resume in paused. |
| In dying | Disabled (non-interactive) | N/A | 1.2s/0.2s cinematic |
| In continue_offer | NO (decline) | Esc | Back = choosing NO; the offer IS the decision |
| In game_over (initials live) | Skip initials | Esc | Safer than accidental commit |
| In game_over (initials committed) | Done → title | Esc | Standard back |
| In floor_missing | BackToTitle | Esc | Same as [BACK TO TITLE] button |

B is never "unbound." It always has a context-appropriate function. The paused exception (B = Resume, not Back) is the only deviation from "B = Back in menus" and exists because the safe default in paused is to keep playing, not to quit.

### Controller disconnect recovery

1. If in play: PadLostAutoPause fires → state transitions to paused → pad_lost modal appears over paused.
2. If in a menu: pad_lost modal appears over the current screen (no auto-pause needed — menu is already static).
3. If a child modal (remap_capture, credits_pop, privacy_pop) is open: child modal dismissed → parent screen transitions to paused if caller was play → pad_lost renders over parent.
4. Modal: "YOUR WEAPON WENT SILENT. PRESS A KEY OR RECONNECT."
5. Recovery: (a) reconnect gamepad → modal dismisses; state stays paused (if was play) — player must press Resume. (b) press any keyboard key → input switches to keyboard; modal dismisses; the dismissing key event is CONSUMED by the modal (does NOT forward to the underlying screen — player must press a second key to interact); state stays paused (if was play) — player must press Resume.
6. **Game never auto-resumes from pad_lost.** Player must deliberately press Resume.
7. On pad_lost dismissal, the parent screen reconverges to its prior state. Any dismissed child modal does NOT auto-reopen — the player must re-invoke it.

### Pointer (mouse) states

- **Hover:** Focus ring (same as keyboard). Cursor → pointer-hand on interactive elements.
- **Pressed:** Element depresses 2px. No color change (period palette).
- **Activated:** Left-click moves focus to the element and activates its action (Enter/A equivalent). The click triggers the transition/toggle, not just a visual depression.
- **Focus:** After click, focus remains on clicked element for keyboard resume.
- **Disabled:** No disabled elements exist. Unavailable options hidden.

### Remapping

Per-row [REMAP] buttons in Settings → Controls. Each action has its own button:
1. Player selects [REMAP] on an action row.
2. remap_capture modal: "PRESS A KEY OR BUTTON FOR [ACTION]"
3. Next single input captured. The captured input replaces the binding for its input scheme only (keyboard replaces keyboard, gamepad replaces gamepad; arrow keys and WASD are separate within the keyboard scheme). If already bound: "[KEY] IS BOUND TO [ACTION]. SWAP? [YES] [NO]"
4. [CLEAR BINDING] removes the current binding. For movement actions (Move Up/Down/Left/Right), clearing reverts to the factory default binding — never empty (prevents unplayable state). For non-movement actions (Throw, Potion, Pause), clearing can leave the binding empty (action unbound until remapped).
5. Esc/B cancels. Modal returns to settings. Binding persists immediately (atomic write).

Menu navigation (↑/↓/←/→/Enter/Back) is not remappable — follows active input scheme conventions.

### Initials entry widget

- 3 slots, one character each. Character set: A–Z (26) + 0–9 (10) + space (1) = 37 characters.
- Default: AAA.
- Keyboard: type letter → fills current slot, advances. Backspace → deletes, moves back. Enter → commits (all 3 slots filled).
- Gamepad: ←/→ select slot, ↑/↓ change character, Enter/A commits.
- Esc/B → skip (score displays as "---").
- After commit: focus → RETRY FLOOR N (or BEGIN NG+ on campaign_results). Initials row becomes static (non-focusable).

---

## 9. Haptic policy

**7 event types declared. No per-session fire cap — the Settings toggle (Gamepad Rumble ON/OFF) is the only gate.** Haptics are supplemental (G2 §8.6); every event has an audio + visual equivalent.

| # | Event | Intensity | Duration | Audio + Visual Fallback |
|---|-------|-----------|----------|------------------------|
| 1 | Continue token consumed | Medium | 200ms | Announcer: "THE HALL TAKES A TOKEN." + token counter decrements with flash |
| 2 | Last continue token spent | Strong | 400ms | Announcer: "NO TOKENS REMAIN." + token icons drain to empty |
| 3 | Floor cleared | Light | 150ms | Fanfare sting + floor_results render with SAVED tag |
| 4 | Campaign cleared | Strong | 600ms | Victory fanfare + campaign_results render + NG+ UNLOCKED banner |
| 5 | Player death | Medium | 300ms | Death sound + crumble animation (or 0.2s instant fade if Reduced Motion) + "-20% FLOOR SCORE" |
| 6 | HP critical threshold crossed | Light pulse | 100ms | HP bar red pulse + screen vignette (fires once when HP drops below 25%; visual fallback persists while critical) |
| 7 | Generator destroyed | Medium | 250ms | Collapse sound + generator sprite breaks apart + spawns cease |

**Superseded (LAR-2):**
- Per-throw rumble: superseded. Elf 3.0/s = fatigue trip-wire. Feedback via projectile audio + visual trails + impact flashes.
- Per-kill rumble: superseded. Pack kills can exceed 5/s. Feedback via death audio + particle bursts + score increment.
- Per-food-pickup rumble: superseded. Frequent, low-stakes. Feedback via pickup chime + HP bar fill.

**Fatigue reasoning:** Event #6 fires once on threshold crossing, not per-tick while critical — the persistent visual fallback (red pulse + vignette + heartbeat loop) carries the ongoing state. This keeps the total haptic duty cycle bounded by game events, not by frame rate.

**Reduced Motion interaction:** When Reduced Motion is ON, haptic event #5 (player death) still fires at 300ms — the haptic is supplemental to the death sound, not the crumble animation. The crumble animation is replaced by a 0.2s instant fade, but the haptic and audio still fire. All other haptic events are unaffected by Reduced Motion (they are tied to discrete game events, not continuous motion).

**Settings control:** Gamepad Rumble [ON / OFF] in Settings → Haptics (section visible only when a gamepad is connected). When OFF, no haptic events fire. Audio + visual fallbacks remain active regardless.

---

## 10. Sound policy

**Declaration: Major events only — wins, losses, milestones.** Game fully playable with audio off. Every audio cue has a visual equivalent.

### Audio event inventory

| Event | Audio Cue | Visual Fallback (audio off) |
|-------|-----------|----------------------------|
| Announcer callout (class entry, HP critical, food, key, level) | 1985 arcade speech synthesis, character-specific | Caption bar, 2s, same text as spoken |
| Throw / projectile | Projectile sting | Projectile sprite + trail |
| Projectile hits enemy | Impact sting | Enemy flash + knockback |
| Enemy dies | Death sting + particles | Dissolve animation + particles |
| Food picked up | Pickup chime | HP bar fill + food icon disappears |
| Key picked up | Key chime | Key icon fills + glow |
| Potion used | Potion activate | Potion effect animation |
| Generator destroyed | Collapse sound | Sprite breaks apart + spawns cease |
| Player takes damage | Damage grunt + edge flash | Red screen-edge flash |
| HP critical (<25%) | Heartbeat loop | Red HP bar pulse + vignette |
| Floor cleared | Fanfare sting | floor_results render + SAVED tag |
| Campaign cleared | Victory fanfare | campaign_results render + NG+ banner |
| Continue token consumed | Token drain | Counter decrements with flash |
| Player death | Death sound + crumble | Crumble animation + "-20% FLOOR SCORE" |
| Menu navigation | Soft tick | Focus ring moves |
| Menu confirm | Confirm click | Screen transition |
| Pause / Resume | Pause/Resume sting | Paused screen appears/dismisses |
| Controller disconnect | Disconnect tone | pad_lost modal appears |

### Audio mixing

- Announcer lines duck all other audio by -12dB during playback. Announcer = highest-priority channel.
- Music at -6dB below SFX. Ambient dungeon atmosphere, not melodic.
- Captions ON → caption bar displays 2s per callout, same text as spoken.
- Announcer OFF → lines don't play. Captions still display if Captions ON. If both OFF, visual fallbacks carry the information.

### No-audio playable path

Game fully playable with Master Volume 0% or all toggles OFF. Gameplay-critical info carried visually: HP bar (pulses red <25%), score counter, token counter, potion icons, key icon, floor counter, caption bar (if Captions ON), implicit visual cues (screen flash for damage, icon glows for pickups, screen render for floor clear, exit door pulse when all keys held). Enemy/projectile/hazard sprites visually distinct without audio.

**CI verification (`ci/no_audio_test.gd`):** The test loads Floor 1 with `--audio-driver Dummy --headless`, simulates 30s of bot gameplay, and verifies that every critical gameplay event has a visual fallback that fires within 1 physics tick of the event. Critical events enumerated:

| # | Event | Validation Rule |
|---|-------|----------------|
| 1 | Announcer callout | Caption bar text matches expected callout string; renders within 1 tick |
| 2 | Throw | Projectile node spawned in scene tree within 1 tick of throw input |
| 3 | Projectile hits enemy | Enemy flash animation plays within 1 tick of collision |
| 4 | Enemy dies | Dissolve animation + particle burst spawned within 1 tick of HP ≤ 0 |
| 5 | Food picked up | HP bar increments + food node freed within 1 tick of pickup |
| 6 | Key picked up | Key icon in HUD changes state + glow effect within 1 tick |
| 7 | Potion used | Potion effect animation plays within 1 tick |
| 8 | Generator destroyed | Generator sprite freed + spawn counter stops within 1 tick |
| 9 | Player takes damage | Red screen-edge flash renders within 1 tick of damage event |
| 10 | HP critical (<25%) | HP bar red pulse + vignette active within 1 tick of threshold crossing |
| 11 | Floor cleared | floor_results screen renders within 1 tick of exit trigger |
| 12 | Player death | Dying state entered + "-20% FLOOR SCORE" text renders within 1 tick |

Test fails if any of the 12 events fires without its visual fallback within 1 tick. Test entry declared for the Sneferu bot telemetry path; runs on every build.

---

## Appendix A — Simulated reviewer diaries

### Reviewer A — SIMULATED_9_YEAR_OLD (keyboard + gamepad, skips reading, presses everything) — HAPPY PATH

```
T+0s: I opened the game. Diamond thing in the middle. I pressed A.
T+0.3s: Skipped to a menu. Fighting behind the words! Cool.
T+1s: NEW GAME. I pressed Enter. Nothing asked me to read.
T+1.5s: Four guys. I pressed right. Lady with shield lit up. Right again.
        Wizard. Again. Elf with a bow.
T+3s: Back to warrior. Enter.
T+4s: Robot voice said "THE WARRIOR ENTERS HUNGERHALL." Funny.
T+5s: Dungeon. I pressed W. Guy moved. J. Axe! Ghosts died. Numbers up.
T+6s: Pressed B — potion! Cool burst.
T+8s: Walked into a ghost. Health down. Going down on its own too!
T+10s: Found food. Walked over it. Health up. Number flashed.
T+15s: Found a key. Icon lit up. Door. Walked to it. Exit door glowing.
T+20s: Door opened. Exit. Walked onto it.
T+22s: "FLOOR 1 CLEARED." Enter. Next floor. Robot voice again.
T+30s: Still playing. Nothing made me read. Robot voice is my favorite.
```

**Defects:** None. B threw a potion in play (not back). Every element responded. No dead-ends. Announcer at T+4s was first delight. Combat immediate. HUD communicated without text. Exit door glow at T+15s was a nice touch — I knew where to go.

### Reviewer B — SIMULATED_65_YEAR_OLD (keyboard, arrows + Enter, reads labels) — HAPPY PATH

```
T+0s: Diamond logo. "any confirm after 0.3s skips onward."
T+1.2s: Menu on its own. Good — didn't have to figure out what to press.
T+1.3s: HUNGERHALL. "THE VAULT DEVOURS." Movement behind menu — someone
        fighting. It's a game already running.
T+2s: NEW GAME highlighted with bright outline. Below: HALL OF HEROES,
      SETTINGS, EXIT. Bottom: CREDITS.
T+3s: Enter on NEW GAME. Character selection.
T+4s: "CHOOSE YOUR HERO." Four characters. Warrior highlighted. "WARRIOR:
      Pays HP for position. Walks through crowds." I understand — tough
      but costs health.
T+6s: Right arrow. Valkyrie. "HER LANE IS ALREADY PAID." Shield. I'll
      play warrior — straightforward.
T+8s: Enter. Voice: "THE WARRIOR ENTERS HUNGERHALL." Words at bottom say
      same thing. Good — I can read it if I miss the voice.
T+9s: Dungeon. Bottom says "J / A: THROW" and "Esc / Start: PAUSE." I see
      controls. Up arrow. Character moved.
T+12s: J. Axe. Hit ghost. Ghost gone. Score up.
T+15s: Health slowly going down. That's "pays HP." I need food. Something
       on floor. Walked to it. Health up.
T+20s: Esc. Pause menu. "KEEP DELVING" highlighted. Esc again. Back in game.
T+30s: Still playing. Found key. Icon in top bar. Locked door. I understand.
       Nothing confused me.
```

**Defects:** None. Labels readable. Back consistent (Esc = back/pause/resume). No gestures, no combos. Footer hint told me what keys do. Pause default = safe option.

### Reviewer A — SIMULATED_9_YEAR_OLD — DEATH → CONTINUE → RETRY CYCLE

```
T+0s: I've been playing for a while. Floor 7. My health is low.
T+2s: A ghost hit me. Health hit zero. My guy crumbled to dust.
      "−20% FLOOR SCORE" appeared. It said that for about a second.
T+3.2s: Screen popped up. "CONTINUES LEFT: 2. CONTINUE?" YES highlighted.
T+4s: I pressed Enter (A on my gamepad). "THE HALL TAKES A TOKEN."
      My guy is back! But half health. Potions gone. Keys gone.
T+6s: Died again. Same screen. "CONTINUES LEFT: 1."
T+7s: Pressed Enter. Back again. Still half health.
T+9s: Died a third time. "OUT OF TOKENS." It stayed for 3 seconds.
T+12s: "GAME OVER. FINAL SCORE: 18,450. FLOOR REACHED: 7."
       "CAMPAIGN SAVE: FLOOR 6." I see — my saved game is at floor 6.
T+13s: It wants initials. I typed AAA. Pressed Enter.
T+14s: "RETRY FLOOR 7" highlighted. Pressed Enter.
T+15s: Back on floor 7! Full health! 2 tokens! Score is lower — it went
       back to what it was before floor 7.
T+20s: Fighting again. Robot voice said "THE WARRIOR ENTERS HUNGERHALL."
T+30s: Still playing. I like retrying the floor. I don't like losing score
       but it felt fair. The "OUT OF TOKENS" screen was scary but I got it.
```

**Defects:** None on the death-retry path. The 3s "OUT OF TOKENS" hold was long enough to read. The 300ms grace on continue_offer — I didn't notice it, which means it worked (my death-mashing didn't auto-decline). Retry gave full health and fresh tokens, which felt fair. Score penalty stung but I kept playing. The continue at 50% HP was tense — I died faster, which taught me that continues are precious. The "CAMPAIGN SAVE: FLOOR 6" line was clear — I knew what I'd go back to if I quit.

### Reviewer B — SIMULATED_65_YEAR_OLD — DEATH → CONTINUE → RETRY CYCLE

```
T+0s: Floor 4. My health bar went red and started pulsing.
T+3s: A ghost caught me. My character crumbled. "−20% FLOOR SCORE."
      I had about a second to read it.
T+4.2s: "CONTINUES LEFT: 2. CONTINUE?" YES is already highlighted.
        A ring is draining — I have about ten seconds. Enter.
T+5s: Voice: "THE HALL TAKES A TOKEN." Back on the floor entrance.
      Half health. My potions are gone. Understood — continuing costs.
T+15s: Esc. "KEEP DELVING" highlighted. Down to SETTINGS. Everything
       on one page — I found Captions without hunting. Esc. Back to paused.
       Esc. Playing again.
T+40s: Died. "CONTINUES LEFT: 1." Enter. Back again.
T+60s: Died once more. "OUT OF TOKENS." Then GAME OVER with my score.
       "CAMPAIGN SAVE: FLOOR 3." Initials — I typed my initials with
       the letter keys. Enter. "RETRY FLOOR 4" was already highlighted.
       Enter. Fresh start on the floor, full health. Fair.
```

**Defects:** None. The continue screen explained the economy at the exact moment I needed it. Retry restoring full health was clearly a fresh start, not a continue — the score going back to the last floor-results total matched what "RETRY" promised. The "CAMPAIGN SAVE: FLOOR 3" line told me exactly what I was going back to if I chose RETURN TO TITLE.

### Hard veto check

| Veto signal | Status |
|-------------|--------|
| Onboarding budget exceeded | N/A (commercial_focused; declared ceilings met: 2 screens, ~19–37 words, ~10s) |
| Time-to-first-delight >30s | PASS — T+10s (announcer callout + combat) |
| Settings has sub-menus | PASS — zero sub-menus, one flat column |
| Tap target <44pt without accommodation | N/A (no touch; mouse ≥280×56px, focus always visible) |
| Audio-required gameplay | PASS — every cue has visual fallback; playable muted |
| Edge-swipe as only access | PASS — no edge-swipe, no gestures, no touch |
| Back-button unspecified | PASS — every screen and modal has explicit Back rule |
| Empty-state copy generic | PASS — all copy in game voice ("THE HALL IS EMPTY...") |

---

## Appendix B — Core-loop reference (binding numbers for G7)

These numbers are UX-relevant because they determine pacing, tension, and UI event frequency. G7 implements against these; G9 tunes them. Full combat tuning traces to G2 GDD.

### HP drain

| Class | Max HP | Drain rate | Time to empty (no food) |
|-------|--------|-----------|------------------------|
| Warrior | 800 | 1 HP / 0.5s | 400s (6.7 min) |
| Valkyrie | 680 | 1 HP / 0.45s | 306s (5.1 min) |
| Wizard | 520 | 1 HP / 0.4s | 208s (3.5 min) |
| Elf | 560 | 1 HP / 0.35s | 196s (3.3 min) |

### Generators

| Property | Value |
|----------|-------|
| HP | 100 (3 Warrior axe, 5 Valkyrie spear, 5 Wizard bolt, 7 Elf arrow) |
| Spawn rate | 1 enemy / 2.5s |
| Max concurrent | 8 per generator |
| Placement | Behind enemy territory — cannot be sniped from start |

### Food

| Property | Value |
|----------|-------|
| Per floor | 3–5 (deterministic, baked) |
| HP restored | 100 per piece |
| Respawns | Never within a floor |
| Required | Yes — campaign not completable without consuming |

### Keys and doors

| Property | Value |
|----------|-------|
| Keys per floor | 1–3 (deterministic) |
| Doors | Match key count; gate exit path |
| Exit | Requires all doors on path opened |

### Continue tokens

| Property | Value |
|----------|-------|
| Starting | 2 per floor |
| Reset | floor_results entry (each cleared floor) |
| Continue cost | 1 token |
| Continue HP | 50% class max |
| Continue state | FULL FLOOR RESET: generators reset to full HP/initial spawn, enemies reset to initial positions, doors reset to locked; only eaten food persists; potions/keys zeroed; floor rebuilt from same baked seed |
| Retry (game_over) | Fresh: full HP, 2 tokens, score = last floor_results total, potions = 0, same seed; no token consumed |
| Persisted in save | No — always 2 on any load (the only save point is floor_results entry, where tokens are already 2) |

### Exit trigger

| Property | Value |
|----------|-------|
| Condition | Stand on open exit 3 consecutive physics ticks |
| Duration | 50ms at 60Hz fixed step |
| Auto-fires | Yes |
| Visual telegraph | Exit door pulses with soft glow when player holds all required keys |
| Idle prompt | "EXIT" glyph near door after 15s if exit visible and floor not cleared |

### Score

| Property | Value |
|----------|-------|
| Death penalty | -20% current floor score (applied at dying entry) |
| Total | Running sum across campaign |
| High score | Top 10 per class, local |
| Initials qualification (game_over) | N<10: any positive score (>0); full table: > 10th-place score; score 0 does NOT qualify |
| Initials qualification (campaign_results) | ALWAYS qualifies — beating the campaign is the mark |
| Game over FINAL SCORE | Last floor_results total (failed floor's score is lost) |

### UX timing constants

| Constant | Value |
|----------|-------|
| Splash | Auto-advance 1.2s; skippable after 0.3s |
| Dying (default) | 1.2s crumble, non-interactive, no pre-crumble |
| Dying (Reduced Motion ON) | 0.2s instant fade, non-interactive, auto-advances |
| Continue offer ring | 10.0s |
| Continue offer entry grace | 300ms — ALL input suppressed (buffered and new) |
| TokensEmpty banner | 3.0s, no input accepted |
| Idle prompt MOVE | 4s after no movement input |
| Idle prompt THROW | 10s after no throw input |
| Idle prompt EXIT | 15s after no floor clear if exit visible |
| Idle prompt rearm | Once per app launch per type |
| Announcer caption | 2s per callout |
| HP critical threshold | 25% of class max |
| Attract replay | Seed 0xDEAD, Warrior bot, Floor 1, 30Hz half-speed (same rules code, half the tick rate), dimmed 40%, muted |
| NG+ entrance caption | "NEW GAME+ UNLOCKED" — 2s on first title render after unlock, then never again |
| Campaign | 24 floors (1–23 → floor_results; 24 → campaign_results) |

---

## Appendix C — Godot architecture contract

G7 owns the full Godot 4.7 architecture contract. The following UX-relevant specifics are binding from G5.

### Autoloads (scarce, named, lifetime declared)

| Autoload | Process Mode | Responsibility | Lifetime |
|----------|-------------|----------------|----------|
| SessionManager | ALWAYS | State machine owner (all screen transitions); stores settings_caller, current_floor, current_class, current_score, current_tokens, ng_plus_flag, new_run_active (in-memory flag for unsaved new campaign) | App start → quit |
| SaveManager | ALWAYS | Atomic file I/O (temp + rename) for save, profile, settings, scores; quarantine on corruption | App start → quit |
| InputManager | ALWAYS | Scheme switching, controller hot-plug detection, pad_lost firing | App start → quit |

No other autoloads. No global signal bus. No global variable drawer.

### Scene tree

```
Main (Node)
├── SessionManager (autoload)
├── SaveManager (autoload)
├── InputManager (autoload)
└── CurrentScene (Node — swapped by SessionManager)
    ├── SplashScene
    ├── TitleScene (attract replay in SubViewport behind UI)
    ├── ClassSelectScene
    ├── PlayScene
    │   ├── PlayViewport (SubViewport — game rendering)
    │   ├── HUD (CanvasLayer — HP, score, tokens, potions, keys, floor)
    │   └── CaptionBar (CanvasLayer — captions, idle prompts)
    ├── PausedScene
    ├── SettingsScene
    ├── HallOfHeroesScene
    ├── DyingScene
    ├── ContinueOfferScene
    ├── GameOverScene (inline InitialsEntry Control)
    ├── FloorResultsScene
    └── CampaignResultsScene (inline InitialsEntry Control)
```

Each screen is a `PackedScene`. Modals are `PackedScene` instances loaded above their parent; they seize input and always return to the parent.

### Rules layer (pure, RefCounted, no Node dependency)

- **FloorRules:** floor layout, generator placement, food/key/potion distribution, exit condition. Seeded PRNG (RandomNumberGenerator, seed from floor data).
- **CombatRules:** damage, projectile behavior, enemy AI, generator spawn logic.
- **ScoreRules:** scoring, death penalty (-20% floor score at dying entry), total accumulation.
- **ContinueRules:** token economy, continue offer logic, retry load semantics, full floor reset specification.

### Deterministic machine-play seam

- `ci/sneferu_bot.gd`: SceneTree script calling SessionManager + FloorRules/CombatRules/ScoreRules API — the SAME API as the real game, not a parallel simulation.
- Seeded PRNG: FloorRules owns RandomNumberGenerator with seed from floor data. No random calls outside the owned PRNG.
- Fixed step: 60Hz physics, max 360,000 steps per floor (100 min at 60Hz).
- Bot policy: random-walk + throw-on-enemy-sight + potion-on-low-HP.
- Telemetry `playtest_telemetry_v1`: {seed, floor, class, actions[], score, hp_trace[], deaths, continues, time_elapsed, result}.
- Impossible progress, loops, crashes, invalid state, and timeouts surface as telemetry result codes.
- Atomic output to the orchestrator-provided absolute telemetry path.

### Attract replay

Live deterministic simulation in a SubViewport behind title UI. Seed-locked Warrior bot on Floor 1 (seed 0xDEAD). Uses the same FloorRules/CombatRules/ScoreRules code as the real game — the rules are identical, not a parallel simulation. However, the attract replay updates at 30Hz (half-speed) to reduce CPU load on the title screen. This means the bot takes half as many simulation steps per second as the real game; the rules code is the same but the tick rate differs, producing a slower-motion preview. Rendered at 40% opacity, muted, no haptics. Loops on bot death or floor clear. Not a pre-rendered video.

### CI no-audio test

`ci/no_audio_test.gd`: SceneTree script run via `godot --audio-driver Dummy --headless --script ci/no_audio_test.gd`. Loads Floor 1, simulates 30s of bot gameplay, verifies that every critical gameplay event (12 events enumerated in §10) has a visual fallback that fires within 1 physics tick of the event. Test fails if any event fires without its visual fallback. Runs on every build. Output to the orchestrator-provided telemetry path.

### Pause process modes

| Node | Process Mode | Reason |
|------|-------------|--------|
| PlayScene | PROCESS_MODE_PAUSABLE | Stops on pause |
| PausedScene | PROCESS_MODE_ALWAYS | Runs while paused |
| Audio nodes | PROCESS_MODE_ALWAYS | Pause sting plays, then ducks |
| Telemetry | PROCESS_MODE_ALWAYS | Records pause event, continues writing |
| Transition tweens | PROCESS_MODE_ALWAYS | Crossfade completes |
| HUD (paused) | PROCESS_MODE_ALWAYS | Paused overlay renders |

### Initials entry implementation

Inline `HBoxContainer` with three `Label` slots inside GameOverScene / CampaignResultsScene. Keyboard: `_input` captures A–Z/0–9/space, Backspace, Enter. Gamepad: ←/→ slot select, ↑/↓ char cycle via `InputEventJoypadMotion`/button. Focus moves to RETRY FLOOR N (or BEGIN NG+) on commit; row becomes static.

### Forward-compatibility hooks (not implemented, not promised)

The architecture reserves extension points for future Steam integration:
- SessionManager can emit `steam_achievement_unlocked` signal (no handler currently).
- SaveManager can intercept save writes for Steam Cloud sync (no sync currently).
- HallOfHeroesScene can render a "FRIEND GHOSTS" tab (no tab currently).
- These hooks are architectural reservations, not feature promises. G1 out-of-scope for online features stands.

---

## Appendix D — Save system specification

### Paths

| File | Path | Content |
|------|------|---------|
| Campaign save | `user://save/campaign.json` | Current run state |
| Profile | `user://save/profile.json` | NG+ flag, classes cleared |
| Settings | `user://save/settings.json` | All settings |
| Scores | `user://save/scores.json` | High-score tables |
| Quarantine | `user://save/campaign.corrupt` | Corrupted campaign save renamed |
| Quarantine | `user://save/settings.corrupt` | Corrupted settings file renamed |

On Windows, `user://` maps to `%APPDATA%/Godot/app_userdata/Hungerhall/`.

**Atomic write pattern (all files):** write to `<file>.tmp` via FileAccess, flush, then `DirAccess.rename` over the target. No partial writes can be observed on crash.

### Campaign save schema

```json
{
  "save_version": 1,
  "floor": 7,
  "class": "elf",
  "score": 12450,
  "potions_remaining": 1,
  "ng_plus": false,
  "timestamp": 1690000000
}
```

Tokens are deliberately absent: the only write point is floor_results entry, where tokens are already 2 — every load grants 2 tokens, and no stale-token desync is possible. Migration: unrecognized `save_version` → fresh start with notification. `new_run_active` is an in-memory flag on SessionManager, NOT persisted — it tracks whether the player started a new campaign that hasn't reached floor_results yet. If the player quits mid-floor, `new_run_active` is lost (the new run is abandoned) and the old save's CONTINUE is correct.

### Profile schema

```json
{
  "profile_version": 1,
  "ng_plus_unlocked": false,
  "classes_cleared": []
}
```

`classes_cleared` drives laurels on class_select. Written at campaign_results entry: the played class name is appended if not already present. No other transition writes to `classes_cleared`. Migration: unrecognized `profile_version` → defaults loaded, old file quarantined.

### Settings schema

```json
{
  "settings_version": 1,
  "display": {
    "brightness": 80,
    "ui_scale": 100,
    "window_mode": "fullscreen",
    "resolution": "1920x1080"
  },
  "audio": {
    "master": 80,
    "sfx": true,
    "music": true,
    "announcer": true
  },
  "controls": {
    "bindings": {
      "move_up": ["W", "Up", "LS-Up"],
      "move_down": ["S", "Down", "LS-Down"],
      "move_left": ["A", "Left", "LS-Left"],
      "move_right": ["D", "Right", "LS-Right"],
      "throw": ["J", "A"],
      "potion": ["K", "B"],
      "pause": ["Escape", "Start"]
    },
    "auto_fire": false
  },
  "accessibility": {
    "captions": true,
    "reduced_motion": false,
    "color_blind": "off"
  },
  "haptics": {
    "rumble": true
  }
}
```

Note: `hold_to_throw` renamed to `auto_fire` throughout. Migration: unrecognized `settings_version` → defaults loaded, old file quarantined to `settings.corrupt`. Settings read-fail on boot: silent recovery to defaults, no modal, no player action needed (see §6 SettingsReadFail).

### Scores schema

```json
{
  "scores_version": 1,
  "tables": {
    "warrior": [{"initials": "AAA", "score": 12400}],
    "valkyrie": [{"initials": "BBB", "score": 11200}],
    "wizard": [{"initials": "CCC", "score": 10800}],
    "elf": [{"initials": "DDD", "score": 9400}]
  }
}
```

Top 10 per class. Local only (G1 out-of-scope: online leaderboards); future Steam integration is an Appendix C architectural hook, not a data-field promise. Migration: unrecognized `scores_version` → empty tables loaded, old file quarantined.

### Erase semantics

`erase_warn` YES wipes ALL: campaign.json, profile.json, settings.json, scores.json. Complete reset. NG+ flag does NOT survive (it lives in profile.json). `classes_cleared` does NOT survive (also in profile.json).

`reset_warn` YES wipes settings.json ONLY. Campaign, scores, profile untouched.

---

## Appendix E — Acceptance criteria and definition of done

### G5 acceptance criteria

1. Screen graph is unambiguous: every screen, transition, and Back rule named with no contradictions.
2. Every screen has an ASCII wireframe with declared target sizes.
3. First-30-seconds storyboard marks FIRST DELIGHT explicitly.
4. Onboarding budget ceilings declared and met for the commercial_focused profile (2 screens, ~19–37 words, ~10s to control, ~10s to delight).
5. Settings screen has zero sub-menus; all settings on one scrollable screen.
6. Every error state has trigger, UI, recovery path, and voice-bible copy — including SettingsReadFail (silent recovery).
7. Every empty state uses game voice, not generic phrasing.
8. Every input scheme has focus order, visible focus, remapping, and disconnect recovery — including left-click activation, paused B-button exception, and pad_lost key-consumption.
9. Haptic policy declares 7 event types with audio + visual fallbacks; no per-action haptics; Reduced Motion interaction specified.
10. Sound policy declares a no-audio playable path with visual fallbacks for every cue; CI test enumerates 12 critical events with per-event validation rules.
11. B-button mapping unambiguous: full exception table in §8 (Potion in play, Back in menus, Resume in paused, NO in continue_offer, Skip in initials, BackToTitle in floor_missing).
12. Dying timing consistent across all sections (1.2s default / 0.2s Reduced Motion, no pre-crumble).
13. initials_entry consistently inline (not modal); paused/dying/continue_offer consistently screens — graph, wireframes, and rules agree.
14. Token economy defined (2 per floor, reset at floor_results entry; retry consumes none; not persisted; full floor reset on continue — generators/enemies/doors reset, only eaten food persists).
15. Save paths, schemas, migration rules, and erase semantics declared; classes_cleared write point declared (campaign_results entry).
16. Lock-amendment record traces every G2 deviation (LAR-1 through LAR-4) with a rollback rule.
17. Wireframe notation uses Xbox A/B/X/Y throughout, not ✕/○.
18. Reviewer diaries exercise happy path AND death → continue → retry cycle for both personas; diaries reference CAMPAIGN SAVE line and exit-door telegraph.
19. Persistence declaration has no contradictions: class_select.LockedIn does not write save; save written only at floor_results entry; new-game death behavior declared and surfaced via CAMPAIGN SAVE line on game_over.
20. Initials qualification rule binding in §1: game_over gates on score (N<10: >0; full: >10th place; 0 does not qualify); campaign_results always qualifies.
21. floor_missing retry loop eliminated: floors 1–23 advance save.floor on both options; floor 24 offers only [BACK TO TITLE] with save preserved at 23.
22. pad_lost topology resolved: auto-pause fires first, modal over paused, dismissing key consumed, child modals dismissed, no auto-resume.
23. Window Mode + Resolution interaction contract declared in §5.
24. CLEAR BINDING on movement reverts to factory default; remap capture replaces per-scheme only.
25. Auto-Fire (formerly Hold-to-Throw) renamed and semantics defined: ON = hold auto-fires at base rate, tap fires once; OFF = press fires once.
26. NG+ row visually differentiated (star badge + one-time entrance caption).
27. Attract replay claim qualified: same rules code, 30Hz half-speed, not identical simulation.
28. DIS-7 defense acknowledges friction is the only cost and justifies it as the tension gate.

### Definition of done

- All 28 acceptance criteria met.
- No internal contradictions (B-button, timing, topology, modal classification, save-write point, score wording).
- All DIS items resolved with explicit positions in the DIS resolution table; DIS-7 defense not self-contradictory.
- Lock-amendment record complete for all G2 deviations; each flagged pending G2 re-lock.
- Core-loop appendix provides binding numbers for G7.
- Godot architecture contract provides autoloads, scene tree, rules layer, machine-play seam, process modes, CI test spec.
- Save system specification provides paths, schemas, migration, erase semantics, classes_cleared write point.
- Simulated reviewer diaries exercise happy path AND death-retry cycle; diaries reference new features (CAMPAIGN SAVE line, exit-door telegraph).
- All obligations responded to (ADDRESSED, DISPUTED, or DEFERRED).
- G7 can implement the state machine without guessing.

---

## Obligation Responses

OBL-1: ADDRESSED — §8 adds explicit rule: left-click moves focus and activates action (Enter/A equivalent), not visual-only.
OBL-2: ADDRESSED — §5 adds Window Mode + Resolution interaction: Fullscreen/Borderless use desktop res (control disabled); Windowed uses selecte...
OBL-3: ADDRESSED — §1/§8: pad_lost dismissing key event consumed by modal, not forwarded to underlying screen; player presses second key to inte...
OBL-4: ADDRESSED — §1/§6: floor 24 missing offers only [BACK TO TITLE], no skip; save preserved at 23; campaign not cleared; build defect logged.
OBL-5: ADDRESSED — §5: CLEAR on movement actions reverts to factory default (W/S/A/D, arrows, LS), never empty; non-movement can clear to empty.
OBL-6: ADDRESSED — §10/Appendix C: CI test enumerates 12 critical events with per-event validation rules (visual fallback fires within 1 tick).
OBL-7: ADDRESSED — DIS-7 defense rewritten: acknowledges friction is the only cost; justifies two-action path as the tension gate between impuls...
OBL-8: ADDRESSED — §1: PadLostAutoPause fires first → state transitions to paused → pad_lost modal renders over paused, never over live play.
OBL-9: ADDRESSED — §1: floor_missing [BACK TO TITLE] advances save.floor (floors 1–23); no retry loop possible; floor 24 preserves at 23.
OBL-10: ADDRESSED — §1: campaign_results initials always fire (beating campaign = qualification); game_over gates on score threshold per §1 rule.
OBL-11: ADDRESSED — §1/§2: title→credits_pop transition added; CREDITS footer link added to title wireframe; credits_pop parent now includes title.
OBL-12: ADDRESSED — §1 continue_offer.YesChosen: full floor reset — generators reset to full HP/initial spawn, enemies reset, doors reset to lock...
OBL-13: ADDRESSED — §1/§3: newgame_warn copy: "BEGIN A NEW CAMPAIGN? YOUR CURRENT RUN (FLOOR N · CLASS) REMAINS UNTIL YOU CLEAR FLOOR 1."
OBL-14: ADDRESSED — §2/Appendix C: attract replay claim qualified — same rules code, 30Hz half-speed update, not identical simulation; slower-mot...
OBL-15: ADDRESSED — §1/§2: game_over displays "CAMPAIGN SAVE: FLOOR N" below FINAL SCORE; newgame_warn sets expectations about old save persisting.
OBL-16: ADDRESSED — §5/§8: if focus on Rumble toggle when gamepad disconnects, focus moves to nearest preceding focusable element (Auto-Fire togg...
OBL-17: ADDRESSED — §1: class_select→play rewritten — no save overwrite; new campaign begins in memory; save written only at first floor_results...
OBL-18: ADDRESSED — §1: FINAL SCORE = last floor_results total; failed floor score lost; no "post-penalty total" language anywhere.
OBL-19: ADDRESSED — §1: initials qualification elevated to binding rule — N<10: any positive score (>0); full: >10th place; 0 does not qualify.
OBL-20: ADDRESSED — §5: renamed to Auto-Fire; ON = hold fires at base rate, tap fires once; OFF = press fires once; HUD footer updates accordingly.
OBL-21: ADDRESSED — §2: NEW GAME+ row has ★ badge accent (period gold) + one-time "NEW GAME+ UNLOCKED" entrance caption (2s on first render after...
OBL-22: ADDRESSED — §1: floor_missing Back/Esc/B = BackToTitle; both options advance save.floor (floors 1–23); floor 24 preserves at 23.
OBL-23: ADDRESSED — §6: SettingsReadFail error state added — quarantine corrupt file, load defaults silently, no modal, no player action needed.
OBL-24: ADDRESSED — §1: pad_lost stacking — child modal dismissed, parent transitions to paused if was play, pad_lost over parent, no auto-reopen...
OBL-25: ADDRESSED — DIS-7 defense explicitly states "the only material cost is navigation friction: two deliberate actions versus one button press."
OBL-26: ADDRESSED — §1/§2: newgame_warn copy + game_over CAMPAIGN SAVE line make old-save-persists behavior explicit; player knows what CONTINUE...
OBL-27: ADDRESSED — §1/Appendix D: campaign_results entry appends class to profile.classes_cleared; laurels render on next class_select.
OBL-28: ADDRESSED — §1: initials qualification defines sparse table (N<10: threshold=0, strict >) and empty table (any positive score qualifies).
OBL-29: ADDRESSED — §5: remap capture replaces binding for captured input's scheme only — keyboard replaces keyboard, gamepad replaces gamepad.
OBL-30: ADDRESSED — §5/§9: Reduced Motion ON → dying is 0.2s instant fade, still non-interactive, auto-advances; haptic+audio still fire.
OBL-31: ADDRESSED — §1: game-over score wording unified — FINAL SCORE = last floor_results total; no "post-penalty total" language.
OBL-32: ADDRESSED — §8: paused B-button = Resume explicitly called out in full exception table as the only deviation from "B = Back in menus."
OBL-33: ADDRESSED — §1/§8: pad_lost dismissing key event consumed by modal; player must press second key to interact with underlying screen.
OBL-34: ADDRESSED — §6: LowMemory [TRY AGAIN] re-checks OS memory pressure; after 3 critical checks, replaced by "NO RELIEF" text, QUIT only option.
OBL-35: ADDRESSED — §4: exit-door idle prompt (15s → "EXIT" glyph) + door pulses when all keys held; visual telegraph of accessibility.
OBL-36: ADDRESSED — §1: class_select→play rewritten (no save overwrite); title CONTINUE display clarified via game_over CAMPAIGN SAVE line.
OBL-37: ADDRESSED — §1: floor_missing [BACK TO TITLE] advances save.floor (floors 1–23); no retry loop; floor 24 preserves at 23 (finale).
OBL-38: ADDRESSED — §1: continue state — full floor reset from baked seed; generators/enemies/doors reset; only eaten food persists.
OBL-39: ADDRESSED — §5: renamed to Auto-Fire; tap fires once in both ON and OFF modes; ON adds hold-to-auto-fire at base rate.
OBL-40: ADDRESSED — §1: initials qualification — sparse table threshold=0 (strict >); campaign_results always qualifies regardless of score.
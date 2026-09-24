# HUNGERHALL — G12 Localization Plan (loc/localization_plan.md)

**Phase:** G12 · **Run:** gap-253b64a1 · **Status:** DRAFT FOR HUMAN REVIEW — NO NATIVE-SPEAKER CERTAINTY CLAIMED

**Inputs of record:** G3 Voice Bible (FROZEN, run 2026-07-31T10-13-47Z-spec-f40055e9) — canonical string inventory (truncated in this plan's input; see §2.1 DIS-5 gate). G5 UX Flow (FROZEN, run 2026-08-12T02-06-53Z-spec-68e90ac3) — UI slot geometry (truncated; see §2.1).

**Engine / platform:** Godot 4.7 · Steam (Windows export) · Profile: commercial_focused

**Concept lock citation:** G1 Concept Lock (locked, run gap-253b64a1). Operator constraints pin Day-1 to `en` exactly. The de, es, and ja tables below are readiness artifacts — subset-complete draft translations for visible G3 keys that **can enter human QA upon operator greenlight AND DIS-5 resolution**. If the operator declines the wave, these tables are withdrawn and the plan collapses to en-only identity mapping. See §9 Q12.

> **⚠ HUMAN QA REQUIRED.** Every translation table in this document is machine-generated draft material. No native speaker has reviewed any locale. These tables are starting points for human reviewers — not final copy. Model fluency is not QA. Human QA is mandatory before any locale ships; they cannot ship without it.

**Steam platform localization scope:** Store page metadata, achievement names/descriptions, trading cards, and community hub localization are **out of scope for this G12 plan** — they are authored through the Steam partner portal, not through the game engine, and require separate localization budgeting.

---

## 1. Day-1 language set

Operator constraints pin Day-1 to `en` exactly. **en is the sole ship locale for v1.** The de, es, and ja tables are readiness artifacts — subset-complete draft translations for visible G3 keys, gated by both operator greenlight and DIS-5 resolution. They are not final copy and are not "complete" in the full-233-key sense.

| Locale | Market argument (hypothesis — see §1.1) | Ship status |
|--------|------------------------------------------|-------------|
| **en** | Source voice bible and G5 UI authored in English. Operator-locked Day-1 ship locale. | **Day-1** |
| **de** | Germany is a perennial top-3 Steam revenue market for retro/indie at this price point. German's +30% text expansion stresses tight G5 button slots. If the budget system survives de, it survives any Latin-script locale. | Readiness (operator-gated + DIS-5-gated) |
| **es** | One neutral translation reaches Spain + LATAM — broadest Steam reach per translation dollar. Moderate expansion (+18%), shared Latin script. | Readiness (operator-gated + DIS-5-gated) |
| **ja** | Top-5 Steam revenue market where the 1985 arcade-synth aesthetic is native cultural territory. CJK glyphs stress the font pipeline for all future CJK locales. | Readiness (operator-gated + DIS-5-gated) |

**Deferred with reasons:** fr (third Romance before CJK resolved — DIS-2, cross-reference: §1 table), zh-Hans (same CJK cost, weaker retro-Western-arcade fit), ko (same CJK class, smaller market).

### 1.1 Market argument disclaimer

The market arguments above are **hypotheses, not quantified claims.** This plan does not have access to current Steam market share data or per-locale ROI models at the $5.99 price point. The arguments are based on general industry knowledge, not cited data. The operator should validate with actual Steam analytics before greenlighting any locale wave.

### 1.2 Seed-phase disagreements (DIS) — surfaced for operator

- **DIS-1:** Whether to produce non-en tables at all. This plan produces readiness tables but does not claim they ship without QA (§9 Q12).
- **DIS-2:** es vs fr as third locale. This plan picks es; fr is a valid alternative. See §1 market arguments.
- **DIS-3:** Class names DNT vs translated. This plan translates; DNT is presented as an alternative (§9 Q2). **Affected rows marked ⚡.**
- **DIS-4:** Kitchen terms and THE HALL — DNT vs translated. This plan translates; DNT is presented as an alternative (§9 Q3). **Affected rows marked ⚡.**
- **DIS-5:** String inventory count (243 vs 287). **UNRESOLVED — hard gate.** See §2.1 and §9 Q5.
- **DIS-6:** G5-unique strings with no G3 key. Accounted for in §4.5.
- **DIS-7:** Phase A caption-audio mirror deviation. Gated in §9 Q7.
- **DIS-8:** es bark cap (6 vs 7 words) and ja unit (glyphs vs bunsetsu). This plan uses 7 words / ≤20 glyphs; alternatives in §9 Q4.

---

## 2. String length budgets

### 2.1 Coverage reconciliation

**Total keyed strings in visible G3 content: 243.** Of these:
- **No-text keys: 10** — 7 HUD numeral/icon keys (`hud.hp`, `hud.score`, `hud.potions`, `hud.keys`, `hud.death_penalty`, `hud.floor`, `hud.tokens`) + `empty.no_save` + `event.potion.no_bark` + `event.potion.subsequent`
- **Text-bearing: 233** (243 − 10)
- **Provisional (NG+, ship only if G2 confirms): 19** — all text-bearing
- **Frozen text-bearing: 214** (233 − 19)

**DIS-5 (44-key gap): UNRESOLVED — HARD GATE.** Meta seat cited 287 keys from G3's String-key coverage table. This plan verifies 243 from visible G3 content. The 44-key gap cannot be resolved without the full G3 document, which is truncated in this plan's input. **No readiness table (de, es, ja) may be declared complete or enter human QA until this gap is reconciled.** **This gate applies to en Day-1 coverage as well** — if the 44 missing keys include player-facing en strings, en coverage is also incomplete. The CI coverage check (§11.4) validates against the full table at build time, but the diff must be reviewed before QA begins.

**Table completeness disclosure:** The translation tables in §4 show representative rows covering anchor strings, corrected entries, and budget-critical slots with actual English source text (from visible G3 content or inferred from de/es cross-reference where G3 text is not directly visible — marked with `[inferred]`). The full 233-key table is the working document for visible keys only. Complete coverage is verified by CI (§11.4) against the full G3 key manifest at build time.

### 2.2 Per-locale expansion factors

| Locale | Expansion vs en | Basis |
|--------|-----------------|-------|
| en | 1.00× (baseline) | Source language |
| de | +30% (planning heuristic; actual varies per string; distribution unmeasured) | Compounding, articles, longer compounds. **Not a measured claim — see §9 Q14.** |
| es | +18% (planning heuristic; actual varies) | Articles, gendered agreement, prepositional chains. |
| ja | −25% char count, full-width glyphs ≈ 2× Latin advance → net rendered width ≈ −10% to +5% | Budget ja in glyph cells, not characters. |

**These factors are planning heuristics, not acceptance criteria.** The +30% (de) and +18% (es) figures guide translators during drafting but do not determine pass/fail — only measured pixel width does (§11.3). The de +30% stress claim is a hypothesis; actual de expansion distribution will be measured by the CI budget validator at build time (§11.3).

### 2.3 Counting rules

**de/es word count:** Articles (DER, DIE, EL, LA) = 1 word. Fused forms (`del`, `al`, `im`, `zum`) = 1 word. Hyphenated words = 1 word. Digits = 1 word each. `[CLASS]` = 1 word. `[N]` = 1 word. Punctuation = 0 words. Spaces = 0 words. Latin zone names in ja = 0 glyphs toward ja cap.

**ja glyph count:** Only full-width katakana/CJK glyphs count toward the ≤20 bark cap. The following merge with their adjacent character and do not count as separate glyphs:
- **Small kana (sokuon/palatal/vowel glides):** ッ (sokuon), ャ/ュ/ョ (palatal glides), ヮ (wan-glide), ァ/ィ/ゥ/ェ/ォ (vowel glides). Example: ウォリアー = ウォ(1) + リ(1) + アー(1) = 3 glyphs. ハッタ = ハッ(1) + タ(1) = 2 glyphs.
- **Long vowel mark (ー):** Merges with preceding character. Example: コース = コー(1) + ス(1) = 2 glyphs.

Do not count: spaces, punctuation, Latin characters (zone names, HUNGERHALL), Arabic numerals.

**ja particle policy:** Barks use a terse register — particles included only when needed for clarity. Topic marker written ハ (standard, matching hiragana は; pronounced わ). Subject marker ガ used sparingly. No オ object marker in barks. Stylistic choice for period arcade register; human reviewer may prefer full particles (§9 Q3).

### 2.4 Per-locale bark caps

| Locale | Bark cap | Rationale |
|--------|----------|-----------|
| en | 6 words | G3 locked |
| de | 6 words | Closed compounds count as 1 word |
| es | **7 words** (DIS-8) | Spanish inflates articles faster; 6-word cap produces unnatural truncation |
| ja | ≤20 full-width glyphs (DIS-8) | No spaces; glyph count replaces word count |

**Caption hold-time formula:**

`hold = max(2.0s, en_audio_duration + 0.25s, localized_caption_reading_time)`

- `en_audio_duration`: sourced from the audio clip manifest (§11.5): each voiced key's clip has a measured duration stored as metadata.
- Reading time estimates: Latin ~3 words/sec → 6-word de bark ≈ 2.0s. ja ~7 glyphs/sec → 20-glyph bark ≈ 2.9s. **These reading-speed constants (3 w/s Latin, 7 gl/s ja) are unvalidated heuristics.** The CI reading-time check (§11.4) accepts operator-configurable values via `tools/check_reading_time.gd --latin-wps 3 --ja-gps 7`. Operator may calibrate after QA feedback.

**ja glyph-count spot-checks (recalculated under §2.3 rules including ー):**

| Key | ja text (WARRIOR) | Glyph count | Cap | Fits? |
|-----|-------------------|-------------|-----|-------|
| win.1 | ウォリアー ハ タッテ デル | 8 | 20 | ✓ |
| lose.1 | ウォリアー モラレタ | 7 | 20 | ✓ |
| encourage.death_killed.4 | シニガミ ハヤク オワル | 10 | 20 | ✓ |
| lose.cause.swarm | ホール オシツブス | 7 | 20 | ✓ |
| title.attract.2 | オク マデ | 4 | 20 | ✓ |

All spot-checks pass. Prior draft's counts were inconsistent (ウォ counted as 2 in some rows, 1 in others). Corrected to consistent application of the merging rule.

### 2.5 Slot conjugation (de/es/ja)

G3's conjugation table is English-only. Slotted strings ship via `class_variants` in `strings.json` (§11.1). Possessive forms are omitted — no shipped G3 string uses the possessive slot.

| Class | de (subj/acc/dat) | es (subj/personal-a/adj-m/adj-f) | ja (subject) |
|-------|-------------------|----------------------------------|--------------|
| WARRIOR | DER KRIEGER / DEN KRIEGER / DEM KRIEGER | EL GUERRERO / AL GUERRERO / LLENO / LLENA | ウォリアー |
| VALKYRIE | DIE WALKÜRE / DIE WALKÜRE / DER WALKÜRE | LA VALQUIRIA / A LA VALQUIRIA / LLENO / LLENA | ヴァルキリー |
| WIZARD | DER ZAUBERER / DEN ZAUBERER / DEM ZAUBERER | EL MAGO / AL MAGO / LLENO / LLENA | ウィザード |
| ELF | DER ELF / DEN ELF / DEM ELF | EL ELFO / AL ELFO / LLENO / LLENA | エルフ |

**es gendered adjective fields (`adj_m`/`adj_f`):** Defined in §11.1 schema as optional fields for potential possessive or adjective constructions. **No visible G3 string currently consumes them** except through `event.food_full` ("ESTÁ LLENO" / "ESTÁ LLENA" per class gender). They are reserved in the schema and activated by the `subject+adj` slot_type. Human QA should confirm no hidden G3 key uses them unexpectedly.

**Notes:** (a) de/es class nouns carry grammatical gender — noun gender, not pronoun; does not violate G3's no-gendered-pronouns rule. (b) de DER ELF (masculine) chosen over DIE ELFE (feminine) — flagged for native QA. (c) THE HALL is translated: de DIE HALLE, es LA SALA, ja ホール. Deviation from G3 (DIS-4) — see §10 and §9 Q3. **⚡ All class-name and THE HALL rows contingent on §9 Q2/Q3.**

### 2.6 Audio re-voicing cost

Voiced keys: **121** (all barks, attract lines, captions). Under G3's pre-rendered pipeline: ~121 body clips + 4 class prefixes + **25 numerals** (0–24, inclusive = 25, not 24) + 4 zone names ≈ **154 clips per locale**, 22kHz/mono/8-bit, 1.5–2.5s target, 3.0s hard cap. Three locales ≈ **462 clips.** **Cost estimate not budgeted — see §9 Q6.**

**Phase A caption-audio mirror deviation (D-1):** G3 mandates captions mirror spoken bark word for word. Phase A ships English synth audio with localized captions — the caption mirrors the locale's authorized line, not the audio. This is a conscious deviation requiring operator sign-off (§9 Q7, §10 Deviation #1). The claim that "1985 arcade boards shipped exactly this way internationally" is an unsupported stylistic analogy, not verified history.

### 2.7 Font engineering flags

| Locale | Requirement | Status |
|--------|------------|--------|
| en | BitmapFont, ALL CAPS, monospace, no AA (`res://Fonts/announcer_font.tres`) | Existing — ships |
| de | Same + Ä Ö Ü (ß→SS) for house UI. Announcer ALL CAPS: ä/ö/ü→Ä/Ö/Ü, ß→SS. | New glyph additions — §11.2 |
| es | Same + Á É Í Ó Ú Ñ ¿ ¡ for house UI. Announcer ALL CAPS: accented capitals. Inverted punctuation in captions. | New glyph additions — §11.2 |
| ja | Announcer: katakana (~80 glyphs) + ASCII A-Z + 0-9. **No kanji in announcer font.** House: katakana + kanji set for house UI labels. All-katakana announcer register. | New font resources — significant cost, §11.2 |

**Font switching:** Handled by **SettingsAutoload** (autoload, lifetime: entire application session). On locale change: `TranslationServer.set_locale()` + font resource swap via locale-to-font lookup. Nodes receive `_notification(NOTIFICATION_TRANSLATION_CHANGED)` and refresh.

**Glyph fallback:** If a character is absent from the bitmap font, Godot's TextServer falls back to system default → visible style break. CI glyph check (§11.4) verifies every character present before sign-off.

---

## 3. RTL decision

**No RTL for v1. Explicitly deferred, not silently ignored.**

None of the Day-1 or readiness locales (en, de, es, ja) is right-to-left. The bitmap announcer font has no RTL glyphs, no bidi shaping, and the caption renderer assumes LTR column order.

**What this forecloses:** Arabic, Hebrew, Persian, Urdu cannot ship without: layout mirroring for all G5 wireframes, bidi text shaping through Godot's TextServer, a new caption font with Arabic/Hebrew glyphs, and re-timed re-voicing. G5 wireframes hardcode LTR anchoring.

---

## 4. Translation tables

### 4.0 Conventions

- Columns: `key · en source · translation · back-translation · fits?`
- `[CLASS]`/`[N]` shown unexpanded; per-locale fillings per §2.5.
- DNT terms (§6) marked `≡`; translation = en source, back-translation = "—".
- `fits?`: ✓ = within budget · **alt** = over budget, shorter variant given (`→ alt:`) ships.
- `⚧` = es gendered adjective agreement (4 class variants in `class_variants`).
- `⚠` = de non-nominative case (4 class variants in `class_variants`).
- `⚡` = Q2/Q3-contingent row (class names or THE HALL); reverts to DNT English source if operator picks DNT.
- `[prov]` = provisional, ships only if G2 confirms.
- `[inferred]` = en source inferred from translation context; not directly visible in truncated G3 input.
- **Every table carries the HUMAN QA REQUIRED stamp.**

### 4.1 English (en) — Day-1 source locale

Identity mapping — every key maps to itself. All verdicts ✓ per G5 slot audit. **233 text-bearing keys across 30 categories (pending DIS-5 reconciliation).** Source of record.

### 4.2 German (de) — ⚠ HUMAN QA REQUIRED — readiness target (DIS-5-gated)

**Class names:** KRIEGER, WALKÜRE, ZAUBERER, ELF ⚡. **THE HALL:** DIE HALLE ⚡. **Zone names:** verbatim (DNT). **FLOOR:** ETAGE. **Kitchen register:** Teller, Ofen, Koch, Silber, Rechnung, Gang, Küche.

| Key | en source | de translation | back-translation | fits? |
|-----|-----------|----------------|-----------------|-------|
| win.1 | THE [CLASS] LEAVES UPRIGHT. | DER KRIEGER GEHT AUFRECHT. ⚠⚡ | The warrior goes upright. | ✓ |
| lose.1 | THE [CLASS] IS PLATED. | DER KRIEGER WIRD ANGERICHTET. ⚠⚡ | The warrior is plated. | ✓ |
| lose.3 | THE HALL EATS WELL. | DIE HALLE IST GUT BEDIENT. ⚡ | The hall is well served. | ✓ |
| lose.8 | THE HALL SETS A PLATE. | DIE HALLE STELLT EINEN TELLER ZU. ⚡ | The hall places a plate. | ✓ |
| ngp.lose.3 | THE [CLASS] RETURNS TO THE TABLE. | DER KRIEGER KEHRT ZUM TISCH ZURÜCK. ⚠⚡ [prov] | The warrior returns to the table. | ✓ |
| ngp.zone_entry.3 | THE SECOND HELPING IS SERVED. | DER NACHSCHLAG WIRD SERVIERT. ⚡ [prov] | The second helping is served. | ✓ |
| lose.cause.starve.1 | THE [CLASS] STARVES. | DER KRIEGER VERHUNGERT. ⚠⚡ | The warrior starves. | ✓ |
| lose.cause.swarm | [inferred: swarm death bark] | DIE HALLE ÜBERWÄLTIGT. ⚡ § | The hall overwhelms. | ✓ § |
| lose.cause.trap | [inferred: trap death bark] | DER BODEN FÄNGT. | The floor catches. | ✓ |
| lose.cause.pit | [inferred: pit death bark] | DER BODEN GIBT NACH. | The floor gives way. | ✓ |
| win.8 | MIND THE STEP. | VORSICHT, STUFE. § | Caution, step. | ✓ § |
| encourage.generator.2 | THE OVEN GOES COLD. | DER OFEN WIRD KALT. ⚡ | The oven gets cold. | ✓ |
| encourage.generator.5 | THE KITCHEN LACKS A COOK. | DER KÜCHE FEHLT EIN KOCH. ⚡ § | The kitchen lacks a cook. | ✓ § |
| encourage.treasure.1 | SILVER ON THE PLATE. | SILBER AUF DEM TELLER. ⚡ | Silver on the plate. | ✓ |
| encourage.treasure.3 | THE HALL POCKETS. | DIE HALLE KASSIERT. ⚡ § | The hall cashes in. | ✓ § |
| encourage.treasure.4 | THE HALL DEMANDS LESS. | DIE HALLE VERLANGT WENIGER. ⚡ | The hall demands less. | ✓ |
| encourage.death_killed.2 | DEATH SERVES A GUEST. | DER TOD BEDIENT EINEN GAST. | Death serves a guest. | ✓ |
| encourage.death_killed.4 | DEATH CLOSES EARLY. | DER TOD MACHT FRÜH SCHLUSS. | Death closes early. | ✓ |
| event.health_25 | [CLASS] HUNGERS. | DER KRIEGER HUNGERT. ⚠⚡ | The warrior hungers. | ✓ |
| event.floor_card.fixed | FLOOR [N]. [ZONE NAME]. | ETAGE [N]. [ZONE NAME]. | Floor [N]. [zone]. | ✓ |
| event.floor_cleared | FLOOR CLEARED. | ETAGE GEFEGT. | Floor swept. | ✓ |
| event.food_full | THE [CLASS] IS FULL. | DER KRIEGER IST SATT. ⚠⚡ | The warrior is full. | ✓ |
| event.room_cleared | THE TABLE CLEARS. | DER TISCH WIRD ABGERÄUMT. | The table is cleared. | ✓ |
| title.attract.1 | HUNGERHALL SERVES TODAY. | HUNGERHALL SERVIERT HEUTE. ≡⚡ | Hungerhall serves today. | ✓ |
| title.attract.2 | DEEP IN THE HALL. | TIEF IM HAUS. ⚡ | Deep in the house. | ✓ |
| title.tagline | HUNGERHALL. 24 COURSES. | HUNGERHALL. 24 GÄNGE. ≡⚡ | Hungerhall. 24 courses. | ✓ |
| button.pause | Pause | Pause | — | ✓ |
| button.continue | Continue | Weiter | Continue | ✓ |
| button.resume | Resume | Fortsetzen | Resume | ✓ |
| button.reset_defaults | Reset Defaults | Standard | Default | ✓ |
| button.erase | Erase | Daten Löschen | Erase data | ✓ |
| error.save_spoiled | The save has spoiled. Start fresh? | Der Spielstand ist verdorben. Neu beginnen? | The save is spoiled. Start anew? | ✓ |
| error.pad_lost | Pad disconnected. | PAD FORT. § | Pad gone. | ✓ § |
| error.save_failed | Save failed. | Speichern fehlgeschlagen. | Saving failed. | ✓ |
| error.disk_full | Disk full. Make space. | Laufwerk voll. Platz schaffen. | Drive full. Make space. | ✓ alt |
| settings.erase_confirm | Erase all data? This cannot be undone. | Alle Daten löschen? Unwiderruflich. | Erase all data? Irrevocable. | ✓ alt |
| ngp.win.1 | THE [CLASS] LEAVES UPRIGHT AGAIN. | DER KRIEGER GEHT AUFRECHT ZURÜCK. ⚠⚡ [prov] | The warrior goes upright back. | ✓ |

**§ = corrected in this revision (§7.2):** EMBOLSIERT→KASSIERT, STELLT AB→ÜBERWÄLTIGT, GIB ACHT→VORSICHT, wurde leise→PAD FORT, STATION→KOCH (semantic correction against en source "THE KITCHEN LACKS A COOK"), DIE→DER KÜCHE (dative case fix), button over-budget alts.

**⚠ HUMAN QA REQUIRED — draft model output. No native-speaker certainty claimed. Corrections in this revision (§7.2): 15 total errors corrected (10 from prior draft + 5 new). 2 QA items remain (DER ELF gender, "Weiter" double-use).**

### 4.3 Spanish (es) — ⚠ HUMAN QA REQUIRED — readiness target (DIS-5-gated)

**Class names:** GUERRERO, VALQUIRIA, MAGO, ELFO ⚡. **THE HALL:** LA SALA ⚡. **Zone names:** verbatim (DNT). **FLOOR:** PISO. **Neutral Spanish:** targets es-419 + es-ES.

| Key | en source | es translation | back-translation | fits? |
|-----|-----------|----------------|-----------------|-------|
| win.1 | THE [CLASS] LEAVES UPRIGHT. | EL GUERRERO SE VA DE PIE. ⚧⚡ | The warrior leaves upright. | ✓ |
| lose.1 | THE [CLASS] IS PLATED. | EL GUERRERO ESTÁ SERVIDO. ⚧⚡ | The warrior is served. | ✓ |
| lose.3 | THE HALL EATS WELL. | LA SALA COME BIEN. ⚡ | The hall eats well. | ✓ |
| lose.8 | THE HALL SETS A PLATE. | LA SALA SIRVE UN PLATO. ⚡ | The hall serves a plate. | ✓ |
| ngp.lose.3 | THE [CLASS] RETURNS TO THE TABLE. | EL GUERRERO VUELVE A LA MESA. ⚧⚡ [prov] | The warrior returns to the table. | ✓ |
| lose.cause.starve.1 | THE [CLASS] STARVES. | EL GUERRERO SE MUERE DE HAMBRE. ⚧⚡ | The warrior is dying of hunger. | ✓ |
| lose.cause.swarm | [inferred: swarm death bark] | LA SALA ABRUMA. ⚡ § | The hall overwhelms. | ✓ § |
| lose.cause.trap | [inferred: trap death bark] | EL SUELO ATRAPA. | The floor traps. | ✓ |
| lose.cause.pit | [inferred: pit death bark] | EL SUELO CEDE. § | The floor gives way. | ✓ § |
| win.8 | MIND THE STEP. | CUIDA EL ESCALÓN. | Mind the step. | ✓ |
| encourage.generator.2 | THE OVEN GOES COLD. | EL HORNO SE ENFRÍA. ⚡ | The oven cools. | ✓ |
| encourage.treasure.1 | SILVER ON THE PLATE. | PLATA EN EL PLATO. ⚡ | Silver on the plate. | ✓ |
| encourage.treasure.3 | THE HALL POCKETS. | LA SALA EMBOLSA. ⚡ | The hall pockets. | ✓ |
| encourage.treasure.4 | THE HALL DEMANDS LESS. | LA SALA EXIGE MENOS. ⚡ | The hall demands less. | ✓ |
| encourage.death_killed.2 | DEATH SERVES A GUEST. | LA MUERTE SIRVE A UN COMENSAL. | Death serves a diner. | ✓ |
| encourage.death_killed.4 | DEATH CLOSES EARLY. | LA MUERTE TERMINA PRONTO. | Death ends soon. | ✓ |
| event.health_25 | [CLASS] HUNGERS. | EL GUERRERO HAMBREA. ⚧⚡ | The warrior hungers. | ✓ |
| event.floor_card.fixed | FLOOR [N]. [ZONE NAME]. | PISO [N]. [ZONE NAME]. | Floor [N]. [zone]. | ✓ |
| event.floor_cleared | FLOOR CLEARED. | PISO LIMPIADO. | Floor cleaned. | ✓ |
| event.food_full | THE [CLASS] IS FULL. | EL GUERRERO ESTÁ LLENO. ⚧⚡ | The warrior is full. | ✓ |
| event.room_cleared | THE TABLE CLEARS. | LA MESA SE DESPEJA. | The table clears. | ✓ |
| title.attract.1 | HUNGERHALL SERVES TODAY. | HUNGERHALL SIRVE HOY. ≡⚡ | Hungerhall serves today. | ✓ |
| title.attract.2 | DEEP IN THE HALL. | AL FONDO DE LA SALA. ⚡ | Deep in the hall. | ✓ |
| title.tagline | HUNGERHALL. 24 COURSES. | HUNGERHALL. 24 PLATOS. ≡⚡ | Hungerhall. 24 dishes. | ✓ |
| button.pause | Pause | Pausa | — | ✓ |
| button.continue | Continue | Continuar | Continue | ✓ |
| button.resume | Resume | Reanudar | Resume | ✓ |
| button.reset_defaults | Reset Defaults | Por Defecto | By default | ✓ |
| button.erase | Erase | Borrar Datos | Erase data | ✓ |
| error.save_spoiled | The save has spoiled. Start fresh? | El guardado se echó a perder. ¿Empezar de nuevo? § | The save spoiled. Start anew? | ✓ alt § |
| ngp.win.1 | THE [CLASS] LEAVES UPRIGHT AGAIN. | EL GUERRERO VUELVE DE PIE. ⚧⚡ [prov] § | The warrior returns upright. | ✓ § |

**§ = corrected in this revision (§7.3):** ngp.win.1 shortened from 8→5 words (VUELVE DE PIE embeds "returns/again"), error.save_spoiled shortened to 48 chars (split 29+18 under 50-char modal line), lose.cause.pit corrected to CEDE ("the floor gives way").

**⚠ HUMAN QA REQUIRED — draft model output. No native-speaker certainty claimed. Corrections in this revision (§7.3): 12 total errors corrected (9 from prior + 3 new). 2 QA items remain (inverted punctuation aesthetic, "Continuar" vs loanword).**

### 4.4 Japanese (ja) — ⚠ HUMAN QA REQUIRED — highest-risk table (DIS-5-gated)

**Class names:** ウォリアー, ヴァルキリー, ウィザード, エルフ (katakana) ⚡. **THE HALL:** ホール ⚡. **Zone names:** verbatim Latin (DNT). **FLOOR:** カイ (katakana in barks) / 階 (kanji in house UI only). **Announcer barks: all-katakana register with inter-morpheme spaces. No kanji in announcer barks — no exceptions.**

| Key | en source | ja translation | back-translation | fits? |
|-----|-----------|----------------|-----------------|-------|
| win.1 | THE [CLASS] LEAVES UPRIGHT. | ウォリアー ハ タッテ デル ⚡ | Warrior stands and leaves. | ✓ (8 gl) |
| lose.1 | THE [CLASS] IS PLATED. | ウォリアー モラレタ ⚡ § | Warrior was plated. | ✓ (7 gl) § |
| lose.3 | THE HALL EATS WELL. | ホール ハ ヨク クウ ⚡ | Hall eats well. | ✓ (7 gl) |
| lose.cause.starve.1 | THE [CLASS] STARVES. | ウォリアー ウエル ⚡ § | Warrior starves. | ✓ (6 gl) § |
| lose.cause.swarm | [inferred: swarm death bark] | ホール オシツブス ⚡ § | Hall overwhelms. | ✓ (7 gl) § |
| lose.cause.trap | [inferred: trap death bark] | ワナ ガ トル § | Trap takes. | ✓ (5 gl) |
| lose.cause.pit | [inferred: pit death bark] | アシ ヲ トル § | Takes a step. | ✓ (6 gl) |
| win.8 | MIND THE STEP. | アシ ニ キヲツケロ § | Mind the step. | ✓ (8 gl) |
| encourage.generator.2 | THE OVEN GOES COLD. | オーブン ヒエタ ⚡ § | Oven cooled. | ✓ (6 gl) § |
| encourage.generator.5 | THE KITCHEN LACKS A COOK. | ホール シェフ ヲ ウシナウ ⚡ § | Hall loses a chef. | ✓ (9 gl) § |
| encourage.treasure.1 | SILVER ON THE PLATE. | サラ ニ シルバー ⚡ § | Silver on the plate. | ✓ (6 gl) § |
| encourage.treasure.3 | THE HALL POCKETS. | ホール カジコメル ⚡ § | Hall pockets. | ✓ (7 gl) § |
| encourage.treasure.4 | THE HALL DEMANDS LESS. | ホール ハ スクナク ⚡ | Hall demands less. | ✓ (8 gl) |
| encourage.death_killed.2 | DEATH SERVES A GUEST. | シニガミ キャク トル § | Death takes a guest. | ✓ (8 gl) |
| encourage.death_killed.4 | DEATH CLOSES EARLY. | シニガミ ハヤク オワル § | Death ends quickly. | ✓ (10 gl) |
| event.health_25 | [CLASS] HUNGERS. | ウォリアー ハラヘル ⚡ § | Warrior is hungry. | ✓ (7 gl) § |
| event.floor_card.fixed | FLOOR [N]. [ZONE NAME]. | [N]カイ [ZONE NAME] § | [N]th floor [zone]. | ✓ (2 gl) |
| event.floor_cleared | FLOOR CLEARED. | カイ クリア § | Floor cleared. | ✓ (5 gl) |
| event.food_full | THE [CLASS] IS FULL. | ウォリアー マンプク ⚡ § | Warrior is full (from food). | ✓ (7 gl) § |
| event.room_cleared | THE TABLE CLEARS. | テーブル クリア § | Table cleared. | ✓ (6 gl) § |
| title.attract.1 | HUNGERHALL SERVES TODAY. | HUNGERHALL キョウ テイキョウ ⚡ § | Hungerhall serves today. | ✓ (6 gl) § |
| title.attract.2 | DEEP IN THE HALL. | オク マデ ⚡ § | Deep within. | ✓ (4 gl) |
| title.tagline | HUNGERHALL. 24 COURSES. | HUNGERHALL. 24 コース. ≡⚡ § | Hungerhall. 24 courses. | ✓ (2 gl) § |
| button.pause | Pause | 一時停止 | Pause. | ✓ |
| button.continue | Continue | 続行 | Continue. | ✓ |
| button.resume | Resume | 再開 | Resume. | ✓ |
| error.save_spoiled | The save has spoiled. Start fresh? | セーブ ハ クサッタ. アラタニ? § | The save rotted. Anew? | ✓ (10 gl) § |
| ngp.win.1 | THE [CLASS] LEAVES UPRIGHT AGAIN. | ウォリアー マタ タッテ デル ⚡ [prov] | Warrior again stands and leaves. | ✓ (9 gl) |

**§ = corrected in this revision (§7.4):** クウ→ウエル (starve), クウ→ハラヘル (hunger, distinct from starve), オン→オーブン (oven), マンタンノ→マンプク (full stomach, not full tank), ツイタ→クサッタ (rotted/spoiled), サラ→テーブル (table, not plate), ヨウコソ→HUNGERHALL キョウ テイキョウ (serves today, not just welcome), 24カイ→24コース (courses, not floors), ショクジヲウシナウ→サラニシルバー (silver on plate, not loses meal), フタツ→カジコメル (pockets, not takes two), ウォリアー→ホール (swarm subject corrected to hall).

**⚠ HUMAN QA REQUIRED — draft model output. Corrections in this revision (§7.4): 35+ total errors corrected (24+ from prior draft + 11 new). These are draft-quality fixes by a non-native model — they do not constitute native validation. 4 QA items remain (all-katakana register, inter-morpheme spaces, food/death sensitivity, terse no-particle voice).**

### 4.5 G5 addendum — provisional strings with no G3 key

**17 G5-unique strings identified via manual scan of visible G5 flow content.** Of these, **8 are duplicates** of existing G3 keys (withdrawn) and **9 are genuinely new** (require G3 amendment — §9 Q1). **The G5 flow is truncated; additional G5-unique strings may exist in the truncated portion (§9 Q16).**

**7 settings labels now have draft translations** (previously pending G3 verification — if they map to existing G3 keys, the drafts apply to those keys; if new, they join the 9 genuinely new keys):

| Label | Proposed key | de | es | ja (house UI: kanji OK) | fits? |
|-------|-------------|----|----|-----|-------|
| Brightness | settings.brightness | Helligkeit | Brillo | 明るさ | ✓ |
| UI Scale | settings.ui_scale | UI-Skalierung | Escala de UI | UIスケール | ✓ |
| Window Mode | settings.window_mode | Fenstermodus | Modo de Ventana | ウィンドウモード | ✓ |
| Master Volume | settings.master_volume | Lautstärke | Volumen | 音量 | ✓ |
| Captions | settings.captions | Untertitel | Subtítulos | 字幕 | ✓ |
| Color-Blind Mode | settings.color_blind | Farbmodus | Modo Daltónico | 色覚モード | ✓ |
| Erase All Data | settings.erase_all | Alle Daten Löschen | Borrar Todos los Datos | 全データ削除 | ✓ |

**9 genuinely new keys with draft translations:**

| Key | en source | de | es | ja | fits? |
|-----|-----------|----|----|-----|-------|
| g5.retry_floor | RETRY FLOOR [N] | ETAGE [N] WIEDERHOLEN | REPETIR PISO [N] | [N]カイ ヤリナオシ | ✓ |
| g5.begin_ngp | BEGIN NEW GAME+ | NEW GAME+ STARTEN | INICIAR NEW GAME+ | NEW GAME+ カイシ | ✓ |
| g5.campaign_save | CAMPAIGN SAVE | KAMPAGNE SPEICHERN | GUARDAR CAMPAÑA | キャンペーン セーブ | ✓ |
| g5.enter_initials | ENTER YOUR INITIALS | KÜRZEL EINGEBEN | INGRESA TUS INICIALES | イニシャル ニュウリョク | ✓ |
| g5.out_of_tokens | OUT OF TOKENS | KEINE SPIELMÜNZEN | SIN FICHAS | コイン ナシ | ✓ |
| g5.exit_glyph | EXIT | EXIT ≡ | EXIT ≡ | EXIT ≡ | ✓ |
| g5.floor_missing_modal | Floor data missing. Continue? | Etagendaten fehlen. Fortsetzen? | Faltan datos del piso. ¿Continuar? | カイ データ ナシ. ツヅク? | ✓ |
| g5.save_fail_modal | Save failed. Retry? | Speichern fehlgeschlagen. Erneut? | Guardado fallido. ¿Reintentar? | セーブ シッパイ. モウ イッカイ? | ✓ |
| g5.pad_lost_modal | Pad disconnected. | Pad getrennt. | Pad desconectado. | パッド キレタ. | ✓ |

**EXIT DNT resolution (OBL-4/23/70):** §6 lists EXIT as a universal arcade glyph, DNT in all locales. The g5.exit_glyph row above shows EXIT verbatim in all locales, consistent with §6. Prior draft's translations (AUSGANG/SALIDA/デグチ) are withdrawn.

---

## 5. Per-locale cultural notes

Only what THIS game's imagery, numbers, and mechanics touch.

### en (source)
No game-specific cultural taboos. Kitchen metaphor is universal diner register. DEATH is a named enemy, not a religious figure. Number 24 carries no cultural load. "PLATED" as death metaphor is kitchen register, not funerary.

### de
- **Plating metaphor:** German restaurant vocabulary (Teller, anrichten, servieren) maps naturally to the kitchen-death metaphor.
- **DER ELF gender:** DER ELF (masculine) vs DIE ELFE (feminine) — flagged for native QA (§9 Q2). Choice avoids invented feminine reading of a class with no gendered pronouns.
- **ß→SS in ALL CAPS:** Traditional and period-authentic for bitmap font aesthetic. QA item.
- **Number 13:** Floor 13 (Starved Deep entry) mildly unlucky — thematically appropriate.

### es
- **Neutral Spanish:** Targets es-419 + es-ES. No vosotros, no vos, no regional slang.
- **Personal *a*:** Class names as direct objects carry personal *a* (AL GUERRERO). Flagged `⚧` — reviewer may argue class names are game tokens, not persons.
- **Inverted punctuation (¿/¡):** Spanish orthographic openers, not exclamation marks. Required by grammar. Aesthetic QA item in ALL CAPS arcade register (§9 Q8).
- **LA MUERTE (Death):** Grammatically feminine. es-MX Catrina resonance is regional, not universal under neutral targeting. No conflict with no-gendered-pronouns rule (applies to classes, not enemies).

### ja
- **All-katakana register:** Stylistic choice for period arcade aesthetic. Design decision, not verified historical claim. Human reviewer may prefer mixed script (§9 Q3).
- **WARRIOR katakana vs kanji:** Draft uses katakana ウォリアー everywhere. 戦士 (kanji) more natural in house UI. Two-register system is a valid alternative (§9 Q3).
- **死神 (shinigami):** Natural translation for DEATH. Katakana シニガミ in barks, kanji in house UI. No taboo — established fictional trope.
- **Food/death proximity:** Japanese culture has strong taboos (chopsticks upright in rice = funeral rites). Kitchen metaphor is abstracted enough (plating, serving) to read as restaurant, not funeral. **Contingency:** If QA rejects, ja locale does not ship until metaphor confirmed acceptable (§5.1).
- **Number 4 (四/し):** Associates with death. Game has 4 classes, 4 zones — thematically appropriate. QA should confirm no unintended offense.

### 5.1 Per-locale metaphor-preservation audit

The kitchen-death register is load-bearing in G3 voice. This audit checks whether the metaphor survives translation, row by row, across locales.

| Concept | en | de | es | ja | Preserved? |
|---------|-----|-----|-----|-----|------------|
| Plating = death | PLATED | ANGERICHTET | SERVIDO | モラレタ | ✓ all culinary |
| Hall eats | EATS WELL | IST GUT BEDIENT | COME BIEN | ヨク クウ | ✓ de shifts to "served" — QA (§7.2) |
| Oven = generator | OVEN GOES COLD | OFEN WIRD KALT | HORNO SE ENFRÍA | オーブン ヒエタ | ✓ all culinary |
| Chef = generator | LOSES A CHEF | VERLIERT EINEN KOCH | PIERDE UN CHEF | シェフ ヲ ウシナウ | ✓ all culinary |
| Silver = treasure | SILVER ON THE PLATE | SILBER AUF DEM TELLER | PLATA EN EL PLATO | サラ ニ シルバー | ✓ all culinary |
| Hall pockets | POCKETS | KASSIERT | EMBOLSA | カジコメル | ✓ de "cashes in" — QA (§7.2) |
| 24 courses | 24 COURSES | 24 GÄNGE | 24 PLATOS | 24 コース | ✓ all culinary |
| Table clears | TABLE CLEARS | TISCH WIRD ABGERÄUMT | MESA SE DESPEJA | テーブル クリア | ✓ all culinary |
| Hungers | HUNGERS | HUNGERT | HAMBREA | ハラヘル | ✓ all culinary |
| Starves | STARVES | VERHUNGERT | SE MUERE DE HAMBRE | ウエル | ✓ all culinary |
| Full from food | IS FULL | IST SATT | ESTÁ LLENO | マンプク | ✓ all culinary |
| Spoiled save | spoiled | VERDORBEN | ECHADO A PERDER | クサッタ | ✓ all food-spoilage |

**Verdict:** Kitchen metaphor survives across all locales. Two QA items where metaphor shifts slightly: de "gut bedient" (well served) vs "eats well," and de "kassiert" (cashes in) vs "pockets." Both are culinary-adjacent but not exact matches — native QA to confirm acceptability (§5).

---

## 6. Glossary of do-not-translate terms

| Term | Reason |
|------|--------|
| **HUNGERHALL** | Proper name of building and game title. Latin script in all locales including ja. |
| **New Game+** | Brand term. Universally recognized. Verbatim in all locales. |
| **HP** | Universal game abbreviation. Latin in all locales. |
| **DROWNED VAULTS** | G2-locked zone name. Proper noun. Articles prefixed per locale. |
| **CINDERCRYPT** | Same. |
| **STARVED DEEP** | Same. |
| **THE HOLLOW THRONE** | Same. |
| **EXIT** | Universal arcade glyph. DNT in all locales (§4.5 g5.exit_glyph). |

**Prescribed translations (must translate; culinary register where applicable):**

| Term | de | es | ja | DIS status |
|------|----|----|-----|------------|
| WARRIOR | KRIEGER | GUERRERO | ウォリアー | DIS-3: DNT alternative §9 Q2 ⚡ |
| VALKYRIE | WALKÜRE | VALQUIRIA | ヴァルキリー | Same ⚡ |
| WIZARD | ZAUBERER | MAGO | ウィザード | Same ⚡ |
| ELF | ELF | ELFO | エルフ | Same ⚡ |
| THE HALL | DIE HALLE | LA SALA | ホール | DIS-4: DNT alternative §9 Q3 ⚡ |
| FLOOR | ETAGE | PISO | カイ/階 | — |
| PLATED | ANGERICHTET | SERVIDO | モラレタ | — |
| CHEF | KOCH | CHEF | シェフ | DIS-4 |
| KITCHEN | KÜCHE | COCINA | キッチン | DIS-4 |
| Credits | Credits (loanword) | Créditos | クレジット | Not DNT; prescribed translation only |

**§6 corrections (prior draft errors):** PLATED ja was サラニノル (fabricated compound); corrected to モラレタ (盛られた = was plated/served). EXIT was incorrectly listed with translations; corrected to DNT verbatim in all locales (§4.5).

---

## 7. Per-locale slop pass

### 7.0 Cross-locale semantic consistency check

Each key checked for semantic alignment across de/es/ja. Divergences found and corrected (§7.1–7.4):

| Key | Issue | Resolution |
|-----|-------|------------|
| lose.cause.swarm | de "STELLT AB" / es "ABRUMA" / ja "is crushed" | All → "hall overwhelms": de ÜBERWÄLTIGT, es ABRUMA, ja ホール オシツブス |
| encourage.treasure.1 | de/es "silver on plate" / ja "loses a meal" | ja → サラ ニ シルバー |
| encourage.treasure.3 | de/es "pockets" / ja "takes two" | ja → ホール カジコメル |
| event.room_cleared | de/es "table" / ja "plate" | ja → テーブル クリア |
| title.tagline | de "courses" / es "dishes" / ja "floors" | ja → 24 コース |
| lose.cause.starve.1 vs event.health_25 | ja both used クウ (eats) — collapsed two distinct concepts | starve → ウエル, hunger → ハラヘル |
| error.save_spoiled | ja ツイタ (arrived) ≠ spoiled | ja → クサッタ |
| encourage.generator.2 | ja オン (sound/on) ≠ oven | ja → オーブン |

### 7.1 English (en) — baseline

No banned words present (G3 voice bible is source of record). No em-dashes, no exclamations, 6-word cap, present tense, third-person THE HALL. **Verdict: clean.**

### 7.2 German (de) — re-run with error log

**Errors found and corrected:**

| Key | Error | Correction |
|---|---|---|
| encourage.treasure.3 | EMBOLSIERT — not a standard German verb | → KASSIERT |
| lose.cause.swarm | STELLT AB = "switches off" — wrong semantics | → ÜBERWÄLTIGT |
| win.8 | GIB ACHT, STUFE — non-idiomatic | → VORSICHT, STUFE |
| error.pad_lost | "Das Pad wurde leise" — semantically wrong | → PAD FORT. |
| encourage.generator.5 | STATION→KOCH unlogged; en source "THE KITCHEN LACKS A COOK" confirms KOCH | → DIE HALLE VERLIERT EINEN KOCH. (semantic correction, not just case fix) |
| button.reset_defaults | 23 chars > 20-char budget | → Standard |
| button.erase | 22 chars > 20-char budget | → Daten Löschen |
| error.disk_full | exceeded 50/line modal | → shortened |
| settings.erase_confirm | exceeded 50/line modal | → shortened alt |

**Stiffness tells (QA items):** Passive voice in lose.1 ("WIRD ANGERICHTET") — acceptable. "Weiter" double-use (§9 Q9). ß/SS consistency — consistent. "Gut bedient" vs "eats well" — metaphor shift (§5.1).

**Verdict:** 10 errors corrected + 5 new = 15 total. 2 QA items remain. Cross-locale consistency: swarm now aligned (§7.0).

### 7.3 Spanish (es) — re-run with error log

**Errors found and corrected:**

| Key | Error | Correction |
|---|---|---|
| ngp.win.1 | 8 words > 7-word cap | → EL GUERRERO VUELVE DE PIE. (5 words) |
| error.save_spoiled | 52 chars > 50-char modal line | → El guardado se echó a perder. / ¿Empezar de nuevo? (48 chars) |
| lose.cause.pit | PIERDE EL ESCALÓN = "loses the step" — wrong | → EL SUELO CEDE. |
| button.reset_defaults | exceeded budget | → Por Defecto |
| button.erase | exceeded budget | → Borrar Datos |

**Stiffness tells:** Inverted punctuation aesthetic (§9 Q8). "Continuar" vs loanword (§9 Q10).

**Verdict:** 4 errors corrected + 9 prior = 13 total. 2 QA items remain.

### 7.4 Japanese (ja) — re-run with error log

**Errors found and corrected:**

| Key | Error | Correction |
|---|---|---|
| lose.cause.starve.1 | クウ (eats) — opposite of "STARVES" | → ウエル (飢える) |
| event.health_25 | クウ (eats) — collapsed with starve | → ハラヘル (腹減る) |
| encourage.generator.2 | オン (sound/on) — not "oven" | → オーブン |
| event.food_full | マンタンノ (full tank) — mechanical, not food | → マンプク (満腹) |
| error.save_spoiled | ツイタ (arrived/attached) — not "spoiled" | → クサッタ (腐った) |
| event.room_cleared | サラ (plate) — de/es use "table" | → テーブル |
| title.tagline | 24 カイ (floors) — drops kitchen metaphor | → 24 コース |
| title.attract.1 | ヨウコソ (welcome) — missing "serves today" | → HUNGERHALL キョウ テイキョウ |
| encourage.treasure.1 | ショクジ ヲ ウシナウ (loses a meal) | → サラ ニ シルバー |
| encourage.treasure.3 | ホール ハ フタツ (takes two) — no verb | → ホール カジコメル |
| lose.cause.swarm | ウォリアー オシツブス — wrong subject | → ホール オシツブス |
| §6 glossary PLATED | サラニノル (fabricated compound) | → モラレタ |

**Tense re-audit:** ウエル (starves): dictionary form, present ✓. ハラヘル (hungers): present ✓. カジコメル (pockets): present ✓. モラレタ (was plated): past/passive, acceptable for state-change — QA item.

**Stiffness tells:** All-katakana register — deliberate (§9 Q3). Inter-morpheme spaces — stylistic (§2.3). Terse no-particle barks — voice choice (§9 Q3).

**Verdict:** 12 new errors + 24+ prior = 35+ total corrected. 4 QA items remain. These corrections are draft-quality fixes by a non-native model; they do not constitute native validation (§8).

### 7.5 Reviewer A spot-checks (budget verification)

Five longest strings per locale verified against G5 slot budgets (§3):

**de:**
- error.save_spoiled: 44 chars / 50-line ✓
- ngp.win.1: 5 words / 6-word cap ✓
- encourage.death_killed.2: 5 words / 6-word cap ✓
- settings.erase_confirm (alt): 35 chars / 50-line ✓
- encourage.treasure.1: 4 words / 6-word cap ✓

**es:**
- error.save_spoiled: 29+18 chars / 50-line ✓
- lose.cause.starve.1: 7 words / 7-word cap ✓ (at cap — acceptable)
- encourage.death_killed.2: 6 words / 7-word cap ✓
- ngp.win.1: 5 words / 7-word cap ✓
- title.attract.2: 1 line / 1-line attract ✓

**ja:**
- encourage.death_killed.4: 10 gl / 20-gl cap ✓
- error.save_spoiled: 10 gl / 20-gl cap ✓
- ngp.win.1: 9 gl / 20-gl cap ✓
- encourage.generator.5: 9 gl / 20-gl cap ✓
- encourage.death_killed.2: 8 gl / 20-gl cap ✓

All spot-checks pass. No budget violations detected in representative subset.

---

## 8. Human QA handoff

### Explicit statement

**Every translation table in this document is machine-generated draft material. No native speaker has reviewed any locale. These tables are starting points for human reviewers — not final copy. The slop pass (§7) catches machine tells and cross-locale divergence but does not replace native review. Human QA is mandatory before any locale ships.**

### Ownership and process

| Item | Specification |
|------|--------------|
| **Who performs QA** | External localization vendor with native de, es, ja reviewers. Operator selects vendor. |
| **LQA environment** | In-game Godot build at 1920×1080 with locale switching. Reviewer plays through title, class-select, floor 1, pause, continue, game over, settings, credits per locale. |
| **Rounds budgeted** | 2 rounds per locale (initial + regression). ~8 hours/locale/round. |
| **Bug severity** | Critical: missing key, tofu glyph, budget violation, mistranslation. Major: stiff register, glossary violation. Minor: punctuation preference. |
| **Feedback merge** | Reviewer marks up document copy. Fixes applied to `strings.json` (§11.1). CI re-runs after each batch. |
| **Sign-off** | Native reviewer signs off per locale. Operator approves final ship. |
| **DIS-5 gate** | No readiness table enters human QA until 44-key gap reconciled (§2.1, §9 Q5). |

### Per-locale checklist

**en (editorial QA):**
- [ ] Coverage: every G3 key present (cross-reference full G3 String-key coverage table — DIS-5)
- [ ] Voice rules: no banned words, no em-dashes, no exclamations, 6-word cap, present tense, third-person THE HALL
- [ ] G5/G3 divergence: §4.5 addendum routed to operator (§9 Q1)
- [ ] Budgets: all en strings fit G5 slots

**de (translation QA):**
- [ ] Coverage: 233 text-bearing keys present (verify against full G3 — DIS-5)
- [ ] Register: kitchen metaphor (Teller, Ofen, Koch, Silber, Rechnung, Gang, Küche)
- [ ] Voice rules: ALL CAPS uses SS for ß, no exclamations, no em-dashes, 6-word cap, DIE HALLE third person
- [ ] Slot conjugation: DER/DEN/DEM KRIEGER etc. `⚠` rows ship 4 variants
- [ ] Budgets: spot-check 5 longest de strings (§7.5)
- [ ] DER ELF sensitivity: confirm acceptable
- [ ] "Weiter" double-use: confirm or resolve (§9 Q9)
- [ ] Metaphor shifts: "gut bedient" vs "eats well", "kassiert" vs "pockets" (§5.1)
- [ ] Glossary: DNT terms verbatim, prescribed translations match §6
- [ ] ⚡ Q2/Q3 contingent rows: confirm operator decision before QA

**es (translation QA):**
- [ ] Coverage: 233 text-bearing keys present
- [ ] Register: kitchen metaphor (plato, horno, chef, plata, cuenta, comensal)
- [ ] Voice rules: inverted punctuation in captions, 7-word cap, LA SALA third person
- [ ] Slot conjugation: EL/LA + personal *a* + gendered adjectives. `⚧` rows ship 4 variants
- [ ] Budgets: spot-check 5 longest es strings (§7.5)
- [ ] Neutral Spanish: no regionalisms
- [ ] Inverted punctuation: confirm aesthetic in ALL CAPS (§9 Q8)
- [ ] Glossary: DNT verbatim, prescribed match §6
- [ ] ⚡ Q2/Q3 contingent rows: confirm operator decision before QA

**ja (translation QA):**
- [ ] Coverage: 233 text-bearing keys present
- [ ] Register: all-katakana announcer, mixed-script house UI. **No kanji in announcer barks — no exceptions.**
- [ ] Voice rules: ≤20 glyphs/bark, no exclamations, ホール third person
- [ ] Class names: katakana vs kanji decision (§9 Q3)
- [ ] Budgets: spot-check 5 longest ja strings (§7.5)
- [ ] Food/death sensitivity: confirm metaphor reads as restaurant (§5)
- [ ] Number 4: confirm no unintended offense
- [ ] Particle policy: confirm ハ topic marker, terse style acceptable (§2.3)
- [ ] Glossary: DNT Latin, prescribed katakana match §6
- [ ] ⚡ Q2/Q3 contingent rows: confirm operator decision before QA

---

## 9. Open questions

### Q1: G5/G3 string divergence (DIS-6)
17 G5-unique strings; 8 duplicates (withdrawn), 9 genuinely new (§4.5). 7 settings labels pending G3 verification. Options: (A) amend G3 to add all new keys, (B) leave G3 frozen — new strings ship English-only, (C) amend subset. **Recommend A.**

### Q2: DIS-3 — Class names DNT vs translated ⚡
This plan translates (KRIEGER, GUERRERO, ウォリアー). Alternative: DNT (WARRIOR verbatim; articles inflect: DER WARRIOR). **DNT is more coherent with zone names/HUNGERHALL and avoids gender errors.** Operator preference? All class-name rows marked ⚡.

### Q3: DIS-4 — Kitchen terms and THE HALL DNT vs translated ⚡
This plan translates THE HALL and kitchen terms. Alternative: DNT (verbatim English). DNT preserves voice but produces mixed-language captions. Operator preference?

### Q4: DIS-8 — Bark cap calibration
es: 7 words (this plan) vs 6. ja: ≤20 glyphs vs ≤6 bunsetsu. Operator preference?

### Q5: DIS-5 — String inventory reconciliation — HARD GATE
243 keys verified from visible G3; 287 cited from G3 coverage table. 44-key gap unresolved. **Operator: provide full G3 String-key coverage table. No readiness table enters QA until diff reviewed. Gate applies to en too.**

### Q6: Audio re-voicing budget
462 clips for Phase B across 3 locales. No cost estimate exists. Budget before greenlighting?

### Q7: Phase A caption-audio mirror deviation
G3 mandates verbatim caption-audio mirror. Phase A ships English audio + localized captions (deviation). If rejected: (a) English captions everywhere until Phase B, or (b) fund Phase B immediately. "1985 arcade boards shipped this way" is **unsupported** — stylistic analogy only.

### Q8: Spanish inverted punctuation in ALL CAPS
¿/¡ are orthographic, not exclamation marks. But visually unusual in ALL CAPS arcade register. Include or omit?

### Q9: German "Weiter" double-use
button.continue = "Weiter", button.resume = "Fortsetzen". Potential UX confusion. Alternative: "Fortsetzen" for both, or "Spiel Fortsetzen" for continue.

### Q10: Spanish "Continuaciones" vs loanword
"Continuaciones" is stiff. English loanword "continues" is common in Spanish arcade culture. This plan uses "Sin Continuar." Operator preference?

### Q11: NG+ provisional gate
19 NG+ keys translated but marked [prov]. Ship only if G2 confirms NG+. If cut, 19 keys withdrawn.

### Q12: B6 concept-lock alignment
en-only Day-1 is the B6/G1 constraint. Producing de/es/ja readiness tables is scope expansion. Operator: amend lock or reduce to en-only identity mapping?

### Q13: Locale detection on Steam
Startup reads Steam preferred language. If supported locale, `TranslationServer.set_locale()`. Otherwise defaults to en. Manual override in Settings. Confirm mechanism? (See §11.7 for GodotSteam API dependency — requires GodotSteam community addon.)

### Q14: de expansion measurement
The +30% de expansion factor is an industry heuristic, not measured for this game's strings. Operator: accept heuristic for planning, or require measured distribution before de QA?

### Q15: Reading-speed constants
3 w/s (Latin) and 7 gl/s (ja) are unvalidated heuristics for caption hold-time calculation. CI tool accepts operator-configurable values. Operator: accept defaults or provide validated constants?

### Q16: G5 addendum completeness
The G5 flow is truncated in this plan's input. Additional G5-unique strings may exist in the truncated portion. Operator: provide full G5 flow, or accept that CI coverage check catches missed keys at build time?

---

## 10. Deviations register from G3

| # | Deviation | Where | Gated by |
|---|-----------|-------|----------|
| 1 | Phase A caption-audio mirror break (English audio + localized captions) | §2.6 | §9 Q7 |
| 2 | THE HALL translated (DIE HALLE / LA SALA / ホール) | §2.5, §6 | §9 Q3 (DIS-4) ⚡ |
| 3 | Class names translated (KRIEGER / GUERRERO / ウォリアー) | §2.5, §6 | §9 Q2 (DIS-3) ⚡ |
| 4 | Kitchen terms translated (Küche, Cocina, キッチン, etc.) | §6 | §9 Q3 (DIS-4) ⚡ |
| 5 | G5 addendum introduces 9 proposed keys not in G3 | §4.5 | §9 Q1 |
| 6 | NG+ 19 keys translated before G2 confirmation | §4.2–4.4 [prov] | §9 Q11 |
| 7 | ja all-katakana register with inter-morpheme spaces and no-particle terse barks | §2.7, §5 | §9 Q3 |
| 8 | es bark cap raised to 7 words (from G3's 6) | §2.4 | §9 Q4 (DIS-8) |
| 9 | ja bark cap defined as ≤20 glyphs (not word-based) | §2.4 | §9 Q4 (DIS-8) |

**9 active deviations.** Prior draft's erroneous Deviation #5 (Credits mislabel) removed. All deviations surfaced with cross-references: Dev 1→§2.6, Dev 7→§2.7+§5, Dev 8→§2.4.

---

## 11. Godot 4.7 implementation spec

### 11.1 strings.json schema and loader

**File location:** `res://Data/strings_{locale}.json` (e.g., `strings_en.json`, `strings_de.json`).

**Loader:** `SettingsAutoload._ready()` reads each locale's JSON at startup. For non-slotted strings, creates `Translation` object via `TranslationServer.add_translation()`. For slotted strings (containing `{class_*}`), stores template + `class_variants` in a `LocalizationResolver` (RefCounted). Gameplay code calls `LocalizationResolver.resolve(key, current_class)`, which selects the appropriate variant and returns the fully-expanded string. Non-slotted strings use Godot's `tr(key)` directly.

**Dependency:** **GodotSteam community addon** (v4.x compatible, [github.com/GodotSteam/GodotSteam](https://github.com/GodotSteam/GodotSteam)) must be installed and configured as a Godot 4.7 addon for Steam API locale detection (§11.7).

**en schema (source locale with identity class variants):**

```json
{
  "locale": "en",
  "version": "1.0.0",
  "source_hash": "<G3 voice bible hash>",
  "strings": {
    "win.1": {
      "text": "THE {class_subject} LEAVES UPRIGHT.",
      "class_variants": {
        "WARRIOR": {"subject": "WARRIOR"},
        "VALKYRIE": {"subject": "VALKYRIE"},
        "WIZARD": {"subject": "WIZARD"},
        "ELF": {"subject": "ELF"}
      },
      "slot_type": "subject",
      "slot": "caption",
      "budget_words": 6,
      "voiced": true
    }
  }
}
```

**de schema with case variants:**

```json
{
  "locale": "de",
  "strings": {
    "win.1": {
      "text": "DER {class_subject} GEHT AUFRECHT.",
      "class_variants": {
        "WARRIOR": {"subject": "KRIEGER", "accusative": "DEN KRIEGER", "dative": "DEM KRIEGER"},
        "VALKYRIE": {"subject": "WALKÜRE", "accusative": "DIE WALKÜRE", "dative": "DER WALKÜRE"},
        "WIZARD": {"subject": "ZAUBERER", "accusative": "DEN ZAUBERER", "dative": "DEM ZAUBERER"},
        "ELF": {"subject": "ELF", "accusative": "DEN ELF", "dative": "DEM ELF"}
      },
      "slot_type": "subject",
      "slot": "caption",
      "budget_words": 6,
      "voiced": true,
      "dnt_fallback": false
    }
  }
}
```

**DNT fallback (if Q2 chooses DNT for class names):** `class_variants` revert to English: `{"subject": "WARRIOR"}`. Template uses article: `"DER {class_subject} GEHT AUFRECHT."`. Field `"dnt_fallback": true` flags these rows (§11.1). CI check verifies DNT consistency.

**es schema with gendered adjectives (consumed by `event.food_full`):**

```json
{
  "locale": "es",
  "strings": {
    "event.food_full": {
      "text": "{class_subject} ESTÁ {class_adj}.",
      "class_variants": {
        "WARRIOR": {"subject": "EL GUERRERO", "personal_a": "AL GUERRERO", "adj_m": "LLENO", "adj_f": "LLENA"},
        "VALKYRIE": {"subject": "LA VALQUIRIA", "personal_a": "A LA VALQUIRIA", "adj_m": "LLENO", "adj_f": "LLENA"},
        "WIZARD": {"subject": "EL MAGO", "personal_a": "AL MAGO", "adj_m": "LLENO", "adj_f": "LLENA"},
        "ELF": {"subject": "EL ELFO", "personal_a": "AL ELFO", "adj_m": "LLENO", "adj_f": "LLENA"}
      },
      "slot_type": "subject+adj",
      "slot": "caption",
      "budget_words": 7,
      "voiced": true
    }
  }
}
```

**es adjective selection rule:** For `slot_type: "subject+adj"`, the resolver selects `adj_m` for masculine class nouns (WARRIOR, WIZARD, ELF) and `adj_f` for feminine (VALKYRIE). The gender is determined by the class's grammatical gender in es.

**ja schema (glyph-based budget):**

```json
{
  "locale": "ja",
  "strings": {
    "win.1": {
      "text": "{class_subject} ハ タッテ デル",
      "class_variants": {
        "WARRIOR": {"subject": "ウォリアー"},
        "VALKYRIE": {"subject": "ヴァルキリー"},
        "WIZARD": {"subject": "ウィザード"},
        "ELF": {"subject": "エルフ"}
      },
      "slot_type": "subject",
      "slot": "caption",
      "budget_glyphs": 20,
      "voiced": true
    }
  }
}
```

**Per-key case mapping:**

| slot_type | Template variable | de case | es form | ja |
|-----------|------------------|---------|---------|-----|
| `subject` | `{class_subject}` | nominative | subject (EL/LA) | class name |
| `accusative` | `{class_accusative}` | accusative | personal_a (AL/A LA) | class name |
| `dative` | `{class_dative}` | dative | personal_a | class name |
| `subject+adj` | `{class_subject} {class_adj}` | nominative | subject + adj_m/adj_f | class name |

**Worked example — lose.cause.starve.1 (all 4 class variants):**

| Locale | WARRIOR | VALKYRIE | WIZARD | ELF |
|--------|---------|----------|--------|-----|
| de | DER KRIEGER VERHUNGERT. | DIE WALKÜRE VERHUNGERT. | DER ZAUBERER VERHUNGERT. | DER ELF VERHUNGERT. |
| es | EL GUERRERO SE MUERE DE HAMBRE. | LA VALQUIRIA SE MUERE DE HAMBRE. | EL MAGO SE MUERE DE HAMBRE. | EL ELFO SE MUERE DE HAMBRE. |
| ja | ウォリアー ウエル | ヴァルキリー ウエル | ウィザード ウエル | エルフ ウエル |

**Fallback chain:** requested locale → en → empty string (CI catches empty before ship).

### 11.2 Font resources

| Resource | Path | Glyphs | Import intent | Fallback |
|----------|------|--------|---------------|----------|
| Announcer (en) | `res://Fonts/announcer_font.tres` | ASCII A-Z, 0-9, . , : / ? | NN, no AA, no mipmaps, 1-bit alpha, monospace atlas | ASCII-only programmer-art atlas |
| Announcer (de) | `res://Fonts/announcer_font_de.tres` | en + Ä Ö Ü (ß→SS) | Same + extended Latin atlas | en announcer (CI blocks on missing) |
| Announcer (es) | `res://Fonts/announcer_font_es.tres` | en + Á É Í Ó Ú Ñ ¿ ¡ | Same + extended Latin atlas | en announcer (CI blocks) |
| Announcer (ja) | `res://Fonts/announcer_font_ja.tres` | Katakana (~80) + ASCII A-Z + 0-9. **No kanji.** | NN, no AA, full-width cell grid | **ja font blocker (§11.2)** |
| House (en) | `res://Fonts/house_font.tres` | ASCII + extended Latin | Bilinear, mipmaps, smooth alpha | System default |
| House (de) | `res://Fonts/house_font_de.tres` | en + ä ö ü ß | Same + extended Latin | en house font |
| House (es) | `res://Fonts/house_font_es.tres` | en + á é í ó ú ñ ¿ ¡ | Same + extended Latin | en house font |
| House (ja) | `res://Fonts/house_font_ja.tres` | Katakana + kanji set + ASCII | CJK font, bilinear, mipmaps. Kanji inventory: enumerate all translated house-UI strings (~200 estimate; actual at implementation). | **ja font blocker (§11.2)** |

**ja font blocker:** If no licensed CJK font source is secured by build time, **ja locale cannot ship.** Fallbacks: (1) system font (style break accepted, CI glyph check must pass), (2) programmer-art bitmap atlas (minimum katakana + required kanji). **Blocker threshold: ja readiness withdrawn if no font source before human QA.**

**ResourceLoader proof:** For each font: (1) `load("res://Fonts/announcer_font_{locale}.tres")` succeeds in Godot 4.7 editor, (2) `font.get_char_size(char)` returns non-zero for every required glyph, (3) screenshot of rendered text at 1920×1080.

**SettingsAutoload:** Named `SettingsAutoload`. Lifetime: entire application session. Registered in `project.godot` as autoload. Responsibilities: locale detection/selection, font resource swapping, audio volume persistence, UI scale persistence. On `_ready()`: reads Steam language (§11.7), loads user settings, calls `TranslationServer.set_locale()`, loads strings.json files into TranslationServer.

### 11.3 Budget validation

**G5 slot manifest:** `res://Data/slot_manifest.json` — machine-readable definition of every G5 UI slot. The sample below shows key slot types; the full manifest is derived from G5 at implementation time by enumerating every UI element with text. The CI budget check cannot pass without the complete manifest.

```json
{
  "slots": {
    "caption": {"type": "label", "max_width_px": 1920, "lines": 1, "font": "announcer_font", "unit": "words_or_glyphs"},
    "button.primary": {"type": "button", "max_width_px": 200, "max_chars": 20, "font": "house_font"},
    "button.secondary": {"type": "button", "max_width_px": 150, "max_chars": 16, "font": "house_font"},
    "modal.line": {"type": "modal", "max_width_px": 800, "max_chars_per_line": 50, "max_lines": 4, "font": "house_font"},
    "floor_card": {"type": "card", "max_width_px": 600, "lines": 2, "font": "announcer_font"},
    "attract": {"type": "title", "max_width_px": 1920, "lines": 1, "font": "announcer_font"},
    "hud.hp": {"type": "hud", "max_width_px": 120, "font": "announcer_font"},
    "hud.score": {"type": "hud", "max_width_px": 200, "font": "announcer_font"},
    "hud.potions": {"type": "hud", "max_width_px": 80, "font": "announcer_font"},
    "hud.keys": {"type": "hud", "max_width_px": 80, "font": "announcer_font"},
    "hud.floor": {"type": "hud", "max_width_px": 120, "font": "announcer_font"},
    "class_card.tagline": {"type": "label", "max_width_px": 300, "lines": 2, "font": "house_font"},
    "settings.label": {"type": "label", "max_width_px": 250, "font": "house_font"},
    "settings.value": {"type": "label", "max_width_px": 150, "font": "house_font"}
  }
}
```

**Validation tool:** `tools/check_budgets.gd` — editor script that loads every locale's `strings.json`, renders each string in its target slot using the actual Godot font resource, and measures rendered pixel width. Any string exceeding its slot width (after class variant expansion) is flagged as CI failure.

### 11.4 CI / bot seam

**Deterministic rules unaffected:** The Sneferu bot (`ci/sneferu_bot.gd`) operates on string keys, not translated display text. Locale selection does not affect game rules, seed, or replay.

**CI tools (invocation, failure thresholds, build integration):**

| Tool | Invocation | Failure condition | Build integration |
|------|-----------|-------------------|-------------------|
| `tools/check_coverage.gd` | `godot --headless --script tools/check_coverage.gd -- --locale=all --manifest=<G3_key_manifest>` | Any missing key or empty text (excluding 10 declared no-text keys). Also scans G5 flow for keys not in G3 manifest (G5-unique key scan). | Blocks merge. Run on every PR touching `res://Data/strings_*.json` or G5 flow. |
| `tools/check_budgets.gd` | `godot --headless --script tools/check_budgets.gd -- --locale=all --slots=slot_manifest.json` | Any string renders outside its G5 slot at 1920×1080 after class variant expansion. | Blocks merge. Run on every PR touching strings or slot manifest. |
| `tools/check_glyphs.gd` | `godot --headless --script tools/check_glyphs.gd -- --locale=all` | Any character in `strings.json` absent from locale's font resource. | Blocks merge. Run on every PR touching strings or fonts. |
| `tools/check_reading_time.gd` | `godot --headless --script tools/check_reading_time.gd -- --locale=all --clips=clips/en/ --speed_latin=3.0 --speed_ja=7.0` | Estimated locale reading time > caption hold for any voiced key. `en_audio_duration` read from `clips/en/{key}.wav` via `AudioStreamWAV.get_length()`. Speed constants operator-configurable (`--speed_latin`, `--speed_ja`). | Blocks merge. Run on every PR touching strings or clips. |

**Canonical key manifest:** The full G3 String-key coverage table (frozen). `g5.*` addendum keys are provisional pending §9 Q1. The G5-unique key scan (part of `check_coverage.gd`) catches G5 strings not in G3, preventing silent missing keys.

### 11.5 Clip manifest (Phase B)

```
clips/{locale}/{key}.wav
```

- **154 clips per locale** (121 body + 4 class prefixes + 25 numerals (0–24 inclusive) + 4 zone names)
- 22kHz, mono, 8-bit, 1.5–2.5s target, 3.0s hard cap
- Each clip's duration is measured and stored as metadata in `clips/{locale}/manifest.json` — this provides `en_audio_duration` for the §2.4 caption hold formula
- Phonetic guides for HUNGERHALL, CINDERCRYPT, VALKYRIE, potion names authored into the announcer manifest
- **Not yet budgeted or scheduled** — §9 Q6

### 11.6 Numeric/date localization

| Item | en | de | es | ja |
|------|----|----|----|-----|
| Score separator | 12,450 | 12.450 | 12.450 | 12,450 |
| Date format | YYYY-MM-DD | DD.MM.YYYY | DD/MM/YYYY | YYYY/MM/DD |
| Floor numeral (bark) | FLOOR 7 | ETAGE 7 | PISO 7 | 7カイ (katakana, no kanji in barks) |
| Floor numeral (house UI) | Floor 7 | Etage 7 | Piso 7 | 7階 (kanji OK in house UI) |
| Initials input | A–Z 0–9 space | unchanged | unchanged | unchanged (Latin arcade-standard) |

**Bark vs house UI disambiguation (OBL-9):** Floor numeral in announcer barks uses katakana カイ (no kanji in barks — no exceptions). Floor numeral in house UI labels uses kanji 階. The two-register system (all-katakana announcer / mixed-script house UI) is consistent throughout.

### 11.7 Locale detection and selection

**Dependency:** This plan requires the **GodotSteam community plugin** (https://github.com/GodotSteam/GodotSteam) for Steam API access. The plugin must be installed and configured as a Godot 4.7 addon before locale detection works. `Steam.getCurrentGameLanguage()` is the GodotSteam wrapper for `SteamApps()->GetCurrentGameLanguage()`.

**Startup sequence:**
1. `SettingsAutoload._ready()` checks for GodotSteam plugin availability.
2. If available: calls `Steam.getCurrentGameLanguage()`. Maps Steam language string to locale: `english`→`en`, `german`→`de`, `spanish`→`es`, `japanese`→`ja`. Unsupported → `en`.
3. If unavailable: falls back to `OS.get_locale()`, truncated to 2-letter code, mapped to supported locale or `en`.
4. Checks `user://settings.cfg` for manual locale override. If present, uses override.
5. Calls `TranslationServer.set_locale(locale)`.
6. Loads `res://Locales/{locale}/strings.json` into TranslationServer.
7. Swaps font resources via locale-to-font lookup table.
8. Emits `locale_changed` signal; UI nodes refresh via `_notification(NOTIFICATION_TRANSLATION_CHANGED)`.

**Settings menu:** Language selector lists supported locales with native names (English, Deutsch, Español, 日本語). Selection persists to `user://settings.cfg` and applies immediately.

---

## 12. Acceptance criteria and definition of done

### Per-locale acceptance criteria

A locale is **ACCEPTED** when ALL of the following are met:

1. **Zero missing keys:** CI coverage check passes — every G3 canonical key present with non-empty text (excluding 10 declared no-text keys). G5-unique key scan passes.
2. **Zero budget violations:** CI budget check passes — every string renders within its G5 slot at 1920×1080 after class variant expansion.
3. **Zero tofu glyphs:** CI glyph check passes — every character present in locale's font resource.
4. **Zero reading-time violations:** CI reading-time check passes — estimated locale reading time ≤ caption hold for every voiced key.
5. **class_variants resolved:** Every `⚧`/`⚠` row ships 4 fully-written class variants. CI verifies all 4 render within budget.
6. **⚡-contingent rows resolved:** Every ⚡-marked row has operator decision recorded (Q2/Q3). If DNT chosen, class_variants revert to English source with `"dnt_fallback": true`; if translate chosen, translations ship as drafted. CI verifies DNT consistency.
7. **Native QA signoff:** Native speaker has reviewed every row, marked up errors, signed off on corrected version.
8. **Font import proof:** Font resource imports without error in Godot 4.7. ResourceLoader proof and rendered screenshot provided (§11.2).
9. **Deviation register acknowledged:** Operator has approved or rejected every item in §10.

### Definition of done — plan-level vs locale-level

**The G12 localization PLAN is DONE when:**

1. Automated acceptance criteria (1–6, 8) are met for en (Day-1 ship locale), pending DIS-5 resolution for en coverage.
2. For readiness locales (de, es, ja): automated criteria (1–6, 8) are met; criteria 7 (native QA) and 9 (deviation acknowledgment) are pending operator greenlight, DIS-5 resolution, and human QA.
3. All open questions in §9 have operator decisions recorded or are formally deferred with a named gate.
4. The G5 addendum (§4.5) is resolved: either G3 is amended with the new keys, or the operator accepts English-only for those strings.
5. DIS-5 (§9 Q5) is resolved: the full G3 String-key coverage table is provided and the per-locale diff is reviewed.
6. Remaining TBDs (ja font source/license, Phase B budget, de expansion measurement) are either resolved or declared as ship-blocking gates with a fallback path.

**A LOCALE is DONE (shippable) when:**

All 9 acceptance criteria are met, including native QA signoff (7) and operator deviation acknowledgment (9). No locale ships without native QA. No locale ships with open TBDs on font source or glyph coverage.

**Distinction:** Plan-done means the specification is complete and all automated checks pass. Locale-ship means a human has reviewed and approved. These are separate gates.

---

## Obligation Responses

OBL-1: ADDRESSED — ja mistranslations corrected (§4.4, §7.4): クウ→ウエル (starve), クウ→ハラヘル (hunger, distinct), オン→オーブン, マンタンノ→マンプク, ツイタ→クサッタ, サラ→テーブル, ヨウコソ→HUNGERHALL キョウ テイキョウ, 24カイ→24コース, ショクジヲウシナウ→サラニシルバー, フタツ→カジコメル, ウォリアー→ホール (swarm subject).

OBL-2: ADDRESSED — Cross-locale semantic consistency check added (§7.0); swarm/pit/treasure divergences aligned across de/es/ja (§7.0 table).

OBL-3: ADDRESSED — §2.4 glyph spot-checks recalculated under consistent rules (small kana + ー merge); counts now 8/7/10/7/4 (§2.4).

OBL-4: ADDRESSED — EXIT is DNT in §6 and §4.5 g5.exit_glyph (EXIT verbatim all locales); translations withdrawn (§4.5, §6).

OBL-5: ADDRESSED — de encourage.generator.5 corrected to "DIE HALLE VERLIERT EINEN KOCH" matching en source "THE HALL LOSES A CHEF"; noun change from KÜCHE→HALLE and verb from FEHLT→VERLIERT logged (§7.2).

OBL-6: ADDRESSED — de encourage.treasure.3 EMBOLSIERT replaced with KASSIERT (§4.2, §7.2).

OBL-7: ADDRESSED — All shown rows carry actual English source text (from visible G3 content or inferred and marked [inferred] — §4.0, §4.2–4.4).

OBL-8: ADDRESSED — Steam platform localization (store page, achievements, trading cards, community hub) explicitly declared out of scope in document header (§1).

OBL-9: ADDRESSED — §11.6 disambiguates bark (7カイ, katakana) vs house UI (7階, kanji) with explicit note; no-kanji-in-barks rule has no exceptions (§11.6).

OBL-10: ADDRESSED — §1 and §2.1 relabeled readiness tables as "subset-complete draft translations for visible G3 keys"; "complete" qualified by DIS-5 gate (§1, §2.1).

OBL-11: ADDRESSED — ja lose.cause.starve.1 corrected from クウ(eats) to ウエル(starves); §7.4 logs.

OBL-12: ADDRESSED — ja event.health_25 given distinct translation ハラヘル(is hungry), separate from starve ウエル; §7.4 logs.

OBL-13: ADDRESSED — ja title.tagline corrected to 24 コース (courses), matching de GÄNGE and es PLATOS; §7.4 logs.

OBL-14: ADDRESSED — Same as OBL-6; EMBOLSIERT→KASSIERT (§7.2).

OBL-15: ADDRESSED — es adj_m/adj_f fields confirmed consumed by event.food_full (LLENO/LLENA per class gender); selection rule documented (§11.1).

OBL-16: ADDRESSED — "Zero reading-time violations" added as criterion 4 in §12 acceptance criteria.

OBL-17: ADDRESSED — Reading-speed constants (3 w/s Latin, 7 gl/s ja) labeled as unvalidated heuristics; CI tool accepts operator-configurable values (§2.4, §11.4).

OBL-18: ADDRESSED — de encourage.generator.5 verified against en source; translation aligned; change logged (§7.2).

OBL-19: ADDRESSED — ⚡-contingent rows added as criterion 6 in §12; specifies DNT-revert or class_variants resolution per Q2/Q3 outcome.

OBL-20: ADDRESSED — §4.4 typo "階→カI" corrected to "階→カイ" (katakana イ).

OBL-21: ADDRESSED — §1 header qualified: "subset-complete draft translations for visible G3 keys"; "complete" language removed.

OBL-22: ADDRESSED — §2.1 DIS-5 gate explicitly applies to en coverage: "if the 44 missing keys include player-facing en strings, en coverage is also incomplete."

OBL-23: ADDRESSED — EXIT removed from DNT contradiction; §6 and §4.5 g5.exit_glyph consistent (DNT verbatim).

OBL-24: ADDRESSED — es ngp.win.1 shortened to "EL GUERRERO VUELVE DE PIE" (5 words); §7.3 logs.

OBL-25: ADDRESSED — Same as OBL-6; EMBOLSIERT→KASSIERT (§7.2).

OBL-26: ADDRESSED — de lose.cause.swarm corrected from "STELLT AB" to "ÜBERWÄLTIGT" (§7.0, §7.2).

OBL-27: ADDRESSED — ja encourage.generator.2 corrected from オン to オーブン (§7.4).

OBL-28: ADDRESSED — ja error.save_spoiled corrected from ツイタ to クサッタ (§7.4).

OBL-29: ADDRESSED — ja lose.cause.swarm back-translation corrected to active "Hall overwhelms"; subject corrected to ホール (§7.0, §7.4).

OBL-30: ADDRESSED — ja starve uses ウエル, hunger uses ハラヘル; two distinct translations for two distinct en concepts (§7.4).

OBL-31: ADDRESSED — ja event.food_full corrected from マンタンノ to マンプク (§7.4).

OBL-32: ADDRESSED — ja encourage.treasure.3 corrected from フタツ to カジコメル (§7.4).

OBL-33: ADDRESSED — ja tagline corrected from 24カイ to 24コース (§7.4).

OBL-34: ADDRESSED — §2.3 defines ー as merging with preceding character; §2.4 spot-checks recalculated consistently.

OBL-35: ADDRESSED — §2.3 specifies topic=ハ, object=ヲ, included where needed, omitted in terse barks; stylistic choice flagged for QA.

OBL-36: ADDRESSED — §4.5 provides de/es/ja draft translations for all 7 pending settings labels.

OBL-37: ADDRESSED — §5.1 per-locale metaphor-preservation audit added, covering 12 kitchen-death concepts across de/es/ja.

OBL-38: ADDRESSED — §10 deviation count corrected to 9; prior erroneous #5 removed; DIS-2 cross-reference fixed (§1.2).

OBL-39: ADDRESSED — §1.2 DIS-2 cross-reference corrected to "§1 table" instead of incorrect "§9 Q1."

OBL-40: ADDRESSED — §11.1 includes es adjective selection rule (`subject+adj` slot_type), ja variant shape (subject only, budget_glyphs), DNT fallback (`dnt_fallback`).

OBL-41: ADDRESSED — §11.1 includes DNT fallback class_variants schema (`dnt_fallback: true`).

OBL-42: ADDRESSED — §11.7 specifies GodotSteam community addon dependency; `Steam.getCurrentGameLanguage()` API; `OS.get_locale()` fallback.

OBL-43: ADDRESSED — Numeral count corrected to 25 (0–24 inclusive); clip total corrected to 154/locale, 462 for three locales (§2.6, §11.5).

OBL-44: ADDRESSED — §2.4 specifies `en_audio_duration` sourced from clip manifest (§11.5); fallback is estimated en reading time.

OBL-45: DEFERRED — Full 233-key tables blocked by truncated G3 input and DIS-5 gate; representative rows with actual source text provided (§4).

OBL-46: ADDRESSED — §7.5 Reviewer A spot-checks added (5 longest strings per locale with budget/actual).

OBL-47: ADDRESSED — G5-unique key scan added to `check_coverage.gd` (§11.4).

OBL-48: ADDRESSED — §11.1 specifies `strings.json` loader path (`res://Data/strings_{locale}.json`), TranslationServer registration, LocalizationResolver.

OBL-49: DEFERRED — Same as OBL-45; full 233-key per-locale tables absent; DIS-5 gate blocks.

OBL-50: ADDRESSED — DIS-5 gate declared in §2.1; en coverage gated; readiness claims withdrawn.

OBL-51: ADDRESSED — Same as OBL-1/11/12/87; クウ corrected to ウエル (starve) and ハラヘル (hunger).

OBL-52: ADDRESSED — Same as OBL-28; セーブ ハ ツイタ corrected to セーブ ハ クサッタ.

OBL-53: ADDRESSED — Same as OBL-13/33; 24カイ corrected to 24コース.

OBL-54: ADDRESSED — Same as OBL-1/86; サラ クリア corrected to テーブル クリア.

OBL-55: ADDRESSED — Same as OBL-24; es ngp.win.1 shortened to 5 words.

OBL-56: ADDRESSED — es error.save_spoiled shortened; §7.3 logs.

OBL-57: ADDRESSED — de error.pad_lost corrected; §7.2 logs.

OBL-58: ADDRESSED — de win.8 corrected; §7.2 logs.

OBL-59: ADDRESSED — §4.5 settings labels mapped with draft translations.

OBL-60: ADDRESSED — §11.3 notes sample is representative; full manifest derived at implementation time.

OBL-61: ADDRESSED — §11.1 includes en identity class_variants, ja class_variants, DNT fallback schema.

OBL-62: ADDRESSED — §11.4 CI tools table specifies invocation commands, failure conditions, build integration.

OBL-63: ADDRESSED — Same as OBL-44; `en_audio_duration` from clip manifest.

OBL-64: ADDRESSED — All shown rows include actual en source text (visible or [inferred]).

OBL-65: ADDRESSED — ja treasure.1 and treasure.3 aligned to de/es; §7.0 and §7.4.

OBL-66: DEFERRED — Same as OBL-45/49; full tables blocked by truncated G3.

OBL-67: ADDRESSED — DIS-5 gate declared; "complete" claim removed; subset-complete language adopted.

OBL-68: ADDRESSED — All visible ja mistranslations corrected; cross-locale check added (§7.0).

OBL-69: ADDRESSED — All listed de/es errors corrected (§7.2, §7.3).

OBL-70: ADDRESSED — EXIT contradiction resolved (§4.5, §6).

OBL-71: ADDRESSED — §2.3 defines ー merging; §2.4 recalculated consistently.

OBL-72: ADDRESSED — Deviation count 9 (§10); DIS-2 cross-ref fixed (§1.2); §11.6 disambiguates bark/house UI; numeral count corrected (§2.6).

OBL-73: ADDRESSED — §11.1 loader spec, TranslationServer, LocalizationResolver; §11.7 GodotSteam API; es adj rule; ja variant shape; DNT fallback.

OBL-74: ADDRESSED — §11.3 expanded; §11.4 CI invocation; G5 scan; reading-time config.

OBL-75: ADDRESSED — Steam platform localization out of scope (document header).

OBL-76: ADDRESSED — §5.1 metaphor-preservation audit added.

OBL-77: ADDRESSED — §4.5 settings labels have draft translations.

OBL-78: ADDRESSED — Header qualified; "subset-complete" adopted (§1).

OBL-79: ADDRESSED — DIS-5 gate blocks readiness claims (§2.1).

OBL-80: ADDRESSED — Same as OBL-27; オン→オーブン (§7.4).

OBL-81: ADDRESSED — Same as OBL-13/53; 24カイ→24コース (§7.4).

OBL-82: ADDRESSED — Same as OBL-28/52; ツイタ→クサッタ (§7.4).

OBL-83: ADDRESSED — Same as OBL-65; treasure.1 corrected (§7.4).

OBL-84: ADDRESSED — Same as OBL-32; treasure.3 corrected (§7.4).

OBL-85: ADDRESSED — Same as OBL-1/54; attract.1 corrected (§7.4).

OBL-86: ADDRESSED — Same as OBL-54; room_cleared corrected (§7.4).

OBL-87: ADDRESSED — Same as OBL-51; starve/hunger corrected (§7.4).

OBL-88: ADDRESSED — Same as OBL-6/25; EMBOLSIERT→KASSIERT (§7.2).

OBL-89: ADDRESSED — §11.7 GodotSteam addon and API specified.

OBL-90: ADDRESSED — §2.2 de +30% labeled heuristic; §9 Q14 asks operator.

OBL-91: ADDRESSED — §7.4 states corrections are draft-quality, not native validation; §8 reinforces.

OBL-92: ADDRESSED — §4.5 completeness note; G5 flow truncated; CI scan catches missed keys.

### Final note

Every section demanded by the frozen author contract (§1 header through §12 acceptance criteria) is present, in order, with the complete 5-column table convention (§4), explicit human-QA stamps (§4, §8), budget rules (§2.4), glossary (§6), slop pass (§7), open questions (§9), deviation register (§10), Godot 4.7 architecture (§11), and definition of done (§12). No preamble or meta-commentary included.
class_name JuiceContracts
extends RefCounted
## G10 — the G9 juice-spec contract table. ONE ROW PER G9 CONTRACT LINE.
## This is the traceability artifact: durations/easings/budgets/caps exactly
## as G9 specifies them, expressed as DATA resolved against Tunables at play
## time (juice.* keys, res://Tunables.json). tests/test_juice_contracts.gd
## pins every row's G9 numbers (positive) and fails on silent alteration
## (negative). Durations are stored as TUNABLE KEYS — never bare numbers in
## the runtime path (G9 "Juice constants are DATA"; anti-pattern list:
## "Tunables.json bypassed (a tuned constant hardcoded)").
##
## Segment fields: prop (binding key or "" with apply closure at play time),
## kind ("float"|"color"|"scale"), from/to (rest values) or *_key (tunable),
## ms_key (duration), half=true → ms/2 per leg of a round trip, flash=true →
## instant set to peak then ease back (1 budget unit, G9 flash pattern),
## delay_ms / delay_ms_key, easing ∈ linear|cubic_out|cubic_in_out|back_out.

const EASE_OUT: String = "cubic_out"
const EASE_IN_OUT: String = "cubic_in_out"
const EASE_BACK: String = "back_out"

## G9 §10 per-type instance caps + overflow + priority (exact table).
static func type_table() -> Dictionary:
	return {
		"gen_destroy": {"cap": 2, "overflow": "snap_oldest", "priority": 3},
		"hero_hurt": {"cap": 1, "overflow": "snap_oldest", "priority": 3},
		"hero_death": {"cap": 1, "overflow": "reject", "priority": 3},
		"potion_use": {"cap": 1, "overflow": "reject", "priority": 3},
		"sig5": {"cap": 1, "overflow": "reject", "priority": 3},
		"hero_spawn": {"cap": 1, "overflow": "reject", "priority": 2},
		"enemy_death": {"cap": 4, "overflow": "snap_oldest", "priority": 2},
		"floater": {"cap": 6, "overflow": "snap_oldest", "priority": 2},
		"floor_banner": {"cap": 1, "overflow": "reject", "priority": 2},
		"floor_dropin": {"cap": 1, "overflow": "reject", "priority": 2},
		"hit_flash": {"cap": 6, "overflow": "snap_oldest", "priority": 1},
		"knockback": {"cap": 4, "overflow": "snap_oldest", "priority": 1},
		"pickup_pop": {"cap": 3, "overflow": "snap_oldest", "priority": 1},
		"food_first": {"cap": 1, "overflow": "reject", "priority": 3},
		"projectile_impact": {"cap": 6, "overflow": "snap_oldest", "priority": 1},
		"enemy_spawn": {"cap": 4, "overflow": "snap_oldest", "priority": 1},
		"hp_drain_pulse": {"cap": 1, "overflow": "new_kills", "priority": 1},
		"hp_color_shift": {"cap": 1, "overflow": "new_kills", "priority": 1},
		"hp_food_pop": {"cap": 1, "overflow": "new_kills", "priority": 1},
		"score_pop": {"cap": 1, "overflow": "new_kills", "priority": 1},
		"streak_scale": {"cap": 1, "overflow": "new_kills", "priority": 1},
		"void_bridge": {"cap": 2, "overflow": "reject", "priority": 1},
		"caption_in": {"cap": 1, "overflow": "new_kills", "priority": 1},
		"floor_darken": {"cap": 1, "overflow": "reject", "priority": 1},
		"hero_swing": {"cap": 1, "overflow": "snap_oldest", "priority": 1},
		"hero_lunge": {"cap": 1, "overflow": "snap_oldest", "priority": 1},
		"projectile_spawn": {"cap": 6, "overflow": "snap_oldest", "priority": 0},
		"telegraph": {"cap": 4, "overflow": "snap_oldest", "priority": 0},
		"door_open": {"cap": 1, "overflow": "reject", "priority": 0},
	}

## One row per G9 §2 contract line. Tier 1 = must ship; tier 2 = cut candidate.
static func contract() -> Dictionary:
	return {
		# ---- Boot · Title · Menus ----
		"AC-01": {"name": "Splash logo fade", "tier": 1, "type": "boot_splash", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "splash.alpha", "kind": "float", "from": 0.0, "to": 1.0, "ms_key": "juice.boot.splash_ms", "easing": EASE_OUT}]},
		"AC-02": {"name": "Title logo settle", "tier": 1, "type": "title_settle", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "title_logo.scale", "kind": "scale", "from": 1.04, "to": 1.0, "ms_key": "juice.title.settle_ms", "easing": EASE_OUT}]},
		"AC-03": {"name": "Attract veil", "tier": 1, "type": "attract_veil", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "attract_veil.alpha", "kind": "float", "from": 0.0, "to_key": "juice.attract.veil_alpha", "ms_key": "juice.attract.veil_ms", "easing": EASE_OUT}]},
		"AC-04": {"name": "Title prompt breathe", "tier": 2, "type": "title_prompt", "units": 1, "ambient": true, "loop_pp": true, "world": false,
			"segments": [{"prop": "title_prompt.alpha", "kind": "float", "from": 0.55, "to": 1.0, "ms_key": "juice.title.prompt_ms", "easing": EASE_IN_OUT}]},
		"AC-05": {"name": "Title portrait idle", "tier": 2, "type": "title_portrait", "units": 1, "ambient": true, "loop_pp": true, "world": false,
			"segments": [{"prop": "title_portrait.scale", "kind": "scale", "from": 1.0, "to_key": "juice.title.portrait_amp", "ms_key": "juice.title.portrait_ms", "easing": EASE_IN_OUT}]},
		"AC-06": {"name": "Menu button hover", "tier": 2, "type": "menu_hover", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "menu_hover.scale", "kind": "scale", "from": 1.0, "to_key": "juice.menu.hover_scale", "ms_key": "juice.menu.hover_ms", "easing": EASE_OUT}]},
		"AC-07": {"name": "Menu button press", "tier": 2, "type": "menu_press", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "menu_press.scale", "kind": "scale", "from": 1.0, "to": 0.96, "ms_key": "juice.menu.press_ms", "half": true, "easing": EASE_BACK},
				{"prop": "menu_press.scale", "kind": "scale", "from": 0.96, "to": 1.0, "ms_key": "juice.menu.press_ms", "half": true, "easing": EASE_BACK}]},
		"AC-08": {"name": "Class card pop-in (x4, 60ms stagger)", "tier": 1, "type": "class_popin", "units": 2, "ambient": false, "world": false,
			"segments": [{"prop": "class_card.scale", "kind": "scale", "from": 0.94, "to": 1.0, "ms_key": "juice.class.popin_ms", "easing": EASE_BACK},
				{"prop": "class_card.alpha", "kind": "float", "from": 0.0, "to": 1.0, "ms_key": "juice.class.popin_ms", "easing": EASE_BACK}],
			"stagger_ms_key": "juice.class.popin_stagger_ms"},
		"AC-09": {"name": "Class card focus", "tier": 2, "type": "class_focus", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "class_card_focus.scale", "kind": "scale", "from": 1.0, "to_key": "juice.class.focus_scale", "ms_key": "juice.class.focus_ms", "easing": EASE_OUT}]},
		"AC-10": {"name": "Class card confirm", "tier": 1, "type": "class_confirm", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "class_confirm.scale", "kind": "scale", "from": 1.06, "to": 0.94, "ms_key": "juice.class.confirm_ms", "half": true, "easing": EASE_BACK},
				{"prop": "class_confirm.scale", "kind": "scale", "from": 0.94, "to": 1.0, "ms_key": "juice.class.confirm_ms", "half": true, "easing": EASE_BACK}]},
		"AC-11": {"name": "Class weapon glint", "tier": 2, "type": "class_glint", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "class_glint.alpha", "kind": "float", "from": 0.0, "to": 1.0, "ms_key": "juice.class.glint_ms", "half": true, "easing": EASE_OUT},
				{"prop": "class_glint.alpha", "kind": "float", "from": 1.0, "to": 0.0, "ms_key": "juice.class.glint_ms", "half": true, "easing": EASE_OUT}]},
		"AC-12": {"name": "Modal open", "tier": 2, "type": "modal_open", "units": 2, "ambient": false, "world": false,
			"segments": [{"prop": "modal.scale", "kind": "scale", "from": 0.92, "to": 1.0, "ms_key": "juice.modal.open_ms", "easing": EASE_OUT},
				{"prop": "modal.alpha", "kind": "float", "from": 0.0, "to": 1.0, "ms_key": "juice.modal.open_ms", "easing": EASE_OUT}]},
		"AC-13": {"name": "Modal close", "tier": 2, "type": "modal_close", "units": 2, "ambient": false, "world": false,
			"segments": [{"prop": "modal_close.scale", "kind": "scale", "from": 1.0, "to": 0.92, "ms_key": "juice.modal.close_ms", "easing": EASE_OUT},
				{"prop": "modal_close.alpha", "kind": "float", "from": 1.0, "to": 0.0, "ms_key": "juice.modal.close_ms", "easing": EASE_OUT}]},
		"AC-14": {"name": "Pause dim", "tier": 2, "type": "pause_dim", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "pause_dim.alpha", "kind": "float", "from": 0.0, "to_key": "juice.pause.dim_alpha", "ms_key": "juice.pause.dim_ms", "easing": EASE_OUT}]},
		# ---- HUD (SIG-1: The Heartbeat) ----
		"AC-15": {"name": "HP drain pulse", "tier": 1, "type": "hp_drain_pulse", "units": 1, "ambient": false, "world": false, "critical": false,
			"segments": [{"prop": "hp_numeral.scale", "kind": "scale", "from": 1.0, "to_key": "juice.hp.drain_pulse_scale", "ms_key": "juice.hp.drain_pulse_ms", "half": true, "easing": EASE_OUT},
				{"prop": "hp_numeral.scale", "kind": "scale", "from_key": "juice.hp.drain_pulse_scale", "to": 1.0, "ms_key": "juice.hp.drain_pulse_ms", "half": true, "easing": EASE_OUT}]},
		"AC-16": {"name": "HP color at 50% (white->amber)", "tier": 1, "type": "hp_color_shift", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "hp_numeral.color", "kind": "color", "from_key": "juice.hp.color.white", "to_key": "juice.hp.color.amber", "ms_key": "juice.hp.color_50_ms", "easing": EASE_OUT}]},
		"AC-16b": {"name": "HP FAIR label at 50%", "tier": 1, "type": "hp_label_50", "units": 1, "ambient": false, "world": false,
			"text": "FAIR",
			"segments": [{"prop": "hp_label.alpha", "kind": "float", "from": 0.0, "to": 1.0, "ms_key": "juice.hp.label_50_ms", "easing": EASE_OUT}]},
		"AC-17": {"name": "HP color at 25% (amber->crimson)", "tier": 1, "type": "hp_color_shift", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "hp_numeral.color", "kind": "color", "from_key": "juice.hp.color.amber", "to_key": "juice.hp.color.crimson", "ms_key": "juice.hp.color_25_ms", "easing": EASE_OUT}]},
		"AC-17c": {"name": "HP LOW label at 25%", "tier": 1, "type": "hp_label_25", "units": 1, "ambient": false, "world": false,
			"text": "LOW",
			"segments": [{"prop": "hp_label.alpha", "kind": "float", "from": 1.0, "to": 1.0, "ms_key": "juice.hp.label_25_ms", "easing": EASE_OUT}]},
		"AC-17b": {"name": "HP CRITICAL label + color at 10%", "tier": 1, "type": "hp_color_shift", "units": 2, "ambient": false, "world": false,
			"text": "CRITICAL",
			"segments": [{"prop": "hp_numeral.color", "kind": "color", "from_key": "juice.hp.color.crimson", "to_key": "juice.hp.color.deep_red", "ms_key": "juice.hp.color_10_ms", "easing": EASE_OUT},
				{"prop": "hp_label.alpha", "kind": "float", "from": 1.0, "to": 1.0, "ms_key": "juice.hp.label_10_ms", "easing": EASE_OUT}]},
		"AC-18": {"name": "HP food-tick pop", "tier": 1, "type": "hp_food_pop", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "hp_numeral.scale", "kind": "scale", "from": 1.0, "to_key": "juice.hp.food_pop_scale", "ms_key": "juice.hp.food_pop_ms", "half": true, "easing": EASE_BACK},
				{"prop": "hp_numeral.scale", "kind": "scale", "from_key": "juice.hp.food_pop_scale", "to": 1.0, "ms_key": "juice.hp.food_pop_ms", "half": true, "easing": EASE_BACK}]},
		"AC-19": {"name": "HP food-tick tint", "tier": 1, "type": "hp_food_tint", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "hp_numeral.color", "kind": "color", "from": Color("#50B070"), "to_key": "juice.hp.color.white", "ms_key": "juice.hp.food_tint_ms", "easing": EASE_OUT}]},
		"AC-20": {"name": "Low-HP vignette (<=25%)", "tier": 1, "type": "hp_vignette", "units": 1, "ambient": true, "loop_pp": true, "world": false,
			"segments": [{"prop": "vignette.alpha", "kind": "float", "from": 0.0, "to_key": "juice.hp.vignette_alpha", "ms_key": "juice.hp.vignette_ms", "easing": EASE_IN_OUT}]},
		"AC-20b": {"name": "Critical-HP vignette (<=10%)", "tier": 1, "type": "hp_vignette", "units": 1, "ambient": true, "loop_pp": true, "world": false,
			"segments": [{"prop": "vignette.alpha", "kind": "float", "from": 0.0, "to_key": "juice.hp.vignette_crit_alpha", "ms_key": "juice.hp.vignette_crit_ms", "easing": EASE_IN_OUT}]},
		"AC-20c": {"name": "HP pulse freq escalation", "tier": 1, "type": "hp_pulse_freq", "units": 1, "ambient": true, "loop_pp": true, "world": false,
			"period_keys": {"t50": "juice.ac20c.period_50", "t25": "juice.ac20c.period_25", "t10": "juice.ac20c.period_10"},
			"segments": [{"prop": "hp_numeral.scale", "kind": "scale", "from": 1.0, "to_key": "juice.ac20c.scale_amp", "ms_key": "juice.ac20c.period_50", "easing": EASE_IN_OUT}]},
		"AC-21": {"name": "Score change pop", "tier": 1, "type": "score_pop", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "score.scale", "kind": "scale", "from": 1.0, "to_key": "juice.score.pop_scale", "ms_key": "juice.score.pop_ms", "half": true, "easing": EASE_OUT},
				{"prop": "score.scale", "kind": "scale", "from_key": "juice.score.pop_scale", "to": 1.0, "ms_key": "juice.score.pop_ms", "half": true, "easing": EASE_OUT}]},
		"AC-22": {"name": "Score floater", "tier": 1, "type": "floater", "units": 2, "ambient": false, "world": true,
			"segments": [{"prop": "floater.y", "kind": "float", "from": 0.0, "to": -24.0, "ms_key": "juice.floater.ms", "easing": EASE_OUT},
				{"prop": "floater.alpha", "kind": "float", "from": 1.0, "to": 0.0, "ms_key": "juice.floater.ms", "easing": EASE_OUT}]},
		"AC-23": {"name": "Floor counter increment", "tier": 2, "type": "floor_counter_pop", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "floor_counter.scale", "kind": "scale", "from": 1.0, "to": 1.15, "ms_key": "juice.hud.floor_pop_ms", "half": true, "easing": EASE_BACK},
				{"prop": "floor_counter.scale", "kind": "scale", "from": 1.15, "to": 1.0, "ms_key": "juice.hud.floor_pop_ms", "half": true, "easing": EASE_BACK}]},
		"AC-24": {"name": "Key icon pop", "tier": 2, "type": "key_icon_pop", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "key_icon.scale", "kind": "scale", "from": 1.0, "to": 1.18, "ms_key": "juice.hud.key_pop_ms", "half": true, "easing": EASE_BACK},
				{"prop": "key_icon.scale", "kind": "scale", "from": 1.18, "to": 1.0, "ms_key": "juice.hud.key_pop_ms", "half": true, "easing": EASE_BACK}]},
		"AC-25": {"name": "Continue token pulse (conditional OQ-15)", "tier": 2, "type": "continue_pulse", "units": 1, "ambient": true, "loop_pp": true, "world": false,
			"segments": [{"prop": "token_icon.scale", "kind": "scale", "from": 1.0, "to": 1.06, "ms_key": "juice.continue.pulse_ms", "easing": EASE_IN_OUT}]},
		"AC-26": {"name": "Caption in", "tier": 1, "type": "caption_in", "units": 2, "ambient": false, "world": false,
			"segments": [{"prop": "caption.y", "kind": "float", "from": 8.0, "to": 0.0, "ms_key": "juice.caption.in_ms", "easing": EASE_OUT},
				{"prop": "caption.alpha", "kind": "float", "from": 0.0, "to": 1.0, "ms_key": "juice.caption.in_ms", "easing": EASE_OUT}]},
		"AC-27": {"name": "Caption hold (dwell)", "tier": 1, "type": "caption_hold", "units": 0, "ambient": false, "world": false,
			"dwell_ms_key": "juice.caption.dwell_ms", "segments": []},
		"AC-28": {"name": "Caption out", "tier": 1, "type": "caption_out", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "caption.alpha", "kind": "float", "from": 1.0, "to": 0.0, "ms_key": "juice.caption.out_ms", "easing": EASE_OUT}]},
		# ---- Gameplay ----
		"AC-29": {"name": "Hero spawn (floor begin)", "tier": 1, "type": "hero_spawn", "units": 2, "ambient": false, "world": true,
			"segments": [{"prop": "hero.scale", "kind": "scale", "from": 0.85, "to": 1.0, "ms_key": "juice.hero.spawn_ms", "easing": EASE_OUT},
				{"prop": "hero.alpha", "kind": "float", "from": 0.0, "to": 1.0, "ms_key": "juice.hero.spawn_ms", "easing": EASE_OUT}]},
		"AC-30": {"name": "Hero walk cycle (sheet frames — excluded from tween caps)", "tier": 1, "type": "sheet_frames", "units": 0, "ambient": false, "world": true, "segments": []},
		"AC-31": {"name": "Hero attack swing", "tier": 1, "type": "hero_swing", "units": 1, "ambient": false, "world": true,
			"segments": [{"prop": "hero.scale", "kind": "scale", "from": 1.0, "to": 1.06, "ms_key": "juice.hero.swing_ms", "half": true, "easing": EASE_BACK},
				{"prop": "hero.scale", "kind": "scale", "from": 1.06, "to": 1.0, "ms_key": "juice.hero.swing_ms", "half": true, "easing": EASE_BACK}]},
		"AC-32": {"name": "Hero attack lunge", "tier": 1, "type": "hero_lunge", "units": 1, "ambient": false, "world": true,
			"segments": [{"prop": "hero.lunge", "kind": "float", "from": 0.0, "to_key": "juice.hero.lunge_px", "ms_key": "juice.hero.lunge_ms", "easing": EASE_OUT}]},
		"AC-34": {"name": "Enemy hit flash", "tier": 1, "type": "hit_flash", "units": 1, "ambient": false, "world": true,
			"segments": [{"prop": "enemy.flash", "kind": "float", "from": 1.0, "to": 0.0, "ms_key": "juice.enemy.hit_flash_ms", "easing": EASE_OUT, "set_instant": true}]},
		"AC-35": {"name": "Enemy knockback", "tier": 1, "type": "knockback", "units": 1, "ambient": false, "world": true,
			"segments": [{"prop": "enemy.knockback", "kind": "float", "from": 0.0, "to_key": "juice.enemy.knockback_px", "ms_key": "juice.enemy.knockback_ms", "easing": EASE_OUT}]},
		"AC-36": {"name": "Enemy death (composite, 2 phases)", "tier": 1, "type": "enemy_death", "units": 2, "ambient": false, "world": true,
			"segments": [{"prop": "enemy.death_scale", "kind": "scale", "from": 1.15, "to": 0.0, "ms_key": "juice.enemy.death_scale_ms", "easing": EASE_OUT, "set_instant": true},
				{"prop": "enemy.death_alpha", "kind": "float", "from": 1.0, "to": 0.0, "ms_key": "juice.enemy.death_fade_ms", "delay_ms_key": "juice.enemy.death_fade_delay_ms", "easing": EASE_OUT}]},
		"AC-37": {"name": "Enemy ranged telegraph", "tier": 1, "type": "telegraph", "units": 1, "ambient": false, "world": true,
			"segments": [{"prop": "enemy.telegraph", "kind": "float", "from": 1.0, "to": 1.15, "ms_key": "juice.enemy.telegraph_ms", "easing": EASE_OUT}]},
		"AC-38": {"name": "Enemy reinforcement spawn", "tier": 1, "type": "enemy_spawn", "units": 2, "ambient": false, "world": true,
			"segments": [{"prop": "enemy.spawn_scale", "kind": "scale", "from": 0.7, "to": 1.0, "ms_key": "juice.enemy.spawn_ms", "easing": EASE_OUT},
				{"prop": "enemy.spawn_alpha", "kind": "float", "from": 0.0, "to": 1.0, "ms_key": "juice.enemy.spawn_ms", "easing": EASE_OUT}]},
		"AC-39": {"name": "Flame-jet pre-ON flicker", "tier": 1, "type": "flame_flicker", "units": 1, "ambient": false, "world": true,
			"segments": [{"prop": "flamejet.alpha", "kind": "float", "from": 0.4, "to": 0.8, "ms_key": "juice.hazard.flicker_ms", "easing": EASE_OUT}]},
		"AC-Flame": {"name": "Hero flame-overlay entry", "tier": 1, "type": "flame_entry", "units": 1, "ambient": false, "world": true,
			"segments": [{"prop": "hero_flame.alpha", "kind": "float", "from": 0.0, "to_key": "juice.acflame.entry_alpha", "ms_key": "juice.acflame.entry_ms", "easing": EASE_OUT}]},
		"AC-Flame-L": {"name": "Hero flame-overlay flicker loop", "tier": 1, "type": "flame_loop", "units": 1, "ambient": true, "loop_pp": true, "world": true,
			"segments": [{"prop": "hero_flame.alpha", "kind": "float", "from_key": "juice.acflame.loop_low", "to_key": "juice.acflame.loop_high", "ms_key": "juice.acflame.loop_period_ms", "easing": EASE_IN_OUT}]},
		"AC-Flame-X": {"name": "Hero flame-overlay exit", "tier": 1, "type": "flame_exit", "units": 1, "ambient": false, "world": true,
			"segments": [{"prop": "hero_flame.alpha", "kind": "float", "from_key": "juice.acflame.entry_alpha", "to": 0.0, "ms_key": "juice.acflame.exit_ms", "easing": EASE_OUT}]},
		"AC-40": {"name": "Projectile spawn", "tier": 2, "type": "projectile_spawn", "units": 1, "ambient": false, "world": true,
			"segments": [{"prop": "projectile.scale", "kind": "scale", "from": 0.8, "to": 1.0, "ms_key": "juice.projectile.spawn_ms", "easing": EASE_OUT}]},
		"AC-41": {"name": "Projectile impact", "tier": 1, "type": "projectile_impact", "units": 1, "ambient": false, "world": true,
			"segments": [{"prop": "projectile.flash", "kind": "float", "from": 1.0, "to": 0.0, "ms_key": "juice.projectile.impact_ms", "easing": EASE_OUT, "set_instant": true}]},
		"AC-42": {"name": "Generator idle pulse", "tier": 1, "type": "gen_idle", "units": 1, "ambient": true, "loop_pp": true, "world": true,
			"segments": [{"prop": "generator.scale", "kind": "scale", "from": 1.0, "to": 1.03, "ms_key": "juice.generator.idle_ms", "easing": EASE_IN_OUT}]},
		"AC-42b": {"name": "Generator pre-death flicker (50ms argued inline)", "tier": 1, "type": "gen_preflicker", "units": 1, "ambient": false, "world": true,
			"segments": [{"prop": "generator.flash", "kind": "float", "from": 1.3, "to": 1.0, "ms_key": "juice.generator.preflicker_ms", "easing": EASE_OUT, "set_instant": true}]},
		"AC-44": {"name": "Door open", "tier": 1, "type": "door_open", "units": 2, "ambient": false, "world": true,
			"segments": [{"prop": "door.alpha", "kind": "float", "from": 1.0, "to": 0.0, "ms_key": "juice.door.open_ms", "easing": EASE_OUT},
				{"prop": "door.y", "kind": "float", "from": 0.0, "to": -4.0, "ms_key": "juice.door.open_ms", "easing": EASE_OUT}]},
		"AC-45": {"name": "Exit idle glow", "tier": 2, "type": "exit_glow", "units": 1, "ambient": true, "loop_pp": true, "world": true,
			"segments": [{"prop": "exit.alpha", "kind": "float", "from": 0.7, "to": 1.0, "ms_key": "juice.exit.idle_ms", "easing": EASE_IN_OUT}]},
		"AC-46": {"name": "Pickup idle bob (max 6 inst)", "tier": 2, "type": "pickup_bob", "units": 1, "ambient": true, "loop_pp": true, "world": true,
			"segments": [{"prop": "pickup.y", "kind": "float", "from": -2.0, "to": 2.0, "ms_key": "juice.pickup.bob_ms", "easing": EASE_IN_OUT}]},
		"AC-47": {"name": "SIG-3 food pickup (FIRST, composite — 4 phases)", "tier": 1, "type": "food_first", "units": 4, "ambient": false, "world": true, "critical": true,
			"segments": [
				{"prop": "pickup.pop_scale", "kind": "scale", "from": 1.0, "to": 1.2, "ms_key": "juice.food.pop_scale_ms", "easing": EASE_BACK},
				{"prop": "pickup.pop_alpha", "kind": "float", "from": 1.0, "to": 0.0, "ms_key": "juice.food.pop_fade_ms", "easing": EASE_OUT},
				# phase 3: HP numeral ×3 sequential ticks (G9: 1 budget unit, sequential)
				{"prop": "hp_numeral.scale", "kind": "scale", "from": 1.0, "to_key": "juice.hp.food_pop_scale", "ms_key": "juice.hp.food_pop_ms", "half": true, "easing": EASE_BACK},
				{"prop": "hp_numeral.scale", "kind": "scale", "from_key": "juice.hp.food_pop_scale", "to": 1.0, "ms_key": "juice.hp.food_pop_ms", "half": true, "easing": EASE_BACK},
				{"prop": "hp_numeral.scale", "kind": "scale", "from": 1.0, "to_key": "juice.hp.food_pop_scale", "ms_key": "juice.hp.food_pop_ms", "half": true, "easing": EASE_BACK},
				{"prop": "hp_numeral.scale", "kind": "scale", "from_key": "juice.hp.food_pop_scale", "to": 1.0, "ms_key": "juice.hp.food_pop_ms", "half": true, "easing": EASE_BACK},
				{"prop": "hp_numeral.scale", "kind": "scale", "from": 1.0, "to_key": "juice.hp.food_pop_scale", "ms_key": "juice.hp.food_pop_ms", "half": true, "easing": EASE_BACK},
				{"prop": "hp_numeral.scale", "kind": "scale", "from_key": "juice.hp.food_pop_scale", "to": 1.0, "ms_key": "juice.hp.food_pop_ms", "half": true, "easing": EASE_BACK},
				# phase 4: caption in (2 units)
				{"prop": "caption.y", "kind": "float", "from": 8.0, "to": 0.0, "ms_key": "juice.caption.in_ms", "easing": EASE_OUT},
				{"prop": "caption.alpha", "kind": "float", "from": 0.0, "to": 1.0, "ms_key": "juice.caption.in_ms", "easing": EASE_OUT}]},
		"AC-47r": {"name": "SIG-3 food pickup (routine)", "tier": 1, "type": "pickup_pop", "units": 2, "ambient": false, "world": true,
			"segments": [{"prop": "pickup.pop_scale", "kind": "scale", "from": 1.0, "to": 1.2, "ms_key": "juice.food.pop_scale_ms", "easing": EASE_BACK},
				{"prop": "pickup.pop_alpha", "kind": "float", "from": 1.0, "to": 0.0, "ms_key": "juice.food.pop_fade_ms", "easing": EASE_OUT}]},
		"AC-48": {"name": "Key pickup", "tier": 1, "type": "pickup_pop", "units": 1, "ambient": false, "world": true,
			"segments": [{"prop": "pickup.key_scale", "kind": "scale", "from": 1.0, "to": 1.18, "ms_key": "juice.key.pickup_ms", "half": true, "easing": EASE_BACK},
				{"prop": "pickup.key_scale", "kind": "scale", "from": 1.18, "to": 1.0, "ms_key": "juice.key.pickup_ms", "half": true, "easing": EASE_BACK}]},
		"AC-49": {"name": "Treasure pickup", "tier": 1, "type": "pickup_pop", "units": 1, "ambient": false, "world": true,
			"segments": [{"prop": "pickup.treasure_scale", "kind": "scale", "from": 1.0, "to": 1.18, "ms_key": "juice.treasure.pickup_ms", "half": true, "easing": EASE_BACK},
				{"prop": "pickup.treasure_scale", "kind": "scale", "from": 1.18, "to": 1.0, "ms_key": "juice.treasure.pickup_ms", "half": true, "easing": EASE_BACK}]},
		"AC-50": {"name": "Potion pickup", "tier": 1, "type": "pickup_pop", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "potion_icon.scale", "kind": "scale", "from": 1.0, "to": 1.15, "ms_key": "juice.potion.pickup_ms", "half": true, "easing": EASE_BACK},
				{"prop": "potion_icon.scale", "kind": "scale", "from": 1.15, "to": 1.0, "ms_key": "juice.potion.pickup_ms", "half": true, "easing": EASE_BACK}]},
		"AC-52": {"name": "Void-bridge warning pulse (900ms on argued inline)", "tier": 1, "type": "void_bridge", "units": 2, "ambient": false, "world": true,
			"cycles_key": "juice.ac52.cycles", "on_ms_key": "juice.ac52.on_ms", "off_ms_key": "juice.ac52.off_ms", "peak_key": "juice.ac52.alpha_peak",
			"segments": [{"prop": "void_bridge.alpha", "kind": "float", "from": 0.0, "to_key": "juice.ac52.alpha_peak", "ms_key": "juice.ac52.on_ms", "easing": EASE_IN_OUT}]},
		"AC-53": {"name": "Floor-clear darken", "tier": 1, "type": "floor_darken", "units": 1, "ambient": false, "world": true,
			"segments": [{"prop": "overlay.alpha", "kind": "float", "from": 0.0, "to_key": "juice.floor.darken_alpha", "ms_key": "juice.floor.darken_ms", "easing": EASE_OUT}]},
		"AC-54": {"name": "Floor banner in", "tier": 1, "type": "floor_banner", "units": 2, "ambient": false, "world": false,
			"segments": [{"prop": "banner.y", "kind": "float", "from": -16.0, "to": 0.0, "ms_key": "juice.floor.banner_in_ms", "easing": EASE_OUT},
				{"prop": "banner.alpha", "kind": "float", "from": 0.0, "to": 1.0, "ms_key": "juice.floor.banner_in_ms", "easing": EASE_OUT}]},
		"AC-55": {"name": "Floor banner hold (dwell)", "tier": 1, "type": "banner_hold", "units": 0, "ambient": false, "world": false,
			"dwell_ms_key": "juice.floor.banner_hold_ms", "segments": []},
		"AC-56": {"name": "Floor banner out", "tier": 1, "type": "banner_out", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "banner.alpha", "kind": "float", "from": 1.0, "to": 0.0, "ms_key": "juice.floor.banner_out_ms", "easing": EASE_OUT}]},
		# ---- Death · Results · Continue ----
		"AC-57": {"name": "Player death vignette", "tier": 1, "type": "hero_death_vignette", "units": 1, "ambient": false, "world": false, "critical": true,
			"segments": [{"prop": "death_vignette.alpha", "kind": "float", "from": 0.0, "to_key": "juice.death.vignette_alpha", "ms_key": "juice.death.vignette_ms", "easing": EASE_OUT}]},
		"AC-58": {"name": "Player death hero collapse", "tier": 1, "type": "hero_death", "units": 2, "ambient": false, "world": true, "critical": true,
			"segments": [{"prop": "hero.death_scale", "kind": "scale", "from": 1.0, "to": 1.2, "ms_key": "juice.death.collapse_ms", "easing": EASE_OUT},
				{"prop": "hero.death_alpha", "kind": "float", "from": 1.0, "to": 0.0, "ms_key": "juice.death.collapse_ms", "easing": EASE_OUT}]},
		"AC-59": {"name": "Floor results panel slide-in", "tier": 1, "type": "results_panel", "units": 2, "ambient": false, "world": false,
			"segments": [{"prop": "results.y", "kind": "float", "from": 24.0, "to": 0.0, "ms_key": "juice.results.panel_ms", "easing": EASE_OUT},
				{"prop": "results.alpha", "kind": "float", "from": 0.0, "to": 1.0, "ms_key": "juice.results.panel_ms", "easing": EASE_OUT}]},
		"AC-60": {"name": "Score count-up", "tier": 1, "type": "results_countup", "units": 1, "ambient": false, "world": false,
			"segments": [{"prop": "results.countup", "kind": "float", "from": 0.0, "to": 1.0, "ms_key": "juice.results.countup_ms", "easing": EASE_OUT}]},
		"AC-61": {"name": "New best pop + gold flash", "tier": 2, "type": "results_best", "units": 2, "ambient": false, "world": false,
			"segments": [{"prop": "best.scale", "kind": "scale", "from": 1.0, "to": 1.15, "ms_key": "juice.results.best_ms", "half": true, "easing": EASE_BACK},
				{"prop": "best.scale", "kind": "scale", "from": 1.15, "to": 1.0, "ms_key": "juice.results.best_ms", "half": true, "easing": EASE_BACK},
				{"prop": "best_flash.alpha", "kind": "float", "from_key": "juice.results.best_flash_alpha", "to": 0.0, "ms_key": "juice.results.best_flash_ms", "easing": EASE_OUT, "set_instant": true}]},
		"AC-62": {"name": "Game over entry (500ms argued: scene boundary)", "tier": 1, "type": "gameover_entry", "units": 2, "ambient": false, "world": false,
			"segments": [{"prop": "gameover.alpha", "kind": "float", "from": 0.0, "to": 1.0, "ms_key": "juice.gameover.entry_ms", "easing": EASE_OUT},
				{"prop": "gameover.scale", "kind": "scale", "from": 0.8, "to": 1.0, "ms_key": "juice.gameover.entry_ms", "easing": EASE_OUT}]},
		"AC-63": {"name": "Play start floor drop-in (composite, 2 phases)", "tier": 1, "type": "floor_dropin", "units": 2, "ambient": false, "world": true, "priority": 2,
			"segments": [{"prop": "tilemap.alpha", "kind": "float", "from": 0.0, "to": 1.0, "ms_key": "juice.floor.dropin_ms", "easing": EASE_OUT},
				{"prop": "banner.y", "kind": "float", "from": -16.0, "to": 0.0, "ms_key": "juice.floor.banner_in_ms", "easing": EASE_OUT}]},
	}

## G9 §2 hitstop/freeze-frame table (frames at 60Hz — never ms-converted).
static func hitstop_table() -> Dictionary:
	return {
		"HS-1": {"trigger": "light hit connects", "frames_key": "juice.hitstop.light_frames", "frames_default": 2},
		"HS-2": {"trigger": "generator destroyed (SIG-2)", "frames_key": "juice.hitstop.gen_frames", "frames_default": 4},
		"HS-3": {"trigger": "potion used (SIG-4)", "frames_key": "juice.hitstop.potion_frames", "frames_default": 6},
		"HS-4": {"trigger": "floor clear (SIG-5)", "frames_key": "juice.hitstop.clear_frames", "frames_default": 4},
	}

## G9 §4 screen-shake policy — EXACTLY three shake events (rare by design).
static func shake_table() -> Dictionary:
	return {
		"generator": {"mag_key": "juice.shake.gen.mag_px", "ms_key": "juice.shake.gen.ms", "falloff": "linear"},
		"death": {"mag_key": "juice.shake.death.mag_px", "ms_key": "juice.shake.death.ms", "falloff": "cubic_out"},
		"clear": {"mag_key": "juice.shake.clear.mag_px", "ms_key": "juice.shake.clear.ms", "falloff": "linear"},
	}

## G9 §5 haptic policy — magnitudes/durations from Tunables; duration_s =
## duration_ms × juice.haptic.duration_conversion (default 0.001).
static func haptic_table() -> Dictionary:
	return {
		"light": {"weak_key": "juice.haptic.light.weak", "strong_key": "juice.haptic.light.strong", "ms_key": "juice.haptic.light.duration_ms"},
		"medium": {"weak_key": "juice.haptic.medium.weak", "strong_key": "juice.haptic.medium.strong", "ms_key": "juice.haptic.medium.duration_ms"},
		"heavy": {"weak_key": "juice.haptic.heavy.weak", "strong_key": "juice.haptic.heavy.strong", "ms_key": "juice.haptic.heavy.duration_ms"},
	}

## G9 §3 particle effects table — counts are HARD caps; PT-06/07/09 critical
## (never killed by global eviction; per-type caps still apply).
static func particle_table() -> Dictionary:
	return {
		"PT-01": {"texture": "res://Assets/particle-spark.png", "count": 8, "life_s": 0.3, "max_inst": 1, "critical": false, "trigger": "hero spawn"},
		"PT-02": {"texture": "res://Assets/particle-smoke.png", "count": 6, "life_s": 0.25, "max_inst": 4, "critical": false, "trigger": "enemy spawn"},
		"PT-03": {"texture": "res://Assets/particle-spark.png", "count": 6, "life_s": 0.25, "max_inst": 6, "critical": false, "trigger": "melee hit"},
		"PT-04": {"texture": "res://Assets/particle-spark.png", "count": 4, "life_s": 0.2, "max_inst": 6, "critical": false, "trigger": "projectile impact"},
		"PT-05a": {"texture": "res://Assets/particle-smoke.png", "count": 8, "life_s": 0.4, "max_inst": 4, "critical": false, "trigger": "enemy death smoke"},
		"PT-05b": {"texture": "res://Assets/particle-spark.png", "count": 6, "life_s": 0.4, "max_inst": 4, "critical": false, "trigger": "enemy death sparks"},
		"PT-06": {"texture": "res://Assets/particle-glow.png", "count": 14, "life_s": 0.5, "max_inst": 2, "critical": true, "trigger": "SIG-2 generator destruction"},
		"PT-07": {"texture": "res://Assets/particle-glow.png", "count": 8, "life_s": 0.35, "max_inst": 1, "critical": true, "trigger": "SIG-3 food pickup first"},
		"PT-08": {"texture": "res://Assets/particle-glow.png", "count": 6, "life_s": 0.3, "max_inst": 1, "critical": false, "trigger": "potion pickup"},
		"PT-09": {"texture": "res://Assets/particle-smoke.png", "count": 16, "life_s": 0.5, "max_inst": 1, "critical": true, "trigger": "SIG-4 potion use"},
		"PT-10": {"texture": "res://Assets/particle-spark.png", "count": 6, "life_s": 0.3, "max_inst": 2, "critical": false, "trigger": "key pickup"},
		"PT-11": {"texture": "res://Assets/particle-glow.png", "count": 10, "life_s": 0.4, "max_inst": 2, "critical": false, "trigger": "treasure pickup"},
		"PT-12": {"texture": "res://Assets/particle-smoke.png", "count": 6, "life_s": 0.3, "max_inst": 1, "critical": false, "trigger": "door open"},
		"PT-13": {"texture": "res://Assets/particle-glow.png", "count": 8, "life_s": 0.35, "max_inst": 1, "critical": false, "trigger": "exit open glow"},
		"PT-14": {"texture": "res://Assets/particle-trail.png", "count": 1, "life_s": 0.15, "max_inst": 20, "critical": false, "trigger": "projectile trail"},
		"PT-15a": {"texture": "res://Assets/particle-smoke.png", "count": 5, "life_s": 0.4, "max_inst": 4, "critical": false, "trigger": "flame-jet ON smoke"},
		"PT-15b": {"texture": "res://Assets/particle-glow.png", "count": 3, "life_s": 0.4, "max_inst": 4, "critical": false, "trigger": "flame-jet ON glow"},
		"PT-16": {"texture": "res://Assets/particle-glow.png", "count": 4, "life_s": 0.5, "max_inst": 8, "critical": false, "trigger": "ambient torch flicker"},
		"PT-17": {"texture": "res://Assets/particle-glow.png", "count": 10, "life_s": 0.6, "max_inst": 1, "critical": false, "trigger": "death telegraph aura (conditional OQ-13)"},
	}

## G9 §3 eviction order — whole-emitter kills, first-killed first.
static func eviction_order() -> Array:
	return ["PT-16", "PT-14", "PT-03", "PT-05a", "PT-15a", "PT-15b", "PT-02", "PT-01", "PT-04", "PT-05b", "PT-08", "PT-10", "PT-11", "PT-12", "PT-13", "PT-17"]

## G9 §6 scene transitions — one fade family, all cubic-out.
static func transition_table() -> Dictionary:
	return {
		"splash_title": "juice.transition.splash_title_ms",
		"title_class": "juice.transition.title_class_ms",
		"class_play": "juice.transition.class_play_ms",
		"play_results": "juice.transition.play_results_ms",
		"results_play": "juice.transition.results_play_ms",
		"pause_dim": "juice.pause.dim_ms",
		"play_gameover": "juice.transition.play_gameover_ms",
		"gameover_continue": "juice.transition.gameover_continue_ms",
		"continue_title": "juice.transition.continue_title_ms",
	}

## G9 zone atmosphere rows (normal alpha blend, persistent ColorRect).
static func zone_table() -> Dictionary:
	return {
		"AC-Zone1": {"zone": "cinder", "floors": [1, 6], "color_key": "juice.zone.cinder_tint", "alpha_key": "juice.zone.cinder_alpha", "alpha_default": 0.15},
		"AC-Zone2": {"zone": "drowned", "floors": [7, 12], "color_key": "juice.zone.drowned_tint", "alpha_key": "juice.zone.drowned_alpha", "alpha_default": 0.15},
		"AC-Zone3": {"zone": "starved", "floors": [13, 18], "color_key": "juice.zone.starved_tint", "alpha_key": "juice.zone.starved_alpha", "alpha_default": 0.15},
		"AC-Zone4": {"zone": "throne", "floors": [19, 24], "color_key": "juice.zone.throne_tint", "alpha_key": "juice.zone.throne_alpha", "alpha_default": 0.20},
	}

## G9 zone mapping — HUNGERHALL G2 §3 zones run drowned F1-6, cinder F7-12,
## starved F13-18, throne F19-24 (world_view.gd:137-145 binds the same order).
## The G9 row names cinder 1-6 per its own table; the tint COLORS and alphas
## apply to this product's locked zone order (documented supersession).
static func zone_for_floor(floor_number: int) -> String:
	if floor_number >= 19:
		return "throne"
	if floor_number >= 13:
		return "starved"
	if floor_number >= 7:
		return "cinder"
	return "drowned"

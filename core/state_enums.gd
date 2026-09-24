class_name StateEnums
extends RefCounted
## HUNGERHALL core enums — G6 §3.1, exact integer mappings. Pure data.

# State enum — 12 session states
enum State {
	SPLASH = 0, TITLE = 1, CLASS_SELECT = 2, PLAYING = 3,
	PAUSED = 4, SETTINGS = 5, HALL_OF_HEROES = 6,
	DYING = 7, CONTINUE_OFFER = 8, GAME_OVER = 9,
	FLOOR_RESULTS = 10, CAMPAIGN_RESULTS = 11
}

# SceneId enum — 22 scene identifiers (12 screens + 10 modals)
enum SceneId {
	SPLASH = 0, TITLE = 1, CLASS_SELECT = 2, PLAY = 3,
	PAUSED = 4, SETTINGS = 5, HALL_OF_HEROES = 6,
	DYING = 7, CONTINUE_OFFER = 8, GAME_OVER = 9,
	FLOOR_RESULTS = 10, CAMPAIGN_RESULTS = 11,
	MODAL_QUIT_WARN = 12, MODAL_NEWGAME_WARN = 13,
	MODAL_ERASE_WARN = 14, MODAL_RESET_WARN = 15,
	MODAL_REMAP_CAPTURE = 16, MODAL_CREDITS_POP = 17,
	MODAL_PRIVACY_POP = 18, MODAL_PAD_LOST = 19,
	MODAL_SAVE_FAIL = 20, MODAL_FLOOR_MISSING = 21
}

# Verb enum — 21 transition verbs
enum Verb {
	PRESS = 0, RESUME = 1, CHOOSE = 2, PAUSE = 3,
	QUIT = 4, CLEAR = 5, FINISH = 6, ADVANCE = 7,
	SAVE_QUIT = 8, ENTER = 9, DRAIN = 10, PROMPT = 11,
	CONTINUE = 12, EXPIRE = 13, BACK = 14, SETTINGS = 15,
	RETRY = 16, SKIP = 17, CONFIRM = 18, CANCEL = 19,
	TIMEOUT = 20
}

# ClassType enum — 4 classes
enum ClassType { WARRIOR = 0, VALKYRIE = 1, WIZARD = 2, ELF = 3 }

# EnemyAIType enum — 6 AI types
enum EnemyAIType {
	GHOST = 0, GRUNT = 1, DEMON = 2,
	LOBBER = 3, SORCERER = 4, DEATH = 5
}

# HazardType enum — 3 hazard types
enum HazardType { FLAME_JET = 0, VOID_BRIDGE = 1, COLLAPSING_VOID = 2 }

# TriggerType enum — 3 trigger types
enum TriggerType { PERIODIC = 0, PHASED = 1, PLAYER_STEP = 2 }

# PotionType enum — 4 class-specific potion effects
enum PotionType { WHIRLWIND = 0, AEGIS = 1, NOVA = 2, VOLLEY = 3 }

# Tile codes used by FloorData.tiles string rows.
enum Tile { FLOOR = 0, WALL = 1, DOOR = 2, EXIT = 3, VOID = 4 }

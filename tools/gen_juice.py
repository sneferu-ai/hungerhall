#!/usr/bin/env python3
"""G10 DoD #2 — single-source juice tunables generator.

Reads data/tunables_schema.json (the ONE source) and regenerates:
  1. the juice.* section of Tunables.json (game_tunables_v1) — every other
     key in Tunables.json is preserved byte-for-byte in place;
  2. data/juice_defaults.gd — the boot-time fallback constants the
     SessionStateMachine loads when Tunables.json is missing (G9 §"Juice
     constants are DATA").

Usage: python3 tools/gen_juice.py [--check]
  --check  exit 1 if the generated outputs would differ (CI drift gate).
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCHEMA = ROOT / "data" / "tunables_schema.json"
TUNABLES = ROOT / "Tunables.json"
DEFAULTS_GD = ROOT / "data" / "juice_defaults.gd"

BANNER = (
    "class_name JuiceDefaults\n"
    "extends RefCounted\n"
    "## GENERATED FILE — tools/gen_juice.py from res://data/tunables_schema.json.\n"
    "## Do NOT hand-edit. Boot fallback for the juice.* keys when Tunables.json\n"
    "## is missing (G9 'Juice constants are DATA' / G10 DoD #2). Numeric keys load\n"
    "## through TunablesLoader.get_value/get_int; identity (color) keys via\n"
    "## TunablesLoader.get_color.\n\n"
    'const SCHEMA_SOURCE: String = "res://data/tunables_schema.json"\n\n'
)


def load_schema() -> dict:
    schema = json.loads(SCHEMA.read_text())
    keys = schema.get("keys", {})
    if not keys:
        raise SystemExit("schema has no keys")
    for key, entry in keys.items():
        if "value" not in entry:
            raise SystemExit(f"{key}: missing value")
        band = entry.get("band")
        value = entry["value"]
        if band is not None:
            if not (isinstance(value, (int, float)) and band[0] <= value <= band[1]):
                raise SystemExit(f"{key}: value {value} outside band {band}")
        else:
            if entry.get("step") is not None:
                raise SystemExit(f"{key}: band null requires step null")
    return keys


def juice_entry(entry: dict) -> dict:
    out = {
        "value": entry["value"],
        "default": entry["value"],
        "band": entry.get("band"),
        "step": entry.get("step"),
        "affects": ["juice"],
    }
    return out


def render_gd(keys: dict) -> str:
    lines = [BANNER, "const DEFAULTS: Dictionary = {"]
    for key, entry in keys.items():
        value = entry["value"]
        if isinstance(value, str):
            rendered = json.dumps(value)
        elif isinstance(value, bool):
            rendered = "true" if value else "false"
        elif isinstance(value, int):
            rendered = str(value)
        else:
            rendered = repr(float(value))
        lines.append(f'\t"{key}": {rendered},')
    lines.append("}\n")
    return "\n".join(lines)


def main() -> int:
    check = "--check" in sys.argv
    keys = load_schema()

    tunables = json.loads(TUNABLES.read_text())
    constants = tunables.get("constants", {})
    # why: preserve the EXISTING key ordering in Tunables.json. The prior
    # approach (extract non-juice, append juice) reordered the dict — every
    # juice key jumped to the end, which made --check always report drift even
    # when values matched. Instead, walk the current order and update juice.*
    # entries in place; append any schema juice keys not yet present at the end.
    rebuilt: dict = {}
    for key, existing in constants.items():
        if str(key).startswith("juice.") and key in keys:
            rebuilt[key] = juice_entry(keys[key])
        else:
            rebuilt[key] = existing
    # why: new juice.* keys added to the schema since the last generation
    for key, entry in keys.items():
        if key not in rebuilt:
            rebuilt[key] = juice_entry(entry)
    tunables["constants"] = rebuilt
    new_tunables = json.dumps(tunables, indent=2) + "\n"

    new_gd = render_gd(keys)

    if check:
        drift = False
        if TUNABLES.read_text() != new_tunables:
            print("DRIFT: Tunables.json juice.* section differs from schema")
            drift = True
        if not DEFAULTS_GD.exists() or DEFAULTS_GD.read_text() != new_gd:
            print("DRIFT: data/juice_defaults.gd differs from schema")
            drift = True
        return 1 if drift else 0

    TUNABLES.write_text(new_tunables)
    DEFAULTS_GD.write_text(new_gd)
    print(f"gen_juice: wrote {len(keys)} juice.* keys into Tunables.json + data/juice_defaults.gd")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

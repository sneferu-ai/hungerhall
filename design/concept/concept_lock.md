# AUTOPILOT MASTER RUN gap-253b64a1 — G1 Concept Lock

Run-first: Godot project; Sneferu Game Pipeline assumed operational — this game proves it by exercising the pipeline end-to-end, not a minimal project that barely touches it.

## Goal
A single-player, top-down 2D arcade dungeon crawler that channels Gauntlet (1985 arcade) — frantic hack-and-slash action, four distinct hero classes, continuous health-drain tension, an iconic voice announcer, and arcade scoring. Built in Godot through the Sneferu Game Pipeline, exported for Steam at $5.99, targeting a nostalgic audience. The game validates the Sneferu Game Pipeline by being a genuinely sellable product, not a minimal tech demo or vertical slice.

## Deliverables
- Single-player top-down 2D dungeon crawler built in Godot, exportable as a Windows build for Steam distribution
- Four hero classes with differentiated stat profiles and gameplay-defining traits, faithful to Gauntlet's roster archetypes (Warrior, Valkyrie, Wizard, Elf) — each class must demand a distinct combat rhythm and survival strategy, not percentage stat offsets that feel interchangeable over time
- Core arcade mechanics: continuous health-drain timer, enemy generators, finite food-as-health pickups per level, key/door level gating
- Arcade scoring system with a visible, accumulating score tracked across the campaign and a local high-score table; death carries a score penalty to preserve arcade risk-reward tension
- Arcade-style continue system on death adapted from Gauntlet's coin-op model for single-player home use: continues are limited per dungeon floor and continuing restarts the current floor with reduced resources — not unlimited free restarts from the exact death location
- Voice announcer system delivering varied callouts across gameplay events (health critical, food consumed, key found, level transition) with character-specific lines — the voice style must evoke 1980s arcade speech synthesis, not a single repeating clip or modern natural recording
- Dungeon campaign with at least 2 hours of engaging content across multiple themed zones with escalating enemy types and hazards — combat encounters, level progression, and class-driven replay value, not padded corridors, empty traversal, or repeated identical room layouts
- 2D pixel-art visual style faithful to 1980s arcade aesthetics — period-appropriate color palette and sprite proportions, not modern high-resolution pixel art with contemporary lighting or effects
- All art and audio assets original or commissioned, created or processed through the Sneferu Game Pipeline — no asset-store flips

## Constraints
- Single-player only — no multiplayer, netcode, split-screen, or AI companion
- 2D only — no 3D graphics, rendering, or physics
- Engine: Godot (pre-locked)
- Platform: Steam (Windows export is the design target)
- Concept locked: Gauntlet-inspired single-player top-down dungeon crawler — no re-ideation or alternative concepts
- Ambition profile: commercial_focused
- Monetization: $5.99
- Audience: Nostalgic — expects mechanical fidelity to 1985 arcade Gauntlet, not merely visual homage
- All game content (art, sound, voice) must be created or processed via the Sneferu Game Pipeline; no asset or build step may bypass the pipeline's intended workflow
- Keyboard and gamepad input supported

## Out of scope
- Multiplayer in any form
- 3D graphics, rendering, or physics
- Development of the Sneferu Game Pipeline itself
- Re-ideation or alternative concepts
- Online leaderboards, level editors
- Complex meta-progression, inventory management, or RPG-style character building beyond the arcade stat model

## Acceptance
- Game launches as a Godot project and exports to a Windows executable through the Sneferu Game Pipeline with no manual workarounds outside the pipeline
- Player selects from four hero classes with distinct stat profiles that produce visibly different playstyles — each class demands a fundamentally different approach to encounters (e.g., Warrior absorbs hits and wades into crowds, Elf outranges threats and kites, Wizard clears groups with area damage, Valkyrie balances offense and defense)
- Continuous health-drain creates constant forward pressure — standing still is never a viable strategy
- Enemy generators spawn foes at a rate that sustains combat intensity during encounters; generators are destructible but positioned to require advancement into hostile territory to destroy, not sniped from a safe starting position
- Food restores health, is finite per level with no respawning, and is scarce enough that survival requires aggressive forward progress
- Keys open doors and gate level progression
- Food pickups are necessary for survival — the campaign cannot be completed without consuming them
- A visible, accumulating score is displayed during gameplay, persists across sessions via a local high-score table, and death reduces the score to preserve arcade risk-reward tension
- Voice announcer delivers varied callouts during gameplay with character-specific lines, event-triggered variety, and a style evoking 1980s arcade speech synthesis
- Campaign provides at least 2 hours of engaging content across multiple dungeon themes that introduce new enemy types and hazards — not repeated room layouts or copypasted encounters
- Player can save and resume progress between levels without dying; death triggers a limited continue that restarts the current floor with reduced resources, preserving arcade tension without erasing campaign progress
- Game sustains 60 fps with at least 20 on-screen enemies during combat
- Gamepad controls work without manual remapping
- Production is completed end-to-end through the Sneferu Game Pipeline: all assets are imported, processed, and packaged via the pipeline; no manual workarounds are required to produce the final Windows executable

## Falsification
- Game cannot export to Windows from Godot through the Sneferu Game Pipeline
- Game requires multiplayer to be playable or enjoyable
- Game uses 3D graphics or physics
- Hero classes are cosmetically different but produce interchangeable playstyles — no class demands a unique combat approach
- Health-drain mechanic is absent or so slow that standing still is viable
- Food respawns within a level, enabling indefinite camping without advancing
- Enemy generators can be destroyed from a safe starting position without advancing, or can be safely camped without consequence
- Food pickups can be ignored — the campaign is completable without consuming them
- No visible score is displayed or tracked, or death carries no score penalty
- Voice announcer uses a single repeating clip, lacks character-specific variety, or does not evoke 1980s arcade speech synthesis
- Total playable content is under 2 hours, insufficient for $5.99
- Campaign duration is achieved through padded corridors, slow traversal, empty rooms, or repeated identical layouts rather than engaging combat encounters with escalating variety
- Continue system allows unlimited free restarts from the death location with no resource penalty, removing arcade tension
- Player cannot save and resume between levels without dying — progress is lost on quit unless death occurs first
- Frame rate drops below 50 fps during combat with 20+ on-screen enemies
- Any asset or build step requires bypassing the Sneferu Game Pipeline's intended workflow
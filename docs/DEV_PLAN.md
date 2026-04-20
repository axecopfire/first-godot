---
title: Development Plan
description: Project structure, implementation status, and iteration roadmap for the medieval market survival game
ms.date: 2026-04-18
---

## Project Structure

Organize scenes and scripts by domain so each game entity is a self-contained scene with
an attached script. This follows Godot's scene composition model and keeps files navigable
as the project grows.

```text
project.godot
docs/
  GAME_DESIGN.md            # What the game is (story, mechanics, controls)
  DEV_PLAN.md               # How to build it (structure, steps, status)
  CHANGELOG.md              # What was built and when
scenes/
  boot.tscn
  main.tscn                 # World composition using child scenes
  player/
    player.tscn              # Player sprite, collision, camera
  npcs/
    npc.tscn                 # Base NPC scene
    guard.tscn               # Guard variant
  items/
    pickup_item.tscn         # Reusable item scene
  ui/
    hud.tscn                 # Suspicion bar, inventory, clock
    dialogue_box.tscn
scripts/
  autoloads/
    game_state.gd            # Suspicion, relationships, day/night, story flags
    story_manager.gd         # Story graph transitions
  player/
    player.gd
  npcs/
    npc.gd
    npc_dialogues.gd
    guard_npc.gd
  items/
    pickup_item.gd
  ui/
    hud.gd
    dialogue_box.gd
  world/
    main.gd                  # Scene composition only (loads child scenes)
    map_generator.gd         # Procedural map logic extracted from main.gd
  tools/
    texture_generator.gd
    generate_textures.gd
resources/                   # .tres files for NPC stats, item definitions
textures/
```

### Principles

* Each "thing" (player, NPC, item, UI element) is its own scene and script pair.
* Shared game state (suspicion, relationships, time) lives in autoload singletons.
* `main.gd` composes child scenes rather than building everything procedurally.
* Use `.tres` resource files for data (NPC stats, item values) instead of hardcoding.

## Current Status

What exists today versus what the game design calls for.

| System | Status | Notes |
|--------|--------|-------|
| Procedural map (40x30 tiles) | Done | Built entirely in `main.gd` |
| Player movement and animation | Done | Built in code, not a scene yet |
| NPC wandering and dialogue | Done | 4 NPCs with inventory-aware dialogue |
| Item pickup and drop | Done | 4 items, press E to pick up, Q to drop |
| Texture generation | Done | Runtime pixel art generator |
| Suspicion meter | Not started | No tracking, no HUD bar |
| Stealth toggle | Not started | Shift key mapped but no behavior |
| Guard behavior | Not started | No guard NPC, no arrest mechanic |
| Death/restart loop | Not started | No prison, no respawn |
| Gift mechanic | Not started | G key mapped but no gift logic |
| Witness detection | Not started | NPCs don't track what they see |
| Relationship tracking | Not started | No friendship system |
| Word learning | Not started | No foreign language display |
| Day/night cycle | Not started | No time progression |
| Shelter/sleep | Not started | R key mapped but no sleep logic |
| Career branches | Not started | Placeholder design only |

## Iteration Roadmap

Each step is a single focused work session. After each step the game should be runnable
and testable. Complete steps in order; each builds on the previous.

### Step 1: Extract player into a scene

Move player creation out of `main.gd` into `scenes/player/player.tscn`. The scene
includes the sprite, collision shape, camera, and attached script. `main.gd` instantiates
the scene instead of building the player in code.

**Done when:** Player scene loads from `.tscn`, movement and animation still work.

### Step 2: Create `game_state.gd` autoload

Add `scripts/autoloads/game_state.gd` registered as an autoload in Project Settings.
Track `suspicion: float`, `relationships: Dictionary`, `time_of_day: float`.
Expose signals: `suspicion_changed`, `relationship_changed`, `day_started`.

**Done when:** `GameState.suspicion` is accessible from any script.

### Step 3: Add the suspicion meter

Create `scenes/ui/hud.tscn` with a progress bar bound to `GameState.suspicion_changed`.
Suspicion ticks up +1.5/sec when the player is visible in the market area.

**Done when:** A suspicion bar appears and climbs while walking in the market.

### Step 4: Add stealth toggle

Hold Shift to enter stealth. Visual indicator (sprite tint or crouch frame). Suspicion
decays at -0.5/sec while crouching.

**Done when:** Holding Shift slows/reverses the suspicion bar.

### Step 5: Wire NPCs to suspicion thresholds

At suspicion 35+ the nearest NPC follows the player. At 60+ a guard NPC begins chasing.
At 80+ the guard arrests the player.

**Done when:** NPCs visibly react at each threshold.

### Step 6: Build the death/restart loop

Arrest triggers a prison scene or overlay, then the player respawns in the alley.
Suspicion resets to 0.

**Done when:** Walking openly into the market leads to arrest and restart (Phase 1
complete as a playable loop).

### Step 7: Add gift mechanic

Press G near an NPC to offer the last inventory item. Apply the gift acceptance formula.
Track whether the NPC witnessed the theft. Accepted gifts increase the relationship
value in `GameState`.

**Done when:** Gifts accepted/rejected based on the formula, relationship stored.

### Step 8: Add word learning and dialogue responses

When a gift is accepted the player learns a foreign word. NPC dialogue references the
learned word. A small UI element shows learned words.

**Done when:** Gifting bread to the Merchant teaches "Khleb" (Phase 2 complete).

### Step 9: Friendship and vouching

When `GameState.relationships[npc] >= 40`, mark that NPC as befriended. Befriended NPCs
vouch for the player (suspicion -25). Herbalist offers shelter.

**Done when:** Befriending the Herbalist grants shelter access (Phase 3 complete).

### Step 10: Day/night cycle and survival loop

Add a time-of-day counter in `GameState`. Night triggers a sleep prompt. Without shelter
there is a 60% arrest chance. Surviving a night reduces suspicion by 10.

**Done when:** Full day/night survival loop is playable (Phase 4 complete).

### Future steps (after core loop)

* Extract NPC data into `.tres` resource files
* Separate map generation into `map_generator.gd`
* Build scene variants for guard, merchant, baker
* Begin career branch content (Phase 5)

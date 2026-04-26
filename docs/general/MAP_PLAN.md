---
title: Incremental Map Build Plan
description: Step-by-step plan to grow the village map from the current 40×30 market square to the full village layout described in village.md
ms.date: 2026-04-26
---

## Current State

The map is a 90×50 tile grid built procedurally in `scripts/world/map_generator.gd`.
Steps 0–9 of this plan are implemented; Step 10 is data-tagged but not wired to the
suspicion system (waiting on DEV_PLAN Step 3).

The map contains:

- A cobblestone market plaza centered on a stone fountain
- A starting alley north of the plaza, flanked by stone walls
- Building shells with walls, doorways, and wood-floor interiors for: church, workshop,
  school, tailor, blacksmith, mill, warehouse, barracks, and a walled manor compound
  with an inner manor house
- A walled manor gate that is closed at start (StaticBody2D blocks movement)
- An acequia (water tile, blocks movement) running from the north edge through the
  plaza to the mill, with bridges at path crossings
- Open fields west of the plaza with a low pasture wall
- Per-zone Rect2i and suspicion modifier tables exposed by `MapGenerator`
- 16 NPCs reconciled with `village.md` (original four textures reused for the wider
  cast; legacy names preserve inventory-aware dialogue)

## Principles

1. **One zone per step.** Each step adds one navigable area and is playable on its own.
2. **Expand the grid, don't replace it.** Grow `MAP_W` and `MAP_H` as needed. Existing
   tile coordinates stay valid.
3. **Extract before expanding.** Move map generation out of `main.gd` before the map
   gets larger.
4. **Buildings are collision rectangles first.** Draw a solid wall tile rectangle, cut a
   doorway, add an interior floor. Visual detail comes later.
5. **NPCs follow zones.** Place an NPC in a new zone only when that zone exists on the map.
6. **Test after every step.** Walk to the new area, confirm collision, confirm the player
   can return to the market.

## Target Layout

Derived from [village.md](../places/village.md). Cardinal directions relative to the
market square:

| Direction | Zones |
|-----------|-------|
| Center | Market Square (exists), Fountain (exists) |
| North | Alley (player start), Church, Workshop, School |
| East | Warehouse, Barracks |
| South | Blacksmith, Mill |
| West | Fields (wheat, flax, beehives, pasture), road to Manor |
| Far West | Manor (late-game, walled compound) |

The Tailor sits between the north quarter and the market, connected by back alleys.

## Steps

### Step 0: Extract map generation into `map_generator.gd` ✅

Map generation lives in `scripts/world/map_generator.gd` as a `RefCounted` class with a
single `build(parent: Node2D)` entry point. `main.gd` instantiates it, calls `build`, and
then composes player/NPCs/items/UI on top. The generator also exposes `player_spawn`,
`ZONES` (Rect2i per area), `ZONE_SUSPICION` (per-second suspicion modifiers), and
`get_zone_at(world_pos)`.

---

### Step 1: Expand grid and add the starting alley ✅

Grew the map directly to 90×50 (the Step 7 target) so all later steps could land in the
same pass. Shift the existing plaza content so it sits in the center. Add a
narrow alley north of the market (2–3 tiles wide, 6–8 tiles long) paved with dirt or
cobble, flanked by wall tiles.

Move the player spawn point from the plaza center to the alley.

**Map change:** `MAP_W = 60`, `MAP_H = 50`. Alley at roughly column 29–31, rows 2–9.

**Done when:** Player wakes in a narrow alley and walks south into the market square.

---

### Step 2: Add building shells — Blacksmith and Mill (south) ✅

Below the market square, place two building rectangles using wall tiles with single-tile
doorway gaps facing the plaza. Inside each building, fill the floor with wood tiles.

- **Blacksmith** (south-west of plaza): ~6×5 tile interior. Door faces north.
- **Mill** (south-east of plaza): ~6×5 tile interior. Door faces north.

No NPCs yet, just walkable interiors.

**Done when:** Player can walk south from the plaza, enter both buildings, and walk back.

---

### Step 3: Add the Warehouse and Barracks (east) ✅

East of the plaza, add a lane (dirt path, 3 tiles wide) leading to two buildings:

- **Warehouse**: ~8×6 tile interior. Large door facing west (toward the lane). Back exit
  (single tile gap) on the east wall leading to a short alley.
- **Barracks**: ~6×6 tile interior, south of the warehouse. Connected to the warehouse
  via the back-exit alley. Door facing west.

**Done when:** Player can walk east from the plaza through the lane, enter the warehouse,
exit through the back into the alley behind the barracks, and return.

---

### Step 4: Add the North Quarter — Church, Workshop, School ✅

North of the alley (the starting area), place three buildings arranged in a row:

- **Church**: ~6×8 tiles, westernmost. Door faces south toward an alley connecting to the
  market.
- **Workshop**: ~5×5 tiles, east of the church. Door faces south.
- **School**: ~5×5 tiles, east of the workshop. Door faces south.

Connect all three to the market via the alley from Step 1.

**Done when:** Player can walk north from the market through the alley and enter all three
buildings.

---

### Step 5: Add the Tailor (between north quarter and market) ✅

Place a small building (~4×4 tile interior) on the west side of the alley between the
north quarter and the market square. A back door on the north wall opens into a short
path to the church garden (open area behind the church — grass tiles, 4×4).

**Done when:** Player can enter the tailor from the alley, exit through the back into the
church garden, and loop back to the church.

---

### Step 6: Add fields and the west road ✅

Extend the map westward if needed. West of the plaza, a dirt road (3 tiles wide) leads
to open fields. The fields area is large (~20×20 tiles) and uses grass tiles with a few
dirt-path dividers between plots:

- **Wheat/barley** (north-west area): grass with scattered crop decoration sprites.
- **Flax** (center-west): grass, slightly different decoration.
- **Beehives** (south-west, near edge): a few decoration sprites.
- **Pasture** (south): grass with a low stone-wall line (wall tiles, 1 tile high).

The acequia is a 1-tile-wide line of a blue-tinted tile (new tile type: `WATER`)
running from the north edge through the fields into the plaza fountain.

**Done when:** Player can walk west from the market into open fields. Acequia is visible.
Fields feel distinct from the plaza.

---

### Step 7: Add the Manor (far west) ✅

At the western edge of the fields, on a slight rise (visual only — darker grass or a
stone border), place the manor compound:

- **Outer wall**: rectangle of wall tiles (~12×10) with a single gate (2 tiles wide)
  facing east.
- **Courtyard**: cobble floor inside the walls. A well decoration.
- **Manor house**: smaller wall rectangle inside the courtyard (~6×4) with a door. Interior
  floor is wood.

The gate is initially blocked by a collision body (locked). Unlocking it is a gameplay
mechanic for later.

**Done when:** Player can see the manor walls from the fields. The gate is closed. Walking
up to it does nothing yet.

---

### Step 8: Place NPCs in new zones ✅

With all zones built, station NPCs using the configurations from village.md:

| NPC | Zone | Behavior |
|-----|------|----------|
| Ibrahim (Blacksmith) | Blacksmith interior | Wanders near anvil |
| Tarik (Apprentice) | Blacksmith / market lane | Errands between zones |
| Abbas (Miller) | Mill interior | Stationary, singing |
| Rafiq (Warehouse boss) | Warehouse interior | Patrols inside |
| Salim, Nura (Workers) | Warehouse / market | Haul goods back and forth |
| Capitán Rodrigo | Barracks | Guard patrol route |
| Father Domingo | Church interior | Stationary near altar |
| Zahra (Potter) | Workshop interior | Absorbed in work |
| Maestro al-Rashid | School interior | Stationary during morning |
| Maryam (Tailor) | Tailor interior | Works by lamplight |
| Qadir (Field boss) | Fields | Patrols crop plots |
| Old Hamid | Market livestock corner | Stationary |

Existing NPCs (Merchant, Baker, Blacksmith, Herbalist) should be reconciled with the new
characters. The current Blacksmith NPC becomes Ibrahim; the others map to Fatima (Grocer),
Yusuf (Household Goods), etc., based on village.md.

**Done when:** Each new zone has at least one NPC. All NPCs have placeholder dialogue.

---

### Step 9: Add the acequia as a tile type and zone connector ✅

Add `Tile.WATER` (index 5 in the tile strip). Paint a 1-tile-wide acequia channel from
the north map edge through the fields, into the plaza (connecting to the fountain), and
south-east to the mill (powering the waterwheel). Water tiles block movement (shallow
collision) unless a bridge tile (wood plank) is placed over them.

**Done when:** The acequia is visible, connects fields → fountain → mill, and the player
must use bridges to cross it.

---

### Step 10: Zone-based suspicion rules — partial

Zones and per-second suspicion modifiers are exposed via `MapGenerator.ZONES` and
`MapGenerator.ZONE_SUSPICION`, with `get_zone_at(world_pos)` for lookup. Wiring these
values into the suspicion meter waits on DEV_PLAN Steps 2–3.

Tag each zone with a suspicion modifier stored in `map_generator.gd`:

| Zone | Suspicion rate | Notes |
|------|---------------|-------|
| Market Square | +1.5/sec | Highest traffic |
| Alley | 0 | Hidden |
| Blacksmith | 0 | Presence tolerated |
| Mill | 0 | Abbas doesn't mind |
| Church | −0.5/sec | Sanctuary |
| Warehouse | +1.0/sec | Rafiq watches |
| Barracks | +2.0/sec | Most dangerous |
| Fields | +0.3/sec | Low traffic |
| Manor courtyard | +1.0/sec | Guarded |
| Tailor | 0 | Quiet |

This requires the player's current zone to be detectable (check tile region or use
`Area2D` zone triggers).

**Done when:** Suspicion rate changes when walking between zones. HUD reflects this
(requires Step 3 of the DEV_PLAN: suspicion meter).

## Dependencies on DEV_PLAN

| Map step | Requires DEV_PLAN step |
|----------|----------------------|
| Step 0 | None |
| Steps 1–7 | None (pure map work) |
| Step 8 | None (NPCs exist already, just more of them) |
| Step 9 | None (new tile type) |
| Step 10 | DEV_PLAN Step 2 (game_state autoload) and Step 3 (suspicion meter) |

Steps 0–9 can proceed independently of the DEV_PLAN iteration roadmap. Step 10 ties into
the suspicion system.

## Estimated Grid Size Progression

| After step | MAP_W | MAP_H | Tile count |
|------------|-------|-------|------------|
| Current | 40 | 30 | 1,200 |
| Step 1 | 60 | 50 | 3,000 |
| Step 6 | 80 | 50 | 4,000 |
| Step 7 | 90 | 50 | 4,500 |

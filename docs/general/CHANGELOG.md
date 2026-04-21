---
title: Changelog
description: Session-by-session record of what was built in the medieval market survival game
ms.date: 2026-04-18
---

## 2026-04-18

* Split `GAME_PLAN.md` into `GAME_DESIGN.md`, `DEV_PLAN.md`, and `CHANGELOG.md`
* Added target project structure and iteration roadmap to `DEV_PLAN.md`
* Corrected phase statuses to reflect actual implementation state

## 2026-04-17 (initial build)

* Procedural 40x30 tile map with cobblestone plaza, dirt paths, grass border
* 4 market stalls with collision at cardinal positions
* Decorations: fountain (center), barrels, crates, well
* Player character with 4-frame walk animation and 3-direction sprite sheet
* WASD movement at 200px/s with 3x zoom camera
* 4 NPCs (Merchant, Baker, Blacksmith, Herbalist) with random wandering
* Inventory-aware NPC dialogue system with item reactions and combo lines
* 4 pickup items (Bread, Sword, Herb, Gold Coin) with E to collect, Q to drop
* Runtime pixel art texture generator (boot scene creates all sprites on first run)
* Boundary walls around map edges
* Inventory HUD in top-right corner

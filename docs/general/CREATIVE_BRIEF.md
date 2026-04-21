---
title: Creative Brief
description: One-page handoff for creative director, separating locked constraints from open creative territory
ms.date: 2026-04-19
---

## Play the Prototype First

Run the Godot project and walk around. Pick things up, talk to NPCs, get caught. The
prototype demonstrates the core loop better than any doc can. Everything below is context
for what you experience.

## The Feeling

Isolation. Desperation. Fragile trust. Belonging.

You are alone in a place where no one understands you and you understand no one. Every
interaction is a risk. Over time, small acts of generosity crack the walls between you
and the people around you. The game is about earning a place in a world that doesn't
want you there.

## Locked (non-negotiable)

These constraints define the game. They are not changing.

- Stranger in a foreign land: the player is an outsider with no allies, no resources, no
  context for where they are or why.
- Top-down 2D: the camera perspective and visual format.
- The player cannot speak: no dialogue choices, no voice, no text input. Communication
  happens through actions (stealing, gifting, helping, hiding).

## The Core Loop (working, open to reshaping)

The prototype implements this sequence:

1. Explore while avoiding attention (suspicion rises the longer you're visible).
2. Steal items to survive (spikes suspicion further).
3. Gift stolen items to NPCs who didn't witness the theft (lowers suspicion, builds
   relationship).
4. Build enough trust with an NPC to earn friendship and protection.
5. Survive the night. Repeat.

The mechanics work. The numbers, pacing, and feel are all open to adjustment. See
[GAME_DESIGN.md](GAME_DESIGN.md) for current values.

## Placeholders (yours to reimagine)

Everything below exists to make the prototype playable. None of it is precious.

- The medieval market setting: could be any place, any era, any world.
- NPC identities (Merchant, Baker, Blacksmith, Herbalist): could be anyone.
- Items (Bread, Herb, Sword, Gold Coin): could be anything.
- Foreign language words (Khleb, Trava, Mech, Zolota): filler.
- Career branches (Military, Religious, Scholar, Merchant guild): sketched but undesigned.
- Visual style, color palette, sound, music: wide open.
- Narrative voice and tone: yours to define.

## Goal

Ship a small complete experience. One tight loop that feels finished, not the first
chapter of something sprawling.

## Open Questions for You

- What setting and world fits this premise?
- Who are these NPCs as characters? What do they want?
- What's the tone: grim, darkly comic, bittersweet, something else?
- What does "a small complete experience" look like to you? Where does the game end?
- How should the player's inability to speak *feel*: frustrating, mysterious, poignant?

## Reference Docs

- [GAME_DESIGN.md](GAME_DESIGN.md): full mechanics, story graph, and control scheme as
  built in the prototype.
- [DEV_PLAN.md](DEV_PLAN.md): implementation status and iteration roadmap.

These document the prototype, not the final vision.

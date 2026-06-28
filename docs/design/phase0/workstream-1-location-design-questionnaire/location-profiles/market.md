---
title: Location Profile Market Square
description: Detailed Workstream 1 profile for the Market Square zone
ms.date: 2026-06-28
ms.topic: reference
keywords:
  - location profile
  - market square
  - phase 0
estimated_reading_time: 5
---

## Identity

| Field | Value |
|---|---|
| Location name | Market Square |
| Zone key | `market` |
| Baseline type | Existing |
| Current status | Keep |

## Role and taxonomy

| Question | Answer |
|---|---|
| Short fiction intent | Public center where social norms are most visible and most enforced |
| Primary gameplay role | Social pressure |
| Secondary gameplay role | Language learning |
| Risk profile and rationale | High due to witness density, faction crossover, and visible actions |
| Intended player loops supported | First contact, observed action, gift gamble, trust gain |
| Explicit Phase 1 mechanic unblocked | Individual suspicion accumulation with witness context |

## Premise and guardrail checks

1. Assimilation pressure is strongest here because ordinary routines are public and strict.
2. Player learns behavior through repeated observation of stall etiquette, timing, and proximity norms.
3. Non-stealth suspicion reduction can come from accepted transactions, gifts, and sponsor-backed interactions.
4. Market hostility should frame mismatch as social misfit, not explicit identity revelation.

## Witness and visibility model

| Prompt | Answer |
|---|---|
| Expected witness roles and factions | Merchants, laborers, guards, travelers, neutral villagers |
| Always-on versus conditional witnesses | Merchants are near-constant; guards and travelers vary by time and event |
| Dominant line-of-sight lanes and cover pockets | Open fountain approaches are exposed; stall edges create temporary cover pockets |
| Socially appropriate, suspicious, and severe actions | Appropriate: browse, greet, buy. Suspicious: loitering near goods, rapid lane switching. Severe: theft witnessed by multiple NPCs |
| Threshold visibility priority (35, 60, 80) | First visible at 35 and 60 here |
| Immediate NPC reactions by threshold | 35: warnings, avoidance. 60: crowd signaling to guards. 80: coordinated guard interception |

## Entry and access contracts

| Prompt | Answer |
|---|---|
| Allowed entry conditions | Daytime public access |
| Discouraged entry conditions | Night access without task, repeated loops near same stall |
| Forbidden entry conditions | Active theft or prior incident under guard watch |
| Time-of-day, weather, faction deltas | Evening lowers density but increases anomaly visibility |
| Sponsorship or token required for low-friction entry | Trusted merchant sponsorship lowers interpretation severity |
| Language or social knowledge requirement | Basic greeting and exchange patterns reduce mismatch deltas |
| Context-inappropriate actions and deltas | Touching goods without permission, interrupting trade flow, entering private stall space |

## Adjacency and traversal contracts

| Prompt | Answer |
|---|---|
| Direct connected locations | Alley, warehouse lane, south lane to blacksmith and mill, west road to fields |
| Route hierarchy intent | Primary hub that routes all early loops |
| Dead-end risk for core loops | None if all exits remain available |
| Safe, risky, and ambiguous transitions | Safe to alley and tailor paths; risky to warehouse and barracks lanes |
| Chokepoints for faction control and stealth alternatives | East lane chokepoint near warehouse should be guard-observable |
| Recovery adjacency after failure or arrest | Alley and church route provide immediate recovery path |

## Keep or cut review

| Prompt | Answer |
|---|---|
| Why keep this location in Phase 1 scope | It is the essential pressure test surface for social assimilation mechanics |
| If revised, what is the minimum revision | Add explicit witness lanes and stall-specific appropriateness cues |
| If cut, what location absorbs its function | Not applicable |
| Decision owner and review date | World design and systems, 2026-06-28 |

## Open issues

| ID | Question | Impact | Owner | Due date | Fallback rule |
|---|---|---|---|---|---|
| WS1-MARKET-001 | Should traveler stalls be a separate conditional witness profile | Medium | Narrative design | 2026-07-03 | Keep as market sub-state |

---
title: Location Profile Warehouse
description: Detailed Workstream 1 profile for the Warehouse zone
ms.date: 2026-06-28
ms.topic: reference
keywords:
  - location profile
  - warehouse
  - phase 0
estimated_reading_time: 4
---

## Identity

| Field | Value |
|---|---|
| Location name | Warehouse |
| Zone key | `warehouse` |
| Baseline type | Existing |
| Current status | Keep |

## Role and taxonomy

| Question | Answer |
|---|---|
| Short fiction intent | Supervised resource choke with strong ownership enforcement |
| Primary gameplay role | High enforcement |
| Secondary gameplay role | Labor economy |
| Risk profile and rationale | High due to concentrated value, oversight, and barracks adjacency |
| Intended player loops supported | Observed action, stealth recovery, labor entry |
| Explicit Phase 1 mechanic unblocked | Witness memory with value-sensitive severity scaling |

## Premise and guardrail checks

1. Assimilation pressure is explicit through work discipline and permission boundaries.
2. Player learns who can authorize access and what handling patterns are acceptable.
3. Non-stealth reduction path exists via supervised labor assignments.
4. Enforcement should remain social and procedural, not identity-reveal based.

## Witness and visibility model

| Prompt | Answer |
|---|---|
| Expected witness roles and factions | Supervisor, workers, rotating guard witness |
| Always-on versus conditional witnesses | Supervisor persistent by day; guards conditional |
| Dominant line-of-sight lanes and cover pockets | Entry and central aisles highly visible; stacks create partial occlusion |
| Socially appropriate, suspicious, and severe actions | Appropriate: assigned handling. Suspicious: unsanctioned handling. Severe: theft, forced entry |
| Threshold visibility priority (35, 60, 80) | 60 and 80 should be strongly legible here |
| Immediate NPC reactions by threshold | 35: challenge. 60: detention attempt. 80: rapid guard handoff |

## Entry and access contracts

| Prompt | Answer |
|---|---|
| Allowed entry conditions | Daytime work with role context |
| Discouraged entry conditions | Idle loitering at storage aisles |
| Forbidden entry conditions | Night forced access |
| Time-of-day, weather, faction deltas | Night lock and elevated severity |
| Sponsorship or token required for low-friction entry | Supervisor assignment token |
| Language or social knowledge requirement | Role-specific task comprehension |
| Context-inappropriate actions and deltas | Moving sealed goods, bypassing supervisor checks |

## Adjacency and traversal contracts

| Prompt | Answer |
|---|---|
| Direct connected locations | Market east lane, back alley toward barracks |
| Route hierarchy intent | Enforcement-rich branch off market hub |
| Dead-end risk for core loops | Medium if back alley becomes one-way trap |
| Safe, risky, and ambiguous transitions | Risky to barracks back corridor |
| Chokepoints for faction control and stealth alternatives | Front door and back alley are explicit chokepoints |
| Recovery adjacency after failure or arrest | Low, intentional pressure node |

## Keep or cut review

| Prompt | Answer |
|---|---|
| Why keep this location in Phase 1 scope | Core testbed for resource theft and supervised labor interpretation |
| If revised, what is the minimum revision | Improve distinction between assigned and unassigned interactions |
| If cut, what location absorbs its function | Barracks and market cannot fully absorb resource-pressure loop |
| Decision owner and review date | Systems and world design, 2026-06-28 |

## Open issues

| ID | Question | Impact | Owner | Due date | Fallback rule |
|---|---|---|---|---|---|
| WS1-WAREHOUSE-001 | Should warehouse night access require a multi-step sponsorship gate | Medium | Systems design | 2026-07-04 | Keep hard lock in Phase 1 |

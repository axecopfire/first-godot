---
title: Location Profile Barracks
description: Detailed Workstream 1 profile for the Barracks zone
ms.date: 2026-06-28
ms.topic: reference
keywords:
  - location profile
  - barracks
  - phase 0
estimated_reading_time: 4
---

## Identity

| Field | Value |
|---|---|
| Location name | Barracks |
| Zone key | `barracks` |
| Baseline type | Existing |
| Current status | Keep |

## Role and taxonomy

| Question | Answer |
|---|---|
| Short fiction intent | Central enforcement node and arrest consequence anchor |
| Primary gameplay role | Faction gate |
| Secondary gameplay role | High enforcement |
| Risk profile and rationale | High by design with strongest consequence visibility |
| Intended player loops supported | Observed action, arrest, recovery restart |
| Explicit Phase 1 mechanic unblocked | Threshold reaction behaviors at 60 and 80 |

## Premise and guardrail checks

1. Assimilation failure consequences are made legible without reducing to pure stealth policing.
2. Player learns prohibited conduct through escalating warnings before hard detention.
3. Non-stealth reduction path exists outside barracks through sponsorship before escalation.
4. Barracks fiction must not disclose hidden identity premise.

## Witness and visibility model

| Prompt | Answer |
|---|---|
| Expected witness roles and factions | Guard personnel and detainees |
| Always-on versus conditional witnesses | Guard witness density always high |
| Dominant line-of-sight lanes and cover pockets | Entry and common room highly controlled, minimal cover |
| Socially appropriate, suspicious, and severe actions | Appropriate: escorted entry. Suspicious: loitering near arms. Severe: intrusion or theft |
| Threshold visibility priority (35, 60, 80) | 60 and 80 primary demonstration location |
| Immediate NPC reactions by threshold | 35: warning at perimeter. 60: stop-and-question. 80: immediate detention |

## Entry and access contracts

| Prompt | Answer |
|---|---|
| Allowed entry conditions | Escort, summons, or sanctioned delivery |
| Discouraged entry conditions | Unsponsored approach |
| Forbidden entry conditions | Unauthorized entry |
| Time-of-day, weather, faction deltas | Always enforced, stronger at night |
| Sponsorship or token required for low-friction entry | Official summons or trusted intermediary |
| Language or social knowledge requirement | Clear compliance cues |
| Context-inappropriate actions and deltas | Weapon interaction, refusal to comply, perimeter breach |

## Adjacency and traversal contracts

| Prompt | Answer |
|---|---|
| Direct connected locations | Warehouse back corridor, east-side lanes |
| Route hierarchy intent | Enforcement endpoint |
| Dead-end risk for core loops | Intentional dead-end under arrest state |
| Safe, risky, and ambiguous transitions | Risky from warehouse and market spillover |
| Chokepoints for faction control and stealth alternatives | Entrances should remain hard control points |
| Recovery adjacency after failure or arrest | Directly feeds reset and recovery loop |

## Keep or cut review

| Prompt | Answer |
|---|---|
| Why keep this location in Phase 1 scope | Required to express consequence ladder and arrest loop |
| If revised, what is the minimum revision | Clarify pre-detention warning states to reduce abruptness |
| If cut, what location absorbs its function | No valid substitute |
| Decision owner and review date | Systems design, 2026-06-28 |

## Open issues

| ID | Question | Impact | Owner | Due date | Fallback rule |
|---|---|---|---|---|---|
| WS1-BARRACKS-001 | Should threshold 60 include temporary release under sponsorship | High | Narrative systems | 2026-07-03 | Keep detention at 60+ |

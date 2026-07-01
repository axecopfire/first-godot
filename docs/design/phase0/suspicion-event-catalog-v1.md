---
title: Suspicion Event Catalog v1
description: Symbolic event catalog for per-witness trust-suspicion deltas with playtest-tuning placeholders
ms.date: 2026-06-29
ms.topic: reference
keywords:
  - suspicion
  - trust
  - event catalog
  - balancing
estimated_reading_time: 10
---

## Purpose

Define the Phase 1 event dictionary for per-witness social assimilation scoring using symbolic severity tiers.

This version intentionally avoids fixed numeric thresholds. Constants are placeholders that must be tuned during implementation and playtesting.

## Terminology Lock

| Term | Phase 1 definition |
|---|---|
| District | Broad map grouping used for world structure and narrative framing |
| Zone | Gameplay area used by threshold and enforcement behaviors |
| Location | Concrete place or interactable spot inside a zone where actions occur |

## Model Contract

| Field | Rule |
|---|---|
| Scale shape | Single spectrum: trust at one end, suspicion at the other |
| Scope | Per witness NPC |
| Clamp | 0 to 100 per witness |
| Event mapping | One witnessed action maps to one primary event key |
| Zone multipliers | Not used in Phase 1 baseline |

## Symbolic Severity Tiers

| Tier key | Meaning | Numeric value |
|---|---|---|
| TIER_LOW | Minor mismatch or weak positive conformity signal | BALANCE_TIER_LOW |
| TIER_MEDIUM | Clear mismatch or clear positive conformity signal | BALANCE_TIER_MEDIUM |
| TIER_HIGH | Strong mismatch or strong positive conformity signal | BALANCE_TIER_HIGH |
| TIER_CRITICAL | Extreme mismatch with immediate social consequence pressure | BALANCE_TIER_CRITICAL |

## Delta Direction Rules

| Event class | Trust-Suspicion direction |
|---|---|
| Mismatch event | Move toward suspicion by tier magnitude |
| Conformity event | Move toward trust by tier magnitude |
| Neutral event | No movement |

## Placeholder Constants

Set these constants in code/config first, then tune with playtest data.

| Constant | Initial placeholder rule |
|---|---|
| BALANCE_TIER_LOW | Smallest non-zero step |
| BALANCE_TIER_MEDIUM | Greater than BALANCE_TIER_LOW |
| BALANCE_TIER_HIGH | Greater than BALANCE_TIER_MEDIUM |
| BALANCE_TIER_CRITICAL | Greater than BALANCE_TIER_HIGH |
| BALANCE_DECAY_IDLE | Optional passive drift toward neutral if later enabled |

## Event Dictionary v1

| Event key | Trigger condition (witnessed) | Class | Tier | Rumor eligible |
|---|---|---|---|---|
| EVT_FORCED_ENTRY | Player enters restricted/private area without social permission | Mismatch | TIER_HIGH | Yes |
| EVT_ITEM_TAKEN_PUBLIC | Player takes item considered owned in visible context | Mismatch | TIER_HIGH | Yes |
| EVT_ITEM_DROPPED_CONTEXT_MISMATCH | Player drops object in socially inappropriate context | Mismatch | TIER_LOW | No |
| EVT_CONTEXT_INAPPROPRIATE_INTERACT | Player interacts with object/NPC at wrong time or wrong role context | Mismatch | TIER_MEDIUM | No |
| EVT_DIALOGUE_LANGUAGE_MISMATCH | Player dialogue choice indicates low local language fit | Mismatch | TIER_MEDIUM | No |
| EVT_DIALOGUE_POLITE_CONFORMITY | Player dialogue choice follows expected tone and local norm | Conformity | TIER_LOW | No |
| EVT_TASK_HELPFUL_ACTION | Player completes socially legible helpful action witnessed by NPC | Conformity | TIER_MEDIUM | No |
| EVT_ROLE_APPROPRIATE_BEHAVIOR | Player follows role-expected routine in context | Conformity | TIER_LOW | No |

## Resolution Rules

| Rule ID | Rule |
|---|---|
| R1 | Apply at most one primary event key per witnessed action |
| R2 | If multiple keys qualify, choose the highest-severity mismatch key |
| R3 | If mismatch and conformity both qualify, mismatch wins in Phase 1 |
| R4 | Apply clamp after each delta application |
| R5 | Do not apply zone-based multipliers in this version |

## Telemetry And Balancing Loop

| Step | Action | Output |
|---|---|---|
| 1 | Log event key, witness id, tier, pre value, post value | Raw balancing dataset |
| 2 | Track time-to-threshold and time-to-recovery per play session | Pacing evidence |
| 3 | Review top over-triggered event keys and under-felt event keys | Candidate tuning list |
| 4 | Adjust BALANCE_TIER_* placeholders only (keep event semantics stable) | New balancing build |
| 5 | Re-test with same scenario set and compare deltas | Change impact report |

## Initial Calibration Heuristics

| Heuristic ID | Guideline |
|---|---|
| H1 | A single low-tier mistake should feel noticeable but recoverable quickly |
| H2 | Repeated medium-tier mistakes should create sustained social pressure |
| H3 | High-tier events should push toward escalation fast enough to be legible |
| H4 | Critical-tier events should be rare and reserved for clear boundary violations |
| H5 | Positive conformity must provide a viable non-stealth recovery path |

## Open Calibration Items

| Item ID | Description | Owner | Status |
|---|---|---|---|
| CAL-001 | Set first-pass numeric values for BALANCE_TIER_* | Design + Implementation | Pending |
| CAL-002 | Decide whether BALANCE_DECAY_IDLE is enabled in Phase 1 | Design | Pending |

## Change Log

| Date | Change |
|---|---|
| 2026-06-29 | Created symbolic v1 catalog aligned to DEC-WS3-001 answers |
| 2026-07-01 | Added rumor-eligible flag column to event dictionary per DEC-WS3-004; high and critical tier events are eligible |

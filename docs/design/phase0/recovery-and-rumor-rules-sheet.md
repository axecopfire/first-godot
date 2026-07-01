---
title: Recovery and Rumor Rules Sheet
description: Phase 1 recovery contract and rumor propagation rules synthesized from Workstream 3 decisions
ms.date: 2026-07-01
ms.topic: reference
keywords:
  - suspicion
  - recovery
  - rumor
  - trust
  - balancing
estimated_reading_time: 7
---

## Purpose

Define the implementation-ready rules for suspicion recovery and rumor propagation in Phase 1.

This sheet is the canonical reference for recovery and rumor behavior.
Balance constants marked as PLACEHOLDER must be calibrated during implementation
and playtesting before shipping.

## Source Decisions

| Decision ID | Contribution |
|---|---|
| DEC-WS3-001 | Single trust-suspicion spectrum, no zone multipliers |
| DEC-WS3-003 | Recovery step model, zone-independent recovery guarantee, same-witness-only scope |
| DEC-WS3-004 | Rumor trigger classes, spread scope, and second-hand cap |

## Model Contract

| Field | Rule |
|---|---|
| Spectrum | Single trust-suspicion spectrum; trust at one end, suspicion at the other |
| Scale | 0 to 100 per NPC witness |
| Multipliers | No zone multipliers in Phase 1 |
| Evaluation scope | Per NPC, per witnessed action |

## Recovery Rules

### Core Recovery Contract

| Rule ID | Rule |
|---|---|
| REC-01 | Recovery requires a witnessed conformity action; passive time decay does not apply |
| REC-02 | Each valid witnessed conformity action applies one fixed recovery step |
| REC-03 | The fixed recovery step is a PLACEHOLDER constant; set and tune during implementation |
| REC-04 | No multipliers, rapid-compliance modifiers, or severity-specific recovery formulas apply in Phase 1 |
| REC-05 | Recovery applies only on the same witness NPC who observes the conformity action |
| REC-06 | Sponsors and witness-sharing mechanics are deferred to later phases |

### Early Loop Recovery Guarantee

| Rule ID | Rule |
|---|---|
| REC-G1 | The early loop must always offer at least one low-friction recovery action independent of zone |
| REC-G2 | No zone should be designed where all available actions are high-risk or mismatch-only |
| REC-G3 | The starter recovery action list must be locked in implementation docs before Phase 1 ships |

### Recovery Placeholder Constants

| Constant | Initial placeholder rule |
|---|---|
| BALANCE_RECOVERY_STEP | One conservative fixed step; tune upward or downward from playtest feedback |

## Rumor Rules

### Rumor Trigger Contract

| Rule ID | Rule |
|---|---|
| RUM-01 | Rumor packets are emitted only for high-tier and critical-tier events in Phase 1 |
| RUM-02 | Low-tier and medium-tier events do not emit rumor packets |
| RUM-03 | High-tier and critical-tier mismatch events are tagged rumor-eligible in the event catalog |

### Rumor Spread Scope

| Rule ID | Rule |
|---|---|
| RUM-S1 | Eligible rumor packets use village-class scope by default |
| RUM-S2 | Village-class scope reaches all active witnesses in the village context |
| RUM-S3 | Lane-class and local-class spread are reserved for future phases |

### Rumor Contribution Cap

| Rule ID | Rule |
|---|---|
| RUM-C1 | Second-hand suspicion contribution from one rumor packet is capped at a low, non-zero amount |
| RUM-C2 | The cap preserves recoverability; rumor-only hard-fail states must not be possible |
| RUM-C3 | BALANCE_RUMOR_CAP_HIGH and BALANCE_RUMOR_CAP_CRITICAL are PLACEHOLDER constants |
| RUM-C4 | Start with one conservative shared cap across enabled classes; split by class after playtest |

### Rumor Placeholder Constants

| Constant | Initial placeholder rule |
|---|---|
| BALANCE_RUMOR_CAP_HIGH | One conservative low cap; tune from playtest telemetry |
| BALANCE_RUMOR_CAP_CRITICAL | One conservative low cap; tune from playtest telemetry |

## Recovery Versus Rumor Conflict

If the same witness has received a rumor contribution and the player then performs a conformity
action in front of that witness, the fixed recovery step applies normally.
Recovery can counteract rumor-sourced suspicion using the same per-witness mechanism.

## Open Issues

| ID | Issue | Owner | Due date | Fallback rule |
|---|---|---|---|---|
| WS3-001-O1 | Numeric thresholds for severity bands need playtest calibration | Design | 2026-07-15 | Start with evenly spaced provisional bands and iterate from telemetry |
| WS3-003-O1 | Fixed recovery step value and starter recovery action list need tuning | Design | 2026-07-01 | Use one conservative fixed step and ship with one always-available low-friction action |
| WS3-004-O1 | Calibrate low, non-zero rumor contribution caps by class | Design | 2026-07-15 | Start with one conservative shared cap across enabled classes |

## Change Log

| Date | Change |
|---|---|
| 2026-07-01 | Created from DEC-WS3-001, DEC-WS3-003, and DEC-WS3-004 answers and synthesis |

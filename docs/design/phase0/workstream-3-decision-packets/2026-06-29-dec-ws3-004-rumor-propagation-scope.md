---
title: Rumor Propagation Scope
description: Single-decision packet for Phase 1 rumor propagation classes and spread limits
ms.date: 2026-06-29
ms.topic: how-to
keywords:
  - decision packet
  - design
  - systems
estimated_reading_time: 8
---

## Metadata

| Field | Value |
|---|---|
| Decision ID | DEC-WS3-004 |
| Domain | systems |
| Owner | Design |
| Status | Answered-With-Tuning-Pending |
| Created | 2026-06-29 |
| Target decision date | 2026-07-01 |

## Decision Scope

### In scope

Decide whether any second-hand rumor propagation exists in Phase 1 and define the boundary for deferral.

### Out of scope

Complex social graph simulation, witness-to-witness transfer with decay, institution politics, and long-term memory persistence beyond Phase 1.

## Decision Statement Draft

We need to decide the minimal rumor propagation scope under Phase 1 constraints to optimize social consequence readability without creating opaque punishment.

## Context Overview

Workstream 3 requires rumor spread classes for severe versus local events. Phase 1 needs enough propagation for social pressure while preserving clear cause and effect.

## Terminology Lock

| Term | Phase 1 definition |
|---|---|
| District | Broad map grouping used for world structure and narrative framing |
| Zone | Gameplay area used by threshold and enforcement behaviors |
| Location | Concrete place or interactable spot inside a zone where witnessed actions occur |

## Evidence And References

| Source artifact | Relevant excerpt or summary | Why it matters |
|---|---|---|
| docs/general/PHASE_0_DEVELOPMENT_PLAN.md | Rumor spread classes are a required Workstream 3 output | Makes rumor scope mandatory |
| docs/general/MECHANICS_SPEC.md | Rumor propagation is severe-event oriented and should support witness memory | Constrains trigger and intensity |
| docs/places/village.md | Village has strong lane structure and role-based visibility differences | Supports local, lane, and village spread classes |

## Dependency Tree

### Upstream dependencies

* DEC-WS3-001 baseline event severity model
* DEC-WS3-002 threshold enforcement contract

### Downstream consumers

* Recovery versus rumor conflict rule
* NPC role design in Workstream 2
* Map-level threshold visibility planning in Workstream 5

### Blockers and assumptions

* Assumption: rumor packets are emitted only for high and critical events in Phase 1.
* Assumption: village-class packets can apply a capped low, non-zero second-hand contribution.

## Precedent

| Decision ID | Relationship | Rationale |
|---|---|---|
| DEC-WS3-001 | Adapt | Severity bands drive rumor trigger classes |
| DEC-WS3-002 | Adapt | Enforcement outcomes can emit village-class rumors |

## Question Set

| Question ID | Question | Why this exists | Expected answer format | Impact if unanswered |
|---|---|---|---|---|
| Q01 | In Phase 1, should rumors trigger only from high and critical events, or include selected medium events? | Determines noise level and player readability | Choice plus event class list | Rumor system may overfire or underfire |
| Q02 | Should village-class rumors be limited to key witnesses, or reach all active witnesses by default? | Controls fairness and systemic pressure | One scope rule | Second-hand suspicion balance is unstable |
| Q03 | What is the maximum second-hand suspicion contribution from one rumor packet by class? | Needed to prevent rumor-only hard fail states | Numeric caps per class | Tuning cannot guarantee recoverability |

## Answers

| Question ID | Answer |
|---|---|
| Q01 | Trigger rumor packets only from high and critical events in Phase 1. |
| Q02 | Use village-class scope by default for eligible rumor packets, reaching all active witnesses. |
| Q03 | Use a low, non-zero second-hand suspicion contribution cap per rumor packet class in Phase 1. |

## Synthesis

### Resolved points

* Phase 1 enables second-hand rumor propagation for high and critical events only.
* Eligible packets use village-class scope and can reach all active witnesses.
* Second-hand rumor contribution is capped at a low, non-zero amount to preserve recoverability.

### Unresolved points

* Exact low-cap numeric values per rumor class remain open pending playtest calibration.

### Confidence

Medium. The scope is clear, but numeric tuning is still required.

### Tradeoffs

* High and critical gating protects readability but may under-represent lower-level social chatter.
* Village-class scope strengthens social pressure and world coherence, but raises over-punishment risk in dense scenes.
* Low, non-zero contribution allows measurable systemic impact without making rumor-only failure states likely.

## Proposed Artifact Changes

| Action | Artifact | Proposed change | Rationale |
|---|---|---|---|
| Update | docs/design/phase0/recovery-and-rumor-rules-sheet.md | Set Phase 1 rumor spread to high and critical events with village-class scope and low, non-zero second-hand cap | Lock implementation-facing rumor behavior and safeguard recoverability |
| Update | docs/design/phase0/suspicion-event-catalog-v1.md | Add rumor-eligible flag for high and critical mismatch events and reference low, non-zero second-hand cap | Keep event catalog and rumor scope consistent |

## Open Issues And Carry-Forward

| ID | Issue | Owner | Due date | Fallback rule |
|---|---|---|---|---|
| WS3-004-O1 | Calibrate low, non-zero second-hand rumor contribution caps by class | Design | 2026-07-15 | Start with one conservative low cap shared across enabled classes and tune from playtest telemetry |

## Exit Check

* Single-decision boundary maintained.
* Every active question passes quality gates.
* Answers mapped one-to-one to question IDs.
* Synthesis maps to concrete artifact proposals.
* Dependencies and downstream impacts are explicit.

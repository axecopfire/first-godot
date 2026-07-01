---
title: Threshold Reaction Contracts 35 60 80
description: Single-decision packet for threshold reaction contracts at suspicion 35, 60, and 80
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
| Decision ID | DEC-WS3-002 |
| Domain | systems |
| Owner | Design |
| Status | Answered-With-Tuning-Pending |
| Created | 2026-06-29 |
| Target decision date | 2026-07-01 |

## Decision Scope

### In scope

Define exact behavioral contracts for alert, hostile, and enforcement states at thresholds 35, 60, and 80.

### Out of scope

Exact pathfinding code, animation implementation, and prison scene content.

## Decision Statement Draft

We need to decide threshold reaction contracts under per-NPC suspicion constraints to optimize clarity, fairness, and reliable escalation in Phase 1.

## Context Overview

The phase plan locks threshold reactions at 35, 60, and 80. Current prototype has no finalized escalation contract yet, so implementation risks drift unless contracts are fixed.

## Evidence And References

| Source artifact | Relevant excerpt or summary | Why it matters |
|---|---|---|
| docs/general/PHASE_0_DEVELOPMENT_PLAN.md | Workstream 3 requires Threshold Reaction Playbook at 35, 60, and 80 | Defines mandatory output |
| docs/general/MECHANICS_SPEC.md | Threshold reactions are phase-1 target and arrest must reset suspicion baseline while preserving language | Constrains enforcement and reset behavior |
| docs/places/village.md | Barracks and warehouse are high-enforcement spaces and market is high visibility | Requires zone-aware reaction readability |

## Dependency Tree

### Upstream dependencies

* DEC-WS3-001 baseline delta model

### Downstream consumers

* Arrest and recovery loop contract
* NPC routine and witness placement in Workstream 2
* Implementation acceptance criteria for hostile and arrest behaviors

### Blockers and assumptions

* Assumption: each NPC evaluates threshold locally each tick.
* Assumption: highest nearby threshold state drives player-facing feedback priority.

## Precedent

| Decision ID | Relationship | Rationale |
|---|---|---|
| DEC-WS3-001 | Adapt | Threshold cadence depends on accepted delta model |

## Question Set

| Question ID | Question | Why this exists | Expected answer format | Impact if unanswered |
|---|---|---|---|---|
| Q01 | At threshold 35, should follow behavior persist with a minimum timer even after line-of-sight break? | Controls readability versus frustration | Timer value and break condition | Alert behavior remains inconsistent |
| Q02 | At threshold 60, should nearby authority NPCs be pulled by support-call logic in Phase 1 or deferred? | Affects complexity and perceived danger | Defer or include with radius value | Hostile state balance cannot be tuned reliably |
| Q03 | At threshold 80, should arrest require sustained contact time or allow instant capture on overlap? | Determines fairness and escape possibility | One choice with optional duration value | Arrest loop feel remains ambiguous |

## Answers

| Question ID | Answer |
|---|---|
| Q01 | Follow behavior persists on a short timer after line-of-sight breaks, stays inside its zone, and can end early if the target leaves the zone. Higher severity can trigger support calls. |
| Q02 | Include support-call logic in Phase 1, but keep it local to the same zone. Defer ally vouching and arrival support to a later mechanic. |
| Q03 | Allow instant capture on overlap. |

## Synthesis

### Resolved points

* Follow behavior is timer-based, zone-locked, and ends when line of sight breaks or the target leaves the zone.
* Severity can escalate a follow state into local support calls from nearby authority NPCs.
* Arrest uses instant capture on overlap for Phase 1.

### Unresolved points

* Exact follow timer length still needs tuning.
* Ally vouching support is deferred to a later mechanic.

### Confidence

Medium. The core escalation contract is set, but the follow timer still needs tuning.

### Tradeoffs

* Longer follow persistence improves clarity but can increase pressure fatigue.
* Zone-local support calls make escalation readable but can still over-punish early mistakes in dense spaces.
* Instant capture improves urgency and clarity but reduces escape ambiguity.

## Proposed Artifact Changes

| Action | Artifact | Proposed change | Rationale |
|---|---|---|---|
| Update | docs/general/MECHANICS_SPEC.md | Tighten the threshold reactions row to reflect timer-based follow, same-zone support calls, and instant capture on overlap | Keep the Phase 1 contract aligned with the accepted decision |
| Update | docs/general/MECHANICS_SPEC.md | Add ally vouching as a deferred support mechanic for later phases | Preserve the future social-support idea without expanding Phase 1 scope |

## Open Issues And Carry-Forward

| ID | Issue | Owner | Due date | Fallback rule |
|---|---|---|---|---|
| WS3-002-O1 | Follow timer still needs tuning | Design | 2026-07-01 | Start with a short timer and adjust from playtest feedback |

## Exit Check

* Single-decision boundary maintained.
* Every active question passes quality gates.
* Answers mapped one-to-one to question IDs.
* Synthesis maps to concrete artifact proposals.
* Dependencies and downstream impacts are explicit.

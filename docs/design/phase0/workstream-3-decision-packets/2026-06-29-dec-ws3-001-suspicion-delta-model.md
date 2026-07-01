---
title: Suspicion Delta Model
description: Single-decision packet for baseline suspicion and trust delta model in Workstream 3
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
| Decision ID | DEC-WS3-001 |
| Domain | systems |
| Owner | Design |
| Status | Answered-With-Tuning-Pending |
| Created | 2026-06-29 |
| Target decision date | 2026-07-01 |

## Decision Scope

### In scope

Define the baseline numeric model for per-witness suspicion and trust deltas in Phase 1.

### Out of scope

Threshold behavior details, arrest sequence flow, and full rumor network propagation.

## Decision Statement Draft

We need to decide the baseline delta model for witnessed events under Phase 1 constraints to optimize readability, recoverability, and consistent social-assimilation pressure.

## Context Overview

Workstream 3 requires an executable ruleset with minimal ambiguity. The prototype currently supports movement, interaction, item pickup and drop, and basic NPC dialogue, but does not yet lock event magnitudes.

## Terminology Lock

| Term | Phase 1 definition |
|---|---|
| District | Broad map grouping used for world structure and narrative framing |
| Zone | Gameplay area used by threshold and enforcement behaviors |
| Location | Concrete place or interactable spot inside a zone where actions occur |

## Evidence And References

| Source artifact | Relevant excerpt or summary | Why it matters |
|---|---|---|
| docs/general/PHASE_0_DEVELOPMENT_PLAN.md | Workstream 3 asks for an event dictionary with trigger conditions and severity bands | Requires explicit numeric deltas |
| docs/general/MECHANICS_SPEC.md | Suspicion is per NPC witness and active conformity is required for reduction | Sets hard constraints on delta behavior |
| docs/places/village.md | Market, warehouse, and barracks differ strongly in social risk and visibility | Supports event variety and witness context, not per-zone delta multipliers |

## Dependency Tree

### Upstream dependencies

* Phase 0 scope lock for social-assimilation-first suspicion
* Current Phase 1 action set from prototype interactions

### Downstream consumers

* Threshold playbook values and escalation feel
* Recovery and rumor conversion rules
* Future implementation in event_witnessed signal processing

### Blockers and assumptions

* Assumption: values are clamped 0-100 per NPC.
* Assumption: one witnessed event maps to one primary delta event before modifiers.

## Precedent

| Decision ID | Relationship | Rationale |
|---|---|---|
| None | Adapt | Fresh packet in new workflow |

## Question Set

| Question ID | Question | Why this exists | Expected answer format | Impact if unanswered |
|---|---|---|---|---|
| Q01 | What target range should low, medium, high, and critical suspicion deltas use before modifiers? | Needed to stabilize balancing and threshold pacing | Four numeric ranges | Threshold design stays speculative |
| Q02 | Should trust always move opposite suspicion, or be partially independent for selected events? | Determines whether social nuance can exist in early loop | Choice with rule exceptions | Relationship tuning becomes inconsistent |
| Q03 | Should zone multipliers apply to all event types or only mismatch events? | Affects fairness in safe spaces and enforcement spaces | Binary choice with one rule note | Zone readability and exploit risk remain unclear |

## Answers

| Question ID | Answer |
|---|---|
| Q01 | Keep low, medium, high, and critical thresholds speculative in this packet and tune via playtests during implementation. |
| Q02 | Trust and suspicion are a single spectrum, with trust at one end and suspicion at the other. |
| Q03 | Do not use zone multipliers in the Phase 1 baseline model. |

## Synthesis

### Resolved points

* Threshold values remain intentionally provisional until implementation and playtest balancing.
* Trust and suspicion use one shared spectrum instead of partially independent tracks.
* Zone multipliers are excluded from the Phase 1 baseline model.

### Unresolved points

* Exact numeric threshold values for low, medium, high, and critical deltas are pending playtest data.

### Confidence

Medium. Core model direction is clear, but balancing data is still required.

### Tradeoffs

* Deferring numeric thresholds preserves flexibility but delays precise escalation tuning.
* A single trust-suspicion spectrum improves readability but reduces modeling nuance for mixed social states.
* Removing zone multipliers simplifies rules and communication but may reduce local-context differentiation until later phases.

## Proposed Artifact Changes

| Action | Artifact | Proposed change | Rationale |
|---|---|---|---|
| Update | docs/design/phase0/suspicion-event-catalog-v1.md | Define low, medium, high, and critical bands as symbolic severity tiers with playtest-tuning placeholders instead of fixed numbers | Preserve balancing flexibility before implementation |
| Update | docs/design/phase0/recovery-and-rumor-rules-sheet.md | Align recovery logic to the single trust-suspicion spectrum model and keep threshold constants marked provisional | Keep recovery behavior coherent with the accepted model |

## Open Issues And Carry-Forward

| ID | Issue | Owner | Due date | Fallback rule |
|---|---|---|---|---|
| WS3-001-O1 | Numeric thresholds for severity bands need playtest calibration during implementation | Design | 2026-07-15 | Start with evenly spaced provisional bands and iterate from telemetry and playtest feedback |

## Exit Check

* Single-decision boundary maintained.
* Every active question passes quality gates.
* Answers mapped one-to-one to question IDs.
* Synthesis maps to concrete artifact proposals.
* Dependencies and downstream impacts are explicit.

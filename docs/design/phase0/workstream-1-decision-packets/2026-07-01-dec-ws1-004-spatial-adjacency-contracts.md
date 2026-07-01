---
title: Spatial Adjacency Contracts
description: Single-decision packet for Workstream 1 location adjacency and traversal contract model
ms.date: 2026-07-01
ms.topic: how-to
keywords:
  - decision packet
  - design
  - world
estimated_reading_time: 8
---

## Metadata

| Field | Value |
|---|---|
| Decision ID | DEC-WS1-004 |
| Domain | world |
| Owner | Design |
| Status | Awaiting-Answers |
| Created | 2026-07-01 |
| Target decision date | 2026-07-03 |

## Decision Scope

### In scope

Define the Phase 1 adjacency contract model used to connect locations into readable traversal loops without dead ends for core progression paths.

### Out of scope

Final map art layout, exact path costs, and dynamic routing implementation.

## Decision Statement Draft

We need to decide the adjacency contract model for Phase 1 locations under core-loop progression constraints to optimize branch readability, recovery access, and modular map expansion.

## Context Overview

Workstream 1 requires location adjacency contracts that support storyboard loops. If adjacency semantics are vague, Workstream 4 module sequencing and Workstream 5 storyboard-to-zone mapping will require rework.

## Evidence And References

| Source artifact | Relevant excerpt or summary | Why it matters |
|---|---|---|
| docs/general/PHASE_0_DEVELOPMENT_PLAN.md | Workstream 1 requires adjacency contracts that support storyboard loops without dead ends | Defines the decision requirement |
| docs/general/storyboard_modular.drawio | Core loop includes first failure, recovery, observed action, trust gains, and night choices | Adjacency must permit loop transitions under pressure |
| docs/general/MAP_PLAN.md | Zone relationships define the intended progression structure | Contract model must map to zone-level plans |
| docs/general/GAME_DESIGN.md | Early-game flow emphasizes social assimilation and recoverability | Adjacency should preserve non-stealth recovery routes |

## Dependency Tree

### Upstream dependencies

* DEC-WS1-001 taxonomy contract
* DEC-WS1-003 entry and visibility contract model

### Downstream consumers

* Workstream 4 core loop module catalog and fail-state routing
* Workstream 5 storyboard-to-zone crosswalk and map gap register
* Phase 1 implementation slicing for zone modules

### Blockers and assumptions

* Assumption: adjacency is authored at location level and summarized at zone level.
* Assumption: at least one low-pressure fallback route must exist from every high-pressure branch node.

## Precedent

| Decision ID | Relationship | Rationale |
|---|---|---|
| DEC-WS1-001 | Adapt | Role taxonomy informs adjacency intent tags |
| DEC-WS3-003 | Reuse | Recovery guardrail requires reachable fallback paths |

## Question Set

| Question ID | Question | Why this exists | Expected answer format | Impact if unanswered |
|---|---|---|---|---|
| Q01 | Should adjacency contracts require intent-labeled edge types (progression, recovery, stealth, labor, social) instead of unlabeled links? | Prevents ambiguous traversal semantics | Yes or no plus edge-type list | Crosswalk and module routing remain vague |
| Q02 | Should every high-pressure location be required to connect to at least one recovery-capable node within two hops? | Enforces recoverability in spatial design | Yes or no plus hop rule | Players may enter unrecoverable pressure corridors |
| Q03 | Should one-way adjacency be allowed in Phase 1 outside scripted events? | Defines baseline map readability and player agency | Allow or disallow with exception set | Dead-end and pacing behavior remains inconsistent |

## Answers

| Question ID | Answer |
|---|---|
| Q01 | Pending decision session |
| Q02 | Pending decision session |
| Q03 | Pending decision session |

## Synthesis

### Resolved points

* None yet.

### Unresolved points

* Intent-labeled edge requirement is not locked.
* Recovery-distance adjacency requirement is not locked.
* One-way adjacency allowance is not locked.

### Confidence

Low. This packet is awaiting answers.

### Tradeoffs

* Labeled edge contracts improve system clarity but add mapping overhead.
* Strict recovery-distance rules improve fairness but can constrain dramatic pacing.

## Proposed Artifact Changes

| Action | Artifact | Proposed change | Rationale |
|---|---|---|---|
| Update | docs/design/phase0/spatial-contract-map.md | Add directed adjacency schema with edge intent labels and recovery-distance validation notes | Make traversal contracts implementation-ready |
| Update | docs/design/phase0/storyboard-zone-crosswalk.md | Add adjacency dependency references for each storyboard beat transition | Tie beat flow to map contracts explicitly |

## Open Issues And Carry-Forward

| ID | Issue | Owner | Due date | Fallback rule |
|---|---|---|---|---|
| WS1-004-O1 | Adjacency semantics and recovery-distance rule are not approved | Design | 2026-07-03 | Use undirected provisional links and annotate risky dead-end candidates for review |

## Exit Check

* Single-decision boundary maintained.
* Every active question passes quality gates.
* Answers mapped one-to-one to question IDs.
* Synthesis maps to concrete artifact proposals.
* Dependencies and downstream impacts are explicit.
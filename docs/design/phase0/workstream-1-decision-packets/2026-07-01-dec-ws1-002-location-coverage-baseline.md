---
title: Location Coverage Baseline
description: Single-decision packet for Workstream 1 baseline normalization and net-new location coverage requirements
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
| Decision ID | DEC-WS1-002 |
| Domain | world |
| Owner | Design |
| Status | Decided |
| Created | 2026-07-01 |
| Target decision date | 2026-07-03 |

## Decision Scope

### In scope

Confirm whether Phase 1 requires any location normalization or net-new location coverage additions.

### Out of scope

Exact geometry layouts, asset production, and implementation ordering.

## Decision Statement Draft

We decide to keep the current Phase 1 location set unchanged, with no mandatory normalization pass and no net-new location additions.

## Context Overview

This packet resolves whether Workstream 1 must change location coverage for Phase 1 readiness. The decision is to keep existing locations as-is and avoid introducing additional location-scope obligations in this phase gate.

## Evidence And References

| Source artifact | Relevant excerpt or summary | Why it matters |
|---|---|---|
| docs/general/PHASE_0_DEVELOPMENT_PLAN.md | Workstream 1 requires normalization first, plus minimum net-new additions by role | Defines hard scope floor |
| docs/places/village.md | Existing location set has uneven detail and role clarity | Indicates normalization needs |
| docs/general/MAP_PLAN.md | Map evolution expects expanded traversal and interaction coverage | Requires explicit growth targets |
| docs/general/DEV_PLAN.md | Phase work must remain modular and implementation-ready | Coverage decision must be auditable and bounded |

## Dependency Tree

### Upstream dependencies

* DEC-WS1-001 taxonomy contract
* Workstream 3 threshold and recovery rules

### Downstream consumers

* Workstream 2 final witness placement and staffing density
* Workstream 5 map gap register and zone-mechanic crosswalk
* Phase 1 definition-of-ready checklist

### Blockers and assumptions

* Assumption: normalization includes role assignment, visibility profile, and social appropriateness notes for each existing location.
* Assumption: net-new coverage is validated by role intent and adjacency, not by art-complete spaces.

## Precedent

| Decision ID | Relationship | Rationale |
|---|---|---|
| DEC-WS1-001 | Adapt | Coverage lock depends on canonical role taxonomy |

## Question Set

| Question ID | Question | Why this exists | Expected answer format | Impact if unanswered |
|---|---|---|---|---|
| Q01 | What exact normalization checklist must every existing location pass before new locations can be accepted? | Defines acceptance gate and avoids partial backfill | Checklist with mandatory fields | Readiness claims remain subjective |
| Q02 | Should net-new location requirements stay at the current minimum role count or be increased for early-loop redundancy? | Sets design workload and resilience level | Choose minimum or expanded count with rationale | Scope and coverage tradeoffs remain implicit |
| Q03 | Should milestone acceptance require at least one low-risk and one high-risk test location per major Phase 1 mechanic? | Enforces testability across mechanics | Yes or no plus validation rule | Mechanics may ship without clear testing coverage |

## Answers

| Question ID | Answer |
|---|---|
| Q01 | No normalization checklist required for this phase gate. Existing locations are accepted as-is with no mandatory update pass. |
| Q02 | Net-new location requirements are removed. Keep the current location set unchanged with no expanded redundancy target. |
| Q03 | No. Milestone acceptance will not require low-risk and high-risk test-location pairs per major mechanic in this packet. |

## Synthesis

### Resolved points

* Existing locations remain unchanged for this decision window.
* No net-new location additions are required.
* No additional location-based mechanic risk-pair acceptance rule is required.

### Unresolved points

* None.

### Confidence

High. The scope direction is explicit and constrained.

### Tradeoffs

* Keeping locations unchanged reduces design and implementation churn.
* This choice may reduce early-loop coverage redundancy and test-surface breadth.

## Proposed Artifact Changes

| Action | Artifact | Proposed change | Rationale |
|---|---|---|---|
| No update | docs/design/phase0/location-design-matrix.md | No changes required under this decision | Existing locations are explicitly accepted as-is |
| No update | docs/design/phase0/phase1-definition-of-ready-checklist.md | No Workstream 1 location-coverage additions required from this packet | No net-new or extra location-gate criteria are being introduced |

## Open Issues And Carry-Forward

| ID | Issue | Owner | Due date | Fallback rule |
|---|---|---|---|---|
| None | No open issues | Design | 2026-07-03 | Continue with current location set unless a new decision packet supersedes this one |

## Exit Check

* Single-decision boundary maintained.
* Every active question passes quality gates.
* Answers mapped one-to-one to question IDs.
* Synthesis maps to concrete artifact proposals.
* Dependencies and downstream impacts are explicit.
---
title: Entry and Visibility Contracts
description: Single-decision packet for Workstream 1 location entry, witness visibility, and social-appropriateness rules
ms.date: 2026-07-01
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
| Decision ID | DEC-WS1-003 |
| Domain | systems |
| Owner | Design |
| Status | Awaiting-Answers |
| Created | 2026-07-01 |
| Target decision date | 2026-07-03 |

## Decision Scope

### In scope

Define the Phase 1 contract for location entry permissions, witness visibility pressure, ambient cover assumptions, and social appropriateness bands.

### Out of scope

Line-of-sight implementation code, stealth tuning constants, and arrest animation flow.

## Decision Statement Draft

We need to decide a single entry and visibility contract model under social-assimilation-first constraints to optimize fair suspicion signaling and consistent readability across locations.

## Context Overview

Workstream 1 requires explicit entry and visibility rules per location. These contracts feed Workstream 3 mismatch heuristics, Workstream 2 witness placement, and Workstream 5 threshold visibility mapping. Unclear contracts will produce contradictory suspicion outcomes in equivalent player actions.

## Evidence And References

| Source artifact | Relevant excerpt or summary | Why it matters |
|---|---|---|
| docs/general/PHASE_0_DEVELOPMENT_PLAN.md | Workstream 1 requires expected witnesses, line-of-sight pressure, ambient cover, and social appropriateness bands | Defines this packet's decision boundary |
| docs/design/phase0/social-norm-rulebook-v1.md | Wrong place and context-inappropriate actions are explicit mismatch classes | Entry permissions must map to mismatch categories |
| docs/design/phase0/suspicion-event-catalog-v1.md | Event severity depends on witnessed context and action interpretation | Visibility rules need consistent interpretation anchors |
| docs/general/MECHANICS_SPEC.md | Suspicion is witness-driven and recovery requires social conformity | Entry model must support readable witness logic |

## Dependency Tree

### Upstream dependencies

* DEC-WS1-001 taxonomy contract
* DEC-WS3-001 suspicion delta model
* DEC-WS3-003 recovery rules contract

### Downstream consumers

* Workstream 2 witness and sponsor coverage definitions
* Workstream 4 interaction module fail-path contracts
* Workstream 5 threshold visibility map

### Blockers and assumptions

* Assumption: each location can declare one default visibility pressure tier and one override condition set.
* Assumption: social appropriateness is evaluated by role, timing, and player presentation cues.

## Precedent

| Decision ID | Relationship | Rationale |
|---|---|---|
| DEC-WS3-001 | Reuse | Keeps district, zone, and location terminology stable |
| DEC-WS3-003 | Adapt | Recovery viability depends on clarity of witnessed conformity and mismatch contexts |

## Question Set

| Question ID | Question | Why this exists | Expected answer format | Impact if unanswered |
|---|---|---|---|---|
| Q01 | Should Phase 1 use a fixed three-tier visibility model per location (low, medium, high) with explicit trigger overrides? | Determines readability and authoring complexity | Yes or no plus model rule | Visibility interpretation will vary by author |
| Q02 | Should entry permission be represented as social appropriateness bands (expected, tolerated, suspicious, forbidden) instead of binary allow-deny? | Affects mismatch nuance and warning design | One model choice with label set | Entry outcomes may become abrupt and opaque |
| Q03 | Should ambient cover reduce witness confidence only for line-of-sight-sensitive events and never for explicit social violations? | Prevents cover from trivializing social-assimilation pressure | Yes or no with one exception rule | Cover mechanics may undermine social rules |

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

* Visibility tier model is not locked.
* Entry representation model is not locked.
* Ambient cover interaction with social violations is not locked.

### Confidence

Low. This packet is awaiting answers.

### Tradeoffs

* A richer entry model supports social nuance but increases authoring overhead.
* Simpler visibility rules improve implementation speed but may flatten location identity.

## Proposed Artifact Changes

| Action | Artifact | Proposed change | Rationale |
|---|---|---|---|
| Update | docs/design/phase0/location-design-matrix.md | Add entry permission band and visibility pressure fields per location | Turn qualitative rules into comparable rows |
| Update | docs/design/phase0/social-norm-rulebook-v1.md | Add mapping table from entry bands and visibility tiers to mismatch interpretation guidance | Keep social rulebook and location contracts synchronized |

## Open Issues And Carry-Forward

| ID | Issue | Owner | Due date | Fallback rule |
|---|---|---|---|---|
| WS1-003-O1 | Contract model not approved for entry and visibility interpretation | Design | 2026-07-03 | Use provisional binary entry rules with qualitative visibility notes until model is locked |

## Exit Check

* Single-decision boundary maintained.
* Every active question passes quality gates.
* Answers mapped one-to-one to question IDs.
* Synthesis maps to concrete artifact proposals.
* Dependencies and downstream impacts are explicit.
---
title: Location Taxonomy Contract
description: Single-decision packet for Workstream 1 location taxonomy by gameplay role
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
| Decision ID | DEC-WS1-001 |
| Domain | world |
| Owner | Design |
| Status | Answered |
| Created | 2026-07-01 |
| Target decision date | 2026-07-03 |

## Decision Scope

### In scope

Decide whether Phase 1 uses location roles, location tags, and role-intent texts.

### Out of scope

Zone-specific witness assignments, exact threshold placements, and NPC routine scheduling.

## Decision Statement Draft

We need to lock whether Phase 1 uses any location role taxonomy, role/tag metadata, or intent texts so downstream artifacts use one consistent model.

## Context Overview

Workstream 1 must remove ambiguity about location metadata before Workstreams 2, 4, and 5 advance authoring. If this packet remains unresolved, downstream artifacts will continue to assume role and tag fields that are not wanted.

## Evidence And References

| Source artifact | Relevant excerpt or summary | Why it matters |
|---|---|---|
| docs/general/PHASE_0_DEVELOPMENT_PLAN.md | Workstream 1 explicitly requires a location taxonomy by gameplay role | Makes taxonomy lock a required output |
| docs/general/MECHANICS_SPEC.md | Suspicion and trust are witness-driven with social mismatch as the primary pressure | Taxonomy must reflect social pressure and recovery contexts |
| docs/places/village.md | Current village spaces vary in visibility, enforcement pressure, and social intent | Grounds role labels in existing map reality |
| docs/general/MAP_PLAN.md | Zone and traversal plans imply both safe and risky routes | Requires role tags that support route readability |

## Dependency Tree

### Upstream dependencies

* Phase 0 scope lock that defers institution systems
* Workstream 3 social-assimilation ruleset outputs

### Downstream consumers

* Workstream 2 witness and sponsor coverage grid
* Workstream 4 module-to-location targeting
* Workstream 5 zone mechanic intent table and threshold visibility mapping

### Blockers and assumptions

* Assumption: every implemented location can hold multiple tags but has one primary gameplay role.
* Assumption: taxonomy labels remain stable through Phase 1 and only extend in later phases.

## Precedent

| Decision ID | Relationship | Rationale |
|---|---|---|
| DEC-WS3-001 | Adapt | Uses stable terminology for district, zone, and location that Workstream 1 should preserve |

## Question Set

| Question ID | Question | Why this exists | Expected answer format | Impact if unanswered |
|---|---|---|---|---|
| Q01 | Which primary taxonomy set should be canonical for Phase 1 location roles? | Prevents role-label drift across artifacts | Choose one fixed label set | Downstream artifacts will map locations inconsistently |
| Q02 | Should every location be required to expose both a primary role and optional secondary tags? | Determines authoring and validation constraints | Yes or no plus one rule note | Testing coverage and doc consistency remain ambiguous |
| Q03 | Should role definitions include explicit social-assimilation intent text, not only mechanical intent text? | Preserves core premise framing in early design outputs | Yes or no plus definition rule | Rolebook may drift toward stealth-only framing |

## Answers

| Question ID | Answer |
|---|---|
| Q01 | No location taxonomy set is canonical for Phase 1. |
| Q02 | No. Locations expose neither primary roles nor secondary tags. |
| Q03 | No. No role definitions are authored, so no mechanical or social-assimilation intent text is authored for roles. |

## Synthesis

### Resolved points

* Phase 1 uses no location roles.
* Phase 1 uses no location tags.
* Phase 1 uses no role intent texts, mechanical or social-assimilation.

### Unresolved points

* None.

### Confidence

High. Direct stakeholder decisions were provided for every active question.

### Tradeoffs

* Removing role and tag metadata simplifies authoring and validation.
* Downstream documents must rely on explicit location IDs and zone context instead of role abstractions.

## Proposed Artifact Changes

| Action | Artifact | Proposed change | Rationale |
|---|---|---|---|
| Update | docs/design/phase0/location-design-matrix.md | Remove role and tag columns; keep location-level mechanics and thresholds only | Align matrix schema with no-role, no-tag decision |
| Update | docs/design/phase0/spatial-contract-map.md | Remove role and tag annotations; keep node identity and adjacency only | Prevent reintroduction of role metadata through mapping artifacts |

## Open Issues And Carry-Forward

| ID | Issue | Owner | Due date | Fallback rule |
|---|---|---|---|---|
| WS1-001-O1 | Confirm downstream artifact templates no longer require role or tag fields | Design | 2026-07-03 | If a template still requires those fields, set them to Not Used and log the template for cleanup |

## Exit Check

* Single-decision boundary maintained.
* Every active question passes quality gates.
* Answers mapped one-to-one to question IDs.
* Synthesis maps to concrete artifact proposals.
* Dependencies and downstream impacts are explicit.
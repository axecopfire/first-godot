---
title: Recovery Rules Contract
description: Single-decision packet for active recovery rules and constraints in Phase 1
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
| Decision ID | DEC-WS3-003 |
| Domain | systems |
| Owner | Design |
| Status | Answered-With-Tuning-Pending |
| Created | 2026-06-29 |
| Target decision date | 2026-07-01 |

## Decision Scope

### In scope

Define what actions count as valid active recovery and what the early-loop recovery contract is in Phase 1.

### Out of scope

Late-game sponsorship systems, full relationship economy, and institution-wide pardons.

## Decision Statement Draft

We need to decide the Phase 1 recovery contract under social-assimilation-first constraints to optimize recoverability without removing meaningful risk.

## Context Overview

Phase rules state suspicion does not passively decay and must recover through witnessed conformity. This decision locks recovery viability for non-stealth play.

## Evidence And References

| Source artifact | Relevant excerpt or summary | Why it matters |
|---|---|---|
| .github/copilot-instructions.md | Non-stealth paths must reduce suspicion through social learning | Hard guardrail for recovery design |
| docs/general/MECHANICS_SPEC.md | Active conformity required to reduce suspicion and no passive decay | Core system constraint |
| docs/places/village.md | Church, mill, and labor contexts imply different valid conformity actions | Supports action variety without zone-gating recovery |

## Terminology Lock

| Term | Phase 1 definition |
|---|---|
| District | Broad map grouping used for world structure and narrative framing, not a recovery logic key in Phase 1 |
| Zone | Gameplay area used by threshold and enforcement behaviors |
| Location | Concrete place or interactable spot inside a zone where actions occur |

## Dependency Tree

### Upstream dependencies

* DEC-WS3-001 baseline delta model

### Downstream consumers

* Core loop module contracts in Workstream 4
* Zone mechanic intent table in Workstream 5
* Tutorialization of early failure and recovery path

### Blockers and assumptions

* Assumption: recovery is evaluated per witness and is not gated by zone.
* Assumption: a single mismatch event can be partially recovered by repeated conformity actions.

## Precedent

| Decision ID | Relationship | Rationale |
|---|---|---|
| DEC-WS3-001 | Adapt | Recovery scale depends on baseline magnitudes |

## Question Set

| Question ID | Question | Why this exists | Expected answer format | Impact if unanswered |
|---|---|---|---|---|
| Q01 | Should the early loop always offer at least one low-friction recovery action, regardless of zone? | Needed to satisfy non-stealth recovery guardrail | Yes or no with examples | Early loop may become stealth-only |
| Q02 | Should Phase 1 recovery use one fixed recovery step per valid witnessed conformity action, with no multipliers or severity formulas? | Keeps the loop readable and implementation-light | Yes or no with one rule note | Recovery pacing remains ambiguous |
| Q03 | Should recovery stay same-witness-only in Phase 1, with sponsors and witness sharing deferred? | Defines social-learning breadth and complexity | One model choice | Scope risk remains high |

## Answers

| Question ID | Answer |
|---|---|
| Q01 | Yes. The early loop must always provide at least one low-friction recovery action regardless of zone. |
| Q02 | Yes. Use one fixed recovery step per valid witnessed conformity action in Phase 1. Do not use multipliers, rapid-compliance modifiers, or severity-specific recovery formulas. |
| Q03 | Use same-witness-only recovery in Phase 1. Defer sponsors and witness-sharing mechanics to later phases. |

## Synthesis

### Resolved points

* Early-loop recovery is guaranteed through at least one low-friction action independent of zone.
* Phase 1 recovery uses a fixed-step model with no multipliers and no rapid-compliance rule.
* Recovery remains same-witness-only in Phase 1.
* Sponsor mechanics and witness-sharing are deferred.

### Unresolved points

* Exact fixed-step recovery value still needs tuning.
* Final early-loop recovery action list still needs to be locked in implementation docs.

### Confidence

Medium. Core contract is locked and only tuning details remain.

### Tradeoffs

* Fixed-step recovery improves readability and implementation speed but limits nuance.
* Zone-independent recovery preserves agency but reduces location-specific flavor in Phase 1.
* Same-witness-only logic is clear and testable but can feel narrow in crowded scenes.

## Proposed Artifact Changes

| Action | Artifact | Proposed change | Rationale |
|---|---|---|---|
| Update | docs/design/phase0/recovery-and-rumor-rules-sheet.md | Replace provisional recovery constraints with accepted contract | Ensure recovery is implementation-ready |
| Update | docs/design/phase0/social-norm-rulebook-v1.md | Align conformity evidence section with same-witness-only recovery and fixed-step rule | Keep ruleset internally consistent |

## Open Issues And Carry-Forward

| ID | Issue | Owner | Due date | Fallback rule |
|---|---|---|---|---|
| WS3-003-O1 | Fixed recovery step value and starter recovery action list need tuning | Design | 2026-07-01 | Use one conservative fixed step and ship with one always-available low-friction action |

## Exit Check

* Single-decision boundary maintained.
* Every active question passes quality gates.
* Answers mapped one-to-one to question IDs.
* Synthesis maps to concrete artifact proposals.
* Dependencies and downstream impacts are explicit.

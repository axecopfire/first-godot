---
title: Threshold Reaction Playbook
description: Executable behavioral contracts for NPC threshold reactions at suspicion 35, 60, and 80 in Phase 1
ms.date: 2026-07-01
ms.topic: reference
keywords:
  - suspicion
  - threshold
  - NPC behavior
  - enforcement
estimated_reading_time: 6
---

## Purpose

Define exact behavioral contracts for each suspicion threshold so Phase 1 implementation
has unambiguous acceptance criteria for alert, hostile, and enforcement states.

This playbook is the canonical reference for threshold behavior.
It supersedes any provisional threshold notes in MECHANICS_SPEC.md.

## Source Decisions

| Decision ID | Contribution |
|---|---|
| DEC-WS3-001 | Baseline delta model and single trust-suspicion spectrum |
| DEC-WS3-002 | Follow timer rules, support-call scope, and arrest capture model |

## Evaluation Model

| Rule | Value |
|---|---|
| Evaluation scope | Per NPC, evaluated locally each tick |
| Priority arbitration | Highest threshold state among nearby NPCs drives player-facing feedback priority |
| Spectrum | Single trust-suspicion spectrum; trust at one end, suspicion at the other |
| Value clamp | 0 to 100 per NPC |

## Threshold Contracts

### Threshold 35: Alert State

| Field | Contract |
|---|---|
| Trigger | Individual NPC suspicion reaches or exceeds 35 |
| Behavior | NPC begins timer-based follow toward the player |
| Zone lock | Follow stays inside the NPC's current zone; NPC does not cross zone boundaries to follow |
| Line-of-sight break | Follow persists on a short timer after line-of-sight breaks |
| Zone exit break | Follow ends immediately if the player leaves the zone |
| Severity escalation | If NPC suspicion is elevated further while following, the state can escalate to a local support call |
| Feedback | Player receives a visible social-pressure signal, such as a reactive NPC stance or dialogue |

### Threshold 60: Hostile State

| Field | Contract |
|---|---|
| Trigger | Individual NPC suspicion reaches or exceeds 60 |
| Behavior | NPC actively chases the player and emits a zone-local support call |
| Support call scope | Support calls are limited to authority NPCs inside the same zone |
| Ally vouching | Ally vouching and cross-zone arrival support are deferred to a later mechanic |
| Chase termination | Chase ends if the player exits the zone |
| Feedback | Player receives an escalation signal distinct from the alert state |

### Threshold 80: Enforcement State

| Field | Contract |
|---|---|
| Trigger | Individual NPC suspicion reaches or exceeds 80 |
| Behavior | Arrest triggers on player-NPC overlap |
| Capture model | Instant capture on overlap; no sustained contact time required in Phase 1 |
| Post-arrest suspicion | Suspicion resets to baseline on arrest |
| Post-arrest learning | Language and relationship state are preserved across arrest |
| Feedback | Arrest transition must be legible as a distinct terminal state, not just another escalation |

## Deferred Mechanics

| Mechanic | Deferral note |
|---|---|
| Ally vouching | Deferred to later phase; trusted allies can eventually intervene and vouch during escalation |
| Cross-zone support calls | Support calls stay zone-local in Phase 1; cross-zone coordination is out of scope |
| Follow timer tuning | Short timer length is a tuning variable; set a conservative starting value and adjust from playtest |

## Open Issues

| ID | Issue | Owner | Due date | Fallback rule |
|---|---|---|---|---|
| WS3-002-O1 | Follow timer exact length needs playtest calibration | Design | 2026-07-01 | Start with a short timer and adjust from playtest feedback |

## Change Log

| Date | Change |
|---|---|
| 2026-07-01 | Created from DEC-WS3-002 answers and synthesis |

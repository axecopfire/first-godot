---
title: Location Profile Starting Alley
description: Detailed Workstream 1 profile for the Starting Alley zone
ms.date: 2026-06-28
ms.topic: reference
keywords:
  - location profile
  - alley
  - phase 0
estimated_reading_time: 4
---

## Identity

| Field | Value |
|---|---|
| Location name | Starting Alley |
| Zone key | `alley` |
| Baseline type | Existing |
| Current status | Keep |

## Role and taxonomy

| Question | Answer |
|---|---|
| Short fiction intent | Low-visibility onboarding and reset corridor |
| Primary gameplay role | Safe recovery |
| Secondary gameplay role | Language learning |
| Risk profile and rationale | Low by design to support early retries |
| Intended player loops supported | First contact, stealth recovery, night decision |
| Explicit Phase 1 mechanic unblocked | Arrest recovery restart loop readability |

## Premise and guardrail checks

1. Early pressure remains social because the alley is relief, not total safety.
2. Player learns contrast between hidden and public norms when stepping into the market.
3. Non-stealth recovery uses pacing, observation, and re-entry timing.
4. The alley should not imply secret origin knowledge or explicit identity clues.

## Witness and visibility model

| Prompt | Answer |
|---|---|
| Expected witness roles and institutions | Occasional passerby and patrol spillover |
| Always-on versus conditional witnesses | Mostly conditional by patrol schedule |
| Dominant line-of-sight lanes and cover pockets | Long narrow sightline with wall cover on sides |
| Socially appropriate, suspicious, and severe actions | Appropriate: transit and rest. Suspicious: repeated lurking near market mouth. Severe: active pursuit into alley |
| Threshold visibility priority (35, 60, 80) | Mostly post-threshold spillover, not first reveal |
| Immediate NPC reactions by threshold | 35: watchful passersby. 60: patrol checks. 80: active sweep |

## Entry and access contracts

| Prompt | Answer |
|---|---|
| Allowed entry conditions | Always |
| Discouraged entry conditions | Long stationary behavior near choke exits |
| Forbidden entry conditions | None |
| Time-of-day, weather, institution deltas | Night increases patrol relevance at alley mouth |
| Sponsorship or token required for low-friction entry | None |
| Language or social knowledge requirement | Minimal |
| Context-inappropriate actions and deltas | None severe; low deltas for loitering patterns |

## Adjacency and traversal contracts

| Prompt | Answer |
|---|---|
| Direct connected locations | Market Square and north quarter approach |
| Route hierarchy intent | Recovery buffer and stealth lane |
| Dead-end risk for core loops | Low if both ends remain navigable |
| Safe, risky, and ambiguous transitions | Safe by default, ambiguous when patrol escalates |
| Chokepoints for institution control and stealth alternatives | Alley mouth should remain key observation threshold |
| Recovery adjacency after failure or arrest | Primary early loop recovery adjacency |

## Keep or cut review

| Prompt | Answer |
|---|---|
| Why keep this location in Phase 1 scope | Supports recoverability and pacing without trivializing pressure |
| If revised, what is the minimum revision | Add one contextual tutorial signal for re-entry timing |
| If cut, what location absorbs its function | Church corridor could absorb partially but would reduce loop clarity |
| Decision owner and review date | World design, 2026-06-28 |

## Open issues

| ID | Question | Impact | Owner | Due date | Fallback rule |
|---|---|---|---|---|---|
| WS1-ALLEY-001 | Should minor ambient NPC traffic be added for social norm teaching | Low | Systems design | 2026-07-02 | Keep sparse traffic |

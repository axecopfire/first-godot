---
title: Workstream 7 Faction Mechanics Questionnaire
description: Structured questionnaire to define and normalize faction mechanics for Phase 0 Workstream 7
ms.date: 2026-06-28
ms.topic: how-to
keywords:
  - phase 0
  - workstream 7
  - faction mechanics
  - questionnaire
estimated_reading_time: 12
---

## Purpose

Use this questionnaire to convert Workstream 7 goals into concrete and consistent faction design decisions.

Complete it before finalizing any Workstream 1 through Workstream 5 artifact that depends on faction assumptions.

## How to use

* Run this as a facilitated session with narrative, systems, world design, and balance represented
* Record one clear answer per question, even if temporary
* Mark unknowns as open items with an owner and due date
* Treat unresolved faction gate or coupling questions as blockers for Milestone A stability
* Use the answers here as source authority for all faction naming and threshold contracts

## Premise and guardrail checks

1. How does each faction enforce social assimilation expectations, not only anti-crime enforcement?
2. Which faction spaces primarily teach human-normal behavior through observation and correction?
3. Which non-stealth paths let the player reduce suspicion through sponsorship or routine learning?
4. Which faction content must avoid revealing the hidden player-identity premise too early?

## Section 0: Canonical scope and naming gate

Complete this gate before balancing tables.

1. What are the canonical faction IDs for Phase 1, and which aliases must map to each ID? Can you propose this?
2. Which legacy labels in current docs cause naming drift and need normalization? I think once you figure out the first answer this will fall into place
3. Which locations and NPC groups map to each faction by default? So each faction will have a district with multiple locations, we'll need to get specific
4. Which spaces are contested or mixed-control, and who has priority for interpretation there? I agree there should be some boundary areas that aren't controlled by either district
5. Which unresolved naming issue would block downstream workstreams today? Depends on previous answers

## Section A: Faction taxonomy canonical table

Answer for every faction that can witness or react in Phase 1.

| Question | Answer |
|---|---|
| Canonical faction ID | |
| Display name | |
| Alias list to normalize | |
| Core social norm expectation in one sentence | |
| Preferred escalation style (warn, shame, deny access, detain) | |
| Typical sponsor profile in this faction | |
| Typical enforcer profile in this faction | |
| Primary controlled zones | |
| Secondary influence zones | |

## Section B: Action interpretation bands

Define baseline reactions for core witnessed actions.

| Witnessed action | Faction | Context assumptions | Baseline delta | Min cap | Max cap | Notes |
|---|---|---|---|---|---|---|
| Enter restricted area | | | | | | |
| Loiter in labor zone | | | | | | |
| Speak wrong phrase in formal context | | | | | | |
| Gift low-value item | | | | | | |
| Help with visible labor task | | | | | | |
| Flee from questioning | | | | | | |
| Use stealth movement in crowded area | | | | | | |
| Return lost goods publicly | | | | | | |

Prompt checks:

1. Which actions have opposite interpretations by faction and why?
2. Which action interpretations are context-sensitive by location, time, or witness role?
3. Where should positive deltas be intentionally possible for social learning loops?
4. Which deltas should be clamped in Phase 1 to avoid runaway extremes?

## Section C: Faction gate contract table

Define one consolidated gate ruleset.

| Gate | Owning faction | Threshold condition | Lock condition | Unlock condition | Required sponsor or token | Fallback behavior if unknown |
|---|---|---|---|---|---|---|
| Barracks interior | | | | | | |
| Warehouse secure lane | | | | | | |
| Manor courtyard audience path | | | | | | |
| Church sanctuary privilege | | | | | | |
| School advanced dialogue set | | | | | | |

Prompt checks:

1. Which gate should be soft-gated versus hard-gated in Phase 1?
2. Which gate failures should add suspicion versus only block progress?
3. Which gate unlocks must rely on trust or sponsorship, not only suspicion score?
4. Which gate behavior needs explicit messaging to prevent player confusion?

## Section D: Cross-faction coupling rules

Define how one faction reaction influences others.

1. Which faction pairs are tightly coupled, loosely coupled, or independent?
2. When faction A suspicion rises, what mandatory effect applies to faction B trust or suspicion?
3. When faction A trust rises, which faction B values should remain unchanged to avoid contradiction?
4. Which coupling effects are additive, multiplicative, or clamped in Phase 1?
5. Which coupling rules are deferred to later phases, and what temporary fallback applies now?

Coupling matrix starter:

| Source faction event | Target faction | Shift type (trust, suspicion, reputation) | Delta rule | Cap or floor | Rationale |
|---|---|---|---|---|---|
| Guard suspicion spike | | | | | |
| Church sponsorship gain | | | | | |
| Artisan trust gain | | | | | |
| Manor warning issued | | | | | |
| Labor reliability streak | | | | | |

## Section E: Balancing guardrails for Phase 1

1. What are the maximum per-event positive and negative deltas by faction family?
2. What escalation pacing rules protect early learning while preserving pressure?
3. What recovery floor behavior prevents permanent soft-locks in early loops?
4. Which combinations of witness count and event severity should trigger immediate cap clamps?
5. Which values are tuning-safe during implementation, and which require design sign-off?

Guardrail table:

| Guardrail | Value | Rationale | Owner |
|---|---|---|---|
| Per-event negative delta cap | | | |
| Per-event positive delta cap | | | |
| Maximum threshold jumps per scene | | | |
| Minimum recoverable state floor | | | |
| Cooldown for repeated same-action penalties | | | |

## Section F: Dependency handoff readiness

Complete this checklist before marking Workstream 7 output stable.

* Canonical faction IDs and aliases are complete and conflict-free
* Interpretation matrix rows exist for every core witnessed Phase 1 action
* Gate contract table includes threshold, lock, unlock, and fallback behavior
* Cross-faction coupling rules prevent contradictory outcomes
* Balancing guardrails define caps, pacing, and recovery floors for Phase 1
* Open questions have owners, due dates, and fallback assumptions

## Open issues log template

| ID | Question | Impact if unresolved | Owner | Due date | Fallback rule |
|---|---|---|---|---|---|
| WS7-001 |  |  |  |  |  |
| WS7-002 |  |  |  |  |  |
| WS7-003 |  |  |  |  |  |

## Output package expectations

At session end, export answers into the following artifacts:

* Faction Taxonomy Canonical Table
* Faction Interpretation Matrix v1
* Faction Gate Contract Table
* Cross-Faction Coupling Rules v1

If one of these cannot be produced from the answers, rerun the missing section before closing Workstream 7 for Milestone A.
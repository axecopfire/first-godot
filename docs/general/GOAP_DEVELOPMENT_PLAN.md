---
title: GOAP Development Plan
description: Phased migration plan from score-based NPC behavior to GOAP planning in the medieval market project
ms.date: 2026-07-01
ms.topic: how-to
keywords:
  - goap
  - npc ai
  - planning
  - suspicion
  - godot
estimated_reading_time: 12
---

## Purpose

This document defines a low-risk path to introduce Goal-Oriented Action Planning (GOAP)
for NPC behavior without breaking the current playable loop.

The plan keeps existing movement and schedule integration intact while replacing only the
NPC decision layer in controlled increments.

## Design guardrails

The GOAP implementation must preserve the project premise and social pressure framing:

* Keep the hidden identity arc concealed in gameplay-facing content until late reveal points.
* Treat suspicion as social assimilation pressure first, with enforcement as a later outcome.
* Support at least one non-stealth suspicion recovery path through social conformity.
* Keep language learning and trust-building central to progression.

## Current baseline

Current NPC logic uses weighted action scoring in scripts/npc_brain.gd and executes targets
through scripts/npc.gd.

Existing action set:

* home
* work
* socialize
* wander

Existing world inputs used by decisions:

* Day cycle progress and hour
* Work window by NPC schedule
* Bell state via pending tolls
* Player proximity
* Friendly tie metadata

## Target architecture

### Runtime boundaries

Keep these boundaries stable through migration:

* scripts/main.gd provides world timing and bell context.
* scripts/npc.gd remains responsible for movement and target following.
* scripts/npc_brain.gd becomes responsible for GOAP world state, goal selection, and planning.

### GOAP model

The first implementation uses a compact GOAP model:

* World state facts: boolean and small integer facts derived from existing runtime signals.
* Goals: desired world state patterns with priority and utility modifiers.
* Actions: preconditions, effects, cost, and target resolver.
* Planner: bounded forward search with lowest-cost plan selection.
* Executor: stepwise action execution with replan triggers.

## Data contracts for Phase 1

### Required world facts

First fact set should remain intentionally small:

* in_work_window
* bell_pending
* player_nearby
* has_friendly_tie
* at_home
* at_work
* at_social_hub
* recently_socialized

### Initial goals

Define these goals in priority order:

1. maintain_role_routine
2. maintain_rest_routine
3. maintain_social_assimilation
4. avoid_attention_spike

### Initial actions

Define these actions first:

* GoToWork
* GoHome
* SocializeAtHub
* WanderLocal

Each action must provide:

* Preconditions
* Effects
* Cost
* Target derivation method
* Completion check

## Migration strategy

### Phase 0: Instrumentation and baseline lock

Scope:

* Add debug telemetry output for action, reason, target, and replans.
* Record baseline behavior traces for several in-game days.
* Keep current score-based behavior as default execution path.

Done when:

* Baseline traces are captured for all current NPC professions.
* Trace format is stable and readable in debug mode.

### Phase 1: GOAP scaffolding with fallback

Scope:

* Add GOAP data structures in scripts/npc_brain.gd.
* Add planner skeleton with bounded depth and deterministic tie-breaks.
* Add feature flag per NPC for legacy vs GOAP decision mode.

Done when:

* GOAP mode compiles and runs with no behavior regressions in legacy mode.
* GOAP mode produces a valid plan for nominal day-cycle states.

### Phase 2: Hybrid execution

Scope:

* Route action target selection through GOAP plan step output.
* Keep movement code unchanged in scripts/npc.gd.
* Replan only on explicit triggers.

Replan triggers:

* Current plan exhausted
* Action precondition invalidated
* Major world-state change
* Goal utility shift beyond threshold

Done when:

* GOAP-driven NPCs move and complete action loops without stalling.
* Legacy NPCs remain unaffected.

### Phase 3: Goal tuning and social pressure alignment

Scope:

* Tune action costs and goal priorities to produce believable routines.
* Increase weight for conformity and social timing in suspicion-adjacent contexts.
* Validate non-stealth recovery paths through social behavior.

Done when:

* NPC routines remain legible across dawn, workday, evening, and night windows.
* Socially appropriate behavior lowers pressure opportunities relative to erratic behavior.

### Phase 4: Role specialization

Scope:

* Add profession-specific actions and goal modifiers.
* Add role-based plan preferences for teacher, captain, merchant, artisan, and priest patterns.
* Keep shared base action model for maintainability.

Done when:

* At least five professions show distinct routine signatures under identical world conditions.

### Phase 5: Expansion and hardening

Scope:

* Introduce richer facts such as zone pressure and witness density.
* Add plan stability mechanisms to avoid oscillation.
* Add regression tests for planner determinism and fallback behavior.

Done when:

* Planner output remains deterministic for fixed seed and world state.
* No soft locks, endless replans, or target thrashing in extended simulations.

## Implementation work items

### Task batch A: Brain internals

* Add GOAP action and goal descriptors in scripts/npc_brain.gd.
* Add world-state builder from existing inputs.
* Add bounded planner and plan cache.

### Task batch B: NPC wiring

* Add decision mode flag and debug display integration in scripts/npc.gd.
* Keep _physics_process movement path unchanged.
* Add action completion hooks for executor step transitions.

### Task batch C: Debug and tooling

* Extend schedule debug output to include goal and current plan step.
* Add optional planner trace output in debug builds.
* Add a quick day-cycle simulation command path for repeatable checks.

### Task batch D: Balancing pass

* Tune costs and priorities by profession.
* Verify social assimilation framing across common interactions.
* Validate bell and schedule interruptions.

## Validation plan

### Functional checks

* NPC can always produce either a plan or a safe fallback action.
* NPC reaches target for each initial action type.
* Replanning triggers only when intended.
* Legacy mode still behaves as before.

### Design checks

* Suspicion pressure remains tied to social mismatch and context fit.
* Social conformity remains a viable recovery path.
* Daily routines remain readable to the player.

### Performance checks

* Planner stays within frame budget under full NPC count.
* Replan frequency remains bounded.
* No per-frame allocation spikes from planner internals.

## Risks and mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Planner oscillation between equal plans | Unnatural movement | Add inertia bonus, cooldown, and tie-break ordering |
| Over-planning each tick | Frame-time spikes | Replan on triggers, cache active plan |
| Behavior drift from narrative intent | Theme regression | Enforce goal weighting aligned to social assimilation framing |
| Debug opacity during tuning | Slow iteration | Add clear planner and action traces in debug UI |
| Large action set complexity growth | Maintenance burden | Keep shared base actions, add role overlays incrementally |

## Milestones and expected outcomes

| Milestone | Window | Outcome |
|-----------|--------|---------|
| M1 Baseline and scaffolding | 1 to 2 sessions | GOAP structures exist with safe legacy fallback |
| M2 Hybrid execution | 1 session | GOAP drives target choice for selected NPCs |
| M3 Tuning pass | 2 sessions | Stable day-loop behavior with social alignment |
| M4 Role specialization | 2 to 3 sessions | Profession-specific behavior signatures |
| M5 Hardening | 1 to 2 sessions | Deterministic, testable, and scalable planner behavior |

## Definition of done

GOAP migration is complete when all conditions are true:

* Decision logic for production NPCs is GOAP-based with documented fallback behavior.
* Social assimilation framing is preserved in observed NPC behavior.
* At least one non-stealth social recovery path is represented in NPC planning context.
* Planner behavior is deterministic under fixed seed inputs.
* Debug traces are sufficient to diagnose goal choice and action execution issues.
* No critical performance regressions are observed in debug and release builds.

## Next execution slice

Start with a thin vertical slice:

1. Implement GOAP scaffolding in scripts/npc_brain.gd.
2. Add feature flag in scripts/npc.gd.
3. Turn on GOAP for one NPC profession only.
4. Run day-cycle simulation and compare traces against baseline.
5. Tune costs before expanding to full roster.

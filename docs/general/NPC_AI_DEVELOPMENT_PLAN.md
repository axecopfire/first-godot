---
title: HTN + GOAP Hybrid Development Plan
description: Phased migration plan from score-based NPC behavior to a hybrid HTN and GOAP planning system in the medieval market project
ms.date: 2026-07-02
ms.topic: how-to
keywords:
  - htn
  - goap
  - npc ai
  - planning
  - suspicion
  - godot
estimated_reading_time: 14
---

## Purpose

This document defines a low-risk path to introduce a hybrid Hierarchical Task Network (HTN)
and Goal-Oriented Action Planning (GOAP) system for NPC behavior without breaking the current
playable loop.

HTN owns the middle layer: authored task decomposition for structured profession routines and
profession-specific execution patterns. GOAP owns the top decision layer: event-driven goal
selection that chooses which HTN routine to pursue, plus reactive replanning when world state
shifts or a primitive task can no longer execute directly.

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

* A new dedicated world state system (scripts/world_state/ or similar) centralizes world timing, bell context, and environmental facts.
* scripts/main.gd delegates to the world state system and orchestrates high-level game loops.
* scripts/npc.gd remains responsible for movement and target following.
* scripts/npc_brain.gd acts as an orchestration entry point for NPC decisions and delegates planning details to specialized AI modules.

### Code organization for scalability and legibility

To keep AI code maintainable as HTN and GOAP complexity grows, avoid concentrating behavior
logic in only scripts/world_state/ and scripts/npc_brain.gd.

Use a modular layout under scripts/ai/ with clear ownership:

* scripts/npc_brain.gd: high-level decision lifecycle orchestration, trigger intake, and dispatch to executor.
* scripts/world_state/
  * world_state_manager.gd: authoritative runtime state and query API surface.
  * world_time.gd: day clock progression, hour/day boundaries, and time presets.
  * bell_system.gd: bell schedule evaluation, pending toll queue, and toll cooldown logic.
  * world_facts.gd: derived world and environment facts exposed to GOAP and HTN.
  * world_events.gd: explicit event emission and trigger classification inputs.
* scripts/ai/goap/
  * goal_catalog.gd: authored goal descriptors and scoring factors.
  * action_catalog.gd: selectors that bind GOAP decisions to HTN root tasks, with preconditions, switch costs, cooldowns, and completion checks.
  * planner.gd: bounded GOAP search and deterministic tie-break logic.
* scripts/ai/htn/
  * task_library.gd: root tasks and shared compound task definitions.
  * method_library_base.gd: default methods and fallback ordering.
  * method_library_<profession>.gd: profession overlays for role specialization.
  * decomposer.gd: bounded HTN decomposition and fallback handling.
* scripts/ai/runtime/
  * facts_builder.gd: transforms world_state into planner-ready fact dictionaries.
  * decision_mapper.gd: maps primitive steps to runtime actions and targets.
  * event_router.gd: classifies soft versus hard reevaluation triggers.
  * plan_cache.gd: GOAP and HTN cache keys, cache policy, and invalidation.
* scripts/tools/sim_runner.gd and scripts/tools/sim_assert.gd: headless validation and assertions.

Module boundary rule:

* catalogs and libraries define data,
* planners and decomposers compute plans,
* runtime modules translate and execute,
* npc_brain orchestrates only.

### GOAP layer

The GOAP layer handles event-driven intent selection and bounded replanning:

* World state facts: boolean and small integer facts derived from the world state system.
* Events: day start, schedule boundary, bell toll, suspicion spike, social opportunity, resource shortage, and other explicit triggers that request reconsideration.
* Goals: desired world state patterns such as maintain role routine, improve social standing, reduce attention, or pursue a profession change.
* Goal evaluation: scores candidate goals against current facts, NPC traits, profession utility, and long-horizon town needs.
* Hysteresis: prevents rapid switching between near-equal goals by applying commitment windows, switch penalties, and minimum win margins before replacing the current intent.
* HTN binding: each selected goal resolves to one or more candidate HTN root tasks or method libraries.
* Planner: bounded forward search with deterministic tie-breaks that chooses the best reachable goal or routine package for the current event.
* Executor: commits to the chosen HTN entry point until a new trigger warrants reevaluation.

This layer should support Pareto-style tradeoffs rather than a single hard-coded daily script.
An NPC can weigh role stability, social conformity, economic opportunity, and local shortages,
then pick the routine that best fits its current frontier of acceptable tradeoffs.

### Goal scoring and hysteresis

Competing goals should be resolved through explicit scoring rather than fixed priority alone.
Each candidate goal should compute a deterministic score from a small authored set of factors:

* Base motive weight for the goal type
* Current urgency from world facts
* NPC trait bias, relationship bias, and profession bias
* Town-need utility, such as labor shortage or market saturation
* Commitment bonus for staying with the current intent
* Switch penalty for abandoning the current intent early

Suggested selection flow:

1. Gather candidate goals for the triggering event.
2. Compute a score for each candidate goal.
3. Discard goals that are unreachable or on cooldown.
4. Compare the best challenger against the current active goal.
5. Keep the current goal unless the challenger exceeds it by a minimum hysteresis margin.

This keeps the planner responsive while avoiding oscillation between nearly equivalent routines.
Pareto-style tradeoffs can still shape candidate generation or utility terms, but runtime selection
should end with one active intent at a time.

### HTN layer

The HTN layer handles structured, authored routine realization after GOAP selects intent:

* Tasks: compound tasks that decompose via ordered methods, and primitive tasks that map directly to actions.
* Methods: ordered lists of subtasks with preconditions; the first method whose preconditions are satisfied is selected.
* Decomposition: top-down; a root task decomposes until all leaves are primitive tasks.
* Plan output: an ordered sequence of primitive tasks passed to the executor.

Example decomposition:

```
PerformWorkday
  method [work_window_open]: TravelToWork → PerformJobLoop → ReturnHome
  method [default]:          Wander

PerformJobLoop
  method [bell_not_pending]: DoJobTask → PerformJobLoop
  method [bell_pending]:     idle
```

Primitive leaves are HTN executor detail and should not be modeled as top-level GOAP actions.
HTN is the authored routine library that GOAP selects from.

### Dispatch boundary

The boundary between layers is defined in scripts/npc_brain.gd:

1. A world or simulation event asks GOAP whether the NPC should keep its current intent or select a new one.
2. GOAP chooses a goal and binds it to an HTN root task, routine package, or profession-change candidate.
3. HTN decomposes the selected root task to a sequence of primitive tasks.
4. The executor attempts each primitive task in order.
5. If a primitive task's preconditions are not met, the brain can either request a short GOAP corrective sequence or ask GOAP to fully reconsider intent, depending on trigger severity.
6. HTN resumes after corrective GOAP completion, or GOAP replaces the active HTN routine when a higher-value plan wins.

## Data contracts for Phase 1

### World state system

A dedicated world state module set (scripts/world_state/ or equivalent) will:

* Consolidate all timing calculations, bell management, and environmental state currently in scripts/main.gd.
* Expose a clean API for fact queries used by both HTN method precondition checks and GOAP planning.
* Remain the single source of truth for time progression and context changes.

Suggested file ownership:

* scripts/world_state/world_state_manager.gd composes and coordinates submodules.
* scripts/world_state/world_time.gd owns progression and clock utilities.
* scripts/world_state/bell_system.gd owns bell schedule and toll state.
* scripts/world_state/world_facts.gd computes derived fact dictionaries.
* scripts/world_state/world_events.gd emits start-of-day, boundary, bell, and alert events.

### Required world facts

First fact set should remain intentionally small and sourced from the world state system.
These facts are shared by GOAP goal evaluation, HTN method preconditions, and GOAP action-selector preconditions:

* in_work_window
* bell_pending
* player_nearby
* has_friendly_tie
* at_home
* at_work
* at_social_hub
* recently_socialized

Additional event-scoped or strategic facts should be introduced early to support event-driven GOAP:

* day_started
* schedule_boundary_crossed
* bell_rang
* suspicion_elevated
* profession_saturation
* unmet_town_need
* apprenticeship_available

### Goal candidate contract

Each GOAP goal candidate should expose a stable authored data shape:

* name
* desired
* candidate_htn_roots
* base_weight
* urgency_weight
* social_weight
* economic_weight
* commitment_window_hours
* switch_penalty
* hysteresis_margin
* cooldown_hours
* interrupt_class

The first implementation should keep the scoring formula simple and deterministic.
One acceptable starting form is:

$$
score = base + urgency + social + economic + stay\_bonus - switch\_penalty
$$

The current goal should remain active unless a challenger wins by at least its hysteresis margin.

### Initial HTN task library

Define these root tasks first as GOAP-selectable routines:

* PerformWorkday
* PerformRestDay
* PerformSocialWindow

Add one exploratory root task for economic or social adaptation:

* EvaluateProfessionShift

Each task must provide:

* At least two methods with distinct preconditions
* A default method that always matches as fallback
* Primitive task leaves that map to executor actions and target derivation rules

EvaluateProfessionShift should initially stay narrow: it can inspect a small authored set of
profession alternatives rather than opening unconstrained simulation-wide role search.

### Initial GOAP actions

Define GOAP actions as HTN root selectors, not primitive movement verbs:

* SelectPerformWorkday -> HTN root `PerformWorkday`
* SelectPerformRestDay -> HTN root `PerformRestDay`
* SelectPerformSocialWindow -> HTN root `PerformSocialWindow`

Add one strategic selection action family for event-driven planning:

* SelectRoutine -> choose among candidate HTN roots for the winning goal
* ConsiderProfessionChange -> bind to `EvaluateProfessionShift`

Each action must provide:

* Preconditions
* Effects on active intent, selected HTN root, or method-library binding
* Switch cost
* Candidate HTN root reference(s)
* Completion check

Strategic selection actions may complete by changing the active HTN root task, profession tag,
or routine method library rather than by moving the NPC immediately.

### Event triggers

GOAP should not run every tick. It should run on explicit decision triggers:

* Start of day
* Schedule boundary crossed
* Bell toll or town-wide alert
* Suspicion spike or recovery opportunity
* Resource shortage or unmet profession need in town simulation
* Relationship or sponsorship change that opens a new role path
* Primitive task failure that cannot be solved cheaply inside the current HTN routine

### Event-triggered reevaluation policy

Not every event should force a goal switch. Events should trigger reevaluation, then hysteresis
should decide whether the current intent is retained.

Reevaluation types:

* Soft reevaluation: recompute scores but preserve the current intent unless a challenger clearly wins.
* Hard reevaluation: clear commitment protection and allow immediate replacement of the current intent.

Suggested trigger classes:

* Start of day: soft reevaluation
* Schedule boundary crossed: soft reevaluation
* Bell toll or town-wide alert: hard reevaluation
* Suspicion spike: hard reevaluation
* Social recovery opportunity: soft reevaluation
* Resource shortage or unmet town need: soft reevaluation
* Primitive task failure inside HTN: soft reevaluation first, then corrective GOAP or hard reevaluation if unresolved

This policy separates "should I reconsider" from "should I switch," which is the core requirement
for stable multi-goal behavior.

### HTN entry points

The initial GOAP goals should map to HTN root tasks rather than bypassing HTN entirely:

1. maintain_role_routine → PerformWorkday
2. maintain_rest_routine → PerformRestDay
3. maintain_social_assimilation → PerformSocialWindow
4. avoid_attention_spike → PerformSocialWindow or a short corrective sequence
5. explore_profession_shift → EvaluateProfessionShift

This keeps HTN as the authored routine layer while allowing GOAP to choose among routines,
including strategic changes that may alter profession over time.

## Migration strategy

### Phase 0: Instrumentation, world state extraction, and simulation harness

Scope:

* Extract world timing, bell management, and environmental context from scripts/main.gd into a dedicated world state module set (scripts/world_state/).
* Refactor scripts/main.gd to use scripts/world_state/world_state_manager.gd for high-level orchestration.
* Add debug telemetry output for action, reason, target, and replans.
* Record baseline behavior traces for several in-game days.
* Keep current score-based behavior as default execution path.
* Build a headless day-cycle simulation harness in scripts/tools/sim_runner.gd that can run without loading the Godot scene tree.

#### Simulation harness requirements

The harness must support evaluation without opening the Godot editor or browser:

* **Headless execution**: run via `godot --headless --script scripts/tools/sim_runner.gd` from the terminal with no scene loaded.
* **Programmatic control**: accept a seed, NPC roster configuration, day count, and initial world state as command-line arguments or an input JSON file so CI or scripts can drive repeatable runs.
* **Structured output**: emit one NDJSON record per NPC decision event containing day, hour, npc_id, profession, active_goal, trigger, htn_root, method, primitive_sequence, goal_score, challenger_score, and hysteresis_decision. Write to stdout or a specified output file.
* **Manual inspection mode**: when passed `--interactive`, pause at each decision event and print a human-readable summary, then wait for Enter to advance to the next event.
* **Assertion hooks**: expose a `SimAssert` helper that scripts can call to declare expected outcomes (e.g., NPC should be at work during work window). Failed assertions print a diff and exit non-zero.
* **Baseline capture**: running with `--capture` writes current output to a named baseline file. Running without `--capture` compares against the baseline and reports divergences.

The harness should import and use world_state.gd, npc_brain.gd, and schedule_config.gd directly. It should stub movement and spatial APIs so the planner logic can execute without a physics world.

Done when:

* World state system compiles and runs with all timing and context facts available through a clean query API.
* scripts/main.gd successfully delegates to scripts/world_state/world_state_manager.gd without behavioral regression.
* Baseline traces are captured for all current NPC professions.
* Trace format is stable and readable in debug mode.
* Headless simulation runner executes a full in-game day for at least one NPC profession without launching the Godot UI.
* Programmatic run produces stable NDJSON output that can be diffed between runs.
* Interactive mode pauses at each decision event and prints a readable summary.
* Baseline capture and comparison round-trip correctly for the current score-based behavior.

### Phase 1: HTN and GOAP scaffolding with event triggers

Scope:

* Add HTN task, method, and primitive task data structures in scripts/ai/htn/.
* Add GOAP action and goal descriptors in scripts/ai/goap/.
* Add bounded GOAP planner skeleton with deterministic tie-breaks in scripts/ai/goap/planner.gd.
* Add bounded HTN decomposition engine in scripts/ai/htn/decomposer.gd.
* Add explicit event trigger plumbing for day start, schedule boundaries, and primitive failure.
* Add goal scoring and hysteresis fields to GOAP goal descriptors.
* Add feature flag per NPC for legacy vs hybrid decision mode.

Done when:

* Hybrid mode compiles and runs with no behavior regressions in legacy mode.
* GOAP selects a valid HTN root task on at least one explicit event, such as day start.
* HTN decomposes a selected root task to a valid primitive sequence for nominal day-cycle states.
* Goal switching is stable under repeated reevaluation and does not thrash between near-equal candidates.
* GOAP still produces a corrective plan when a primitive task precondition is blocked.

### Phase 2: Hybrid execution with dispatch boundary

Scope:

* Implement the HTN-to-GOAP dispatch boundary in scripts/npc_brain.gd.
* Route routine selection through GOAP first, then action target selection through HTN primitive output.
* Keep movement code unchanged in scripts/npc.gd.
* Trigger HTN method reselection and GOAP reevaluation only on explicit conditions.

Replan triggers:

* Start-of-day evaluation event
* Current town-state event that changes strategic utility, such as shortage, sponsorship, or pressure shift
* Current HTN primitive sequence exhausted
* Primitive task precondition invalidated mid-execution
* Major world-state change (bell toll, schedule boundary)
* GOAP corrective plan fails to resolve blocked precondition

Done when:

* HTN-driven NPCs decompose root tasks and execute primitive sequences without stalling.
* GOAP activates on explicit decision events and blocked primitives, not on every tick.
* Hysteresis prevents intent churn during repeated soft reevaluations.
* Legacy NPCs remain unaffected.

### Phase 3: Routine tuning and social pressure alignment

Scope:

* Tune HTN method preconditions to produce legible day-cycle routines.
* Tune GOAP goal scoring, hysteresis margins, and action costs to favor socially conformant choices.
* Increase weight for conformity and social timing in suspicion-adjacent contexts.
* Introduce bounded strategic utility for profession exploration and town-need response.
* Validate non-stealth recovery paths through social behavior.

Done when:

* NPC routines remain legible across dawn, workday, evening, and night windows.
* GOAP routine selection and corrective sequences favor socially plausible paths over erratic shortcuts.
* Socially appropriate behavior lowers pressure opportunities relative to erratic behavior.

### Phase 4: Role specialization via HTN method libraries

Scope:

* Add profession-specific HTN method libraries for teacher, captain, merchant, artisan, and priest.
* Add role-specific GOAP goal scoring and action cost overrides where profession behavior diverges.
* Keep the shared base task and action vocabulary for maintainability.

Done when:

* At least five professions show distinct routine signatures under identical world conditions.
* Profession differences are expressed as HTN method variation, not duplicated action sets.

### Phase 5: Expansion and hardening

Scope:

* Introduce richer facts such as zone pressure, witness density, labor demand, and market saturation.
* Add HTN plan caching and GOAP result caching to bound per-frame cost.
* Add regression tests for HTN decomposition determinism, GOAP event-trigger coverage, and corrective fallback coverage.

Done when:

* Planner output remains deterministic for fixed seed and world state.
* No soft locks, endless replans, or target thrashing in extended simulations.

## Implementation work items

### Task batch A: World state system and brain internals

* Create scripts/world_state/world_state_manager.gd to compose world time, bell, facts, and event submodules.
* Create scripts/world_state/world_time.gd, scripts/world_state/bell_system.gd, scripts/world_state/world_facts.gd, and scripts/world_state/world_events.gd.
* Expose a clean query API from scripts/world_state/world_state_manager.gd for world facts shared by HTN preconditions and GOAP planning.
* Refactor scripts/main.gd to use scripts/world_state/world_state_manager.gd instead of managing timing directly.
* Add HTN task and method descriptors in scripts/ai/htn/task_library.gd and scripts/ai/htn/method_library_base.gd.
* Add GOAP action and goal descriptors in scripts/ai/goap/action_catalog.gd and scripts/ai/goap/goal_catalog.gd.
* Add world-state facts builder in scripts/ai/runtime/facts_builder.gd that queries the dedicated world state system.
* Add event descriptors and trigger evaluation in scripts/ai/runtime/event_router.gd for strategic GOAP invocations.
* Add goal scoring, commitment windows, cooldowns, and hysteresis margins to the goal catalog and selection policy.
* Add bounded HTN decomposition engine in scripts/ai/htn/decomposer.gd and bounded GOAP planner in scripts/ai/goap/planner.gd.
* Implement HTN-to-GOAP dispatch boundary logic in scripts/npc_brain.gd through module integration points.
* Add plan caches for both layers in scripts/ai/runtime/plan_cache.gd.

### Task batch B: NPC wiring

* Add decision mode flag and debug display integration in scripts/npc.gd.
* Keep _physics_process movement path unchanged.
* Add action completion hooks for HTN executor step transitions and GOAP sequence completion.

### Task batch C: Debug and tooling

* Extend schedule debug output to include current GOAP goal, trigger source, active HTN root task, active method, primitive sequence, current goal score, best challenger score, and any active GOAP fallback.
* Add optional planner trace output in debug builds for both HTN decomposition and GOAP search.
* Create scripts/tools/sim_runner.gd as the headless simulation entry point.
* Create scripts/tools/sim_assert.gd as reusable assertion helpers for simulation checks.
* Implement NDJSON decision-event emitter used by both the headless runner and the in-game debug overlay.
* Implement `--interactive` mode with per-event pause and human-readable summary.
* Implement `SimAssert` helper with diff output and non-zero exit on failure.
* Implement `--capture` / baseline comparison workflow.
* Implement command-line argument and input JSON parsing for seed, roster, day count, and world state overrides.
* Stub movement and spatial dependencies so the runner can import brain and schedule scripts without a scene tree.

### Task batch D: Balancing pass

* Tune HTN method preconditions and GOAP action costs by profession.
* Verify social assimilation framing across common interactions.
* Validate bell and schedule interruptions trigger correct HTN method reselection.

## Validation plan

### Functional checks

* NPC can always produce either a GOAP-selected HTN routine, a GOAP corrective plan, or a safe fallback action.
* HTN decomposes every selected root task to a valid primitive sequence for all nominal day-cycle states.
* GOAP activates only on explicit decision events or blocked primitive preconditions, not on every tick.
* Repeated soft reevaluations preserve the current intent unless the challenger exceeds the hysteresis threshold.
* NPC reaches target for each initial action type.
* HTN method reselection and GOAP replanning trigger only when intended.
* Legacy mode still behaves as before.

### Design checks

* Suspicion pressure remains tied to social mismatch and context fit.
* Social conformity remains a viable recovery path.
* Daily routines remain readable to the player.
* Goal switching appears legible and motivated rather than erratic.

### Performance checks

* Planner stays within frame budget under full NPC count.
* Replan frequency remains bounded.
* Event-triggered strategic GOAP evaluation stays sparse and amortized.
* No per-frame allocation spikes from planner internals.

## Risks and mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| HTN method deadlock with no matching method | NPC stalls | Require a default method on every compound task |
| GOAP overreach into unconstrained town simulation | Unpredictable routines | Bind GOAP outputs to authored HTN roots and cap profession-shift candidates |
| Planner oscillation between equal GOAP plans | Unnatural movement | Add inertia bonus, cooldown, and tie-break ordering |
| Over-planning each tick | Frame-time spikes | Replan on triggers, cache active HTN and GOAP plans separately |
| Profession churn from short-term incentives | Town instability | Add commitment windows, switch costs, and apprenticeship gates |
| Poorly tuned hysteresis blocks meaningful change | NPCs feel stubborn | Separate soft and hard reevaluation triggers and tune per-goal margins |
| Behavior drift from narrative intent | Theme regression | Enforce HTN method design aligned to social routine framing |
| Debug opacity during tuning | Slow iteration | Add clear HTN decomposition and GOAP search traces in debug UI |
| Role method library complexity growth | Maintenance burden | Keep shared base task vocabulary, add profession overlays as method variants |

## Milestones and expected outcomes

| Milestone | Window | Outcome |
|-----------|--------|---------|
| M1 World state system and hybrid scaffolding | 2 to 3 sessions | World state system extracts timing from main.gd; HTN and GOAP structures coexist with safe legacy fallback |
| M2 Dispatch boundary and hybrid execution | 1 to 2 sessions | GOAP selects routines on events; HTN drives decomposition; GOAP still handles blocked primitives |
| M3 Tuning pass | 2 sessions | Stable day-loop behavior with legible routines and social alignment |
| M4 Role specialization via method libraries | 2 to 3 sessions | Profession-specific behavior signatures expressed as HTN method variants |
| M5 Hardening | 1 to 2 sessions | Deterministic, testable, and scalable behavior for both planners |

## Definition of done

HTN and GOAP hybrid migration is complete when all conditions are true:

* Decision logic for production NPCs uses event-driven GOAP to select and revise HTN routines, plus documented legacy fallback.
* HTN method libraries exist for all active professions.
* GOAP scope includes explicit event-driven routine selection and corrective sequences triggered by blocked primitive preconditions.
* Goal scoring, commitment windows, and hysteresis margins are authored and observable in debug traces.
* Social assimilation framing is preserved in observed NPC behavior.
* At least one non-stealth social recovery path is represented in both HTN methods and GOAP corrective actions.
* Profession-shift behavior is bounded, legible, and driven by authored town-need and social-access signals.
* Both planner outputs are deterministic under fixed seed inputs.
* Debug traces are sufficient to diagnose HTN method selection, GOAP activation, and action execution issues.
* No critical performance regressions are observed in debug and release builds.

## Village orchestration decision

Decision for current implementation window:

* Use a narrow village director now.
* Keep primary intelligence in per-NPC GOAP plus HTN.
* Defer broad hierarchical centralized control until interaction loops and service continuity metrics are stable.

Rationale:

* Preserves the existing migration strategy and keeps current risk low.
* Avoids early over-centralization that can hide tuning problems in local routines.
* Supports readable behavior where NPC intent changes remain legible to players.
* Keeps scaling options open for later top-down coordination.

Current director scope:

* Publish village-level demand and pressure signals.
* Emit soft and hard orchestration triggers.
* Track service continuity and repeated interaction failures.
* Do not assign per-step movement or primitive actions directly.

Planned future centralization gate:

Move to stronger hierarchical control only after these conditions hold:

* Core service loops are stable across multi-day fixed-seed runs.
* Soft reevaluations do not cause intent thrash.
* Corrective GOAP fallback resolves blocked primitive tasks at acceptable rates.
* Director telemetry can explain intervention causes without ambiguity.

When the gate is met, expand in this order:

1. Add role-level quotas and staffing targets to director outputs.
2. Add supervised interaction brokering for critical services only.
3. Add town-wide emergency overrides for alert-class events.
4. Keep non-critical social and routine choices decentralized.

Immediate implementation implications:

* Add a `director_signal` fact channel in world-state-derived planner inputs.
* Add an `orchestration_event_class` field to event routing and debug traces.
* Keep GOAP goal scoring as the final selector for active NPC intent.
* Add continuity metrics to the headless simulation output so expansion decisions are evidence-based.

## Next execution slice

Start with a thin vertical slice:

1. Create scripts/world_state/world_state_manager.gd plus world_time.gd, bell_system.gd, world_facts.gd, and world_events.gd; then extract timing and bell logic from scripts/main.gd.
2. Verify the in-game loop is unaffected with scripts/main.gd delegating to scripts/world_state/world_state_manager.gd.
3. Create scripts/ai/goap/, scripts/ai/htn/, and scripts/ai/runtime/ with stub modules and wire scripts/npc_brain.gd as orchestrator only.
4. Build the headless simulation harness in scripts/tools/sim_runner.gd: NDJSON emitter, movement stubs, command-line argument parsing, and interactive mode.
5. Create scripts/tools/sim_assert.gd and integrate assertion hooks into the harness flow.
6. Capture a baseline trace of current score-based NPC behavior using `--capture` for all current professions.
7. Implement GOAP event descriptors, goal scoring, and hysteresis in scripts/ai/goap/ and scripts/ai/runtime/event_router.gd for start-of-day evaluation.
8. Implement HTN task and method descriptors for PerformWorkday, PerformRestDay, and PerformSocialWindow in scripts/ai/htn/ as GOAP-selectable routines.
9. Implement GOAP action descriptors for SelectPerformWorkday, SelectPerformRestDay, SelectPerformSocialWindow, SelectRoutine, and ConsiderProfessionChange in scripts/ai/goap/.
10. Implement the HTN decomposition engine and GOAP planner with the event-driven dispatch boundary integrated through scripts/npc_brain.gd.
11. Add feature flag in scripts/npc.gd.
12. Enable hybrid mode for one NPC profession only.
13. Run the harness and compare GOAP trigger traces, goal score traces, hysteresis decisions, HTN decomposition traces, and corrective GOAP traces against the captured baseline.
14. Tune GOAP goal scoring, HTN method preconditions, hysteresis margins, and profession-switch constraints before expanding to full roster.

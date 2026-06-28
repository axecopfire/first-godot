---
title: Phase 0 Development Plan
description: Design-first plan that establishes modular artifacts and readiness criteria for Phase 1 mechanics implementation
ms.date: 2026-06-27
ms.topic: how-to
keywords:
  - planning
  - mechanics
  - phase 0
  - design workflow
estimated_reading_time: 12
---

## Intent

Phase 0 exists to make Phase 1 implementation predictable.

The focus is design and specification work, not feature coding.

By the end of Phase 0, we should have modular artifacts that let us build Phase 1 mechanics in parallel, with clear contracts between narrative, systems, and world design.

## Source alignment

This plan is derived from the following references:

* docs/general/MECHANICS_SPEC.md
* docs/general/storyboard.drawio
* docs/general/storyboard_modular.drawio
* docs/general/MAP_PLAN.md
* docs/places/village.md
* docs/people/people.md

## Citation traceability

Use this section to verify why each Phase 0 workstream requirement exists.

* Workstream 1 (Location design) maps to [Visibility and suspicion](MECHANICS_SPEC.md#visibility-and-suspicion), [Current State](MAP_PLAN.md#current-state), [Target Layout](MAP_PLAN.md#target-layout), and zone intent sections such as [Market Square](../places/village.md#market-square) and [Barracks](../places/village.md#barracks)
* Workstream 2 (NPC architecture) maps to [Visibility and suspicion](MECHANICS_SPEC.md#visibility-and-suspicion), [Learning and social norm discovery](MECHANICS_SPEC.md#learning-and-social-norm-discovery), and roster sources such as [Market Stalls](../people/people.md#market-stalls) and [Barracks](../people/people.md#barracks)
* Workstream 3 (Suspicion ruleset hardening) maps to [Visibility and suspicion](MECHANICS_SPEC.md#visibility-and-suspicion), [Faction-relative witness logic](MECHANICS_SPEC.md#faction-relative-witness-logic), and early-loop pressure in [Overview](GAME_DESIGN.md#overview)
* Workstream 4 (Core loop content architecture) maps to [Story Graph](GAME_DESIGN.md#story-graph), [Narrative Phases](GAME_DESIGN.md#narrative-phases), and the storyboard artifacts in `docs/general/storyboard.drawio` and `docs/general/storyboard_modular.drawio`
* Workstream 5 (Map-mechanic integration) maps to [Target Layout](MAP_PLAN.md#target-layout), [Step 8: Add NPCs in new zones](MAP_PLAN.md#step-8-add-npcs-in-new-zones-), [Step 10: Zone-based suspicion rules - partial](MAP_PLAN.md#step-10-zone-based-suspicion-rules--partial), and [Visibility and suspicion](MECHANICS_SPEC.md#visibility-and-suspicion)
* Workstream 6 (Modular delivery framework) maps to [Phase planning anti-blocker protocol](MECHANICS_SPEC.md#phase-planning-anti-blocker-protocol), [Specification authority levels](MECHANICS_SPEC.md#specification-authority-levels), and modular sequencing in `docs/general/storyboard_modular.drawio`
* Workstream 7 (Faction mechanics) maps to [Faction-relative witness logic](MECHANICS_SPEC.md#faction-relative-witness-logic), [Faction action examples and caps](MECHANICS_SPEC.md#faction-action-examples-and-caps), [Faction suspicion thresholds and access gates](MECHANICS_SPEC.md#faction-suspicion-thresholds-and-access-gates), [Career arc progression](MECHANICS_SPEC.md#career-arc-progression), and [Faction gate thresholds](GAME_DESIGN.md#faction-gate-thresholds)

## Phase 1 mechanics this plan must unblock

Phase 1 requires these mechanics to be implementation-ready:

* Individual NPC suspicion and trust with witness memory
* Faction reaction matrix with action interpretation by witness context
* Event severity and threshold reactions at 35, 60, and 80 suspicion
* Arrest and recovery loop with state reset policy and persistent language learning
* First-contact and core-loop progression from alley start into market social pressure

These mechanics already exist conceptually, but they need tighter design contracts before coding can scale.

## What Phase 0 is not

Phase 0 does not include production implementation of gameplay systems.

Allowed technical activity is limited to lightweight validation prototypes needed to answer open design questions.

## Design workstreams

## Workstream execution order

Run workstreams in this order to reduce rework and prevent downstream design drift.

1. Workstream 7: Faction mechanics design and normalization
2. Workstream 3: Suspicion and social assimilation ruleset hardening
3. Workstream 1: Location design for modular mechanics testing
4. Workstream 2: NPC roster expansion and behavioral cast architecture
5. Workstream 4: Core loop content architecture
6. Workstream 5: Map and mechanic integration design
7. Workstream 6: Modular delivery framework

### Workstream 1: Location design for modular mechanics testing

Goal: Expand and classify locations so each major mechanic can be tested in at least one low-risk and one high-risk space.

Dependencies:

* Depends on: Workstream 7 outputs (canonical factions, gate contracts) and Workstream 3 outputs (event dictionary, threshold behavior)
* Required before: Workstream 2 final witness placement, Workstream 5 final zone-mechanic mapping

Task citations:

* Location taxonomy by gameplay role: [Visibility and suspicion](MECHANICS_SPEC.md#visibility-and-suspicion), [Faction-relative witness logic](MECHANICS_SPEC.md#faction-relative-witness-logic)
* Net-new location prioritization: [Target Layout](MAP_PLAN.md#target-layout), [Principles](MAP_PLAN.md#principles)
* Entry and visibility rules: [Market Square](../places/village.md#market-square), [Warehouse](../places/village.md#warehouse), [Barracks](../places/village.md#barracks)
* Adjacency contracts: [Target Layout](MAP_PLAN.md#target-layout), [Village Map](../places/village.md#village-map)

Design tasks:

* Define a location taxonomy by gameplay role: social pressure, safe recovery, high enforcement, language learning, labor economy, faction gate
* Backfill and normalize every currently implemented location before approving net-new additions
* Prioritize net-new locations beyond the current map baseline, including at minimum one additional stealth lane, one additional social interior, one additional labor sub-zone, and one additional faction-controlled chokepoint
* Specify entry and visibility rules per location: expected witnesses, line-of-sight pressure, ambient cover, social appropriateness bands
* Define location adjacency contracts so traversal supports storyboard loops without dead ends

Artifacts:

* Location Design Matrix (high-level index of role, risk profile, witness density, intended loops, and keep or cut decisions)
* Location Profile Pack (one detailed profile per location, existing and net-new)
* Spatial Contract Map (connectivity graph and route intent overlays)
* Location Readability Guide (what visual cues teach risk and safety)

Phase 1 dependency unlocked:

* Suspicion accumulation and stealth pressure can be tuned against explicit zone intent, not ad hoc scene layout

### Workstream 2: NPC roster expansion and behavioral cast architecture

Goal: Expand NPC coverage so every major zone and faction beat has named witnesses, sponsors, and friction actors.

Dependencies:

* Depends on: Workstream 1 location taxonomy and adjacency contracts, Workstream 7 faction taxonomy, Workstream 3 suspicion and witness rules
* Required before: Workstream 4 module actor assignments, Workstream 5 threshold witness placement

Task citations:

* Zone witness map (primary and secondary witness): [Visibility and suspicion](MECHANICS_SPEC.md#visibility-and-suspicion), [Step 8: Add NPCs in new zones](MAP_PLAN.md#step-8-add-npcs-in-new-zones-)
* Social function per NPC: [Faction-relative witness logic](MECHANICS_SPEC.md#faction-relative-witness-logic), [Market Stalls](../people/people.md#market-stalls), [Barracks](../people/people.md#barracks)
* Routine templates: [Learning and social norm discovery](MECHANICS_SPEC.md#learning-and-social-norm-discovery), [Step 8: Add NPCs in new zones](MAP_PLAN.md#step-8-add-npcs-in-new-zones-)
* Interaction stakes and refusal logic: [Gifting and relationship growth](MECHANICS_SPEC.md#gifting-and-relationship-growth), [Overview](GAME_DESIGN.md#overview)

Design tasks:

* Create an NPC role map that assigns each zone at least one primary witness and one secondary witness
* Define social function per NPC: enforcer, sponsor, rumor source, labor gate, language bridge, sanctuary gate
* Design routine templates for Phase 1 only: patrol, stall-bound, interior-bound, lane-transition, day-night swap
* Define interaction stakes and refusal logic for first-contact phase, gifting, and early trust repair

Artifacts:

* NPC Architecture Sheet (role, faction alignment, routine type, witness priority)
* Witness and Sponsor Coverage Grid (which mechanics each NPC supports)
* NPC Interaction Voice Cards (tone, refusal style, trust signals, suspicion signals)

Phase 1 dependency unlocked:

* Witness memory and threshold reactions can be implemented against complete cast coverage, not placeholder NPCs

### Workstream 3: Suspicion and social assimilation ruleset hardening

Goal: Convert current mechanics descriptions into an executable design ruleset with minimal ambiguity.

Dependencies:

* Depends on: Workstream 7 canonical faction model and baseline faction interpretation assumptions
* Required before: Workstream 1 high-risk and low-risk location intent validation, Workstream 2 witness role definitions, Workstream 5 threshold placement

Task citations:

* Suspicion event dictionary: [Visibility and suspicion](MECHANICS_SPEC.md#visibility-and-suspicion)
* Social mismatch heuristics: [Overview](GAME_DESIGN.md#overview), [Learning and social norm discovery](MECHANICS_SPEC.md#learning-and-social-norm-discovery)
* Faction interpretation matrix: [Faction-relative witness logic](MECHANICS_SPEC.md#faction-relative-witness-logic), [Faction action examples and caps](MECHANICS_SPEC.md#faction-action-examples-and-caps)
* Recovery design for Phase 1: [Suspicion reset rules](MECHANICS_SPEC.md#visibility-and-suspicion), [Failure and restart loop](MECHANICS_SPEC.md#failure-and-restart-loop)

Design tasks:

* Formalize suspicion event dictionary for Phase 1 actions with trigger conditions and severity bands
* Define social mismatch heuristics explicitly: language mismatch, wrong place, wrong timing, context-inappropriate action
* Author the first-pass faction interpretation matrix for visible actions, including positive and negative deltas
* Define recovery design for Phase 1: what can recover suspicion now, what is deferred to later phases

Artifacts:

* Suspicion Event Catalog v1
* Social Norm Rulebook v1
* Faction Interpretation Matrix v1
* Threshold Reaction Playbook (35, 60, 80 behavior definitions)

Phase 1 dependency unlocked:

* Core suspicion loop can be built from stable design tables with fewer rewrites

### Workstream 4: Core loop content architecture

Goal: Make the first-contact to daily-loop arc content-modular and reusable.

Dependencies:

* Depends on: Workstream 1 location contracts, Workstream 2 NPC role map, Workstream 3 event and threshold rules, Workstream 7 faction progression contracts
* Required before: Workstream 5 storyboard-to-zone finalization and implementation-ready module slicing

Task citations:

* Reusable interaction modules: [Story Graph](GAME_DESIGN.md#story-graph), [Phase 1: First Contact (tutorial death)](GAME_DESIGN.md#phase-1-first-contact-tutorial-death), [Phase 2: Signal and Interpret](GAME_DESIGN.md#phase-2-signal-and-interpret)
* Module I/O contracts: [Narrative Phases](GAME_DESIGN.md#narrative-phases), `docs/general/storyboard_modular.drawio`
* Language-learning token progression: [Overview](GAME_DESIGN.md#overview), [Learning and social norm discovery](MECHANICS_SPEC.md#learning-and-social-norm-discovery)
* Labor versus crime entry modules: [Fields](../places/village.md#fields), [Faction-relative witness logic](MECHANICS_SPEC.md#faction-relative-witness-logic)

Design tasks:

* Break storyboard beats into reusable interaction modules: first failure, stealth recovery, observed action, gift gamble, trust gain, night decision
* Define module I/O contracts: prerequisites, state changes, fail paths, and repeatability conditions
* Specify language-learning token progression for Phase 1 and what content references each token
* Define labor versus crime entry points as design modules, even if one side is initially thin in implementation

Artifacts:

* Core Loop Module Catalog
* State Transition Contract Sheet
* Language Token Progression Map
* Interaction Outcome Library (accepted, rejected, witnessed, unseen variants)

Phase 1 dependency unlocked:

* Content and mechanics can be authored independently and assembled by module contracts

### Workstream 5: Map and mechanic integration design

Goal: Ensure map zones, suspicion logic, and storyboard loops align one-to-one.

Dependencies:

* Depends on: Workstream 1 location outputs, Workstream 2 witness coverage, Workstream 3 threshold behavior, Workstream 4 module contracts, Workstream 7 faction gates
* Required before: Phase 1 backlog generation from validated crosswalk artifacts

Task citations:

* Storyboard-to-zone crosswalk: [Story Graph](GAME_DESIGN.md#story-graph), [Target Layout](MAP_PLAN.md#target-layout)
* Zone-level mechanic intents: [Current State](MAP_PLAN.md#current-state), [Market Square](../places/village.md#market-square), [Church](../places/village.md#church), [Barracks](../places/village.md#barracks), [Fields](../places/village.md#fields)
* Threshold visibility placement and witnesses: [Threshold reactions](MECHANICS_SPEC.md#visibility-and-suspicion), [Step 8: Add NPCs in new zones](MAP_PLAN.md#step-8-add-npcs-in-new-zones-), [Step 10: Zone-based suspicion rules - partial](MAP_PLAN.md#step-10-zone-based-suspicion-rules--partial)
* Map-level gap identification: [Principles](MAP_PLAN.md#principles), [Step 10: Zone-based suspicion rules - partial](MAP_PLAN.md#step-10-zone-based-suspicion-rules--partial)

Design tasks:

* Crosswalk every key storyboard beat to one or more target zones
* Define zone-level mechanic intents for market, alley, church, barracks, warehouse, fields, and manor perimeter
* Specify where each threshold event should become visible in space and who should witness it
* Identify map-level gaps that block Phase 1 mechanics readability and prioritize design fixes

Artifacts:

* Storyboard to Zone Crosswalk
* Zone Mechanic Intent Table
* Threshold Visibility Map
* Map Gap Register for Phase 1 readiness

Phase 1 dependency unlocked:

* Mechanics validation can run against an intentional map test surface instead of generic traversal

### Workstream 6: Modular delivery framework

Goal: Create execution artifacts that keep implementation modular through the full lifecycle.

Dependencies:

* Depends on: Workstream 1 through 5 artifact outputs and Workstream 7 normalization outputs
* Required before: Final Phase 1 handoff and dependency-safe parallel implementation planning

Task citations:

* Artifact ownership and update cadence: [Specification authority levels](MECHANICS_SPEC.md#specification-authority-levels), [Phase planning anti-blocker protocol](MECHANICS_SPEC.md#phase-planning-anti-blocker-protocol)
* Acceptance criteria templates: [Core loop mechanics we must build](MECHANICS_SPEC.md#core-loop-mechanics-we-must-build), `docs/general/storyboard_modular.drawio`
* Explicit artifact dependency graph: [Phase planning anti-blocker protocol](MECHANICS_SPEC.md#phase-planning-anti-blocker-protocol), [Narrative Phases](GAME_DESIGN.md#narrative-phases)
* Lightweight change-control process: [Specification authority levels](MECHANICS_SPEC.md#specification-authority-levels), [Supporting mechanics we should add next](MECHANICS_SPEC.md#supporting-mechanics-we-should-add-next)

Design tasks:

* Define artifact ownership and update cadence per workstream
* Define acceptance criteria templates for mechanic modules, NPC modules, and zone modules
* Define dependency graph between artifacts so implementation order is explicit
* Create a lightweight change-control process for balancing updates and narrative adjustments

Artifacts:

* Phase 1 Definition of Ready Checklist
* Module Acceptance Template Pack
* Artifact Dependency Graph
* Balancing Change Log Template

Phase 1 dependency unlocked:

* Teams can execute in parallel with fewer blockers and less rework

### Workstream 7: Faction mechanics design and normalization

Goal: Define a canonical faction model and balancing contract so faction reactions, gates, and progression are consistent across mechanics, NPCs, and locations.

Dependencies:

* Depends on: Source mechanics references in `MECHANICS_SPEC.md`, `GAME_DESIGN.md`, `people.md`, and `village.md`
* Required before: Workstreams 1, 2, 3, 4, and 5 can be considered stable for Milestone A and Milestone B outputs

Task citations:

* Canonical faction behavior model: [Faction-relative witness logic](MECHANICS_SPEC.md#faction-relative-witness-logic), [Faction action examples and caps](MECHANICS_SPEC.md#faction-action-examples-and-caps)
* Faction gate definitions: [Faction suspicion thresholds and access gates](MECHANICS_SPEC.md#faction-suspicion-thresholds-and-access-gates), [Faction gate thresholds](GAME_DESIGN.md#faction-gate-thresholds)
* Faction progression and outcomes: [Career arc progression](MECHANICS_SPEC.md#career-arc-progression), [Phase 5: Career Branches (placeholder)](GAME_DESIGN.md#phase-5-career-branches-placeholder)
* Cross-faction coupling: [Career arc progression](MECHANICS_SPEC.md#career-arc-progression), [Cross-faction reputation](MECHANICS_SPEC.md#supporting-mechanics-we-should-add-next)

Design tasks:

* Define canonical faction IDs and alias mapping used across all Phase 0 artifacts
* Define per-faction action interpretation bands for core witnessed actions with baseline deltas and caps
* Define per-faction gate rules in one consolidated table with thresholds, lock conditions, and unlock conditions
* Define cross-faction coupling rules for trust, suspicion, and reputation shifts to prevent contradictory outcomes
* Define balancing guardrails for Phase 1 tuning: cap ceilings, escalation pacing, and recovery floor behavior

Artifacts:

* Faction Taxonomy Canonical Table
* Faction Interpretation Matrix v1
* Faction Gate Contract Table
* Cross-Faction Coupling Rules v1

Phase 1 dependency unlocked:

* Faction behavior can be implemented without naming drift or contradictory gate logic across systems

## Required net-new design coverage

To match current scope pressure, Phase 0 must explicitly deliver:

* More locations: at least four net-new location definitions with role intent and adjacency contracts
* More NPCs: at least eight net-new NPC role definitions with witness and sponsor coverage
* More designed interactions: at least twenty interaction outcomes in the module outcome library, spread across stealth, social, and survival contexts

These are design minimums, not implementation commitments.

## Phase 0 milestones

### Milestone A: Foundation packs

Deliver:

* Location Design Matrix
* NPC Architecture Sheet
* Suspicion Event Catalog v1
* Storyboard to Zone Crosswalk

Exit check:

* Every Phase 1 mechanic has at least one mapped location and two mapped NPC roles

### Milestone B: Loop contracts

Deliver:

* Core Loop Module Catalog
* State Transition Contract Sheet
* Threshold Reaction Playbook
* Zone Mechanic Intent Table

Exit check:

* First-contact and day-loop branches have unambiguous state transitions and fail recovery paths

### Milestone C: Readiness and handoff

Deliver:

* Phase 1 Definition of Ready Checklist
* Module Acceptance Template Pack
* Artifact Dependency Graph
* Map Gap Register for Phase 1 readiness

Exit check:

* Phase 1 implementation backlog can be generated directly from artifacts without adding new design assumptions

## Definition of ready for Phase 1 mechanics

Phase 1 starts only when all conditions are true:

* Suspicion events, thresholds, and recovery rules are table-complete for initial action set
* Zone intents and adjacency contracts are finalized for all Phase 1 play spaces
* NPC witness coverage and routine templates are complete for all critical zones
* Core loop modules have explicit input, output, and fail-state contracts
* Open design questions affecting arrest, suspicion, or trust are either resolved or explicitly deferred with a fallback rule

## Suggested artifact file layout

To keep execution modular, store design outputs as separate files under docs/design/phase0:

* docs/design/phase0/location-design-matrix.md
* docs/design/phase0/spatial-contract-map.md
* docs/design/phase0/npc-architecture-sheet.md
* docs/design/phase0/witness-sponsor-coverage-grid.md
* docs/design/phase0/suspicion-event-catalog-v1.md
* docs/design/phase0/faction-interpretation-matrix-v1.md
* docs/design/phase0/core-loop-module-catalog.md
* docs/design/phase0/state-transition-contract-sheet.md
* docs/design/phase0/storyboard-zone-crosswalk.md
* docs/design/phase0/phase1-definition-of-ready-checklist.md
* docs/design/phase0/faction-taxonomy-canonical-table.md
* docs/design/phase0/faction-gate-contract-table.md
* docs/design/phase0/cross-faction-coupling-rules-v1.md

This structure keeps each artifact independently versionable and easy to hand off.

## Risks and mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Design remains too narrative and not system-ready | Phase 1 stalls on missing values and triggers | Require table-complete event and threshold definitions before implementation |
| Location expansion outpaces mechanic intent | Rework in map and AI behavior tuning | Gate new location design with role taxonomy and zone intent table |
| NPC count increases without witness coverage logic | Suspicion loop feels random | Enforce witness and sponsor coverage grid as a readiness artifact |
| Modular storyboard is not reflected in task slicing | Parallel work blocks on hidden dependencies | Maintain artifact dependency graph and module acceptance templates |

## Immediate next action

Start with Milestone A and produce the four foundation packs.

Once those are complete, generate the Phase 1 implementation backlog directly from the artifacts instead of writing implementation tasks from scratch.
---
title: Phase 0 Development Plan
description: Design-first plan that makes Phase 1 implementation predictable without institution systems
ms.date: 2026-06-28
ms.topic: how-to
keywords:
  - planning
  - mechanics
  - phase 0
  - design workflow
estimated_reading_time: 9
---

## Intent

Phase 0 exists to make Phase 1 implementation predictable.

The focus is design and specification work, not feature coding.

By the end of Phase 0, we should have modular artifacts that let us build Phase 1 mechanics
in parallel, with clear contracts between narrative, systems, and world design.

## Scope decision

Faction systems are deferred to a later phase.

Phase 0 and Phase 1 focus on social assimilation pressure through individual NPC witnessing,
suspicion, trust, language learning, relationships, and survival pacing.

## Source alignment

This plan is derived from the following references:

* docs/general/MECHANICS_SPEC.md
* docs/general/storyboard.drawio
* docs/general/storyboard_modular.drawio
* docs/general/MAP_PLAN.md
* docs/places/village.md
* docs/people/people.md

## Phase 1 mechanics this plan must unblock

* Individual NPC suspicion and trust with witness memory
* Event severity and threshold reactions at 35, 60, and 80 suspicion
* Arrest and recovery loop with state reset policy and persistent language learning
* First-contact and core-loop progression from alley start into market social pressure
* Relationship growth and vouching foundations

## What Phase 0 is not

Phase 0 does not include production implementation of gameplay systems.

Allowed technical activity is limited to lightweight validation prototypes needed
to answer open design questions.

## Workstream execution order

Run workstreams in this order to reduce rework and prevent downstream drift.

1. Workstream 3: Suspicion and social assimilation ruleset hardening
2. Workstream 1: Location design for modular mechanics testing
3. Workstream 2: NPC roster expansion and behavioral cast architecture
4. Workstream 4: Core loop content architecture
5. Workstream 5: Map and mechanic integration design
6. Workstream 6: Modular delivery framework

### Workstream 1: Location design for modular mechanics testing

Goal: Expand and classify locations so each major mechanic can be tested in at least one low-risk and one high-risk space.

Dependencies:

* Depends on: Workstream 3 outputs (event dictionary, threshold behavior)
* Required before: Workstream 2 final witness placement, Workstream 5 final zone-mechanic mapping

Design tasks:

* Define a location taxonomy by gameplay role: social pressure, safe recovery, high enforcement, language learning, and labor economy
* Backfill and normalize every currently implemented location before approving net-new additions
* Prioritize net-new locations beyond the current map baseline, including at minimum one additional stealth lane, one additional social interior, and one additional labor sub-zone
* Specify entry and visibility rules per location: expected witnesses, line-of-sight pressure, ambient cover, and social appropriateness bands
* Define location adjacency contracts so traversal supports storyboard loops without dead ends

Artifacts:

* Location Design Matrix
* Location Profile Pack
* Spatial Contract Map
* Location Readability Guide

### Workstream 2: NPC roster expansion and behavioral cast architecture

Goal: Expand NPC coverage so every major zone and loop beat has named witnesses, sponsors, and friction actors.

Dependencies:

* Depends on: Workstream 1 location taxonomy and adjacency contracts, Workstream 3 suspicion and witness rules
* Required before: Workstream 4 module actor assignments, Workstream 5 threshold witness placement

Design tasks:

* Create an NPC role map that assigns each zone at least one primary witness and one secondary witness
* Define social function per NPC: enforcer, sponsor, rumor source, labor gate, language bridge, sanctuary gate
* Design routine templates for Phase 1: patrol, stall-bound, interior-bound, lane-transition, day-night swap
* Define interaction stakes and refusal logic for first-contact phase, gifting, and early trust repair

Artifacts:

* NPC Architecture Sheet
* Witness and Sponsor Coverage Grid
* NPC Interaction Voice Cards

### Workstream 3: Suspicion and social assimilation ruleset hardening

Goal: Convert current mechanics descriptions into an executable design ruleset with minimal ambiguity.

Dependencies:

* Required before: Workstream 1 high-risk and low-risk location validation, Workstream 2 witness role definitions, Workstream 5 threshold placement

Design tasks:

* Formalize a suspicion event dictionary for Phase 1 actions with trigger conditions and severity bands
* Define social mismatch heuristics explicitly: language mismatch, wrong place, wrong timing, context-inappropriate action
* Define recovery design for Phase 1: what recovers suspicion now and what is deferred
* Define rumor spread classes for severe versus local events

Artifacts:

* Suspicion Event Catalog v1
* Social Norm Rulebook v1
* Threshold Reaction Playbook (35, 60, 80)
* Recovery and Rumor Rules Sheet

### Workstream 4: Core loop content architecture

Goal: Make the first-contact to daily-loop arc content-modular and reusable.

Dependencies:

* Depends on: Workstream 1 location contracts, Workstream 2 NPC role map, Workstream 3 event and threshold rules
* Required before: Workstream 5 storyboard-to-zone finalization and implementation-ready module slicing

Design tasks:

* Break storyboard beats into reusable interaction modules: first failure, stealth recovery, observed action, gift gamble, trust gain, night decision
* Define module input-output contracts: prerequisites, state changes, fail paths, and repeatability conditions
* Specify language-learning token progression for Phase 1 and what content references each token
* Define labor versus covert entry points as design modules, even if one side is initially thin in implementation

Artifacts:

* Core Loop Module Catalog
* State Transition Contract Sheet
* Language Token Progression Map
* Interaction Outcome Library

### Workstream 5: Map and mechanic integration design

Goal: Ensure map zones, suspicion logic, and storyboard loops align one-to-one.

Dependencies:

* Depends on: Workstream 1 location outputs, Workstream 2 witness coverage, Workstream 3 threshold behavior, Workstream 4 module contracts
* Required before: Phase 1 backlog generation from validated crosswalk artifacts

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

### Workstream 6: Modular delivery framework

Goal: Create execution artifacts that keep implementation modular through the full lifecycle.

Dependencies:

* Depends on: Workstream 1 through 5 artifact outputs
* Required before: Final Phase 1 handoff and dependency-safe parallel implementation planning

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

## Required net-new design coverage

To match current scope pressure, Phase 0 must explicitly deliver:

* At least four net-new location definitions with role intent and adjacency contracts
* At least eight net-new NPC role definitions with witness and sponsor coverage
* At least twenty interaction outcomes in the module outcome library across stealth, social, and survival contexts

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
* docs/design/phase0/core-loop-module-catalog.md
* docs/design/phase0/state-transition-contract-sheet.md
* docs/design/phase0/storyboard-zone-crosswalk.md
* docs/design/phase0/phase1-definition-of-ready-checklist.md

## Deferred systems note

If later phases re-introduce institutions, add them as a new workstream after the Phase 1 core loop is stable.

That future workstream should consume existing role and institution tags instead of redefining baseline suspicion behavior.
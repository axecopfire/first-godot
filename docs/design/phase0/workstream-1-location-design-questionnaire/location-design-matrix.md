---
title: Workstream 1 Location Design Matrix
description: High-level normalized matrix for all current and planned Phase 0 locations
ms.date: 2026-06-28
ms.topic: reference
keywords:
  - phase 0
  - workstream 1
  - location design
  - matrix
estimated_reading_time: 8
---

## Purpose

Use this matrix as the high-level control plane for Workstream 1.

Keep it compact. Put detailed design, threshold behavior, and open-issue tracking in per-location profile files.

## Scope and normalization rules

* Scope includes every currently tracked Phase 0 location and every approved net-new location
* No location enters Milestone A done status unless it has a linked profile
* Keep or cut decisions happen here first, then profile details are updated
* Market sub-areas can stay in one profile unless they need unique suspicion thresholds or access contracts
* Fields can stay in one profile during Phase 0, then split into sub-zone profiles in Phase 1 if balancing needs it

## Zone model

Use a two-layer structure:

* **Institution zone** is the social control layer (who sets norms, who enforces behavior, and whose trust or suspicion matters most)
* **Location** is a concrete place inside that institution zone where specific loops happen

This means an institution zone can contain multiple locations. Institution zones identify social ownership and pressure context.

## Matrix

| Location | Institution zone | Baseline type | Primary role | Risk profile | Keep decision | Readiness | Required rework summary | Profile |
|---|---|---|---|---|---|---|---|---|
| Market Square | Civic Commons (contested) | Existing | Social pressure | High | Keep | Review complete | Keep as main witness-dense pressure arena; formalize stall-specific witness lanes | [market](location-profiles/market.md) |
| Starting Alley | Civic Commons fringe | Existing | Safe recovery | Low | Deprecate | Review complete | Deprecated in favor of Fields as initial spawn | [alley](location-profiles/alley.md) |
| Church | Church zone | Existing | Safe recovery | Low | Keep | Review complete | Keep sanctuary logic tied to trust sponsorship and institution exceptions | [church](location-profiles/church.md) |
| Workshop | Scholar zone | Existing | Language learning | Medium | Keep | Review complete | Clarify scholar-path onboarding and witness conditions by time block | [workshop](location-profiles/workshop.md) |
| School | Scholar zone | Existing | Language learning | Low | Keep with revision | Review complete | Differentiate from workshop or merge later if redundant after playtest | [school](location-profiles/school.md) |
| Tailor | Artisan zone | Existing | Safe recovery | Low | Keep with revision | Review complete | Strengthen unique loop purpose beyond passive safety and item drip | [tailor](location-profiles/tailor.md) |
| Blacksmith | Artisan zone | Existing | Labor economy | Medium | Keep | Review complete | Use tolerated-presence behavior to teach social timing norms | [blacksmith](location-profiles/blacksmith.md) |
| Mill | Artisan and labor zone | Existing | Labor economy | Low | Keep with revision | Review complete | Add explicit day-night contract and hiding-risk transition behavior | [mill](location-profiles/mill.md) |
| Warehouse | Guard and logistics zone | Existing | High enforcement | High | Keep | Review complete | Formalize supervised labor route and theft escalation ladder | [warehouse](location-profiles/warehouse.md) |
| Barracks | Guard and logistics zone | Existing | Authority gate | High | Keep | Review complete | Keep as threshold demonstration anchor at 60 and 80 suspicion | [barracks](location-profiles/barracks.md) |
| Fields | Agrarian labor zone | Existing | Labor economy + initial spawn | Medium | Keep | Review complete | New initial spawn location; stage sub-zones in profile now; split into separate zones only if required | [fields](location-profiles/fields.md) |
| Manor Courtyard | Manor authority zone | Existing | Authority gate | High | Keep | Review complete | Gate access by sponsorship and progression, not only hard lock | [manor-courtyard](location-profiles/manor-courtyard.md) |
| Manor House | Manor authority zone | Existing | High enforcement | High | Keep | Review complete | Reserve late access and narrative reveal pacing constraints | [manor-house](location-profiles/manor-house.md) |

## Cut criteria for future review

A location should be considered for cut, merge, or defer when at least two of these are true:

* It duplicates another location's primary and secondary role
* It does not unlock a distinct Phase 1 mechanic
* It has no unique witness or sponsorship pattern
* It adds traversal complexity without improving loop pacing
* It does not support either a pressure path or a recovery path

## Governance

* Update this matrix first when a keep or cut decision changes
* Update the linked profile in the same change
* Keep readiness values to one of: `Not started`, `In review`, `Review complete`, `Ready for Milestone A`

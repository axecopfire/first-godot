---
title: Social Norm Rulebook v1
description: Explicit mismatch heuristics, conformity evidence, and recovery evidence for Phase 1 social assimilation
ms.date: 2026-07-01
ms.topic: reference
keywords:
  - social norms
  - mismatch
  - conformity
  - suspicion
  - recovery
estimated_reading_time: 7
---

## Purpose

Define the explicit heuristics for what counts as a social mismatch and what counts as
conformity evidence in Phase 1.

This rulebook gives implementation a shared vocabulary so mismatch events and conformity
events are evaluated consistently across all contexts.

## Source Decisions

| Decision ID | Contribution |
|---|---|
| DEC-WS3-003 | Recovery contract, same-witness-only rule, fixed-step model, early-loop guarantee |
| DEC-WS3-001 | Single spectrum model; mismatch and conformity are opposite directions on the same axis |

## Core Model

Mismatch and conformity are not separate systems. They are opposing forces on a single
trust-suspicion spectrum per NPC witness.

| Action class | Effect on spectrum |
|---|---|
| Mismatch event | Move toward suspicion by the event's tier magnitude |
| Conformity event | Move toward trust by the event's tier magnitude |
| Neutral event | No movement |

## Mismatch Heuristics

A mismatch occurs when the player's action conflicts with a local social expectation
that a human resident would follow without thinking.

### Primary Mismatch Classes

| Class | Definition | Examples |
|---|---|---|
| Language mismatch | Dialogue or interaction choice does not fit local speech norms or comprehension level | Using wrong greeting register, failing basic question response, choosing a word the character would not know |
| Wrong place | Player is present in a location where their role or status is not locally expected | Entering the barracks without a social pretext, lingering in a private residence without invitation |
| Wrong timing | Player performs an action at a time of day or social moment when it is not appropriate | Approaching a stall during closing, interrupting a ritual or communal moment |
| Context-inappropriate action | Player performs an action that is technically possible but socially illegible in context | Picking up an object in a market with no exchange, interacting with an NPC tool or workstation uninvited |
| Role violation | Player behaves in a way inconsistent with the social role they have implied or been assigned | Giving orders to an NPC in a setting where the player has no authority |

### Mismatch Evaluation Rule

Apply at most one primary mismatch class per witnessed action.
If multiple classes qualify, choose the highest-severity mismatch class.
If mismatch and conformity both qualify, mismatch wins in Phase 1.

## Conformity Evidence

Conformity occurs when the player's action visibly aligns with a local social expectation
and is witnessed by at least one NPC.

### Primary Conformity Classes

| Class | Definition | Examples |
|---|---|---|
| Polite dialogue conformity | Dialogue choice follows expected tone and local norm | Using the correct greeting, responding appropriately to a social prompt |
| Helpful visible action | Player completes a socially legible helpful action in a shared space | Picking up a dropped object and returning it, helping with an observable task |
| Role-appropriate routine | Player follows a routine or behavior expected for the context | Standing in an expected place at an expected time, participating in a communal activity |
| Correct timing presence | Player arrives at or leaves a location at a socially appropriate moment | Joining a market context at the right hour, departing before a restricted period |

### Conformity Evaluation Rule

Conformity applies one fixed recovery step per qualifying witnessed action.
The same witness must observe the action for recovery to apply.
Recovery is not shared across witnesses in Phase 1.

## Same-Witness-Only Recovery

| Rule ID | Rule |
|---|---|
| SNR-01 | Recovery from a mismatch event applies only to the NPC witness who directly observes the conformity action |
| SNR-02 | A conformity action does not reduce suspicion with NPCs who did not witness it |
| SNR-03 | Sponsors and witness-sharing mechanics are deferred to a later phase |

## Early Loop Recovery Guarantee

| Rule ID | Rule |
|---|---|
| ELR-01 | At least one low-friction conformity action must be available to the player in every zone during the early loop |
| ELR-02 | No zone should be designed as mismatch-only with no viable recovery path |
| ELR-03 | The starter list of low-friction recovery actions must be documented in implementation artifacts before Phase 1 ships |

## Conformity and Mismatch Interaction With Rumor

| Rule ID | Rule |
|---|---|
| CMR-01 | A conformity action applied to a witness who received a rumor contribution reduces that witness's suspicion by the standard fixed recovery step |
| CMR-02 | Rumor-sourced suspicion is not a separate track; it contributes to the same per-witness spectrum value |

## Open Issues

| ID | Issue | Owner | Due date | Fallback rule |
|---|---|---|---|---|
| WS3-003-O1 | Starter recovery action list needs to be locked in implementation docs | Design | 2026-07-01 | Ship with one always-available low-friction action and expand from playtest feedback |

## Change Log

| Date | Change |
|---|---|
| 2026-07-01 | Created from DEC-WS3-003 answers and synthesis, aligned to DEC-WS3-001 spectrum model |

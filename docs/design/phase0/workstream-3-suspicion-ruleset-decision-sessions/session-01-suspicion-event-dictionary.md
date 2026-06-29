---
title: Workstream 3 Session 1 Suspicion Event Dictionary
description: Decision session to define Phase 1 suspicion events, trigger conditions, and severity bands
ms.date: 2026-06-28
ms.topic: how-to
keywords:
  - phase 0
  - workstream 3
  - suspicion events
  - severity bands
estimated_reading_time: 9
---

## Session metadata

| Field | Value |
|---|---|
| Session number | 1 |
| Session title | Suspicion event dictionary and severity bands |
| Date | 2026-06-28 |
| Facilitator | Pending |
| Participants | Narrative, Systems, World Design |
| Target artifact | Suspicion Event Catalog v1 |

## Objective

Define the initial event dictionary for Phase 1 with explicit triggers, severity, and witness scope.

By the end of this session, every high-frequency early-game action should map to one event rule.

## Guardrail checks

1. Does each event represent social mismatch first, not only crime detection?
2. Does each severe event avoid exposing the hidden identity reveal prematurely?
3. Does each event leave room for non-stealth social recovery paths?
4. Does the event set reinforce routine learning and non-verbal social conformity as progression?

## Severity vocabulary

Use one shared severity vocabulary in all Workstream 3 artifacts.

| Band | Meaning | Typical suspicion delta range |
|---|---|---|
| Minor | Noticeable mismatch, low immediate threat | +2 to +5 |
| Moderate | Clear mismatch or rule breach with social consequence | +6 to +12 |
| Major | High concern event likely to trigger coordinated response | +13 to +25 |

Adjust numeric ranges only if the team agrees on a different baseline in this session.

## Event rule prompts

Use one row per event candidate.

| Event candidate | Trigger conditions | Severity band | Suggested delta | Witness scope (local, area, institution, global) | First expected reaction |
|---|---|---|---|---|---|
| Non-response in formal exchange | During formal greeting or trade script, player does not perform required acknowledgement action twice in one exchange | Minor | +4 | local | NPC pauses interaction, repeats gesture cue, and tags player as unfamiliar |
| Entering restricted interior without social permission | Player crosses into flagged restricted interior without invitation token, role permit, or escort state | Moderate | +10 | area | Nearest authority or worker blocks path and demands justification |
| Loitering in high-control zone at wrong time window | Player remains in curfew-controlled zone for more than 45 seconds without valid task reason | Moderate | +8 | area | Patrol actor approaches and escorts player to public lane |
| Taking item in visible lane without clear ownership transfer | Player picks up owned item in line of sight before barter, gift, or task handoff is complete | Major | +16 | area | Owner calls out violation and nearby actors begin coordinated watch |
| Ignoring direct instruction from authority actor | Authority gives explicit command and player performs blocked action within response window | Moderate | +9 | institution | Command source issues formal warning and reduces institutional trust score |
| Repeated context-inappropriate action after warning | Same minor mismatch repeats 3 times within 120 seconds after explicit warning | Major | +14 | local | Crowd sentiment shifts to alarm and sponsor credibility is reduced |

## Event granularity decisions

Resolve these before accepting final event IDs.

1. Should repeated minor mismatches stack into one moderate composite event, or remain separate events?
2. Which events are location-agnostic and which require location-specific variants?
3. Which events should only fire if witnessed, and which can fire from systemic checks?
4. Which events must be blocked behind non-verbal cue-recognition thresholds?
5. Which events should be soft-blocked during first-contact grace windows?

## Accepted event rules

Assign stable IDs in this format: WS3-E###.

| Event ID | Rule statement | Trigger conditions | Severity | Delta | Witness scope | Recoverability class |
|---|---|---|---|---|---|---|
| WS3-E001 | Formal exchange non-response in civic interaction | In a formal exchange node, player fails to perform required acknowledgement action twice | Minor | +4 | local | Quick social repair via correct acknowledgement gesture and compliant pacing |
| WS3-E002 | Unauthorized restricted-entry attempt | Player enters restricted interior without permission flag or escort | Moderate | +10 | area | Repair via compliance, exit, and role-based explanation |
| WS3-E003 | Curfew-zone loitering mismatch | Player remains in high-control zone during restricted hours without task token | Moderate | +8 | area | Repair via escort compliance plus time-window learning objective |
| WS3-E004 | Visible ownership transfer breach | Player takes owned item before clear transfer in visible lane | Major | +16 | area | Repair via restitution, witness-facing apology, and optional sponsor vouch |
| WS3-E005 | Authority instruction defiance | Player ignores direct authority instruction within response timer | Moderate | +9 | institution | Repair via immediate compliance and authority mediation task |
| WS3-E006 | Escalated repeated mismatch pattern | Same minor mismatch occurs 3 times after warning in short rolling window | Major | +14 | local | Repair via coached routine completion with sponsor present |
| WS3-E007 | Ritual sequence disruption in shared space | Player violates required order in church or school ceremony after prompt | Moderate | +7 | institution | Repair via corrective participation in next valid sequence |
| WS3-E008 | Unverified sponsorship claim | Player claims local sponsorship link that fails validation check | Major | +18 | institution | Repair via verified sponsor introduction or formal probation task |

## Dependency notes

| Dependent workstream | Data needed from this session | Why it matters |
|---|---|---|
| Workstream 1 | High-risk versus low-risk event distribution assumptions | Validates location pressure and recovery profile design |
| Workstream 2 | Witness-scope definitions and actor reaction expectations | Drives witness role coverage and routine templates |
| Workstream 5 | Spatial visibility expectations for major events | Enables threshold visibility mapping by zone |

## Open issues

| ID | Question | Owner | Due date | Fallback rule |
|---|---|---|---|---|
| WS3-S1-001 | What is the exact first-contact grace window before minor non-response events can fire? | Systems Design | 2026-07-01 | Use 90-second grace from spawn or first district entry |
| WS3-S1-002 | Should institution-scope events propagate to all authority actors immediately or with delay? | AI and Narrative | 2026-07-02 | Apply 30-second propagation delay with local-area priority |

## Exit checklist

* At least 12 candidate events reviewed
* At least 8 events accepted with stable IDs
* All accepted events include trigger, severity, delta, and witness scope
* At least one recovery-compatible note exists for each major event
* Unresolved items have owner and fallback

## Export actions

* Copy accepted rules into Suspicion Event Catalog v1
* Record unresolved issues in Workstream 3 master log
* Prepare carry-forward questions for Session 2
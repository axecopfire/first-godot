---
title: Mechanics Specification
description: Core mechanics baseline for Phase 0 and Phase 1, with institution systems deferred to a later phase
ms.date: 2026-06-28
ms.topic: overview
keywords:
  - game design
  - mechanics
  - systems
  - balancing
estimated_reading_time: 9
---

## Purpose

This specification defines the minimum complete system needed for the first playable loop.

The core fantasy is hidden AI acculturation. The player is unknowingly performing the role
of an AI learning to function among humans, with that identity revealed near the end.

## Scope decision

Factions are removed from Phase 0 and Phase 1 scope.

Any institution-specific reputation, coupling, or political systems are deferred to a later phase.
Current mechanics should stay compatible with future institution layering by using neutral tags
such as role, institution, and context instead of hard-coded institution IDs.

## Source of truth

This document consolidates mechanics from:

* docs/general/GAME_DESIGN.md
* docs/general/DEV_PLAN.md
* docs/general/MAP_PLAN.md
* docs/people/people.md

## Specification authority levels

Not every statement in this file has the same implementation authority.

| Level | Meaning | Planning behavior |
|---|---|---|
| Locked constraint | Non-negotiable for current milestone and hidden-premise guardrails | Must be implemented as written or changed by explicit design decision |
| Phase target | Intended for a named phase, but values and formulas can change during implementation | Can be adjusted in phase planning with rationale |
| Working baseline | Starting balance or threshold proposal | Tune freely during implementation and playtest |
| Open design question | Known unknown or unresolved design detail | Do not block phase start; create a spike or assumption and proceed |

## Core loop mechanics we must build

### Visibility and suspicion

Suspicion is social assimilation pressure first, enforcement pressure second.

* Each NPC tracks individual suspicion and trust based on witnessed events.
* Witnessing is the core mechanic. NPC memory drives immediate social outcomes.
* Inappropriate behavior triggers suspicion. Appropriate behavior builds trust.
* Rumor propagation can spread severe events to additional NPCs.
* Suspicion decay requires active conformity. Passive time decay does not apply.

| Mechanic | Required behavior | Status target |
|---|---|---|
| Individual NPC suspicion | Each NPC tracks own suspicion and trust from witnessed behavior | Phase 1 |
| Witnessing events | NPCs remember positive and negative actions | Phase 1 |
| Event severity classification | Actions classify into suspicion or trust deltas | Phase 1 |
| Rumor propagation | High and critical events emit village-class rumor packets reaching all active witnesses; low and medium events stay local | Phase 1 |
| Second-hand reputation | NPCs can shift stance based on trusted reports | Phase 2 |
| Ally vouching | Trusted allies can intervene and vouch to reduce suspicion during escalation | Phase 3 |
| Stealth state | Stealth reduces visibility and witnessing probability | Phase 1 |
| Threshold reactions | Suspicion 35: timer-based zone-locked follow, ends on line-of-sight break or zone exit, severity can escalate to local support calls; suspicion 60: zone-local chase and same-zone support calls; suspicion 80: instant arrest on overlap | Phase 1 |
| Suspicion reset rules | Arrest resets suspicion to baseline, preserves learning state | Phase 1 |
| Trust building through witnessing | Repeated visible conformity lowers suspicion and raises trust | Phase 2 |

### Learning and social norm discovery

This loop teaches right place, right time, right action through observation and feedback.

| Mechanic | Required behavior | Status target |
|---|---|---|
| NPC routine patterns | Schedules teach context and appropriateness | Phase 2 |
| Immediate NPC feedback | Reactions reward conformity and signal mismatch | Phase 1 |
| Language learning as discovery | Learned words unlock hints and safer responses | Phase 2 |
| Gifting reveals values | Accepted and rejected gifts teach social priorities | Phase 2 |
| Trial and error loop | Player experiments, NPCs react, player adapts | Phase 1 |

### Gifting and relationship growth

| Mechanic | Required behavior | Status target |
|---|---|---|
| Gift interaction | Player can offer held item near NPC | Phase 2 |
| Gift acceptance formula | Uses item value, need, relationship, and recent memory | Phase 2 |
| Relationship score per NPC | Persistent relationship values by character | Phase 2 |
| Friendship threshold | Relationship greater than or equal to 40 marks ally | Phase 3 |
| Vouching | Ally can reduce suspicion by fixed amount | Phase 3 |
| Word learning | Accepted gifts can teach language tokens | Phase 2 |

### Survival loop

| Mechanic | Required behavior | Status target |
|---|---|---|
| Day and night progression | Time advances and gates events | Phase 4 |
| Sleep anywhere | Player can sleep in any accessible location | Phase 4 |
| Location-based suspicion | Being seen in socially inappropriate spaces increases suspicion | Phase 4 |
| Hunger decay | Hunger decays on set timers | Phase 1 |
| Shelter quality scale | Shelter quality affects outcomes and recovery | Phase 3/4 |
| Safe shelter unlock | Trust and poverty rules govern safe shelter access | Phase 3/4 |

### Failure and restart loop

| Mechanic | Required behavior | Status target |
|---|---|---|
| Arrest flow | High suspicion leads to arrest and imprisonment | Phase 1 |
| Death flow | Extreme outcomes lead to game over | Phase 1 |
| Respawn policy | Arrest restarts in fields early in development | Phase 1 |
| Language persistence | Learned words persist after arrest and across runs | Phase 1 |
| State reset on arrest | Suspicion resets, language and relationship progress remain | Phase 1 |

### Career progression baseline

Career progression remains in scope, but without institution simulation.

| Path | Required trigger | Required systems |
|---|---|---|
| Merchant | Build trust with trade-linked NPCs | Relationship, errands, economic outcomes |
| Military-adjacent service | Gain access through compliance and patrol support | Suspicion control, restricted area rules |
| Religious sanctuary | Earn trust through ritual conformity and social repair | Language, trust, sanctuary gate logic |
| Scholar | Reach language and knowledge milestones | Translation tasks, study gates |
| Underworld | Build ties through covert tasks and secrecy | Risk management, witness avoidance |

## Supporting mechanics we should add next

### AI behavior upgrades

| Proposal | Why it matters | Suggested scope |
|---|---|---|
| Awareness cones and hearing radius | Makes stealth skill-based | Light and sound checks per NPC |
| Group alert propagation | Makes mistakes feel systemic | Shared alert state among nearby NPCs within the same zone |
| Guard patrol schedules | Creates readable risk windows | Time-based route graph |
| Cooldown and de-escalation | Prevents perpetual chase states | Decay timers and safe-zone logic |
| Ally vouching | Gives a future social-support path during escalation | Trusted allies in the same zone can intervene and vouch |

### Economy and scarcity

| Proposal | Why it matters | Suggested scope |
|---|---|---|
| Dynamic prices by scarcity | Connects social pressure, weather, and markets | Item multiplier by daily supply |
| Work-for-food loops | Supports non-criminal survival | Repeatable labor actions in fields and mill |
| Debt and favor ledger | Adds medium-term planning | Track obligations with merchants and manor staff |

### Language and communication depth

| Proposal | Why it matters | Suggested scope |
|---|---|---|
| Partial sentence comprehension | Makes language progress tangible | Replace unknown words gradually |
| Misinterpretation events | Adds risk to low fluency | Wrong choices at low comprehension |
| Translation checks in quests | Gives scholar path identity | Dialogue gates by lexicon count |

### Social simulation

| Proposal | Why it matters | Suggested scope |
|---|---|---|
| NPC rumor network | Actions propagate through village memory | Daily rumor spread pass |
| Moral profile per NPC | Makes gift outcomes less binary | Morality shifts by witnessed behavior |
| Sponsor credibility | Makes social recovery strategic | Vouch strength by witness trust |

## Deferred systems registry

These mechanics are intentionally deferred and should not block Phase 0 or Phase 1.

* Faction reputation meters
* Cross-institution coupling penalties and bonuses
* Faction-specific gates and lockouts
* Faction policy and manor influence simulation
* Multi-institution balancing contracts

Revisit trigger: after first playable loop reaches stable playtest quality for suspicion,
relationships, and survival pacing.

## Technical mechanics architecture

### Data model we need now

| Data object | Minimum fields |
|---|---|
| PlayerState | hunger, inventory, known_words, current_zone |
| NPCState | id, relationship, individual_suspicion, individual_trust, role, institution, witnessed_events |
| WitnessEvent | event_type, severity, date, witnesses_list, context_tags |
| RumorState | event_id, originating_npc, heard_by_npcs, severity_class |
| WorldState | time_of_day, day_index, alert_state_per_zone, event_flags |
| ReputationState | merchant_path, service_path, sanctuary_path, scholar_path, underworld_path |
| QuestState | active_stage, completion_flags, branching_choice |

### Signals and events we should standardize

| Signal | Payload |
|---|---|
| event_witnessed | npc_id, event_type, severity, location, outcome |
| rumor_spread | originating_npc_id, event_id, propagating_to_npc_ids, severity_class |
| individual_suspicion_changed | npc_id, current_value, delta, source, reason |
| individual_trust_changed | npc_id, current_value, delta, source, reason |
| conformity_witnessed | action_type, witness_npc_id, zone, trust_impact |
| relationship_changed | npc_id, new_value, reason |
| day_started | day_index |
| path_rep_changed | path_id, delta, source |

## Balancing metrics to define early

| Metric | Starting target | Notes |
|---|---|---|
| Time to first arrest (new player) | 2 to 5 minutes | Teaches danger quickly |
| Time to first friendship | 20 to 40 minutes | Keeps social loop meaningful |
| Time to unlock first path | 45 to 90 minutes | Depends on route quality |
| Daily survival failure rate without shelter | 40 to 70 percent | Maintains pressure |
| Suspicion recovery time from 60 to 20 | 1 to 3 minutes | Must feel recoverable |

## Design decisions locked

1. Phase 1 spawn location: fields only.
2. Suspicion is individual NPC-driven, with witnessing and rumor as the primary input.
3. Arrest is recoverable and death is game over.
4. Language learning is persistent across failures.
5. Active conformity is required to reduce suspicion.
6. Combat is out of scope. Resolution is social and stealth-based.
7. Factions are deferred and must not be required for first playable loop completion.

## Suggested implementation order

1. Finalize state model and reset policy.
2. Ship individual NPC witnessing and suspicion-trust tracking.
3. Ship stealth, arrest, and restart loop.
4. Ship gifting and relationship persistence.
5. Ship day-night cycle and shelter outcomes.
6. Add rumor propagation and richer social memory.
7. Re-evaluate institution layer only after baseline loop is stable.
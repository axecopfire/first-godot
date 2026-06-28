---
title: Mechanics Specification
description: Full mechanics inventory for the medieval village survival game, including planned systems, proposed additions, and open design questions
ms.date: 2026-06-27
ms.topic: overview
keywords:
  - game design
  - mechanics
  - systems
  - balancing
estimated_reading_time: 12
---

## Purpose

This specification lists every core mechanic we need to build for the current game vision, then proposes additional systems that can deepen strategy, replayability, and narrative identity.

The core fantasy is hidden AI acculturation. The player is unknowingly performing the role
of an AI learning to function among humans, with that identity revealed near the end.

## Source of truth

This document consolidates mechanics from:

* `docs/general/GAME_DESIGN.md`
* `docs/general/DEV_PLAN.md`
* `docs/general/MAP_PLAN.md`
* `docs/people/people.md`
* `docs/general/faction_arcs_detailed.drawio`

## Specification authority levels

Not every statement in this file has the same implementation authority. Use these levels during planning and execution.

| Level | Meaning | Planning behavior |
|---|---|---|
| Locked constraint | Non-negotiable for current milestone and hidden-premise guardrails | Must be implemented as written or changed by explicit design decision |
| Phase target | Intended for a named phase, but values and formulas can change during implementation | Can be adjusted in phase planning with rationale |
| Working baseline | Starting balance or threshold proposal | Tune freely during implementation and playtest |
| Open design question | Known unknown or unresolved design detail | Do not block phase start; create a spike or assumption and proceed |

Unless an item is explicitly labeled as a locked constraint, treat it as a phase target or working baseline.

## Phase planning anti-blocker protocol

When planning a phase, convert candidate mechanics into one of three tracks so detail gaps do not stop execution.

| Track | Entry condition | Output required before implementation |
|---|---|---|
| Implement now | Mechanic is phase-critical and sufficiently specified | Task list with acceptance tests |
| Spike first | Mechanic is phase-critical but underspecified | Timeboxed spike with one recommended implementation shape |
| Defer | Mechanic is non-critical for current phase goals | Backlog note with dependency and revisit trigger |

Use the following rule in planning sessions.

1. If a mechanic lacks enough detail to code, do not treat it as blocked by default.
2. Decide whether to spike or defer based on phase-criticality.
3. Record the assumption in the phase plan and continue.

## Core loop mechanics we must build

### Visibility and suspicion

The game depends on pressure from social mismatch. This system is mandatory.

Suspicion is **dual-track**:

* Each NPC tracks their own suspicion/trust of the player based on witnessed events.
* Each faction tracks a separate **faction alert level** that reflects collective concern and can trigger faction-wide responses.
* **Witnessing is the core mechanic**: NPCs remember what they see you do, and their memory influences both their individual stance and (potentially) the village-wide perception.
* Inappropriate behavior triggers suspicion; appropriate behavior builds trust.
* **Rumor propagation**: Depending on the severity and social importance of a witnessed event, NPCs may tell others about it. Minor infractions stay private; major scandals spread through the village network.
* **Second-hand effects**: When an NPC hears about you from another NPC, it creates reputation shifts without direct witnessing.
* **Suspicion decay requires active conformity** — passive time decay does not apply. Individual suspicion only decreases through correct repeated behavior, successful gifting, and vouching.
* **Faction alert level** — aggregate individual reports and rumor intensity produce a faction-wide alert state that can trigger organized faction events.

| Mechanic | Required behavior | Status target |
|---|---|---|
| Individual NPC suspicion | Each NPC tracks own suspicion/trust value based on witnessed behavior | Phase 1 |
| Faction alert level | Each faction tracks an independent alert meter based on member reports and rumor salience | Phase 1 |
| Witnessing events | NPCs remember positive and negative actions; memory persists | Phase 1 |
| Event severity classification | Inappropriate actions trigger suspicion; appropriate actions build trust | Phase 1 |
| Rumor propagation | Severe events may be shared; minor infractions stay private | Phase 2 |
| Second-hand reputation | NPCs hearing about events from others affects their stance without direct witnessing | Phase 2 |
| Stealth state | Shift reduces visibility/witnessing probability | Phase 1 |
| Threshold reactions | Individual suspicion 35+ follow, 60+ chase, 80+ arrest (guards aggregate NPCs) | Phase 1 |
| Faction threshold events | Faction alert 40+ scrutiny events, 65+ crackdown events, 85+ emergency doctrine events | Phase 2 |
| Suspicion reset rules | Arrest resets individual suspicions to base; active conformity required to rebuild | Phase 1 |
| Trust building through witnessing | Being in right place, right time, right action grows trust; witnessed conformity lowers suspicion | Phase 2 |
| Active conformity required | Only correct repeated behavior gradually lowers individual suspicion | Phase 3 |

### Persistent accuser loop and vendetta risk

This loop models a villager who repeatedly warns others while the broader faction oscillates between alarm and calm.

Status target: Phase 3 (after friendship and vouching systems are available).

* If one NPC reaches individual suspicion >= 70 multiple times while their faction alert repeatedly recovers, that NPC can become a persistent accuser.
* Persistent accusers are more likely to witness, initiate rumor bursts, and reinterpret ambiguous actions negatively.
* If ignored long enough, persistent accusers can escalate into vigilantism or recruit a coalition.
* De-escalation requires social repair, not stealth alone: witnessed conformity, public apology beats, third-party mediation, and successful vouching.

| Escalation stage | Entry condition | Behavior | Off-ramp |
|---|---|---|---|
| Vocal accuser | Same NPC hits 70+ suspicion two times within 3 in-game days | Increased reporting cadence and louder rumor spread | 2 mediated positive encounters + 1 trusted vouch |
| Vendetta (Phase 3) | Same NPC hits 80+ suspicion while faction alert is below 50 | Targeted tailing, baiting, and unilateral escalation attempts | Public restitution event witnessed by accuser |
| Coalition builder (Phase 3) | Vendetta persists 2+ days and recruits 2+ aligned NPCs | Organized anti-player meetings, coordinated reporting, potential vigilante interception | Break coalition trust via contradictory public evidence or sponsor intervention |

### Learning and social norm discovery

The core loop requires teaching the player what "right place, right time, right action" means. This happens through observation and feedback.

| Mechanic | Required behavior | Status target |
|---|---|---|
| NPC routine patterns | NPCs have readable schedules; being present during their routine teaches appropriateness | Phase 2 |
| Immediate NPC feedback | Positive reactions (neutral or friendly) reward correct behavior; negative reactions (avoidance, suspicion) teach mistakes | Phase 1 |
| Language learning as discovery | Learned words unlock NPC dialogue hints about their preferences and expectations | Phase 2 |
| Gifting reveals values | Watching what NPCs accept or reject teaches their morality, poverty, and social priorities | Phase 2 |
| Conformity bonuses | Repeated correct behavior in the same location/time/context gradually teaches the pattern | Phase 3 |
| Trial and error feedback loop | Player experiments, NPCs react, reactions teach the rule | Phase 1 |

### Faction-relative witness logic

Witnessing is the foundational social mechanic. Actions are interpreted by faction values, not by fixed morality.

| Mechanic | Required behavior | Status target |
|---|---|---|
| Faction reaction matrix | A witnessed action can raise trust with one faction while raising suspicion with another | Phase 1 |
| Action-specific caps | Each action has per-faction max contribution caps so one loop cannot fully max a meter | Phase 1 |
| Witness memory by action tag | Witness remembers action tag and context (for example study, pray, enforce, smuggle knowledge) | Phase 2 |
| Rumor by ideological salience | High-ideology actions spread faster than routine actions | Phase 2 |
| Seen vs unseen actions | If unseen, only direct outcome applies; if seen, faction interpretation and rumor may apply | Phase 2 |

### Faction action examples and caps

The table below is a starting baseline for balancing:

| Witnessed action | Military reaction | Criminal reaction | Church reaction | Academia reaction | Cap behavior |
|---|---|---|---|---|---|
| Theft/poaching | Suspicion +8 | Trust +6 | Suspicion +4 | Suspicion +2 | Military from theft caps at +30; church from theft caps at +20 |
| Study publicly | Suspicion +1 | Suspicion +1 | Suspicion +5 | Trust +7 | Church suspicion from study caps at +20 |
| Pray publicly | Trust +1 | Suspicion +1 | Trust +7 | Suspicion +5 | Academia suspicion from pray caps at +20 |
| Assist guard patrol | Trust +8 | Suspicion +7 | Trust +2 | Neutral | Criminal suspicion from enforcement caps at +35 |
| Share unapproved technology | Trust +2 | Trust +1 | Suspicion +12 | Trust +10 | Church suspicion from heretical teaching can exceed soft caps and reach hard lock thresholds |

### Faction suspicion thresholds and access gates

Suspicion and trust thresholds should unlock and lock interactions per faction.

| Faction | Threshold | Gate behavior |
|---|---|---|
| Church | Suspicion >= 20 | Priest dialogue options restricted; blessings unavailable |
| Church | Suspicion >= 50 | Church entry denied; guards notified if player lingers |
| Church | Suspicion >= 75 | Heretic state; sanctuary and ritual actions hard-locked |
| Academia | Trust >= 20 | Basic study tasks unlocked |
| Academia | Trust >= 50 | Research room and manuscript exchange unlocked |
| Military | Suspicion >= 35 | Watched status; patrols trail player |
| Military | Suspicion >= 60 | Detain checks and zone denial near armory |
| Criminal | Trust >= 25 | Contraband errands unlocked |
| Criminal | Trust >= 50 | Underworld contact introduction unlocked |

### Gifting and relationship growth

This system is the bridge from survival to progression.

| Mechanic | Required behavior | Status target |
|---|---|---|
| Gift interaction | Player can offer held item near NPC | Phase 2 |
| Gift acceptance formula | Uses item value, need, faction alignment, and recent action memory | Phase 2 |
| Relationship score per NPC | Persistent relationship values by character | Phase 2 |
| Trust damage recovery | Faction-offensive actions cause recoverable trust damage, not permanent | Phase 2 |
| Friendship threshold | `relationship >= 40` marks ally | Phase 3 |
| Vouching | Ally can reduce suspicion by fixed amount | Phase 3 |
| Word learning | Accepted gifts teach language tokens | Phase 2 |

### Survival loop

The game must force hard choices each day.

| Mechanic | Required behavior | Status target |
|---|---|---|
| Day and night progression | Time advances and gates events | Phase 4 |
| Sleep anywhere | Player can sleep in any accessible location | Phase 4 |
| Location-based suspicion | Being witnessed in socially inappropriate places (any time) raises suspicion by context | Phase 4 |
| Hunger decay | Hunger decays on set timers independent of location or shelter quality | Phase 1 |
| Shelter quality scale | Shelter ranges from dangerous to safe; affects hunger recovery and social outcomes | Phase 3/4 |
| Safe shelter unlock | Friendship and poverty rules control access | Phase 3/4 |

### Failure and restart loop

Arrest is recoverable; death is permanent failure.

| Mechanic | Required behavior | Status target |
|---|---|---|
| Arrest flow | High suspicion leads to arrest; player imprisoned | Phase 1 |
| Death flow | Arrest with very high suspicion leads to execution; game over | Phase 1 |
| Respawn policy | Arrest: restart in fields (as safety unlocks, expand spawn points); early phase fields only | Phase 1 |
| Death consequence | Game over; no restart within the run | Phase 1 |
| Language persistence | Learned words persist through arrest and across runs | Phase 1 |
| State reset on arrest | Suspicion and district heat reset to base; relationships, language, and arc progress kept | Phase 1 |

### Career arc progression

All three faction arcs are part of the first shippable milestone. Investment in any arc has effects on the other arcs (cross-arc reputation coupling).

| Arc | Required trigger | Required systems | Cross-arc coupling |
|---|---|---|---|
| Merchant | Befriend merchant-side NPCs | Reputation, quest stages, economic outcomes | Rising merchant rep may trigger military attention; scholar access granted |
| Military | Criminal notoriety plus guard recruitment | Order metrics, patrol authority, enforcement outcomes | Military recruitment can damage merchant standing; scholar cooperation possible |
| Religious | Broad trust plus sanctuary invitation | Moral choices, sanctuary law, faith authority outcomes | Religious favor can offset criminal rep with guards; independent of merchant/military |
| Scholar | Language and knowledge milestones | Research tasks, translation gates, policy influence | Scholar knowledge affects all paths; religious and military research diverge |
| Underworld | Criminal reputation and covert contacts | Network control, heists, crackdown pressure | Criminal rep triggers military recruitment; damages religious standing; affects merchant access |

## Supporting mechanics we should add next

These are not strictly required for a first playable loop, but they substantially improve quality and depth.

### AI behavior upgrades

| Proposal | Why it matters | Suggested scope |
|---|---|---|
| Awareness cones and hearing radius | Makes stealth skill-based | Light and sound checks per NPC |
| Group alert propagation | Makes mistakes feel systemic | Shared alert state among nearby NPCs |
| Guard patrol schedules | Creates readable risk windows | Time-based route graph |
| Cooldown and de-escalation | Prevents perpetual chase states | Decay timers and safe-zone logic |

### Economy and scarcity

| Proposal | Why it matters | Suggested scope |
|---|---|---|
| Dynamic prices by scarcity | Connects social pressure, weather, and markets | Item multiplier by daily supply |
| Work-for-food mini loops | Supports non-criminal survival | Repeatable labor actions in fields and mill |
| Debt and favor ledger | Adds medium-term planning | Track obligations with merchant and manor |

### Language and communication depth

| Proposal | Why it matters | Suggested scope |
|---|---|---|
| Partial sentence comprehension | Makes language progress tangible | Replace unknown words gradually |
| Misinterpretation events | Adds risk to low fluency | Wrong choices at low comprehension |
| Translation checks in quests | Gives scholar route mechanical identity | Dialogue gates based on lexicon count |

### Social simulation

| Proposal | Why it matters | Suggested scope |
|---|---|---|
| NPC rumor network | Actions propagate through village memory | Daily rumor spread pass |
| Moral profile per NPC | Makes gift outcomes less binary | Morality shifts by witnessed behavior |
| Cross-faction reputation | One gain can cause another loss | Reputation matrix by faction |

### Strategic world state

| Proposal | Why it matters | Suggested scope |
|---|---|---|
| Heat by district | Lets map zones feel distinct | Separate suspicion sub-meters by area |
| Event calendar | Adds anticipation and route planning | Feast day, patrol surge, market day events |
| Weather impacts | Adds stealth and economy variation | Rain noise cover, crop output modifiers |

### Manor policies and power jostling

This town is not a democracy. Factions compete for influence at the manor, and the lord passes policies from advisors he currently trusts most.

| Proposal | Why it matters | Suggested scope |
|---|---|---|
| Advisor influence scores | Turns faction reputation into governance leverage | Per-faction influence score with daily or event-driven recalculation |
| Policy proposal queue | Makes political pressure visible and forecastable | Track active proposals with sponsor faction, opponents, and urgency |
| Lord trust weighting | Keeps Don Álvaro as final authority | Proposal acceptance weighted by lord trust in sponsor, stability risk, and current alert climate |
| Legal state flags | Converts abstract politics into concrete rules | World flags for legal, illegal, prohibited, taxed, and restricted actions or zones |
| Enforcement doctrine shifts | Makes passed policy change guard behavior | Policy-driven changes to patrol routes, detain thresholds, fines, and inspections |
| Repeal and replacement loop | Prevents one-time static outcomes | New power blocs can revoke, soften, or harden existing policy sets |
| Policy communication layer | Lets player learn law changes in-world | Town crier, notices, and NPC dialogue rumors announcing active decrees |

## Technical mechanics architecture

### Data model we need

| Data object | Minimum fields |
|---|---|
| PlayerState | hunger, inventory, known_words, current_zone |
| NPCState | id, relationship, individual_suspicion, individual_trust, accuser_stage, accuser_strikes, morality, poverty, witnessed_events, faction, faction_action_caps |
| WitnessEvent | event_type (study, pray, conformity, norm_violation, etc), severity, date, witnesses_list, faction_tags |
| RumorState | event_id, originating_npc, heard_by_npcs, severity_class (spreads_widely vs stays_private) |
| FactionAlertState | faction_id, alert_value, trend, last_triggered_event_tier |
| PolicyState | policy_id, status (proposed, enacted, repealed), sponsor_faction, opposing_factions, legal_effects, enforcement_profile, expires_on_day |
| ManorCouncilState | advisor_trust_by_faction, influence_rankings, pending_proposals, recently_passed_policies |
| WorldState | time_of_day, day_index, alert_state_per_zone, event_flags |
| ReputationState | merchant, military, religious, scholar, underworld |
| QuestState | active_stage, completion_flags, branching_choice |

### Signals and events we should standardize

| Signal | Payload |
|---|---|
| event_witnessed | npc_id, event_type, severity, location, outcome (suspicion_delta or trust_delta) |
| rumor_spread | originating_npc_id, event_id, propagating_to_npc_ids, severity_class |
| individual_suspicion_changed | npc_id, current_value, delta, source, reason |
| individual_trust_changed | npc_id, current_value, delta, source, reason |
| faction_alert_changed | faction_id, alert_level, delta, aggregate_source |
| faction_action_witnessed | action_type, witness_npc_id, interpreted_faction, delta, cap_remaining |
| conformity_witnessed | action_type, witness_npc_id, zone, trust_impact |
| accuser_stage_changed | npc_id, old_stage, new_stage, trigger_reason |
| coalition_formed | leader_npc_id, member_npc_ids, faction_bias, declared_grievance |
| relationship_changed | npc_id, new_value, reason |
| day_started | day_index |
| faction_rep_changed | faction, delta, source |
| policy_proposed | policy_id, sponsor_faction, legal_effects, rationale |
| policy_enacted | policy_id, legal_effects, enforcement_profile, effective_day |
| policy_repealed | policy_id, repealed_by_faction, replacement_policy_id |
| legal_state_changed | zone_or_system, old_state, new_state, source_policy_id |
| advisor_influence_changed | faction_id, old_rank, new_rank, reason |

## Balancing metrics to define early

| Metric | Starting target | Notes |
|---|---|---|
| Time to first arrest (new player) | 2 to 5 minutes | Teaches danger quickly |
| Time to first friendship | 20 to 40 minutes | Keeps social loop meaningful |
| Time to unlock first arc | 45 to 90 minutes | Depends on route quality |
| Daily survival failure rate without shelter | 40 to 70 percent | Maintains pressure |
| Suspicion recovery time from 60 to 20 | 1 to 3 minutes | Must feel recoverable |
| Time from vocal accuser to vendetta (no intervention) | 1 to 2 in-game days | Must feel preventable |
| Coalition formation probability after vendetta | 30 to 50 percent | Depends on local faction alignment |

## Design decisions locked

Only the items in this section are locked constraints. Everything else in this document is adjustable through phase planning, spikes, and playtest-driven balancing.

1. **Phase 1 spawn location**: Fields. Safety unlocks as you progress the game; early phases spawn fields only.
2. **Suspicion meters**: Individual per-NPC tracking plus per-faction alert levels, both driven by witnessing and rumor propagation. Major events spread village-wide; minor infractions stay private.
2b. **Witnessing as core mechanic**: Each NPC remembers what they witness you do. Inappropriate behavior triggers individual suspicion; appropriate behavior (being in the right place, at the right time, doing the right thing) builds individual trust. Depending on event severity, NPCs may share rumors with others, creating second-hand reputation effects without direct witnessing.
3. **Failure states**: Arrest is recoverable (restart in fields with language learned); death is game over. High suspicion leads to arrest; very high suspicion leads to execution/murder and failure.
4. **Language persistence**: Language learning is permanent across deaths.
5. **Trust recovery**: Witnessed faction-offensive actions create recoverable trust damage, not permanent.
6. **Arc recovery**: All arcs are always accessible; investment in any arc affects the others through cross-arc reputation coupling.
7. **Shippable content**: All three career arcs (Merchant, Military, Religious) are part of the first shippable milestone. Scholar and Underworld follow in Phase 2.
8. **Combat**: No combat. Social and stealth-only resolution.
9. **Faction reputation**: Mostly independent with soft cross-arc penalties. Rising reputation in one arc has consequences elsewhere.
10. **Full-run target**: One complete ending should be achievable in 60–120 minutes for an efficient player; 180+ minutes for exploratory play.
11. **Shelter quality**: Quality scale (dangerous → unsafe → marginal → safe). Affects hunger recovery and social outcomes. No fatigue mechanic.
12. **Social-fit drivers**: All three — language mismatch, movement pattern violations, and transaction behavior anomalies all drive suspicion equally in Phase 1.
13. **Suspicion decay rule**: Active conformity required. Suspicion does not passively decay over time; it decays only through correct repeated behavior, successful gifting, vouching, and overnight survival.

## Context: Don Álvaro

**Don Álvaro de Calatrava** is a shrewd, well-educated minor noble who governs the manor with a merchant's pragmatism. He tolerates the cultural mixing in the village because it makes the area prosperous. He is neither kind nor cruel: he is transactional. The player is invisible to him until they become either useful or disruptive. He controls everything and everyone answers to him ultimately. He is the final gatekeeper for the merchant career path and a key faction endpoint. His steward, **Munir**, manages daily operations and is often the player's first point of contact at the manor.

## Suggested implementation order after answers

1. Finalize canonical state model and reset policy.
2. Ship individual NPC witnessing and suspicion/trust tracking as foundation.
3. Ship suspicion, stealth, arrest, and restart as a stable loop.
4. Ship faction-action witness interpretation and gifting formula with relationship persistence.
5. Ship day and night plus shelter outcomes.
6. Ship one faction arc as a vertical slice with one ending.
7. Expand into rumor propagation and cross-faction reputation effects.
8. Add manor policy governance loop (proposal, enactment, legal state updates, enforcement shifts).

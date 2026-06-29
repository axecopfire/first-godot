---
title: Game Design
description: Story graph, narrative phases, mechanics, and player controls for the medieval market survival game
ms.date: 2026-06-27
---

## Overview

You wake in an alley off a foreign town square market. No one speaks your language. Every moment you
spend failing to match expected local behavior raises suspicion. Get caught and you die. Learn to mimic
social norms, choose social-signaling actions, gift, befriend, and survive while navigating competing
institution expectations.

The hidden premise is that you are an AI learning to function among humans. The player should discover
this only near the end, but all mechanics should reinforce that learning arc from the start.

## Story Graph

```mermaid
flowchart TD
    subgraph START ["OPENING"]
        A[alley_awakening]
    end

    subgraph CORE ["CORE LOOP"]
        B[market_exploration]
        C[stealth_mode]
        D[institution_signal_action]
    end

    subgraph SUSPICION ["SUSPICION ESCALATION"]
        E[npcs_suspicious]
        F[being_followed]
        G[guard_alert]
    end

    subgraph PUNISHMENT ["PUNISHMENT"]
        H[prison]
        I[death]
    end

    subgraph SOCIAL ["GIFTING & FRIENDSHIP"]
        J[gift_attempt]
        K[gift_accepted]
        L[gift_rejected]
        M[befriended]
        N[vouched_for]
    end

    subgraph SURVIVAL ["SHELTER & SURVIVAL"]
        O[found_shelter]
        P[sleeping_streets]
        Q[caught_sleeping]
        R[survived_night]
        S[need_food]
    end

    subgraph INSTITUTION ["COMMUNITY TENSION"]
        T[institution_alignment_shift]
    end

    subgraph CAREERS ["CAREER BRANCHES"]
        U[merchant_path]
        V[military_path]
        W[religious_path]
        X[scholar_path]
    end

    A -->|stealth| C
    A -->|walk into market| B

    B <-->|crouch/stand| C
    B -->|act| D
    C -->|act| D
    C -->|return| A

    B -->|suspicion 35+| E
    C -->|spotted| E
    E -->|hide| C
    E -->|suspicion 60+| F
    F -->|suspicion 80+| G

    G -->|arrested| H
    H --> I
    I -->|restart| A

    D -->|offer gift| J
    D -->|witnessed by opposing institution| E
    D -->|continue| B
    D -->|hide| C
    D -->|institution trust 50+| T

    J -->|accepted| K
    J -->|rejected| L
    K -->|friendship 40+| M
    K -->|continue| B
    L -->|more suspicion| E

    M -->|vouch| N
    M -->|shelter offered| O
    N -->|continue eased| B

    O -->|sleep safe| R
    P -->|patrol catches| Q
    P -->|survive| R
    Q --> H
    R --> S
    S -->|search| B
    S -->|sneak| C

    T --> B

    M -.->|merchant guild| U
    T -.->|recruited| V
    M -.->|temple| W
    M -.->|scholar| X
```

## Narrative Phases

### Phase 1: First Contact (tutorial death)

The player walks openly into the market and is quickly noticed, followed, and arrested.
They restart in the alley. This teaches them to sneak.

```mermaid
flowchart TB
    A1[Wake in alley] --> A2{Walk or sneak?}
    A2 -->|walk openly| A3[Suspicion rises fast]
    A2 -->|hold Shift| A4[Stealth: suspicion decays]
    A3 --> A5[NPCs notice > follow > guard > prison > death]
    A5 --> A6[Restart in alley]
    A6 -.->|this time sneak| A2
```

### Phase 2: Signal and Interpret

Choose visible social actions to test institution reactions. The same action can improve trust with one
group and increase suspicion with another. Gifts remain a secondary repair and relationship tool.

```mermaid
flowchart TB
    B1[Choose action: study or pray] --> B2[Witness checks institution values]
    B2 --> B3{Who saw it?}
    B3 -->|Church witness study| B4[Church suspicion +5, cap +20]
    B3 -->|Academia witness study| B5[Academia trust +7]
    B3 -->|Church witness pray| B6[Church trust +7]
    B3 -->|Academia witness pray| B7[Academia suspicion +5, cap +20]
    B4 --> B8[Adjust access gates]
    B5 --> B8
    B6 --> B8
    B7 --> B8
```

### Phase 3: Friendship

Hit relationship 40 with an NPC and they befriend you. They vouch for you (suspicion -25).
If they are poor (poverty >= 0.6), they also offer shelter.

```mermaid
flowchart TB
    C1[Relationship >= 40] --> C2[Befriended]
    C2 --> C3[They vouch: suspicion -25]
    C2 --> C4{NPC poverty >= 0.6?}
    C4 -->|yes| C5[They offer shelter]
    C4 -->|no| C6[No shelter yet]
```

### Phase 4: Survival Loop

Day and night cycle of earning food through work, favors, and institution access while avoiding patrols.
Without shelter there is a 60% chance of arrest each night.

```mermaid
flowchart TB
    D1[Sleep?] --> D2{Have shelter?}
    D2 -->|yes| D3[Safe sleep: new day]
    D2 -->|no| D4[Sleep on streets]
    D4 -->|60% chance| D5[Guard catches you: prison]
    D4 -->|40% chance| D3
    D3 --> D6[Hunger: need food]
    D6 --> D7[Work, negotiate, or call in favors]
```

### Phase 5: Career Branches (placeholder)

Five branching story paths. Each is a separate narrative arc that needs full design.

```mermaid
flowchart TB
    E1[Criminal trust 50+] -.-> E2[Criminal Underworld]
    E3[Merchant trust 50+] -.-> E4[Merchant Guild]
    E5[Church trust 50+] -.-> E6[Religious Path]
    E7[Academia trust 50+] -.-> E8[Scholar Path]
    E9[Military trust 50+] -.-> E10[Military Recruitment]
```

| Branch | Trigger | Theme |
|--------|---------|-------|
| Merchant | Befriend the Merchant NPC | Trade, negotiation, wealth |
| Military | Military trust 50+ (guard captain recruits) | Discipline, order, honor |
| Religious | Church trust 50+ (priest offers sanctuary) | Faith, wisdom, devotion |
| Scholar | Academia trust 50+ (librarian notices language learning) | Knowledge, language, discovery |
| Underworld | Criminal trust 50+ (broker offers protection network) | Covert power, favors, risk |

## Mechanics

### Dual alert model (0 to 100)

The game tracks two connected pressure systems:

* Individual suspicion per NPC: who personally distrusts you.
* Community alert per institution: how organized that group is against you.

### Individual suspicion thresholds (per NPC)

| Threshold | Effect |
|-----------|--------|
| 0 | Socially passing |
| 35 | NPCs start following |
| 60 | Guard begins chase |
| 80 | Arrested |

### Community alert thresholds (per institution)

| Threshold | Effect |
|-----------|--------|
| 0 to 24 | Baseline monitoring |
| 25 to 44 | Increased gossip and witness checks |
| 45 to 64 | Community scrutiny events and spot questioning |
| 65 to 84 | Coordinated response, patrol density increases |
| 85 to 100 | Emergency doctrine, hard access restrictions |

### Persistent accuser escalation (Phase 3 unlock)

One NPC can become a recurring threat even when community alert temporarily cools.

| Stage | Trigger | Behavior |
|-------|---------|----------|
| Vocal accuser | NPC reaches 70+ suspicion twice in 3 days | Publicly reports your actions and amplifies rumors |
| Vendetta (Phase 3) | Same NPC reaches 80+ after an institution cooldown | Tails you, interprets ambiguous actions as hostile |
| Coalition builder (Phase 3) | Vendetta persists 2+ days | Recruits 2 to 4 NPCs into an anti-player group |

### Anti-loop recovery rules

To prevent unwinnable spirals, vendetta and coalition states require social resolution options:

* Two witnessed conformity successes reduce accuser strike count by 1.
* One trusted sponsor vouch removes coalition status if community alert is below 50.
* Public restitution event clears vendetta if witnessed by the accuser and one neutral NPC.
* Stealth can buy time but cannot fully clear vendetta on its own.

### Suspicion rate changes

| Event | Change |
|-------|--------|
| Visible in market without norm conformity | +1.5/sec |
| Stealthing (Shift) | -0.5/sec |
| Language mismatch near NPC | +8 |
| Contextual norm violation | +10 to +20 |
| Study witnessed by church NPC | +5 (church suspicion contribution capped at 20) |
| Study witnessed by academia NPC | +7 trust (academia) |
| Pray witnessed by church NPC | +7 trust (church) |
| Pray witnessed by academia NPC | +5 (academia suspicion contribution capped at 20) |
| Share heretical technology in public | +12 church suspicion (can exceed soft caps) |
| Friend vouches | -25 |
| Correct routine repeated | -5 |
| Survive a night | -10 |
| Gift rejected | +5 |
| Same accuser witnesses repeated mismatch | +10 accuser strike |
| Accuser reaches strike threshold | Escalates stage |
| Public restitution witnessed | -1 accuser stage |

### Authority gate thresholds

| Institution | Threshold | Effect |
|---------|-----------|--------|
| Church suspicion | 20 | Religious dialogue options reduced |
| Church suspicion | 50 | Church entry blocked |
| Church suspicion | 75 | Heretic flag; sanctuary denied |
| Academia trust | 20 | Basic study actions unlocked |
| Academia trust | 50 | Research actions unlocked |
| Military suspicion | 35 | Patrol follows player |
| Military suspicion | 60 | Forced detain checks |
| Criminal trust | 25 | Contraband errands unlocked |
| Criminal trust | 50 | Underworld contacts unlocked |

### Gift acceptance formula

```text
score = itemValue * (1 + need) + alignment_bonus - offense_memory_penalty
```

* score > 0: accepted, relationship increases by score, player learns foreign word
* score <= 0: rejected, suspicion +5

### NPC stats

| NPC | Morality | Poverty | Easy to gift? | Can shelter? |
|-----|----------|---------|---------------|--------------|
| Merchant | 0.3 | 0.1 | Easiest | No |
| Baker | 0.7 | 0.5 | Hard | No |
| Blacksmith | 0.5 | 0.3 | Medium | No |
| Herbalist | 0.6 | 0.7 | Medium | Yes |

### Item values

| Item | Value | Foreign word |
|------|-------|-------------|
| Bread | 10 | Khleb |
| Herb | 15 | Trava |
| Sword | 30 | Mech |
| Gold Coin | 40 | Zolota |

### Friendship

* Relationship >= 40: befriended
* Befriended + poverty >= 0.6: shelter offered
* Befriended: NPC vouches (suspicion -25)

## Controls

| Key | Action |
|-----|--------|
| WASD | Move |
| Shift (hold) | Stealth |
| E | Interact / advance dialogue |
| G | Give last item to nearest NPC |
| Q | Drop last item |
| R | Sleep (while standing still) |
| Tab | Toggle story graph debug viewer |

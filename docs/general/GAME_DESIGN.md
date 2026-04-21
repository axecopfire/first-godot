---
title: Game Design
description: Story graph, narrative phases, mechanics, and player controls for the medieval market survival game
ms.date: 2026-04-18
---

## Overview

You wake in an alley off a foreign town square market. No one speaks your language. Every moment you
spend visible in the market raises suspicion. Get caught and you die. Learn to steal, gift, befriend,
and survive, or rise through the criminal underworld.

## Story Graph

```mermaid
flowchart TD
    subgraph START ["OPENING"]
        A[alley_awakening]
    end

    subgraph CORE ["CORE LOOP"]
        B[market_exploration]
        C[stealth_mode]
        D[stole_item]
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

    subgraph CRIME ["CRIMINAL PATH"]
        T[criminal_rise]
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
    B -->|steal| D
    C -->|steal| D
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
    D -->|heat rises| E
    D -->|continue| B
    D -->|hide| C
    D -->|rep 50+| T

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

### Phase 2: Steal and Gift

Discover items on the ground. Picking them up spikes suspicion. Giving them to an NPC who
did not witness the theft may earn trust and a word in the foreign language.

```mermaid
flowchart TB
    B1[See item on ground] --> B2[Pick it up: suspicion spike]
    B2 --> B3{Give to NPC?}
    B3 -->|NPC saw you steal| B4[Rejected: more suspicion]
    B3 -->|NPC did not see| B5{Gift formula}
    B5 -->|score > 0| B6[Accepted: learn a word]
    B5 -->|score <= 0| B4
    B6 --> B7[Relationship increases]
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

Day/night cycle of stealing food, sleeping, and avoiding patrols.
Without shelter there is a 60% chance of arrest each night.

```mermaid
flowchart TB
    D1[Sleep?] --> D2{Have shelter?}
    D2 -->|yes| D3[Safe sleep: new day]
    D2 -->|no| D4[Sleep on streets]
    D4 -->|60% chance| D5[Guard catches you: prison]
    D4 -->|40% chance| D3
    D3 --> D6[Hunger: need food]
    D6 --> D7[Steal more or find work]
```

### Phase 5: Career Branches (placeholder)

Four branching story paths. Each is a separate narrative arc that needs full design.

```mermaid
flowchart TB
    E1[Criminal rep 50+] -.-> E2[Criminal Underworld]
    E3[Befriend Merchant] -.-> E4[Merchant Guild]
    E5[Befriend anyone] -.-> E6[Religious Path]
    E5 -.-> E7[Scholar Path]
    E1 -.-> E8[Military Recruitment]
```

| Branch | Trigger | Theme |
|--------|---------|-------|
| Merchant | Befriend the Merchant NPC | Trade, negotiation, wealth |
| Military | Criminal rep 50+ (guard captain recruits) | Discipline, combat, honor |
| Religious | Befriend any NPC (priest offers sanctuary) | Faith, wisdom, devotion |
| Scholar | Befriend any NPC (librarian notices language learning) | Knowledge, language, discovery |

## Mechanics

### Suspicion meter (0 to 100)

| Threshold | Effect |
|-----------|--------|
| 0 | Safe |
| 35 | NPCs start following |
| 60 | Guard begins chase |
| 80 | Arrested |

### Suspicion rate changes

| Event | Change |
|-------|--------|
| Visible in market | +1.5/sec |
| Stealthing (Shift) | -0.5/sec |
| Steal unseen | +15 |
| Steal witnessed | +30 |
| Friend vouches | -25 |
| Survive a night | -10 |
| Gift rejected | +5 |

### Gift acceptance formula

```text
score = itemValue * (1 + poverty) - morality * stolenCount * 5
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

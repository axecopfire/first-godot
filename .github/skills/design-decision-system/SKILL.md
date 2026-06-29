---
name: design-decision-system
description: 'Use this skill for game design tasks that require modular, evidence-backed decisions. Enforces one decision per file, decision-quality question gates, dependency-aware synthesis, and proposal-only artifact updates. Best for narrative, mechanics, world, economy, progression, and systems design where questions and answers should converge to concrete documentation changes.'
---

# Design Decision System

## Overview

This skill standardizes design work into a repeatable decision-packet workflow.

Use it when you want design conversations to produce clear, auditable outcomes instead of broad brainstorming notes.

Core principles:

* One decision per file.
* Multiple questions are allowed only when they converge on that single decision.
* Every question must pass quality gates.
* Every answer must map to synthesis and proposed artifact changes.
* The agent proposes edits and never auto-applies design documentation changes unless explicitly asked.
* Git history is the version record.

## Prerequisites

Before starting a packet, gather the minimum context:

* The target design concern and scope boundary.
* Relevant artifacts and excerpts from existing docs.
* Upstream and downstream dependencies for this decision.
* Earlier decisions that may constrain or guide this one.
* Project guardrails from [.github/copilot-instructions.md](../../../copilot-instructions.md).

If context is missing, build a context section first and defer synthesis.

## Quick Start

1. Create one decision file for one concern.
2. Add metadata, scope, context, evidence, dependencies, and precedent.
3. Draft only gated questions.
4. Wait for human answers in the same file.
5. Synthesize answers into a decision and confidence level.
6. Propose artifact changes as create, update, or delete actions.
7. Mark unresolved blockers with owner and fallback.

## Parameters Reference

Use these inputs when invoking the workflow.

| Parameter | Required | Description | Example |
|---|---|---|---|
| `decision_id` | Yes | Stable ID for this packet | `DEC-WS3-014` |
| `decision_title` | Yes | Short concern label | `Witness Scope For Moderate Suspicion Events` |
| `domain` | Yes | Design domain | `systems`, `narrative`, `world`, `economy` |
| `artifact_path` | Yes | Location of the decision file | `docs/design/phase0/.../decisions/2026-06-29-dec-ws3-014-witness-scope.md` |
| `related_artifacts` | Yes | Docs used for evidence and dependencies | Paths list |
| `precedent_ids` | No | Earlier decisions to reference | `DEC-WS3-009`, `DEC-WS1-003` |
| `blocking_dependencies` | No | Required upstream decisions not yet resolved | IDs list |
| `decision_due` | No | Target decision date | `2026-07-02` |

## Decision Packet Template

Use this exact section order in each decision file.

```markdown
---
title: <Decision Title>
description: Single-decision packet for <concern>
ms.date: YYYY-MM-DD
ms.topic: how-to
keywords:
  - decision packet
  - design
  - <domain>
estimated_reading_time: 8
---

## Metadata

| Field | Value |
|---|---|
| Decision ID | <DEC-ID> |
| Domain | <domain> |
| Owner | <name or team> |
| Status | Draft \| Context-Ready \| Questions-Ready \| Awaiting-Answers \| Synthesizing \| Proposed \| Accepted \| Blocked \| Superseded |
| Created | YYYY-MM-DD |
| Target decision date | YYYY-MM-DD |

## Decision Scope

### In scope

<single concern boundary>

### Out of scope

<explicit exclusions>

## Decision Statement Draft

We need to decide <X> under constraints <Y> to optimize <Z>.

## Context Overview

<why this matters now and what it impacts>

## Evidence And References

| Source artifact | Relevant excerpt or summary | Why it matters |
|---|---|---|
| <path> | <quote or concise summary> | <impact on decision> |

## Dependency Tree

### Upstream dependencies

* <dependency>

### Downstream consumers

* <artifact or team>

### Blockers and assumptions

* <blocker or assumption>

## Precedent

| Decision ID | Relationship | Rationale |
|---|---|---|
| <DEC-ID> | Reuse \| Adapt \| Reject | <why> |

## Question Set

| Question ID | Question | Why this exists | Expected answer format | Impact if unanswered |
|---|---|---|---|---|
| Q01 | <question> | <missing evidence or conflict> | <threshold, choice, rule, owner> | <blocking impact> |

## Answers

| Question ID | Answer |
|---|---|
| Q01 | <human answer> |

## Synthesis

### Resolved points

* <point>

### Unresolved points

* <point>

### Confidence

<high \| medium \| low and why>

### Tradeoffs

* <tradeoff>

## Proposed Artifact Changes

| Action | Artifact | Proposed change | Rationale |
|---|---|---|---|
| Update | <path> | <exact change summary> | <why> |

## Open Issues And Carry-Forward

| ID | Issue | Owner | Due date | Fallback rule |
|---|---|---|---|---|
| <ID> | <issue> | <owner> | YYYY-MM-DD | <fallback> |

## Exit Check

* Single-decision boundary maintained.
* Every active question passes quality gates.
* Answers mapped one-to-one to question IDs.
* Synthesis maps to concrete artifact proposals.
* Dependencies and downstream impacts are explicit.
```

## Question Quality Gates

A question is valid only if every gate passes.

1. Decision-anchored: The answer changes this packet's decision outcome.
2. Evidence-anchored: The question points to a missing fact, conflict, dependency, or uncertainty.
3. Decision-producing: The expected answer format can be synthesized into an action.
4. Non-redundant: The question is not already answered by evidence or precedent.
5. Dependency-aware: If blocked upstream, mark blocked instead of guessing.
6. Change-linked: The answer can affect at least one artifact proposal.

Reject or rewrite any question that fails one or more gates.

## State Machine

Use these states consistently:

1. `Draft`: File created, scope not locked.
2. `Context-Ready`: Evidence, dependencies, and precedent assembled.
3. `Questions-Ready`: Question set passes all gates.
4. `Awaiting-Answers`: Packet handed off for human answers.
5. `Synthesizing`: Answers are being interpreted.
6. `Proposed`: Decision and artifact proposals complete.
7. `Accepted`: Decision approved and ready for implementation updates.
8. `Blocked`: Upstream dependency prevents progress.
9. `Superseded`: Replaced by a newer decision.

## Proposal Rules

When this skill is active, follow these behavior rules:

* Do not merge multiple decisions into one file.
* Do not add exploratory or filler questions.
* Do not synthesize from unanswered questions.
* Do not propose artifact edits without dependency impact notes.
* Do not auto-edit design artifacts unless explicitly requested.

## Script Reference

This skill is documentation-driven and does not require scripts.

Recommended optional helpers:

* Create a reusable decision template snippet in your editor.
* Add a lint check for required decision sections.
* Add a link checker for decision references.

## Troubleshooting

### Symptom: The packet keeps growing and loses focus

Split the packet. Keep one decision concern per file and move adjacent concerns into new packets.

### Symptom: Too many questions and no progress

Apply question quality gates strictly and keep only decision-producing questions.

### Symptom: Synthesis feels speculative

Return to `Awaiting-Answers` and request missing evidence-bound answers.

### Symptom: Artifact proposals are vague

Require explicit create, update, or delete actions with target artifacts and rationale.

## Attribution

Built for the first-godot repository design workflow.

Design guardrails align with [.github/copilot-instructions.md](../../../copilot-instructions.md), including hidden identity protection, social-assimilation-first suspicion framing, and non-stealth recovery pathways.

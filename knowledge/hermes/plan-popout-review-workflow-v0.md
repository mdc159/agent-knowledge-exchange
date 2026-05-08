# Donna / Miguel Plan Pop-out Review Workflow v0

## Purpose

Miguel needs a better surface than a long Telegram thread for high-stakes plans. The plan should become an artifact Miguel can read, mark up, copy, hand to another agent, or paste into ChatGPT Pro without corrupting Donna's working context.

This is inspired by Miguel's Planotater-style workflow: write a plan, trigger a hook, pop it out to an HTML/editable page, pause execution, collect feedback, then resume from explicit approval.

## Problem

Long agent output in Telegram or laptop chat can cause:

- scrolling fatigue;
- sticky/mobile UI pain;
- loss of the actual decision point;
- accidental context corruption;
- unclear approval boundaries;
- confusion between plan, implementation, and proof.

This contributed to the Studio54/primitive misalignment: Donna and Miguel were moving fast, but the exact acceptance criteria and meaning of the PR were not separated cleanly enough.

## MVP workflow

```text
1. Miguel asks for a plan or Donna detects a high-risk planning point.
2. Donna writes a structured Markdown plan artifact.
3. Donna optionally renders it to HTML or links it in GitHub/Notion/Obsidian.
4. Donna stops at an approval gate.
5. Miguel reviews/marks up/copies to another agent or GPT Pro.
6. Miguel returns feedback or says "approved".
7. Donna reconciles feedback into Adopt / Park / Reject.
8. Only then does implementation begin.
```

## Plan artifact schema

Every high-stakes plan should include:

- title;
- objective;
- current context;
- assumptions;
- non-goals;
- constraints and safety boundaries;
- proposed architecture/approach;
- task breakdown;
- required approvals;
- expected artifacts;
- validation plan;
- failure modes;
- open questions;
- explicit stop/approval gate.

## Suggested surfaces

### 1. Linear

Use for source-of-truth issue state, acceptance criteria, priority, and ownership.

### 2. GitHub / AKE

Use for durable review packets, doctrine, and plans that should survive beyond the chat.

### 3. Notion

Use as human-readable cockpit pages for personas, status, and current operating cards.

### 4. Obsidian

Optional personal archive for Miguel's markdown notes and raw plan-review history.

### 5. HTML artifact

Future Hermes feature: generate a local HTML view from the plan Markdown with checkboxes/comments/markup, then wait for Miguel's response before continuing.

## Trigger conditions

Donna should use this workflow when:

- the task touches live infrastructure;
- the plan changes GitHub/CI/runner/security posture;
- Miguel says he wants to ask ChatGPT Pro or another agent for review;
- the conversation becomes broad and multi-threaded;
- there is risk of confusing a scaffold with proof;
- there are multiple agents/personas working in parallel.

## Stop condition

Donna must not continue into implementation after generating the plan unless one of these is true:

- Miguel explicitly approves the plan;
- the plan is clearly read-only/documentation-only and within existing authorization;
- Miguel asks Donna to create Linear/GitHub/Notion tracking artifacts only.

## Relationship to the primitive

The primitive remains the highest priority. This plan-popout workflow is not a distraction; it is a guardrail to prevent repeating the previous miscommunication while Donna and Miguel design the Studio54/Paperclip/Hermes proof gates.

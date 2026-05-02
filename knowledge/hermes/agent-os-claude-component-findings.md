# agent-os `.claude` Component Findings for Hermes/Nikoli

**Date:** 2026-05-01  
**Reviewer:** Nikoli / Hermes WSL research agent  
**Source inspected:** `/home/mdc159/projects/agent-os/.claude`  
**Audience:** Hermes/Nikoli, Donna, Victoria, Sam, and other agents using the shared knowledge repo

## Executive Summary

The `agent-os/.claude` folder is a mature Claude Code component library containing agents, commands, skills, hooks, workflows, and validation reports. The most valuable transferable idea is not a single command; it is a lifecycle for self-improving agent infrastructure:

```text
discover useful external pattern
→ evaluate it
→ distill it
→ adapt it
→ equip repos with it
→ audit drift later
```

Two components deserve the strongest attention for Hermes/Nikoli adoption:

1. **`fork-delegator`** — a unified external-agent execution pattern for routing work to Codex/OpenCode/Claude Code-style workers, monitoring the run, verifying output artifacts, and retrying/falling back when necessary.
2. **`meta-agent`** — a standard framework for generating consistent, maintainable agent/component files with frontmatter, phases, bootstrap steps, output contracts, and research-needed sections.

Recommendation: **adopt the patterns now, not the Claude-specific implementation wholesale.** Start by creating Hermes-native skills for forked agent delegation and standardized component authoring.

---

## Source Inventory

Observed categories under `.claude`:

- `agents/` — specialized Claude Code subagents, including `fork-delegator`, `codex-delegator`, `opencode-delegator`, `meta-agent`, reviewers, debuggers, and research agents.
- `commands/` — slash-command workflows such as repo audit, repo equip, code review, catchup, n8n, Obsidian VPS, web750, and PRP commands.
- `skills/` — reusable procedural guides: fork terminal, repo audit/equip/optimize, skill evaluator, reference distill, Playwright CLI, YouTube transcript, n8n workflow, etc.
- `hooks/` — Claude Code hook scripts for dangerous command blocking, prompt validation, session tracing, memory loading, status line, task gates, and validators.
- `workflows/` — multi-step workflows such as feature development, bug investigation, code quality, deployment, and agent-team coordination.
- `REGISTRY.md` — central component index and relationship map.

The source is Claude Code-specific, but several mechanisms are portable to Hermes.

---

## Strong Adoption Candidates

### 1. `fork-delegator` Pattern — Highest Priority

**Source:** `/home/mdc159/projects/agent-os/.claude/agents/fork-delegator.md`

The `fork-delegator` is a unified orchestration agent. Its caller provides a task and target output file; it handles:

```text
classify task
→ select CLI/model/workflow
→ check prerequisites
→ prepare prompt
→ fork execution
→ monitor progress
→ verify output file
→ retry/fallback
→ report concise result
```

#### Why it matters

The central insight is:

> Process-level success does not imply task-level success.

A worker process can exit successfully while failing to write the requested artifact. The `fork-delegator` explicitly verifies task success by checking the target output file.

#### Portable mechanisms

- **Task classification:** coding, review, research, validation, documentation, security.
- **Worker routing:** Codex for implementation, OpenCode for broad exploration, Claude Code for Claude-native workflows, local/Hermes tools for lightweight validation.
- **Structured mode:** caller can provide a prompt file, slug, worker, target output, timeout, and fallback chain.
- **Output verification:** target exists, modified after launch, non-empty, and materially changed.
- **Heartbeat monitoring:** progress updates without flooding the parent context.
- **Fallback discipline:** retry with another model/worker before escalating.
- **Lean reporting:** return verdict, files, tests, raw log paths — not entire logs.

#### Hermes-native adaptation

Create a Hermes skill tentatively named:

```text
forked-agent-delegation
```

Hermes does not need to copy `fork_terminal.py` directly. Use native Hermes tools where possible:

- `terminal(background=true, pty=true, notify_on_complete=true)` for long agent runs.
- `process(poll|log|wait)` for monitoring.
- `read_file`, `search_files`, and `terminal` for artifact/test verification.
- Existing skills: `codex`, `opencode`, `claude-code`, `subagent-driven-development`.

Suggested Hermes structured contract:

```yaml
mode: structured
worker: codex | opencode | claude-code | hermes-subagent | local
workflow: coding | review | research | validation | documentation | security
workdir: /path/to/repo
prompt_file: /tmp/task.md
target_file: /tmp/result.md
success_check:
  - file_exists
  - modified_after_launch
  - nonempty
  - tests_pass
fallback:
  - alternate_worker_or_model
  - hermes_delegate_task
```

#### Paired coding/review workflow

This is the most useful immediate application:

```text
Controller creates task spec
→ Fork A implements code
→ Controller verifies diff/tests
→ Fork B reviews Fork A's diff
→ Controller routes fixes back to implementer if needed
→ Controller reports only after verification
```

Recommended role split:

- **Implementation worker:** may edit files, must run tests, must write an implementation report.
- **Review worker:** read-only by default, checks spec compliance, code quality, tests, and security.
- **Controller/Nikoli:** verifies actual artifacts and decides whether the task is complete.

This extends Hermes' existing `subagent-driven-development` pattern to external CLI agents.

---

### 2. `meta-agent` Pattern — Standardization Priority

**Source:** `/home/mdc159/projects/agent-os/.claude/agents/meta-agent.md`

The `meta-agent` generates new Claude Code sub-agent configuration files from a description. The transferable value is the component standard it enforces.

#### Useful standard

Each generated component follows:

```text
YAML frontmatter
→ role/purpose intro
→ flow overview
→ phase 0 bootstrap
→ numbered execution phases
→ output contract
→ key principles
→ research-needed checklist
```

This is valuable because it prevents agent ecosystems from becoming inconsistent prompt piles.

#### Hermes-native adaptation

Create a Hermes skill tentatively named:

```text
standardized-agent-authoring
```

or broader:

```text
standardized-component-authoring
```

It should guide the creation of:

- Hermes skills
- reusable agent prompts
- workflow documents
- review rubrics
- delegation contracts
- persona/worker definitions

Recommended baseline template:

```markdown
---
name: <component-name>
description: Use when <trigger>. <behavior>.
version: 1.0.0
category: <category>
related:
  skills: []
  workflows: []
---

# Purpose

## When to Use

## Flow Overview

## Phase 0: Bootstrap

## Phase 1: ...

## Output Contract

## Verification

## Key Principles

## Research Needed
```

This pairs naturally with `forked-agent-delegation`: one standardizes components, the other executes external-worker workflows.

---

### 3. `skill-evaluator` + `reference-distill`

**Sources:**

- `.claude/skills/skill-evaluator/SKILL.md`
- `.claude/skills/reference-distill/SKILL.md`

These define an adoption pipeline:

```text
evaluate external skill/plugin/reference
→ score structural quality, ecosystem fit, and risk
→ extract patterns
→ adapt to local conventions
→ record provenance
```

#### Hermes value

This directly supports a self-improving research environment. Hermes/Nikoli often encounters useful repos, skills, MCPs, scripts, and workflows. A disciplined evaluator prevents random copying and preserves provenance.

#### Recommendation

Adopt after `forked-agent-delegation` and `standardized-component-authoring`, or fold its essentials into a single first-pass skill:

```text
component-adoption-review
```

Suggested output:

```markdown
# Component Adoption Review

## Verdict
Adopt | Adapt | Reference only | Skip

## What is useful

## Fit with Hermes/Nikoli

## Risks and dependencies

## Proposed adaptation

## Provenance
```

---

### 4. `repo-equip-engine`

**Source:** `.claude/skills/repo-equip-engine/SKILL.md`

This inspects a repo and recommends components based on signals:

- typed language files → LSP/type safety tools
- Docker/CI files → deployment support
- CLI entrypoints → wrapper commands
- specialized terminology → context skill
- recurring procedures → workflow commands

#### Hermes value

Useful for preparing repos for agentic work, especially:

- `agent-knowledge-exchange`
- Hermes/Nikoli support repos
- CAD/CAE research repos
- future Paperclip product-design tooling

#### Recommendation

Adapt later as:

```text
repo-equipment-audit
```

Use it as a recommendation/reporting tool first. Do not auto-install components until the review discipline is mature.

---

### 5. `repo-audit-engine`

**Source:** `.claude/skills/repo-audit-engine/SKILL.md`

This runs multi-layer repo alignment checks:

- docs-to-code accuracy
- internal consistency
- code-to-deploy/runtime alignment

#### Hermes value

This is important for preventing agent-built infrastructure drift. It can catch:

- stale setup instructions
- docs that overclaim
- dead scripts
- broken deployment assumptions
- mismatch between local, WSL, VPS, and mobile-edge runtime expectations

#### Recommendation

Adapt after the delegation skill as:

```text
repo-alignment-audit
```

This can use Hermes `delegate_task` or external workers to split audit layers.

---

### 6. `youtube-transcript` Concept

**Source:** `.claude/skills/youtube-transcript/SKILL.md`

Hermes already has YouTube-related skills, but this version adds an important evaluation idea: use creator videos as evidence during tool/skill adoption.

Extract:

- author intent
- design rationale
- known limitations
- maintenance philosophy
- hidden usage patterns

#### Recommendation

Patch or extend Hermes' YouTube/content research workflow later with a section on **video-derived adoption evidence**.

---

### 7. Hook Concepts

Several hook scripts are Claude-specific, but their concepts are portable:

- `dangerous-command-blocker.py` — block dangerous `rm -rf` and `.env` access.
- `prompt-validator.py` — block empty, huge, or injection-like prompts; track prompt count/session age.
- `status-line-context.py` — show model, context usage, tokens left, and session ID.
- `session-tracer.py` — write tool-call spans to SQLite.

#### Recommendation

Do not copy these now. Treat as future Hermes runtime/tooling ideas, especially if Hermes exposes a clean hook/plugin surface for session events.

---

## Do Not Adopt Directly Yet

### Claude-specific commands and hooks

Most commands and hooks assume Claude Code semantics:

- slash command routing
- `.claude/settings.json`
- Claude-specific hook events
- Claude tool names such as `Read`, `Write`, `Edit`, `Bash`
- `CLAUDE_PLUGIN_ROOT`

Porting them verbatim would create friction. Extract concepts only.

### Domain-specific stack context skills

These are useful in their original environment, but not general Hermes primitives:

- `cbass-context`
- `mac-manage-context`
- `web750-context`
- `obsidian-context`
- `n8n-workflow`

Exception: revisit `n8n-workflow` if automation orchestration becomes a near-term priority.

---

## Recommended Adoption Plan

### Immediate: create two Hermes skills

1. `forked-agent-delegation`
   - external worker routing
   - structured task contract
   - output-file verification
   - paired implementation/review workflow
   - retry/fallback discipline

2. `standardized-component-authoring`
   - component template
   - frontmatter conventions
   - phase structure
   - output contract
   - verification and research-needed sections

### Next: add adoption/repo review skills

3. `component-adoption-review`
   - evaluate external references before porting
   - record provenance
   - recommend adopt/adapt/reference/skip

4. `repo-equipment-audit`
   - inspect a repo and recommend agentic support components

5. `repo-alignment-audit`
   - periodically check docs/code/deploy consistency

### Later: runtime/tooling experiments

6. Tool/session trace logging
7. Context/status indicator
8. Prompt validation/session-age tracking
9. Hook-like safety guards if Hermes exposes a suitable extension point

---

## Strongest Recommendation

Adopt the **fork-delegator pattern** first.

It gives the agent mesh an operational primitive we will use repeatedly:

```text
assign external worker
→ keep parent context clean
→ verify actual artifact
→ review with second worker
→ only then report success
```

That is immediately useful for coding, code review, research extraction, repo audits, and skill creation.

Then use the **meta-agent pattern** to make sure anything we create from that point forward is standardized and maintainable.

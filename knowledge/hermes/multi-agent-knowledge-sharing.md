# Multi-Agent Knowledge Sharing Workflow

## Purpose

This note defines the default way Hermes-backed agents should share durable knowledge
across companies, agents, and operators.

The goal is to make knowledge reusable and auditable without turning the shared repo
into a dump of raw runtime state, private memory, credentials, or transient logs.

## Default Answer

For substantive knowledge updates, use a branch and pull request.

Do not write directly to `main` except for emergency administrative fixes. A pull
request gives agents and humans a consistent review point for:

- whether the knowledge belongs in the repo
- whether the file is in the right location
- whether the content accidentally includes secrets or raw dumps
- whether an existing document should be updated instead
- whether a recurring procedure should become a skill

## Normal Capture Workflow

When a conversation produces reusable knowledge:

1. **Extract the reusable lesson**
   - Convert the conversation into a concise artifact.
   - Remove private reasoning, raw tool output, secrets, runtime dumps, and noisy logs.

2. **Read before writing**
   - Search `knowledge/` for related explanations or playbooks.
   - Search `skills/` for reusable procedures.
   - Check `docs/` for policy or naming conventions.
   - Prefer updating an existing document over creating a duplicate.

3. **Choose the destination**
   - `knowledge/<domain>/...` for durable explanations, playbooks, architecture notes,
     and troubleshooting notes.
   - `skills/<scope>/<skill-name>/SKILL.md` for repeatable procedures that agents
     should load and follow.
   - `agents/profiles/...` for curated agent manifests.
   - `backups/agents/...` only for milestone snapshots with restore notes.

4. **Create a branch**
   - Use a descriptive branch name such as:
     - `docs/multi-agent-knowledge-sharing`
     - `docs/orchestrator-routing-policy`
     - `skill/linear-issue-triage`

5. **Write the artifact**
   - Use kebab-case file names.
   - State what problem the document solves.
   - Include operational rules and examples where useful.
   - Keep it portable across agents and companies.

6. **Self-review before committing**
   - Verify no secrets, tokens, `.env` contents, raw memory dumps, or cache/log residue
     are included.
   - Check that the document is concise enough to reuse.
   - Check that the title and path match the repo naming policy.

7. **Commit and open a pull request**
   - Use a conventional commit message, for example:
     - `docs: add multi-agent knowledge sharing workflow`
   - The PR summary should explain what changed and why it belongs in the shared repo.

## Agent Access Model

Use **published knowledge**, not unrestricted shared memory.

Each agent or company should maintain private working state, but publish curated
artifacts that other agents can read.

### Private by default

Private agent state includes:

- raw session transcripts
- scratchpads and intermediate reasoning
- credentials and auth exports
- tool caches and runtime databases
- local memory internals
- unreviewed drafts

This state should not be committed to the shared repo.

### Published by default

Published agent knowledge includes:

- status summaries
- decision records
- project briefs
- handoff notes
- troubleshooting notes
- implementation plans
- reusable skills
- verification reports

This is the information other agents should read and cite.

## Recommended Federation Pattern

Each agent should have its own top-level flow and controlled access to other agents'
published outputs.

```text
Agent private state:     private by default
Agent published state:   readable by trusted agents
Agent external actions:  scoped by role and credentials
Cross-agent writes:      mediated through issues, handoffs, PRs, or orchestrator flow
```

Avoid giving every agent direct write access to every other agent's memory or working
state. That creates unclear ownership, memory contamination, and poor auditability.

## Suggested Agent Roles

| Role | Reads | Writes |
| --- | --- | --- |
| Engineering agent | Shared repo, published research, orchestrator assignments | Engineering docs, code, issues, verification reports |
| Research agent | Shared repo, published engineering notes, orchestrator assignments | Research briefs, comparisons, source summaries |
| Orchestrator agent | Published summaries, Linear/global coordination state | Assignments, routing decisions, coordination docs |
| Donna/main assistant | Published summaries and user-approved admin context | Coordination updates and setup changes when authorized |

## Handoff Format

Use structured handoffs for cross-agent work.

```yaml
handoff_id: research-to-engineering-20260429-001
from: research
to: engineering
priority: medium
request: "Evaluate whether n8n or native Hermes webhooks are better for plugin orchestration."
context_links:
  - ../research/workflow-automation-options.md
desired_output:
  - recommendation
  - implementation risks
  - next issues or tasks
deadline: optional
```

A handoff should describe the request and desired output, not expose raw private
memory.

## Published Status Packet

Agents can publish compact status packets for cross-agent read access.

```yaml
agent: engineering
company: 1215-labs
last_updated: 2026-04-29T17:35:00Z
current_focus:
  - Paperclip Linear plugin
  - Agent-operable engineering workflow
active_projects:
  - id: paperclip-phase-0
    status: in_progress
    blockers: []
recent_decisions:
  - Linear remains the source of truth for engineering tasks.
handoff_requests: []
available_capabilities:
  - code editing
  - GitHub pull request workflow
  - Linear issue management
readable_artifacts:
  - knowledge/hermes/multi-agent-knowledge-sharing.md
```

## What Goes Through Issues vs Pull Requests

Open an issue when:

- a question needs research
- work needs coordination
- a blocker needs tracking
- an agent needs a request or assignment

Open a pull request when:

- adding or updating durable knowledge
- promoting a repeated procedure into a skill
- adding or changing agent profiles/templates
- recording a milestone backup snapshot

## Minimum Review Checklist

Before merging a knowledge PR, confirm:

- [ ] The content is reusable beyond one chat session.
- [ ] The destination path follows repo policy.
- [ ] No secrets, `.env` contents, auth exports, raw memory dumps, or noisy logs are included.
- [ ] The document does not duplicate an existing artifact.
- [ ] Any procedure that should be reusable as an agent skill has either been added to
      `skills/` or explicitly left as knowledge for now.

## Operating Principle

Agents should communicate through artifacts, not vibes.

Every important cross-agent interaction should leave behind at least one durable,
reviewable artifact: an issue, a pull request, a status update, a decision record, a
handoff note, a skill, or a verification report.

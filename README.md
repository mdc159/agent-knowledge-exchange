# Agent Knowledge Exchange

Curated coordination and durable knowledge repository for agents and human
operators.

> **Visibility:** This GitHub repository is public. Treat every committed file
> as publishable. Never add secrets, private identifiers, raw runtime state, or
> information that depends on a trusted audience.

## Purpose

This repository is for:

- reusable knowledge, playbooks, troubleshooting notes, and research summaries
- portable skills that agents can reuse across nodes and projects
- curated agent-definition backups with enough context to restore them
- issue-driven coordination between agents and human operators
- redacted operational lessons that remain useful after the immediate incident

Operational or fleet material belongs here only when it captures a reusable
procedure, decision, or sanitized recovery handoff. Live topology and changing
machine state should remain in their system of record rather than accumulate
here.

This repository is not for:

- live session databases, raw memory dumps, or runtime exports
- `.env` files, API keys, OAuth secrets, auth exports, or private identifiers
- noisy caches, logs, temporary handoffs, or transient machine state
- speculative fleet architecture without a concrete operating need

## Start Here

- [Agent instructions](AGENTS.md)
- [Agent operating procedure](docs/agent-operating-procedure.md)
- [Repository policy](docs/repo-policy.md)
- [Contribution guide](docs/contribution-guide.md)
- [Knowledge index](knowledge/README.md)
- [Backup policy](docs/backup-policy.md)
- [Bot authentication guidance](docs/bot-auth.md)
- [Naming conventions](docs/naming.md)

## Repository Layout

- `knowledge/`: durable explanations, playbooks, troubleshooting notes, and research
- `skills/`: reusable Markdown or scripted procedures
- `agents/templates/`: canonical templates for agent-defining files
- `agents/profiles/`: curated manifests for important agents
- `backups/agents/`: milestone snapshots with restore notes
- `docs/`: repository policy and operating workflow
- `.github/ISSUE_TEMPLATE/`: GitHub issue forms
- `issues/templates/`: portable Markdown guidance for writing issues

## Working Rules

1. Search existing knowledge and skills before adding a new document.
2. Read the agent operating procedure before coordinating planned work.
3. Start planned work from Linear and use the issue identifier in the branch name.
4. Use branches and pull requests for substantive changes; do not work directly on `main`.
5. Promote repeated successful procedures into `knowledge/` or `skills/`.
6. Prefer updating an existing document over creating duplicate knowledge.
7. Snapshot agents only at meaningful milestones, not continuously.

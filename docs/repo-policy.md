# Repository Policy

## Purpose

This repo is the shared exchange for:

- durable operational knowledge
- portable skills
- curated agent-definition backups
- issue and PR based coordination

It is intentionally narrow. If content is not reusable, auditable, or restorable,
it probably does not belong here.

## What Belongs Here

- playbooks
- postmortems
- research summaries
- troubleshooting notes
- curated skill definitions
- agent manifests and templates
- milestone backup snapshots
- restore notes

## What Must Never Be Committed

- `.env` files
- API keys or OAuth tokens
- provider auth exports
- raw session databases
- raw memory dumps as the default operating model
- full cache trees
- large transient logs
- anything whose only value is machine residue

## Contribution Rules

1. Open issues for questions, coordination, and requests.
2. Make substantive changes on a branch.
3. Merge through pull requests, not direct pushes to `main`.
4. Prefer updating an existing doc over creating duplicate knowledge.
5. If a procedure repeats and works, promote it into a skill or knowledge doc.

## Backup Rules

- snapshot on milestones, not continuously
- include only the files needed to reconstruct the agent definition and the
  reasoning needed to restore it
- accompany every backup snapshot with restore notes
- if a snapshot cannot be safely shared, summarize it instead of committing it

## Review Standard

Every addition should be easy to answer:

- what problem does this solve?
- who will reuse it?
- why is this in version control instead of live runtime state?

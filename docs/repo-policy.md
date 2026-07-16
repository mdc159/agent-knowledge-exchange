# Repository Policy

## Purpose

This repo is the shared exchange for:

- durable operational knowledge
- portable skills
- generic agent-definition templates
- issue and PR based coordination
- agent-operable GitHub and Linear workflow standards

It is intentionally narrow. If content is not reusable, auditable, or restorable,
it probably does not belong here.

## What Belongs Here

- playbooks
- postmortems
- research summaries
- troubleshooting notes
- curated skill definitions
- generic agent templates
- sanitized restore patterns

## What Must Never Be Committed

- `.env` files
- API keys or OAuth tokens
- provider auth exports
- raw session databases
- raw memory dumps as the default operating model
- full cache trees
- large transient logs
- anything whose only value is machine residue
- fleet inventories, node manifests, access maps, or live handoffs
- named operator or agent profiles and milestone snapshots

## Contribution Rules

1. Open issues for questions, coordination, and requests.
2. Make substantive changes on a branch.
3. Merge through pull requests, not direct pushes to `main`.
4. Prefer updating an existing doc over creating duplicate knowledge.
5. If a procedure repeats and works, promote it into a skill or knowledge doc.
6. Follow `docs/agent-operating-procedure.md` for planned agent work.

## Backup Guidance

- keep real snapshots in a private system
- publish only generic backup and restore patterns
- replace real identities, addresses, and paths with fictional examples
- summarize the reusable lesson instead of committing runtime state

## Review Standard

Every addition should be easy to answer:

- what problem does this solve?
- who will reuse it?
- why is this in version control instead of live runtime state?
- what Linear issue or operating need does it close?
- what validation was performed?

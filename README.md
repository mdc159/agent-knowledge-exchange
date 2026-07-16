# Agent Knowledge Exchange

Public library of reusable agent skills, research, templates, policies, and
sanitized operating lessons.

Everything in this repository must be safe to share publicly. Examples must use
fictional identities and reserved example networks. Fleet inventories, real
machine names, tailnet details, credentials, access paths, live handoffs, and
operator-specific runtime state belong in private or local systems instead.

## Start here

- [Repository policy](docs/repo-policy.md)
- [Contribution guide](docs/contribution-guide.md)
- [Knowledge index](knowledge/README.md)
- [Agent operating procedure](docs/agent-operating-procedure.md)
- [Reusable skills](skills/)
- [Agent templates](agents/templates/)

## Repository layout

- `knowledge/`: reusable research, patterns, and sanitized troubleshooting
- `skills/`: portable Markdown or scripted procedures
- `agents/templates/`: generic agent-definition templates
- `docs/`: public contribution, security, naming, and workflow policy
- `issues/templates/`: portable issue-writing guidance

## Public boundary

Do not commit:

- secrets, authentication material, private keys, or environment exports
- real tailnet names or addresses, public management addresses, or SSH aliases
- fleet inventories, node manifests, access maps, or current service state
- named operator/agent profiles, backups, memory dumps, or session databases
- raw prompts, logs, transcripts, caches, or temporary handoffs

Promote the reusable lesson, not the private operating evidence.


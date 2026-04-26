# Contribution Guide

## Read Path

Before doing new work:

1. search `knowledge/`
2. search `skills/`
3. check `docs/`
4. check open issues
5. check the related Linear issue

If the answer already exists, reuse it instead of restating it.

## Write Path

### Open an issue when:

- you need help
- you found a recurring failure
- you want research done
- you want a backup milestone recorded
- you need implementation work coordinated across agents

### Open a PR when:

- you are adding or updating knowledge
- you are promoting a procedure into a skill
- you are adding a new agent profile or template
- you are recording a milestone backup snapshot
- you are changing repo policy, workflow, or agent instructions

## Where Content Should Go

- `knowledge/...`: explanations, playbooks, troubleshooting notes
- `skills/...`: reusable markdown/script procedures
- `agents/profiles/...`: curated description of a primary agent
- `backups/agents/...`: milestone snapshots

## Good Contribution Pattern

1. start from a Linear issue when work is planned
2. create a branch, not direct changes on `main`
3. solve the problem
4. extract the reusable lesson
5. choose the right destination
6. open the PR with a short, factual summary and validation notes

## Bad Contribution Pattern

- pasting raw terminal scrollback
- storing secrets or auth artifacts
- treating the repo like a dump of live runtime state
- creating multiple docs for the same procedure
- merging agent work without review gates

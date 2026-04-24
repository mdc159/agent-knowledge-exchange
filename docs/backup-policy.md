# Backup Policy

## Goal

Backups in this repo are for restoring agent definition and operator intent,
not for mirroring every byte of runtime state.

## When To Snapshot

Take a milestone snapshot:

- before risky experimentation
- after major persona or config changes
- after a stable, known-good setup
- before replacing a model, adapter, or memory layout

## What To Include

Usually include:

- `SOUL.md`
- `AGENTS.md` or equivalent instruction file
- `config.yaml`
- `honcho.json`
- model/provider notes
- curated memory summary
- restore notes

## What To Exclude

Do not commit:

- `.env`
- API keys
- provider auth exports
- raw session DBs
- raw logs
- caches
- temporary scratch files

## Snapshot Layout

Use:

`backups/agents/<agent-name>/<YYYY-MM-DD>-<milestone>/`

Each snapshot should contain at least:

- copied or normalized defining files
- `restore-notes.md`
- `summary.md`

## Restore Standard

Another operator should be able to answer:

- what files define this agent?
- what model/provider did it use?
- what memory/backend assumptions existed?
- what must be recreated outside git?

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A docs-only coordination repo for trusted agents and human operators. Everything is markdown — no build, no test runner, no application code. Work happens through Linear issues, branches, PRs, and review.

If a change does not produce reusable, auditable, or restorable knowledge, it likely does not belong here. See `docs/repo-policy.md`.

## Workflow — defer to AGENTS.md

`AGENTS.md` and `docs/agent-operating-procedure.md` are the canonical source for the Linear → branch → PR → review → merge workflow. **Read them before substantive work.** Don't restate their rules — follow them.

The non-negotiables to keep top-of-mind every turn:

- **Linear is the source of truth for planned work.** Start from an issue when work is planned. Refine vague issues before implementing.
- **Never push to `main`.** Branch for everything substantive.
- Branch naming: `121-123-short-slug` when a Linear issue exists, `ops-short-slug` when not yet.
- PR title: `[121-123] Short outcome`. Link the Linear issue in title or description; move the issue to `In Review` when the PR opens.
- **Never merge your own PR.** **Never apply the `automerge` label** — only a human operator does that.
- Stop in one of three states: PR opened with validation notes, draft PR with blockers listed, or a no-code status comment explaining why the issue cannot proceed.

## Hard rules — never commit

- `.env` files, API keys, OAuth tokens, provider auth exports
- raw session DBs, raw memory dumps, full caches, large logs
- transient runtime state of any kind

`.gitignore` blocks the obvious cases. The rule still applies to anything pasted into a markdown file.

## Read before write

Before adding new content (per `docs/contribution-guide.md`):

1. `knowledge/` — playbooks, troubleshooting, research summaries
2. `skills/` — reusable procedures
3. `docs/` — repo-level policy
4. open issues
5. the related Linear issue

If the answer already exists, **update the existing doc** instead of creating a parallel one. Duplicate knowledge is the failure mode this repo is built to avoid.

## Where things go

| Content type | Path |
|---|---|
| Durable knowledge (playbooks, postmortems, research) | `knowledge/<domain>/<topic>.md` |
| Reusable procedures | `skills/<scope>/<skill-name>/SKILL.md` |
| Curated agent manifest | `agents/profiles/<agent-name>.md` |
| Canonical agent-defining file templates | `agents/templates/` |
| Milestone agent snapshot | `backups/agents/<agent-name>/<YYYY-MM-DD>-<milestone>/` |
| Issue-writing guidance (mirrored under `.github/ISSUE_TEMPLATE/`) | `issues/templates/` |
| Repo policy / process | `docs/` |

`<scope>` under `skills/` is `shared/` (cross-company) or a specific domain (`paperclip/`, `hermes/`). Match the existing pattern.

## Naming and labels

See `docs/naming.md` for the full list. Use `kebab-case` for files and skill folders, `YYYY-MM-DD-short-milestone` for backup directories. Pick labels from the existing vocabulary — workflow labels (`agent-work`, `copilot`, `codex`, `low-risk`, `automerge`, `no-automerge`, etc.) have specific meanings in `docs/agent-operating-procedure.md`. Don't invent new ones casually.

## Backups have a strict shape

Per `docs/backup-policy.md`, snapshot only on milestones (before risky experiments, after stable known-good setups, before swapping models/adapters/memory layouts). Each snapshot directory contains:

- copied/normalized defining files (`SOUL.md`, `AGENTS.md`, `config.yaml`, `honcho.json`, model/provider notes, curated memory summary)
- `restore-notes.md`
- `summary.md`

A snapshot that cannot be safely shared should be **summarized** instead of committed. See `backups/agents/big-hermes/2026-04-24-initial-profile/` as the working example.

## Architectural concept that recurs

Several docs assume the **outer Hermes vs inner Hermes** distinction (`knowledge/hermes/outer-vs-inner-hermes.md`):

- **Outer Hermes** — host-native, machine-level, cross-company, carries long-horizon operator memory.
- **Inner Hermes** — invoked through Paperclip adapters, scoped to one company, uses company-local runtime homes.
- **Paperclip owns company state.** Outer Hermes may supervise or initialize companies but should not mutate company state around Paperclip.

Many skills and agent profiles only make sense under this two-layer model — keep it in mind when reading or editing them.

## Promotion rule

If you solve a problem and find yourself doing the same procedure twice, **promote it** into `knowledge/` or `skills/` rather than letting it live in chat or issue threads. That promotion *is* the contribution.

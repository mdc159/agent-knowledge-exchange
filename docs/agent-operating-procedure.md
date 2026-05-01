# Agent-Operable GitHub + Linear Workflow

## Purpose

This is the standard operating procedure for coordinating human operators,
local agents, cloud agents, GitHub Copilot, Linear, GitHub, and Vercel.

Linear is the source of truth for planned work. GitHub is the code, review,
and audit system. Vercel is the preview and production deployment system for
web projects.

## Default Flow

```text
Linear issue -> branch -> agent work -> GitHub PR -> validation/review/preview -> merge -> Linear Done
```

## Systems of Record

- Linear: issue state, priority, acceptance criteria, and ownership.
- GitHub: branches, commits, pull requests, reviews, checks, and merge history.
- Vercel: preview deployments for PRs and production deploys from `main`.
- This repo: durable playbooks, knowledge, templates, and agent instructions.

## Linear States

Use the `121` Linear team workflow this way:

- `Backlog`: unaccepted ideas, rough requests, and parking lot items.
- `Todo`: accepted work with enough detail to start.
- `In Progress`: an agent or human is actively working on a branch.
- `In Review`: a GitHub PR is open.
- `Done`: the PR is merged or the work is intentionally completed without code.
- `Canceled` or `Duplicate`: the work should not proceed.

## Issue Requirements

Every planned work item should have:

- a clear outcome
- acceptance criteria
- constraints or exclusions
- target repo, if known
- preferred agent/tool, if known
- links to prior docs, issues, PRs, or research

Do not start implementation from a vague issue. Refine it first.

## Branches

Use branches for all substantive work.

Preferred branch format:

```text
121-123-short-slug
```

If there is no Linear issue yet, use:

```text
ops-short-slug
```

Create the Linear issue before the work becomes more than exploratory.

## Pull Requests

Open a PR for every substantive change. Draft PRs are encouraged for work that
needs early visibility or feedback.

PR title format:

```text
[121-123] Short outcome
```

Every PR must include:

- linked Linear issue, or a reason no issue exists
- what changed
- why it changed
- validation performed
- operational risks
- follow-up work
- confirmation that no secrets or raw runtime state were added

## Review Rules

Required before merge:

- relevant validation commands pass
- PR template is complete
- Copilot review is requested when available
- human review is complete for risky changes
- Vercel preview is checked for website changes

Agents may respond to review comments and push fixes to the same branch.

## Auto-Merge Policy

Agents may suggest auto-merge, but only a human operator may apply the
`automerge` label.

Auto-merge is allowed only when all of these are true:

- PR is labeled `low-risk`
- PR is labeled `automerge`
- required checks pass
- no reviewer has requested changes
- the PR does not touch sensitive systems

The repository auto-merge workflow only enables GitHub auto-merge when
`low-risk` and `automerge` are both present and `no-automerge` is absent.
GitHub branch protection and repository auto-merge must also be available for
the repo. If GitHub plan or visibility restrictions block those controls, treat
auto-merge as disabled and merge manually after review.

Never auto-merge changes involving:

- secrets or auth
- billing
- deployment credentials or production infrastructure
- database migrations
- broad refactors
- dependency upgrades
- agent permission expansion

Use `no-automerge` when a PR must be manually merged even if it looks small.

## Agent Roles

- Human operator: final authority for merge policy and production risk.
- Local/cloud coding agents: implement scoped issues and open PRs.
- GitHub Copilot coding agent: handles well-scoped GitHub tasks and PR updates.
- Copilot review: provides review feedback, but does not replace human judgment.
- Vercel: provides PR previews and production deployment from `main`.

## Vercel Rules

For website repos:

- connect the GitHub repo to Vercel
- use `main` as the production branch unless documented otherwise
- require preview verification before merging user-facing changes
- include the preview URL in the PR
- do not expose production secrets to untrusted fork PRs

## Codespaces Rules

Use a light standard first:

- each repo should document local setup
- add `.devcontainer` only when setup is repeated, fragile, or useful for cloud agents
- prefer repo scripts over hidden manual steps

## Labels

Use these labels consistently:

- `agent-work`: agent-authored or agent-assisted implementation
- `copilot`: GitHub Copilot was used for implementation or review
- `codex`: Codex was used for implementation or review
- `human-review`: explicit human review needed
- `blocked`: work cannot proceed without a decision or dependency
- `needs-preview`: Vercel or UI preview must be checked
- `low-risk`: docs, tests, metadata, or small non-production change
- `automerge`: human-approved auto-merge candidate
- `no-automerge`: must be manually merged

## Completion Checklist

Before marking work complete:

- PR is merged or closed with a clear reason
- Linear issue is moved to `Done`, `Canceled`, or `Duplicate`
- follow-up work is captured as new Linear issues
- durable knowledge is added to `knowledge/` or `docs/` when applicable

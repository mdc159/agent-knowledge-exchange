# Branch and PR Consolidation Playbook

This repository is knowledge-first, so reducing branch and PR sprawl is useful.
However, **do not squash everything into one long-lived branch** without triage.

## Short answer

Yes — you can get to a single clean branch (`main`) as the source of truth, but the
safe process is:

1. Triage open issues and PRs.
2. Close stale or duplicate work explicitly.
3. Merge only validated, scoped branches through PRs.
4. Archive decisions in docs/issues.
5. Delete merged/stale branches.

## Why not force-merge everything?

Blindly merging all pending branches can:

- reintroduce conflicting edits
- merge abandoned experiments as if they were approved
- break trust in issue and PR history
- violate workflow expectations in `docs/agent-operating-procedure.md`

## Recommended consolidation workflow

### 1) Stabilize intake

- Freeze new work temporarily (except urgent fixes).
- Label currently open items (`keep`, `close`, `needs-update`, `blocked`).

### 2) Audit all open PRs

For each PR:

- Confirm linked issue and acceptance criteria.
- Rebase/merge from latest `main`.
- Run repository validation checks.
- Merge only if still relevant.
- Close with a clear reason when not relevant.

### 3) Audit open issues

- Convert vague issues into clear outcomes or close them.
- Deduplicate overlapping requests.
- Move work without active owners back to `Todo` or `Backlog`.

### 4) Clean branch inventory

- Keep active branches tied to in-progress issues.
- Delete merged branches immediately.
- Delete stale branches after confirming no unique committed work is needed.

### 5) Preserve knowledge before closing anything

For closed PRs/issues with useful context, move durable notes into `knowledge/` or
`docs/` and link back to source discussions.

## Operational guardrails

- Keep `main` as the single clean integration branch.
- Continue using short-lived issue branches for all new changes.
- Require PR-based merges and validation checks.
- Use labels consistently (`blocked`, `low-risk`, `no-automerge`, etc.).

## Suggested cadence

- Weekly: stale branch + PR review.
- Biweekly: issue dedupe and closure sweep.
- Monthly: process review and template cleanup.

## Definition of "clean"

A clean repo state usually means:

- `main` reflects approved current knowledge.
- Open PRs are only active, reviewable work.
- Branches map to real in-progress issues.
- Closed work has explicit reasons and no ambiguity.

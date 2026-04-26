# Agent Operating Instructions

This repository uses the standard 1215 agent workflow. Read
`docs/agent-operating-procedure.md` before doing substantive work.

## Required Workflow

1. Start from a Linear issue whenever work is planned.
2. Do not work directly on `main`.
3. Use a branch named from the Linear issue when one exists, for example
   `121-123-short-slug`.
4. Keep changes reviewable and scoped to the issue.
5. Open a GitHub pull request for substantive changes.
6. Link the Linear issue in the PR title or description.
7. Move the Linear issue to `In Review` when the PR is open.
8. Do not merge unless repo policy and GitHub protections explicitly allow it.

## Agent Boundaries

Agents may:

- inspect issues, docs, and prior knowledge
- create branches, commits, and pull requests
- run validation commands
- suggest labels, reviewers, and follow-up issues
- update PR descriptions and comments with status

Agents must not:

- commit secrets, auth exports, raw session databases, or transient caches
- push directly to `main`
- merge their own PRs unless explicitly authorized by repository rules
- apply the `automerge` label without human approval
- treat unresolved TODOs as complete work

## Stop Condition

Before stopping, leave the work in one of these states:

- PR opened with validation notes
- draft PR opened with blockers listed
- no-code status comment explaining why the issue cannot proceed

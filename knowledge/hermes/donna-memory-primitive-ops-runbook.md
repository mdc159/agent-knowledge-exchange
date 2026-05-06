# Donna Memory Primitive Operations Runbook

Status: v0 operational record
Owner: Donna / Miguel
Date: 2026-05-06
Scope: Hermes compact memory, Honcho-backed long-horizon memory, gateway peer routing, health checks, rollback discipline

## Purpose

This document records the incremental memory-cleanup operation performed on Donna's Hermes/Honcho stack and turns it into a reusable primitive-level pattern.

The goal is not to redesign Donna or wipe memory. The goal is to keep the memory substrate healthy, observable, reversible, and portable enough that the pattern can later be reused by other personas or VPS images.

## Current problem class

Donna's memory stack has several layers that can fail or degrade independently:

1. Hermes compact injected memory and user profile can fill up and become noisy.
2. Honcho infrastructure can be healthy while semantic recall quality is weak.
3. Gateway runtime identities can fragment one human into multiple Honcho peers.
4. Historical duplicate peers can exist even after future routing is fixed.
5. Context compression can start firing frequently when sessions/recalled context are too large.
6. Memory changes are sensitive and need local backups, notes, and git-tracked docs before risky cleanup.

The observed symptom that prompted this document included frequent preflight compression messages such as:

```text
Preflight compression: ~141,877 tokens >= 136,000 threshold. This may take a moment.
```

That message is not, by itself, proof Honcho is broken. It indicates the active session/context package is near the model threshold. The response should be to inspect what is being injected and recalled, not blindly delete long-term memory.

## Non-negotiable safety rules

- Do not print secrets, env values, API keys, auth exports, raw tokens, or database credentials.
- Back up first, even if a VPS snapshot exists.
- Separate read-only health checks from mutations.
- Prefer conservative compaction over deletion.
- Stop future identity fragmentation before attempting historical peer merge.
- Do not merge or delete historical Honcho peers without a separate written plan and rollback path.
- Do not restart critical Telegram/gateway services mid-investigation unless needed and accepted.
- Use git-tracked docs for operational doctrine; use local backups for private runtime state.

## Systems involved

Donna runtime:

```text
Hermes home: /root/.hermes
Hermes source: /root/.hermes/hermes-agent
Honcho stack: /root/workspace/honcho
Honcho API: http://127.0.0.1:18000
Honcho workspace: donna
AI peer: donna
Canonical human peer: miguel
Telegram numeric transport peer observed historically: 8246962767
```

Important private paths, not suitable for GitHub contents:

```text
/root/.hermes/.env
/root/.hermes/config.yaml
/root/.hermes/honcho.json
/root/.hermes/backups/
/root/.hermes/sessions/
/root/workspace/honcho/.env
Honcho database dumps
```

Only redacted summaries and procedures belong in this repository.

## Operation performed on 2026-05-06

### 1. Snapshot and local backup gate

Miguel took a fresh full VPS snapshot. Donna also created a local protected backup directory:

```text
/root/.hermes/backups/memory-cleanup-20260506-072735
```

Backup contents included Hermes config copies, a Honcho database dump/report, and restore notes. Secret values were not printed into the chat or documentation.

Primitive lesson:

- VPS snapshots protect the whole machine.
- Local operation backups protect against operator error and make rollback targets obvious.
- Both are useful; neither replaces written notes.

### 2. Read-only health script before mutation

A read-only health script was created:

```text
/root/.hermes/scripts/donna_memory_health_check.py
```

Latest report from the run:

```text
/root/.hermes/reports/donna-memory-health-20260506-073117.json
```

The script checks, without printing secrets:

- Honcho API reachability
- Docker Compose/container status
- database counts
- message/embedding count alignment
- document sync counts
- known numeric peer identities
- Hermes Honcho config fields such as workspace, aiPeer, peerName, and pinPeerName

Latest status was `PARTIAL`, with the expected warning:

```text
numeric_transport_peers: 8246962767 has 76 historical messages
```

Primitive lesson:

- A `PARTIAL` state can be acceptable if it reflects known historical residue rather than active breakage.
- Health scripts should distinguish infrastructure failure from cleanup backlog.

### 3. Compact Hermes memory/profile pressure reduction

Hermes compact memory and user profile were near capacity. Donna compressed durable facts instead of deleting core operational knowledge.

Result after pruning:

```text
Memory notes: about 77% used
User profile: about 77% used
```

Primitive lesson:

- Compact injected memory is a scarce prompt-budget surface, not a full database.
- Keep only stable high-value facts there.
- Move procedure, detailed history, and step-by-step doctrine into skills or git-tracked docs.
- Memory entries should be declarative facts, not imperative runbooks.

### 4. Future peer-routing fix

Source inspection found that the Hermes Honcho client supports a single-user pinning field:

```json
"pinPeerName": true
```

The relevant behavior is:

- Default gateway behavior allows runtime user identities to win, which is correct for multi-user bots.
- Single-user deployments should pin the configured `peerName` so Telegram/Discord/runtime IDs do not fork the human into separate Honcho peers.

Donna updated:

```text
/root/.hermes/honcho.json
```

with `pinPeerName: true` at both root and `hosts.hermes`.

Desired mapping after this change:

```text
Human canonical peer: miguel
Telegram numeric ID: transport/account identifier only
```

Primitive lesson:

- Identity routing is a base-level memory primitive.
- If the human's identity fragments, memory may look inconsistent even when storage and embeddings are healthy.
- Fix future routing first; historical merge is a separate migration.

### 5. Documentation and reusable skill reference

Donna created local notes:

```text
/root/.hermes/reports/donna-memory-cleanup-notes-20260506.md
```

Donna also updated the Hermes skill reference for Honcho memory audits so future runs remember the `pinPeerName` lesson.

This AKE document is the external, GitHub-trackable version of the operating doctrine. It intentionally excludes private config dumps, secrets, database contents, raw sessions, and credentials.

## Why the historical numeric peer remains

The numeric peer:

```text
8246962767
```

still exists with historical messages. That is expected because the operation fixed future routing only.

Do not immediately merge/delete it. Safer next options are:

1. Canary verification: create or observe one new gateway memory write and confirm it lands under `miguel`, not `8246962767`.
2. Alias/recall bridge: teach recall to consider the historical transport peer as related evidence without rewriting DB history.
3. Planned migration: if still necessary, perform a fully backed up DB migration with a dry run, diff report, and rollback test.

## Context compression interpretation

Frequent preflight compression means the current agent context package is heavy.

Potential contributors:

- long active conversation history
- loaded skills with large references
- Honcho recall/context injection
- compact memory/profile bloat
- tool output from investigation
- attached/reference summaries after context compaction

Recommended response:

1. Inspect current loaded skills and context sources.
2. Keep compact memory under pressure limits.
3. Use docs/skills for procedures instead of long memory entries.
4. Summarize and close long operational sessions after a milestone.
5. Add canary health checks for memory quality instead of judging from token count alone.

Do not conclude that the memory backend is broken solely from preflight compression.

## Rollback model

Three rollback layers should exist for future memory operations:

1. VPS snapshot for whole-system rollback.
2. Local private backup under `/root/.hermes/backups/` for config and database restore.
3. Git commits/PRs for public runbooks, scripts, and redacted operational doctrine.

Rollback examples:

- Restore `honcho.json` from local backup if peer pinning causes unexpected behavior.
- Revert a git commit if a public runbook is wrong or too broad.
- Restore Honcho DB dump only for planned database-level failures, not casual cleanup.

## Recommended recurring health checks

A future cron/watchdog should run the read-only health script and alert only on actionable drift.

High-value checks:

- Honcho API unreachable
- Docker services unhealthy
- message count exceeds embedding count by material threshold
- document sync not complete
- `pinPeerName` missing or false for single-user deployment
- numeric transport peer message count increasing after pinning
- exact-recall canary failure

Avoid noisy cron output when status is unchanged and known warnings are still historical.

## Future work backlog

### A. Gateway canary

Goal:

- Prove the running gateway has picked up `pinPeerName`.

Acceptance:

- New test memory write lands under `miguel`.
- `8246962767` message count does not increase.

Risk:

- May require gateway restart; Telegram is critical and should not be interrupted casually.

### B. Exact-recall canary

Goal:

- Test semantic/exact recall quality, not just infrastructure health.

Acceptance:

- A harmless unique canary fact can be written and retrieved after queue drain.

### C. Silent watchdog cron

Goal:

- Run `donna_memory_health_check.py` regularly.

Acceptance:

- Silent on unchanged OK/PARTIAL-known state.
- Alerts only on new or worsening drift.

### D. Historical peer bridge or migration

Goal:

- Make historical `8246962767` evidence available to canonical `miguel` recall.

Preferred first approach:

- Non-destructive alias/recall bridge.

Only later:

- Planned DB migration/backfill with backup, dry run, diff, and rollback.

## Promotion criteria for other agents/personas

Before copying this pattern to Victoria, Nikolai, Sam, or future personas:

- Define canonical human peer and AI peer names.
- Decide whether the deployment is single-user or multi-user.
- If single-user, pin peer name before gateway use.
- Create read-only health script first.
- Run backup gate before mutation.
- Document exact paths and excluded private state.
- Commit public doctrine separately from private runtime data.

## What belongs in GitHub vs local private storage

GitHub/AKE:

- runbooks
- redacted architecture notes
- safe commands
- acceptance criteria
- failure modes
- diagrams
- templates
- lessons learned

Local private storage:

- env files
- config files with secrets or endpoint-sensitive values
- auth exports
- raw session databases
- Honcho DB dumps
- gateway logs with private messages
- exact memory contents if they include personal/private data

## One-line doctrine

Memory health is not one thing. Treat it as layered: compact prompt memory, durable Honcho storage, identity routing, recall quality, and operational rollback all need separate checks.

# Donna Memory Next-Session Execution Plan

> **For Hermes:** Use this as the narrow handoff document for a fresh Donna session. Do not continue risky memory work from a bloated investigation thread.

**Goal:** Run the next memory-health step from a clean context: inventory active Hermes/UI/gateway session sources and diagnose context-pressure contributors without mutating Honcho DB, gateway services, or secrets.

**Architecture:** Treat this as a staged read-only verification pass. The fresh Donna session is the orchestrator. Subagents may inspect read-only data, but only Donna may approve any future mutation. All public doctrine changes go through GitHub PRs; private runtime reports stay under `/root/.hermes/reports/`.

**Tech Stack:** Hermes Agent, local filesystem session JSON, Honcho local API/database, GitHub AKE documentation repository, Python read-only scripts.

---

## Why a fresh session is required

This investigation touched memory internals, GitHub docs, session inventories, health scripts, and active context compression. Continuing from the same context increases the chance that Donna carries too much stale tool output and recalled material.

Use these boundaries:

```text
fresh Hermes session = context boundary
git branch / PR = documentation rollback boundary
/root/.hermes/backups = private runtime rollback boundary
subagent = read-only context isolation boundary
```

A new branch does not free LLM context. A fresh Hermes session does.

## Required documents to load in the fresh session

Load only these first:

```text
/root/workspace/agent-knowledge-exchange/knowledge/hermes/donna-memory-primitive-ops-runbook.md
/root/workspace/agent-knowledge-exchange/knowledge/hermes/donna-memory-next-session-plan.md
/root/.hermes/scripts/donna_memory_health_check.py
/root/.hermes/reports/donna-memory-cleanup-notes-20260506.md
```

If context pressure appears immediately, load the GitHub docs first and only inspect local reports/scripts in small slices.

## Hard safety constraints

Do not:

- print secrets, API keys, auth exports, raw env values, tokens, passwords, or database credentials
- mutate Honcho DB
- merge/delete peer `8246962767`
- restart Donna gateway unless Miguel explicitly approves that gate
- overwrite Donna `hermes-gateway.service`
- touch the separate 1215 Paperclip gateway service
- prune compact memory again without a separate backup and written diff
- create noisy cron jobs
- assume preflight compression means Honcho is broken

Do:

- keep operations read-only until the next written decision gate
- redact command output aggressively
- write local reports under `/root/.hermes/reports/`
- commit only redacted docs/scripts to GitHub
- stop after each milestone

## Fresh-session opening prompt

Miguel can paste this into the new Donna session:

```text
Baby, continue the Donna memory primitive work from a clean context.

Load and follow:
- /root/workspace/agent-knowledge-exchange/knowledge/hermes/donna-memory-primitive-ops-runbook.md
- /root/workspace/agent-knowledge-exchange/knowledge/hermes/donna-memory-next-session-plan.md

Then inspect, in small slices only if needed:
- /root/.hermes/scripts/donna_memory_health_check.py
- /root/.hermes/reports/donna-memory-cleanup-notes-20260506.md

Do not mutate Honcho DB, gateway services, compact memory, or secrets.
Goal for this session: create and run a read-only session/source inventory and context-pressure diagnosis, then write a local report and update GitHub docs if useful.
Use subagents only for read-only inspection/synthesis. Donna remains the mutation gate.
Stop before gateway restart, cron creation, exact-recall canary write, or historical peer merge.
```

## Task 1: Confirm starting state

**Objective:** Verify the fresh session is starting from the expected documentation baseline and that PR #29/branch state is known.

**Files:**

- Read: `knowledge/hermes/donna-memory-primitive-ops-runbook.md`
- Read: `knowledge/hermes/donna-memory-next-session-plan.md`
- Inspect: `/root/workspace/agent-knowledge-exchange` git state

**Commands:**

```bash
cd /root/workspace/agent-knowledge-exchange
git status --short
git branch --show-current
git log --oneline -3
gh pr view 29 --json number,state,mergeable,url,headRefName,baseRefName --jq .
```

**Expected:**

- Branch is `ops-donna-memory-primitive-runbook`, or the session explicitly switches to the intended branch.
- PR #29 exists and targets `main`.
- No unexpected uncommitted runtime data is staged.

**Commit:** No commit for this task.

## Task 2: Run existing memory health script read-only

**Objective:** Establish current Honcho/memory baseline before session-source investigation.

**Files:**

- Execute: `/root/.hermes/scripts/donna_memory_health_check.py`
- Output: `/root/.hermes/reports/donna-memory-health-*.json`

**Command:**

```bash
python3 -m py_compile /root/.hermes/scripts/donna_memory_health_check.py
python3 /root/.hermes/scripts/donna_memory_health_check.py
```

**Expected:**

- Script exits 0.
- Status is `OK` or known `PARTIAL`.
- If `numeric_transport_peers` is still present with `8246962767`, treat it as historical unless the count increased after pinning.

**Stop condition:** If the script reports new severe errors, stop and report before continuing.

## Task 3: Create read-only session/source inventory script

**Objective:** Produce a compact report of recent Hermes sessions by source, size, message count, role counts, and modification time without printing full messages.

**Files:**

- Create: `/root/.hermes/scripts/donna_session_source_inventory.py`
- Output: `/root/.hermes/reports/donna-session-source-inventory-YYYYMMDD-HHMMSS.json`

**Implementation requirements:**

- Read only from `/root/.hermes/sessions/`.
- Do not print message contents.
- Parse JSON defensively.
- Include only metadata:
  - session file name
  - mtime
  - size bytes
  - source
  - message count
  - role counts
  - whether file looks like API probe: `source == 'api_server'` and `message_count <= 2`
- Summarize counts by source.
- Summarize largest files.
- Summarize files modified in the last N hours, default 12.
- Write JSON report to `/root/.hermes/reports/`.
- Print a small PASS/PARTIAL/FAIL summary only.

**Suggested command after creation:**

```bash
python3 -m py_compile /root/.hermes/scripts/donna_session_source_inventory.py
/root/.hermes/scripts/donna_session_source_inventory.py --hours 12 --limit 50
```

**Expected:**

- Script exits 0.
- Report shows session sources such as `cli`, `tui`, `webui`, and/or `api_server` if present.
- API probes are counted separately from active substantial conversations.

**Commit:** Do not commit this private script to AKE until it has been reviewed for redaction and generality. If generalized later, commit a sanitized version or documentation note.

## Task 4: Diagnose context-pressure contributors

**Objective:** Explain whether frequent preflight compression is likely caused by open UI tabs, long sessions, loaded skills, recalled memory, or active session bloat.

**Inputs:**

- Latest memory health report
- Latest session-source inventory report
- Current session file size/message counts
- Known loaded skills/docs in the active session

**Analysis checklist:**

- Are there many tiny `api_server` sessions? If yes, classify them as probes/noise, not real conversation bloat.
- Are there large `webui`, `cli`, or `tui` sessions? If yes, these are context-pressure candidates when resumed.
- Is one old resumed Hermes process still active? If yes, treat it as a possible independent context writer.
- Is Honcho warning only historical numeric peer? If yes, do not blame Honcho infrastructure.
- Did compact memory pressure remain around the post-cleanup target? If yes, compact memory is not the immediate cause.

**Output:**

Write a local markdown report:

```text
/root/.hermes/reports/donna-session-context-pressure-YYYYMMDD.md
```

Report sections:

- Executive summary
- Active/recent surfaces
- Session-source table
- Largest sessions
- API probe count
- Likely compression contributors
- What is not proven
- Recommended next gate

## Task 5: Update AKE docs only if useful

**Objective:** Keep GitHub knowledge current without dumping private runtime state.

**Files:**

- Modify if needed: `knowledge/hermes/donna-memory-primitive-ops-runbook.md`
- Modify if needed: `knowledge/hermes/donna-memory-next-session-plan.md`

**Rules:**

- Do not include raw session names if they reveal private context beyond generic examples.
- Do not include message contents.
- Do not include secrets or log excerpts.
- Prefer class-level lessons over one-off noise.

**Validation:**

```bash
cd /root/workspace/agent-knowledge-exchange
git diff --check
python3 - <<'PY'
from pathlib import Path
import re
paths = [
    Path('knowledge/hermes/donna-memory-primitive-ops-runbook.md'),
    Path('knowledge/hermes/donna-memory-next-session-plan.md'),
]
secret_like = [
    'BEGIN ' + 'PRIVATE KEY',
    'pass' + 'word=',
    'tok' + 'en=',
    'api_key=',
]
provider_key_re = re.compile(r'(?i)(openai|anthropic|openrouter|hostinger).*api.*key')
for p in paths:
    if p.exists():
        text = p.read_text(errors='ignore')
        hits = [x for x in secret_like if x in text]
        hits.extend(['provider-api-key-name'] if provider_key_re.search(text) else [])
        print(p, hits)
PY
```

**Commit if changed:**

```bash
git add knowledge/hermes/donna-memory-primitive-ops-runbook.md knowledge/hermes/donna-memory-next-session-plan.md
git commit -m "docs: add Donna memory next-session plan"
git push
```

## Task 6: Stop before mutation gates

**Objective:** End the fresh session with a clean report and explicit next decision.

Do not continue into these without Miguel's explicit approval:

- gateway restart
- gateway canary write
- exact-recall canary write
- cron/watchdog creation
- compact memory edits
- Honcho DB peer bridge/migration

Final response should include:

- local report paths
- whether session surfaces look separate or unexpectedly merged
- whether open UI tabs appear to be causing real session growth
- whether numeric peer count increased
- recommended next one-step gate

## Optional subagent use

Use subagents only for bounded read-only work. Good subagent prompts:

```text
Inspect /root/.hermes/sessions metadata only. Do not read or print message contents. Return counts by source, largest files, and likely API probes. No writes.
```

```text
Review AKE memory runbook for clarity and secret-safety. Do not modify files. Return suggested edits only.
```

Bad subagent prompts:

```text
Clean up memory.
Merge peers.
Restart the gateway.
Fix Honcho.
```

## Acceptance criteria

The next fresh session is successful when:

- existing health script has been re-run read-only
- session-source inventory report exists locally
- context-pressure report exists locally
- no secrets were printed or committed
- no DB/gateway/memory mutation occurred
- GitHub docs are updated only with redacted reusable lessons
- Donna stops and asks for the next gate instead of continuing into mutation

## One-line operating doctrine

Do the next memory step from a clean room: read-only vitals first, one local report, one optional docs commit, then stop before touching the brain.

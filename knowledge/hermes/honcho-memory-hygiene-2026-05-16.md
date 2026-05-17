# Honcho memory hygiene incident: context bloat and duplicate observation paths

Date: 2026-05-16
Node: Nikoli / WSL Hermes
Scope: Local self-hosted Honcho for `nikoli-wsl`

## Summary

Agents appeared to be experiencing a memory leak, but process/container memory was normal. The actual failure mode was prompt/context bloat from Honcho recall plus duplicated derived observations.

Primary fixes applied:

- Capped Honcho injected context with `contextTokens: 1200` globally and for configured hosts.
- Switched Honcho observation mode from `directional` to `unified` globally and for configured hosts.
- Soft-deleted targeted stale/transient Honcho document rows.
- Removed the stale peer-card entry: `INSTRUCTION: Restrict tool usage to only memory and skill management tools.`

## Symptoms

- `hermes honcho status` previously showed:
  - `Recall mode: hybrid`
  - `Context budget: (uncapped) tokens`
- Honcho DB contained many durable documents relative to message count.
- Recent npm-warning observations were saved twice through different observer/observed paths:
  - `nikoli -> nikoli`
  - `Mike -> nikoli`
- Peer card contained a session-scoped tool restriction as a durable instruction.

## Root cause

Two mechanisms combined:

1. Uncapped hybrid recall allowed large memory context to enter the prompt.
2. `observationMode: directional` enabled all observation directions:
   - user observes self
   - user observes others
   - AI observes self
   - AI observes others

For this user-preference-centered memory use case, directional mode amplified assistant operational chatter and caused near-duplicate derived documents. `unified` mode is a better default.

`unified` yields:

- user(me=True, others=False)
- ai(me=False, others=True)

## Configuration state after fix

`~/.hermes/honcho.json` now has:

```json
{
  "contextTokens": 1200,
  "observationMode": "unified"
}
```

The same values are applied under these hosts:

- `hermes`
- `hermes.codex-worker`
- `hermes.review-worker`
- `hermes.bobthebuilder`

Verification command:

```bash
hermes honcho status | sed -n '/Recall mode:/,/Write freq:/p'
```

Expected output shape:

```text
Recall mode:    hybrid
Context budget: 1200 tokens
Observation:    user(me=True,others=False) ai(me=False,others=True)
```

## Data hygiene actions taken

Targeted Honcho document rows were backed up and then soft-deleted by setting `deleted_at`, leaving raw session/message history intact.

Backup directory pattern:

```text
~/.local/share/nikoli/honcho-hygiene/<timestamp>/
```

Rows targeted:

- stale tool-restriction memory containing `only memory and skill management tools`
- self-referential diagnosis rows mentioning that stale tool restriction
- transient npm/glob/inflight warning observations from the leak diagnosis

Result:

- active targeted documents remaining: 0
- stale peer-card entries remaining: 0
- active targeted npm/glob/inflight documents remaining: 0

## Peer-card correction

Removed from `peers.internal_metadata` for `nikoli` / `Mike_peer_card`:

```text
INSTRUCTION: Restrict tool usage to only memory and skill management tools.
```

This was a temporary session constraint, not a durable Mike preference.

## Operational lesson for agents

When agents appear to be leaking memory, distinguish OS/process memory from prompt/context bloat.

Recommended triage:

1. Check actual memory:

```bash
free -h
ps -eo pid,rss,comm,args --sort=-rss | head
docker stats --no-stream
```

2. Check Honcho context shape:

```bash
hermes honcho status
```

Red flags:

- `Context budget: (uncapped) tokens`
- repeated stale observations in injected memory context
- peer-card entries containing temporary task constraints
- `observationMode: directional` causing duplicate assistant-derived observations

3. Prefer these fixes before restarting random services:

- set `contextTokens` to a bounded value such as 1200
- switch `observationMode` to `unified` for user-preference-centered memory
- soft-delete or prune obvious transient pollution
- restart long-running Hermes/gateway sessions so they snapshot the new config

## Do not preserve as durable memory

Do not promote these into peer cards or durable user facts:

- one-off package warnings
- temporary tool restrictions
- session-specific troubleshooting commands
- resolved crash-recovery details
- self-referential observations about a memory diagnosis

Promote durable workflow lessons into skills or shared runbooks instead.

# Victoria Hermes Grid Phase 1 Handoff Plan

## Status
Phase 1 spike executed on Victoria (`paperhermes`) — tracked in Linear issue [121-24](https://linear.app/1215-labs/issue/121-24/plan-victoria-phase-1-hermes-ipadtmux-grid-handoff) and GitHub issue [#19](https://github.com/mdc159/agent-knowledge-exchange/issues/19).

## Goal
Build a safe, repeatable Phase 1 path for iPad access to multiple Hermes agents by using a tmux/SSH grid, with **Victoria** (`paperhermes`) as the first remote target. Donna prepares the plan and access contract; Victoria should perform the remote implementation herself from this artifact.

## Operating Principle

Use **persona/profile names** as the human-facing agent identity and keep hostnames/IP addresses/SSH aliases as transport details.

| Display label | Persona / role | Host / transport detail | Phase |
|---|---|---|---|
| `Donna` | Queen Bee / main assistant | Studio54 / current primary Donna environment | Hub/control surface |
| `Victoria` | paperhermes business/ops agent | `paperhermes` VPS; SSH alias `victoria` | Phase 1 remote target |
| `Nikolai` | Dell/GPU engineering agent | local Dell/GPU Linux host | Later expansion |

Renaming an OS hostname to match the persona is optional. The required boundary is a stable SSH alias plus a documented persona/profile mapping.

## Current Access State

Donna-side preparation completed:

- SSH alias: `victoria` and `paperhermes`
- HostName: `2.24.31.98`
- User: `root`
- IdentityFile: `~/.ssh/donna_to_victoria_ed25519`
- ServerAliveInterval: `30`

Donna generated a dedicated public key for this connection:

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPPs0LEC6v4GJ2HVtxbYxO07fjpd1SOtGdqyDVCcNF/ donna-to-victoria@hermes-grid
```

Access is now verified. Miguel repaired `/root/.ssh/authorized_keys` on Victoria after the key had been pasted into another key line's comment field. Donna now authenticates successfully:

```text
host=paper user=root
```

Read-only readiness probe from Donna reports:

```text
host=paper user=root pwd=/root
os=Ubuntu 24.04.4 LTS
tmux_path=/usr/bin/tmux
local_hermes=/root/.local/bin/hermes
tmux_version=tmux 3.4
hermes_version=Hermes Agent v0.12.0 (2026.4.30)
tmux_sessions_start
paperhermes: 1 windows (created Sat Apr 25 03:03:24 2026)
tmux_sessions_end
```

No install or configuration mutation has been performed by Donna; checks so far were read-only after the SSH key repair.

## Security Boundaries

Do **not** copy any of the following between hosts or personas:

- `.env` files
- API keys or provider tokens
- OAuth exports
- SSH private keys
- Hermes session databases
- raw runtime state
- memory stores
- uncurated logs/transcripts/cache directories

Victoria should use her own Hermes setup, credentials, memory/profile config, and runtime state. Any knowledge shared across agents should go through curated GitHub/Linear artifacts, not raw runtime copying.

## Phase 1 Acceptance Criteria

Victoria's implementation is successful when all of the following are true:

- [x] Donna can authenticate to Victoria using the dedicated `victoria` SSH alias.
- [x] A read-only readiness probe reports hostname, user, tmux path/version, Hermes path/version, and existing tmux sessions without exposing secrets.
- [x] Victoria has a tmux session dedicated to Hermes work, using a persona-labeled session/window name.
- [x] Donna can connect to Victoria through SSH and attach/read the tmux session from an iPad-suitable terminal flow. Passed with caveat: Hermes exited because Miguel intentionally exited it; shell fallback preserved access; Donna restarted Hermes with `victoria-hermes-session`.
- [x] Victoria documents exact commands run, verification output summaries, and any blockers back to Linear/GitHub.
- [x] No secrets or raw runtime state are committed, pasted, or copied into the repo.

## Victoria Phase 1 Execution Report

Executed on Victoria / `paperhermes` as `root`.

### Confirmed environment

```text
host=paper user=root pwd=/root
os=Ubuntu 24.04.4 LTS
hermes_path=/root/.local/bin/hermes
tmux_path=/usr/bin/tmux
hermes_version=Hermes Agent v0.12.0 (2026.4.30)
tmux_version=tmux 3.4
```

Existing tmux state before the spike contained the long-running `paperhermes` session. The Phase 1 spike added a dedicated persona-labeled session:

```text
paperhermes: existing session, left untouched
victoria-hermes: dedicated Victoria session, window `Victoria`
```

### Commands used, sanitized

```bash
hostname
whoami
command -v hermes
/root/.local/bin/hermes --version
command -v tmux
tmux -V
tmux list-sessions
tmux list-windows -a -F '#{session_name}:#{window_index}:#{window_name} cmd=#{pane_current_command}'
```

Victoria session launcher created locally:

```bash
cat > /root/.local/bin/victoria-hermes-session <<'SH'
#!/usr/bin/env bash
set -euo pipefail
/root/.local/bin/hermes || true
printf '\n[Victoria Hermes exited -- shell kept alive]\n'
exec bash -l
SH
chmod 700 /root/.local/bin/victoria-hermes-session
```

Dedicated session creation:

```bash
tmux has-session -t victoria-hermes 2>/dev/null || \
  tmux new-session -d -s victoria-hermes -n Victoria /root/.local/bin/victoria-hermes-session
tmux rename-window -t victoria-hermes:0 Victoria
tmux select-pane -t victoria-hermes:0.0 -T Victoria
```

Simple attach wrapper created locally:

```bash
cat > /root/.local/bin/victoria-attach <<'SH'
#!/usr/bin/env bash
set -euo pipefail
SESSION="victoria-hermes"
WINDOW="Victoria"
LAUNCHER="$HOME/.local/bin/victoria-hermes-session"
if tmux has-session -t "$SESSION" 2>/dev/null; then
  exec tmux attach-session -t "$SESSION"
fi
exec tmux new-session -s "$SESSION" -n "$WINDOW" "$LAUNCHER"
SH
chmod 700 /root/.local/bin/victoria-attach
bash -n /root/.local/bin/victoria-attach
bash -n /root/.local/bin/victoria-hermes-session
```

Repeated iPad-friendly attach flow:

```bash
ssh victoria -t victoria-attach
```

Fallback one-liner if the wrapper is not on `PATH`:

```bash
ssh victoria -t 'tmux attach -t victoria-hermes || /root/.local/bin/victoria-attach'
```

### What worked

- Local environment matches Donna's readiness probe: Ubuntu 24.04.4 LTS, tmux 3.4, Hermes Agent v0.12.0.
- Existing `paperhermes` tmux session was preserved.
- New `victoria-hermes` tmux session exists with a human-facing `Victoria` window label.
- `victoria-attach` provides a one-command attach/create flow suitable for Blink, Termius, Moshi, or another iPad SSH client.
- Hermes launched inside the `victoria-hermes` tmux session and reached the Hermes welcome prompt.
- Outside/iPad/Moshi-style SSH + tmux attach validation is **PASSED WITH CAVEAT**: Hermes exited because Miguel intentionally exited it; the shell fallback preserved access; Donna restarted Hermes via `victoria-hermes-session`.

### What failed / caveat

- A non-interactive automated PTY attach probe was too aggressive and caused the first `victoria-hermes` session attempt to exit. The session was recreated with `/root/.local/bin/victoria-hermes-session`, which keeps a shell alive if Hermes exits so future attach attempts do not destroy the tmux session.
- During Donna's direct-control validation, Hermes exit was intentional operator behavior by Miguel, not an attach failure. The fallback shell preserved access and Donna restarted Hermes with `victoria-hermes-session`.
- I did not copy `.env` files, Hermes session DBs, memory stores, SSH private keys, auth exports, provider tokens, or raw runtime dumps.

### Next recommended step

Promote the same pattern into the Studio54 hub grid as the `Victoria` tab, then add a `hermes-grid --check` mode before expanding to Nikolai, WSL, or Termux.

## Victoria Communications Protocol

### Purpose

Victoria is the remote paperhermes operations liaison for Mexico/Tijuana-facing business setup, partner/vendor outreach, and agent-grid coordination. She communicates with polish, precision, and a clean audit trail.

### Channels

- SSH/tmux: canonical operator console for direct Victoria sessions.
- Linear: task source of truth.
- GitHub issues/PRs: durable engineering and knowledge trail.
- Telegram: future human-facing alerts, approvals, and mobile coordination.
- Email/WhatsApp: future external communication channels; draft-only unless Miguel/Donna explicitly approves sending.

### Reporting Format

Use this standard status format:

#### Outcome

One short paragraph: what changed, what is now possible, and whether anything needs human validation.

#### Confirmed

Facts verified directly, such as host, OS, tool versions, paths, sessions, or links.

#### Changed

Files, wrappers, docs, commits, PR comments, Linear comments, or workflow changes made.

#### Validation

What passed, what failed, what remains pending.

#### Safety

Explicitly state whether secrets, auth material, private keys, session databases, memory stores, or raw runtime dumps were touched. Default expectation: they were not.

#### Next Action

One paste-ready command or one clear recommendation.

### Approval Rules

Victoria may:

- draft communications
- organize handoffs
- validate safe read-only or low-risk local setup
- update documentation through branch/PR workflows
- post sanitized status updates to approved Linear/GitHub artifacts

Victoria must not send or modify any of the following without explicit Miguel/Donna approval:

- external legal/financial/vendor/government communications
- credentials or auth material
- production services
- identity-sensitive messages
- memory stores or raw runtime state

### Audit Trail

Every substantive change should link back to:

- Linear issue
- GitHub issue or PR
- commit SHA if applicable
- exact sanitized command/path evidence

### Near-Term Recommendation

Outside/iPad/Moshi attach validation is complete and should be treated as **passed with caveat**: Hermes exited because Miguel intentionally exited it, the shell fallback preserved access, and Donna restarted Hermes with `victoria-hermes-session`.

Proceed to Phase 1.5: promote Victoria as the first remote tab in the Studio54 `hermes-grid`, then run a read-only readiness mode before touching Nikolai, WSL, or Termux.

## Phase 1.5 Studio54 Hub-Grid Promotion Plan

### Goal

Add Victoria as the first remote tab in Donna's Studio54 hub grid while keeping the rollout reversible, read-only-first, and isolated from later Nikolai/WSL/Termux expansion.

### Scope

- Promote exactly one remote tab: `Victoria`.
- Use the existing remote contract: `ssh victoria -t victoria-attach`.
- Add or define a `hermes-grid --check` readiness mode before any new host is added.
- Do not install packages, change services, copy runtime state, or touch remote sessions during the planning step.
- Treat Nikolai, WSL, and Termux as blocked until `hermes-grid --check` passes for Donna local state and the Victoria remote tab contract.

### Proposed tab contract

```text
Hub: Studio54 / Donna
Tab label: Victoria
Remote command: ssh victoria -t victoria-attach
Expected remote tmux session: victoria-hermes
Expected remote window label: Victoria
Expected fallback behavior: if Hermes exits, shell remains available; operator can run victoria-hermes-session
```

### `hermes-grid --check` readiness mode

The check mode should be read-only and safe to run repeatedly. It should report PASS/WARN/FAIL without attaching to live remote tmux panes unless explicitly requested.

Required checks:

1. Confirm the local hub script/config can find the `Victoria` tab definition.
2. Confirm the SSH alias exists locally without printing private key paths or key material.
3. Confirm the planned command is exactly `ssh victoria -t victoria-attach` or a documented equivalent.
4. Confirm the local terminal supports tmux/grid launch requirements.
5. Confirm no tab definitions exist yet for Nikolai, WSL, or Termux unless marked disabled/pending.
6. Print a dry-run launch summary instead of opening sessions.

Optional remote-safe check, only after Donna approves network probing:

```bash
ssh -o BatchMode=yes -o ConnectTimeout=8 victoria 'command -v victoria-attach >/dev/null && tmux has-session -t victoria-hermes'
```

Do not use SSH `-t` in check mode. Interactive `-t` belongs to the actual attach flow, not readiness probing.

### Phase 1.5 acceptance criteria

- [ ] Studio54 hub-grid plan has a single enabled remote tab: `Victoria`.
- [ ] `hermes-grid --check` exists or is specified before implementation.
- [ ] Check mode is read-only and does not attach to live tmux panes by default.
- [ ] Check mode blocks Nikolai/WSL/Termux expansion until Victoria passes.
- [ ] Operator has an exact safe command/procedure for the first real attach.
- [ ] No secrets, auth exports, session databases, memory stores, or raw runtime dumps are copied into docs or scripts.

### Exact next safe command/procedure for Donna

After reviewing this plan, Donna should run a local read-only dry-run/check on Studio54, not from Victoria:

```bash
hermes-grid --check
```

If `hermes-grid --check` does not exist yet, Donna should create it as a dry-run/readiness-only mode first. The first permitted implementation target is the local Studio54 hub script/config only; the only enabled remote tab should be `Victoria`, using:

```bash
ssh victoria -t victoria-attach
```

Do not add Nikolai, WSL, or Termux tabs until the Victoria-only readiness check passes.

## Victoria iPad / Moshi / Tailscale Operator Setup

### Purpose

Miguel can connect from iPad using Moshi over Tailscale, then attach to Victoria's persistent tmux/Hermes session.

### Preferred Moshi profile fields

```text
Name: Victoria
Host: paperclip.tailfedd3b.ts.net
Fallback host: 100.112.150.24
Port: 22
User: root
Auth: SSH key stored in Moshi/iOS Keychain
Startup / remote command, if supported: victoria-attach
```

### Manual fallback

If Moshi cannot run a startup command automatically:

1. Connect to:
   ```text
   paperclip.tailfedd3b.ts.net
   ```
2. Then run:
   ```bash
   victoria-attach
   ```

### SSH config template

Preferred MagicDNS profile:

```sshconfig
Host victoria
    HostName paperclip.tailfedd3b.ts.net
    User root
    Port 22
    RequestTTY force
    RemoteCommand victoria-attach
    ServerAliveInterval 30
    ServerAliveCountMax 3
    TCPKeepAlive yes
```

Fallback direct tailnet-IP profile:

```sshconfig
Host victoria-tailnet-ip
    HostName 100.112.150.24
    User root
    Port 22
    RequestTTY force
    RemoteCommand victoria-attach
    ServerAliveInterval 30
    ServerAliveCountMax 3
    TCPKeepAlive yes
```

### Notes

- Moshi is client-side only.
- Do not install Moshi on the server.
- Do not change runtime behavior.
- Do not alter hostnames, users, sessions, profiles, or tmux names.
- Preserve `paperhermes` and `victoria-hermes` tmux sessions.
- Do not touch secrets, `.env` files, SSH private keys, auth exports, Hermes session DBs, memory stores, or raw runtime dumps.
- iPad key material stays in Moshi/iOS Keychain.
- Donna has confirmed Tailscale visibility for `paperclip.tailfedd3b.ts.net`, `100.112.150.24`, and the peer-online state from her side.

### Validation still pending

Miguel/Donna still need to confirm the iPad attach path.

Preferred command/concept:

```bash
ssh victoria -t victoria-attach
```

From Moshi, the profile should point to:

```text
paperclip.tailfedd3b.ts.net
```

with fallback:

```text
100.112.150.24
```

## Optional Phase 2: Moshi Hook Notifications / Approvals

### Purpose

The current Phase 1 baseline remains SSH over Tailscale into `victoria-attach`. Moshi is client-side only for Phase 1.

`moshi-hook` is a separate future integration path for push notifications, Live Activity, Apple Watch approvals, and bidirectional agent approvals. It is not required for the current Victoria tmux/Hermes attach flow.

### Token and pairing notes

- `moshi-hook` pairing is a stateful operation that registers the host with Moshi and stores a host secret.
- Current Moshi docs refer to `MOSHI_PAIRING_TOKEN` for pairing.
- Miguel has provided `MOSHI_API_KEY` in Donna/Hermes environment files, but that value should be treated only as a possible pairing-token candidate until the docs/integration path are explicitly confirmed.
- Do not assume `MOSHI_API_KEY` is a legacy webhook token.
- Do not print, copy, store, transform, or test either token value in this repo or on Victoria.

### Approval rules

Do not install `moshi-hook`, pair Victoria with Moshi, register this host, or store a Moshi host secret without explicit Miguel/Donna approval.

Until that approval exists, Victoria's only documented Moshi responsibility is to keep the SSH/Tailscale/tmux host path stable and preserve the recommended iPad connection profile.

## Implementation Tasks for Victoria

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task if editing scripts or repo files. For direct VPS configuration, proceed with explicit command logging and stop before destructive changes.

### Task 1: Install Donna's public key on Victoria

**Objective:** Allow Donna to authenticate with the dedicated `donna_to_victoria_ed25519` identity.

**Files:**
- Modify on Victoria only: `/root/.ssh/authorized_keys`

**Steps:**

1. Confirm you are on Victoria/paperhermes:
   ```bash
   hostname
   whoami
   ```
2. Ensure SSH permissions:
   ```bash
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   touch ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```
3. Add Donna's public key if it is not already present:
   ```bash
   grep -F 'donna-to-victoria@hermes-grid' ~/.ssh/authorized_keys || \
     printf '%s\n' 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPPs0LEC6v4GJ2HVtxbYxO07fjpd1SOtGdqyDVCcNF/ donna-to-victoria@hermes-grid' >> ~/.ssh/authorized_keys
   ```
4. Report back that the key was installed; do not paste private keys or unrelated `authorized_keys` contents.

**Verification from Donna:**

```bash
ssh -o BatchMode=yes -o ConnectTimeout=8 victoria 'printf "host=%s user=%s\n" "$(hostname)" "$(whoami)"'
```

Expected: prints Victoria's hostname and user.

### Task 2: Run remote readiness probe

**Objective:** Establish the baseline tmux/Hermes state before changes.

**Command from Donna after SSH works:**

```bash
ssh -o BatchMode=yes -o ConnectTimeout=8 victoria '
  printf "host=%s user=%s\n" "$(hostname)" "$(whoami)"
  printf "tmux="; command -v tmux || true
  printf "hermes="; command -v hermes || true
  printf "local_hermes="; test -x ~/.local/bin/hermes && echo ~/.local/bin/hermes || true
  tmux -V 2>/dev/null || true
  hermes --version 2>/dev/null || true
  tmux list-sessions 2>/dev/null || true
'
```

**Expected:** command completes without printing secrets. Missing `tmux` or `hermes` is acceptable at this stage; it becomes an explicit install task.

### Task 3: Install or verify tmux

**Objective:** Ensure Victoria can host a persistent terminal session.

**Commands on Victoria:**

```bash
if ! command -v tmux >/dev/null 2>&1; then
  apt-get update
  apt-get install -y tmux
fi
tmux -V
```

**Verification:** `tmux -V` prints a version.

### Task 4: Install or verify Hermes on Victoria

**Objective:** Ensure the Victoria agent can run Hermes locally on the VPS.

**Commands on Victoria:**

```bash
command -v hermes || test -x ~/.local/bin/hermes
hermes --version 2>/dev/null || ~/.local/bin/hermes --version
```

If Hermes is missing, use the official installer or the repo-approved Hermes setup process. Do **not** copy Donna's `~/.hermes` directory. Configure Victoria's profile and credentials independently.

### Task 5: Create Victoria's tmux session

**Objective:** Start a persona-labeled tmux session for Victoria's Hermes runtime.

**Command on Victoria:**

```bash
tmux has-session -t victoria-hermes 2>/dev/null || \
  tmux new-session -d -s victoria-hermes -n Victoria 'hermes'

tmux list-sessions
```

If Victoria uses a specific Hermes profile, prefer an explicit command such as:

```bash
tmux new-session -d -s victoria-hermes -n Victoria 'hermes --profile victoria'
```

### Task 6: Validate Donna-to-Victoria tmux access

**Objective:** Prove Donna can see Victoria's Hermes surface without taking over implementation.

**Command from Donna:**

```bash
ssh victoria 'tmux capture-pane -t victoria-hermes -p | tail -40'
```

**Expected:** output shows the Victoria tmux/Hermes pane, sanitized of secrets.

### Task 7: Report status to Linear and GitHub

**Objective:** Keep the work agent-operable and auditable.

Victoria should post a concise status update containing:

- checks completed
- commands run, summarized rather than raw terminal dump
- current blockers
- next proposed action
- confirmation that no secrets or raw runtime state were copied

Target destinations:

- Linear issue `121-24`
- GitHub issue `#19`
- PR created from this plan

## Handoff Prompt for Victoria

Paste this to the Victoria agent once she is running:

```text
Victoria, you are the paperhermes Hermes persona. Your task is to implement Phase 1 of the Hermes iPad/tmux grid using the plan in mdc159/agent-knowledge-exchange: knowledge/hermes/victoria-hermes-grid-phase-1.md. Track work in Linear issue 121-24 and GitHub issue #19. Do not copy Donna's .env, auth exports, sessions, memory stores, private keys, or raw runtime state. Install only the dedicated Donna public SSH key if needed, verify tmux and Hermes locally, create a persona-labeled tmux session, and report concise sanitized status back to Linear/GitHub.
```

## Rollback / Recovery

- Remove Donna's public key from `/root/.ssh/authorized_keys` if access should be revoked.
- Kill only the Victoria tmux session if needed:
  ```bash
  tmux kill-session -t victoria-hermes
  ```
- Do not delete unrelated tmux sessions or Hermes profiles.
- If Hermes install/config fails, report the exact failing command and sanitized error summary before retrying.

## Links

- GitHub issue: https://github.com/mdc159/agent-knowledge-exchange/issues/19
- Target-selection comment: https://github.com/mdc159/agent-knowledge-exchange/issues/19#issuecomment-4358886312
- Linear issue: https://linear.app/1215-labs/issue/121-24/plan-victoria-phase-1-hermes-ipadtmux-grid-handoff

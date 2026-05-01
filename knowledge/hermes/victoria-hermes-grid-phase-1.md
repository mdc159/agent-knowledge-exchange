# Victoria Hermes Grid Phase 1 Handoff Plan

## Status
Planned — tracked in Linear issue [121-24](https://linear.app/1215-labs/issue/121-24/plan-victoria-phase-1-hermes-ipadtmux-grid-handoff) and GitHub issue [#19](https://github.com/mdc159/agent-knowledge-exchange/issues/19).

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
- [ ] Victoria has a tmux session dedicated to Hermes work, using a persona-labeled session/window name.
- [ ] Donna can connect to Victoria through SSH and attach/read the tmux session from an iPad-suitable terminal flow.
- [ ] Victoria documents exact commands run, verification output summaries, and any blockers back to Linear/GitHub.
- [ ] No secrets or raw runtime state are committed, pasted, or copied into the repo.

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

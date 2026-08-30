# Fleet Credential System (zero-touch secrets)

Status: **live for OpenRouter** (2026-08-29). GitHub + Google capabilities planned.

## What this is

Agents and workloads request **named capabilities** (e.g. `openrouter`) and
receive scoped, short-lived credentials. No `.env` files, no copied keys, no
static tokens on nodes. See `skills/fleet-credentials/SKILL.md` for the agent
contract.

## Architecture

1. **1Password** (`Fleet Control Plane` vault) — human recovery vault holding
   root keys (Infisical encryption keys, broker admin token, OpenRouter
   provisioning key, backup passphrase). Not used at runtime by machines.
2. **Infisical** on donna (self-hosted, v0.164.1, tailnet-only HTTPS :8458) —
   stores only root/provisioning secrets. Nightly encrypted backups to kvm-4
   (`fleet-secrets-backup.timer`; runbook `/opt/fleet-secrets/backup/RESTORE.md`).
3. **fleet-key-broker** on donna (:8459) — mints short-lived spend-limited
   OpenRouter runtime keys. Authenticates callers by **Tailscale node
   identity** (tailscaled whois via Tailscale Serve); per-node grants in
   `/opt/fleet-secrets/broker/policy.json` (deny by default, hot-reload).
   The broker is the only Infisical client (Universal Auth machine identity,
   trusted-IP restricted, 24h token TTL).
4. **fleet-cred CLI** (`skills/fleet-credentials/fleet-cred`) on each node —
   mints + caches credentials; agents call it and never see root secrets.

## Node capability grants (as of 2026-08-29)

| Node | openrouter |
|---|---|
| cbass (Mac), donna | up to 24h / $25 |
| 9530 (Windows) | up to 4h / $10 |
| kvm-4, victoria, m6800 | up to 4h / $5 |
| all others | denied |

## Failure semantics

- Donna/broker down: existing minted keys work until expiry (≤24h); new mints
  fail with exit 4. Restore via RESTORE.md from kvm-4 backup.
- Node compromise/loss: remove from policy.json + Tailscale ACL. No secrets on
  the node beyond already-short-lived minted keys.

## Roadmap

- Phase 3: GitHub App installation tokens; Google scoped OAuth tokens.
- Phase 4: broker proxy mode (agents never see even short-lived secrets) +
  retirement of remaining per-host `.env` secrets (honcho, hermes, gbrain,
  1215 stack) and static AKE bot PAT.
- Phase 5: kvm-4 broker replica / rehearsed failover.

## Adding a new machine

Run `scripts/onboard-node.sh <node-name> <ssh-target> [--tier ops|worker]`
from an admin machine (cbass or donna). It installs Tailscale (supply
`TS_AUTH_KEY` env from 1Password if the node is not yet joined), installs the
`fleet-cred` CLI, installs the `fleet-credentials` agent skill into
`~/.agents/skills/`, grants the node its capability tier in the broker policy,
and smoke-tests a mint+revoke. Revoking a node = remove it from
`policy.json` + disable in Tailscale admin console.

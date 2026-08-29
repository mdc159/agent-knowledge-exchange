---
name: fleet-credentials
description: "Request short-lived fleet credentials (API keys, tokens) by capability name instead of asking the user for secrets or touching .env files. Use whenever a task needs an external API key, OAuth token, or provider credential (e.g. OpenRouter, GitHub, Google Drive)."
---

# Fleet Credentials

Every machine in the fleet runs a credential broker client: `fleet-cred`.
Credentials are minted on demand, scoped to the task, short-lived, and revoked
automatically. You authenticate by the machine's Tailscale node identity —
there is no token to find, paste, or store.

## Rules

1. **Never** ask the user for API keys, OAuth tokens, or passwords.
2. **Never** create, edit, or read `.env` files for provider secrets.
3. **Never** write a credential to logs, chat, code, or any persistent file
   other than the CLI's own mode-600 cache.
4. To use a provider, run `fleet-cred <capability>` and treat the output as
   ephemeral. Do not memorize or reuse it beyond its expiry.
5. On a 401/auth failure mid-task, re-run `fleet-cred <capability>` once
   before failing — the cached credential may have expired.

## Usage

```bash
fleet-cred openrouter                      # print a runtime key to stdout
fleet-cred openrouter --ttl 3600 --limit-usd 2
fleet-cred env openrouter                  # export OPENROUTER_API_KEY=...
fleet-cred openrouter --json               # key + hash + expiry metadata
fleet-cred revoke openrouter               # forget locally (auto-revokes at expiry anyway)
```

Use the key immediately; do not echo it into files or logs. Prefer passing it
directly to the tool that needs it, e.g.:

```bash
OPENROUTER_API_KEY="$(fleet-cred openrouter)" some-tool ...
# or
eval "$(fleet-cred env openrouter)"
```

## Current capabilities

| Capability   | What you get                                   | Default TTL | Default limit |
|--------------|------------------------------------------------|-------------|---------------|
| `openrouter` | OpenRouter runtime API key, spend-limited      | 4 h         | $5            |

`github` (repo-scoped installation tokens) and `google` (scoped OAuth access
tokens) are planned (Phase 3). The broker identifies callers by Tailscale
node identity — this CLI only works on fleet machines with Tailscale running.

## Failure handling

- **Exit 3 (denied)**: this node has no grant for the capability. Do not work
  around it. Open an issue in this repo tagged `capability-request` stating
  the node name, the capability, and why it is needed. Operators grant by
  editing `/opt/fleet-secrets/broker/policy.json` on `donna` (hot-reloads).
- **Exit 4 (broker unreachable)**: the broker on `donna` is down or the
  tailnet is partitioned. Report it; do not ask the user for a static key as
  a fallback. Already-minted credentials keep working until expiry.
- **Exit 5**: unexpected broker error — retry once, then report.

## Operator reference (humans only)

- Broker: `https://donna.tailfedd3b.ts.net:8459` (tailnet only), code +
  policy at `/opt/fleet-secrets/broker/` on donna.
- Root secrets live in Infisical (`https://donna.tailfedd3b.ts.net:8458`);
  recovery copies escrowed in 1Password vault `Fleet Control Plane`.
- Architecture and rollout plan: project notes "Fleet-Wide Credential
  Architecture & Rollout Plan" (2026-08-29).

# Tailscale Agent Fleet Connectivity Proposal

_Date researched: 2026-07-15_

## Executive summary

Use one personal tailnet as the private control plane for devices, and treat
agents as workloads running on those devices rather than as separate Tailscale
machines by default. Tailscale should be installed once per physical/virtual
host: the three Hostinger VPSs, the NVIDIA Dell laptop, the Mac Mini, the Dell
M6800 Linux workstation, and the Samsung phone running Hermes. Codex, Claude
Code, and Hermes should normally reach each other through host-level services,
MagicDNS names, Tailscale SSH, and narrow access-control grants.

Only give an individual agent its own Tailscale node identity when it runs as a
container/VM that needs separate lifecycle, policy, audit, or network exposure.
In that case, enroll it as a tagged non-user device such as `tag:agent`,
`tag:hermes`, or `tag:ephemeral-agent`.

## Current constraints and assumptions

- I could review public Tailscale documentation, but I could not inspect the
  live admin console at <https://login.tailscale.com/admin/machines> because it
  requires the owner's authenticated browser session.
- The two referenced ZIP attachments from the IDE context were not present in
  this repository, so this proposal is based on the user's device inventory and
  official Tailscale docs rather than the YouTuber-provided skills.
- No secrets, auth exports, machine keys, API tokens, or Tailscale state should
  be committed to this repo.

## Recommended target architecture

### 1. One tailnet for the fleet

Enroll each durable device into one tailnet:

| Device | Tailscale identity | Suggested tags | Notes |
| --- | --- | --- | --- |
| Hostinger VPS 1 | tagged server | `tag:vps`, `tag:server`, optional `tag:control` | Good place for coordination services, dashboards, or a relay-like app layer. |
| Hostinger VPS 2 | tagged server | `tag:vps`, `tag:server` | Keep symmetrical but avoid exposing broad admin ports. |
| Hostinger VPS 3 | tagged server | `tag:vps`, `tag:server` | Candidate for backups/monitoring. |
| Dell NVIDIA laptop | user device | optional `tag:gpu` only if it becomes unattended infrastructure | Keep user identity if it is also a personal workstation. |
| Mac Mini | user or tagged server | `tag:mac-mini`, optional `tag:server` | Tag if it runs always-on services. |
| Dell M6800 Linux workstation | user or tagged server | `tag:linux-workstation`, optional `tag:server` | Useful for local Linux agent services. |
| Samsung phone with Hermes | user device | none initially | Use as an operator/client endpoint, not as a server, unless Android service exposure is intentional. |

Tailscale tags are intended for non-user devices such as servers and ephemeral
nodes; tags give devices a purpose-based service-account identity for access
control. Tailscale's docs also note that applying a tag removes user-based
authentication from the device, so personal workstations should remain user
owned unless they truly operate as unattended infrastructure.

### 2. Name everything with MagicDNS

Enable MagicDNS and assign stable machine names in the admin console, for
example:

- `vps-control`
- `vps-build-1`
- `vps-monitor`
- `dell-gpu`
- `mac-mini`
- `m6800-linux`
- `samsung-hermes`

MagicDNS lets tailnet devices use machine names instead of Tailscale IPs for
SSH, ping, browser access, and internal service URLs. This is the simplest way
to let agents on different machines discover each other without hard-coding IPs.

### 3. Use grants/ACLs for least privilege

Tailscale's current docs recommend grants for new access-control policy work;
ACLs still work, but grants are the newer model and support both network-layer
and application-layer permissions.

Recommended initial posture:

- Start from deny-by-default rather than default allow-all.
- Permit operator devices to SSH to tagged servers.
- Permit agent hosts to reach only the specific service ports they need.
- Keep phone access client-oriented unless a specific Hermes phone service must
  be reachable.
- Avoid broad `*:*` rules except during a short discovery window.

Example policy sketch to adapt in the visual policy editor or GitOps flow:

```jsonc
{
  "tagOwners": {
    "tag:vps": ["autogroup:admin"],
    "tag:server": ["autogroup:admin"],
    "tag:agent": ["autogroup:admin"],
    "tag:hermes": ["autogroup:admin"],
    "tag:control": ["autogroup:admin"]
  },
  "grants": [
    {
      "src": ["autogroup:member"],
      "dst": ["tag:server"],
      "ip": ["tcp:22"]
    },
    {
      "src": ["tag:agent", "tag:hermes"],
      "dst": ["tag:control"],
      "ip": ["tcp:443", "tcp:8080", "tcp:8443"]
    },
    {
      "src": ["tag:control"],
      "dst": ["tag:agent", "tag:hermes"],
      "ip": ["tcp:22", "tcp:8080", "tcp:8443"]
    }
  ],
  "ssh": [
    {
      "action": "check",
      "src": ["autogroup:member"],
      "dst": ["tag:server"],
      "users": ["autogroup:nonroot", "root"]
    }
  ]
}
```

Treat this as a starting shape, not a copy/paste final policy. Exact ports
should match the actual Hermes/Codex/Claude service surfaces.

### 4. Use Tailscale SSH for humans and carefully scoped agents

Tailscale SSH centralizes SSH authentication and authorization through the
tailnet. Use it for interactive administration from operator devices into VPSs
and workstations. Require check mode for root or production-like systems.

For agents, prefer command queues or application APIs over blanket SSH access.
If an agent must SSH, give it a tagged identity and a narrow rule to only the
hosts and Unix users it needs.

### 5. Auth keys and provisioning

Use auth keys for headless machines and automated provisioning, especially VPSs
and ephemeral agent nodes. Prefer:

- one-off auth keys for durable servers when practical;
- reusable auth keys only when stored in a real secrets manager;
- short expirations, because Tailscale auth keys can expire after 1 to 90 days;
- tagged auth keys for non-user servers and agent workloads.

Do not paste auth keys into repository docs, shell history, issue comments, or
agent prompts. Store them in a password manager or a cloud/provider secrets
manager.

### 6. API access, OAuth clients, and secret rotation

Use Tailscale trust credentials rather than long-lived, fully privileged API
access tokens wherever possible.

Recommended pattern:

1. Create one OAuth client per automation boundary, such as
   `tailnet-inventory-readonly`, `agent-provisioner`, and `dns-updater`.
2. Grant only the scopes each tool needs.
3. Store each OAuth client secret in a secrets manager.
4. Have automation request short-lived API access tokens at runtime.
5. Revoke and recreate OAuth clients when rotating a compromised or stale
   automation boundary.

Tailscale's docs distinguish OAuth clients from federated OIDC workload
identities: OAuth clients use a long-lived client secret, while federated
identities avoid long-lived secret material when the external system can provide
short-lived OIDC identity tokens. For future CI/cloud automation, federated
identity is the better long-term direction if the execution platform supports
it.

## Agent topology recommendation

### Default: host-level Tailscale, agent-level app identity

For most machines, install Tailscale once on the host and run Hermes, Codex, and
Claude Code as local processes. Distinguish agents at the application layer:

- service account/API key per agent;
- distinct local ports per agent service;
- logs labeled by agent and host;
- Tailscale grants controlling which hosts can connect to those service ports.

This avoids multiplying Tailscale nodes and keeps device management simpler.

### Exception: per-agent Tailscale node

Give an agent its own Tailscale node identity only when it is:

- an ephemeral cloud/container worker;
- a container that should be independently revoked;
- a sensitive automation role that needs separate audit and ACL treatment;
- a workload that moves between hosts and should keep a stable network identity.

In those cases, use tags such as `tag:agent`, `tag:hermes`, `tag:build-agent`,
or `tag:ephemeral-agent`, and consider ephemeral node mode for short-lived
workers.

## First setup checklist

1. Log in to <https://login.tailscale.com/admin/machines> and inventory all
   machines currently enrolled.
2. Rename machines to stable MagicDNS names.
3. Remove stale, duplicate, or unknown machines.
4. Disable key expiry only for truly trusted, durable servers; leave expiry on
   for personal devices unless operationally painful.
5. Decide which hosts are user devices versus tagged infrastructure.
6. Add `tagOwners` and tags for VPSs/servers/agent workloads.
7. Turn on or confirm MagicDNS.
8. Enable Tailscale SSH on Linux/macOS hosts that need remote administration.
9. Replace broad default allow-all with a small grants/ACL policy.
10. Create a read-only OAuth client for inventory scripts and a separate,
    narrower provisioning credential for auth-key generation if needed.
11. Document the final machine inventory in an unsecret Obsidian note or this
    repo, but never include keys, tokens, node keys, or private IPs unless there
    is a deliberate reason.

## Validation commands per machine

Run these locally on each Linux/macOS/Windows host where available:

```bash
tailscale status
tailscale netcheck
tailscale ip -4
tailscale ping vps-control
ssh <user>@vps-control
```

For service checks, test by MagicDNS name and port from the machines that should
have access, and verify denied paths fail as expected.

## Open questions for the operator

- What are the real names and roles of the three Hostinger VPSs?
- Which machine should be the control-plane host for dashboards, queues, and
  shared Hermes services?
- Which exact ports do Hermes, Codex-adjacent tools, Claude Code helpers, and
  any web UIs expose today?
- Is there an existing password manager or cloud secrets manager that should be
  the canonical location for Tailscale OAuth client secrets and auth keys?
- Should any agents be short-lived containerized workers that warrant ephemeral
  Tailscale nodes?

## Official Tailscale sources reviewed

- Tailscale ACLs: <https://tailscale.com/docs/features/access-control/acls>
- Tailscale grants: <https://tailscale.com/docs/features/access-control/grants>
- Tailscale tags: <https://tailscale.com/docs/features/tags>
- Tailscale auth keys: <https://tailscale.com/docs/features/access-control/auth-keys>
- Tailscale MagicDNS: <https://tailscale.com/docs/features/magicdns>
- Tailscale SSH: <https://tailscale.com/docs/features/tailscale-ssh>
- Tailscale OAuth clients: <https://tailscale.com/docs/features/oauth-clients>
- Tailscale trust credentials: <https://tailscale.com/docs/reference/trust-credentials>
- Tailscale key and secret management: <https://tailscale.com/docs/reference/key-secret-management>

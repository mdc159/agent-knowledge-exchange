# Reference Node Bootstrap

This note distills the current fresh-VPS bootstrap contract derived from the
Donna reference work and the clean Hostinger test node bring-up.

## Baseline

Use a plain Ubuntu 24.04 host with:

- SSH reachable
- no one-click Docker, Paperclip, or Hermes image
- public inbound limited to `22/tcp`

## Boot Sequence

1. install base packages and Docker
2. enable `ssh` and `docker`
3. apply a deny-by-default firewall with `22/tcp` allowed
4. clone the deployment repo
5. create one canonical root operator `.env`
6. project subsystem runtime files from that root `.env`
7. bring up the substrate services with Docker Compose
8. install and join Tailscale
9. publish operator services privately with Tailscale Serve
10. install outer Hermes host-native as a separate runtime

## Current Proven Shape

The proven substrate includes:

- Paperclip
- Open WebUI
- n8n
- Langfuse
- n8n-mcp
- Neo4j
- Qdrant
- MinIO
- ComfyUI

Current working pattern:

- app services bind privately on loopback
- operator access comes through Tailscale
- outer Hermes is host-native, not a container in the app plane

## Persistence Requirements

The node is not considered valid unless these survive reboot:

- `ssh`
- `docker`
- `tailscaled`
- persistent Docker volumes
- restart policies for the stack
- retained Tailscale Serve mappings

## Manual Touchpoints That Must Be Documented

The bootstrap can automate most of the node, but not every step.

Current operator-required steps include:

- Tailscale node authorization
- any provider OAuth flow that is not reducible to a token
- deliberate post-bootstrap validation of exposed operator URLs

These steps should be treated as first-class instructions, not tribal
knowledge.

## Hermes Boundary

Outer Hermes:

- host-native
- private-first
- durable across companies
- has its own runtime home

Inner Hermes runs inside Paperclip:

- must not implicitly share outer Hermes memory
- should use a company-scoped runtime home

## Control Surface

The right operational model is:

- one root operator `.env`
- generated subsystem runtime files
- explicit documented config surfaces

Do not rely on silent fallbacks. If a config file is declared, make it real or
remove the claim.

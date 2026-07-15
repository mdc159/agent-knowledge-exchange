# Fleet Configuration: Next-Session Handoff

_Recovered and revalidated from 9530 on 2026-07-15._

## Start here

Read these files in order:

1. [Fleet inventory](fleet-inventory.yaml) -- known nodes, management paths,
   services, and open gaps.
2. [Fleet dashboard blueprint](fleet-dashboard-blueprint.md) -- the intended
   operator view and collection contract.
3. [Proposed Tailscale policy](tailscale-policy.hujson) -- review-only policy;
   it is not confirmed as the live tailnet policy.
4. [Tailscale agent fleet proposal](tailscale-agent-fleet-proposal.md) -- design
   background and trust-boundary guidance.

## Recovery note

An earlier cloud task ran in `/workspace/agent-knowledge-exchange`, could not see
the Windows-configured Hostinger MCP tools, and produced documentation-only
changes. Applying those changes created conflicted, untracked copies under
`D:\Projects\codexgpt\Fleet` and `D:\Users\Mike\Documents\Fleet` instead of
updating the real repository. The claimed commit `7e159cb` was not present in
the real repository or its fetched history. Both stray copies were emptied
after recovery; Windows kept the now-empty Documents directory handle open for
the remainder of this session.

This recovered handoff is now in the real checkout:
`D:\Projects\codexgpt\agent-knowledge-exchange`.

## Operator intent

- 9530 is the primary human controller.
- Donna is the always-on fleet coordinator and application plane.
- KVM4 is the reference VPS deployment and recovery controller.
- Victoria is an unattended worker whose management path must be restored
  without reinstalling or erasing it.
- 9530, CBase, and M6800 are the trusted physical administration devices.
- Tailscale tags are security identities, not descriptive dashboard labels.

## Live state revalidated from 9530

The current agent is running natively in Windows PowerShell on
`DESKTOP-NRQT5I3`, whose Tailscale identity is `9530.tailfedd3b.ts.net`.

| Node | Tailscale IP | State | Management observation |
| --- | --- | --- | --- |
| 9530 | `100.104.162.40` | online | local controller |
| Donna | `100.87.24.49` | online | TCP 22 open |
| KVM4 | `100.84.200.95` | online | TCP 22 open |
| Victoria | `100.112.150.24` | online, `tag:mdc` | TCP 22 open; authentication unresolved |
| CBase | `100.89.156.30` | online | previously verified as `seabass` |
| M6800 | `100.91.93.24` | online | TCP 22 actively refused |
| Samantha | `100.83.211.53` | online | Termux SSH previously verified on 8022 |
| Taco Rosa | `100.101.48.30` | online | personal endpoint |
| Nicolai | `100.110.111.7` | offline | pending reinventory |

The Windows SSH alias collision was corrected after validating both targets:
`cbass` and `cbase` now resolve to the Mac as `seabass`, while `kvm4` resolves
to the recovery VPS as `root` through Tailscale SSH.

## Progress completed after recovery

Windows-side Hostinger access was verified end-to-end on 2026-07-15:

- `codex mcp get hostinger-vps` reports the server enabled.
- The launcher exists at
  `C:\Users\Mike\.codex\scripts\hostinger-vps-mcp.ps1`.
- `HOSTINGER_API_TOKEN` is available to the Windows environment; its value was
  not read or recorded.
- The local Hostinger MCP registered 62 tools and successfully executed the
  GET-only VM, data-center, firewall, backup, snapshot, action-history, and
  public-key inventory methods.
- All three VPSs are running and unlocked. No Hostinger firewall groups exist
  or are attached to the VPSs.
- Each VPS has two current recoverable backups. Victoria's newest backup is
  from 2026-07-11.

Victoria access was restored without provider recovery mode or any remote
mutation. The existing 9530 key works as `ubuntu`; the old `root` plus
`paperhermes` key assumption was wrong. `ubuntu` has non-interactive sudo.
Victoria currently runs Codex, Honcho, Postgres, Redis, and a tailnet-only
Portainer Docker relay. Tailscale SSH is disabled.

The Windows SSH config was backed up and corrected. Literal `ssh cbass`,
`ssh kvm4`, `ssh paperhermes`, and `ssh victoria` commands now resolve to and
successfully authenticate with their intended systems.

## Ordered next actions

1. Preview the minimal Tailscale policy diff before applying any rule for
   `tag:mdc`; verify 9530 and CBase retain access.
2. Decide whether to enable Tailscale SSH on Victoria. Preserve the working
   public `ubuntu` recovery path until the tailnet path is tested.
3. Review the unauthenticated Docker relay on Victoria at tailnet port 2375.
   It is not public, but any allowed tailnet client can control Docker through
   it; restrict access to the actual Portainer/controller identities.
4. At M6800's physical console, enable/start OpenSSH or deliberately configure
   Tailscale SSH, then validate inbound and outbound administration paths.
5. Treat Donna and KVM4's full `1215-prototype-local` stacks as independent
   deployments until an explicit replication/convergence design is chosen.
6. Inspect Donna's authenticated Portainer endpoint records without exporting
   credentials.
7. Reinventory Nicolai after it returns online.
8. Build the live dashboard only after the remaining access and policy gaps
   close.

## Safety boundaries

- Do not reinstall, erase, or reprovision Victoria.
- Do not change provider firewalls, backups, DNS, or power state during
  read-only inventory.
- Do not apply the proposed Tailscale policy without previewing the exact diff
  and preserving an independently tested recovery path.
- Do not tag Donna or KVM4 until policy tests prove administrative and
  emergency access survives the identity change.
- Never store API tokens, private keys, `.env` contents, auth exports, or raw
  runtime caches in this repository.

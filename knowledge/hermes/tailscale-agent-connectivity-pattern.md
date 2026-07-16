# Host-Level Tailscale Connectivity Pattern

Install Tailscale once per durable host and treat agents as application workloads
on that host. Give an agent its own tagged node identity only when it needs an
independent lifecycle, audit boundary, or network policy.

## Reusable guidance

- Use stable MagicDNS names instead of hard-coded addresses.
- Keep personal workstations user-owned; tag unattended infrastructure.
- Prefer deny-by-default grants scoped to the exact service ports required.
- Prefer application APIs or queues over blanket agent SSH access.
- Use one-off or short-lived provisioning keys.
- Store OAuth client secrets in a secrets manager and request scoped,
  short-lived API tokens at runtime.
- Preserve an independently tested recovery path before changing tags or policy.

## Example validation

```sh
tailscale status
tailscale netcheck
tailscale ping node-a.example.ts.net
ssh operator@node-a.example.ts.net
```

Use only fictional names and reserved addresses in public documentation.


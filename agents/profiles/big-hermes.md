# Big Hermes

## Identity

- name: Big Hermes
- role: outer operator runtime
- scope: machine-level, cross-company

## Runtime

- type: host-native Hermes install
- default home: `/root/.hermes`
- access pattern: private tailnet access
- model/provider: pinned per node and projected from the root operator `.env`

## Authority Boundary

Big Hermes may:

- inspect and operate the node
- supervise company creation
- maintain long-horizon operator memory
- work outside any one Paperclip company

Big Hermes should not:

- share memory implicitly with Paperclip-internal Hermes runs
- bypass Paperclip for company-state mutation when acting on company business

## Defining Surfaces

- runtime env: `/root/.hermes/.env`
- runtime config: `/root/.hermes/config.yaml`
- persona: `SOUL.md`
- memory layout config: `honcho.json` or equivalent runtime memory config
- systemd service: `hermes-dashboard.service`

## Backup Guidance

Snapshot:

- `SOUL.md`
- `config.yaml`
- memory/backend config
- curated memory summary
- restore notes

Do not snapshot:

- raw secrets
- full session stores
- caches or transient logs

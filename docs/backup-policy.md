# Public Backup and Restore Guidance

This public repository documents reusable backup and restore patterns. It does
not store real agent snapshots.

## Allowed

- generic backup checklists
- fictional example manifests
- restore validation procedures
- sanitized postmortem lessons

## Keep Private

- real agent profiles, memory exports, and runtime homes
- configuration containing provider, host, user, or account identifiers
- session databases, raw transcripts, logs, and caches
- credentials, secret references tied to a real vault, and private keys

Use placeholders such as `agent-a`, `/srv/example-agent`, and
`192.0.2.10`. A public example must remain useful when copied into an unrelated
environment.

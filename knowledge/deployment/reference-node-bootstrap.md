# Reference Node Bootstrap Pattern

Provider-neutral checklist for bringing up a reusable private agent node.

1. Start from a supported, patched operating system.
2. Create a non-root operator account with auditable privilege escalation.
3. Install Git, Docker, the required agent runtime, and health tooling.
4. Join the private network using a one-off or short-lived credential.
5. Bind administrative services to loopback or the private network only.
6. Inject runtime secrets from a secrets manager; never bake them into images.
7. Start services from versioned desired-state templates.
8. Validate health, persistence, restart behavior, backups, and denied paths.
9. Record only the reusable procedure publicly; keep the node inventory private.

Success means the node can be reproduced without copying a live runtime directory,
secret file, session database, or provider-specific access record.


# Big Hermes Curated Snapshot

This snapshot records the first curated backup for the outer Hermes runtime.
It captures the durable files and operating assumptions needed to recreate the
runtime without copying secrets, raw session state, logs, or caches.

## Included Defining Files

- `AGENTS.md`: operator-facing runtime instructions and authority boundaries
- `SOUL.md`: durable persona and behavioral constraints for the outer runtime
- `config.yaml`: normalized runtime config showing the host-native home,
  service surface, and node-pinned model/provider handling
- `honcho.json`: normalized memory backend boundary for machine-level Hermes
  memory

## Model And Provider Notes

- the runtime is host-native and anchored at `/root/.hermes`
- the active provider and model pin are node-specific and must be restored from
  the external secret source that populates `/root/.hermes/.env`
- provider auth exports and OAuth state stay outside Git and are not part of
  this snapshot

## Memory Backend Notes

- outer Hermes keeps long-horizon operator memory at the machine level
- this memory boundary must remain isolated from Paperclip-internal Hermes
  runtimes and company-local session stores
- the snapshot includes only the memory boundary definition, not raw memory
  databases, embeddings, caches, or transient logs

## Exclusions

- `/root/.hermes/.env`
- provider auth exports such as `auth.json`
- raw session data or database dumps
- transient logs, caches, or scratch files

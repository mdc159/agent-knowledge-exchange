# Restore Notes

To restore this curated outer Hermes snapshot:

1. recreate the runtime home at `/root/.hermes` on the target node and ensure
   the service account can read it
2. restore `AGENTS.md`, `SOUL.md`, `config.yaml`, and `honcho.json` from this
   snapshot into the runtime's defining file locations
3. recreate secrets outside Git, including `/root/.hermes/.env`, provider API
   keys, and any required OAuth or auth exports
4. reapply the node-specific model/provider pin in `config.yaml` and confirm it
   matches the external secret source before launch
5. recreate or update `hermes-dashboard.service` so it points at the restored
   runtime home and launcher path
6. start or reload the service and verify the runtime is reachable through the
   expected private tailnet access path
7. confirm the memory backend still uses the isolated outer-runtime boundary
   and does not reuse Paperclip-internal Hermes session stores
8. do a smoke check with a host-scoped prompt and verify no raw session data,
   transient logs, or caches were restored from this backup

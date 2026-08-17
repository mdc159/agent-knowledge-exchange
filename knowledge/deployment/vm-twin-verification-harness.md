# VM-twin physical verification before PRs

**Date:** 2026-08-17
**Origin:** shizzle PR #7 (remote mixer surface). Stubbed and in-process tests
were green; the user asked "did you physically test everything with a playing
sample?" — and the physical run found real bugs the stubs could not.

## The pattern

Keep a production-shaped VM twin (same compose topology, real TLS, real auth,
real media) as a standing verification target, and run a full-stack
browser-level test against it before opening the PR. For shizzle this is the
SHIZZLE-TEST VMware guest (host-only network, no internet — images and
bundles ferried by scp; recipe in the repo at `deploy/vps/vm-test/`), with a
VMware snapshot of the working stack so spin-up is revert-plus-one-command.

Assert physical effect, not proxy state, where the app exposes sensors: the
shizzle player publishes per-stem post-gain PCM (`signalRmsDbfs`), so "remote
mutes vocals" is verified as *measured silence on that channel while the
master bus keeps carrying signal* — in a production build, over the real
relay, with a real track playing.

## What the physical layer caught that stubs/in-process tests missed

1. **`credentials: 'omit'` on a media fetch** — worked in every stubbed test;
   failed the moment a real Secure cookie had to ride a real HTTPS request.
2. **Secure-cookie auth silently dead over HTTP** — a test stack must have
   real TLS (pinned self-signed cert; Caddy's `tls internal` with a catch-all
   `:443` site does not wire a connection policy for SNI-less IP access —
   pin explicit cert/key files instead).
3. **Stale test-target images**: after a review loop repaired backend auth,
   the VM still ran the pre-repair API — new client + old server produced a
   spurious failure. Always redeploy the *matched* candidate stack (api +
   client together) before judging a physical run.

## Interplay with a review-convergence loop

E2B-style disposable sandboxes stay the default execution surface for
reproducing and repairing code-level findings. The VM is the escalation tier
for what sandboxes cannot do (real media playback, WebSocket relays across
browser contexts, cookie/TLS semantics, multi-service topology). Route it
through the finding ledger — the driver flags "needs physical verification",
the orchestrator runs the VM spec — rather than letting the review driver
drive a shared VM itself. In PR #7 this combination took Greptile 3/5 → 5/5
across three reproduced P1s, with the final one (a stale-command race)
fixed and then proven on the VM before the confirmation review.

## Distilled rules

- A green stub suite plus a green unit suite is not a physical test; budget
  one real-stack run per behavior-bearing PR.
- The test stack must match production semantics where the bug classes live:
  TLS on, auth on, production build (dev-only test hooks absent — use
  production-exposed observability instead).
- Ship client and server from the same candidate SHA to the test target.
- Snapshot the working test stack immediately; the snapshot is the spin-up.

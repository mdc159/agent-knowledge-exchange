# Paperclip Access and CLI Auth on a Headless VPS

This note captures the most reusable operational lessons learned while trying to operate a live Paperclip deployment from a VPS.

For a quick guide to the Paperclip notes in this directory, see
[Paperclip Knowledge](README.md). If you are configuring a company or checking
runtime wiring rather than access, use
[Paperclip Company Setup](paperclip-company-setup.md).

## Executive Summary

The most important lesson is simple:

Infrastructure access is not the same thing as Paperclip control-plane access.

A Paperclip instance can be:

- installed correctly
- healthy on localhost
- reachable over Tailscale
- inspectable from the filesystem and source tree

and still not grant board/company operations until real Paperclip authentication is established.

## Known Environment Shape

Observed on the reference VPS:

- Paperclip install path: `/opt/paperclip-pilot/paperclip`
- service: `paperclip.service`
- local URL: `http://localhost:3100`
- private remote URL: `https://paperclip.tailfedd3b.ts.net`
- runtime data/config/backups: `/root/.paperclip`
- Postgres container: `paperclip-db`
- Caddy disabled
- public firewall exposure limited; SSH allowed publicly

## Core Access Boundary

When Paperclip runs in authenticated mode:

- local shell access does not imply board access
- localhost reachability does not imply company access
- browser access from the user’s device does not imply the agent/browser session is authenticated

Typical symptoms:

- browser redirects to `/auth`
- API calls return `401 Unauthorized`
- board-only routes return `403 {"error":"Board access required"}`

This usually means the service is alive but the current actor lacks board credentials.

## Practical Distinction: Infra vs Auth

Treat these as separate checks.

1. Is the service up?
2. Do we have authenticated board access?

An agent can often do all of the following before Paperclip auth is solved:

- inspect `paperclip.service`
- call `/api/health`
- inspect ports, logs, Tailscale, and runtime directories
- read source code and route definitions
- run repo-local CLI commands

But that still may not allow:

- administering the company
- accessing board-only API routes
- managing plugins, secrets, approvals, or company state

## Current CLI Auth Flow

The current Paperclip CLI auth flow uses:

```sh
paperclipai auth login
```

If the binary is not globally installed, the repo-local form is:

```sh
pnpm --dir /opt/paperclip-pilot/paperclip/cli dev auth login --api-base http://localhost:3100
```

The flow is:

1. CLI creates a challenge
2. CLI prints an approval URL
3. a signed-in board user opens the URL
4. board approves access
5. CLI polls for completion
6. CLI stores local auth material

## Credential Storage

Current credential storage path:

```text
~/.paperclip/auth.json
```

An older planning reference mentioned `~/.paperclip/credentials`, but the current implementation uses `~/.paperclip/auth.json`.

## Headless VPS Failure Mode

The most reusable Paperclip-specific lesson from practice was a headless auth failure.

Observed behavior:

- the CLI successfully generated an approval URL
- the CLI then tried to launch a browser with `xdg-open`
- on the VPS, `xdg-open` was missing
- the CLI exited with `spawn xdg-open ENOENT`

Why this matters:

Browser approval alone is not enough if the CLI process exits before it finishes polling and writing `~/.paperclip/auth.json`.

A new operator can easily think:

“the approval page appeared, so auth must be done.”

That assumption is wrong if the CLI crashed before persisting credentials.

## Workaround for Headless CLI Auth

A practical workaround is to place a fake `xdg-open` earlier in `PATH` so the CLI stays alive long enough to keep polling:

```sh
mkdir -p /tmp/fakebin
printf '#!/bin/sh\nexit 0\n' >/tmp/fakebin/xdg-open
chmod +x /tmp/fakebin/xdg-open
PATH="/tmp/fakebin:$PATH" pnpm --dir /opt/paperclip-pilot/paperclip/cli dev auth login --api-base http://localhost:3100
```

Then verify actual success:

```sh
test -f ~/.paperclip/auth.json && echo OK || echo MISSING
```

Do not declare victory until the auth file exists and authenticated operations work.

## Useful Source Breadcrumbs

These codepaths were useful for understanding the real auth model:

- `cli/src/commands/client/auth.ts`
- `cli/src/client/board-auth.ts`
- `cli/src/config/home.ts`
- `server/src/routes/access.ts`
- `ui/src/pages/CliAuth.tsx`
- `server/src/middleware/auth.ts`

## Recommended Troubleshooting Sequence

1. Check service health
   - `systemctl status paperclip.service --no-pager -l`
   - `curl -sS -m 5 -w '\nHTTP_CODE:%{http_code}\n' http://localhost:3100/api/health`

2. Check deployment/auth posture
   - inspect whether health output reports authenticated deployment mode
   - probe a board endpoint and record whether it fails with `401` or `403`

3. Separate infra from auth in your diagnosis
   - if health works but board endpoints fail, say so explicitly
   - do not claim full Paperclip access

4. Use CLI auth if appropriate
   - `paperclipai auth login`
   - or repo-local `pnpm --dir /opt/paperclip-pilot/paperclip/cli dev auth login --api-base http://localhost:3100`

5. On a headless VPS, anticipate `xdg-open` failure
   - if needed, use the fake-`xdg-open` workaround
   - keep the CLI alive while a human approves in a real browser

6. Verify persisted auth
   - check `~/.paperclip/auth.json`
   - verify with a follow-up authenticated operation

## Related Knowledge

See also:

- [Paperclip Knowledge](README.md)
- [Paperclip Company Setup](paperclip-company-setup.md)
- skill: `paperclip-board-cli-auth`
- skill: `paperclip-vps-access-troubleshooting`
- skill: `honcho-paperclip-hermes-memory-architecture`

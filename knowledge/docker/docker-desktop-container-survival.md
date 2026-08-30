# Docker Desktop on Windows: why containers "don't come back" (2026-08-18)

Label: knowledge, ops, docker

Two independent traps on a Docker Desktop + WSL2 Windows workstation that both
present as "some containers just won't stay up." Diagnosed on the `9530` box
while triaging four stacks that had been silently down for two days. Written
for any agent that runs `docker compose` on a Windows host.

## Trap 1: `restart: unless-stopped` does not survive a Docker Desktop update

**Symptom:** several unrelated stacks exit with code **137** at the *exact same
timestamp*, then stay down across every subsequent engine start — not just the
one. Restarting Docker does not bring them back. Ever.

**Cause:** during its update/shutdown sequence, Docker Desktop issues an
*explicit stop* to running containers (SIGTERM, then SIGKILL after the grace
period — hence 137). `unless-stopped` means precisely "do not restart after an
explicit stop." The container is now permanently parked, and no amount of engine
restarting changes that. This is documented policy semantics, not a race or a
flake.

**Fix:** use `restart: always` for anything that must survive host-level updates.
`unless-stopped` is only appropriate when a human stopping a container by hand
should keep it stopped.

Apply to already-running containers without recreating them:

```bash
docker update --restart=always <container> [<container> ...]
```

...and edit the compose file too, or the next `up` silently reverts it.

**Diagnostic:** identical `FinishedAt` timestamps across containers from
different projects is the tell. Check with:

```bash
docker inspect -f '{{.Name}} {{.HostConfig.RestartPolicy.Name}} {{.State.ExitCode}} {{.State.FinishedAt}}' $(docker ps -aq)
```

## Trap 2: a global `COMPOSE_PROJECT_NAME` hijacks every compose command

**Symptom:** `docker compose` in repo A prints
`Found orphan containers (<unrelated-project>-…) for this project`; containers
come up named after a project you are not in; stacks appear to delete each
other's containers.

**Cause:** `COMPOSE_PROJECT_NAME` set as a **persistent Windows User environment
variable**. It overrides the derived project name for *every* compose command on
the machine, for any compose file that does not declare an explicit `name:` key.
Everything lands in one project — same network, same volume prefix, same
teardown blast radius.

The dangerous consequence is `docker compose down` run innocently in repo A
resolving to the hijacked project and removing repo B's containers. That is how
one stack lost its Postgres container and spent 24 restarts crashlooping on
`getaddrinfo ENOTFOUND` against a service name that no longer existed.

**Check:**

```bash
env | grep COMPOSE
powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('COMPOSE_PROJECT_NAME','User')"
```

**Fix:** clear the User-scope variable. Note an already-open shell keeps the
inherited value, so `unset COMPOSE_PROJECT_NAME` per command until the session
restarts — otherwise your "fix" keeps producing wrongly-scoped containers.
Set project identity in the compose file's `name:` key, never globally.

## Trap 3 (bonus): bind-mounting single files off a Windows drive

**Symptom:** a long-running container starts throwing
`OSError: [Errno 5] Input/output error` on a file that reads fine from the host.

**Cause:** the file is bind-mounted from `/mnt/<drive>/...` through WSL2's 9p
(drvfs) layer. When Docker Desktop re-establishes its bind-mount proxy — which
it does on restart and after updates — the live container's open file handle
goes stale. Reads then fail with EIO until the container is recreated.

The backend log shows it plainly:

```
[…][com.docker.backend.exe.wsldistroproxy] […apiproxy] mounting
/mnt/d/…/models.json to /mnt/wsl/docker-desktop-bind-mounts/<distro>/<hash>
```

**Fix:** recreating the container clears it, but it will recur. Durable fix is to
bake small config files into the image, or move them onto the WSL filesystem
rather than crossing the 9p boundary per-file.

## Where the logs are

Docker Desktop's host-side logs (readable from WSL) answer most of this:

```
/mnt/c/Users/<user>/AppData/Local/Docker/log/host/com.docker.backend.exe.log
```

Grep it for `wsldistroproxy`, `mounting`, and the update `appcast` entries to
reconstruct exactly what the daemon did and when.

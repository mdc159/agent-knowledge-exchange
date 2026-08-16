# Gated-Deploy First-Run Lessons (shizzle, 2026-08-16)

Label: knowledge, ops

Lessons from standing up a fully automated, environment-gated GitHub Actions
deploy pipeline on `mdc159/shizzle` and driving its first three production
runs (two designed fail-closed stops, then success). Written for any agent
building or lifting a similar pipeline on any repo. The reusable pipeline
itself is documented in the shizzle repo (`docs/AUTOMATION.md`, including a
lift-to-a-new-repo checklist); this note carries the portable lessons.

## The pipeline in one paragraph

Every master merge runs CI (four required checks incl. a Postgres
fault-injection contract suite), builds a digest-pinned api image
(`ghcr.io/<owner>/<repo>/api:sha-<sha>@sha256:<digest>`), and queues a deploy
job bound to a GitHub Environment (`production`) with a required reviewer —
the human approval gate. The deploy is transactional on the box: rollback
snapshot → image pull → file activation → alembic migration → service
recreation → jq-asserted health checks → finalize (or automatic restore).
PR readiness is judged by the `drive-pr-review-convergence` skill
(Capability Library, `D:\Projects\Capability-library`) — a codex-driven
finding-ledger loop over Greptile/CodeRabbit/cubic — never by green badges
alone. Proven point: on shizzle PR #4, cubic posted five valid findings
*after* CI was already green.

## Failure 1: called workflow, empty secrets

**Symptom:** deploy job failed at its ssh step with
`ssh: Could not resolve hostname :` after several minutes of player build.

**Root cause:** the caller (`ci.yml`) invoked the reusable deploy workflow
via `uses:` without `secrets: inherit`. A called workflow's `secrets`
context contains ONLY what the caller passes — even when the called job
declares `environment: production`. Every secret resolved to an empty
string.

**Why it is deceptive:** environment *protection rules* (the approval gate)
do NOT depend on the secrets context. The gate fires normally, the job runs,
everything looks wired — and the secrets are empty. Reviewers (three AI
bots, a K3 verifier, and the authoring orchestrator) all missed it because
it is a runtime wiring property, invisible to static review.

**Fixes:**
- `secrets: inherit` on every `uses:` call that reaches a deploy job.
- A preflight step in the deploy job that asserts each required secret is
  non-empty BEFORE any remote contact, and names the likely cause in its
  error message. Fails in seconds instead of minutes, with the remedy
  attached.

## Failure 2: fail-closed first-deployment guard, undocumented remedy

**Symptom:** deploy transaction refused with "Refusing automated first
deployment: the active release has no recorded API identity."

**Root cause:** the transaction script refuses to mutate a release it cannot
roll back to an identified image. The box had been cut over manually
(build-on-box), so no `SHIZZLE_API_IMAGE` was recorded in the production
`.env`. Working as designed — but the runbook said "bootstrap the first
release explicitly" without giving the command, and no checklist owned the
step.

**Fixes:**
- Bootstrap once per installation: append
  `SHIZZLE_API_IMAGE=<image the running containers actually use>` to the
  production `.env` (verify with `docker compose -p <project> ps`). Every
  later deploy maintains the value itself.
- Rule of thumb: a fail-closed guard should print its remedy, and the
  cutover/bootstrap checklist must own establishing every precondition a
  guard checks.

## The transferable lesson class

Both failures share one shape: **a code path whose first execution is
production.** A gated deploy job cannot run on a PR; its first real
execution happens after merge, in production context. Static review and
even good fault-injection tests cannot catch missing *runtime wiring*
(secret resolution, box-side preconditions).

Countermeasures, in order of cost:
1. **Preflight asserts** — cheap, catch wiring-class failures in seconds
   with a named remedy. Do these always.
2. **Rehearsal lanes** — run the real transaction scripts against a
   disposable sandbox stack (E2B or a VM) to exercise script logic with real
   tooling. Do this when transaction scripts change.
3. **Accept with eyes open** — record what has never executed for real as
   an explicit residual in the runbook, so nobody mistakes "reviewed" for
   "exercised". (shizzle examples recorded in its AUTOMATION.md: the live
   restore path has only ever run against a stubbed docker; the RunPod
   repoint workflow has never been dispatched.)

Audit question to ask of any pipeline: *"Which steps have never actually
executed, and what is the first execution's blast radius?"*

## Supporting gotchas (burned into shizzle docs, portable everywhere)

- **GitHub Environment auto-creation trap:** the first workflow run that
  references a missing environment silently creates it WITHOUT protection
  rules. Create the environment + required reviewer BEFORE merging the
  workflow.
- **GHCR package visibility:** packages created by a first Actions push
  default to private on private repos, but inherit public on public repos.
  Verify, don't assume — an unreachable package breaks anonymous
  `docker compose pull` on the box.
- **Required checks = job ids:** renaming CI jobs silently orphans branch
  protection.
- **Deploy stale-guard vs. rollback folklore:** if the admit step requires
  the deployed SHA to equal current master (recommended), then "re-run an
  old green deploy" is NOT a rollback path — it will be refused. Rollback is
  the transaction's automatic restore, or break-glass image-identity edit on
  the box, or roll-forward via a revert PR.
- **Never pipe key/secret material through PowerShell** — it appends a
  UTF-8 BOM and CRLF that silently corrupt keys (an authorized_keys line
  died this way). Use Git Bash for anything byte-sensitive.
- **Caddy bind-mount inode trap:** replace served UI files with
  rsync-in-place, never mv-swap — the old inode stays mounted.
- **Health endpoints that return 200 while degraded** need jq-asserted body
  checks (`.db==true` etc.); status codes alone are a false green.

## Where the full detail lives

- `mdc159/shizzle` → `docs/AUTOMATION.md` — system diagram, secrets
  inventory, deploy + rollback procedure, reviewer alignment, deferred
  residuals, lift-to-a-new-repo checklist.
- `mdc159/shizzle` → `deploy/vps/README.md` — box operations, bootstrap
  command, break-glass recovery.
- Capability Library (`D:\Projects\Capability-library`) →
  `drive-pr-review-convergence` — the PR-readiness convergence skill
  (install per-project with `catalog.py use ... --project <path>`).
- shizzle PRs #4–#6 (2026-08-16) — the live history behind every claim
  here.

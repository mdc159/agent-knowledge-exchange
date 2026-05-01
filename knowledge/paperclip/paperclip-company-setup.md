# Paperclip Company Setup

This note captures the practical lessons from observed Paperclip company setups
and the first runtime inspection work done against a live Paperclip VPS.

## What Paperclip Actually Owns

Paperclip is the system of record for company state:

- org structure
- issues and goals
- routines
- approvals and governance
- adapter assignment per agent

That means a "company" is more than memory. It is company-scoped state plus
the runtime wiring behind each agent.

## Agent Wiring Pattern

Observed Paperclip agents use adapter types such as:

- `hermes_local`
- `codex_local`
- `claude_local`

In practice, `local` means the adapter expects to invoke a local runtime or CLI
on the same host or inside the Paperclip execution environment. It does not
prove there is a separate daemon per agent.

## Important Runtime Finding

In the inspected VPS:

- `codex_local` worked through a local `codex` CLI on `PATH`
- `claude_local` depended on a local `claude` CLI
- `hermes_local` depended on a local `hermes` CLI

The CEO agent configured as `hermes_local` failed because the Paperclip runtime
could not resolve `hermes` on `PATH`, even though Hermes existed on the host in
`/root/.local/bin/hermes`.

## Operational Lesson

If Paperclip is expected to run `hermes_local`, one of these must be true:

1. the Paperclip execution environment contains a resolvable `hermes` CLI
2. a supported wrapper/gateway layer is implemented and documented

Do not assume host installation alone is enough.

## Fresh-Node `hermes_local` Proof Findings

Confirmed on `srv1264451`:

- Paperclip can execute `hermes_local` inside the Paperclip container.
- The successful proof used a company-scoped home at:
  `/paperclip/instances/default/companies/c754b277-80cc-47f3-8d54-90d02ff41b2d/hermes-home`
- Hermes loaded its projected runtime env from that isolated home, not from the
  outer host-native Hermes home.
- The Paperclip issue loop produced an agent-authored comment from a
  `hermes_local` run.
- A second proof used a fresh company
  `ab6896c0-a9a8-473d-943e-88012137055c`, agent
  `8a5e57dc-ebe9-435b-a9d0-716c8826a4c6`, issue `HERA-1`, and run
  `3a2b0317-bee0-48fb-8cb1-2b4590bb9a6f`.
- The second proof kept `adapterConfig.env.HERMES_HOME` persisted as a Paperclip
  env binding object and succeeded after Paperclip passed the resolved runtime
  config into the adapter.

New failure modes found during the proof:

- Installing Hermes with `uv` as `root` can leave the venv launcher pointing at
  a Python interpreter under `/root/.local/share/uv/...`. If `/root` is not
  executable by the Paperclip runtime user, `hermes` is on `PATH` but fails with
  `Permission denied`.
- Host-side preparation of a company Hermes home must leave the company tree
  writable by the Paperclip runtime user. Otherwise agent creation can insert
  the agent row and then fail while materializing managed instructions under
  `/paperclip/instances/<instance>/companies/<company>/agents`.
- Paperclip persists adapter env values as secret/env binding objects. Local
  adapters need the resolved runtime config; passing persisted bindings through
  directly can produce invalid environment values such as `[object Object]`.
- `hermes-paperclip-adapter` builds its default prompt from `ctx.config`
  (`taskId`, `taskTitle`, `taskBody`, etc.). If Paperclip only places those
  fields in heartbeat context, the adapter can fall into its no-task heartbeat
  branch even for an issue-assignment wake.

## Company-Scoped Isolation

Accepted direction:

- outer Hermes keeps its own runtime home
- inner Paperclip Hermes runs must use a company-scoped `HERMES_HOME`
- memory transfer between companies is explicit, not ambient

Current accepted company path shape:

`/paperclip/instances/<instance-id>/companies/<company-id>/hermes-home`

## Setup Guidance

When creating a Paperclip company:

1. create the company and org roles in Paperclip
2. assign adapter types deliberately
3. verify each required local runtime exists where Paperclip can execute it
4. set company-scoped homes for runtimes that accumulate memory or state
5. pin important models for approval-bearing roles

## Known Failure Modes

- Paperclip agent says a runtime is `local`, but the CLI is not on `PATH`
- Codex auth is present only in the host root home and not accessible to the
  Paperclip execution environment
- `hermes_local` accidentally points at outer Hermes state instead of a
  company-local runtime home
- provider/model choices drift without being treated as role changes

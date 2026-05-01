# Paperclip Company Setup

This note captures the first real Paperclip company setup and repair lessons from
an agent that inspected and debugged a live Paperclip VPS.

For a quick guide to the Paperclip notes in this directory, see
[Paperclip Knowledge](README.md). If you are trying to authenticate to an
existing deployment or diagnose board access problems, use
[Paperclip Access and CLI Auth](paperclip-access-and-cli-auth.md).

## What Paperclip Actually Owns

Paperclip is the system of record for company state:

- org structure
- issues and goals
- routines
- approvals and governance
- adapter assignment per agent
- provider/model choice per role when it is explicitly pinned

That means a "company" is more than memory. It is company-scoped state plus
the runtime wiring behind each agent.

## First-Hand Setup Shape

The inspected company used local adapters for the real working paths:

- `codex_local`
- `claude_local`
- `hermes_local`

In practice, `local` means the adapter expects to invoke a local runtime or CLI
on the same host or inside the Paperclip execution environment. It does not
prove there is a separate daemon per agent.

Observed runtime expectations on the VPS:

- `codex_local` worked through a local `codex` CLI on `PATH`
- `claude_local` depended on a local `claude` CLI
- `hermes_local` depended on a local `hermes` CLI

The first real failure was the CEO agent configured as `hermes_local`. Paperclip
could not resolve `hermes` on `PATH`, even though Hermes existed on the host in
`/root/.local/bin/hermes`.

## Adapter Choices

What worked or was accepted in the inspected setup:

- use `codex_local` when the Paperclip runtime can actually invoke `codex`
- use `claude_local` when the Paperclip runtime can actually invoke `claude`
- use `hermes_local` only when the Paperclip runtime can actually invoke
  `hermes` and the runtime home is intentionally company-scoped

Operational lesson: if Paperclip is expected to run `hermes_local`, one of these
must be true:

1. the Paperclip execution environment contains a resolvable `hermes` CLI
2. a supported wrapper or gateway layer is implemented and documented

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

## Model Choices

The first real setup lesson is not a specific model string. It is that model
choice must be treated as part of the company definition, especially for
approval-bearing roles.

Use these rules:

- pin models deliberately for CEO or other approval-bearing roles
- record provider plus model together, not just the adapter type
- treat a provider/model change as a role change, not harmless drift
- do not trust ambient defaults when creating or repairing a company

If a company is misbehaving, verify model pinning even when the obvious symptom
looks like a runtime failure. Repair work is slower when adapter mismatches and
model drift are debugged separately.

## Company-Scoped Isolation

Accepted direction:

- outer Hermes keeps its own runtime home
- inner Paperclip Hermes runs must use a company-scoped `HERMES_HOME`
- memory transfer between companies is explicit, not ambient

Current accepted company path shape:

`/paperclip/instances/<instance-id>/companies/<company-id>/hermes-home`

## Create or Repair Checklist

When creating or repairing a Paperclip company:

1. create the company and org roles in Paperclip
2. assign adapter types deliberately for each role
3. verify each required local runtime exists where Paperclip can execute it
4. verify auth is present inside the Paperclip execution environment, not only in
   the host root home
5. set company-scoped homes for runtimes that accumulate memory or state
6. pin important provider/model pairs for approval-bearing roles
7. run one issue loop end to end before trusting autonomy

## Known Failure Modes

- Paperclip agent says a runtime is `local`, but the CLI is not on `PATH`
- the CLI exists on the host, but not in the Paperclip execution environment
- Codex auth is present only in the host root home and not accessible to the
  Paperclip execution environment
- `hermes_local` accidentally points at outer Hermes state instead of a
  company-local runtime home
- provider/model choices drift without being treated as role changes
- a company is declared "set up" before an end-to-end issue loop proves the
  wiring works

## What Should Be Templated Next

The next reusable template should remove the wiring guesswork that caused the
first repair pass:

- a company role matrix with role name, adapter type, provider, and pinned model
- a runtime preflight checklist that proves `codex`, `claude`, and `hermes` are
  resolvable from the Paperclip execution environment
- a generated company-scoped runtime home/env layout for Hermes-like stateful
  runtimes
- a post-create verification checklist that runs one real issue loop and records
  the first failure before the company is considered healthy

## Related Knowledge

See also:

- [Paperclip Knowledge](README.md)
- [Paperclip Access and CLI Auth](paperclip-access-and-cli-auth.md)

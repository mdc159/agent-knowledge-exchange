# Paperclip Company Setup

This note captures the practical lessons from observed Paperclip company setups,
live runtime inspection work, and repeated fresh-node `hermes_local` proofs on
`srv1264451`.

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

## Fresh-Node Proof Status

Fresh-node `hermes_local` proofs later succeeded twice on `srv1264451`, first
for `HER-1` and then again for `HERA-1` with a different company and agent.

What the repeated proofs established:

- `hermes_local` works on a fresh node when Paperclip installs Hermes inside its
  execution environment
- isolated per-company `HERMES_HOME` works and was confirmed by agent-authored
  comments along with the expected `config.yaml`
- the assignment wake path works through the normal heartbeat adapter execution
  path
- API-persisted `adapterConfig.env.HERMES_HOME` bindings work once Paperclip
  resolves them to runtime values before invoking the adapter

## Operational Lesson

If Paperclip is expected to run `hermes_local`, one of these must be true:

1. the Paperclip execution environment contains a resolvable `hermes` CLI
2. a supported wrapper/gateway layer is implemented and documented

Do not assume host installation alone is enough.

## Critical Adapter Contract

For the proven `hermes_local` path to keep working:

- the Paperclip image must install Hermes inside the execution environment
- both the Hermes launcher and its Python interpreter must be executable by the
  Paperclip runtime user
- company Hermes-home preparation must `chown` the company tree to the
  Paperclip runtime UID/GID
- Paperclip must pass resolved adapter config and env values into local
  adapters; unresolved binding objects such as `[object Object]` are invalid
- assignment wakes must surface `taskId`, `taskTitle`, `taskBody`, `commentId`,
  and `wakeReason` into adapter config because `hermes-paperclip-adapter`
  builds its default prompt from `ctx.config`

If the assignment wake fields are omitted, the adapter can fall back to its
no-task heartbeat branch.

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
5. ensure the Paperclip runtime user owns those runtime-home trees
6. verify local adapters receive resolved config/env values plus assignment-wake
   task metadata when they build prompts from runtime config
7. pin important models for approval-bearing roles

## Known Failure Modes

- Paperclip agent says a runtime is `local`, but the CLI is not on `PATH`
- Codex auth is present only in the host root home and not accessible to the
  Paperclip execution environment
- `hermes_local` accidentally points at outer Hermes state instead of a
  company-local runtime home
- company-scoped Hermes state exists, but ownership prevents the Paperclip
  runtime user from executing or writing inside it
- Paperclip passes unresolved binding objects such as `[object Object]` into a
  local adapter instead of resolved config/env values
- assignment wakes omit task fields from adapter config, so the adapter falls
  back to a no-task heartbeat branch
- provider/model choices drift without being treated as role changes

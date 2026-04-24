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

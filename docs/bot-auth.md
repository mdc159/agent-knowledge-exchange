# Bot / Machine Credential Setup

## Recommended v1 Setup

Use one dedicated fine-grained GitHub token or bot credential for this repo.

Required permissions:

- Contents: read/write
- Issues: read/write
- Pull requests: read/write
- Metadata: read-only

## Accepted Distribution Pattern

Use a host-local auth file mounted read-only into selected trusted runtimes.

Operational shape:

- keep one dedicated repo bot credential per trusted node outside Git
- store it in an operator-managed host-local auth file
- mount that file read-only only into runtimes that need to mutate this repo
- do not mount it into general-purpose or untrusted runtimes

## Why This Pattern

This is preferred over:

- per-node secret injection into every runtime, which creates secret sprawl and
  drift
- a shared secret manager reference, which adds runtime dependency and failure
  modes that this repo does not otherwise require

Do not commit it here.

## Recommended Uses

Agents may use the credential to:

- clone and pull
- create branches
- push PR branches
- open issues
- open pull requests

## Operational Rule

Do not hand out personal broad classic PATs to every agent runtime.

Use one dedicated credential for this repo unless there is a stronger isolation
reason to split by agent.

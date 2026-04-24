# Bot / Machine Credential Setup

## Recommended v1 Setup

Use one dedicated fine-grained GitHub token or bot credential for this repo.

Required permissions:

- Contents: read/write
- Issues: read/write
- Pull requests: read/write
- Metadata: read-only

## Storage Rule

Store the credential in each trusted runtime as a secret.

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

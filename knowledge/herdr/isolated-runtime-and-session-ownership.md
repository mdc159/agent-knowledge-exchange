# Isolated HERDR Runtime and Session Ownership

## Purpose

An application that embeds HERDR should own a private HERDR runtime. It should
not discover and reuse whichever HERDR session happens to be running for the
operator.

This boundary prevents two independent owners from sharing process lifetime,
session names, panes, sockets, configuration, or cleanup behavior. It also lets
the application use HERDR for general parallel Pi-agent work, not only for one
feature such as cognitive memory or research synthesis.

## The failure mode

Attaching an embedded application to a global HERDR instance creates ambiguous
ownership:

- the operator may stop or reconfigure the instance while application work is
  running;
- application cleanup may close panes or sessions that belong to the operator;
- session names and environment variables can collide;
- a global binary upgrade can change the protocol beneath a running application;
- provenance cannot reliably distinguish application work from unrelated work.

Process discovery is therefore not a safe ownership mechanism. A reachable
HERDR endpoint proves only that an instance exists, not that the application is
authorized to control it.

## Ownership model

| Concern | Recommended owner | Durable? |
| --- | --- | --- |
| Bundled HERDR distribution and active version | Host application | Yes |
| HERDR socket or endpoint | One application runtime instance | No |
| HERDR workspace, tab, pane, and process lifecycle | HERDR | No |
| Agent definitions and routing manifests | Host application or project | Yes |
| Approvals, budgets, evidence, artifacts, and provenance | Host application | Yes |
| Agent output checkpoints needed for recovery | Host application | Yes |
| Jupyter service environment | Host application | Yes, but replaceable |
| Project Python kernels and dependencies | Project | Yes |

HERDR is the live execution fabric. The host application remains the durable
control plane and system of record.

## Isolation contract

An embedded integration should satisfy all of these conditions:

1. **Private distribution.** Launch a pinned HERDR binary from an
   application-managed runtime directory. Do not resolve the executable from a
   user's shell `PATH` unless they explicitly select an external-runtime mode.
2. **Private endpoint.** Allocate a dedicated socket, named pipe, or loopback
   endpoint and pass it explicitly to every child process.
3. **Private state.** Give the instance separate configuration, cache, plugin,
   log, and session-state directories. Do not inherit global HERDR paths.
4. **Explicit identity.** Stamp each workspace and dispatch with an
   application instance ID, project ID, job ID, and route ID. These identifiers
   should be opaque and must not contain credentials.
5. **Owned process tree.** Track the exact server process and every child the
   application launches. On Windows, use process-tree or Job Object semantics
   where practical so shutdown does not leave orphaned panes.
6. **No implicit attachment.** Refuse to adopt an endpoint merely because it is
   reachable. External attachment should be a separate, visible, opt-in mode
   with reduced cleanup authority.
7. **Bounded cleanup.** Close only workspaces and processes bearing the current
   application's identity. Never use broad name matching to kill processes.

A development override can expose a system HERDR binary, but it should remain
explicit and should not change the production default.

## Distribution and upgrades

Pinning and upgradeability are compatible. Treat the embedded runtime as a
versioned application dependency:

1. ship or download a versioned distribution manifest;
2. verify the archive and executable hashes before activation;
3. unpack into a new version directory rather than overwriting the active one;
4. probe the binary version and protocol compatibility;
5. run an isolated smoke session against a private endpoint;
6. switch the active-version pointer only after verification;
7. retain the previous known-good version for rollback;
8. remove old versions only when no owned process is using them.

Version agent definitions separately from the HERDR binary. An application may
upgrade routing definitions without replacing HERDR, or upgrade HERDR while
retaining a compatible definition set. Record both versions with each durable
job so recovery never depends on "whatever is installed now."

Treat protocol compatibility as a capability check, not a version-string
assumption. Installed command wrappers can lag the underlying protocol schema.
Feature-detect the live commands and fields before requesting optional pane,
layout, popup, or event behavior.

## General Pi-agent parallelism

HERDR can execute any bounded Pi-agent graph. Cognitive-memory workflows are one
consumer, not the organizing boundary.

A reusable builder/verifier dispatch looks like this:

1. Freeze a task brief, inputs, constraints, and acceptance tests.
2. Create independent route records with explicit provider and model IDs.
3. Launch builders in separate HERDR panes or workspaces.
4. Give verifiers the frozen brief, builder result, and primary evidence. Do not
   give them only the builder's narrative.
5. Collect structured outputs, timing, failures, and dissent into durable host
   records.
6. Close the live HERDR resources after terminal output is recorded.
7. Retry from a recorded checkpoint or create a new route; do not silently
   mutate the history of a failed route.

Two builder/verifier combinations that have worked well in reviewed practical
use are:

| Builder | Verifier | Useful characteristic |
| --- | --- | --- |
| GLM 5.2 | Kimi K3 | Heterogeneous cross-check with different model behavior |
| GLM 5.2 | GPT-5.6 Sol | Strong independent verification for higher-assurance work |

These are operating examples, not universal benchmark conclusions. Record the
exact provider route, model identifier, model revision when available, prompt
contract, and evaluation result before promoting any pairing to a project
default.

Parallelism should be bounded by explicit concurrency, time, cost, data-egress,
and approval policy. The host application decides whether a route is permitted;
HERDR executes the approved route without becoming a second policy database.

## Durable state and live state

Do not use a HERDR session as the only record of work. Live session state can
disappear during restart, upgrade, operator intervention, or machine failure.

Persist outside HERDR:

- the immutable task brief and input hashes;
- selected agent-definition and runtime versions;
- approvals and resource limits;
- route identity and lifecycle events;
- checkpoints and terminal outputs;
- evidence references, dissent, and final verdicts;
- enough metadata to decide whether work may be resumed or must be replayed.

Derive liveness from a fresh HERDR observation. Never persist a claim that a
pane is currently running as durable truth. After restart, reconcile owned
workspaces against durable route records and classify missing live work
explicitly instead of fabricating continuity.

## Jupyter and project environments

The Jupyter service and the notebook kernel have different ownership needs.

- The **application-managed service environment** contains the pinned
  JupyterLab or gateway packages, collaboration extensions, and integration
  server. It exists to provide a stable service contract and can be replaced as
  part of an application upgrade.
- A **project kernel environment** contains the user's scientific packages and
  is selected per notebook or project. It may be managed by UV, Conda, or
  another supported tool.

UV is a strong default for fast Python dependency management. Conda remains
useful when a project depends on non-Python native libraries, compiled
scientific stacks, CUDA variants, or established Conda environment files.
Supporting Conda kernels does not require installing the HERDR runtime or the
Jupyter control service inside the Conda environment.

Register kernels by explicit environment identity and executable path. Do not
activate a shell globally or let one project's environment replace the
application service environment.

## Windows lifecycle considerations

Windows integrations should test the real packaged lifecycle, not only direct
command-line launches:

- verify terminal panes under ConPTY, including resize and Unicode input;
- pass private endpoint and state paths explicitly because GUI processes often
  have a different environment from interactive shells;
- detect stale lock files separately from live owned processes;
- terminate the owned process tree on normal exit, crash recovery, and upgrade;
- avoid killing by executable name because a global HERDR instance may be
  running simultaneously;
- verify restart and resume with the previous application instance gone;
- exercise paths containing spaces and non-administrator installations;
- confirm an application upgrade does not modify the user's global HERDR
  installation or sessions.

## Verification checklist

Before shipping an embedded integration, verify:

- a global HERDR instance and the application-owned instance run concurrently;
- each instance has a different endpoint and state root;
- the application creates work only in its owned instance;
- stopping either instance does not interrupt the other;
- application shutdown removes only its owned live resources;
- a failed or incompatible runtime upgrade rolls back cleanly;
- agent-definition upgrades are traceable independently of runtime upgrades;
- at least two Pi routes can run concurrently and retain distinct outputs;
- a verifier failure remains visible and does not promote the builder result;
- Jupyter service restart does not replace or mutate project kernel environments;
- durable job records survive HERDR loss and reconcile honestly after restart.

The invariant is simple: the application owns policy and durable truth, HERDR
owns explicitly delegated live execution, and the operator's global HERDR
session remains independent.

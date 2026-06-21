# Kanban Federation and Dynamic Routing Constraints v0

## Purpose

Define the redacted operating doctrine for using Hermes Kanban across Donna, Sam, Victoria, Nikolai, Windows-native Hermes, and future nodes without assuming that every node shares one board or one SQLite database.

This note is documentation-only. It does not authorize service changes, database replication, profile creation, remote dispatch, SSH setup, broker deployment, or cross-node automation.

## Core premise

Hermes Kanban is a strong local coordination primitive. It is not, by itself, a universal cross-node mesh.

A Kanban board is only shared by the Hermes runtimes that can actually read and write the same Kanban store under the same Hermes home or configured board database. Donna may see her own board and local profiles; Sam, Victoria, Nikolai, and a Windows-native Hermes install may each have their own local boards that Donna cannot mutate unless an explicit transport, broker, or replicated command protocol exists.

Treat cross-node work as federation:

- Donna owns top-level intent, approvals, and the queen-bee ledger.
- Each node owns its local execution board and local dispatcher boundary.
- Cross-node assignment is a command protocol transaction, not a blind write into Donna's local board.
- Completion proof returns through `QACK`, `QSTATUS`, `QDONE`, `QBLOCKED`, `QNACK`, or broker-equivalent events.

## Identity model

Profile names are not globally unique. A profile called `default` may exist on Donna, Sam, Victoria, Nikolai, Windows, and Paperclip company runtimes at the same time.

Use compound identity for any routed Kanban target:

```text
<node_id>/<profile_name>/<board_slug>
```

Examples:

```text
donna-vps/beedocs/default
sam-s24/s24-cloud/default
victoria-paperhermes/default/empire-ops
nikolai-wsl/engineering/local
windows-native-hermes/default/local
```

When a task names only `assignee=beedocs` or `assignee=default`, that name should be interpreted as local to the dispatcher and board that will consume the row. It should not be interpreted as a global fleet-wide worker id.

## Node-local SQLite boundaries

Current safe assumption:

- A Hermes Kanban SQLite database is node-local unless explicitly proven otherwise.
- A profile can only claim tasks from boards visible to the dispatcher running in that profile's environment.
- A task inserted into Donna's local Kanban DB will not automatically appear in Sam's, Victoria's, Nikolai's, or Windows' local Kanban DB.
- Sharing a writable SQLite file across unreliable network filesystems is not a safe default for federation.

Do not route work by writing a row to one board and assuming a remote dispatcher will see it. The dispatcher must be proven to watch that exact board database, or the route must use a command/broker layer.

## Multi-tenant boards

Kanban tenants and board slugs are useful local scoping tools, not a substitute for node identity. In other words, multi-tenant boards solve local scoping, not cross-node federation.

Use tenants for logical separation such as company, project, or workstream scope. Use board slugs for local queues such as `default`, `empire-ops`, `review`, or `local`. Still include the node and profile when discussing cross-node work.

Recommended locator shape:

```text
node_id: donna-vps
profile: beedocs
board: empire-ops
tenant: optional-project-or-company-scope
```

Avoid overloaded shorthand such as `empire-ops/default` when the node is not obvious. The same tenant and board slug can exist on multiple nodes with different contents.

## Dynamic profile-created events

Dynamic profiles are expected. They may be created by a human, Donna, a local Hermes command, a Paperclip company workflow, a mobile node, or a Windows-native experiment.

Any profile, board, or worker creation path should emit or expose a `PROFILE_CREATED`-class event before the new worker is treated as schedulable capacity.

Minimum redacted event fields:

```json
{
  "event_type": "PROFILE_CREATED",
  "event_id": "uuid-or-stable-id",
  "created_at": "iso8601",
  "node_id": "redacted-node-id",
  "profile_name": "profile-name",
  "board_slug": "optional-board",
  "hermes_home_kind": "host|termux|wsl|windows|container|company-scoped|unknown",
  "creator": "human|donna|kanban|paperclip|manual|unknown",
  "intended_role": "worker|reviewer|orchestrator|research|dashboard|unknown",
  "mutation_authority": 0,
  "requires_contract_review": true
}
```

Do not include secret values, API keys, auth exports, private keys, raw config files, session databases, memory dumps, or `.env` contents in these events.

## Readiness gates before routing

A newly discovered profile is not automatically a valid assignee.

Before Donna routes real work to a remote profile, require evidence for:

1. Node identity: the target node id is known and current.
2. Transport: a reliable route exists, or broker delivery is configured.
3. Board visibility: the target dispatcher watches the board where work will appear.
4. Profile readiness: the profile can spawn a worker with the expected tools and model.
5. Workspace policy: the profile has a safe local workspace boundary.
6. Acknowledgment: a dry `QPING` or `QTASK` receives `QACK` within the expected deadline.
7. Completion proof: a dry or low-risk task can return `QDONE` or `QBLOCKED` with artifacts or a reason.

Until those checks pass, keep the profile in `candidate` or `unreviewed` status and use paste-ready relay or manual operator confirmation for work.

## Cross-node routing semantics

### Local board assignment

Use direct `kanban_create` only when the assignee profile is local to the current board and dispatcher boundary.

Safe examples:

- Donna creates a task for another profile that is known to share Donna's Kanban DB.
- A node-local orchestrator creates child tasks for node-local worker profiles.
- A Paperclip company manager creates tasks inside the company-scoped runtime that its workers are proven to watch.

### Remote node assignment

Use `QTASK`/`QACK`/`QDONE` or broker-equivalent semantics when the target is remote.

Required behavior:

1. Donna emits `QTASK` with a stable command id, target compound identity, task body, deadline, and redaction level.
2. Target node or broker returns `QACK` if accepted, or `QNACK` with a reason if not accepted.
3. Target node creates local Kanban work on its own board if appropriate.
4. Target reports progress with `QSTATUS` when long-running.
5. Target finishes with `QDONE`, including artifact links or redacted summary, or `QBLOCKED` with the exact missing input.
6. Donna records the event chain in her command ledger and updates the top-level board.

A broker may implement these events with a queue, webhook, n8n workflow, file drop, dashboard API, or other audited transport. The key property is acknowledgment and completion semantics, not the specific technology.

## Why not assume one shared board?

Assuming every board is shared causes predictable failures:

- Phantom dispatch: Donna creates a row that the remote dispatcher never sees.
- Wrong-worker dispatch: a local profile with the same name claims work intended for a remote node.
- Split-brain status: Donna marks a task ready while a remote node has no corresponding row or has a different row state.
- Lost blockers: the remote node blocks locally but Donna never receives the reason.
- Unsafe authority creep: visibility of a board is mistaken for permission to mutate the target node.
- Audit gaps: work crosses machines without a durable command id, acknowledgment, or artifact proof.

## Node-specific notes

### Donna

Donna is the queen-bee control plane. Her Kanban should hold top-level objectives, approvals, routing decisions, and federation status. Donna should not claim that a remote task is accepted until she has `QACK` or broker proof.

### Sam

Sam is a mobile/Termux-style edge node. Treat Sam as local-only until persistence, transport, and dispatch readiness are proven. Mobile availability can change quickly, so `QACK` deadlines and `QSTATUS` heartbeats matter.

### Victoria

Victoria is a VPS/Tijuana ops persona candidate. Route work only through a proven courier lane or broker. If Donna cannot reach Victoria directly, provide Miguel a paste-ready relay instead of silently waiting.

### Nikolai / Nikoli

Nikolai is a workstation/WSL engineering persona candidate. Tailnet presence is not enough; require SSH or dashboard reachability, local workspace readiness, Hermes profile readiness, and an acknowledgment loop before assigning real work.

### Windows-native Hermes

Windows-native Hermes should be represented as a first-class node id, not as an exception or an invisible local profile. Expect different path, shell, service, and SQLite-file assumptions. Do not assume Linux paths, WSL paths, or Donna's dispatcher behavior apply.

## Recommended state labels

Use these labels for fleet routing status:

- `local-ready`: profile shares the current Kanban DB and has passed a dry task.
- `remote-ready`: remote profile has passed transport, board, `QACK`, and `QDONE` gates.
- `candidate`: node/profile exists but readiness is incomplete.
- `unreviewed`: profile-created event received but contract review is pending.
- `blocked`: known missing transport, auth, workspace, or dispatcher capability.
- `retired`: do not route new work without re-review.

## Minimal command envelope

For brokered or manual relay routing, use a redacted envelope like:

```json
{
  "type": "QTASK",
  "command_id": "qtask-YYYYMMDD-shortid",
  "from": "donna-vps/beedocs/empire-ops",
  "to": "node/profile/board",
  "tenant": "optional-redacted-tenant",
  "title": "short task title",
  "body": "bounded task instructions",
  "deadline": "iso8601-or-null",
  "redaction": "no-secrets-no-raw-runtime-state",
  "ack_required": true,
  "done_required": true
}
```

Responses should carry the same `command_id`:

```json
{
  "type": "QDONE",
  "command_id": "qtask-YYYYMMDD-shortid",
  "from": "node/profile/board",
  "status": "done|blocked|failed",
  "summary": "redacted result",
  "artifacts": ["approved-link-or-path-if-safe"],
  "sensitive_data_inspected": false,
  "mutation_performed": false
}
```

## Safety boundaries

This doctrine does not authorize:

- reading or copying raw Kanban SQLite databases across nodes;
- sharing writable SQLite over network filesystems;
- editing Hermes profiles, gateway services, or dispatcher config;
- creating new profiles without review;
- treating profile names as globally unique;
- exposing secrets, `.env` values, auth exports, session DBs, raw logs, or memory dumps;
- mutating remote infrastructure because a node appears in an inventory.

## Operating rule

For any cross-node task, ask three questions before routing:

1. What is the exact compound target identity: `<node>/<profile>/<board>`?
2. What mechanism proves the target accepted the work: local dispatcher claim, `QACK`, or broker acknowledgment?
3. What mechanism returns completion or blocker state to Donna: local board status, `QDONE`, `QBLOCKED`, or broker event?

If any answer is missing, do not treat the task as dispatched. Mark the target as candidate/blocked, record the gap, and use a paste-ready relay or request human approval for the next transport step.

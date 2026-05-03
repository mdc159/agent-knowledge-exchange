# Empire Visibility Communications Plan v0

## Purpose

Create a redacted, governance-level communications plan for the Empire Visibility rollout tracked in Linear `121-34`.

This artifact defines how Miguel, Donna, Victoria, and approved 1215 operators discuss and review visibility across container operations, API-call tracing, LLM-call tracing, and daily operator sound-offs without crossing into infrastructure mutation or sensitive data inspection.

## Assumptions

- Linear `121-34` is the primary tracker for Empire Visibility rollout coordination.
- Portainer-style visibility is for high-level environment and container awareness, not unmanaged changes.
- Langfuse, OpenTelemetry, API traces, and LLM traces are observability surfaces, not permission to expose private payloads.
- Honcho and other memory/context systems are sensitive domains and remain out of scope unless separately approved.
- This plan is documentation-only and redacted by default.
- If a fact is not verified from approved non-secret sources, the daily sound-off should say `not verified`.

## Control-plane vs workload-plane split

### Control-plane

The control-plane is the management, visibility, coordination, and approval layer. It may include Linear tracking, knowledge-repo docs, Portainer dashboards, Langfuse dashboards, approved reports, and approval records.

Control-plane access does not automatically authorize mutation. Operators should treat visibility as evidence for review and escalation, not as permission to change infrastructure.

### Workload-plane

The workload-plane is the actual running services, containers, APIs, agents, gateways, jobs, databases, memory stores, and host-level processes.

Workload-plane changes require explicit approval, an owner, a rollback path, and validation appropriate to the risk. This v0 plan does not authorize workload-plane changes.

## Communication channels

### Primary tracker

- Linear: `121-34`
- Purpose: issue status, approvals, blockers, rollout state, and review handoff.

### Durable knowledge artifact

- Repository path: `knowledge/hermes/empire-communications-plane-v0.md`
- Purpose: shared governance vocabulary, daily sound-off structure, approval gates, and safety boundaries.

### Internal sound-offs

- Use the daily sound-off format in this document.
- Keep updates concise, redacted, and operational.
- Do not include secrets, auth exports, raw logs, `.env` contents, private keys, session DBs, memory dumps, or credential material.

### External communications

External vendor, government, customer, or public communications are out of scope for this plan unless Miguel or Donna separately approve exact channel, recipient, body, attachments, links, and timing.

## Portainer-style container visibility

Purpose: provide high-level container and Docker-environment awareness so operators can understand where workloads live and what appears healthy or blocked.

Allowed at governance level:

- Environment names or labels when already approved for sharing.
- Container or stack names when non-sensitive.
- High-level state such as running, stopped, unhealthy, unknown, or not verified.
- Ownership or operational notes when already known and non-sensitive.
- Summary-level risk notes.

Not allowed without explicit approval:

- Container environment variables.
- Secrets or secret-like config values.
- Raw compose files containing credentials.
- Raw container logs.
- Volume contents.
- Shell access into containers.
- Restart, update, delete, exec, deploy, network, or firewall actions.

Suggested report language:

```text
Portainer-style visibility:
- Environments visible: <approved names only / not verified>
- Workload summary: <summary only>
- Health summary: <running/stopped/unhealthy/unknown>
- Mutation performed: none
- Sensitive data inspected: none
```

## Langfuse / OTel / API + LLM trace coverage

Purpose: provide safe observability for API calls, LLM calls, tool calls, retries, latency, errors, and cost patterns without exposing sensitive payloads.

Allowed at governance level:

- Trace-readiness status.
- Synthetic ingestion status.
- Service, span, or operation naming proposals.
- Redacted error categories.
- Latency, retry, and cost summaries when non-sensitive.
- Trace coverage maps that describe categories rather than raw payloads.

Not allowed without explicit approval:

- Raw prompts.
- Raw completions.
- Raw request or response bodies.
- Auth headers.
- API keys or tokens.
- Session DB records.
- Memory-store contents.
- Private user or customer payloads.

Suggested trace categories:

- Agent request received.
- Tool call started.
- Tool call completed.
- API request started.
- API request completed.
- LLM call started.
- LLM call completed.
- Retry or fallback triggered.
- Error surfaced.
- Human approval required.

## Daily sound-off format

Use this template for daily Empire Visibility updates:

```md
Empire Visibility Daily Sound-Off — YYYY-MM-DD

Linear:
- Tracking issue: 121-34

Observed:
- Portainer-style container visibility:
  - Environments:
  - Workload summary:
  - Health summary:
  - Sensitive data inspected: none / not applicable / approved exception reference
- Langfuse / OTel / API + LLM traces:
  - Health:
  - Ingestion:
  - Trace coverage:
  - Payload exposure: none / not applicable / approved exception reference
- Honcho / memory domains:
  - Memory reads/writes: none / approved exception reference

Changed:
- Docs:
- Config:
- Services:
- Network/firewall:
- Data/memory:
- External messages:
- Automation/scheduling:

Validation:
- Checks performed:
- Evidence type:
- Redactions applied:

Risks / blockers:
-

Approval needed:
-

Next action:
-
```

## Approval gates

### Gate 0: Communications and governance only

Allowed:

- Draft or update redacted docs.
- Prepare daily sound-off templates.
- Define glossary terms.
- Reference Linear `121-34`.

Forbidden:

- Infrastructure changes.
- Service changes.
- Credential, env, raw-log, session DB, or memory-store reads.
- Portainer, Langfuse, Honcho, Docker, firewall, gateway, or Hermes wiring.
- Sending, scheduling, or automation.

### Gate 1: Read-only inventory summary

Requires explicit Miguel/Donna approval.

Possible scope after approval:

- Approved environment names.
- Approved container or stack summary.
- High-level health states.
- No secrets, raw logs, env values, shell access, or mutation.

### Gate 2: Trace design

Requires explicit Miguel/Donna approval.

Possible scope after approval:

- Trace naming conventions.
- Span taxonomy.
- Redaction policy.
- Metadata allowlist.
- Payload-exclusion rules.

### Gate 3: Synthetic ingestion validation

Requires explicit Miguel/Donna approval.

Possible scope after approval:

- Synthetic test traces.
- Non-sensitive test payloads.
- Dashboard verification using test data only.

### Gate 4: Production visibility rollout

Requires explicit Miguel/Donna approval, named owner, rollback path, and validation plan.

Possible scope after approval:

- Selected service tracing.
- Production dashboards.
- Alerting.
- Scheduled reporting.

## No-mutation boundaries

This v0 artifact authorizes documentation only.

Do not perform or imply authorization for:

- Infrastructure changes.
- Service installs, restarts, or edits.
- Firewall or network changes.
- Docker changes.
- Gateway unit changes.
- Hermes profile changes.
- Agent-session changes.
- Portainer configuration changes.
- Langfuse configuration changes.
- Honcho configuration changes.
- Memory-store reads or writes.
- Credential, secret, auth export, `.env`, private key, raw log, session DB, or memory dump reads.
- External party contact.
- Sending, scheduling, or automation.
- Promotion into hermes-grid.

## Rollout phases

### Phase 1: Communications prep

- Create redacted governance artifact.
- Align on daily sound-off format.
- Confirm approval gates.
- Keep all work documentation-only.

### Phase 2: Read-only visibility design

- Identify approved read-only summary fields.
- Define Portainer-style inventory language.
- Define trace metadata allowlist.
- Confirm sensitive-data exclusions.

### Phase 3: Synthetic validation plan

- Define synthetic test data.
- Define success criteria for ingestion and dashboard review.
- Require approval before any execution.

### Phase 4: Controlled rollout planning

- Select candidate services.
- Define owner and rollback plan.
- Define review cadence.
- Require explicit production approval.

### Phase 5: Operating cadence

- Use daily sound-offs.
- Track approvals and blockers in Linear `121-34`.
- Keep governance docs updated through reviewable changes.

## Open questions

- Who is the named owner for Empire Visibility after Phase 1?
- Which operators are approved to view Portainer-style summaries?
- Which trace metadata fields are approved for API and LLM calls?
- Are token and cost summaries allowed in daily sound-offs?
- What is the retention expectation for trace summaries?
- What is the minimum approval record required before moving from synthetic traces to production traces?
- Should Honcho and other memory domains remain fully excluded from Empire Visibility, or receive a separate memory-governance issue?
- What dashboards, if any, should be considered official control-plane views?

## Glossary

### Control-plane

The management, visibility, coordination, and approval layer used to observe and guide operations. Examples include approved dashboards, Linear issues, knowledge-repo docs, and operator sound-offs.

### Workload-plane

The running operational layer: services, containers, APIs, agents, gateways, databases, jobs, and host processes. Changes to this layer require explicit approval.

### Host-metal Hermes

A Hermes instance running directly on a host or VPS with potential access to local shell, files, services, tmux sessions, Docker, or other host resources depending on configuration. Treat as higher risk than a narrowly scoped client or sandbox.

### Company Hermes

A 1215-approved Hermes instance or workflow operating under company governance, documented permissions, expected audit behavior, and explicit boundaries.

### Honcho domain

The memory and context domain associated with Honcho, including session context, peer representations, conclusions, and related memory-backed reasoning. Treat as sensitive; no reads or writes without explicit approval.

### Langfuse trace

A structured observability record for an operation such as an API call, LLM call, tool call, span, retry, or error. Safe use requires metadata allowlists and redaction rules.

### Portainer environment

A Docker endpoint or environment registered in Portainer for visibility or management. Visibility of an environment does not authorize mutation of containers, stacks, networks, volumes, or host settings.

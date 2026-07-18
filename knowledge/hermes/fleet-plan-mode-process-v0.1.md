# Fleet Plan Mode — Process and Release Gates v0.1

## Operating rule
Plan once, visibly, before execution. After release, ship and iterate. No workstream enters `Ready` until the plan graph, routing, evidence path, and tracking capacity exist.

## Board states
1. `Triage` — raw goal; planning has not started.
2. `Todo` — specified and mapped, but not released.
3. `Ready` — all release gates passed; dispatcher may claim it.
4. `Running` — claimed, workspace/run ID posted, heartbeat active.
5. `Blocked` — named blocker or `review-required`; no hidden waiting.
6. `Done` — acceptance met, evidence attached, verifier disposition recorded.

## Exact flow

### 1. Capture the raw goal
Create one Goal card containing:
- desired outcome and why it matters;
- measurable success condition;
- constraints, non-goals, urgency, and cost/time ceiling;
- execution lane: disposable R&D or promotion/persistent infrastructure;
- Plan Owner and Release Authority.

Gate G0 — Intake complete: outcome, success condition, lane, Plan Owner, and Release Authority exist. Otherwise remain in `Triage`.

### 2. Build the Plan Pack
The Plan Owner writes one concise Plan Pack on the Goal card:
- deliverables and acceptance tests;
- assumptions and unknowns;
- boundaries and interfaces;
- rollback/cleanup expectation;
- artifact and evidence destinations;
- stop conditions: what result kills or redirects the experiment.

Gate G1 — Spec complete: every deliverable has an observable acceptance test and an evidence destination.

### 3. Decompose into independently observable workstreams
Create the smallest useful cards with one owner, one primary output, and one terminal condition. Do not split work merely to create activity. Each card must state:
- input/context;
- output/artifact;
- acceptance criteria;
- hard dependencies;
- node/profile capability requirements;
- workspace/isolation mode;
- evidence receipt;
- expected checkpoint/heartbeat;
- verifier and verification method;
- stop/timeout/TTL.

Create an Integration card whenever several outputs must become one system. Create an independent Verification card for every promoted/shared artifact; disposable spikes may use a lightweight smoke-test card.

Gate G2 — Graph complete: all initial deliverables map to cards; every card maps back to a deliverable; hard dependencies are encoded as board parent links, not buried in prose.

### 4. Map dependencies
Draw the DAG before changing any card to `Ready`:
- link only true hard dependencies;
- leave independent lanes unlinked so they can run in parallel;
- identify the critical path;
- name integration points and shared mutable surfaces;
- serialize cards that touch the same unsafe surface unless isolation removes the collision;
- make synthesis/integration/review children of every input they require.

Gate G3 — Dependency safety: no child can be claimed before unfinished parents; no two released cards can unknowingly mutate the same unisolated surface.

### 5. Route by live capability
Discover the actual node/profile roster; never invent assignees. For each card, match:
- required OS, CPU/GPU/RAM, network location, hardware, browser, or mobile access;
- installed tools and skills;
- repository/data locality;
- credential and permission availability;
- current health, load, and concurrency;
- model strengths;
- independence requirement for verification.

Record primary node/profile and fallback. Capability must be proven live at planning time, not inferred from an old inventory. Builder and verifier must not be the same agent/model for promoted work.

Gate G4 — Route valid: assignee exists, required capabilities are live, access path is proven, fallback is named, and verifier is independent where required.

### 6. Stand up the whole visible board
Before execution:
- create the Goal, workstream, integration, and verification cards;
- encode parent links during child creation;
- assign every card;
- attach Plan Pack/version to the Goal card;
- put unreleased work in `Todo`, never prematurely in `Ready`;
- publish the DAG, critical path, WIP cap, and release order;
- designate exactly one Release Authority.

Gate G5 — Board ready: there is no shadow work. Every planned lane, owner, dependency, artifact, verifier, and acceptance test is visible.

### 7. Perform one up-front Plan Review
Review the complete board once before fan-out. Review only for:
- missing deliverable or dependency;
- wrong routing or unavailable capability;
- conflicting writes/shared-surface collisions;
- absent acceptance evidence;
- irreversible action without isolation/rollback;
- verifier circularity;
- fan-out exceeding tracking capacity.

Resolve findings on the cards, stamp Plan Version `v0.1`, record reviewer and disposition, and freeze the initial graph. After release, do not reopen architecture debate for ordinary implementation friction; create a change card only when evidence invalidates a plan assumption.

Gate G6 — Plan approved: reviewer disposition is `APPROVE`, `APPROVE WITH NAMED EXPERIMENT`, or `BLOCK`. Only the first two permit release.

### 8. Release through the fan-out governor
A task may move from `Todo` to `Ready` only when its parents are done and its card has:
- valid owner/assignee;
- acceptance criteria;
- isolated workspace or explicit shared-surface lock;
- run/artifact/evidence destinations;
- credential/access readiness;
- heartbeat/checkpoint expectation;
- timeout/TTL and stop condition;
- verifier route.

Global release slots are:

`min(capable healthy execution slots, dependency-ready cards, tracking slots, verifier capacity + 1, integration capacity)`

Tracking-slot enforcement:
- Start with WIP cap = 3 running workstreams for a new plan.
- Release at most the available WIP tokens.
- A token is consumed when a card enters `Ready` and returned only at `Done`, `Blocked`, or explicit reclaim.
- Do not release the next card until every newly claimed card has posted a `STARTED` receipt containing node, profile, workspace, run ID, and next checkpoint.
- Reconcile the board once per release wave. Increase WIP by only one after all active cards have fresh heartbeats, resolvable artifacts, and no orphaned claims.
- Reserve verifier capacity: normally at least one verifier slot per two builder slots.
- If the board cannot identify where a running lane is, fan-out stops automatically; reclaim or block before releasing more.

This is the hard rule: no fan-out faster than the board can establish identity, location, liveness, and evidence for every active lane.

Gate G7 — Fan-out allowed: Plan Approved, Board Ready, per-card Release Ready, and a WIP token available.

### 9. Execute and report evidence
On claim, post `STARTED {node, profile, workspace, run_id, plan_version, next_checkpoint}`. During execution, heartbeat only meaningful progress. On completion, post:
- artifact location/version/hash where applicable;
- commands/tests and real outputs;
- acceptance result;
- changed surfaces;
- cost and elapsed time;
- cleanup/rollback state;
- known failures and suggested next iteration.

Do not call a card done because a process ran or `/health` returned green; prove the stated behavior.

Gate G8 — Builder complete: artifact exists and has been read back/exercised; evidence is attached; cleanup or retention TTL is explicit.

### 10. Verify independently and release
Verifier reproduces the acceptance test from the artifact/evidence, not from the builder's prose. Outcomes:
- `PASS` — integration/release child may proceed;
- `FAIL` — create a new remediation child assigned to the builder lane;
- `INCONCLUSIVE` — block with the exact missing evidence or decision.

Integration/release confirms the combined behavior, records final artifact and rollback, and reports one concise result to Mike.

Gate G9 — Released: independent disposition recorded, integrated acceptance met, artifact address supplied, rollback/cleanup known, and no unresolved blocker disguised as a TODO.

### 11. Compound the lesson
At close:
- ephemeral run detail stays on the board;
- reusable operational procedure becomes a skill;
- durable fleet fact or architecture decision goes to GBrain/canonical knowledge;
- code/runtime truth stays in Git and live infrastructure;
- create follow-up cards only for evidence-backed next iterations.

## Required card template

```text
Goal/Deliverable:
Input/Context:
Output/Artifact:
Acceptance Criteria:
Hard Parents:
Shared Mutable Surfaces:
Primary Node/Profile:
Fallback Node/Profile:
Required Capabilities/Access:
Workspace/Isolation:
Evidence Destination:
Heartbeat/Next Checkpoint:
Timeout/TTL/Stop Condition:
Verifier/Profile + Method:
Plan Version:
```

## Release checklist
A fan-out wave is forbidden unless all are true:
- Goal card and Plan Owner exist.
- Plan Pack has observable acceptance tests.
- Initial task graph and integration card exist.
- Hard dependencies are encoded.
- Assignees are real and capabilities live-proven.
- Workspaces or shared-surface locks are defined.
- Evidence and artifact destinations exist.
- Independent verifier routes exist where impact requires them.
- One up-front Plan Review is approved and versioned.
- WIP cap, verifier reserve, and release authority are visible.
- Every released card has a WIP token.

## R&D posture
The gates make work trackable, not slow. Disposable experiments use lightweight evidence, short TTLs, and smoke-test verification. Shared fleet primitives use reproducibility, independent verification, rollback, residue checks, and delayed re-checks. Once G7 passes, execute aggressively and let measured results—not speculative review—drive iteration.

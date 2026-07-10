# 1215 Empire Topology & Node Model

> **Status: DRAFT for operator review.** Assembled 2026-07-10 by the Claude Code
> instance running on the `srv1264451` / `kvm-4` node, from (a) direct read-only
> inspection of that box, (b) the `studio54`, `1215-vps`, and
> `agent-knowledge-exchange` repos, and (c) working conversations with the operator.
> **It intentionally separates verified fact from reconstruction from operator-stated,
> so the operator can catch any drift, self-contradiction, or mutually-reinforcing
> assumption.** Do not treat 🟡/❓ claims as settled.
>
> **This is a public repo.** Two things are deliberately kept OUT of this doc and live
> only in the private on-box node docs:
> 1. **Live infrastructure** — exact addresses, the Tailnet name, account handles, IPs,
>    and node online/offline states.
> 2. **Persona names** — the operator's colloquial labels for agents are a private
>    recall heuristic, *not* architecturally significant (see the modeling note below).
>    Nodes are described here by **capability and role** only.
>
> Provenance markers: ✅ **Verified** this session · 🟡 **Reconstructed** (in a repo,
> not re-verified) · ❓ **Operator-stated** · ⚠️ **Gap / possible conflict**.

---

## 0. The unit of the architecture: the node

**The node is the fundamental building block.** A node is one reproducible deployment —
a VPS or a VM on a device — that can be one-shot bootstrapped into the full stack
(substrate + Paperclip + Hermes agent). A node is defined by **what its hardware can do**
(its *capability*) and **what job it's given** (its *role*). After deployment a node can
be assigned any persona or task; the persona is a runtime label, not part of the
architecture. Everything below is expressed in terms of nodes, capabilities, and roles —
never specific agent names.

---

## 1. The core mental model

The 1215 enterprise is a **capability-partitioned distributed company**: physically
separate nodes (VPSs + personal devices in different locations), each defined by *what
its hardware can do*, each running a Hermes agent, all coordinated by one control-plane
node. ❓/🟡

- **Nodes are departments defined by physical capability** — heavy CAE software vs.
  local-GPU inference vs. cloud/web vs. cloud services. A node does what only it can do. ❓
- **One control-plane node ("corporate / CEO") is the single point of contact.** The
  operator directs strategy through it; it supervises company creation and keeps the other
  nodes aligned. ❓/🟡
- **Coordination is publish-and-subscribe, not shared memory.** Each node/company keeps
  private, isolated memory; cross-node visibility happens only through a *published*
  shared layer. "Cross-company memory transfer is explicit, not ambient." 🟡
  (verbatim rule from `skills/hermes/company-memory-seeding/SKILL.md`)
- **Each node should be reproducible** — a "franchise" one-shot bootstrapped from zero. ❓/🟡
  (the repo's `node` concept; see `node-rollout-plan.md`, `canonical/node-growth-and-isolation.md`)

The organizing metaphor: **a company.** The control-plane node = corporate/CEO. Other
nodes = employees or subsidiaries, each with a specialty. Paperclip = the mechanism that
instantiates "companies" (agent teams) on a node.

---

## 2. Node roster (the org chart, by role & capability)

Physically distributed nodes joined over a private Tailnet. **Exact addresses, the
Tailnet name, account handles, and live states are NOT recorded here** (public repo).
Roles/capabilities below are ❓/🟡 unless marked ✅.

```text
        OPERATOR
             │  single point of contact
             ▼
   ┌─────────────────────────┐
   │  CONTROL-PLANE NODE      │  role: corporate / CEO  (outer Hermes)
   │  (the coordinator)       │  50k-ft strategy, world-awareness, resource
   │                          │  alignment, supervises company creation; hosts a
   │                          │  shared upper-level honcho memory several nodes read. ❓
   └───────────┬─────────────┘
               │
  ┌──────────┬─┴────────┬──────────────┬───────────────┐
  ▼          ▼          ▼              ▼               ▼
ENGINEERING COMPUTE /  SIMULATION /   WORKING NODE    PROVING-GROUND
/ R&D NODE  EXPERIMENT WEB NODE       (this box,      NODE
capability: NODE       capability:    kvm-4)          capability: the
heavy CAE   capability:simulation +  role: healthy   original Paperclip+
(MATLAB,    local-GPU, runs Vercel/   n8n + n8n-MCP   Hermes experiment
PTC Creo,   big LOCAL  web build/     host; a         bed; a low-stakes
ANSYS,      LLMs 24/7  deploy work ❓   throwaway      persona sandbox ❓
COMSOL);    (free                     side-persona;
the only    iterative                future
node that   experiments,             consolidation
runs it ❓    Karpathy                 target
            style);
            duplicate
            services ❓
```

Additional nodes/devices exist on the Tailnet (a Windows box, a Mac, an iOS device, an
Android device, and a laptop that may be the engineering hardware). Their exact
identities, addresses, and which persona each currently runs stay in the private on-box
docs.

⚠️ **Open mapping questions:**
- Which physical host backs each role (which peer is the compute node, etc.)? Is the
  engineering capability one machine or split across a workstation + a separate box? ❓
- A **simulation/Vercel (web) node** is confirmed to exist in the fleet but is not yet
  located to a specific host in this reconstruction. ❓
- Is there **one** control-plane node across the whole fleet (headquarters model) or one
  coordinator **per** node (pure franchise)? Operator leans HQ. ❓

---

## 3. The agent layer (persona-agnostic)

- **Control-plane / outer Hermes** — host-native, corporate/CEO role: single point of
  contact, supervises company creation, persists across company lifecycles. Maps to the
  repos' **"outer Hermes" / `big-hermes`** role (`knowledge/hermes/outer-vs-inner-hermes.md`,
  `agents/profiles/big-hermes.md`). 🟡/❓
- **Inner Hermes (per company)** — spawned per Paperclip company, company-scoped runtime
  home, isolated memory, does the actual work. 🟡
- **Node-local Hermes** — the agent running on a given capability node (engineering,
  compute, working, proving-ground). Each carries whatever persona the operator assigns;
  the persona is a label, not a role.

> **Modeling note.** The operator uses colloquial persona names as a private recall
> heuristic. They are intentionally omitted here: a node's identity is its **capability +
> role**, and any node can be re-assigned a different persona after deployment. Persona↔node
> bindings, where they matter operationally, live in the private on-box docs.

### 3a. This node (srv1264451 / kvm-4) — ✅ verified on box
Role: **working node** (n8n / n8n-MCP host) + a **throwaway side-persona** on Hermes
profile `v`, deliberately isolated from the operator's primary persona so experiments here
can't disturb it (a few Hermes profiles exist on the box; names kept in private docs).
The active gateway is a **live Telegram surface** (`hermes-gateway-v.service`). Its model, tooling, and honcho
memory were repaired 2026-07-10 (see the node-local runbook / `[[hermes-profile-v-llm]]`
and `[[honcho-deriver-state]]` in the operator's Claude memory).

---

## 4. Memory & isolation model

The most thoroughly documented area (see `studio54:docs/architecture/honcho-memory-topology.md`,
611 lines, and `1215-vps:docs/architecture/`). 🟡

- **Three non-conflatable layers:** (1) Paperclip control-plane state, (2) Hermes
  local/runtime memory under `HERMES_HOME`, (3) Honcho long-horizon reasoned memory.
- **Isolation boundaries:** Paperclip company-ID → Honcho **workspace** (the hard
  boundary); Paperclip agent-ID → Honcho **AI peer**. The *real* enforcement is the
  **gateway spawn layer** (`spawn.py`: profile allowlist, blocked env keys, `HERMES_HOME`
  pinning, path-traversal defense) — via the three knobs `--profile` + `cwd` + `HERMES_HOME`.
- **"Explicit, not ambient":** cross-company/-node knowledge moves only by publishing an
  approved artifact to a shared surface (Postgres alignment log, shared Neo4j/Qdrant,
  Langfuse), never by shared runtime homes or shared workspaces.
- **The "control-plane node sees across companies" goal:** documented as a *boundary rule /
  aspiration*, ⚠️ **not an implemented mechanism.** Docs prescribe the outer Hermes get its
  **own** isolated scope and NOT reuse company workspaces. Honcho's `observe_me`/
  `observe_others` + dialectic primitives could implement cross-read, but no such code is
  wired. So "corporate reads across nodes" = via the *published layer*, not by reading
  private memories. ⚠️ **The single most important thing to confirm we agree on** — it is
  easy to assume the coordinator "just reads everyone's memory," and the design deliberately
  says otherwise.

### Canary verification (how isolation was proven) 🟡
Two canary systems: a **fake-secret canary** (a deterministic fake secret) swept out of
memory/broker/Langfuse/qdrant/neo4j/minio/repo by `./bin/1215 smoke`'s `canary_check`;
and a **hermes-zero tool-level canary** that refuses any write/commit containing the
marker. Findings on record: per-company `HERMES_HOME` isolation **proven twice**; one real
leak found = **identity fragmentation** (one human split into a named peer vs. a numeric
Telegram peer), fixed with `pinPeerName: true`. ✅ Independently corroborated on-box
2026-07-10: every Paperclip company workspace showed 100% message-embedding coverage during
its active session — derivation kept up in real time; no knowledge was lost.

---

## 5. Orchestration model (the loop we want)

```text
Operator → control-plane node (1 contact) → Paperclip creates a company
        → hermes-gateway SPAWNS that company's inner Hermes (only legit spawner)
        → BROKER ("continuity plane") carries the traffic between agents
        → work happens → results/knowledge PUBLISHED to the shared layer
        → control-plane node reads the published layer → reports to operator
```

❓ **Historical context / the pain this solves:** months ago the operator could not get
two agents (outer + inner Hermes) to coordinate and was **manually copy-pasting between
them for hours** — hand-simulating a message bus that didn't exist yet. The **broker +
gateway** are exactly the machinery meant to close that gap. Whether they now close it
end-to-end is ⚠️ **unproven in this reconstruction** (see §7).

---

## 6. The reproducible "franchise" node

❓ Intent: any node (a VPS, or a VM on a device) can be **one-shot bootstrapped** into the
full stack — substrate (the ~14-container mesh), Paperclip, Honcho, a Hermes agent —
"ready to rock." The operator ran VM experiments toward one-shotting the whole setup. 🟡
The repo's `node` concept + `./bin/1215` control plane + `node-rollout-plan.md` are the
codified form. Operator's current stance (✅ stated): the bootstrap is "good enough /
reproducible," and polishing it further is lower-value than **using it to produce billable
work.**

⚠️ Some nodes appear to run **duplicate services** (e.g. n8n on more than one node),
suggesting a **redundancy/failover** angle on top of pure capability-partitioning — nodes
may replicate some services, not just specialize. Confirm whether duplication is
intentional failover or drift.

---

## 7. Open questions, gaps, and possible conflicts (READ THIS FIRST, operator)

This section exists specifically to guard against a "positive projection loop." Each item
is something this doc asserts or assumes that is **not fully verified**:

1. ⚠️ **Cross-node cross-read is an aspiration, not built.** If the mental model is
   "the coordinator reads all node memories directly," that conflicts with the documented
   design (isolated scopes + published layer). Which is the intent?
2. ⚠️ **One control-plane node (HQ) vs one coordinator per node (franchise).** The two
   imply different architectures. Operator leans HQ; the isolation docs lean per-node
   isolation. Not contradictory, but the boundary needs stating.
3. ⚠️ **A simulation/Vercel (web) node is under-specified** — confirmed to exist but not
   located to a host or described beyond "simulation + web/Vercel."
4. ⚠️ **Node→capability→hardware mapping is partly inferred** (which peer is the compute
   node; whether the engineering capability is one box or two).
5. ⚠️ **Implemented vs documented honcho.json diverge:** the CEO installer hardcodes a
   single shared workspace (`1215-vps`/peer `ceo`), while the design docs prescribe
   per-company-ID workspaces. The single-node prototype and the multi-company design are
   not the same shape.
6. ⚠️ **The end-to-end isolation test was never built** (audit: 6/10 E2E tests missing;
   fake-secret-canary script absent in 1215-vps). No test forks two companies and proves
   A's canary doesn't surface in B. Isolation is *claimed proven* by ad-hoc runs, not an
   automated gate.
7. ⚠️ **The orchestration loop (§5) is not verified working end-to-end here.** The broker
   is running; whether outer↔inner Hermes actually coordinate without a human relay today
   is unconfirmed.
8. ❓ **What does this node (srv1264451) become?** Permanent node with a role, or staging
   area to consolidate the working-node learnings and fold them up to corporate?
9. ❓ **Paperclip utilization is still "a mystery"** to the operator — how companies
   actually use it is not fully understood, even by the person who built it.

---

## 8. This node right now (srv1264451) — ✅ verified 2026-07-10

- **Role in use:** healthy **n8n + n8n-MCP** host (the operator wants to use these because
  another node's n8n has been flaky). Candidate working node for producing actual output.
- **Stack:** Compose project `1215-prototype-local`, 14 containers healthy; host-native
  broker, honcho, paperclip app; Hermes `v` gateway live on Telegram with honcho memory
  wired to its own isolated workspace. Full node-local operations docs live on the box
  (private).
- **Not wired to the shared upper-level memory yet** — this box has no SSH credentials to
  the control-plane node; reachable on the Tailnet but access is pending operator setup.

---

*This document is a shared-model checkpoint, not a spec. Correct it freely — the whole
point is to converge on one accurate picture before building further.*

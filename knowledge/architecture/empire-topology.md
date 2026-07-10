# 1215 Empire Topology & Node Model

> **Status: DRAFT for operator review.** Assembled 2026-07-10 by the Claude Code
> instance running on the `srv1264451` / `kvm-4` VPS, from (a) direct read-only
> inspection of that box, (b) the `studio54`, `1215-vps`, and
> `agent-knowledge-exchange` repos, and (c) a working conversation with the operator
> (mdc159 / "Mike"). **It intentionally separates verified fact from reconstruction
> from operator-memory, so the operator can catch any drift, self-contradiction, or
> mutually-reinforcing assumption.** Do not treat 🟡/❓ claims as settled.
>
> Provenance markers used throughout:
> - ✅ **Verified** this session (observed on the box or in a repo)
> - 🟡 **Reconstructed** — documented in a repo, not independently re-verified here
> - ❓ **Operator-stated** — from conversation/memory, needs confirmation
> - ⚠️ **Gap / possible conflict** — flagged for the operator to resolve

---

## 1. The core mental model

The 1215 enterprise is a **capability-partitioned distributed company**: physically
separate nodes (VPSs + personal devices in different locations), each defined by *what
its hardware can do*, each running a Hermes agent with its own persona, all under one
corporate head. ❓/🟡

- **Nodes are departments defined by physical capability** — heavy CAE software vs.
  local-GPU inference vs. cloud services. A node does what only it can do. ❓
- **One corporate head ("Donna") is the single point of contact.** The operator directs
  strategy through Donna; Donna supervises company creation and keeps the nodes aligned. ❓/🟡
- **Coordination is publish-and-subscribe, not shared memory.** Each node/company keeps
  private, isolated memory; cross-node visibility happens only through a *published*
  shared layer. "Cross-company knowledge transfer is explicit, not ambient." 🟡
  (verbatim rule from `skills/hermes/company-memory-seeding/SKILL.md`)
- **Each node should be reproducible** — a "franchise" that can be one-shot bootstrapped
  from zero into the full stack (substrate + Paperclip + Hermes). ❓/🟡 (this is the repo's
  `node` concept; see `node-rollout-plan.md`, `canonical/node-growth-and-isolation.md`)

The organizing metaphor: **a company.** Donna = corporate/CEO. Other nodes = employees or
subsidiaries, each with a specialty. Paperclip = the mechanism that instantiates
"companies" (agent teams) on a node.

---

## 2. Node roster (the org chart)

Physically distributed; all joined over one Tailnet (`tailfedd3b.ts.net`, account
`mdc159@`). Tailnet data below is ✅ (observed 2026-07-10); roles/personas are ❓/🟡.

```
        OPERATOR (Mike / mdc159)
                 │  single point of contact
                 ▼
        ┌───────────────────────┐
        │  CORPORATE / CEO       │   "DONNA"   node: donna  100.87.24.49 (linux, ONLINE ✅)
        │  outer Hermes          │   50k-ft strategy, world-awareness, resource alignment,
        │  shared upper-level    │   supervises company creation. Hosts a shared honcho
        │  honcho memory ❓       │   memory that several upper-level agents (incl. Claude
        └───────────┬───────────┘   Codes) read. ❓
                    │
   ┌────────────────┼───────────────────┬──────────────────────┐
   ▼                ▼                    ▼                      ▼
ENGINEERING/R&D  COMPUTE/EXPERIMENTS   THIS VPS               PROVING GROUND
"NIKOLAI"(Tesla) Mac mini              srv1264451 / kvm-4     "VICTORIA" (orig.)
node: nicolai    node: cbass? ⚠️       100.84.200.95 (ONLINE) node: victoria
100.110.111.7    (macOS, ONLINE ✅)     ✅                     100.112.150.24 (linux,
(linux, OFFLINE) Apple-silicon, runs   healthy n8n + n8n-MCP   tagged-devices, ONLINE ✅)
✅               big LOCAL LLMs 24/7    host; carries a         original Paperclip+Hermes
Dell w/s; MATLAB, for free iterative   throwaway side-persona  experiment; persona
PTC Creo, ANSYS, experiments (Karpathy Victoria/`v`. Future    Victoria (modeled on a
COMSOL. The only auto-research style). consolidation target.   real person the operator
node that runs   Has DUPLICATE services ❓ (see §6)             knows; dual business +
heavy CAE. Works (n8n etc.). Slated to                         backstory persona
w/ operator. ❓   attach → this VPS. ❓                          experiment). ❓
```

Other Tailnet peers observed ✅ (roles unconfirmed ❓): `m6800` 100.91.93.24 (linux,
offline — likely the Dell workstation hardware), `9530` 100.104.162.40 (windows),
`samantha` 100.83.211.53 (android, offline — an unplaced persona ⚠️), `taco-rosa`
100.101.48.30 (iOS).

⚠️ **Open mapping questions:**
- Which physical host is the "Mac mini / compute" node — `cbass` (macOS)? And is
  `nicolai` (offline) vs `m6800` one machine or two? ❓
- `samantha` (android persona) is not placed in the org chart. What is her role? ❓
- Is there **one** Donna across all nodes (headquarters model) or one outer Hermes
  **per** node (pure franchise)? Operator statement leans "one Donna = corporate,"
  which is the headquarters model. ❓

---

## 3. Personas & the agent layer

- **Donna** — the outer/host-native Hermes at corporate; the "CEO of the parent
  company." Single point of contact. In the repos this maps to the **"outer Hermes" /
  `big-hermes`** role (`knowledge/hermes/outer-vs-inner-hermes.md`,
  `agents/profiles/big-hermes.md`). 🟡/❓ ("Mona" in earlier operator notes = Donna,
  a speech-to-text artifact. ✅ operator-confirmed)
- **Inner Hermes (per company)** — spawned per Paperclip company, company-scoped runtime
  home, isolated memory, does the actual work. 🟡
- **Victoria** — a persona modeled on a real person (Tijuana, helps the operator with
  business). Ran as a **dual persona**: a business persona and a backstory-enriched
  personal persona (experiment to make her less "bot-ish"). Original lives on the
  `victoria` proving-ground VPS. ❓
- **Nikolai (Tesla)** — the engineering-workstation agent; collaborates with the operator
  on mechanical-engineering work. ❓
- **Samantha** — unplaced persona (android device). ❓ ⚠️

### 3a. This node's persona (srv1264451) — ✅ verified on box
Active profile is **`v` = "Victoria"** (a *throwaway side-persona* the operator created
here — deliberately NOT the main persona — because he couldn't recall where the main one
lived and didn't want to break it; some content was copied from the original `victoria`
VPS). Profiles present: `v`, `vforge`, `victoria-candidate`. The `v` gateway is a **live
Telegram surface** (`hermes-gateway-v.service`). Model + tooling were repaired 2026-07-10
(see the node-local runbook / `[[hermes-profile-v-llm]]` in the operator's Claude memory).

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
- **The "main Hermes sees across companies" goal:** documented as a *boundary rule /
  aspiration*, ⚠️ **not an implemented mechanism.** Docs actually prescribe the outer
  Hermes get its **own** isolated scope and NOT reuse company workspaces. Honcho's
  `observe_me`/`observe_others` + dialectic primitives could implement cross-read, but no
  such code is wired. So "corporate reads across nodes" = via the *published layer*, not
  by reading private memories. ⚠️ **This is the single most important thing to confirm we
  agree on** — it is easy to assume "Donna can just read everyone's memory," and the
  design deliberately says otherwise.

### Canary verification (how isolation was proven) 🟡
Two canary systems: a **fake-secret canary** (`sk-test-DO-NOT-STORE-12345` /
`FAKE_CEO_SECRET_…`) swept out of memory/broker/Langfuse/qdrant/neo4j/minio/repo by
`./bin/1215 smoke`'s `canary_check`; and a **hermes-zero tool-level canary** that refuses
any write/commit containing the marker. Findings on record: per-company `HERMES_HOME`
isolation **proven twice** (companies HER-1, HERA-1); one real leak found = **identity
fragmentation** (one human split into peer `miguel` vs Telegram numeric peer
`8246962767`), fixed with `pinPeerName: true`. ⚠️ Note: `8246962767` is the same Telegram
peer currently on this node's Victoria allowlist — worth remembering it was a known
problem peer.

---

## 5. Orchestration model (the loop we want)

```
Operator → Donna (1 contact) → Paperclip creates a company
        → hermes-gateway SPAWNS that company's inner Hermes (only legit spawner)
        → BROKER ("continuity plane", :8090) carries the traffic between agents
        → work happens → results/knowledge PUBLISHED to the shared layer
        → Donna reads the published layer → reports to operator
```

❓ **Historical context / the pain this solves:** months ago the operator could not get
two agents (outer + inner Hermes) to coordinate and was **manually copy-pasting between
them for hours** — hand-simulating a message bus that didn't exist yet. The **broker +
gateway** are exactly the machinery meant to close that gap. Whether they now close it
end-to-end is ⚠️ **unproven in this reconstruction** (see §7).

---

## 6. The reproducible "franchise" node

❓ Intent: any node (a VPS, or a VM on a PC) can be **one-shot bootstrapped** into the full
stack — substrate (the ~14-container mesh), Paperclip, Honcho, a Hermes agent — "ready to
rock." The operator ran VM experiments toward one-shotting the whole setup. 🟡 The repo's
`node` concept + `./bin/1215` control plane + `node-rollout-plan.md` are the codified form.
Operator's current stance (✅ stated): the bootstrap is "good enough / reproducible," and
polishing it further is lower-value than **using it to produce billable work.**

⚠️ The Mac mini "duplicate services" (n8n etc.) suggest a **redundancy/failover** angle in
addition to pure capability-partitioning — i.e., nodes may replicate some services, not
just specialize. Confirm whether duplication is intentional failover or drift.

---

## 7. Open questions, gaps, and possible conflicts (READ THIS FIRST, operator)

This section exists specifically to guard against a "positive projection loop." Each item
is something this doc asserts or assumes that is **not fully verified**:

1. ⚠️ **Cross-node cross-read is an aspiration, not built.** If the operator's mental model
   is "Donna reads all node memories directly," that conflicts with the documented design
   (isolated scopes + published layer). Which is the intent?
2. ⚠️ **One Donna (HQ) vs one outer-Hermes-per-node (franchise).** The two imply different
   architectures. Operator statement leans HQ; the isolation docs lean per-node isolation.
   These aren't contradictory but the boundary needs stating.
3. ⚠️ **Node→persona→hardware mapping is partly inferred** (Mac mini = `cbass`? `nicolai`
   vs `m6800`? where does `samantha` fit?).
4. ⚠️ **Implemented vs documented honcho.json diverge:** the CEO installer hardcodes a
   single shared workspace `1215-vps`/peer `ceo`, while the design docs prescribe
   per-company-ID workspaces. The single-node prototype and the multi-company design are
   not the same shape.
5. ⚠️ **The end-to-end isolation test was never built** (audit: 6/10 E2E tests missing;
   `fake_secret_canary` script absent in 1215-vps). No test forks two companies and proves
   A's canary doesn't surface in B. Isolation is *claimed proven* by ad-hoc runs, not an
   automated gate.
6. ⚠️ **The orchestration loop (§5) is not verified working end-to-end here.** The broker
   is running; whether outer↔inner Hermes actually coordinate without a human relay today
   is unconfirmed.
7. ❓ **What does this node (srv1264451) become?** Permanent node with a role, or staging
   area to consolidate the Victoria-experiment learnings and fold them up to corporate?
8. ❓ **Paperclip utilization is still "a mystery"** to the operator — how companies
   actually use it is not fully understood, even by the person who built it.

---

## 8. This node right now (srv1264451) — ✅ verified 2026-07-10

- **Role in use:** healthy **n8n + n8n-MCP** host (the operator wants to use these because
  another node's n8n/Donna has been flaky). Candidate working node for producing actual
  output.
- **Stack:** Compose project `1215-prototype-local`, 14 containers healthy; host-native
  broker (:8090), honcho (:18000), paperclip app (:3100); Hermes `v` gateway live on
  Telegram. Full node-local operations docs live on the box at `/root/claude/vps-docs/`.
- **Not wired to the shared upper-level memory yet** — this box has no SSH credentials to
  Donna (`100.87.24.49`); reachable on the Tailnet but access is pending operator setup.

---

*This document is a shared-model checkpoint, not a spec. Correct it freely — the whole
point is to converge on one accurate picture before building further.*

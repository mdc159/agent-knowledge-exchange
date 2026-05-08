# Studio54 Primitive / GitHub Actions Experiment — GPT Pro Review Packet

## Purpose

This packet is designed for Miguel to paste into ChatGPT Pro / GPT-5.5 high reasoning for an external critique of the current Studio54/Paperclip/Hermes experiment plan.

The goal is not to ask the external model to mutate infrastructure. The goal is to pressure-test the experimental design, the GitHub workflow, and the repeatability proof strategy before Donna and Miguel keep building.

## Paste-ready prompt

```text
You are reviewing an AI-agent infrastructure experiment for Miguel Martillo.

Context:
- Miguel is building a small "agent empire" around Hermes Agent, Paperclip companies, GitHub, Linear, Notion, Tailscale, and self-hosted/local memory.
- Donna is the Queen Bee / CEO control plane agent.
- Other personas include Victoria, Veronica, Nikolai/Nikoli, Sam, and a planned Mac Mini Hermes node.
- Studio54 is the deployment/proof repo for getting the primitive Paperclip/Hermes element into repeatable, plug-and-play shape.
- Agent Knowledge Exchange is the durable doctrine/knowledge repo.

Core objective:
Design a repeatable primitive deployment experiment so each Paperclip/Hermes company deployment can be reproduced and verified. The primitive should prove both:
1. layered memory correctness; and
2. reliable communications readiness.

Current known misalignment:
A prior Studio54 PR created useful CI/verifier scaffolding and simulated/fake VPS proof, but it did not prove that the live/intended VPS was left in the full memory-correct state. Therefore it should not be treated as the full solution to the issue.

Desired proof gates:
- host/root Hermes scope verified;
- Paperclip company A scope verified;
- Paperclip company B scope verified;
- behavioral sentinel write/recall works in each scope;
- cross-scope isolation/no leakage is proven;
- communications readiness is proven by either direct Donna-to-agent QACK/QDONE or an immediate paste-ready relay fallback;
- output is deterministic and structured, such as JSON reports plus concise Markdown summary.

Communication protocol under consideration:
- QPING: reachability probe;
- QTASK: bounded task handoff;
- QACK: target repeats accepted scope/constraints;
- QSTATUS: progress update;
- QDONE: final result with artifacts;
- QBLOCKED: exact blocker and operator action required;
- QFAIL: failure with evidence and safe next step.

GitHub/cloud resources to consider:
- GitHub Actions;
- GitHub-hosted runners;
- self-hosted runners where appropriate;
- Codespaces or cloud coding agents;
- PR templates;
- issue templates;
- branch protections/checks;
- @mention-style coding/review agents;
- automation that can safely run simulated/read-only proof gates before any live VPS mutation.

Hard constraints:
- Do not store secrets, raw `.env` values, private keys, raw logs, session databases, or memory dumps in GitHub/Linear/Notion.
- Do not mutate live VPS/Paperclip/Hermes infrastructure without explicit human approval.
- Clearly separate simulated CI proof from live environment proof.
- Keep the workflow agent-operable: clear issues, branches, PRs, acceptance criteria, validation artifacts, and review gates.

Please answer:
1. Are we on the right path conceptually?
2. What is the best experimental design for proving the primitive deployment is repeatable and memory-correct?
3. How should the GitHub repo be structured to support this: folders, scripts, Actions, reports, templates, branch protections, and runner strategy?
4. What should be proven in CI versus only proven in an explicitly approved live run?
5. What would you change about the QPING/QTASK/QACK/QDONE communications protocol?
6. What are the biggest failure modes or false positives we should guard against?
7. Give a staged implementation plan with milestones that Donna and Miguel can execute without context corruption.
```

## Links Miguel may include

- Agent Knowledge Exchange PR for current empire/current-structure docs: https://github.com/mdc159/agent-knowledge-exchange/pull/27
- Linear parent roadmap: https://linear.app/1215-labs/issue/121-36/roadmap-agent-fleet-expansion-research-stack-and-automation-leverage
- Linear review-packet task: https://linear.app/1215-labs/issue/121-46/prepare-gpt-pro-review-packet-for-studio54-primitivegithub-actions

## How to bring the answer back

When GPT Pro returns feedback, paste back either:

1. the full response; or
2. a short summary plus the sections it recommends changing.

Donna should then reconcile it into three buckets:

- **Adopt now:** changes that improve safety/repeatability immediately.
- **Park:** good ideas that are not on the critical path.
- **Reject:** ideas that add complexity, weaken proof quality, or bypass the live-mutation approval gate.

## No-secret rule

This packet is safe to paste into an external model because it intentionally excludes credentials, private host details, keys, raw logs, runtime session data, and memory dumps.

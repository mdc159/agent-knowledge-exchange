# Adoption and experiments

**Working draft.** Start with guidance that is present at the point of work. Add mechanisms only when observations show they make the workflow more useful or efficient.

## Smallest useful adoption

1. Place a short compass in the runtime's persistent guidance: know the goal, current evidence and why the next step helps.
2. Make the practical engineering skill available through the runtime's documented automatic-loading mechanism, or adopt its compact loop directly where appropriate.
3. Use domain-specific skills for procedures and project notes for decisions/evidence.
4. Exercise the real loader or context-assembly path. Verify the guidance is included, rather than treating a saved file as activated behavior.
5. Evaluate behavior on real tasks and revise the guidance from observed results.

Keep one maintained source and a small activation reference where the runtime supports it. Choose full automatic loading versus a compact prompt deliberately: balance reliable availability against context cost and repeated guidance. Preserve existing skill selections and instructions when adding an entry.

A possible compact orientation is:

> Work toward the actual human outcome. Use available evidence, take the next useful step within agreed scope, verify the result, and periodically reconsider whether the route still serves the destination.

Saving, loading and practicing are separate milestones. A successful context-loading test verifies availability; behavior is evaluated in task outcomes. Each participating agent or runtime adopts changes explicitly through its own supported configuration.

## Optional small-model assistance

A small classification or routing model may make quick decisions up front: select relevant context or skills, identify a routine path, or flag a change that deserves deeper reasoning. This can spare the main reasoning model repetitive work.

Start with a useful advisory output and a measured fallback. Compare accuracy, latency, inference cost and total reasoning effort against the simpler baseline. Retain the simpler approach when the additional model does not earn its complexity.

## Optional hooks

A pre-reasoning hook is a possible place for lightweight orientation or context selection: it can help even when the main model would otherwise choose no tool action. A pre-tool hook serves a different purpose, such as action-specific context or checks.

Runtime support and timing must be verified before adopting either. Record what a hook sees, what it changes, its timeout/fallback, context cost and whether its output affects future prompt construction. These are design options, not implemented components of this contribution.

Use existing security and approval boundaries as the foundation. The purpose of these optional mechanisms is efficient, well-oriented assistance rather than constructing a second prohibition engine.

## Evaluate the destination, not motion

Use a few representative tasks, including imperfect inputs and collaborator requests. Review:

- Was the useful outcome reached and actually checked?
- Did partial evidence produce value early?
- Did an experiment resolve uncertainty or improve the route?
- Did the agent reorient when an implementation detour stopped serving the goal?
- Did collaboration preserve the agreed participants and resources?
- Was overhead proportionate to benefit?

Record concise examples and revise the working draft. No benchmark result or model-efficiency improvement is claimed here; those come from experiments.

## Current contribution

This folder documents the philosophy, adoption options and a portable skill. It installs no hook, model, service or global prompt change. Runtime-specific deployments remain separately configured and verified.

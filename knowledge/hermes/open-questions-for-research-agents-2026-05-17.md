# Open Questions for Follow-Up Research Agents — 2026-05-17

Status: handoff packet for independent research agents

## Purpose

This note captures unresolved questions from the Caboose documentation, CAD/FEA evaluation, and ComfyUI/RunPod template work. The goal is to let a separate agent investigate these questions without pulling the main Nikoli control-room context into another rabbit hole.

## Operating rules for the follow-up agent

- Treat this as research and evidence gathering, not implementation.
- Do not print or commit secrets, `.env` contents, bearer tokens, or raw runtime state.
- Record exact source URLs, repo SHAs, commands, and artifact paths when verified.
- Separate evidence from inference.
- If a question requires a paid API or credentialed account, stop at the documented request boundary and say what credential/scope is required.
- Prefer concise Markdown reports under the relevant `knowledge/` area.

## Caboose documentation questions

1. **Native Kanban alignment**
   - Are there additional Hermes Kanban primitives that should be explicitly named in the Caboose pattern, especially review-required gates, metadata handoffs, comments, or dashboard affordances?
   - Evidence target: Hermes docs or code references.

2. **Best artifact shape**
   - Should Caboose standardize on Markdown-first with optional HTML, HTML-first with Markdown source, or a paired report model?
   - Evidence target: comparison of ease of review, git diffs, dashboard readability, and transfer to other agents.

3. **Judge automation boundary**
   - What checks can a Caboose Judge safely automate without becoming a second workflow engine?
   - Candidate checks: required headings, diagram presence, artifact path existence, status-color vocabulary, no secrets, next-gate criteria.

4. **Biology-project transfer**
   - What section labels should be added for biology or medical-adjacent research: safety/ethics boundary, clinical-not-medical disclaimer, data provenance, protocol uncertainty?
   - Evidence target: examples of research documentation structures, not medical advice.

## CAD/FEA evaluation questions

1. **CAD Skills lane**
   - Is the G1 circular flange failure representative of a structural limitation in the CAD Skills harness, or just a bad prompt/spec/validation target?
   - Evidence target: reproduce with pinned SHA, prompt, generated STEP, independent CAD review screenshots, and validation JSON.

2. **Benchmark A solver loop**
   - Partly answered by the 2026-05-21 local smoke: Gmsh CLI -> CalculiX produced STEP, `.msh`, `.inp`, `.frd`, and a summary JSON without cloud APIs or licensed tools. See `knowledge/research/CAD-FEA Local Solver Loop Progress 2026-05-21.md`.
   - Remaining question: what is the smallest fully local proof loop that includes faithful Benchmark A geometry, independent geometry check, robust named boundaries, parsed displacement/stress extrema, and a geometry-revision step?
   - Evidence target: one reproducible run with paths, commands, versions, parsed result extrema, and expected analytical comparison.

3. **FreeCAD/CalculiX lane**
   - What is the lowest-friction local install path on this WSL/Windows workstation, and should execution happen in WSL, Windows, or a VM?
   - Evidence target: install commands, version probes, a cantilever or bracket FEM smoke test.

4. **Commercial tool bridge**
   - What minimal ANSYS PyMechanical or COMSOL MPh smoke test is safe to run without consuming long license time or mutating production projects?
   - Evidence target: read-only or disposable model workflow, no private license data in report.

## ComfyUI / RunPod questions

1. **Template metadata resolution**
   - For a RunPod deploy URL such as `https://console.runpod.io/deploy?template=x4px1sy09w`, what authenticated endpoint and fields reliably reveal the image name, ports, volumes, env keys, and startup command?
   - Evidence target: API docs or a credentialed test with sensitive values redacted.

2. **Image provenance**
   - Once a template image is known, what registry metadata should be captured before using or deriving from it?
   - Candidate fields: digest, tag, Dockerfile/source link if public, CUDA/Python/PyTorch versions, exposed ports, default command, license notes.

3. **Local baseline preservation**
   - What should be the canonical local ComfyUI baseline checklist before experimenting with new images?
   - Evidence target: current working local container properties, model mount assumptions, rollback steps.

4. **Agent-safe ComfyUI experiments**
   - What is the smallest safe agent-run experiment that proves model path/mount correctness without consuming expensive GPU time?
   - Evidence target: tiny workflow, low-resolution generation, or metadata-only probe.

## Desired output format

Follow-up agents should return:

1. one-paragraph answer per question;
2. evidence links or local artifact paths;
3. confidence level: high / medium / low;
4. what this changes in the Caboose pattern, CAD/FEA project, or ComfyUI runbook;
5. any proposed PR-ready edits.

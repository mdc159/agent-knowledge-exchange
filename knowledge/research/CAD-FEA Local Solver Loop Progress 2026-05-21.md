# CAD/FEA Local Solver Loop Progress — 2026-05-21

Status: evidence update for shared agents  
Project source: workstation-agent WSL `cad-fea-eval` board and local artifact bundle  
Last verified: 2026-05-22T09:08:26Z

## Purpose

Capture the latest CAD/FEA evaluation progress so other agents can see what has moved from planning/research into local execution. This is not a full artifact mirror; it is a durable summary with enough paths, commands, and caveats for another agent to pick up the next card without reading the whole chat history.

## Summary

The project now has a first local, script-first **CAD -> Gmsh mesh -> CalculiX** smoke run for Benchmark A. It produced a STEP file, a Gmsh `.msh` tetrahedral mesh, a CalculiX `.inp`, and CalculiX result files including `.frd`. The run is intentionally scoped as a smoke proof: it proves local toolchain invocation and artifact flow, not engineering correctness.

The main board also has a completed Caboose documentation checkpoint and a shared knowledge PR carrying the Caboose pattern. Caboose should remain a thin documentation/review overlay over native Kanban primitives, not a second workflow engine.

## Current board state at handoff

Board: `cad-fea-eval`

Observed state:

- `done`: 18
- `blocked`: 2
- `todo`: 1
- `ready`: 0
- `running`: 0

Important active gates:

| Card | Status | Meaning |
| --- | --- | --- |
| `t_14e494a8` — A1: Benchmark A local CAD-mesh-CalculiX smoke | blocked / review-required | Smoke run passed; waiting for human/controller acceptance of simplifications and toy boundary conditions. |
| `t_d2fe054c` — G1: CAD Skills Benchmark 2 circular flange local generation | blocked intentionally | CAD Skills produced plausible STEP but failed design-intent/production-CAD section review; retained as evidence, not an active rework target. |
| `t_9f64f7cd` — G2: CAD Skills primitive suite | todo | Dependent on G1; should not advance until the lane decision is revisited. |

## Benchmark A smoke evidence

Canonical local report:

```text
/home/example-user/projects/cad-fea-eval/experiments/benchmark-a-open-source-solver-loop/reports/benchmark-a-smoke.md
```

Canonical summary JSON:

```text
/home/example-user/projects/cad-fea-eval/experiments/benchmark-a-open-source-solver-loop/results/benchmark-a-smoke-summary.json
```

Run directory:

```text
/home/example-user/projects/cad-fea-eval/experiments/benchmark-a-open-source-solver-loop/runs/20260521T115951Z
```

Key artifacts:

| Artifact | Path |
| --- | --- |
| Gmsh geometry | `runs/20260521T115951Z/cad/benchmark_a_calibration_bracket.geo` |
| STEP export | `runs/20260521T115951Z/cad/benchmark_a_calibration_bracket.step` |
| Gmsh mesh | `runs/20260521T115951Z/mesh/benchmark_a_calibration_bracket.msh` |
| CalculiX input | `runs/20260521T115951Z/fea/benchmark_a_calibration_bracket.inp` |
| CalculiX field result | `runs/20260521T115951Z/fea/benchmark_a_calibration_bracket.frd` |
| CalculiX log | `runs/20260521T115951Z/logs/ccx.log` |
| Mesh summary | `runs/20260521T115951Z/results/mesh-summary.json` |

Executed command classes:

```bash
bash experiments/benchmark-a-open-source-solver-loop/scripts/verify_native_prereqs.sh
python3 experiments/benchmark-a-open-source-solver-loop/scripts/run_benchmark_a_smoke.py
/usr/bin/gmsh <benchmark>.geo -0 -format step -o <benchmark>.step
/usr/bin/gmsh <benchmark>.geo -3 -format msh2 -o <benchmark>.msh
/usr/bin/ccx benchmark_a_calibration_bracket
```

Observed smoke results:

- status: `pass`
- local-first only: `true`
- cloud APIs or credentials used: `false`
- licensed tools launched: none
- mesh nodes: 900
- C3D4 tetrahedra: 2517
- CalculiX exit code: 0
- CalculiX `.frd` generated: yes
- `ccx.log` reports `Job finished`

## Important caveats

This run does **not** prove physical correctness.

Known limitations from the report/summary:

- Smoke proof only; not validated engineering analysis.
- Geometry uses Gmsh OCC `.geo`, not a FreeCAD FEM workflow.
- Outside R3 corner radius is recorded from the spec but not modeled in this first smoke geometry.
- Slot is interpreted as a rectangular left-edge notch.
- Boundary conditions are toy constraints/load selected only to prove solver invocation.
- `.dat` exists but is empty because this minimal input requested `.frd` field output rather than printed tabular values.
- Native prerequisite verification still exits non-zero because system Python cannot import `gmsh`; this did not block the smoke because `/usr/bin/gmsh` and `/usr/bin/ccx` were used directly.

## Visual check

operator opened the Gmsh mesh in the GUI and saw the calibration bracket mesh, confirming the `.msh` artifact is viewable. Treat this as visual sanity evidence only; it is not a formal mesh-quality or solver validation.

## Caboose documentation status

CAD/FEA Caboose outputs exist locally:

```text
/home/example-user/projects/cad-fea-eval/docs/caboose-documentation-standard.md
/home/example-user/projects/cad-fea-eval/reports/caboose-dashboard-2026-05-17.html
/home/example-user/projects/cad-fea-eval/reports/status-report-2026-05-17.html
```

The shared Caboose pattern is already included in the knowledge PR as:

```text
knowledge/hermes/caboose-phase-documentation-pattern.md
skills/shared/caboose-phase-documentation-gate/SKILL.md
```

Operating rule: run Caboose at meaningful phase boundaries. Do not call Caboose after every small card. Native Kanban remains the truth ledger; Caboose is the readable checkpoint.

## Recommended next card

Accept or reject `A1` after reviewing the smoke report and visible mesh. If accepted, create the next focused technical card:

> Strengthen Benchmark A mesh/BC automation: model R3 outside corners, use robust named boundary selection rather than coordinate extrema, parse `.frd` displacement/stress extrema into JSON, and keep the same Gmsh CLI -> CalculiX path before adding FreeCAD FEM workflow complexity.

## What other agents should not do

- Do not claim Benchmark A is physically validated.
- Do not introduce cloud APIs, Zoo credentials, COMSOL, ANSYS, Creo automation, or UI-driving tools into this lane without a separate approved card.
- Do not resurrect the CAD Skills G1 circular flange rework as active work unless the question is explicitly to diagnose whether the failure was prompt/spec/tooling.
- Do not fork Caboose into a separate state machine, database, or dispatcher.

## Open questions updated by this run

- The smallest local proof loop question is now partly answered: Gmsh CLI -> CalculiX can complete a smoke loop locally.
- The next unresolved question is narrower: can the loop produce a more faithful Benchmark A geometry, robust named boundaries, and parsed result extrema while staying script-first and local-only?

# Addendum: Hand Sketch to Engineering Model Workflow

For the Hermes / Paperclip engineering design system.

## Purpose

This addendum clarifies the intended workflow for converting a hand sketch, patent figure, or other 2D mechanical concept into a spatially reasoned, parametric, simulation-ready engineering model. The generated image stage is not cosmetic. It is a spatial-hypothesis stage used to infer possible orthographic views and hidden geometry before rebuilding the design as CAD.

## Core correction

The correct target is not “sketch to pretty rendering.” The target is “sketch to spatial hypothesis to constrained CAD to verified engineering analysis.” The image or mesh output is never the final engineering model. It is an intermediate reasoning artifact used to help reconstruct a dimensioned, parameterized model.

## 1. Revised workflow model

The workflow should be represented as a staged engineering pipeline:

1. hand sketch, phone photo, or patent figure
2. sketch cleanup and annotation extraction
3. spatial interpretation and hidden-geometry hypotheses
4. controlled orthographic view synthesis
5. multi-view consistency checking
6. rough 3D asset or visual mesh generation
7. mesh quality control and measurement extraction
8. parametric CAD rebuild in CadQuery, FreeCAD, Creo, or equivalent
9. reduced-order engineering checks in Python or MATLAB
10. CAE setup in ANSYS, CalculiX, or another solver
11. verification, dossier generation, and skill-memory update

Important boundary: the system may infer shape from a 2D sketch, but it cannot infer scale, material, tolerances, load cases, or safety suitability unless those are supplied or explicitly modeled. A prosthetic component inferred from a sketch could be nine feet tall if no scale reference exists. Therefore, the pipeline must record scale assumptions and reject engineering analysis until at least one dimension or reference constraint is available.

## 2. Agent roles and artifacts

| Stage | Agent | Primary output | Primary verification |
|---|---|---|---|
| Sketch intake | Sketch Intake Agent | `clean_sketch.png`; `sketch_annotations.json`; `known_dimensions.json` | Deskewed, cropped, text/callouts extracted, at least one scale reference requested if absent. |
| Spatial interpretation | Spatial Interpretation Agent | `spatial_hypothesis.json`; `mechanism_graph.json` | Components, joints, symmetries, and hidden-geometry hypotheses are explicit and uncertainty-scored. |
| View synthesis | Prompt/View Synthesis Agent | `front.png`; `side.png`; `top.png`; `isometric.png`; `prompts.json` | Topology preserved: same hole count, joint count, link count, datum logic, and visible functional surfaces. |
| View consistency | Multi-View Consistency Agent | `view_consistency.json`; `rejected_views/` | Hole centers, axes, mating faces, and inferred features agree across views or are flagged. |
| 3D concept asset | 3D Asset Agent | `concept_mesh.glb/obj`; `generation_log.json` | Mesh is treated as visual reference only, not simulation authority. |
| Mesh QC | Mesh Repair/QC Agent | `mesh_qc.json`; `mesh_measurements.json` | Watertightness, normals, components, non-manifold defects, and scale assumptions are reported. |
| CAD rebuild | CAD Reconstruction Agent | `cad_rebuild_plan.md`; `feature_tree.json`; `part.step`; CAD source | CAD is parametric, regenerable, dimensioned, and exports cleanly. |
| Reduced-order checks | MATLAB/Python Analysis Agent | `hand_calc.py` or `.m`; `assumptions.md`; plots | Loads, units, boundary assumptions, and first-order stress/stiffness are plausible. |
| CAE | FEA/CFD Agent | solver input; mesh report; `results.csv`; plots | Analysis runs only on rebuilt CAD with explicit loads, constraints, materials, and convergence checks. |
| Review and memory | Verification/Skeptic and Dossier Agents | `engineering_dossier.md`; `artifact_manifest.json`; `skill_candidate.md` | The result is marked as concept, analysis-grade, decision-grade, or build-blocked; skill promotion requires repeatability. |

## 3. `spatial_hypothesis.json` as the key contract

The system should create a structured object between vision/image generation and CAD. This object prevents model imagination from silently becoming engineering fact.

```json
{
  "source_type": "hand_sketch | patent_figure | photo",
  "object_class": "mechanical bracket / linkage / housing / prosthetic subcomponent",
  "known_dimensions": {
    "overall_length_mm": null,
    "hole_diameter_mm": null,
    "scale_reference": "missing"
  },
  "inferred_features": [
    {
      "name": "clevis ears",
      "evidence": "side sketch shows fork-like end with coaxial pin hole",
      "confidence": 0.72,
      "engineering_status": "hypothesis"
    }
  ],
  "symmetry_assumptions": ["possible mirror symmetry about center plane"],
  "hidden_geometry_hypotheses": ["two parallel side plates rather than one plate"],
  "do_not_treat_as_fact": [
    "material",
    "load capacity",
    "fatigue life",
    "human-use safety",
    "scale without reference dimension"
  ],
  "required_human_or_agent_review": [
    "datum selection",
    "wall thickness",
    "pin diameter",
    "load case",
    "safety classification"
  ]
}
```

## 4. Model and hardware routing

| Resource/model | Best use | Avoid using it for |
|---|---|---|
| Gemini or other strong vision model | Sketch interpretation, figure decomposition, spatial explanation, view-type identification. | Final CAD authority, safety conclusions, direct FEA setup. |
| ComfyUI / image models | Controlled orthographic and isometric view synthesis; prompt mutation; concept visualization as spatial hypotheses. | Decorative redesign, uncontrolled product styling, hidden feature invention. |
| Stable Fast 3D / TripoSR / Hunyuan3D / TRELLIS | Rough visual 3D asset generation from view images or prompts. | Simulation-ready geometry or build-ready CAD. |
| Open3D / trimesh / PyMeshLab / Blender | Mesh QC, cleanup, orientation, visual inspection, and measurements. | Replacing parametric CAD for engineering intent. |
| CadQuery / FreeCAD | Fast scripted CAD rebuild and test geometry. | Final production CAD when Creo is required for release workflow. |
| PTC Creo | Authoritative professional CAD, templates, assemblies, drawings, feature naming, mass properties. | Screenshot-click automation as the primary model authoring path. |
| MATLAB / Python | Reduced-order checks, units, loads, parameter studies, simulation pre-checks. | Replacing CAE validation for complex physics. |
| ANSYS / CalculiX / other solvers | FEA/CFD after CAD rebuild, load definition, mesh checks, convergence checks. | Running directly on unconstrained generated meshes. |
| Mac Mini | 24/7 low-cost iteration: patent search, prompt optimization, small-model evals, memory consolidation. | Heavy image generation or high-end 3D generation. |
| 96 GB VRAM workstation | Local multimodal workers, LoRA experiments, larger 3D models, concurrent agents, local embeddings/retrieval. | Replacing deterministic workflows or engineering verification. |

## 5. First benchmark workflow

The first benchmark should not be a full prosthetic limb. Use a simple mechanical subcomponent with one clear load path, such as a clevis bracket, linkage arm, motor mount, prosthetic adapter plate, hinge link, pulley bracket, or small housing with bosses.

Input: one phone photo of a hand sketch or one patent figure, plus one known dimension if possible.

Expected artifacts:

- `clean_sketch.png`
- `spatial_hypothesis.json`
- `front.png`, `side.png`, `top.png`, `isometric.png`
- `view_consistency.json`
- `concept_mesh.glb` or `concept_mesh.obj`
- `mesh_qc.json` and `mesh_measurements.json`
- `cad_rebuild_plan.md` and `feature_tree.json`
- `part.step` and regenerable CAD source
- `reduced_order_check.py` or `reduced_order_check.m`
- solver input, solver logs, `result_summary.csv`, plots
- `engineering_dossier.md` and `artifact_manifest.json`

## 6. Pass/fail criteria

Pass criteria:

- System preserves sketch topology across generated views.
- At least one scale reference is recorded, or the workflow blocks engineering analysis.
- All inferred hidden features are marked as hypotheses with evidence and confidence.
- Generated mesh is used only as visual/reference geometry.
- CAD rebuild is parameterized, regenerable, and exports cleanly to STEP.
- Reduced-order check documents units, loads, assumptions, and obvious limits.
- FEA/CAE runs only after CAD rebuild and explicit load/constraint/material definition.
- Dossier clearly states uncertainty and non-build status unless formally reviewed.

Fail criteria:

- Image model changes hole count, joint count, link count, or functional surfaces without flagging it.
- System treats an unscaled sketch or generated mesh as engineering geometry.
- CAD agent copies a defective mesh instead of rebuilding features.
- FEA is run before loads, materials, constraints, or scale are defined.
- One successful experiment is promoted directly into trusted skill memory.
- Dossier hides uncertainty or omits evidence for inferred geometry.
- Safety-critical or human-use conclusions are made without professional review.

## 7. Skill-memory promotion gate

Hermes self-learning is useful, but engineering workflows need a promotion gate. Separate memory into episodic memory, artifact memory, skill memory, and company operating memory. A workflow should become a trusted skill only after repeatability and verification.

- Run completed end-to-end and produced every required artifact.
- Automated checks passed: scale, topology, mesh QC, CAD export, solver logs, and dossier completeness.
- Verification/Skeptic Agent reviewed the run and recorded limitations.
- The workflow was repeated on at least one variant.
- Known failure modes and negative lessons were stored separately from executable skill memory.
- A human engineer reviewed any workflow that could affect safety-critical, medical, pressure, thermal, rotating, combustion, or high-energy systems.

## 8. Bottom line

The intended system is not “AI draws a product.” It is a company-style agent workflow that converts uncertain visual input into audited engineering artifacts. The generated views and rough 3D mesh are spatial hypotheses. The engineering value appears when those hypotheses are tested for consistency, rebuilt as parametric CAD, checked with reduced-order calculations, analyzed with CAE, and documented with uncertainty and review gates.

Preferred one-line formulation: paper sketch or patent figure → spatial hypothesis → controlled views → visual 3D reference → parametric CAD rebuild → reduced-order check → CAE → dossier → gated skill update.

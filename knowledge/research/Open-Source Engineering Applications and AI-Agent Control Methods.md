# Open-Source Engineering Applications and AI-Agent Control Methods

## Executive recommendation

The shortest credible path to an AI-agent-operable open-source engineering workbench is **script-first, file-first, GUI-last**. For near-term product design and analysis, I recommend a primary stack of **CadQuery for parametric geometry, Gmsh for meshing, CalculiX for structural FEA, SU2 for the first fully headless CFD pipelines, ParaView and PyVista for post-processing, and Markdown/Jupyter/Pandoc-style report generation for the engineering dossier**. Use **FreeCAD** as a secondary CAD and drawing environment when you need import-repair, sketch-driven edits, or human review; use **Blender** and Python mesh tools only for mesh cleanup, visualization, and reconstruction support, not as the source of engineering truth. This recommendation follows directly from the documented scriptability, headless operation, plain-text inputs, and automation surfaces of these tools. citeturn44view0turn44view1turn45view0turn17search0turn34search10turn34search12turn43view0turn31search1

The reason to prefer this stack over a heavier GUI-centered one is not that the tools are universally “best” in absolute engineering capability. It is that they expose the right control surfaces for agents: **Python libraries or script interpreters, stable CLIs, versionable text files, batch execution modes, and outputs that can be inspected automatically**. CadQuery is intentionally GUI-less by design; Gmsh supports both scripting and API-driven workflows; CalculiX runs from Abaqus-like input decks on the command line; SU2 uses text configuration files and explicit marker names for boundary conditions; ParaView can convert GUI traces into `pvpython` and `pvbatch` scripts; OpenFOAM cases are organized around readable ASCII dictionaries. Այդ combination is what makes reproducible agent operation realistic now. citeturn44view0turn45view0turn17search0turn34search6turn34search10turn34search12turn43view0turn43view1turn32search3turn46view0

The most important negative recommendation is equally clear: **do not make GUI manipulation the primary authoring path for engineering data if a script or text-file path exists**. GUI macro and desktop-control methods are useful for inspection, trace capture, and occasional recovery, but they are too brittle for primary model creation in CAD/CAE. The right hybrid pattern is: **agent writes scripts and solver files, runs the tools headlessly, opens a GUI only to inspect geometry or results, and then emits a reproducible artifact for every final decision.** ParaView’s trace system, OpenSCAD’s CLI export model, Blender background scripting, and FreeCAD’s command-line and Python surfaces all fit this pattern better than raw screenshot-driven desktop automation. citeturn43view2turn43view0turn42view0turn47search7turn39search10turn39search17

For concept generation and reconstruction, the strategic conclusion is more conservative. Current open image-to-3D and mesh-generation systems such as **Hunyuan3D**, **TripoSR**, **Stable Fast 3D**, **InstantMesh**, and **Shap-E** mainly produce **meshes or textured assets**, not parametric solids or engineering-quality B-reps. They are useful as **reference geometry**, not as simulation authority. Likewise, photogrammetry and Gaussian-splatting pipelines such as **COLMAP**, OpenMVS, 3D Gaussian Splatting, and SuGaR are powerful for reconstructing scenes and editable visual assets, but they do not remove the need to rebuild critical geometry into parametric CAD before engineering analysis. citeturn18search0turn18search2turn18search14turn19search0turn27view0turn26search0turn28view0turn19search1turn19search4turn24view0turn21search0turn25view0

## Tool matrix

The **agent-readiness score** below is my synthesis, using a 1–5 scale based on determinism, headless support, scriptability, file openness, and Linux/WSL practicality. It is not a project-provided metric. citeturn44view0turn45view0turn17search0turn34search12turn43view1

| Tool | Category | Primary use | Headless support | Python API | CLI / batch support | GUI automation suitability | File formats | Agent-readiness score | Main risks |
|---|---|---|---|---|---|---|---|---:|---|
| CadQuery | Parametric CAD | Scripted mechanical parts and assemblies | Strong | Native | Strong through Python execution | Low need | STEP, STL, DXF, glTF, XML/XBF | 5 | Best near-term CAD authoring tool for agents because it is a Python library and explicitly GUI-less; weaker than interactive CAD for ad hoc sketch repair and imported-feature healing. citeturn44view0turn44view1turn44view2 |
| FreeCAD | Parametric CAD and drafting | Sketch-driven edits, import/repair, FEM front-end, TechDraw-style review | Partial to strong | Embedded Python | Good via command line / `freecadcmd` surfaces | Medium, but better via scripting/macros than image automation | FCStd, STEP, IGES, BREP, STL and more | 4 | Very useful secondary tool, but broader workbench surface and GUI-centric workflows make it less deterministic than CadQuery for unattended agents. Official docs show command-line startup and large Python scripting support. citeturn39search10turn39search2turn39search17 |
| OpenSCAD | Scripted CAD | Simple CSG parts, fixtures, enclosures, laser-cut / print-heavy geometry | Strong | No native Python API, but easy subprocess control | Strong | Low need | SCAD, STL, OFF, 3MF, DXF, SVG, PNG, PDF | 4 | Excellent for deterministic CSG and parameter sweeps; poor fit for imported B-rep editing and more advanced mechanical surfacing. citeturn41view0turn42view0 |
| Blender | Mesh modeling and visualization | Mesh cleanup, rendering, visual inspection, scripted mesh transforms | Strong in background mode | Native | Strong | Medium only for inspection; primary desktop automation is brittle | BLEND, OBJ, STL, PLY, glTF and many others | 3 | Powerful, but it is a mesh/content tool, not an engineering solid modeler. Use background scripting and avoid using Blender meshes as the authoritative engineering model. citeturn1search10turn47search7 |
| Open3D / trimesh / PyMeshLab | Mesh repair and validation | Watertightness checks, cleanup, remeshing, orientation, measurement | Strong | Native | Usually invoked through Python scripts | Low need | OBJ, STL, PLY and related mesh formats | 5 | This is the best automation tier for mesh validation. `trimesh` emphasizes watertight surfaces; Open3D exposes mesh analysis including watertightness; PyMeshLab gives scripted access to MeshLab filters. citeturn30search1turn30search13turn2search11turn2search15turn2search14 |
| Gmsh | Meshing | Scripted 1D/2D/3D meshing from geometry or scripts | Strong | Native | Strong | Low need | GEO, MSH, STEP/IGES import, MED/CGNS post data, export across multiple mesh formats | 5 | Core mesher for agents. Strong API, batch meshing, physical groups, and standard CAD import. Less ideal than SALOME for some very complex interactive prep, but much more automatable. citeturn45view0turn37search0 |
| CalculiX | FEA | Linear and nonlinear structural, thermal, contact-style problems through Abaqus-like decks | Strong | No primary Python API; control via files | Strong | Low need | INP input, FRD/DAT outputs | 5 | Best first FEA solver for agents because the input deck is text and the command pattern is simple. Risks are solver interpretation, element choices, and manual responsibility for units and golden rules. citeturn17search0turn17search3turn32search4turn32search14 |
| Elmer | Multiphysics FEA | Thermal, electromagnetics, multiphysics, parallel runs | Strong | More file-driven than Python-driven | Strong | Low to medium | SIF, Elmer mesh DB, VTK-style post paths | 3 | Capable and scriptable, but the working style is more specialized and less streamlined for general mechanical-product agents than CalculiX. Documentation emphasizes solver manuals, test cases, and SIF-driven studies. citeturn7search2turn7search3turn7search9 |
| SU2 | CFD and adjoint | Headless CFD, especially clean benchmark and aero pipelines | Strong | Python helpers available | Strong | Low need | CFG config, mesh with named markers, history / visualization outputs | 5 | For first agent-run CFD, SU2 is easier to reason about than OpenFOAM because a single config file and explicit mesh markers own much of the case definition. It is narrower than OpenFOAM in ecosystem breadth. citeturn34search5turn34search6turn34search10turn34search12turn34search0turn34search4 |
| OpenFOAM | CFD | General CFD platform for internal flow, turbulence, and larger solver ecosystem | Strong | Mostly file/CLI centric rather than Python-native | Strong | Low need | ASCII dictionaries, `polyMesh`, time directories, function-object outputs | 4 | Extremely powerful and deeply scriptable, but more sprawling for agents: more files, more conventions, more places to make boundary-condition mistakes. Add after SU2, not before, if the goal is shortest-path automation. citeturn32search3turn45view1turn46view0turn46view1turn46view2 |
| ParaView / PyVista | Post-processing | Automated screenshots, slices, traces, result summaries, interactive review | Strong | Native Python for PyVista; `pvpython` / `pvbatch` for ParaView | Strong | Medium for trace-capture, low for primary automation | VTK, VTU, VTP, CSV, PVSM, images | 5 | Ideal post-processing tier. ParaView traces can bootstrap scripts; PyVista makes it easy to generate reproducible images headlessly. Risk is producing attractive but physically empty visuals unless result checks are scripted first. citeturn43view0turn43view1turn43view2turn31search1turn31search3turn31search6turn30search3 |

A second tier of **supporting or deferred tools** is still important, but I would not center the first agent stack on them. citeturn10view0turn13search0turn19search1turn24view0turn25view0

| Tool | Category | Primary use | Headless support | Python API | CLI / batch support | GUI automation suitability | File formats | Agent-readiness score | Main risks |
|---|---|---|---|---|---|---|---|---:|---|
| SALOME / Code_Aster | Advanced CAE | Large CAE studies, coupled prep, higher-end structural workflows | Partial to good, but less cleanly evidenced here than Gmsh/CalculiX | Python surfaces exist in the ecosystem, but I did not verify a minimal first-class batch path in this pass | Mixed | Medium | MED and Code_Aster command/doc ecosystem | 2 | High capability, lower near-term agent readiness. The documentation surface is large and specialized; reserve for later Paperclip agents after the first stack is proven. citeturn8search0turn10view0turn13search0turn13search2 |
| COLMAP / OpenMVS | Reconstruction | Photogrammetry, dense point cloud and textured mesh recovery | Strong | PyCOLMAP exists; OpenMVS is more toolchain-oriented | Strong | Low need | COLMAP DB/model files, textured mesh outputs | 3 | Best reconstruction path for scanned or photo-derived reference geometry, but outputs are still reconstruction assets, not engineering solids. OpenMVS build/deployment is more brittle than COLMAP. citeturn19search1turn19search4turn19search20turn24view0 |
| Text and image to 3D models | Concept mesh | Rough concept geometry and visual ideation | Usually strong | Often Python-first | Often strong | Low need | Meshes and textures | 1 | Good for visual reference only. Hunyuan3D, TripoSR, Stable Fast 3D, InstantMesh, and Shap-E all foreground mesh or textured-asset outputs rather than parametric CAD. citeturn18search0turn18search2turn19search0turn27view0turn26search0turn28view0 |

## Recommended Hermes and Paperclip architecture

**Hermes subagents can already own the “research → script → run → inspect → document” loop for the core stack**. They are a good fit for CadQuery, Gmsh, CalculiX, SU2, Open3D/trimesh, PyVista, and report generation because those tools are exposed through Python, text files, CLIs, or all three. Hermes can also operate FreeCAD, Blender, and ParaView effectively **when the goal is inspection or trace generation**, not when the goal is repeated GUI clicking. citeturn44view0turn45view0turn17search0turn34search12turn43view2turn31search1

The Paperclip idea is still valuable, but the specialization should be **workflow ownership plus verification discipline**, not merely narrower prompting. The right Paperclip agents are the ones that can own a boundary of engineering responsibility and emit artifacts with clear pass/fail checks.

| Agent | Required tools and skills | Inputs | Outputs | Verification criteria | Minimal first benchmark | Hermes now or Paperclip later |
|---|---|---|---|---|---|---|
| Research Librarian | Official docs, tutorials, benchmark cases, install notes | Tool name, physics domain, benchmark question | Curated sources, starter cases, known caveats | Primary-source coverage, tutorial provenance, license clarity | Gather official cantilever, pitzDaily, NACA0012, and Elmer beam examples | Hermes now |
| CAD Reconstruction | CadQuery first; FreeCAD second; dimension extraction; feature decomposition | Requirements, rough mesh, target dimensions | CAD script, STEP, STL, optional FCStd | Solid closes, dimensions match intent, named interfaces survive export | Rebuild a bracket or nozzle from a reference mesh | Hermes now, Paperclip later for complex feature healing |
| Mesh Repair | Open3D, trimesh, PyMeshLab, Blender | OBJ/STL/PLY/GLB mesh | Cleaned mesh, repair log, measurements | Watertightness, manifoldness, consistent normals, scale/orientation checks | Repair a non-manifold concept mesh and report defects | Hermes now |
| Meshing | Gmsh first; later SALOME or OpenFOAM meshing | STEP/BREP or parameter script | MSH, INP, SU2/open solver mesh, mesh report | Physical groups, skewness/quality thresholds, refinement logic, boundary names | Cantilever beam mesh with named fixtures and loads | Hermes now |
| FEA | CalculiX first; Elmer second; materials, loads, BCs, result parsing | Solid geometry, mesh, load cases, material model | INP/SIF, solver logs, plots, result tables | Unit checks, reaction-force balance, displacement/stress sanity, mesh sensitivity | Cantilever beam versus analytical deflection | Hermes now |
| CFD | SU2 first, OpenFOAM second; BCs, solver choice, convergence review | Flow domain, mesh, fluid properties, BCs | CFG / OpenFOAM case, logs, residual/history plots | Boundary markers correct, residual drop, monitor stability, mass balance | NACA0012 or backward-facing-step style case | Hermes now for SU2; Paperclip for richer OpenFOAM workflows |
| Visualization and Post | ParaView, PyVista, VTK | Solver outputs | Slices, contours, screenshots, CSV summaries, PVSM/Python traces | Images correspond to checked fields and time steps, camera/state saved | Automated displacement and pressure-drop figures | Hermes now |
| Engineering Dossier | Markdown, Jupyter, Pandoc, report templates | Inputs and outputs from all prior agents | Structured report, assumptions register, artifact manifest | Every claim linked to an artifact; limitations explicit | One benchmark report end to end | Hermes now |
| Verification and Skeptic | Cross-checking scripts, unit logic, analytical checks | All workflow artifacts | Audit notes, stop/go decision, next-test requests | Units, BCs, convergence, mesh independence, plausibility | Audit the cantilever and duct benchmarks | Paperclip strongly recommended |

The practical split is simple. **Hermes should run the first reproducible stack now. Paperclip should appear only when a workflow repeatedly fails in the same domain-specific way**: mesh labeling, FreeCAD repair, OpenFOAM case assembly, material-model assumptions, or result skepticism. That is where specialized agents produce leverage.

## Control-method analysis

The control-method ranking I recommend is:

1. **Pure file-based control**
2. **CLI / batch execution**
3. **Python API control**
4. **GUI trace / macro capture**
5. **Desktop automation**
6. **Hybrid review loops**

That ranking is driven by evidence from the tools themselves. OpenFOAM is built around readable dictionaries and standard case folders; SU2 uses a text configuration file and named markers; CalculiX is driven by text input decks; OpenSCAD is fundamentally text-to-geometry; Gmsh supports both `.geo` scripts and an API; CadQuery is already pure Python. These are the most agent-friendly control surfaces because every step can be diffed, linted, versioned, and replayed. citeturn32search3turn46view0turn34search10turn34search6turn17search0turn42view0turn45view0turn44view0

**Python API control** is the best default for geometry generation, mesh repair, and post-processing. CadQuery, Gmsh, Blender, Open3D, PyVista, and FreeCAD all expose useful Python surfaces, but they are not equal. CadQuery and PyVista are “agent-natural” because they are directly Pythonic. Gmsh is close behind. FreeCAD Python is powerful, yet more stateful and workbench-shaped. Blender Python is excellent for mesh and scene automation but should be constrained to mesh work, rendering, and scripted transforms. citeturn44view0turn45view0turn31search1turn2search11turn39search2turn47search7

**GUI traces and macros** are useful only when they help you cross the scriptability gap once and then get out of the way. ParaView is the best example: you can interactively build a visualization recipe, save a Python trace or state, then run it headlessly with `pvpython` or `pvbatch`. FreeCAD is also viable in this pattern for occasional macro capture and script discovery. This is the right meaning of “hybrid”: **use a GUI to discover commands, not to perform repeated production work.** citeturn43view2turn43view0turn39search2turn39search10

**Desktop automation** through VNC, X11 automation, screenshot-plus-vision control, or keyboard/mouse scripting should be treated as a last resort for engineering apps. It becomes acceptable only for narrow inspection tasks such as opening a STEP file, confirming that boundary labels appear, or capturing a manual checkpoint screenshot. It is too brittle for authoring critical CAD/CAE state because geometry, selection context, hidden constraints, and transient GUI lag are difficult to verify reliably after the fact. The correct fallback is almost always to increase script coverage instead of increasing GUI cleverness.

Recommended defaults by application are therefore straightforward: **CadQuery via Python**, **FreeCAD via Python and command line**, **OpenSCAD via CLI**, **Gmsh via Python or `.geo` plus CLI**, **CalculiX via INP plus CLI**, **SU2 via CFG plus CLI**, **OpenFOAM via dictionaries plus shell runners**, **ParaView via trace-to-`pvpython`**, **Blender via `-b -P` batch scripts**, and **Open3D/trimesh/PyMeshLab via Python libraries**. citeturn39search10turn39search17turn42view0turn45view0turn17search0turn34search12turn46view1turn43view0turn47search7turn30search13turn2search14

## Minimum viable pipelines

**Parametric CAD to FEA**

The cleanest first pipeline is:

```bash
python make_bracket.py
gmsh -3 bracket.step -o bracket.inp -format inp
ccx bracket
pvpython post_bracket.py
```

In this pattern, `make_bracket.py` is a CadQuery script that emits `bracket.step` and preserves the same parameter names used in the report and the reduced-order notebook. Gmsh handles meshing and physical grouping. CalculiX solves from `bracket.inp`. `post_bracket.py` produces PNG plots, CSV summaries, and optionally VTU-style derived outputs for archival visualization. CadQuery’s export model, Gmsh’s API and batch tooling, and CalculiX’s command-line input-deck workflow make this the most reliable first end-to-end structural benchmark. citeturn44view1turn44view2turn45view0turn17search0turn32search14turn43view0turn31search1

The verification loop for this pipeline should be explicit and automatic. The agent should compare CAD bounding box and volume before meshing, confirm that every load and fixture region maps to a named boundary/physical group, verify solver completion, check reaction-force balance, and compare the first benchmark against an analytical solution or a hand calculation. The best first part is not a “real product,” but a **cantilever beam, thin cylinder, or simple bracket** where you know what the answer should roughly be before you mesh it. CalculiX documentation explicitly foregrounds units, golden rules, simple example problems, and verification examples, which is exactly what an agent stack needs. citeturn17search3turn32search4turn32search14

**Parametric geometry to CFD**

For the very first fully automated CFD pipeline, I recommend **parameterized flow-domain scripts and SU2 or simple OpenFOAM cases before generic STEP-to-snappyHexMesh automation**. The shortest path is something like:

```bash
python write_channel_or_airfoil_case.py
SU2_CFD case.cfg
pvpython post_su2.py
```

or, for an OpenFOAM internal-flow benchmark,

```bash
blockMesh
simpleFoam >& log.simpleFoam
```

SU2’s case definition is concentrated in a text config file, and boundary conditions attach to named mesh markers. OpenFOAM is also scriptable, but it spreads the case across more directories and dictionaries. The **best canonical first CFD cases** are therefore a SU2 airfoil or duct case and the OpenFOAM `pitzDaily`-style backward-facing-step family, because both are official, benchmark-like, and easy to audit for boundary-condition mistakes. citeturn34search10turn34search6turn34search12turn34search0turn45view1turn46view0turn46view1turn46view2

The verification loop must be stricter than “the solver finished.” The agent should check marker names or boundary dictionaries before launch, track residuals and monitor outputs during solve, verify mass conservation or pressure-drop consistency, and reject runs where residuals plateau early, outlet conditions are incompatible, or turbulence models are being used outside a sensible regime. SU2’s history output and OpenFOAM’s logs and function objects are the right sources for this. citeturn34search4turn46view1

**Concept mesh to parametric CAD reconstruction**

This pipeline should be deliberately two-stage:

```bash
python run_triposr_or_sf3d.py
python validate_and_repair_mesh.py
python rebuild_as_parametric_cad.py
```

The first stage may use TripoSR, Stable Fast 3D, Hunyuan3D geometry-only modes, or InstantMesh to generate a rough concept mesh. The second stage uses Open3D, trimesh, and PyMeshLab to repair normals, test watertightness, simplify, orient, scale, and measure. The third stage does the real engineering work: re-express the shape as a simplified parametric model in CadQuery or FreeCAD, then export STEP and continue with meshing and CAE. This is the correct use of generative 3D in engineering workflows right now. The current open models produce meshes and textures quickly, but they do not produce the explicit constraints, feature history, or dimensional control needed for simulation-ready product geometry. citeturn27view0turn19search0turn18search2turn26search0turn30search13turn2search11turn2search14turn44view0

What should remain manual or human-reviewed in this reconstruction pipeline is also clear. Feature intent, datums, mating references, wall thickness, tolerances, and safety-critical geometry simplifications should not be accepted solely from the AI mesh. Use the mesh to infer **proportions and candidate primitives**, not to infer final engineering truth. That distinction is especially important for turbines, pressure vessels, hot-fluid systems, burners, and any geometry where tiny local changes have large stress, seal, or thermal consequences.

**Recommended file handoffs**

The most robust handoffs are:

- **Concept mesh → cleanup:** OBJ, STL, PLY, or GLB, but treat units as suspect and validate scale from the bounding box.
- **Authoritative CAD:** STEP plus the **source CAD script** (`.py` for CadQuery, `.scad` for OpenSCAD, optionally `FCStd` for FreeCAD review).
- **Meshing:** MSH as the main interchange mesh; export solver-native files only at the solver boundary.
- **FEA solver:** CalculiX `INP`; Elmer `SIF` and mesh DB.
- **CFD solver:** SU2 `CFG` plus named-boundary mesh; OpenFOAM dictionaries plus `polyMesh`.
- **Results:** Prefer VTU/VTP or other VTK XML family outputs where possible, because the VTK XML formats are designed for richer features such as random access, compression, and parallel I/O; keep CSV and images alongside them for auditability. citeturn45view0turn44view1turn17search0turn34search10turn32search3turn30search3turn30search7

## Benchmark plan

The table below is the benchmark set I would actually run. Difficulty and runtime bands are **planning estimates**, not sourced project claims.

| Benchmark | Best first tools | Success criteria | Expected artifacts | Approximate difficulty | Main agent skills tested |
|---|---|---|---|---|---|
| Cantilever beam | CadQuery, Gmsh, CalculiX | Tip deflection and reaction force within agreed tolerance of Euler-Bernoulli estimate after mesh refinement | `beam.py`, `beam.step`, `beam.inp`, solver log, deformation plots, report | Low | Units, BCs, meshing, result parsing |
| Thin cylinder or pressure vessel | CadQuery, Gmsh, CalculiX | Hoop and axial stress in the expected range from thin-wall theory | CAD, mesh, stress plots, comparison table | Low to medium | Pressure load setup, shell versus solid reasoning, stress sanity |
| Practical bracket under load | CadQuery or FreeCAD, Gmsh, CalculiX | Stable load path, plausible hotspot pattern, mesh-refinement trend | CAD, mesh, von Mises plots, skeptical review notes | Medium | Real CAD authoring, named interfaces, report quality |
| Thermal block or heat sink surrogate | CadQuery, Gmsh, Elmer or CalculiX thermal | Temperature gradients consistent with hand estimate, energy balance checks | Geometry, thermal setup, contour plots, CSV summaries | Medium | Material properties, thermal BCs, notebook-coupled assumptions |
| Backward-facing step or duct | OpenFOAM `pitzDaily` family or a simple SU2 duct | Residual drop, stable pressure drop or recirculation metric, correct boundary setup | Case directory, logs, residual/history plots, streamlines | Medium | Boundary naming, solver convergence, post-processing |
| NACA0012 airfoil | SU2 Quick Start lineage, later OpenFOAM comparison | Stable lift/drag trend and sensible pressure distribution under chosen assumptions | Mesh, `cfg`, history output, surface coefficients, plots | Medium | Marker mapping, inviscid/viscous setup, residual interpretation |

This set is intentionally skewed toward **analytically checkable** or **officially tutorial-backed** cases. CalculiX includes a cantilever beam example and broader verification material; SU2’s Quick Start centers on NACA0012; OpenFOAM’s quickstart uses the `pitzDaily` setup and documents its case structure; Elmer documentation points to loaded-beam and step-style tutorials plus large test coverage. These are the right first proving grounds because they test the stack rather than your imagination. citeturn32search14turn32search6turn34search0turn45view1turn46view0turn7search8turn7search9

## Installation and deployment recommendation

The packaging rule that matters most is the one already implicit in your prompt: **do not force heavyweight CAD and CAE applications into the same Python environment as orchestration code**. Keep a lean Python project for orchestration, notebooks, param studies, mesh validation, post-processing, and dossier generation. Install heavy GUI or solver applications separately and invoke them via subprocesses, batch scripts, or file handoffs. That separation is what preserves reproducibility while reducing dependency breakage.

The best near-term split is:

- **Base orchestration environment**: a `uv`-managed or otherwise isolated Python project for CadQuery, Gmsh Python bindings if desired, Open3D, trimesh, PyVista, NumPy, SciPy, Matplotlib, notebooks, and report generation.
- **Native desktop applications**: FreeCAD, Blender, Gmsh, and ParaView installed separately through their normal channels.
- **Solver layer**: CalculiX, SU2, and OpenFOAM installed separately from the Python project, preferably through distro packages, dedicated environments, or containers depending on the tool.  
This is the cleanest way to let agents coordinate many tools without turning one Python environment into a fragile monolith. citeturn47search4turn29search5turn29search11turn29search20turn43view1

For **Linux and WSL**, the split should be even more explicit. entity["organization","Microsoft","windows platform company"] documents that WSLg supports Linux GUI apps and hardware-accelerated OpenGL through a virtual GPU path, and entity["company","NVIDIA","gpu company"] documents CUDA on WSL for GPU compute. At the same time, entity["organization","Microsoft","windows platform company"]’s own WSLg architecture guidance notes that more complex 3D apps such as Blender benefit noticeably from proper GPU support and a modern graphics stack. My recommendation is therefore: **use WSL2 or Linux for orchestration, notebooks, file-based CAD/CAE, and batch solvers; use native Windows GUI builds of FreeCAD, Blender, and ParaView when you need a rich desktop review loop.** That gives you the automation benefits of Linux without pretending every 3D GUI is equally pleasant inside WSLg. citeturn29search0turn29search1turn29search15

For **containers**, use them mainly for **solver isolation**, not for interactive CAD. Podman’s own documentation emphasizes that it is daemonless, Docker-CLI comparable, and often usable as a regular user, which makes it attractive for reproducible solver images and safer local experimentation. In practice, containers make the most sense for OpenFOAM, SU2, Code_Aster-adjacent setups, and reproducible benchmark runners. They make much less sense as the primary home for FreeCAD or Blender if the agent needs a fluid interactive GUI. citeturn47search1turn47search21turn47search9

For **8 GB VRAM hardware**, the practical line is also clear from current model documentation. TripoSR’s default single-image inference is around **6 GB VRAM**; Stable Fast 3D advertises operation around **7 GB VRAM**; Hunyuan3D’s newer geometry generation can run in the **6 GB** range and even lower in optimized geometry-only modes, but the full 2.1 shape-plus-texture pipeline is documented at much higher memory requirements; InstantMesh exposes a CLI but its own README emphasizes larger CUDA-heavy dependencies and even multi-GPU demo options to save memory. On an RTX 4070-class 8 GB card, **TripoSR and Stable Fast 3D are the most realistic local concept-mesh generators; Hunyuan3D full texture pipelines and some InstantMesh paths are better treated as remote or deferred workloads.** citeturn27view0turn19search3turn18search2turn18search14turn26search0

The install order I would use is simple: **CadQuery + Gmsh + CalculiX first; then SU2; then PyVista/ParaView and report generation; then FreeCAD; then Blender and mesh-repair libraries; then OpenFOAM; then advanced stacks such as Elmer, SALOME, or Code_Aster.** That order mirrors the recommended benchmarks and gets you to a verifiable end-to-end loop as fast as possible.

## Failure modes, verification, immediate next experiments, and open questions

The most important conceptual safeguard is to keep seven levels separate in the dossier and in agent state:

**visual design → parametric CAD → simulation-ready geometry → mesh-ready geometry → physically meaningful simulation → decision-quality result → build-ready design.**

Open-source tools can support each level, but they do not collapse those levels into one. A textured mesh from a generative model can be excellent at level one and still be useless at levels four through seven. A successful solver run can be good at level five and still be unfit for level six if units, BCs, or mesh sensitivity were never audited.

The recurring failure modes and the right automatic checks are as follows. **Units** fail when agent pipelines cross CAD, mesh, and solver stages with no authoritative scale register; every run should log the source units, bounding box, characteristic length, and any unit conversions. **Non-manifold or open meshes** fail concept and reconstruction workflows; use Open3D and trimesh checks before any downstream use. **Boundary-condition corruption** fails between meshing and solvers; inspect named groups, markers, or boundary files before launch. **Solver divergence** fails when residuals, linear solves, or function-object outputs are not monitored and parsed. **Pretty but meaningless visualizations** fail when plotting runs are allowed without first checking which field, time step, and units are being shown. Tools such as Open3D, trimesh, SU2 history outputs, OpenFOAM logs, ParaView traces, and PyVista screenshots are useful only when wrapped in these explicit checks. citeturn2search11turn30search13turn34search4turn46view1turn43view2turn31search1

The first experiments I would run immediately are deliberately small:

1. **Cantilever beam FEA**
   ```bash
   python make_beam.py
   gmsh -3 beam.step -o beam.inp -format inp
   ccx beam
   pvpython post_beam.py
   ```
   Expected files: `beam.py`, `beam.step`, `beam.inp`, solver outputs such as `beam.dat` and `beam.frd`, plus plots and a short report. Pass if reaction force matches applied load and tip deflection approaches the analytical estimate under mesh refinement. citeturn44view2turn17search0turn32search14turn43view0

2. **First agent-run CFD benchmark**
   ```bash
   SU2_CFD case.cfg
   ```
   or
   ```bash
   blockMesh
   simpleFoam >& log.simpleFoam
   ```
   Expected files: mesh, `cfg` or OpenFOAM case dictionaries, history/log outputs, and automated plots. Pass if boundary naming is correct, residuals behave sensibly, and a chosen scalar monitor stabilizes. citeturn34search12turn34search4turn45view1turn46view1

3. **ParaView trace-to-batch conversion**
   Use the GUI once, save a trace, then batch rerun it with:
   ```bash
   pvpython trace.py
   ```
   Expected files: `trace.py`, screenshots, optional animation, and a saved state when useful. Pass if the batch output reproduces the intended view without manual clicks. citeturn43view2turn43view0

4. **Concept mesh to repaired mesh to re-CAD**
   ```bash
   python run.py examples/chair.png --output-dir output/
   python validate_and_repair_mesh.py
   python rebuild_as_cad.py
   ```
   Use TripoSR or a similarly lightweight model locally. Pass only if the repaired mesh is watertight or at least well-characterized, and the rebuilt CAD closes as a solid and exports cleanly to STEP. citeturn27view0turn30search13turn2search11turn44view1

A few open questions remain and should be treated as genuine unknowns rather than glossed over. I did **not** verify a best-in-class open repository set for permissively licensed mechanical CAD benchmark parts in this pass, so the safest immediate source of benchmark geometry remains **official example and tutorial suites** from the tools themselves. I also did not complete a deep enough automation audit of SALOME and Code_Aster to recommend them as first-stack tools. Robust generic **STEP-to-CFD meshing** for arbitrary parts, especially with OpenFOAM and `snappyHexMesh`, deserves a dedicated follow-up evaluation. And the gap between **AI-generated mesh assets** and **editable engineering B-rep reconstruction** is still a real technical gap, not a tooling inconvenience. That is also where proprietary systems still retain a major advantage.
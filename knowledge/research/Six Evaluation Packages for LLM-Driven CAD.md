# Six Evaluation Packages for LLM-Driven CAD/FEA — Hands-On This Week

**TL;DR**
- Start with **Package 4 (cad-khana standalone)** Monday to internalize the diagnostics-first loop in ~1 hour, then move to **Package 1 (cad-khana + Build123d + MPh-COMSOL + multi-model)** as your production workbench — it is the only stack that closes the agent → geometry → FEA → agent loop against your COMSOL license.
- **Package 2 (Zoo Text-to-CAD)** is the cheapest 30-minute "is this real?" test (20 free minutes/month, $0.0083/sec ≈ $0.50/min thereafter). **Package 3 (FreeCAD MCP)** gives you Claude-Desktop natural-language CAD plus a built-in CalculiX FEM solver — ideal for the prosthetic socket nonprofit.
- Treat **Package 5 (PyMechanical/PyAnsys agent)** as a parallel commercial-tool bridge for stress-critical bellows runs, and **Package 6 (UI-TARS driving Creo)** as a Friday experiment — instructive about computer-use limits (UI-TARS hits 24.6% on OSWorld at 50 steps per its own paper), but the least likely to produce production output this quarter.

## Maturity Spectrum

| # | Package | Maturity | Production potential |
|---|---|---|---|
| 1 | Build123d + cad-khana + MPh-COMSOL + multi-model orchestration | Mid (cad-khana early; rest stable) | **Highest** |
| 2 | Zoo Text-to-CAD (KittyCAD Python SDK) | Production API | Medium (one-shot generation) |
| 3 | FreeCAD MCP (neka-nat) + CalculiX | Production MCP, 943 GitHub stars | Medium-high |
| 4 | cad-khana standalone (Claude Code skill) | Early but working | Medium (entry ramp for #1) |
| 5 | PyMechanical / PyAnsys agentic wrapper | Production (Ansys-supported) | High for ANSYS users |
| 6 | UI-TARS Desktop driving Creo (computer-use long shot) | Experimental (34k★) | Low–medium, high learning |

All repo URLs were verified active in May 2026 on GitHub. All install commands were verified against current PyPI/GitHub indexes.

---

## Package 1 — "Workshop" (FAVORITE)
**Build123d + cad-khana + MPh-COMSOL + Claude/Gemini Orchestration**

**One-liner:** Diagnostics-first parametric CAD-as-code where Claude writes Build123d, cad-khana enforces clearances/wall-thickness in JSON, Gemini reads rendered PNGs for spatial checks, and MPh hands geometry to COMSOL Multiphysics for FEA — all in one loop.

**Maturity:** Mid. Build123d, MPh, and ocp_vscode are production-stable; cad-khana is explicitly *"Status: early. API may still churn"* per its GitHub README — but it works today and is the closest thing to a purpose-built LLM-CAD harness.

**Repos:**
- `https://github.com/cyberchitta/cad-khana` (Claude Code skill + Build123d diagnostics wrapper)
- `https://github.com/gumyr/build123d` (CAD kernel — installed via pip)
- `https://github.com/MPh-py/MPh` (Pythonic wrapper over COMSOL's Java API; current version 1.3.1 published Oct 30, 2025 per PyPI)
- `https://github.com/bernhard-42/vscode-ocp-cad-viewer` (the viewer cad-khana pushes to; current 3.x)

**Environment (Linux/macOS/Windows all OK; on Apple Silicon use ARM-native Python so MPh ≥ 1.3.0 finds the ARM COMSOL build):**

```bash
# Python 3.11 or 3.12 (OCP wheels currently support Python 3.10–3.13)
uv venv --python 3.12 .venv-cadkhana
source .venv-cadkhana/bin/activate            # PowerShell: .venv-cadkhana\Scripts\Activate.ps1

uv pip install build123d ocp_vscode MPh anthropic google-genai pillow numpy
uv tool install git+https://github.com/cyberchitta/cad-khana

# Install the Claude Code skill into your project
git clone --depth=1 https://github.com/cyberchitta/cad-khana /tmp/cad-khana
mkdir -p .claude/skills
cp -r /tmp/cad-khana/skills/cad-khana .claude/skills/
rm -rf /tmp/cad-khana

# Viewer: install "OCP CAD Viewer" VS Code extension (publisher bernhard-42, v3.x)
#         OR run standalone:
python -m ocp_vscode                          # standalone viewer on http://127.0.0.1:3939
```

Export keys:
```bash
export ANTHROPIC_API_KEY=[REDACTED]
export GEMINI_API_KEY=[REDACTED]
# Optional, for COMSOL on a Linux server:
#   comsol mphserver -port 2036 -silent &
```

**Worked example: bellows accumulator with FEA closure**

Goal — design a parametric metal bellows accumulator (convolution count N, pitch, wall thickness t, root/crest radii) and run a static axial-compression FEA in COMSOL until peak von Mises < σ_y × 1/SF.

1. `scripts/bellows.py` — Build123d script: revolve a sinusoidal profile to build N convolutions parameterized by `(N, pitch, t, r_root, r_crest, ID, OD)`. Add assertions: `assert min_wall(part) >= t * 0.9` and `assert clearance(crest, next_root) >= 0.5`.
2. `khana build scripts/bellows.py` — writes `diagnostics.json` and exports STEP. If assertions fail, Claude reads the JSON and rewrites the script.
3. `khana render scripts/bellows.py` — orthographic + iso PNGs. Send the iso PNG to Gemini 2.5 Pro with: *"Are the convolutions evenly spaced? Any kinks at the end caps?"* Gemini returns text; Claude reads it.
4. `comsol_runner.py` — imports STEP into a pre-built `bellows_template.mph`, sets `t`, applies `p_internal`, sweeps axial displacement, returns peak von Mises and effective axial stiffness:

```python
import mph
client = mph.start(cores=4)             # local; or mph.connect(version='6.2', port=2036)
model = client.load('bellows_template.mph')
model.parameter('t', f'{t_mm} [mm]')
model.import_('imp1', file='bellows.step')
model.build(); model.mesh(); model.solve()
peak_vm = model.evaluate('solid.misesMax')
k_eff   = model.evaluate('reacAx/dispAx')
client.clear()
```

5. Orchestrator loop — Claude Sonnet 4.6 as conductor (planning + script edits), Gemini 2.5 Pro for image inspection — until `peak_vm < 0.6 * sigma_y` and `k_eff` within the target band.

**Success criterion:** A converged STEP file plus a `runs/*.json` log showing 5–10 iterations where wall thickness or convolution pitch was adjusted by Claude in response to MPh's stress numbers — not by you. You should feel the difference between "LLM types CAD" (Package 2) and "LLM iterates against physics" (this one).

**Cost estimate (typical 30-iteration session, May 2026 rates):**
- ~80 k input tokens × 30 iter × $3/MTok (Sonnet 4.6) ≈ **$7.20** input
- ~6 k output tokens × 30 × $15/MTok ≈ **$2.70** output
- ~10 Gemini 2.5 Pro vision calls @ ~$0.012 each ≈ **$0.12**
- COMSOL solves: license cost is your fixed cost; no API fee
- **≈ $10–15 per full design exploration session.** With prompt caching (Anthropic offers up to 90% off on cache hits per its pricing page), you can drive this under $3 once your system prompt stabilizes.

**Gotchas:**
- cad-khana CLI is early — pin the commit hash you start with (`uv tool install git+...@<sha>`) so a behind-the-scenes change doesn't break your runs mid-week.
- MPh's JVM shutdown can hang after repeated model loads — wrap COMSOL calls in subprocess if you see > 5-second hangs (see MPh-py/MPh issue #1).
- On macOS Apple Silicon, if you accidentally launch Python under Rosetta (e.g. via Homebrew x86_64), MPh will look for the wrong COMSOL build. Verify with `python -c "import platform; print(platform.machine())"` → must be `arm64`. MPh ≥ 1.3.0 adds native ARM support per its release notes.
- `ocp_vscode` viewer port 3939 collides with other Flask apps — set `OCP_PORT` if needed.
- The OCP CAD Viewer extension and `ocp_vscode` Python package must be the **same version**, or the websocket handshake fails silently. Check the VS Code Output panel for version mismatch.

**Connection to your licenses:** This is the only package that drives COMSOL Multiphysics 6.0–6.3 (6.3 explicitly tested per MPh's installation docs) directly from the agent loop via MPh's pythonic wrapper around COMSOL's Java API. STEP files exported from Build123d also import cleanly into Creo (use Creo's import mapper) and into ANSYS Mechanical via PyMechanical — so the same Build123d source-of-truth feeds all three of your licensed tools.

---

## Package 2 — "Speed Dial"
**Zoo Text-to-CAD via KittyCAD Python SDK**

**One-liner:** One prompt → STEP file in 10–30 seconds via Zoo's ML-ephant endpoint; the simplest possible end-to-end test of "can an LLM make geometry I'd actually open?"

**Maturity:** Production API. Per Zoo's ML API page: *"Get started with 20 free minutes of API access (a $10 balance)"* (zoo.dev/machine-learning-api). Zoo's FAQ confirms: *"All users get $10.00 worth of API calls per month for free."* After that: *"Each second costs ~$0.0083"* (zoo.dev/docs/faq) — and per Zoo's Sept 26, 2025 billing post (zoo.dev/blog/turning-on-billing-for-text-to-cad): *"We now meter by the second at the same $0.50/min rate."*

**Repos / tools:**
- `https://github.com/KittyCAD/kittycad.py` (official Python SDK)
- `https://github.com/KittyCAD/text-to-cad-ui` (optional SvelteKit reference UI)

**Environment:**
```bash
uv venv --python 3.12 .venv-zoo
source .venv-zoo/bin/activate
uv pip install kittycad
export ZOO_API_TOKEN=[REDACTED]                # generate at zoo.dev account settings
```

**Worked example: parametric bracket for prosthetic socket harness**

```python
from kittycad.client import ClientFromEnv
from kittycad.api.ml import create_text_to_cad, get_text_to_cad_part_for_user
from kittycad.models import FileExportFormat, TextToCadCreateBody
import base64, time, pathlib

client = ClientFromEnv()
prompt = ("A pelvic-belt buckle bracket, 60 mm wide, 30 mm tall, 4 mm thick, "
          "two 6.2 mm through-holes 40 mm apart on center, "
          "rounded corners (R3), one chamfered slot 20x5 mm vertical on the left face.")

req = create_text_to_cad.sync(client=client,
                              output_format=FileExportFormat.STEP,
                              body=TextToCadCreateBody(prompt=prompt))
while req.completed_at is None:
    time.sleep(5)
    req = get_text_to_cad_part_for_user.sync(client=client, id=req.id)

step_b64 = req.outputs["source.step"]
pathlib.Path("bracket.step").write_bytes(base64.b64decode(step_b64))
```

Drop `bracket.step` into Creo or COMSOL. Run the same prompt 5 times to see stability.

**Success criterion:** A workflow you can call from any orchestrator (Claude tool, shell, Jupyter) to get a starting STEP — and a feel for which geometries Zoo handles. Use it for sketches/brackets, not for the bellows itself.

**Cost:** $0.0083/sec; typical Text-to-CAD calls last 10–30 seconds → **$0.08–$0.25 per generation**. 20 free minutes/month ≈ 40–60 successful generations free. Failed calls are not charged.

**Gotchas:**
- Per Zoo's FAQ: *"Yes. We are working on our machine learning endpoints every day, but it is still experimental. Some results may not be as good as you expect."* Budget 2–3 attempts per geometry.
- Output is STEP (always) + optional KCL (Zoo's own language). No native parametric history into Creo.
- Zoo's own advice: prompt the feature tree, not the noun — "chamfered cylindrical fitting with M6 thread relief" beats "fitting."

**Connection to your tools:** Pure STEP export → flows into Creo, COMSOL, ANSYS. No round-trip parametric link. Best used as a **seed-geometry generator** that you then refine in Build123d (Package 1) or directly in Creo.

---

## Package 3 — "MCP CAD"
**FreeCAD MCP (neka-nat) with Built-In FEM**

**One-liner:** Claude Desktop / Cursor talks directly to a running FreeCAD instance via MCP, creates PartDesign features, *and* runs a CalculiX FEA via `run_fem_analysis` — no Python wrapper code needed by you.

**Maturity:** Production MCP. The neka-nat/freecad-mcp server reports 943 GitHub stars (per its releases page, verified May 2026) and active commits; it ships an `examples/cantilever_fem.py` end-to-end and a `run_fem_analysis` tool that wraps CalculiX.

**Repos:**
- `https://github.com/neka-nat/freecad-mcp` (primary — has FEM tool)
- `https://github.com/contextform/freecad-mcp` (alternate — simpler bridge, no native FEM)

**Environment:**
```bash
# Prereqs: install FreeCAD 1.0+ from freecad.org, install uv (pip install uv)

git clone https://github.com/neka-nat/freecad-mcp.git
cd freecad-mcp

# Install workbench:
# Linux (FreeCAD 1.1):
mkdir -p ~/.local/share/FreeCAD/v1-1/Mod/
cp -r addon/FreeCADMCP ~/.local/share/FreeCAD/v1-1/Mod/
# macOS (FreeCAD 1.1):
# cp -r addon/FreeCADMCP ~/Library/Application\ Support/FreeCAD/v1-1/Mod/
# Windows:
# xcopy /E addon\FreeCADMCP %APPDATA%\FreeCAD\Mod\

# Restart FreeCAD → choose "MCP Addon" workbench → click "Start RPC Server"
```

Claude Desktop config (`~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):
```json
{ "mcpServers": {
    "freecad": { "command": "uvx", "args": ["freecad-mcp", "--only-text-feedback"] }
}}
```

**Worked example: cantilever calibration + prosthetic-socket lattice trial**

1. Run shipped `examples/cantilever_fem.py` first — confirms CalculiX is wired up: builds a beam, fixes one end, loads the other, calls `run_fem_analysis`, prints max von Mises, max displacement, mesh node count, working directory.
2. Then prompt Claude in Claude Desktop:
   > *"Create a prosthetic socket trim ring: 110 mm ID, 6 mm wall, 25 mm tall, 12 evenly spaced 8 mm windows around the circumference. Then run a FEM analysis with a 100 N radial load at the top edge and the bottom edge fixed."*
3. Claude calls `create_document`, a series of `execute_python_script` / PartDesign tool calls, then `run_fem_analysis`. Returns stress and displacement summary.

**Success criterion:** You're able to talk to Claude as if it were a junior engineer holding the FreeCAD mouse, get a meshed FEA result back as text, and iterate on geometry — all without writing the connective Python yourself. This is the lowest-friction package for fast-moving prosthetic-socket exploration.

**Cost:**
- With `--only-text-feedback`: ~10–30 k Claude input tokens, ~3 k output per iter → **~$0.07/iter** with Sonnet 4.6 ($3/$15 per MTok). 40-iteration session ≈ **$3**.
- Without the text-only flag, screenshots inflate cost ~3–5×.
- Zero subscription if you have Claude Pro or use the API directly.

**Gotchas:**
- RPC server must be manually started after each FreeCAD launch unless you enable auto-start in the workbench (persists via `freecad_mcp_settings.json`).
- CalculiX must be installed and findable — on macOS, `brew install calculix-ccx`; FreeCAD's FEM workbench needs to locate it.
- Token cost balloons fast with screenshot feedback. Default to `--only-text-feedback`; flip on only when stuck.
- The contextform variant is cleaner-installing (npm one-liner) but lacks built-in FEM — choose **neka-nat** for the prosthetic FEA use case.

**Connection to your tools:** FreeCAD's STEP export is your bridge to Creo and ANSYS; native FEA via CalculiX is fine for trim-and-cut iteration. Promote final designs to COMSOL (Package 1) or ANSYS (Package 5) for production-grade results.

---

## Package 4 — "Ramp"
**cad-khana Standalone with Claude Code**

**One-liner:** The cad-khana CLI by itself, no COMSOL, no Gemini — just to learn the diagnostics → fix → re-build loop in 60–90 minutes.

**Maturity:** Early but functional. README explicitly: *"Status: early. API may still churn."*

**Repo:** `https://github.com/cyberchitta/cad-khana`

**Environment (minimal):**
```bash
uv tool install git+https://github.com/cyberchitta/cad-khana

# Skill into project (Claude Code) OR global:
git clone --depth=1 https://github.com/cyberchitta/cad-khana /tmp/ck
mkdir -p ~/.claude/skills && cp -r /tmp/ck/skills/cad-khana ~/.claude/skills/ && rm -rf /tmp/ck

# Viewer (optional but recommended):
uv pip install build123d ocp_vscode
python -m ocp_vscode &
```

**Worked example: bellows convolution sub-component**

`bellows_unit.py`:
```python
from build123d import *
from cad_khana.core.assembly import Assembly
from cad_khana.core.build import build

def convolution(pitch=4.0, t=0.2, r_root=0.6, r_crest=0.6, OD=40, ID=30):
    with BuildLine() as profile:
        # half-convolution profile: root → crest → root (Bezier or arc segments)
        ...
    with BuildPart() as p:
        revolve(profile.line, axis=Axis.Z)
    return p.part

assembly = (Assembly()
            .add("conv", convolution())
            .assert_no_interferences()
            .assert_min_wall(0.15))
build(assembly, out="out/")
```

Run `khana build bellows_unit.py`. Read `out/diagnostics.json`. Have Claude Code propose pitch/wall changes; repeat with `khana check` / `khana render` / `khana view`.

**Success criterion:** A working `diagnostics.json` for a single convolution that flags any sub-0.15 mm wall thickness, plus a 10-minute habit of `khana check → khana render → adjust → khana view`. You've internalized the loop before stacking COMSOL on top.

**Cost:** Pure local — only Claude API or your LLM of choice. **$0.20–$2** per exploration.

**Gotchas:**
- OCP CAD Viewer must be running on port 3939 for `khana view` (run `python -m ocp_vscode` or use the VS Code extension).
- The skill auto-installs `cad-khana` on first invocation via `uv tool install`; if `uv` isn't on PATH, the skill fails silently — pre-install yourself.

**Connection to your tools:** Build123d exports STEP, STL, BREP. Take the converged convolution unit into Creo as a base feature; pattern it there if Creo's pattern engine is preferred for your team.

---

## Package 5 — "Commercial Bridge"
**PyMechanical / PyAnsys Agentic Wrapper**

**One-liner:** Use the official PyMechanical (`ansys-mechanical-core`) so an LLM can launch ANSYS Mechanical, import a STEP, run a static structural analysis, and read back stress/strain — the ANSYS counterpart to Package 1's MPh path.

**Maturity:** Production. PyAnsys is Ansys-supported, MIT-licensed, and PyMechanical works with Mechanical 2024 R1+ via either gRPC ("remote session") or in-process embedding (`App`).

**Repos:**
- `https://github.com/ansys/pymechanical` (Mechanical wrapper)
- `https://github.com/ansys/pyansys` (metapackage — pulls all PyAnsys libs)
- `https://github.com/ansys/pymechanical-stubs` (IDE autocomplete stubs)

**Environment (Windows is canonical; Linux supported for Mechanical 2024 R2+):**
```powershell
uv venv --python 3.11 .venv-ansys
.venv-ansys\Scripts\Activate.ps1
uv pip install ansys-mechanical-core ansys-mechanical-stubs anthropic
# AWP_ROOTDV_DEV should point to your Mechanical install, e.g.
# setx AWP_ROOTDV_DEV "C:\Program Files\ANSYS Inc\v242"
```

**Worked example: bellows from Package 1 → ANSYS confirmation run**

```python
from ansys.mechanical.core import launch_mechanical
m = launch_mechanical(batch=True)
m.run_python_script(r"""
geom = Model.GeometryImportGroup.AddGeometryImport()
geom.Import(r'C:\work\bellows.step')
analysis = Model.AddStaticStructuralAnalysis()
# … fixed bottom face, axial displacement on top face,
#   evaluate equivalent stress (LLM writes the rest)
""")
peak = m.run_python_script(
    "sol = Model.Analyses[0].Solution; sol.Solve(True); "
    "str(sol.EquivalentStress.Maximum.Value)")
print("ANSYS peak vM (Pa):", peak)
m.exit()
```

Wrap in an Anthropic tool-use loop: Claude reads the stress, decides whether to thicken the wall, regenerates Build123d, exports new STEP, re-runs.

**Success criterion:** A tool-use script that takes a STEP and a load case and returns a peak stress number — and a stack where two independent solvers (COMSOL in #1, ANSYS here) confirm each other on the same bellows geometry. Matters for nonprofit/medical-adjacent defensibility.

**Cost:**
- PyAnsys: free. License cost is your fixed ANSYS Mechanical seat.
- Token cost ≈ Package 1: **~$5–15/session.**

**Gotchas:**
- Embedding mode (`App()`) is faster but locks you to one Mechanical instance per Python process; remote-session mode is slower per call but cleaner for orchestration loops.
- Use `ansys-pythonnet` (not vanilla `pythonnet`) — they're API-compatible but the ansys fork ships pre-built wheels for the right .NET runtime.
- `AWP_ROOTDV_DEV` must point at the right ANSYS version directory or the embedded App refuses to start.

**Connection to your tools:** PyMechanical is the *direct* Python API for your ANSYS license. STEP from Build123d (Package 1) or Zoo (Package 2) flows in; results JSON flows out. Pairs naturally with MPh (Package 1) for two-solver cross-validation.

---

## Package 6 — "Long Shot"
**UI-TARS Desktop Driving PTC Creo (Computer-Use Experiment)**

**One-liner:** Use ByteDance's UI-TARS Desktop (or, alternatively, Anthropic Computer Use) to literally watch Creo's screen and click through commands by natural language — for tasks where Creo's J-Link/OTK isn't a fit and you'd otherwise be teaching a junior engineer the GUI.

**Maturity:** Experimental. Per the UI-TARS paper (arXiv 2501.12326, ByteDance/Tsinghua): *"UI-TARS achieves scores of 24.6 with 50 steps and 22.7 with 15 steps, outperforming Claude's 22.0 and 14.9 respectively"* on OSWorld. That is *not* a success rate you'd ship on — treat this as a research probe, not a delivery vehicle.

**Repos:**
- `https://github.com/bytedance/UI-TARS-desktop` (34k GitHub stars per its releases page, May 2026; Apache 2.0; native macOS/Win/Linux desktop agent)
- `https://github.com/bytedance/UI-TARS` (model + prompt templates)
- Fallback: `https://github.com/anthropics/anthropic-quickstarts` → `computer-use-demo` (Docker'd Linux desktop)

**Environment (UI-TARS Desktop, native install):**
```bash
brew install --cask ui-tars                                  # macOS
# or download from https://github.com/bytedance/UI-TARS-desktop/releases
# VLM Provider options in app settings:
#   - Hosted: Volcano Engine OS Agent Services (paid)
#   - Self-hosted: deploy UI-TARS-1.5-7B from Hugging Face on a 24 GB GPU
#   - Trial: use Anthropic Claude with computer-use beta
```

For Anthropic Computer Use (alternative; needs Docker + 8 GB RAM):
```bash
export ANTHROPIC_API_KEY=[REDACTED]
docker run -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  -v $HOME/.anthropic:/home/computeruse/.anthropic \
  -p 5900:5900 -p 8501:8501 -p 6080:6080 -p 8080:8080 -it \
  ghcr.io/anthropics/anthropic-quickstarts:computer-use-demo-latest
```

**Worked example: graded probe of Creo automation**

Since your Creo seat is on a real workstation, run **UI-TARS-Desktop locally** with the VLM pointed at a deployed UI-TARS-1.5 endpoint (Volcano Engine, or self-hosted).

Tasks in increasing difficulty:
1. "Open `bellows_v3.prt`, suppress feature `Pattern_Conv`, regenerate, save as `bellows_v3_noconv.prt`."
2. "In the open assembly, set parameter `WALL_T` to 0.25 and regenerate."
3. "Run Creo Simulate static analysis with the existing constraint set and report max von Mises from the report window."

Record demonstrations of yourself doing tasks 1–3 once; UI-TARS can take these as in-context examples.

**Success criterion:** Task 1 should work; task 2 sometimes; task 3 likely fails on first attempt. The *learning* is calibrating where computer-use agents currently break (modal dialogs, scroll-based selection, anything time-sensitive) and where they shine (deterministic menu sequences). Useful for orienting expectations as Creo AI Assistant, NX Copilot, and Dassault Aura/Leo/Marie roll out.

**Cost:**
- UI-TARS-1.5-7B self-hosted on a 24 GB GPU: free if you own the hardware.
- Anthropic Computer Use via Claude Sonnet 4.6 ($3/$15 per MTok): ~$0.20–$0.80 per multi-step Creo task because screenshots are large image tokens.
- Volcano Engine hosted UI-TARS endpoints: small per-action fee.

**Gotchas:**
- Computer-use agents need a **dedicated VM or VNC desktop** — running against your daily-driver session will eventually click the wrong thing. Anthropic's own warning: *"Use a dedicated virtual machine or container with minimal privileges to prevent direct system attacks or accidents."*
- Creo's modal dialog timing is a known VLM-agent weakness — screenshot, decide, act, but the dialog has already moved.
- Screenshots are large; budget caps are mandatory.
- UI-TARS-1.5 is Apache-2.0; UI-TARS-2 is research-access-only as of May 2026.

**Connection to your tools:** This is the *only* package that touches Creo directly, because Creo's open APIs (J-Link, Pro/TOOLKIT, Mapkey) are heavyweight and don't suit fast LLM-driven scripting. Treat UI-TARS as a way to capture a Creo workflow you'd otherwise document for an intern.

---

## Recommendations — Suggested Order (Mon–Fri)

Given your three goals — (a) **prosthetic socket nonprofit**, (b) **bellows accumulator FEA**, (c) **general LLM+CAD literacy**:

- **Mon AM (1 h) — Package 4: cad-khana standalone.** Build a single bellows convolution. You'll know whether code-CAD + diagnostics clicks for you. Threshold to continue: a `diagnostics.json` that catches a wall-thickness violation you intentionally introduce.
- **Mon PM (2 h) — Package 2: Zoo Text-to-CAD.** Burn ~$1 of credit generating 5 prosthetic-bracket variants. Threshold to keep it in workflow: at least 2 of 5 STEPs open cleanly in Creo without manual cleanup.
- **Tue (½ day) — Package 3: FreeCAD MCP + CalculiX.** Run the cantilever example end-to-end, then ask Claude to make a prosthetic socket trim ring with a 100 N load case. This gives the nonprofit project a working iteration loop *today*.
- **Wed–Thu (1.5 days) — Package 1: the full stack.** Build a `bellows_template.mph` in COMSOL once, then let the loop drive convolution count, pitch, and wall thickness. This is the bellows accumulator's home base. Threshold to declare success: 5+ autonomous iterations converging on a stress target you set.
- **Fri AM (3 h) — Package 5: PyMechanical.** Take Wednesday's converged STEP and confirm in ANSYS Mechanical. Two-solver agreement (<10% delta on peak von Mises) is your go/no-go for using the result anywhere consequential.
- **Fri PM (2 h) — Package 6: UI-TARS against Creo.** Controlled experiment — how far does a computer-use agent get on Creo's UI? Don't expect deliverables; expect calibration of expectations.

**Decision benchmarks:**
- If Package 1 produces a converged bellows by Thursday end-of-day → it becomes your default workbench; skip Packages 5 and 6 unless ANSYS validation is contractually required.
- If Package 3 produces a usable socket trim-ring FEA by Tuesday end-of-day → ship that as v0 of the nonprofit's iteration loop while you build Package 1 in parallel.
- If Package 2 fails to deliver clean STEPs in 2 of 5 attempts → drop it from regular use; revisit when Zoo improves Text-to-CAD (their roadmap mentions returning KCL code, which would change the math).
- If Package 6 succeeds at Task 2 but not Task 3 → wait for vendor AI assistants (Creo AI Assistant) before investing further in computer-use for Creo.

## Caveats

- **cad-khana is early** — the author calls it that explicitly. Don't put it on a critical-path nonprofit deliverable yet — pin commits, keep a Build123d-only fallback.
- **Zoo Text-to-CAD is "experimental"** per Zoo's own FAQ — you *will* be charged for bad results (Zoo's wording: *"We are working on our machine learning endpoints every day, but it is still experimental. Some results may not be as good as you expect."*).
- **All API prices verified May 14–15, 2026.** Anthropic Sonnet 4.6 / 4.5 is $3 / $15 per MTok input/output; Opus 4.7 is $5 / $25 (with a new tokenizer that, per Anthropic's docs, *"may use up to 35% more tokens for the same fixed text"*). Gemini 2.5 Pro is $1.25 / $10 (≤200 k context) per Google's pricing page (last updated 2026-05-14 UTC). Cached input is up to 90% cheaper on Anthropic and 90% cheaper on Gemini context caching.
- **MPh is not affiliated with COMSOL Inc.** Its installation docs state: *"Comsol versions 6.0 and newer are expected to work. Up to version 6.3, they have been successfully tested."* If you have a Class Kit license, call `mph.option('classkit', True)` before `mph.start()`. For Apple Silicon, use MPh ≥ 1.3.0 (current 1.3.1, published Oct 30 2025 per PyPI) and ARM-native Python.
- **UI-TARS's measured performance is modest** — 24.6% on OSWorld at 50 steps (per arXiv 2501.12326). Useful for orientation, not delivery.
- **No CAD-LLM stack today writes parametric Creo .prt feature history directly.** All paths above produce STEP/BREP, which you re-attribute in Creo or NX manually if you want a feature tree.
- **The MCP and computer-use ecosystem moves fast.** Re-check the FreeCAD MCP and UI-TARS Desktop release notes monthly — both shipped major updates in late 2025/early 2026 (UI-TARS Desktop v0.2.0 in June 2025; Agent TARS CLI v0.3.0 in Nov 2025; UI-TARS-2 in Sept 2025).
- **Two-solver validation is good practice** for any geometry you'd consider load-bearing (medical, pressure-containing). The Package 1 + Package 5 pairing exists for exactly this reason — pick conservative material data and use both COMSOL and ANSYS on the same final STEP before committing.
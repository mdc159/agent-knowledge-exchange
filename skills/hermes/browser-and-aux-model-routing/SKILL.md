# Hermes Browser and Auxiliary Model Routing

## Purpose

Use this skill when setting up or troubleshooting a Hermes runtime's browser tools,
Computer Use, local real-browser/CDP paths, Tailscale-visible services, or auxiliary
LLM task routing.

The goal is to keep the main agent useful while preserving safe defaults:
managed browser tooling first, local real-browser control only when it is deliberately
needed, and auxiliary model configuration that can fall back instead of hard-failing
on one stale provider.

## When To Use

- A Hermes node needs browser automation or macOS Computer Use verified.
- A user asks whether a local Mac/PC/network service is reachable from the agent side.
- A runtime has multiple browser paths: managed browser, macOS Computer Use,
  local browser-harness/CDP, or Tailscale-exposed web services.
- Auxiliary calls fail for title generation, compression, web extraction, session
  search, vision, approvals, MCP, or curator tasks.
- A node uses GPT/OpenAI-Codex models and should prefer the appropriate GPT lane
  before falling back to other configured providers.
- A Kanban/multi-profile Hermes layout needs cheap-first routing documented.

## Browser Tooling Ladder

Use the least powerful browser path that satisfies the task.

1. **Managed browser automation**
   - Default for normal web navigation, snapshots, clicks, and extraction.
   - Verify with a safe page such as `https://example.com`.
   - Keep this as the default when it is working.

2. **macOS Computer Use**
   - Use for native Mac UI, visible app state, permission-free screenshots, or
     workflows where Browser Use cannot see the target.
   - Capture first, prefer element-index clicks over raw coordinates, and verify
     after state-changing actions.
   - Never type secrets, payment data, 2FA codes, or click permission dialogs
     without explicit human authorization.

3. **Local real-browser / browser-harness / CDP**
   - Treat as high-power and experimental.
   - Prefer an isolated browser profile for automation.
   - Do not attach to a user's normal logged-in Chrome profile unless the task
     explicitly requires that session and the human approves the risk.
   - Document whether the path is managed-browser, isolated CDP profile, or
     real-profile attach.

4. **Tailscale-accessible local services**
   - Probe from the agent side before giving relay-only instructions.
   - Use Tailscale IPs/names for private services when LAN discovery is unreliable.
   - Check ports directly before assuming a protocol is available.

## Browser Verification Commands

For a macOS Hermes node, useful checks include:

```bash
hermes tools list 2>/dev/null || hermes tools
hermes status --all
hermes computer-use status 2>/dev/null || true
```

For network/browser-adjacent troubleshooting:

```bash
ifconfig -a
route -n get default
netstat -rn -f inet
scutil --dns
lsof -nP -iTCP -sTCP:LISTEN
```

For Tailscale reachability:

```bash
tailscale status
tailscale ip -4
tailscale netcheck
tailscale ping <peer-name-or-100.x-ip>
nc -vz -G 2 <peer-ip> <port>
```

Interpretation examples:

- `tailscale ping` returning `via <LAN-IP>:41641` means the peer is reachable
  directly over the local network, not only through DERP relay.
- SMB open on `445` means file sharing may work, but authentication can still fail.
- RDP requires `3389`; if that port times out, enable Remote Desktop and firewall
  access on the Windows host before retrying.
- macOS Tailscale GUI/Network Extension builds can use normal SSH over Tailscale
  if macOS Remote Login is on, but they cannot host the Tailscale SSH server.

## Auxiliary Model Routing Rule

Prefer resilient `provider: auto` unless there is a deliberate authority, cost, or
capability reason to hard-pin a provider.

Important behavior: in Hermes auxiliary config, an explicit non-`auto` provider is
a hard constraint. If `auxiliary.title_generation.provider` is pinned to a broken
provider, Hermes may fail that side task instead of using a healthy main runtime or
fallback path.

Recommended pattern for GPT-first nodes:

```yaml
auxiliary:
  title_generation:
    provider: auto
    model: gpt-5.4-mini
  compression:
    provider: auto
    model: gpt-5.4-mini
  session_search:
    provider: auto
    model: gpt-5.4-mini
  web_extract:
    provider: auto
    model: gpt-5.4-mini
  skills_hub:
    provider: auto
    model: gpt-5.4-mini
  approval:
    provider: auto
    model: gpt-5.4-mini
  mcp:
    provider: auto
    model: gpt-5.4-mini
  triage_specifier:
    provider: auto
    model: gpt-5.4
  curator:
    provider: auto
    model: gpt-5.4
  vision:
    provider: auto
    model: gpt-5.5
```

Why this works:

- `provider: auto` leaves Hermes room to use the main GPT/OpenAI-Codex runtime first
  and route around eligible provider failures.
- The model field still expresses the desired GPT lane for the task.
- Cheap text side tasks avoid spending the main/frontier model by default.
- Vision and high-trust review/curation can use stronger models where quality matters.

## Kanban / Multi-Profile GPT Layout

For a Hermes Kanban roster, start cheap and escalate only when evidence shows the
current lane is insufficient.

Suggested roster:

- `kb-worker`: `gpt-5.4-mini`
- `kb-researcher`: `gpt-5.4-mini` or `gpt-5.2`
- `kb-browser`: `gpt-5.4-mini`
- `kb-coder`: `gpt-5.3-codex-spark`
- `kb-coder-heavy`: `gpt-5.3-codex`
- `kb-orchestrator`: `gpt-5.4`
- `kb-reviewer`: `gpt-5.4`
- main/operator profile: `gpt-5.5`

Escalation ladder:

```text
gpt-5.4-mini -> gpt-5.3-codex-spark -> gpt-5.3-codex -> gpt-5.4 -> gpt-5.5
```

Operational rule:

- Keep most cards on worker/researcher/browser.
- Use codex-spark for normal coding cards.
- Use codex for deep debugging/refactors.
- Reserve 5.4 for orchestration and review.
- Escalate to the main 5.5 profile only for high-stakes synthesis, hard ambiguity,
  or failed specialist lanes.

## Smoke Test for Auxiliary Routing

Use the Hermes runtime Python, not a random system Python, when importing Hermes
modules directly. The launcher may point at a project venv that has dependencies
such as `openai` installed while system Python does not.

```bash
HERMES_PY=$(head -1 "$(which hermes)" | sed 's/^#!//')
"$HERMES_PY" - <<'PY'
import sys
from agent.auxiliary_client import call_llm, extract_content_or_reasoning
resp = call_llm(
    task="title_generation",
    messages=[{"role": "user", "content": "Reply with exactly: ok"}],
    temperature=0,
    max_tokens=10,
)
print(extract_content_or_reasoning(resp))
PY
```

A healthy run should log which auxiliary provider/model was used and print `ok`.
If it fails with a missing Python module, confirm the interpreter is the Hermes
launcher interpreter, not Homebrew/pyenv/system Python.

## Common Pitfalls

1. **Relay-only troubleshooting.** If the agent can probe the LAN, Tailscale, route,
   DNS, or ports, do that before asking a human to relay guesses.

2. **Hard-pinned auxiliary providers.** `provider: openrouter` or another explicit
   provider can defeat fallback. Use `provider: auto` unless the pin is intentional.

3. **Confusing Tailscale SSH with normal SSH.** Tailscale SSH is a special auth
   layer and is not available as a server in sandboxed macOS GUI builds. Normal SSH
   over a Tailscale IP still works when the OS SSH server is enabled.

4. **Attaching automation to the user's real browser profile.** Local CDP access to
   a logged-in Chrome session is powerful and risky. Prefer managed browser or an
   isolated profile.

5. **Testing Hermes internals with the wrong Python.** Use the interpreter in the
   `hermes` shebang or the project's venv.

## Output Shape

When reporting back, include:

- browser path selected and why
- network path tested, if any
- ports or services confirmed reachable/unreachable
- auxiliary provider/model policy applied
- exact config keys changed
- verification command and result
- risks or follow-up actions

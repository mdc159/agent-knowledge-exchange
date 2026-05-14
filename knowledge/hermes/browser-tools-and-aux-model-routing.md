# Hermes Browser Tools and Auxiliary Model Routing Notes

Date: 2026-05-14
Status: operational note
Scope: Hermes Agent browser tooling, macOS Computer Use, Tailscale reachability checks, browser-harness posture, and GPT-first auxiliary model configuration

## Executive summary

For operator Hermes runtimes, keep browser control and auxiliary LLM routing layered:

1. Managed browser automation remains the default browser path.
2. macOS Computer Use is the native-app/visible-desktop fallback and should be verified by capture before action.
3. Local real-browser/CDP tooling such as browser-harness is a high-power optional mode, preferably with an isolated profile.
4. Tailscale/LAN claims should be probed from the agent side before giving relay-only instructions.
5. Auxiliary LLM tasks should usually use `provider: auto` with task-appropriate GPT model preferences, not hard-pinned providers.

The main lesson from the setup session was that `auto` and model preference are complementary: `provider: auto` preserves fallback, while `model: gpt-*` still expresses the preferred GPT lane. Hard-pinning `provider: openai-codex` or another provider turns the provider into a hard constraint and can prevent fallback.

## Browser tool stack

### Managed browser automation

Use managed Browser Automation first for routine web navigation. It is the safest default because it avoids attaching to the user's real browser profile and keeps state isolated from local logged-in sessions.

Verification pattern:

- navigate to `https://example.com`
- inspect the snapshot
- click the safe `Learn more` link
- verify the resulting page changed as expected

A successful smoke test confirms that navigation, click dispatch, and accessibility snapshots are working.

### macOS Computer Use

Use macOS Computer Use when the target is a native app, a visible desktop workflow, or a browser/UI surface not accessible through managed browser automation.

Operational rules:

- Capture first, preferably scoped to the app.
- Use element-index clicks from the capture rather than raw coordinates when possible.
- Verify after state-changing actions.
- Do not click permission dialogs, payment UI, password prompts, or type secrets unless the human explicitly authorizes the action.

### Local real-browser / browser-harness / CDP

Treat browser-harness or local CDP control as optional and high-power.

Recommended posture:

1. Managed browser default for ordinary browsing.
2. Isolated local browser profile for local CDP experiments.
3. Real logged-in Chrome profile attach only when explicitly required and approved.

Reason: a real-profile CDP session can operate a user's authenticated browser state. That is useful for some local workflows, but it widens the blast radius for accidental clicks, prompt injection, and credential-bearing pages.

## Tailscale and LAN troubleshooting lesson

When a user reports that a Mac is disrupting a PC or LAN connection, verify from the Mac before giving relay-only instructions.

Useful checks:

```bash
ifconfig -a
route -n get default
netstat -rn -f inet
scutil --dns
lsof -nP -iTCP -sTCP:LISTEN
tailscale status
tailscale netcheck
tailscale ping <peer>
nc -vz -G 2 <peer-ip> <port>
```

Interpretation examples from the session:

- A Mac can have Wi-Fi as the default route while a wired Ethernet link is physically active but self-assigned `169.254.x.x`; that is suspicious enough to mention, but it is not evidence of routing/NAT unless IP forwarding or Internet Sharing is enabled.
- `sysctl net.inet.ip.forwarding` and `net.inet6.ip6.forwarding` at `0` means the Mac is not acting as a router.
- `tailscale ping` showing `via <LAN-IP>:41641` means the Tailscale peer is reachable directly over the local network, not only through DERP.
- Open ports identify the usable connection mode. For example, SMB `445` open means file sharing may be available, while RDP `3389` timing out means Remote Desktop is not enabled or not allowed through the firewall.

Tailscale SSH note:

- The sandboxed macOS Tailscale GUI/Network Extension build cannot run the Tailscale SSH server and will report: `The Tailscale SSH server does not run in sandboxed Tailscale GUI builds.`
- Normal OS SSH over a Tailscale IP can still work if macOS Remote Login/OpenSSH is enabled.
- Do not switch Tailscale variants mid-incident if ordinary Tailscale connectivity is already working; use normal SSH, SMB, RDP, or web ports over the Tailscale IP first.

## Auxiliary model configuration lesson

Hermes auxiliary tasks include title generation, compression, session search summarization, web extraction, vision, approvals, MCP assistance, memory flushing, and curation.

Key behavior:

- `auxiliary.<task>.provider: auto` lets Hermes resolve the main runtime and fallback chain.
- An explicit non-`auto` provider is a hard constraint in important paths.
- A task can prefer a GPT model while still preserving fallback by using `provider: auto` plus `model: gpt-*`.
- Test Hermes internals using the Hermes launcher interpreter or project venv; system Python may not have dependencies such as `openai` installed.

### GPT-first operator layout

For the observed GPT/OpenAI-Codex operator node, the desired policy was:

```yaml
auxiliary:
  web_extract:
    provider: auto
    model: gpt-5.4-mini
  compression:
    provider: auto
    model: gpt-5.4-mini
  session_search:
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
  title_generation:
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

This differs from the earlier generic proposal of empty model values. The generic policy remains good for broad portability. For an operator node with known GPT lanes and working OpenAI-Codex auth, a GPT model preference is useful as long as the provider remains `auto`.

### Kanban profile model layout

A cheap-first Hermes Kanban roster can use:

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

Use most cards on cheap worker/research/browser lanes, coding cards on codex-spark, deep debugging on codex, orchestration/review on 5.4, and main 5.5 only for high-stakes synthesis or failed specialist lanes.

## Verification pattern for auxiliary routing

Use the Hermes runtime Python:

```bash
HERMES_PY=$(head -1 "$(which hermes)" | sed 's/^#!//')
"$HERMES_PY" - <<'PY'
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

A healthy run should log the auxiliary task's resolved provider/model and return `ok`.

## Relationship to the shared skill

The reusable procedure version of this note lives at:

```text
skills/hermes/browser-and-aux-model-routing/SKILL.md
```

Load that skill when operating on a Hermes runtime's browser tooling, Computer Use setup, browser-harness posture, Tailscale/private-service reachability, or auxiliary GPT/fallback configuration.

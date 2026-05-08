# Hermes Agents Through Shared Open WebUI Over Tailscale

Date captured: 2026-05-07

This document explains the current setup, what was changed, how to verify it, and the main pitfalls encountered while connecting multiple Hermes agents to a single Open WebUI surface.

## Goal

Use one Open WebUI instance, running on the VPS, as the common chat/control surface for multiple Hermes agents.

The architecture is:

```text
Browser / phone / local machine
  -> Tailscale Serve HTTPS
  -> VPS Open WebUI container
  -> Tailscale
  -> individual Hermes API servers
```

In this setup, Open WebUI is the shared frontend and provider router. Each Hermes agent exposes an OpenAI-compatible API server. Open WebUI registers each Hermes API server as an OpenAI-compatible provider connection.

Important: tool execution happens on the machine running the selected Hermes agent. Selecting the WSL Hermes model in Open WebUI means the Hermes agent and its tools run in WSL/local context, even though the browser UI is hosted from the VPS.

## Current Hosts

### VPS

The Open WebUI container is running on the VPS, not on the local WSL machine.

```text
Hostname: srv1264451.tailfedd3b.ts.net
Tailscale IP: 100.84.200.95
Open WebUI container: 1215-prototype-local-open-webui-1
Container port mapping: 127.0.0.1:8080 -> container 8080
```

Tailscale Serve exposes the VPS loopback service:

```text
https://srv1264451.tailfedd3b.ts.net:8444 -> http://127.0.0.1:8080
https://donna.tailfedd3b.ts.net:8444       -> same Open WebUI surface / alias path
```

The useful browser URL is:

```text
https://donna.tailfedd3b.ts.net:8444/?model=Donna%20Hermes
```

For API automation, the canonical hostname that accepted the admin API key was:

```text
https://srv1264451.tailfedd3b.ts.net:8444
```

The `donna.tailfedd3b.ts.net` hostname served the UI correctly, but the pasted admin API token returned `401` against that host. Use the canonical Serve hostname for automation unless this is intentionally changed.

### Local WSL Hermes Agent

The local WSL machine is running Hermes and exposes the Hermes API server on its Tailscale address.

```text
Hostname: nikoli-wsl.tailfedd3b.ts.net
Tailscale IP: 100.110.111.7
Hermes API port: 8642
Hermes model id exposed by API: nikolai-hermes
```

Relevant local Hermes env settings:

```text
API_SERVER_ENABLED=true
API_SERVER_HOST=100.110.111.7
API_SERVER_PORT=8642
API_SERVER_MODEL_NAME=nikolai-hermes
API_SERVER_KEY=<redacted>
```

The local process observed was:

```text
/home/mdc159/.hermes/hermes-agent/venv/bin/python -m hermes_cli.main gateway run --replace
```

Hermes version observed:

```text
Hermes Agent v0.12.0 (2026.4.30)
```

## Open WebUI Provider Configuration

Open WebUI has OpenAI-compatible provider connections. The relevant provider list after the change:

```text
0: https://openrouter.ai/api/v1
1: http://nikoli-wsl.tailfedd3b.ts.net:8642/v1
```

The Hermes API server must be registered with `/v1` on the end:

```text
http://nikoli-wsl.tailfedd3b.ts.net:8642/v1
```

Open WebUI uses the Hermes agent's `API_SERVER_KEY` as the provider key for that upstream connection.

Do not confuse the two API keys:

```text
Open WebUI admin API key = used to configure/call Open WebUI
Hermes API_SERVER_KEY     = used by Open WebUI to call a Hermes agent
```

## Display Alias

The raw local Hermes model id is:

```text
nikolai-hermes
```

The browser URL was selecting:

```text
Donna Hermes
```

Those are not the same. To make the URL work, an Open WebUI custom model alias was created:

```text
Donna Hermes -> nikolai-hermes
```

Observed Open WebUI model record:

```text
id: Donna Hermes
name: Donna Hermes
base_model_id: nikolai-hermes
tags: Hermes Agent, Donna
```

After that, this URL selects the shared VPS Open WebUI surface and routes requests to the WSL Hermes backend:

```text
https://donna.tailfedd3b.ts.net:8444/?model=Donna%20Hermes
```

## Commands Used For Discovery

### Check Local Tailscale State

```bash
tailscale status --json
```

Key facts discovered:

```text
Self HostName: nikoli-wsl
Self DNSName: nikoli-wsl.tailfedd3b.ts.net.
Self Tailscale IP: 100.110.111.7
```

### Check Local Listening Ports

```bash
ss -ltnp | rg '(:8642|:8080|:3000|:8787)'
```

Observed:

```text
100.110.111.7:8642 listening via python
```

This confirmed that the local Hermes API server was bound directly to the Tailscale IP, not just `127.0.0.1`.

### Check Local Hermes API Health

```bash
curl -sS http://100.110.111.7:8642/health
```

Expected:

```json
{"status": "ok", "platform": "hermes-agent"}
```

### Check Authenticated Hermes Model Discovery

From local WSL:

```bash
set -a
. ~/.hermes/.env
set +a

curl -sS \
  -H "Authorization: Bearer $API_SERVER_KEY" \
  http://100.110.111.7:8642/v1/models
```

Expected model:

```text
nikolai-hermes
```

### Check Bad Key Behavior

```bash
curl -i \
  -H "Authorization: Bearer wrong" \
  http://100.110.111.7:8642/v1/models
```

Expected:

```text
401 Unauthorized
Invalid API key
```

This confirmed the Hermes API auth was active and behaving normally.

### Check End-to-End Hermes Completion Directly

```bash
set -a
. ~/.hermes/.env
set +a

curl -sS \
  -H "Authorization: Bearer $API_SERVER_KEY" \
  -H "Content-Type: application/json" \
  http://100.110.111.7:8642/v1/chat/completions \
  -d '{
    "model": "nikolai-hermes",
    "messages": [
      {"role": "user", "content": "Reply with exactly: hermes-api-ok"}
    ],
    "stream": false
  }'
```

Observed completion:

```text
hermes-api-ok
```

### Check VPS Docker State

```bash
ssh root@srv1264451.tailfedd3b.ts.net \
  'docker ps --format "{{.Names}}\t{{.Image}}\t{{.Ports}}"'
```

Open WebUI container:

```text
1215-prototype-local-open-webui-1
```

Open WebUI was bound only to VPS loopback:

```text
127.0.0.1:8080->8080/tcp
```

This is intentional. Direct `http://100.84.200.95:8080` refused because the service is not bound to the VPS Tailscale IP. Tailscale Serve handles the exposure.

### Check VPS Tailscale Serve

```bash
ssh root@srv1264451.tailfedd3b.ts.net 'tailscale serve status'
```

Relevant route:

```text
https://srv1264451.tailfedd3b.ts.net:8444 (tailnet only)
|-- / proxy http://127.0.0.1:8080
```

### Check Whether Open WebUI Container Can Reach WSL Hermes

Inside the VPS Open WebUI container:

```bash
docker exec 1215-prototype-local-open-webui-1 sh -lc 'python - <<PY
import urllib.request
for url in [
    "http://100.110.111.7:8642/health",
    "http://nikoli-wsl.tailfedd3b.ts.net:8642/health",
]:
    try:
        print(url, urllib.request.urlopen(url, timeout=8).read().decode()[:200])
    except Exception as e:
        print(url, type(e).__name__, e)
PY'
```

Expected:

```text
http://100.110.111.7:8642/health {"status": "ok", "platform": "hermes-agent"}
http://nikoli-wsl.tailfedd3b.ts.net:8642/health {"status": "ok", "platform": "hermes-agent"}
```

This ruled out Docker networking and Tailscale routing as blockers.

## Open WebUI Admin API

The installed Open WebUI exposes provider config endpoints:

```text
GET  /openai/config
POST /openai/config/update
```

These are protected by `get_admin_user`, so a regular user key may not work. An admin Open WebUI API key is needed.

The installed code stores:

```text
OPENAI_API_BASE_URLS
OPENAI_API_KEYS
OPENAI_API_CONFIGS
```

Provider URLs and keys are parallel arrays.

The Open WebUI config update preserved the existing OpenRouter connection and appended the WSL Hermes connection:

```text
https://openrouter.ai/api/v1
http://nikoli-wsl.tailfedd3b.ts.net:8642/v1
```

Keys are redacted and should never be written into notes or shell history if avoidable.

## Verification Through Open WebUI

### Model List

With the Open WebUI admin API key:

```bash
curl -sS \
  -H "Authorization: Bearer <OPEN_WEBUI_ADMIN_KEY>" \
  https://srv1264451.tailfedd3b.ts.net:8444/api/models
```

Expected:

```text
Donna Hermes
nikolai-hermes
```

`Donna Hermes` is the friendly Open WebUI alias. `nikolai-hermes` is the backend Hermes model id.

### End-to-End Completion Through Open WebUI

```bash
curl -sS \
  -H "Authorization: Bearer <OPEN_WEBUI_ADMIN_KEY>" \
  -H "Content-Type: application/json" \
  https://srv1264451.tailfedd3b.ts.net:8444/openai/chat/completions \
  -d '{
    "model": "Donna Hermes",
    "messages": [
      {"role": "user", "content": "Reply exactly: donna-hermes-ok"}
    ],
    "stream": false
  }'
```

Observed:

```text
donna-hermes-ok
```

That proves the full path:

```text
Open WebUI API -> Donna Hermes alias -> nikolai-hermes -> WSL Hermes API -> response
```

## Adding Another Hermes Agent

For each new Hermes agent:

1. Enable its Hermes API server.
2. Bind it to a Tailscale-reachable address, preferably its Tailscale IP or hostname.
3. Give it a unique model name.
4. Verify `/health`.
5. Verify `/v1/models` with its `API_SERVER_KEY`.
6. Verify the VPS Open WebUI container can reach it.
7. Add it to Open WebUI provider config.
8. Optionally create a friendly Open WebUI model alias.

Example Hermes `.env` shape:

```text
API_SERVER_ENABLED=true
API_SERVER_HOST=<agent-tailnet-ip-or-host>
API_SERVER_PORT=8642
API_SERVER_MODEL_NAME=<unique-agent-model-id>
API_SERVER_KEY=<strong secret>
```

Recommended model id examples:

```text
donna-hermes
nikolai-hermes
paperclip-hermes
victoria-hermes
```

Then in Open WebUI provider config:

```text
http://<agent-tailnet-host>:8642/v1
```

If the user-facing display name should be pretty, create an Open WebUI custom model:

```text
Display id/name: Donna Hermes
Base model id:   donna-hermes
```

## Pitfalls Encountered

### 1. Direction Confusion

There are two possible architectures:

```text
A. Open WebUI connects to Hermes agents
B. Hermes agents call Open WebUI as their model provider
```

The intended architecture here is A.

Open WebUI is the shared frontend and routes to multiple Hermes API servers. The Hermes agents do not need to "connect into" Open WebUI as clients. Instead, Open WebUI registers each Hermes agent as an upstream OpenAI-compatible provider.

### 2. Open WebUI Was Not Publicly Bound

`http://100.84.200.95:8080` refused. This looked wrong at first, but it was correct because Open WebUI is intentionally bound to VPS loopback:

```text
127.0.0.1:8080
```

Tailscale Serve exposes it privately:

```text
https://srv1264451.tailfedd3b.ts.net:8444
```

Do not "fix" this by binding Open WebUI publicly unless there is a deliberate security review.

### 3. Canonical Hostname vs Alias Hostname

The UI worked at:

```text
https://donna.tailfedd3b.ts.net:8444
```

But the Open WebUI API token returned `401` against that hostname.

The same token worked at:

```text
https://srv1264451.tailfedd3b.ts.net:8444
```

Use the canonical Tailscale Serve hostname for API automation unless token/cookie/domain behavior is intentionally adjusted.

### 4. Raw Model ID vs Friendly Model Name

The WSL Hermes API exposed:

```text
nikolai-hermes
```

The browser URL selected:

```text
Donna Hermes
```

Open WebUI did not automatically know those were the same. The solution was to create a custom Open WebUI model alias:

```text
Donna Hermes -> nikolai-hermes
```

### 5. Missing `/v1`

Open WebUI provider URLs should include `/v1`:

```text
http://nikoli-wsl.tailfedd3b.ts.net:8642/v1
```

Without `/v1`, model discovery and completions may hit the wrong path.

### 6. Container Lacked Common Tools

The Open WebUI container did not have `wget`. Python was available, so connectivity tests used:

```python
urllib.request.urlopen(...)
```

Do not assume common CLI tools exist inside slim containers.

### 7. Exposed Keys In Chat

An Open WebUI admin API key was pasted into chat. It should be rotated after this work is complete.

Also rotate any Hermes `API_SERVER_KEY` that was exposed anywhere unsafe.

## Security Notes

Keep all of this tailnet-only:

```text
Open WebUI: VPS loopback + Tailscale Serve
Hermes API servers: Tailscale-reachable only
No public 0.0.0.0 binding unless firewalled and intentional
```

Hermes API access is powerful. Anyone with the right Open WebUI access and model selection can cause tools to run on the Hermes host.

For each Hermes agent, think about blast radius:

```text
What workspace is mounted?
What tools are available?
What secrets are in that user's environment?
What filesystem can it write?
Which machine will execute commands?
```

## Good Health Checklist

For each agent:

```bash
curl http://<agent-tailnet-host>:8642/health
```

Expected:

```json
{"status": "ok", "platform": "hermes-agent"}
```

Authenticated model discovery:

```bash
curl \
  -H "Authorization: Bearer <HERMES_API_SERVER_KEY>" \
  http://<agent-tailnet-host>:8642/v1/models
```

Expected:

```text
<agent-model-id>
```

From inside Open WebUI container:

```bash
docker exec 1215-prototype-local-open-webui-1 sh -lc 'python - <<PY
import urllib.request
print(urllib.request.urlopen("http://<agent-tailnet-host>:8642/health", timeout=8).read().decode())
PY'
```

Open WebUI model visibility:

```bash
curl \
  -H "Authorization: Bearer <OPEN_WEBUI_ADMIN_KEY>" \
  https://srv1264451.tailfedd3b.ts.net:8444/api/models
```

End-to-end Open WebUI completion:

```bash
curl \
  -H "Authorization: Bearer <OPEN_WEBUI_ADMIN_KEY>" \
  -H "Content-Type: application/json" \
  https://srv1264451.tailfedd3b.ts.net:8444/openai/chat/completions \
  -d '{
    "model": "<friendly-or-raw-model-id>",
    "messages": [{"role": "user", "content": "Reply exactly: ok"}],
    "stream": false
  }'
```

## Current Working Summary

Working path:

```text
https://donna.tailfedd3b.ts.net:8444/?model=Donna%20Hermes
  -> VPS Tailscale Serve
  -> VPS Open WebUI container
  -> model alias: Donna Hermes
  -> base model: nikolai-hermes
  -> provider: http://nikoli-wsl.tailfedd3b.ts.net:8642/v1
  -> local WSL Hermes agent
```

Verified response through that model path:

```text
donna-hermes-ok
```


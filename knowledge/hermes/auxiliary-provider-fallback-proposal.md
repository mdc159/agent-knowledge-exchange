# Hermes Auxiliary Provider Fallback Proposal

Date: 2026-04-30
Status: proposal
Scope: Hermes Agent auxiliary LLM tasks for local, gateway, and Paperclip-adjacent Hermes runtimes

## Executive summary

Hermes auxiliary tasks should default to resilient routing, not hard-pinned single-provider routing.

Recommended baseline:

1. Use `provider: auto` and empty `model: ""` for most auxiliary text tasks.
2. Pin a provider only when the task truly requires that provider's capability, and add a health check for that credential.
3. Prefer active Nous Portal credentials as a managed fallback path when available, especially for Hermes instances already using the Nous subscription tool gateway.
4. Treat OpenRouter as useful but not authoritative: a stale, missing, depleted, or wrong OpenRouter key can break every hard-pinned auxiliary task even while the main agent and Nous Portal are healthy.
5. Keep secrets in `.env` or OAuth stores, never in `config.yaml` or this repository.

The incident that triggered this proposal was a Hermes warning:

```text
Auxiliary title_generation: using openrouter (z-ai/glm-4.7-flash)
Title generation failed: Error code: 401 - {'error': {'message': 'User not found.', 'code': 401}}
```

This warning meant the main user-facing answer worked, but Hermes could not run the background LLM call used to auto-title the session. The failure occurred because `auxiliary.title_generation` was explicitly configured for OpenRouter while OpenRouter credentials were not valid for this instance. Active Nous Portal credentials did not help because the explicit OpenRouter route prevented normal fallback behavior.

## What auxiliary tasks are

Hermes uses auxiliary LLM calls for side work that supports the main conversation. Examples include:

- session title generation
- context compression
- session search summarization
- web extraction summarization
- vision or browser screenshot analysis
- approval classification
- skill hub or MCP assistance
- memory flushing / curation

These calls are operationally important, but most are not the primary answer path. A failure should be visible, diagnosable, and preferably recoverable through fallback.

## Evidence from Hermes behavior

### Configuration storage and precedence

Hermes documentation states that normal settings live in `~/.hermes/config.yaml`, secrets live in `~/.hermes/.env`, and OAuth credentials such as Nous Portal live in `~/.hermes/auth.json`. Configuration precedence is CLI arguments, `config.yaml`, `.env`, then built-in defaults.

Operational implication: provider names and routing policy belong in `config.yaml`; API keys and OAuth tokens do not belong in knowledge documents, Git, or copied runtime state.

### Auxiliary configuration model

Hermes' example config describes auxiliary models as advanced/experimental and says normal users should not need to change them. The example recommends `provider: "auto"` and empty model values for tasks unless the operator has a specific reason to override.

In current Hermes source, auxiliary calls resolve provider/model using this priority:

1. explicit call arguments
2. `auxiliary.<task>` config in `config.yaml`
3. `auto` resolution

The source also treats an explicit non-`auto` provider as a hard constraint in important cases. If a task is pinned to `openrouter`, Hermes tries OpenRouter for that task rather than freely selecting a healthier provider.

### Auto fallback behavior

Current Hermes source describes text-task auto resolution as a chain that can use the main runtime, OpenRouter, Nous Portal, custom endpoints, Anthropic, and direct API-key providers. The exact chain may evolve by release, but the key design point is stable: `auto` lets Hermes choose among available credentials; hard-pinning collapses the chain to one provider.

Payment and connection failures have explicit fallback behavior in auto mode. Auth failures for a hard-pinned provider are not equivalent to "try everything else"; they usually mean the configured provider is wrong or stale and should be fixed or unpinned.

## Incident note: OpenRouter 401 while Nous Portal was active

Observed instance state:

- main model: `gpt-5.5`
- main provider: OpenAI Codex
- Nous Portal: logged in and managed web/image/browser tools available
- OpenRouter: not configured or not valid in `hermes status`
- auxiliary title generation: explicitly configured to OpenRouter

Observed warning:

```text
HTTP 401 - User not found
```

Interpretation:

- This is an authentication/account identity failure from the OpenRouter path used by the auxiliary title-generation call.
- It is not evidence that the main model failed.
- It is not evidence that Honcho memory failed.
- It is not evidence that Nous Portal failed.
- It does mean every auxiliary task hard-pinned to OpenRouter is at risk of similar failure until the OpenRouter credential is repaired or the task is moved to `auto`/another provider.

Significance of active Nous Portal credentials:

- Active Nous Portal credentials give Hermes another managed inference/tooling path.
- They are especially valuable on a Nous subscription because web tools, image generation, OpenAI TTS, and browser automation can be available without separate Firecrawl/FAL/Browser-Use keys.
- They do not automatically override a task explicitly configured for OpenRouter.
- Therefore, "Nous Portal active" is only useful for auxiliary LLM fallback when the auxiliary task is configured to `auto` or explicitly to `nous`.

## Recommended fallback policy

### Tier 1: default resilient baseline

For general-purpose Hermes instances, use `auto` for text auxiliary tasks and leave model empty unless a known compatibility issue requires a model pin.

Suggested baseline:

```yaml
auxiliary:
  title_generation:
    provider: auto
    model: ""
    timeout: 30

  compression:
    provider: auto
    model: ""
    timeout: 120

  session_search:
    provider: auto
    model: ""
    timeout: 30
    max_concurrency: 3
    extra_body: {}

  skills_hub:
    provider: auto
    model: ""
    timeout: 30

  approval:
    provider: auto
    model: ""
    timeout: 30

  mcp:
    provider: auto
    model: ""
    timeout: 30

  flush_memories:
    provider: auto
    model: ""
    timeout: 30

  curator:
    provider: auto
    model: ""
    timeout: 600
```

Rationale: these are text tasks where reliability is more important than provider purity. If OpenRouter is broken but Nous Portal, Codex, Z.AI, or another provider is healthy, Hermes should have room to route around the fault.

### Tier 2: capability-pinned tasks

For tasks that need special model capabilities, pin only the minimum needed surface.

Vision example:

```yaml
auxiliary:
  vision:
    provider: auto
    model: ""
    timeout: 120
    download_timeout: 30

  web_extract:
    provider: auto
    model: ""
    timeout: 360
```

If a specific multimodal model is known to work better, pin the model but keep the provider `auto` when possible. Pin both provider and model only when the operator has verified the credential and model endpoint.

### Tier 3: explicit provider pins

Use explicit provider pins only when one of these is true:

- cost accounting requires a specific provider
- a task depends on a provider-specific model or feature
- compliance or data-routing policy forbids other providers
- the instance is intentionally isolated to a local/custom endpoint

When pinning, add an operational check:

```bash
hermes status --all
hermes config path
hermes config set auxiliary.title_generation.provider auto
hermes config set auxiliary.title_generation.model ""
```

For a pinned provider, verify all of these before relying on it:

- the provider appears configured in `hermes status --all`
- the relevant secret exists in `.env` or OAuth store, not in Git
- the selected model exists on that provider
- a small auxiliary call succeeds after a fresh Hermes session starts

## Recommended provider priority by environment

### Operator / research Hermes with Nous subscription

Recommended:

- Main model: choose for quality and task fit.
- Auxiliary text tasks: `auto`, empty model.
- Vision/web extraction: `auto`, empty model unless a known model is required.
- Managed tools: use Nous subscription gateway where available.

Why: active Nous Portal credentials are a strong fallback and reduce separate key management. Hard-pinning OpenRouter defeats this advantage.

### Cost-controlled batch or CI Hermes

Recommended:

- Main model: explicit low-cost provider/model.
- Auxiliary tasks: explicit provider if budgeting requires it, otherwise `auto`.
- Add smoke tests before long jobs.

Why: batch jobs should fail early if the budgeted provider is unavailable, but normal interactive agents should degrade gracefully.

### Local/self-hosted Hermes

Recommended:

- Auxiliary text tasks may use `main` or a custom endpoint if the local model is reliable.
- Keep `auto` for tasks where cloud fallback is acceptable.
- Do not route vision to a text-only local model.

Why: local routing is useful, but silent capability mismatch can be worse than a cloud fallback.

### Company-local / Paperclip inner Hermes

Recommended:

- Use company-local `HERMES_HOME` and company-scoped credentials.
- Do not inherit outer Hermes provider secrets or memory accidentally.
- Use `auto` only across providers authorized for that company.

Why: fallback paths are authority boundaries. An inner/company Hermes should not escape to an operator-level account just because a local key failed.

## Concrete recommendation for the observed instance

Immediate minimal fix:

```bash
hermes config set auxiliary.title_generation.provider auto
hermes config set auxiliary.title_generation.model ""
```

Recommended broader cleanup:

```bash
hermes config set auxiliary.compression.provider auto
hermes config set auxiliary.compression.model ""
hermes config set auxiliary.session_search.provider auto
hermes config set auxiliary.session_search.model ""
hermes config set auxiliary.skills_hub.provider auto
hermes config set auxiliary.skills_hub.model ""
hermes config set auxiliary.approval.provider auto
hermes config set auxiliary.approval.model ""
hermes config set auxiliary.mcp.provider auto
hermes config set auxiliary.mcp.model ""
hermes config set auxiliary.flush_memories.provider auto
hermes config set auxiliary.flush_memories.model ""
```

Then restart Hermes or start a new session. Tool and config changes are often snapshotted at process/session startup.

Do not paste API keys into this repository. If OpenRouter should remain part of the chain, repair it through local config only:

```bash
hermes config set OPENROUTER_API_KEY <key>
hermes status --all
```

## Monitoring and alerting recommendations

Watch for these log patterns:

```text
Auxiliary <task>: using <provider> (<model>)
Title generation failed
Error code: 401
Error code: 402
No LLM provider configured for task=<task>
```

Suggested interpretation:

- 401: credential/account/auth problem; repair or unpin the provider.
- 402: credit/billing problem; `auto` may route around it, hard-pinned providers probably will not.
- 404: model or endpoint mismatch; clear stale model pins or verify provider catalog.
- timeout/connection: provider unavailable; prefer `auto` unless isolation policy forbids fallback.

## Open questions

1. Should the shared Hermes template set all text auxiliary tasks to `auto` by default?
2. Should operator instances prefer `nous` explicitly for some auxiliary tasks when a Nous subscription is active, or leave `auto` to use the main runtime first?
3. Should Hermes core treat hard-pinned auxiliary provider 401 as eligible for fallback after one warning, or is the current fail-fast behavior correct because a pin is an operator constraint?
4. Should `hermes doctor` warn when auxiliary tasks are pinned to providers that `hermes status` reports as unavailable?

## Decision proposal

Adopt this repository convention:

- Default auxiliary task provider: `auto`.
- Default auxiliary task model: empty string.
- Provider pins require a reason in the profile, deployment note, or company config.
- Credentials must remain local to the runtime and must not be committed.
- For Hermes instances with active Nous Portal credentials, avoid OpenRouter-only auxiliary routing unless OpenRouter is explicitly required.

This keeps the agent useful under partial credential failure while preserving authority boundaries for inner/company-scoped Hermes runtimes.

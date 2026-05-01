# Telegram Agent Communication Plan

## Status

Draft for GitHub issue [#21](https://github.com/mdc159/agent-knowledge-exchange/issues/21): `[research] leveraging Telegram`.

Recommended destination for PR: `knowledge/hermes/telegram-agent-communication-plan.md`.

Verdict: **proceed with modifications**. Telegram should be adopted as a human-facing coordination, notification, approval, and handoff surface. It should **not** become the canonical agent-to-agent event bus, durable task ledger, raw transcript archive, or source of truth.

## Context

Miguel requested a plan for maximally leveraging Telegram for communication between humans and agents, and for visible agent-to-agent coordination across the team, including group chats and channels.

The review on issue #21 concluded that Hermes already supports most of the required Telegram primitives, but that the operating model must preserve the existing GitHub/Linear/knowledge-repo protocol:

- Linear remains canonical for planned work, priority, acceptance criteria, ownership, and status.
- GitHub remains canonical for code, issues, PRs, review, checks, and merge history.
- This repo remains canonical for durable playbooks, research, knowledge, templates, and agent instructions.
- Telegram is the mobile, human-facing surface for interaction, alerts, summaries, approvals, and lightweight handoffs.

## Grounding Sources

- GitHub issue: https://github.com/mdc159/agent-knowledge-exchange/issues/21
- Review comment: https://github.com/mdc159/agent-knowledge-exchange/issues/21#issuecomment-4359071068
- Hermes Telegram docs: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram
- Hermes Messaging Gateway docs: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/
- Hermes Gateway internals: https://hermes-agent.nousresearch.com/docs/developer-guide/gateway-internals
- Team Telegram Assistant guide: https://hermes-agent.nousresearch.com/docs/guides/team-telegram-assistant
- Telegram Bot API: https://core.telegram.org/bots/api
- Telegram bot features: https://core.telegram.org/bots/features
- Repo policy: `docs/repo-policy.md`
- Contribution guide: `docs/contribution-guide.md`
- Agent operating procedure: `docs/agent-operating-procedure.md`
- Hermes knowledge index: `knowledge/hermes/README.md`
- Related knowledge: `knowledge/hermes/multi-agent-knowledge-sharing.md`

## Recommended Architecture

Use Telegram as the **operator and team interaction layer** in front of canonical systems.

```text
Miguel / human team
        |
Telegram DMs, groups, forum topics, optional read-only channel
        |
Hermes Telegram gateway / dispatcher
        |
Canonical systems of record
  - Linear: planned work, owners, acceptance criteria, state
  - GitHub: issues, branches, PRs, reviews, checks, merge history
  - agent-knowledge-exchange: durable docs, playbooks, skills, templates
  - future broker/state layer, if needed: durable agent-to-agent events
        |
Agents, personas, tools, artifacts
```

Default rule: if the information must survive, be audited, be merged, be restored, or be used by another agent later, it belongs in Linear, GitHub, the knowledge repo, or a purpose-built broker/state layer — not only in Telegram history.

Telegram is excellent for:

- Miguel/operator private DMs with a specific agent.
- Human team coordination in a shared group or forum topic.
- Mobile notifications for agent status, PR state, blocked work, and incidents.
- Approval prompts and human-in-the-loop decisions.
- Scheduled digests and reports.
- Visible agent-to-agent handoff notifications.
- Short sanitized summaries with links to canonical artifacts.

Telegram is risky or weak for:

- durable work planning or task state;
- raw transcript archival;
- unrestricted terminal/log dumping;
- secrets or auth exchange;
- canonical agent-to-agent event flow;
- multi-bot bus semantics, because Telegram bots should not be relied upon as a robust bot-to-bot messaging fabric;
- broad group monitoring without explicit allowlists, topic controls, and privacy policy.

## Telegram Topology

### 1. Private DMs

Use DMs for sensitive operator-to-agent work and direct human-in-the-loop approvals.

Recommended DM usage:

- Miguel ↔ Donna for primary operator coordination.
- Miguel ↔ Victoria for VPS/business/ops work when Victoria is the correct actor.
- Miguel ↔ Nikolai for local Dell/GPU engineering work when Nikolai is the correct actor.
- Approval prompts that could expose sensitive commands, file paths, or operational details.
- `/new`, `/reset`, `/status`, `/approve`, `/deny`, `/stop`, `/model`, and similar session commands.

DMs may use Telegram private chat topics where available to isolate workstreams inside a single 1:1 bot chat.

### 2. Team Supergroup with Forum Topics

Create one trusted team supergroup with forum topics enabled. Use topics as visible workrooms, not as canonical project state.

Suggested topics:

- `General` — low-sensitivity coordination and questions.
- `Research` — research requests, source summaries, and links to research PRs.
- `Engineering` — implementation coordination and PR/check notifications.
- `Approvals` — restricted or carefully moderated approval prompts when a DM is not required.
- `Agent Status` — health, availability, queue, and completion notices.
- `Handoffs` — visible cross-persona handoff notices.
- Per-issue or per-run topics when an active workstream needs temporary focus.

Default behavior in group contexts should be conservative:

- require a slash command, reply, direct `@botusername` mention, or configured wake phrase;
- keep `require_mention` enabled for shared spaces;
- ignore noisy or sensitive topics explicitly;
- summarize rather than paste raw logs or transcripts;
- include canonical links when a message describes durable work.

### 3. Optional Announcement Channel

Use an optional read-only channel for broadcast summaries only.

Good channel content:

- daily/weekly status digest;
- merged PR summaries;
- high-level incident notifications;
- agent availability/maintenance notices;
- links to issues, PRs, and durable docs.

Do not use the channel for approvals, secrets, raw logs, raw session content, or task ownership changes.

## Hermes Feature Mapping

Hermes and Telegram already cover most of the needed surface.

| Need | Hermes / Telegram support | Recommended use |
| --- | --- | --- |
| Authorized users | `TELEGRAM_ALLOWED_USERS` with numeric Telegram user IDs | Always configure; do not rely on usernames. |
| Bot setup | BotFather token and bot profile commands | Create one bot per persona or one dispatcher bot, depending on isolation needs. Keep tokens outside Git. |
| Group visibility | Telegram privacy mode, bot admin status, Hermes group handling | Prefer privacy mode plus explicit mention/command routing unless full-group monitoring is deliberately approved. |
| Mention-gated group use | `telegram.require_mention`, `telegram.mention_patterns` | Set `require_mention: true` in shared groups; add narrow wake patterns if needed. |
| Topic suppression | `telegram.ignored_threads` | Silence topics that should not trigger agents. |
| Forum topics | Telegram forum topics / thread routing | Use topics as workrooms with isolated context where supported. |
| Private chat topics | Telegram Bot API private chat topics | Use for multiple isolated workspaces in a DM when available. |
| Home delivery | `/sethome`, `TELEGRAM_HOME_CHANNEL`, `TELEGRAM_HOME_CHANNEL_NAME` | Route scheduled digest/report output to the chosen safe home channel. |
| Commands | `/new`, `/reset`, `/status`, `/stop`, `/approve`, `/deny`, `/model`, `/resume`, `/title`, `/usage` | Use commands for session hygiene, approvals, and status checks. |
| Approvals | Hermes approval prompts and `/approve` / `/deny` | Keep sensitive approvals in DM or restricted approval topic. |
| Attachments | Telegram media/file support and Hermes `MEDIA:/path` delivery | Use for generated artifacts only when paths are host-readable and content is safe to share. |
| Voice | Hermes Telegram voice transcription and outgoing voice support | Useful for mobile operator interaction; summaries still need durable artifacts when decisions matter. |
| Scheduled reports | Hermes gateway cron delivery | Send concise digests with links to canonical records. |
| Outbound messages | Hermes delivery / `send_message` style routing | Use for notifications, handoff notices, and status packets. |
| Sessions | Hermes per-chat/per-topic session routing | Keep persona and topic context isolated; do not manually construct or share session DBs. |

Configuration examples in a future implementation PR must use placeholders only. Do not commit real bot tokens, numeric user IDs unless explicitly approved as public, `.env` contents, auth exports, logs, session databases, or memory dumps.

## Persona/Session Isolation

Preserve the existing persona convention:

| Display name | Persona / role | Default Telegram posture |
| --- | --- | --- |
| Donna | main assistant / hub | Primary operator DM and coordination surface. |
| Victoria | `paperhermes` VPS persona | VPS/business/ops DM and topic participant. |
| Nikolai | local Dell/GPU persona | Local GPU/engineering DM and topic participant. |

Rules:

1. Use persona names in all shared-room summaries and handoffs: Donna, Victoria, Nikolai.
2. Keep persona sessions isolated by default.
3. Prefer topic-specific context over one giant shared chat.
4. Do not copy one persona's `.env`, auth material, session DB, raw memory, or logs into another persona.
5. Do not let shared Telegram rooms become implicit shared memory.
6. Publish curated artifacts for cross-persona learning: issue comments, PRs, knowledge docs, status packets, and handoff notes.
7. When a persona acts on behalf of another, require an explicit handoff with scope, desired output, and canonical links.

Recommended handoff notice format for Telegram:

```text
HANDOFF
From: Donna
To: Victoria
Scope: Investigate paperhermes gateway readiness
Canonical link: <Linear/GitHub issue or PR>
Desired output: sanitized status summary and blockers
Sensitive material: none included; use DM for approvals if needed
```

Durable handoffs should still be captured in Linear/GitHub or a knowledge artifact.

## Safety/Privacy Policy

Telegram messages are convenient and mobile-first, but they are not a substitute for repo policy or secret handling. Shared rooms should receive sanitized summaries, links, and approval prompts only when appropriate.

Never post or commit:

- `.env` files or copied `.env` contents;
- API keys, bot tokens, OAuth tokens, provider credentials, or auth exports;
- SSH private keys or unrelated `authorized_keys` contents;
- raw Hermes session databases;
- raw memory dumps;
- raw runtime state;
- full cache trees;
- large transient logs;
- unrestricted terminal scrollback;
- anything whose only value is machine residue.

Telegram-specific safety rules:

1. Use numeric Telegram user IDs for allowlists; usernames are not stable authority boundaries.
2. Keep bot tokens secret and revoke immediately through BotFather if exposed.
3. Start with least visibility in groups: commands, replies, direct mentions, and explicit wake phrases.
4. Use `telegram.require_mention: true` for shared team groups unless there is a documented reason not to.
5. Use `telegram.ignored_threads` for topics where the bot should never respond.
6. Keep sensitive approvals in DM or a restricted approval topic.
7. Summarize command output instead of pasting raw logs.
8. Link to GitHub/Linear/knowledge docs for durable context.
9. Treat Telegram history as operational convenience, not as backup or memory.
10. If a generated artifact is sent with `MEDIA:/path`, confirm the file is safe to disclose and readable by the gateway host.

## Agent-to-Agent Boundary

Telegram may show agent-to-agent coordination, but it should not be the agent-to-agent substrate.

Allowed through Telegram:

- visible handoff notices;
- status packets;
- completion summaries;
- blocked-work alerts;
- requests for human approval;
- links to canonical issues, PRs, docs, or artifacts.

Not allowed as the default through Telegram:

- canonical task assignment state;
- hidden bot-to-bot protocols;
- raw memory exchange;
- raw transcript exchange;
- durable event sourcing;
- direct credential or secret exchange;
- final decisions with no GitHub/Linear/doc record.

Recommended rule: **agents communicate through artifacts, not vibes**. Telegram can announce and discuss the artifact, but the artifact lives elsewhere.

## Rollout Plan

### Phase 0 — Knowledge PR

- Add this plan as `knowledge/hermes/telegram-agent-communication-plan.md`.
- Update `knowledge/hermes/README.md` to link it.
- PR should cite issue #21 and confirm no secrets or raw runtime state were added.
- No gateway configuration changes yet.

### Phase 1 — Single Persona Pilot

- Pilot with Donna as the primary Telegram-facing assistant.
- Configure a bot through BotFather and Hermes gateway setup using local secret storage only.
- Allowlist Miguel by numeric Telegram user ID.
- Test DM commands: `/new`, `/status`, `/stop`, `/approve`, `/deny`.
- Test a safe scheduled digest to the configured home channel.
- Document only sanitized setup decisions and validation summaries.

### Phase 2 — Team Group / Forum Topics

- Create a trusted team supergroup with topics.
- Add the bot with conservative group behavior.
- Enable mention-gated responses using `telegram.require_mention: true`.
- Define narrow wake phrases if needed.
- Add ignored threads for topics where Hermes should stay silent.
- Test one low-risk topic, then expand.

### Phase 3 — Persona Expansion

- Decide whether Donna, Victoria, and Nikolai should use separate bots, separate gateway profiles, or a dispatcher pattern.
- Prefer separate persona/session boundaries when authority, host, memory, or credentials differ.
- Introduce visible handoff notices between personas.
- Keep canonical work state in Linear/GitHub/knowledge docs.

### Phase 4 — Automation and Digests

- Add scheduled status digests for PRs, blocked work, and agent availability.
- Add approval routing conventions.
- Add incident/update summary templates.
- Evaluate whether any gap requires gateway hooks, a lightweight broker, or a state layer.

### Phase 5 — Broker/State Layer Only If Needed

Only introduce a separate durable event broker if there are real requirements Telegram and existing systems do not satisfy, such as:

- reliable machine-to-machine delivery;
- replayable events;
- idempotency;
- strict audit logs;
- multi-agent routing independent of human chat UX.

If this layer is introduced, Telegram should remain a notification/control surface over it, not the durable store itself.

## Follow-up Issues

Suggested follow-ups after the knowledge PR lands:

1. **Telegram pilot for Donna** — configure and validate a single-persona Telegram DM pilot with no secrets in Git.
2. **Team group topic convention** — define the trusted group, topics, mention policy, ignored topics, and home channel rules.
3. **Approval routing policy** — document which approvals belong in DM, restricted topics, GitHub, or Linear.
4. **Persona bot/session decision** — decide separate bots vs gateway profiles vs dispatcher for Donna, Victoria, and Nikolai.
5. **Scheduled digest templates** — define daily/weekly status packets and safe content rules.
6. **Broker gap analysis** — only if actual cross-agent delivery requirements exceed GitHub/Linear/knowledge-doc handoffs.

Do not create these issues until the research PR identifies and scopes the real gaps.

## Links

- Issue #21: https://github.com/mdc159/agent-knowledge-exchange/issues/21
- Review comment: https://github.com/mdc159/agent-knowledge-exchange/issues/21#issuecomment-4359071068
- Proposed doc path: `knowledge/hermes/telegram-agent-communication-plan.md`
- Hermes Telegram docs: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram
- Hermes Messaging Gateway docs: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/
- Hermes Gateway internals: https://hermes-agent.nousresearch.com/docs/developer-guide/gateway-internals
- Team Telegram Assistant guide: https://hermes-agent.nousresearch.com/docs/guides/team-telegram-assistant
- Telegram Bot API: https://core.telegram.org/bots/api
- Telegram bot features: https://core.telegram.org/bots/features

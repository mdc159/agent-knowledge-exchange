# Victoria Communications Operating Plan v0

## Purpose

Give Victoria a bounded communications operating model for Studio54 Phase 1 without enabling external sending, new accounts, runtime topology, or phone/Nikolai/Android/Termux work.

Primary tracker: Studio54 issue #12
Related trail: AKE issue #19, Linear 121-33

## Operating stance

Victoria may draft, triage, summarize, and sound off. Victoria must not send external messages or change communication infrastructure without explicit Miguel/Donna approval.

## Outbound use cases

Victoria may prepare drafts for:

- internal GitHub/Linear status updates
- issue/PR handoff summaries
- vendor/government/contact outreach drafts for Miguel/Donna review
- appointment, permit, logistics, or follow-up message drafts
- risk alerts when a communication could create legal, financial, operational, or reputation exposure

Victoria may post directly only to approved internal artifacts when the task authorizes it, such as GitHub issues/PRs or Linear comments.

## Inbound triage

When inbound information is pasted or summarized by Miguel/Donna, Victoria should classify it as:

1. Action required now: deadline, blocker, approval, incident, or live coordination.
2. Draft response needed: Victoria can prepare text but must not send externally.
3. Research needed: gather public/non-secret context before recommending action.
4. File for record: summarize and link to the relevant issue/PR/doc.
5. Escalate: legal, financial, identity, credential, safety, government, vendor-contract, or reputation risk.

Victoria should preserve the source boundary: do not ask for or inspect secrets, auth exports, private keys, `.env`, session DBs, memory stores, raw transcripts, or raw logs.

## Channels

### Approved now

- GitHub issues/PRs for sanitized engineering and operating updates.
- Linear comments for task status when explicitly authorized.
- AKE knowledge docs for durable operating plans and playbooks.
- Direct Donna/Miguel chat for decision requests and concise sound-offs.

### Future / draft-only until separately approved

- Telegram, WhatsApp, SMS, email, phone, social media DMs, vendor portals, legal/government portals, and public posts.
- Any account setup, OAuth pairing, notification hook, bot configuration, or external-send automation.

## Approval rules before external sends

Victoria must get explicit Miguel/Donna approval before any external send or state-changing communication. Approval must include:

- destination/channel
- recipient or audience
- final message body or approved summary
- whether attachments/links are included
- deadline or send window

Approval expires if the content, recipient, channel, or context changes.

## Cadence

- Kickoff: confirm scope, allowed artifacts, no-send boundaries, and current tracker links.
- During work: sound off after each material artifact, blocker, or decision point.
- End of task: report outcome, changed artifacts, validation, safety, and next action.
- Ongoing operations: prefer one concise daily digest per active communications thread unless there is an urgent blocker or explicit request for higher cadence.

## Templates / snippets

### Internal status comment

```text
outcome: <what changed or was decided>
confirmed: <facts verified from approved sources>
changed: <files/issues/PRs/comments updated>
validation: <checks performed, markdown/diff review, links>
safety: no external sends; no secrets/auth/session/runtime state touched
next_action: <one concrete next step and owner>
```

### External draft header

```text
DRAFT ONLY — NOT SENT
recipient/channel: <recipient + channel>
purpose: <why this message exists>
approval needed from: Miguel/Donna
message:
<draft text>
```

### Escalation request

```text
Escalation needed: <Miguel|Donna|both>
Reason: <legal/financial/vendor/government/identity/reputation/deadline/etc.>
Decision requested: <specific yes/no or option choice>
Deadline: <if any>
Safe default if no response: do not send / hold action
```

## Escalation to Miguel/Donna

Escalate immediately for:

- external sends or public posts
- legal, financial, tax, government, permit, immigration, identity, or banking topics
- vendor commitments, quotes, contracts, or cancellation notices
- messages involving credentials, keys, secrets, auth flows, or account recovery
- reputational risk, conflict, threats, harassment, or anything that could piss off the wrong cabrón
- ambiguity about whether a message is internal or external

Safe default: do not send; draft and ask.

## Safety boundaries / no-send rules

Victoria must not:

- send external messages without explicit approval
- configure accounts, OAuth, bots, phone, Android, Termux, Nikolai, or topology
- install packages, change services/firewalls, or alter runtime/session state
- read or paste secrets, `.env`, auth exports, SSH private keys, session DBs, memory stores, raw logs, or raw transcripts
- post raw panes or raw runtime dumps
- imply Miguel/Donna approval when only a draft exists
- treat silence as approval

## Sound-off format

Use this exact structure for Phase 1 communications work:

```text
outcome:
confirmed:
changed:
validation:
safety:
next_action:
```

## v0 acceptance checklist

- [x] Outbound use cases defined.
- [x] Inbound triage classes defined.
- [x] Approved and future channels separated.
- [x] External-send approval rules defined.
- [x] Cadence defined.
- [x] Templates/snippets included.
- [x] Miguel/Donna escalation rules defined.
- [x] Safety boundaries and no-send rules defined.
- [x] Sound-off format included.

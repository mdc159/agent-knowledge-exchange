# Victoria Communications Starter Kit v0

## Purpose

Provide reusable fill-in templates for Victoria Phase 1 communications work under the bounded operating contract in `knowledge/hermes/victoria-communications-operating-plan.md`.

Primary tracker: Studio54 issue #13
Related trail: Studio54 issue #12, AKE issue #19

## Use rules

- These templates are draft and triage aids, not permission to send.
- External messages remain `DRAFT ONLY — NOT SENT` until Miguel or Donna explicitly approves the exact channel, recipient, body, links, attachments, and send window.
- Approved internal tracker updates may use GitHub issues/PRs or Linear comments only when the task explicitly authorizes them.
- Safe default when unsure: do not send; ask Miguel/Donna.
- Do not request, read, paste, or summarize secrets, credentials, auth exports, `.env`, session databases, memory stores, raw logs, raw transcripts, private keys, or runtime dumps.

## Template 1: Inbound triage note

Use when Miguel or Donna pastes or summarizes inbound information for Victoria to classify.

```text
INBOUND TRIAGE NOTE
source boundary: <pasted summary / approved tracker / approved doc / other approved source>
received_from: <Miguel / Donna / internal tracker / other>
received_at: <date/time or unknown>
related_tracker: <issue/PR/doc URL>

classification:
- [ ] action required now
- [ ] draft response needed
- [ ] research needed
- [ ] file for record
- [ ] escalate

summary:
<sanitized summary of what came in>

confirmed:
<facts verified from approved non-secret sources>

risk_flags:
- [ ] legal / government / permit / tax
- [ ] financial / quote / contract / cancellation
- [ ] identity / credential / account recovery
- [ ] vendor commitment
- [ ] reputation / conflict / threat / harassment
- [ ] deadline / live coordination
- [ ] unclear internal vs external boundary

recommended_next_action:
<one concrete next step>

safety:
No external send. No secrets/auth/session DB/memory-store/raw log/raw transcript/runtime dump read or requested.
```

## Template 2: Outbound draft for Miguel/Donna approval

Use when Victoria prepares a message that may later be sent externally by an approved human or approved future channel.

```text
DRAFT ONLY — NOT SENT
approval_needed_from: <Miguel / Donna / both>
recipient_or_audience: <name/role/org/audience>
channel: <email / SMS / WhatsApp / Telegram / phone script / portal / other>
purpose: <why this message exists>
related_tracker: <issue/PR/doc URL>
deadline_or_send_window: <if any>
attachments_or_links: <none / list exact items>

message_draft:
"""
<write the proposed message here>
"""

approval_scope_requested:
- [ ] destination/channel approved
- [ ] recipient/audience approved
- [ ] exact body approved
- [ ] attachments/links approved
- [ ] send window approved

sound_off:
outcome: outbound draft prepared, not sent
confirmed: <facts used to draft>
changed: <draft artifact/comment/doc updated>
validation: reviewed against operating contract and no-send boundary
safety: DRAFT ONLY; no external send; approval expires if content, recipient, channel, or context changes
next_action: Miguel/Donna approve, revise, or reject
```

## Template 3: Approval request checklist

Use before any external send, public post, vendor communication, government/legal contact, or state-changing communication.

```text
APPROVAL REQUEST CHECKLIST
request_owner: Victoria
approval_needed_from: <Miguel / Donna / both>
related_tracker: <issue/PR/doc URL>

send_details:
channel: <exact channel>
recipient_or_audience: <exact recipient/audience>
message_body_location: <paste draft or link to approved draft>
attachments_or_links: <none / exact list>
send_window: <exact timing or deadline>

pre_send_checks:
- [ ] message is necessary and within scope
- [ ] facts are from approved sources
- [ ] no secrets, credentials, auth data, private keys, raw logs, raw transcripts, or runtime dumps included
- [ ] no legal/financial/vendor/government commitment unless explicitly intended
- [ ] tone and identity are appropriate
- [ ] approval covers this exact content, recipient, channel, links, attachments, and timing

approval_record:
approved_by: <name>
approval_time: <date/time>
approval_text_or_link: <exact approval or tracker link>

safe_default_if_not_approved:
do not send
```

## Template 4: Daily communications digest

Use once per active communications thread/day unless Miguel or Donna requests a different cadence or an urgent blocker appears.

```text
DAILY COMMUNICATIONS DIGEST
period: <date / time window>
owner: Victoria
related_trackers: <issue/PR/doc URLs>

outcome:
<what moved today>

confirmed:
<facts verified from approved sources>

changed:
<docs/issues/PRs/comments/drafts updated>

open_threads:
- <thread/topic>: <current status>

pending_approvals:
- <approval needed>: <owner + deadline>

blockers_or_risks:
- <blocker/risk or none>

validation:
<diff/markdown/source checks performed>

safety:
No external sends unless separately approved and recorded. No forbidden secret/runtime sources touched.

next_action:
<one concrete next step and owner>
```

## Template 5: Weekly communications digest

Use for a concise weekly rollup across active Victoria communications work.

```text
WEEKLY COMMUNICATIONS DIGEST
week_of: <YYYY-MM-DD>
owner: Victoria
scope: <projects/issues covered>

outcome:
<highest-level weekly result>

confirmed:
<stable facts and decisions confirmed this week>

changed:
<durable docs, PRs, issues, templates, or tracker updates changed>

decisions_needed:
- <decision>: <Miguel/Donna/both + deadline>

risks_and_blockers:
- <risk/blocker or none>

planned_next_week:
- <next planned action>

validation:
<checks performed across docs/diffs/trackers>

safety:
No unapproved external sends. No account/channel setup. No sending, scheduling, automation, topology, phone, Android, Termux, Nikolai, service, firewall, install, or forbidden secret/runtime-source work.

next_action:
<one concrete next step and owner>
```

## Template 6: Blocker / escalation note

Use when Victoria hits a decision point, risk, missing approval, or unsafe ambiguity.

```text
BLOCKER / ESCALATION NOTE
escalation_to: <Miguel / Donna / both>
related_tracker: <issue/PR/doc URL>
blocker_type: <approval / legal / financial / vendor / government / identity / credential / reputation / deadline / scope ambiguity / safety>
urgency: <low / normal / urgent>
deadline: <if any>

outcome:
Work is blocked pending a human decision.

confirmed:
<facts known from approved sources>

changed:
<what has already been drafted or updated, if anything>

decision_needed:
<specific yes/no or option choice>

safe_default:
do not send / do not change state / hold action

validation:
<checks already performed>

safety:
No external send or state-changing action taken. No forbidden sources touched.

next_action:
Miguel/Donna decide, or Victoria keeps the item parked.
```

## Template 7: No-send / needs-human-approval note

Use when a requested or implied action would cross the external-send or state-changing boundary.

```text
NO-SEND / NEEDS-HUMAN-APPROVAL NOTE
related_tracker: <issue/PR/doc URL>
requested_action: <what would be sent/scheduled/changed>
boundary_hit: <external send / public post / account setup / automation / legal-financial-vendor-government commitment / forbidden source / runtime change / other>

outcome:
No send or state-changing action performed.

confirmed:
Operating contract requires explicit Miguel/Donna approval before this action.

changed:
<draft prepared / tracker note added / no file changes>

approval_needed:
- destination/channel
- recipient/audience
- exact body or action
- attachments/links
- send window or execution timing

validation:
Checked against `victoria-communications-operating-plan.md` no-send and approval rules.

safety:
Held action. No external send, scheduling, automation, account/channel setup, runtime change, or forbidden secret/source access.

next_action:
Miguel/Donna provide explicit approval or revise scope.
```

## Template 8: Follow-up tracker entry

Use to capture next steps in GitHub/Linear/approved internal trackers.

```text
FOLLOW-UP TRACKER ENTRY
tracker: <GitHub issue/PR / Linear issue / AKE doc>
owner: <Victoria / Miguel / Donna / other>
due_or_review_date: <date or none>
status: <open / waiting for approval / blocked / done>

outcome:
<what this follow-up exists to accomplish>

confirmed:
<facts/decisions already confirmed>

changed:
<artifact or tracker updated>

next_steps:
- <step 1>
- <step 2>

validation:
<tracker links checked / markdown checked / diff checked / not applicable>

safety:
Internal tracker entry only. No external sends or forbidden source/runtime access.

next_action:
<one owner + one action>
```

## v0 acceptance checklist

- [x] Inbound triage note template included.
- [x] Outbound draft for Miguel/Donna approval template included.
- [x] Approval request checklist included.
- [x] Daily communications digest template included.
- [x] Weekly communications digest template included.
- [x] Blocker/escalation note template included.
- [x] No-send / needs-human-approval note included.
- [x] Follow-up tracker entry template included.
- [x] Studio54 sound-off fields included where relevant.
- [x] No-send and forbidden-source boundaries repeated.

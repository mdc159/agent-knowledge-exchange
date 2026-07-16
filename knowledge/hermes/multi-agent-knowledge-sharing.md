# Multi-Agent Knowledge Sharing

Use durable, reviewable artifacts to transfer conclusions between agents that do
not share conversation state.

## Pattern

1. Give each agent a bounded task, acceptance criteria, and source boundary.
2. Keep raw runtime output outside Git.
3. Record the reusable conclusion in a knowledge note or skill.
4. Link evidence without copying secrets, logs, prompts, or private state.
5. Have another agent or operator review the extracted conclusion.

## Handoff contract

A useful handoff states:

- the question and scope
- verified facts and their date
- assumptions and unresolved gaps
- validation performed
- the next safe action

Use fictional identifiers in public examples. Live agent rosters, hostnames,
addresses, current work assignments, and management paths belong elsewhere.


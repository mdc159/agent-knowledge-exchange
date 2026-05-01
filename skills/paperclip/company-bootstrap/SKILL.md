# Paperclip Company Bootstrap

## Purpose

Create or repair a Paperclip company with deliberate runtime wiring.

## Procedure

1. create the company and org roles
2. assign adapter types explicitly
3. verify each required runtime exists where Paperclip can execute it
4. pin important models for approval-bearing roles
5. set company-scoped runtime homes where memory isolation matters
6. ensure the Paperclip runtime user owns those runtime-home trees
7. verify local adapters receive resolved config and env values rather than raw
   binding objects
8. run one issue loop end to end, including an assignment wake, before trusting
   autonomy

## Common Checks

- `hermes_local` can resolve `hermes`
- the Paperclip runtime user can execute both the Hermes launcher and its
  Python interpreter
- `codex_local` can resolve `codex`
- company-specific homes exist where expected
- company-specific Hermes homes are owned by the Paperclip runtime UID/GID
- assignment wakes surface `taskId`, `taskTitle`, `taskBody`, `commentId`, and
  `wakeReason` into adapter config for adapters that build prompts from
  `ctx.config`
- local adapter env values are resolved strings, not `[object Object]`
- Paperclip can reach any required backing services

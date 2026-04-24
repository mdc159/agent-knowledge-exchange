# Paperclip Company Bootstrap

## Purpose

Create or repair a Paperclip company with deliberate runtime wiring.

## Procedure

1. create the company and org roles
2. assign adapter types explicitly
3. verify each required runtime exists where Paperclip can execute it
4. pin important models for approval-bearing roles
5. set company-scoped runtime homes where memory isolation matters
6. run one issue loop end to end before trusting autonomy

## Common Checks

- `hermes_local` can resolve `hermes`
- `codex_local` can resolve `codex`
- company-specific homes exist where expected
- Paperclip can reach any required backing services

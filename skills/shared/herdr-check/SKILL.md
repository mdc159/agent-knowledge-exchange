---
name: herdr-check
description: Deterministic whereabouts check — am I in a Herdr-managed pane? Run at session start in any agent harness (claude, codex, pi, gemini, opencode) or whenever unsure. Executes a script that reports pane/workspace identity and tells the agent exactly which fleet skills to load.
---

# herdr-check

One deterministic check, harness-agnostic: a shell script decides whether this
process runs inside a Herdr-managed pane and prints explicit directives. The
agent never has to remember the check logic — it only has to run the script and
obey the output.

## Steps

1. Run the script (from bash or any shell with Git Bash on PATH):

   ```bash
   bash "$HOME/.agents/bin/herdr-check.sh"
   ```

   From PowerShell:

   ```powershell
   bash "$env:USERPROFILE/.agents/bin/herdr-check.sh"
   ```

2. Follow the output exactly:
   - `IN_HERDR=yes` → load the `herdr` and `herdr-fleet` skills from the
     `SKILL:` paths printed by the script (read each path's `SKILL.md`),
     before doing substantive work. Fleet mode is then the default posture.
   - `IN_HERDR=no` → do not run any herdr session-control command this
     session. Proceed normally.

3. Tell the user in one line where you are (pane/workspace IDs, or "not in
   Herdr").

## Notes

- The script is read-only and safe to run anywhere, including outside Herdr.
- Canonical source lives in the `mdc159/agent-knowledge-exchange` repo under
  `skills/shared/herdr-check/`; the runtime copy is
  `~/.agents/bin/herdr-check.sh`. Fix bugs in the repo by PR, then re-install.

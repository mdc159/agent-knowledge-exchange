# Session whereabouts check: /herdr-check

**Date:** 2026-08-16
**Origin:** A Claude Code session in shizzle received the "check for Herdr at
session start" instruction in its global CLAUDE.md and still skipped it after a
`/clear`. Prose instructions that depend on a model remembering are fragile;
the check was made deterministic and harness-agnostic instead.

## The pattern

One read-only shell script decides whether the current process is inside a
Herdr-managed pane and prints explicit directives. Agents never re-implement
the check — they run the script and obey its output.

- **Script (runtime copy):** `~/.agents/bin/herdr-check.sh`
- **Canonical source:** `skills/shared/herdr-check/herdr-check.sh` in this repo
- **Cross-runtime skill:** `~/.agents/skills/herdr-check/SKILL.md` (visible to
  claude, pi, codex, gemini — every runtime that reads `~/.agents/skills`)

The script prints machine-readable facts (`IN_HERDR=yes|no`, pane/tab/
workspace/socket IDs, herdr version, resolved `SKILL:` paths for the fleet
skills), then numbered directives: load `herdr` + `herdr-fleet`, fleet-mode
default, safety rules — or, outside Herdr, "do not run session-control
commands."

## Per-harness /command wrappers (this machine)

Each wrapper is a thin "run the script and follow its directives" prompt:

| Harness | Location |
| --- | --- |
| Claude Code | `~/.claude/commands/herdr-check.md` |
| codex | `~/.codex/prompts/herdr-check.md` |
| opencode | `~/.config/opencode/command/herdr-check.md` |
| gemini | `~/.gemini/commands/herdr-check.toml` |
| pi | via the `herdr-check` skill in `~/.agents/skills` |

## Install on a new node

1. Copy `skills/shared/herdr-check/herdr-check.sh` to
   `~/.agents/bin/herdr-check.sh` (LF line endings; runs under Git Bash on
   Windows).
2. Copy `skills/shared/herdr-check/SKILL.md` to
   `~/.agents/skills/herdr-check/SKILL.md`.
3. Add the per-harness wrapper files for whichever CLIs the node has (contents
   above are three sentences each — mirror an existing node's copies).
4. Ensure `herdr` and `herdr-fleet` skills exist under `~/.agents/skills` so
   non-Claude runtimes can load them (on the first node `herdr-fleet` existed
   only in `~/.claude/skills` — Claude-only — until it was copied over).

## Lessons

- A session-start instruction in a harness memory file is advisory; a `/command`
  wrapping a deterministic script survives model non-compliance, `/clear`, and
  harness differences, because the environment does the checking and the agent
  only follows printed directives.
- Keep the script read-only so it is safe to run reflexively anywhere,
  including outside Herdr.

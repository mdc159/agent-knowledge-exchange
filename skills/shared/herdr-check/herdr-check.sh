#!/usr/bin/env bash
# herdr-check — deterministic whereabouts check for any agent harness.
# Prints machine-readable facts first, then explicit directives for the agent.
# Safe to run anywhere: read-only, no session mutation.

if [ "${HERDR_ENV:-}" = "1" ]; then
    echo "IN_HERDR=yes"
    echo "PANE=${HERDR_PANE_ID:-unknown}"
    echo "TAB=${HERDR_TAB_ID:-unknown}"
    echo "WORKSPACE=${HERDR_WORKSPACE_ID:-unknown}"
    echo "SOCKET=${HERDR_SOCKET_PATH:-unknown}"
    if command -v herdr >/dev/null 2>&1; then
        echo "HERDR_VERSION=$(herdr --version 2>/dev/null | head -1)"
    else
        echo "HERDR_VERSION=binary-not-on-PATH"
    fi

    # Where the fleet skills live on this machine (first hit wins per name).
    for name in herdr herdr-fleet driving-pi-agents herdr-verifier-loop pi-observability; do
        found=""
        for root in "$HOME/.agents/skills" "$HOME/.claude/skills"; do
            if [ -f "$root/$name/SKILL.md" ]; then
                found="$root/$name"
                break
            fi
        done
        echo "SKILL:$name=${found:-MISSING}"
    done

    echo ""
    echo "DIRECTIVES FOR THE AGENT (follow in order):"
    echo "1. You are inside a Herdr-managed pane. Load the 'herdr' skill (operating"
    echo "   manual) and the 'herdr-fleet' skill (fleet orchestration) from the"
    echo "   SKILL: paths above BEFORE substantive work."
    echo "2. Fleet mode is the default: delegate independent, parallelizable, or"
    echo "   slow-and-offloadable work to sibling panes (claude, codex, pi,"
    echo "   opencode). Background jobs get their own panes."
    echo "3. Safety: use --no-focus for background panes, only touch panes you"
    echo "   created, parse IDs from JSON responses, supervise workers actively."
    echo "4. For producer->verifier pairs prefer the herdr-verifier-loop harness."
else
    echo "IN_HERDR=no"
    echo ""
    echo "DIRECTIVE FOR THE AGENT:"
    echo "This is NOT a Herdr-managed pane. Do not run any herdr session-control"
    echo "command (pane/tab/workspace/agent control). Proceed normally."
fi

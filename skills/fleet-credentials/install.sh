#!/usr/bin/env bash
# Install the fleet-cred CLI and (optionally) register the fleet-credentials
# skill for local agents. Idempotent. Usage:
#   skills/fleet-credentials/install.sh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

install_cli() {
  local dest=""
  for d in /opt/homebrew/bin /usr/local/bin "$HOME/.local/bin"; do
    if [ -d "$d" ] && [ -w "$d" ]; then dest="$d"; break; fi
  done
  if [ -z "$dest" ]; then
    dest="$HOME/.local/bin"; mkdir -p "$dest"
  fi
  install -m 755 "$HERE/fleet-cred" "$dest/fleet-cred"
  echo "installed CLI: $dest/fleet-cred"
  command -v fleet-cred >/dev/null || \
    echo "NOTE: $dest is not in PATH — add it for agents to find fleet-cred"
}

install_skill_link() {
  local skills_dir="$HOME/.agents/skills"
  if [ -d "$skills_dir" ]; then
    ln -sfn "$HERE" "$skills_dir/fleet-credentials"
    echo "linked skill: $skills_dir/fleet-credentials -> $HERE"
  else
    echo "no ~/.agents/skills directory; skipping skill link"
  fi
}

install_cli
install_skill_link

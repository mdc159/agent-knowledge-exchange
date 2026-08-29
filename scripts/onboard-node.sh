#!/usr/bin/env bash
# onboard-node.sh — plug a new machine into the fleet credential system.
#
# Run FROM an admin machine (cbass or donna) against a fresh node:
#
#   ./onboard-node.sh <node-name> <ssh-target> [--tier ops|worker] [--user <name>]
#
#   ./onboard-node.sh m6800 root@192.168.1.50 --tier worker
#   TS_AUTH_KEY=tskey-auth-... ./onboard-node.sh newbox root@newbox.local --tier worker
#
# What it does (idempotent, safe to re-run):
#   1. Ensures Tailscale is installed and joined (uses TS_AUTH_KEY from the
#      environment if the node is not yet on the tailnet; get a key from
#      1Password "Tailscale Provisioning OAuth" or the Tailscale admin panel.
#      The key is passed over ssh to the install command and never stored).
#   2. Installs the fleet-cred CLI to /usr/local/bin.
#   3. Installs the fleet-credentials agent skill into ~/.agents/skills/.
#   4. Grants the node its capability tier in the broker policy on donna
#      (hot-reload; no restart). ops = 24h/$25, worker = 4h/$5.
#   5. Smoke-tests: mints one OpenRouter key, revokes it immediately, clears
#      the cache. The key value is never printed or stored persistently.
#
# Requirements on the admin machine: ssh access to the node and to donna.
# The node's Tailscale name MUST equal <node-name> for policy grants to work.
set -euo pipefail

NODE="${1:?usage: onboard-node.sh <node-name> <ssh-target> [--tier ops|worker] [--user name]}"
TARGET="${2:?missing ssh target}"
TIER="worker"
NODE_USER="root"
shift 2
while [ $# -gt 0 ]; do
  case "$1" in
    --tier) TIER="$2"; shift 2 ;;
    --user) NODE_USER="$2"; shift 2 ;;
    *) echo "unknown flag: $1"; exit 2 ;;
  esac
done

case "$TIER" in
  ops)    MAX_TTL=86400; MAX_USD=25 ;;
  worker) MAX_TTL=14400; MAX_USD=5 ;;
  *) echo "tier must be ops or worker"; exit 2 ;;
esac

CLI_SRC="${CLI_SRC:-$(dirname "$0")/../skills/fleet-credentials/fleet-cred}"
[ -f "$CLI_SRC" ] || CLI_SRC="$(dirname "$0")/fleet-cred"
[ -f "$CLI_SRC" ] || { echo "cannot find fleet-cred CLI next to script"; exit 1; }
SKILL_DIR="$(dirname "$CLI_SRC")"

echo "== 1/5 tailscale on $NODE =="
ssh -o ConnectTimeout=10 "$TARGET" '
  if ! command -v tailscale >/dev/null; then
    echo "installing tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
  fi
  if ! tailscale status >/dev/null 2>&1; then
    if [ -n "'"${TS_AUTH_KEY:-}"'" ]; then
      sudo tailscale up --auth-key="'"${TS_AUTH_KEY:-}"'" --hostname="'"$NODE"'"
    else
      echo "TAILSCALE-NEEDS-LOGIN"
    fi
  fi
  tailscale status --self 2>/dev/null | head -1 || true
'

echo "== 2/5 fleet-cred CLI =="
ssh "$TARGET" 'mkdir -p /usr/local/bin'
scp -q "$CLI_SRC" "$TARGET:/usr/local/bin/fleet-cred"
ssh "$TARGET" 'chmod 755 /usr/local/bin/fleet-cred && command -v python3 >/dev/null || { echo "python3 missing — install it"; exit 1; }'

echo "== 3/5 agent skill =="
ssh "$TARGET" "mkdir -p /home/$NODE_USER/.agents/skills /root/.agents/skills 2>/dev/null || true"
scp -qr "$SKILL_DIR" "$TARGET:/tmp/fleet-credentials-skill"
ssh "$TARGET" '
  for d in /home/*/.agents/skills /root/.agents/skills; do
    [ -d "$d" ] && rm -rf "$d/fleet-credentials" && cp -r /tmp/fleet-credentials-skill "$d/fleet-credentials" && echo "skill -> $d/fleet-credentials"
  done
  rm -rf /tmp/fleet-credentials-skill
'

echo "== 4/5 broker policy grant ($TIER: ${MAX_TTL}s/\$${MAX_USD}) =="
ssh root@donna "python3 - <<PYEOF
import json
p = '/opt/fleet-secrets/broker/policy.json'
policy = json.load(open(p))
policy.setdefault('nodes', {})['$NODE'] = {'openrouter': {'max_ttl_seconds': $MAX_TTL, 'max_limit_usd': $MAX_USD}}
json.dump(policy, open(p, 'w'), indent=2)
print('granted: $NODE')
PYEOF"

echo "== 5/5 smoke test =="
HASH=$(ssh "$TARGET" 'fleet-cred openrouter --json --ttl 300 --limit-usd 1' | python3 -c "import json,sys; print(json.load(sys.stdin)['hash'])")
ssh root@donna "TOKEN=\$(grep '^BROKER_API_TOKEN=' /opt/fleet-secrets/broker/.env | cut -d= -f2); curl -sf -m 10 -X DELETE -H \"Authorization: Bearer \$TOKEN\" http://127.0.0.1:8086/v1/keys/$HASH >/dev/null && echo revoked"
ssh "$TARGET" 'fleet-cred revoke openrouter >/dev/null; echo cache-cleared'

echo
echo "ONBOARDED: $NODE ($TIER)"
echo "Next: start a persistent Herdr session on the node; agents there can now"
echo "run 'fleet-cred openrouter' with zero setup. To revoke the node later:"
echo "remove it from /opt/fleet-secrets/broker/policy.json on donna and disable"
echo "the node in the Tailscale admin console."

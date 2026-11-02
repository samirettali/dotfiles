#!/usr/bin/env bash

# SessionStart hook of a Claude Code cloud session, installed by
# claude-cloud/setup.sh: join the tailnet with the environment's TS_AUTHKEY so
# that `ssh vega` reaches vega over Tailscale SSH. What it prints goes into the
# session's context. See docs/ai/claude-cloud.md, "The tailnet".

set -uo pipefail

state=/var/lib/tailscale
log=/tmp/tailscaled.log

if [[ -z ${TS_AUTHKEY:-} ]] || ! command -v tailscaled >/dev/null 2>&1; then
    echo "Tailscale: not set up in this environment (no TS_AUTHKEY or no tailscaled), so vega is out of reach."
    exit 0
fi

backend() { tailscale status --json 2>/dev/null | jq -r .BackendState; }

if [[ $(backend) == Running ]]; then
    echo "Tailscale: up. \`ssh vega\` reaches vega as samir over Tailscale SSH."
    exit 0
fi

if [[ -z $(backend) ]]; then
    mkdir -p "$state"
    # The container has no UDP to Tailscale, so traffic goes through DERP over
    # the HTTPS proxy, which tailscaled reads from HTTPS_PROXY.
    setsid tailscaled --tun=userspace-networking --statedir="$state" >"$log" 2>&1 </dev/null &
    for _ in $(seq 20); do
        [[ -n $(backend) ]] && break
        sleep 0.5
    done
fi

if out=$(tailscale up --auth-key="file:"<(printf %s "$TS_AUTHKEY") \
    --advertise-tags=tag:claude-cloud --hostname=claude-cloud --timeout=30s 2>&1); then
    echo "Tailscale: up. \`ssh vega\` reaches vega as samir over Tailscale SSH."
else
    echo "Tailscale: tailscale up failed, so vega is out of reach: ${out//$'\n'/ }. tailscaled's log is $log."
fi
exit 0

#!/usr/bin/env bash

# Run by a Claude Code cloud environment's setup script, from a clone of this
# repository: install the rendered configuration (make claude-cloud) and build
# ~/.claude/CLAUDE.md the way home/packages/ai/agents.nix does, with
# machines/claude-cloud.md as "This machine". CLAUDE.md is put together here,
# not rendered, so that an edit to agents.md reaches the next session.

set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
ai=$repo/home/packages/ai

mkdir -p "$HOME/.claude"
cp -R "$repo/claude-cloud/home/." "$HOME/"

{
    cat "$ai/agents.md"
    printf '\n'
    cat "$ai/personal.md"
    printf '\n'
    cat "$ai/projects.md"
    printf '\n## This machine\n\n'
    cat "$ai/machines/claude-cloud.md"
} > "$HOME/.claude/CLAUDE.md"

# Only cloud sessions join the tailnet, so the hook is added here and not in
# the render of mbp's settings. The test sets CLAUDE_CLOUD_NO_INSTALL to keep
# the packages off the machine it runs on.
if [[ -z ${CLAUDE_CLOUD_NO_INSTALL:-} ]]; then
    tailscale_version=1.104.4
    curl -fsSL "https://pkgs.tailscale.com/stable/tailscale_${tailscale_version}_amd64.tgz" | tar xz -C /opt
    ln -sf "/opt/tailscale_${tailscale_version}_amd64/tailscale" "/opt/tailscale_${tailscale_version}_amd64/tailscaled" /usr/local/bin/
    apt-get update -qq
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openssh-client
fi

mkdir -p "$HOME/.claude/hooks"
install -m 0755 "$repo/claude-cloud/tailscale.sh" "$HOME/.claude/hooks/tailscale.sh"
settings=$HOME/.claude/settings.json
jq --arg command "$HOME/.claude/hooks/tailscale.sh" \
    '.hooks.SessionStart = [{hooks: [{type: "command", command: $command, timeout: 60}]}]' \
    "$settings" > "$settings.tmp" && mv "$settings.tmp" "$settings"

# Tailscale SSH needs no key: the tailnet's policy lets tag:claude-cloud in.
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
grep -qs '^Host vega$' "$HOME/.ssh/config" || cat >> "$HOME/.ssh/config" <<'EOF'
Host vega
    User samir
    ProxyCommand tailscale nc %h %p
    StrictHostKeyChecking accept-new
EOF

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

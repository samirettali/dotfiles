#!/usr/bin/env bash

set -euo pipefail

usage() {
    printf 'Usage: %s <ssh-target>\n' "${0##*/}" >&2
    exit 2
}

[[ $# -eq 1 ]] || usage

target=$1
if [[ ! $target =~ ^[a-zA-Z0-9._@-]+$ ]]; then
    printf 'Invalid SSH target: %s\n' "$target" >&2
    exit 2
fi

for command in git rsync ssh; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'Required command not found: %s\n' "$command" >&2
        exit 1
    fi
done

files=(
    .config/tmux/tmux.conf
    .claude/CLAUDE.md
    .claude/settings.json
    .codex/AGENTS.md
    .codex/config.toml
    .pi/agent/AGENTS.md
    .pi/agent/mcp.json
    .pi/agent/settings.json
    revive.toml
)

directories=(
    .config/nvim
    .hammerspoon
    .claude/skills
    .codex/skills
    .pi/agent/extensions
    .pi/agent/skills
)

for path in "${files[@]}" "${directories[@]}"; do
    if [[ ! -e $HOME/$path ]]; then
        printf 'Configured source does not exist: %s\n' "$HOME/$path" >&2
        exit 1
    fi
done

printf 'Connecting to %s...\n' "$target"
remote_home=$(ssh -n "$target" "/bin/sh -c 'printf %s \"\$HOME\"'")
if [[ $remote_home != /* || $remote_home == *:* || $remote_home == *[[:space:]]* ]]; then
    printf 'Unexpected remote home directory: %s\n' "$remote_home" >&2
    exit 1
fi

tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/sync-configs.XXXXXX")
cleanup() {
    /bin/chmod -R u+w "$tmpdir" 2>/dev/null || true
    rm -rf "$tmpdir"
}
trap cleanup EXIT
mkdir "$tmpdir/before" "$tmpdir/after"

printf 'Preparing local configuration snapshot...\n'
for path in "${directories[@]}"; do
    mkdir -p "$tmpdir/after/$path"
    if [[ $path == .pi/agent/extensions ]]; then
        rsync -aL --exclude=/node_modules/ "$HOME/$path/" "$tmpdir/after/$path/"
    else
        rsync -aL "$HOME/$path/" "$tmpdir/after/$path/"
    fi
done
for path in "${files[@]}"; do
    parent=${path%/*}
    [[ $parent == "$path" ]] && parent=
    mkdir -p "$tmpdir/after/$parent"
    rsync -aL "$HOME/$path" "$tmpdir/after/$path"
done

remote_paths=$(ssh -n "$target" "/bin/sh -c 'for path in \
	.config/nvim .config/tmux/tmux.conf .hammerspoon \
	.claude/CLAUDE.md .claude/settings.json .claude/skills \
	.codex/AGENTS.md .codex/config.toml .codex/skills \
	.pi/agent/AGENTS.md .pi/agent/mcp.json .pi/agent/settings.json \
	.pi/agent/extensions .pi/agent/skills revive.toml; do \
	[ ! -e \"\$HOME/\$path\" ] || printf \"%s\\n\" \"\$path\"; done'")

printf 'Fetching remote configuration snapshot...\n'
for path in "${directories[@]}"; do
    if ! grep -Fxq "$path" <<<"$remote_paths"; then
        continue
    fi
    mkdir -p "$tmpdir/before/$path"
    if [[ $path == .pi/agent/extensions ]]; then
        rsync -aL --exclude=/node_modules/ \
            "$target:$remote_home/$path/" "$tmpdir/before/$path/"
    else
        rsync -aL "$target:$remote_home/$path/" "$tmpdir/before/$path/"
    fi
done
for path in "${files[@]}"; do
    if ! grep -Fxq "$path" <<<"$remote_paths"; then
        continue
    fi
    parent=${path%/*}
    [[ $parent == "$path" ]] && parent=
    mkdir -p "$tmpdir/before/$parent"
    rsync -aL "$target:$remote_home/$path" "$tmpdir/before/$path"
done
/bin/chmod -R u+w "$tmpdir/before" "$tmpdir/after"

if git --no-pager diff --quiet --no-index -- "$tmpdir/before" "$tmpdir/after"; then
    printf 'The selected configurations are already in sync.\n'
    exit 0
fi

printf '\nChanges to apply on %s (press q to close the diff):\n\n' "$target"
git -c core.pager='less -FRX' --paginate diff --no-index --no-prefix --color=always \
    -- "$tmpdir/before" "$tmpdir/after" || true

printf '\nApply these changes? [y/N] '
read -r answer </dev/tty
case $answer in
y | Y | yes | YES) ;;
*)
    printf 'Sync cancelled.\n'
    exit 0
    ;;
esac

ssh -n "$target" "/bin/sh -c 'mkdir -p \
	\"\$HOME/.config/nvim\" \
	\"\$HOME/.config/tmux\" \
	\"\$HOME/.hammerspoon\" \
	\"\$HOME/.claude/skills\" \
	\"\$HOME/.codex/skills\" \
	\"\$HOME/.pi/agent/extensions\" \
	\"\$HOME/.pi/agent/skills\"'"

for path in "${directories[@]}"; do
    if [[ $path == .pi/agent/extensions ]]; then
        rsync -aL --delete --exclude=/node_modules/ \
            "$HOME/$path/" "$target:$remote_home/$path/"
    else
        rsync -aL --delete "$HOME/$path/" "$target:$remote_home/$path/"
    fi
done

for path in "${files[@]}"; do
    rsync -aL "$HOME/$path" "$target:$remote_home/$path"
done

ssh -n "$target" "/bin/sh -c 'chmod -R u+w \
	\"\$HOME/.config/nvim\" \
	\"\$HOME/.config/tmux/tmux.conf\" \
	\"\$HOME/.hammerspoon\" \
	\"\$HOME/.claude/CLAUDE.md\" \
	\"\$HOME/.claude/settings.json\" \
	\"\$HOME/.claude/skills\" \
	\"\$HOME/.codex/AGENTS.md\" \
	\"\$HOME/.codex/config.toml\" \
	\"\$HOME/.codex/skills\" \
	\"\$HOME/.pi/agent/AGENTS.md\" \
	\"\$HOME/.pi/agent/mcp.json\" \
	\"\$HOME/.pi/agent/settings.json\" \
	\"\$HOME/.pi/agent/extensions\" \
	\"\$HOME/.pi/agent/skills\" \
	\"\$HOME/revive.toml\"'"

printf 'Configurations synced to %s.\n' "$target"

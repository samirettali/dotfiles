#!/usr/bin/env bash

# Copy the Claude Code configuration home-manager builds for mbp into
# claude-cloud/home, the files a Claude Code cloud session gets from
# claude-cloud/setup.sh. A cloud container cannot build the flake (its proxy
# refuses GitHub's tarballs) and has no chezmoi, so the render writes finished
# files, with nothing left to fill in on the container.

set -euo pipefail

home_dir=${1:-$HOME/dev/dotfiles/claude-cloud/home}
flake_dir=${2:-$HOME/dev/dotfiles}

for tool in rsync nix jq; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'Required command not found: %s\n' "$tool" >&2
        exit 1
    fi
done

files=(
    .claude/settings.json
)

# Skills that need neither rbw, nix nor Herdr, which a cloud session has not got.
directories=(
    .claude/skills/commit
    .claude/skills/review-comments
    .claude/skills/review-loop
)

attribute=darwinConfigurations.mbp.config.home-manager.users.samir.home-files

printf 'Building %s#%s...\n' "$flake_dir" "$attribute"

if ! root=$(nix build --no-link --no-write-lock-file --print-out-paths "$flake_dir#$attribute"); then
    printf 'The file tree did not build, so there is nothing to render.\n' >&2
    exit 1
fi

for path in "${files[@]}" "${directories[@]}"; do
    if [[ ! -e $root/$path ]]; then
        printf 'Not owned by nix, so the render cannot reach it: %s\n' "$path" >&2
        exit 1
    fi
done

printf 'Rendering into %s...\n' "$home_dir"

# Store files share an epoch mtime; transfer these small files even at equal size.
for path in "${directories[@]}"; do
    mkdir -p "$home_dir/$path"
    rsync -aL --ignore-times --delete "$root/$path/" "$home_dir/$path/"
done

for path in "${files[@]}"; do
    mkdir -p "$home_dir/${path%/*}"
    rsync -aL --ignore-times "$root/$path" "$home_dir/$path"
done

# The status line and the hooks run scripts nix builds for mbp. Firecrawl
# reads its key from the rbw vault, so Claude Code keeps its own WebSearch and
# WebFetch. The session's GitHub tools may come through the claude.ai
# connectors, so those stay on. sessionUrl keeps the session's link out of
# commits and pull requests.
settings=$home_dir/.claude/settings.json
jq 'del(.statusLine, .hooks, .disableClaudeAiConnectors)
    | .permissions.deny -= ["WebSearch", "WebFetch"]
    | .attribution.sessionUrl = false' \
    "$settings" > "$settings.tmp" && mv "$settings.tmp" "$settings"

chmod -R u+w "$home_dir"

contaminated=$(grep -rlE '/nix/store|/Users/samir' "$home_dir" || true)
if [[ -n $contaminated ]]; then
    printf '\nThese rendered files name a path of mbp:\n%s\n' "$contaminated" >&2
    printf 'Drop them from the list or strip the path in this script.\n' >&2
    exit 1
fi

printf 'Rendered. Review with: git -C %s status\n' "$flake_dir"

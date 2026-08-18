#!/usr/bin/env bash

# Copy the configuration home-manager deployed in $HOME into the chezmoi source
# tree, so the work Mac gets the same files without Nix. Run it after a build.

set -euo pipefail

source_dir=${1:-$HOME/dev/dotfiles/chezmoi}

if [[ ! -d $source_dir ]]; then
    printf 'chezmoi source directory not found: %s\n' "$source_dir" >&2
    exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
    printf 'Required command not found: rsync\n' >&2
    exit 1
fi

files=(
    .config/herdr/config.toml
    .config/tmux/tmux.conf
    .claude/settings.json
    .codex/config.toml
    revive.toml
)

directories=(
    .config/nvim
    .claude/skills/commit
    .claude/skills/code-review
    .codex/skills/commit
    .codex/skills/code-review
)

# .claude/CLAUDE.md and .codex/AGENTS.md are chezmoi templates, not copies.
# Everything under .pi and .hammerspoon stays on this machine.

# chezmoi names a dotfile after its target with the leading dot spelled out.
source_name() {
    local component out=
    local IFS=/
    for component in $1; do
        [[ $component == .* ]] && component=dot_${component#.}
        out=${out:+$out/}$component
    done
    printf '%s\n' "$out"
}

for path in "${files[@]}" "${directories[@]}"; do
    if [[ ! -e $HOME/$path ]]; then
        printf 'Configured source does not exist: %s\n' "$HOME/$path" >&2
        exit 1
    fi
done

printf 'Rendering into %s...\n' "$source_dir"

for path in "${directories[@]}"; do
    target=$source_dir/$(source_name "$path")
    rm -rf "$target"
    mkdir -p "$target"
    rsync -aL --delete "$HOME/$path/" "$target/"
done

for path in "${files[@]}"; do
    target=$source_dir/$(source_name "$path")
    mkdir -p "${target%/*}"
    rsync -aL "$HOME/$path" "$target"
done

chmod -R u+w "$source_dir"

# A rendered file that points into the store is useless on a machine without
# Nix. Report it instead of shipping it.
contaminated=$(grep -rl '/nix/store' "$source_dir" || true)
if [[ -n $contaminated ]]; then
    printf '\nThese rendered files reference the nix store:\n%s\n' "$contaminated" >&2
    printf 'Drop them from the list or replace the paths with bare command names.\n' >&2
    exit 1
fi

printf 'Rendered. Review with: git -C %s status\n' "${source_dir%/*}"

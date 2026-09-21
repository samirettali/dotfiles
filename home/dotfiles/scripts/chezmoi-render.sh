#!/usr/bin/env bash

# Copy the configuration home-manager builds for mbp into the chezmoi source
# tree, so the work Mac gets the same files without Nix.
#
# The source is the built file tree, not $HOME: a render then needs no
# activation, runs on any Mac and in CI, and cannot pick up a file edited by
# hand that nix does not own — which is how the herdr config drifted.

set -euo pipefail

source_dir=${1:-$HOME/dev/dotfiles/chezmoi}
flake_dir=${2:-${source_dir%/*}}

if [[ ! -d $source_dir ]]; then
    printf 'chezmoi source directory not found: %s\n' "$source_dir" >&2
    exit 1
fi

for tool in rsync nix jq; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'Required command not found: %s\n' "$tool" >&2
        exit 1
    fi
done

# Use `built:target` when a target needs a different name.
files=(
    .config/ghostty/config
    .config/herdr/config.toml
    .config/git/allowed_signers
    .config/tmux/tmux.conf
    .claude/hooks/herdr-agent-state.sh
    revive.toml
)

directories=(
    .config/nvim
    .claude/skills/commit
    .claude/skills/code-review
)

# A template merges the work-only additions into these, so they land among the
# templates instead of the targets.
templates=(
    .claude/settings.json:claude-settings.json
    .config/git/config:git-config
    .config/git/ignore:git-ignore
    .config/sottomano/keymap.json:sottomano-keymap.json
    .config/nvim/lua/plugins/init.lua:nvim-plugins-init.lua
    .config/nvim/lua/lsp-features.lua:nvim-lsp-features.lua
)

# Paths the render neither copies nor deletes: files written by hand for the
# work Mac, the templates that replace a copied file, and the plugin lock, since
# the work Mac resolves its own plugin versions.
declare -A skipped=(
    [.config/nvim]='lua/plugins/roslyn.lua lua/plugins/flutter.lua lua/plugins/init.lua lua/plugins/init.lua.tmpl lua/lsp-features.lua lua/lsp-features.lua.tmpl lsp/terraformls.lua nvim-pack-lock.json'
)

# .claude/CLAUDE.md is a chezmoi template, not a copy.
# Codex is not managed on the work Mac.
# Everything under .pi stays on this machine.

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

attribute=darwinConfigurations.mbp.config.home-manager.users.samir.home-files

printf 'Building %s#%s...\n' "$flake_dir" "$attribute"

if ! root=$(nix build --no-link --print-out-paths "$flake_dir#$attribute"); then
    printf 'The file tree did not build, so there is nothing to render.\n' >&2
    exit 1
fi

for path in "${files[@]%%:*}" "${directories[@]}" "${templates[@]%%:*}"; do
    if [[ ! -e $root/$path ]]; then
        printf 'Not owned by nix, so the render cannot reach it: %s\n' "$path" >&2
        printf 'Declare it in home-manager, or drop it from this script.\n' >&2
        exit 1
    fi
done

printf 'Rendering into %s...\n' "$source_dir"

for path in "${directories[@]}"; do
    target=$source_dir/$(source_name "$path")
    excludes=()
    for kept in ${skipped[$path]:-}; do
        excludes+=("--exclude=/$kept")
    done
    mkdir -p "$target"
    rsync -aL --delete "${excludes[@]}" "$root/$path/" "$target/"
done

for entry in "${files[@]}"; do
    path=${entry%%:*}
    target=$source_dir/$(source_name "${entry#*:}")
    mkdir -p "${target%/*}"
    rsync -aL "$root/$path" "$target"
done

for entry in "${templates[@]}"; do
    target=$source_dir/.chezmoitemplates/${entry#*:}
    mkdir -p "${target%/*}"
    rsync -aL "$root/${entry%%:*}" "$target"
done

# The status line is a script nix builds, so the work Mac has not got it.
template=$source_dir/.chezmoitemplates/claude-settings.json
jq "del(.statusLine)" "$template" > "$template.tmp" && mv "$template.tmp" "$template"

# The launcher binds the rbw vault and the sketchybar hook, which the work Mac
# has not got, and it names every command by store path because `open` gives it
# launchd's PATH. Dropping the bindings drops rbw, curl and sketchybar with them.
template=$source_dir/.chezmoitemplates/sottomano-keymap.json
jq 'del(.hooks) | .entries |= map(select(.name != "links" and .name != "vault"))' \
    "$template" > "$template.tmp" && mv "$template.tmp" "$template"

sed -e 's#/nix/store/[^ "]*/bin/jq#/opt/homebrew/bin/jq#g' \
    -e 's#/nix/store/[^ "]*/bin/spotctl#{{ .chezmoi.homeDir }}/go/bin/spotctl#g' \
    "$template" > "$template.tmp" && mv "$template.tmp" "$template"

# git names three commands by store path: the credential helper home-manager
# writes for gh, the ssh-keygen that signs, and the bun that reads bun.lockb,
# which the programs.bun module adds as a diff driver. Point them at what the
# work Mac has.
template=$source_dir/.chezmoitemplates/git-config
sed -e 's#/nix/store/[^ "]*/bin/gh#/opt/homebrew/bin/gh#g' \
    -e 's#/nix/store/[^ "]*/bin/ssh-keygen#/usr/bin/ssh-keygen#g' \
    -e 's#/nix/store/[^ "]*/bin/bun#/opt/homebrew/bin/bun#g' \
    "$template" > "$template.tmp" && mv "$template.tmp" "$template"

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

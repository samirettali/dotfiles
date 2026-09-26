#!/usr/bin/env bash
# Prepares a new worktree the way its repository asks. From the main checkout it
# copies the untracked files listed in .worktreeinclude (.gitignore patterns,
# the format Claude Code reads), allows the worktree's .envrc, and runs
# `make worktree` when the Makefile has that target. Output goes to stderr.
# Usage: worktree-setup [worktree directory]
set -euo pipefail
dir=$(cd "${1:-.}" && pwd -P)
main=$(dirname "$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir)")

if [[ -f $main/.worktreeinclude && $dir != "$main" ]]; then
    git -C "$main" ls-files -z --others --ignored --exclude-from="$main/.worktreeinclude" |
        while IFS= read -r -d '' file; do
            mkdir -p "$dir/$(dirname "$file")"
            cp -p "$main/$file" "$dir/$file"
            printf 'copied %s\n' "$file" >&2
        done
fi

envrc=false
if [[ -f $dir/.envrc ]] && command -v direnv >/dev/null; then
    direnv allow "$dir" >&2
    envrc=true
fi

if [[ -f $dir/Makefile ]] && make -C "$dir" -n worktree >/dev/null 2>&1; then
    if $envrc; then
        direnv exec "$dir" make -C "$dir" worktree >&2
    else
        make -C "$dir" worktree >&2
    fi
fi

#!/usr/bin/env bash
# Claude Code's WorktreeCreate and WorktreeRemove hook. Every worktree lives at
# ~/dev/.worktrees/<repo>/<name>, on a branch worktree-<name> taken from the
# checkout's HEAD, so local commits not yet pushed come along. Only the final
# path goes to stdout: Claude Code reads it as the worktree's location.
set -euo pipefail

input=$(cat)

case "${1:-}" in
create)
    name=$(jq -r .name <<<"$input")
    cwd=$(jq -r .cwd <<<"$input")
    common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir)
    repo=$(basename "$(dirname "$common")")
    dir="$HOME/dev/.worktrees/$repo/$name"
    mkdir -p "$(dirname "$dir")"
    git -C "$cwd" worktree add -b "worktree-$name" "$dir" HEAD >&2
    # A failed setup still leaves a usable checkout, so it only warns.
    "$HOME/.local/bin/worktree-setup" "$dir" >&2 ||
        printf 'worktree-setup failed in %s\n' "$dir" >&2
    printf '%s\n' "$dir"
    ;;
remove)
    dir=$(jq -r .worktree_path <<<"$input")
    branch=$(git -C "$dir" branch --show-current)
    main=$(dirname "$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir)")
    # Refuses a worktree with uncommitted changes, which keeps it on disk.
    git -C "$main" worktree remove "$dir" >&2
    # Only a merged branch goes; an unmerged one stays for me to decide.
    git -C "$main" branch -d "$branch" >&2 || true
    ;;
*)
    printf 'usage: %s create|remove < hook-input.json\n' "${0##*/}" >&2
    exit 2
    ;;
esac

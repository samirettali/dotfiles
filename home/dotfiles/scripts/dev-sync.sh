#!/usr/bin/env bash

# Pushes every repository under a root directory and rebases the ones that are
# behind. Never commits: a dirty working tree is reported, not resolved.

set -euo pipefail

usage() {
    printf 'Usage: %s [-n|--dry-run] [root]\n' "${0##*/}" >&2
    printf '\n  -n, --dry-run  report the state of every repository, change nothing\n' >&2
    printf '  root           directory holding the repositories (default: ~/dev)\n' >&2
    exit 2
}

dry_run=false
root=

while [[ $# -gt 0 ]]; do
    case $1 in
    -n | --dry-run)
        dry_run=true
        shift
        ;;
    -h | --help)
        usage
        ;;
    -*)
        printf 'Unknown option: %s\n' "$1" >&2
        usage
        ;;
    *)
        [[ -n $root ]] && usage
        root=$1
        shift
        ;;
    esac
done

root=${root:-$HOME/dev}

if [[ ! -d $root ]]; then
    printf 'Not a directory: %s\n' "$root" >&2
    exit 1
fi

if [[ -t 1 ]]; then
    green=$'\033[32m'
    yellow=$'\033[33m'
    red=$'\033[31m'
    dim=$'\033[2m'
    reset=$'\033[0m'
else
    green='' yellow='' red='' dim='' reset=''
fi

synced=0
attention=0
failed=0

# Repository names line up only if every status starts at the same column.
width=0
for path in "$root"/*/; do
    name=${path%/}
    name=${name##*/}
    ((${#name} > width)) && width=${#name}
done

report() {
    local color=$1 name=$2 message=$3
    printf '%s%-*s%s  %s%s%s\n' "$dim" "$width" "$name" "$reset" "$color" "$message" "$reset"
}

for path in "$root"/*/; do
    path=${path%/}
    name=${path##*/}

    if ! git -C "$path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        continue
    fi

    if ! branch=$(git -C "$path" symbolic-ref --quiet --short HEAD); then
        report "$yellow" "$name" "detached HEAD, skipped"
        ((attention += 1))
        continue
    fi

    if ! upstream=$(git -C "$path" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null); then
        report "$yellow" "$name" "$branch has no upstream, skipped"
        ((attention += 1))
        continue
    fi

    remote=${upstream%%/*}

    if ! git -C "$path" fetch --quiet --prune "$remote" 2>/dev/null; then
        report "$red" "$name" "fetch from $remote failed"
        ((failed += 1))
        continue
    fi

    dirty=false
    [[ -n $(git -C "$path" status --porcelain) ]] && dirty=true

    read -r behind ahead < <(git -C "$path" rev-list --left-right --count "$upstream...HEAD")

    if [[ $behind -eq 0 && $ahead -eq 0 ]]; then
        if $dirty; then
            report "$yellow" "$name" "up to date, uncommitted changes"
            ((attention += 1))
        else
            ((synced += 1))
        fi
        continue
    fi

    if $dry_run; then
        state=
        [[ $behind -gt 0 ]] && state="behind $behind"
        [[ $ahead -gt 0 ]] && state="${state:+$state, }ahead $ahead"
        $dirty && state="$state, uncommitted changes"
        report "$yellow" "$name" "$branch $state"
        ((attention += 1))
        continue
    fi

    # A rebase needs a clean tree, and a stash that conflicts on a machine
    # nobody is watching is worse than the divergence it tried to resolve.
    if [[ $behind -gt 0 ]] && $dirty; then
        report "$yellow" "$name" "$branch behind $behind, uncommitted changes, skipped"
        ((attention += 1))
        continue
    fi

    if [[ $behind -gt 0 ]]; then
        # Rebase onto the ref just fetched, not onto whatever branch.<name>.merge
        # resolves to: the two differ when the tracking config is unusual.
        if ! git -C "$path" rebase --quiet "$upstream" >/dev/null 2>&1; then
            git -C "$path" rebase --abort >/dev/null 2>&1 || true
            report "$red" "$name" "rebase onto $upstream failed, left untouched"
            ((failed += 1))
            continue
        fi
        read -r behind ahead < <(git -C "$path" rev-list --left-right --count "$upstream...HEAD")
    fi

    if [[ $ahead -eq 0 ]]; then
        report "$green" "$name" "rebased onto $upstream"
        ((synced += 1))
        continue
    fi

    if ! git -C "$path" push --quiet "$remote" "$branch" 2>/dev/null; then
        report "$red" "$name" "push to $upstream failed"
        ((failed += 1))
        continue
    fi

    pushed="pushed $ahead $([[ $ahead -eq 1 ]] && printf commit || printf commits) to $upstream"
    if $dirty; then
        report "$green" "$name" "$pushed, uncommitted changes left alone"
        ((attention += 1))
    else
        report "$green" "$name" "$pushed"
        ((synced += 1))
    fi
done

printf '\n%s%d in sync%s' "$dim" "$synced" "$reset"
[[ $attention -gt 0 ]] && printf '%s, %d need you%s' "$yellow" "$attention" "$reset"
[[ $failed -gt 0 ]] && printf '%s, %d failed%s' "$red" "$failed" "$reset"
printf '\n'

[[ $failed -eq 0 ]]

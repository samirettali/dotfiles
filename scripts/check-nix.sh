#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

files=()
while IFS= read -r -d '' file; do
    [[ -f $file && ! -L $file ]] && files+=("$file")
done < <(git ls-files --cached -z -- '*.nix' ':(exclude)machines/xps/**')

if [[ ${#files[@]} == 0 ]]; then
    printf 'No tracked Nix files to check.\n'
    exit 0
fi

case ${1:-lint} in
    fmt) alejandra "${files[@]}" ;;
    fmt-check) alejandra --check "${files[@]}" ;;
    lint)
        status=0
        deadnix --fail "${files[@]}" || status=1
        for file in "${files[@]}"; do
            statix check "$file" || status=1
        done
        exit "$status"
        ;;
    *) printf 'Usage: %s {fmt|fmt-check|lint}\n' "$0" >&2; exit 2 ;;
esac

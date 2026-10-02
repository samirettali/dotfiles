#!/usr/bin/env bash
# Update flake.lock, then write an HTML report with the changelog of every package it bumps on this host.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

host=$(hostname -s)
if [[ $(uname -s) == Darwin ]]; then
    config="f.darwinConfigurations.$host.config"
    packages="c.environment.systemPackages ++ builtins.concatMap (u: u.home.packages) (builtins.attrValues c.home-manager.users)"
else
    config="f.homeConfigurations.$host.config"
    packages="c.home.packages"
fi

snapshot() {
    nix eval --impure --json --expr "
      let
        f = builtins.getFlake (toString ./.);
        c = $config;
        # Wrappers such as neovim's keep the metadata on the package they wrap.
        entry = p: let d = builtins.parseDrvName (p.name or \"\"); u = p.unwrapped or p; in {
          name = p.pname or d.name;
          value = {
            version = p.version or d.version;
            changelog = u.meta.changelog or \"\";
            owner = u.src.owner or \"\";
            repo = u.src.repo or \"\";
            rev = u.src.rev or \"\";
            urls = builtins.filter builtins.isString [
              (u.meta.changelog or null) (u.src.url or null) (u.meta.homepage or null) (u.meta.downloadPage or null)
            ];
          };
        };
      in builtins.listToAttrs (map entry ($packages))
    " 2>/dev/null
}

escape() { sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g' <<<"$1"; }

# Every GitHub release published after the old tag, up to the new one; prereleases left out.
releases() {
    local re='^https://github\.com/([^/]+/[^/]+)/releases/tag/(.+)$'
    [[ $1 =~ $re ]] || return 1
    local repo=${BASH_REMATCH[1]} new=${BASH_REMATCH[2]}
    [[ $2 =~ $re ]] || return 1
    local old=${BASH_REMATCH[2]}
    gh api "repos/$repo/releases?per_page=100" 2>/dev/null | jq -r --arg old "$old" --arg new "$new" '
      map(select(.draft | not)) as $all
      | ($all | map(select(.tag_name == $new))[0] // error) as $latest
      | ($all | map(select(.tag_name == $old))[0].published_at) as $from
      | if $from then $all | map(select((.prerelease | not) and .published_at > $from and .published_at <= $latest.published_at))
        else [$latest] end
      | sort_by(.published_at) | reverse[]
      | "## \(.tag_name)\n\n\(.body // "")\n"
    ' 2>/dev/null
}

# The CHANGELOG.md entries from the new version's heading down to the old one's.
changelog_file() {
    [[ $1 =~ ^https://github\.com/([^/]+/[^/]+)/blob/([^/]+)/(.+)$ ]] || return 1
    local text
    text=$(gh api -H 'Accept: application/vnd.github.raw' "repos/${BASH_REMATCH[1]}/contents/${BASH_REMATCH[3]}?ref=${BASH_REMATCH[2]}" 2>/dev/null) || return 1
    awk -v from="${2//./[.]}" -v to="${3//./[.]}" '
      function heading(version) { return $0 ~ "^#+ (.*[^0-9.])?" version "([^0-9.]|$)" }
      heading(from) { found = started; exit }
      heading(to) { started = 1 }
      started { entries = entries $0 "\n" }
      END { if (!found) exit 1; printf "%s", entries }
    ' <<<"$text"
}

# The commits between two refs of a GitHub repository, merges left out.
# Without source revisions, the refs are the versions, as tags with or without a v or as commits.
commits() {
    [[ -n $1 && -n $2 && -n $3 ]] || return 1
    gh api "repos/$1/compare/$2...$3" --jq '
      .commits[] | select(.parents | length == 1)
      | "- [`\(.sha[:7])`](\(.html_url)) \(.commit.message | split("\n")[0])"
    ' 2>/dev/null
}

old=$(snapshot) || old=
# Authenticate nix's GitHub API calls, which are otherwise limited to 60 an hour.
if token=$(gh auth token 2>/dev/null); then
    NIX_CONFIG="access-tokens = github.com=$token" nix flake update
else
    nix flake update
fi
new=$(snapshot) || new=

if [[ -z $old || -z $new ]]; then
    printf 'changelog unavailable: the configuration did not evaluate\n' >&2
    exit 0
fi

report=${XDG_CACHE_HOME:-$HOME/.cache}/flake-update/$(date +%Y-%m-%d-%H%M%S).html
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

jq -r -n --argjson old "$old" --argjson new "$new" '
  $new | to_entries[]
  | select($old[.key] and $old[.key].version != .value.version)
  | [.key, $old[.key].version, .value.version, $old[.key].changelog, .value.changelog,
     .value.owner, .value.repo, $old[.key].rev, .value.rev,
     ([.value.urls[] | capture("^https://github\\.com/(?<r>[^/]+/[^/#?]+)").r | sub("\\.git$"; "")][0] // "")] | join("\u001f")
' | sort | while IFS=$'\x1f' read -r name from to old_changelog changelog owner repo old_rev rev github; do
    printf '%s: %s -> %s\n' "$name" "$from" "$to"
    link=$changelog
    # A source fetched as a flake input, such as neovim's, has a revision but no owner or repo.
    source=${owner:+$owner/$repo}
    source=${source:-$github}
    if md=$(releases "$changelog" "$old_changelog") || md=$(changelog_file "$changelog" "$from" "$to"); then
        :
    elif [[ -n $source ]] && md=$(commits "$source" "$old_rev" "$rev"); then
        link=https://github.com/$source/compare/$old_rev...$rev
    elif [[ -n $github ]] && md=$(commits "$github" "v$from" "v$to"); then
        link=https://github.com/$github/compare/v$from...v$to
    elif [[ -n $github ]] && md=$(commits "$github" "$from" "$to"); then
        link=https://github.com/$github/compare/$from...$to
    else
        md=
    fi

    id=$(printf '%s' "$name" | tr -c 'A-Za-z0-9_-' -)
    printf '<li><a href="#%s"><span>%s</span><small>%s → %s</small></a></li>\n' \
        "$id" "$(escape "$name")" "$(escape "$from")" "$(escape "$to")" >>"$work/index"
    {
        printf '<section id="%s">\n<h2>%s</h2>\n<p class="versions">%s → %s' \
            "$id" "$(escape "$name")" "$(escape "$from")" "$(escape "$to")"
        [[ -n $link ]] && printf ' · <a href="%s">Source</a>' "$(escape "$link")"
        printf '</p>\n'
        if [[ -n $md ]]; then
            printf '<div class="notes">\n'
            jq -n --arg text "$md" \
                '{text: $text, mode: "markdown"}' |
                gh api markdown --input - 2>/dev/null || printf '<pre>%s</pre>' "$(escape "$md")"
            printf '</div>\n'
        else
            printf '<p class="empty">No changelog available.</p>\n'
        fi
        printf '</section>\n'
    } >>"$work/sections"
done

if [[ ! -s $work/index ]]; then
    printf 'No package changed.\n'
    exit 0
fi

mkdir -p "$(dirname "$report")"
{
    cat <<HTML
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Flake update · $host · $(date '+%Y-%m-%d %H:%M')</title>
<style>
:root { color-scheme: light dark; --muted: #6b6b6b; --line: #e3e3e3; --code: #f4f4f4; }
@media (prefers-color-scheme: dark) { :root { --muted: #9a9a9a; --line: #333; --code: #1e1e1e; } }
* { box-sizing: border-box; }
body { margin: 0; font: 15px/1.55 system-ui, sans-serif; }
a { color: LinkText; }
.layout { display: grid; grid-template-columns: 18rem minmax(0, 46rem); gap: 3rem; padding: 2rem; }
nav { padding-right: .75rem; position: sticky; top: 2rem; align-self: start; max-height: calc(100vh - 4rem); overflow-y: auto; }
nav h1 { font-size: 1rem; margin: 0 0 .25rem; }
nav p { margin: 0 0 1rem; color: var(--muted); font-size: .85rem; }
nav ul { list-style: none; margin: 0; padding: 0; }
nav a { display: flex; justify-content: space-between; gap: .75rem; padding: .3rem 0; text-decoration: none; color: inherit; }
nav a:hover span { text-decoration: underline; }
nav small, .versions { color: var(--muted); font-variant-numeric: tabular-nums; }
nav small { text-align: right; overflow-wrap: anywhere; }
section { padding-bottom: 2rem; margin-bottom: 2rem; border-bottom: 1px solid var(--line); scroll-margin-top: 2rem; }
section h2 { margin: 0; font-size: 1.35rem; }
.versions { margin: .25rem 0 1rem; }
.empty { color: var(--muted); }
.notes { overflow-wrap: anywhere; }
.notes h1, .notes h2, .notes h3, .notes h4 { font-size: 1rem; margin: 1.5rem 0 .5rem; }
.notes img { max-width: 100%; height: auto; }
.notes pre, .notes code { background: var(--code); border-radius: 4px; font-size: .9em; }
.notes code { padding: .1em .3em; }
.notes pre { padding: .75rem; overflow-x: auto; }
.notes pre code { padding: 0; }
.notes table { border-collapse: collapse; display: block; overflow-x: auto; }
.notes th, .notes td { border: 1px solid var(--line); padding: .3rem .6rem; }
@media (max-width: 52rem) { .layout { grid-template-columns: 1fr; gap: 2rem; } nav { position: static; max-height: none; } }
</style>
</head>
<body>
<div class="layout">
<nav>
<h1>Flake update</h1>
<p>$host · $(date '+%Y-%m-%d %H:%M') · $(wc -l <"$work/index" | tr -d ' ') packages</p>
<ul>
HTML
    cat "$work/index"
    printf '</ul>\n</nav>\n<main>\n'
    cat "$work/sections"
    printf '</main>\n</div>\n</body>\n</html>\n'
} >"$report"
printf '\nChangelog: file://%s\n' "$report"

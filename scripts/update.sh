#!/usr/bin/env bash
# Update flake.lock, then write an HTML report with the commits of every package it bumps on this host.
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

# The repository and ref a GitHub changelog URL points at, such as a release tag.
ref() {
    [[ $1 =~ ^https://github\.com/([^/]+/[^/]+)/(releases/tag|blob|tree|commits)/([^/]+) ]] || return 1
    printf '%s %s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[3]}"
}

# The commits between two refs of a GitHub repository as JSON lines, newest first, merges left out.
commits() {
    [[ -n $1 && -n $2 && -n $3 && $2 != "$3" ]] || return 1
    local pages
    pages=$(gh api --paginate "repos/$1/compare/$2...$3?per_page=100" --jq '
      .commits[] | select(.parents | length == 1)
      | {sha, url: .html_url, subject: ((.commit.message | sub("\r"; "") | split("\n")[0]) // "")}
    ' 2>/dev/null) || return 1
    jq -c -s 'reverse[]' <<<"$pages"
}

# Sets list and link from the first pair of refs GitHub can compare.
compare() {
    list=$(commits "$1" "$2" "$3") && link=https://github.com/$1/compare/$2...$3
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
    # A source fetched as a flake input, such as neovim's, has a revision but no owner or repo.
    source=${owner:+$owner/$repo}
    source=${source:-$github}
    read -r tag_repo new_tag < <(ref "$changelog") || true
    read -r _ old_tag < <(ref "$old_changelog") || true
    compare "$source" "$old_rev" "$rev" ||
        compare "$tag_repo" "$old_tag" "$new_tag" ||
        compare "$github" "v$from" "v$to" ||
        compare "$github" "$from" "$to" ||
        { list='' link=''; }

    id=$(printf '%s' "$name" | tr -c 'A-Za-z0-9_-' -)
    printf '<li><a href="#%s"><span>%s</span><small>%s → %s</small></a></li>\n' \
        "$id" "$(escape "$name")" "$(escape "$from")" "$(escape "$to")" >>"$work/index"
    {
        printf '<section id="%s" data-title="%s %s → %s">\n<h2><label><input type="checkbox" class="all">%s</label></h2>\n<p class="versions">%s → %s' \
            "$id" "$(escape "$name")" "$(escape "$from")" "$(escape "$to")" "$(escape "$name")" "$(escape "$from")" "$(escape "$to")"
        [[ -n $link ]] && printf ' · <a href="%s">Compare</a>' "$(escape "$link")"
        printf '</p>\n'
        if [[ -n $list ]]; then
            printf '<ul class="commits">\n'
            jq -r '"<li><label><input type=\"checkbox\" data-url=\"\(.url | @html)\" data-subject=\"\(.subject | @html)\"><a href=\"\(.url | @html)\"><code>\(.sha[:7])</code></a><span>\(.subject | @html)</span></label></li>"' <<<"$list"
            printf '</ul>\n'
        else
            printf '<p class="empty">No commits available.</p>\n'
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
:root { color-scheme: light dark; --muted: #6b6b6b; --line: #e3e3e3; }
@media (prefers-color-scheme: dark) { :root { --muted: #9a9a9a; --line: #333; } }
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
section h2 label, .commits label { display: grid; grid-template-columns: 1rem auto 1fr; gap: .6rem; align-items: baseline; }
section h2 label { grid-template-columns: 1rem 1fr; cursor: pointer; }
input[type=checkbox] { margin: 0; justify-self: start; }
.commits { list-style: none; margin: 0; padding: 0; }
.commits label { padding: .15rem 0; cursor: pointer; overflow-wrap: anywhere; }
.commits code { font: .85em ui-monospace, monospace; font-variant-numeric: tabular-nums; }
.commits a { color: var(--muted); }
.actions { display: flex; gap: .5rem; margin: 0 0 1rem; }
.actions button { font: inherit; font-size: .85rem; padding: .2rem .6rem; }
@media (max-width: 52rem) { .layout { grid-template-columns: 1fr; gap: 2rem; } nav { position: static; max-height: none; } }
</style>
</head>
<body>
<div class="layout">
<nav>
<h1>Flake update</h1>
<p>$host · $(date '+%Y-%m-%d %H:%M') · $(wc -l <"$work/index" | tr -d ' ') packages</p>
<div class="actions"><button id="clear" disabled>Clear</button><button id="copy" disabled>Copy</button></div>
<ul>
HTML
    cat "$work/index"
    printf '</ul>\n</nav>\n<main>\n'
    cat "$work/sections"
    cat <<'HTML'
</main>
</div>
<script>
// Copies the selected commits as one block per package, for pasting to an agent.
const commits = [...document.querySelectorAll('main input[data-url]')];
const copy = document.getElementById('copy');
const clear = document.getElementById('clear');
const selected = () => commits.filter((box) => box.checked);

function refresh() {
  for (const section of document.querySelectorAll('main section')) {
    const all = section.querySelector('.all');
    const boxes = [...section.querySelectorAll('input[data-url]')];
    const checked = boxes.filter((box) => box.checked).length;
    all.disabled = boxes.length === 0;
    all.checked = boxes.length > 0 && checked === boxes.length;
    all.indeterminate = checked > 0 && checked < boxes.length;
  }
  const count = selected().length;
  copy.textContent = count ? `Copy ${count} commit${count === 1 ? '' : 's'}` : 'Copy';
  copy.disabled = clear.disabled = count === 0;
}

function text() {
  return [...document.querySelectorAll('main section')]
    .map((section) => {
      const lines = [...section.querySelectorAll('input[data-url]:checked')]
        .map((box) => `- ${box.dataset.url} ${box.dataset.subject}`);
      return lines.length ? `${section.dataset.title}\n${lines.join('\n')}` : '';
    })
    .filter(Boolean)
    .join('\n\n');
}

document.querySelector('main').addEventListener('change', (event) => {
  if (event.target.classList.contains('all')) {
    for (const box of event.target.closest('section').querySelectorAll('input[data-url]')) box.checked = event.target.checked;
  }
  refresh();
});

let copied;
copy.addEventListener('click', async () => {
  try {
    await navigator.clipboard.writeText(text());
    copy.textContent = 'Copied';
  } catch {
    copy.textContent = 'Copy failed';
  }
  clearTimeout(copied);
  copied = setTimeout(refresh, 1500);
});

clear.addEventListener('click', () => {
  for (const box of commits) box.checked = false;
  refresh();
});

refresh();
</script>
</body>
</html>
HTML
} >"$report"
printf '\nChangelog: file://%s\n' "$report"

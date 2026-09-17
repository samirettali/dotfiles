# Rendering the work Mac's configuration

`settali` cannot run nix, so its configuration is a copy of the one nix builds
for `mbp`. `make chezmoi` runs `home/dotfiles/scripts/chezmoi-render.sh`, which
copies that configuration into `chezmoi/`. Run it on `mbp`, commit the result,
then `chezmoi apply` on `settali`.

The source is the built file tree, not `$HOME`:

```sh
nix build .#darwinConfigurations.mbp.config.home-manager.users.samir.home-files
```

A render therefore needs no activation, runs on any Mac and in CI, and cannot
pick up a file edited by hand that nix does not own — which is how the herdr
configuration drifted.

## Adding a file to the render

The script carries three lists, and a file belongs to exactly one of them.

- `files` — copied as it is. Use this when the rendered file is already correct
  for the work Mac. An entry may be `built:target` where the name in the built
  tree is not the name the work Mac wants.
- `directories` — copied with `rsync --delete`, so anything the render does not
  produce is removed. Name the exceptions in `skipped`: files written by hand
  for the work Mac, the templates that replace a copied file, and the plugin
  lock, since the work Mac resolves its own plugin versions.
- `templates` — copied into `.chezmoitemplates/<name>` instead of the target.
  Use this when the file needs a value from the machine: the matching
  `chezmoi/**/<file>.tmpl` pulls it in with `includeTemplate` and edits it.

The render then fails, on purpose, if a listed path is not in the built tree, or
if any rendered file mentions `/nix/store` — a store path is useless on a
machine without nix.

## What a template fixes up

The export is built for `mbp`, so it carries that home directory and that
identity. `dot_config/git/config.tmpl` shows both corrections:

```gotemplate
{{- includeTemplate "git-config" .
      | replace "/Users/samir/" (printf "%s/" .chezmoi.homeDir)
      | replace "samir@ettali.com" "s.ettali@young.business" -}}
```

Work-only additions go in the same template, guarded by the profile, so the
target stays a copy of what nix builds — see `dot_config/git/ignore.tmpl` and
`dot_config/nvim/lua/plugins/init.lua.tmpl`.

## Leaving out what the work Mac has not got

A binding the work Mac cannot run has to go before the store-path check reads
the file, so the render drops it in the script rather than in the template:
`sottomano-keymap.json` loses `hooks` and the `links` and `vault` entries, and
with them every mention of rbw, curl and sketchybar. What is left the template
edits — the browser to launch, the email to type.

## What the render does not reach

- `.claude/CLAUDE.md` and `.codex/AGENTS.md` are chezmoi templates built from
  `.chezmoitemplates/agents-md`, which `include`s `home/packages/ai/agents.md`
  out of the source tree at apply time. Nothing to render: an edit there reaches
  the work Mac on the next `chezmoi apply`.
- Everything under `.pi` stays on `mbp`.
- `.statusLine` is stripped from the Claude settings: it points at a script nix
  builds, which the work Mac has not got.

---
name: add-skill
description: Add an Agent Skill (SKILL.md) from a GitHub repo to this dotfiles repo so it's installed for all coding agents (Claude Code, Codex, pi). Use when the user asks to add/install a skill, points at a skill repo, or says something like "configure <repo> skill".
---

# Add a skill to the dotfiles

Skills in this repo are pinned as **flake inputs** and exposed to every coding
agent through one shared list. `nix flake update` keeps them current. This skill
walks through adding a new one end-to-end.

## How skills are wired here

- `flake.nix` — each skill source is a `flake = false` input (`github:owner/repo`).
  `inputs` is threaded into home-manager modules via `extraSpecialArgs`.
- `home/packages/shell/coding-agent-skills.nix` — the single source of truth:
  `{inputs}: { <name> = "<dir-with-SKILL.md>"; }`. Every agent imports it:
  - Claude Code: `programs.claude-code.skills` (`home/packages/shell/claude-code.nix`)
  - Codex: `programs.codex.skills` (`home/packages/dev/default.nix`)
  - pi: symlinked into `~/.pi/agent/skills/<name>` (`home/packages/shell/pi-coding-agent/default.nix`)

So adding a skill = add one input + add one line to the shared list.

## Steps

1. **Locate / fetch the repo to inspect its structure.** Derive the repo dir name
   from `owner/repo` (the repo part). Check `/tmp/<repo>` first; clone only if missing:
   ```
   test -d /tmp/<repo> || git clone https://github.com/<owner>/<repo> /tmp/<repo>
   ```

2. **Find the skill(s).** Locate every `SKILL.md` and read its frontmatter `name`:
   ```
   find /tmp/<repo> -name SKILL.md -not -path '*/.git/*'
   ```
   - The **attr name** in the shared list = the skill's frontmatter `name:` (this
     becomes the installed dir `~/.claude/skills/<name>`).
   - The **value** = the path to the directory containing that `SKILL.md`, relative
     to the repo root, as `"${inputs.<input>}/<rel-dir>"`. If `SKILL.md` is at the
     repo root, the value is just `"${inputs.<input>}"`.

3. **Pick which to install.**
   - Exactly one `SKILL.md` → use it, no need to ask.
   - More than one → ask the user whether they want **one** (which?), **many** (which?),
     or **all** of them.

4. **Add the flake input.** In `flake.nix`, alongside the other `flake = false`
   inputs, add:
   ```nix
   <input> = {
     url = "github:<owner>/<repo>";
     flake = false;
   };
   ```
   Use the repo name (or skill name) as `<input>`.

5. **Lock it:** `nix flake lock` (adds the input to `flake.lock` at the current HEAD).

6. **Add to the shared list** in `home/packages/shell/coding-agent-skills.nix`,
   one entry per chosen skill:
   ```nix
   <name> = "${inputs.<input>}/<rel-dir>";
   ```

7. **Make new/edited files visible to the flake.** The flake reads the git tree,
   so any *new* file must be staged or Nix won't see it: `git add -N <file>`
   (`flake.nix` and `coding-agent-skills.nix` are already tracked).

8. **Verify it resolves for every agent** (should all print the same store path):
   ```
   nix eval --json '.#darwinConfigurations.mbp.config.home-manager.users.samir.programs.claude-code.skills'
   nix eval --json '.#darwinConfigurations.mbp.config.home-manager.users.samir.programs.codex.skills'
   nix eval --raw '.#darwinConfigurations.mbp.config.home-manager.users.samir.home.file' \
     --apply 'f: f.".pi/agent/skills/<name>".source'
   ```

9. **Format** any edited `.nix` files with `alejandra -q <files>`.

## Apply (tell the user; don't run unprompted)

```
nix run nix-darwin -- switch --flake .#mbp
```

Update later with `nix flake update <input>` (one) or `nix flake update` (all).

## Notes

- Do **not** run `npx skills add ...` — that writes into `~/.claude/skills/`
  imperatively and conflicts with the declarative setup here.
- Don't flip an agent's `enable` flag just to install a skill; ask first.
- Only ask the user a question when step 3 is genuinely ambiguous (multiple skills).

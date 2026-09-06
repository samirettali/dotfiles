# Manual skill invocation

Nine skills require explicit invocation rather than automatic discovery:

- `autoresearch-create`, `autoresearch-finalize`, `autoresearch-hooks`
- `generate-music`, `generate-speech`
- `live-ui-variants`, `show-me`, `neovim`, `remotion-best-practices`

In pi, `disable-model-invocation: true` removes the name and description from
the model's skill catalog. The skill remains available through `/skill:name`.
Its full instructions still load when invoked. This does not remove content
already read into a conversation or hide an extension's tools and commands.

The six shared skills also carry `policy.allow_implicit_invocation: false`
in `agents/openai.yaml` for Codex. The SKILL.md flag covers pi and Claude Code;
other agents may ignore these fields. Manual invocation is not an access-control
boundary.

## Where the policy lives

Repository-owned skills declare it in their own metadata. Imported `neovim`,
`show-me`, and `remotion-best-practices` skills pass through `manualSkill` in
`home/packages/ai/coding-agent-skills.nix`. That builder preserves their bodies,
support files, and existing Codex metadata while setting both fields.

Autoresearch stays a pi-only package. Its wrapper in
`home/packages/ai/pi-coding-agent/default.nix` patches the three skill headers,
not the manifest, extension, or support files. Filtering the skills out of the
package would also remove their slash commands, which is not the desired behavior.

After `make build`, use `/reload` or start a new pi session. Verify that the
nine skills remain discoverable as commands but not in `formatSkillsForPrompt`.
All other skills retain their existing invocation policy.

## X search in pi

Pi excludes the shared `x-search` skill because its native `x_search` tool uses
pi's xAI credentials and carries the search guidance itself. Claude Code and
Codex keep the CLI skill. Keep the tool and CLI aligned on the model, handle
limit, retry policy, citation cleanup, and usage reporting.

Run `node --test tests/x-search.test.mjs` with the installed pi runtime to test
the extension against mocked responses without paid searches.

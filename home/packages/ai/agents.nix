{vars, ...}: let
  content =
    builtins.readFile ./agents.md
    + ''

      ## This machine

      ${builtins.readFile ./machines/${vars.hostname}.md}'';
in {
  home.file = {
    ".claude/CLAUDE.md".text = content;
    ".codex/AGENTS.md".text = content;
    ".pi/agent/AGENTS.md".text = content;
  };
}

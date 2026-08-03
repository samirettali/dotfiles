_: let
  content = builtins.readFile ./agents.md;
in {
  # Claude Code reads CLAUDE.md, not AGENTS.md.
  home.file = {
    ".claude/CLAUDE.md".text = content;
    ".codex/AGENTS.md".text = content;
    ".pi/agent/AGENTS.md".text = content;
  };
}

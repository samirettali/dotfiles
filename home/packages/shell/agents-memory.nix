{...}: let
  memory = ./agents-memory.md;
in {
  # Claude Code reads CLAUDE.md, not AGENTS.md.
  home.file = {
    ".claude/CLAUDE.md".source = memory;
    ".codex/AGENTS.md".source = memory;
    ".pi/agent/AGENTS.md".source = memory;
  };
}

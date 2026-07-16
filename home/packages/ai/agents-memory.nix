{config, ...}: let
  base = builtins.readFile ./agents-memory.md;
  content = base + config.dotfiles.agentsMemory.extra;
in {
  # Claude Code reads CLAUDE.md, not AGENTS.md.
  home.file = {
    ".claude/CLAUDE.md".text = content;
    ".codex/AGENTS.md".text = content;
    ".pi/agent/AGENTS.md".text = content;
  };
}

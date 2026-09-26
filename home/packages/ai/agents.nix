{vars, ...}: let
  content =
    builtins.readFile ./agents.md
    + ''

      ${builtins.readFile ./personal.md}
      ${builtins.readFile ./projects.md}
      ## This machine

      ${builtins.readFile ./machines/${vars.hostname}.md}'';
in {
  home.file = {
    ".claude/CLAUDE.md".text = content;
    ".codex/AGENTS.md".text = content;
    ".pi/agent/AGENTS.md".text = content;
    # Named by absolute path in agents.md and in Claude Code's worktree hook.
    ".local/bin/worktree-setup" = {
      source = ./worktree-setup.sh;
      executable = true;
    };
  };
}

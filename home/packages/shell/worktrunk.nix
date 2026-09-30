{...}: {
  programs.worktrunk = {
    enable = true;
    settings = {
      # The same layout as Claude Code's worktree hook.
      worktree-path = "~/dev/.worktrees/{{ repo }}/{{ branch | sanitize }}";
      pre-start.setup = "~/.local/bin/worktree-setup {{ worktree_path }}";
    };
  };
}

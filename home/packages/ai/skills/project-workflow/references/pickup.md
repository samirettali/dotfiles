# Picking up an issue

1. Read the issue **with its comments** — the real context is often there, not in
   the body:

   ```sh
   gh issue view <N> --repo samirettali/<repo> --comments
   ```

2. Read the project's `AGENTS.md`. Use the docs index to locate relevant
   guidance; read journal entries only when the issue depends on that history.
3. Create a worktree on a new `issue-<N>-<slug>` branch.
4. Move the issue to `🏗 In progress`.
5. Investigate apparent ambiguity against the current code and issue discussion;
   an old issue may describe a problem that has since changed. Ask about unresolved
   requirements or conflicting intent, and continue independent, unblocked work.

## Worktree bootstrap

A worktree carries only the tracked files:

- run `make worktree` if the repo has that target — it is the repo's own bootstrap;
- otherwise symlink what cannot be regenerated (`.env`, local config), regenerate
  what can (`pnpm install`), and **ask** about live state, like a local database:
  copying it forks it, sharing it means two processes on one file.

With two worktrees open the default port is taken, so bind another one and **say
which URL you bound**.

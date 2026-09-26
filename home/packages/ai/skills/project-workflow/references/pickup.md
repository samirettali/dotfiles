# Picking up an issue

1. Read the issue **with its comments** — the real context is often there, not in
   the body:

   ```sh
   gh issue view <N> --repo samirettali/<repo> --comments
   ```

2. Read the project's `AGENTS.md`. Use the docs index to locate relevant
   guidance; read journal entries only when the issue depends on that history.
3. Create a worktree at `~/dev/.worktrees/<repo>/issue-<N>-<slug>`, on a new
   `issue-<N>-<slug>` branch.
4. Move the issue to `🏗 In progress`.
5. Investigate apparent ambiguity against the current code and issue discussion;
   an old issue may describe a problem that has since changed. Ask about unresolved
   requirements or conflicting intent, and continue independent, unblocked work.

## Worktree bootstrap

A worktree carries only the tracked files. `~/.local/bin/worktree-setup <dir>`
fills in what the repo declares: it copies the untracked files listed in
`.worktreeinclude`, allows the `.envrc`, and runs `make worktree` if the repo has
that target. Claude Code's worktree tool runs it already; after `git worktree add`,
run it yourself.

For anything the repo does not declare, regenerate what can be regenerated
(`pnpm install`) and **ask** about live state, like a local database: copying it
forks it, sharing it means two processes on one file.

With two worktrees open the default port is taken, so bind another one and **say
which URL you bound**.

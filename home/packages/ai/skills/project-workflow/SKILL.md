---
name: project-workflow
description: Work on tasks tracked as GitHub issues in Samir's personal repos — pick up an issue, open a new one, close it with a PR. Use when asked to work on an issue or a task, to open an issue for something found along the way, or to check what is pending on a project.
---

# Project workflow

Tasks for personal projects are **GitHub issues**, collected in the `dev` Project
(<https://github.com/users/samirettali/projects/1>). Repos live under
`samirettali/`, local checkouts in `~/dev/<repo-name>`.

`Priority` (P0–P3) and `Status` are **Project fields**, not labels.

## Statuses

**Never decide `Priority` on your own**: Samir does the triage. If he tells you
what it should be, set it.


`📋 Backlog` → `🏗 In progress` → `👀 In review` → `✅ Done`

Backlog and Done are automatic (Project workflows: *item added* and *pull request
merged* / *item closed*). The two middle transitions are yours to make:

```sh
gh project item-edit 1 --owner samirettali \
  --url https://github.com/samirettali/<repo>/issues/<N> \
  --field Status --value "🏗 In progress"
```

The value is the option's **exact name, emoji included**: `"In progress"` is
rejected. That is not a trap, though — the error lists every valid option, so a
wrong one corrects itself.

`--owner` selects the *Project*, not the repo: the issue is named by its URL and
may live under a different owner.

Verified on gh 2.97.

## Picking up an issue

1. Read the issue **with its comments** — the real context is often there, not in
   the body:

   ```sh
   gh issue view <N> --repo samirettali/<repo> --comments
   ```

2. Read the project context: `AGENTS.md`, the `docs/` index, and `JOURNAL.md` if
   it exists.
3. Create a worktree on a new `issue-<N>-<slug>` branch and work there (see
   [Worktrees](#worktrees)).
4. Move the issue to `🏗 In progress` (see [Statuses](#statuses)).
5. If anything in the issue does not add up or is ambiguous, **ask before writing
   code**. An issue written months ago may describe a problem that has since
   changed.

## Opening an issue

1. Search for duplicates first:

   ```sh
   gh issue list --repo samirettali/<repo> --search "<keywords>" --state all
   ```

2. Write a **self-sufficient** description. The reader is someone — or some agent
   — picking it up cold months later, with no memory of how it surfaced:

   - what is wrong
   - **where**: file and function, with the snippet when it helps
   - why it matters, in concrete terms
   - what the fix looks like — and if you don't know, say it needs investigating
     rather than inventing a plausible cause
   - what to verify afterwards
   - which docs need updating when it lands

3. Always pass the Project explicitly, don't rely on auto-add (the Free plan
   allows a single auto-add workflow, on a single repo):

   ```sh
   gh issue create --repo samirettali/<repo> --project "dev" \
     --title "<title>" --body "<body>"
   ```

4. The new issue lands in `📋 Backlog` by itself. Do not set `Priority`.

## Closing

1. If behaviour changed, update the docs **in the same PR**. A doc deferred to a
   later PR is a doc that falls behind.
2. Open the PR with the reference that closes the issue:

   ```sh
   gh pr create --title "<title>" --body "Closes #<N>

   <what changes and how it was verified>"
   ```

3. Move the issue to `👀 In review` (see [Statuses](#statuses)).
4. Watch the checks: `gh pr checks <N>`. On a failure, `gh run view <run-id>
   --log-failed` prints the logs of the failed steps only.
5. Do not close the issue by hand, and do not set it to `✅ Done`: the merge takes
   care of it.

## Documentation

- `AGENTS.md` stays **thin**: what the project is, commands, conventions, and a
  one-line index entry per `docs/` page.
- Everything else lives in `docs/`, versioned alongside the code. No wiki: it
  lives in a separate repo, skips review, and its links into the code break
  silently.

## Worktrees

Work in a worktree, outside the repo, so the main checkout stays on `main`.
`EnterWorktree` does it on Claude Code, `git worktree add` everywhere else.

A worktree carries only the tracked files, so:

- run `make worktree` if the repo has that target — it is the repo's own bootstrap;
- otherwise symlink what cannot be regenerated (`.env`, local config), regenerate
  what can (`pnpm install`), and **ask** about live state, like a local database:
  copying it forks it, sharing it means two processes on one file;
- on dotfiles there is nothing to carry, but `direnv allow` the new directory, and
  remember that a new file is invisible to the flake until `git add -N`.

Run your own processes there, and **never touch a process you did not start** —
it is probably his. With two worktrees open the default port is taken, so bind
another one and **say which URL you bound**.

Samir does not need the branch in his own checkout to look at the work: the
worktree is a directory, he can enter it. Git refuses the same branch in two
worktrees anyway.

## Notes

- TODOs in the code stay in the code. If you turn one into an issue, cite file and
  line in the issue and **do not remove the comment** unless asked.

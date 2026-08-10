---
name: project-workflow
description: Work on tasks tracked as GitHub issues in Samir's personal repos — pick up an issue, open a new one, close it with a PR. Use when asked to work on an issue or a task, to open an issue for something found along the way, or to check what is pending on a project.
---

# Project workflow

Tasks for personal projects are **GitHub issues**, collected in the `dev` Project
(<https://github.com/users/samirettali/projects/1>). Repos live under
`samirettali/`, local checkouts in `~/dev/<repo-name>`.

`Priority` (P0–P3) and `Status` are **Project fields**, not labels.

## Language

**Everything written into the repo is in English**: issue titles and bodies, issue
comments, PR titles and descriptions, commit messages, `AGENTS.md` and `docs/`,
and code comments. This holds regardless of the language of the conversation.
Only an explicit request for another language changes it.

**Never decide `Priority` on your own**: Samir does the triage. If he tells you
what it should be, set it.

## Statuses

`📋 Backlog` → `🏗 In progress` → `👀 In review` → `✅ Done`

Backlog and Done are automatic (Project workflows: *item added* and *pull request
merged* / *item closed*). The two middle transitions are yours to make:

```sh
ITEM=$(gh project item-list 1 --owner samirettali --format json \
  | jq -r '.items[] | select(.content.number == <N>
      and (.content.repository | test("/<repo>$"))) | .id')

gh project item-edit --project-id PVT_kwHOALClx84AFfr4 --id "$ITEM" \
  --field-id PVTSSF_lAHOALClx84AFfr4zgDKqo8 \
  --single-select-option-id <OPTION>
```

`<OPTION>`: `In progress` = `4ddd38ae`, `In review` = `f78a3bae`.

The IDs above are hardcoded because `item-edit` does not accept names. If they
ever stop working — Project or field recreated — look them up again with:

```sh
gh project field-list 1 --owner samirettali --format json
```

## Picking up an issue

1. Read the issue **with its comments** — the real context is often there, not in
   the body:

   ```sh
   gh issue view <N> --repo samirettali/<repo> --comments
   ```

2. Read the project context: `AGENTS.md`, the `docs/` index, and `JOURNAL.md` if
   it exists.
3. Create a dedicated branch: `git switch -c issue-<N>-<slug>`.
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
4. Do not close the issue by hand, and do not set it to `✅ Done`: the merge takes
   care of it.

## Documentation

- `AGENTS.md` stays **thin**: what the project is, commands, conventions, and a
  one-line index entry per `docs/` page.
- Everything else lives in `docs/`, versioned alongside the code. No wiki: it
  lives in a separate repo, skips review, and its links into the code break
  silently.

## Notes

- TODOs in the code stay in the code. If you turn one into an issue, cite file and
  line in the issue and **do not remove the comment** unless asked.
- Worktrees are handled manually for now: they are not part of this flow.

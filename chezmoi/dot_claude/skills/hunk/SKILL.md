---
name: hunk
description: Work with a live Hunk diff review session. Use when the user reviewed a diff in Hunk and left notes, asks you to look at what they marked, or wants you to walk them through a changeset with inline comments and highlights.
---

# Hunk

## Read the official skill first

The binary ships a skill that is the authority on `hunk session` syntax:

```sh
hunk skill path
```

The rest of this file is only what that skill does not say.

## Picking up the user's notes

The user drops notes on the exact lines they mean. Those notes are the request.

```sh
hunk session comment list --repo . --type user --json
```

Always `--json`: the text renderer prints the hunk and drops the line. Each note carries
`filePath` and `newRange`, a `[first, last]` pair that spans several lines when the user
selected a range. A note with `parentId` is a reply in a thread, not a new request: read it
with its parent.

Notes do not follow the code. Every edit above a note leaves it pointing at the old line
number, with or without `reload` or `--watch`. So:

1. Read every note and resolve each one to the code it points at, before editing anything.
2. Edit from the bottom of the file upwards when several notes share a file.
3. Reply to each note as you handle it, from the line it was left on:

   ```sh
   hunk session comment add --repo . --reply-to <noteId> --summary "..."
   ```

There is no resolved state. A reply is how a note gets closed; the thread stays under the
user's note. `comment rm` deletes a user note silently and for good: only when asked.

Report each change in chat by file and line. The user is looking at the diff.

## Steering the user's view

`navigate --comment <id>` accepts only agent comments. To reach a user note use its line,
or step through notes in order:

```sh
hunk session navigate --repo . --file <path> --new-line <n>
hunk session navigate --repo . --next-comment
```

`highlight add` takes character offsets into the line, 0-based, end exclusive. Compute
them from the line read from the file rather than by eye, and `highlight clear` before
moving to the next topic.

## What bites

- **`session list` reports `comments: 0` while user notes exist.** That count is agent
  comments only. Trust `comment list --type user`.
- **`--author user` does not make a user note.** It lands as `source: agent`, so the read
  path cannot be tested from the CLI. Ask the user to leave a real note.
- **Notes die with the session.** Closing Hunk discards them, the user's included. Read
  them before asking the user to relaunch, with `--watch` or otherwise.

## Related

**code-review** covers how to word findings once you have them.

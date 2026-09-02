---
name: herdr
description: Drive the Herdr terminal workspace from an agent — split a pane, run a long-lived process next to yourself, read what another pane printed, send keys to it, close it again. Use when something has to keep running while you carry on (a dev server, a browser with a debug port, a build), or when you need to see or steer another pane. Triggers on herdr, pane, split, tab, terminal workspace, "run this in another pane", "keep it running", "read the output of", "send keys to". For talking to other *agents* rather than panes, use agent-messaging.
---

# Driving Herdr

## Read the official skill first

The installed binary ships its own skill, and it is the authority on syntax:

```sh
herdr --skill
```

Read it before running anything. Do not take command syntax from memory or from this file
— a pinned copy drifts from the installed version. The rest of this file is only what that
skill does not say.

## What bites

- **`pane run` goes through the pane's shell, and the arguments are joined into a command
  line.** A path with spaces has to carry its own quotes:

  ```sh
  herdr pane run w1Y:p58 "'/Users/x/Some App/bin/prog' --flag value"
  ```

  Passing it as separate argv entries produces `fish: Unknown command: /Users/x/Some`.

- **A foreground process owns that pane's shell**, and this applies to every pane, not only
  to the one rule stated for `agent start`. While a foreground process runs, further
  `pane run` calls type the command at a prompt that never executes it — the text
  accumulates in `pane read` with no output and no new prompt. Everything succeeds and
  nothing happens. Either wait, or close the pane and split a new one.

## When not to use a pane

For a process the user does not need to watch, the agent's own background execution is
simpler than a pane, and it survives across turns just as well. Use a pane when the output
is worth seeing, or when the process must outlive the agent session.

## Housekeeping

The official rule is not to close what you did not create. The converse also holds: close
the panes you did create, once the process is done.

## Related

`herdr agent list` and `herdr agent prompt` address *agents* rather than panes, and have
their own skill: **agent-messaging**. `herdr server live-handoff` swaps the binary without
killing panes, so running agents survive an update.

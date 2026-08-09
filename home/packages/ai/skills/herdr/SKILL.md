---
name: herdr
description: Drive the Herdr terminal workspace from an agent — split a pane, run a long-lived process next to yourself, read what another pane printed, send keys to it, close it again. Use when something has to keep running while you carry on (a dev server, a browser with a debug port, a build), or when you need to see or steer another pane. Triggers on herdr, pane, split, tab, terminal workspace, "run this in another pane", "keep it running", "read the output of", "send keys to". For talking to other *agents* rather than panes, use agent-messaging.
---

# Driving Herdr

[Herdr](https://herdr.dev) is the terminal workspace the agent runs inside. Every pane and
tab has an id and can be created, inspected and driven from the CLI. All commands print
JSON on stdout.

The reason to reach for it: a process that must outlive one command. Run it in its own
pane and it keeps going, visible to the user, while you continue working.

## Finding your way

```sh
herdr pane current          # the pane the agent is in, with pane_id, tab_id, workspace_id
herdr pane list             # every pane
herdr status                # server and client state, capabilities
```

`pane_current` gives the `pane_id` — `w1Y:p1H` — that every other command wants.

## Running something beside you

```sh
herdr pane split --current --direction down --ratio 0.25
```

The reply contains the new pane's `pane_id`. Capture it: there is no "last created pane".

```sh
herdr pane run <PANE_ID> <COMMAND>...
herdr pane read <PANE_ID>          # terminal output, for checking it started
herdr pane send-keys <PANE_ID> enter
herdr pane send-text <PANE_ID> "literal text"
herdr pane close <PANE_ID>
```

Clean up panes you created once the process is done. Leaving debris in someone's workspace
is rude in a way a stray background process is not.

## What bites

- **`pane run` goes through the pane's shell, and the arguments are joined into a command
  line.** A path with spaces has to carry its own quotes:

  ```sh
  herdr pane run w1Y:p58 "'/Users/x/Some App/bin/prog' --flag value"
  ```

  Passing it as separate argv entries produces `fish: Unknown command: /Users/x/Some`.

- **A foreground process owns that pane's shell.** While it runs, further `pane run` calls
  type the command at a prompt that never executes it — you see the text accumulate in
  `pane read` with no output and no new prompt. Either wait, or close the pane and split a
  new one. This is the single most confusing failure: everything succeeds, nothing happens.

- **Check with `pane read` before concluding a command worked.** The JSON reply from
  `pane run` says the request was delivered, not that the command ran.

- **For a process the user does not need to watch**, the agent's own background execution
  is simpler than a pane, and it survives across turns just as well. Use a pane when the
  output is worth seeing, or when the process must outlive the agent session.

- `herdr pane send-keys` takes key names (`enter`, `esc`, `ctrl-c`); `send-text` sends
  characters literally. Sending `enter` as text does not submit a command.

## Related

`herdr agent list` and `herdr agent prompt` address *agents* rather than panes, and have
their own skill: **agent-messaging**. `herdr server live-handoff` swaps the binary without
killing panes, so running agents survive an update.

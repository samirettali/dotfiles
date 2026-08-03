---
name: agent-messaging
description: Message another running agent session (pi, Claude Code, or any agent Herdr detects) to coordinate, hand off work, or notify it that something is ready. Also use to list which agent sessions are currently running and what they are doing. Triggers on "tell the other agent", "hand this off to", "ask the session working on X", "which agents are running", "notify the other Claude".
---

# Messaging other agent sessions

Agents run as panes inside [Herdr](https://herdr.dev), a terminal workspace manager.
Herdr's socket API is the transport: it can list every agent it detects and inject a
prompt into any of them. There is no separate message bus to set up.

All commands print JSON on stdout.

## Find the target

```bash
herdr agent list
```

Each entry has `pane_id` (the address), `agent` (`pi`, `claude`, …), `agent_status`
(`idle`, `working`, `blocked`, `unknown`), `cwd`, and `terminal_title_stripped` — the
title usually describes what that session is working on, which is the best way to pick
the right one when several sessions share a directory.

To find your own pane, so you can tell the other agent who is writing and where to reply:

```bash
herdr pane current
```

## Send

```bash
herdr agent prompt <pane_id> "<text>"
```

Herdr injects the text verbatim, exactly as if Samir had typed it into that pane. It
carries no sender identity, so **always say who you are and where you are** in the
message itself:

```bash
herdr agent prompt wV:pB "From the Claude session in ~/dev/dotfiles (pane wV:p1): the API schema is merged, you can regenerate the client."
```

Without that prefix the receiving agent has no way to tell a relayed message from
something Samir typed, and cannot reply to you.

## Delivery semantics

- **Target idle:** the prompt starts a turn immediately. The other session wakes up on
  its own, with no action from Samir.
- **Target working:** the prompt is queued and delivered when the current turn ends.
  It does not interrupt tool calls in flight.
- **Target not running:** nothing is queued. The send fails and the message is lost —
  check `herdr agent list` first rather than sending blind.

Messaging is one-way and fire-and-forget. The other session decides whether to reply;
do not block waiting for an answer unless Samir asked you to.

## Optional: wait and read

```bash
herdr agent wait <pane_id> --until idle --timeout 120000
herdr agent read <pane_id>
```

`wait` blocks until the target settles; `read` dumps its terminal output, which is how
you check what it answered.

Do not use `herdr agent prompt --wait` for ordinary sends. It reports `timeout` even
when the prompt was delivered and answered correctly, because a short turn can finish
before Herdr observes the state change. Send without `--wait`, then poll with
`herdr agent wait` if you genuinely need the result.

## When to use this

Use it when Samir asks to coordinate with, hand off to, or notify another session, or
when he asks what is running. Do not message other sessions unprompted — an injected
prompt makes another agent start working and spend tokens.

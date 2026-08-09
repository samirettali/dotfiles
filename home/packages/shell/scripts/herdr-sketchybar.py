#!/usr/bin/env python3
"""Push Herdr's pending agent counts into a sketchybar item.

Herdr's socket API pushes: `events.subscribe` keeps the connection open and the
server writes one JSON object per line. So this holds a connection rather than
polling, and only recounts when Herdr says something changed.

Two things shape the subscription set:

- `pane.agent_status_changed` takes a `pane_id`; there is no global variant. So
  it is subscribed once per agent pane, and the connection is re-established
  whenever that set of panes changes.
- The global alternative, `pane.updated`, does exist but measured ~10 messages a
  second on a busy session, which would mean recounting on a timer in disguise.

The counts come from `herdr agent list`, not from the event payloads: an event
says one pane changed, not how many are waiting, so totals accumulated from
events would drift after any missed message.
"""

from __future__ import annotations

import json
import os
import socket
import subprocess
import sys
import time

# What Herdr would show as waiting for you: blocked agents, and agents that
# finished while you were looking elsewhere. `idle` and `working` are not
# counted — an agent that is working does not need you.
PENDING_STATUSES = ("blocked", "done")

# Global, parameterless, and low volume: these tell us a pane appeared or went
# away, which is when the per-pane subscriptions have to be rebuilt.
LIFECYCLE_SUBSCRIPTIONS = (
    "pane.created",
    "pane.closed",
    "pane.exited",
    "pane.agent_detected",
)

RECONNECT_DELAY_SECONDS = 5

# The event carries the two counts; the per-agent rows go through this file
# instead. Pane ids contain `:` and titles contain arbitrary punctuation, so
# packing them into `sketchybar --trigger` variables would mean inventing an
# encoding. The item only reads the file when its popup opens.
DETAIL_PATH = os.path.expanduser("~/.cache/sketchybar/herdr-agents.json")
# Panes rarely change alone: a split, a restore or a workspace switch arrives as
# a burst. Draining it before recounting keeps this to one `agent list` per
# burst instead of one per event.
COALESCE_SECONDS = 0.2


def socket_path() -> str:
    override = os.environ.get("HERDR_SOCKET_PATH")
    if override:
        return override
    config_home = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
    base = os.path.join(config_home, "herdr")
    session = os.environ.get("HERDR_SESSION")
    if session:
        return os.path.join(base, "sessions", session, "herdr.sock")
    return os.path.join(base, "herdr.sock")


def log(message: str) -> None:
    print(message, file=sys.stderr, flush=True)


def agent_list() -> list[dict]:
    try:
        result = subprocess.run(
            ["herdr", "agent", "list"],
            capture_output=True,
            text=True,
            timeout=10,
        )
    except (OSError, subprocess.TimeoutExpired) as err:
        # A missing `herdr` on PATH used to fail here silently, leaving the item
        # counting zero forever, so every failure is logged.
        log(f"agent list failed: {err}")
        return []
    if result.returncode != 0:
        log(f"agent list exited {result.returncode}: {result.stderr.strip()}")
        return []
    try:
        # Every CLI response is wrapped in an envelope: {"id":…,"result":{…}}.
        agents = json.loads(result.stdout).get("result", {}).get("agents")
    except json.JSONDecodeError as err:
        log(f"agent list is not JSON: {err}")
        return []
    return agents if isinstance(agents, list) else []


def count_pending(agents: list[dict]) -> dict[str, int]:
    counts = {status: 0 for status in PENDING_STATUSES}
    for agent in agents:
        if not isinstance(agent, dict):
            continue
        status = agent.get("agent_status")
        if status in counts:
            counts[status] += 1
    return counts


def pane_ids(agents: list[dict]) -> set[str]:
    return {
        agent["pane_id"]
        for agent in agents
        if isinstance(agent, dict) and isinstance(agent.get("pane_id"), str)
    }


def write_detail(agents: list[dict]) -> None:
    """Describe every pending agent, ordered the way the popup should read."""
    pending = [
        {
            "pane_id": agent.get("pane_id"),
            "status": agent.get("agent_status"),
            # The directory basename, which is what Herdr's own sidebar shows,
            # and the actionable part: it says which project is waiting.
            "project": os.path.basename((agent.get("cwd") or "").rstrip("/")) or "?",
            "title": agent.get("terminal_title_stripped") or "",
        }
        for agent in agents
        if isinstance(agent, dict) and agent.get("agent_status") in PENDING_STATUSES
    ]
    # Blocked first: it is the one that cannot make progress without you.
    pending.sort(key=lambda row: (PENDING_STATUSES.index(row["status"]), row["project"]))
    try:
        os.makedirs(os.path.dirname(DETAIL_PATH), exist_ok=True)
        with open(DETAIL_PATH, "w") as handle:
            json.dump({"agents": pending}, handle)
    except OSError as err:
        log(f"could not write {DETAIL_PATH}: {err}")


def publish(counts: dict[str, int]) -> None:
    args = ["sketchybar", "--trigger", "herdr_agents"]
    args += [f"{status}={counts[status]}" for status in PENDING_STATUSES]
    log("publish " + " ".join(f"{k}={v}" for k, v in counts.items()))
    try:
        subprocess.run(args, capture_output=True, timeout=10)
    except (OSError, subprocess.TimeoutExpired) as err:
        log(f"sketchybar trigger failed: {err}")


def subscribe(stream: socket.socket, panes: set[str]) -> None:
    subscriptions = [{"type": name} for name in LIFECYCLE_SUBSCRIPTIONS]
    subscriptions += [
        {"type": "pane.agent_status_changed", "pane_id": pane} for pane in sorted(panes)
    ]
    request = {
        "id": "sketchybar",
        "method": "events.subscribe",
        "params": {"subscriptions": subscriptions},
    }
    stream.sendall(json.dumps(request).encode() + b"\n")


def drain_burst(stream: socket.socket) -> bool:
    """Read whatever else is already on its way. False once the peer is gone."""
    stream.settimeout(COALESCE_SECONDS)
    try:
        while True:
            if not stream.recv(65536):
                return False
    except (TimeoutError, socket.timeout):
        return True
    finally:
        stream.settimeout(None)


def watch(path: str, published: dict[str, dict[str, int] | None]) -> None:
    """Serve one connection. Returns when the pane set changes or the peer goes.

    `published` carries the last counts across connections, so the reconnect a
    new pane triggers does not re-send an unchanged count.
    """
    agents = agent_list()
    subscribed = pane_ids(agents)
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as stream:
        stream.connect(path)
        subscribe(stream, subscribed)
        while True:
            counts = count_pending(agents)
            if counts != published["last"]:
                # The detail file is written before the trigger, so the item can
                # never read rows that disagree with the count it was handed.
                write_detail(agents)
                publish(counts)
                published["last"] = counts
            # A pane appeared or died, so the per-pane subscriptions are stale:
            # drop the connection and let the caller open a fresh one.
            if pane_ids(agents) != subscribed:
                return
            if not stream.recv(65536):
                return
            if not drain_burst(stream):
                return
            agents = agent_list()


def main() -> int:
    path = socket_path()
    published: dict[str, dict[str, int] | None] = {"last": None}
    while True:
        try:
            watch(path, published)
            continue
        except (FileNotFoundError, ConnectionError, OSError) as err:
            # No server yet, or it went away: `herdr server stop`, a live
            # handoff, a reboot. Clear the item so a stale count is not left on
            # screen, then keep trying.
            print(f"herdr socket unavailable: {err}", file=sys.stderr, flush=True)
        empty = {status: 0 for status in PENDING_STATUSES}
        if published["last"] != empty:
            write_detail([])
            publish(empty)
            published["last"] = empty
        time.sleep(RECONNECT_DELAY_SECONDS)


if __name__ == "__main__":
    sys.exit(main())

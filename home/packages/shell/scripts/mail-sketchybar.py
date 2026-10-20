#!/usr/bin/env python3
"""Push the Fastmail inbox unread count into a sketchybar item.

Fastmail speaks JMAP, whose event source is a Server-Sent Events stream: it
sends a `state` event whenever a mailbox changes, and a `ping` every
PING_SECONDS. So this holds the stream open and only recounts when Fastmail says
the mailboxes changed.

The count comes from `Mailbox/get`, not from the events: a state change says
something changed, not what the count is.

The Fastmail token comes from `FASTMAIL_API_KEY`.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request

SESSION_URL = "https://api.fastmail.com/jmap/session"
USING = ["urn:ietf:params:jmap:core", "urn:ietf:params:jmap:mail"]

# Fastmail ignores intervals below 30 seconds. Silence for over two pings means
# the connection is dead, which is also how a sleep shows up.
PING_SECONDS = 30
READ_TIMEOUT_SECONDS = 75
RECONNECT_DELAY_SECONDS = 5
# launchd spawns an agent at most once every 10 seconds, so a token rejected
# right after the start would be retried that often.
REJECTED_EXIT_DELAY_SECONDS = 60


def log(message: str) -> None:
    print(message, file=sys.stderr, flush=True)


def request(token: str, url: str, body: dict | None = None, timeout: float = 30):
    headers = {"Authorization": f"Bearer {token}"}
    data = None
    if body is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(body).encode()
    return urllib.request.urlopen(
        urllib.request.Request(url, data=data, headers=headers), timeout=timeout
    )


def unread(token: str, session: dict) -> int:
    account = session["primaryAccounts"]["urn:ietf:params:jmap:mail"]
    body = {
        "using": USING,
        "methodCalls": [
            ["Mailbox/query", {"accountId": account, "filter": {"role": "inbox"}}, "q"],
            [
                "Mailbox/get",
                {
                    "accountId": account,
                    "#ids": {"resultOf": "q", "name": "Mailbox/query", "path": "/ids"},
                    "properties": ["unreadEmails"],
                },
                "g",
            ],
        ],
    }
    with request(token, session["apiUrl"], body) as response:
        mailboxes = json.load(response)["methodResponses"][1][1]["list"]
    return sum(mailbox["unreadEmails"] for mailbox in mailboxes)


def publish(count: int) -> None:
    try:
        subprocess.run(
            ["sketchybar", "--trigger", "mail_unread", f"count={count}"],
            capture_output=True,
            timeout=10,
        )
    except (OSError, subprocess.TimeoutExpired) as err:
        log(f"sketchybar trigger failed: {err}")


def watch(token: str, published: dict[str, int | None]) -> None:
    """Serve one stream. Returns or raises when it ends."""
    with request(token, SESSION_URL) as response:
        session = json.load(response)
    url = (
        session["eventSourceUrl"]
        .replace("{types}", "Mailbox")
        .replace("{closeafter}", "no")
        .replace("{ping}", str(PING_SECONDS))
    )
    with request(token, url, timeout=READ_TIMEOUT_SECONDS) as stream:
        event = None
        for raw in stream:
            line = raw.decode().rstrip("\r\n")
            if line.startswith("event:"):
                event = line.removeprefix("event:").strip()
            # The first `state` arrives on connect, so a reconnect recounts
            # whatever changed while the stream was down.
            elif line.startswith("data:") and event == "state":
                count = unread(token, session)
                if count != published["last"]:
                    publish(count)
                    published["last"] = count


def main() -> int:
    token = os.environ.get("FASTMAIL_API_KEY")
    if not token:
        log("FASTMAIL_API_KEY is not set")
        return 1
    published: dict[str, int | None] = {"last": None}
    while True:
        try:
            watch(token, published)
            log("event stream closed")
        except urllib.error.HTTPError as err:
            log(f"fastmail returned {err.code}")
            if err.code in (401, 403):
                # A revoked or replaced token: exit, so the caller can start
                # this again with a new one.
                time.sleep(REJECTED_EXIT_DELAY_SECONDS)
                return 1
        except (OSError, ValueError, KeyError) as err:
            log(f"fastmail unavailable: {err!r}")
        time.sleep(RECONNECT_DELAY_SECONDS)


if __name__ == "__main__":
    sys.exit(main())

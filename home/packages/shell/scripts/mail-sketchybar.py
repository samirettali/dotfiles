#!/usr/bin/env python3
"""Push the Fastmail inbox unread count into a sketchybar item.

Fastmail speaks JMAP, whose event source is a Server-Sent Events stream: it
sends a `state` event whenever a mailbox changes, and a `ping` every
PING_SECONDS. So this holds the stream open and only recounts when Fastmail says
the mailboxes changed.

The count comes from `Mailbox/get`, not from the events: a state change says
something changed, not what the count is.
"""

from __future__ import annotations

import json
import subprocess
import sys
import time
import urllib.error
import urllib.request

SESSION_URL = "https://api.fastmail.com/jmap/session"
TOKEN_ENTRY = "fastmail-api-key"
USING = ["urn:ietf:params:jmap:core", "urn:ietf:params:jmap:mail"]

# Fastmail ignores intervals below 30 seconds. Silence for over two pings means
# the connection is dead, which is also how a sleep shows up.
PING_SECONDS = 30
READ_TIMEOUT_SECONDS = 75
RECONNECT_DELAY_SECONDS = 5
# Waiting for the vault to be unlocked. `rbw get` on a locked vault would open
# a pinentry prompt from a background process.
VAULT_RETRY_SECONDS = 60


def log(message: str) -> None:
    print(message, file=sys.stderr, flush=True)


def read_token() -> str | None:
    unlocked = subprocess.run(["rbw", "unlocked"], capture_output=True)
    if unlocked.returncode != 0:
        log("rbw vault is locked")
        return None
    result = subprocess.run(["rbw", "get", TOKEN_ENTRY], capture_output=True, text=True)
    if result.returncode != 0:
        log(f"rbw get {TOKEN_ENTRY} exited {result.returncode}: {result.stderr.strip()}")
        return None
    return result.stdout.strip() or None


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
    published: dict[str, int | None] = {"last": None}
    token = None
    while True:
        if token is None:
            token = read_token()
            if token is None:
                time.sleep(VAULT_RETRY_SECONDS)
                continue
        delay = RECONNECT_DELAY_SECONDS
        try:
            watch(token, published)
            log("event stream closed")
        except urllib.error.HTTPError as err:
            log(f"fastmail returned {err.code}")
            if err.code in (401, 403):
                # A revoked or replaced token: read it again from the vault.
                token = None
                delay = VAULT_RETRY_SECONDS
        except (OSError, ValueError, KeyError) as err:
            log(f"fastmail unavailable: {err!r}")
        time.sleep(delay)


if __name__ == "__main__":
    sys.exit(main())

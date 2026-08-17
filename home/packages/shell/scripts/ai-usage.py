#!/usr/bin/env python3
"""Subscription usage for Claude and Codex, as JSON.

Both providers only expose this to their own OAuth session, so the credentials
are borrowed from the CLIs: Claude Code keeps its token in the login keychain,
Codex in ~/.codex/auth.json.
"""

from __future__ import annotations

import json
import os
import select
import subprocess
import sys
import time
import urllib.error
import urllib.request

TIMEOUT = 10

CLAUDE_USAGE_URL = "https://api.anthropic.com/api/oauth/usage"
CODEX_USAGE_URL = "https://chatgpt.com/backend-api/wham/usage"

# Claude names its buckets by kind; `weekly_scoped` carries the model it applies
# to (an Opus-only weekly cap, say) and is labelled with it instead.
CLAUDE_LABELS = {"session": "5h", "weekly_all": "7d"}


def get_json(url: str, headers: dict[str, str]) -> dict:
    request = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
        return json.load(response)


def claude_token() -> str | None:
    try:
        raw = subprocess.run(
            ["/usr/bin/security", "find-generic-password", "-s", "Claude Code-credentials", "-w"],
            capture_output=True,
            text=True,
            timeout=TIMEOUT,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    if raw.returncode != 0:
        return None
    try:
        return json.loads(raw.stdout)["claudeAiOauth"]["accessToken"]
    except (ValueError, KeyError, TypeError):
        return None


def claude() -> dict:
    token = claude_token()
    if not token:
        return {"key": "claude", "name": "Claude", "error": "no credentials"}

    try:
        # The endpoint is the one Claude Code's own /usage draws, and needs the
        # OAuth beta header — a bare bearer token is rejected.
        payload = get_json(
            CLAUDE_USAGE_URL,
            {"Authorization": f"Bearer {token}", "anthropic-beta": "oauth-2025-04-20"},
        )
    except urllib.error.HTTPError as error:
        # Nothing here refreshes the token: Claude Code owns it, and writing a
        # new one back to the keychain would race with it.
        return {"key": "claude", "name": "Claude", "error": f"http {error.code}"}
    except (urllib.error.URLError, TimeoutError, ValueError) as error:
        return {"key": "claude", "name": "Claude", "error": str(error)}

    windows = []
    for limit in payload.get("limits") or []:
        kind = limit.get("kind")
        label = CLAUDE_LABELS.get(kind)
        if label is None:
            if kind != "weekly_scoped":
                continue
            model = ((limit.get("scope") or {}).get("model") or {}).get("display_name")
            if not model:
                continue
            label = model.lower()
        windows.append(
            {
                "label": label,
                "percent": limit.get("percent") or 0,
                "resets_at": limit.get("resets_at"),
            }
        )

    return {"key": "claude", "name": "Claude", "windows": windows}


def codex_window(window: dict | None) -> dict | None:
    if not window:
        return None
    seconds = window.get("limit_window_seconds") or 0
    hours = round(seconds / 3600)
    reset = window.get("reset_at")
    return {
        "label": "7d" if hours >= 144 else "1d" if hours >= 24 else f"{hours}h",
        "percent": window.get("used_percent") or 0,
        "resets_at": time.strftime("%Y-%m-%dT%H:%M:%S%z", time.localtime(reset)) if reset else None,
    }


def codex_from_app_server() -> dict:
    """Ask the Codex CLI, which refreshes the OAuth token on the way.

    Slower than the HTTP call (~0.5s against ~0.2s) but self-healing, so it is
    the fallback rather than the default: the stored token expires within the
    hour and nothing else here can renew it.
    """
    requests = [
        {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {"clientInfo": {"name": "ai-usage", "title": "ai-usage", "version": "1.0.0"}},
        },
        {"jsonrpc": "2.0", "method": "initialized", "params": {}},
        {"jsonrpc": "2.0", "id": 2, "method": "account/rateLimits/read", "params": {}},
    ]

    process = subprocess.Popen(
        ["codex", "app-server"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    try:
        process.stdin.write("".join(json.dumps(request) + "\n" for request in requests))
        process.stdin.flush()
        deadline = time.monotonic() + TIMEOUT
        buffer = b""
        # stdout stays open for the lifetime of app-server. Wait for readable
        # bytes with the remaining deadline instead of blocking in readline().
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                return {"key": "codex", "name": "Codex", "error": "app-server timed out"}
            ready, _, _ = select.select([process.stdout], [], [], remaining)
            if not ready:
                return {"key": "codex", "name": "Codex", "error": "app-server timed out"}
            chunk = os.read(process.stdout.fileno(), 65536)
            if not chunk:
                break
            buffer += chunk
            while b"\n" in buffer:
                line, buffer = buffer.split(b"\n", 1)
                try:
                    message = json.loads(line)
                except ValueError:
                    continue
                if message.get("id") != 2:
                    continue
                limits = (message.get("result") or {}).get("rateLimits") or {}
                windows = []
                for key in ("primary", "secondary"):
                    window = limits.get(key)
                    if not window:
                        continue
                    converted = codex_window(
                        {
                            "limit_window_seconds": (window.get("windowDurationMins") or 0) * 60,
                            "used_percent": window.get("usedPercent"),
                            "reset_at": window.get("resetsAt"),
                        }
                    )
                    if converted:
                        windows.append(converted)
                return {"key": "codex", "name": "Codex", "windows": windows}
    except (OSError, ValueError) as error:
        return {"key": "codex", "name": "Codex", "error": str(error)}
    finally:
        if process.poll() is None:
            process.kill()
        process.wait()

    return {"key": "codex", "name": "Codex", "error": "no answer from app-server"}


def codex() -> dict:
    auth_path = os.path.join(os.environ.get("CODEX_HOME", os.path.expanduser("~/.codex")), "auth.json")
    try:
        with open(auth_path) as handle:
            tokens = (json.load(handle) or {}).get("tokens") or {}
    except (OSError, ValueError):
        return codex_from_app_server()

    token = tokens.get("access_token")
    if not token:
        return {"key": "codex", "name": "Codex", "error": "no credentials"}

    headers = {"Authorization": f"Bearer {token}", "Accept": "application/json"}
    if tokens.get("account_id"):
        headers["ChatGPT-Account-Id"] = tokens["account_id"]

    try:
        payload = get_json(CODEX_USAGE_URL, headers)
    except urllib.error.HTTPError as error:
        # An expired token comes back as Cloudflare's 403 HTML, not a JSON 401.
        if error.code in (401, 403):
            return codex_from_app_server()
        return {"key": "codex", "name": "Codex", "error": f"http {error.code}"}
    except (urllib.error.URLError, TimeoutError, ValueError) as error:
        return {"key": "codex", "name": "Codex", "error": str(error)}

    rate_limit = payload.get("rate_limit") or {}
    windows = [
        window
        for window in (
            codex_window(rate_limit.get("primary_window")),
            codex_window(rate_limit.get("secondary_window")),
        )
        if window
    ]
    return {"key": "codex", "name": "Codex", "windows": windows}


def main() -> int:
    providers = {"claude": claude, "codex": codex}
    requested = sys.argv[1:] or list(providers)
    unknown = [key for key in requested if key not in providers]
    if unknown:
        print(f"unknown provider: {', '.join(unknown)}", file=sys.stderr)
        return 2

    json.dump({"providers": [providers[key]() for key in requested]}, sys.stdout)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())

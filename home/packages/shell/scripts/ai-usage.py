#!/usr/bin/env python3
"""Subscription usage for Claude, Codex, Antigravity and Grok, as JSON.

Each provider only exposes this to its own OAuth session, so the credentials
are borrowed from the CLIs: Claude Code and Antigravity keep their tokens in
the login keychain, Codex in ~/.codex/auth.json, Grok in ~/.grok/auth.json.
"""

from __future__ import annotations

import base64
import datetime
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
# The daily host is the one the CLI talks to; cloudcode-pa.googleapis.com
# answers too, but with a separate quota pool and different reset times.
AGY_USAGE_URL = "https://daily-cloudcode-pa.googleapis.com/v1internal:retrieveUserQuotaSummary"
GROK_USAGE_URL = "https://cli-chat-proxy.grok.com/v1/billing?format=credits"

CLAUDE_PAGE = "https://claude.ai/settings/usage"
CODEX_PAGE = "https://chatgpt.com/codex/settings/usage"
AGY_PAGE = "https://antigravity.google/g1-activity"
GROK_PAGE = "https://grok.com/?_s=usage"

# The Antigravity CLI fallback starts a whole session before answering.
AGY_TIMEOUT = 30

GROK_PERIODS = {"USAGE_PERIOD_TYPE_WEEKLY": "7d", "USAGE_PERIOD_TYPE_MONTHLY": "30d"}

# Claude names its buckets by kind; `weekly_scoped` carries the model it applies
# to (an Opus-only weekly cap, say) and is labelled with it instead.
CLAUDE_LABELS = {"session": "5h", "weekly_all": "7d"}


def epoch(value: object) -> int | None:
    """Reset instants leave here as Unix seconds, whatever shape the API sent."""
    if isinstance(value, (int, float)):
        return int(value)
    if isinstance(value, str):
        try:
            return int(datetime.datetime.fromisoformat(value.replace("Z", "+00:00")).timestamp())
        except ValueError:
            return None
    return None


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


def claude() -> list[dict]:
    token = claude_token()
    if not token:
        return [{"key": "claude", "name": "Claude", "url": CLAUDE_PAGE, "error": "no credentials"}]

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
        return [{"key": "claude", "name": "Claude", "url": CLAUDE_PAGE, "error": f"http {error.code}"}]
    except (urllib.error.URLError, TimeoutError, ValueError) as error:
        return [{"key": "claude", "name": "Claude", "url": CLAUDE_PAGE, "error": str(error)}]

    windows = []
    # A model-scoped cap belongs to that model, not to the plan: it becomes its
    # own provider section so its percentage never reads as overall usage.
    scoped: dict[str, list[dict]] = {}
    for limit in payload.get("limits") or []:
        kind = limit.get("kind")
        label = CLAUDE_LABELS.get(kind)
        model = None
        if label is None:
            if kind != "weekly_scoped":
                continue
            model = ((limit.get("scope") or {}).get("model") or {}).get("display_name")
            if not model:
                continue
            label = "7d"
        window = {
            "label": label,
            "percent": limit.get("percent") or 0,
            "resets_at": epoch(limit.get("resets_at")),
        }
        if model:
            scoped.setdefault(model, []).append(window)
        else:
            windows.append(window)

    providers = [{"key": "claude", "name": "Claude", "url": CLAUDE_PAGE, "windows": windows}]
    for model, model_windows in scoped.items():
        key = "claude." + model.lower().replace(" ", "-")
        providers.append({"key": key, "name": model, "url": CLAUDE_PAGE, "windows": model_windows})
    return providers


def codex_window(window: dict | None) -> dict | None:
    if not window:
        return None
    seconds = window.get("limit_window_seconds") or 0
    hours = round(seconds / 3600)
    reset = window.get("reset_at")
    return {
        "label": "7d" if hours >= 144 else "1d" if hours >= 24 else f"{hours}h",
        "percent": window.get("used_percent") or 0,
        "resets_at": epoch(reset),
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
                return {"key": "codex", "name": "Codex", "url": CODEX_PAGE, "error": "app-server timed out"}
            ready, _, _ = select.select([process.stdout], [], [], remaining)
            if not ready:
                return {"key": "codex", "name": "Codex", "url": CODEX_PAGE, "error": "app-server timed out"}
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
                return {"key": "codex", "name": "Codex", "url": CODEX_PAGE, "windows": windows}
    except (OSError, ValueError) as error:
        return {"key": "codex", "name": "Codex", "url": CODEX_PAGE, "error": str(error)}
    finally:
        if process.poll() is None:
            process.kill()
        process.wait()

    return {"key": "codex", "name": "Codex", "url": CODEX_PAGE, "error": "no answer from app-server"}


def codex() -> dict:
    auth_path = os.path.join(os.environ.get("CODEX_HOME", os.path.expanduser("~/.codex")), "auth.json")
    try:
        with open(auth_path) as handle:
            tokens = (json.load(handle) or {}).get("tokens") or {}
    except (OSError, ValueError):
        return codex_from_app_server()

    token = tokens.get("access_token")
    if not token:
        return {"key": "codex", "name": "Codex", "url": CODEX_PAGE, "error": "no credentials"}

    headers = {"Authorization": f"Bearer {token}", "Accept": "application/json"}
    if tokens.get("account_id"):
        headers["ChatGPT-Account-Id"] = tokens["account_id"]

    try:
        payload = get_json(CODEX_USAGE_URL, headers)
    except urllib.error.HTTPError as error:
        # An expired token comes back as Cloudflare's 403 HTML, not a JSON 401.
        if error.code in (401, 403):
            return codex_from_app_server()
        return {"key": "codex", "name": "Codex", "url": CODEX_PAGE, "error": f"http {error.code}"}
    except (urllib.error.URLError, TimeoutError, ValueError) as error:
        return {"key": "codex", "name": "Codex", "url": CODEX_PAGE, "error": str(error)}

    rate_limit = payload.get("rate_limit") or {}
    windows = [
        window
        for window in (
            codex_window(rate_limit.get("primary_window")),
            codex_window(rate_limit.get("secondary_window")),
        )
        if window
    ]
    return {"key": "codex", "name": "Codex", "url": CODEX_PAGE, "windows": windows}


def agy_error(message: str) -> list[dict]:
    return [{"key": "agy", "name": "Antigravity", "url": AGY_PAGE, "error": message}]


def agy_token() -> tuple[str | None, bool]:
    """The access token and whether it is still valid, or (None, False)."""
    try:
        raw = subprocess.run(
            ["/usr/bin/security", "find-generic-password", "-s", "gemini", "-a", "antigravity", "-w"],
            capture_output=True,
            text=True,
            timeout=TIMEOUT,
        )
    except (OSError, subprocess.SubprocessError):
        return None, False
    if raw.returncode != 0:
        return None, False
    try:
        # go-keyring stores what the CLI gave it, base64 behind a prefix.
        encoded = raw.stdout.strip().removeprefix("go-keyring-base64:")
        token = json.loads(base64.b64decode(encoded))["token"]
        access = token["access_token"]
        expiry = epoch(token.get("expiry"))
    except (ValueError, KeyError, TypeError):
        return None, False
    return access, expiry is None or expiry > time.time() + 30


def agy_providers(groups: list[dict]) -> list[dict]:
    """The HTTP response spells its keys in camelCase, the CLI in snake_case."""

    def pick(mapping: dict, *keys: str) -> object:
        for key in keys:
            if key in mapping:
                return mapping[key]
        return None

    providers = []
    for group in groups:
        name = pick(group, "displayName", "name") or ""
        if not name:
            continue
        # "Gemini Models" and "Claude and GPT models" read better as
        # "Antigravity Gemini" and "Antigravity Claude and GPT".
        short = name[: -len(" models")] if name.lower().endswith(" models") else name
        windows = []
        for bucket in group.get("buckets") or []:
            window = bucket.get("window")
            label = "7d" if window == "weekly" else window
            remaining = pick(bucket, "remainingFraction", "remaining_fraction")
            if not label or not isinstance(remaining, (int, float)):
                continue
            windows.append(
                {
                    "label": label,
                    "percent": (1 - remaining) * 100,
                    "resets_at": epoch(pick(bucket, "resetTime", "reset_time")),
                }
            )
        # Antigravity lists the weekly bucket first; the other providers put the
        # short window on top, so the popup keeps one order throughout.
        windows.sort(key=lambda window: window["label"] != "5h")
        providers.append(
            {
                "key": "agy." + short.lower().replace(" ", "-"),
                "name": f"Antigravity {short}",
                "url": AGY_PAGE,
                "windows": windows,
            }
        )
    return providers or agy_error("no quota groups")


def agy_from_cli() -> list[dict]:
    """Ask the Antigravity CLI, which refreshes the keychain token on the way.

    `/usage` in print mode returns the same quota groups as the endpoint, in a
    few seconds rather than a fraction of one, so it is the fallback.
    """
    try:
        # Every print-mode run opens a fresh log file under ~/.gemini; a poller
        # would leave hundreds a day behind.
        raw = subprocess.run(
            ["agy", "--log-file", "/dev/null", "-p", "/usage", "--output-format", "json"],
            capture_output=True,
            text=True,
            timeout=AGY_TIMEOUT,
        )
    except (OSError, subprocess.SubprocessError) as error:
        return agy_error(str(error))
    if raw.returncode != 0:
        return agy_error(f"exit {raw.returncode}")
    try:
        payload = json.loads(raw.stdout)
    except ValueError:
        return agy_error("no json from agy")
    if payload.get("status") != "SUCCESS":
        return agy_error(payload.get("status") or "no status")
    return agy_providers(((payload.get("command") or {}).get("data") or {}).get("groups") or [])


def agy() -> list[dict]:
    """Each quota group (Gemini models, Claude and GPT models) has its own
    weekly and 5-hour buckets, so each becomes its own provider section, as
    the model-scoped Claude caps do.
    """
    token, valid = agy_token()
    if not token or not valid:
        # Nothing here refreshes the token: the CLI owns it, and a second
        # writer to the keychain would race with it.
        return agy_from_cli()

    try:
        # The endpoint is the one the CLI's own /usage draws. It answers with
        # SUBSCRIPTION_REQUIRED unless the User-Agent names Antigravity.
        request = urllib.request.Request(
            AGY_USAGE_URL,
            data=b"{}",
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json",
                "User-Agent": "antigravity-cli",
            },
        )
        with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
            payload = json.load(response)
    except urllib.error.HTTPError as error:
        if error.code in (401, 403):
            return agy_from_cli()
        return agy_error(f"http {error.code}")
    except (urllib.error.URLError, TimeoutError, ValueError) as error:
        return agy_error(str(error))
    return agy_providers(payload.get("groups") or [])


def grok_error(message: str) -> dict:
    return {"key": "grok", "name": "Grok", "url": GROK_PAGE, "error": message}


def grok_provider(payload: dict) -> dict:
    """One window: the billing period of the plan, with its credit usage.

    The proxy omits `creditUsagePercent`, `includedUsed` and `totalUsed` while
    they are zero, which is what the TUI's /usage bar shows as 0%.
    """
    config = payload.get("config") or {}
    period = config.get("currentPeriod") or {}
    label = GROK_PERIODS.get(period.get("type"))
    if not label:
        return grok_error("no billing period")
    window = {
        "label": label,
        "percent": config.get("creditUsagePercent") or 0,
        "resets_at": epoch(period.get("end")),
    }
    return {"key": "grok", "name": "Grok", "url": GROK_PAGE, "windows": [window]}


def grok_from_agent() -> dict:
    """Ask the Grok CLI, which refreshes the OAuth token on the way.

    `grok agent stdio` speaks the Agent Client Protocol; `_x.ai/billing` is the
    extension method behind the TUI's /usage and needs no session.
    """
    requests = [
        {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {"protocolVersion": 1, "clientCapabilities": {}, "clientInfo": {"name": "ai-usage", "version": "1"}},
        },
        {"jsonrpc": "2.0", "id": 2, "method": "_x.ai/billing", "params": {}},
    ]

    process = subprocess.Popen(
        ["grok", "agent", "--no-leader", "stdio"],
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
        # stdout stays open for the lifetime of the agent, as with Codex.
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                return grok_error("agent timed out")
            ready, _, _ = select.select([process.stdout], [], [], remaining)
            if not ready:
                return grok_error("agent timed out")
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
                if message.get("error"):
                    return grok_error(message["error"].get("message") or "agent error")
                return grok_provider(message.get("result") or {})
    except (OSError, ValueError) as error:
        return grok_error(str(error))
    finally:
        if process.poll() is None:
            process.kill()
        process.wait()

    return grok_error("no answer from agent")


def grok() -> dict:
    auth_path = os.path.expanduser("~/.grok/auth.json")
    try:
        with open(auth_path) as handle:
            # One entry per issuer, keyed "<issuer>::<client id>".
            accounts = list((json.load(handle) or {}).values())
    except (OSError, ValueError):
        return grok_from_agent()
    account = accounts[0] if accounts and isinstance(accounts[0], dict) else {}
    token = account.get("key")
    if not token:
        return grok_error("no credentials")
    expires = epoch(account.get("expires_at"))
    if expires is not None and expires <= time.time() + 30:
        return grok_from_agent()

    try:
        payload = get_json(GROK_USAGE_URL, {"Authorization": f"Bearer {token}"})
    except urllib.error.HTTPError as error:
        if error.code in (401, 403):
            return grok_from_agent()
        return grok_error(f"http {error.code}")
    except (urllib.error.URLError, TimeoutError, ValueError) as error:
        return grok_error(str(error))
    return grok_provider(payload)


def main() -> int:
    providers = {"claude": claude, "codex": codex, "agy": agy, "grok": grok}
    requested = sys.argv[1:] or list(providers)
    unknown = [key for key in requested if key not in providers]
    if unknown:
        print(f"unknown provider: {', '.join(unknown)}", file=sys.stderr)
        return 2

    fetched = []
    for key in requested:
        result = providers[key]()
        fetched.extend(result if isinstance(result, list) else [result])

    json.dump({"providers": fetched}, sys.stdout)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Subscription usage for Claude, Codex and Antigravity, as JSON.

Each provider only exposes this to its own OAuth session, so the credentials
are borrowed from the CLIs: Claude Code and Antigravity keep their tokens in
the login keychain, Codex in ~/.codex/auth.json.

Claude arrives in two pieces. The plan's own windows come free of charge from
Claude Code's statusLine command, which writes what it already holds to
~/.cache/sketchybar/claude-usage.json. The per-model weekly caps do not: the
statusLine payload is built from the anthropic-ratelimit-unified-* response
headers, which carry no model-scoped window, so only the usage endpoint knows
them and it has to be asked.
"""

from __future__ import annotations

import base64
import datetime
import json
import os
import select
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request

TIMEOUT = 10
# What to wait when a 429 carries no Retry-After of its own.
CLAUDE_COOLDOWN = 900
# How old the model-scoped reading may get before the endpoint is asked again,
# and before the rows it feeds turn grey. Measured, the endpoint allows about
# one call an hour per token and answers 429 with a Retry-After of most of it,
# so asking every five minutes costs nothing beyond the first refusal and the
# rows have to survive a whole window between two readings.
CLAUDE_SCOPED_MAX_AGE = 300
CLAUDE_SCOPED_STALE_AGE = 5400

CLAUDE_USAGE_FILE = os.path.expanduser("~/.cache/sketchybar/claude-usage.json")
CLAUDE_SCOPED_FILE = os.path.expanduser("~/.cache/sketchybar/claude-scoped.json")
# Claude Code parks the usage endpoint's last answer here, whole. It is only
# rewritten when something made it ask, so it is a free head start, not a feed.
CLAUDE_STATE_FILE = os.path.expanduser("~/.claude.json")
CLAUDE_USAGE_URL = "https://api.anthropic.com/api/oauth/usage"
CODEX_USAGE_URL = "https://chatgpt.com/backend-api/wham/usage"
# The daily host is the one the CLI talks to; cloudcode-pa.googleapis.com
# answers too, but with a separate quota pool and different reset times.
AGY_USAGE_URL = "https://daily-cloudcode-pa.googleapis.com/v1internal:retrieveUserQuotaSummary"

CLAUDE_PAGE = "https://claude.ai/settings/usage"
CODEX_PAGE = "https://chatgpt.com/codex/settings/usage"
AGY_PAGE = "https://antigravity.google/g1-activity"

# The Antigravity CLI fallback starts a whole session before answering.
AGY_TIMEOUT = 30

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


def write_json(path: str, document: object) -> None:
    """Replaced whole: Sketchybar reads this file while this process writes it."""
    directory = os.path.dirname(path)
    try:
        os.makedirs(directory, exist_ok=True)
        fd, temp = tempfile.mkstemp(dir=directory, prefix=".ai-usage.")
        with os.fdopen(fd, "w") as handle:
            json.dump(document, handle, separators=(",", ":"))
        os.replace(temp, path)
    except OSError:
        pass


def get_json(url: str, headers: dict[str, str]) -> dict:
    request = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
        return json.load(response)


def retry_after(error: urllib.error.HTTPError) -> int | None:
    raw = error.headers.get("Retry-After") if error.headers else None
    try:
        seconds = int(str(raw).strip())
    except (TypeError, ValueError):
        return None
    return seconds if seconds > 0 else None


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


def claude_scoped_providers(limits: object) -> list[dict]:
    """Project the endpoint's limits[] array into one section per model.

    A model-scoped cap belongs to that model, not to the plan: it becomes its
    own provider so its percentage never reads as overall usage.
    """
    providers: dict[str, dict] = {}
    for limit in limits if isinstance(limits, list) else []:
        if not isinstance(limit, dict) or limit.get("kind") != "weekly_scoped":
            continue
        model = ((limit.get("scope") or {}).get("model") or {}).get("display_name")
        if not model:
            continue
        key = "claude." + model.lower().replace(" ", "-")
        window = {"label": "7d", "percent": limit.get("percent") or 0, "resets_at": epoch(limit.get("resets_at"))}
        providers.setdefault(key, {"key": key, "name": model, "url": CLAUDE_PAGE, "windows": []})
        providers[key]["windows"].append(window)
    return list(providers.values())


def claude_code_cache() -> tuple[list[dict], int]:
    """What Claude Code's own copy of the endpoint's answer is worth today."""
    try:
        with open(CLAUDE_STATE_FILE) as handle:
            cached = json.load(handle).get("cachedUsageUtilization")
    except (OSError, ValueError, AttributeError):
        return [], 0
    if not isinstance(cached, dict):
        return [], 0
    fetched_at = int((cached.get("fetchedAtMs") or 0) / 1000)
    utilization = cached.get("utilization")
    if not fetched_at or not isinstance(utilization, dict):
        return [], 0
    return claude_scoped_providers(utilization.get("limits")), fetched_at


def claude_scoped() -> list[dict]:
    """The per-model weekly caps, asked for as rarely as they can be.

    The endpoint budgets a handful of calls per access token and Claude Code
    spends them itself, so a 429 is expected rather than exceptional: it parks
    the reading until Retry-After has passed and the rows go grey meanwhile.
    """
    now = int(time.time())
    try:
        with open(CLAUDE_SCOPED_FILE) as handle:
            state = json.load(handle)
    except (OSError, ValueError):
        state = {}
    providers = state.get("providers") if isinstance(state.get("providers"), list) else []
    fetched_at = int(state.get("fetched_at") or 0)
    blocked_until = int(state.get("blocked_until") or 0)

    borrowed, borrowed_at = claude_code_cache()
    if borrowed_at > fetched_at:
        providers, fetched_at = borrowed, borrowed_at

    if now - fetched_at >= CLAUDE_SCOPED_MAX_AGE and now >= blocked_until:
        try:
            # The endpoint is the one Claude Code's own /usage draws, and needs
            # the OAuth beta header — a bare bearer token is rejected. Nothing
            # here refreshes the token: Claude Code owns it, and writing a new
            # one back to the keychain would race with it.
            token = claude_token()
            if token:
                payload = get_json(
                    CLAUDE_USAGE_URL,
                    {"Authorization": f"Bearer {token}", "anthropic-beta": "oauth-2025-04-20"},
                )
                providers, fetched_at, blocked_until = claude_scoped_providers(payload.get("limits")), now, 0
        except urllib.error.HTTPError as error:
            if error.code == 429:
                blocked_until = now + (retry_after(error) or CLAUDE_COOLDOWN)
        except (urllib.error.URLError, TimeoutError, ValueError):
            pass
        write_json(
            CLAUDE_SCOPED_FILE,
            {"providers": providers, "fetched_at": fetched_at, "blocked_until": blocked_until},
        )

    if now - fetched_at <= CLAUDE_SCOPED_STALE_AGE:
        return providers
    # Past that the numbers are worth nothing, but the sections still are: an
    # error keeps the widget's cached rows and turns them grey.
    minutes = (now - fetched_at) // 60
    return [{k: v for k, v in p.items() if k != "windows"} | {"error": f"stale ({minutes}m)"} for p in providers]


def claude() -> list[dict]:
    """The plan's windows come from the statusLine file; see its script."""
    try:
        with open(CLAUDE_USAGE_FILE) as handle:
            document = json.load(handle)
        providers = document["providers"]
        assert isinstance(providers, list) and providers
    except FileNotFoundError:
        providers = [{"key": "claude", "name": "Claude", "url": CLAUDE_PAGE, "error": "no statusline data yet"}]
    except (OSError, ValueError, KeyError, AssertionError):
        providers = [{"key": "claude", "name": "Claude", "url": CLAUDE_PAGE, "error": "bad statusline data"}]
    return providers + claude_scoped()


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


def main() -> int:
    providers = {"claude": claude, "codex": codex, "agy": agy}
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

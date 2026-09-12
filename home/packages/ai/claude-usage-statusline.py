#!/usr/bin/env python3
"""Claude Code statusLine command that records the plan's rate limits.

Claude Code hands every statusLine render a JSON document with `rate_limits`
taken from its own API response headers. Writing them to the Sketchybar cache
gives the usage widget Claude's numbers without a single call to
api.anthropic.com/api/oauth/usage, whose per-token budget Claude Code itself
consumes. Nothing is printed, so the status line stays empty.
"""

import json
import os
import shutil
import subprocess
import sys
import tempfile

CACHE_DIR = os.path.expanduser("~/.cache/sketchybar")
CACHE_FILE = os.path.join(CACHE_DIR, "claude-usage.json")
CLAUDE_PAGE = "https://claude.ai/settings/usage"
LABELS = {"five_hour": "5h", "seven_day": "7d"}


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except ValueError:
        return 0
    limits = payload.get("rate_limits") if isinstance(payload, dict) else None
    if not isinstance(limits, dict):
        return 0

    windows = []
    for kind, label in LABELS.items():
        window = limits.get(kind)
        if not isinstance(window, dict):
            continue
        windows.append(
            {
                "label": label,
                "percent": window.get("used_percentage") or 0,
                "resets_at": window.get("resets_at"),
            }
        )
    if not windows:
        return 0

    document = {"providers": [{"key": "claude", "name": "Claude", "url": CLAUDE_PAGE, "windows": windows}]}
    encoded = json.dumps(document, separators=(",", ":"))
    try:
        with open(CACHE_FILE) as handle:
            if handle.read() == encoded:
                return 0
    except OSError:
        pass

    os.makedirs(CACHE_DIR, exist_ok=True)
    fd, temp = tempfile.mkstemp(dir=CACHE_DIR, prefix=".claude-usage.")
    with os.fdopen(fd, "w") as handle:
        handle.write(encoded)
    os.replace(temp, CACHE_FILE)

    sketchybar = os.environ.get("SKETCHYBAR") or shutil.which("sketchybar")
    if sketchybar:
        subprocess.run([sketchybar, "--trigger", "claude_usage"], check=False, timeout=5)
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Clone and update a list of read-only repositories under ~/ref."""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from urllib.parse import urlparse

RETRIES = 3
RETRY_DELAY = 5

# Retrying these only makes a failure take 10 seconds longer.
PERMANENT = ("not found", "does not exist", "authentication failed", "access denied")


class Failure(Exception):
    pass


def repo_path(root: Path, url: str) -> Path:
    path = urlparse(url).path.strip("/")
    if path.endswith(".git"):
        path = path[: -len(".git")]
    parts = path.split("/")
    return root / parts[-2] / parts[-1] if len(parts) >= 2 else root / parts[-1]


def git(*args: str, cwd: Path | None = None) -> str:
    done = subprocess.run(
        ["git", *args],
        cwd=cwd,
        capture_output=True,
        text=True,
    )
    if done.returncode != 0:
        raise Failure((done.stderr or done.stdout).strip().splitlines()[-1])
    return done.stdout.strip()


def with_retries(action, what: str):
    for attempt in range(1, RETRIES + 1):
        try:
            return action()
        except Failure as err:
            if attempt == RETRIES or any(p in str(err).lower() for p in PERMANENT):
                raise
            time.sleep(RETRY_DELAY)
    raise Failure(what)


def clone(url: str, dest: Path) -> str:
    dest.parent.mkdir(parents=True, exist_ok=True)
    with_retries(lambda: git("clone", "--quiet", url, str(dest)), "clone")
    return "cloned"


def update(dest: Path) -> str:
    with_retries(lambda: git("fetch", "--quiet", "--prune", "--tags", cwd=dest), "fetch")

    try:
        upstream = git("rev-parse", "--abbrev-ref", "@{u}", cwd=dest)
    except Failure:
        return "fetched (no upstream)"

    before = git("rev-parse", "HEAD", cwd=dest)
    after = git("rev-parse", upstream, cwd=dest)
    if before == after:
        return "up to date"

    if git("status", "--porcelain", cwd=dest):
        return f"fetched ({before[:7]}..{after[:7]} not merged, tree is dirty)"

    git("merge", "--quiet", "--ff-only", upstream, cwd=dest)
    return f"updated {before[:7]}..{after[:7]}"


def sync(url: str, root: Path) -> tuple[str, str, str | None]:
    dest = repo_path(root, url)
    name = str(dest.relative_to(root))
    try:
        return name, (update(dest) if dest.exists() else clone(url, dest)), None
    except Failure as err:
        return name, "failed", str(err)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repos", type=Path, required=True, help="file with one URL per line")
    parser.add_argument("--dir", type=Path, default=Path(os.environ.get("GIT_SYNC_DIR", "~/ref")))
    parser.add_argument("--jobs", type=int, default=5)
    args = parser.parse_args()

    root = args.dir.expanduser()
    urls = [
        line.strip()
        for line in args.repos.read_text().splitlines()
        if line.strip() and not line.startswith("#")
    ]

    print(f"Syncing {len(urls)} repositories into {root}")
    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = list(pool.map(lambda url: sync(url, root), urls))

    for name, status, error in sorted(results):
        print(f"  {name}: {error if error else status}")

    failed = [name for name, _, error in results if error]
    if failed:
        print(f"\n{len(failed)} of {len(urls)} failed: {', '.join(sorted(failed))}", file=sys.stderr)
        return 1

    print(f"\n{len(urls)} repositories synced")
    return 0


if __name__ == "__main__":
    sys.exit(main())

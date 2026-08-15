#!/usr/bin/env python3
"""Synchronize checked-out branches in Git repositories under ~/dev."""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path


class GitError(Exception):
    pass


def git(repo: Path, *args: str, check: bool = True) -> str:
    done = subprocess.run(
        ["git", "-C", str(repo), *args],
        capture_output=True,
        text=True,
    )
    if check and done.returncode != 0:
        output = (done.stderr or done.stdout).strip()
        raise GitError(output.splitlines()[-1] if output else "git command failed")
    return done.stdout.strip()


def repositories(root: Path) -> list[Path]:
    if not root.is_dir():
        raise GitError(f"directory does not exist: {root}")

    return sorted(
        path
        for path in root.iterdir()
        if path.is_dir()
        and git(path, "rev-parse", "--is-inside-work-tree", check=False) == "true"
    )


def counts(repo: Path) -> tuple[int, int]:
    output = git(repo, "rev-list", "--left-right", "--count", "HEAD...@{upstream}")
    ahead, behind = output.split()
    return int(ahead), int(behind)


def sync(repo: Path) -> str:
    git(repo, "fetch", "--quiet", "--prune")

    branch = git(repo, "symbolic-ref", "--quiet", "--short", "HEAD", check=False)
    if not branch:
        raise GitError("detached HEAD")

    upstream = git(
        repo,
        "rev-parse",
        "--abbrev-ref",
        "--symbolic-full-name",
        "@{upstream}",
        check=False,
    )
    if not upstream:
        raise GitError(f"{branch} has no upstream")

    ahead, behind = counts(repo)
    dirty = bool(git(repo, "status", "--porcelain"))

    if behind and dirty:
        state = "diverged" if ahead else "behind"
        raise GitError(f"{state} {upstream}, working tree is dirty")

    rebased = False
    if behind:
        try:
            git(repo, "rebase", upstream)
        except GitError as error:
            git(repo, "rebase", "--abort", check=False)
            raise GitError(f"rebase failed: {error}") from error
        rebased = True
        ahead, _ = counts(repo)

    if ahead:
        git(repo, "push", "--quiet")
        if rebased:
            return f"rebased onto {upstream} and pushed {ahead} commit(s)"
        return f"pushed {ahead} commit(s)"

    if rebased:
        return f"updated from {upstream}"
    return "up to date"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(os.environ.get("SYNC_DEV_ROOT", "~/dev")),
        help="directory whose immediate children are repositories (default: ~/dev)",
    )
    args = parser.parse_args()
    root = args.root.expanduser()

    try:
        repos = repositories(root)
    except GitError as error:
        print(f"sync-dev: {error}", file=sys.stderr)
        return 1

    print(f"Syncing {len(repos)} repositories under {root}")
    failures = 0
    for repo in repos:
        try:
            result = sync(repo)
            print(f"  {repo.name}: {result}")
        except GitError as error:
            failures += 1
            print(f"  {repo.name}: {error}", file=sys.stderr)

    if failures:
        print(f"\n{failures} of {len(repos)} repositories need attention", file=sys.stderr)
        return 1

    print(f"\n{len(repos)} repositories synced")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""PreToolUse hook shared by Claude Code, Codex and agy.

Refuses to pull a whole large file into the context: a read without a limit,
or a `cat`/`head -n 5000`/`sed -n 1,9000p` in a shell command. Everything that
lands in the context is re-read on every call for the rest of the session, so
the cheap moment to say no is before the read.

Exit 2 with a message on stderr blocks the call and hands the message to the
model; that is the one convention the three CLIs share. Tune with
GUARD_MAX_LINES (default 400).
"""

import json
import os
import re
import shlex
import sys

MAX_LINES = int(os.environ.get("GUARD_MAX_LINES", "400"))

# Read tools and the fields that bound a read, per CLI.
READ_TOOLS = {"Read", "read", "read_file", "view_file", "read_many_files"}
PATH_KEYS = ("file_path", "path", "absolute_path", "AbsolutePath")
BOUND_KEYS = ("limit", "end_line", "EndLine")
COMMAND_KEYS = ("command", "cmd", "command_line", "CommandLine")
DUMPERS = {"cat", "less", "more", "bat", "batcat"}


def line_count(path):
    try:
        with open(os.path.expanduser(path), "rb") as fh:
            return sum(1 for _ in fh)
    except OSError:
        return None


def block(message):
    sys.stderr.write(message + "\n")
    sys.exit(2)


def advice(path, count):
    return (
        f"{path} has {count} lines, more than the {MAX_LINES} allowed in one read. "
        "Read the part you need with offset/limit, search it with grep, or delegate the "
        "reading to a subagent and keep only its answer: everything read here is re-sent "
        "on every call for the rest of the session."
    )


def check_read(inputs):
    path = next((inputs[k] for k in PATH_KEYS if inputs.get(k)), None)
    if not path or any(inputs.get(k) for k in BOUND_KEYS):
        return
    count = line_count(path)
    if count and count > MAX_LINES:
        block(advice(path, count))


def segments(command):
    # Shell control operators split the command line into independent segments.
    for segment in re.split(r"\|\||&&|[|;]", command):
        try:
            words = shlex.split(segment)
        except ValueError:
            continue
        if words:
            yield words


def files_in(words):
    return [w for w in words[1:] if not w.startswith("-") and os.path.isfile(os.path.expanduser(w))]


def head_tail_limit(words):
    for i, w in enumerate(words):
        m = re.fullmatch(r"-n?(\d+)", w) or re.fullmatch(r"-n(\d+)", w)
        if m:
            return int(m.group(1))
        if w in ("-n", "--lines") and i + 1 < len(words) and words[i + 1].isdigit():
            return int(words[i + 1])
    return 10  # the default for head and tail


def sed_range(words):
    for w in words:
        m = re.fullmatch(r"'?(\d+),(\d+)p'?", w)
        if m:
            return int(m.group(2)) - int(m.group(1)) + 1
    return None


def unwrap_shell(words):
    # Codex runs `["bash", "-lc", "<script>"]`: the script is the command.
    if len(words) >= 3 and os.path.basename(words[0]) in ("sh", "bash", "zsh", "fish") and words[1].startswith("-") and "c" in words[1]:
        return words[2]
    return None


def check_command(command):
    if isinstance(command, list):
        command = unwrap_shell(command) or " ".join(shlex.quote(w) for w in command)
    if not isinstance(command, str):
        return
    for words in segments(command):
        inner = unwrap_shell(words)
        if inner:
            check_command(inner)
            continue
        name = os.path.basename(words[0])
        if name in DUMPERS:
            for path in files_in(words):
                count = line_count(path)
                if count and count > MAX_LINES:
                    block(advice(path, count))
        elif name in ("head", "tail"):
            if head_tail_limit(words) > MAX_LINES and files_in(words):
                block(f"`{name}` asks for more than {MAX_LINES} lines. Narrow the range, or grep for what you need.")
        elif name == "sed":
            span = sed_range(words)
            if span and span > MAX_LINES and files_in(words):
                block(f"`sed -n` prints {span} lines, more than the {MAX_LINES} allowed. Narrow the range, or grep for what you need.")


def main():
    try:
        data = json.load(sys.stdin)
    except ValueError:
        return
    tool = data.get("tool_name") or data.get("toolName") or ""
    inputs = data.get("tool_input") or data.get("toolInput") or data.get("tool_args") or {}
    if not isinstance(inputs, dict):
        return
    if tool in READ_TOOLS:
        check_read(inputs)
    command = next((inputs[k] for k in COMMAND_KEYS if inputs.get(k)), None)
    if command is not None:
        check_command(command)


if __name__ == "__main__":
    main()

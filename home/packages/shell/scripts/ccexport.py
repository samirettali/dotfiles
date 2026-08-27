#!/usr/bin/env python3
"""Export a Claude Code conversation to a single, self-contained HTML page.

The transcripts live as JSON Lines under ~/.claude/projects/<slug>/<id>.jsonl,
one record per line and many kinds of record — modes, file snapshots, titles —
of which only `user` and `assistant` carry the conversation.

Prompts and answers are the page; tool calls and thinking are kept but folded
away, because the reason to reopen a conversation months later is a sentence
somebody wrote, not the fifty greps it took to write it.
"""

from __future__ import annotations

import argparse
import datetime
import glob
import html
import json
import os
import re
import sys
import webbrowser

PROJECTS = os.path.expanduser("~/.claude/projects")

# Wrappers the CLI puts around its own machinery. None of them was typed by
# anybody, and a page full of them reads as a log rather than a conversation.
NOISE = re.compile(
    r"<(local-command-caveat|system-reminder|task-notification|command-message"
    r"|command-args|local-command-stdout)>.*?</\1>",
    re.DOTALL,
)
COMMAND = re.compile(r"<command-name>(.*?)</command-name>", re.DOTALL)


# --------------------------------------------------------------------------
# finding a transcript


def transcripts() -> list[str]:
    return sorted(
        glob.glob(os.path.join(PROJECTS, "*", "*.jsonl")),
        key=os.path.getmtime,
        reverse=True,
    )


def resolve(wanted: str) -> str:
    """Accept a full id, a unique prefix, or a path to the file itself."""
    if os.path.isfile(wanted):
        return wanted
    files = transcripts()
    exact = [f for f in files if os.path.basename(f)[:-6] == wanted]
    if exact:
        return exact[0]
    hits = [f for f in files if os.path.basename(f).startswith(wanted)]
    if not hits:
        sys.exit(f"no conversation whose id starts with {wanted!r}")
    if len(hits) > 1:
        names = "\n  ".join(os.path.basename(f)[:-6] for f in hits[:10])
        sys.exit(f"{wanted!r} matches several conversations:\n  {names}")
    return hits[0]


def project_of(path: str) -> str:
    slug = os.path.basename(os.path.dirname(path))
    return "/" + slug.lstrip("-").replace("-", "/")


def tail_title(path: str, window: int = 262144) -> str:
    """The title is written repeatedly and late, so read the end of the file.

    A transcript runs to tens of megabytes; listing a hundred of them by
    parsing every line takes seconds, and reading the last quarter megabyte
    takes none.
    """
    with open(path, "rb") as fh:
        fh.seek(0, os.SEEK_END)
        fh.seek(max(0, fh.tell() - window))
        chunk = fh.read().decode("utf-8", "replace")
    title = ""
    for line in chunk.splitlines():
        if '"ai-title"' not in line:
            continue
        try:
            rec = json.loads(line)
        except ValueError:
            continue
        if rec.get("aiTitle"):
            title = rec["aiTitle"]
    return title


def first_prompt(path: str) -> str:
    for rec in records(path):
        if rec.get("type") != "user" or rec.get("isMeta"):
            continue
        content = rec.get("message", {}).get("content")
        if not isinstance(content, str):
            continue
        text = clean_user(content)
        if text:
            return " ".join(text.split())[:90]
    return ""


def records(path: str):
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line)
            except ValueError:
                continue


def do_list(limit: int, project: str | None) -> None:
    shown = 0
    for path in transcripts():
        if project and project not in os.path.basename(os.path.dirname(path)):
            continue
        when = datetime.datetime.fromtimestamp(os.path.getmtime(path))
        title = tail_title(path) or first_prompt(path) or "(senza titolo)"
        size = os.path.getsize(path) / 1e6
        print(
            f"{os.path.basename(path)[:-6][:8]}  {when:%Y-%m-%d %H:%M}  "
            f"{size:6.1f}MB  {project_of(path):<28} {title[:70]}"
        )
        shown += 1
        if shown >= limit:
            break


# --------------------------------------------------------------------------
# a very small markdown


FENCE = re.compile(r"^```(\w*)\s*$")
TABLE_SEP = re.compile(r"^\s*\|?[\s:|-]+\|[\s:|-]*$")


def inline(text: str) -> str:
    out = []
    # Code spans are protected from everything else: a path in backticks is
    # full of underscores and asterisks that are not emphasis.
    parts = re.split(r"(`[^`]+`)", text)
    for part in parts:
        if part.startswith("`") and part.endswith("`") and len(part) > 1:
            out.append(f"<code>{html.escape(part[1:-1])}</code>")
            continue
        s = html.escape(part)
        s = re.sub(r"\[([^\]]+)\]\(([^)\s]+)\)", r'<a href="\2">\1</a>', s)
        s = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", s)
        s = re.sub(r"(?<![\w*])\*([^*\n]+)\*(?![\w*])", r"<em>\1</em>", s)
        s = re.sub(r"(?<![\w_])_([^_\n]+)_(?![\w_])", r"<em>\1</em>", s)
        out.append(s)
    return "".join(out)


def cells(row: str) -> list[str]:
    row = row.strip()
    if row.startswith("|"):
        row = row[1:]
    if row.endswith("|"):
        row = row[:-1]
    return [c.strip() for c in row.split("|")]


def markdown(text: str) -> str:
    lines = text.split("\n")
    out: list[str] = []
    i = 0
    while i < len(lines):
        line = lines[i]

        m = FENCE.match(line)
        if m:
            lang = m.group(1)
            i += 1
            body = []
            while i < len(lines) and not FENCE.match(lines[i]):
                body.append(lines[i])
                i += 1
            i += 1
            code = html.escape("\n".join(body))
            cls = f' class="language-{lang}"' if lang else ""
            out.append(f"<pre><code{cls}>{code}</code></pre>")
            continue

        if not line.strip():
            i += 1
            continue

        if re.match(r"^\s*([-*_]\s*){3,}$", line):
            out.append("<hr>")
            i += 1
            continue

        m = re.match(r"^(#{1,6})\s+(.*)$", line)
        if m:
            level = min(len(m.group(1)) + 1, 6)
            out.append(f"<h{level}>{inline(m.group(2))}</h{level}>")
            i += 1
            continue

        # A table needs its separator row on the next line, or it is prose
        # that happens to contain a pipe.
        if "|" in line and i + 1 < len(lines) and TABLE_SEP.match(lines[i + 1]):
            head = cells(line)
            i += 2
            body = []
            while i < len(lines) and "|" in lines[i]:
                body.append(cells(lines[i]))
                i += 1
            th = "".join(f"<th>{inline(c)}</th>" for c in head)
            rows = "".join(
                "<tr>" + "".join(f"<td>{inline(c)}</td>" for c in r) + "</tr>"
                for r in body
            )
            out.append(f"<table><thead><tr>{th}</tr></thead><tbody>{rows}</tbody></table>")
            continue

        if re.match(r"^\s*>", line):
            body = []
            while i < len(lines) and re.match(r"^\s*>", lines[i]):
                body.append(re.sub(r"^\s*>\s?", "", lines[i]))
                i += 1
            out.append(f"<blockquote>{markdown(chr(10).join(body))}</blockquote>")
            continue

        m = re.match(r"^\s*([-*+]|\d+[.)])\s+", line)
        if m:
            ordered = not m.group(1) in "-*+"
            items: list[str] = []
            while i < len(lines):
                m = re.match(r"^\s*(?:[-*+]|\d+[.)])\s+(.*)$", lines[i])
                if m:
                    items.append(m.group(1))
                    i += 1
                elif lines[i].startswith(("    ", "\t")) and items:
                    items[-1] += "\n" + lines[i].strip()
                    i += 1
                else:
                    break
            tag = "ol" if ordered else "ul"
            body = "".join(f"<li>{inline(it)}</li>" for it in items)
            out.append(f"<{tag}>{body}</{tag}>")
            continue

        para = []
        while i < len(lines) and lines[i].strip() and not FENCE.match(lines[i]):
            if re.match(r"^\s*(#{1,6}\s|>|([-*+]|\d+[.)])\s)", lines[i]) and para:
                break
            para.append(lines[i])
            i += 1
        out.append("<p>" + inline("\n".join(para)).replace("\n", "<br>") + "</p>")

    return "\n".join(out)


# --------------------------------------------------------------------------
# the conversation


def clean_user(text: str) -> str:
    commands = COMMAND.findall(text)
    text = NOISE.sub("", text)
    text = COMMAND.sub("", text)
    text = text.strip()
    if commands:
        slash = " ".join(f"/{c.strip().lstrip('/')}" for c in commands)
        text = f"`{slash}`\n\n{text}".strip()
    return text


def block_text(content) -> str:
    """Tool results arrive as a string or as a list of blocks."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return "\n".join(
            b.get("text", "") for b in content if isinstance(b, dict) and b.get("type") == "text"
        )
    return ""


def details(summary: str, body: str, cls: str) -> str:
    return f'<details class="{cls}"><summary>{summary}</summary>{body}</details>'


def pre(text: str, limit: int = 20000) -> str:
    text = text or ""
    cut = len(text) > limit
    if cut:
        text = text[:limit] + f"\n… [{len(text) - limit} caratteri in meno]"
    return f"<pre><code>{html.escape(text)}</code></pre>"


def render(path: str, sidechains: bool, keep_tools: bool, keep_thinking: bool):
    results: dict[str, dict] = {}
    for rec in records(path):
        if rec.get("type") != "user":
            continue
        content = rec.get("message", {}).get("content")
        if not isinstance(content, list):
            continue
        for b in content:
            if isinstance(b, dict) and b.get("type") == "tool_result":
                results[b.get("tool_use_id", "")] = b

    parts: list[str] = []
    stats = {"user": 0, "assistant": 0, "tools": 0}
    models: set[str] = set()
    first = last = None
    open_turn = False

    def close():
        nonlocal open_turn
        if open_turn:
            parts.append("</div>")
            open_turn = False

    for rec in records(path):
        kind = rec.get("type")
        if kind not in ("user", "assistant"):
            continue
        if rec.get("isSidechain") and not sidechains:
            continue
        ts = rec.get("timestamp")
        if ts:
            first = first or ts
            last = ts
        message = rec.get("message", {}) or {}
        content = message.get("content")

        if kind == "user":
            if rec.get("isMeta"):
                continue
            text = clean_user(content) if isinstance(content, str) else ""
            if not text:
                continue
            close()
            stats["user"] += 1
            when = stamp(ts)
            parts.append(
                f'<div class="turn user"><div class="who">tu<span>{when}</span></div>'
                f'<div class="body">{markdown(text)}</div></div>'
            )
            continue

        if message.get("model"):
            models.add(message["model"])
        blocks = content if isinstance(content, list) else []
        rendered: list[str] = []
        for b in blocks:
            if not isinstance(b, dict):
                continue
            t = b.get("type")
            if t == "text" and b.get("text", "").strip():
                rendered.append(f'<div class="body">{markdown(b["text"])}</div>')
            elif t == "thinking" and keep_thinking and b.get("thinking", "").strip():
                rendered.append(
                    details("ragionamento", f'<div class="body">{markdown(b["thinking"])}</div>', "think")
                )
            elif t == "tool_use" and keep_tools:
                stats["tools"] += 1
                name = html.escape(str(b.get("name", "tool")))
                arg = b.get("input", {})
                hint = ""
                for k in ("command", "file_path", "pattern", "path", "url", "prompt", "description"):
                    if isinstance(arg, dict) and arg.get(k):
                        hint = " ".join(str(arg[k]).split())[:110]
                        break
                res = results.get(b.get("id", ""))
                body = pre(json.dumps(arg, indent=2, ensure_ascii=False))
                if res is not None:
                    body += '<div class="label">risultato</div>' + pre(block_text(res.get("content")))
                bad = " error" if res is not None and res.get("is_error") else ""
                rendered.append(
                    details(
                        f'<span class="tool{bad}">{name}</span> <span class="hint">{html.escape(hint)}</span>',
                        body,
                        "tool",
                    )
                )
        if not rendered:
            continue
        stats["assistant"] += 1
        if not open_turn:
            parts.append(f'<div class="turn claude"><div class="who">claude<span>{stamp(ts)}</span></div>')
            open_turn = True
        parts.extend(rendered)

    close()
    return "\n".join(parts), stats, models, first, last


def stamp(ts: str | None) -> str:
    if not ts:
        return ""
    try:
        when = datetime.datetime.fromisoformat(ts.replace("Z", "+00:00")).astimezone()
    except ValueError:
        return ""
    return when.strftime("%d/%m/%Y %H:%M")


CSS = """
:root{color-scheme:light dark;--bg:#fbfaf8;--fg:#1c1b19;--faint:#6f6a62;--line:#e2ded6;
--card:#fff;--user:#f2efe8;--code:#f4f1ea;--accent:#8a5a2b}
@media (prefers-color-scheme:dark){:root{--bg:#15140f;--fg:#e9e5dc;--faint:#948d80;
--line:#2c2a24;--card:#1b1a15;--user:#22201a;--code:#211f19;--accent:#d0a26a}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--fg);
font:16px/1.65 -apple-system,BlinkMacSystemFont,"Segoe UI",Inter,sans-serif}
header{position:sticky;top:0;z-index:2;background:var(--bg);border-bottom:1px solid var(--line);
padding:14px 24px}
header h1{margin:0;font-size:18px;font-weight:600}
header .meta{color:var(--faint);font-size:12.5px;margin-top:4px;
text-transform:uppercase;letter-spacing:.04em}
header .controls{margin-top:8px;display:flex;gap:14px;font-size:13px}
header button{background:none;border:0;color:var(--accent);cursor:pointer;padding:0;font:inherit}
main{max-width:820px;margin:0 auto;padding:28px 24px 120px}
.turn{margin:0 0 26px}
.turn.user{background:var(--user);border-radius:10px;padding:14px 18px}
.who{font-size:11.5px;text-transform:uppercase;letter-spacing:.08em;color:var(--faint);
margin-bottom:6px;display:flex;gap:10px}
.who span{opacity:.7;text-transform:none;letter-spacing:0}
.body{overflow-wrap:anywhere}
.body>*:first-child{margin-top:0}.body>*:last-child{margin-bottom:0}
p{margin:.6em 0}
h2,h3,h4,h5,h6{margin:1.4em 0 .5em;line-height:1.3}
code{background:var(--code);padding:.1em .35em;border-radius:4px;
font:13.5px/1.5 ui-monospace,SFMono-Regular,Menlo,monospace}
pre{background:var(--code);border:1px solid var(--line);border-radius:8px;padding:12px 14px;
overflow-x:auto}
pre code{background:none;padding:0}
table{border-collapse:collapse;margin:1em 0;display:block;overflow-x:auto}
th,td{border:1px solid var(--line);padding:6px 10px;text-align:left;vertical-align:top}
th{background:var(--code)}
blockquote{margin:1em 0;padding-left:14px;border-left:3px solid var(--line);color:var(--faint)}
a{color:var(--accent)}
hr{border:0;border-top:1px solid var(--line);margin:1.6em 0}
details{margin:8px 0;border:1px solid var(--line);border-radius:8px;background:var(--card)}
details>summary{cursor:pointer;padding:7px 12px;font-size:13.5px;color:var(--faint);
list-style:none;display:flex;gap:8px;align-items:baseline}
details>summary::-webkit-details-marker{display:none}
details>summary::before{content:"▸";font-size:11px}
details[open]>summary::before{content:"▾"}
details>*:not(summary){margin:0 12px 12px}
details.tool .tool{font-family:ui-monospace,Menlo,monospace;color:var(--fg)}
details.tool .tool.error{color:#c0392b}
details.tool .hint{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
details.think>summary{font-style:italic}
.label{font-size:11.5px;text-transform:uppercase;letter-spacing:.08em;color:var(--faint);
margin:10px 12px 4px}
"""

JS = """
function all(open){document.querySelectorAll('details').forEach(d=>d.open=open)}
"""


def page(title: str, meta: str, body: str) -> str:
    return f"""<!doctype html>
<html lang="it"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{html.escape(title)}</title>
<style>{CSS}</style></head>
<body><header><h1>{html.escape(title)}</h1>
<div class="meta">{meta}</div>
<div class="controls"><button onclick="all(true)">apri tutto</button>
<button onclick="all(false)">chiudi tutto</button></div></header>
<main>{body}</main>
<script>{JS}</script></body></html>
"""


def slug(text: str) -> str:
    text = re.sub(r"[^\w\s-]", "", text.lower()).strip()
    return re.sub(r"[\s_-]+", "-", text)[:60] or "conversazione"


def main() -> None:
    ap = argparse.ArgumentParser(
        description="Esporta una conversazione di Claude Code in una pagina HTML."
    )
    ap.add_argument("id", nargs="?", help="id della sessione, un suo prefisso, o un file .jsonl")
    ap.add_argument("-l", "--list", action="store_true", help="elenca le conversazioni recenti")
    ap.add_argument("-n", type=int, default=30, help="quante elencarne (default 30)")
    ap.add_argument("-p", "--project", help="filtra l'elenco per progetto")
    ap.add_argument("-o", "--out", help="file di destinazione, - per stdout")
    ap.add_argument("--open", action="store_true", help="aprilo nel browser")
    ap.add_argument("--sidechains", action="store_true", help="includi i subagent")
    ap.add_argument("--no-tools", action="store_true", help="ometti le tool call")
    ap.add_argument("--no-thinking", action="store_true", help="ometti il ragionamento")
    args = ap.parse_args()

    if args.list or not args.id:
        do_list(args.n, args.project)
        if not args.id and not args.list:
            sys.exit(1)
        return

    path = resolve(args.id)
    body, stats, models, first, last = render(
        path, args.sidechains, not args.no_tools, not args.no_thinking
    )
    title = tail_title(path) or first_prompt(path) or "Conversazione"
    session = os.path.basename(path)[:-6]
    meta = " · ".join(
        x
        for x in [
            html.escape(project_of(path)),
            stamp(first),
            f"{stats['user']} prompt",
            f"{stats['tools']} tool" if stats["tools"] else "",
            html.escape(", ".join(sorted(m.replace("claude-", "") for m in models))),
            session[:8],
        ]
        if x
    )
    doc = page(title, meta, body)

    if args.out == "-":
        sys.stdout.write(doc)
        return
    out = args.out or f"{slug(title)}-{session[:8]}.html"
    with open(out, "w", encoding="utf-8") as fh:
        fh.write(doc)
    print(os.path.abspath(out))
    if args.open:
        webbrowser.open("file://" + os.path.abspath(out))


if __name__ == "__main__":
    main()

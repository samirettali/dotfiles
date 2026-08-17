# /// script
# requires-python = ">=3.10"
# dependencies = ["httpx==0.28.1"]
# ///

import argparse
import datetime as dt
import email.utils
import json
import os
import sys
import time

import httpx

BASE_URL = "https://api.x.ai/v1/responses"
MODEL = "grok-4.6"
MAX_HANDLES = 20
RETRIES = 2
RETRYABLE_STATUS_CODES = {408, 429, 500, 502, 503, 504}
TIMEOUT = httpx.Timeout(300, connect=10)
# A broad query can cite fifty posts; that buries the answer. --json keeps them all.
SHOWN_CITATIONS = 15


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Search current X posts through xAI's hosted X Search.")
    parser.add_argument("query", help="What to search for on X")
    parser.add_argument(
        "--handle",
        action="append",
        default=[],
        metavar="HANDLE",
        help="Only search posts from this handle, without @; repeatable",
    )
    parser.add_argument(
        "--exclude-handle",
        action="append",
        default=[],
        metavar="HANDLE",
        help="Exclude posts from this handle, without @; repeatable",
    )
    parser.add_argument("--from", dest="from_date", metavar="YYYY-MM-DD", help="Earliest post date")
    parser.add_argument("--to", dest="to_date", metavar="YYYY-MM-DD", help="Latest post date")
    parser.add_argument("--images", action="store_true", help="Also read images attached to matching posts")
    parser.add_argument("--videos", action="store_true", help="Also read videos attached to matching posts")
    parser.add_argument("--json", action="store_true", help="Print the raw answer and citations as JSON")
    return parser.parse_args()


def normalize_handles(handles: list[str], flag: str) -> list[str]:
    seen: list[str] = []
    for handle in handles:
        cleaned = handle.strip().lstrip("@")
        if cleaned and cleaned not in seen:
            seen.append(cleaned)
    if len(seen) > MAX_HANDLES:
        raise SystemExit(f"{flag} accepts at most {MAX_HANDLES} handles")
    return seen


def parse_date(value: str | None, flag: str) -> dt.date | None:
    if value is None:
        return None
    try:
        return dt.date.fromisoformat(value)
    except ValueError:
        raise SystemExit(f"{flag} must be a valid YYYY-MM-DD date")


def validate_dates(from_date: str | None, to_date: str | None) -> None:
    start = parse_date(from_date, "--from")
    end = parse_date(to_date, "--to")
    if start and end and start > end:
        raise SystemExit("--from must be on or before --to")
    today = dt.datetime.now(dt.timezone.utc).date()
    if start and start > today:
        raise SystemExit(f"--from cannot be in the future (today is {today.isoformat()})")


def build_tool(args: argparse.Namespace, allowed: list[str], excluded: list[str]) -> dict:
    tool: dict = {"type": "x_search"}
    if allowed:
        tool["allowed_x_handles"] = allowed
    if excluded:
        tool["excluded_x_handles"] = excluded
    if args.from_date:
        tool["from_date"] = args.from_date
    if args.to_date:
        tool["to_date"] = args.to_date
    if args.images:
        tool["enable_image_understanding"] = True
    if args.videos:
        tool["enable_video_understanding"] = True
    return tool


def retry_delay(response: httpx.Response | None, attempt: int) -> float:
    if response is not None and (value := response.headers.get("Retry-After")):
        try:
            return max(0, float(value))
        except ValueError:
            try:
                retry_at = email.utils.parsedate_to_datetime(value)
                if retry_at.tzinfo is None:
                    retry_at = retry_at.replace(tzinfo=dt.timezone.utc)
                return max(0, (retry_at - dt.datetime.now(dt.timezone.utc)).total_seconds())
            except (TypeError, ValueError):
                pass
    return 2**attempt


def request(api_key: str, query: str, tool: dict) -> dict:
    payload = {
        "model": MODEL,
        "input": [{"role": "user", "content": query}],
        "tools": [tool],
        "store": False,
    }
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}

    with httpx.Client(timeout=TIMEOUT) as client:
        for attempt in range(RETRIES + 1):
            try:
                response = client.post(BASE_URL, headers=headers, json=payload)
            except (httpx.ConnectError, httpx.ConnectTimeout) as error:
                if attempt == RETRIES:
                    raise SystemExit(f"xAI connection failed: {error}") from error
                time.sleep(retry_delay(None, attempt))
                continue
            except httpx.TransportError as error:
                raise SystemExit(f"xAI request failed: {error}") from error

            if response.status_code not in RETRYABLE_STATUS_CODES or attempt == RETRIES:
                break
            time.sleep(retry_delay(response, attempt))

    try:
        body = response.json()
    except ValueError:
        raise SystemExit(f"xAI returned invalid JSON (HTTP {response.status_code})")

    if response.status_code >= 400 or body.get("error"):
        raise SystemExit(f"xAI request failed ({response.status_code}): {error_message(body)}")
    return body


def error_message(body: dict) -> str:
    error = body.get("error")
    if isinstance(error, str):
        return error
    if isinstance(error, dict):
        return str(error.get("message") or error.get("code") or error)
    return str(body.get("message") or body.get("code") or "unknown error")


def extract_answer(body: dict) -> str:
    text = body.get("output_text")
    if isinstance(text, str) and text.strip():
        return text.strip()

    parts: list[str] = []
    for item in body.get("output") or []:
        if item.get("type") != "message":
            continue
        for content in item.get("content") or []:
            if content.get("type") in {"output_text", "text"} and isinstance(content.get("text"), str):
                parts.append(content["text"].strip())
    return "\n\n".join(part for part in parts if part)


def extract_citations(body: dict) -> list[dict]:
    citations: list[dict] = []
    seen: set[str] = set()

    def add(url: str | None, title: str | None) -> None:
        if not url or url in seen:
            return
        seen.add(url)
        # xAI often has no real title: it sends the citation index, or the URL again.
        if title is not None and (title.strip().isdigit() or title.strip() == url):
            title = None
        citations.append({"url": url, "title": title})

    for citation in body.get("citations") or []:
        if isinstance(citation, str):
            add(citation, None)
        elif isinstance(citation, dict):
            add(citation.get("url"), citation.get("title"))

    for item in body.get("output") or []:
        if item.get("type") != "message":
            continue
        for content in item.get("content") or []:
            for annotation in content.get("annotations") or []:
                if annotation.get("type") == "url_citation":
                    add(annotation.get("url"), annotation.get("title"))

    return citations


def report_usage(body: dict) -> None:
    sys.stdout.flush()
    usage = body.get("usage") or {}
    tools = usage.get("server_side_tool_usage_details") or {}
    calls = tools.get("x_search_calls", 0)
    print(
        f"[{usage.get('input_tokens', 0)} in / {usage.get('output_tokens', 0)} out tokens, "
        f"{calls} x_search call(s)]",
        file=sys.stderr,
    )


def main() -> None:
    args = parse_args()
    if not args.query.strip():
        raise SystemExit("query is empty")

    allowed = normalize_handles(args.handle, "--handle")
    excluded = normalize_handles(args.exclude_handle, "--exclude-handle")
    if allowed and excluded:
        raise SystemExit("--handle and --exclude-handle cannot be combined")
    validate_dates(args.from_date, args.to_date)

    api_key = os.environ.get("XAI_API_KEY")
    if not api_key:
        raise SystemExit("XAI_API_KEY is not set")

    tool = build_tool(args, allowed, excluded)
    body = request(api_key, args.query.strip(), tool)

    answer = extract_answer(body)
    citations = extract_citations(body)
    filtered = bool(allowed or excluded or args.from_date or args.to_date)

    if args.json:
        print(json.dumps({"answer": answer, "citations": citations}, indent=2))
    else:
        print(answer or "(no answer returned)")
        if citations:
            print("\nSources:")
            for citation in citations[:SHOWN_CITATIONS]:
                print(f"- {citation['url']}" + (f" — {citation['title']}" if citation["title"] else ""))
            hidden = len(citations) - SHOWN_CITATIONS
            if hidden > 0:
                print(f"- ... and {hidden} more (use --json for all)")

    report_usage(body)
    if filtered and not citations:
        print(
            "warning: filters were active but no posts were cited; the answer may not come from X",
            file=sys.stderr,
        )


if __name__ == "__main__":
    main()

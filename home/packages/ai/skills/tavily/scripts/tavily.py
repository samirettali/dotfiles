# /// script
# requires-python = ">=3.10"
# dependencies = ["httpx==0.28.1"]
# ///

import argparse
import json
import os
import pathlib
import re
import sys
import time

import httpx

SEARCH_URL = "https://api.tavily.com/search"
EXTRACT_URL = "https://api.tavily.com/extract"
USAGE_URL = "https://api.tavily.com/usage"
RETRIES = 2
RETRYABLE_STATUS_CODES = {408, 429, 500, 502, 503, 504}
TIMEOUT = httpx.Timeout(120, connect=10)
MAX_EXTRACT_URLS = 20
# An Amazon product page extracts to 100k characters of navigation chrome.
# Printing that costs more context than the answer is worth, so cap it and
# point at --out for the whole thing.
EXTRACT_PRINT_LIMIT = 20000


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Search the web and extract pages through Tavily.")
    sub = parser.add_subparsers(dest="command", required=True)

    search = sub.add_parser("search", help="Search the web")
    search.add_argument("query", help="What to search for")
    search.add_argument("-n", "--max-results", type=int, default=8, metavar="N", help="Results to return (default 8)")
    search.add_argument("--topic", choices=["general", "news", "finance"], default="general", help="Search index")
    search.add_argument("--days", type=int, metavar="N", help="Only results from the last N days; news topic only")
    search.add_argument("--country", metavar="COUNTRY", help="Boost results from this country, e.g. italy")
    search.add_argument("--depth", choices=["basic", "advanced"], default="basic", help="Advanced costs 2 credits")
    search.add_argument("--no-answer", action="store_true", help="Skip the synthesized answer, return links only")
    search.add_argument("--include-domain", action="append", default=[], metavar="DOMAIN", help="Repeatable")
    search.add_argument("--exclude-domain", action="append", default=[], metavar="DOMAIN", help="Repeatable")
    search.add_argument("--json", action="store_true", help="Print the raw response as JSON")

    extract = sub.add_parser("extract", help="Extract the readable content of pages")
    extract.add_argument("urls", nargs="+", help="Pages to extract, up to 20")
    extract.add_argument("--depth", choices=["basic", "advanced"], default="basic", help="Advanced costs 2 credits")
    extract.add_argument("-o", "--out", metavar="DIR", help="Write each page to DIR instead of printing it")
    extract.add_argument("--json", action="store_true", help="Print the raw response as JSON")

    sub.add_parser("usage", help="Show the plan's credit usage")

    return parser.parse_args()


def request(api_key: str, url: str, payload: dict | None) -> dict:
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}

    with httpx.Client(timeout=TIMEOUT) as client:
        for attempt in range(RETRIES + 1):
            try:
                if payload is None:
                    response = client.get(url, headers=headers)
                else:
                    response = client.post(url, headers=headers, json=payload)
            except (httpx.ConnectError, httpx.ConnectTimeout) as error:
                if attempt == RETRIES:
                    raise SystemExit(f"Tavily connection failed: {error}") from error
                time.sleep(2**attempt)
                continue
            except httpx.TransportError as error:
                raise SystemExit(f"Tavily request failed: {error}") from error

            if response.status_code not in RETRYABLE_STATUS_CODES or attempt == RETRIES:
                break
            time.sleep(2**attempt)

    try:
        body = response.json()
    except ValueError:
        raise SystemExit(f"Tavily returned invalid JSON (HTTP {response.status_code})")

    if response.status_code >= 400:
        detail = body.get("detail")
        if isinstance(detail, dict):
            detail = detail.get("error")
        raise SystemExit(f"Tavily request failed ({response.status_code}): {detail or body}")
    return body


def run_search(api_key: str, args: argparse.Namespace) -> None:
    if not args.query.strip():
        raise SystemExit("query is empty")
    if args.days is not None and args.topic != "news":
        raise SystemExit("--days only applies to --topic news")

    payload: dict = {
        "query": args.query.strip(),
        "max_results": args.max_results,
        "topic": args.topic,
        "search_depth": args.depth,
        "include_answer": False if args.no_answer else "advanced",
    }
    if args.days is not None:
        payload["days"] = args.days
    if args.country:
        payload["country"] = args.country
    if args.include_domain:
        payload["include_domains"] = args.include_domain
    if args.exclude_domain:
        payload["exclude_domains"] = args.exclude_domain

    body = request(api_key, SEARCH_URL, payload)

    if args.json:
        print(json.dumps(body, indent=2))
    else:
        answer = (body.get("answer") or "").strip()
        if answer:
            print(answer)
            print()
        results = body.get("results") or []
        if not results:
            print("(no results)")
        for result in results:
            date = result.get("published_date")
            print(f"- {result.get('url')}" + (f"  [{date}]" if date else ""))
            snippet = (result.get("content") or "").strip().replace("\n", " ")
            if snippet:
                print(f"  {snippet[:200]}")

    sys.stdout.flush()
    print(
        f"[{len(body.get('results') or [])} results in {body.get('response_time')}s, "
        f"{2 if args.depth == 'advanced' else 1} credit(s)]",
        file=sys.stderr,
    )


def slugify(url: str) -> str:
    return re.sub(r"[^a-zA-Z0-9._-]+", "-", url.split("://", 1)[-1]).strip("-")[:120] or "page"


def run_extract(api_key: str, args: argparse.Namespace) -> None:
    if len(args.urls) > MAX_EXTRACT_URLS:
        raise SystemExit(f"extract accepts at most {MAX_EXTRACT_URLS} URLs")

    body = request(api_key, EXTRACT_URL, {"urls": args.urls, "extract_depth": args.depth})

    if args.json:
        print(json.dumps(body, indent=2))
    else:
        out_dir = pathlib.Path(args.out).expanduser() if args.out else None
        if out_dir:
            out_dir.mkdir(parents=True, exist_ok=True)
        for result in body.get("results") or []:
            url = result.get("url", "")
            content = result.get("raw_content") or ""
            print(f"## {url} ({len(content)} chars)")
            if out_dir:
                path = out_dir / f"{slugify(url)}.md"
                path.write_text(content)
                print(f"written to {path}")
            elif len(content) > EXTRACT_PRINT_LIMIT:
                print(content[:EXTRACT_PRINT_LIMIT])
                print(f"... truncated; rerun with --out DIR to keep all {len(content)} characters")
            else:
                print(content)
            print()

    sys.stdout.flush()
    for failure in body.get("failed_results") or []:
        print(f"failed: {failure.get('url')}: {failure.get('error')}", file=sys.stderr)

    pages = len(args.urls)
    credits = (pages + 4) // 5 * (2 if args.depth == "advanced" else 1)
    print(f"[{len(body.get('results') or [])}/{pages} pages, {credits} credit(s)]", file=sys.stderr)


def run_usage(api_key: str) -> None:
    account = request(api_key, USAGE_URL, None).get("account") or {}
    print(f"plan: {account.get('current_plan')}")
    print(f"used: {account.get('plan_usage')} / {account.get('plan_limit')} credits")


def main() -> None:
    args = parse_args()

    api_key = os.environ.get("TAVILY_API_KEY")
    if not api_key:
        raise SystemExit("TAVILY_API_KEY is not set")

    if args.command == "search":
        run_search(api_key, args)
    elif args.command == "extract":
        run_extract(api_key, args)
    else:
        run_usage(api_key)


if __name__ == "__main__":
    main()

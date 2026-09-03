# /// script
# requires-python = ">=3.10"
# dependencies = ["httpx==0.28.1"]
# ///

import argparse
import json
import os
import sys

import httpx

DEFAULT_URL = "https://links.samirettali.com"
TIMEOUT = httpx.Timeout(60, connect=10)
PAGE_SIZE = 100


class ApiError(Exception):
    pass


def client() -> httpx.Client:
    token = os.environ.get("LINKDING_TOKEN")
    if not token:
        raise SystemExit("LINKDING_TOKEN is not set")
    base = os.environ.get("LINKDING_URL", DEFAULT_URL).rstrip("/")
    return httpx.Client(
        base_url=f"{base}/api",
        headers={"Authorization": f"Token {token}"},
        timeout=TIMEOUT,
        follow_redirects=True,
    )


def call(http: httpx.Client, method: str, path: str, **kwargs) -> dict | None:
    response = http.request(method, path, **kwargs)
    if response.status_code >= 400:
        raise ApiError(f"{method} {path} failed with {response.status_code}: {response.text[:500]}")
    if response.status_code == 204 or not response.content:
        return None
    return response.json()


def paginate(http: httpx.Client, path: str, params: dict, limit: int) -> list[dict]:
    items: list[dict] = []
    offset = 0
    while len(items) < limit:
        page = call(
            http,
            "GET",
            path,
            params={**params, "limit": min(PAGE_SIZE, limit - len(items)), "offset": offset},
        )
        results = page.get("results", [])
        items.extend(results)
        if not page.get("next") or not results:
            break
        offset += len(results)
    return items[:limit]


def label(bookmark: dict) -> str:
    for key in ("title", "website_title"):
        value = bookmark.get(key)
        if value:
            return value
    return bookmark.get("url", "")


def format_bookmark(bookmark: dict) -> str:
    flags = []
    if bookmark.get("unread"):
        flags.append("unread")
    if bookmark.get("is_archived"):
        flags.append("archived")
    if bookmark.get("shared"):
        flags.append("shared")
    tags = " ".join(f"#{tag}" for tag in bookmark.get("tag_names", []))
    parts = [f"[{bookmark['id']}]", label(bookmark), bookmark.get("url", "")]
    if tags:
        parts.append(tags)
    if flags:
        parts.append(f"({', '.join(flags)})")
    return "  ".join(p for p in parts if p)


def emit(data, as_json: bool, render) -> None:
    if as_json:
        json.dump(data, sys.stdout, indent=2, ensure_ascii=False)
        sys.stdout.write("\n")
        return
    render(data)


def build_query(args) -> str:
    terms = list(args.query or [])
    terms += [f"#{tag}" for tag in args.tag]
    if getattr(args, "unread", False):
        terms.append("!unread")
    if getattr(args, "untagged", False):
        terms.append("!untagged")
    return " ".join(terms)


def cmd_list(http: httpx.Client, args) -> None:
    path = "/bookmarks/archived/" if args.archived else "/bookmarks/"
    params = {}
    query = build_query(args)
    if query:
        params["q"] = query
    if args.modified_since:
        params["modified_since"] = args.modified_since
    if args.added_since:
        params["added_since"] = args.added_since
    bookmarks = paginate(http, path, params, args.limit)
    emit(
        bookmarks,
        args.json,
        lambda items: print("\n".join(format_bookmark(b) for b in items) or "no bookmarks matched"),
    )


def cmd_get(http: httpx.Client, args) -> None:
    bookmark = call(http, "GET", f"/bookmarks/{args.id}/")
    emit(bookmark, args.json, lambda b: print(detail(b)))


def detail(bookmark: dict) -> str:
    lines = [format_bookmark(bookmark)]
    for key in ("description", "notes", "date_added", "date_modified"):
        value = bookmark.get(key)
        if value:
            lines.append(f"{key}: {value}")
    return "\n".join(lines)


def cmd_check(http: httpx.Client, args) -> None:
    result = call(http, "GET", "/bookmarks/check/", params={"url": args.url})

    def render(data):
        bookmark = data.get("bookmark")
        if bookmark:
            print(detail(bookmark))
        else:
            print("not bookmarked")
            metadata = data.get("metadata") or {}
            if metadata.get("title"):
                print(f"title: {metadata['title']}")
            if metadata.get("description"):
                print(f"description: {metadata['description']}")
        auto_tags = data.get("auto_tags") or []
        if auto_tags:
            print(f"auto tags: {' '.join(auto_tags)}")

    emit(result, args.json, render)


def bookmark_body(args) -> dict:
    body = {}
    for field in ("url", "title", "description", "notes"):
        value = getattr(args, field, None)
        if value is not None:
            body[field] = value
    if args.tag:
        body["tag_names"] = args.tag
    for flag in ("unread", "shared"):
        value = getattr(args, flag, None)
        if value is not None:
            body[flag] = value
    return body


def cmd_add(http: httpx.Client, args) -> None:
    params = {"disable_scraping": "true"} if args.no_scrape else {}
    bookmark = call(http, "POST", "/bookmarks/", params=params, json=bookmark_body(args))
    emit(bookmark, args.json, lambda b: print(f"saved {format_bookmark(b)}"))


def cmd_update(http: httpx.Client, args) -> None:
    body = bookmark_body(args)
    if not body:
        raise SystemExit("nothing to update: pass at least one field")
    bookmark = call(http, "PATCH", f"/bookmarks/{args.id}/", json=body)
    emit(bookmark, args.json, lambda b: print(f"updated {format_bookmark(b)}"))


def cmd_delete(http: httpx.Client, args) -> None:
    call(http, "DELETE", f"/bookmarks/{args.id}/")
    print(f"deleted bookmark {args.id}")


def cmd_archive(http: httpx.Client, args) -> None:
    action = "unarchive" if args.unarchive else "archive"
    call(http, "POST", f"/bookmarks/{args.id}/{action}/")
    print(f"{action}d bookmark {args.id}")


def cmd_tags(http: httpx.Client, args) -> None:
    tags = paginate(http, "/tags/", {}, args.limit)
    emit(
        tags,
        args.json,
        lambda items: print("\n".join(f"[{t['id']}]  {t['name']}" for t in items) or "no tags"),
    )


def flag_pair(parser: argparse.ArgumentParser, name: str, help_text: str) -> None:
    group = parser.add_mutually_exclusive_group()
    group.add_argument(f"--{name}", dest=name, action="store_true", default=None, help=help_text)
    group.add_argument(f"--no-{name}", dest=name, action="store_false", default=None, help=f"unset {name}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Read and write bookmarks in a linkding instance.")
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--json", action="store_true", help="Print the raw API response")
    sub = parser.add_subparsers(dest="command", required=True, parser_class=lambda **kw: argparse.ArgumentParser(parents=[common], **kw))

    listing = sub.add_parser("list", help="List or search bookmarks")
    listing.add_argument("query", nargs="*", help="Search terms")
    listing.add_argument("--tag", action="append", default=[], metavar="TAG", help="Filter by tag; repeatable")
    listing.add_argument("--unread", action="store_true", help="Only unread bookmarks")
    listing.add_argument("--untagged", action="store_true", help="Only untagged bookmarks")
    listing.add_argument("--archived", action="store_true", help="Search the archive instead")
    listing.add_argument("--modified-since", metavar="ISO8601")
    listing.add_argument("--added-since", metavar="ISO8601")
    listing.add_argument("--limit", type=int, default=50)
    listing.set_defaults(func=cmd_list)

    get = sub.add_parser("get", help="Show one bookmark")
    get.add_argument("id", type=int)
    get.set_defaults(func=cmd_get)

    check = sub.add_parser("check", help="Check whether a URL is bookmarked, with scraped metadata")
    check.add_argument("url")
    check.set_defaults(func=cmd_check)

    add = sub.add_parser("add", help="Save a bookmark")
    add.add_argument("url")
    add.add_argument("--title")
    add.add_argument("--description")
    add.add_argument("--notes")
    add.add_argument("--tag", action="append", default=[], metavar="TAG", help="Repeatable")
    add.add_argument("--no-scrape", action="store_true", help="Do not fetch title and description from the page")
    flag_pair(add, "unread", "Mark as unread")
    flag_pair(add, "shared", "Mark as shared")
    add.set_defaults(func=cmd_add)

    update = sub.add_parser("update", help="Patch the fields given on an existing bookmark")
    update.add_argument("id", type=int)
    update.add_argument("--url")
    update.add_argument("--title")
    update.add_argument("--description")
    update.add_argument("--notes")
    update.add_argument("--tag", action="append", default=[], metavar="TAG", help="Replaces every tag; repeatable")
    flag_pair(update, "unread", "Mark as unread")
    flag_pair(update, "shared", "Mark as shared")
    update.set_defaults(func=cmd_update)

    delete = sub.add_parser("delete", help="Delete a bookmark permanently")
    delete.add_argument("id", type=int)
    delete.set_defaults(func=cmd_delete)

    archive = sub.add_parser("archive", help="Archive or unarchive a bookmark")
    archive.add_argument("id", type=int)
    archive.add_argument("--unarchive", action="store_true")
    archive.set_defaults(func=cmd_archive)

    tags = sub.add_parser("tags", help="List tags")
    tags.add_argument("--limit", type=int, default=200)
    tags.set_defaults(func=cmd_tags)

    return parser.parse_args()


def main() -> None:
    args = parse_args()
    try:
        with client() as http:
            args.func(http, args)
    except ApiError as error:
        raise SystemExit(str(error))
    except httpx.HTTPError as error:
        raise SystemExit(f"request failed: {error}")


if __name__ == "__main__":
    main()

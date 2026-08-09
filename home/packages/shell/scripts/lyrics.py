"""Lyrics and annotations for a song, from LRCLIB and Genius.

LRCLIB supplies the text (measured: 83% of the IT/FR rap library, two thirds of
it synced), Genius supplies the community annotations, which are the good source
for references and quotations. The two are correlated rather than complementary:
where LRCLIB has nothing, Genius almost always has nothing either.

Every answer states *how* the text was found (`match.exactness`), because on a
remix the text that turns up is usually the original's — and a freestyle over
the same beat is a different text entirely, which no API can tell apart. Better
to say so than to guess in silence.
"""

import argparse
import json
import os
import re
import sqlite3
import subprocess
import sys
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request

UA = "lyrics/1.0 (personal skill; +https://github.com/samirettali)"
LRCLIB = "https://lrclib.net/api"
GENIUS = "https://api.genius.com"

CACHE_DIR = os.path.expanduser("~/.cache/lyrics")
CACHE_DB = os.path.join(CACHE_DIR, "lyrics.db")

# Suffixes Spotify appends to titles and that LRCLIB almost never carries.
REMIX_RE = re.compile(r"\b(remix|rmx|edit|bootleg|flip|mashup)\b", re.I)
SUFFIX_RE = re.compile(
    r"\s*[-–(\[]\s*[^-–()\[\]]*\b("
    r"remaster(ed)?|radio edit|live|remix|rmx|version|mix|edit|bootleg|flip|"
    r"mashup|instrumental|acoustic|demo|bonus|deluxe|reloaded|prod\.?|feat\.?|"
    r"ft\.?|con |avec "
    r")[^-–()\[\]]*[)\]]?\s*$",
    re.I,
)


def die(msg, **extra):
    json.dump({"error": msg, **extra}, sys.stdout)
    sys.stdout.write("\n")
    sys.exit(1)


def strip_accents(s):
    s = unicodedata.normalize("NFKD", s)
    return "".join(c for c in s if not unicodedata.combining(c))


def norm(s):
    s = strip_accents((s or "").lower())
    s = re.sub(r"[^a-z0-9]+", " ", s)
    return " ".join(s.split())


def base_title(title):
    """Strip one suffix at a time until the title stops changing."""
    out = title
    for _ in range(4):
        stripped = SUFFIX_RE.sub("", out).strip(" -–")
        if stripped == out or not stripped:
            break
        out = stripped
    return out


# --------------------------------------------------------------------------
# cache


def cache():
    os.makedirs(CACHE_DIR, exist_ok=True)
    db = sqlite3.connect(CACHE_DB)
    db.execute(
        "CREATE TABLE IF NOT EXISTS entries ("
        "  kind TEXT, key TEXT, payload TEXT, fetched_at INTEGER,"
        "  PRIMARY KEY (kind, key))"
    )
    return db


def cache_get(db, kind, key):
    row = db.execute(
        "SELECT payload, fetched_at FROM entries WHERE kind = ? AND key = ?",
        (kind, key),
    ).fetchone()
    if not row:
        return None
    return json.loads(row[0]), row[1]


def cache_put(db, kind, key, payload):
    db.execute(
        "INSERT OR REPLACE INTO entries VALUES (?, ?, ?, ?)",
        (kind, key, json.dumps(payload, ensure_ascii=False), int(time.time())),
    )
    db.commit()


# --------------------------------------------------------------------------
# http


def http_json(url, headers=None, retries=3):
    req = urllib.request.Request(url, headers={"User-Agent": UA, **(headers or {})})
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(req, timeout=25) as r:
                return json.loads(r.read())
        except urllib.error.HTTPError as e:
            if e.code == 404:
                return None
            if e.code in (401, 403):
                raise
            time.sleep(1 + 2 * attempt)
        except Exception:
            if attempt == retries - 1:
                raise
            time.sleep(1 + 2 * attempt)
    return None


def lrclib(path, params):
    return http_json(f"{LRCLIB}/{path}?" + urllib.parse.urlencode(params))


# --------------------------------------------------------------------------
# current track


def now_playing():
    """spotctl stays the only thing talking to Spotify; here it is only read."""
    try:
        out = subprocess.run(
            ["spotctl", "queue", "get", "--full"],
            capture_output=True, text=True, timeout=30,
        )
    except FileNotFoundError:
        die("spotctl not found on PATH")
    except subprocess.TimeoutExpired:
        die("spotctl did not answer within 30s")

    if out.returncode != 0:
        detail = (out.stderr or out.stdout).strip()[:300]
        die("spotctl queue get failed", detail=detail)

    try:
        cur = json.loads(out.stdout).get("currently_playing")
    except json.JSONDecodeError:
        die("could not decode spotctl output")

    if not cur:
        die("nothing is playing")

    return {
        "id": cur.get("id"),
        "name": cur["name"],
        "artist": cur["artists"][0]["name"],
        "artists": [a["name"] for a in cur["artists"]],
        "album": (cur.get("album") or {}).get("name"),
        "duration": round(cur["duration_ms"] / 1000) if cur.get("duration_ms") else None,
    }


# --------------------------------------------------------------------------
# LRCLIB: the ladder of attempts


def shape(rec, exactness, note=None):
    if rec is None:
        return None
    matched = {
        "artist": rec.get("artistName"),
        "title": rec.get("trackName"),
        "album": rec.get("albumName"),
        "duration": rec.get("duration"),
    }
    out = {
        "match": {"exactness": exactness, "source": "lrclib", "matched": matched},
        "lyrics": {
            "instrumental": bool(rec.get("instrumental")),
            "synced": bool(rec.get("syncedLyrics")),
            "plain": rec.get("plainLyrics"),
            "synced_text": rec.get("syncedLyrics"),
        },
    }
    if note:
        out["match"]["note"] = note
    return out


def artist_matches(a, b):
    na, nb = norm(a), norm(b)
    if not na or not nb:
        return False
    if na == nb or na in nb or nb in na:
        return True
    return bool(set(na.split()) & set(nb.split()))


def find_lyrics(track):
    artist, title = track["artist"], track["name"]
    album, dur = track.get("album"), track.get("duration")
    tried = []
    base = base_title(title)
    is_remix = bool(REMIX_RE.search(title)) and norm(base) != norm(title)

    def attempt(label, params, exactness, note=None):
        tried.append(label)
        rec = lrclib("get", {k: v for k, v in params.items() if v not in (None, "")})
        return shape(rec, exactness, note)

    if album and dur:
        r = attempt("get:album+duration",
                    {"artist_name": artist, "track_name": title,
                     "album_name": album, "duration": dur}, "exact")
        if r:
            return r, tried

    if dur:
        r = attempt("get:duration",
                    {"artist_name": artist, "track_name": title, "duration": dur},
                    "no-album")
        if r:
            return r, tried

    r = attempt("get:artist+title",
                {"artist_name": artist, "track_name": title}, "loose-duration",
                "duration not verified: this may be another version")
    if r:
        return r, tried

    if norm(base) != norm(title):
        exactness = "original-of-remix" if is_remix else "normalized"
        note = (
            "text of the base version, not of the remix: if it is a freestyle "
            "over the same beat the words are different"
            if is_remix else
            "found after stripping the suffix from the title"
        )
        r = attempt("get:normalized-title",
                    {"artist_name": artist, "track_name": base}, exactness, note)
        if r:
            return r, tried

    tried.append("search")
    hits = lrclib("search", {"artist_name": artist, "track_name": base}) or []
    for hit in hits[:10]:
        if norm(hit.get("trackName", "")) != norm(base):
            continue
        if not artist_matches(hit.get("artistName", ""), artist):
            continue
        delta = None
        if dur and hit.get("duration"):
            delta = abs(hit["duration"] - dur)
            if delta > 20:
                continue
        note = "fuzzy match from search: check it is the right version"
        if delta is not None:
            note += f" (duration off by {delta}s)"
        return shape(hit, "fuzzy", note), tried

    return None, tried


# --------------------------------------------------------------------------
# Genius: annotations


def genius_token():
    """Only GENIUS_ACCESS_TOKEN: filling it from the sops secret is the nix
    wrapper's job. With no token the annotations are simply skipped."""
    return os.environ.get("GENIUS_ACCESS_TOKEN", "").strip() or None


def genius_api(path, params, token):
    return http_json(
        f"{GENIUS}{path}?" + urllib.parse.urlencode(params),
        headers={"Authorization": f"Bearer {token}"},
    )


def find_annotations(track, token):
    res = genius_api("/search", {"q": f"{track['artist']} {track['name']}"}, token)
    if not res:
        return {"available": False, "reason": "song not found on Genius"}

    want_title, base = norm(track["name"]), norm(base_title(track["name"]))
    song = None
    for hit in (res.get("response", {}) or {}).get("hits", []):
        s = hit.get("result", {})
        gt = norm(s.get("title", ""))
        if gt not in (want_title, base) and want_title not in gt and base not in gt:
            continue
        if not artist_matches(s.get("primary_artist", {}).get("name", ""), track["artist"]):
            continue
        song = s
        break

    if song is None:
        return {"available": False, "reason": "no reliable match on Genius"}

    out = {
        "available": True,
        "source": "genius",
        "song_id": song["id"],
        "url": song.get("url"),
        "title": song.get("title"),
        "artist": song.get("primary_artist", {}).get("name"),
        "items": [],
    }

    refs = genius_api(
        "/referents",
        {"song_id": song["id"], "text_format": "plain", "per_page": 50},
        token,
    )
    for ref in ((refs or {}).get("response", {}) or {}).get("referents", []):
        frag = (ref.get("fragment") or "").strip()
        for ann in ref.get("annotations", []):
            body = ((ann.get("body") or {}).get("plain") or "").strip()
            if not body:
                continue
            out["items"].append({
                "fragment": frag,
                "annotation": body,
                "votes": ann.get("votes_total", 0),
            })

    out["items"].sort(key=lambda a: -a["votes"])
    out["count"] = len(out["items"])
    return out


def limit_annotations(ann, limit):
    """Truncate for output only. The cache holds every annotation, so raising
    --max-annotations answers from disk instead of needing --refresh."""
    if not ann.get("available") or not limit:
        return ann
    items = ann.get("items", [])
    if len(items) <= limit:
        return ann
    return {**ann, "items": items[:limit], "truncated": True}


# --------------------------------------------------------------------------


def run(track, args):
    db = cache()
    key = track.get("id") or f"{norm(track['artist'])}|{norm(track['name'])}"

    hit = None if args.refresh else cache_get(db, "lyrics", key)
    if hit:
        payload, fetched = hit
        payload["source"] = "cache"
        payload["cached_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime(fetched))
    else:
        found, tried = find_lyrics(track)
        if found is None:
            payload = {
                "match": {"exactness": "not_found", "tried": tried},
                "lyrics": None,
            }
        else:
            payload = found
        payload["source"] = "live"
        cache_put(db, "lyrics", key, payload)

    result = {"track": track, **payload}

    # The timestamped text is the plain one with [mm:ss.xx] in front of every
    # line, so shipping both doubles the lyrics for a reader that does not need
    # to follow along. The cache keeps it either way.
    lyrics = result.get("lyrics")
    if lyrics and not args.synced:
        result["lyrics"] = {k: v for k, v in lyrics.items() if k != "synced_text"}

    if args.annotations:
        ann_hit = None if args.refresh else cache_get(db, "annotations", key)
        if ann_hit:
            result["annotations"] = limit_annotations(ann_hit[0], args.max_annotations)
        else:
            token = genius_token()
            if not token:
                result["annotations"] = {
                    "available": False,
                    "reason": "GENIUS_ACCESS_TOKEN is not set",
                }
            else:
                try:
                    ann = find_annotations(track, token)
                    cache_put(db, "annotations", key, ann)
                except urllib.error.HTTPError as e:
                    ann = {
                        "available": False,
                        "reason": f"Genius rejected the token (HTTP {e.code}): "
                                  "regenerate it at genius.com/api-clients",
                    }
                result["annotations"] = limit_annotations(ann, args.max_annotations)

    json.dump(result, sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write("\n")


def main():
    p = argparse.ArgumentParser(
        prog="lyrics",
        description="A song's lyrics (LRCLIB) and annotations (Genius).",
    )
    p.add_argument("artist", nargs="?", help="artist; omit with --now")
    p.add_argument("title", nargs="?", help="title; omit with --now")
    p.add_argument("--now", action="store_true",
                   help="use the currently playing track (via spotctl)")
    p.add_argument("--album", help="disambiguate the match")
    p.add_argument("--duration", type=int, help="duration in seconds")
    p.add_argument("--no-annotations", dest="annotations", action="store_false",
                   help="lyrics only, no call to Genius")
    p.add_argument("--max-annotations", type=int, default=15,
                   help="how many annotations to return (default 15, 0 = all)")
    p.add_argument("--synced", action="store_true",
                   help="include the timestamped text alongside the plain one")
    p.add_argument("--refresh", action="store_true", help="ignore the cache")
    args = p.parse_args()

    if args.now:
        track = now_playing()
    elif args.artist and args.title:
        track = {
            "id": None,
            "name": args.title,
            "artist": args.artist,
            "artists": [args.artist],
            "album": args.album,
            "duration": args.duration,
        }
    else:
        p.error("ARTIST and TITLE are required, or --now")

    run(track, args)


if __name__ == "__main__":
    main()

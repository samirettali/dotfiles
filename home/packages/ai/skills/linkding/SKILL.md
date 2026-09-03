---
name: linkding
description: Read and write Samir's linkding bookmarks — search saved links, check whether a URL is already bookmarked, save one with tags and notes, retag or archive it, list tags. Use when asked what he has bookmarked about a topic, to save or bookmark a link, to look through his reading list or unread links, or to tidy tags.
---

# Linkding

`linkding` talks to the instance at `https://links.samirettali.com`. It reads
`LINKDING_TOKEN` from the environment, and the wrapper takes it from the rbw
vault when the vault is unlocked. Override the host with `LINKDING_URL`.

## Search

```sh
linkding list 'account abstraction'
linkding list --tag go --tag kafka --limit 20
linkding list --unread
linkding list --untagged
linkding list --archived 'nix'
```

Search terms match title, description, notes and URL. Tags are ANDed. Use
`--added-since` or `--modified-since` with an ISO 8601 timestamp for what
changed recently.

Output is one line per bookmark: `[id]  title  url  #tags  (flags)`. Pass
`--json` when you need the full objects.

## One bookmark

```sh
linkding get 412
linkding check https://example.com/post
```

`check` answers whether a URL is already saved. When it is not, it returns the
scraped title and description plus the tags linkding would apply on its own —
use it before saving to avoid a duplicate.

## Save and edit

```sh
linkding add https://example.com/post --tag go --tag concurrency
linkding add https://example.com/post --title 'Title' --notes 'why it matters' --no-scrape
linkding update 412 --tag go --tag rust --notes 'revisit'
linkding archive 412
linkding archive 412 --unarchive
```

`add` scrapes the page for title and description unless `--no-scrape` is given.
`update` patches only the flags you pass, but `--tag` replaces the whole tag
list — read the bookmark first and repeat the tags you want to keep.

`linkding delete <id>` removes a bookmark permanently. Ask before running it.

## Tags

```sh
linkding tags
```

Check the existing tags before inventing a new one, and reuse the spelling that
is already there.

---
name: tavily
description: Search the web with a synthesized answer and date-filtered results, or extract the readable content of pages that block a plain fetch. Use when the built-in web search cannot filter by recency, when a page returns 403 or 500 to a normal fetch, or when a search must be restricted to a country or a set of domains.
---

# Tavily

The built-in web search stays the default: it is free and it already returns page
content. Reach for `tavily` when it cannot do the job.

Use it when:

- The answer depends on when it was published. `--topic news --days 1` returns
  real publisher domains and per-article timestamps.
- A page answers with 403 or 500 to a plain fetch. `tavily extract` reads Amazon
  and other bot-hostile pages.
- The search must be pinned to a country or a domain list.

Do not use it for a question the built-in search answers in one call.

## Search

```sh
tavily search 'Go 1.26 release notes'
tavily search --topic news --days 1 'bitcoin price'
tavily search --country italy --depth advanced 'tassazione plusvalenze cripto'
tavily search --include-domain go.dev 'error wrapping'
```

Each result prints its URL, its publication date when known, and a snippet. The
synthesized answer comes first; `--no-answer` drops it when only the links matter.

The answer is built from the snippets, so it inherits whatever the sources say.
On a contested fact the sources disagree about, read the results rather than the
answer.

## Extract

```sh
tavily extract https://www.amazon.com/dp/B09B8V1LZ3
tavily extract --out ./pages https://example.com/a https://example.com/b
```

Extraction returns the whole page as Markdown, navigation chrome included: a
product page runs to 100k characters. Output over 20k characters is truncated
unless `--out DIR` writes each page to a file, which is the right flag whenever
the answer is a few fields buried in a long page.

`--depth advanced` retries harder on pages that render late. Failed URLs are
reported on stderr and never fail the batch.

## Credits

The plan allows 1000 credits a month. A basic search costs 1 credit, `--depth
advanced` costs 2, and extraction costs 1 per 5 URLs. Each command prints what it
spent on stderr.

```sh
tavily usage
```

Never print or store `TAVILY_API_KEY`.

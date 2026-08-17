---
name: x-search
description: Search current X posts, threads, reactions, and specific accounts through xAI. Use for current discussion on X, not documentation or general facts.
---

# X Search

Use `x-search` for current discussion on X.

## Search

Run one focused search per question. Each call costs roughly $0.05–$0.08.

```sh
x-search 'What are people saying about the Go 1.26 release?'
```

Ask what people said. Do not ask the search model to explain the underlying topic.

## Filters

Pass handles without `@`. Include or exclude up to 20 handles, but never both.

```sh
x-search --handle mitchellh --handle rob_pike 'What did they say about Zig?'
x-search --exclude-handle elonmusk 'Reactions to the X API pricing change'
```

Dates use `YYYY-MM-DD`. Both bounds are optional.

```sh
x-search --from 2026-08-01 --to 2026-08-15 'Discussion about the Cloudflare outage'
```

Use `--images` or `--videos` only when media contains the answer. Media analysis costs extra.

Use `--json` only when structured citations help the task.

If active filters return no citations, report that they matched no posts. Do not present the model's answer as X content.

Never print or store `XAI_API_KEY`.

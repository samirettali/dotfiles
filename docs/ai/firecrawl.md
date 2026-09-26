# Firecrawl

Firecrawl is the default shared external web search provider. The CLI lives in
`samirettali/nur` as `firecrawl-cli`, including its automatic release updater.
Dotfiles only wrap `nurPkgs.firecrawl-cli` and configure usage policy.

`home/packages/ai/firecrawl.nix` reads `FIRECRAWL_API_KEY`, falling back to the
unlocked rbw entries `firecrawl-api-key` and `firecrawl-api-key-2`, one per
account. No key is stored in Nix or CLI config. The wrapper tries the accounts
in order and drops one that answers 402 (out of credits). The CLI does not retry
a 429; the wrapper moves on to the next account, and when every account is
limited it waits as long as the error's "retry after" says, up to three minutes.
Each account allowed about 14 requests a minute in September 2026.
Feedback/refunds are unwanted: the wrapper forces `FIRECRAWL_NO_SEARCH_FEEDBACK=1`
and makes both feedback commands no-ops. Telemetry is also disabled.

Four repository-owned skills cover Search, Scrape, Developer Index, and Research
Index. They adapt the vendor workflows to our CLI version and conventions:
unique temporary output instead of project-local `.firecrawl/`, bounded reads,
selective scraping, no feedback, no implicit paid Agent/browser/monitor jobs.
They are local rather than importing the vendor prompts, whose refund loop,
project writes, and broad automatic research expansion conflict with this policy.
Recheck command syntax when updating the CLI, especially Developer Index filters:
version 1.23.3 only accepts query text and count, while the HTTP API also exposes
hard repository/type/source filters. Query-text scoping is not a hard filter.

`native-web-search` is removed from the shared registry; `agent-stuff` remains pinned for other skills.
Dedicated tools such as GitHub CLI and X Search keep precedence for their services.
No Firecrawl MCP server or imperative `firecrawl setup` is needed.

Use `firecrawl credit-usage --json` for balance checks. Search costs 2 credits per
1–10 results; plain scrape costs 1 per page, including cache hits. Research Index
paper endpoints are currently free. Scrape keeps the whole page: in a benchmark
of 20 pages, `--only-main-content` cut a quarter of the text but dropped content
the agent needed on two of them, and the skill saves the page to a file anyway. Never estimate net costs from refunds.
The account's monthly recharge cap is managed in Firecrawl billing, not by this
wrapper. Pricing and provider-side limits can change independently of the CLI.

After activation, reload the agent's skill catalog or start a new session.

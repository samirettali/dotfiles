# Firecrawl

Firecrawl is the default shared external web search provider. The CLI lives in
`samirettali/nur` as `firecrawl-cli`, including its automatic release updater.
Dotfiles only wrap `nurPkgs.firecrawl-cli` and configure usage policy.

`home/packages/ai/firecrawl.nix` reads `FIRECRAWL_API_KEY`, falling back to the
unlocked rbw entry `firecrawl-api-key`. No key is stored in Nix or CLI config.
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

Tavily remains available only by explicit skill invocation. `native-web-search`
is removed from the shared registry; `agent-stuff` remains pinned for other skills.
Dedicated tools such as GitHub CLI and X Search keep precedence for their services.
No Firecrawl MCP server or imperative `firecrawl setup` is needed.

Use `firecrawl credit-usage --json` for balance checks. Search costs 2 credits per
1–10 results; plain scrape costs 1 per page, including cache hits. Research Index
paper endpoints are currently free. Never estimate net costs from refunds.
The account's monthly recharge cap is managed in Firecrawl billing, not by this
wrapper. Pricing and provider-side limits can change independently of the CLI.

After activation, reload the agent's skill catalog or start a new session.

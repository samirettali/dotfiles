
## Reliable interactions

```bash
./scripts/click.js 'button[type="submit"]'
./scripts/fill.js 'input[name="email"]' 'samir@example.com'
./scripts/fill.js 'textarea' ''
```

Selectors are **CSS only** and must match exactly one element. Helpers wait up to
25 seconds for a visible, enabled, unobstructed element at a stable position,
then send browser input events rather than setting `.value` or calling `.click()`.
Fill supports text-like inputs (including email and number) and textareas. It
replaces the current text, verifies the value and blurs to commit `change`.
It does not support contenteditable, select, date, checkbox or file inputs.
Use Chrome DevTools MCP for those controls, shadow DOM or frame interactions.
Click does not wait for subsequent navigation or asynchronous application work.

Page-touching CLI scripts share a cross-process lock per debug endpoint. Parallel
calls cannot operate on the page simultaneously, but their ordering is not FIFO.
**Always chain dependent commands with `&&`**, rather than batching them in
parallel. The lock waits up to 120 seconds. It uses a localhost TCP port derived
from the debug endpoint; override `BROWSER_ACTION_LOCK_PORT` consistently for all
commands if another service uses that port. MCP calls and external CDP clients
are not covered by this lock; do not mix them concurrently with CLI actions.

## Filtered logs (non-destructive)

```bash
./scripts/logs.js --kind console --filter 'TypeError' --limit 20
./scripts/logs.js --kind network --url '/api/' --status 401
./scripts/logs.js --kind network --since '2026-01-01T12:00:00Z'
./scripts/logs.js --file /path/to/target.jsonl --kind network
```

Defaults to the latest modified target log in the latest dated directory and
prints its path on stderr. Use `--file` to avoid ambiguity with multiple tabs.
Returns the latest matching entries in chronological order, never clears logs,
and limits output to 100 entries (configurable up to 1000) and 48KB. Existing
`logs-tail.js --follow` and `net-summary.js` remain available. Network correlation
keeps the latest 10,000 request IDs; older unmatched responses show `?` for method.

Headers are **not captured by default**. To debug headers, start the browser with:

```bash
BROWSER_LOG_HEADERS=authorization,content-type ./scripts/start.js --headless
./scripts/logs.js --kind network --url '/api/' --headers authorization,content-type
```

The environment setting applies when the background watcher starts, not when
reading logs. An already-running watcher must be stopped and restarted with the
setting. Only explicitly named headers are saved; `--headers` independently opts
into showing them. These are headers from ordinary CDP request/response events,
not a guarantee of every on-wire header. Enabling sensitive headers writes
credentials into local JSONL logs: remove those logs when finished. Do not enable
capture speculatively or expose tokens in responses to the user.

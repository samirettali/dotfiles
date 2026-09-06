import assert from "node:assert/strict";
import { realpathSync } from "node:fs";
import { homedir } from "node:os";
import { createRequire } from "node:module";
import { test } from "node:test";

// Use the installed pi runtime, as extensions do, without a second dependency tree.
const modules = `${homedir()}/.pi/agent/extensions/node_modules`;
const require = createRequire(`${realpathSync(`${modules}/@earendil-works/pi-coding-agent`)}/package.json`);
const { createJiti } = require("jiti");
const jiti = createJiti(import.meta.url, {
    alias: Object.fromEntries(["@earendil-works/pi-coding-agent", "@earendil-works/pi-tui", "typebox"]
        .map(name => [name, name === "typebox" ? require.resolve(name) : realpathSync(`${modules}/${name}`)])),
});
const { default: extension } = await jiti.import("../home/packages/ai/pi-coding-agent/extensions/x-search.ts");
let tool;
extension({ registerTool: definition => { tool = definition; } });
const ctx = { modelRegistry: { getApiKeyForProvider: async () => "test-key" } };
const execute = (params, signal) => tool.execute("test", params, signal, undefined, ctx);
const response = (body, status = 200, headers = {}) => new Response(JSON.stringify(body), { status, headers });

test("request parity, citation cleanup and usage", async t => {
    t.mock.method(globalThis, "fetch", async (url, options) => {
        assert.equal(url, "https://api.x.ai/v1/responses");
        const body = JSON.parse(options.body);
        assert.equal(body.model, "grok-4.6");
        assert.equal(body.store, false);
        assert.deepEqual(body.tools, [{ type: "x_search", allowed_x_handles: ["alice"], from_date: "2025-01-01", to_date: "2025-02-01", enable_image_understanding: true, enable_video_understanding: true }]);
        return response({
            citations: ["https://x.com/1", { url: "https://x.com/2", title: "2" }],
            output: [{ type: "message", content: [{ type: "output_text", text: "Answer", annotations: [
                { type: "url_citation", url: "https://x.com/1" },
                { type: "url_citation", url: "https://x.com/3", title: "A post" },
                { type: "url_citation", url: "https://x.com/4", title: "https://x.com/4" },
            ] }] }],
            usage: { input_tokens: 12, output_tokens: 34, server_side_tool_usage_details: { x_search_calls: 2 } },
        });
    });
    const result = await execute({ query: "question", allowed_x_handles: ["@alice", "alice"], from_date: "2025-01-01", to_date: "2025-02-01", enable_image_understanding: true, enable_video_understanding: true });
    const data = JSON.parse(result.content[0].text);
    assert.equal(data.answer, "Answer");
    assert.deepEqual(data.citations, [{ url: "https://x.com/1" }, { url: "https://x.com/2" }, { url: "https://x.com/3", title: "A post" }, { url: "https://x.com/4" }]);
    assert.deepEqual(data.usage, { input_tokens: 12, output_tokens: 34, x_search_calls: 2 });
    assert.equal(data.degraded, false);
});

test("20 handles accepted, overflow and conflicting filters rejected", async t => {
    t.mock.method(globalThis, "fetch", async () => response({ output_text: "Answer" }));
    const handles = Array.from({ length: 20 }, (_, i) => `user${i}`);
    assert.equal(tool.parameters.properties.allowed_x_handles.maxItems, 20);
    const result = await execute({ query: "question", allowed_x_handles: handles });
    assert.equal(JSON.parse(result.content[0].text).degraded, true);
    await assert.rejects(execute({ query: "question", allowed_x_handles: [...handles, "extra"] }), /20 handles/);
    await assert.rejects(execute({ query: "question", allowed_x_handles: handles, excluded_x_handles: ["other"] }), /cannot be combined/);
});

for (const status of [408, 429, 500, 502, 503, 504]) {
    test(`retries ${status} and honors Retry-After`, async t => {
        let calls = 0;
        t.mock.method(globalThis, "fetch", async () => ++calls === 1
            ? response({}, status, { "Retry-After": "0" })
            : response({ output_text: "Answer" }));
        await execute({ query: "question" });
        assert.equal(calls, 2);
    });
}

test("HTTP-date Retry-After and retry exhaustion", async t => {
    let calls = 0;
    t.mock.method(globalThis, "fetch", async () => {
        calls++;
        return response({ error: "rate limited" }, 429, { "Retry-After": "Wed, 01 Jan 2020 00:00:00 GMT" });
    });
    await assert.rejects(execute({ query: "question" }), /rate limited/);
    assert.equal(calls, 3);
});

test("does not retry 400", async t => {
    const fetch = t.mock.method(globalThis, "fetch", async () => response({ error: "bad query" }, 400));
    await assert.rejects(execute({ query: "question" }), /bad query/);
    assert.equal(fetch.mock.callCount(), 1);
});

test("cancellation stops retry backoff", async t => {
    const controller = new AbortController();
    const fetch = t.mock.method(globalThis, "fetch", async () => {
        controller.abort();
        return response({}, 429, { "Retry-After": "60" });
    });
    await assert.rejects(execute({ query: "question" }, controller.signal), /abort/i);
    assert.equal(fetch.mock.callCount(), 1);
});

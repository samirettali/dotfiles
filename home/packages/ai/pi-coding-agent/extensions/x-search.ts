import {
    DEFAULT_MAX_BYTES,
    DEFAULT_MAX_LINES,
    formatSize,
    truncateHead,
    type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { mkdtemp, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Type } from "typebox";

const XAI_BASE_URL = "https://api.x.ai/v1";
const X_SEARCH_MODEL = "grok-4.5";
const MAX_HANDLES = 10;
const MAX_RETRIES = 2;

type Citation = string | {
    url?: string;
    title?: string;
    start_index?: number;
    end_index?: number;
};

interface XSearchDetails {
    model: string;
    query: string;
    citations: Citation[];
    degraded: boolean;
}

const XSearchParams = Type.Object({
    query: Type.String({ description: "What to search for on X." }),
    allowed_x_handles: Type.Optional(
        Type.Array(Type.String(), {
            maxItems: MAX_HANDLES,
            description: "Only search posts from these X handles (without @). Cannot be combined with excluded_x_handles.",
        }),
    ),
    excluded_x_handles: Type.Optional(
        Type.Array(Type.String(), {
            maxItems: MAX_HANDLES,
            description: "Exclude posts from these X handles (without @). Cannot be combined with allowed_x_handles.",
        }),
    ),
    from_date: Type.Optional(Type.String({ description: "Start date in YYYY-MM-DD format." })),
    to_date: Type.Optional(Type.String({ description: "End date in YYYY-MM-DD format." })),
    enable_image_understanding: Type.Optional(
        Type.Boolean({ description: "Analyze images attached to matching posts." }),
    ),
    enable_video_understanding: Type.Optional(
        Type.Boolean({ description: "Analyze videos attached to matching posts." }),
    ),
});

function normalizeHandles(handles: string[] | undefined): string[] {
    return [...new Set((handles ?? []).map((handle) => handle.trim().replace(/^@/, "")).filter(Boolean))];
}

function parseDate(value: string | undefined, field: string): Date | undefined {
    if (!value) return undefined;
    if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
        throw new Error(`${field} must use YYYY-MM-DD format`);
    }

    const date = new Date(`${value}T00:00:00Z`);
    if (Number.isNaN(date.getTime()) || date.toISOString().slice(0, 10) !== value) {
        throw new Error(`${field} must be a valid date`);
    }
    return date;
}

function validateDates(fromDate: string | undefined, toDate: string | undefined): void {
    const from = parseDate(fromDate, "from_date");
    const to = parseDate(toDate, "to_date");
    if (from && to && from > to) {
        throw new Error("from_date must be on or before to_date");
    }

    const today = new Date();
    today.setUTCHours(0, 0, 0, 0);
    if (from && from > today) {
        throw new Error(`from_date cannot be in the future (today UTC is ${today.toISOString().slice(0, 10)})`);
    }
}

function extractText(payload: Record<string, any>): string {
    if (typeof payload.output_text === "string" && payload.output_text.trim()) {
        return payload.output_text.trim();
    }

    const parts: string[] = [];
    for (const item of payload.output ?? []) {
        if (item?.type !== "message") continue;
        for (const content of item.content ?? []) {
            if ((content?.type === "output_text" || content?.type === "text") && typeof content.text === "string") {
                parts.push(content.text.trim());
            }
        }
    }
    return parts.filter(Boolean).join("\n\n");
}

function extractInlineCitations(payload: Record<string, any>): Citation[] {
    const citations: Citation[] = [];
    for (const item of payload.output ?? []) {
        if (item?.type !== "message") continue;
        for (const content of item.content ?? []) {
            for (const annotation of content?.annotations ?? []) {
                if (annotation?.type !== "url_citation") continue;
                citations.push({
                    url: annotation.url,
                    title: annotation.title,
                    start_index: annotation.start_index,
                    end_index: annotation.end_index,
                });
            }
        }
    }
    return citations;
}

function errorMessage(status: number, payload: unknown): string {
    if (payload && typeof payload === "object") {
        const body = payload as Record<string, any>;
        const error = body.error;
        if (typeof error === "string") return error;
        if (error && typeof error === "object") {
            return String(error.message || error.code || JSON.stringify(error));
        }
        if (body.code || body.message) return String(body.message || body.code);
    }
    return `xAI returned HTTP ${status}`;
}

function delay(milliseconds: number, signal?: AbortSignal): Promise<void> {
    return new Promise((resolve, reject) => {
        const onAbort = () => {
            clearTimeout(timer);
            reject(new Error("X search cancelled"));
        };
        const timer = setTimeout(() => {
            signal?.removeEventListener("abort", onAbort);
            resolve();
        }, milliseconds);
        signal?.addEventListener("abort", onAbort, { once: true });
    });
}

async function truncateResult(serialized: string): Promise<string> {
    const truncation = truncateHead(serialized, {
        maxBytes: DEFAULT_MAX_BYTES,
        maxLines: DEFAULT_MAX_LINES,
    });
    if (!truncation.truncated) return truncation.content;

    const directory = await mkdtemp(join(tmpdir(), "pi-x-search-"));
    const path = join(directory, "result.json");
    await writeFile(path, serialized, "utf8");
    return `${truncation.content}\n\n[Output truncated: ${truncation.outputLines} of ${truncation.totalLines} lines (${formatSize(truncation.outputBytes)} of ${formatSize(truncation.totalBytes)}). Full output saved to: ${path}]`;
}

export default function xSearch(pi: ExtensionAPI) {
    pi.registerTool({
        name: "x_search",
        label: "X Search",
        description:
            "Search current X (Twitter) posts, profiles, and threads through xAI's hosted X Search. Supports handle and date filters and returns citation-backed results. Requires /login xai with a SuperGrok or X Premium subscription, or XAI_API_KEY.",
        promptSnippet: "Search current X posts, profiles, and threads with optional handle and date filters",
        promptGuidelines: [
            "Use x_search instead of general web search when the user asks about current discussion, reactions, accounts, posts, or threads on X.",
        ],
        parameters: XSearchParams,

        async execute(_toolCallId, params, signal, onUpdate, ctx) {
            const query = params.query.trim();
            if (!query) throw new Error("query is required");

            const allowed = normalizeHandles(params.allowed_x_handles);
            const excluded = normalizeHandles(params.excluded_x_handles);
            if (allowed.length && excluded.length) {
                throw new Error("allowed_x_handles and excluded_x_handles cannot be combined");
            }
            validateDates(params.from_date, params.to_date);

            const apiKey = await ctx.modelRegistry.getApiKeyForProvider("xai");
            if (!apiKey) {
                throw new Error("No xAI credentials found. Run /login xai and choose a subscription or API key.");
            }

            const tool: Record<string, unknown> = { type: "x_search" };
            if (allowed.length) tool.allowed_x_handles = allowed;
            if (excluded.length) tool.excluded_x_handles = excluded;
            if (params.from_date) tool.from_date = params.from_date;
            if (params.to_date) tool.to_date = params.to_date;
            if (params.enable_image_understanding) tool.enable_image_understanding = true;
            if (params.enable_video_understanding) tool.enable_video_understanding = true;

            onUpdate?.({
                content: [{ type: "text", text: `Searching X for: ${query}` }],
                details: undefined,
            });

            let response: Response | undefined;
            for (let attempt = 0; attempt <= MAX_RETRIES; attempt++) {
                try {
                    response = await fetch(`${XAI_BASE_URL}/responses`, {
                        method: "POST",
                        headers: {
                            Authorization: `Bearer ${apiKey}`,
                            "Content-Type": "application/json",
                            "User-Agent": "pi-x-search/1.0",
                        },
                        body: JSON.stringify({
                            model: X_SEARCH_MODEL,
                            input: [{ role: "user", content: query }],
                            tools: [tool],
                            store: false,
                        }),
                        signal,
                    });
                    if (response.ok || response.status < 500 || attempt === MAX_RETRIES) break;
                } catch (error) {
                    if (signal?.aborted || attempt === MAX_RETRIES) throw error;
                }
                await delay(1500 * (attempt + 1), signal);
            }

            if (!response) throw new Error("xAI did not return a response");

            let payload: Record<string, any>;
            try {
                payload = await response.json() as Record<string, any>;
            } catch {
                throw new Error(`xAI returned invalid JSON (HTTP ${response.status})`);
            }
            if (!response.ok) throw new Error(errorMessage(response.status, payload));
            if (payload.error) throw new Error(errorMessage(response.status, payload));

            const answer = extractText(payload);
            const citations = [
                ...(Array.isArray(payload.citations) ? payload.citations : []),
                ...extractInlineCitations(payload),
            ] as Citation[];
            const filtered = Boolean(allowed.length || excluded.length || params.from_date || params.to_date);
            const degraded = filtered && citations.length === 0;
            const result = {
                answer,
                citations,
                degraded,
                ...(degraded ? { warning: "No citations were returned despite active filters; the answer may not come from matching X posts." } : {}),
            };

            const serialized = JSON.stringify(result, null, 2);
            return {
                content: [{ type: "text", text: await truncateResult(serialized) }],
                details: {
                    model: X_SEARCH_MODEL,
                    query,
                    citations,
                    degraded,
                } satisfies XSearchDetails,
            };
        },

        renderCall(args, theme) {
            return new Text(
                `${theme.fg("toolTitle", theme.bold("x_search "))}${theme.fg("muted", args.query)}`,
                0,
                0,
            );
        },

        renderResult(result, { isPartial }, theme) {
            if (isPartial) return new Text(theme.fg("muted", "Searching X…"), 0, 0);
            const details = result.details as XSearchDetails | undefined;
            if (!details) {
                const first = result.content[0];
                return new Text(first?.type === "text" ? first.text : "", 0, 0);
            }
            const status = details.degraded ? theme.fg("warning", "degraded") : theme.fg("success", "done");
            return new Text(`${status} · ${details.citations.length} citation(s) · ${details.model}`, 0, 0);
        },
    });
}

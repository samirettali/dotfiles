/**
 * Herdr Session Title Extension
 *
 * Generates a short title from the first user message of a session, sets it as
 * the pi session name, and reports it to Herdr as a `session` pane token so the
 * agent sidebar can show it next to the harness name.
 *
 * Herdr already shows Claude Code's OSC session title via the built-in
 * `terminal_title_stripped` token. pi only emits "π - <dir>", hence this.
 *
 * Provider and model are overridable through HERDR_TITLE_PROVIDER and
 * HERDR_TITLE_MODEL.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { TextContent } from "@earendil-works/pi-ai";
import { completeSimple } from "@earendil-works/pi-ai/compat";

const PROVIDER = process.env.HERDR_TITLE_PROVIDER || "openai-codex";
const MODEL_ID = process.env.HERDR_TITLE_MODEL || "gpt-5.6-luna";
const TOKEN_SOURCE = "pi-session-title";
const MAX_INPUT_CHARS = 2000;
const MAX_TITLE_CHARS = 60;

const SYSTEM_PROMPT = [
	"You write terse titles for coding-agent sessions.",
	"Given the user's first message, reply with a title of at most six words.",
	"No quotes, no trailing period, no preamble. Reply with the title only.",
	"Use the language of the user's message.",
].join(" ");

function fallbackTitle(text: string): string {
	const collapsed = text.replace(/\s+/g, " ").trim();
	if (collapsed.length <= MAX_TITLE_CHARS) return collapsed;
	return `${collapsed.slice(0, MAX_TITLE_CHARS - 1).trimEnd()}…`;
}

function cleanTitle(raw: string): string {
	const collapsed = raw.replace(/\s+/g, " ").trim().replace(/^["'`]|["'`]$/g, "").replace(/\.$/, "");
	if (!collapsed) return "";
	if (collapsed.length <= MAX_TITLE_CHARS) return collapsed;
	return `${collapsed.slice(0, MAX_TITLE_CHARS - 1).trimEnd()}…`;
}

export default function herdrSessionTitle(pi: ExtensionAPI) {
	let done = false;

	async function generate(text: string, ctx: ExtensionContext): Promise<string> {
		const model = ctx.modelRegistry.find(PROVIDER, MODEL_ID);
		if (!model) throw new Error(`model ${PROVIDER}/${MODEL_ID} not found in registry`);

		const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
		if (!auth.ok) throw new Error(auth.error);

		const message = await completeSimple(
			model,
			{
				systemPrompt: SYSTEM_PROMPT,
				messages: [
					{
						role: "user",
						content: [{ type: "text", text: text.slice(0, MAX_INPUT_CHARS) }],
						timestamp: Date.now(),
					},
				],
			},
			{ apiKey: auth.apiKey, headers: auth.headers, maxTokens: 64, reasoning: "minimal" },
		);
		if (message.stopReason === "error") throw new Error(message.errorMessage ?? "title request failed");

		return message.content
			.filter((part): part is TextContent => part.type === "text")
			.map((part: TextContent) => part.text)
			.join(" ");
	}

	async function report(title: string): Promise<void> {
		const paneId = process.env.HERDR_ACTIVE_PANE_ID;
		if (!paneId) return;
		await pi.exec("herdr", [
			"pane",
			"report-metadata",
			paneId,
			"--source",
			TOKEN_SOURCE,
			"--token",
			`session=${title}`,
		]);
	}

	pi.on("input", async (event, ctx) => {
		if (done || event.source !== "interactive") return;
		const text = event.text.trim();
		if (!text || text.startsWith("/")) return;
		done = true;

		let title = fallbackTitle(text);
		try {
			title = cleanTitle(await generate(text, ctx)) || title;
		} catch {
			// Keep the truncated first message.
		}

		pi.setSessionName(title);
		await report(title);
	});

	pi.on("session_info_changed", async (event) => {
		if (!event.name) return;
		done = true;
		await report(event.name);
	});
}

/**
 * System Prompt Printer Extension
 *
 * Registers a /system-prompt command that prints the current system prompt
 * to the console at any time.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("system-prompt", {
		description: "Print the current system prompt to the console",
		handler: async (_args, ctx) => {
			const prompt = ctx.getSystemPrompt();
			console.log("\n=== System Prompt ===\n");
			console.log(prompt);

			console.log("\n=== End System Prompt ===\n");
		},
	});
}

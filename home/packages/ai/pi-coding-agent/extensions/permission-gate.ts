/**
 * Permission Gate Extension
 *
 * Gates potentially dangerous bash commands in three modes:
 *
 * - off:  no gating at all
 * - auto: regex rules pre-filter, then a classifier model decides whether the
 *         user already authorized this specific action (Claude Code auto mode)
 * - ask:  confirm every regex match, with a per-session "always allow" escape
 *
 * The regex rules are a coarse pre-filter, not the verdict: in auto mode most
 * matches (`eval` in a harmless context, a `git push` the user just asked for)
 * are allowed without prompting.
 *
 * Provider and model are overridable through PI_PERMS_PROVIDER and PI_PERMS_MODEL.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { TextContent } from "@earendil-works/pi-ai";
import { completeSimple } from "@earendil-works/pi-ai/compat";

type Mode = "off" | "auto" | "ask";

const MODES: Mode[] = ["off", "auto", "ask"];
const DEFAULT_MODE: Mode = "auto";
const PROVIDER = process.env.PI_PERMS_PROVIDER || "openai-codex";
const MODEL_ID = process.env.PI_PERMS_MODEL || "gpt-5.6-luna";
const STATUS_KEY = "permission-gate";
const RECENT_INPUTS = 6;

/**
 * Each category states what the user must have named for the action to count as
 * authorized. Naming the category alone is never enough.
 */
const TAXONOMY = [
	"destroy-data [must name: the exact path, branch, or table being destroyed]: irreversible deletion or overwrite of files, history, or database objects.",
	"raw-disk [must name: the device]: writing to block devices, creating filesystems, partitioning, erasing volumes.",
	"escalate-privileges [must name: the command being escalated]: sudo, su, recursive permission or ownership changes.",
	"mutate-system [must name: the service, setting, or package]: system config, launch services, firewall, security settings, package install or removal, shutdown or reboot.",
	"remote-code [must name: the source URL or repo]: executing content fetched from the network.",
	"publish-remote [must name: the remote, host, or environment]: pushing commits, deploying, mutating clusters or infrastructure, connecting to remote hosts.",
];

const dangerousRules = [
	// destructive deletion
	{ label: "destructive deletion: rm", pattern: /\brm\b\s+/i },
	{ label: "destructive deletion: find -delete", pattern: /\bfind\b.*\s-delete\b/i },
	{ label: "destructive deletion: xargs rm", pattern: /\bxargs\s+rm\b/i },
	{ label: "destructive deletion: shred", pattern: /\bshred\b/i },

	// forceful overwrite / extraction
	{ label: "forceful overwrite: mv -f", pattern: /\bmv\s+-f\b/i },
	{ label: "forceful overwrite: cp -f", pattern: /\bcp\s+-f\b/i },
	{ label: "archive extraction: tar -x", pattern: /\btar\b.*\s-x[fzjJ]\b/i },
	{ label: "archive extraction: unzip", pattern: /\bunzip\b/i },

	// privilege escalation / ownership / perms
	{ label: "privilege escalation: sudo", pattern: /\bsudo\b/i },
	{ label: "privilege escalation: su", pattern: /\bsu\b\s+/i },
	{ label: "permission change: chmod 777", pattern: /\bchmod\b.*\b777\b/i },
	{ label: "permission change: chmod -R", pattern: /\bchmod\s+-R\b/i },
	{ label: "ownership change: chown -R", pattern: /\bchown\s+-R\b/i },

	{ label: "remote access: ssh", pattern: /\bssh.*/i },

	// disk / filesystem operations
	{ label: "disk write: dd to /dev", pattern: /\bdd\b.*\bof =\/dev\//i },
	{ label: "filesystem creation: mkfs", pattern: /\bmkfs(?:\.\w+)?\b/i },
	{ label: "partitioning: fdisk/parted", pattern: /\b(fdisk|parted)\b/i },
	{ label: "disk utility mutation: diskutil erase/partition", pattern: /\bdiskutil\s+(eraseDisk|partitionDisk)\b/i },

	// remote script execution
	{ label: "remote script execution: curl|wget pipe to shell", pattern: /\b(curl|wget)\b.*\|\s*(sh|bash|zsh)\b/i },
	{ label: "remote script execution: shell -c $(curl ...)", pattern: /\b(sh|bash|zsh)\s+-c\s+["']?\$\(curl\b/i },

	// process / system disruption
	{ label: "system disruption: kill -9 -1", pattern: /\bkill\s+-9\s+-1\b/i },
	{ label: "process termination: killall/pkill", pattern: /\b(killall|pkill)\b/i },
	{ label: "system shutdown/reboot", pattern: /\b(shutdown|reboot|halt)\b/i },
	{ label: "firewall/network mutation", pattern: /\b(iptables|ufw|pfctl|networksetup)\b/i },
	{ label: "service unload: launchctl", pattern: /\blaunchctl\s+(unload|bootout)\b/i },
	{ label: "system defaults write", pattern: /\bdefaults\s+write\b/i },
	{ label: "system integrity config: csrutil", pattern: /\bcsrutil\b/i },
	{ label: "gatekeeper disable: spctl --master-disable", pattern: /\bspctl\b.*\b--master-disable\b/i },

	// package / system mutation
	{ label: "package removal: apt remove/purge", pattern: /\bapt\s+(remove|purge)\b/i },
	{ label: "package removal: brew uninstall/cleanup", pattern: /\bbrew\s+(uninstall|cleanup)\b/i },
	{ label: "global package removal: npm uninstall -g", pattern: /\bnpm\s+uninstall\s+-g\b/i },

	// destructive git actions
	{ label: "git destructive reset: git reset --hard", pattern: /\bgit\s+reset\s+--hard\b/i },
	{ label: "git destructive clean: git clean -fdx", pattern: /\bgit\s+clean\s+-fdx\b/i },
	{ label: "git remote mutation: git push", pattern: /\bgit\s+push\b/i },

	// infra / container deletion
	{ label: "docker prune: docker system prune -a", pattern: /\bdocker\s+system\s+prune\b.*\s-a\b/i },
	{ label: "docker forced removal: docker rm -f", pattern: /\bdocker\s+rm\b.*\s-f\b/i },
	{ label: "cluster mutation: kubectl delete", pattern: /\bkubectl\s+delete\b/i },
	{ label: "terraform destroy", pattern: /\bterraform\s+destroy\b/i },
	{ label: "terraform command", pattern: /\bterraform\s+\b/i },

	// database destruction
	{ label: "database destruction: DROP statement", pattern: /\b(sqlite3|psql|mysql)\b.*\bDROP\b/i },
];

const CLASSIFIER_PROMPT = [
	"You are a permission classifier for a coding agent. Decide whether the user has already",
	"authorized the command the agent is about to run.",
	"",
	"Categories, each stating what the user must have named:",
	...TAXONOMY.map((line) => `- ${line}`),
	"",
	"A command is authorized only when the user named the specific target, not merely the",
	"general activity. \"Go ahead\" or \"fix the tests\" never authorizes a category on its own.",
	"A command that matches no category is authorized.",
	"",
	'Answer with one line of JSON: {"allow":true} or',
	'{"allow":false,"category":"<category>","reason":"<one sentence naming what was not authorized>"}',
].join("\n");

function isMode(value: string): value is Mode {
	return (MODES as string[]).includes(value);
}

export default function permissionGate(pi: ExtensionAPI) {
	const flagDefault = process.env.PI_PERMS_MODE || DEFAULT_MODE;
	let mode: Mode = isMode(flagDefault) ? flagDefault : DEFAULT_MODE;
	const allowedRules = new Set<string>();
	const recentInputs: string[] = [];

	function showMode(ctx: ExtensionContext) {
		const suffix = allowedRules.size ? ` +${allowedRules.size}` : "";
		ctx.ui.setStatus(STATUS_KEY, `perms: ${mode}${suffix}`);
	}

	async function classify(command: string, rule: string, ctx: ExtensionContext) {
		const model = ctx.modelRegistry.find(PROVIDER, MODEL_ID);
		if (!model) throw new Error(`model ${PROVIDER}/${MODEL_ID} not found in registry`);

		const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
		if (!auth.ok) throw new Error(auth.error);

		const request = [
			`Recent user messages:\n${recentInputs.join("\n---\n") || "(none)"}`,
			`Command: ${command}`,
			`Pre-filter rule matched: ${rule}`,
		].join("\n\n");

		const message = await completeSimple(
			model,
			{
				systemPrompt: CLASSIFIER_PROMPT,
				messages: [{ role: "user", content: [{ type: "text", text: request }], timestamp: Date.now() }],
			},
			{ apiKey: auth.apiKey, headers: auth.headers, maxTokens: 200, reasoning: "minimal" },
		);
		if (message.stopReason === "error") throw new Error(message.errorMessage ?? "classifier request failed");

		const text = message.content
			.filter((part): part is TextContent => part.type === "text")
			.map((part: TextContent) => part.text)
			.join(" ");

		const json = text.match(/\{.*\}/s);
		if (!json) throw new Error(`classifier returned no JSON: ${text.slice(0, 200)}`);
		return JSON.parse(json[0]) as { allow: boolean; category?: string; reason?: string };
	}

	async function ask(command: string, rule: string, ctx: ExtensionContext) {
		const always = "Always allow this rule (session)";
		const choice = await ctx.ui.select(
			`⚠️ Dangerous command:\n\n  ${command}\n\nMatched rule: ${rule}\n\nAllow?`,
			["Yes", always, "No"],
		);

		if (choice === always) {
			allowedRules.add(rule);
			showMode(ctx);
			return undefined;
		}
		if (choice !== "Yes") return { block: true, reason: `Blocked by user (matched rule: ${rule})` };
		return undefined;
	}

	pi.registerFlag("perms", {
		type: "string",
		description: `Permission gate mode: ${MODES.join(" | ")}`,
		default: mode,
	});

	pi.registerCommand("perms", {
		description: "Show or set the permission gate mode",
		handler: async (args, ctx) => {
			const requested = args.trim();
			if (requested && isMode(requested)) {
				mode = requested;
			} else if (requested) {
				ctx.ui.notify(`Unknown mode "${requested}". Use: ${MODES.join(", ")}`, "error");
				return;
			} else {
				const choice = await ctx.ui.select("Permission gate mode", [...MODES]);
				if (!choice || !isMode(choice)) return;
				mode = choice;
			}
			showMode(ctx);
			ctx.ui.notify(`Permission gate: ${mode}`, "info");
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		const flag = pi.getFlag("perms");
		if (typeof flag === "string" && isMode(flag)) mode = flag;
		showMode(ctx);
	});

	pi.on("input", async (event) => {
		if (event.source !== "interactive") return undefined;
		recentInputs.push(event.text.trim());
		if (recentInputs.length > RECENT_INPUTS) recentInputs.shift();
		return undefined;
	});

	pi.on("tool_call", async (event, ctx) => {
		if (mode === "off" || event.toolName !== "bash") return undefined;

		const command = event.input.command as string;
		const matched = dangerousRules.find((rule) => rule.pattern.test(command));
		if (!matched || allowedRules.has(matched.label)) return undefined;

		if (mode === "auto") {
			try {
				const verdict = await classify(command, matched.label, ctx);
				if (verdict.allow) return undefined;
				return {
					block: true,
					reason: `[${verdict.category ?? "unauthorized"}] ${verdict.reason ?? "not authorized by the user"}. Continue with the rest of the task; ask the user if this step is required.`,
				};
			} catch (error) {
				// Classifier unavailable: fall back to asking rather than silently allowing.
				ctx.ui.notify(`Permission classifier failed: ${String(error)}`, "warning");
			}
		}

		if (!ctx.hasUI) {
			return { block: true, reason: `Dangerous command blocked (matched rule: ${matched.label}, no UI for confirmation)` };
		}
		return ask(command, matched.label, ctx);
	});
}

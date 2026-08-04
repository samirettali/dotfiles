/**
 * Speak Extension
 *
 * Reads assistant responses out loud while they are being generated, by piping
 * the streamed text deltas into `speak --stream` (ElevenLabs websocket TTS).
 *
 * One `speak` process per turn, not per message: a single websocket produces
 * continuous audio, whereas a process per assistant message would overlap when
 * the model resumes talking after a tool call.
 *
 * Thinking blocks are not read out — they are long, unstructured, and mostly
 * uninteresting to listen to. Instead the first thinking block of a turn plays a
 * short cached earcon so silence is distinguishable from the model working.
 *
 * Defaults come from PI_SPEAK and PI_SPEAK_CUE; voice and model are read by the
 * script itself from SPEAK_VOICE / SPEAK_MODEL.
 */

import { spawn, type ChildProcess } from "node:child_process";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const STATUS_KEY = "speak";
const CUE_INTERVAL_MS = Number(process.env.PI_SPEAK_CUE_INTERVAL || 15_000);

function envFlag(name: string, fallback: boolean): boolean {
	const value = (process.env[name] || "").trim().toLowerCase();
	if (["on", "1", "true", "yes"].includes(value)) return true;
	if (["off", "0", "false", "no"].includes(value)) return false;
	return fallback;
}

export default function speak(pi: ExtensionAPI) {
	let enabled = envFlag("PI_SPEAK", false);
	let cueEnabled = envFlag("PI_SPEAK_CUE", true);
	let voice = process.env.SPEAK_VOICE || "";

	let child: ChildProcess | null = null;
	let cue: ChildProcess | null = null;
	let lastCue = 0;
	let warned = false;

	function showStatus(ctx: ExtensionContext) {
		ctx.ui.setStatus(STATUS_KEY, enabled ? `speak: on${voice ? ` (${voice})` : ""}` : "");
	}

	function spawnSpeak(args: string[]): ChildProcess {
		const full = voice ? ["--voice", voice, ...args] : args;
		return spawn("speak", full, { stdio: ["pipe", "ignore", "pipe"] });
	}

	function ensureChild(ctx: ExtensionContext): ChildProcess {
		// Respawn when the previous process is gone: a long turn can outlive the
		// websocket's inactivity timeout.
		if (child && child.exitCode === null && !child.killed) return child;

		const next = spawnSpeak(["--stream", "--quiet"]);
		next.stderr?.on("data", (data: Buffer) => {
			const message = data.toString().trim();
			if (!message || warned) return;
			warned = true;
			ctx.ui.notify(`speak: ${message.split("\n")[0]}`, "warning");
		});
		next.on("error", () => {
			if (warned) return;
			warned = true;
			ctx.ui.notify("speak: command not found", "error");
		});
		child = next;
		return next;
	}

	function endChild() {
		// Closing stdin lets the current sentence finish playing instead of
		// cutting the audio off mid-word.
		child?.stdin?.end();
		child = null;
	}

	function stop() {
		child?.kill("SIGTERM");
		child = null;
		cue?.kill("SIGTERM");
		cue = null;
	}

	function playCue() {
		if (!enabled || !cueEnabled) return;
		if (child || cue) return;
		if (Date.now() - lastCue < CUE_INTERVAL_MS) return;
		lastCue = Date.now();

		const next = spawnSpeak(["--cue"]);
		next.on("exit", () => {
			if (cue === next) cue = null;
		});
		cue = next;
	}

	pi.registerCommand("speak", {
		description: "Toggle reading assistant responses out loud",
		getArgumentCompletions: (prefix: string) => {
			const items = ["on", "off", "stop", "cue", "voice", "status"]
				.filter((value) => value.startsWith(prefix))
				.map((value) => ({ value, label: value }));
			return items.length > 0 ? items : null;
		},
		handler: async (args, ctx) => {
			const [command = "", ...rest] = args.trim().split(/\s+/);

			switch (command) {
				case "":
					enabled = !enabled;
					break;
				case "on":
					enabled = true;
					break;
				case "off":
					enabled = false;
					stop();
					break;
				case "stop":
					stop();
					ctx.ui.notify("speak: stopped", "info");
					return;
				case "cue":
					cueEnabled = !cueEnabled;
					ctx.ui.notify(`speak: thinking cue ${cueEnabled ? "on" : "off"}`, "info");
					return;
				case "voice":
					voice = rest.join(" ");
					ctx.ui.notify(`speak: voice ${voice || "default"}`, "info");
					showStatus(ctx);
					return;
				case "status":
					ctx.ui.notify(
						`speak: ${enabled ? "on" : "off"}, cue ${cueEnabled ? "on" : "off"}, voice ${voice || "default"}`,
						"info",
					);
					return;
				default:
					ctx.ui.notify(`Unknown argument "${command}". Use: on, off, stop, cue, voice, status`, "error");
					return;
			}

			warned = false;
			showStatus(ctx);
			ctx.ui.notify(`speak: ${enabled ? "on" : "off"}`, "info");
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		showStatus(ctx);
	});

	pi.on("turn_start", async () => {
		lastCue = 0;
	});

	pi.on("message_update", async (event, ctx) => {
		if (!enabled) return;
		const update = event.assistantMessageEvent;
		if (!update) return;

		if (update.type === "thinking_start") {
			playCue();
			return;
		}
		if (update.type !== "text_delta" || !update.delta) return;

		cue?.kill("SIGTERM");
		cue = null;
		ensureChild(ctx).stdin?.write(update.delta);
	});

	pi.on("turn_end", async () => {
		endChild();
	});

	pi.on("agent_end", async () => {
		endChild();
	});

	// A new prompt means the previous answer is no longer wanted.
	pi.on("input", async () => {
		stop();
	});

	pi.on("session_shutdown", async () => {
		stop();
	});
}

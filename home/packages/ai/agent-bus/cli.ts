#!/usr/bin/env bun
/**
 * agent-bus CLI, and the Claude Code hook entrypoints.
 *
 *   agent-bus list
 *   agent-bus send --from <id> <target> <text>
 *   agent-bus hook-session-start | hook-stop | hook-session-end   (stdin: hook JSON)
 */

import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { basename } from "node:path";
import {
    type AgentInfo,
    drain,
    formatAgentList,
    formatMessages,
    listAgents,
    register,
    resolveTarget,
    send,
    shortId,
    unregister,
} from "./bus.ts";

interface HookInput {
    session_id: string;
    cwd?: string;
    hook_event_name?: string;
}

/**
 * Hooks run as short-lived grandchildren of the agent, so our own pid says
 * nothing about session liveness. Walk up to the owning `claude` process.
 */
function ownerPid(): number {
    let pid = process.ppid;
    for (let hop = 0; hop < 8; hop++) {
        let line: string;
        try {
            line = execFileSync("ps", ["-o", "ppid=,comm=", "-p", String(pid)], { encoding: "utf-8" }).trim();
        } catch {
            return pid;
        }
        const match = line.match(/^\s*(\d+)\s+(.*)$/);
        if (!match) return pid;
        if (basename(match[2].trim()).includes("claude")) return pid;
        const parent = Number(match[1]);
        if (!parent || parent <= 1) return pid;
        pid = parent;
    }
    return pid;
}

function readStdin(): HookInput {
    try {
        return JSON.parse(readFileSync(0, "utf-8")) as HookInput;
    } catch {
        return { session_id: "" };
    }
}

function selfFromHook(input: HookInput): AgentInfo {
    const cwd = input.cwd || process.cwd();
    return {
        id: shortId(input.session_id || String(process.pid)),
        name: `claude:${basename(cwd)}`,
        kind: "claude",
        cwd,
        pid: ownerPid(),
        startedAt: new Date().toISOString(),
    };
}

function emitContext(hookEventName: string, additionalContext: string): void {
    process.stdout.write(JSON.stringify({ hookSpecificOutput: { hookEventName, additionalContext } }));
}

function usageBlock(self: AgentInfo): string {
    const peers = listAgents().filter((a) => a.id !== self.id);
    return [
        "## Agent bus",
        `Other agent sessions can message this one. Your agent id is \`${self.id}\`.`,
        [
            "To message another session, run:",
            "```",
            `agent-bus send --from ${self.id} <target-id> "<message>"`,
            "```",
            "`agent-bus list` shows who is running. Incoming messages are delivered to you automatically.",
        ].join("\n"),
        peers.length > 0 ? `Currently running:\n${formatAgentList(peers)}` : "No other sessions are running right now.",
    ].join("\n\n");
}

function cmdSend(args: string[]): number {
    let from: string | undefined;
    const rest: string[] = [];
    for (let i = 0; i < args.length; i++) {
        if (args[i] === "--from") from = args[++i];
        else rest.push(args[i]);
    }

    const [target, ...text] = rest;
    if (!target || text.length === 0) {
        process.stderr.write('usage: agent-bus send --from <id> <target> "<message>"\n');
        return 2;
    }

    const resolved = resolveTarget(target, from);
    if (!resolved.ok) {
        process.stderr.write(`${resolved.error}\n`);
        return 1;
    }

    const sender = listAgents().find((a) => a.id === from) ?? {
        id: from ?? "unknown",
        name: from ?? "unknown",
        kind: "claude" as const,
        cwd: process.cwd(),
        pid: process.pid,
        startedAt: new Date().toISOString(),
    };

    send(sender, resolved.agent, text.join(" "));
    process.stdout.write(`sent to ${resolved.agent.id} (${resolved.agent.name})\n`);
    return 0;
}

function main(): number {
    const [command, ...args] = process.argv.slice(2);

    switch (command) {
        case "list":
            process.stdout.write(`${formatAgentList(listAgents())}\n`);
            return 0;

        case "send":
            return cmdSend(args);

        case "hook-session-start": {
            const self = selfFromHook(readStdin());
            register(self);
            emitContext("SessionStart", usageBlock(self));
            return 0;
        }

        case "hook-stop": {
            const input = readStdin();
            const self = selfFromHook(input);
            // Refresh presence: the session may have started before the bus existed.
            register(self);
            const messages = drain(self.id);
            if (messages.length > 0) emitContext("Stop", formatMessages(messages));
            return 0;
        }

        case "hook-session-end":
            unregister(selfFromHook(readStdin()).id);
            return 0;

        default:
            process.stderr.write("usage: agent-bus <list|send|hook-session-start|hook-stop|hook-session-end>\n");
            return 2;
    }
}

process.exit(main());

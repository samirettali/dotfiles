/**
 * Agent bus for pi.
 *
 * Publishes this session on the shared bus, watches its inbox, and delivers
 * incoming messages as user messages. Delivery is end-of-turn: an in-flight
 * agent finishes its tool calls first. Flip DELIVER_AS to "steer" to interrupt
 * mid-turn instead.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { type FSWatcher, watch } from "node:fs";
import { basename } from "node:path";
import { Type } from "typebox";
import {
    type AgentInfo,
    drain,
    formatAgentList,
    formatMessages,
    inboxDir,
    listAgents,
    register,
    resolveTarget,
    send,
    shortId,
    unregister,
} from "./bus.ts";

const DELIVER_AS = "followUp" as const;
const POLL_MS = 5000;

export default function agentBusExtension(pi: ExtensionAPI) {
    let self: AgentInfo | undefined;
    let watcher: FSWatcher | undefined;
    let poller: NodeJS.Timeout | undefined;
    let draining = false;

    function identify(ctx: ExtensionContext): AgentInfo | undefined {
        const sessionFile = ctx.sessionManager.getSessionFile();
        if (!sessionFile) return undefined; // Ephemeral session: nothing to address.

        return {
            id: shortId(sessionFile),
            name: pi.getSessionName() || `pi:${basename(ctx.cwd)}`,
            kind: "pi",
            cwd: ctx.cwd,
            pid: process.pid,
            startedAt: new Date().toISOString(),
        };
    }

    async function deliver(ctx: ExtensionContext): Promise<void> {
        if (!self || draining) return;
        draining = true;
        try {
            const messages = drain(self.id);
            if (messages.length === 0) return;

            ctx.ui.notify(`Agent bus: ${messages.length} incoming`, "info");
            const text = formatMessages(messages);
            if (ctx.isIdle()) pi.sendUserMessage(text);
            else pi.sendUserMessage(text, { deliverAs: DELIVER_AS });
        } finally {
            draining = false;
        }
    }

    function stopWatching(): void {
        watcher?.close();
        watcher = undefined;
        if (poller) clearInterval(poller);
        poller = undefined;
    }

    pi.on("session_start", async (_event, ctx) => {
        stopWatching();
        self = identify(ctx);
        if (!self) return;

        register(self);

        // fs.watch is the fast path; the interval covers platforms where it
        // misses events, and picks up mail queued before this session started.
        try {
            watcher = watch(inboxDir(self.id), () => void deliver(ctx));
        } catch {
            // Fall back to polling alone.
        }
        poller = setInterval(() => void deliver(ctx), POLL_MS);
        void deliver(ctx);
    });

    pi.on("session_info_changed", async () => {
        if (!self) return;
        self = { ...self, name: pi.getSessionName() || self.name };
        register(self);
    });

    pi.on("session_shutdown", async () => {
        stopWatching();
        if (self) unregister(self.id);
        self = undefined;
    });

    pi.registerCommand("agents", {
        description: "List running agent sessions on the bus",
        handler: async (_args, ctx) => {
            ctx.ui.notify(formatAgentList(listAgents(), self?.id), "info");
        },
    });

    pi.registerTool({
        name: "agent_list",
        label: "List agents",
        description: "List the other agent sessions currently running that you can message.",
        promptSnippet: "List other running agent sessions",
        parameters: Type.Object({}),
        async execute() {
            const others = listAgents().filter((a) => a.id !== self?.id);
            return { content: [{ type: "text", text: formatAgentList(others) }], details: {} };
        },
    });

    pi.registerTool({
        name: "agent_send",
        label: "Message agent",
        description:
            "Send a message to another running agent session. The message is delivered to that session after it finishes its current turn. Use agent_list first to find the target id.",
        promptSnippet: "Send a message to another agent session",
        promptGuidelines: [
            "Use agent_send only when the user asks to coordinate with, hand off to, or notify another session.",
            "Messages are one-way; the other session decides whether to reply. Do not wait for an answer.",
        ],
        parameters: Type.Object({
            target: Type.String({ description: "Target agent id, id prefix, or session name" }),
            message: Type.String({ description: "Message text to deliver" }),
        }),
        async execute(_toolCallId, params) {
            if (!self) {
                return { content: [{ type: "text", text: "This session is not on the bus (ephemeral session)." }], details: {} };
            }

            const resolved = resolveTarget(params.target, self.id);
            if (!resolved.ok) {
                return { content: [{ type: "text", text: resolved.error }], details: {} };
            }

            send(self, resolved.agent, params.message);
            return {
                content: [{ type: "text", text: `Delivered to ${resolved.agent.id} (${resolved.agent.name}).` }],
                details: {},
            };
        },
    });
}

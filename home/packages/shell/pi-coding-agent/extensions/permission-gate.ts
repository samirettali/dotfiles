/**
 * Permission Gate Extension
 *
 * Prompts for confirmation before running potentially dangerous bash commands.
 * Patterns checked include destructive deletion, overwrite operations,
 * permission changes, raw disk operations, remote script execution,
 * system disruption, package/system mutation, destructive git actions,
 * infra/container deletion, and database drop statements.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function(pi: ExtensionAPI) {
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
        { label: "dynamic evaluation: eval", pattern: /\beval\b/i },

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

    pi.on("tool_call", async (event, ctx) => {
        if (event.toolName !== "bash") return undefined;

        const command = event.input.command as string;
        const matchedRule = dangerousRules.find((rule) => rule.pattern.test(command));

        if (matchedRule) {
            if (!ctx.hasUI) {
                // In non-interactive mode, block by default
                return { block: true, reason: `Dangerous command blocked (matched rule: ${matchedRule.label}, no UI for confirmation)` };
            }

            const choice = await ctx.ui.select(`⚠️ Dangerous command:\n\n  ${command}\n\nMatched rule: ${matchedRule.label}\n\nAllow?`, ["Yes", "No"]);

            if (choice !== "Yes") {
                return { block: true, reason: `Blocked by user (matched rule: ${matchedRule.label})` };
            }
        }

        return undefined;
    });
}


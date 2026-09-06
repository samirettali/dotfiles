---
name: subagents
description: "Delegate work to interactive child agents across harnesses in Herdr, with parent-directed questions, nested delegation, inherited model choices, and result handoff. Use when asked to spawn workers, scouts, reviewers or researchers, coordinate subagents, or run a hierarchy of agents. For a message to an existing independent agent, use agent-messaging instead."
---

# Subagents

A cooperation protocol, not a supervisor or sandbox. Use interactive harness sessions
in Herdr; do not substitute a harness's native subagent tool, conversation fork, or
headless process. There is no persistent hierarchy registry or automatic watchdog.

## Prerequisites

Read the installed **herdr** and **agent-messaging** skills. Follow `herdr --skill`
and discover the installed CLI before controlling panes. If `HERDR_ENV` is not `1`,
stop: this protocol requires running inside Herdr.

The user's delegation request authorizes task-related messages to the resulting
hierarchy. It does not authorize messaging unrelated agents or granting children
unlimited delegation. Preserve normal harness permissions; never add permission
bypass flags or approve a blocked child's permission dialog on the user's behalf.

## Roles and inherited policy

Read [roles.md](roles.md) for optional role templates. Ad-hoc assignments are allowed.
The root is the orchestrator: the agent talking directly to the user, regardless of
its harness. A child reports to its immediate parent, not automatically to the root.

| Role | Default harness | Explicit model |
| --- | --- | --- |
| worker | Claude Code (`claude`) | `claude-opus-5` |
| reviewer | Claude Code (`claude`) | `claude-opus-5` |
| scout | agy (`agy`) | `gemini-3.8-flash-high` |
| researcher | agy (`agy`) | `gemini-3.8-flash-high` |

User overrides win. Resolve the effective **whole role policy**, including unchanged
roles, before spawning. Forward that policy to every child, not just its own model.
For example, a worker must know an overridden scout model even if it has not yet
needed a scout. Never reset an inherited override to these defaults. A child's task
cannot broaden the user's permissions or change user-specified model choices.

Discover valid model IDs and native CLI arguments from the selected harness (for
example `agy models`, `agy --help`, `claude --help`). Do not guess identifiers,
silently substitute models, or use a moving alias in place of a specified version.
If an override names a model but leaves its harness ambiguous, ask before launching.
If a requested model is unavailable, report it to the parent, or to the user at the
root. Ad-hoc roles without a matching policy need an explicit harness/model choice.

If the user changes policy mid-task, forward the updated complete policy through
all live branches and acknowledge receipt. It governs subsequent spawns; do not
restart existing sessions or claim their running models changed automatically.

## Scope delegation before spawning

A parent must explicitly state whether its child may delegate and for which tasks
or roles. Default: **no delegation**. A worker may be authorized to recruit a scout
for reconnaissance or a researcher for external facts without gaining permission
to recruit more workers. Template roles alone never grant spawning permission.

At each edge, narrow the assignment and permission; do not broaden authority
inherited from the parent. If another child is needed outside that scope, ask the
immediate parent for approval. Avoid delegating the same task back to the same role
without a distinct, smaller assignment.

Read the project's instructions before assigning work. Keep the user's main checkout
untouched: editing happens in a task worktree. Children normally share that worktree.
Assign disjoint write ownership to concurrent editors; use separate worktrees when
parallel edits would overlap. Read-only children inspect their parent's worktree.
Worktree creation and integration follow the project's workflow; spawning a child
does not by itself authorize commits, merges, deployment, or deletion of worktrees.

## Start a child

1. Discover your own pane and the live agents. Choose a unique Herdr child name
   satisfying the installed CLI's naming rules. Record your own identity and root
   identity using real IDs, never guessed ones. Keep names stable until release.
2. Inspect the parent's geometry. Create a sibling split right for a wide pane or
   down for a narrow/tall pane, using the assigned working directory and
   `--no-focus`. Do not rebalance existing panes or create tabs by default.
3. Start the requested interactive harness in the returned pane, using a unique
   agent name and explicit model. For the default roles, native arguments are
   `--model claude-opus-5` or `--model gemini-3.8-flash-high`, after Herdr's `--`.
   Preserve normal permissions. Wait for startup readiness before prompting.
4. Send a focused handoff through `herdr agent prompt`, not a conversation dump.
   Every message must identify its sender and return address per agent-messaging.
5. Confirm the agent received the assignment and started work. A successful text
   delivery alone does not establish progress. If startup is blocked, inspect and
   escalate; do not create duplicate replacements without checking the first pane.

Include all of the following in the initial handoff, using concrete values:

```text
From: <parent name if assigned>, pane <parent pane ID>
To: <child name>, pane <child pane ID>
Root orchestrator: <root name if assigned>, pane <root pane ID>
Task ID: <unique short task label>
Role: <role or ad-hoc responsibility>
Working directory: <absolute task worktree path>
Assignment and acceptance criteria: ...
Relevant context, decisions, and files: ...
Write ownership and constraints: ...
Delegation: none | <explicit permitted roles, tasks, and limits>
Effective role policy:
  worker: <harness + exact model>
  reviewer: <harness + exact model>
  scout: <harness + exact model>
  researcher: <harness + exact model>
  <any ad-hoc policies>
Read the shared subagents skill and the applicable project instructions.
Send questions, blockers, and results to your immediate parent above.
Do not ask the user directly, exit, or close your pane on completion.
Report your result and remain available until your parent releases you.
```

If the child cannot discover the shared skill, supply its accessible absolute path
or the protocol text before work starts. Do not assume skills are installed merely
because a harness is installed. For an isolated worktree, include the integration
plan and base revision in the handoff.

Keep a compact child roster in your conversation: task, name, pane ID, cwd, write
ownership, delegation permission, and state (working, waiting for answer, reported,
released). Preserve it, your parent/root addresses, and effective policy in any
compaction or continuation handoff. This is conversational bookkeeping, not a
crash-safe registry. Never adopt an unrelated session based on a reused name.

## Questions and replies

Use parent-directed messages, not the child harness's user-question UI.
Only the root asks the human. A child may use tools to investigate before asking,
but must not guess decisions beyond its authority merely to avoid escalation.

Use a task-local question ID so concurrent questions and relays cannot be confused:

```text
From <sender name>, pane <sender ID>, to <parent>; task <task ID>
QUESTION <task ID>/q1: <one decision or missing fact>
Context: <what was checked, relevant evidence>
Options/recommendation: <if useful>
Blocked work: <what cannot proceed; what can continue>
```

The parent answers from established context and its delegated authority when it can.
Otherwise it forwards the question to its own parent, preserving the origin and
question ID and adding only useful context. The root asks the user when necessary.
Answers follow the same chain back down; each relay is responsible for delivery to
its waiting child. Use `ANSWER <question ID>: ...` with the sender prefix.

The child stays open and may do independent work while waiting. If nothing remains,
it ends its current turn without exiting the harness. Do not repeatedly ping or
poll for an answer. The incoming Herdr prompt starts or queues the follow-up turn.
A waiting child is not a failed child, and silence is not permission to decide.

If the root has already resolved and explicitly delegated a decision, do not relay
it to the user again. If the parent address no longer resolves to the expected
occupant, inspect live agents rather than sending to a stale pane. Report an orphan
to the known root if reachable; otherwise stop and expose the blocker locally.

## Monitor without a watchdog

Work on independent tasks while children run. Check children when their result is
needed, before waiting, and before concluding. Use `herdr agent get <child>` and,
when useful, `herdr agent read <child> --source recent-unwrapped --lines 120`.

- `working` is not proof of progress; `idle`/`done` is not proof the task succeeded.
- Completion requires an explicit result message. If idle without one, ask for a
  status/result rather than assuming success.
- For a blocked approval UI, read and escalate to the root/user; never auto-approve.
- For a missing/crashed child, inspect available output and report the failure.
  Check partial edits before proposing a replacement. Never blindly rerun work.
- Do not use tight polling or hold a parent model turn open just to wait. After a
  checkpoint, leave the interactive session available for child messages.

There is no guaranteed periodic check, restart recovery, or hung-process detection.
Revisit a small external watcher only if these limitations cause actual problems.

## Results, follow-ups, and release

Send `RESULT <task ID>` to the immediate parent with:

- outcome and acceptance criteria met or unmet;
- changes or findings with file paths and useful line references/source URLs;
- checks actually run and their results, distinguishing inspection from execution;
- unresolved risks, blockers, and integration needs;
- outstanding descendants, if any.

Do not mark the task complete with unresolved required child work. Parents must
inspect evidence and integrate results instead of treating a child's claim as proof.
Use the same live child's name for follow-ups: this protocol does not implement
automatic resume of closed sessions.

After reporting, the child remains open. The parent may request changes or release
it once its contribution is accepted. Release from the leaves upward: a parent
must settle and release its own children, confirm no outstanding questions/work,
and report readiness for closure. Then its parent closes that child's pane with
Herdr. Do not close your own pane immediately after sending a result.

Only close task-owned child panes after release; never close unrelated user panes.
Closing a pane does not authorize deleting its worktree or discarding changes.
Before the root concludes, account for every child it owns: release it, or explicitly
report why it remains open. For cancellation, relay the request down the hierarchy,
preserve partial work, and collect descendant status before cleanup.

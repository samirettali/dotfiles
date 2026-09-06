---
name: subagents
description: "Delegate work to interactive child agents across harnesses in Herdr, with parent-directed questions, nested delegation, inherited model choices, and result handoff. Use when asked to spawn workers, scouts, reviewers or researchers, coordinate subagents, or run a hierarchy of agents. For a message to an existing independent agent, use agent-messaging instead."
---

# Subagents

A cooperation protocol, not a supervisor or sandbox. Use interactive harness
sessions in Herdr, not native subagent tools, conversation forks, or headless
processes. There is no persistent hierarchy registry or automatic watchdog.
If `HERDR_ENV` is not `1`, stop: this protocol requires running inside Herdr.

## Load by responsibility

Read the installed **agent-messaging** skill for transport and sender identity.
Resolve these references relative to this skill:

- **Parent spawning or managing children:** [Parent lifecycle](references/parent.md).
  This includes a child acting as a parent when delegation is authorized.
- **Child receiving an assignment:** [Child lifecycle](references/child.md).
- **Optional role templates:** [roles.md](roles.md). Ad-hoc assignments are allowed.

## Authority and inherited policy

The root is the agent talking directly to the user, regardless of harness. A
child reports to its immediate parent. Only the root asks the human; children
use parent-directed messages, not their harness's user-question UI.

The user's delegation request authorizes task-related messages within the resulting
hierarchy, not unrelated sessions or unlimited delegation. At each edge, narrow
scope and authority. Delegation defaults to **none** unless the parent explicitly
authorizes roles, tasks, and limits. Templates alone grant no spawning permission.

Preserve normal harness permissions. Never add bypass flags or approve another
agent's blocked permission dialog on the user's behalf. Spawning does not authorize
commits, merges, deployment, or worktree deletion. Never close unrelated panes or
discard changes as a side effect of closing a child.

| Role | Default harness | Explicit model |
| --- | --- | --- |
| worker | Claude Code (`claude`) | `claude-opus-5` |
| reviewer | Claude Code (`claude`) | `claude-opus-5` |
| scout | agy (`agy`) | `gemini-3.8-flash-high` |
| researcher | agy (`agy`) | `gemini-3.8-flash-high` |

User overrides win. Every child inherits the **whole effective role policy**,
including unchanged roles and overrides for roles it may later recruit. Never
reset inherited choices to defaults or broaden the user's permissions. Ad-hoc
roles without a matching policy need an explicit harness/model choice. Preserve
policy, parent/root addresses, and task state in compaction or continuation handoffs.

## Shared message contracts

Every message identifies its sender and return address per agent-messaging.
Use task-local question IDs to distinguish concurrent questions and relays:

```text
From <sender name>, pane <sender ID>, to <parent>; task <task ID>
QUESTION <task ID>/q1: <one decision or missing fact>
Context: <what was checked, relevant evidence>
Options/recommendation: <if useful>
Blocked work: <what cannot proceed; what can continue>
```

Reply with `ANSWER <question ID>:` and the sender prefix. Questions and answers
follow the immediate-parent chain; a relay preserves origin and ID and is
responsible for delivery. Do not relay a decision to the user again when the root
has already resolved and delegated it. Silence is not permission to decide.

Send `RESULT <task ID>` to the immediate parent with:

- outcome and acceptance criteria met or unmet;
- changes or findings with file paths and useful line references/source URLs;
- checks actually run and their results, distinguishing inspection from execution;
- unresolved risks, blockers, and integration needs;
- outstanding descendants, if any.

Completion requires an explicit result, not an idle status or successful text
delivery. Children remain available after reporting until their parent releases
them. Release descendants before their parent; account for unresolved work and
preserve partial changes on cancellation or failure.

# Child lifecycle

Follow the [shared protocol](../SKILL.md) and the project's instructions. Work
inside the assigned directory and write ownership. Your assignment cannot broaden
the user's permissions or change user-specified model choices.

## Questions and waiting

Send questions to your immediate parent using the shared `QUESTION` format, not
the harness's user-question UI. Investigate with tools before asking when useful,
but do not guess decisions beyond your authority merely to avoid escalation.

Stay open and do independent work while waiting. If nothing remains, end the
current turn without exiting the harness. Do not repeatedly ping or poll for an
answer. The incoming Herdr prompt starts or queues the follow-up turn. A waiting
child is not a failed child, and silence is not permission to decide.

If the parent address no longer resolves to the expected occupant, inspect live
agents rather than sending to a stale pane. Report an orphan to the known root
if reachable; otherwise stop and expose the blocker locally.

## Delegation and policy updates

Delegation defaults to none. If another child is needed outside your assignment's
permitted roles, tasks, or limits, ask the immediate parent. When authorized to
spawn, load the [parent lifecycle](parent.md) and forward the whole inherited
role policy, not just your own model choice.

Acknowledge updated policy and forward it through any live branches you own.
It governs future spawns; running sessions do not change models automatically.
Preserve your task state, effective policy, and parent/root addresses in any
compaction or continuation handoff.

## Results and release

Send `RESULT <task ID>` with the shared result fields to your immediate parent.
Remain available for follow-ups; do not exit or close your pane after reporting.
If you own descendants, resolve required work and release them first, then report
readiness for closure to your parent. Only your parent closes your pane after
accepting your contribution and releasing you.

On cancellation, preserve partial work and report its state. If you own children,
relay cancellation, collect their status, and follow the parent cleanup protocol.

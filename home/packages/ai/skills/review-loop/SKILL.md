---
name: review-loop
description: Have a second agent review the work, fix every finding that holds, and repeat until the reviewer has none left. Use when asked to get the change reviewed and to keep going until it is clean — "get a review and fix everything", "ask another agent for a review", "keep going until it says it is fine", "review loop", "get this reviewed and iterate".
disable-model-invocation: true
---

# Review loop

One reviewer, several rounds, one stop condition. The point is not the first review: it is that every round after the first one starts from what the reviewer already knows, so closed findings stay closed and the new ones are about the fixes.

## The loop

1. **Finish the work first.** Build, tests and linters green before anyone looks at it. A review of a broken branch spends its findings on the breakage.
2. **Spawn one reviewer** (see below). Read-only, fresh context, a stronger model than a linter — this is for correctness, not style.
3. **Act on every finding** (see below).
4. **Re-run the checks**, all of them, after each round.
5. **Reply to the same reviewer** with what you did, finding by finding, and ask for another round.
6. **Stop when it replies `No findings.`** — the exact sentence you asked for.

Between rounds, tell the user what came out in a few lines: the bugs first, what you disagreed with, what you left. Not a transcript.

## The reviewer

Spawn it as a native Claude Code subagent, in the background, with `model: "opus"` (Opus 5.5) and tools, but told not to edit. Its prompt carries:

- **Where the work is** — directory, branch, base, and the command that shows the diff. New files are untracked, so say to read them directly.
- **What the change is for.** Intent, not a diff summary: the reviewer needs the rule to judge the code against, and it can read the code itself.
- **The repo's conventions file** (`AGENTS.md`, `CLAUDE.md`), by path, to read first.
- **The commands that verify it**, to run rather than assume, plus **what is known broken and not part of this change** — a lint version mismatch, pre-existing formatting noise. Without that you get findings about someone else's mess.
- **What you are unsure about.** Name the two or three places you want looked at hardest. This is where the real bugs come back from.
- **The output format** — the repo's review convention if it has one, otherwise the `review-comments` skill. Findings only, bugs first, every one with `file:line`, and what to do about it on its last line.
- **The stop sentence**, verbatim: reply `No findings.` when nothing needs changing.

**One reviewer for the whole loop.** Continue it with `SendMessage` to its agent ID; a new agent each round has no memory of what it already accepted and re-opens it.

## Acting on the findings

- **A bug gets fixed**, and pinned with a test where the repo already has tests. Write the test, then check it fails against the old code — revert the fix for one run if that is what it takes. A regression test that never went red proves nothing. Where the repo has no tests, do not start a suite for this.
- **Doubts go to the user.** Fix what holds. A finding that needs a design or scope decision, or one you are not sure is real, is a question for the user, not something to settle with the reviewer.
- **An improvement gets fixed, or argued back** in the reply. Disagreeing is allowed and often right; saying nothing and skipping it is not, the next round will raise it again.
- **A note needs no action.** Repeat it to the user if it deserves a ticket.
- **Fix the cause, not the sentence.** If a finding says the comment lies, decide which of the two is wrong — the code or the comment.
- **Keep the diff on its subject.** A refactor the review suggests is its own pull request, and the reviewer will usually say so itself.
- **Update the documentation the repo asks for** in the same round. Anything outside the repo the change touches — an API client, a wiki, another repository — is the user's to confirm: say what needs updating and wait. The reviewer cannot see those either, so tell it what the user decided.

## Ending it

Stop at `No findings.`

Stop early, and bring it to the user, when a round returns only findings you disagree with, or when two rounds in a row move words rather than behaviour. Closing a finding sometimes opens a smaller one — that is the loop working, until the findings stop being about the code.

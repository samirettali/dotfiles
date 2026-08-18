---
name: code-review
description: Write the findings of a code review — of a pull request, a branch, or a diff — as Conventional Comments. Use when reviewing changes and reporting what is wrong with them, whether the comments go on the pull request or into a message. For prose that is not a review, use writing.
---

# Code review

A review is a list of findings, ordered by severity with the bugs first. Nothing else: no
summary of what the change does, no restatement of the description. State once, before the
findings, that the build, the tests and the formatter pass — it tells the reader which
failures you are *not* reporting.

## Format

[Conventional Comments](https://conventionalcomments.org):

```
**<label> (<decoration>):** <subject>

<discussion>
```

The subject carries the claim, not the topic — "the fee is counted twice", never "fee
handling". It has to stand on its own, read without the discussion under it, because it is
the only line most readers read in full.

Seven of the twelve labels the standard defines:

| label | when |
| --- | --- |
| `issue` | a specific problem with the code under review |
| `suggestion` | a concrete improvement — say what, and why |
| `question` | a concern you are not sure is relevant, or a decision that is the author's |
| `todo` | small, trivial, but necessary |
| `chore` | a task to be done before the change is accepted, outside the code itself |
| `note` | nothing to do, worth knowing |
| `nitpick` | a preference, always non-blocking |

`(blocking)` stops the change from being accepted until it is resolved, `(non-blocking)` does
not, `(if-minor)` leaves it to the author if the fix turns out to be trivial. `praise` is
deliberately left out: a review here is findings, and a compliment is one more line to scan.

## Rules

- **One kind of problem per comment, with all of its occurrences inside it.** A bug, a scope
  question and a preference bundled together get weighed the same and dismissed together. Ten
  instances of the same nit are one comment with one example, not ten.
- **Write what is wrong and what happens because of it, not how to implement the fix** — that
  is the author's call, and prescribing it starts an argument about the wrong thing.
  Interfaces others depend on (a payload, an endpoint, a field name) are a contract, not an
  implementation: pin those. When the resolution is not obvious, say why rather than leaving
  the reader to find one.
- **Name a function, a variable or a constant, and cite `file:line`** — every time, including
  the second mention. A reviewer opening the file is the point.
- **A number beats an adjective.** "142 ms at p99, of which 120 ms is the serialization" is a
  finding; "slow" is an opinion. Say where the number came from, and whether it is measured
  or derived.
- **"We", not "you".** "We should cover this with a test", not "you should" — in writing
  there is no tone of voice to soften the second one.
- **A bug is a statement, an open decision is a question, and an unverified claim says so.**
  Do not turn a finding you are sure of into a rhetorical question: the reader has to be able
  to tell what is fact.
- **Rank, never truncate.** Order by severity and say what the ordering means. Findings are
  content, not formatting — report every one you found.

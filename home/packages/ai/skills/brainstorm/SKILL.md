---
name: brainstorm
description: Run a design brainstorm across several models in rounds - independent proposals, cross-critique, convergence - and stop when a round brings nothing new. Use when asked to brainstorm a design or a decision with other models or agents, "ask Gemini, GPT and Kimi what they think", "get a few models to argue it out", "brainstorm this with". The user names the models each time.
disable-model-invocation: false
---

# Brainstorm

Several models, the same question, three rounds. You run it and write the synthesis; you do not enter a proposal of your own, since whoever writes the synthesis pulls it toward their own design.

## Before the first round

- **The participants come from the user.** Use the models they name, each run the way the user's instructions say to run it. If they name none, ask. Run every headless CLI with `< /dev/null`.
- **Write one brief**, the same for everyone, in a file. It holds the problem in plain words, what exists today, the figures measured (say where each comes from), the hard constraints, and the questions to answer. Leave your own preferred answer out of it.
- **Verify the brief's facts first.** A wrong number in the brief becomes the base of every proposal.
- **Say what a participant may read.** A model with read access to the repository grounds its answer in the code; tell it to edit nothing and name the files worth reading.
- **Send nothing private** to an outside model: no names, keys, addresses or account details in the brief.

Keep every brief and answer in a scratch directory, one file each, named by round and participant.

## Round 1: independent proposals

Send the brief to every participant at once, in parallel. Nobody sees another's answer. A model that reads a proposal before thinking improves it instead of looking for another one, and the point of this round is to get different designs.

When the answers are in, check every claim about the user's code, system or data that the next round would build on. Mark the ones that are wrong.

## Round 2: cross-critique

Each participant gets every proposal, its own included, labelled A, B, C with no model names, so that none is believed for its reputation. Add your list of claims found wrong. Ask each for three things:

- what is wrong or does not hold in each proposal, its own too;
- what it would take from the others;
- how its own proposal changes.

Continue the same session of each participant where the tool allows it, so that it remembers its reasoning.

## Round 3: convergence

Write the synthesis yourself:

- the points every participant agrees on;
- each point where they differ, with the positions held and who holds them (still by letter);
- the claims you verified and the ones you could not.

Send it to everyone with one question per open point: which do you choose, and which measurement would decide it. The result is one design and a short list of points to settle by experiment.

## When to stop

Stop when a round brings no new idea and no new objection, only rewording. That is usually round 3. Run a round 4 only on a disagreement that changes what gets built, and only on that point.

Past that, the models start agreeing with each other and the variety of round 1 is gone. A disagreement left after round 3 is not settled by more talk: propose to build the variants and measure them.

## What the user gets

Between rounds, one line: which round ended and whether anything needs them. At the end:

- the design the rounds converged on, in plain words;
- what each participant added that the others lacked;
- the open points, each with the experiment that settles it;
- what you verified, what you could not, and what the participants only estimated;
- your own recommendation, said as yours;
- where the full answers are.

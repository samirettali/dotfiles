---
name: design
description: Design, build, refine, and review interfaces across web and native apps. Use for UI/UX work on screens, components, forms, navigation, reading experiences, and public sites; for accessibility, typography, color, layout, motion, and interface copy. Keeps visual style in each project's DESIGN.md rather than imposing a shared aesthetic.
---

# Design

Help someone complete a task, understand content, or make a decision. Visual
choices serve that purpose; novelty is not a requirement.

This skill owns the process and UX checks. The project's `DESIGN.md` owns its
visual identity and chosen interaction conventions. There is no default palette,
font pairing, radius, page template, animation curve, or preferred framework.

## Establish the boundary

Before changing an interface:

1. Read the project's instructions and `DESIGN.md`. Inspect
   nearby components, tokens, copy, and the rendered surface when available.
2. Identify the person, their immediate goal, and the requested surface. A
   booking panel serves a task; a lyrics page serves reading; a public site
   helps someone decide. One product can need all three.
3. Separate a new design, a refinement, and a review. Missing design documentation
   does not make an existing interface a blank canvas.

Ask one focused question when missing context would materially change the work.
Do not re-ask information the brief or project already supplies. For a small
component change, inspect its surroundings instead of reopening the whole brand.

**Refinement preserves the system.** Reuse its components, vocabulary, navigation,
and supported platforms. A redesign does not authorize deleting routes, changing
business behavior, rewriting factual copy, or replacing the technology stack.

**Review is read-only unless implementation was also requested.** State the scope
and inspect it before judging. A request to fix one component does not authorize
an audit or rewrite of every other component.

## Read the relevant references

Resolve these paths relative to this skill, not the project:

| Work | Read |
| --- | --- |
| Flows, controls, states, navigation, forms, or interface copy | [UX](references/ux.md) |
| Keyboard, assistive technology, contrast, targets, or text resizing | [Accessibility](references/accessibility.md) |
| Visual direction, typography, color, layout, responsiveness, or motion | [Visual decisions](references/visual.md) |
| Reviewing or verifying an implementation | [Verification](references/verification.md) |

A new screen or whole-flow review needs all four. A focused change needs only
its relevant references and verification. Do not load unrelated material or
require another design skill. If a reference cannot be read, name the gap rather
than claiming its checks passed.

## Decide the experience before its appearance

Sketch the shortest complete path through the task. Include the states and exits
that can actually occur, not eight invented states for every component.

- Show what matters through order, grouping, and emphasis before adding badges
  or explanatory chrome. Keep secondary content readable.
- Preserve recognizable controls and platform behavior. Familiarity helps a
  person who uses the same screen all day.
- Keep the user's context through loading, validation, and navigation. Feedback
  should not erase the control, move the target, or discard their work.

For a consequential flow, show a compact sketch of the proposed behavior before
building. For a routine edit, use the established pattern without ceremony.

## Choose style per project

**Existing system:** apply its decisions, including choices this skill's sources
would dislike. Serif dashboards, pure white, square buttons, and unbordered links
can all be deliberate. Check their usability rather than their fashion.

**New system:** derive a direction from the subject, audience, content, and any
references the user supplies. Propose the composition and a small set of tokens.
Use real copy and representative data. Confirm unresolved project-wide choices
before spreading them across screens. Offer materially different visual examples
when words cannot settle the choice; do not build multiple variants unasked.

Record an agreed new system in the project's `DESIGN.md`. Capture roles,
component behavior, values, and the reason for exceptions. Link to the code that
owns the tokens instead of keeping several independent copies of their values. Do not create logs, branded stamps,
theme catalogs, or extra token exports as a side effect.

**A locked system can still contain a defect.** If contrast fails or a control
cannot be used, report the evidence and propose a system-level correction. Do not
silently change the palette or call a documented exception compliant. Ask before
changing a locked decision. After adding a shared rule, ask whether to inspect
existing uses; do not turn that question into an unsolicited migration.

## Build and verify

Prefer, in order: what the platform provides, what the project already provides,
and an established accessible primitive when both fall short. Own custom
behavior only when the task requires it. Stay in the project's stack.

Make the smallest coherent change. Verify the rendered result and the relevant
interactions using [Verification](references/verification.md). Fix observed
defects together, then check the affected states again. Stop when the scoped work
passes; do not spend repeated passes searching for a different aesthetic.

Report what changed, what you checked, and any remaining limitation. Separate
measured failures from optional suggestions. Never claim a visual review from
source alone, or accessibility compliance from an automated audit alone.

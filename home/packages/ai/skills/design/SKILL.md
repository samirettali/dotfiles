---
name: design
description: Design, build, refine, and review interfaces across web and native apps. Use for UI/UX work on screens, components, forms, navigation, reading experiences, and public sites; for accessibility, typography, color, layout, motion, and interface copy. Keeps visual style in each project's DESIGN.md rather than imposing a shared aesthetic.
---

# Design

Help someone complete a task, understand content, or make a decision. Visual
choices serve that purpose; novelty is not a requirement.

This skill owns the process and UX checks. The project's `DESIGN.md` owns its
visual identity and interaction conventions. There is no default palette, font
pairing, radius, page template, animation curve, or preferred framework.

## Establish the boundary

1. Read the project's instructions and `DESIGN.md`. Inspect nearby components,
   tokens, copy, and the rendered surface when available.
2. Identify the person, their immediate goal, and the requested surface: a task,
   reading, or a decision. One product can need all three.
3. Separate a new design, a refinement, and a review. Missing design
   documentation does not make an existing interface a blank canvas.

Ask one focused question when missing context would materially change the work.
For a small component change, inspect its surroundings instead of reopening the
whole brand.

- **Refinement preserves the system**: its components, vocabulary, navigation,
  and supported platforms. A redesign does not authorize deleting routes,
  changing business behavior, rewriting factual copy, or replacing the stack.
- **Review is read-only** unless implementation was also requested. A request
  to fix one component does not authorize an audit of every other component.

## Read the relevant references

Resolve these paths relative to this skill, not the project:

| Work | Read |
| --- | --- |
| Flows, controls, states, navigation, forms, or interface copy | [UX](references/ux.md) |
| Keyboard, assistive technology, contrast, targets, or text resizing | [Accessibility](references/accessibility.md) |
| Visual direction, typography, color, layout, responsiveness, or motion | [Visual decisions](references/visual.md) |
| Reviewing or verifying an implementation | [Verification](references/verification.md) |

A new screen or whole-flow review needs all four. A focused change needs only
its relevant references and verification. If a reference cannot be read, name
the gap rather than claiming its checks passed.

## Decide the experience before its appearance

Sketch the shortest complete path through the task, with the states and exits
that can actually occur. Show what matters through order, grouping, and emphasis
before adding badges or chrome. Preserve recognizable controls and platform
behavior. Feedback must not erase the control, move the target, or discard the
user's work.

For a consequential flow, show a compact sketch before building. For a routine
edit, use the established pattern without ceremony.

## Choose style per project

- **Existing system**: apply its decisions, including choices this skill's
  sources would dislike. Check their usability, not their fashion.
- **New system**: derive a direction from the subject, audience, content, and
  supplied references. Propose the composition and a small set of tokens with
  real copy and representative data. Confirm project-wide choices before
  spreading them across screens. Offer materially different examples only when
  words cannot settle the choice; do not build variants unasked.
- Record an agreed new system in `DESIGN.md`: roles, component behavior,
  values, and the reason for exceptions. Link to the code that owns the tokens.
  No logs, branded stamps, theme catalogs, or token exports as a side effect.
- **A locked system can still contain a defect.** Report the evidence and
  propose a system-level correction; do not silently change the palette or call
  a documented exception compliant. Ask before changing a locked decision, and
  ask before migrating existing uses of a new shared rule.

## Build and verify

Prefer, in order: what the platform provides, what the project provides, an
established accessible primitive. Own custom behavior only when the task
requires it. Stay in the project's stack.

Make the smallest coherent change. Verify the rendered result and the relevant
interactions per [Verification](references/verification.md). Fix observed
defects together, then check the affected states again. Stop when the scoped
work passes.

Report what changed, what you checked, and any remaining limitation, separating
measured failures from suggestions. Never claim a visual review from source
alone, or accessibility compliance from an automated audit alone.

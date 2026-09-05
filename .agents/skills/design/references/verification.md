# Verification

Inspect what the user will encounter, not just the intended styles. Bound the
work to the requested screen, component, flow, or change.

## Choose evidence before judgment

Read the project's preview and test commands. Use existing services only as
permitted by the project; do not stop or replace a process you did not start.
Do not send notifications, spend money, publish, or delete real data to test UI
without explicit authorization. Use fixtures or an isolated environment.

For a review of changes, establish the base and affected surfaces first. Separate
introduced defects, regressions, and pre-existing problems. Follow shared
components to their confirmed uses; do not infer a repository-wide failure from
one screenshot.

A source inspection can establish a missing label or an inconsistent token use.
Wrapping, computed contrast, clipping, hit areas, focus behavior, and animation
need rendered evidence. Mark claims you cannot check as not verified.

## Walk one complete path

For the scoped flow, inspect applicable scenarios:

- The ordinary path, from entry through a real result and a meaningful exit.
- Empty, loading, refresh, failure, retry, and partial-result states that exist.
- Keyboard operation, visible focus, accessible names, and focus after transitions.
- Long content and realistic data, not just a short demonstration label.
- The supported narrow and wide layouts; for web reflow, include 320 CSS pixels.
- Text resizing, supported themes, reduced motion, and relevant input devices.
- Reload, Back, deep links, scrolling, and unsaved work where those affect the task.

For native apps, use supported window sizes, text scaling, platform accessibility
inspection, and expected keyboard or touch behavior. Do not translate every web
check into a CSS requirement on native controls.

Not every component has every state. Record what applies rather than inventing
loading, error, and success variants for a static label.

## Inspect efficiently

Run the project's relevant build, typecheck, and tests. Batch visual inspections
at representative sizes and states. Check typography, alignment, imagery, and
contrast in the same render rather than taking separate screenshot trips.

Fix observed defects together. Recheck the changed interactions and any shared
component they could affect. Do not repeat an open-ended beautification loop.
When a blocker remains, report it rather than claiming completion because the
inspection budget ended.

Measure the claim that would otherwise be a guess. Examples: computed contrast
on the actual surface, a control's target rectangle, overflow at a narrow width,
or input-to-feedback latency. State the environment and result. Keep diagnosis
separate from an unverified theory about the cause.

Automated accessibility tools and performance scores complement this walk. They
cannot establish comprehension, keyboard completeness, or overall usability.
Never invent a self-score or a checklist pass before inspecting the result.

## Report the smallest useful set of findings

Rank by consequence:

- **Blocking:** an inaccessible action, lost work, misleading outcome, unreadable
  required content, or a broken primary flow. Name the concrete failure.
- **Non-blocking issue:** a verified inconsistency or friction that does not prevent
  completion. Explain the user impact.
- **Suggestion:** a plausible improvement without evidence of a defect. Do not
  use a preference for a different style as grounds to block.

Use Conventional Comments for review findings, for example:

> **issue (blocking): The retry clears the booking details.**
> `BookingForm.tsx:84`: a failed save resets the customer and time fields.
> Preserve those values so correcting the error does not require re-entry.

This example ties one observed failure to a location, consequence, and fix.

Report one finding per cause, with confirmed affected locations together. A
shared token failure belongs at the token, not in twenty duplicate comments.
Keep pre-existing findings separate from the verdict on a change.

For a locked design decision, show the failing behavior or measurement and propose
an amendment. Do not call it acceptable merely because the document records it.
Ask before applying a system change or expanding a local fix into a migration.

Prefer removing unnecessary behavior, using the platform, or reusing an existing
component before adding another abstraction. Suggest the cheapest coherent fix.

End with scope, checks performed, and gaps. Say "No findings in the inspected
scope" when appropriate. Do not say "fully accessible" or approve surfaces and
states you did not inspect. For implementation work, keep the handoff to the
actual changes, verification results, and remaining limitations.

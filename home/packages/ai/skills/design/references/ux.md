# UX

## Lead with the user's job

Identify what the person came to do and what information makes that possible.
Remove questions the interface can answer without asking them. Do not automate
an action that spends money, publishes, or contacts someone without consent.

Group information by the decision it supports. A calendar can lead with the next
action requiring attention; a reading page can lead with something worth reading.
Neither needs a universal hero, metric strip, or card grid.

Distinguish primary content, supporting context, and optional detail. Use order,
space, and scale before adding markers. Reducing emphasis must not reduce text
below its contrast requirement.

Do not make users repeatedly choose options they rarely change. Put secondary
choices behind a discoverable control with a useful current value. Never hide a
required field, active filter, or critical consequence to make the page quieter.

## Make actions recognizable

Use the project's established affordances. A border is one option, not the rule:
a conventional text link can be clearer than a decorative button.

Keep actions, navigation, selection, hover, and status distinguishable. A status
badge should not imply clickability; hovering must not look like committing a
selection. A selected state needs more than a transient hover treatment.

Use controls for their established jobs:

- Links navigate. On the web, preserve opening in a new tab and copying the URL.
- Buttons perform actions. Name the action and its object when context is unclear.
- Switches usually apply an on/off setting immediately. Checkboxes usually select
  items or options for a later action. Follow an existing convention if the
  application makes its save behavior clear.
- Tabs change the visible panel. Filters change the result set. Do not disguise
  one as the other or mix view settings with filters without a clear grouping.

One visual priority per decision group is usually enough. Several independent
tasks can have their own primary actions; a screen-wide quota would be arbitrary.

Use a whole row as a target only when its action is clear. Do not nest buttons
inside links or intercept text selection to fake a clickable row. Preserve
independent actions and their keyboard paths.

## Preserve context between states

Model the states the data and action actually have:

| Situation | What the interface must communicate |
| --- | --- |
| First load | What is loading, without pretending that absence is confirmed |
| Refresh | Existing content remains useful, with an update indicator if needed |
| Empty collection | Why it is empty and an applicable next action |
| No matches | The query or filters in force and a way to change them |
| Pending action | What started, whether the user can leave, and how to find it again |
| Partial failure | What succeeded, what failed, and what remains actionable |
| Recoverable failure | A useful retry or correction that preserves previous work |
| Unavailable or permanent failure | A truthful limit or alternative, not a retry that cannot work |

Keep stable keys and control identity when the action stays the same. Preserve
focus, selection, scroll position, and entered values where the interaction
requires them. If a control must disappear, move focus to a meaningful successor.

For example, Sottotesto keeps the request action in one place while its label
changes from requesting a reading to waiting or retrying. That is continuity,
not a rule that every screen must keep every element mounted forever.

Reserve space where predictable content changes would otherwise move a target.
Use a fitting minimum size rather than a fixed height that clips longer text.
Never keep stale results under a new query without distinguishing them.

## Match feedback to the work

A visible state change can be its own success message. Add confirmation when the
result would otherwise be unclear, off-screen, or consequential. An assistive
announcement can be necessary even when another visible message is redundant.

Keep one message per event. Do not repeat the button's label in a sentence next
to it. Merge errors with one shared cause when that clarifies recovery; keep
independent failures distinguishable.

Acknowledge input immediately. Prevent duplicate submissions while a request is
pending without making the focused control vanish. Do not claim success before
the system confirms a non-optimistic operation.

Choose loading feedback for the observed wait. Do not invent percentages or
countdowns. For long jobs, provide a durable status and a way to return to it.
Never imply that navigating away cancels server work unless it really does.

Do not delay a fast result to show an animation. Delay a distracting spinner
only if brief requests would otherwise make it flash; preserve immediate input
feedback. Keep waiting text steady rather than pulsing the words someone reads.

## Make forms explain themselves

Ask only for information the task needs. Show required fields, units, accepted
formats, and consequential defaults before submission. Preserve entered values
on failure and when moving between steps.

Use visible labels, appropriate input types, autocomplete, and the right virtual
keyboard. Allow paste and password managers. Do not impose name, address, or
phone formats more restrictive than the real domain requires.

Validate at a useful moment. Show format hints before input; avoid announcing
an error on each keystroke while a value is incomplete. Check cross-field and
server constraints at submission even when the client also validates.

An enabled submit can reveal validation problems. A disabled submit is acceptable
when the missing requirements remain discoverable without activating it. Never
leave a person guessing why they cannot continue.

Place field errors next to their fields and connect them programmatically. For
long forms, an error summary can link to each problem. On failure, direct focus
to the summary or first invalid field as appropriate; do not clear valid fields.

Distinguish not saved, saving, and saved when that distinction affects decisions.
A switch inside an explicitly saved form must not imply immediate persistence.

## Protect consequential actions

Match friction to the consequence and the chance of a slip:

- Reversible local edits can apply immediately, with undo where useful.
- Irreversible changes need an explicit consequence and deliberate confirmation.
- External effects need special care: undoing a booking does not unsend the
  customer's notification. Confirm before that effect, not after it.

Name the affected item, scope, and consequence. A confirmation's action should
say what it does, not merely "Yes". Use a safe initial focus when an accidental
activation would cause harm.

Preserve unsaved work or ask before discarding it. Do not add routine
confirmations for actions that cannot lose anything.

Use optimistic updates only when rollback is credible. Show rejection and
restore the prior state on failure. Payments, publication, and scarce booking
slots must not silently look final while confirmation remains pending.

## Keep navigation and overlays predictable

Maintain location, selected navigation, and a meaningful Back path. Use URLs for
shareable screens and useful filters where the application supports deep links.
Reload, Back, Forward, and returning from a detail should preserve useful context.
Do not add half-typed queries to history unless live search is the agreed behavior.

Choose an inline region, a separate page, or an overlay for the actual task and
the project's established pattern. A modal is not automatically wrong, nor the
default container for every form.

Avoid stacking task dialogs. A sub-flow can become a step inside the existing
surface, with a visible way back. Distinguish Back, Cancel, and Close. Escape,
close controls, and outside clicks must respect unsaved-work protection.

Make scrollable and collapsed content discoverable. Use a next-item preview,
scrollbar, or clear disclosure control. Never hide navigation beyond an edge
with no cue.

## Write for the person using the product

Use the product's language consistently from action to outcome: "Publish" leads
to "Published", not "Uploaded". Keep the established voice and locale; use calm,
precise language for errors, consent, and destructive actions.

A label must describe the actual action. An error must say what failed and what
the person can do, without blaming them or guessing a cause. Keep provider
payloads, stack traces, internal hostnames, and secrets out of user-facing copy.
A safe support reference can connect the message to diagnostic logs.

Omit an empty optional content section when its absence is unsurprising. Explain
absence when someone expects content or needs a next step. An empty References
section in a reading and a failed search do not need the same treatment.

Do not invent metrics, testimonials, customer logos, progress, or activity.
Mark demonstration data as illustrative. Keep developer diagnostics out of the
product unless they support a decision its audience can actually make.

Localize whole messages with plural rules rather than concatenating fragments.
Format dates, numbers, currencies, and time zones for the person making the
decision. Ambiguous booking times and money values are functional defects.

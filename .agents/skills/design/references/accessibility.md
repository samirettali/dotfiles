# Accessibility

Use the platform's semantic controls before recreating their behavior. On the
web, follow WCAG 2.2 AA and the relevant ARIA Authoring Practices patterns.
For native apps, use the platform's accessibility APIs and interaction guidance;
CSS pixels and ARIA attributes are not native implementation instructions.

A design document may record a known failure, but cannot waive a standard into
compliance. Report the failure and respect the user's scope for changing it.

## Semantics and names

Use real buttons for actions, links for navigation, and form controls for input.
Reuse accessible primitives for composite controls the platform does not supply.
A custom visual treatment does not justify losing native behavior.

Give every control an accessible name. Keep the visible label in that name.
Label inputs visibly; placeholders disappear and cannot replace labels. Group
related inputs with a fieldset and legend or their toolkit equivalent.

Expose role, value, and state, including selected, expanded, invalid, and busy
where relevant. Avoid redundant or misleading ARIA. Do not put focusable content
inside an `aria-hidden` subtree.

Choose image alternatives by purpose. Decorative images get an empty alternative;
informative images convey meaning; a functional image names its action. Provide
text equivalents for meaningful charts and captions for relevant audio/video.

Use a coherent heading outline and landmarks. Choose heading levels by structure,
not desired font size. Provide a way to skip repeated navigation. Keep visual
order, reading order, and focus order coherent.

## Keyboard and focus

Complete every pointer task through the keyboard. Add a simple non-drag path for
dragging operations. Native platforms should retain their expected shortcuts.

On the web, Tab moves between controls; composite widgets follow their APG
pattern for arrows, activation, and Escape. Do not apply one widget's keyboard
behavior to every control. Avoid positive `tabindex` values.

Keep focus visible and unobscured. Do not remove the browser's indicator without
a verified replacement. A custom indicator must remain legible on every surface
and in forced-colors mode. Do not animate away its initial visibility.

Modal dialogs need an accessible name, an appropriate initial focus, contained
keyboard focus, and an inactive background. Restore focus to the trigger or a
logical successor on close. Nonmodal popovers must not trap focus like dialogs.
Use the platform or an established primitive for these contracts.

A disabled control still needs a discoverable explanation when its availability
is unclear. `aria-disabled` does not stop events; code must prevent activation
if using it instead of native `disabled`. Never rely on a hover-only tooltip to
explain a disabled action.

## Contrast and non-color cues

Measure the actual rendered foreground and background, including transparency,
ancestor opacity, state layers, and images. A token's hex value alone does not
prove the rendered pair passes. Test each supported theme.

WCAG 2.2 reference thresholds:

| Content | Requirement |
| --- | --- |
| Normal text, including meaningful placeholder text | At least 4.5:1 |
| Large text: 18pt regular or 14pt bold, approximately 24px or 18.67px | At least 3:1 |
| Visual information needed to identify controls and their states | At least 3:1 against adjacent colors |

Check the criterion's applicability and exceptions before reporting. Decorative
separators are not control boundaries. Inactive controls have contrast exceptions,
but the information explaining their state still needs to be readable.

A ring on the page outside a button has a different adjacent color from a ring
inside its fill. Measure what actually touches the indicator.

Use text, shape, an icon, or another persistent cue alongside semantic color.
Do not convey failure, selection, or a chart's meaning through hue alone.
Never estimate contrast by eye or call a token compliant because its name says so.

## Target size, resizing, and reachability

WCAG 2.2 AA target size is 24×24 CSS pixels or its defined spacing and other
exceptions. A 44×44 target is a useful touch target and the AAA size, not the
universal AA minimum. Follow native platform target guidance on native apps.

Evaluate the actual target, not just its visible glyph. Expanding a small icon's
hit area is useful only when it does not overlap another target or block content.
Inline prose links and equivalent controls require different treatment from
standalone toolbar actions.

On the web, test text resizing to 200% and reflow at 320 CSS pixels. Do not cap
zoom. Check enlarged text and display settings on native platforms. Two-dimensional
content such as a data table may need its own scrolling region; the whole page
should not require sideways scrolling to reach ordinary controls.

Respect user text spacing without losing content: line-height 1.5 times font
size, paragraph spacing 2 times, letter spacing 0.12 times, word spacing 0.16 times.
These are override tests, not a required default visual style.

Keep essential controls reachable around sticky chrome, display cutouts, and the
on-screen keyboard. Do not hide clipping with global overflow rules. Keep
truncated content available through a keyboard- and touch-accessible path.

## Motion and announcements

Honor reduced-motion preferences. Remove nonessential spatial and continuous
motion; keep the resulting state understandable without an animation. A
crossfade is an option, not a required replacement for an instant change.

Provide pause, stop, or hide controls for applicable automatically moving or
updating content. Avoid flashing effects. Do not make an action depend only on
a gesture, animation, sound, or hover.

Connect validation errors to their fields. Announce asynchronous status without
stealing focus. Use a polite live region for routine updates and an assertive
alert only when interruption is justified. Keep repeated status regions stable.

Do not announce every progress tick or every typed character. A success visible
in place may still need an announcement for someone who cannot see that change.

Tooltips must work beyond hover when they carry useful information. Hover/focus
content should remain available while inspected and be dismissible where required.
Essential instructions belong in persistent text, not a tooltip.

## Verify with the appropriate tools

Inspect names, roles, and states in the accessibility tree. Walk the complete
keyboard path. Use the target screen reader for announcement and focus behavior
when available. An accessibility-tree inspection is not a screen-reader test.

Automated checks find some defects, not all of them. State which platform,
browser, assistive technology, and scenarios you actually checked. Mark unavailable
tests as not verified rather than issuing a blanket compliance claim.

Primary references: [WCAG 2.2](https://www.w3.org/TR/WCAG22/),
[ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/),
[Apple accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility),
[Android accessibility](https://developer.android.com/guide/topics/ui/accessibility).

---
name: live-ui-variants
disable-model-invocation: true
description: Build a temporary development-only variant switcher that lets users compare multiple UI or UX alternatives live in the same app. Use when a user wants to see several design options before choosing one, compare layouts or interactions, or experiment without repeatedly rewriting the implementation. Works for web frontends and native macOS (SwiftUI) apps.
---

# Live UI Variants

Compare alternatives for one focused UI decision inside the real application,
using a small floating development control:

```text
VARIANT  1  2  3  4
```

Switching updates the UI immediately while preserving application data and state.
The switcher is temporary: never expose it in production, and remove it once the
user chooses a final design.

## Platform reference

Load only the relevant implementation reference, relative to this skill:

- [Web](references/web.md): development guards, storage, markup, and responsive checks.
- [SwiftUI](references/swiftui.md): debug guards, AppStorage, control example, and window checks.

Other frameworks use equivalent compile-time development guards and persistence.

## Comparison contract

Inspect the existing component, styles, responsive behavior, design tokens, and
state flow. Compare the smallest design decision, not unrelated parts of the page.
Keep the current implementation as a baseline unless explicitly rejected, and
create two or three materially different options rather than cosmetic color swaps.
A useful set is the baseline, recommended redesign, restrained alternative, and
more functional or native-control alternative.

All variants reuse the same API data, mutations, event handlers, selected records,
loading/error states, and business rules. Branch only the presentation or
interaction under evaluation, not backend calls or domain logic. Prefer small
compositions or modifiers over copying whole pages or windows.

Persist the selection with a project-and-feature-scoped development key, validating
restored values against the known variants. The floating control must be compact,
visually distinct from the product, above the compared UI, and clear of primary
actions. Use numbered buttons, descriptive tooltips and accessible names, a clear
active state, keyboard access, and visible focus. An accent/warning border can
separate the control from product UI.

Stay inside the existing visual language: reuse typography, color tokens,
spacing, borders, focus styles, and motion conventions. Compare a design decision,
not unrelated design systems. Honor reduced motion and do not add animation merely
to distinguish options.

## Validation

Run the project checks relevant to the changed code. Before presenting the
experiment, establish its specific acceptance criteria:

- The production/release configuration compiles without the development code
  and does not expose the switcher. Build release once; `#if DEBUG` excludes
  the switcher by construction but does not prove the remaining code compiles.
  Where practical, allow dead-code elimination to remove experiment code entirely.
- Every variant works at the relevant sizes, using the same live state. Check
  for clipping, overflow, accidental layout jumps, inaccessible or covered
  controls, and stale local state; platform references cover platform-only checks.
- The selected variant survives refresh/restart.

Tell the user what each number represents and which option is recommended, but
let them evaluate the variants directly.

## Finalization

After the user chooses, keep only the selected implementation. Remove rejected
branches, the floating switcher, experiment-specific state, storage keys, types,
and styles. Remove stale stored values when useful; platform references give the
commands. Run checks relevant to the cleanup and verify the release implementation
no longer depends on experiment code. Commit only when requested.

Do not leave temporary variant infrastructure in the final production implementation
unless the user explicitly asks for a permanent feature flag or A/B testing system.

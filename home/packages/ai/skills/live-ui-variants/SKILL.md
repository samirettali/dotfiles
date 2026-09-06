---
name: live-ui-variants
disable-model-invocation: true
description: Build a temporary development-only variant switcher that lets users compare multiple UI or UX alternatives live in the same app. Use when a user wants to see several design options before choosing one, compare layouts or interactions, or experiment without repeatedly rewriting the implementation. Works for web frontends and native macOS (SwiftUI) apps.
---

# Live UI Variants

Use this workflow when a design decision is easier to evaluate by seeing alternatives in the real application instead of discussing static descriptions.

## Goal

Implement several materially different versions of one focused UI decision and expose them through a small floating development control:

```text
VARIANT  1  2  3  4
```

Switching variants must update the UI immediately while preserving the same application data and state.

The switcher is temporary experimentation infrastructure. It must not appear in production and must be removed after the user chooses a final design.

## Before implementation

1. Inspect the existing component, styles, responsive behavior, design tokens, and state flow.
2. Identify the smallest design decision being compared. Do not create variants for unrelated parts of the page at the same time.
3. Keep the current implementation as one baseline variant unless the user explicitly rejects it.
4. Create two or three additional options with meaningful differences, not superficial color changes.
5. Name each option clearly for tooltips and accessibility, even if the visible controls only show numbers.

A good set often contains:

1. current baseline;
2. recommended redesign;
3. restrained alternative;
4. more functional or native-control alternative.

## Implementation rules

### Share behavior and data

Variants must reuse:

- the same API data;
- the same mutations and event handlers;
- the same selected records;
- the same loading and error states;
- the same business rules.

Only branch the presentation or interaction being evaluated. Do not duplicate backend calls or domain logic.

Prefer:

- conditional presentation in one component/view;
- CSS modifier classes or SwiftUI view composition;
- `data-variant` attributes;
- small variant-specific subcomponents/subviews.

Avoid copying an entire page or window once per variant.

### Development only

Use the platform's compile-time development guard so the switcher cannot ship:

- **Vite:** `if (!import.meta.env.DEV) return null;`
- **SwiftUI / SwiftPM:** `#if DEBUG` (debug builds define it; build the experiment with the debug configuration, e.g. `make bundle CONFIG=debug`).
- Other frameworks: their equivalent development-only mechanism.

The production/release build must not render the switcher. When practical, structure the code so dead-code elimination can remove it entirely.

Never expose internal experiment controls to customers.

### Persistence

Persist the selection so restarts/refreshes do not reset the comparison:

- **Web:** `localStorage`, e.g. `localStorage.setItem("project_feature_variant", selectedVariant)`.
- **SwiftUI:** `@AppStorage`/`UserDefaults` with a clearly dev-scoped key, e.g. `"dev.settingsLayoutVariant"`.

Namespace the key by project and feature. Validate restored values against the known variant list before using them.

### Floating switcher

The switcher should:

- float above the UI being compared (web: `position: fixed` near a viewport corner; SwiftUI: `.overlay(alignment: .bottomTrailing)` on the window's root view);
- have a high enough z-order to remain visible;
- be compact and visually distinct from the product UI (an accent/warning-colored border works well);
- avoid covering primary actions;
- show numbered buttons for fast comparison;
- expose descriptive tooltips (`title` / `.help(_:)`);
- mark the active option clearly;
- be keyboard accessible with visible focus states.

Web markup sketch:

```tsx
<aside aria-label="Design variants">
  <span>Feature</span>
  <button
    type="button"
    aria-label="Variant 2: Compact date navigator"
    aria-pressed={selectedVariant === "compact"}
    title="2. Compact date navigator"
  >
    2
  </button>
</aside>
```

SwiftUI sketch:

```swift
enum LayoutVariant: String, CaseIterable {
    case current, tabs, sidebar
    var label: String { ... }
}

struct VariantSwitcher: View {
    @Binding var selectionRaw: String

    var body: some View {
        #if DEBUG
        HStack(spacing: 5) {
            Text("LAYOUT").font(.system(size: 9, weight: .bold)).foregroundStyle(.secondary)
            ForEach(Array(LayoutVariant.allCases.enumerated()), id: \.element) { index, variant in
                Button { selectionRaw = variant.rawValue } label: {
                    Text("\(index + 1)")
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(variant.rawValue == selectionRaw
                            ? AnyShapeStyle(Color.accentColor)
                            : AnyShapeStyle(Color(nsColor: .quaternarySystemFill))))
                }
                .buttonStyle(.plain)
                .help("\(index + 1). \(variant.label)")
                .accessibilityAddTraits(variant.rawValue == selectionRaw ? .isSelected : [])
            }
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(.thinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(.orange.opacity(0.55), lineWidth: 1))
        .padding(12)
        #else
        EmptyView()
        #endif
    }
}
```

The host view switches on the validated stored value and renders one of the variant compositions; all variants read the same observable state.

### Responsive / window comparison

Every variant must be usable at the relevant sizes (web: desktop and mobile breakpoints; macOS: the window sizes each variant implies — variants may legitimately need different window frames, e.g. a sidebar layout wider than a tabbed one).

Check that switching variants does not introduce:

- overflow or clipped content;
- content jumps caused by accidental fixed dimensions;
- inaccessible targets;
- controls hidden behind the switcher;
- duplicated element IDs (web);
- stale local component/view state.

### Visual discipline

Variants should remain inside the existing visual language. Reuse the project's typography, color tokens, spacing scale, borders, focus styles, and motion conventions. On macOS prefer native controls and standard `Form`/`TabView`/`NavigationSplitView` compositions over custom chrome.

The purpose is to compare a design decision, not to compare unrelated design systems.

Honor `prefers-reduced-motion` / reduced-motion settings and avoid adding animation merely to distinguish variants.

## Validation

Run the project checks relevant to the changed code. Before presenting the
experiment, establish its specific acceptance criteria:

- The production/release configuration compiles without the development code
  and does not expose the switcher. Build release once; `#if DEBUG` excludes
  the switcher by construction but does not prove the remaining code compiles.
- Every variant works at the relevant sizes, using the same live state.
- The selected variant survives refresh/restart.

Tell the user what each number represents and which option is recommended, but let them evaluate the variants directly.

## Finalization

After the user chooses a variant:

1. keep only the selected implementation;
2. remove all rejected branches;
3. remove the floating switcher;
4. remove experiment-specific state, storage keys, types, and styles;
5. remove stale stored values when useful (web: `localStorage.removeItem`; macOS: `defaults delete <bundle-id> <key>`);
6. run checks relevant to the cleanup and verify the release implementation no longer depends on experiment code;
7. commit only when requested.

Do not leave temporary variant infrastructure in the final production implementation unless the user explicitly asks for a permanent feature flag or A/B testing system.

# SwiftUI variant switcher

Branch presentation with view composition or small variant-specific subviews.
Avoid copying an entire window per variant; all variants reuse the same
observable state, handlers, and business rules.

Prefer native controls and standard `Form`/`TabView`/`NavigationSplitView`
compositions over custom chrome.

## Development guard and persistence

Use `#if DEBUG` so the switcher cannot ship in a release build. SwiftPM debug
builds define it; build the experiment with the debug configuration, for example
`make bundle CONFIG=debug`.

Persist selection in `@AppStorage`/`UserDefaults` with a project-and-feature-scoped
development key such as `"dev.settingsLayoutVariant"`. Validate restored values
against the known variant list before rendering a composition.

## Floating control

Use `.overlay(alignment: .bottomTrailing)` on the window's root view. Keep the
control visible without covering primary actions, with numbered buttons,
descriptive `.help(_:)` tooltips, keyboard access, and a clear active state.

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

The host view switches on the validated stored value and renders one of the
variant compositions. Test the window sizes each implies: variants may
legitimately use different frames, such as a sidebar wider than a tabbed layout.
Check overflow, clipping, accidental fixed-dimension jumps, inaccessible targets,
controls behind the switcher, and stale view state. Honor reduced-motion settings.

When finalizing, remove stale stored values when useful with
`defaults delete <bundle-id> <key>`.

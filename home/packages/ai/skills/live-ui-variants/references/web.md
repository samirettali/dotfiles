# Web variant switcher

Branch presentation with conditional components, CSS modifier classes,
`data-variant` attributes, or small variant-specific subcomponents. Avoid copying
an entire page per variant; all variants reuse the same data, handlers, and state.

## Development guard

Use the framework's compile-time development guard so the switcher cannot ship.
For Vite:

```tsx
if (!import.meta.env.DEV) return null;
```

The production build must not render the switcher. Where practical, structure
experiment code so dead-code elimination removes it entirely.

## Persistence and controls

Persist selection in `localStorage`, using a project-and-feature-scoped key:

```ts
localStorage.setItem("project_feature_variant", selectedVariant);
```

Validate restored values against the known variant list before using them.
Use `position: fixed` near a viewport corner, with sufficient z-order and
without covering primary actions. Number the buttons, give them descriptive
`title` tooltips and accessible names, and expose the selected state:

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

Check desktop and mobile breakpoints, including overflow, clipping, accidental
fixed-dimension jumps, inaccessible targets, controls behind the switcher,
duplicated element IDs, and stale component state. Honor `prefers-reduced-motion`.

When finalizing, remove stale stored values when useful with
`localStorage.removeItem("project_feature_variant")`.

# UX defaults

Behavioural choices that survived real usage; visual style stays out.

- **Never stack popups.** Sub-flows are in-popup steps; a confirm dialog is
  the only legitimate overlay. Escape goes back one level, outside click
  closes (guarded by a discard confirmation when the form is dirty).
- **Never animate layout.** Layout snaps to its final size immediately —
  content laid out and painted once, full from the first frame; motion is a
  compositor-driven reveal (clip-path/transform/opacity). Animating `height`
  re-layouts every frame and some engines defer painting freshly-mounted
  content until it ends.
- **No dead ends in filters.** Offer only options that lead to results;
  already-selected options stay visible so they can be deselected.
- **Content before it's needed.** Prefetch and cache (module-level, TTL,
  invalidated by mutations) so a flow opens already populated instead of
  loading in front of the user; recover visibly from failed fetches with a
  retry affordance.
- **Never land on emptiness.** Preselect the first option that has results
  (first free day, first non-empty section) before first paint.
- **Reserved areas.** Zones whose content loads or empties keep a fixed
  size; loading and empty states never move the layout.
- **Forms submit only when valid.** Submit stays disabled until required
  inputs validate; every button carries an explicit `type`.
- **Deep-linkable state.** Sections and presets ride query parameters;
  one-shot presets are consumed and then removed from the URL.
- **Switch vs checkbox.** A toggle switch for persistent on/off state that
  takes effect immediately; a checkbox for choices submitted with a form.

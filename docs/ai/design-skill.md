# The shared design skill

`design` lives in [`home/packages/ai/skills/design`](../../home/packages/ai/skills/design/SKILL.md).
The shared registry installs it for every configured agent, not as a dotfiles-local skill. It replaces
`frontend-design`, `hallmark`, and the seven `better-*` skills.

## Ownership

The skill owns UX principles, the design process, and verification. Each project
owns its style and interaction conventions in `DESIGN.md`.
Samir chose one self-contained entry point on 2026-09-05.

Style includes fonts, palettes, radii, density, page families, and exact motion
timings. Do not introduce shared aesthetic defaults while adding UX guidance.
Numeric accessibility requirements are different from aesthetic preferences;
label their criteria and exceptions rather than calling every number a standard.

The skill needs no runtime, network request, external skill, theme catalog, or
project log. References live beside the entry point and load by task.

A locked design can contain a measured failure. Report it without silently
rewriting the system or pretending documentation makes it compliant. Ask before
changing a locked decision or sweeping existing components after adding a rule.

## Sources and deliberate omissions

The text synthesizes principles in original wording rather than concatenating
upstream prompts. These are the inspected snapshots, not runtime dependencies.

| Source | What informed this skill | What stayed out |
| --- | --- | --- |
| [Anthropic frontend-design](https://github.com/anthropics/skills/tree/41bbe19d1a1a7eaab5e7bb9050a417e5c6cffc8f/skills/frontend-design) | Brief-led direction, restraint, copy, rendered critique | Mandatory distinctiveness and lists of unfashionable styles |
| [Impeccable](https://github.com/pbakaus/impeccable/tree/0ac0b6866f8e912bf0ff50070844f1284c8d359c/.agents/skills/impeccable) | Different goals for task, reading, and public surfaces; bounded verification | Binary launcher, hooks, mandatory project artifacts, absolute visual bans |
| [Jakub Krehel's skills](https://github.com/jakubkrehel/skills/tree/267330e1adfc66a718fb65fa6918c1f06d0a689e/skills) | Evidence-based review, accessibility, semantic tokens, layout and interaction checks | Mandatory animation values, font restrictions, universal submit policy |
| [Interface Design](https://github.com/Dammyjay93/interface-design/tree/2f9be3206855bcb2d1d0af262c8bae25cba6658d/.claude/skills/interface-design) | Reuse controls, preserve state behavior, inspect product context | A signature for every product, per-component design monologues |
| [Hallmark](https://github.com/Nutlope/hallmark/tree/13ac0ec7e148655948100b6396439e481361d690/skills/hallmark) | Preserve existing systems, plan structure, use honest content | Theme rotation, stamps, logs, global overflow clipping, eight states everywhere |
| [Taste-skill](https://github.com/Leonxlnx/taste-skill/tree/ccbc15639c97057cbfcf32ecebc38ef716e4bb37/skills/taste-skill) | Separate refinement from overhaul, verify motion and assets | Style dials, prescribed stack, mandatory dark mode, punctuation bans |
| [UI/UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill/tree/f3ac195224eac1eb0dfe1a3059c2a6add78ffbe3/.claude/skills/ui-ux-pro-max) | Prioritize usability, identify the actual platform, load focused guidance | Search runtime, style database, generated design systems |

Accessibility thresholds follow [WCAG 2.2](https://www.w3.org/TR/WCAG22/) rather
than informal upstream summaries. In particular, 44px is not the universal AA
target minimum, and 18px regular text is not WCAG large text.

## Lessons from the projects

Read on 2026-09-05:

- [Sottocasa design decisions](https://github.com/samirettali/sottocasa/blob/f3d7bdc/design.md)
  contributes actionable hierarchy, recognizable controls, confirmation for
  external effects, stable popup steps, and evidence from rejected experiments.
- [Sottotesto design decisions](https://github.com/samirettali/sottotesto/blob/9afcc72/design.md)
  contributes continuity across asynchronous states, nonduplicated feedback,
  recoverable errors, content-first disclosure, and measured accessibility gaps.

Their styles deliberately disagree. Sottocasa uses square, bordered controls and
an editorial ledger. Sottotesto uses a neutral reading surface with quieter
navigation. The skill preserves both rather than averaging their tokens.

Their implementation choices are examples, not universal rules. Sottotesto's
persistent request button teaches continuity, not a ban on unmounting elements.
Sottocasa's submit policy teaches discoverable prerequisites, not a requirement
to disable every invalid form.

## Review cases for future edits

These are behavioral acceptance cases, not claims of a generation benchmark.
Use them to check whether new guidance accidentally imposes a style or broadens
scope. A model-based evaluation must report its prompts, model, and actual output.

| Request | Expected behavior |
| --- | --- |
| Fix Sottocasa's booking picker | Reuse the themed picker and square controls; do not migrate to native styling |
| Improve Sottotesto's reading view | Preserve its palette and typography; do not add display fonts, cards, or a hero |
| Review Sottotesto's faint text | Report measured failures; ask before changing locked tokens; never claim the documented exception passes |
| Add an input to a form with disabled submits | Preserve the clear convention; verify the reason for unavailability and server validation |
| Retry a failed reading request | Keep useful state and focus; do not offer retries for a known permanent failure |
| Confirm a booking that sends a message | Do not call Undo equivalent to preventing the outgoing notification |
| Review a narrow screen without a browser | Report source findings and mark rendered behavior unverified |
| Change one button label | No brand interview, new token architecture, or whole-project cleanup |
| Build a new product with no visual brief | Resolve audience and task; agree project-specific style rather than choosing a shared theme |
| Add a native settings screen | Use native controls and platform accessibility; do not impose HTML, ARIA, or CSS sizing |

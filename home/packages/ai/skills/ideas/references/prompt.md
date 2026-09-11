# The prompt file

One Markdown file per pick in `~/dev/prompts/<name>.md`, in English,
self-contained: he pastes it into an agent on another machine that has none
of this conversation. Shape it like the ones already there, and like this:

1. **What to build**, in two sentences, and the name or how to choose one.
2. **Load the `side-project` skill** and say which shape applies: frontend
   only, API only, full product. Repo at `~/dev/<name>`, `git init`, a locked
   `design.md` when there is a UI.
3. **The principles** that make it his: data not code, deterministic from a
   seed with `Math.random` banned outside one file, nothing from wall-clock
   time, state in the URL.
4. **The substance**: stages, families, presets, components, whatever the
   project is made of, in enough detail that the agent does not have to
   guess and specific enough to verify (the glider must glide, the file must
   open in a real viewer). Name the papers and reference implementations
   and ask for every constant to carry its source.
5. **Interface**: Italian UI copy, English code and docs, the skill's UX
   defaults, light and dark, port in the Makefile and in `AGENTS.md`.
6. **How to work**: no questions unless two readings lead to materially
   different work, build the thin end-to-end path first and deepen after,
   verify in a real browser at each step, screenshots in `docs/`, `TODO.md`
   untracked, and what to print when done.

Keep it under 80 lines. Do not run the prompt yourself and do not create the
repo: the file is the deliverable. Say where it landed in one line.

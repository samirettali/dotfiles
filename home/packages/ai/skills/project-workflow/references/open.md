# Opening an issue

1. Search for duplicates first:

   ```sh
   gh issue list --repo samirettali/<repo> --search "<keywords>" --state all
   ```

2. Write a **self-sufficient** description. The reader is someone — or some agent
   — picking it up cold months later, with no memory of how it surfaced:

   - what is wrong
   - **where**: file and function, with the snippet when it helps
   - why it matters, in concrete terms
   - what the fix looks like — and if you don't know, say it needs investigating
     rather than inventing a plausible cause
   - what to verify afterwards
   - which docs need updating when it lands

3. Always pass the Project explicitly, don't rely on auto-add (the Free plan
   allows a single auto-add workflow, on a single repo):

   ```sh
   gh issue create --repo samirettali/<repo> --project "dev" \
     --title "<title>" --body "<body>"
   ```

4. The new issue lands in `📋 Backlog` by itself. Do not set `Priority`.

TODOs in the code stay in the code. If you turn one into an issue, cite file and
line in the issue and **do not remove the comment** unless asked.

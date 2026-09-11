# Closing an issue

1. If behaviour changed, update the docs **in the same PR**. A doc deferred to a
   later PR is a doc that falls behind. `AGENTS.md` stays thin: what the project
   is, commands, conventions, and a one-line index entry per `docs/` page.
   Everything else lives in `docs/`, versioned alongside the code. No wiki.
2. Open the PR with the reference that closes the issue:

   ```sh
   gh pr create --title "<title>" --body "Closes #<N>

   <what changes and how it was verified>"
   ```

3. Move the issue to `👀 In review`.
4. Watch the checks: `gh pr checks <N>`. On a failure, `gh run view <run-id>
   --log-failed` prints the logs of the failed steps only.
5. Do not close the issue by hand, and do not set it to `✅ Done`: the merge takes
   care of it.

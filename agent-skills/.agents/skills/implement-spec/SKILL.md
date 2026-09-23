---
name: implement-spec
description: "Implement a specification in code."
disable-model-invocation: true
---

You have been provided a spec. This spec should have tickets associated with it, describing how to implement the spec.

The goal is a PR which implements the entire spec on a single branch.

The tickets are not a list of steps. They are a **task graph** with blocking relationships between them. This means there is always a **frontier** of tickets which are ready to be grabbed.

Communication to and from subagents should be sparse. Communicate primarily through **context pointers**: to the spec, tickets, research notes, and previous commits. Don't duplicate information already available via pointers.

**Implementer subagents** should be run in the background where possible for **maximum concurrency**.

The ticket lifecycle and the tracker commands should have been provided to you (`docs/agents/ticket-lifecycle.md`, `docs/agents/issue-tracker.md`). If not, tell the user to run `/setup-repo`. The frontier is the open tickets whose blockers are all `done`.

## Steps

1. Read the spec and tickets. Read enough to understand the task graph.

2. (optional) Use an **exploration subagent** to conduct any exploration required by the tickets - relevant codebase files or external documentation. Ensure the exploration subagent can save files - it should save its markdown notes in a directory outside the repo, accessible by all future subagents. This lets **implementer subagents** focus on implementation rather than exploration.

3. Create a branch, and a draft PR that references the spec and its tickets with `Refs #N`. Leave closing keywords like `Closes` out: the spec stays open for the user to validate, and each ticket is closed in step 5.

4. Use **implementer subagents** to implement each ticket. Each implementer subagent should work in its own worktree, on its own branch. It claims its ticket before any work and references it in each commit as the **Commit references** section of `docs/agents/issue-tracker.md` says (`Refs #N` when it has none).

5. Once an **implementer subagent** completes, merge its work to the PR branch with a **merger subagent**. Then close its ticket: tick the acceptance criteria the implementer verified, and close it as `done` with a comment naming what shipped and the merge commit. A ticket with a criterion unmet stays `in-progress`, with a comment naming what is missing; report it to the user at the end.

6. If this changes the **frontier** of available tickets, kick off more **implementer subagents** to work on the new tickets. This allows for maximum concurrency.

7. Once all tickets are complete, run /review-diff on the PR branch. Fix all issues raised by the code review in a single **implementer subagent**.

8. Mark the PR as ready for review. Leave the spec open, and tell the user both the PR and the spec are ready for their review.

9. Clean up all **implementer subagent** worktrees.

If you stop before the spec is built, release every ticket still `in-progress`.

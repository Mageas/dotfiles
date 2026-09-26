---
name: implement-spec
description: "Implement a specification in code."
disable-model-invocation: true
---

You have been provided a spec. This spec should have tickets associated with it, describing how to implement the spec.

The goal is a PR which implements the entire spec on a single **integration branch**.

The tickets are not a list of steps. They are a **task graph** with blocking relationships between them. This means there is always a **frontier** of tickets which are ready to be grabbed.

Communication to and from subagents should be sparse. Communicate primarily through **context pointers**: to the spec, tickets, research notes, and previous commits. Don't duplicate information already available via pointers.

**Implementer subagents** should be run in the background where possible for **maximum concurrency**.

The ticket lifecycle and the tracker commands should have been provided to you (`docs/agents/ticket-lifecycle.md`, `docs/agents/issue-tracker.md`). If not, tell the user to run `/setup-repo`. The frontier is the open tickets whose blockers are all `done`.

## Steps

1. Read the spec and tickets. Read enough to understand the task graph.

2. (optional) Use an **exploration subagent** to conduct any exploration required by the tickets - relevant codebase files or external documentation. Ensure the exploration subagent can save files - it should save its markdown notes in a directory outside the repo, accessible by all future subagents. This lets **implementer subagents** focus on implementation rather than exploration.

3. Create the integration branch, and note the commit it starts from: it is the fixed point of the review in step 7.

4. Hand each frontier ticket to an **implementer subagent**, working in its own worktree on its own branch. Claim the ticket yourself first, and point the subagent at it and at the spec by issue reference, or by absolute path on a local tracker: a worktree holds only tracked files, so a gitignored `.scratch/` is missing from it. Each implementer subagent:
   - confirms its worktree is based on the integration branch before starting, and resets onto it if not;
   - calls the Skill tool with `tdd` to build the ticket, at the seams the spec agreed;
   - references the ticket in each commit as the **Commit references** section of `docs/agents/issue-tracker.md` says (`Refs #N` when it has none);
   - merges the integration branch tip into its own branch before reporting done.

5. Once an **implementer subagent** completes, merge its work to the integration branch with a **merger subagent**. Then close its ticket: tick the acceptance criteria the implementer verified, and close it as `done` with a comment naming what shipped and the merge commit. A ticket with a criterion unmet stays `in-progress`, with a comment naming what is missing; report it to the user at the end. Name any seam the implementer flagged as unconfirmed in the ticket's comment, and report it to the user at the end.

   After the first merge, open a draft PR from the integration branch that references the spec and its tickets with `Refs #N`. Before that merge the branch has no commits ahead of the default branch, and a PR can't open. Leave closing keywords like `Closes` out: the spec stays open for the user to validate, and each ticket is closed by this step.

6. If this changes the **frontier** of available tickets, kick off more **implementer subagents** on the new tickets, as in step 4. This allows for maximum concurrency.

7. Once all tickets are complete, run /review-diff on the integration branch, with the commit noted in step 3 as its fixed point. Fix all issues raised by the code review in a single **implementer subagent**.

8. Call the Skill tool with `pr-body` to write the PR body, keeping its `Refs` lines, then mark the PR as ready for review. Leave the spec open, and tell the user both the PR and the spec are ready for their review.

9. Clean up all **implementer subagent** worktrees.

If you stop before the spec is built, release every ticket still `in-progress`.

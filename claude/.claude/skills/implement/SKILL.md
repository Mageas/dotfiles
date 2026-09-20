---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work to the current branch.

Then close out the ticket you worked from, using the tracker mechanics in `docs/agents/issue-tracker.md`:

- Tick every acceptance criterion you verified, and only those. A criterion you could not verify stays unticked.
- Post a resolution comment: what shipped, how it was verified, and a pointer to the work (the PR when there is one, otherwise the commit on the branch).
- Mark the ticket done: close it on a real tracker, or set its `Status:` to `done` on a local ticket file. Under a PR-based workflow the merge owns the close, so leave the ticket open and name the PR that will close it.
- Leave any parent issue open, even when this was its last child. Tell the user it is ready for their review instead: only they can confirm a parent's acceptance criteria are met, not just that every child is ticked.

If a criterion is unmet, don't mark the ticket done. Name what is missing in the comment and hand back to the user.

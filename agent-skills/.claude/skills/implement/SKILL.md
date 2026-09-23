---
name: implement
description: "Implement a spec or a set of tickets: claim each ticket, build it, review it, commit it, and close it on the tracker."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

The ticket lifecycle and the tracker commands should have been provided to you (`docs/agents/ticket-lifecycle.md`, `docs/agents/issue-tracker.md`). If not, tell the user to run `/setup-repo`. Working without a ticket (a spec alone, or the conversation), skip the tracker steps.

## Before any code

For each ticket you are about to work:

1. Check its blockers. Every one must be `done`; if one isn't, stop and name it to the user.
2. Claim it.

## Build

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /review-diff to review the work.

Commit your work to the current branch. Reference the ticket in each commit message as the **Commit references** section of `docs/agents/issue-tracker.md` says (`Refs #N` when it has none).

## Close out

For each ticket you worked:

1. Tick the acceptance criteria you verified, and only those.
2. Every criterion ticked: close the ticket as `done`, with a comment saying what shipped, how it was verified, and the commit (SHA and branch).
3. A criterion unmet: leave the ticket `in-progress`, comment what is missing, and hand back to the user.

Leave the spec open, even after its last ticket: the user validates it. When no open ticket remains under it, tell the user the spec is ready for their review.

If you stop before the work is done, release each ticket you claimed.

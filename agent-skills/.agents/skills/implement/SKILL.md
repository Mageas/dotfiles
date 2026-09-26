---
name: implement
description: "Implement a spec or a set of tickets: claim each ticket, build it, review it, commit it, and close it on the tracker."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

The ticket lifecycle and the tracker commands should have been provided to you (`docs/agents/ticket-lifecycle.md`, `docs/agents/issue-tracker.md`). If not, tell the user to run `/setup-repo`. Working without a ticket (a spec alone, or the conversation), skip the tracker steps.

## Before any code

For each ticket you are about to work:

1. Check it is unblocked; if it isn't, stop and name the blocker to the user.
2. Claim it.

Then note the current `HEAD`: it is the fixed point the review compares against.

## Build

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Commit your work to the current branch. Reference the ticket in each commit message as the **Commit references** section of `docs/agents/issue-tracker.md` says (`Refs #N` when it has none).

Once committed, run /review-diff with the `HEAD` you noted as its fixed point, and commit any fix it leads to.

## Close out

For each ticket you worked:

1. Tick the acceptance criteria you verified, and only those.
2. Every criterion ticked: close the ticket as `done`. The closing comment also says how it was verified and gives the commit SHA.
3. A criterion unmet: leave the ticket `in-progress`, comment what is missing, and hand back to the user.

Leave the spec open. When no open ticket remains under it, tell the user to run `/accept-spec` on it.

If you stop before the work is done, release each ticket you claimed.

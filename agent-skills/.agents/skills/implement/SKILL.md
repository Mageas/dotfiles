---
name: implement
description: "Implement a ticket, a set of tickets or a small spec on the current branch: claim, build, review, commit and close each ticket. Use when the user asks to implement or build tickets, or a spec that fits one context window."
---

Implement the work described by the user in the spec or tickets.

The ticket lifecycle and the tracker commands should have been provided to you (`docs/agents/ticket-lifecycle.md`, `docs/agents/issue-tracker.md`). If not, tell the user to run `/setup-repo`. Working without a ticket (a spec alone, or the conversation), skip the tracker steps.

## Several tickets

Given more than one ticket, you orchestrate: each ticket goes to its own **implementer subagent**, one at a time, so each starts from a fresh context. Note the current `HEAD` first: it is the fixed point of the final review.

Take the tickets in blocking order, each after the tickets of the set that block it. For each ticket:

1. Check it is unblocked and claim it, as in **Before any code**.
2. Hand it to an implementer subagent and wait for its report. Point the subagent at the ticket and its spec rather than restating them. The subagent:
   - calls the Skill tool with `tdd` to build the ticket, at the seams the spec agreed;
   - runs the full test suite, then commits to the current branch, referencing the ticket as the **Commit references** section of `docs/agents/issue-tracker.md` says;
   - reports each acceptance criterion as verified, saying how, or unmet, and any seam it flagged as unconfirmed.
3. Close it out as in **Close out**, from the subagent's report. Name any unconfirmed seam in the ticket's comment, and report it to the user at the end.

Once every ticket is closed, call the Skill tool with `review-diff`, with the `HEAD` you noted as its fixed point, and hand its findings to one more implementer subagent, which fixes and commits them.

## Before any code

For each ticket you are about to work:

1. Check it is unblocked; if it isn't, stop and name the blocker to the user.
2. Claim it.

Then note the current `HEAD`: it is the fixed point the review compares against.

## Build

Call the Skill tool with `tdd` where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Commit your work to the current branch. Reference the ticket in each commit message as the **Commit references** section of `docs/agents/issue-tracker.md` says.

Once committed, call the Skill tool with `review-diff`, with the `HEAD` you noted as its fixed point, and commit any fix it leads to.

## Close out

For each ticket you worked:

1. Tick the acceptance criteria you verified, and only those.
2. Every criterion ticked: close the ticket as `done`. The closing comment also says how it was verified and gives the commit SHA.
3. A criterion unmet: leave the ticket `in-progress`, comment what is missing, and hand back to the user.

Leave the spec open. When no open ticket remains under it, tell the user to run `/accept-spec` on it.

If you stop before the work is done, release each ticket you claimed.

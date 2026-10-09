---
name: implement
description: "Implement a ticket, a set of tickets or a small spec on the current branch: claim, build, review, commit and close each ticket. Use when the user asks to implement or build tickets, or a spec that fits one context window."
---

Implement the work described by the user in the spec or tickets.

The ticket lifecycle and the tracker commands should have been provided to you (`docs/agents/ticket-lifecycle.md`, `docs/agents/issue-tracker.md`). If not, tell the user to run `/setup-repo`. Working from a spec alone, skip the tracker steps. Working from the conversation, write the ticket first, as in **From the conversation**.

## From the conversation

For a short change, the ticket is the spec. Before any code, draft one from the conversation in the `<issue-template>` of [to-tickets' SKILL.md](../to-tickets/SKILL.md): what to build and its acceptance criteria. Show it to the user, and once they confirm, publish it with the `ticket` role and work it as any ticket.

A change that leaves every observable behaviour as it is (a typo, a rename, a dependency bump) needs no ticket: skip the tracker steps.

## Several tickets

Given more than one ticket, you orchestrate: each ticket goes to its own **implementer subagent**, one at a time, so each starts from a fresh context. Note the current `HEAD` first: it is the fixed point of the final review.

Take the tickets in blocking order, each after the tickets of the set that block it. For each ticket:

1. Check it is unblocked and claim it, as in **Before any code**.
2. Hand it to an implementer subagent and wait for its report. Point the subagent at the ticket and its spec rather than restating them. The subagent:
   - calls the Skill tool with `tdd` to build the ticket, at the seams the spec agreed;
   - stops at any part of the spec or ticket the build shows wrong, and reports what it found;
   - runs typechecking and the test files the ticket touched, not the full suite, then commits to the current branch, referencing the ticket as the **Commit references** section of `docs/agents/issue-tracker.md` says;
   - reports each acceptance criterion as verified, saying how, or unmet, and any seam it flagged as unconfirmed.
3. Close it out as in **Close out**, from the subagent's report. Name any unconfirmed seam in the ticket's comment, and report it to the user at the end. A report of the spec being wrong goes through **When the spec is wrong** before the next ticket.

Once every ticket is closed, call the Skill tool with `review-diff`, with the `HEAD` you noted as its fixed point, and hand its findings to one more implementer subagent, which fixes and commits them, then runs the full test suite once and fixes what fails: the only full run of the set.

## Before any code

For each ticket you are about to work:

1. Check it is unblocked; if it isn't, stop and name the blocker to the user.
2. Claim it.

Then note the current `HEAD`: it is the fixed point the review compares against.

## Build

Call the Skill tool with `tdd` where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end. If the repo has `docs/agents/testing.md`, run the tests as it says.

Commit your work to the current branch. Reference the ticket in each commit message as the **Commit references** section of `docs/agents/issue-tracker.md` says.

Once committed, call the Skill tool with `review-diff`, with the `HEAD` you noted as its fixed point, and commit any fix it leads to.

## When the spec is wrong

An open spec is amended, then built. When the build shows part of the spec or ticket wrong (a criterion that cannot hold, an interface that has to differ, a story the spec missed), stop that ticket and bring what you found to the user. Once they decide:

1. Edit the spec's body where the decision changes it: the story, its criteria, the Architecture section or an implementation decision.
2. Edit the open tickets that copied the changed part.
3. Comment on the spec what changed and why.

Then resume the ticket against the amended spec.

## Close out

For each ticket you worked:

1. Tick the acceptance criteria you verified, and only those.
2. Every criterion ticked: close the ticket as `done`. The closing comment also says how it was verified and gives the commit SHA.
3. A criterion unmet: leave the ticket `in-progress`, comment what is missing, and hand back to the user.

Leave the spec open. When no open ticket remains under it, tell the user to run `/accept-spec` on it.

If you stop before the work is done, release each ticket you claimed.

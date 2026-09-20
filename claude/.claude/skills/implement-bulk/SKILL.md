---
name: implement-bulk
description: "Implement a run of tickets one fresh subagent per ticket, pushing the branch after each one lands."
disable-model-invocation: true
---

Work a list of tickets the way /implement works one, except each ticket gets its own subagent and every finished ticket is verified and pushed before the next starts.

Use this when the work is several tickets long and you want the orchestrating context to stay small: it holds the ticket order and the state of the branch, never the implementation detail of any single ticket.

- One ticket only: use /implement directly.
- A whole spec whose tickets you want worked concurrently in worktrees behind a draft PR: use /implement-spec.

Here everything happens on **one branch in one working tree**, sequentially. That is the point: each push is a checkpoint the user can look at, and a ticket never builds on unverified work.

## Before the first subagent

1. Read the tickets: enough to order them. Respect their blocking edges; where several are ready at once, pick any order and say which you picked.
2. Be on a feature branch, not the default branch. Create one if needed, and give it an upstream (`git push -u origin <branch>`) so later pushes are a bare `git push`.
3. Show the user the ordered list and get a yes before launching anything.

## The loop, once per ticket

1. **Brief a subagent with pointers, not content.** Give it: the ticket reference, the branch it is on, the path to `docs/agents/issue-tracker.md`, any exploration notes, and the commits earlier tickets in this run produced. Do not paste the ticket body or restate the spec; it can read them.

2. **Tell it the contract:**
   - Follow /implement for **this ticket only**. Use /tdd at the ticket's agreed seams.
   - Work on the current branch in the current working tree. No worktree, no new branch.
   - Typecheck and run the affected test files as it goes.
   - Commit its work. **Do not push**, and do not close the ticket: the orchestrator owns both.
   - Report back short: what shipped, the commit SHAs, which acceptance criteria it verified and how, and anything it could not do.

3. **Verify the claim yourself.** A subagent's report is a claim. Check `git log` and `git status` for the commits it names and for a clean tree, then run the typecheck and the ticket's tests in your own context.

4. **Push.** Green tree, verified commits, then `git push`.

5. **Close the ticket out** with the tracker mechanics in `docs/agents/issue-tracker.md`: tick only the criteria you verified, post a resolution comment pointing at the pushed commits, and mark it done (under a PR-based workflow leave it open and name the PR that will close it).

6. Only then brief the next ticket.

Run the subagents one at a time. They share a working tree, so two at once corrupt each other.

## When a subagent comes back short

Never push a red tree, and never start the next ticket on top of an unfinished one.

- A small gap (a missed edge case, a lint failure): fix it yourself in the orchestrating context, then verify and push as usual.
- A ticket that turned out bigger than it looked, or whose acceptance criteria cannot be met as written: stop the run. Everything green so far is already pushed. Leave the ticket open, name what is missing in its comment, and hand back to the user with the remaining ticket list.

## At the end of the run

1. Run the full test suite once.
2. Run /code-review over the whole range (`merge-base..HEAD`, not just the last ticket). Fix everything it raises in a single subagent, then verify and push that too.
3. Leave any parent issue open, even when this run closed its last child. Tell the user it is ready for their review: only they can confirm a parent's acceptance criteria are met.

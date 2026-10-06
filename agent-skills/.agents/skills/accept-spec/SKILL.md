---
name: accept-spec
description: "Validate a built spec against its user stories, then close it as done or turn the gaps into tickets."
disable-model-invocation: true
---

# Accept Spec

A spec stays open after its last ticket: only the user can accept it. This skill prepares that decision with evidence, then records it.

The ticket lifecycle and the tracker commands should have been provided to you (`docs/agents/ticket-lifecycle.md`, `docs/agents/issue-tracker.md`). If not, tell the user to run `/setup-repo`.

## 1. Gather

Fetch the spec the user names, with its comments, and its tickets: its sub-issues on a real tracker, the files under `.scratch/<feature>/issues/` locally. Note every ticket that isn't `done`, and, for each user story, the tickets whose **User stories** section names it: their commits are where its code and tests are.

Find what shipped: the commits that reference the spec or its tickets (`git log --grep`), and the branch or PR each closing comment names. Check the spec against the branch the user says it ships from, the default branch unless told otherwise, and run the full test suite there once.

## 2. Rate every user story

For each numbered user story in the spec, find, for each of its acceptance criteria, the code that delivers it and the test that proves it, then rate the story. A story with no criteria is rated on its own text.

- **Covered**: code and a passing test deliver every criterion. Cite both, criterion by criterion.
- **Partial**: some criteria are delivered. Name the ones missing.
- **Missing**: nothing delivers it.
- **Needs your eyes**: the rest is covered, and a criterion is left that only a human can judge (a UI's feel, an external system). Give the user the steps to check it.

Then read the spec's **Out of Scope** section and flag anything that shipped anyway.

When the spec has an **Architecture** section, check the code on that branch against it: each interface exists with its agreed signature and adapters, each factored duplicate lives in one module, each module change is made. Flag each difference as a gap.

Done when every criterion of every user story carries its evidence or its gap, every story a rating, and every architecture difference is flagged.

## 3. Decide with the user

Present the ratings story by story, then the open tickets, the out-of-scope flags and the architecture gaps, and ask one question: accept the spec, or not yet?

- **Accept**: close the spec as `done`, with a comment summarising the ratings and naming the branch or PR it shipped on. Any gap the user accepts it with goes in that comment as consciously dropped. Any ticket still open under it closes as `wontfix`, with a comment pointing at the acceptance.
- **Not yet**: draft one ticket per gap the user wants fixed, in the `<issue-template>` of [to-tickets' SKILL.md](../to-tickets/SKILL.md), parented to the spec, with its blocking edges. Confirm the list with the user, publish the tickets with the `ticket` role, as `ready-for-agent`, and comment on the spec which gap became which ticket. The spec stays open for the next `/accept-spec`.

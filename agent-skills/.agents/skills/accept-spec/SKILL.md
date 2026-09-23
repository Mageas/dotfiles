---
name: accept-spec
description: "Validate a built spec against its user stories, then close it as done or turn the gaps into tickets."
disable-model-invocation: true
---

# Accept Spec

A spec stays open after its last ticket: only the user can accept it. This skill prepares that decision with evidence, then records it.

The ticket lifecycle and the tracker commands should have been provided to you (`docs/agents/ticket-lifecycle.md`, `docs/agents/issue-tracker.md`). If not, tell the user to run `/setup-repo`.

## 1. Gather

Fetch the spec the user names, with its comments, and its tickets: its sub-issues on a real tracker, the files under `.scratch/<feature>/issues/` locally. Note every ticket that isn't `done`.

Find what shipped: the commits that reference the spec or its tickets (`git log --grep`), and the branch or PR each closing comment names. Check the spec against the branch the user says it ships from, the default branch unless told otherwise, and run the full test suite there once.

## 2. Rate every user story

For each numbered user story in the spec, find the code that delivers it and the test that proves it, then rate it:

- **Covered**: code and a passing test deliver it. Cite both.
- **Partial**: part of it is delivered. Say which part is missing.
- **Missing**: nothing delivers it.
- **Needs your eyes**: only a human can judge it (a UI's feel, an external system). Give the user the steps to check it.

Then read the spec's **Out of Scope** section and flag anything that shipped anyway.

Done when every user story carries a rating and its evidence.

## 3. Decide with the user

Present the ratings story by story, then the open tickets and the out-of-scope flags, and ask one question: accept the spec, or not yet?

- **Accept**: close the spec as `done`, with a comment summarising the ratings and naming the branch or PR it shipped on. Any gap the user accepts it with goes in that comment as consciously dropped. Any ticket still open under it closes as `wontfix`, with a comment pointing at the acceptance.
- **Not yet**: draft one ticket per gap the user wants fixed, in `/to-tickets`' issue template, parented to the spec, with its blocking edges. Confirm the list with the user, publish the tickets with the `ticket` role, as `ready-for-agent`, and comment on the spec which gap became which ticket. The spec stays open for the next `/accept-spec`.

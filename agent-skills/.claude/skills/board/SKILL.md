---
name: board
description: "Show where every spec, ticket and wayfinder map stands: what waits on you, what's claimable, and what breaks the ticket lifecycle."
disable-model-invocation: true
---

# Board

A read-only snapshot of the tracker, measured against the ticket lifecycle. It changes nothing: every fix it finds is a proposal the user picks from.

The ticket lifecycle and the tracker commands should have been provided to you (`docs/agents/ticket-lifecycle.md`, `docs/agents/issue-tracker.md`). If not, tell the user to run `/setup-repo`.

## 1. Gather

Fetch every open issue with its labels, assignee, last activity, parent, and blocking edges, plus the issues closed in the last 30 days with their closing comments. On a local tracker, read every `.scratch/*/spec.md`, `map.md`, and `issues/*.md`.

## 2. Sort into sections

Refer to every spec, map, and ticket by its title, with its link inside the name. Oldest first within a section; skip an empty section.

1. **Waiting on you**: specs whose tickets are all `done` (ready for `/accept-spec`); wayfinder maps with no open ticket and an empty **Not yet specified** (ready for their hand-off); `ready-for-human` tickets; the count of issues still in `/triage`'s hands (unlabeled, `needs-triage`, `needs-info`).
2. **Claimable now**: per spec, per map, then the standalone ones, the open tickets whose blockers are all `done` and that nobody has claimed, `ready-for-human` ones aside.
3. **In progress**: every `in-progress` ticket with its assignee and last activity. A claim idle for 7 days is **stale**: mark it.
4. **Blocked**: every ticket still waiting, with what it waits on. A `wontfix` blocker never clears, so mark those dependents as needing a re-wire.
5. **Anomalies**, anything the lifecycle rules out:
   - a ticket carrying two states, or a spec carrying one;
   - an `in-progress` ticket with nobody assigned, on a real tracker;
   - a closed ticket with no closing comment;
   - a ticket closed as `done` in the last 30 days whose branch no longer exists and whose commit isn't on the default branch. It may come from an abandoned branch; a squash merge looks the same, so check its PR before calling it one.

Done when every open ticket (specs and maps aside) sits in exactly one section, or is counted in `/triage`'s hands.

## 3. Propose fixes

After the board, list one fix per stale claim, needed re-wire, and anomaly: what to change, and the skill or tracker command that does it. Apply only the fixes the user names.

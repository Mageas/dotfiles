# Ticket Lifecycle

Every ticket on this repo's tracker moves through one lifecycle, whichever skill created it. The skills speak in canonical role names; this file maps each one to the label string used in this repo's tracker. The commands that apply a role, claim a ticket, or close it live in `issue-tracker.md`.

## Open states

| Role in mattpocock/skills | Label in our tracker | Meaning                                          |
| ------------------------- | -------------------- | ------------------------------------------------ |
| `needs-triage`            | `needs-triage`       | Maintainer needs to evaluate this issue          |
| `needs-info`              | `needs-info`         | Waiting on reporter for more information         |
| `ready-for-agent`         | `ready-for-agent`    | Fully specified, ready for an AFK agent to claim |
| `ready-for-human`         | `ready-for-human`    | Ready for a human to claim                       |
| `in-progress`             | `in-progress`        | Claimed: someone is working it                   |

## Closed states

| Role in mattpocock/skills | Label in our tracker    | Meaning                                                            |
| ------------------------- | ----------------------- | ------------------------------------------------------------------ |
| `done`                    | none, the close says it | The work shipped, or the decision was made                         |
| `wontfix`                 | `wontfix`               | Will not happen: rejected, out of scope, duplicate, or invalidated |

## Specs

| Role in mattpocock/skills | Label in our tracker | Meaning                                  |
| ------------------------- | -------------------- | ---------------------------------------- |
| `spec`                    | `spec`               | A spec, the parent its tickets hang from |

A spec carries the `spec` label and no state: it is the user's to validate, never an agent's to claim. It stays open while its tickets move, and the user closes it as `done` once they have validated it.

When a skill mentions a role (e.g. "apply the AFK-ready role"), use the corresponding label string from these tables. Edit the right-hand column to match whatever vocabulary you actually use.

## Rules

- A ticket carries one state at a time. A spec carries none.
- **Claim** before any other work: set `in-progress` and assign yourself, in one write, so concurrent sessions skip the ticket.
- **Release** a claim you abandon: set the ready state back, unassign, and comment why.
- **Close** as `done` or `wontfix`, always with a comment: what shipped or was decided for `done`, the reason for `wontfix`. Drop the open state on close.
- `done` means the work is committed on the branch it ships from, merged or not, so tickets that build on each other can follow one another on the same branch. The closing comment names that branch. If the branch is abandoned, **reopen** its tickets in their ready state, with a comment saying why.
- A ticket is **unblocked** when every ticket blocking it is `done`. A `wontfix` blocker keeps its dependents blocked until each is re-wired or closed itself.

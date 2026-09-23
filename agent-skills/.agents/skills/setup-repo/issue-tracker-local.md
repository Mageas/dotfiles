# Issue tracker: Local Markdown

Issues and specs for this repo live as markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The spec is `.scratch/<feature-slug>/spec.md`. Its file name carries the `spec` role, so it has no `Status:` line until the user closes it.
- Implementation issues are one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`, never a single combined tickets file
- A ticket's state is a `Status:` line near the top of its file, holding one role from `ticket-lifecycle.md`. There is no assignee: `Status: in-progress` is the claim, and closing sets `Status: done` or `Status: wontfix`, with a comment saying why.
- Comments and conversation history append to the bottom of the file under a `## Comments` heading

## Commit references

**Reference tickets in commits: yes.** _(Set to `no` if this repo's history must carry no ticket references; `/implement`, `/implement-spec` and `/diagnose` read this flag.)_

When set to `yes`, reference the ticket in each commit message with a `Refs <ticket file path>` line. Leave closing keywords like `Closes` out: a ticket closes on the tracker, once its criteria are checked. When set to `no`, commit messages carry no ticket path; the ticket's closing comment names the commit instead.

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<feature-slug>/` (creating the directory if needed).

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a file with one **child** file per ticket.

- **Map**: `.scratch/<effort>/map.md` (the Notes / Decisions-so-far / Fog body).
- **Child ticket**: `.scratch/<effort>/issues/NN-<slug>.md`, numbered from `01`, with the question in the body. A `Type:` line records the ticket type (`research`/`prototype`/`grilling`/`task`); a `Status:` line records its state once claimed (`in-progress`, then `done` or `wontfix`).
- **Blocking**: a `Blocked by: NN, NN` line near the top. A ticket is unblocked when every file it lists is `done`.
- **Frontier**: scan `.scratch/<effort>/issues/` for files with no `Status:` line yet (neither claimed nor closed) that are unblocked; first by number wins.
- **Claim**: set `Status: in-progress` and save before any work.
- **Stale claims**: files with `Status: in-progress` whose last change is more than 7 days old (`git log -1 --format=%cr -- <file>`, or the file's modification time when uncommitted).
- **Resolve**: append the answer under an `## Answer` heading, set `Status: done`, then append a context pointer (gist + link) to the map's Decisions-so-far in `map.md`.

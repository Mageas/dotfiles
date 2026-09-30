# Issue tracker: Local Markdown

Issues and specs for this repo live as markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The spec is `.scratch/<feature-slug>/spec.md`, with `Type: spec` and no `Status:` line until the user closes it.
- Implementation issues are one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`, never a single combined tickets file
- There is no assignee: `Status: in-progress` is the claim, and closing sets `Status: done` or `Status: wontfix`, with a comment saying why.

## File layout

Every file on this tracker, whichever skill writes it (spec, map, ticket, triaged issue), has the same layout: what a real tracker keeps beside the body comes first, then the body, then the comments.

```markdown
# <Title>

Type: <type>
Status: <state>
Blocked by: <NN, NN>

<body>

## Comments

### <YYYY-MM-DD>

<comment>
```

- **Title**: the file's first line is a `#` heading holding the issue's title, as a real tracker would show it. A ticket's number stays in its file name, out of the title.
- **Field lines**: plain `Key: value` lines, never bold, in this order, each written only when it applies:
  - `Type:` on every file: one type from `ticket-lifecycle.md`, the same string a real tracker would use as a label (`spec`, `ticket`, `bug`, `enhancement`, `wayfinder:research`, ...).
  - `Status:` once the file has a state: one role from `ticket-lifecycle.md`. A spec and a map carry none. A wayfinder ticket gets one when claimed; every other ticket is created with its ready state.
  - `Blocked by:` on every ticket under an `issues/` directory: the numbers of the tickets that gate it, or `none`.
- **Body**: the template of the skill that creates the file, as it would go into a real tracker's body, less the two sections the layout already holds: a `## Parent` section is dropped, the file's directory being its parent, and a `## Blocked by` section becomes the `Blocked by:` line.
- **Comments**: each comment and resolution is appended at the bottom under the one `## Comments` heading, created with the first comment, and opens with a `### <YYYY-MM-DD>` heading. Headings inside a comment go below that level (`####`).

## Commit references

**Reference tickets in commits: yes.** _(Set to `no` if this repo's history must carry no ticket references; `/implement`, `/implement-spec` and `/diagnose` read this flag.)_

When set to `yes`, reference the ticket in each commit message with a `Refs <ticket file path>` line. Leave closing keywords like `Closes` out: a ticket closes on the tracker, once its criteria are checked. When set to `no`, commit messages carry no ticket path; the ticket's closing comment names the commit instead.

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<feature-slug>/` (creating the directory if needed).

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a file with one **child** file per ticket.

- **Map**: `.scratch/<effort>/map.md`, with `Type: wayfinder:map` and the map body.
- **Child ticket**: `.scratch/<effort>/issues/NN-<slug>.md`, numbered from `01`, with the question as its body. Its `Type:` line records the ticket type (`wayfinder:research`/`wayfinder:prototype`/`wayfinder:grilling`/`wayfinder:task`); its `Status:` line appears once claimed (`in-progress`, then `done` or `wontfix`).
- **Blocking**: the ticket's `Blocked by:` line (see **File layout**). A ticket is unblocked when every file it lists is `done`.
- **Frontier**: scan `.scratch/<effort>/issues/` for files with no `Status:` line yet (neither claimed nor closed) that are unblocked; first by number wins.
- **Claim**: set `Status: in-progress` and save before any work.
- **Stale claims**: files with `Status: in-progress` whose last change is more than 7 days old (`git log -1 --format=%cr -- <file>`, or the file's modification time when uncommitted).
- **Resolve**: append the answer as a comment, set `Status: done`, then append a context pointer (gist + link) to the map's Decisions-so-far in `map.md`.

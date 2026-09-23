---
name: setup-repo
description: "Configure this repo for the engineering skills: set up its issue tracker, ticket lifecycle labels, and domain doc layout. Run once before first use of the other engineering skills."
disable-model-invocation: true
---

# Setup Repo

Scaffold the per-repo configuration that the engineering skills assume:

- **Issue tracker**: where issues live (GitHub by default; local markdown is also supported out of the box)
- **Ticket lifecycle**: the states every ticket moves through, mapped to this tracker's label strings, and the labels created on the tracker
- **Domain docs**: where `CONTEXT.md` and ADRs live, and the consumer rules for reading them

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Process

### 1. Explore

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

- `git remote -v` and `.git/config`: is this a GitHub repo? Which one?
- `AGENTS.md` and `CLAUDE.md` at the repo root: does either exist? Is there already an `## Agent skills` section in either?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root
- `docs/adr/` and any `src/*/docs/adr/` directories
- `docs/agents/`: does this skill's prior output already exist? A `triage-labels.md` there is the older name of `ticket-lifecycle.md`.
- `.scratch/`: a sign that a local-markdown issue tracker convention is already in use
- Is the `wayfinder` skill installed? (a `wayfinder` skill folder alongside this one, or `wayfinder` in your available skills.) This decides whether step 5 also creates the `wayfinder:*` labels.
- Monorepo signals: a `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, or a populated `packages/*` with its own `src/`. These are present only in a genuinely large multi-package repo; their absence means single-context, which is almost every repo.

### 2. Present findings and ask

Summarise what's present and what's missing. Then take the sections in order. One section, one answer, then the next.

Lead each section with the recommended answer so the user can accept it in a word. Give a one-line explainer only when the choice genuinely branches; skip the section entirely when exploration already settled it (Section B on a local-markdown tracker, Section C when there's no monorepo).

**Section A: Issue tracker.**

> Explainer: The "issue tracker" is where issues live for this repo. Skills like `to-tickets`, `triage`, and `to-spec` read from and write to it. They need to know whether to call `gh issue create`, write a markdown file under `.scratch/`, or follow some other workflow you describe. Pick the place you actually track work for this repo.

Default posture: these skills were designed for GitHub. If a `git remote` points at GitHub, propose that. If a `git remote` points at GitLab (`gitlab.com` or a self-hosted host), propose GitLab. Otherwise (or if the user prefers), offer:

- **GitHub**: issues live in the repo's GitHub Issues (uses the `gh` CLI)
- **GitLab**: issues live in the repo's GitLab Issues (uses the [`glab`](https://gitlab.com/gitlab-org/cli) CLI)
- **Local markdown**: issues live as files under `.scratch/<feature>/` in this repo (good for solo projects or repos without a remote)
- **Other** (Jira, Linear, etc.): ask the user to describe the workflow in one paragraph; the skill will record it as freeform prose

Record the choice in `docs/agents/issue-tracker.md`. The GitHub and GitLab templates carry a "PRs as a request surface" flag, defaulted **off**. Leave it off and don't raise it: a user who wants external PRs in the triage queue can flip the flag in the file later.

**Section B: Lifecycle labels.** Every skill that creates, claims, or closes a ticket reads the lifecycle, so this section runs whichever skills are installed. Skip it on a local-markdown tracker, where a ticket's `Status:` line holds the role name itself.

Ask exactly one question:

> Do you want to keep the default lifecycle labels? (recommended: **yes**)

The defaults are the roles in [ticket-lifecycle.md](./ticket-lifecycle.md), each label string equal to its name. On **yes**, write them as-is. Only if the user says no, usually because their tracker already uses other names (e.g. `bug:triage` for `needs-triage`), collect the overrides so the skills apply existing labels instead of creating duplicates. When a `triage-labels.md` exists from an earlier setup, its mapping is the starting point.

**Section C: Domain docs.** Default to **single-context** (one `CONTEXT.md` + `docs/adr/` at the repo root). This fits almost every repo; write it without asking.

Offer **multi-context** (a root `CONTEXT-MAP.md` pointing to per-context `CONTEXT.md` files) only when exploration found monorepo signals. Then confirm which layout they want.

### 3. Confirm and edit

Show the user a draft of:

- The `## Agent skills` block to add to whichever of `CLAUDE.md` / `AGENTS.md` is being edited (see step 4 for selection rules)
- The contents of `docs/agents/issue-tracker.md`, `docs/agents/domain.md`, and `docs/agents/ticket-lifecycle.md`
- On a real tracker, the labels step 5 will create

Let them edit before writing.

### 4. Write

**Pick the file to edit:**

- If `CLAUDE.md` exists, edit it.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create; don't pick for them.

Never create `AGENTS.md` when `CLAUDE.md` already exists (or vice versa); always edit the one that's already there.

If an `## Agent skills` block already exists in the chosen file, update its contents in-place rather than appending a duplicate. Don't overwrite user edits to the surrounding sections.

The block:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked]. See `docs/agents/issue-tracker.md`.

### Ticket lifecycle

[one-line summary of the label vocabulary]. See `docs/agents/ticket-lifecycle.md`.

### Domain docs

[one-line summary of layout: "single-context" or "multi-context"]. See `docs/agents/domain.md`.
```

An earlier setup may have left a `### Triage labels` sub-block and a `docs/agents/triage-labels.md`: replace the sub-block with `### Ticket lifecycle` and delete the old file once its mapping lives in `ticket-lifecycle.md`.

Then write the docs files using the seed templates in this skill folder as a starting point:

- [issue-tracker-github.md](./issue-tracker-github.md): GitHub issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md): GitLab issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md): local-markdown issue tracker
- [ticket-lifecycle.md](./ticket-lifecycle.md): lifecycle states and their label mapping
- [domain.md](./domain.md): domain doc consumer rules + layout

For "other" issue trackers, write `docs/agents/issue-tracker.md` from scratch using the user's description.

### 5. Create the labels

On a real tracker, create every label the lifecycle maps to, using the create-label command in `docs/agents/issue-tracker.md`, and give each one the description and color below. A label that already exists gets its description and color updated. When `wayfinder` is installed, also create the `wayfinder:` labels. For an "other" tracker, set the description and color wherever it supports them; with no create-label command, give the user the list to create by hand.

A lifecycle label's description is its **Meaning** in `ticket-lifecycle.md`. The colors follow two rules, so a new label fits in: a state is saturated and a type is pastel, and the hue says who acts next (red: the user, blue: the agent, purple: either, yellow: the reporter, green: someone already on it, grey: no one). Two types that share a hue take different shades, so each label stays recognizable.

| Label                 | Description                                     | Color    |
| --------------------- | ----------------------------------------------- | -------- |
| `needs-triage`        | Meaning                                         | `B60205` |
| `needs-info`          | Meaning                                         | `FBCA04` |
| `ready-for-agent`     | Meaning                                         | `0969DA` |
| `ready-for-human`     | Meaning                                         | `D73A4A` |
| `in-progress`         | Meaning                                         | `1A7F37` |
| `wontfix`             | Meaning                                         | `57606A` |
| `spec`                | Meaning                                         | `F8C8C8` |
| `wayfinder:map`       | Wayfinder map                                   | `EAEEF2` |
| `wayfinder:research`  | Wayfinder ticket: AFK research                  | `C5DEF5` |
| `wayfinder:prototype` | Wayfinder ticket: HITL prototype                | `F4B0BC` |
| `wayfinder:grilling`  | Wayfinder ticket: HITL decision                 | `FDE2E4` |
| `wayfinder:task`      | Wayfinder ticket: work that unblocks a decision | `DCCBF7` |

Done when the tracker's label list shows every one with its description and color.

### 6. Done

Tell the user the setup is complete and which engineering skills will now read from these files. Mention they can edit `docs/agents/*.md` directly later; re-running this skill is only necessary if they want to switch issue trackers or restart from scratch.

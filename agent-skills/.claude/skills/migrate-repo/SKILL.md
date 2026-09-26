---
name: migrate-repo
description: "Bring a repo configured by an older /setup-repo up to the current layout: its docs/agents files, its Agent skills block, its tracker labels, and its local tickets."
disable-model-invocation: true
---

# Migrate Repo

`/setup-repo` writes a repo's configuration once, and the skills keep moving after it. This skill finds what an older setup left behind and brings it to the current layout, keeping the choices the repo already made.

The current layout is `setup-repo`'s: its `SKILL.md` and its seed templates, in the `setup-repo` skill folder beside this one. Read them first. If that folder is missing, tell the user to install `setup-repo` and stop.

## 1. Detect

The files, not a version number, say how old the setup is. Check every marker below; each one found is a migration to run.

| Marker                                                                                                                                                             | Migration                                                                   |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------- |
| No `docs/agents/`                                                                                                                                                  | None: the repo was never set up. Tell the user to run `/setup-repo`, and stop |
| `docs/agents/triage-labels.md`                                                                                                                                     | Its label mapping moves into `ticket-lifecycle.md`, then the file is deleted |
| `docs/agents/ticket-lifecycle.md` missing, or lacking a table, row or rule of the template                                                                         | Write it from the template                                                  |
| `docs/agents/issue-tracker.md` behind the template its title names: a section missing (**Commit references**, **Wayfinding operations**), a command missing (**Claim**, **Release**, **Create a label**), `PRD` where the template says `spec` | Write it from the template                                                  |
| `docs/agents/domain.md` differing from the template                                                                                                                | Write it from the template                                                  |
| The `## Agent skills` block in `CLAUDE.md` or `AGENTS.md` differing from `setup-repo`'s, such as a `### Triage labels` sub-block                                   | Update the block                                                            |
| `.out-of-scope/` at the repo root                                                                                                                                  | `git mv` it to `docs/out-of-scope/`                                         |
| On a local tracker, a file under `.scratch/` in an old format (below)                                                                                              | Rewrite its old lines                                                       |
| On a real tracker, a lifecycle label missing, or lacking its description or color                                                                                  | Create or update the labels                                                 |

Old local formats, and what each becomes:

| Old                                                                     | Current                                                                              |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `PRD.md` or `prd.md`                                                    | `spec.md` (`git mv`), with `Type: spec` and no `Status:` line; each ticket's parent link follows the rename |
| A ticket with `Type: AFK`                                               | `Type: ticket`, its status unchanged                                                 |
| A ticket with `Type: HITL`                                              | `Type: ticket`; a `ready-for-agent` status becomes `ready-for-human`                 |
| A ticket under a feature's `issues/` with no `Type:`                    | `Type: ticket`                                                                       |
| `Type: research`, `prototype`, `grilling` or `task`                     | The same type prefixed `wayfinder:`                                                  |
| A `map.md` with no `Type:`                                              | `Type: wayfinder:map`                                                                |
| `Status: claimed` / `Status: resolved`                                  | `Status: in-progress` / `Status: done`                                               |

Write `Type:` and `Status:` as two lines, as the current templates do, even where the old file held both on one.

Done when every marker is checked and each one found is listed with the files it touches. If none is found, tell the user the repo is current and stop.

## 2. Plan and ask

Present the migrations found. Carry over the repo's own choices without asking: the label strings its old mapping used, the tracker, the PRs-as-a-request-surface flag, an "other" tracker's prose, the domain layout, and any section the user added that no template has.

Ask only what the old setup never recorded, with `setup-repo`'s recommendation: the Commit references question of its Section A, when `issue-tracker.md` lacks the flag. Then confirm the plan with the user.

## 3. Apply

Run the confirmed migrations:

- Write each `docs/agents/` file by filling its template as `setup-repo`'s step 4 does, with the carried-over values.
- Update the `## Agent skills` block in place, as `setup-repo`'s step 4 describes it.
- On a real tracker, create or update the labels as `setup-repo`'s step 5 does. Then list the open issues that carry a lifecycle state and no type, and propose a type for each: a PRD or spec becomes `spec` and drops its state, a slice of one becomes `ticket`. Apply the ones the user confirms.

Done when running step 1 again finds no marker. Show the user `git status`, and leave the commit to them.

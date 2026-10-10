---
name: brain
description: Look up a fact in the user's brain, the notes on their machines, homelab, servers, seedbox, dev tools and personal dev projects. Use when a task needs one of these facts and the current project does not hold it.
---

# Brain

The brain is a git repo of Markdown notes at `~/Documents/KBfAI`. Its `CLAUDE.md` is a map:
every note is two hops from it.

## Look up a fact

1. Read `~/Documents/KBfAI/CLAUDE.md`. Its Areas table gives each area's scope and router.
2. Read the router of the area whose scope covers the question, then the note or state file
   its line points to. A link in the brain is relative to the file that holds it.
3. Answer with the fact and the brain file it came from.

Done when you hold the fact and its file, or the matching router lists nothing on the
subject: then say the brain does not hold it. When `~/Documents/KBfAI` does not exist on
this machine, say so and stop.

## Record a fact

From another project the brain is read only. A fact worth keeping beyond this project goes
to this project's memory; the brain's harvest skill moves it into the brain.

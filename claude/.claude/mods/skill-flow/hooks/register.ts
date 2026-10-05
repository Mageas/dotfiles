import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

const ran = atom({ plugin: 'skill-flow', key: 'ran' } as const, [])

// The skills that usually run before each one. A skill missing here is an
// entry point (grill, triage, diagnose, wayfinder, deepen) or standalone.
const AFTER: Record<string, string[]> = {
  prototype: ['grill', 'handoff'],
  architect: ['grill', 'wayfinder', 'to-spec'],
  'to-spec': ['grill', 'architect', 'wayfinder'],
  'to-tickets': ['to-spec'],
  implement: ['grill', 'to-tickets', 'triage', 'wayfinder'],
  'implement-spec': ['to-tickets'],
  'accept-spec': ['implement', 'implement-spec'],
  retro: ['implement', 'implement-spec', 'diagnose', 'accept-spec'],
}

const MAP = `/setup-repo (once)

/grill ──┬─ question only code can settle? ─> /handoff → /prototype → /handoff back
         ├─ changes the shape of the code? ─> /architect
         └─ several sessions?
              yes ─> /to-spec → /to-tickets → /implement (ticket by ticket)
                                            or /implement-spec (whole spec, one PR)
              no  ─> /implement directly
                     (either way: /tdd to build, /review-diff to finish,
                      /pr-body for the PR)
         → /accept-spec (once every ticket is done)
         → /retro

/triage    ──> ready tickets ──> /implement
/diagnose  ──> fix + regression test ──> /retro (then /deepen if a seam is missing)
/wayfinder ──> map of decision tickets ──> /architect or /to-spec ──> main flow
/deepen    ──> a chosen opportunity becomes an idea ──> /grill`

function note(skill: string, before: string[]): string {
  const list = before.map(name => `/${name}`).join(', ')

  return `<workflow-note>
/${skill} usually follows ${list}, and none of them ran in this session.

If the user's request or the skill's arguments already carry that upstream work (a handoff file, a ticket, a spec, an issue number), say nothing about it and carry on. Otherwise, before starting, tell the user in two or three lines where /${skill} sits in the workflow below and what usually comes before it, then carry on with the skill unless they stop you.

${MAP}
</workflow-note>

`
}

export const register: Register = on => {
  on('skill.prompt', async ($, e, next) => {
    const computed = await next(e)
    const before = AFTER[e.skill]
    const history = await read($, ran)
    await update($, ran, list => [...list, e.skill])

    if (!before || before.some(name => history.includes(name))) {
      return computed
    }

    const root = await $.session.root()
    const isSetUp = await $.fs.exists(`${root}/docs/agents/issue-tracker.md`)

    return isSetUp ? { text: note(e.skill, before) + computed.text } : computed
  })

  on('session.end', async ($, e, next) => {
    if (e.reason === 'clear') {
      await update($, ran, () => [])
    }

    return next(e)
  })
}

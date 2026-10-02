import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

type Step = { next: string[]; options: string[]; isInterview?: true }

const FLOW: Record<string, Step> = {
  wayfinder: { next: ['architect', 'to-spec'], options: ['implement'], isInterview: true },
  grill: { next: ['to-spec'], options: ['architect', 'handoff', 'prototype'], isInterview: true },
  prototype: { next: ['handoff'], options: [] },
  architect: { next: ['to-spec'], options: ['grill'], isInterview: true },
  'to-spec': { next: ['to-tickets'], options: ['implement', 'architect'] },
  'to-tickets': { next: ['implement', 'implement-spec'], options: ['board'] },
  implement: { next: ['accept-spec'], options: ['implement', 'review-diff', 'board'] },
  'implement-spec': { next: ['accept-spec'], options: ['review-diff', 'board'] },
  tdd: { next: ['review-diff'], options: ['tdd'] },
  'review-diff': { next: ['accept-spec'], options: ['implement', 'retro'] },
  'accept-spec': { next: ['retro'], options: ['implement', 'board'] },
  triage: { next: ['implement'], options: ['board'], isInterview: true },
  diagnose: { next: ['retro'], options: ['deepen'], isInterview: true },
  deepen: { next: ['grill'], options: [], isInterview: true },
  retro: { next: [], options: ['grill', 'deepen'] },
}

// Phases whose thinking must survive a compaction intact, until /to-tickets has written it down.
const COMPACT: Record<string, string> = {
  wayfinder: 'Keep every decision ticket resolved so far with its outcome, the open decision tickets, and the map URL.',
  grill: 'Keep every decision taken, each term added to or sharpened in GLOSSARY.md with its definition, the ADRs written, and the questions still open.',
  architect: 'Keep the agreed Architecture section verbatim, the audit findings it answers, the decisions taken, glossary terms, and the questions still open.',
  'to-spec': 'Keep the spec path or issue URL, the user stories, the decisions behind them, glossary terms, and the questions still open. /to-tickets comes next.',
}

const phase = atom({ plugin: 'flow-band', key: 'phase' } as const, null)
const isOpen = atom({ plugin: 'flow-band', key: 'isOpen' } as const, false)

export const register: Register = on => {
  let isSuggesting = false

  on('skill.prompt', async ($, e, next) => {
    const current = await read($, phase)
    // /implement subagents drive /tdd; that is not a new phase.
    const isInsideBuild = e.skill === 'tdd' && (current === 'implement' || current === 'implement-spec')
    if (e.skill in FLOW && !isInsideBuild) {
      await update($, phase, () => e.skill)
      isSuggesting = !FLOW[e.skill].isInterview && FLOW[e.skill].next.length > 0
    }

    return next(e)
  })

  on('prompt.submit', ($, e, next) => {
    isSuggesting = false

    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    const result = await next(e)
    const current = await read($, phase)
    if (isSuggesting && current) {
      isSuggesting = false
      await $.prompt.suggest({ text: `/${FLOW[current].next[0]}` })
    }

    return result
  })

  on('session.compact', async ($, e, next) => {
    const current = await read($, phase)
    if (e.agentId || e.trigger === 'precompute' || !current || !COMPACT[current]) {
      return next(e)
    }

    const instructions = [e.instructions, `Session is in the /${current} phase. ${COMPACT[current]}`]
      .filter(Boolean)
      .join('\n\n')

    return next({ ...e, instructions })
  })

  // At rest, only the suggested next command among the footer's modes, as quiet as the model name beside it.
  on('ui.render', { component: 'SessionMode' }, async ($, e, next) => {
    const current = await read($, phase)
    if (!current || FLOW[current].next.length === 0) {
      return next(e)
    }

    // The modes and what other mods draw in the footer (the smart-zone gauge) come from beneath.
    const below = await next(e)
    const { Box, Button, Text } = $.ui.resolve(e)
    const step = FLOW[current]

    return (
      <Box columnGap={1}>
        {/* First: the desktop footer draws the button ahead of the rest whatever its place in the tree. */}
        <Button key="flow" plain dimColor label={`/${step.next[0]}`} onPress={() => update($, isOpen, value => !value)} />
        {/* Braille blanks: the desktop footer ignores columnGap and trims spaces, non-breaking ones included. */}
        <Text>{'\u2800'.repeat(2)}</Text>
        {below}
      </Box>
    )
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const current = await read($, phase)
    if (e.props.hasSurvey || !current || !(await read($, isOpen))) {
      return next(e)
    }

    const { Box, Button } = $.ui.resolve(e)
    const step = FLOW[current]
    const close = () => update($, isOpen, () => false)
    const pick = async (name: string) => {
      await close()
      await $.prompt.fill({ text: `/${name} ` })
    }

    return (
      <Box columnGap={1} flexWrap="wrap">
        {[...step.next, ...step.options].map((name, index) => (
          <Button
            key={name}
            variant={index < step.next.length ? 'primary' : undefined}
            dimColor={index >= step.next.length}
            hotkey={String(index + 1)}
            label={`/${name}`}
            onPress={() => pick(name)}
          />
        ))}
        <Button key="close" role="dismiss" plain dimColor label="×" onPress={close} />
      </Box>
    )
  })
}

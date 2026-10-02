import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

// The smart zone of which-skill's "Context hygiene": the gauge counts down from it.
const SMART_ZONE = 150_000

// The gauge's color by the share of the smart zone left, red at none.
const STOPS: [number, [number, number, number]][] = [
  [0, [224, 49, 49]],
  [0.25, [232, 89, 12]],
  [0.5, [208, 140, 0]],
  [1, [43, 147, 72]],
]

const tokens = atom({ plugin: 'smart-zone', key: 'tokens' } as const, null)

const tint = (left: number) => {
  const share = Math.min(1, Math.max(0, left / SMART_ZONE))
  const i = Math.max(1, STOPS.findIndex(([at]) => at >= share))
  const [from, low] = STOPS[i - 1]!
  const [to, high] = STOPS[i]!
  const t = (share - from) / (to - from)

  return `#${low.map((c, j) => Math.round(c + (high[j]! - c) * t).toString(16).padStart(2, '0')).join('')}`
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const { context } = await $.session.usage()
    await update($, tokens, () => context.tokens ?? null)

    return next(e)
  })

  on('session.measure', async ($, e, next) => {
    if (e.changed.includes('context')) {
      await update($, tokens, () => e.context.tokens ?? null)
    }

    return next(e)
  })

  on('session.end', async ($, e, next) => {
    if (e.reason === 'clear') {
      await update($, tokens, () => null)
    }

    return next(e)
  })

  on('ui.render', { component: 'SessionMode' }, async ($, e, next) => {
    const left = SMART_ZONE - ((await read($, tokens)) ?? 0)
    // The modes and what other mods draw in the footer come from beneath.
    const below = await next(e)
    const { Box, Text } = $.ui.resolve(e)

    return (
      <Box columnGap={1}>
        {below}
        <Text color={tint(left)}>🧠 {Math.round(left / 1000)}k</Text>
      </Box>
    )
  })
}

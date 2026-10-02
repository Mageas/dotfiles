import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

const TTL = 60 * 60 * 1000

const lastAt = atom({ plugin: 'cache-timer', key: 'lastAt' } as const, null)
const now = atom({ plugin: 'cache-timer', key: 'now' } as const, 0)

const color = (left: number) =>
  left <= 0 ? '#e03131' : left < 5 * 60_000 ? '#e8590c' : left < 15 * 60_000 ? '#d08c00' : '#2b9348'

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const tick = async () => {
      const t = await $.clock.now()
      await update($, now, () => t)
    }
    await tick()
    $.clock.every(20_000, () => void tick())

    return next(e)
  })

  // The last request of a main turn is the one that refreshed the cache.
  on('turn.complete', async ($, e, next) => {
    if (e.agentId === undefined) {
      const t = await $.clock.now()
      await update($, lastAt, () => t)
      await update($, now, () => t)
    }

    return next(e)
  })

  on('session.end', async ($, e, next) => {
    if (e.reason === 'clear') {
      await update($, lastAt, () => null)
    }

    return next(e)
  })

  on('ui.render', { component: 'SessionMode' }, async ($, e, next) => {
    const below = await next(e)
    const at = await read($, lastAt)
    if (at === null) return below

    const left = at + TTL - (await read($, now))
    const { Box, Text } = $.ui.resolve(e)

    return (
      <Box>
        {/* Braille blanks: the desktop footer ignores columnGap and trims spaces, non-breaking ones included. */}
        <Text color={color(left)}>⏱ {left > 0 ? `${Math.ceil(left / 60_000)}m` : 'cold'}{'\u2800'.repeat(2)}</Text>
        {below}
      </Box>
    )
  })
}

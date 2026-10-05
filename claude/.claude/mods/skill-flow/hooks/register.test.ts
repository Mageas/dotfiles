import { expect, test } from 'claude-code/testing'

test('notes a skill run without its predecessors in a set-up repo', async ($, on) => {
  on('skill.prompt', ($, e) => ({ text: 'BODY' }))
  on('session.root', () => ({ value: '/repo' }))
  on('fs.exists', () => ({ value: true }))

  const { text } = await $.skill.prompt({ skill: 'prototype', text: 'BODY' })

  expect(text.startsWith('<workflow-note>')).toBe(true)
  expect(text.endsWith('BODY')).toBe(true)
})

test('stays quiet once a predecessor ran', async ($, on) => {
  on('skill.prompt', ($, e) => ({ text: 'BODY' }))
  on('session.root', () => ({ value: '/repo' }))
  on('fs.exists', () => ({ value: true }))

  await $.skill.prompt({ skill: 'grill', text: 'BODY' })
  const { text } = await $.skill.prompt({ skill: 'prototype', text: 'BODY' })

  expect(text).toBe('BODY')
})

test('stays quiet in a repo that is not set up', async ($, on) => {
  on('skill.prompt', ($, e) => ({ text: 'BODY' }))
  on('session.root', () => ({ value: '/repo' }))
  on('fs.exists', () => ({ value: false }))

  const { text } = await $.skill.prompt({ skill: 'prototype', text: 'BODY' })

  expect(text).toBe('BODY')
})

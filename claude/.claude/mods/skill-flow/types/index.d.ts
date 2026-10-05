export type SkillRun = string

declare module 'claude-code' {
  interface PluginState {
    'skill-flow': { ran: SkillRun[] }
  }
}

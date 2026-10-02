export type Phase = string | null

declare module 'claude-code' {
  interface PluginState {
    'flow-band': { phase: Phase; isOpen: boolean }
  }
}

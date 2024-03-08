interface Window {
  systemPlatform?: 'win32' | 'darwin'
  isElectronNative?: boolean
  NERoom?: any,
  isWins32: boolean
  ipcRenderer?: {
    send: (channel: string, ...args: any[]) => void
    sendSync: (channel: string, ...args: any[]) => any
    invoke: (channel: string, ...args: any[]) => Promise<any>
    on: (channel: string, listener: (...args: any[]) => void) => void
    once: (channel: string, listener: (...args: any[]) => void) => void
    off: (channel: string, listener: (...args: any[]) => void) => void
    removeListener: (
      channel: string,
      listener: (...args: any[]) => void
    ) => void
    removeAllListeners: (channel?: string) => void
  }
}

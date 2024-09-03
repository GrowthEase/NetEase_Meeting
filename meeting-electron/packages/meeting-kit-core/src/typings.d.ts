declare module '*.jpg'
declare module '*.png'

interface Window {
  h5App?: boolean
  systemPlatform?: 'win32' | 'darwin'
  isElectronNative?: boolean
  isChildWindow?: boolean
  NERoom?: any
  electronLog?: (...params: any[]) => void
  isWins32: boolean
  webFrame?: {
    clearCache: () => void
  }
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

declare module '*.less' {
  const resource: { [key: string]: string }
  export = resource
}

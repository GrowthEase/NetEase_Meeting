declare module '*.jpg'
declare module '*.png'

type MarvelConfig = {
  marvelId: string
  sdkName: string
  sdkVersion: string
  userId: string
  deviceIdentifier: string
  appKey: string
}

interface Window {
  h5App?: boolean
  systemPlatform?: 'win32' | 'darwin' | 'linux'
  isElectronNative?: boolean
  isLocal?: boolean
  isChildWindow?: boolean
  NERoom?: any
  startMarvel?: (config: MarvelConfig) => void
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
  electronPopover: {
    show: (items: MenuProps['items']) => void
    hide: () => void
    update: (items: MenuProps['items']) => void
  }
}

declare module '*.less' {
  const resource: { [key: string]: string }
  export = resource
}

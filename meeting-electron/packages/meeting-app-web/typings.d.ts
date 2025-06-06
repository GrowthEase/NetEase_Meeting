declare module '*.css';
declare module '*.less';
declare module '*.png';
declare module '*.svg' {
  export function ReactComponent(
    props: React.SVGProps<SVGSVGElement>,
  ): React.ReactElement;
  const url: string;
  export default url;
}

interface Window {
  h5App?: boolean;
  systemPlatform?: 'win32' | 'darwin' | 'linux';
  isArm64: boolean;
  isElectronNative?: boolean;
  NERoom?: any;
  electronLog?: (...params: any[]) => void;
  isWins32: boolean;
  webFrame?: {
    clearCache: () => void;
  };
  eleProcess?: {
    argv: string[];
  };
  ipcRenderer?: {
    send: (channel: string, ...args: any[]) => void;
    sendSync: (channel: string, ...args: any[]) => any;
    invoke: (channel: string, ...args: any[]) => Promise<any>;
    on: (channel: string, listener: (...args: any[]) => void) => void;
    once: (channel: string, listener: (...args: any[]) => void) => void;
    off: (channel: string, listener: (...args: any[]) => void) => void;
    removeListener: (
      channel: string,
      listener: (...args: any[]) => void,
    ) => void;
    removeAllListeners: (channel?: string) => void;
  };
}

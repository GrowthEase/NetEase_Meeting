import { resources, defaultNS } from './i18n'

declare module 'i18next' {
  interface CustomTypeOptions {
    defaultNS: 'translation'
    resources: typeof resources['zh-CN']
  }
}

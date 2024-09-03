import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'

import zh from './zh'
import en from './en'
import ja from './ja'

export const resources = {
  'ja-JP': {
    translation: ja,
  },
  'en-US': {
    translation: en,
  },
  'zh-CN': {
    translation: zh,
  },
}

i18n.use(initReactI18next).init({
  resources,
  defaultNS: 'translation',
  fallbackLng: 'zh-CN',
  lng: 'zh-CN',
  debug: false,
  interpolation: {
    escapeValue: false, // not needed for react as it escapes by default
  },
})

export default i18n

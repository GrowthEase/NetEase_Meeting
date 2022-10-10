

import Vue from 'vue'
import VueI18n from 'vue-i18n'
import zh from './zh'
import education from './education'

Vue.use(VueI18n)

export default function (locale = 'zh') {
  const i18n = new VueI18n({
    locale,
    messages: {
      zh,
      edu: education,
    },
  })
  return i18n
}

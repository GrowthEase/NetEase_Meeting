// import '@/init-log';
import Vue from 'vue'
import App from './App.vue'
import store from './store'
import VTooltip from 'v-tooltip'
import VToast from './components/ui/Toast/index'
import vueI18n from './locale/i18n'
// @ts-ignore
import Roomkit from 'neroom-web-sdk'

Vue.use(VTooltip)
Vue.use(VToast)

const EventBus = new Vue()

Vue.config.productionTip = false
Vue.prototype.$EventBus = EventBus
Vue.prototype.$roomkit = new Roomkit()

const i18n = vueI18n('zh')

new Vue({
  store,
  i18n,
  render: (h) => h(App),
}).$mount('#app')

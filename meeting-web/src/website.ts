/*
 * @Description: 对外站点测试构建入口文件
 */
import Vue from 'vue'
import store from './store/index'
import NemeetingMain from './pages/main.vue'
import VTooltip from 'v-tooltip'
import VToast from './components/ui/Toast/index'
import router from './pages/router'
import VForm from '~/ui/form/v-form.vue'
import VFormItem from '~/ui/form/v-form-item.vue'
import VCheckbox from '~/ui/CheckBox.vue'
import vueI18n from './locale/i18n'
const i18n = vueI18n('zh')

Vue.use(VTooltip)
Vue.use(VToast)
Vue.component('v-form', VForm)
Vue.component('v-form-item', VFormItem)
Vue.component('v-check-box', VCheckbox)

const EventBus = new Vue()

Vue.config.productionTip = false
Vue.prototype.$EventBus = EventBus

new Vue({
  store,
  i18n,
  router,
  render: (h) => h(NemeetingMain),
}).$mount('#app')

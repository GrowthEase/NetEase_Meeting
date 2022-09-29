// import '@/init-log'
import Vue from 'vue'
import App from './App.vue'
import store from './store'
import VTooltip from 'v-tooltip'
import VToast from './components/ui/Toast/index'
import { LogName } from '@/libs/3rd/logStorage'
import {
  checkType,
  localIns,
  uploadLog,
  downloadLog,
  checkSystemRequirements,
} from './utils'
import BaseCustomBtnConfig from '../src/libs/custom-config/customButton'
import { defaultMenus, defaultMoreMenus } from './libs/enum'
import vueI18n from './locale/i18n'
import { Theme } from '@/types/index'
// @ts-ignore
import Roomkit from 'neroom-web-sdk'
;(window as any).store = store

Vue.use(VTooltip)
Vue.use(VToast)

Vue.config.productionTip = false

const EventBus = new Vue()

const roomkit: any = new Roomkit()
Vue.prototype.$roomkit = roomkit
/**
 * @description: 加载iconfont
 * @param {*} url
 * @param {*} callback
 * @return {*}
 */
function loadAsyncScript(url, callback?) {
  const script = document.createElement('script') as any
  script.type = 'text/javascript'
  if (script.readyState) {
    // 兼容IE浏览器
    // 脚本加载完成事件
    script.onreadystatechange = function () {
      if (script.readyState === 'complete' || script.readyState === 'loaded') {
        callback()
      }
    }
  } else {
    // Chrome, Safari, FireFox, Opera可执行
    // 脚本加载完成事件
    script.onload = function () {
      callback && callback()
    }
  }
  script.src = url //将src属性放在后面，保证监听函数能够起作用
  document.head.appendChild(script)
}

const actions = new Proxy<any>(
  {
    meeting: null,
    NEMeetingInfo: {},
    NESettingsService: {},
    historyMeeting: localIns.get('historyMeeting'),
    $toolBarList: null,
    $moreBarList: null,
    memberInfo: {},
    joinMemberInfo: {},
    globalEventListener: null,
    login: (obj, callback: Function = () => true) => {
      // 登陆
      EventBus.$emit('login', { obj: { ...obj, loginType: 1 }, callback })
    },
    loginWithNEMeeting: (
      account,
      password,
      callback: Function = () => true
    ) => {
      // 账密登陆
      const obj = {
        username: account,
        password,
      }
      EventBus.$emit('login', { obj: { ...obj, loginType: 2 }, callback })
    },
    addGlobalEventListener: (listeners) => {
      actions.globalEventListener = listeners
    },

    /**
     * 移除全局事件监听
     */
    removeGlobalEventListener: () => {
      actions.globalEventListener = null
      EventBus.$emit('removeGlobalEventListener')
    },
    loginWithSSOToken: (ssoToken, callback: Function = () => true) => {
      // SSO登陆
      const obj = {
        ssoToken,
      }
      EventBus.$emit('login', { obj: { ...obj, loginType: 3 }, callback })
    },
    anonymousJoinMeeting: function (obj, callback: Function = () => true) {
      // 加入
      this.setCustomList(obj)
        .then((data) => {
          EventBus.$emit('anonymousJoin', { obj: data, callback })
        })
        .catch((e) => {
          callback(e)
        })
    },
    create: function (obj, callback: Function = () => true) {
      // 创建
      actions
        .setCustomList(obj)
        .then((data) => {
          EventBus.$emit('create', { obj: data, callback })
        })
        .catch((e) => {
          callback(e)
        })
    },
    join: function (obj, callback: Function = () => true) {
      // 加入
      this.setCustomList(obj)
        .then((data) => {
          EventBus.$emit('join', { obj: data, callback })
        })
        .catch((e) => {
          callback(e)
        })
    },
    updateCustomList: function (obj, callback: Function = () => true) {
      // 动态更新列表
      this.setCustomList(obj)
        .then((data) => {
          EventBus.$emit('updateInitOptions', { obj: data, callback })
        })
        .catch((e) => {
          callback(e)
        })
    },
    setCustomList: async function (obj) {
      // 校验自定义真实性
      this.$toolBarList = new BaseCustomBtnConfig(
        checkType(obj.toolBarList, 'array') ? obj.toolBarList : defaultMenus,
        true
      )
      this.$moreBarList = new BaseCustomBtnConfig(
        checkType(obj.moreBarList, 'array')
          ? obj.moreBarList
          : defaultMoreMenus,
        false
      )
      await this.$toolBarList.checkList()
      await this.$moreBarList.checkList(this.$toolBarList.getList())
      const result = {
        ...obj,
        toolBarList: this.$toolBarList.getList(),
        moreBarList: this.$moreBarList.getList(),
      }
      return result
    },
    width: 0,
    height: 0,
    init: function (
      width = 0,
      height = 800,
      config = {
        appKey: '',
        // 宽 高 后续各项配置补充
        imPrivateConf: {}, // IM私有化配置
        neRtcServerAddresses: {}, // RTC私有化配置
        locale: 'zh',
        im: null,
      }
    ) {
      // Vue.use(VTooltip)
      // Vue.use(VToast);

      // Vue.config.productionTip = false
      if (!config || !config.appKey) {
        throw new Error('init failed: appKey is empty')
      }
      if (this.meeting) {
        return
      }
      EventBus.$on('NEMeetingInfo', (val) => {
        this.NEMeetingInfo = { ...this.NEMeetingInfo, ...val }
      })
      EventBus.$on('setHistoryMeetingItem', (val) => {
        this.historyMeeting = val
      })
      EventBus.$on('memberInfo', (val) => {
        this.memberInfo = { ...this.memberInfo, ...val }
      })
      EventBus.$on('joinMemberInfo', (val) => {
        this.joinMemberInfo = val
      })
      EventBus.$on('NESettingsService', (val) => {
        this.NESettingsService = { ...this.NESettingsService, ...val }
      })
      Vue.prototype.$EventBus = EventBus
      const i18n = vueI18n(config.locale || 'zh')
      this.meeting = new Vue({
        i18n,
        store,
        render: (h) => h(App),
      }).$mount('#ne-web-meeting')

      EventBus.$emit(
        'uploadNIMconf',
        checkType(config.imPrivateConf, 'object') ? config.imPrivateConf : {}
      )
      EventBus.$emit(
        'uploadNeRtcServerAddresses',
        checkType(config.neRtcServerAddresses, 'object')
          ? config.neRtcServerAddresses
          : {}
      )
      let tmpConfig: any = {}
      if (checkType(config, 'object')) {
        tmpConfig = config
      }
      actions.globalEventListener &&
        (tmpConfig.globalEventListener = actions.globalEventListener)
      EventBus.$emit('uploadInit', tmpConfig)
      this.width = width
      this.height = height
    },
    // 单词错了，记录一下，目前有客户在用，对外先别改了
    destory: function () {
      // 销毁
      this.width = 1
      this.height = 1
      if (this.meeting) {
        // store.dispatch('resetInfo')
        EventBus.$emit('beforeDestroy')
        this.meeting.$el.style.height = 0
        this.meeting.$el.innerHTML = ''
        EventBus.$off()
        this.meeting.$destroy()
        this.meeting = null
      }
    },
    destroy: function () {
      this.destory()
    },
    afterLeave: function (callback: Function = () => true) {
      // 离开前回调
      EventBus.$emit('afterLeave', callback)
    },
    // 订阅音频流
    async subscribeRemoteAudioStream(
      accountId,
      subscribeType,
      callback: Function = () => true
    ) {
      const obj = {
        accountId,
        subscribeType,
        callback,
      }
      if (
        !obj.accountId ||
        (!checkType(obj.accountId, 'string') &&
          !checkType(obj.accountId, 'number'))
      ) {
        obj.callback &&
          obj.callback(
            new Error(
              'errorCode: 300, please check your arguments contains accountId, type not string'
            )
          )
        return
      }
      console.log('订阅单人 %s', obj.subscribeType)
      await this.meeting.$children[0].$refs.login
        .subscribe('audio', obj.subscribeType, obj.accountId)
        .then(() => {
          obj.callback && obj.callback()
        })
        .catch((e) => {
          obj.callback && obj.callback(e)
        })
      // EventBus.$emit('subscribeRemoteAudioStream', obj)
    },
    // 订阅音频流(by list)
    async subscribeRemoteAudioStreams(
      accountId,
      subscribeType,
      callback: Function = () => true
    ) {
      const obj = {
        accountId,
        subscribeType,
        callback,
      }
      // EventBus.$emit('subscribeRemoteAudioStreams', obj)
      if (!obj.accountId || !checkType(obj.accountId, 'array')) {
        obj.callback &&
          obj.callback(
            new Error(
              'errorCode: 300, please check your arguments contains accountIds not array'
            )
          )
        return
      }
      if (checkType(obj.accountId, 'array') && obj.accountId.length === 0) {
        obj.callback &&
          obj.callback(
            new Error(
              'errorCode: 300, please check your arguments contains accountIds, the array is empty'
            )
          )
        return
      }
      console.log('订阅多人bylist %s', obj.subscribeType)
      await this.meeting.$children[0].$refs.login
        .subscribe('audio', obj.subscribeType, obj.accountId)
        .then(() => {
          obj.callback && obj.callback()
        })
        .catch((e) => {
          obj.callback && obj.callback(e)
        })
    },
    // 订阅全部音频流
    async subscribeAllRemoteAudioStreams(
      subscribeType,
      callback: Function = () => true
    ) {
      const obj = {
        subscribeType,
        callback,
      }
      // EventBus.$emit('subscribeAllRemoteAudioStreams', obj)
      console.log('订阅全部 %s', obj.subscribeType)
      await this.meeting.$children[0].$refs.login
        .subscribe('audio', obj.subscribeType)
        .then(() => {
          obj.callback && obj.callback()
        })
        .catch((e) => {
          obj.callback && obj.callback(e)
        })
    },
    // 获取历史会议信息
    async getHistoryMeetingItem(callback: Function = () => true) {
      callback && callback(this.historyMeeting)
      return this.historyMeeting
    },
    on(actionName: string, fu: Function) {
      if (!this.meeting) {
        throw new Error('please init first')
      }
      EventBus.$on(actionName, fu)
    },
    off(actionName: string, fu?: Function) {
      if (!actionName) {
        throw new Error('please add your actionName when you use off')
      }
      fu ? EventBus.$off(actionName, fu) : EventBus.$off(actionName)
    },
    setLocale(
      locale: string,
      data: {
        // 设置国际化
        [propName: string]: string
      }
    ) {
      if (!this.meeting) {
        throw new Error('please init first')
      }
      this.meeting.$i18n.setLocaleMessage(locale, data)
    },
    useLocale(locale: string) {
      if (!this.meeting) {
        throw new Error('please init first')
      }
      this.meeting.$i18n.locale = locale
    },
    setDefaultRenderMode(val: 'big' | 'small') {
      if (!this.meeting) {
        throw new Error('please init first')
      }
      EventBus.$emit('setDefaultRenderMode', val)
    },
    getIMInfo() {
      if (!this.meeting || !this.meeting?.$neMeeting) {
        throw new Error('please join first')
      }
      return this.meeting?.$neMeeting.imInfo
    },
    setSmallModeDom(val: string) {
      EventBus.$emit('setSmallModeDom', val)
    },
    async uploadLog(logNames?: LogName[], start?: number, end?: number) {
      return await uploadLog(logNames, start, end)
    },
    downloadLog(logNames?: LogName[], start?: number, end?: number) {
      downloadLog(logNames, start, end)
    },
    checkSystemRequirements() {
      return checkSystemRequirements()
    },
    setTheme(data: Theme) {
      EventBus.$emit('setTheme', data)
    },
    resetTheme() {
      EventBus.$emit('resetTheme')
    },
    getLayout() {
      if (!this.meeting) {
        return null
      }
      if (!this.meeting.$store.state.canvasInfo) {
        if (
          !(this.meeting.$children && this.meeting.$children.length > 0) ||
          !(
            this.meeting.$children[0].$children &&
            this.meeting.$children[0].$children.length > 0
          )
        ) {
          // 元素未渲染
          return null
        }
        console.log('未获渲染元素')
        return this.meeting.$children[0].$children[0].getLayout()
      }
      return this.meeting.$store.state.canvasInfo
    },
    reuseIM(im: any) {
      return roomkit.reuseIM(im)
    },
    setScreenSharingSourceId(id: string) {
      if (!id) {
        console.log('set sourceId failed ', id)
      }
      EventBus.$emit('setScreenSharingSourceId', id)
    },
    enableScreenShare(enable) {
      EventBus.$emit('enableShareScreen', enable)
    },
  },
  {
    get: function (target, propKey) {
      return target[propKey]
    },
    set: function (target, propKey, value) {
      switch (propKey) {
        case 'width':
          EventBus.$emit('setWidth', value)
          break
        case 'height':
          EventBus.$emit('setHeight', value)
          break
        default:
          break
      }
      target[propKey] = value
      return true
    },
  }
)
loadAsyncScript('https://at.alicdn.com/t/font_2183559_zbxov2d0djl.js')

export { actions }

export default actions

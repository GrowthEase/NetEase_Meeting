import React from 'react'
import ReactDOM from 'react-dom'
import AppH5 from './AppH5'
import { GlobalContextProvider, MeetingInfoContextProvider } from './store'
import './index.less'
import NERoom from 'neroom-web-sdk'
import Eventemitter from 'eventemitter3'
import NEMeetingService from './services/NEMeeting'
import { createMeetingInfoFactory } from './services'
import Auth from './components/Auth'
import { UserEventType } from './types/innerType'
import {
  CreateOptions,
  JoinOptions,
  LoginOptions,
  NEMeeting,
  NEMeetingRole,
  NEMeetingKit as NEMeetingKitInterface,
  NEMeetingInitConfig,
  EventName,
} from './types'
import { NEMeetingLanguage } from './types/type'
import i18n from './locales/i18n'
import './assets/font_2183559_e7ne6iaqsse.js'
import { getDefaultLanguage } from './utils'
import { Logger } from './utils/Logger'
// import { LogName } from './utils/logStorage'
// import { downloadLog, uploadLog } from './utils'
// 入参
interface NEMeetingKitProps {
  appKey: string
  height: number
  width: number
  logger: Logger
  neMeeting: NEMeetingService
  meetingServerDomain?: string
}
const eventEmitter = new Eventemitter()
// 外部用户监听使用
const outEventEmitter = new Eventemitter()

// 代理 NERoomNode 对象
function proxyNERoomNode(targetObj, targetKey: string) {
  function proxyNERoomNodeListener(targetKey, fnName, fn) {
    // @ts-ignore
    window.ipcRenderer.on(
      `NERoomNodeListenerProxy-${targetKey}-${fnName}`,
      (_, data) => {
        fn(...data)
      }
    )
  }
  if (typeof targetObj !== 'object') {
    return targetObj
  }
  return new Proxy(targetObj, {
    get(target, prop) {
      if (typeof prop === 'symbol') {
        return target[prop]
      }
      if (target[prop] === '__FUNCTION__') {
        return function (...args) {
          args.forEach((arg, index) => {
            if (arg instanceof Array) {
              // TODO: 递归处理
            } else if (arg instanceof HTMLElement) {
              args[index] = {}
            } else if (typeof arg === 'object') {
              const obj = {}
              for (const key in arg) {
                const element = arg[key]
                if (typeof element === 'function') {
                  obj[key] = '__LISTENER_FUNCTION__'
                  proxyNERoomNodeListener(targetKey, key, element)
                } else {
                  obj[key] = element
                }
              }
              args[index] = obj
            }
          })
          // @ts-ignore
          const res = window.ipcRenderer.sendSync('NERoomNodeProxyMethod', {
            target: targetKey,
            key: prop,
            args,
          })
          if (res.promise) {
            return res.promise === 'resolve'
              ? Promise.resolve(res.value)
              : Promise.reject(res.value)
          } else {
            return proxyNERoomNode(res.value, `${targetKey}-${prop}`)
          }
        }
      } else {
        // @ts-ignore
        const res = window.ipcRenderer.sendSync('NERoomNodeProxyProperty', {
          target: targetKey,
          key: prop,
        })
        return proxyNERoomNode(res.value, `${targetKey}-${prop}`)
      }
    },
  })
}

let roomkit
// @ts-ignore
if (window.NERoomNode) {
  // @ts-ignore
  const neroom = window.ipcRenderer.sendSync('NERoomNodeProxyInit')
  roomkit = proxyNERoomNode(neroom, 'neroom')
  // roomkit = new window.NERoomNode()
} else {
  roomkit = NERoom.getInstance()
}

const joinLoading = undefined

// 兼容老的locale设置方法
const LanguageMap = {
  zh: 'zh-CN',
  en: 'en-US',
  ja: 'ja-JP',
}

function getLanguage(locale: string): 'zh-CN' | 'en-US' | 'ja-JP' {
  return LanguageMap[locale] || getDefaultLanguage()
}
/**
 * @description: 加载iconfont
 * @param {*} url
 * @param {*} callback
 * @return {*}
 */
function loadAsyncScript(url: string, callback?: () => void) {
  const script = document.createElement('script') as any
  script.type = 'text/javascript'
  if (script.readyState) {
    // 兼容IE浏览器
    // 脚本加载完成事件
    script.onreadystatechange = function () {
      if (script.readyState === 'complete' || script.readyState === 'loaded') {
        callback && callback()
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
const render = async (
  view: HTMLElement,
  props: NEMeetingKitProps,
  callback?: () => void
) => {
  const neMeeting = props.neMeeting
  await neMeeting.init({
    ...props,
    appKey: props.appKey,
    meetingServerDomain: props.meetingServerDomain,
  })
  let globalConfig
  try {
    globalConfig = await neMeeting.getGlobalConfig()
  } catch (e) {
    console.warn('getGlobalConfig', e)
  }
  ReactDOM.render(
    <GlobalContextProvider
      outEventEmitter={outEventEmitter}
      eventEmitter={eventEmitter}
      neMeeting={neMeeting}
      joinLoading={joinLoading}
      logger={props.logger}
      globalConfig={globalConfig}
    >
      <MeetingInfoContextProvider
        memberList={[]}
        meetingInfo={createMeetingInfoFactory()}
      >
        <Auth renderCallback={callback} />
        <AppH5 width={props.width} height={props.height} />
        {/*{process.env.PLATFORM === ('h5' as 'web' | 'h5') ? (*/}
        {/*  <AppH5 width={props.width} height={props.height} />*/}
        {/*) : (*/}
        {/*  <App width={props.width} height={props.height} />*/}
        {/*)}*/}
      </MeetingInfoContextProvider>
    </GlobalContextProvider>,
    view
  )
}
const NEMeetingKit: NEMeetingKitInterface = new Proxy<any>(
  {
    view: null,
    toolBarList: [],
    moreBarList: [],
    joinMemberInfo: {},
    // remoteMemberList: [],
    // localMember: {},
    neMeeting: null,
    roomkit: null,
    globalEventListener: null,
    isInitialized: false,
    login: (options: LoginOptions, callback: () => void) => {
      console.log('login', options)
      eventEmitter.emit(UserEventType.Login, { options, callback })
    },
    logout: (callback: () => void) => {
      eventEmitter.emit(UserEventType.Logout, { callback })
    },
    loginWithPassword: (
      options: { username: string; password: string },
      callback: () => void
    ) => {
      console.log('loginWithPassword', options)
      eventEmitter.emit(UserEventType.LoginWithPassword, { options, callback })
    },

    addGlobalEventListener: (listeners) => {
      NEMeetingKit.globalEventListener = listeners
    },
    /**
     * 移除全局事件监听
     */
    removeGlobalEventListener: () => {
      NEMeetingKit.globalEventListener = null
      roomkit.removeGlobalEventListener()
    },
    init: (
      width = 0,
      height = 0,
      config: NEMeetingInitConfig,
      callback?: () => void
    ): void => {
      if (NEMeetingKit.isInitialized) {
        console.warn('已初始化过')
        return
      }
      if (!config || !config.appKey) {
        throw new Error('init failed: appKey is empty')
      }
      const view = document.getElementById('ne-web-meeting')
      if (!view) {
        throw new Error('init failed: not found #ne-web-meeting')
      }
      const debug = config.debug !== false
      const logger = new Logger('Meeting-NeMeeting', debug)
      const neMeeting = new NEMeetingService({ roomkit, eventEmitter, logger })
      NEMeetingKit.roomkit = roomkit
      NEMeetingKit.neMeeting = neMeeting
      const locale = getLanguage(config.locale || 'zh')
      i18n.changeLanguage(locale)
      neMeeting.switchLanguage(locale)
      // @ts-ignore
      NEMeetingKit.view = view
      render(
        view,
        {
          width,
          height,
          neMeeting,
          logger,
          ...config,
          appKey: config.appKey,
          meetingServerDomain: config.meetingServerDomain,
        },
        callback
      )
      if (NEMeetingKit.globalEventListener) {
        roomkit.addGlobalEventListener(NEMeetingKit.globalEventListener)
      }

      NEMeetingKit.isInitialized = true
    },
    // 修改为静态方法，不需要初始化调用
    checkSystemRequirements: () => {
      return NERoom?.checkSystemRequirements()
    },
    anonymousJoinMeeting: (
      options: JoinOptions,
      callback: (error?: any) => void
    ) => {
      eventEmitter.emit(UserEventType.AnonymousJoinMeeting, {
        options,
        callback,
      })
    },
    create: (options: CreateOptions, callback: (error?: any) => void) => {
      eventEmitter.emit(UserEventType.CreateMeeting, { options, callback })
    },
    join: (options: JoinOptions, callback: (error?: any) => void) => {
      eventEmitter.emit(UserEventType.JoinMeeting, { options, callback })
    },
    afterLeave: (callback: () => void) => {
      !!callback &&
        eventEmitter.emit(UserEventType.SetLeaveCallback, { callback })
    },
    destroy: () => {
      console.log('destroy')
      eventEmitter.emit('destroy')
      // @ts-ignore
      if (!window.ipcRenderer) {
        NEMeetingKit.view &&
          ReactDOM.unmountComponentAtNode(NEMeetingKit.view as HTMLElement)
      }
      NEMeetingKit.view = null
      NEMeetingKit.neMeeting?.release()
      NEMeetingKit.neMeeting = null
      NEMeetingKit.isInitialized = false
      outEventEmitter.removeAllListeners()
      // @ts-ignore
      if (window.NERoomNode) {
        window.location.reload()
      }
    },
    on: (eventName: EventName, callback: (...args: any) => void) => {
      outEventEmitter.on(eventName, callback)
    },

    off: (eventName: EventName, callback?: (...data: any) => void) => {
      if (!eventName) {
        throw new Error('please add your eventName when you use off')
      }
      callback
        ? outEventEmitter.off(eventName, callback)
        : outEventEmitter.off(eventName)
    },
    NEMeetingInfo: { isHost: false, isLocked: false, meetingId: '' },
    enableScreenShare(enable: boolean): void {
      eventEmitter.emit('enableShareScreen', enable)
    },
    setDefaultRenderMode(mode: 'big' | 'small'): void {
      eventEmitter.emit('setDefaultRenderMode', mode)
    },
    setScreenSharingSourceId(sourceId: string): void {
      if (!sourceId) {
        console.log('set sourceId failed ', sourceId)
      }
      eventEmitter.emit('setScreenSharingSourceId', sourceId)
    },
    switchLanguage(language: NEMeetingLanguage): void {
      const languageMap = {
        [NEMeetingLanguage.CHINESE]: 'zh-CN',
        [NEMeetingLanguage.ENGLISH]: 'en-US',
        [NEMeetingLanguage.JAPANESE]: 'ja-JP',
      }
      const locale = (languageMap[language] || 'en-US') as
        | 'zh-CN'
        | 'en-US'
        | 'ja-JP'
      i18n.changeLanguage(locale)
      NEMeetingKit.neMeeting?.switchLanguage(locale)
    },
    getIMInfo() {
      if (!NEMeetingKit.neMeeting?.roomContext) {
        throw new Error('please join first')
      }
      return NEMeetingKit.neMeeting.imInfo
    },
    reuseIM(im: any) {
      return roomkit.reuseIM(im)
    },
    // uploadLog(
    //   // logNames?: LogName[],
    //   start?: number,
    //   end?: number
    // ): Promise<any[]> {
    //   // return uploadLog(logNames, start, end)
    //   return Promise.resolve([])
    // },
    // downloadLog(
    //   // logNames?: LogName[],
    //   start?: number,
    //   end?: number
    // ): Promise<void> {
    //   // return downloadLog(logNames, start, end)
    //   return Promise.resolve()
    // },
  },

  {
    get: function (target, propKey) {
      switch (propKey) {
        case 'accountInfo':
          return NEMeetingKit.neMeeting?.accountInfo
        case 'memberInfo':
          let memberInfo: any = null
          const member = NEMeetingKit.neMeeting?.roomContext?.localMember
          if (member) {
            memberInfo = { ...member, role: member.role?.name }
          }
          return memberInfo
        case 'joinMemberInfo':
          const remoteMemberList =
            NEMeetingKit.neMeeting?.roomContext?.remoteMembers
          const localMember = NEMeetingKit.neMeeting?.roomContext?.localMember
          const joinMemberInfo: any = {}
          if (remoteMemberList && Array.isArray(remoteMemberList)) {
            remoteMemberList.forEach((member) => {
              if (member.isInRtcChannel || member.uuid === localMember?.uuid) {
                joinMemberInfo[member.uuid] = {
                  ...member,
                  role: member.role?.name,
                }
              }
            })
          }
          if (localMember) {
            joinMemberInfo[localMember.uuid] = {
              ...localMember,
              role: localMember.role?.name,
            }
          }
          return joinMemberInfo
        case 'meetingInfo':
        case 'NEMeetingInfo': {
          const meeting = NEMeetingKit.neMeeting?.getMeetingInfo()
          if (meeting) {
            const { meetingInfo } = meeting
            return {
              isHost: meetingInfo.hostUuid
                ? meetingInfo.hostUuid === meetingInfo.localMember.uuid
                : false,
              isLocked: meetingInfo.isLocked,
              meetingId: meetingInfo.meetingId,
              meetingNum: meetingInfo.meetingNum,
              password: meetingInfo.password,
              shortMeetingNum: meetingInfo.shortMeetingNum,
              sipId: meetingInfo.sipCid,
            }
          } else {
            return {}
          }
        }
        default:
          return target[propKey]
      }
    },
  }
)
// loadAsyncScript('//at.alicdn.com/t/font_2183559_zbxov2d0djl.js')

export default { actions: NEMeetingKit }

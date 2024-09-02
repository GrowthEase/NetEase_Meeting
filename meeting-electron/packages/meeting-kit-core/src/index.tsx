import Eventemitter from 'eventemitter3'
import './assets/iconfont.js'
import Auth from './components/Auth'
import BaseCustomBtnConfig from './components/common/CustomButton/customButton'
import AppH5 from './components/h5/Meeting'
import App from './components/web/Meeting'
import './index.less'
import i18n from './locales/i18n'
import { NERoomMember } from 'neroom-types'
import {
  createMeetingInfoFactory,
  defaultMenus,
  defaultMenusInH5,
  defaultMoreMenus,
  defaultMoreMenusInH5,
} from './services'
import NEMeetingService from './services/NEMeeting'
import NEMeetingInviteService from './services/NEMeetingInviteService'
import { GlobalContextProvider, MeetingInfoContextProvider } from './store'
import { ChatRoomContextProvider } from './hooks/useChatRoom'
import {
  CreateOptions,
  EventName,
  JoinOptions,
  LoginOptions,
  NEMeetingInitConfig,
  NEMeetingKit as NEMeetingKitInterface,
} from './types'
import { ServerError, UserEventType } from './types/innerType'
import { NEError, NEMeetingInfo, NEMeetingLanguage } from './types/type'
import { checkType, getDefaultLanguage } from './utils'
import { Logger } from './utils/Logger'
import React from 'react'
import { createRoot } from 'react-dom/client.js'
import dayjs from 'dayjs'
import timezone from 'dayjs/plugin/timezone'
import localeData from 'dayjs/plugin/localeData'
import weekday from 'dayjs/plugin/weekday'
import weekOfYear from 'dayjs/plugin/weekOfYear'
import utc from 'dayjs/plugin/utc'
import { LANGUAGE_KEY } from './config'

dayjs.extend(weekday)
dayjs.extend(localeData)
dayjs.extend(weekOfYear)
dayjs.extend(utc)
dayjs.extend(timezone)

// import { LogName } from './utils/logStorage'
// import { downloadLog, uploadLog } from './utils'
// 入参
interface NEMeetingKitProps {
  appKey: string
  height: number
  width: number
  logger: Logger
  neMeeting: NEMeetingService
  inviteService: NEMeetingInviteService
  meetingServerDomain?: string
}
const eventEmitter = new Eventemitter()
// 外部用户监听使用
const outEventEmitter = new Eventemitter()

let roomkit

const joinLoading = undefined

// 兼容老的locale设置方法
const LanguageMap = {
  zh: 'zh-CN',
  en: 'en-US',
  ja: 'ja-JP',
  'zh-CN': 'zh-CN',
  'en-US': 'en-US',
  'ja-JP': 'ja-JP',
}

function getLanguage(locale: string): 'zh-CN' | 'en-US' | 'ja-JP' {
  return LanguageMap[locale] || getDefaultLanguage()
}

// 设置自定义菜单配置
const setCustomList = async (obj: JoinOptions) => {
  const isH5 = window.h5App
  // 工具栏菜单
  const _defaultMenus = isH5 ? defaultMenusInH5 : defaultMenus
  const _customMenus = checkType(obj.toolBarList, 'array')
    ? obj.toolBarList
    : _defaultMenus
  const _toolBarList = new BaseCustomBtnConfig(_customMenus || [], true)
  // 更多项菜单
  const _defaultMoreMenus = isH5 ? defaultMoreMenusInH5 : defaultMoreMenus
  const _customMoreMenus = checkType(obj.moreBarList, 'array')
    ? obj.moreBarList
    : _defaultMoreMenus
  const _moreBarList = new BaseCustomBtnConfig(_customMoreMenus || [], false)

  // 检验自定义菜单格式
  await _toolBarList.checkList()
  await _moreBarList.checkList(_toolBarList.getList())
  const result = {
    ...obj,
    toolBarList: _toolBarList.getList(),
    moreBarList: _moreBarList.getList(),
  }

  return result
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

  const root = createRoot(view)

  root.render(
    <GlobalContextProvider
      outEventEmitter={outEventEmitter}
      eventEmitter={eventEmitter}
      neMeeting={neMeeting}
      inviteService={props.inviteService}
      joinLoading={joinLoading}
      logger={props.logger}
      globalConfig={globalConfig}
    >
      <MeetingInfoContextProvider
        memberList={[]}
        meetingInfo={createMeetingInfoFactory()}
      >
        <ChatRoomContextProvider>
          <Auth renderCallback={callback} />
          {window.h5App ? (
            <AppH5 width={props.width} height={props.height} />
          ) : (
            <App width={props.width} height={props.height} />
          )}
        </ChatRoomContextProvider>
      </MeetingInfoContextProvider>
    </GlobalContextProvider>
  )
}

const NEMeetingKit: NEMeetingKitInterface = new Proxy<NEMeetingKitInterface>(
  {
    view: null,
    toolBarList: [],
    moreBarList: [],
    joinMemberInfo: {},
    // remoteMemberList: [],
    // localMember: {},
    neMeeting: undefined,
    inviteService: undefined,
    roomkit: undefined,
    globalEventListener: null,
    isInitialized: false,
    login: (options: LoginOptions, callback: () => void) => {
      console.log('login', options)
      outEventEmitter.emit(UserEventType.Login, { options, callback })
    },
    logout: (callback: () => void) => {
      outEventEmitter.emit(UserEventType.Logout, { callback })
    },
    afterLeaveCallback: null,
    loginWithPassword: (
      options: { username: string; password: string },
      callback: () => void
    ) => {
      console.log('loginWithPassword', options)
      outEventEmitter.emit(UserEventType.LoginWithPassword, {
        options,
        callback,
      })
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
    /**
     * 添加会议状态变更事件监听
     * @param listener NEMeetingStatusListener
     */
    addMeetingStatusListener: (listener) => {
      if (listener?.onMeetingStatusChanged) {
        outEventEmitter.on(
          UserEventType.onMeetingStatusChanged,
          listener.onMeetingStatusChanged
        )
      }
    },
    removeMeetingStatusListener: () => {
      outEventEmitter.off(UserEventType.onMeetingStatusChanged)
    },
    init: (
      width = 0,
      height = 0,
      config: NEMeetingInitConfig,
      callback?: (e?: Error) => void
    ): void => {
      if (NEMeetingKit.isInitialized) {
        console.warn('已初始化过')
        return
      }

      if (window.isElectronNative) {
        roomkit = new window.NERoom()
      } else {
        roomkit = window.NERoom?.getInstance()
      }

      if (!config || !config.appKey) {
        callback?.(new Error('init failed: appKey is empty'))
      }

      const view = document.getElementById('ne-web-meeting')

      if (!view) {
        callback?.(new Error('init failed: not found #ne-web-meeting'))
      }

      const debug = config.debug !== false
      const logger = new Logger('Meeting-NeMeeting', debug)

      if (NEMeetingKit.globalEventListener) {
        roomkit.addGlobalEventListener(NEMeetingKit.globalEventListener)
      }

      const neMeeting = new NEMeetingService({
        roomkit,
        eventEmitter,
        outEventEmitter,
        logger,
      })

      NEMeetingKit.roomkit = roomkit
      NEMeetingKit.neMeeting = neMeeting
      const inviteService = new NEMeetingInviteService({
        neMeeting,
        eventEmitter: outEventEmitter,
      })

      NEMeetingKit.inviteService = inviteService
      const locale = getLanguage(config.locale || 'zh-CN')

      i18n.changeLanguage(locale)
      neMeeting.switchLanguage(locale)
      NEMeetingKit.view = view
      render(
        view as HTMLElement,
        {
          width,
          height,
          neMeeting,
          inviteService,
          logger,
          ...config,
          appKey: config.appKey,
          meetingServerDomain: config.meetingServerDomain,
        },
        callback
      )
      outEventEmitter?.on('roomEnded', (reason: number) => {
        NEMeetingKit.afterLeaveCallback?.(reason)
      })
      NEMeetingKit.isInitialized = true
    },
    // 修改为静态方法，不需要初始化调用
    checkSystemRequirements: () => {
      return window.NERoom?.checkSystemRequirements?.()
    },
    anonymousJoinMeeting: (
      options: JoinOptions,
      callback: (error?: ServerError | Error) => void
    ) => {
      setCustomList(options)
        .then((_options) => {
          outEventEmitter.emit(UserEventType.AnonymousJoinMeeting, {
            options: _options,
            callback,
          })
        })
        .catch((e) => {
          callback?.(e)
        })
    },
    create: (options: CreateOptions, callback: (error?: NEError) => void) => {
      setCustomList(options)
        .then((_options) => {
          outEventEmitter.emit(UserEventType.CreateMeeting, {
            options: _options,
            callback,
          })
        })
        .catch((e) => {
          console.log('eee>>', e)
          callback?.(e)
        })
    },
    join: (options: JoinOptions, callback: (error?: NEError) => void) => {
      setCustomList(options)
        .then((_options) => {
          outEventEmitter.emit(UserEventType.JoinMeeting, {
            options: _options,
            callback,
          })
        })
        .catch((e) => {
          callback?.(e)
        })
    },
    getRoomCloudRecordList: async (roomArchiveId: number) => {
      return NEMeetingKit.neMeeting?.getRoomCloudRecordList(roomArchiveId)
    },
    afterLeave: (callback: (reason: number) => void) => {
      NEMeetingKit.afterLeaveCallback = callback
    },
    leaveMeeting: (finish: boolean, callback?: (e?: Error) => void) => {
      if (finish) {
        outEventEmitter.emit(UserEventType.EndMeeting, callback)
      } else {
        outEventEmitter.emit(UserEventType.LeaveMeeting, callback)
      }
    },
    updateMeetingInfo: (meetingInfo: Partial<NEMeetingInfo>) => {
      outEventEmitter.emit(UserEventType.UpdateMeetingInfo, {
        ...meetingInfo,
      })
    },
    getReducerMeetingInfo: (callback: (data) => void) => {
      outEventEmitter.emit(UserEventType.GetReducerMeetingInfo, callback)
    },
    destroy: () => {
      eventEmitter.emit('destroy')

      NEMeetingKit.afterLeaveCallback = null
      NEMeetingKit.view = null
      NEMeetingKit.neMeeting?.release()
      NEMeetingKit.inviteService?.destroy()
      NEMeetingKit.inviteService = undefined
      NEMeetingKit.neMeeting = undefined
      NEMeetingKit.isInitialized = false
      outEventEmitter.removeAllListeners()
    },
    on: (eventName: EventName, callback: (...args) => void) => {
      outEventEmitter.on(eventName, callback)
    },

    off: (eventName: EventName, callback?: (...data) => void) => {
      if (!eventName) {
        throw new Error('please add your eventName when you use off')
      }

      callback
        ? outEventEmitter.off(eventName, callback)
        : outEventEmitter.off(eventName)
    },
    NEMeetingInfo: {
      isHost: false,
      isLocked: false,
      meetingId: '',
      meetingNum: '',
    },
    enableScreenShare(enable: boolean): void {
      outEventEmitter.emit('enableShareScreen', enable)
    },
    setDefaultRenderMode(mode: 'big' | 'small'): void {
      outEventEmitter.emit('setDefaultRenderMode', mode)
    },
    setScreenSharingSourceId(sourceId: string): void {
      if (!sourceId) {
        console.log('set sourceId failed ', sourceId)
      }

      outEventEmitter.emit('setScreenSharingSourceId', sourceId)
    },
    switchLanguage(language: NEMeetingLanguage): void {
      if (language === NEMeetingLanguage.AUTOMATIC) {
        return
      }

      const languageMap = {
        [NEMeetingLanguage.CHINESE]: 'zh-CN',
        [NEMeetingLanguage.ENGLISH]: 'en-US',
        [NEMeetingLanguage.JAPANESE]: 'ja-JP',
      }
      const locale = (languageMap[language] || 'en-US') as
        | 'zh-CN'
        | 'en-US'
        | 'ja-JP'

      localStorage.setItem(LANGUAGE_KEY, locale)

      i18n.changeLanguage(locale)

      NEMeetingKit.neMeeting?.switchLanguage(locale)
    },
    getIMInfo() {
      if (!NEMeetingKit.neMeeting?.roomContext) {
        throw new Error('please join first')
      }

      return NEMeetingKit.neMeeting.imInfo
    },
    reuseIM(im) {
      return roomkit.reuseIM(im)
    },
  },

  {
    get: function (target, propKey) {
      switch (propKey) {
        case 'accountInfo':
          return NEMeetingKit.neMeeting?.accountInfo
        case 'memberInfo': {
          let memberInfo:
            | NERoomMember
            | {
                role: string
              }
            | null = null
          const member = NEMeetingKit.neMeeting?.roomContext?.localMember

          if (member) {
            memberInfo = { ...member, role: member.role?.name }
          }

          return memberInfo
        }

        case 'joinMemberInfo': {
          const remoteMemberList =
            NEMeetingKit.neMeeting?.roomContext?.remoteMembers
          const localMember = NEMeetingKit.neMeeting?.roomContext?.localMember
          const joinMemberInfo = {}

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
        }

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
              isInWaitingRoom: !!meetingInfo.inWaitingRoom,
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

export default { actions: NEMeetingKit }

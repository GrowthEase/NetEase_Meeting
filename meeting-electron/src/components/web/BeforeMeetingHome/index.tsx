import React, { useEffect, useMemo, useRef, useState } from 'react'

import CloseOutlined from '@ant-design/icons/CloseOutlined'
import EditOutlined from '@ant-design/icons/EditOutlined'
import ExclamationCircleFilled from '@ant-design/icons/ExclamationCircleFilled'
import {
  Badge,
  Button,
  Dropdown,
  Input,
  MenuProps,
  notification,
  Spin,
  Tag,
} from 'antd'
import dayjs from 'dayjs'
import { useTranslation } from 'react-i18next'
import MeetingPopover from '../../common/Popover'

import EmptyScheduleMeetingImg from '../../../assets/empty-schedule-meeting.png'
import FeedbackImg from '../../../assets/feedback.png'
import LightFeedbackImg from '../../../assets/light-feedback.png'
import NEMeetingKit from '../../../index'
import BeforeMeetingHomeHeader from '../../../assets/before-meeting-home-header.png'
import {
  copyElementValue,
  getMeetingDisplayId,
  getCurrentDateTime,
  formatTimeWithLanguage,
} from '../../../utils'
import AboutModal from '../BeforeMeetingModal/AboutModal'
import HistoryMeetingModal from '../BeforeMeetingModal/HistoryMeetingModal'
import ImmediateMeetingModal from '../BeforeMeetingModal/ImmediateMeetingModal'
import JoinMeetingModal from '../BeforeMeetingModal/JoinMeetingModal'
import ScheduleMeetingModal from '../BeforeMeetingModal/ScheduleMeetingModal'
import UpdateUserNicknameModal from '../BeforeMeetingModal/UpdateUserNicknameModal'
import FeedbackModal from '../Feedback/FeedBackModal'
import Setting from '../Setting'
import './index.less'

import Eventemitter from 'eventemitter3'
import {
  LOCALSTORAGE_INVITE_MEETING_URL,
  LOCALSTORAGE_USER_INFO,
  NOT_FIRST_LOGIN,
  PRIVATE_CONFIG,
} from '../../../../app/src/config'

import { NEPreviewController, NERoomService } from 'neroom-web-sdk'
import { NECustomSessionMessage } from 'neroom-web-sdk/dist/types/types/messageChannelService'
import qs from 'qs'
import { IPCEvent } from '../../../../app/src/types'
import usePostMessageHandle from '../../../hooks/usePostMessagehandle'
import eleIpc from '../../../services/electron/index'
import {
  CreateMeetingResponse,
  CreateOptions,
  EventType,
  GetMeetingConfigResponse,
  JoinOptions,
  MeetingRepeatType,
  MeetingSetting,
} from '../../../types'
import {
  MoreBarList,
  NEMeetingInviteInfo,
  NEMeetingInviteStatus,
  NEMeetingPrivateConfig,
  NEMeetingStatus,
} from '../../../types/type'
import { closeWindow, getWindow, openWindow } from '../../../utils/windowsProxy'
import UserAvatar from '../../common/Avatar'
import Modal from '../../common/Modal'
import MeetingNotification from '../../common/Notification'
import PCTopButtons from '../../common/PCTopButtons'
import Toast from '../../common/toast'
import ImageCropModal from '../BeforeMeetingModal/ImageCropModal'
import NotificationListModal from '../BeforeMeetingModal/NotificationListModal'
import { SettingTabType } from '../Setting/Setting'
import { parsePrivateConfig } from '../../../../src/utils'
import NPSModal from '../NPS/NPSModal'
import classNames from 'classnames'

const eventEmitter = new Eventemitter()

let appKey = ''
let userUuid = ''
let userToken = ''
const domain = process.env.MEETING_DOMAIN

const LOCAL_STORAGE_KEY = 'ne-meeting-recent-meeting-list'

type MeetingListGroupByDate = {
  date: string
  list: CreateMeetingResponse[]
}[]

interface BeforeMeetingHomeProps {
  onLogout: () => void
}

const BeforeMeetingHome: React.FC<BeforeMeetingHomeProps> = ({ onLogout }) => {
  const { t, i18n: i18next } = useTranslation()

  const i18n = {
    appTitle: t('appTitle'),
    immediateMeeting: t('immediateMeeting'),
    sponsorMeeting: t('sponsorMeeting'),
    joinMeeting: t('meetingJoin'),
    scheduleMeeting: t('scheduleMeeting'),
    scheduleMeetingSuccess: t('scheduleMeetingSuccess'),
    scheduleMeetingFail: t('scheduleMeetingFail'),
    editScheduleMeetingSuccess: t('editScheduleMeetingSuccess'),
    editScheduleMeetingFail: t('editScheduleMeetingFail'),
    cancelScheduleMeetingSuccess: t('cancelScheduleMeetingSuccess'),
    tokenExpired: t('tokenExpired'),
    cancelScheduleMeetingFail: t('cancelScheduleMeetingFail'),
    updateUserNicknameSuccess: t('updateUserNicknameSuccess'),
    updateUserNicknameFail: t('updateUserNicknameFail'),
    emptyScheduleMeeting: t('emptyScheduleMeeting'),
    meetingId: t('meetingId'),
    weekdays: [
      t('globalSunday'),
      t('globalMonday'),
      t('globalTuesday'),
      t('globalWednesday'),
      t('globalThursday'),
      t('globalFriday'),
      t('globalSaturday'),
    ],
    month: t('globalMonth'),
    historyMeeting: t('historyMeeting'),
    currentVersion: t('currentVersion'),
    personalMeetingNum: t('personalMeetingNum'),
    personalShortMeetingNum: t('personalShortMeetingNum'),
    internalUse: t('internalOnly'),
    feedback: t('feedback'),
    about: t('about'),
    logout: t('logout'),
    logoutConfirm: t('logoutConfirm'),
    today: t('today'),
    tomorrow: t('tomorrow'),
    join: t('join'),
    notStarted: t('notStarted'),
    inProgress: t('inProgress'),
    ended: t('ended'),
    copySuccess: t('copySuccess'),
    password: t('meetingPassword'),
    passwordPlaceholder: t('livePasswordTip'),
    passwordError: t('meetingWrongPassword'),
    hint: t('commonTitle'),
    gotIt: t('gotIt'),
    cancel: t('globalCancel'),
    confirm: t('globalSure'),
    networkError: t('networkAbnormalityAndCheck'),
    restoreMeetingTips: t('restoreMeetingTips'),
    restore: t('restore'),
    uploadLoadingText: t('uploadLoadingText'),
    youCanOpen: t('supportedMeetings'),
    settingServiceBundleExpirationDate: t('settingServiceBundleExpirationDate'),
    meetingRoomScreenCasting: t('meetingRoomScreenCasting'),
    copyMeetingIdTip: t('copyMeetingIdTip'),
    comingSoon: t('comingSoon'),
  }

  const passwordRef = React.useRef<string>('')

  const startPreviewCount = useRef(0)

  const [immediateMeetingModalOpen, setImmediateMeetingModalOpen] =
    useState(false)
  const [joinMeetingModalOpen, setJoinMeetingModalOpen] = useState(false)
  const [scheduleMeetingModalOpen, setScheduleMeetingModalOpen] =
    useState(false)
  const [feedbackModalOpen, setFeedbackModalOpen] = useState(false)
  const [npsModalOpen, setNpsModalOpen] = useState(false)
  const [historyMeetingModalOpen, setHistoryMeetingModalOpen] = useState(false)
  const [notificationListModalOpen, setNotificationListModalOpen] =
    useState(false)
  const [updateUserNicknameModalOpen, setUpdateUserNicknameModalOpen] =
    useState(false)
  const [imageCropModalOpen, setImageCropModalOpen] = useState(false)
  const [aboutModalOpen, setAboutModalOpen] = useState(false)
  const [accountInfo, setAccountInfo] = useState<any>()
  const accountInfoRef = React.useRef<any>()

  accountInfoRef.current = accountInfo
  const [editMeeting, setEditMeeting] = useState<CreateMeetingResponse>()
  const [submitLoading, setSubmitLoading] = useState(false)
  const [userMenuOpen, setUserMenuOpen] = useState(false)
  const [inMeeting, setInMeeting] = useState(false)
  const [loginLoading, setLoginLoading] = useState(true)
  const [meetingListGroupByDate, setMeetingListGroupByDate] =
    useState<MeetingListGroupByDate>([])
  const [previewController, setPreviewController] =
    useState<NEPreviewController>()
  const [roomService, setRoomService] = useState<NERoomService>()
  const [settingOpen, setSettingOpen] = useState(false)
  const [settingModalTab, setSettingModalTab] =
    useState<SettingTabType>('normal')
  const [setting, setSetting] = useState<MeetingSetting | null>(null)
  const settingRef = React.useRef<MeetingSetting | null>(null)

  settingRef.current = setting

  const [meetingId, setMeetingId] = useState<string>('')
  const [appName, setAppName] = useState<string>('')
  const [tipInfo, setTipInfo] = useState<{
    content: string
    title: string
    url: string
  }>()
  const [appLiveAvailable, setAppLiveAvailable] = useState<boolean>(false)
  const [showTipInfo, setShowTipInfo] = useState<boolean>(true)
  const [showExpireTip, setShowExpireTip] = useState<boolean>(true)
  const [isOffLine, setIsOffLine] = useState<boolean>(false)
  const isLogin = useRef<boolean>(false)
  const [historyMeetingId, setHistoryMeetingId] = useState<string>()

  const eleIpcIns = useMemo(() => eleIpc.getInstance(), [])
  const [showLoading, setShowLoading] = useState<boolean>(false)
  const [systemAndManufacturer, setSystemAndManufacturer] = useState<{
    manufacturer: string
    version: string
    model: string
  }>()
  const [globalConfig, setGlobalConfig] = useState<GetMeetingConfigResponse>()
  const platform = eleIpcIns ? 'electron' : 'web'
  const previewRoomListenerRef = useRef<any>(null)
  const [invitationMeetingNum, setInvitationMeetingNum] = useState<string>('')
  const [notificationMessages, setNotificationMessages] = useState<
    NECustomSessionMessage[]
  >([])
  const electronInMeetingRef = useRef<boolean>(false)

  const [customMessage, setCustomMessage] =
    useState<NECustomSessionMessage | null>(null)

  // 用于被邀请端打开会议详情时候，邀请端取消会议，被邀请端关闭会议详情
  const openMeetingDetailMeetingNumRef = useRef('')
  const { handlePostMessage } = usePostMessageHandle()
  const [privateConfig, setPrivateConfig] =
    useState<NEMeetingPrivateConfig | null>(null)

  function getMeetingIdFromUrl(url) {
    const match = url.match(/meetingId=([^&]+)/)

    return match ? match[1] : null
  }

  const [notificationApi, contextHolder] = notification.useNotification({
    stack: false,
    bottom: 60,
    getContainer: () =>
      document.getElementById('before-meeting-home') || document.body,
  })

  const joinRoomByInvite = (meetingNum: string) => {
    setSubmitLoading(true)

    joinMeeting(
      {
        meetingNum: meetingNum,
      },
      true
    ).finally(() => {
      setSubmitLoading(false)
    })
  }

  const onNotificationClickHandler = (action: string, message?: any) => {
    if (!message) return
    const data = message.data?.data

    console.log('onNotificationClickHandler', data)
    const type = data?.type

    if (type === 'MEETING.INVITE' || type === 'MEETING.SCHEDULE.START') {
      setCustomMessage(null)
      // 拒绝加入
      if (action === 'reject') {
        NEMeetingKit.actions.inviteService?.rejectInvite(data.meetingId)
        notificationApi?.destroy(data?.meetingId)
      } else if (action === 'join') {
        Modal.destroyAll()
        joinRoomByInvite(data.meetingNum)
        notificationApi.destroy()
      }
    }
  }

  const imageCropValueRef = useRef<string>('')

  useEffect(() => {
    let setting: any = localStorage.getItem('ne-meeting-setting')

    if (setting) {
      try {
        setting = JSON.parse(setting)
      } catch (error) {
        console.log('parse setting error', error)
      }
    }

    // 处理邀请链接入会
    if (window.isElectronNative) {
      const url = localStorage.getItem(LOCALSTORAGE_INVITE_MEETING_URL)

      if (url) {
        handleInvitationUrl(url)
        localStorage.removeItem(LOCALSTORAGE_INVITE_MEETING_URL)
      }
    } else {
      handleInvitationUrl(location.href)
    }

    // 根据设置初始化主进程中的视频镜像配置
    window.ipcRenderer?.send(
      IPCEvent.changeMirror,
      !!setting?.videoSetting?.enableVideoMirroring
    )
    window.ipcRenderer?.on(IPCEvent.electronJoinMeeting, (e, url) => {
      handleInvitationUrl(url)
    })
    window.ipcRenderer?.on(
      IPCEvent.beforeLogin,
      (e, beforeMeeting: boolean) => {
        electronInMeetingRef.current = !beforeMeeting
      }
    )
  }, [])

  function handleInvitationUrl(url: string) {
    let meetingNum = ''

    if (window.isElectronNative) {
      meetingNum = getMeetingIdFromUrl(url)
    } else {
      const query = qs.parse(url.split('?')[1]?.split('#/')[0])

      meetingNum = query.meetingId as string
      // 如果是处理一次后，删除url中的meetingId参数
      if (meetingNum) {
        delete query.meetingId
        history.replaceState(
          {},
          '',
          qs.stringify(query, { addQueryPrefix: true })
        )
      }
    }

    if (meetingNum) {
      setInvitationMeetingNum(meetingNum)
      onOpenJoinMeeting(meetingNum)
      setImmediateMeetingModalOpen(false)
      setScheduleMeetingModalOpen(false)
      setFeedbackModalOpen(false)
      setUpdateUserNicknameModalOpen(false)
    }
  }

  useEffect(() => {
    window.ipcRenderer?.invoke(IPCEvent.getSystemManufacturer).then((res) => {
      setSystemAndManufacturer(res)
    })
  }, [])

  useEffect(() => {
    if (window.isElectronNative) {
      const handle = (_: any, data: any) => {
        const previewController = NEMeetingKit.actions.neMeeting
          ?.previewController as NEPreviewController

        if (!previewController) {
          return
        }

        const { method, args } = data

        if (method === 'startPreview') {
          //@ts-ignore
          previewController.setupLocalVideoCanvas(null)
        } else if (method === 'stopPreview') {
          if (immediateMeetingModalOpen || joinMeetingModalOpen) {
            // 如果当前打开了会前预览窗口，则关闭设置窗口不能停止预览
            return
          }
        }

        console.log('previewController', method, args)

        previewController[method]?.(...args)
      }

      window.ipcRenderer?.on(IPCEvent.previewController, handle)

      return () => {
        window.ipcRenderer?.off(IPCEvent.previewController, handle)
      }
    }
  }, [immediateMeetingModalOpen, joinMeetingModalOpen])

  function handleLogoutModal(): { destroy: () => void } {
    const modal = Modal.confirm({
      title: i18n.logout,
      content: i18n.logoutConfirm,
      focusTriggerAfterClose: false,
      transitionName: '',
      mask: false,
      width: 300,
      zIndex: 2000,
      footer: (
        <div className="nemeeting-modal-confirm-btns">
          <Button onClick={() => modal.destroy()}>{i18n.cancel}</Button>
          <Button
            type="primary"
            onClick={() => {
              modal.destroy()
              logout()
            }}
          >
            {i18n.confirm}
          </Button>
        </div>
      ),
    })

    return modal
  }

  const onOpenFeedback = (id?: string) => {
    setUserMenuOpen(false)
    if (window.isElectronNative) {
      openBeforeMeetingWindow({
        name: 'feedbackWindow',
        postMessageData: {
          event: 'setFeedbackData',
          payload: {
            visible: feedbackModalOpen,
            meetingId: id || meetingId,
            nickname: accountInfo?.nickname,
            appKey: appKey,
            systemAndManufacturer: systemAndManufacturer,
          },
        },
      })
      setInvitationMeetingNum('')
    } else {
      setFeedbackModalOpen(true)
    }
  }

  const items: MenuProps['items'] = [
    {
      key: '1',
      label: (
        <div className="user-menu-head-item">
          <UserAvatar
            nickname={accountInfo?.nickname}
            avatar={accountInfo?.avatar}
            size={48}
            className="user-avatar"
            isEdit={
              globalConfig?.appConfig.MEETING_ACCOUNT_CONFIG
                .avatarUpdateDisabled !== true
            }
            onClick={() => {
              globalConfig?.appConfig.MEETING_ACCOUNT_CONFIG
                .avatarUpdateDisabled !== true && openImageCrop()
            }}
          />
          <div className="user-name-wrap">
            <div className="user-name">
              <div
                style={{
                  fontWeight:
                    window.systemPlatform === 'win32' ? 'bold' : '500',
                }}
                className="user-name-content"
              >
                {accountInfo?.nickname}{' '}
              </div>
              {globalConfig?.appConfig.MEETING_ACCOUNT_CONFIG
                .nicknameUpdateDisabled === true ? null : (
                <EditOutlined
                  onClick={() => {
                    setUserMenuOpen(false)
                    setUpdateUserNicknameModalOpen(true)
                  }}
                />
              )}
            </div>
            <div className="sub-title">{appName}</div>
          </div>
        </div>
      ),
    },
    {
      key: '2',
      label: (
        <div className="nemeeting-open-meeting-info-wrap">
          {/* <div className="user-menu-item user-menu-item-info normal-item">
            <div className="title">{i18n.currentVersion}</div>
            <div className="sub-title">{appName}</div>
          </div> */}
          {accountInfo?.serviceBundle && (
            <div className="nemeeting-open-meeting-info">
              <div className="you-can-open">
                <span>{i18n.youCanOpen}</span>
                {accountInfo.serviceBundle.expireTimeStamp !== -1 ? (
                  <span>
                    {i18n.settingServiceBundleExpirationDate}
                    {dayjs(accountInfo.serviceBundle.expireTimeStamp).format(
                      'YYYY-MM-DD'
                    )}
                  </span>
                ) : null}
              </div>
              <div className="meeting-limit-info">
                <div className="box"></div>
                <div className="info">
                  {accountInfo.serviceBundle.meetingMaxMinutes < 0 ||
                  !accountInfo.serviceBundle.meetingMaxMinutes
                    ? t('meetingNoLimit', {
                        maxCount: accountInfo.serviceBundle.meetingMaxMembers,
                      })
                    : t('meetingLimit', {
                        maxCount: accountInfo.serviceBundle.meetingMaxMembers,
                        maxMinutes: accountInfo.serviceBundle.meetingMaxMinutes,
                      })}
                </div>
              </div>
              {accountInfo.serviceBundle.expireTimeStamp !== -1 ? (
                <div className="expire-tip">
                  {accountInfo.serviceBundle.expireTip}
                </div>
              ) : null}
            </div>
          )}
        </div>
      ),
    },
    {
      key: '2.5',
      label: (
        <div className="user-menu-item normal-item user-menu-item-meeting-num">
          <div className="title">
            <div
              className="personal-meeting-num"
              style={{
                fontWeight: window.systemPlatform === 'win32' ? 'bold' : '500',
              }}
            >
              {i18n.personalShortMeetingNum}
            </div>
            {/* <Tag color="#EBF2FF" className="custom-tag">
              {i18n.internalUse}
            </Tag> */}
          </div>
          <div className="sub-title">
            <div className="short-meeting-num">
              {accountInfo?.shortMeetingNum}
            </div>
            <svg
              onClick={() => {
                copyElementValue(accountInfo?.shortMeetingNum, () => {
                  Toast.success(i18n.copySuccess)
                })
              }}
              className="icon icon-blue iconfont iconfuzhi1"
              aria-hidden="true"
            >
              <use xlinkHref="#iconfuzhi1"></use>
            </svg>
          </div>
        </div>
      ),
      hidden: !accountInfo?.shortMeetingNum,
    },
    {
      key: '3',
      label: (
        <div className="user-menu-item normal-item user-menu-item-meeting-num">
          <div className="title">
            <div
              style={{
                fontWeight: window.systemPlatform === 'win32' ? 'bold' : '500',
              }}
              className="personal-meeting-num"
            >
              {i18n.personalMeetingNum}
            </div>
          </div>
          <div className="sub-title">
            <div className="short-meeting-num">
              {getMeetingDisplayId(accountInfo?.meetingNum)}
            </div>
            <svg
              onClick={() => {
                copyElementValue(accountInfo?.meetingNum, () => {
                  Toast.success(i18n.copySuccess)
                })
              }}
              className="icon icon-blue iconfont iconfuzhi1"
              aria-hidden="true"
            >
              <use xlinkHref="#iconfuzhi1"></use>
            </svg>
          </div>
        </div>
      ),
    },
    {
      key: '4',
      label: (
        <div
          className="user-menu-item normal-item feedback"
          style={{ cursor: 'pointer' }}
          onClick={() => {
            onOpenFeedback()
          }}
        >
          <div
            className="title"
            style={{
              fontWeight: window.systemPlatform === 'win32' ? 'bold' : '500',
            }}
          >
            {i18n.feedback}
          </div>
          <div className="sub-title">
            <svg
              style={{
                fontSize: '24px',
                position: 'relative',
                left: '5px',
              }}
              className="icon iconfont"
              aria-hidden="true"
            >
              <use xlinkHref="#iconyoujiantou-16px-2"></use>
            </svg>
          </div>
        </div>
      ),
    },
    {
      key: '5',
      label: (
        <div
          className="user-menu-item normal-item about"
          style={{ cursor: 'pointer' }}
          onClick={() => {
            setUserMenuOpen(false)
            if (window.isElectronNative) {
              openBeforeMeetingWindow({ name: 'aboutWindow' })
            } else {
              setAboutModalOpen(true)
            }
          }}
        >
          <div
            className="title"
            style={{
              fontWeight: window.systemPlatform === 'win32' ? 'bold' : '500',
            }}
          >
            {i18n.about}
          </div>
          <div className="sub-title">
            <svg
              style={{
                fontSize: '24px',
                position: 'relative',
                left: '5px',
              }}
              className="icon iconfont"
              aria-hidden="true"
            >
              <use xlinkHref="#iconyoujiantou-16px-2"></use>
            </svg>
          </div>
        </div>
      ),
    },
    {
      key: '6',
      label: (
        <div
          className="user-menu-item logout"
          onClick={() => {
            setUserMenuOpen(false)
            handleLogoutModal()
          }}
          style={{ cursor: 'pointer' }}
        >
          <div className="logout-button">{i18n.logout}</div>
        </div>
      ),
    },
  ].filter((item) => !item.hidden)

  const logout = () => {
    onLogout()
    NEMeetingKit?.actions?.destroy()
    isLogin.current = false
  }

  function setNPS(meetingId?: string) {
    console.log('setNps>>>>', meetingId)
    const npsString = localStorage.getItem('ne-meeting-nps')

    if (npsString) {
      const nps = JSON.parse(npsString)

      nps.meetingId = meetingId || NEMeetingKit.actions.NEMeetingInfo.meetingId
      nps.need = true
      localStorage.setItem('ne-meeting-nps', JSON.stringify(nps))
    } else {
      localStorage.setItem(
        'ne-meeting-nps',
        JSON.stringify({
          meetingId: meetingId || NEMeetingKit.actions.NEMeetingInfo.meetingId,
          need: true,
        })
      )
    }
  }

  async function init(cb) {
    if (NEMeetingKit.actions.isInitialized) {
      cb()
      return
    }

    let config: any = {
      appKey: appKey, //云信服务appkey
      meetingServerDomain: domain, //会议服务器地址，支持私有化部署
      locale: i18next.language, //语言
    }
    // 判断是否有私有化配置文件
    let privateConfig: any = null

    if (window.isElectronNative) {
      try {
        privateConfig = await window.ipcRenderer?.invoke(
          IPCEvent.getPrivateConfig
        )
        privateConfig = parsePrivateConfig(privateConfig)
      } catch (error) {
        console.log('getPrivateConfig error', error)
      }
    } else {
      privateConfig = PRIVATE_CONFIG
      console.log('privateConfig>>>', privateConfig)
    }

    if (privateConfig) {
      setPrivateConfig(privateConfig)
      privateConfig.appKey && (config.appKey = privateConfig.appKey)
      privateConfig.meetingServerDomain &&
        (config.meetingServerDomain = privateConfig.meetingServerDomain)
      config = { ...config, ...privateConfig }
    }

    console.log('init config ', config)
    NEMeetingKit.actions.init(0, 0, config, cb) // （width，height）单位px 建议比例4:3
    NEMeetingKit.actions.on('onMeetingStatusChanged', (status: number) => {
      if (status === NEMeetingStatus.MEETING_STATUS_IN_WAITING_ROOM) {
        // 到等候室
        setFeedbackModalOpen(false)
      } else if (
        status === NEMeetingStatus.MEETING_STATUS_FAILED ||
        status === NEMeetingStatus.MEETING_STATUS_IDLE
      ) {
        setInMeeting(false)
      }
    })
    NEMeetingKit.actions.on('roomEnded', (reason: any) => {
      console.log('roomEnded>>>>>', reason)
      setFeedbackModalOpen(false)
      eleIpcIns?.sendMessage(IPCEvent.quiteFullscreen)
      setTimeout(() => {
        setInMeeting(false)
        if (eleIpcIns) {
          window.ipcRenderer?.send(IPCEvent.beforeEnterRoom)
        } else {
          window.location.reload()
        }
      }, 1500)
    })
  }

  function createMeeting(createOptions: Partial<CreateOptions>) {
    const options = {
      meetingNum: '',
      nickName: accountInfo.nickname,
      avatar: accountInfo.avatar,
      showSpeaker: setting?.normalSetting.showSpeakerList,
      enableUnmuteBySpace: setting?.audioSetting.enableUnmuteBySpace,
      meetingIdDisplayOption: 0,
      enableFixedToolbar: setting?.normalSetting.showToolbar,
      enableVideoMirror: setting?.videoSetting.enableVideoMirroring,
      showDurationTime: setting?.normalSetting.showDurationTime,
      ...createOptions,
    }

    !window.isElectronNative && setSubmitLoading(true)

    setImmediateMeetingModalOpen(false)
    setJoinMeetingModalOpen(false)
    setScheduleMeetingModalOpen(false)

    const storeNicknameStr = localStorage.getItem(
      'ne-meeting-nickname-' + accountInfo?.account
    )

    if (storeNicknameStr) {
      const storeNickname = JSON.parse(storeNicknameStr)

      if (storeNickname[options.meetingNum]) {
        options.nickName = storeNickname[options.meetingNum]
      } else {
        localStorage.removeItem('ne-meeting-nickname-' + accountInfo?.account)
      }
    }

    const moreBarList: MoreBarList = [
      { id: 29 },
      { id: 25 },
      {
        id: 1000,
        btnConfig: {
          icon: FeedbackImg,
          lightIcon: LightFeedbackImg,
          text: i18n.feedback,
        },
        type: 'single',
        injectItemClick: () => {
          setMeetingId(NEMeetingKit.actions.NEMeetingInfo.meetingId)
          onOpenFeedback(NEMeetingKit.actions.NEMeetingInfo.meetingId)
        },
      },
    ]
    const module = privateConfig?.module

    if (module?.feedback && module.feedback.enable === false) {
      moreBarList.pop()
    }

    if (window.isElectronNative) {
      setSubmitLoading(false)
      console.log('createMeeting>>>>', accountInfoRef.current)
      window.ipcRenderer?.send(IPCEvent.enterRoom, {
        joinType: 'create',
        meetingServerDomain: domain,
        appKey: appKey,
        userUuid: userUuid,
        userToken: userToken,
        meetingNum: options.meetingNum,
        password: options.password,
        openCamera: options.video,
        openMic: options.audio,
        nickName: options.nickName,
        avatar: options.avatar,
      })
      return
    }

    NEMeetingKit.actions.create(
      {
        meetingNum: options.meetingNum,
        password: options.password,
        nickName: options.nickName,
        video: options.video,
        audio: options.audio,
        showSpeaker: options.showSpeaker,
        enableUnmuteBySpace: options.enableUnmuteBySpace,
        enableFixedToolbar: options.enableFixedToolbar,
        enableVideoMirror: options.enableVideoMirror,
        showDurationTime: setting?.normalSetting.showDurationTime,
        meetingIdDisplayOption: 0,
        showMeetingRemainingTip: true,
        showCloudRecordingUI: true,
        avatar: options.avatar,
        watermarkConfig: {
          name: accountInfo.nickname,
        },
        noSip: false,
        moreBarList: [
          { id: 29 },
          { id: 30 },
          { id: 25 },
          {
            id: 1000,
            btnConfig: {
              icon: FeedbackImg,
              lightIcon: LightFeedbackImg,
              text: i18n.feedback,
            },
            type: 'single',
            injectItemClick: () => {
              setMeetingId(NEMeetingKit.actions.NEMeetingInfo.meetingId)
              onOpenFeedback(NEMeetingKit.actions.NEMeetingInfo.meetingId)
            },
          },
          { id: 31 },
        ],
        env: platform,
      },
      function (e: any) {
        setSubmitLoading(false)
        if (!e) {
          eleIpcIns?.sendMessage('enterRoom')
          setNPS()
          setInMeeting(true)
          setLocalRecentMeetingList(
            NEMeetingKit.actions.NEMeetingInfo.meetingNum
          )
        }
      }
    )
  }

  function cancelScheduleMeeting(
    meetingId: string,
    cancelRecurringMeeting?: boolean
  ) {
    setScheduleMeetingModalOpen(false)
    if (window.isElectronNative) {
      closeWindow('scheduleMeetingWindow')
    }

    setEditMeeting(undefined)

    NEMeetingKit.actions.neMeeting
      ?.cancelMeeting(meetingId, cancelRecurringMeeting)
      .then(() => {
        Toast.success(i18n.cancelScheduleMeetingSuccess)
        getMeetingList()
      })
      .catch((error) => {
        Toast.fail(
          error.msg ||
            (navigator.onLine
              ? i18n.cancelScheduleMeetingFail
              : i18n.networkError)
        )
      })
  }

  function createOrEditScheduleMeeting(value) {
    const {
      subject,
      startTime,
      endTime,
      password,
      audioOff,
      openLive,
      meetingId,
      liveOnlyEmployees,
      attendeeAudioOffType,
      enableWaitingRoom,
      enableJoinBeforeHost,
      recurringRule,
      scheduledMembers,
      enableGuestJoin,
      interpretation,
      timezoneId,
    } = value

    setImmediateMeetingModalOpen(false)
    setJoinMeetingModalOpen(false)

    NEMeetingKit.actions.neMeeting
      ?.scheduleMeeting({
        meetingNum: '',
        meetingId: meetingId,
        nickName: accountInfo?.nickname,
        subject: subject,
        startTime: startTime,
        endTime: endTime,
        password: password,
        attendeeAudioOff: audioOff,
        openLive: openLive,
        liveOnlyEmployees: liveOnlyEmployees,
        noSip: false,
        attendeeAudioOffType,
        enableWaitingRoom,
        enableJoinBeforeHost,
        recurringRule,
        scheduledMembers,
        enableGuestJoin,
        interpretation,
        timezoneId,
      })
      .then(() => {
        setScheduleMeetingModalOpen(false)
        setSubmitLoading(false)
        getMeetingList()
        if (meetingId) {
          Toast.success(i18n.editScheduleMeetingSuccess)
        } else {
          Toast.success(i18n.scheduleMeetingSuccess)
        }

        if (window.isElectronNative) {
          closeWindow('scheduleMeetingWindow')
        }
      })
      .catch((error) => {
        const errorMsg =
          error.msg ||
          (navigator.onLine ? i18n.scheduleMeetingFail : i18n.networkError)

        // 会议已不存在则关闭弹窗
        if (window.isElectronNative) {
          if (error.code === 3104) {
            closeWindow('scheduleMeetingWindow')
          }

          const scheduleMeetingWindow = getWindow('scheduleMeetingWindow')

          scheduleMeetingWindow?.postMessage(
            {
              event: 'createOrEditScheduleMeetingFail',
              payload: {
                errorMsg,
              },
            },
            scheduleMeetingWindow.origin
          )
        } else {
          if (error.code === 3104) {
            setScheduleMeetingModalOpen(false)
          }

          setSubmitLoading(false)
          Toast.fail(errorMsg)
        }
      })
  }

  async function joinMeeting(
    joinOptions: Partial<JoinOptions>,
    joinByInvite?: boolean
  ) {
    const options = {
      meetingNum: '',
      nickName: accountInfoRef.current.nickname,
      video: settingRef.current?.normalSetting.openVideo ? 1 : 2,
      audio: settingRef.current?.normalSetting.openAudio ? 1 : 2,
      avatar: accountInfoRef.current.avatar,
      showSpeaker: settingRef.current?.normalSetting.showSpeakerList,
      enableUnmuteBySpace: settingRef.current?.audioSetting.enableUnmuteBySpace,
      enableFixedToolbar: settingRef.current?.normalSetting.showToolbar,
      enableVideoMirror: settingRef.current?.videoSetting.enableVideoMirroring,
      showDurationTime: settingRef.current?.normalSetting.showDurationTime,
      ...joinOptions,
    }

    !window.isElectronNative && setSubmitLoading(true)
    setImmediateMeetingModalOpen(false)
    setScheduleMeetingModalOpen(false)
    setNotificationListModalOpen(false)
    console.warn('joinMeeting>>>>', joinByInvite)
    await NEMeetingKit.actions.neMeeting
      ?.getMeetingInfoByFetch(options.meetingNum)
      .catch((e) => {
        console.error('join failed', options.meetingNum, e)

        if (e?.code == 3102 || e?.code == 3103) {
          Toast.fail(e?.msg)
        }

        // 非密码错误
        if (e?.code != 1020) {
          setSubmitLoading(false)
          const errorMsg = e.message || e.msg || e.code

          if (window.isElectronNative) {
            const joinMeetingWindow = getWindow('joinMeetingWindow')

            joinMeetingWindow?.postMessage(
              {
                event: 'joinMeetingFail',
                payload: {
                  errorMsg,
                },
              },
              joinMeetingWindow.origin
            )
          } else {
            Toast.fail(errorMsg)
          }

          throw e
        }
      })
    const storeNicknameStr = localStorage.getItem(
      'ne-meeting-nickname-' + accountInfo?.account
    )

    if (storeNicknameStr) {
      const storeNickname = JSON.parse(storeNicknameStr)

      if (storeNickname[options.meetingNum]) {
        options.nickName = storeNickname[options.meetingNum]
      } else {
        localStorage.removeItem('ne-meeting-nickname-' + accountInfo?.account)
      }
    }

    if (window.isElectronNative) {
      setJoinMeetingModalOpen(false)
      setSubmitLoading(false)
      window.ipcRenderer?.send(IPCEvent.enterRoom, {
        joinType: joinByInvite ? 'joinByInvite' : 'join',
        meetingServerDomain: domain,
        appKey: appKey,
        userUuid: userUuid,
        userToken: userToken,
        meetingNum: options.meetingNum,
        password: options.password,
        openCamera: options.video,
        openMic: options.audio,
        nickName: options.nickName,
        avatar: options.avatar,
      })
      return
    }

    function fetchJoin(options: JoinOptions): Promise<void> {
      return new Promise((resolve, reject) => {
        const data: any = {
          ...options,
          showCloudRecordingUI: true,
          showMeetingRemainingTip: true,
          env: platform,
          watermarkConfig: {
            name: accountInfo.nickname,
          },
          moreBarList: [
            { id: 29 },
            { id: 30 },
            { id: 25 },
            {
              id: 1000,
              btnConfig: {
                icon: FeedbackImg,
                lightIcon: LightFeedbackImg,
                text: i18n.feedback,
              },
              type: 'single',
              injectItemClick: () => {
                setMeetingId(NEMeetingKit.actions.NEMeetingInfo.meetingId)
                onOpenFeedback(NEMeetingKit.actions.NEMeetingInfo.meetingId)
              },
            },
            { id: 31 },
          ],
        }

        if (joinByInvite) {
          NEMeetingKit.actions.inviteService
            ?.acceptInvite(data)
            .then(() => {
              resolve()
            })
            .catch((e) => {
              reject(e)
            })
        } else {
          NEMeetingKit.actions.join(data, function (e: any) {
            console.warn('join meeting callback', e)
            if (e) {
              reject(e)
            }

            resolve()
          })
        }
      })
    }

    let modal: any

    return fetchJoin(options)
      .then(() => {
        console.warn('fetchJoin meeting callback')
        setJoinMeetingModalOpen(false)
        eleIpcIns?.sendMessage('enterRoom')
        setNPS()
        setInMeeting(true)
        setLocalRecentMeetingList(options.meetingNum).catch((e) => {
          // 刚好加入会议，主持人结束会议，会议列表接口报错直接退出
          if (e.code === 3102) {
            Toast.fail(e.msg || e.code)
            NEMeetingKit.actions.destroy()
            setInMeeting(false)
          }
        })
      })
      .catch((e) => {
        console.log('==========fetchJoin error==========', e)
        const InputComponent = (inputValue) => {
          return (
            <Input
              placeholder={i18n.passwordPlaceholder}
              value={inputValue}
              maxLength={6}
              allowClear
              onChange={(event) => {
                passwordRef.current = event.target.value.replace(/[^0-9]/g, '')
                modal.update({
                  content: <>{InputComponent(passwordRef.current)}</>,
                  okButtonProps: {
                    disabled: !passwordRef.current,
                    style: !passwordRef.current
                      ? { color: 'rgba(22, 119, 255, 0.5)' }
                      : {},
                  },
                })
              }}
            />
          )
        }

        if (e.code === 1020) {
          passwordRef.current = ''
          modal = Modal.confirm({
            title: i18n.password,
            width: 375,
            content: <>{InputComponent('')}</>,
            okButtonProps: {
              disabled: true,
              style: { color: 'rgba(22, 119, 255, 0.5)' },
            },
            onOk: async () => {
              try {
                await fetchJoin({
                  ...options,
                  password: passwordRef.current,
                })
                setJoinMeetingModalOpen(false)
                eleIpcIns?.sendMessage('enterRoom')
                setNPS()
                setInMeeting(true)
                setLocalRecentMeetingList(options.meetingNum)
              } catch (e: any) {
                if (e.code === 1020) {
                  modal.update({
                    content: (
                      <>
                        {InputComponent(passwordRef.current)}
                        <div
                          style={{
                            color: '#fe3b30',
                            textAlign: 'left',
                            margin: '5px 0px -10px 0px',
                          }}
                        >
                          {i18n.passwordError}
                        </div>
                      </>
                    ),
                  })
                }

                throw e
              }
            },
          })
        } else {
          setInMeeting(false)
          throw e
        }
      })
      .finally(() => {
        setSubmitLoading(false)
      })
  }

  async function setLocalRecentMeetingList(meetingNum: string) {
    const res = await NEMeetingKit.actions.neMeeting?.getMeetingInfoByFetch(
      meetingNum
    )
    const store = JSON.parse(localStorage.getItem(LOCAL_STORAGE_KEY) || '{}')
    const accountInfo = accountInfoRef.current

    if (!store[accountInfo?.account]) {
      store[accountInfo?.account] = [res]
    } else {
      store[accountInfo?.account].unshift(res)
      const uniqueByMeetingNum = store[accountInfo?.account].reduce(
        (unique, o) => {
          if (!unique.some((obj) => obj.meetingNum === o.meetingNum)) {
            unique.push(o)
          }

          return unique
        },
        []
      )

      store[accountInfo?.account] = uniqueByMeetingNum.slice(0, 10)
    }

    localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(store))
  }

  function login(account, token) {
    setLoginLoading(true)
    init((e) => {
      if (!e) {
        const previewController = NEMeetingKit.actions.neMeeting
          ?.previewController as NEPreviewController

        setPreviewController(previewController)
        const roomService = NEMeetingKit.actions.neMeeting
          ?.roomService as NERoomService

        setRoomService(roomService)
        NEMeetingKit.actions.login(
          {
            // 登陆
            accountId: account,
            accountToken: token,
          },
          function (e: any) {
            if (!e) {
              isLogin.current = true
              setLoginLoading(false)
              setAccountInfo({
                //@ts-ignore
                ...NEMeetingKit.actions.accountInfo,
                account: account,
              })
              getMeetingList()

              NEMeetingKit.actions.neMeeting?.eventEmitter.on(
                EventType.ReceiveScheduledMeetingUpdate,
                (res) => {
                  console.log('收到房间状态变更', res)
                  const data = res.data

                  // 账号受到限制
                  if (data?.type === 200) {
                    Toast.warning(i18n.tokenExpired, 3000)
                    setTimeout(() => {
                      logout()
                    }, 1000)
                  } else {
                    // 房间被关闭或者取消 需要被邀请端判断当前是否打开该会议的会议详情。如果是则需要关闭弹窗
                    if (
                      data.type === 101 &&
                      data.state === 4 &&
                      openMeetingDetailMeetingNumRef.current == data.meetingNum
                    ) {
                      if (window.isElectronNative) {
                        closeWindow('scheduleMeetingWindow')
                      } else {
                        setScheduleMeetingModalOpen(false)
                      }

                      openMeetingDetailMeetingNumRef.current = ''
                    }

                    getMeetingList()
                  }
                }
              )

              NEMeetingKit.actions.neMeeting?.eventEmitter.on(
                EventType.ReceiveAccountInfoUpdate,
                (res) => {
                  console.log('收到账号信息变更', res)
                  setAccountInfo((prev) => {
                    return {
                      ...prev,
                      ...res.meetingAccountInfo,
                    }
                  })
                }
              )

              NEMeetingKit.actions.neMeeting?.getAppInfo().then((res) => {
                console.log('getAppInfo', res)
                setAppName(res.appName)
              })
              NEMeetingKit.actions.neMeeting?.getAppTips().then((res) => {
                console.log('getAppTips', res)
                setTipInfo(res.tips[0])
              })
              NEMeetingKit.actions.neMeeting?.getAppConfig().then((res) => {
                console.log('getAppConfig', res)
                setAppLiveAvailable(!!res.appConfig?.APP_ROOM_RESOURCE?.live)
              })
              const notFirstLogin = sessionStorage.getItem(NOT_FIRST_LOGIN)

              if (!notFirstLogin) {
                window.ipcRenderer?.send(IPCEvent.isStartByUrl)
                sessionStorage.setItem(NOT_FIRST_LOGIN, 'true')
              }

              const currentMeetingStr = localStorage.getItem(
                'ne-meeting-current-info'
              )

              // 异常退出恢复会议
              if (currentMeetingStr) {
                const currentMeeting = JSON.parse(currentMeetingStr)

                // 15分钟内恢复会议
                if (currentMeeting.time > Date.now() - 1000 * 60 * 15) {
                  Modal.confirm({
                    title: i18n.hint,
                    content: i18n.restoreMeetingTips,
                    okText: i18n.restore,
                    onCancel: () => {
                      localStorage.removeItem('ne-meeting-current-info')
                    },
                    onOk: () => {
                      try {
                        const currentMeeting = JSON.parse(currentMeetingStr)

                        currentMeeting.joinType = 'join'
                        window.ipcRenderer?.send(IPCEvent.enterRoom, {
                          ...currentMeeting,
                          meetingServerDomain: domain,
                          appKey: appKey,
                          userUuid: userUuid,
                          userToken: userToken,
                        })
                      } catch (error) {
                        console.error('restore meeting error', error)
                      }

                      localStorage.removeItem('ne-meeting-current-info')
                    },
                  })
                } else {
                  localStorage.removeItem('ne-meeting-current-info')
                }
              }

              NEMeetingKit.actions.neMeeting?.getGlobalConfig().then((res) => {
                setGlobalConfig(res)
              })
            } else {
              setLoginLoading(false)
              console.error('login fail appKey ', e, {
                // 登陆
                accountId: account,
                accountToken: token,
              })
              isLogin.current = false
              // 非网络错误才离开
              if (e.code !== 'ERR_NETWORK') {
                logout()
              }
            }
          }
        )
      }
    })
  }

  function getMeetingList() {
    NEMeetingKit.actions.neMeeting
      ?.getMeetingList({
        startTime: dayjs().startOf('day').valueOf(),
        endTime: dayjs().add(14, 'day').endOf('day').valueOf(),
      })
      .then((data) => {
        const groupedData = data
          .filter((item) => item.type === 3)
          .reduce((acc: Record<string, CreateMeetingResponse[]>, obj) => {
            const key = dayjs(obj.startTime).startOf('day').valueOf()

            if (!acc[key]) {
              acc[key] = []
            }

            acc[key].push(obj)
            return acc
          }, {})
        const meetingListGroupByDate: MeetingListGroupByDate = []

        Object.keys(groupedData).forEach((key) => {
          meetingListGroupByDate.push({
            date: key,
            list: groupedData[key],
          })
        })
        setMeetingListGroupByDate(meetingListGroupByDate)
      })
      .catch((e: any) => {
        // 用户被注销或者删除
        if (e.code === 404 || e.code === 401) {
          Toast.warning(i18n.tokenExpired)
          setTimeout(() => {
            logout()
          }, 1000)
        }
      })
  }

  function formatScheduleMeetingDateTitle(time: number) {
    const weekdays = i18n.weekdays
    const weekday =
      dayjs(time) < dayjs().endOf('day')
        ? i18n.today
        : dayjs(time) < dayjs().add(1, 'day').endOf('day')
        ? i18n.tomorrow
        : weekdays[dayjs(time).day()]

    const date = formatTimeWithLanguage(time, i18next.language)

    return (
      <div className="schedule-meeting-group-date">
        <div className="schedule-meeting-group-date-line">
          <span className="weekday">{weekday}</span>
          <span className="date">{date}</span>
        </div>
      </div>
    )
  }

  function onSettingChange(setting: MeetingSetting) {
    setSetting(setting)
    localStorage.setItem('ne-meeting-setting', JSON.stringify(setting))
  }

  function addPreviewRoomListener() {
    if (!window.isElectronNative) {
      return
    }

    const previewConText =
      NEMeetingKit.actions.neMeeting?.roomService?.getPreviewRoomContext()

    if (!previewConText) {
      return
    }

    previewRoomListenerRef.current = {
      onLocalAudioVolumeIndication: (volume: number) => {
        const settingWindow = getWindow('settingWindow')

        settingWindow?.postMessage(
          {
            event: EventType.RtcLocalAudioVolumeIndication,
            payload: {
              volume,
            },
          },
          settingWindow.origin
        )
      },
      onRtcVirtualBackgroundSourceEnabled: (enabled, reason) => {
        const settingWindow = getWindow('settingWindow')

        settingWindow?.postMessage(
          {
            event: EventType.rtcVirtualBackgroundSourceEnabled,
            payload: {
              enabled,
              reason,
            },
          },
          settingWindow.origin
        )
        window.ipcRenderer?.send('previewControllerListener', {
          method: EventType.rtcVirtualBackgroundSourceEnabled,
          args: [
            {
              enabled,
              reason,
            },
          ],
        })
      },
      onVideoFrameData: (uuid, bSubVideo, data, type, width, height) => {
        const immediateMeetingWindow = getWindow('immediateMeetingWindow')

        immediateMeetingWindow?.postMessage(
          {
            event: 'onVideoFrameData',
            payload: {
              uuid,
              bSubVideo,
              data,
              type,
              width,
              height,
            },
          },
          immediateMeetingWindow.origin
        )

        const joinMeetingWindow = getWindow('joinMeetingWindow')

        joinMeetingWindow?.postMessage(
          {
            event: 'onVideoFrameData',
            payload: {
              uuid,
              bSubVideo,
              data,
              type,
              width,
              height,
            },
          },
          joinMeetingWindow.origin
        )

        const settingWindow = getWindow('settingWindow')

        settingWindow?.postMessage(
          {
            event: 'onVideoFrameData',
            payload: {
              uuid,
              bSubVideo,
              data,
              type,
              width,
              height,
            },
          },
          settingWindow.origin,
          [data.bytes.buffer]
        )
      },
    }
    //@ts-ignore
    previewConText?.addPreviewRoomListener(previewRoomListenerRef.current)
  }

  function removePreviewRoomListener() {
    if (previewRoomListenerRef.current) {
      const previewConText =
        NEMeetingKit.actions.neMeeting?.roomService?.getPreviewRoomContext()

      //@ts-ignore
      previewConText?.removePreviewRoomListener(previewRoomListenerRef.current)
    }
  }

  function updateLocalStorageUserInfo(userInfo: any) {
    const userString = localStorage.getItem(LOCALSTORAGE_USER_INFO)

    if (userString) {
      const user = JSON.parse(userString)

      localStorage.setItem(
        LOCALSTORAGE_USER_INFO,
        JSON.stringify({
          ...user,
          ...userInfo,
        })
      )
    }
  }

  useEffect(() => {
    if (inMeeting) return
    const userString = localStorage.getItem(LOCALSTORAGE_USER_INFO)

    if (userString) {
      const user = JSON.parse(userString)

      if (user.userUuid && user.userToken && (user.appKey || user.appId)) {
        appKey = user.appKey || user.appId
        userUuid = user.userUuid
        userToken = user.userToken
        setTimeout(() => {
          login(user.userUuid, user.userToken)
        }, 100)
      } else {
        logout()
      }
    } else {
      logout()
    }

    const setting = localStorage.getItem('ne-meeting-setting')

    if (setting) {
      try {
        setSetting(JSON.parse(setting) as MeetingSetting)
      } catch (error) {
        console.error('parse setting error', error)
      }
    }
  }, [inMeeting])

  useEffect(() => {
    if (inMeeting) {
      removePreviewRoomListener()
    } else {
      if (previewController) {
        addPreviewRoomListener()
        return () => {
          removePreviewRoomListener()
        }
      }
    }
  }, [inMeeting, previewController])

  // useEffect(() => {
  //   if (editMeeting) {
  //     meetingListGroupByDate.forEach((item) => {
  //       const meeting = item.list.find(
  //         (i) => i.meetingId === editMeeting.meetingId
  //       )
  //       if (meeting) {
  //         setEditMeeting(meeting)
  //       }
  //     })
  //   }
  // }, [editMeeting, meetingListGroupByDate])

  document.title = i18n.appTitle

  function onSettingClick(type?: SettingTabType) {
    type = type || 'normal'
    // 非Electron
    setSettingOpen(true)
    if (!window.isElectronNative) {
      setSettingModalTab(type)
    } else {
      openBeforeMeetingWindow({
        name: 'settingWindow',
        postMessageData: {
          event: 'openSetting',
          payload: {
            type: 'normal',
            inMeeting: false,
          },
        },
      })
    }
  }

  function openBeforeMeetingWindow(payload: {
    name: string
    url?: string
    postMessageData?: { event: string; payload: any }
  }) {
    const newWindow = openWindow(payload.name, payload.url)
    const postMessage = () => {
      payload.postMessageData &&
        newWindow?.postMessage(payload.postMessageData, newWindow.origin)
    }

    console.warn('firstOpen', newWindow?.firstOpen)
    // 不是第一次打开
    if (newWindow?.firstOpen === false) {
      postMessage()
    } else {
      windowLoadListener(newWindow)
      newWindow?.addEventListener('load', () => {
        postMessage()
      })
    }
  }

  function windowLoadListener(childWindow) {
    function messageListener(e) {
      const { event, payload } = e.data
      const neMeeting = NEMeetingKit.actions.neMeeting
      const roomService = NEMeetingKit.actions.neMeeting?.roomService
      const previewController =
        NEMeetingKit.actions.neMeeting?.previewController
      const previewContext =
        NEMeetingKit.actions.neMeeting?.roomService?.getPreviewRoomContext()

      if (event === 'neMeeting' && neMeeting) {
        const { replyKey, fnKey, args } = payload
        const result = neMeeting[fnKey]?.(...args)

        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'roomService' && roomService) {
        const { replyKey, fnKey, args } = payload
        const result = roomService[fnKey]?.(...args)

        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'previewController' && previewController) {
        const { replyKey, fnKey, args } = payload

        if (fnKey === 'startPreview') {
          startPreviewCount.current++
        } else if (fnKey === 'stopPreview') {
          startPreviewCount.current--
        }

        if (
          startPreviewCount.current > 1 &&
          (fnKey === 'startPreview' || fnKey === 'setupLocalVideoCanvas')
        ) {
          return
        }

        if (startPreviewCount.current > 0 && fnKey === 'stopPreview') {
          return
        }

        const result = previewController[fnKey]?.(...args)

        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'previewContext' && previewController) {
        const { replyKey, fnKey, args } = payload
        const result = previewContext?.[fnKey]?.(...args)

        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'updateUserAvatar') {
        const { url } = payload

        setAccountInfo({
          ...accountInfo,
          avatar: url,
        })
        Toast.success(t('settingAvatarUpdateSuccess'))
      } else if (event === 'openWindow') {
        openBeforeMeetingWindow(payload)
      } else if (event === 'updateWindowData') {
        const win = getWindow(payload.name)

        win?.postMessage(payload.postMessageData, win.origin)
      } else if (event === 'notificationClick') {
        handleNotificationClick(payload.action, payload.message)
      } else if (event === 'createMeeting') {
        const { value } = payload

        createMeeting({
          meetingNum: value.meetingId,
          password: value.password,
          video: value.openCamera ? 1 : 2,
          audio: value.openMic ? 1 : 2,
        })
      } else if (event === 'onFeedbackSuccess') {
        Toast.success(t('thankYourFeedback'))
      } else if (event === 'onFeedbackUpload') {
        setShowLoading(payload.value)
      } else if (event === 'joinMeeting') {
        const { value } = payload

        joinMeeting({
          meetingNum: value.meetingId,
          video: value.openCamera ? 1 : 2,
          audio: value.openMic ? 1 : 2,
        })
      } else if (event === 'joinScheduleMeeting') {
        const { meetingId } = payload

        joinMeeting({
          meetingNum: meetingId,
        })
      } else if (event === 'createOrEditScheduleMeeting') {
        const { value } = payload

        createOrEditScheduleMeeting(value)
      } else if (event === 'cancelScheduleMeeting') {
        const { meetingId, cancelRecurringMeeting } = payload

        cancelScheduleMeeting(meetingId, cancelRecurringMeeting)
      } else if (
        event === 'onMembersChangeHandler' ||
        event === 'onRoleChange' ||
        event === 'onAddressBookConfirmHandler' ||
        event === 'onAddressBookCancelHandler'
      ) {
        if (e.target === getWindow('addressBook')) {
          const scheduleMeetingWindow = getWindow('scheduleMeetingWindow')

          scheduleMeetingWindow?.postMessage({
            event,
            payload,
          })
        }
      } else if (
        event === 'onSaveInterpreters' ||
        event === 'onDeleteScheduleMember' ||
        event === 'onDeleteInterpreterAndAddressBookMember'
      ) {
        const scheduleMeetingWindow = getWindow('scheduleMeetingWindow')

        scheduleMeetingWindow?.postMessage({
          event,
          payload,
        })
      } else if (event === 'confirmDeleteInterpreter') {
        const addressBookWindow = getWindow('addressBook')

        addressBookWindow?.postMessage({
          event: 'showConfirmDeleteInterpreter',
          payload,
        })
      }
    }

    childWindow?.addEventListener('message', messageListener)
  }

  function openImageCrop() {
    const fileInput = document.createElement('input')

    fileInput.type = 'file'
    fileInput.accept = 'image/*'
    fileInput.onchange = (e) => {
      const file = (e.target as HTMLInputElement).files?.[0]

      if (file) {
        const maxAllowedSize = 5 * 1024 * 1024

        if (file?.size > maxAllowedSize) {
          Toast.fail('图片大小不能超过5MB')
          return
        }

        const reader = new FileReader()

        reader.onload = (e) => {
          imageCropValueRef.current = e.target?.result as string
          if (window.isElectronNative) {
            openBeforeMeetingWindow({
              name: 'imageCropWindow',
              postMessageData: {
                event: 'setAvatarImage',
                payload: {
                  image: imageCropValueRef.current,
                },
              },
            })
          } else {
            setImageCropModalOpen(true)
          }
        }

        reader.readAsDataURL(file)
      }
    }

    fileInput.click()
  }

  function openNotificationList() {
    const sessionId = globalConfig?.appConfig.notifySenderAccid

    if (sessionId) {
      NEMeetingKit.actions.neMeeting?.clearUnreadCount(sessionId).then(() => {
        setNotificationMessages([])
      })
    }

    if (window.isElectronNative) {
      openBeforeMeetingWindow({
        name: 'notificationListWindow',
        postMessageData: {
          event: 'windowOpen',
          payload: {
            sessionId,
            isInMeeting: false,
          },
        },
      })
    } else {
      setNotificationListModalOpen(true)
    }
  }

  function handleNotificationClick(action?: string, message?: any) {
    console.log('handleNotificationClick', action, message)
    if (
      action?.startsWith('meeting://meeting_history') ||
      action?.startsWith('meeting://meeting_info')
    ) {
      const urlObj = new URL(action)
      const searchParams = new URLSearchParams(urlObj.search)
      const meetingId = searchParams.get('meetingId')

      if (meetingId) {
        if (action?.startsWith('meeting://meeting_history')) {
          setHistoryMeetingId(meetingId)
          if (window.isElectronNative) {
            openBeforeMeetingWindow({
              name: 'historyWindow',
              postMessageData: {
                event: 'windowOpen',
                payload: {
                  meetingId,
                },
              },
            })
          } else {
            setHistoryMeetingModalOpen(true)
          }
        } else {
          openMeetingDetailInfo(meetingId)
        }
      }
    } else {
      action && onNotificationClickHandler(action, message)
    }
  }

  const onNotificationCardWinOpen = (message) => {
    console.log('onNotificationCardWinOpen', message)
    openBeforeMeetingWindow({
      name: 'notificationCardWindow',
      postMessageData: {
        event: 'updateNotifyCard',
        payload: {
          message,
        },
      },
    })
  }

  function openNPS() {
    const npsString = localStorage.getItem('ne-meeting-nps')

    if (npsString) {
      const nps = JSON.parse(npsString)

      setMeetingId(nps.meetingId)
      if (
        (!nps.time || nps.time < Date.now() - 24 * 60 * 60 * 1000) &&
        nps.need
      ) {
        nps.time = Date.now()
        if (window.isElectronNative) {
          openBeforeMeetingWindow({
            name: 'npsWindow',
            postMessageData: {
              event: 'setNpsInfo',
              payload: {
                meetingId: nps.meetingId,
                nickname: accountInfoRef.current?.nickname,
                appKey,
              },
            },
          })
        } else {
          setNpsModalOpen(true)
        }
      }

      nps.need = false
      localStorage.setItem('ne-meeting-nps', JSON.stringify(nps))
    }
  }

  const expireTip = useMemo(() => {
    if (
      showExpireTip &&
      accountInfo?.serviceBundle.expireTimeStamp &&
      accountInfo.serviceBundle.expireTimeStamp !== -1 &&
      accountInfo?.serviceBundle.expireTimeStamp < Date.now()
    ) {
      return (
        <div className="before-meeting-home-alter">
          <ExclamationCircleFilled />
          <div className="before-meeting-home-alter-content">
            {t('settingServiceBundleExpirationDateTip')}
          </div>
          <CloseOutlined onClick={() => setShowExpireTip(false)} />
        </div>
      )
    }

    return null
  }, [accountInfo?.serviceBundle.expireTimeStamp, showExpireTip, t])

  const tipStrs = useMemo(() => {
    return tipInfo && showTipInfo && !isOffLine ? (
      <div className="before-meeting-home-alter">
        <ExclamationCircleFilled />
        <MeetingPopover
          placement="bottom"
          rootClassName="before-meeting-home-alter-popover"
          content={
            (tipInfo?.title ? `【${tipInfo.title}】` : '') + tipInfo?.content
          }
        >
          <div
            className="before-meeting-home-alter-content"
            style={{
              cursor: tipInfo?.url ? 'pointer' : 'default',
            }}
            onClick={() => {
              if (tipInfo?.url) {
                if (eleIpcIns) {
                  eleIpcIns.sendMessage('open-browser-window', tipInfo.url)
                } else {
                  window.open(tipInfo.url, '_blank')
                }
              }
            }}
          >
            {tipInfo?.title ? `【${tipInfo.title}】` : ''}
            {tipInfo?.content || ''}
          </div>
        </MeetingPopover>
        <CloseOutlined onClick={() => setShowTipInfo(false)} />
      </div>
    ) : null
  }, [tipInfo, showTipInfo, isOffLine, eleIpcIns])

  useEffect(() => {
    if (!window.isElectronNative) {
      openNPS()
    }

    window.ipcRenderer?.on(IPCEvent.openMeetingFeedback, () => {
      onOpenFeedback()
    })
    window.ipcRenderer?.on(IPCEvent.openMeetingAbout, () => {
      openBeforeMeetingWindow({ name: 'aboutWindow' })
    })
    window.ipcRenderer?.on(IPCEvent.changeSetting, (_, setting) => {
      onSettingChange(setting)
    })
    window.ipcRenderer?.on(IPCEvent.needOpenNPS, () => {
      openNPS()
    })
    window.ipcRenderer?.on(IPCEvent.setNPS, (_, meetingId) => {
      setNPS(meetingId)
    })
  }, [])

  useEffect(() => {
    window.addEventListener('online', () => {
      setIsOffLine(false)
      getMeetingList()
      if (window.ipcRenderer && !isLogin.current) {
        window.location.reload()
      }
    })
    window.addEventListener('offline', () => {
      setIsOffLine(true)
    })
    if (!navigator.onLine) {
      setIsOffLine(true)
    }

    window.ipcRenderer?.on(IPCEvent.joinMeetingLoading, (_, loading) => {
      setSubmitLoading(loading)
    })
  }, [])

  // 查询通知消息
  useEffect(() => {
    function onReceiveMessage(message?) {
      const sessionId = globalConfig?.appConfig.notifySenderAccid

      if (sessionId && message?.sessionId === sessionId) {
        if (message.data) {
          const data =
            Object.prototype.toString.call(message.data) === '[object Object]'
              ? message.data
              : JSON.parse(message.data)

          message.data = data
        }

        if (notificationListModalOpen || getWindow('notificationListWindow')) {
          NEMeetingKit.actions.neMeeting?.clearUnreadCount(sessionId)
        } else {
          // 这里需要延迟查询，否则会出现消息获取不了的问题
          setTimeout(
            () => {
              NEMeetingKit.actions.neMeeting
                ?.queryUnreadMessageList(sessionId)
                .then((res) => {
                  setNotificationMessages(res)
                })
            },
            message.messageId ? 1000 : 0
          )
        }
      }
    }

    onReceiveMessage({ sessionId: globalConfig?.appConfig.notifySenderAccid })
    NEMeetingKit.actions.neMeeting?.eventEmitter.on(
      EventType.onSessionMessageReceived,
      onReceiveMessage
    )
    function onSessionMessageRecentChanged(sessions) {
      const sessionId = globalConfig?.appConfig.notifySenderAccid

      if (sessionId) {
        const session = sessions.find((s) => s.sessionId === sessionId)

        if (session?.unreadCount === 0) {
          setNotificationMessages([])
        }
      }
    }

    NEMeetingKit.actions.neMeeting?.eventEmitter.on(
      EventType.onSessionMessageRecentChanged,
      onSessionMessageRecentChanged
    )
    function onDeleteAllSessionMessage(sessionId, sessionType) {
      const notificationListWindow = getWindow('notificationListWindow')

      notificationListWindow?.postMessage(
        {
          event: 'eventEmitter',
          payload: {
            key: EventType.OnDeleteAllSessionMessage,
            args: [sessionId, sessionType],
          },
        },
        notificationListWindow.origin
      )
    }

    function onMeetingInviteStatusChange(
      status: NEMeetingInviteStatus,
      meetingId: string,
      inviteInfo: NEMeetingInviteInfo,
      message: NECustomSessionMessage
    ) {
      if (status === NEMeetingInviteStatus.calling) {
        // 非会中显示的通知
        const data = message.data?.data

        // 如果当前时间大于接收到的消息时间60s则不处理
        if (!data || Date.now() - data.timestamp > 60000) {
          return
        }

        if (window.isElectronNative) {
          console.warn(
            'electronInMeetingRef',
            electronInMeetingRef.current,
            message
          )
          if (!electronInMeetingRef.current) {
            setCustomMessage(message)
          }
        } else {
          setCustomMessage(message)
        }
      } else if (
        status === NEMeetingInviteStatus.rejected ||
        status === NEMeetingInviteStatus.canceled ||
        status === NEMeetingInviteStatus.removed
      ) {
        // 如果多端登录 邀请被拒绝需要同步关闭本端的
        notificationApi.destroy(meetingId)
        // electron 需要关闭多窗口
        if (window.isElectronNative) {
          const notificationCardWindow = getWindow('notificationCardWindow')

          notificationCardWindow?.postMessage(
            {
              event: 'inviteStateChange',
              payload: {
                status,
                meetingId,
              },
            },
            notificationCardWindow.origin
          )
        }
      }
    }

    NEMeetingKit.actions.neMeeting?.eventEmitter.on(
      EventType.OnDeleteAllSessionMessage,
      onDeleteAllSessionMessage
    )
    NEMeetingKit.actions.inviteService?.on(
      EventType.OnMeetingInviteStatusChange,
      //@ts-ignore
      onMeetingInviteStatusChange
    )
    return () => {
      NEMeetingKit.actions.neMeeting?.eventEmitter.off(
        EventType.onSessionMessageReceived,
        onReceiveMessage
      )
      NEMeetingKit.actions.neMeeting?.eventEmitter.off(
        EventType.onSessionMessageRecentChanged,
        onSessionMessageRecentChanged
      )
      NEMeetingKit.actions.neMeeting?.eventEmitter.on(
        EventType.OnDeleteAllSessionMessage,
        onDeleteAllSessionMessage
      )
      NEMeetingKit.actions.inviteService?.off(
        EventType.OnMeetingInviteStatusChange,
        //@ts-ignore
        onMeetingInviteStatusChange
      )
    }
  }, [globalConfig, inMeeting, notificationListModalOpen])

  useEffect(() => {
    NEMeetingKit.actions.neMeeting?.updateMeetingInfo({
      moreBarList: [
        { id: 29 },
        { id: 30 },
        { id: 25 },
        {
          id: 1000,
          btnConfig: {
            icon: FeedbackImg,
            lightIcon: LightFeedbackImg,
            text: i18n.feedback,
          },
          type: 'single',
          injectItemClick: () => {
            setMeetingId(NEMeetingKit.actions.NEMeetingInfo.meetingId)
            setFeedbackModalOpen(true)
          },
        },
        { id: 31 },
      ],
    })
    NEMeetingKit.actions.neMeeting?.switchLanguage(
      // @ts-ignore
      i18next.language || navigator.language
    )
  }, [t])

  function openMeetingDetailInfo(meetingId: string) {
    NEMeetingKit.actions.neMeeting
      ?.getMeetingInfoByMeetingId(meetingId)
      .then((res) => {
        NEMeetingKit.actions.neMeeting
          ?.getMeetingInfoByFetch(res.meetingNum)
          .then((res) => {
            setEditMeeting(res)
            if (window.isElectronNative) {
              openBeforeMeetingWindow({
                name: 'scheduleMeetingWindow',
                postMessageData: {
                  event: 'windowOpen',
                  payload: {
                    nickname: accountInfo.nickname,
                    appLiveAvailable,
                    globalConfig,
                    editMeeting: res,
                  },
                },
              })
            } else {
              setScheduleMeetingModalOpen(true)
            }
          })
      })
      .catch((e) => {
        Toast.fail(e.message || e.msg)
      })
  }

  const [time, setTime] = useState(getCurrentDateTime().time)
  const [date, setDate] = useState(getCurrentDateTime().date)

  useEffect(() => {
    const now = dayjs() // 获取当前时间的dayjs对象
    const currentSecond = now.second() // 获取当前秒数

    const timeout = setTimeout(() => {
      setTime(getCurrentDateTime().time)
      setInterval(() => {
        setTime(getCurrentDateTime().time)
        setDate(getCurrentDateTime().date)
      }, 1000 * 60)
    }, 1000 * (60 - currentSecond))

    const dateInterval = setInterval(() => {
      setDate(getCurrentDateTime().date)
    }, 1000 * 60 * 60 * 24)

    return () => {
      clearTimeout(timeout)
      clearInterval(dateInterval)
    }
  }, [])

  const onOpenImmediateMeeting = () => {
    if (window.isElectronNative) {
      openBeforeMeetingWindow({
        name: 'immediateMeetingWindow',
        postMessageData: {
          event: 'setImmediateMeetingData',
          payload: {
            nickname: accountInfo.nickname,
            avatar: accountInfo.avatar,
            setting,
            meetingNum: accountInfo.meetingNum,
            shortMeetingNum: accountInfo.shortMeetingNum,
          },
        },
      })
    } else {
      setImmediateMeetingModalOpen(true)
    }
  }

  const onOpenScheduleMeeting = () => {
    setEditMeeting(undefined)
    if (window.isElectronNative) {
      openBeforeMeetingWindow({
        name: 'scheduleMeetingWindow',
        postMessageData: {
          event: 'windowOpen',
          payload: {
            nickname: accountInfo.nickname,
            appLiveAvailable,
            globalConfig,
          },
        },
      })
    } else {
      setScheduleMeetingModalOpen(true)
    }
  }

  const onOpenJoinMeeting = (meetingNum?: string) => {
    if (window.isElectronNative) {
      openBeforeMeetingWindow({
        name: 'joinMeetingWindow',
        postMessageData: {
          event: 'setJoinMeetingData',
          payload: {
            nickname: accountInfoRef.current.nickname,
            avatar: accountInfoRef.current.avatar,
            setting: settingRef.current,
            settingOpen,
            invitationMeetingNum: meetingNum || invitationMeetingNum,
            accountId: accountInfoRef.current.account,
          },
        },
      })
      setInvitationMeetingNum('')
    } else {
      setJoinMeetingModalOpen(true)
    }
  }

  useEffect(() => {
    const joinMeetingWindow = getWindow('joinMeetingWindow')

    joinMeetingWindow?.postMessage(
      {
        event: 'setJoinMeetingData',
        payload: {
          setting,
        },
      },
      joinMeetingWindow.origin
    )

    const immediateMeetingWindow = getWindow('immediateMeetingWindow')

    immediateMeetingWindow?.postMessage(
      {
        event: 'setImmediateMeetingData',
        payload: {
          setting,
        },
      },
      immediateMeetingWindow.origin
    )
  }, [setting])

  return (
    <>
      {!inMeeting && (
        <Spin
          spinning={loginLoading || submitLoading}
          wrapperClassName="before-meeting-home-spin"
        >
          <div
            className="before-meeting-home-container"
            id="before-meeting-home"
          >
            <div
              className={classNames('before-meeting-home-container-header', {
                drag: !userMenuOpen,
              })}
            ></div>
            {isOffLine ? (
              <div className="before-meeting-home-network-error">
                <ExclamationCircleFilled />
                <div className="before-meeting-home-alter-content">
                  {i18n.networkError}
                </div>
              </div>
            ) : null}
            {expireTip ? expireTip : tipStrs}
            <div className="before-meeting-home-content-wrap">
              <div className="before-meeting-home-top-buttons">
                <PCTopButtons size="small" maximizable={false} />
              </div>
              <div
                style={{
                  // @ts-ignore
                  borderRadius:
                    window.systemPlatform === 'win32' ? '0' : '10px 0 0 10px',
                }}
                className={classNames('before-meeting-home-left-side', {
                  drag: !userMenuOpen,
                })}
              >
                <div className="before-meeting-home-user-avatar">
                  <Dropdown
                    menu={{ items }}
                    // @ts-ignore
                    placement="right"
                    trigger={['click']}
                    open={userMenuOpen}
                    onOpenChange={(open) => setUserMenuOpen(open)}
                    overlayClassName="before-meeting-home-user-menu"
                    getPopupContainer={() =>
                      document.getElementById(
                        'before-meeting-home'
                      ) as HTMLElement
                    }
                  >
                    <UserAvatar
                      nickname={accountInfo?.nickname}
                      avatar={accountInfo?.avatar}
                      size={36}
                    ></UserAvatar>
                  </Dropdown>
                </div>
                <div className="before-meeting-home-bottom-buttons">
                  <div
                    className="notification-icon"
                    onClick={() => {
                      openNotificationList()
                    }}
                  >
                    <Badge
                      count={
                        notificationMessages.length > 99
                          ? '99+'
                          : notificationMessages.length
                      }
                    >
                      <svg
                        className="icon iconfont iconxiaoxi"
                        aria-hidden="true"
                      >
                        <use xlinkHref="#icontongzhi"></use>
                      </svg>
                    </Badge>
                  </div>
                  <div
                    className="setting-button"
                    onClick={() => {
                      onSettingClick()
                    }}
                  >
                    <svg className="icon iconfont" aria-hidden="true">
                      <use xlinkHref="#iconshezhi1"></use>
                    </svg>
                  </div>
                </div>
              </div>
              <div className="before-meeting-home-middle">
                <div className="before-meeting-home-middle-content">
                  <div className="before-meeting-home-buttons">
                    <div>
                      <div
                        className="meeting-button-img"
                        onClick={onOpenImmediateMeeting}
                      >
                        <div className="icon-wrap">
                          <span className="iconfont-wrap">
                            <svg
                              className="icon iconfont iconfaqihuiyi"
                              aria-hidden="true"
                            >
                              <use xlinkHref="#iconfaqihuiyi"></use>
                            </svg>
                          </span>
                        </div>
                        <span className="text">{i18n.immediateMeeting}</span>
                      </div>
                      <div
                        className="meeting-button-img"
                        onClick={onOpenScheduleMeeting}
                      >
                        <div className="icon-wrap">
                          <span className="iconfont-wrap">
                            <svg
                              className="icon iconfont iconfaqihuiyi"
                              aria-hidden="true"
                            >
                              <use xlinkHref="#iconyuyuehuiyi"></use>
                            </svg>
                          </span>
                        </div>
                        <span className="text">{i18n.scheduleMeeting}</span>
                      </div>
                    </div>
                    <div>
                      <div
                        className="meeting-button-img"
                        onClick={() => {
                          onOpenJoinMeeting()
                        }}
                      >
                        <div className="icon-wrap">
                          <span className="iconfont-wrap">
                            <svg
                              className="icon iconfont iconfaqihuiyi"
                              aria-hidden="true"
                            >
                              <use xlinkHref="#iconjiaruhuiyi"></use>
                            </svg>
                          </span>
                        </div>
                        <span className="text">{i18n.joinMeeting}</span>
                      </div>
                      <div className="meeting-button-img">
                        <div
                          className="icon-wrap"
                          onClick={() => Toast.success(i18n.comingSoon)}
                        >
                          <span className="iconfont-wrap">
                            <svg
                              className="icon iconfont iconfaqihuiyi"
                              aria-hidden="true"
                            >
                              <use xlinkHref="#iconhuiyishitouping"></use>
                            </svg>
                          </span>
                        </div>
                        <span className="text">
                          {i18n.meetingRoomScreenCasting}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div className="before-meeting-home-right">
                <div className="before-meeting-home-right-content">
                  <div
                    className="before-meeting-home-right-header"
                    style={{
                      backgroundImage: `url(${BeforeMeetingHomeHeader})`,
                    }}
                  >
                    <div className="time">{time}</div>
                    <div className="date">
                      <span className="today">{i18n.today}</span>
                      <span>{date}</span>
                    </div>
                  </div>
                  <div
                    className="before-meeting-home-history-button"
                    onClick={() => {
                      if (isOffLine) {
                        Toast.fail(i18n.networkError)
                        return
                      }

                      if (window.isElectronNative) {
                        openBeforeMeetingWindow({
                          name: 'historyWindow',
                          postMessageData: {
                            event: 'windowOpen',
                            payload: {
                              meetingId: '',
                            },
                          },
                        })
                      } else {
                        setHistoryMeetingId('')
                        setHistoryMeetingModalOpen(true)
                      }
                    }}
                  >
                    <span className="history-meeting-title">
                      {i18n.historyMeeting}
                    </span>
                    <span className="icon-jiantou">
                      <svg className="icon iconfont" aria-hidden="true">
                        <use xlinkHref="#iconyoujiantou-16px-2"></use>
                      </svg>
                    </span>
                  </div>
                  <div className="schedule-meeting-list-container-wrap">
                    {meetingListGroupByDate.length > 0 ? (
                      <div className="schedule-meeting-list-container">
                        {meetingListGroupByDate.map((item) => (
                          <div
                            className="schedule-meeting-group-item"
                            key={item.date}
                          >
                            {formatScheduleMeetingDateTitle(Number(item.date))}
                            {item.list.map((meeting) => (
                              <div
                                className="schedule-meeting-item"
                                key={meeting.meetingCode}
                              >
                                <div className="schedule-meeting-item-content">
                                  <div className="top">
                                    <div className="schedule-meeting-item-subject">
                                      <span
                                        className="schedule-meeting-item-subject-text"
                                        style={{
                                          fontWeight:
                                            window.systemPlatform === 'win32'
                                              ? 'bold'
                                              : '500',
                                        }}
                                      >
                                        {meeting.subject}
                                      </span>
                                      {meeting.recurringRule &&
                                        meeting.recurringRule.type !==
                                          MeetingRepeatType.NoRepeat && (
                                          <Tag
                                            color="#EBF2FF"
                                            className="periodic-tag"
                                            style={{
                                              lineHeight:
                                                window.systemPlatform == 'win32'
                                                  ? '20px'
                                                  : '19px',
                                            }}
                                          >
                                            {t('meetingRepeat')}
                                          </Tag>
                                        )}
                                    </div>

                                    <div className="schedule-meeting-item-buttons">
                                      <Button
                                        className="schedule-meeting-item-button-join"
                                        type="primary"
                                        onClick={() => {
                                          setSubmitLoading(true)
                                          joinMeeting({
                                            meetingNum: meeting.meetingNum,
                                          })
                                        }}
                                      >
                                        {i18n.join}
                                      </Button>
                                      <div className="more">
                                        <svg
                                          onClick={() => {
                                            NEMeetingKit.actions.neMeeting
                                              ?.getMeetingInfoByFetch(
                                                meeting.meetingNum
                                              )
                                              .then((res) => {
                                                eventEmitter.emit(
                                                  EventType.OnScheduledMeetingPageModeChanged,
                                                  'detail'
                                                )
                                                setEditMeeting(res)
                                                openMeetingDetailMeetingNumRef.current =
                                                  meeting.meetingNum
                                                if (window.isElectronNative) {
                                                  openBeforeMeetingWindow({
                                                    name: 'scheduleMeetingWindow',
                                                    postMessageData: {
                                                      event: 'windowOpen',
                                                      payload: {
                                                        nickname:
                                                          accountInfo.nickname,
                                                        appLiveAvailable,
                                                        globalConfig,
                                                        editMeeting: res,
                                                      },
                                                    },
                                                  })
                                                } else {
                                                  setScheduleMeetingModalOpen(
                                                    true
                                                  )
                                                }
                                              })
                                              .catch((e) => {
                                                Toast.fail(e.message || e.msg)
                                              })
                                          }}
                                          className="icon iconfont iconyx-tv-more1x"
                                          aria-hidden="true"
                                        >
                                          <use xlinkHref="#iconyx-tv-more1x"></use>
                                        </svg>
                                      </div>
                                    </div>
                                  </div>
                                  <div className="bottom">
                                    <span className="dur-time">
                                      {dayjs(Number(meeting.startTime)).format(
                                        'HH:mm'
                                      )}
                                      {'-'}
                                      {dayjs(Number(meeting.endTime)).format(
                                        'HH:mm'
                                      )}
                                    </span>
                                    <div className="line"></div>
                                    <MeetingPopover
                                      content={i18n.copyMeetingIdTip}
                                      trigger="hover"
                                    >
                                      <div
                                        className="meeting-id"
                                        onClick={() =>
                                          copyElementValue(
                                            meeting.meetingNum,
                                            () => {
                                              Toast.success(i18n.copySuccess)
                                            }
                                          )
                                        }
                                      >
                                        <span>
                                          {getMeetingDisplayId(
                                            meeting.meetingNum
                                          )}
                                        </span>
                                      </div>
                                    </MeetingPopover>

                                    <div className="line"></div>
                                    <span
                                      className={
                                        meeting.state === 1
                                          ? 'in-ready-state'
                                          : meeting.state === 2
                                          ? `in-progress-state`
                                          : 'in-end-state'
                                      }
                                    >
                                      {
                                        [
                                          i18n.notStarted,
                                          i18n.inProgress,
                                          i18n.ended,
                                        ][meeting.state - 1]
                                      }
                                    </span>
                                  </div>
                                </div>
                              </div>
                            ))}
                          </div>
                        ))}
                      </div>
                    ) : (
                      <div className="before-meeting-home-empty-schedule-meeting">
                        <img
                          className="empty-schedule-meeting-img"
                          src={EmptyScheduleMeetingImg}
                          alt=""
                        />
                        <span className="text">
                          {i18n.emptyScheduleMeeting}
                        </span>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </div>

            <ImmediateMeetingModal
              previewController={previewController}
              setting={setting}
              nickname={accountInfo?.nickname}
              avatar={accountInfo?.avatar}
              onSettingChange={onSettingChange}
              meetingNum={accountInfo?.meetingNum}
              shortMeetingNum={accountInfo?.shortMeetingNum}
              open={immediateMeetingModalOpen}
              onCancel={() => setImmediateMeetingModalOpen(false)}
              submitLoading={submitLoading}
              onOpenSetting={(tab) => {
                onSettingClick(tab)
              }}
              onSummit={(value) => {
                return createMeeting({
                  meetingNum: value.meetingId,
                  password: value.password,
                  video: value.openCamera ? 1 : 2,
                  audio: value.openMic ? 1 : 2,
                })
              }}
            />

            <JoinMeetingModal
              wrapClassName="join-meeting-modal-wrap"
              previewController={previewController}
              setting={setting}
              nickname={accountInfo?.nickname}
              avatar={accountInfo?.avatar}
              settingOpen={settingOpen}
              onSettingChange={onSettingChange}
              open={joinMeetingModalOpen}
              getContainer={false}
              onCancel={() => setJoinMeetingModalOpen(false)}
              afterClose={() => setInvitationMeetingNum('')}
              meetingNum={invitationMeetingNum}
              submitLoading={submitLoading}
              recentMeetingList={
                JSON.parse(localStorage.getItem(LOCAL_STORAGE_KEY) || '{}')[
                  accountInfo?.account
                ] || []
              }
              onClearRecentMeetingList={() => {
                const localStorageData = JSON.parse(
                  localStorage.getItem(LOCAL_STORAGE_KEY) || '{}'
                )

                delete localStorageData[accountInfo?.account]
                localStorage.setItem(
                  LOCAL_STORAGE_KEY,
                  JSON.stringify(localStorageData)
                )
              }}
              onOpenSetting={(tab) => {
                onSettingClick(tab)
              }}
              onSummit={(value) => {
                setSubmitLoading(true)
                joinMeeting({
                  meetingNum: value.meetingId,
                  video: value.openCamera ? 1 : 2,
                  audio: value.openMic ? 1 : 2,
                })
              }}
            />
            <ScheduleMeetingModal
              neMeeting={NEMeetingKit.actions.neMeeting}
              nickname={accountInfo?.nickname}
              open={scheduleMeetingModalOpen}
              submitLoading={submitLoading}
              appLiveAvailable={appLiveAvailable}
              globalConfig={globalConfig}
              eventEmitter={eventEmitter}
              meeting={editMeeting}
              onCancel={() => setScheduleMeetingModalOpen(false)}
              onJoinMeeting={(meetingId) => {
                joinMeeting({
                  meetingNum: meetingId,
                })
              }}
              onCancelMeeting={(cancelRecurringMeeting) => {
                editMeeting &&
                  cancelScheduleMeeting(
                    String(editMeeting.meetingId),
                    cancelRecurringMeeting
                  )
              }}
              onSummit={(value) => {
                setSubmitLoading(true)
                createOrEditScheduleMeeting(value)
              }}
            />
            <HistoryMeetingModal
              open={historyMeetingModalOpen}
              onCancel={() => {
                setHistoryMeetingModalOpen(false)
              }}
              roomService={roomService}
              neMeeting={NEMeetingKit.actions.neMeeting}
              accountId={accountInfo?.account}
              meetingId={historyMeetingId}
              eventEmitter={eventEmitter}
            />

            {previewController && !window.ipcRenderer && (
              <Setting
                defaultTab={settingModalTab}
                destroyOnClose={true}
                setting={setting}
                onSettingChange={onSettingChange}
                previewController={previewController}
                open={settingOpen}
                onCancel={() => setSettingOpen(false)}
              />
            )}
            <UpdateUserNicknameModal
              nickname={accountInfo?.nickname}
              open={updateUserNicknameModalOpen}
              onCancel={() => setUpdateUserNicknameModalOpen(false)}
              onSummit={(value) => {
                setUpdateUserNicknameModalOpen(false)
                NEMeetingKit.actions.neMeeting
                  ?.updateUserNickname(value.nickname)
                  .then(() => {
                    Toast.success(i18n.updateUserNicknameSuccess)
                    setAccountInfo({
                      ...accountInfo,
                      nickname: value.nickname,
                    })
                    updateLocalStorageUserInfo({ nickname: value.nickname })
                  })
                  .catch(() => {
                    Toast.fail(i18n.updateUserNicknameFail)
                  })
              }}
            />
            <AboutModal
              open={aboutModalOpen}
              onCancel={() => setAboutModalOpen(false)}
            />
          </div>
        </Spin>
      )}
      {inMeeting && eleIpcIns && !window.isElectronNative && (
        <div className="meeting-electron-header-drag-bar">
          <div className="drag-region" />
          {document.title}
          <PCTopButtons />
        </div>
      )}
      {contextHolder}
      <div
        id="ne-web-meeting"
        style={
          !!eleIpcIns && !window.isElectronNative
            ? {
                position: 'absolute',
                top: 28,
                left: 0,
                right: 0,
                width: '100%',
                height: 'calc(100% - 28px)',
                display: inMeeting ? 'block' : 'none',
              }
            : {
                width: '100%',
                height: '100%',
                display: inMeeting ? 'block' : 'none',
              }
        }
      />
      <FeedbackModal
        visible={feedbackModalOpen}
        meetingId={meetingId}
        nickname={accountInfo?.nickname}
        appKey={appKey}
        onClose={() => setFeedbackModalOpen(false)}
        neMeeting={NEMeetingKit.actions.neMeeting}
        loadingChange={(flag) => setShowLoading(flag)}
        systemAndManufacturer={systemAndManufacturer}
      />
      {privateConfig?.module?.nps.enabled !== false && (
        <NPSModal
          visible={npsModalOpen}
          meetingId={meetingId}
          nickname={accountInfo?.nickname}
          appKey={appKey}
          onClose={() => setNpsModalOpen(false)}
        />
      )}

      <NotificationListModal
        neMeeting={NEMeetingKit.actions.neMeeting}
        sessionId={globalConfig?.appConfig.notifySenderAccid}
        open={notificationListModalOpen}
        eventEmitter={NEMeetingKit.actions.neMeeting?.eventEmitter}
        onCancel={() => setNotificationListModalOpen(false)}
        onClick={handleNotificationClick}
      />
      <MeetingNotification
        onClick={onNotificationClickHandler}
        beforeMeeting={true}
        beforeMeetingJoin={joinRoomByInvite}
        notification={notificationApi}
        customMessage={customMessage || undefined}
        neMeeting={NEMeetingKit.actions.neMeeting}
        onNotificationCardWinOpen={onNotificationCardWinOpen}
      />
      <ImageCropModal
        image={imageCropValueRef.current}
        open={imageCropModalOpen}
        neMeeting={NEMeetingKit.actions.neMeeting}
        onCancel={() => setImageCropModalOpen(false)}
        onUpdate={(avatar) => {
          setAccountInfo({
            ...accountInfo,
            avatar,
          })
          setImageCropModalOpen(false)
          Toast.success(t('settingAvatarUpdateSuccess'))
        }}
      />
      {showLoading && (
        <p className="nemeeting-feedback-loading-text">
          {i18n.uploadLoadingText}
        </p>
      )}
    </>
  )
}

export default BeforeMeetingHome

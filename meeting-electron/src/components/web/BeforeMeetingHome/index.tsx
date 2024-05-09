import React, { useEffect, useMemo, useRef, useState } from 'react'

import CloseOutlined from '@ant-design/icons/CloseOutlined'
import EditOutlined from '@ant-design/icons/EditOutlined'
import ExclamationCircleFilled from '@ant-design/icons/ExclamationCircleFilled'
import RightOutlined from '@ant-design/icons/RightOutlined'
import { Badge, Button, Dropdown, Input, MenuProps, Spin, Tag } from 'antd'
import dayjs from 'dayjs'
import { useTranslation } from 'react-i18next'

import EmptyScheduleMeetingImg from '../../../assets/empty-schedule-meeting.png'
import FeedbackImg from '../../../assets/feedback.png'
import ImmediateMeetingImg from '../../../assets/immediate-meeting.jpg'
import JoinMeetingImg from '../../../assets/join-meeting.jpg'
import LightFeedbackImg from '../../../assets/light-feedback.png'
import ScheduleMeetingImg from '../../../assets/schedule-meeting.jpg'
import NEMeetingKit from '../../../index'

import { copyElementValue, getMeetingDisplayId } from '../../../utils'
import AboutModal from '../BeforeMeetingModal/AboutModal'
import HistoryMeetingModal from '../BeforeMeetingModal/HistoryMeetingModal'
import ImmediateMeetingModal from '../BeforeMeetingModal/ImmediateMeetingModal'
import JoinMeetingModal from '../BeforeMeetingModal/JoinMeetingModal'
import ScheduleMeetingModal from '../BeforeMeetingModal/ScheduleMeetingModal'
import UpdateUserNicknameModal from '../BeforeMeetingModal/UpdateUserNicknameModal'
import Feedback from '../Feedback'
import NPS from '../NPS'
import Setting from '../Setting'
import './index.less'

import Eventemitter from 'eventemitter3'
import {
  LOCALSTORAGE_INVITE_MEETING_URL,
  LOCALSTORAGE_USER_INFO,
  NOT_FIRST_LOGIN,
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
import { NEMeetingStatus } from '../../../types/type'
import { getWindow, openWindow } from '../../../utils/windowsProxy'
import UserAvatar from '../../common/Avatar'
import Modal from '../../common/Modal'
import PCTopButtons from '../../common/PCTopButtons'
import Toast from '../../common/toast'
import ImageCropModal from '../BeforeMeetingModal/ImageCropModal'
import NotificationListModal from '../BeforeMeetingModal/NotificationListModal'
import { SettingTabType } from '../Setting/Setting'

const eventEmitter = new Eventemitter()

let appKey = ''
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
  }

  const passwordRef = React.useRef<string>('')

  const scheduleMeetingContainerRef = React.useRef<HTMLDivElement>(null)

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
  const [meetingId, setMeetingId] = useState<string>('')
  const [appName, setAppName] = useState<string>('')
  const [tipInfo, setTipInfo] = useState<{
    content: string
    title: string
    url: string
  }>()
  const [appLiveAvailable, setAppLiveAvailable] = useState<boolean>(false)
  const [showTipInfo, setShowTipInfo] = useState<boolean>(true)
  const [scheduleMeetingContainerHeight, setScheduleMeetingContainerHeight] =
    useState<number>(372)
  const [isOffLine, setIsOffLine] = useState<boolean>(false)
  const [isSSOLogin, setIsSSOLogin] = useState<boolean>(false)
  const isLogin = useRef<boolean>(false)
  const [historyMeetingId, setHistoryMeetingId] = useState<string>()

  const eleIpcIns = useMemo(() => eleIpc.getInstance(), [])
  const [showLoading, setShowLoading] = useState<boolean>(false)
  const [systemAndManufacturer, setSystemAndManufacturer] = useState<{
    manufacturer: string
    version: string
    model: string
  }>()
  const [globalConfig, setGlobalConfig] =
    useState<GetMeetingConfigResponse | null>(null)
  const platform = eleIpcIns ? 'electron' : 'web'
  const previewRoomListenerRef = useRef<any>(null)
  const [invitationMeetingNum, setInvitationMeetingNum] = useState<string>('')
  const [notificationMessages, setNotificationMessages] = useState<
    NECustomSessionMessage[]
  >([])
  const { handlePostMessage } = usePostMessageHandle()
  function getMeetingIdFromUrl(url) {
    const match = url.match(/meetingId=([^&]+)/)
    return match ? match[1] : null
  }

  const imageCropValueRef = useRef<string>('')

  useEffect(() => {
    let setting: any = localStorage.getItem('ne-meeting-setting')
    if (setting) {
      try {
        setting = JSON.parse(setting)
      } catch (error) {}
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
    window.ipcRenderer?.on('electron-join-meeting', (e, url) => {
      handleInvitationUrl(url)
    })
  }, [])

  function handleInvitationUrl(url: string) {
    let meetingNum = ''
    if (window.isElectronNative) {
      meetingNum = getMeetingIdFromUrl(url)
    } else {
      const query = qs.parse(url.split('?')[1]?.split('#/')[0])
      meetingNum = query.meetingId as string
    }
    if (meetingNum) {
      setInvitationMeetingNum(meetingNum)
      setJoinMeetingModalOpen(true)
      setImmediateMeetingModalOpen(false)
      setScheduleMeetingModalOpen(false)
      setFeedbackModalOpen(false)
      setUpdateUserNicknameModalOpen(false)
    }
  }

  useEffect(() => {
    window.ipcRenderer?.invoke('get-system-manufacturer').then((res) => {
      setSystemAndManufacturer(res)
    })
  }, [])
  useEffect(() => {
    if (window.isElectronNative) {
      function handle(_: any, data: any) {
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

  const items: MenuProps['items'] = [
    {
      key: '1',
      label: (
        <div className="user-menu-item">
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
          <div className="user-name">{accountInfo?.nickname}</div>
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
      ),
    },
    {
      key: '2',
      label: (
        <div className="nemeeting-open-meeting-info-wrap">
          <div className="user-menu-item user-menu-item-info normal-item">
            <div className="title">{i18n.currentVersion}</div>
            <div className="sub-title">{appName}</div>
          </div>
          {accountInfo?.serviceBundle && (
            <div className="nemeeting-open-meeting-info">
              <div className="you-can-open">{i18n.youCanOpen}</div>
              <div className="meeting-limit-info">
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
          )}
        </div>
      ),
    },
    {
      key: '2.5',
      label: (
        <div className="user-menu-item normal-item">
          <div className="title">
            {i18n.personalShortMeetingNum}
            &nbsp;
            <Tag color="#EBF2FF" className="custom-tag">
              {i18n.internalUse}
            </Tag>
          </div>
          <div className="sub-title">
            {accountInfo?.shortMeetingNum}
            <svg
              onClick={() => {
                copyElementValue(accountInfo?.shortMeetingNum, () => {
                  Toast.success(i18n.copySuccess)
                })
              }}
              className="icon icon-blue iconfont"
              aria-hidden="true"
            >
              <use xlinkHref="#iconcopy1x"></use>
            </svg>
          </div>
        </div>
      ),
      hidden: !accountInfo?.shortMeetingNum,
    },
    {
      key: '3',
      label: (
        <div className="user-menu-item normal-item">
          <div className="title">{i18n.personalMeetingNum}</div>
          <div className="sub-title">
            {getMeetingDisplayId(accountInfo?.meetingNum)}
            <svg
              onClick={() => {
                copyElementValue(accountInfo?.meetingNum, () => {
                  Toast.success(i18n.copySuccess)
                })
              }}
              className="icon icon-blue iconfont"
              aria-hidden="true"
            >
              <use xlinkHref="#iconcopy1x"></use>
            </svg>
          </div>
        </div>
      ),
    },
    {
      key: '4',
      label: (
        <div
          className="user-menu-item normal-item"
          style={{ cursor: 'pointer' }}
          onClick={() => {
            setUserMenuOpen(false)
            setFeedbackModalOpen(true)
          }}
        >
          <div className="title">{i18n.feedback}</div>
          <div className="sub-title">
            <RightOutlined />
          </div>
        </div>
      ),
    },
    {
      key: '5',
      label: (
        <div
          className="user-menu-item normal-item"
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
          <div className="title">{i18n.about}</div>
          <div className="sub-title">
            <RightOutlined />
          </div>
        </div>
      ),
    },
    {
      key: '6',
      label: (
        <div className="user-menu-item" style={{ cursor: 'pointer' }}>
          <div
            className="logout-button"
            onClick={() => {
              setUserMenuOpen(false)
              handleLogoutModal()
            }}
          >
            {i18n.logout}
          </div>
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

  function init(cb) {
    const config = {
      appKey: appKey, //云信服务appkey
      meetingServerDomain: domain, //会议服务器地址，支持私有化部署
      locale: i18next.language, //语言
    }
    console.log('init config ', config)
    if (NEMeetingKit.actions.isInitialized) {
      cb()
      return
    }
    NEMeetingKit.actions.init(0, 0, config, cb) // （width，height）单位px 建议比例4:3
    NEMeetingKit.actions.on('onMeetingStatusChanged', (status: number) => {
      if (status === NEMeetingStatus.MEETING_STATUS_IN_WAITING_ROOM) {
        // 到等候室
        setFeedbackModalOpen(false)
      } else if (status === NEMeetingStatus.MEETING_STATUS_FAILED) {
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
          window.ipcRenderer?.send('beforeEnterRoom')
        } else {
          window.location.reload()
        }
      }, 1500)
    })
  }

  function createMeeting(options: CreateOptions) {
    setSubmitLoading(true)
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
    if (window.isElectronNative) {
      setSubmitLoading(false)
      window.ipcRenderer?.send(IPCEvent.enterRoom, {
        joinType: 'create',
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
        showCloudRecordingUI: false,
        avatar: options.avatar,
        watermarkConfig: {
          name: accountInfo.nickname,
        },
        moreBarList: [
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
              setFeedbackModalOpen(true)
            },
          },
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

  function scheduleMeeting({
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
  }) {
    setSubmitLoading(true)
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
        attendeeAudioOffType,
        enableWaitingRoom,
        enableJoinBeforeHost,
        recurringRule,
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
      })
      .catch((error) => {
        // 会议已不存在则关闭弹窗
        if (error.code === 3104) {
          setScheduleMeetingModalOpen(false)
        }
        setSubmitLoading(false)
        Toast.fail(
          error.msg ||
            (navigator.onLine ? i18n.scheduleMeetingFail : i18n.networkError)
        )
      })
  }

  async function joinMeeting(options: JoinOptions) {
    setSubmitLoading(true)
    setImmediateMeetingModalOpen(false)
    setScheduleMeetingModalOpen(false)
    await NEMeetingKit.actions.neMeeting
      ?.getMeetingInfoByFetch(options.meetingNum)
      .catch((e) => {
        console.error('join failed', options.meetingNum, e)
        // 非密码错误
        if (e?.code != 1020) {
          setSubmitLoading(false)
          Toast.fail(e.message || e.msg || e.code)
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
        joinType: 'join',
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
        NEMeetingKit.actions.join(
          {
            ...options,
            showCloudRecordingUI: false,
            showMeetingRemainingTip: true,
            env: platform,
            watermarkConfig: {
              name: accountInfo.nickname,
            },
            moreBarList: [
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
                  setFeedbackModalOpen(true)
                },
              },
            ],
          },
          function (e: any) {
            if (e) {
              reject(e)
            }
            resolve()
          }
        )
      })
    }

    let modal: any

    return fetchJoin(options)
      .then(() => {
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
                  // 账号受到限制
                  if (res.data?.type === 200) {
                    Toast.warning(i18n.tokenExpired, 3000)
                    setTimeout(() => {
                      logout()
                    }, 1000)
                  } else {
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
                window.ipcRenderer?.send('isStartByUrl')
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
                        window.ipcRenderer?.send(
                          IPCEvent.enterRoom,
                          currentMeeting
                        )
                      } catch {}
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
        const groupedData = data.reduce(
          (acc: Record<string, CreateMeetingResponse[]>, obj) => {
            const key = dayjs(obj.startTime).startOf('day').valueOf()
            if (!acc[key]) {
              acc[key] = []
            }
            acc[key].push(obj)
            return acc
          },
          {}
        )
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
    const date = dayjs(time).format('DD')
    const month = dayjs(time).month() + 1
    const weekday =
      dayjs(time) < dayjs().endOf('day')
        ? i18n.today
        : dayjs(time) < dayjs().add(1, 'day').endOf('day')
        ? i18n.tomorrow
        : weekdays[dayjs(time).day()]

    return (
      <div className="schedule-meeting-group-date">
        <span className="date">{date}</span>
        <span className="month">
          {month}
          {i18n.month}
        </span>
        <span className="weekday">{weekday}</span>
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
          '*'
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
          '*'
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
        eventEmitter.emit(
          EventType.previewVideoFrameData,
          uuid,
          bSubVideo,
          data,
          type,
          width,
          height
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
          '*',
          [data.bytes.buffer]
        )
        window.ipcRenderer?.send('previewControllerListener', {
          method: EventType.previewVideoFrameData,
          args: [uuid, bSubVideo, data, type, width, height],
        })
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
        setIsSSOLogin(user.loginType === 'SSO')
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
      } catch (error) {}
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [inMeeting])

  useEffect(() => {
    if (inMeeting) {
      removePreviewRoomListener()
    } else {
      if (!!previewController) {
        addPreviewRoomListener()
        return () => {
          removePreviewRoomListener()
        }
      }
    }
  }, [inMeeting, previewController])

  useEffect(() => {
    if (editMeeting) {
      meetingListGroupByDate.forEach((item) => {
        const meeting = item.list.find(
          (i) => i.meetingId === editMeeting.meetingId
        )
        if (meeting) {
          setEditMeeting(meeting)
        }
      })
    }
  }, [editMeeting, meetingListGroupByDate])

  document.title = i18n.appTitle

  function onSettingClick(type?: 'normal' | 'audio' | 'video' | 'beauty') {
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
        newWindow?.postMessage(payload.postMessageData, '*')
    }
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
      } else if (event === 'notificationClick') {
        console.log('notificationClick', payload)
        handleNotificationClick(payload.action)
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
  function handleNotificationClick(action?: string) {
    if (action?.startsWith('meeting://meeting_history')) {
      const urlObj = new URL(action)
      const searchParams = new URLSearchParams(urlObj.search)
      const meetingId = searchParams.get('meetingId')
      if (meetingId) {
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
      }
    }
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

  const tipStrs = useMemo(() => {
    return tipInfo && showTipInfo && !isOffLine ? (
      <div className="before-meeting-home-alter">
        <ExclamationCircleFilled />
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
        <CloseOutlined onClick={() => setShowTipInfo(false)} />
      </div>
    ) : null
  }, [tipInfo, showTipInfo, isOffLine, eleIpcIns])

  useEffect(() => {
    const top = scheduleMeetingContainerRef?.current?.offsetTop || 0
    window.isElectronNative
      ? setScheduleMeetingContainerHeight(650 - top)
      : setScheduleMeetingContainerHeight(650 - top)
  }, [tipStrs, showTipInfo, scheduleMeetingContainerRef?.current?.offsetTop])

  useEffect(() => {
    if (!window.isElectronNative) {
      openNPS()
    }
    window.ipcRenderer?.on('open-meeting-feedback', () => {
      setFeedbackModalOpen(true)
    })
    window.ipcRenderer?.on(IPCEvent.changeSetting, (event, setting) => {
      onSettingChange(setting)
    })
    window.ipcRenderer?.on(IPCEvent.needOpenNPS, (event, _) => {
      openNPS()
    })
    window.ipcRenderer?.on(IPCEvent.setNPS, (event, meetingId) => {
      setNPS(meetingId)
    })
  }, [])

  useEffect(() => {
    window.addEventListener('online', () => {
      setIsOffLine(false)
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

    window.ipcRenderer?.on('NERoomSDKProxy', (_, value) => {
      const { method, data } = value
      if (method === 'roomService') {
        const roomService = NEMeetingKit.actions.neMeeting?.roomService
        if (roomService) {
          const { fnKey, args, replyKey } = data
          const fn = roomService[fnKey]
          if (fn && fn.apply) {
            fn.apply(roomService, args)
              .then((res) => {
                window.ipcRenderer?.send('NERoomSDKProxyReply', {
                  data: {
                    replyKey,
                    fnKey,
                    result: res,
                    error: null,
                  },
                })
              })
              .catch((error) => {
                window.ipcRenderer?.send('NERoomSDKProxyReply', {
                  method,
                  data: {
                    replyKey,
                    fnKey,
                    error: error,
                  },
                })
              })
          }
        }
      }
    })
  }, [])

  // 查询通知消息
  useEffect(() => {
    function onReceiveMessage(message?) {
      const sessionId = globalConfig?.appConfig.notifySenderAccid
      if (sessionId && message?.sessionId === sessionId) {
        // 这里需要延迟查询，否则会出现消息获取不了的问题
        setTimeout(
          () => {
            NEMeetingKit.actions.neMeeting
              ?.queryUnreadMessageList(sessionId)
              .then((res) => {
                setNotificationMessages(res)
              })
          },
          message.messageId ? 3000 : 0
        )
      }
    }
    onReceiveMessage({ sessionId: globalConfig?.appConfig.notifySenderAccid })
    NEMeetingKit.actions.neMeeting?.eventEmitter.on(
      EventType.OnReceiveSessionMessage,
      onReceiveMessage
    )
    function onChangeRecentSession(sessions) {
      console.log('onChangeRecentSession', sessions)
      const sessionId = globalConfig?.appConfig.notifySenderAccid
      if (sessionId) {
        const session = sessions.find((s) => s.sessionId === sessionId)
        if (session?.unreadCount === 0) {
          setNotificationMessages([])
        }
      }
    }
    NEMeetingKit.actions.neMeeting?.eventEmitter.on(
      EventType.OnChangeRecentSession,
      onChangeRecentSession
    )
    function onDeleteAllSessionMessage(sessionId, sessionType) {
      console.log('onDeleteAllSessionMessage', sessionId, sessionType)
      const notificationListWindow = getWindow('notificationListWindow')
      notificationListWindow?.postMessage({
        event: 'eventEmitter',
        payload: {
          key: EventType.OnDeleteAllSessionMessage,
          args: [sessionId, sessionType],
        },
      })
    }
    NEMeetingKit.actions.neMeeting?.eventEmitter.on(
      EventType.OnDeleteAllSessionMessage,
      onDeleteAllSessionMessage
    )
    return () => {
      NEMeetingKit.actions.neMeeting?.eventEmitter.off(
        EventType.OnReceiveSessionMessage,
        onReceiveMessage
      )
      NEMeetingKit.actions.neMeeting?.eventEmitter.off(
        EventType.OnChangeRecentSession,
        onChangeRecentSession
      )
      NEMeetingKit.actions.neMeeting?.eventEmitter.on(
        EventType.OnDeleteAllSessionMessage,
        onDeleteAllSessionMessage
      )
    }
  }, [globalConfig])

  useEffect(() => {
    NEMeetingKit.actions.neMeeting?.updateMeetingInfo({
      moreBarList: [
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
            setFeedbackModalOpen(true)
          },
        },
      ],
    })
    NEMeetingKit.actions.neMeeting?.switchLanguage(
      // @ts-ignore
      i18next.language || navigator.language
    )
  }, [t])

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
            <div className="electron-drag-bar">
              <div className="drag-region" />
              {i18n.appTitle}
              <PCTopButtons maximizable={false} />
            </div>
            <div className="before-meeting-home-content">
              <div className="before-meeting-home-header">
                <div className="nemeeting-header-item">
                  <Dropdown
                    menu={{ items }}
                    placement="bottomLeft"
                    trigger={['click']}
                    open={userMenuOpen}
                    onOpenChange={(open) => setUserMenuOpen(open)}
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
                <div className="nemeeting-header-item">
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
                      <svg className="icon iconfont" aria-hidden="true">
                        <use xlinkHref="#icontongzhizhongxinrukou"></use>
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
                      <use xlinkHref="#iconyx-tv-settingx1"></use>
                    </svg>
                  </div>
                </div>
              </div>
              {isOffLine ? (
                <div className="before-meeting-home-network-error">
                  <ExclamationCircleFilled />
                  <div className="before-meeting-home-alter-content">
                    {i18n.networkError}
                  </div>
                </div>
              ) : null}
              {tipStrs}
              <div className="before-meeting-home-buttons">
                <div
                  className="meeting-button"
                  onClick={() => setImmediateMeetingModalOpen(true)}
                >
                  <img src={ImmediateMeetingImg} alt="" />
                  <span>{i18n.immediateMeeting}</span>
                </div>
                <div
                  className="meeting-button"
                  onClick={() => {
                    setJoinMeetingModalOpen(true)
                  }}
                >
                  <img src={JoinMeetingImg} alt="" />
                  <span>{i18n.joinMeeting}</span>
                </div>
                <div
                  className="meeting-button"
                  onClick={() => {
                    setEditMeeting(undefined)
                    setScheduleMeetingModalOpen(true)
                  }}
                >
                  <img src={ScheduleMeetingImg} alt="" />
                  <span>{i18n.scheduleMeeting}</span>
                </div>
              </div>

              <div
                ref={scheduleMeetingContainerRef}
                className="before-meeting-home-schedule-meeting-container"
                style={{
                  height: scheduleMeetingContainerHeight,
                }}
              >
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
                  {i18n.historyMeeting}
                </div>
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
                            <svg
                              className="icon iconfont iconcalendar1x"
                              aria-hidden="true"
                            >
                              <use xlinkHref="#iconcalendar1x"></use>
                            </svg>
                            <div className="schedule-meeting-item-content">
                              <div className="top">
                                <span className="time">
                                  {dayjs(Number(meeting.startTime)).format(
                                    'HH:mm'
                                  )}
                                </span>
                                &nbsp;&nbsp;|&nbsp;&nbsp;{i18n.meetingId}:&nbsp;
                                {getMeetingDisplayId(meeting.meetingNum)}
                                &nbsp;&nbsp;
                                {meeting.recurringRule &&
                                  meeting.recurringRule.type !==
                                    MeetingRepeatType.NoRepeat && (
                                    <Tag
                                      color="#EBF2FF"
                                      className="periodic-tag"
                                    >
                                      {t('meetingRepeat')}
                                    </Tag>
                                  )}
                                <span
                                  className={
                                    meeting.state === 2
                                      ? `in-progress-state`
                                      : ''
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
                              <div className="bottom">
                                <div className="schedule-meeting-item-subject">
                                  {meeting.subject}
                                </div>
                                <div className="schedule-meeting-item-buttons">
                                  <Button
                                    className="schedule-meeting-item-button"
                                    onClick={() => {
                                      setSubmitLoading(true)
                                      joinMeeting({
                                        meetingNum: meeting.meetingNum,
                                        nickName: accountInfo.nickname,
                                        avatar: accountInfo.avatar,
                                        enableVideoMirror:
                                          setting?.videoSetting
                                            .enableVideoMirroring,
                                        video: setting?.normalSetting.openVideo
                                          ? 1
                                          : 2,
                                        audio: setting?.normalSetting.openAudio
                                          ? 1
                                          : 2,
                                        showSpeaker:
                                          setting?.normalSetting
                                            .showSpeakerList,
                                        enableUnmuteBySpace:
                                          setting?.audioSetting
                                            .enableUnmuteBySpace,
                                        showDurationTime:
                                          setting?.normalSetting
                                            .showDurationTime,
                                      })
                                    }}
                                  >
                                    {i18n.join}
                                  </Button>
                                  <svg
                                    onClick={() => {
                                      NEMeetingKit.actions.neMeeting
                                        ?.getMeetingInfoByFetch(
                                          meeting.meetingNum
                                        )
                                        .then((res) => {
                                          setEditMeeting(res)
                                          setScheduleMeetingModalOpen(true)
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
                          </div>
                        ))}
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="before-meeting-home-empty-schedule-meeting">
                    <img src={EmptyScheduleMeetingImg} alt="" />
                    <span>{i18n.emptyScheduleMeeting}</span>
                  </div>
                )}
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
              settingOpen={settingOpen}
              eventEmitter={eventEmitter}
              onCancel={() => setImmediateMeetingModalOpen(false)}
              summitLoading={submitLoading}
              onOpenSetting={(tab) => {
                onSettingClick(tab)
              }}
              onSummit={(value) => {
                return createMeeting({
                  meetingNum: value.meetingId,
                  password: value.password,
                  nickName: accountInfo.nickname,
                  avatar: accountInfo.avatar,
                  video: value.openCamera ? 1 : 2,
                  audio: value.openMic ? 1 : 2,
                  showSpeaker: setting?.normalSetting.showSpeakerList,
                  enableUnmuteBySpace:
                    setting?.audioSetting.enableUnmuteBySpace,
                  meetingIdDisplayOption: 0,
                  enableFixedToolbar: setting?.normalSetting.showToolbar,
                  enableVideoMirror: setting?.videoSetting.enableVideoMirroring,
                  showDurationTime: setting?.normalSetting.showDurationTime,
                })
              }}
            />

            <JoinMeetingModal
              previewController={previewController}
              setting={setting}
              nickname={accountInfo?.nickname}
              avatar={accountInfo?.avatar}
              settingOpen={settingOpen}
              onSettingChange={onSettingChange}
              open={joinMeetingModalOpen}
              getContainer={false}
              eventEmitter={eventEmitter}
              onCancel={() => setJoinMeetingModalOpen(false)}
              afterClose={() => setInvitationMeetingNum('')}
              meetingNum={invitationMeetingNum}
              summitLoading={submitLoading}
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
                  nickName: accountInfo?.nickname,
                  video: value.openCamera ? 1 : 2,
                  audio: value.openMic ? 1 : 2,
                  avatar: accountInfo?.avatar,
                  showSpeaker: setting?.normalSetting.showSpeakerList,
                  enableUnmuteBySpace:
                    setting?.audioSetting.enableUnmuteBySpace,
                  enableFixedToolbar: setting?.normalSetting.showToolbar,
                  enableVideoMirror: setting?.videoSetting.enableVideoMirroring,
                  showDurationTime: setting?.normalSetting.showDurationTime,
                })
              }}
            />
            <ScheduleMeetingModal
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
                  nickName: accountInfo.nickname,
                  video: setting?.normalSetting.openVideo ? 1 : 2,
                  audio: setting?.normalSetting.openAudio ? 1 : 2,
                  showSpeaker: setting?.normalSetting.showSpeakerList,
                  avatar: accountInfo?.avatar,
                  enableUnmuteBySpace:
                    setting?.audioSetting.enableUnmuteBySpace,
                  enableFixedToolbar: setting?.normalSetting.showToolbar,
                  enableVideoMirror: setting?.videoSetting.enableVideoMirroring,
                  showDurationTime: setting?.normalSetting.showDurationTime,
                })
              }}
              onCancelMeeting={(cancelRecurringMeeting?: boolean) => {
                setScheduleMeetingModalOpen(false)
                editMeeting &&
                  NEMeetingKit.actions.neMeeting
                    ?.cancelMeeting(
                      String(editMeeting.meetingId),
                      cancelRecurringMeeting
                    )
                    .then((res) => {
                      console.log(res)
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
              }}
              onSummit={(value) => {
                setSubmitLoading(true)
                scheduleMeeting({
                  subject: value.subject,
                  startTime: value.startTime,
                  endTime: value.endTime,
                  password: value.password,
                  audioOff: value.audioOff,
                  openLive: value.openLive,
                  meetingId: value.meetingId,
                  liveOnlyEmployees: value.liveOnlyEmployees,
                  attendeeAudioOffType: value.attendeeAudioOffType,
                  enableWaitingRoom: value.enableWaitingRoom,
                  enableJoinBeforeHost: value.enableJoinBeforeHost,
                  recurringRule: value.recurringRule,
                })
              }}
            />
            <HistoryMeetingModal
              open={historyMeetingModalOpen}
              onCancel={() => setHistoryMeetingModalOpen(false)}
              roomService={roomService}
              neMeeting={NEMeetingKit.actions.neMeeting}
              accountId={accountInfo?.account}
              meetingId={historyMeetingId}
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
                  .catch((error) => {
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
      <Feedback
        visible={feedbackModalOpen}
        meetingId={meetingId}
        nickname={accountInfo?.nickname}
        appKey={appKey}
        onClose={() => setFeedbackModalOpen(false)}
        neMeeting={NEMeetingKit}
        loadingChange={(flag) => setShowLoading(flag)}
        systemAndManufacturer={systemAndManufacturer}
      />
      <NPS
        visible={npsModalOpen}
        meetingId={meetingId}
        nickname={accountInfo?.nickname}
        appKey={appKey}
        onClose={() => setNpsModalOpen(false)}
      />
      <NotificationListModal
        neMeeting={NEMeetingKit.actions.neMeeting}
        sessionId={globalConfig?.appConfig.notifySenderAccid}
        open={notificationListModalOpen}
        eventEmitter={NEMeetingKit.actions.neMeeting?.eventEmitter}
        onCancel={() => setNotificationListModalOpen(false)}
        onClick={handleNotificationClick}
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

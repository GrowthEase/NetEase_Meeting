import {
  useContext,
  useEffect,
  useState,
  useRef,
  useMemo,
  useCallback,
} from 'react'
import {
  ActionType,
  AttendeeOffType,
  CreateOptions,
  EventType,
  GetMeetingConfigResponse,
  GlobalContext as GlobalContextInterface,
  JoinOptions,
  LoginOptions,
  MeetingEventType,
  MeetingInfoContextInterface,
  MeetingSetting,
  StaticReportType,
} from '../types'
import { GlobalContext, MeetingInfoContext } from '../store'
import { UserEventType } from '../types/innerType'
import NEMeetingService from '../services/NEMeeting'
import Toast from './common/toast'
import Dialog from './h5/ui/dialog'
import { NEMeetingSDKInfo } from '../types/type'
import { useTranslation } from 'react-i18next'
import { errorCodeMap } from '../config'
import { EventPriority, XKitReporter } from '@xkit-yx/utils'
import WebRoomkit from 'neroom-web-sdk'
import { IntervalEvent } from '../utils/report'
interface AuthProps {
  renderCallback?: () => void
}

const IM_VERSION = '9.11.0'
const RTC_VERSION = '5.4.0'
const Auth: React.FC<AuthProps> = ({ renderCallback }) => {
  const [passwordDialogShow, setPasswordDialogShow] = useState(false)
  const [password, setPassword] = useState('')
  const passwordRef = useRef('')
  const [isAnonymousLogin, setIsAnonymousLogin] = useState(false) // 匿名登录模式
  const joinOptionRef = useRef<JoinOptions | undefined>(undefined)
  const [errorText, setErrorText] = useState('')
  // 加入或者创建回调
  const callbackRef = useRef<any>(null)
  const { t } = useTranslation()
  const { dispatch, memberList } =
    useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const xkitReportRef = useRef<XKitReporter | null>(null)
  const {
    eventEmitter,
    neMeeting,
    logger,
    dispatch: globalDispatch,
  } = useContext<GlobalContextInterface>(GlobalContext)
  const rejoinCountRef = useRef(0)
  useEffect(() => {
    try {
      xkitReportRef.current = XKitReporter.getInstance({
        imVersion: IM_VERSION,
        nertcVersion: RTC_VERSION,
        deviceId: WebRoomkit.getDeviceId(),
      })
      xkitReportRef.current.common.appName = document?.title
    } catch (e) {
      console.warn('xkit', e)
    }
    eventEmitter?.on(
      UserEventType.LoginWithPassword,
      (data: {
        options: { username: string; password: string }
        callback: (e?: any) => void
      }) => {
        const { options, callback } = data
        callbackRef.current = callback
        loginWithPassword(options.username, options.password)
          .then(() => {
            callback && callback()
          })
          .catch((e) => {
            callback && callback(e)
          })
      }
    )

    eventEmitter?.on(
      UserEventType.Login,
      (data: { options: LoginOptions; callback: (e?: any) => void }) => {
        const { options, callback } = data
        login(options.accountId, options.accountToken)
          .then(() => {
            callback && callback()
          })
          .catch((e) => {
            callback && callback(e)
          })
      }
    )

    eventEmitter?.on(
      UserEventType.Logout,
      (data: { callback: (e?: any) => void }) => {
        const { callback } = data
        logout()
          .then(() => {
            callback && callback()
          })
          .catch((e) => {
            callback && callback(e)
          })
      }
    )

    eventEmitter?.on(
      UserEventType.CreateMeeting,
      (data: { options: CreateOptions; callback: (e?: any) => void }) => {
        const { options, callback } = data
        callbackRef.current = callback
        createMeeting(options)
          .then(() => {
            callback && callback()
          })
          .catch((e) => {
            callback && callback(e)
          })
      }
    )
    eventEmitter?.on(UserEventType.RejoinMeeting, () => {
      const options = { ...joinOptionRef.current, password }
      setPasswordDialogShow(false)
      if (isAnonymousLogin) {
        eventEmitter?.emit(UserEventType.AnonymousJoinMeeting, {
          options,
          callback: callbackRef.current,
          isRejoin: true,
        })
      } else {
        eventEmitter?.emit(UserEventType.JoinMeeting, {
          options,
          callback: callbackRef.current,
          isRejoin: true,
        })
      }
    })
    eventEmitter?.on(
      UserEventType.JoinMeeting,
      (data: { options: JoinOptions; callback: any; isRejoin?: boolean }) => {
        const { options, callback } = data
        callbackRef.current = callback
        joinMeeting(options)
          .then(() => {
            if (data.isRejoin) {
              return
            }
            callback && callback()
          })
          .catch((e) => {
            if (data.isRejoin) {
              // 会议已被锁定或者已结束
              if (e.code === 1019 || e.code == 3102) {
                return
              }
              handleRejoinFailed()
              return
            }
            callback && callback(e)
          })
      }
    )
    eventEmitter?.on(
      UserEventType.AnonymousJoinMeeting,
      (data: { options: JoinOptions; callback: any; isRejoin?: boolean }) => {
        const { options, callback } = data
        callbackRef.current = callback
        anonymousJoin(options)
          .then(() => {
            // 断网重新入会不需要触发回调
            if (data.isRejoin) {
              return
            }
            callback && callback()
          })
          .catch((e) => {
            if (data.isRejoin) {
              handleRejoinFailed()
              return
            }
            callback && callback(e)
          })
      }
    )
    try {
      neMeeting?.getGlobalConfig().then((res) => {
        updateGlobalConfig({ globalConfig: res })
      })
      renderCallback && renderCallback()
    } catch (e) {
      console.warn('renderCallback failed', e)
    }
  }, [])

  function handleRejoinFailed() {
    rejoinCountRef.current += 1
    if (rejoinCountRef.current > 3) {
      rejoinCountRef.current = 0
      dispatch?.({
        type: ActionType.RESET_MEETING,
        data: null,
      })
      return
    }
    globalDispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        waitingRejoinMeeting: true,
      },
    })
    return
  }

  useEffect(() => {
    setErrorText('')
  }, [password])

  const login = (accountId: string, accountToken: string): Promise<void> => {
    const loginReport = new IntervalEvent({
      eventId: StaticReportType.MeetingKit_login,
      priority: EventPriority.HIGH,
    })
    try {
      loginReport.addParams({ type: 'token' })
    } catch (e) {}
    return (neMeeting as NEMeetingService)
      .login({
        accountId,
        accountToken,
        loginType: 1,
        loginReport: loginReport,
      })
      .then((res) => {
        try {
          loginReport.endWithSuccess()
          xkitReportRef.current?.reportEvent(loginReport)
        } catch (e) {}
      })
      .catch((e) => {
        loginReport.endWith({
          code: e.code || -1,
          msg: e.msg || e.message || 'failure',
          requestId: e.requestId,
        })
        xkitReportRef.current?.reportEvent(loginReport)
        throw e
      })
  }

  const logout = (): Promise<void> => {
    return (neMeeting as NEMeetingService).logout()
  }

  const loginWithPassword = (
    username: string,
    password: string
  ): Promise<void> => {
    const loginReport = new IntervalEvent({
      eventId: StaticReportType.MeetingKit_login,
      priority: EventPriority.HIGH,
    })
    try {
      loginReport.addParams({ type: 'password' })
    } catch (e) {}
    return (neMeeting as NEMeetingService)
      .login({
        username,
        password,
        loginType: 2,
        loginReport,
      })
      .then((res) => {
        try {
          loginReport.endWithSuccess()
          xkitReportRef.current?.reportEvent(loginReport)
        } catch (e) {}
      })
      .catch((e) => {
        loginReport.endWith({
          code: e.code || -1,
          msg: e.msg || e.message || 'failure',
          requestId: e.requestId,
        })
        xkitReportRef.current?.reportEvent(loginReport)
        throw e
      })
  }
  const createMeeting = (options: CreateOptions): Promise<void> => {
    const createMeetingReport = new IntervalEvent({
      eventId: StaticReportType.MeetingKit_start_meeting,
      priority: EventPriority.HIGH,
    })
    globalDispatch?.({
      type: ActionType.JOIN_LOADING,
      data: true,
    })
    createMeetingReport.addParams({
      type: options.meetingNum ? 'personal' : 'random',
      meetingNum: options.meetingNum,
    })
    return (neMeeting as NEMeetingService)
      .create({ ...options, createMeetingReport: createMeetingReport })
      .then(() => {
        try {
          createMeetingReport.endWithSuccess()
          xkitReportRef.current?.reportEvent(createMeetingReport)
        } catch (e) {}
        handleJoinSuccess(options)
      })
      .catch((e) => {
        createMeetingReport.endWith({
          code: e.code || -1,
          msg: e.msg || e.message || 'failure',
          requestId: e.requestId,
        })
        xkitReportRef.current?.reportEvent(createMeetingReport)
        handleJoinFail(e, options)
        return Promise.reject(e)
      })
  }

  // 加入成功
  const handleJoinSuccess = (options: JoinOptions) => {
    globalDispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        waitingRejoinMeeting: false,
        online: true,
      },
    })
    rejoinCountRef.current = 0
    joinOptionRef.current = options
    const settingStr = localStorage.getItem('ne-meeting-setting')
    let setting: MeetingSetting | null = null
    if (settingStr) {
      try {
        setting = JSON.parse(settingStr) as MeetingSetting
        dispatch &&
          dispatch({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              setting,
            },
          })
      } catch (error) {}
    }
    updateGlobalConfig({
      showSubject: !!options.showSubject,
      showMeetingRemainingTip: !!options.showMeetingRemainingTip,
    })

    // dispatch &&
    //   dispatch({
    //     type: ActionType.UPDATE_MEETING_INFO,
    //     data: {
    //       isUnMutedVideo: options.video === 1,
    //       isUnMutedAudio: options.audio === 1,
    //     },
    //   })
    const meeting = neMeeting?.getMeetingInfo()
    if (meeting && meeting.meetingInfo) {
      const meetingInfo = meeting.meetingInfo
      const whiteboardUuid = meetingInfo.whiteboardUuid
      // 如果加入会议时候发现白板共享id和本端是一致的则表示共享的时候互踢如何，需要重置白板为关闭
      if (whiteboardUuid && whiteboardUuid == meetingInfo.localMember.uuid) {
        neMeeting?.whiteboardController?.stopWhiteboardShare()
        meeting.meetingInfo.whiteboardUuid = ''
      }
      // 入会如果房间不允许开启视频则需要提示
      if (
        meetingInfo.videoOff === AttendeeOffType.offNotAllowSelfOn &&
        meetingInfo.hostUuid !== meetingInfo.localMember.uuid
      ) {
        Toast.info(t('meetingHostMuteAllVideo'))
      }
      if (
        meetingInfo.audioOff === AttendeeOffType.offNotAllowSelfOn &&
        meetingInfo.hostUuid !== meetingInfo.localMember.uuid
      ) {
        Toast.info(t('meetingHostMuteAllAudio'))
      }
      // 如果存在设置缓存则外部没有传入情况下使用设置选项
      if (setting) {
        const { normalSetting, audioSetting, videoSetting } = setting
        audioSetting.recordDeviceId &&
          neMeeting?.changeLocalAudio(audioSetting.recordDeviceId)
        audioSetting.playoutDeviceId &&
          neMeeting?.selectSpeakers(audioSetting.playoutDeviceId)
        videoSetting.deviceId &&
          neMeeting?.changeLocalVideo(videoSetting.deviceId)
        videoSetting.resolution &&
          neMeeting?.setVideoProfile(videoSetting.resolution)
        if (audioSetting.playouOutputtVolume !== undefined) {
          try {
            neMeeting?.rtcController?.adjustPlaybackSignalVolume(
              audioSetting.playouOutputtVolume
            )
          } catch (e) {}
        }
        if (audioSetting.recordOutputVolume !== undefined) {
          neMeeting?.rtcController?.adjustRecordingSignalVolume(
            audioSetting.recordOutputVolume
          )
        }
        meeting.meetingInfo.isUnMutedAudio =
          options.audio === undefined
            ? normalSetting.openAudio
            : options.audio === 1

        meeting.meetingInfo.isUnMutedVideo =
          options.video === undefined
            ? normalSetting.openVideo
            : options.video === 1
        meeting.meetingInfo = {
          ...options,
          ...meeting.meetingInfo,
          enableFixedToolbar:
            options.enableFixedToolbar === undefined
              ? normalSetting.showToolbar
              : options.enableFixedToolbar !== false,
          enableVideoMirror:
            options.enableVideoMirror === undefined
              ? videoSetting.enableVideoMirroring
              : options.enableVideoMirror !== false,
          enableUnmuteBySpace:
            options.enableUnmuteBySpace === undefined
              ? audioSetting.enableUnmuteBySpace
              : options.enableUnmuteBySpace,
          showDurationTime:
            options.showDurationTime === undefined
              ? normalSetting.showDurationTime
              : options.showDurationTime,
          showSpeakerList:
            options.showSpeaker === undefined
              ? normalSetting.showSpeakerList
              : options.showSpeaker,
          enableTransparentWhiteboard:
            options.enableTransparentWhiteboard === undefined
              ? normalSetting.enableTransparentWhiteboard
              : options.enableTransparentWhiteboard,
        } as NEMeetingSDKInfo
      } else {
        meeting.meetingInfo.isUnMutedAudio = options.audio === 1
        meeting.meetingInfo.isUnMutedVideo = options.video === 1
        meeting.meetingInfo = {
          ...options,
          ...meeting.meetingInfo,
          enableFixedToolbar: options.enableFixedToolbar !== false,
          enableVideoMirror: options.enableVideoMirror !== false,
        } as NEMeetingSDKInfo
      }
    }
    hideLoadingPage()
    if (meeting) {
      // 存在如果两个端同时入会，本端入会成功获取到的成员列表可能还未有另外一个端。但是本端会有收到memberJoin事件
      if (memberList && memberList.length > 0) {
        memberList.forEach((member) => {
          const index = meeting.memberList.findIndex((m) => {
            return member.uuid == m.uuid
          })
          if (index < 0) {
            console.log('存在未同步>>', member)
            meeting.memberList.push(member)
          }
        })
      }
      dispatch &&
        dispatch({
          type: ActionType.SET_MEETING,
          data: meeting,
        })
    }
  }

  // 加入失败
  const handleJoinFail = (
    err: { code: number; message: string; msg?: string },
    options?: JoinOptions
  ) => {
    globalDispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        waitingRejoinMeeting: false,
        online: true,
      },
    })
    switch (err.code) {
      // 创建会议 会议已经存在
      case 3100:
        joinOptionRef.current = options
        eventEmitter?.emit(EventType.MeetingExits, {
          options: options,
          callback: callbackRef.current,
        })
        break
      case 3104:
      case 1004:
        Toast.info(err.message || (err.msg as string))
        hideLoadingPage()
        break
      case 1020:
        passwordRef.current && setErrorText(t('wrongPassword'))
        joinOptionRef.current = options
        setPasswordDialogShow(true)
        break
      case 1019:
        Toast.info(t('lockMeetingByHost'))
        hideLoadingPage()
        dispatch?.({
          type: ActionType.RESET_MEETING,
          data: null,
        })
        break
      // 会议已锁定、结束
      case 3102:
        Toast.info(
          errorCodeMap[err.code] || err.msg || err.message || 'join failed'
        )
        hideLoadingPage()
        dispatch?.({
          type: ActionType.RESET_MEETING,
          data: null,
        })
      default:
        Toast.info(
          errorCodeMap[err.code] || err.msg || err.message || 'join failed'
        )
        hideLoadingPage()
        console.log(err, '加入失败')
    }
  }

  function updateGlobalConfig(options: {
    showSubject?: boolean
    globalConfig?: GetMeetingConfigResponse
    showMeetingRemainingTip?: boolean
  }) {
    globalDispatch &&
      globalDispatch({
        type: ActionType.UPDATE_GLOBAL_CONFIG,
        data: options,
      })
  }

  // 隐藏loading页面
  function hideLoadingPage() {
    globalDispatch &&
      globalDispatch({
        type: ActionType.JOIN_LOADING,
        data: false,
      })
    setPasswordDialogShow(false)
    // setPassword('')
    setErrorText('')
    // setIsAnonymousLogin(false)
    passwordRef.current = ''
  }

  const joinMeeting = (options: JoinOptions): Promise<void> => {
    if (!options.meetingId && !options.meetingNum) {
      Toast.info('请输入会议号')
      throw new Error('meetingNum is empty')
    }
    joinOptionRef.current = options
    const joinMeetingReport = new IntervalEvent({
      eventId: StaticReportType.MeetingKit_join_meeting,
      priority: EventPriority.HIGH,
    })
    joinMeetingReport.addParams({
      type: 'normal',
      meetingNum: options.meetingNum,
    })
    globalDispatch &&
      globalDispatch({
        type: ActionType.JOIN_LOADING,
        data: true,
      })
    setIsAnonymousLogin(false)
    return (neMeeting as NEMeetingService)
      .join({ ...options, joinMeetingReport })
      .then((res) => {
        try {
          joinMeetingReport.endWithSuccess()
          xkitReportRef.current?.reportEvent(joinMeetingReport)
        } catch (e) {}
        handleJoinSuccess(options)
      })
      .catch((err) => {
        if (
          err.data &&
          err.data.message?.includes('mediaDevices is not support')
        ) {
          Toast.info('mediaDevices is not support')
          try {
            joinMeetingReport.endWithSuccess()
            xkitReportRef.current?.reportEvent(joinMeetingReport)
          } catch (e) {}
          handleJoinSuccess(options)
          return Promise.resolve()
        }
        try {
          joinMeetingReport.endWith({
            code: err.code || -1,
            msg: err.msg || err.message || 'Failure',
          })
          xkitReportRef.current?.reportEvent(joinMeetingReport)
        } catch (e) {}
        handleJoinFail(err, options)
        return Promise.reject(err)
      })
  }

  const anonymousJoin = (options: JoinOptions) => {
    if (!options.meetingId && !options.meetingNum) {
      Toast.info('请输入会议号')
      throw new Error('meetingId is empty')
    }
    const joinMeetingReport = new IntervalEvent({
      eventId: StaticReportType.MeetingKit_join_meeting,
      priority: EventPriority.HIGH,
    })
    try {
      joinMeetingReport.addParams({
        type: 'anonymous',
        meetingNum: options.meetingNum,
      })
    } catch (e) {}
    globalDispatch &&
      globalDispatch({
        type: ActionType.JOIN_LOADING,
        data: true,
      })
    joinOptionRef.current = options
    setIsAnonymousLogin(true)
    return (neMeeting as NEMeetingService)
      .anonymousJoin({ ...options, joinMeetingReport })
      .then((res) => {
        if ([-101, -102].includes(res?.code)) {
          throw res
        }
        try {
          joinMeetingReport.endWithSuccess()
          xkitReportRef.current?.reportEvent(joinMeetingReport)
        } catch (e) {}
        handleJoinSuccess(options)
      })
      .catch((err) => {
        if (
          err.data &&
          (err.data.message?.includes('mediaDevices is not support') ||
            err.data.message?.includes('getDevices'))
        ) {
          Toast.info('mediaDevices is not support')
          try {
            joinMeetingReport.endWithSuccess()
            xkitReportRef.current?.reportEvent(joinMeetingReport)
          } catch (e) {}
          handleJoinSuccess(options)
          return Promise.resolve()
        }
        try {
          joinMeetingReport.endWith({
            code: err.code || -1,
            msg: err.msg || err.message || 'Failure',
          })
          xkitReportRef.current?.reportEvent(joinMeetingReport)
        } catch (e) {}
        handleJoinFail(err, options)
        return Promise.reject(err)
      })
  }

  // 密码入会
  function joinMeetingWithPsw() {
    if (!password.trim()) {
      setErrorText(t('inputMeetingPassword'))
      return
    }
    const options = { ...joinOptionRef.current, password }
    joinOptionRef.current = options as JoinOptions
    setPasswordDialogShow(false)
    if (isAnonymousLogin) {
      eventEmitter?.emit(UserEventType.AnonymousJoinMeeting, {
        options,
        callback: callbackRef.current,
      })
    } else {
      eventEmitter?.emit(UserEventType.JoinMeeting, {
        options,
        callback: callbackRef.current,
      })
    }
  }

  return (
    <>
      <Dialog
        visible={passwordDialogShow}
        title={t('meetingPassword')}
        width={320}
        confirmText={t('joinMeeting')}
        cancelText={t('cancel')}
        ifShowCancel={false}
        onCancel={() => {
          hideLoadingPage()
        }}
        onConfirm={() => {
          joinMeetingWithPsw()
        }}
      >
        <div style={{ minHeight: 80, paddingTop: 10 }}>
          <input
            style={{
              border: errorText ? '1px solid red' : 'none',
              width: '100%',
            }}
            className={'input-ele'}
            placeholder={t('inputMeetingPassword')}
            maxLength={20}
            value={password.replace(/[^\d]/g, '')}
            required
            onChange={(e) => {
              let val = e.target.value
              val = val.replace(/[^\d]/g, '')
              setPassword(val)
              passwordRef.current = val
            }}
          />
          {errorText ? (
            <div style={{ color: '#ff3141', marginTop: 10, fontSize: 12 }}>
              {errorText}
            </div>
          ) : (
            ''
          )}
        </div>
      </Dialog>
    </>
  )
}

export default Auth

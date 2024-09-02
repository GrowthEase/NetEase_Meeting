import { EventPriority, XKitReporter } from '@xkit-yx/utils'
import React, { useContext, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { IPCEvent } from '../app/src/types'
import { errorCodeMap, IM_VERSION, RTC_VERSION } from '../config'
import NEMeetingService from '../services/NEMeeting'
import {
  MeetingInfoContext,
  useGlobalContext,
  useWaitingRoomContext,
} from '../store'
import {
  ActionType,
  CommonBar,
  CreateOptions,
  EventType,
  GetMeetingConfigResponse,
  JoinOptions,
  LoginOptions,
  MeetingEventType,
  MeetingInfoContextInterface,
  StaticReportType,
} from '../types'
import {
  MeetingSetting,
  memberAction,
  tagNERoomRtcAudioProfileType,
  tagNERoomRtcAudioScenarioType,
  UserEventType,
} from '../types/innerType'
import {
  MoreBarList,
  NEMeetingCode,
  NEMeetingSDKInfo,
  NEMeetingStatus,
  Role,
  ToolBarList,
} from '../types/type'
import { getLocalStorageSetting, setLocalStorageSetting } from '../utils'
import { IntervalEvent } from '../utils/report'
import Modal from './common/Modal'
import Toast from './common/toast'
import { createDefaultSetting } from '../services'
import { NEWindowMode } from '../kit/interface/service/meeting_service'
import { NECommonError } from 'neroom-types'
import { useMount } from 'ahooks'

interface AuthProps {
  renderCallback?: () => void
}

type CallbackType = (error?: NECommonError) => void
const Auth: React.FC<AuthProps> = ({ renderCallback }) => {
  const {
    outEventEmitter,
    eventEmitter,
    neMeeting,
    moreBarList,
    toolBarList,
    dispatch: globalDispatch,
  } = useGlobalContext()

  // 加入或者创建回调
  const { dispatch, memberList, meetingInfo } =
    useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const { dispatch: waitingRoomDispatch } = useWaitingRoomContext()
  const xkitReportRef = useRef<XKitReporter | null>(null)
  const rejoinCountRef = useRef(0)
  const passwordRef = useRef('')
  const [isAnonymousLogin, setIsAnonymousLogin] = useState(false) // 匿名登录模式
  const joinOptionRef = useRef<JoinOptions | undefined>(undefined)
  // 加入或者创建回调
  const callbackRef = useRef<CallbackType | null>(null)
  const { t } = useTranslation()

  const moreBarListRef = useRef(moreBarList)
  const toolBarListRef = useRef(toolBarList)
  const meetingInfoRef = useRef(meetingInfo)

  moreBarListRef.current = moreBarList
  toolBarListRef.current = toolBarList
  meetingInfoRef.current = meetingInfo

  useMount(() => {
    try {
      xkitReportRef.current = XKitReporter.getInstance({
        imVersion: IM_VERSION,
        nertcVersion: RTC_VERSION,
        deviceId: neMeeting?.roomDeviceId || '',
      })
      xkitReportRef.current.common.appName = document?.title
      xkitReportRef.current.common.platform =
        neMeeting?.getClientType() || 'Web'
    } catch (e) {
      console.warn('xkit', e)
    }

    outEventEmitter?.on(UserEventType.GetReducerMeetingInfo, (cb) => {
      cb?.(meetingInfoRef.current)
    })

    outEventEmitter?.on(
      UserEventType.LoginWithPassword,
      (data: {
        options: { username: string; password: string }
        callback: (e?) => void
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

    outEventEmitter?.on(
      UserEventType.Login,
      (data: { options: LoginOptions; callback: (e?) => void }) => {
        const { options, callback } = data

        login(options)
          .then(() => {
            callback && callback()
          })
          .catch((e) => {
            callback && callback(e)
          })
      }
    )

    outEventEmitter?.on(
      UserEventType.Logout,
      (data: { callback: (e?) => void }) => {
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

    outEventEmitter?.on(UserEventType.UpdateMeetingInfo, (data) => {
      console.log('updateMeetingInfo', data)
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data,
      })
    })

    outEventEmitter?.on(
      UserEventType.CreateMeeting,
      (data: { options: CreateOptions; callback: (e?) => void }) => {
        const { options, callback } = data

        callbackRef.current = callback
        joinOptionRef.current = options
        createMeeting(options)
          .then(() => {
            callback && callback()
          })
          .catch((e) => {
            callback && callback(e)
          })
      }
    )
    eventEmitter?.on(UserEventType.CancelJoin, () => {
      outEventEmitter?.emit(
        UserEventType.onMeetingStatusChanged,
        NEMeetingStatus.MEETING_STATUS_IDLE
      )
    })
    eventEmitter?.on(
      UserEventType.JoinOtherMeeting,
      (data: JoinOptions, callback) => {
        const options = { ...joinOptionRef.current, ...data }

        joinMeetingHandler({
          options,
          callback,
          isJoinOther: true,
        })
      }
    )
    eventEmitter?.on(
      UserEventType.RejoinMeeting,
      (data: { isAudioOn: boolean; isVideoOn: boolean }) => {
        if (joinOptionRef.current) {
          joinOptionRef.current.audio = data.isAudioOn ? 1 : 2
          joinOptionRef.current.video = data.isVideoOn ? 1 : 2
        }

        const options = {
          ...joinOptionRef.current,
          password: passwordRef.current,
        }

        if (isAnonymousLogin) {
          outEventEmitter?.emit(UserEventType.AnonymousJoinMeeting, {
            options,
            callback: callbackRef.current,
            isRejoin: true,
          })
        } else {
          outEventEmitter?.emit(UserEventType.JoinMeeting, {
            options,
            callback: callbackRef.current,
            isRejoin: true,
          })
        }
      }
    )
    outEventEmitter?.on(
      UserEventType.SetScreenSharingSourceId,
      (sourceId: string) => {
        neMeeting?.setScreenSharingSourceId(sourceId)
      }
    )
    outEventEmitter?.on(
      UserEventType.JoinMeeting,
      (data: {
        options: JoinOptions
        callback: (e?) => void
        isRejoin?: boolean
        type: 'join' | 'joinByInvite'
      }) => {
        joinMeetingHandler(data)
      }
    )
    outEventEmitter?.on(
      UserEventType.AnonymousJoinMeeting,
      (data: {
        options: JoinOptions
        callback: (e?) => void
        isRejoin?: boolean
      }) => {
        const { options, callback } = data

        callbackRef.current = callback
        anonymousJoin(options, data.isRejoin)
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
    outEventEmitter?.on(
      MeetingEventType.rejoinAfterAdmittedToRoom,
      (data: { isUnMutedVideo: boolean; isUnMutedAudio: boolean }) => {
        handleJoinSuccess(joinOptionRef.current as JoinOptions, data)
      }
    )
    outEventEmitter?.on(
      UserEventType.UpdateInjectedMenuItem,
      (data: CommonBar, callback: () => void) => {
        const toolBarItemIndex = toolBarListRef.current?.findIndex((item) => {
          item.id === data.id
        })

        if (toolBarItemIndex !== undefined && toolBarItemIndex > -1) {
          toolBarListRef.current &&
            (toolBarListRef.current[toolBarItemIndex] = data)

          toolBarListRef.current &&
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                toolBarList: [...toolBarListRef.current],
              },
            })

          callback?.()
          return
        }

        const moreBarItemIndex = moreBarListRef.current?.findIndex(
          (item) => item.id === data.id
        )

        if (moreBarItemIndex !== undefined && moreBarItemIndex > -1) {
          moreBarListRef.current &&
            (moreBarListRef.current[moreBarItemIndex] = data)

          moreBarListRef.current &&
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                moreBarList: [...moreBarListRef.current],
              },
            })
          callback?.()
          return
        }

        callback?.()
      }
    )
    try {
      // neMeeting?.getGlobalConfig().then((res) => {
      //   updateGlobalConfig({ globalConfig: res })
      // })
      renderCallback && renderCallback()
    } catch (e) {
      console.warn('renderCallback failed', e)
    }
  })

  function joinMeetingHandler(data: {
    options: JoinOptions
    callback: (e?) => void
    isRejoin?: boolean
    isJoinOther?: boolean
    type: 'join' | 'joinByInvite' | 'guestJoin'
  }) {
    const { options, callback } = data

    callbackRef.current = callback
    dispatch?.({
      type: ActionType.RESET_MEMBER,
      data: null,
    })
    dispatch &&
      dispatch({
        type: ActionType.RESET_MEETING,
        data: null,
      })
    joinMeeting(options, data.isJoinOther, data.isRejoin)
      .then(() => {
        if (data.isRejoin) {
          return
        }

        callback && callback()
      })
      .catch((e) => {
        if (data.isRejoin) {
          // 会议已被锁定或者已结束、被加入黑名单
          if (e.code === 1019 || e.code == 3102 || e.code === 601011) {
            setTimeout(() => {
              outEventEmitter?.emit(
                UserEventType.onMeetingStatusChanged,
                NEMeetingStatus.MEETING_STATUS_FAILED
              )
            }, 1000)

            return
          }

          handleRejoinFailed()
          return
        }

        callback && callback(e)
      })
  }

  function handleRejoinFailed() {
    rejoinCountRef.current += 1
    console.log('rejoinCountRef.current', rejoinCountRef.current)
    if (rejoinCountRef.current > 3) {
      rejoinCountRef.current = 0
      eventEmitter?.emit(EventType.RoomEnded, 'LEAVE_BY_SELF')
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

  const login = (options: LoginOptions): Promise<void> => {
    const loginReport = new IntervalEvent({
      eventId: StaticReportType.MeetingKit_login,
      priority: EventPriority.HIGH,
    })

    try {
      loginReport.addParams({ type: 'token' })
    } catch (e) {
      console.log('addParams error', e)
    }

    return (neMeeting as NEMeetingService)
      .login({
        loginType: 1,
        loginReport: loginReport,
        ...options,
      })
      .then(async () => {
        try {
          loginReport.endWithSuccess()
          xkitReportRef.current?.reportEvent(loginReport)
          await neMeeting
            ?.getGlobalConfig()
            .then((res) => {
              updateGlobalConfig({ globalConfig: res })
            })
            .catch((e) => {
              console.log('getGlobalConfig error', e)
            })
        } catch (e) {
          console.log('endWithSuccess error', e)
        }
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
    } catch (e) {
      console.log('addParams error', e)
    }

    return (neMeeting as NEMeetingService)
      .login({
        username,
        password,
        loginType: 2,
        loginReport,
      })
      .then(() => {
        try {
          loginReport.endWithSuccess()
          xkitReportRef.current?.reportEvent(loginReport)
        } catch (e) {
          console.log('endWithSuccess error', e)
        }
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
        } catch (e) {
          console.log('endWithSuccess error', e)
        }

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

  const asyncSetting = (setting: MeetingSetting, joinOptions: JoinOptions) => {
    if (setting) {
      if (joinOptions.showDurationTime !== undefined) {
        setting.normalSetting.showDurationTime = joinOptions.showDurationTime
      }

      if (joinOptions.audio !== undefined) {
        setting.normalSetting.openAudio = joinOptions.audio === 1
      }

      if (joinOptions.video !== undefined) {
        setting.normalSetting.openVideo = joinOptions.video === 1
      }

      if (joinOptions.enableSpeakerSpotlight !== undefined) {
        setting.normalSetting.enableVoicePriorityDisplay =
          joinOptions.enableSpeakerSpotlight
      }

      if (joinOptions.enableTransparentWhiteboard !== undefined) {
        setting.normalSetting.enableTransparentWhiteboard =
          joinOptions.enableTransparentWhiteboard
      }

      if (joinOptions.enableShowNotYetJoinedMembers !== undefined) {
        setting.normalSetting.enableShowNotYetJoinedMembers =
          joinOptions.enableShowNotYetJoinedMembers
      }

      setLocalStorageSetting(JSON.stringify(setting))

      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          setting,
        },
      })
    }
  }

  // 加入成功
  const handleJoinSuccess = (
    options: JoinOptions,
    waitingRoomOptions?: {
      isUnMutedVideo: boolean
      isUnMutedAudio: boolean
    }
  ) => {
    outEventEmitter?.emit(
      UserEventType.onMeetingStatusChanged,
      NEMeetingStatus.MEETING_STATUS_INMEETING
    )
    joinOptionRef.current = options

    updateGlobalConfig({
      showSubject: !!options.showSubject,
      showMeetingRemainingTip: !!options.showMeetingRemainingTip,
      toolBarList: options.toolBarList || [],
      moreBarList: options.moreBarList || [],
      waitingJoinOtherMeeting: false,
    })

    hideLoadingPage()
    // dispatch &&
    //   dispatch({
    //     type: ActionType.UPDATE_MEETING_INFO,
    //     data: {
    //       isUnMutedVideo: options.video === 1,
    //       isUnMutedAudio: options.audio === 1,
    //     },
    //   })
    handleMeetingInfo(waitingRoomOptions)

    if (neMeeting?.subscribeMembersMap) {
      neMeeting.subscribeMembersMap = {}
    }

    globalDispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        waitingRejoinMeeting: false,
        waitingJoinOtherMeeting: false,
        online: true,
        meetingIdDisplayOption: options.meetingIdDisplayOption
          ? options.meetingIdDisplayOption
          : 0,
        showCloudRecordingUI:
          options.showCloudRecordingUI === false ? false : true,
        showScreenShareUserVideo:
          options.showScreenShareUserVideo === false ? false : true,
        showCloudRecordMenuItem:
          options.showCloudRecordMenuItem === false ? false : true,
        noChat: options.noChat,
        noWhiteboard: options.noWhiteboard,
        noCaptions: options.noCaptions,
        noTranscription: options.noTranscription,
        noInvite: options.noInvite,
        noSip: options.noSip,
        noSwitchAudioMode: options.noSwitchAudioMode,
        noGallery: options.noGallery,
        noRename: options.noRename,
        noLive: options.noLive,
        enableAudioShare: options.enableAudioShare === false ? false : true,
        showMemberTag: options.showMemberTag,
        detectMutedMic: options.detectMutedMic === false ? false : true,
        defaultWindowMode: options.defaultWindowMode || NEWindowMode.Normal,
        pluginNotifyDuration: options.pluginNotifyDuration,
        enableDirectMemberMediaControlByHost:
          options.enableDirectMemberMediaControlByHost,
      },
    })
    rejoinCountRef.current = 0
  }

  function handleMeetingInfo(data?: {
    isUnMutedVideo: boolean
    isUnMutedAudio: boolean
  }) {
    const options = joinOptionRef.current as JoinOptions
    const meeting = neMeeting?.getMeetingInfo()
    const setting = getLocalStorageSetting() || createDefaultSetting()

    if (setting) {
      asyncSetting(setting, options)
    }

    if (meeting && meeting.meetingInfo) {
      if (joinOptionRef.current) {
        joinOptionRef.current.meetingNum = meeting.meetingInfo.meetingNum
      }

      const meetingInfo = meeting.meetingInfo
      const memberList = meeting.memberList
      const hostMember = memberList.find((member) => member.role === Role.host)

      if (
        hostMember &&
        hostMember?.uuid !== meetingInfo.localMember.uuid &&
        meetingInfo.localMember.uuid === meetingInfo.ownerUserUuid
      ) {
        Modal.confirm({
          key: 'takeBackTheHost',
          title: t('meetingReclaimHost'),
          content: t('meetingReclaimHostTip', { user: hostMember.name }),
          okText: t('meetingReclaimHost'),
          cancelText: t('meetingReclaimHostCancel'),
          onOk: async () => {
            try {
              await neMeeting?.sendMemberControl(
                memberAction.takeBackTheHost,
                hostMember.uuid
              )
            } catch {
              Toast.fail(t('meetingReclaimHostFailed'))
            }
          },
        })
      }

      if (meetingInfo.localMember.role === Role.coHost) {
        Toast.info(t('participantAssignedCoHost'))
      } else if (
        meetingInfo.localMember.role === Role.host &&
        neMeeting?._meetingInfo.ownerUserUuid !== meetingInfo.localMember.uuid
      ) {
        Toast.info(t('participantAssignedHost'))
      }

      // 已开启转写则需要打开
      if (meetingInfo.isTranscriptionEnabled) {
        const targetLanguage = setting.captionSetting.targetLanguage

        targetLanguage &&
          neMeeting?.setCaptionTranslationLanguage(targetLanguage)
        neMeeting?.rtcController?.enableCaption(true)
      }

      const whiteboardUuid = meetingInfo.whiteboardUuid

      if (!whiteboardUuid && joinOptionRef.current?.defaultWindowMode === 2) {
        neMeeting?.roomContext
          ?.updateRoomProperty(
            'whiteboardConfig',
            JSON.stringify({
              isTransparent: joinOptionRef.current?.enableTransparentWhiteboard,
            })
          )
          .then(() => {
            return neMeeting?.whiteboardController?.startWhiteboardShare()
          })
      } else if (whiteboardUuid) {
        if (whiteboardUuid === meetingInfo.localMember.uuid) {
          // 如果加入会议时候发现白板共享id和本端是一致的则表示共享的时候互踢如何，需要重置白板为关闭
          neMeeting?.whiteboardController?.stopWhiteboardShare()
          meeting.meetingInfo.whiteboardUuid = ''
        }

        if (joinOptionRef.current?.defaultWindowMode === 2) {
          Toast.info(t('screenShareNotAllow'))
        }
      }

      // 入会如果房间不允许开启视频则需要提示
      if (
        (!meetingInfo.unmuteVideoBySelfPermission || meetingInfo.videoAllOff) &&
        meetingInfo.hostUuid !== meetingInfo.localMember.uuid &&
        options.video === 1 &&
        !meetingInfo.localMember.hide &&
        !meetingInfo.inWaitingRoom
      ) {
        Toast.info(t('participantHostMuteAllVideo'))
      }

      if (
        (!meetingInfo.unmuteAudioBySelfPermission || meetingInfo.audioAllOff) &&
        meetingInfo.hostUuid !== meetingInfo.localMember.uuid &&
        options.audio === 1 &&
        !meetingInfo.localMember.hide &&
        !meetingInfo.inWaitingRoom
      ) {
        Toast.info(t('participantHostMuteAllAudio'))
      }

      neMeeting?.rtcController?.enableAudioVolumeIndication?.(true, 200)
      // 如果存在设置缓存则外部没有传入情况下使用设置选项
      if (setting) {
        const { normalSetting, audioSetting, videoSetting } = setting

        if (window.isElectronNative) {
          neMeeting?.rtcController?.adjustPlaybackSignalVolume(
            audioSetting.playouOutputtVolume !== undefined
              ? audioSetting.playouOutputtVolume
              : 25
          )
          audioSetting.recordOutputVolume !== undefined &&
            neMeeting?.previewController?.setRecordDeviceVolume?.(
              audioSetting.recordOutputVolume
            )
        } else {
          if (audioSetting.playouOutputtVolume !== undefined) {
            try {
              neMeeting?.rtcController?.adjustPlaybackSignalVolume(
                audioSetting.playouOutputtVolume
              )
            } catch (e) {
              console.log('调节播放音量error', e)
            }
          }

          if (audioSetting.recordOutputVolume !== undefined) {
            neMeeting?.rtcController?.adjustRecordingSignalVolume(
              audioSetting.recordOutputVolume
            )
          }
        }

        audioSetting.recordDeviceId &&
          neMeeting?.changeLocalAudio(audioSetting.recordDeviceId)
        audioSetting.playoutDeviceId &&
          neMeeting?.selectSpeakers(audioSetting.playoutDeviceId)
        videoSetting.deviceId &&
          neMeeting?.changeLocalVideo(videoSetting.deviceId)
        neMeeting?.setVideoProfile(videoSetting.resolution || 720)

        // 处理音频降噪回音立体音等
        if (audioSetting && window?.isElectronNative) {
          try {
            if (audioSetting.enableAudioAI) {
              neMeeting?.enableAudioAINS(true)
            } else {
              neMeeting?.enableAudioAINS(false)
              if (audioSetting.enableMusicMode) {
                neMeeting?.enableAudioEchoCancellation(
                  audioSetting.enableAudioEchoCancellation as boolean
                )
                if (audioSetting.enableAudioStereo) {
                  neMeeting?.setAudioProfileInEle(
                    tagNERoomRtcAudioProfileType.kNEAudioProfileHighQualityStereo,
                    tagNERoomRtcAudioScenarioType.kNEAudioScenarioMusic
                  )
                } else {
                  neMeeting?.setAudioProfileInEle(
                    tagNERoomRtcAudioProfileType.kNEAudioProfileHighQuality,
                    tagNERoomRtcAudioScenarioType.kNEAudioScenarioMusic
                  )
                }
              } else {
                neMeeting?.setAudioProfileInEle(
                  tagNERoomRtcAudioProfileType.kNEAudioProfileDefault,
                  tagNERoomRtcAudioScenarioType.kNEAudioScenarioDefault
                )
              }
            }
          } catch (e) {
            console.log('处理高级音频设置error', e)
          }

          try {
            neMeeting?.enableAudioVolumeAutoAdjust(
              audioSetting.enableAudioVolumeAutoAdjust
            )
          } catch (e) {
            console.log('处理是否自动调节麦克风音量error', e)
          }
        }

        // 如果data存在则是等候室进入
        if (data) {
          meeting.meetingInfo.isUnMutedVideo = data.isUnMutedVideo
          meeting.meetingInfo.isUnMutedAudio = data.isUnMutedAudio
        } else {
          meeting.meetingInfo.isUnMutedAudio =
            options.audio === undefined
              ? normalSetting.openAudio
              : options.audio === 1
          meeting.meetingInfo.isUnMutedVideo =
            options.video === undefined
              ? normalSetting.openVideo
              : options.video === 1
        }

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
        if (data) {
          meeting.meetingInfo.isUnMutedVideo = data.isUnMutedVideo
          meeting.meetingInfo.isUnMutedAudio = data.isUnMutedAudio
        } else {
          meeting.meetingInfo.isUnMutedAudio = options.audio === 1
          meeting.meetingInfo.isUnMutedVideo = options.video === 1
        }

        meeting.meetingInfo = {
          ...options,
          ...meeting.meetingInfo,
          enableFixedToolbar: options.enableFixedToolbar !== false,
          enableVideoMirror: options.enableVideoMirror !== false,
        } as NEMeetingSDKInfo
      }
    }

    // if (window.isElectronNative) {
    //   window.ipcRenderer?.send(IPCEvent.changeMeetingStatus, true)
    // }
    if (meeting) {
      const meetingInfo = meeting.meetingInfo

      // 入会判断是正在录制，如果在录制则弹框提醒
      if (
        meetingInfo.isCloudRecording &&
        meetingInfo.localMember.role !== Role.host &&
        meetingInfo.localMember.role !== Role.coHost &&
        options.showCloudRecordingUI !== false &&
        !meetingInfo.inWaitingRoom
      ) {
        eventEmitter?.emit(MeetingEventType.needShowRecordTip, true)
      }

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

      // 获取初始化直播状态
      const liveInfo = neMeeting?.getLiveInfo()

      if (liveInfo) {
        meeting.meetingInfo.liveState = liveInfo.state
      }

      dispatch &&
        dispatch({
          type: ActionType.SET_MEETING,
          data: meeting,
        })
    }

    neMeeting?.getWaitingRoomInfo().then((res) => {
      if (!res) {
        return
      }

      neMeeting?.updateWaitingRoomUnReadCount(res.memberList.length)
      waitingRoomDispatch?.({
        type: ActionType.WAITING_ROOM_UPDATE_INFO,
        data: { info: res.waitingRoomInfo },
      })
      waitingRoomDispatch?.({
        type: ActionType.WAITING_ROOM_SET_MEMBER_LIST,
        data: { memberList: res.memberList },
      })
    })
  }

  // 加入失败
  const handleJoinFail = (
    err: { code: number | string; message: string; msg?: string },
    options?: JoinOptions,
    isRejoin?: boolean
  ) => {
    globalDispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        waitingRejoinMeeting: false,
        online: true,
      },
    })
    globalDispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        waitingJoinOtherMeeting: false,
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
        if (window.isElectronNative) {
          window.ipcRenderer?.send(IPCEvent.changeMeetingStatus, false)
        }

        joinOptionRef.current = options
        // 会议状态回调：会议状态为等待，原因是需要输入密码
        outEventEmitter?.emit(
          UserEventType.onMeetingStatusChanged,
          NEMeetingStatus.MEETING_STATUS_WAITING,
          NEMeetingCode.MEETING_WAITING_VERIFY_PASSWORD
        )
        break
      case 1019:
        // Toast.info(t('meetingLockMeetingByHost'))
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
        break
      default:
        Toast.info(
          errorCodeMap[err.code] || err.msg || err.message || 'join failed'
        )
        if (!isRejoin) {
          outEventEmitter?.emit(
            UserEventType.onMeetingStatusChanged,
            NEMeetingStatus.MEETING_STATUS_FAILED
          )
        }

        // 重新加入，人数上限就直接退出
        if (isRejoin && err.code === 1022) {
          eventEmitter?.emit(EventType.RoomEnded, 'LEAVE_BY_SELF')
        }

        hideLoadingPage()
        console.log(err, '加入失败')
    }
  }

  function updateGlobalConfig(options: {
    showSubject?: boolean
    globalConfig?: GetMeetingConfigResponse
    showMeetingRemainingTip?: boolean
    toolBarList?: ToolBarList
    moreBarList?: MoreBarList
    waitingJoinOtherMeeting?: boolean
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
  }

  const joinMeeting = (
    options: JoinOptions,
    isJoinOther?: boolean,
    isRejoin?: boolean,
    type?: 'join' | 'joinByInvite' | 'guestJoin'
  ): Promise<void> => {
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
    options.password = options.password || passwordRef.current
    const _neMeeting = neMeeting as NEMeetingService
    let joinFunc = isJoinOther
      ? _neMeeting.acceptInvite.bind(_neMeeting)
      : _neMeeting.join.bind(_neMeeting)

    if (type === 'guestJoin') {
      joinFunc = _neMeeting.guestJoin.bind(_neMeeting)
    }

    return joinFunc({ ...options, joinMeetingReport })
      .then(() => {
        try {
          joinMeetingReport.endWithSuccess()
          xkitReportRef.current?.reportEvent(joinMeetingReport)
        } catch (e) {
          console.log('endWithSuccess error', e)
        }

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
          } catch (e) {
            console.log('endWithSuccess error', e)
          }

          handleJoinSuccess(options)
          return Promise.resolve()
        }

        try {
          joinMeetingReport.endWith({
            code: err.code || -1,
            msg: err.msg || err.message || 'Failure',
          })
          xkitReportRef.current?.reportEvent(joinMeetingReport)
        } catch (e) {
          console.log('endWith error', e)
        }

        handleJoinFail(err, options, isRejoin)
        return Promise.reject(err)
      })
  }

  const anonymousJoin = (options: JoinOptions, isRejoin?: boolean) => {
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
    } catch (e) {
      console.log('addParams error', e)
    }

    globalDispatch &&
      globalDispatch({
        type: ActionType.JOIN_LOADING,
        data: true,
      })
    joinOptionRef.current = options
    options.password = options.password || passwordRef.current
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
        } catch (e) {
          console.log('endWithSuccess error', e)
        }

        handleJoinSuccess(options)
      })
      .catch((err) => {
        console.log('anonymousJoin error', err)
        if (
          err.data &&
          (err.data.message?.includes('mediaDevices is not support') ||
            err.data.message?.includes('getDevices'))
        ) {
          Toast.info('mediaDevices is not support')
          try {
            joinMeetingReport.endWithSuccess()
            xkitReportRef.current?.reportEvent(joinMeetingReport)
          } catch (e) {
            console.log('endWithSuccess error', e)
          }

          handleJoinSuccess(options)
          return Promise.resolve()
        }

        try {
          joinMeetingReport.endWith({
            code: err.code || -1,
            msg: err.msg || err.message || 'Failure',
          })
          xkitReportRef.current?.reportEvent(joinMeetingReport)
        } catch (e) {
          console.log('endWith error', e)
        }

        handleJoinFail(err, options, isRejoin)
        return Promise.reject(err)
      })
  }

  return <></>
}

export default Auth

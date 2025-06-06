import React, { useCallback, useEffect, useRef, useState } from 'react'
import {
  ActionType,
  EndRoomReason,
  EventType,
  MeetingEventType,
  MeetingSetting,
  NEMeetingInfo,
  UserEventType,
} from '../types'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { useTranslation } from 'react-i18next'
import usePreviewHandler from './usePreviewHandler'
import {
  formatDate,
  getLocalStorageSetting,
  getMeetingPermission,
} from '../utils'
import { getWindow } from '../utils/windowsProxy'
import { IPCEvent } from '../app/src/types'
import Toast from '../components/common/toast'
import { NEMeetingCode, NEMeetingLeaveType } from '../types/type'
import { errorCodeMap } from '../config'
import { NEPreviewRoomListener, NEResult, NERoomEndReason } from 'neroom-types'

export function formateMsg(
  message: { type: string; text: string } | undefined,
  t: (text: string) => string
): string {
  if (message?.type === 'text') {
    return message.text
  } else if (message?.type === 'image') {
    return t('imageMsg')
  } else {
    return t('fileMsg')
  }
}

interface WaitingRoomProps {
  closeModalHandle: (data: {
    title: string
    content: string
    closeText: string
    reason: number
    notNeedAutoClose?: boolean
  }) => void
}

type WaitingRoomReturn = {
  openAudio: boolean
  openVideo: boolean
  setOpenVideo: (openVideo: boolean) => void
  setOpenAudio: (openAudio: boolean) => void
  setting: MeetingSetting | null
  unReadMsgCount: number
  isOffLine: boolean
  nickname: string
  recordVolume: number
  meetingInfo: NEMeetingInfo
  meetingState: number
  showChatRoom: boolean
  handleOpenAudio: (openAudio: boolean) => void
  handleOpenVideo: (openVideo: boolean) => void
  handleOpenChatRoom: (openChatRoom: boolean) => void
  startPreview: (view: HTMLElement) => Promise<NEResult<null>> | undefined
  stopPreview: () => void
  openChatRoom: boolean
  formatMeetingTime: (startTime: number) => string
  videoCanvasWrapRef: React.RefObject<HTMLDivElement>
  setSetting: (setting: MeetingSetting) => void
  setOpenChatRoom: (openChatRoom: boolean) => void
  setUnReadMsgCount: (unReadMsgCount: number) => void
  setRecordVolume: (recordVolume: number) => void
}

export function useWaitingRoom(data: WaitingRoomProps): WaitingRoomReturn {
  const { closeModalHandle } = data

  const { t } = useTranslation()
  const [openAudio, setOpenAudio] = useState<boolean>(false)
  const [openVideo, setOpenVideo] = useState<boolean>(false)
  const [setting, setSetting] = useState<MeetingSetting | null>(null)
  const [unReadMsgCount, setUnReadMsgCount] = useState<number>(0)
  const [isOffLine, setIsOffLine] = useState<boolean>(false)
  const [nickname, setNickname] = useState('')
  const previewRoomListenerRef = useRef<NEPreviewRoomListener | null>(null)

  const [openChatRoom, setOpenChatRoom] = useState<boolean>(false)
  const videoCanvasWrapRef = useRef<HTMLDivElement>(null)
  const [recordVolume, setRecordVolume] = useState<number>(0)
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const [meetingState, setMeetingState] = useState(1)
  const [showChatRoom, setShowChatRoom] = useState(false)
  const {
    neMeeting,
    outEventEmitter,
    eventEmitter,
    dispatch: globalDispatch,
  } = useGlobalContext()
  const meetingInfoRef = useRef<NEMeetingInfo>(meetingInfo)
  const closeTimerRef = useRef<null | ReturnType<typeof setTimeout>>(null)

  usePreviewHandler()
  // useEventHandler()
  meetingInfoRef.current = meetingInfo

  const startPreview = useCallback(
    (view: HTMLElement) => {
      const previewController = neMeeting?.previewController

      if (window.ipcRenderer) {
        previewController?.setupLocalVideoCanvas(view)
        return previewController?.startPreview()
      } else {
        return previewController?.startPreview(view).catch((e) => {
          if (e?.msg || errorCodeMap[e?.code]) {
            Toast.fail(e?.msg || t(errorCodeMap[e?.code]))
          } else if (
            e.data?.message &&
            e.data?.message?.includes('Permission denied')
          ) {
            Toast.fail(t(errorCodeMap['10212']))
          }

          throw e
        })
      }
    },
    [neMeeting?.previewController, t]
  )

  const stopPreview = useCallback(() => {
    const previewController = neMeeting?.previewController

    return previewController?.stopPreview()
  }, [neMeeting?.previewController])

  function handleOpenAudio(openAudio: boolean) {
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        isUnMutedAudio: !openAudio,
      },
    })
    const previewController = neMeeting?.previewController

    if (previewController) {
      if (openAudio) {
        previewController?.stopRecordDeviceTest().finally(() => {
          setOpenAudio(false)
        })
      } else {
        previewController
          ?.startRecordDeviceTest((level: number) => {
            setRecordVolume((level as number) * 10)
          })
          .then(() => {
            setOpenAudio(true)
          })
          .catch((e) => {
            if (e?.msg || errorCodeMap[e?.code]) {
              Toast.fail(e?.msg || t(errorCodeMap[e?.code]))
            } else if (
              e.data?.message &&
              (e.data?.message?.includes('Permission denied') ||
                e.data?.name?.includes('NotAllowedError'))
            ) {
              Toast.fail(t(errorCodeMap['10212']))
            }

            throw e
          })
      }
    }
  }

  const handleOpenVideo = useCallback(
    async (openVideo: boolean) => {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          isUnMutedVideo: !openVideo,
        },
      })
      const previewController = neMeeting?.previewController

      if (previewController) {
        if (openVideo) {
          if (window.isElectronNative) {
            const res = await stopPreview()

            if (res?.code === 0) {
              setOpenVideo(false)
            }
          } else {
            try {
              await stopPreview()
            } finally {
              setOpenVideo(false)
            }
          }
        } else {
          if (window.isElectronNative) {
            const res = await startPreview(
              videoCanvasWrapRef.current as HTMLElement
            )

            if (res?.code === 0) {
              setOpenVideo(true)
            }
          } else {
            try {
              await stopPreview()
            } finally {
              await startPreview(videoCanvasWrapRef.current as HTMLElement)
              setOpenVideo(true)
            }
          }
        }
      }
    },
    [dispatch, neMeeting?.previewController, startPreview, stopPreview]
  )

  function addPreviewRoomListener() {
    if (!window.isElectronNative) {
      return
    }

    const previewConText = neMeeting?.roomService?.getPreviewRoomContext()

    if (!previewConText) {
      return
    }

    previewRoomListenerRef.current = {
      onLocalAudioVolumeIndication: (volume: number) => {
        // console.log('onLocalAudioVolumeIndication>>>', volume)
        setRecordVolume(volume)
      },
      onRtcVirtualBackgroundSourceEnabled: (
        enabled: boolean,
        reason: number
      ) => {
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
      },
    }
    previewConText?.addPreviewRoomListener(previewRoomListenerRef.current)
  }

  function removePreviewRoomListener() {
    if (previewRoomListenerRef.current) {
      const previewConText = neMeeting?.roomService?.getPreviewRoomContext()

      previewConText?.removePreviewRoomListener(previewRoomListenerRef.current)
    }
  }

  useEffect(() => {
    setNickname(meetingInfo?.localMember?.name || '')
  }, [meetingInfo?.localMember?.name])

  useEffect(() => {
    window.ipcRenderer?.on(IPCEvent.changeSetting, (event, setting) => {
      setSetting(setting)
    })
    const tmpSetting = getLocalStorageSetting()

    if (tmpSetting) {
      setSetting(tmpSetting)
    }

    neMeeting?._meetingInfo && setMeetingState(neMeeting?._meetingInfo.state)
  }, [neMeeting])

  useEffect(() => {
    if (meetingInfo.isUnMutedAudio) {
      handleOpenAudio(false)
    }

    if (neMeeting?.alreadyJoin) {
      if (meetingInfo.localMember.isVideoOn) {
        handleOpenVideo(false)
      }

      if (meetingInfo.localMember.isAudioOn) {
        handleOpenAudio(false)
      }
    } else {
      if (meetingInfo.isUnMutedVideo) {
        handleOpenVideo(false)
      }

      return () => {
        setOpenChatRoom(false)
      }
    }
  }, [])

  const handleNameChange = useCallback((memberId, name) => {
    const localMember = meetingInfo.localMember

    if (localMember && localMember.uuid === memberId) {
      setNickname(name)
      const value = meetingInfo.shortMeetingNum
        ? {
            [meetingInfo.meetingNum]: name,
            [meetingInfo.shortMeetingNum]: name,
          }
        : {
            [meetingInfo.meetingNum]: name,
          }

      localStorage.setItem(
        'ne-meeting-nickname-' + localMember.uuid,
        JSON.stringify(value)
      )
    }
  }, [])

  const handleMeetingUpdate = useCallback(
    (res) => {
      // 需要判断是否是同一个会议，否则互踢的会有问题
      if (
        res.data &&
        res.data.meetingNum === meetingInfoRef.current.meetingNum
      ) {
        if (res.data?.type === 200) {
          window.isElectronNative && Toast.warning(t('tokenExpired'), 5000)
        } else {
          setMeetingState(res.data.state)
        }
      }
    },
    [t]
  )

  useEffect(() => {
    if (meetingState === 2) {
      setShowChatRoom(true)
    }
  }, [meetingState])

  const getWaitingRoomConfig = useCallback(() => {
    neMeeting?.getWaitingRoomConfig(meetingInfo.meetingNum).then((data) => {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          waitingRoomChatPermission: data.wtPrChat,
        },
      })
    })
  }, [meetingInfo.meetingNum, neMeeting, dispatch])

  const handleReceiveScheduledMeetingUpdate = useCallback((res) => {
    // 多端同时登录，本端在等候室，另外创建或者加入其他会议
    const data = res.data

    if (
      data?.meetingNum !== meetingInfoRef.current.meetingNum &&
      data?.state === 2
    ) {
      // Toast.info(t('meetingSwitchOtherDevice'))
      setTimeout(() => {
        // neMeeting?.leave()
        if (window.isElectronNative) {
          neMeeting?.reset()
        }

        outEventEmitter?.emit(
          EventType.RoomEnded,
          NEMeetingCode.MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE
        )
      }, 2000)
    }
  }, [])
  const handleWaitingRoomEvent = useCallback(() => {
    eventEmitter?.on(
      EventType.ReceiveScheduledMeetingUpdate,
      handleReceiveScheduledMeetingUpdate
    )

    eventEmitter?.on(
      EventType.RoomPropertiesChanged,
      (properties: Record<string, { value: string }>) => {
        console.log('onRoomPropertiesChanged: %o %o %t', properties)
        if (properties.securityCtrl) {
          const avatarHide = Number(properties.securityCtrl.value)

          console.log('avatarHide', getMeetingPermission(avatarHide).avatarHide)
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              avatarHide: getMeetingPermission(avatarHide).avatarHide,
            },
          })
        }

        if (properties.wtPrChat) {
          const waitingRoomChatPermission = Number(properties.wtPrChat.value)

          console.log('waitingRoomChatPermission', waitingRoomChatPermission)

          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              waitingRoomChatPermission,
            },
          })
        }
      }
    )
    eventEmitter?.on(EventType.MyWaitingRoomStatusChanged, (status, reason) => {
      console.log('MyWaitingRoomStatusChanged', status, reason)
      // 被准入
      if (status === 2) {
        globalDispatch?.({
          type: ActionType.JOIN_LOADING,
          data: true,
        })
        dispatch?.({
          type: ActionType.RESET_MEETING,
          data: null,
        })
        window.ipcRenderer?.send(IPCEvent.focusWindow, 'mainWindow')
        neMeeting?.rejoinAfterAdmittedToRoom().then(() => {
          console.warn('rejoinAfterAdmittedToRoom', meetingInfoRef.current)
          // 使用eventEmitter auth组件无法监听到
          outEventEmitter?.emit(MeetingEventType.rejoinAfterAdmittedToRoom, {
            isUnMutedVideo: meetingInfoRef.current.isUnMutedVideo,
            isUnMutedAudio: meetingInfoRef.current.isUnMutedAudio,
          })
          if (window.isElectronNative) {
            const meeting = neMeeting?.getMeetingInfo()

            meeting &&
              dispatch?.({
                type: ActionType.SET_MEETING,
                data: meeting,
              })
          }

          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              inWaitingRoom: false,
            },
          })
        })
      } else if (status === 3) {
        console.log('MyWaitingRoomStatusChanged', status, reason)
        // 被主持人移除 或者全部被移除
        if (reason === 3 || reason === 6) {
          closeModalHandle({
            title: t('removedFromMeeting'),
            content: t('removeFromMeetingByHost'),
            closeText: t('globalClose'),
            reason,
            notNeedAutoClose: true,
          })
        } else {
          // 不是加入房间
          if (reason !== 5) {
            if (reason === 2) {
              Toast.info(t('meetingSwitchOtherDevice'))
              setTimeout(() => {
                // neMeeting?.leave()
                if (window.isElectronNative) {
                  neMeeting?.reset()
                }

                outEventEmitter?.emit(
                  EventType.RoomEnded,
                  NEMeetingCode.MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE
                )
              }, 2000)
            }
          } else {
            neMeeting?.leave()
          }
        }
      }
    })
    eventEmitter?.on(EventType.MemberNameChangedInWaitingRoom, handleNameChange)
    eventEmitter?.on(EventType.RoomEnded, handleRoomEnd)

    eventEmitter?.on(
      EventType.ReceiveScheduledMeetingUpdate,
      handleMeetingUpdate
    )
  }, [])

  function removeWaitingRoomEvent() {
    eventEmitter?.off(EventType.MyWaitingRoomStatusChanged)
    eventEmitter?.off(
      EventType.MemberNameChangedInWaitingRoom,
      handleNameChange
    )
    eventEmitter?.off(EventType.RoomEnded, handleRoomEnd)
    eventEmitter?.off(
      EventType.ReceiveScheduledMeetingUpdate,
      handleMeetingUpdate
    )
    eventEmitter?.off(
      EventType.ReceiveScheduledMeetingUpdate,
      handleReceiveScheduledMeetingUpdate
    )
    // eventEmitter?.off(EventType.MemberJoinWaitingRoom)
    // eventEmitter?.off(EventType.MemberLeaveWaitingRoom)
    // eventEmitter?.off(EventType.MemberAdmitted)
    // eventEmitter?.off(EventType.MemberNameChangedInWaitingRoom)
    // eventEmitter?.off(EventType.WaitingRoomInfoUpdated)
  }

  function handleOpenChatRoom(openChatRoom) {
    setUnReadMsgCount(0)
    setOpenChatRoom(openChatRoom)
  }

  function formatMeetingTime(startTime: number) {
    return startTime ? formatDate(startTime, 'yyyy.MM.dd_hh:mm') : '--'
  }

  const handleRoomEnd = useCallback((reason: string) => {
    const langMap: Record<string, string> = {
      UNKNOWN: t('UNKNOWN'), // 未知异常
      LOGIN_STATE_ERROR: t('LOGIN_STATE_ERROR'), // 账号异常
      CLOSE_BY_BACKEND: meetingInfoRef.current.isScreenSharingMeeting
        ? t('screenShareStop')
        : t('CLOSE_BY_BACKEND'), // 后台关闭
      ALL_MEMBERS_OUT: t('ALL_MEMBERS_OUT'), // 所有成员退出
      END_OF_LIFE: t('END_OF_LIFE'), // 房间到期
      CLOSE_BY_MEMBER: t('meetingEnded'), // 会议已结束
      KICK_OUT: t('KICK_OUT'), // 被管理员踢出
      SYNC_DATA_ERROR: t('SYNC_DATA_ERROR'), // 数据同步错误
      LEAVE_BY_SELF: t('LEAVE_BY_SELF'), // 成员主动离开房间
      OTHER: t('OTHER'), // 其他
    }

    if (reason === 'CLOSE_BY_MEMBER') {
      closeModalHandle({
        title: t('meetingEnded'),
        content: t('closeAutomatically'),
        closeText: t('globalSure'),
        reason,
      })
    } else {
      langMap[reason] && Toast.info(langMap[reason])

      const reasonMap = {
        [NERoomEndReason.CLOSE_BY_MEMBER]:
          NEMeetingCode.MEETING_DISCONNECTING_CLOSED_BY_HOST,
        [NERoomEndReason.END_OF_LIFE]:
          NEMeetingCode.MEETING_DISCONNECTING_END_OF_LIFE,
        [NERoomEndReason.KICK_OUT]:
          NEMeetingCode.MEETING_DISCONNECTING_REMOVED_BY_HOST,
        [NERoomEndReason.kICK_BY_SELF]:
          NEMeetingCode.MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE,
        [NERoomEndReason.SYNC_DATA_ERROR]:
          NEMeetingCode.MEETING_DISCONNECTING_SYNC_DATA_ERROR,
        [NERoomEndReason.LEAVE_BY_SELF]:
          NEMeetingCode.MEETING_DISCONNECTING_BY_SELF,
        [EndRoomReason.JOIN_TIMEOUT]:
          NEMeetingCode.MEETING_DISCONNECTING_JOIN_TIMEOUT,
      }
      let leaveType =
        reasonMap[reason] || reasonMap[reason] === 0
          ? reasonMap[reason]
          : reason

      if (!leaveType && leaveType !== 0) {
        leaveType = NEMeetingLeaveType.UNKNOWN
      }
      stopPreview()
      neMeeting?.previewController?.stopRecordDeviceTest()
      outEventEmitter?.emit(EventType.RoomEnded, leaveType)
    }
  }, [])

  useEffect(() => {
    function handleAcceptInvite(options, callback) {
      // 需要先离开当前会议
      globalDispatch?.({
        type: ActionType.UPDATE_GLOBAL_CONFIG,
        data: {
          waitingJoinOtherMeeting: true,
          joinLoading: true,
        },
      })
      // 在会中
      eventEmitter?.emit(UserEventType.JoinOtherMeeting, options, callback)
    }

    // 在等候室时候监听处理要求加入其他会议事件
    eventEmitter?.on(EventType.AcceptInvite, handleAcceptInvite)
    return () => {
      eventEmitter?.off(EventType.AcceptInvite, handleAcceptInvite)
    }
  }, [eventEmitter, globalDispatch])

  useEffect(() => {
    addPreviewRoomListener()
    neMeeting?.chatController?.leaveChatroom(0)
    neMeeting?.chatController?.joinChatroom(1)
    const closeTimer = closeTimerRef.current

    return () => {
      stopPreview()
      removePreviewRoomListener()
      closeTimer && clearInterval(closeTimer)
      neMeeting?.previewController?.stopRecordDeviceTest()
    }
  }, [])

  useEffect(() => {
    handleWaitingRoomEvent()
    return () => {
      removeWaitingRoomEvent()
    }
  }, [])

  useEffect(() => {
    getWaitingRoomConfig()
    function onlineHandle() {
      setIsOffLine(false)
      // 延迟请求
      setTimeout(() => {
        getWaitingRoomConfig()
      }, 1000)
    }

    function offlineHandle() {
      setIsOffLine(true)
    }

    window.addEventListener('online', onlineHandle)
    window.addEventListener('offline', offlineHandle)
    return () => {
      window.removeEventListener('online', onlineHandle)
      window.removeEventListener('offline', offlineHandle)
    }
  }, [getWaitingRoomConfig])

  return {
    openAudio,
    openVideo,
    setOpenVideo,
    setOpenAudio,
    setting,
    unReadMsgCount,
    isOffLine,
    nickname,
    recordVolume,
    meetingInfo,
    meetingState,
    showChatRoom,
    handleOpenAudio,
    handleOpenVideo,
    handleOpenChatRoom,
    startPreview,
    stopPreview,
    openChatRoom,
    formatMeetingTime,
    videoCanvasWrapRef,
    setSetting,
    setOpenChatRoom,
    setUnReadMsgCount,
    setRecordVolume,
  }
}

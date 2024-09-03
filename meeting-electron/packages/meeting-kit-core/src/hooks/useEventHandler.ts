/**
 * app的web和h5复用逻辑
 */
import {
  NEMediaTypes,
  NERoomEndReason,
  NERoomMember,
  NERoomRtcNetworkQualityInfo,
  NEWaitingRoomMember,
} from 'neroom-types'
import {
  Dispatch as DispatchR,
  SetStateAction,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
} from 'react'
import { useTranslation } from 'react-i18next'
import Modal from '../components/common/Modal'
import Toast from '../components/common/toast'
import { updateMeetingService } from '../services/NEMeeting'
import {
  GlobalContext,
  MeetingInfoContext,
  useWaitingRoomContext,
} from '../store'
import {
  ActionType,
  AttendeeOffType,
  BrowserType,
  Dispatch,
  EndRoomReason,
  EventType,
  GlobalContext as GlobalContextInterface,
  hostAction,
  MeetingEventType,
  MeetingInfoContextInterface,
  MeetingPermission,
  memberAction,
  NEMeetingInfo,
  NEMember,
  RecordState,
  Role,
  UserEventType,
  WatermarkInfo,
} from '../types'
import {
  InterpretationRes,
  NEMeetingCode,
  NEMeetingInterpretationSettings,
  NEMeetingLeaveType,
  NEMeetingStatus,
} from '../types/type'
import {
  debounce,
  getBrowserType,
  getMeetingPermission,
  throttle,
  getClientType,
} from '../utils'
import { Logger } from '../utils/Logger'
import { IPCEvent } from '../app/src/types'
import { MAJOR_AUDIO } from '../config'
import { useEnableCaption } from './useCaption'

const logger = new Logger('Meeting-NeMeeting', true)

interface UseEventHandlerInterface {
  joinLoading: boolean | undefined
  showReplayDialog: boolean
  showStartPlayDialog: boolean
  showReplayScreenDialog: boolean
  isShowAudioDialog: boolean
  isShowVideoDialog: boolean
  showReplayAudioSlaveDialog: boolean
  showTimeTip: boolean
  networkQuality: NERoomRtcNetworkQualityInfo
  setIsOpenVideoByHost: (isOpen: boolean) => void
  setIsShowVideoDialog: DispatchR<SetStateAction<boolean>>
  setIsOpenAudioByHost: (isOpen: boolean) => void
  setIsShowAudioDialog: DispatchR<SetStateAction<boolean>>
  setShowTimeTip: DispatchR<SetStateAction<boolean>>
  timeTipContent: string
  confirmToReplay: (
    type: 'audio' | 'video' | 'audioSlave' | 'screen',
    isRestricted?: boolean
  ) => void
  confirmUnMuteMyAudio: () => void
  confirmUnMuteMyVideo: () => void
}

export default function useEventHandler(): UseEventHandlerInterface {
  const { meetingInfo, memberList, dispatch } =
    useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const {
    neMeeting,
    joinLoading,
    globalConfig,
    dispatch: globalDispatch,
    showMeetingRemainingTip,
    waitingRejoinMeeting,
    waitingJoinOtherMeeting,
    interpretationSetting,
    enableDirectMemberMediaControlByHost,
  } = useContext<GlobalContextInterface>(GlobalContext)
  const { dispatch: waitingRoomDispatch } = useWaitingRoomContext()
  const { eventEmitter, outEventEmitter } =
    useContext<GlobalContextInterface>(GlobalContext)
  const [leaveCallback, setLeaveCallback] = useState<
    ((reason: NEMeetingLeaveType) => void) | null
  >(null)

  const enableDirectMemberMediaControlByHostRef = useRef(
    enableDirectMemberMediaControlByHost
  )

  enableDirectMemberMediaControlByHostRef.current =
    enableDirectMemberMediaControlByHost

  const { enableCaption } = useEnableCaption({ neMeeting, dispatch })
  const meetingInfoRef = useRef<NEMeetingInfo>(meetingInfo)
  const memberListRef = useRef<NEMember[]>(memberList)
  const memberJoinRtcCacheListRef = useRef<NERoomMember[]>([])
  const remainingTimer = useRef<null | ReturnType<typeof setTimeout>>(null)
  const hiddenTimeTipTimer = useRef<null | ReturnType<typeof setTimeout>>(null)
  const remainingSeconds = useRef<number>(0)
  const waitingRejoinMeetingRef = useRef<boolean>(!!waitingRejoinMeeting)
  const waitingJoinOtherMeetingRef = useRef<boolean>(!!waitingJoinOtherMeeting)
  const showMeetingRemainingTipRef = useRef<boolean>(false)
  const [timeTipContent, setTimeTipContent] = useState<string>('')
  const [showTimeTip, setShowTimeTip] = useState<boolean>(false)

  meetingInfoRef.current = meetingInfo
  memberListRef.current = memberList
  showMeetingRemainingTipRef.current = !!showMeetingRemainingTip
  waitingRejoinMeetingRef.current = !!waitingRejoinMeeting
  waitingJoinOtherMeetingRef.current = !!waitingJoinOtherMeeting

  const isAlreadyPlayAudioSlaveRef = useRef<boolean>(false)
  const isAlreadyPlayAudioRef = useRef<boolean>(false)
  const [showReplayDialog, setShowReplayDialog] = useState<boolean>(false)
  const [showStartPlayDialog, setShowStartPlayDialog] = useState(false)
  const [showReplayScreenDialog, setShowReplayScreenDialog] =
    useState<boolean>(false)
  const isOpenAudioByHostRef = useRef<boolean>(false)
  const isOpenVideoByHostRef = useRef<boolean>(false)
  const [isShowAudioDialog, setIsShowAudioDialog] = useState<boolean>(false)
  const [isShowVideoDialog, setIsShowVideoDialog] = useState<boolean>(false)
  // const [online, setOnline] = useState(true)
  const [showReplayAudioSlaveDialog, setShowReplayAudioSlaveDialog] =
    useState<boolean>(false)
  const [networkQuality, setNetworkQuality] =
    useState<NERoomRtcNetworkQualityInfo>({
      userUuid: '',
      downStatus: 0,
      upStatus: 0,
    })
  const canShowNetworkToastRef = useRef(true)
  const isReplayedRef = useRef<boolean>(false)
  const isReplayedVideoRef = useRef<boolean>(false)
  const isReplayedScreenRef = useRef<boolean>(false)
  const activeSpeakerTimerRef = useRef<number | null>(null)
  const interpretationSettingRef = useRef<
    NEMeetingInterpretationSettings | undefined
  >(undefined)

  interpretationSettingRef.current = interpretationSetting

  const { t } = useTranslation()

  const { localMember } = meetingInfo

  const handlePermissionChange = (
    newPermission: MeetingPermission,
    oldPermission: MeetingPermission
  ) => {
    const localMember = meetingInfoRef.current.localMember

    // 关闭共享权限
    if (
      !newPermission.screenSharePermission &&
      oldPermission.screenSharePermission &&
      localMember.isSharingScreen
    ) {
      Toast.info(t('sharingStopByHost'))
      outEventEmitter?.emit('enableShareScreen')
    }

    if (
      !newPermission.whiteboardPermission &&
      oldPermission.whiteboardPermission &&
      localMember.isSharingWhiteboard
    ) {
      Toast.info(t('sharingStopByHost'))
      eventEmitter?.emit(UserEventType.StopWhiteboard)
    }
  }

  const handleMemberJoinRtc = useCallback(
    (rtcMember: NERoomMember, roomMember: NEMember) => {
      // 本端加入rtc完成
      if (roomMember?.uuid === meetingInfoRef.current.localMember.uuid) {
        if (
          meetingInfoRef.current.setting.captionSetting
            ?.autoEnableCaptionsOnJoin
        ) {
          enableCaption(true)
        }
      }

      if (
        roomMember &&
        roomMember.isInRtcChannel !== rtcMember.isInRtcChannel
      ) {
        dispatch?.({
          type: ActionType.UPDATE_MEMBER,
          data: {
            uuid: rtcMember.uuid,
            member: {
              isInRtcChannel: rtcMember.isInRtcChannel,
            },
          },
        })
      }
    },
    [dispatch, enableCaption]
  )

  useEffect(() => {
    if (localMember.isHandsUp && localMember.isSharingScreen) {
      neMeeting?.sendMemberControl(memberAction.handsDown, localMember.uuid)
    }
  }, [
    localMember.isHandsUp,
    localMember.isSharingScreen,
    neMeeting,
    localMember.uuid,
  ])

  useEffect(() => {
    if (memberList.length > 0 && memberJoinRtcCacheListRef.current.length > 0) {
      memberJoinRtcCacheListRef.current.forEach((member) => {
        const roomMember = memberListRef.current.find(
          (item) => item.uuid === member.uuid
        )

        if (roomMember) {
          handleMemberJoinRtc(member, roomMember)
          // 清除对应缓存
          const index = memberJoinRtcCacheListRef.current.findIndex(
            (item) => item.uuid === member.uuid
          )

          index > -1 && memberJoinRtcCacheListRef.current.splice(index, 1)
        }
      })
    }
  }, [memberList.length, handleMemberJoinRtc])

  useEffect(() => {
    // if (meetingInfo.meetingNum) {
    //   addEventListener()
    // }
    return () => {
      // removeEventListener()
      // outEventEmitter?.removeAllListeners()
      // roomEndedHandler()
      remainingTimer.current && clearInterval(remainingTimer.current)
    }
  }, [meetingInfo.meetingNum])
  useEffect(() => {
    logger.debug('添加监听事件')
    addEventListener()
    return () => {
      removeEventListener()
    }
  }, [])

  useEffect(() => {
    if (localMember.role === Role.host || localMember.role === Role.coHost) {
      neMeeting?.chatController?.joinChatroom(1)
    } else {
      neMeeting?.chatController?.leaveChatroom(1)
    }
  }, [localMember, neMeeting])

  // useEffect(() => {
  //   if (canShowNetworkToastRef.current) {
  //     if (networkQuality.downStatus >= 4 || networkQuality.upStatus >= 4) {
  //       Toast.info(t('networkAbnormalityAndCheck'))
  //       canShowNetworkToastRef.current = false
  //       setTimeout(() => {
  //         canShowNetworkToastRef.current = true
  //       }, 6000)
  //     }
  //   }
  // }, [networkQuality.downStatus, networkQuality.upStatus])

  useEffect(() => {
    if (!meetingInfo.meetingNum) {
      hiddenTimeTipTimer.current && clearInterval(hiddenTimeTipTimer.current)
      hiddenTimeTipTimer.current = null
    }
  }, [meetingInfo.meetingNum])

  useEffect(() => {
    if (showTimeTip) {
      hiddenTimeTipTimer.current && clearTimeout(hiddenTimeTipTimer.current)
      hiddenTimeTipTimer.current = setTimeout(() => {
        hiddenTimeTipTimer.current = null
        setShowTimeTip(false)
      }, 60000)
    } else {
      hiddenTimeTipTimer.current && clearTimeout(hiddenTimeTipTimer.current)
    }
  }, [showTimeTip])

  const handleMemberSipInviteStateChanged = useCallback(
    (member) => {
      console.log('handleMemberSipInviteStateChanged', member)
      // 更新当前邀请列表列表
      dispatch?.({
        type: ActionType.SIP_ADD_MEMBER,
        data: {
          member: { ...member },
        },
      })
    },
    [dispatch]
  )
  const handleMeetingUpdate = useCallback(
    (res) => {
      if (res.data) {
        if (res.data?.type === 200) {
          window.isElectronNative && Toast.warning(t('tokenExpired'), 4000)
        }
      }
    },
    [t]
  )

  const handleNameChange = useCallback(
    (memberId, name) => {
      console.log('MemberNameChangedInWaitingRoom', memberId, name)
      waitingRoomDispatch?.({
        type: ActionType.WAITING_ROOM_UPDATE_MEMBER,
        data: { uuid: memberId, member: { name } },
      })
      const localMember = meetingInfoRef.current.localMember

      // 如果是本端则表示，被修改昵称的同事被准入
      if (localMember.uuid === memberId) {
        neMeeting?.modifyNickName({
          nickName: name,
        })
      }
    },
    [neMeeting, waitingRoomDispatch]
  )

  const cancelFocus = useCallback(() => {
    if (
      meetingInfoRef.current.localMember.uuid ===
      meetingInfoRef.current.focusUuid
    ) {
      Toast.info(t('participantUnassignedActiveSpeaker'))
    }
  }, [t])
  const roomEndedHandler = useCallback(
    (reason = 'OTHER') => {
      dispatch?.({
        type: ActionType.RESET_MEMBER,
        data: null,
      })
      dispatch &&
        dispatch({
          type: ActionType.RESET_MEETING,
          data: null,
        })
      globalDispatch?.({
        type: ActionType.UPDATE_GLOBAL_CONFIG,
        data: {
          online: true,
        },
      })
      setIsShowAudioDialog(false)
      setIsShowVideoDialog(false)
      setShowReplayDialog(false)
      isReplayedRef.current = false // 重置重新播放标志
      isReplayedVideoRef.current = false // 重置重新播放标志
      isReplayedScreenRef.current = false // 重置重新播放标志
      isAlreadyPlayAudioSlaveRef.current = false
      isAlreadyPlayAudioRef.current = false
      try {
        neMeeting?.destroy()
      } catch (e) {
        console.log('destroy error', e)
      }

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

      console.warn('reasonmap', reasonMap[reason], reason)
      globalDispatch &&
        globalDispatch({
          type: ActionType.JOIN_LOADING,
          data: false,
        })
      let leaveType =
        reasonMap[reason] || reasonMap[reason] === 0
          ? reasonMap[reason]
          : reason

      if (!leaveType && leaveType !== 0) {
        leaveType = NEMeetingLeaveType.UNKNOWN
      }

      outEventEmitter?.emit(EventType.RoomEnded, leaveType)
      memberJoinRtcCacheListRef.current = []
      // eventEmitter?.removeAllListeners()
      try {
        const leaveType: NEMeetingLeaveType = NEMeetingLeaveType[reason]

        leaveCallback && leaveCallback(leaveType)
      } catch (e) {
        logger.warn('leaveCallback failed', e)
      }
    },
    [dispatch, globalDispatch, leaveCallback, outEventEmitter, neMeeting]
  )
  const unmuteMyAudio = useCallback(() => {
    const localMember = meetingInfoRef.current.localMember

    if (localMember.isAudioOn) {
      return
    }

    eventEmitter?.emit(EventType.NeedAudioHandsUp, false)
    // 主持人或者联席主持人或者设置主持人控制打开则直接开声音
    if (
      localMember.role === Role.host ||
      localMember.role === Role.coHost ||
      enableDirectMemberMediaControlByHostRef.current
    ) {
      neMeeting?.unmuteLocalAudio().then(() => {
        dispatch &&
          dispatch({
            type: ActionType.UPDATE_MEMBER,
            data: {
              uuid: localMember.uuid,
              member: {
                isHandsUp: false,
              },
            },
          })
      })
      return
    }

    if (localMember.isAudioConnected) {
      if (!localMember.isHandsUp) {
        setIsOpenAudioByHost(true)
        setIsShowAudioDialog(true)
      } else {
        // 如果已举手则音频不需要弹框
        Toast.info(t('hostAgreeAudioHandsUp'))
        neMeeting?.unmuteLocalAudio().then(() => {
          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: localMember.uuid,
                member: {
                  isHandsUp: false,
                },
              },
            })
        })
      }
    }
  }, [dispatch, eventEmitter, t, neMeeting])

  const unmuteMyVideo = useCallback(
    (isMySelf = false) => {
      const localMember = meetingInfoRef.current.localMember

      if (localMember.isVideoOn) {
        return
      }

      eventEmitter?.emit(EventType.NeedVideoHandsUp, false)
      if (
        ((localMember.role === Role.host || localMember.role === Role.coHost) &&
          isMySelf) ||
        enableDirectMemberMediaControlByHostRef.current
      ) {
        neMeeting?.unmuteLocalVideo().then(() => {
          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: localMember.uuid,
                member: {
                  isHandsUp: false,
                },
              },
            })
        })
      } else {
        setIsOpenVideoByHost(true)
        setIsShowVideoDialog(true)
      }
    },
    [dispatch, eventEmitter, neMeeting]
  )
  const addEventListener = useCallback(() => {
    console.warn('开始监听会议事件')
    outEventEmitter?.on(UserEventType.SetLeaveCallback, (callback) => {
      setLeaveCallback(callback)
    })
    eventEmitter?.on(
      EventType.MemberAudioMuteChanged,
      (member: NEMember, mute: boolean, operator: NEMember) => {
        logger.debug('onMemberAudioMuteChanged: %o %o %t', member, operator)
        dispatch &&
          dispatch({
            type: ActionType.UPDATE_MEMBER,
            data: {
              uuid: member.uuid,
              member: { isAudioOn: !mute },
            },
          })
        // todo 如果是wx浏览器目前会随机出现无法启动播放音频辅流。提前弹框一次兼容，后续rtc4.6.60会更新
        // if (
        //   !mute &&
        //   getBrowserType() === BrowserType.WX &&
        //   getClientType() === 'Android' &&
        //   !isAlreadyPlayAudioRef.current
        // ) {
        //   isAlreadyPlayAudioRef.current = true
        //   setShowReplayDialog(true)
        // }
        // 非本端直接返回
        if (meetingInfoRef.current.localMember.uuid !== member.uuid) {
          return
        }

        // 静音
        if (mute) {
          if (member.uuid !== operator.uuid) {
            Toast.info(t('participantHostMuteAudio'))
            // 如果被管理员静音且是译员 则需要同声unpub对应翻译频道
            if (
              meetingInfoRef.current.interpretation?.started &&
              meetingInfoRef.current.isInterpreter
            ) {
              const speakerLanguage =
                interpretationSettingRef.current?.speakerLanguage

              if (speakerLanguage && speakerLanguage !== MAJOR_AUDIO) {
                const channelName =
                  meetingInfoRef.current.interpretation?.channelNames[
                    speakerLanguage
                  ]

                channelName &&
                  neMeeting?.enableAndPubAudio(false, channelName, false)
              }
            }
          }
        } else {
          // 开启声音
          if (
            meetingInfoRef.current.localMember.role !== Role.host &&
            operator.uuid !== meetingInfoRef.current.localMember.uuid &&
            !meetingInfoRef.current.localMember.isAudioOn
          ) {
            Toast.info(t('hostAgreeAudioHandsUp'))
          }

          // 如果当前在举手状态，则放下手
          if (meetingInfoRef.current.localMember.isHandsUp) {
            neMeeting?.sendMemberControl(memberAction.handsDown, member.uuid)
          }
        }
      }
    )

    eventEmitter?.on(EventType.MemberJoinRoom, (members: NERoomMember[]) => {
      logger.debug('用户加入: %o %t', members)

      const index = members.findIndex(
        (member) => member.uuid === meetingInfoRef.current.localMember.uuid
      )

      if (index > 0) {
        return
      }

      members.forEach((member) => {
        if (meetingInfoRef.current.localMember.role === Role.host) {
          debounce(() => {
            Toast.info(`${member.name} ${t('enterMeetingToast')}`)
          })
        }

        // 主持人加入
        if (member.role.name === Role.host) {
          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                hostUuid: member.uuid,
                hostName: member.name,
              },
            })
        }

        if (!dispatch) {
          return
        }

        // 判断是否译员加入
        const interpretation = meetingInfoRef.current.interpretation

        if (
          interpretation?.started &&
          interpretation?.interpreters[member.uuid]
        ) {
          const role = meetingInfoRef.current.localMember.role

          if (role === Role.host || role === Role.coHost) {
            eventEmitter.emit(EventType.OnInterpreterLeave)
          }
        }

        console.log('用户加入完成', member)
        dispatch({
          type: ActionType.ADD_MEMBER,
          data: {
            member: { ...member, role: member.role?.name },
          },
        })
        // 如果当前正在共享状态并且共享人是刚加入的人，表示该成员是移动端杀进程重新加入，需要设置为非共享状态
        if (
          meetingInfoRef.current.screenUuid &&
          !member.isSharingScreen &&
          meetingInfoRef.current.screenUuid === member.uuid
        ) {
          dispatch({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              screenUuid: '',
            },
          })
          neMeeting?.rtcController?.unsubscribeRemoteVideoSubStream(member.uuid)
        }

        if (
          meetingInfoRef.current.systemAudioUuid &&
          !member.isSharingSystemAudio &&
          meetingInfoRef.current.systemAudioUuid === member.uuid
        ) {
          dispatch({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              systemAudioUuid: '',
            },
          })
        }
      })
      const _Members = members.map((member) => {
        return {
          uuid: member.uuid,
          name: member.name,
        }
      })

      if (
        meetingInfoRef.current.localMember.role === Role.host ||
        meetingInfoRef.current.localMember.role === Role.coHost
      ) {
        members.forEach((member) => {
          if (
            member.uuid !== meetingInfoRef.current.localMember.uuid &&
            member.role.name !== 'screen_sharer'
          ) {
            Toast.info(`${member.name}${t('meetingJoin')}`)
          }
        })
      }

      outEventEmitter?.emit('peerJoin', _Members)
    })
    eventEmitter?.on(
      EventType.MemberNameChanged,
      (member: NERoomMember, name: string) => {
        logger.debug('onMemberNameChanged: %o %t', member)
        dispatch &&
          dispatch({
            type: ActionType.UPDATE_MEMBER,
            data: {
              uuid: member.uuid,
              member: { name: name },
            },
          })

        if (member.role.name === Role.host) {
          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                hostName: member.name,
              },
            })
        }

        if (member.uuid === meetingInfoRef.current.localMember.uuid) {
          //修改自己昵称 保存昵称，会议逻辑
          localStorage.setItem(
            'ne-meeting-nickname-' + meetingInfoRef.current.localMember.uuid,
            JSON.stringify({
              [meetingInfoRef.current.meetingNum]: name,
              [meetingInfoRef.current.shortMeetingNum]: name,
            })
          )
        }
      }
    )

    eventEmitter?.on(EventType.MemberLeaveRoom, (members: NERoomMember[]) => {
      logger.debug('用户离开: %o %t', members)

      const uuids: string[] = []

      members.forEach((member) => {
        delete neMeeting?.subscribeMembersMap[member.uuid]
        // 本端不处理，如果离开走roomEnd
        if (member.uuid !== meetingInfoRef.current.localMember.uuid) {
          uuids.push(member.uuid)
        }

        if (member.uuid === meetingInfoRef.current.pinVideoUuid) {
          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                pinVideoUuid: '',
              },
            })
        }

        if (member.uuid === meetingInfoRef.current.privateChatMemberId) {
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              privateChatMemberId: 'meetingAll',
            },
          })
        }

        // 判断是否译员离开
        const interpretation = meetingInfoRef.current.interpretation

        if (
          interpretation?.started &&
          interpretation?.interpreters[member.uuid]
        ) {
          // 如果离开的译员是当前收听语言的唯一译员则提示是否切换到主频道
          const listeningLanguage =
            interpretationSettingRef.current?.listenLanguage

          const role = meetingInfoRef.current.localMember.role

          if (role === Role.host || role === Role.coHost) {
            eventEmitter.emit(EventType.OnInterpreterLeave)
          }

          if (!listeningLanguage || listeningLanguage === MAJOR_AUDIO) {
            return
          }

          let keys = Object.keys(interpretation.interpreters)

          keys = keys.filter((key) => {
            return interpretation.interpreters[key].includes(listeningLanguage)
          })
          // 只有当前离开的译员翻译该语言
          if (keys.length <= 1) {
            const listeningChannel =
              interpretation?.channelNames[listeningLanguage]

            eventEmitter.emit(EventType.OnInterpreterLeaveAll, listeningChannel)
          }
        }
      })
      const originMemberList = memberListRef.current
        ? [...memberListRef.current]
        : []

      dispatch &&
        dispatch({
          type: ActionType.REMOVE_MEMBER,
          data: {
            uuids: uuids,
          },
        })

      // 主持人离开
      const hostInfo = members.find((member) => member.role.name === Role.host)

      if (hostInfo) {
        // 互踢本端是host
        const localMember = meetingInfoRef.current.localMember

        if (localMember.role === Role.host) {
          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                hostUuid: localMember.uuid,
                hostName: localMember.name,
              },
            })
        } else {
          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                hostUuid: '',
                hostName: '',
              },
            })
        }
      }

      outEventEmitter?.emit('peerLeave', uuids)
      // 本端离开
      // const index = uuids.findIndex(
      //   (uuid) => uuid === meetingInfoRef.current.localMember.uuid
      // )
      // if (index > -1) {
      //   return
      // }
      // 如果离开的人是共享人员则清空
      if (meetingInfoRef.current.screenUuid) {
        const index = uuids.findIndex(
          (uuid) => uuid === meetingInfoRef.current.screenUuid
        )

        if (index > -1) {
          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                screenUuid: '',
              },
            })
        }
      }

      if (
        meetingInfoRef.current.localMember.role === Role.host ||
        meetingInfoRef.current.localMember.role === Role.coHost
      ) {
        members.forEach((member) => {
          if (
            member.uuid !== meetingInfoRef.current.localMember.uuid &&
            member.role.name !== 'screen_sharer' &&
            originMemberList.find((item) => item.uuid === member.uuid)
          ) {
            Toast.info(`${member.name}${t('meetingLeaveFull')}`)
          }
        })
      }
    })
    eventEmitter?.on(EventType.MemberLeaveRtcChannel, () => {
      // todo
    })
    eventEmitter?.on(
      EventType.MemberRoleChanged,
      (member: NERoomMember, beforeRole, afterRole) => {
        logger.debug(
          'onMemberRoleChanged: %o %o %o %t',
          member,
          beforeRole,
          afterRole
        )
        // 本端
        if (member.uuid === meetingInfoRef.current.localMember.uuid) {
          if (afterRole === Role.host) {
            Toast.info(t('participantAssignedHost'))
            Modal.destroy('takeBackTheHost')
          } else if (afterRole === Role.coHost) {
            Toast.info(t('participantAssignedCoHost'))
          } else if (beforeRole === Role.coHost && afterRole !== Role.coHost) {
            Toast.info(t('participantUnassignedCoHost'))

            // 如果当前没有开启共享白板权限，需要退出
            if (
              !meetingInfoRef.current.whiteboardPermission &&
              meetingInfoRef.current.whiteboardUuid ===
                meetingInfoRef.current.localMember.uuid
            ) {
              eventEmitter?.emit(UserEventType.StopWhiteboard)
            }
            // 如果本端是主持人或者联席主持人则收到设置联席主持人的通知
          } else if (beforeRole === Role.host && afterRole !== Role.host) {
            // 这里通过setTimeout是因为在设置主持人的时候是 2 个通知，确保主持人设置成功后再提示
            setTimeout(() => {
              const nowHost = memberListRef.current.find(
                (member) => member.role === Role.host
              )

              if (nowHost) {
                Toast.info(t('meetingUserIsNowTheHost', { user: nowHost.name }))
              }
            })
          }

          // 被设置为主持人或者联席主持人不需要再举手
          if (afterRole === Role.coHost || afterRole === Role.host) {
            neMeeting?.sendMemberControl(memberAction.handsDown, member.uuid)
            eventEmitter?.emit('needAudioHandsUp', false)
            eventEmitter?.emit('needVideoHandsUp', false)
          }
          // neMeeting && updateMeetingService(neMeeting, dispatch as Dispatch)
        } else {
          // 如果本端是主持人或者联席主持人则收到设置联席主持人的通知
          if (
            meetingInfoRef.current.localMember.role === Role.host ||
            meetingInfoRef.current.localMember.role === Role.coHost
          ) {
            if (afterRole === Role.coHost) {
              Toast.info(`${member.name}${t('becomeTheCoHost')}`)
            } else {
              const oldMember = memberListRef.current.find(
                (_member) => _member.uuid === member.uuid
              )

              if (oldMember && oldMember.role === Role.coHost) {
                Toast.info(`${member.name}${t('participantUnassignedCoHost')}`)
              }
            }
          }
        }

        dispatch &&
          dispatch({
            type: ActionType.UPDATE_MEMBER,
            data: {
              uuid: member.uuid,
              member: { role: afterRole },
            },
          })
        // 更新主持人
        if (afterRole === Role.host) {
          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                hostUuid: member.uuid,
                hostName: member.name,
              },
            })
        }
      }
    )
    eventEmitter?.on(
      EventType.MemberScreenShareStateChanged,
      (member: NEMember, isSharing: boolean, operator: NEMember) => {
        logger.debug('onMemberScreenShareStateChanged: %o %t', member)
        const isMySelf = member.uuid === meetingInfoRef.current.localMember.uuid

        if (dispatch) {
          if (isMySelf && window.isElectronNative) {
            window.ipcRenderer?.send(IPCEvent.sharingScreen, {
              method: isSharing ? 'start' : 'stop',
            })
            // 由于electron端的延迟，需要延迟一段时间再更新状态，避免窗口画面闪烁
            dispatch({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: member.uuid,
                member: { isSharingScreen: isSharing },
              },
            })
          } else {
            dispatch({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: member.uuid,
                member: { isSharingScreen: isSharing },
              },
            })
          }
        }

        if (!isSharing) {
          if (operator.uuid !== member.uuid && isMySelf) {
            Toast.info(t('participantHostStoppedShare'))
          }
        } else {
          // todo 如果是wx浏览器目前会随机出现无法启动播放音频辅流。提前弹框一次兼容，后续rtc4.6.60会更新
          if (
            getBrowserType() === BrowserType.WX &&
            !isAlreadyPlayAudioSlaveRef.current
          ) {
            isAlreadyPlayAudioSlaveRef.current = true
            setShowReplayScreenDialog(true)
          }
        }
      }
    )
    eventEmitter?.on(
      EventType.MemberSystemAudioShareStateChanged,
      (member: NEMember, isSharing: boolean, operator) => {
        logger.debug('MemberSystemAudioShareStateChanged: %o %t', member)
        dispatch?.({
          type: ActionType.UPDATE_MEMBER,
          data: {
            uuid: member.uuid,
            member: { isSharingSystemAudio: isSharing },
          },
        })
        const isMySelf = member.uuid === meetingInfoRef.current.localMember.uuid

        if (!isSharing) {
          if (operator.uuid !== member.uuid && isMySelf) {
            Toast.info(t('participantHostStoppedShare'))
          }
        }
      }
    )
    eventEmitter?.on(
      EventType.MemberVideoMuteChanged,
      (member: NEMember, mute: boolean, operator: NEMember) => {
        logger.debug('login_对端发mutedChange: %o %t', member)
        dispatch &&
          dispatch({
            type: ActionType.UPDATE_MEMBER,
            data: {
              uuid: member.uuid,
              member: { isVideoOn: !mute },
            },
          })
        if (member.uuid === meetingInfoRef.current.localMember.uuid) {
          // 当前静音且不是自己操作
          if (mute && member.uuid !== operator.uuid) {
            Toast.info(t('participantHostMuteVideo'))
          }

          if (!mute) {
            if (meetingInfoRef.current.localMember.isHandsUp) {
              neMeeting?.sendMemberControl(memberAction.handsDown, member.uuid)
            }
          }
        }
      }
    )
    eventEmitter?.on(
      EventType.MemberWhiteboardStateChanged,
      (member: NEMember, isOpen: boolean, operator: NEMember) => {
        logger.debug('onMemberWhiteboardStateChanged: %o %t %t', member, isOpen)

        dispatch &&
          dispatch({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              whiteboardUuid: isOpen ? member.uuid : '',
            },
          })
        // 用户开着白板离开房间
        if (!member && !isOpen) {
          // 如果本端有被授权白板权限需要撤回
          if (
            meetingInfoRef.current.localMember.properties.wbDrawable?.value ===
            '1'
          ) {
            neMeeting?.sendMemberControl(
              memberAction.cancelShareWhiteShare,
              meetingInfoRef.current.localMember.uuid
            )
          }
        } else if (member) {
          const _member = memberListRef.current.find(
            (item) => item.uuid == member.uuid
          )

          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: member.uuid,
                member: {
                  properties: {
                    ..._member?.properties,
                    wbDrawable: { value: isOpen ? '1' : '0' },
                  },
                  isSharingWhiteboard: isOpen,
                },
              },
            })
          // 打开白板
          if (!isOpen) {
            // 如果本端有被授权白板权限需要撤回
            if (
              meetingInfoRef.current.localMember.properties.wbDrawable
                ?.value === '1'
            ) {
              neMeeting?.sendMemberControl(
                memberAction.cancelShareWhiteShare,
                meetingInfoRef.current.localMember.uuid
              )
            }

            if (
              member.uuid === meetingInfoRef.current.localMember.uuid &&
              operator.uuid === meetingInfoRef.current.hostUuid &&
              meetingInfoRef.current.hostUuid !==
                meetingInfoRef.current.localMember.uuid
            ) {
              Toast.info(t('hostCloseWhiteShareToast'))
            }

            // 本端白板关闭
            if (member.uuid === meetingInfoRef.current.localMember.uuid) {
              !isOpen && neMeeting?.whiteboardController?.setEnableDraw(false)
            }
          }
        }
      }
    )
    eventEmitter?.on(
      EventType.RoomPropertiesChanged,
      (properties: Record<string, { value: string }>) => {
        logger.debug('onRoomPropertiesChanged: %o %o %t', properties)
        if (properties.focus) {
          const focus = properties.focus

          if (focus.value) {
            if (meetingInfoRef.current.localMember.uuid === focus.value) {
              // todo 需要添加焦点分辨率设置逻辑
              Toast.info(t('participantAssignedActiveSpeaker'))
            } else if (
              meetingInfoRef.current.localMember.uuid ===
              meetingInfoRef.current.focusUuid
            ) {
              // todo 需要添加焦点分辨率设置逻辑
            }

            // 焦点成员已不在房间，解决极端情况下成员刚离开 设置成功焦点，造成成员入会后还是焦点
            if (
              meetingInfoRef.current.localMember.role === Role.host ||
              meetingInfoRef.current.localMember.role === Role.coHost
            ) {
              const index = memberListRef.current.findIndex(
                (member) => member.uuid == focus.value
              )

              if (index < 0) {
                neMeeting?.sendHostControl(hostAction.unsetFocus, focus.value)
              }
            }
          } else {
            cancelFocus()
          }

          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                focusUuid: focus.value,
              },
            })
        } else if (properties.audioOff) {
          const value = properties.audioOff.value?.split('_')[0]

          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                audioOff: value as AttendeeOffType,
              },
            })
          if (
            value === AttendeeOffType.offAllowSelfOn ||
            value === AttendeeOffType.disable
          ) {
            // 允许自行解除静音，且本身在举手情况下解除举手
            eventEmitter?.emit('needAudioHandsUp', false)
            if (meetingInfoRef.current.localMember.isHandsUp) {
              neMeeting?.sendMemberControl(
                memberAction.handsDown,
                meetingInfoRef.current.localMember.uuid
              )
            }
          }

          switch (value) {
            case AttendeeOffType.offNotAllowSelfOn:
            case AttendeeOffType.offAllowSelfOn:
              if (!meetingInfoRef.current.localMember.isAudioConnected) {
                return
              }

              setIsOpenAudioByHost(false)
              if (
                meetingInfoRef.current.localMember.role !== Role.host &&
                meetingInfoRef.current.localMember.role !== Role.coHost &&
                !meetingInfoRef.current.localMember.hide
              ) {
                Toast.info(t('participantHostMuteAllAudio'))
              }

              if (
                !meetingInfoRef.current.localMember.isAudioOn ||
                meetingInfoRef.current.localMember.role === Role.host ||
                meetingInfoRef.current.localMember.role === Role.coHost
              ) {
                // 已开启视频则不操作
                return
              }

              if (meetingInfoRef.current.localMember.role === Role.observer) {
                return
              }

              neMeeting?.muteLocalAudio()
              break
            case AttendeeOffType.disable: // 解除静音
              if (!meetingInfoRef.current.localMember.isAudioConnected) {
                return
              }

              setIsOpenAudioByHost(true)
              neMeeting?.sendMemberControl(
                memberAction.handsDown,
                meetingInfoRef.current.localMember.uuid
              )
              if (
                meetingInfoRef.current.localMember.isAudioOn ||
                meetingInfoRef.current.localMember.role === Role.host ||
                meetingInfoRef.current.localMember.role === Role.coHost
              ) {
                // 已开启视频则不操作
                return
              }

              if (meetingInfoRef.current.localMember.hide) {
                return
              }

              unmuteMyAudio()
              break
          }
        } else if (properties.videoOff) {
          // 全体视频操作
          const value = properties.videoOff.value?.split('_')[0]

          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                videoOff: value as AttendeeOffType,
              },
            })
          // 允许自行解除则把举手放下
          if (
            value === AttendeeOffType.offAllowSelfOn ||
            value === AttendeeOffType.disable
          ) {
            // 允许自行解除静音，且本身在举手情况下解除举手
            console.log('needVideoHandsUp', value)
            eventEmitter?.emit('needVideoHandsUp', false)
            if (meetingInfoRef.current.localMember.isHandsUp) {
              neMeeting?.sendMemberControl(
                memberAction.handsDown,
                meetingInfoRef.current.localMember.uuid
              )
            }
          }

          // 根据不同类型执行对应逻辑
          switch (value) {
            case AttendeeOffType.offNotAllowSelfOn:
            case AttendeeOffType.offAllowSelfOn:
              setIsOpenVideoByHost(false)
              if (
                meetingInfoRef.current.localMember.role !== Role.host &&
                meetingInfoRef.current.localMember.role !== Role.coHost &&
                !meetingInfoRef.current.localMember.hide
              ) {
                Toast.info(t('participantHostMuteAllVideo'))
              }

              if (
                !meetingInfoRef.current.localMember.isVideoOn ||
                meetingInfoRef.current.localMember.role === Role.host ||
                meetingInfoRef.current.localMember.role === Role.coHost
              ) {
                // 已开启视频则不操作
                return
              }

              if (meetingInfoRef.current.localMember.role === Role.observer) {
                return
              }

              neMeeting?.muteLocalVideo()
              break
            case AttendeeOffType.disable: // 解除静音
              setIsOpenVideoByHost(true)
              neMeeting?.sendMemberControl(
                memberAction.handsDown,
                meetingInfoRef.current.localMember.uuid
              )
              if (
                meetingInfoRef.current.localMember.isVideoOn ||
                meetingInfoRef.current.localMember.role === Role.host ||
                meetingInfoRef.current.localMember.role === Role.coHost
              ) {
                // 已开启视频则不操作
                return
              }

              if (meetingInfoRef.current.localMember.role === Role.observer) {
                return
              }

              unmuteMyVideo()
              break
          }
        } else if (properties.whiteboardConfig) {
          const config = properties.whiteboardConfig.value
          let isTransparent = false

          try {
            isTransparent = JSON.parse(config).isTransparent
          } catch (e) {
            console.warn('解析白板透明度失败', e)
          }

          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              isWhiteboardTransparent: isTransparent === true,
            },
          })
        } else if (properties.rooms_screen_share_mode) {
          const isScreenSharingMeeting =
            properties.rooms_screen_share_mode.value === '1'

          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              isScreenSharingMeeting: isScreenSharingMeeting,
            },
          })
        } else if (properties.watermark) {
          const watermark = properties.watermark.value

          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              watermark: JSON.parse(watermark),
            },
          })
        } else if (properties.crPerm) {
          const meetingChatPermission = Number(properties.crPerm.value)

          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              meetingChatPermission,
            },
          })
        } else if (properties.wtPrChat) {
          const waitingRoomChatPermission = Number(properties.wtPrChat.value)

          console.log('waitingRoomChatPermission', waitingRoomChatPermission)
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              waitingRoomChatPermission,
            },
          })
        } else if (properties.viewOrder) {
          const viewOrder = properties.viewOrder.value

          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              remoteViewOrder: viewOrder,
            },
          })
        } else if (properties.guest) {
          const guest = properties.guest.value
          const enableGuestJoin = guest === '1'

          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              enableGuestJoin,
            },
          })
          const localMember = meetingInfoRef.current.localMember

          if (
            localMember.role === Role.host ||
            localMember.role === Role.coHost
          ) {
            if (enableGuestJoin) {
              Toast.info(t('meetingGuestJoinSecurityNotice'))
            } else {
              Toast.info(t('meetingGuestJoinDisabled'))
            }
          }
        } else if (properties.interpretation) {
          // 同声传译
          const valueStr = properties.interpretation.value

          if (
            valueStr &&
            Object.prototype.toString.call(valueStr) === '[object String]'
          ) {
            const value: InterpretationRes = JSON.parse(valueStr)

            // 如果关闭同声传译提示
            if (
              !value.started &&
              meetingInfoRef.current.interpretation?.started &&
              !meetingInfoRef.current.openInterpretationBySelf
            ) {
              Toast.info(t('interpStopNotification'))
            }

            // 如果本端被删除译员需要弹窗提醒
            if (
              meetingInfoRef.current.isInterpreter &&
              !value.interpreters[meetingInfoRef.current.localMember.uuid]
            ) {
              eventEmitter.emit(EventType.MyInterpreterRemoved)
            }

            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                interpretation: value,
              },
            })
            // 需要等待下个轮训再设置，否则本端开启同声传译后并设置自己为一样，会有成员译员弹窗。
            setTimeout(() => {
              dispatch?.({
                type: ActionType.UPDATE_MEETING_INFO,
                data: {
                  openInterpretationBySelf: false,
                },
              })
            })
          }
        } else if (properties.securityCtrl) {
          const permissionConfig = getMeetingPermission(
            Number(properties.securityCtrl.value || 0)
          )

          if (
            meetingInfoRef.current.localMember.role !== Role.host &&
            meetingInfoRef.current.localMember.role !== Role.coHost
          ) {
            handlePermissionChange(permissionConfig, {
              annotationPermission:
                !!meetingInfoRef.current.annotationPermission,
              screenSharePermission:
                !!meetingInfoRef.current.screenSharePermission,
              unmuteAudioBySelfPermission:
                !!meetingInfoRef.current.unmuteAudioBySelfPermission,
              unmuteVideoBySelfPermission:
                !!meetingInfoRef.current.unmuteVideoBySelfPermission,
              updateNicknamePermission:
                !!meetingInfoRef.current.updateNicknamePermission,
              whiteboardPermission:
                !!meetingInfoRef.current.whiteboardPermission,
              videoAllOff: !!meetingInfoRef.current.videoAllOff,
              audioAllOff: !!meetingInfoRef.current.audioAllOff,
              playSound: !!meetingInfoRef.current.playSound,
              avatarHide: !!meetingInfoRef.current.avatarHide,
            })
            if (permissionConfig.avatarHide) {
              Toast.success(t('hostSetAvatarHide'))
            }
          }

          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              ...permissionConfig,
            },
          })
        }
      }
    )
    eventEmitter?.on(EventType.RoomLockStateChanged, (isLocked: boolean) => {
      logger.debug('onRoomLockStateChanged: %o %t', isLocked)
      dispatch &&
        dispatch({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            isLocked: isLocked,
          },
        })
    })
    eventEmitter?.on(
      EventType.MemberAudioConnectStateChanged,
      (userUuid: string, isAudioConnected: boolean) => {
        console.log('MemberAudioConnectStateChanged', isAudioConnected)
        dispatch &&
          dispatch({
            type: ActionType.UPDATE_MEMBER,
            data: {
              uuid: userUuid,
              member: {
                isAudioConnected,
              },
            },
          })
      }
    )
    eventEmitter?.on(EventType.MemberJoinRtcChannel, (members) => {
      members.forEach((member) => {
        // 当前成员列表还未取到，需要暂存
        if (!memberListRef.current || memberListRef.current.length === 0) {
          memberJoinRtcCacheListRef.current.push(member)
          return
        }

        const roomMember = memberListRef.current.find(
          (item) => item.uuid === member.uuid
        )

        if (!roomMember) {
          memberJoinRtcCacheListRef.current.push(member)
          return
        }

        handleMemberJoinRtc(member, roomMember)
      })
    })
    eventEmitter?.on(
      EventType.MemberPropertiesChanged,
      (
        userUuid: string,
        properties: Record<
          string,
          string | { value: string } | { value: '1' | '0' }
        >
      ) => {
        console.log('MemberPropertiesChanged', properties)
        logger.debug('onMemberPropertiesChanged: %o %t', properties, userUuid)
        if (properties.handsUp) {
          // handsup 1表示举手，2表示被放下
          const handsUp = properties.handsUp as Record<string, string>

          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: userUuid,
                member: {
                  isHandsUp: handsUp.value == '1',
                },
              },
            })
          if (
            handsUp.value == '2' &&
            userUuid === meetingInfoRef.current.localMember.uuid
          ) {
            Toast.info(t('hostRejectAudioHandsUp'))
          }
        } else if (properties.wbDrawable) {
          const wbDrawable = properties.wbDrawable as { value: '1' | '0' }

          // 授权
          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: userUuid,
                member: {
                  properties: {
                    wbDrawable: wbDrawable,
                  },
                },
              },
            })
          // h5 不需要白板画图，先隐藏
          if (userUuid === meetingInfoRef.current.localMember.uuid) {
            // 本端属性修改
            if (wbDrawable.value == '1') {
              Toast.info(t('whiteBoardInteractionTip'))
            } else {
              if (meetingInfoRef.current.whiteboardUuid) {
                // 当前正在共享
                Toast.info(t('whiteBoardUndoInteractionTip'))
              }
            }
          }
        } else {
          dispatch?.({
            type: ActionType.UPDATE_MEMBER_PROPERTIES,
            data: {
              uuid: userUuid,
              properties,
            },
          })
        }
      }
    )
    eventEmitter?.on(
      EventType.MemberPropertiesDeleted,
      (userUuid: string, keys: string[]) => {
        logger.debug('onMemberPropertiesDeleted: %o %o %t', keys, userUuid)
        if (!dispatch) {
          return
        }

        const member = memberListRef.current?.find(
          (member) => member.uuid === userUuid
        )

        if (!member) {
          logger.warn('member not found', userUuid)
          return
        }

        keys.forEach((key) => {
          if (key === 'handsUp') {
            // 举手
            dispatch({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: userUuid,
                member: { isHandsUp: false },
              },
            })
          } else if (key === 'wbDrawable') {
            // 收到取消白板授权
            dispatch({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: userUuid,
                member: {
                  properties: {
                    wbDrawable: { value: '0' },
                  },
                },
              },
            })
            if (meetingInfoRef.current.whiteboardUuid) {
              // 当前正在共享
              Toast.info(t('whiteBoardUndoInteractionTip'))
            }
          }
        })
        dispatch({
          type: ActionType.DELETE_MEMBER_PROPERTIES,
          data: {
            uuid: userUuid,
            properties: keys,
          },
        })
      }
    )
    eventEmitter?.on(EventType.RoomPropertiesDeleted, (keys: string[]) => {
      console.log('RoomPropertiesDeleted', keys)
      logger.debug('onRoomPropertiesDeleted: %o %t', keys)
      keys.forEach((key) => {
        switch (key) {
          case 'focus':
            cancelFocus()
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                focusUuid: '',
              },
            })
            break
          case 'lock':
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                isLocked: false,
              },
            })
            break
          case 'whiteboardConfig':
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                isWhiteboardTransparent: false,
              },
            })
            break
          case 'rooms_screen_share_mode':
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                isScreenSharingMeeting: false,
              },
            })
            break
          case 'viewOrder':
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                remoteViewOrder: undefined,
              },
            })
            break
          default:
            break
        }
      })
    })

    eventEmitter?.on(EventType.NetworkReconnect, () => {
      if (canShowNetworkToastRef.current) {
        globalDispatch?.({
          type: ActionType.UPDATE_GLOBAL_CONFIG,
          data: {
            online: false,
          },
        })
      }

      canShowNetworkToastRef.current = false
      setTimeout(() => {
        setNetworkQuality({
          userUuid: '',
          upStatus: 4,
          downStatus: 4,
        })
      }, 1000)
    })
    // 不在这里监听否则全局2s更新一次
    // eventEmitter?.on(
    //   EventType.NetworkQuality,
    //   (data: NERoomRtcNetworkQualityInfo[]) => {
    //     if (data) {
    //       const localNetwork = data.find((item) => {
    //         return item.userUuid === meetingInfoRef.current?.localMember.uuid
    //       })
    //       console.log("ssss", localNetwork)
    //       if (localNetwork) {
    //         // 设置下行网络质量
    //         setNetworkQuality(localNetwork)
    //       }
    //     }
    //   }
    // )
    eventEmitter?.on(EventType.RoomEnded, (reason: string) => {
      logger.debug(
        'onRoomEnded: %o %t',
        reason,
        waitingRejoinMeetingRef.current
      )
      canShowNetworkToastRef.current = true
      if (reason === 'RTC_CHANNEL_ERROR') {
        eventEmitter.emit(MeetingEventType.rtcChannelError)
        /*
        dispatch?.({
          type: ActionType.RESET_MEMBER,
          data: null,
        })
        */
        globalDispatch?.({
          type: ActionType.UPDATE_GLOBAL_CONFIG,
          data: {
            waitingRejoinMeeting: true,
            online: true,
          },
        })
        // dispatch?.({
        //   type: ActionType.RESET_MEETING,
        //   data: null,
        // })
        return
      }

      if (
        waitingRejoinMeetingRef.current ||
        waitingJoinOtherMeetingRef.current
      ) {
        return
      }

      // outEventEmitter?.emit(EventType.RoomEnded, reason)
      // 组件层不需要提醒，会议结束的Toast
      /*
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
      const localMember = meetingInfoRef.current.localMember

      if (
        (localMember.role != Role.host && localMember.role != Role.coHost) ||
        reason !== 'CLOSE_BY_MEMBER'
      ) {
        langMap[reason] && Toast.info(langMap[reason])
      }
      */

      roomEndedHandler(reason)
    })
    eventEmitter?.on(
      EventType.RtcActiveSpeakerChanged,
      throttle((activeSpeaker) => {
        if (
          activeSpeaker.userUuid === meetingInfoRef.current.activeSpeakerUuid
        ) {
          return
        }

        dispatch &&
          dispatch({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              activeSpeakerUuid: activeSpeaker.userUuid,
              lastActiveSpeakerUuid: activeSpeaker.userUuid,
            },
          })
        if (activeSpeakerTimerRef.current) {
          clearTimeout(activeSpeakerTimerRef.current)
          activeSpeakerTimerRef.current = null
        }

        // 不再清空，现在逻辑是主画面停留在最后一个者
        // 4s未收到新数据表示没人说话 情况当前说话，保留最后一个说话者用户主画面显示
        activeSpeakerTimerRef.current = window.setTimeout(() => {
          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                activeSpeakerUuid: '',
              },
            })
        }, 4000)
      }, 200)
    )
    eventEmitter?.on(EventType.ClientBanned, () => {
      logger.debug('clientBanned: 当前用户被踢出 %t')
      Toast.info(t('meetingSwitchOtherDevice'))
      setIsShowAudioDialog(false)
      setIsShowVideoDialog(false)
      setShowReplayDialog(false)
      isReplayedRef.current = false // 重置重新播放标志
      isReplayedVideoRef.current = false // 重置重新播放标志
      isReplayedScreenRef.current = false // 重置重新播放标志
      dispatch &&
        dispatch({
          type: ActionType.RESET_MEETING,
          data: null,
        })
      roomEndedHandler(NERoomEndReason.kICK_BY_SELF)
    })
    eventEmitter?.on(EventType.NetworkError, () => {
      console.log('断网 NetworkError')
      // todo 断网
      setTimeout(() => {
        roomEndedHandler('NetworkError')
      }, 1000)
    })
    eventEmitter?.on(EventType.NetworkReconnectSuccess, () => {
      Toast.info(t('networkReconnectSuccess'))
      globalDispatch?.({
        type: ActionType.UPDATE_GLOBAL_CONFIG,
        data: {
          online: true,
        },
      })
      canShowNetworkToastRef.current = true
      // electron 不再重新更新房间数据，依赖监听事件更新，否则会崩溃
      if (!window.isElectronNative) {
        neMeeting && updateMeetingService(neMeeting, dispatch as Dispatch)
      }

      neMeeting?.waitingRoomController
        ?.getMemberList(0, 20, true)
        .then((res) => {
          const memberList = res.data

          waitingRoomDispatch?.({
            type: ActionType.WAITING_ROOM_SET_MEMBER_LIST,
            data: { memberList },
          })
          neMeeting?.updateWaitingRoomUnReadCount(memberList.length)
        })
    })

    eventEmitter?.on(
      EventType.RtcChannelDisconnect,
      async (channel: string) => {
        // 如果开启同传，且是当前收听语言则toast
        if (meetingInfoRef.current.interpretation?.started) {
          const listenLanguage =
            interpretationSettingRef.current?.listenLanguage

          if (!listenLanguage || listenLanguage === MAJOR_AUDIO) {
            return
          }

          const listenChannel =
            meetingInfoRef.current.interpretation?.channelNames[listenLanguage]

          if (listenChannel === channel) {
            Toast.info(t('interpListeningChannelDisconnect'))
            // await neMeeting?.leaveRtcChannel(channel)
            // await neMeeting?.joinRtcChannel(channel)
            return
          }

          // 当前是译员
          if (meetingInfoRef.current.isInterpreter) {
            const speakerLangs =
              meetingInfoRef.current.interpretation.interpreters[
                meetingInfoRef.current.localMember.uuid
              ]
            const speakerChannel = speakerLangs.map((lang) => {
              return meetingInfoRef.current.interpretation?.channelNames[lang]
            })

            if (speakerChannel && speakerChannel.includes(channel)) {
              Toast.info(t('interpSpeakingChannelDisconnect'))
              // try {
              //   await neMeeting?.enableAndPubAudio(false, channel)
              //   await neMeeting?.leaveRtcChannel(channel)
              // } catch (error) {
              //   logger.debug('RtcChannelDisconnect error', error)
              // }

              // await neMeeting?.joinRtcChannel(channel)
              // await neMeeting?.enableAndPubAudio(true, channel)
            }
          }
        }
      }
    )

    eventEmitter?.on(EventType.RoomLiveStateChanged, (state) => {
      console.log('RoomLiveStateChanged', state)
      // 需要触发live组件内部的更新
      if (meetingInfoRef.current.liveState === state) {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            liveState: 0,
          },
        })
      }

      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          liveState: state,
        },
      })
    })
    eventEmitter?.on(EventType.ReceivePassThroughMessage, (res) => {
      logger.debug('onReceivePassThroughMessage: %o %t', res)
      const { body } = res.data
      const senderUuid = res.senderUuid
      const localMember = meetingInfoRef.current.localMember

      if (localMember.isHandsUp) {
        neMeeting?.sendMemberControl(memberAction.handsDown, localMember.uuid)
      }

      const isMySelf = senderUuid === localMember.uuid

      switch (
        body.type // 主持人可开启
      ) {
        case 1:
          logger.debug('开启mic请求 %t')
          if (!isMySelf && localMember.isHandsUp && !localMember.isAudioOn) {
            // 非主持人或者联席主持人打开自己的
            Toast.info(t('hostAgreeAudioHandsUp'))
          }

          unmuteMyAudio()
          break
        case 2:
          logger.debug('开启camera请求 %t')
          // this.$neMeeting.sendMemberControl(memberAction.handsDown, [this.localInfo.avRoomUid]);
          unmuteMyVideo(isMySelf)
          break
        case 3:
          logger.debug('开启音视频请求 %t')
          if (!isMySelf && localMember.isHandsUp && !localMember.isAudioOn) {
            // 非主持人或者联席主持人打开自己的
            Toast.info(t('hostAgreeAudioHandsUp'))
          }

          // this.$neMeeting.sendMemberControl(memberAction.handsDown, [this.localInfo.avRoomUid]);
          unmuteMyAudio()
          unmuteMyVideo(isMySelf)
          break
      }
    })
    eventEmitter?.on(
      EventType.roomCloudRecordStateChanged,
      (recordState, operatorMember) => {
        const isCloudRecording = recordState === 0

        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            isCloudRecording,
            cloudRecordState: isCloudRecording
              ? RecordState.Recording
              : RecordState.NotStart,
          },
        })
        // 本端操作不处理
        if (
          !operatorMember ||
          meetingInfoRef.current.localMember.uuid != operatorMember.uuid
        ) {
          eventEmitter?.emit(
            MeetingEventType.needShowRecordTip,
            isCloudRecording
          )
        }
      }
    )
    eventEmitter?.on(EventType.roomRemainingSecondsRenewed, (data) => {
      console.log(
        'roomRemainingSecondsRenewed',
        data,
        showMeetingRemainingTipRef.current
      )
      showMeetingRemainingTipRef.current &&
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            remainingSeconds: data,
          },
        })
    })
    eventEmitter?.on(
      EventType.MemberSipInviteStateChanged,
      handleMemberSipInviteStateChanged
    )
    eventEmitter?.on(
      EventType.MemberAppInviteStateChanged,
      handleMemberSipInviteStateChanged
    )

    eventEmitter?.on(EventType.AutoPlayNotAllowed, (data) => {
      console.log('-notAllowedError- ', data)
      if (data.type === 'audioSlave') {
        setShowReplayAudioSlaveDialog(true)
      } else {
        setShowReplayDialog(true)
      }
      // if (data.type === 'audio') {
      //   // 只展示一次交互弹窗
      //   // !isReplayedRef.current && setShowReplayDialog(true)
      //   setShowReplayDialog(true)
      //   // isReplayedRef.current = true
      // } else if (data.type === 'video') {
      //   // !isReplayedVideoRef.current && setShowReplayVideoDialog(true)
      //   setShowReplayVideoDialog(true)
      //   // isReplayedVideoRef.current = true
      // } else {
      //   // !isReplayedScreenRef.current && setShowReplayScreenDialog(true)
      //   setShowReplayScreenDialog(true)
      //   // isReplayedScreenRef.current = true
      // }
    })

    /*
    eventEmitter?.on(
      EventType.RtcLocalAudioVolumeIndication,
      (volume: number) => {
        const localMember = meetingInfoRef.current.localMember
        dispatch &&
          dispatch({
            type: ActionType.UPDATE_MEMBER,
            data: {
              uuid: localMember.uuid,
              member: {
                volume,
              },
            },
          })
      }
    )
    eventEmitter?.on(
      EventType.RtcAudioVolumeIndication,
      (arr: { userUuid: string; volume: number }[]) => {
        arr.forEach((item) => {
          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: item.userUuid,
                member: {
                  volume: item.volume,
                },
              },
            })
        })
      }
    )
    */
    eventEmitter?.on(EventType.meetingStatusChanged, ({ status, arg }) => {
      outEventEmitter?.emit(UserEventType.onMeetingStatusChanged, status, arg)
    })
    eventEmitter?.on(EventType.MemberJoinWaitingRoom, (member, reason) => {
      console.log('MemberJoinWaitingRoom', member, reason)
      waitingRoomDispatch?.({
        type: ActionType.WAITING_ROOM_ADD_MEMBER,
        data: { member },
      })
    })
    eventEmitter?.on(EventType.MemberLeaveWaitingRoom, (memberId, reason) => {
      console.log('MemberLeaveWaitingRoom', memberId, reason)
      if (memberId === meetingInfoRef.current.privateChatMemberId) {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            privateChatMemberId: 'meetingAll',
          },
        })
      }

      waitingRoomDispatch?.({
        type: ActionType.WAITING_ROOM_REMOVE_MEMBER,
        data: { uuid: memberId },
      })
    })
    eventEmitter?.on(EventType.WaitingRoomAllMembersKicked, () => {
      waitingRoomDispatch?.({
        type: ActionType.WAITING_ROOM_SET_MEMBER_LIST,
        data: { memberList: [] },
      })
    })
    eventEmitter?.on(EventType.WaitingRoomInfoUpdated, (info) => {
      console.log('WaitingRoomInfoUpdated', info)
      waitingRoomDispatch?.({
        type: ActionType.WAITING_ROOM_UPDATE_INFO,
        data: { info },
      })
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          isWaitingRoomEnabled: info.isEnabledOnEntry,
        },
      })
    })
    eventEmitter?.on(EventType.MemberAdmitted, (memberId) => {
      console.log('MemberAdmitted', memberId)
      waitingRoomDispatch?.({
        type: ActionType.WAITING_ROOM_UPDATE_MEMBER,
        data: {
          uuid: memberId,
          member: {
            status: 2,
          },
        },
      })
    })
    eventEmitter?.on(EventType.MemberNameChangedInWaitingRoom, handleNameChange)
    eventEmitter?.on(EventType.MyWaitingRoomStatusChanged, (status, reason) => {
      console.log('MyWaitingRoomStatusChanged', status, reason)
      if (waitingRejoinMeetingRef.current) {
        return
      }

      // 被准入
      if (status === 2) {
        neMeeting?.rejoinAfterAdmittedToRoom().then(() => {
          const meeting = neMeeting?.getMeetingInfo()

          console.log('getMeetingInfo>>>>>', meeting)
          meeting &&
            dispatch?.({
              type: ActionType.SET_MEETING,
              data: meeting,
            })
          outEventEmitter?.emit(
            UserEventType.onMeetingStatusChanged,
            NEMeetingStatus.MEETING_STATUS_INMEETING
          )
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              inWaitingRoom: false,
            },
          })
        })
      } else if (status === 3) {
        // 不是加入房间
        if (
          reason !== 5 &&
          reason !== 2 &&
          !waitingJoinOtherMeetingRef.current
        ) {
          neMeeting?.eventEmitter?.emit(EventType.RoomEnded, reason)
        }
      } else if (status === 1) {
        neMeeting?.eventEmitter?.emit(
          UserEventType.onMeetingStatusChanged,
          NEMeetingStatus.MEETING_STATUS_IN_WAITING_ROOM
        )
        dispatch?.({
          type: ActionType.UPDATE_MEMBER,
          data: {
            uuid: meetingInfoRef.current.localMember.uuid,
            member: { isSharingScreen: false },
          },
        })

        // 需要延迟防止共享时候窗口未恢复
        setTimeout(() => {
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              inWaitingRoom: true,
            },
          })
        })
      }
    })

    eventEmitter?.on(EventType.RoomWatermarkChanged, (value: WatermarkInfo) => {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          watermark: value,
        },
      })
    })
    eventEmitter?.on(
      MeetingEventType.waitingRoomMemberListChange,
      (newAddMembers: NEWaitingRoomMember[]) => {
        if (newAddMembers.length === 0) {
          return
        }

        waitingRoomDispatch?.({
          type: ActionType.WAITING_ROOM_ADD_MEMBER_LIST,
          data: { memberList: newAddMembers },
        })
      }
    )

    eventEmitter?.on(
      MeetingEventType.updateWaitingRoomUnReadCount,
      (count: number) => {
        waitingRoomDispatch?.({
          type: ActionType.WAITING_ROOM_UPDATE_INFO,
          data: {
            info: {
              unReadMsgCount: count,
            },
          },
        })
      }
    )
    eventEmitter?.on(
      MeetingEventType.updateMeetingInfo,
      (info: Record<string, string>) => {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            ...info,
          },
        })
      }
    )
    eventEmitter?.on(
      EventType.RoomLiveBackgroundInfoChanged,
      (sequence: number | undefined) => {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            liveBackgroundInfo: {
              ...meetingInfoRef.current.liveBackgroundInfo,
              newSequence: sequence,
            },
          },
        })
      }
    )
    eventEmitter?.on(
      EventType.RoomAnnotationEnableChanged,
      (enable: boolean) => {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            annotationEnabled: enable,
          },
        })
      }
    )
    eventEmitter?.on(EventType.RoomMaxMembersChanged, (maxMembers: number) => {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          maxMembers,
        },
      })
    })
    eventEmitter?.on(
      EventType.OnStartPlayMedia,
      (data: { userUuid: string; type: NEMediaTypes }) => {
        if (data.type === 'audio' && getClientType() === 'Android') {
          setShowStartPlayDialog(true)
        }
      }
    )
    eventEmitter?.on(
      EventType.ReceiveScheduledMeetingUpdate,
      handleMeetingUpdate
    )
    eventEmitter?.on(EventType.RoomBlacklistStateChanged, (enable: boolean) => {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          enableBlacklist: enable,
        },
      })
    })

    eventEmitter?.on(EventType.OnPrivateChatMemberIdSelected, (id) => {
      if (meetingInfoRef.current.rightDrawerTabActiveKey === 'chatroom') {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            rightDrawerTabActiveKey: '',
          },
        })
      }

      // 强制更新
      setTimeout(() => {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            privateChatMemberId: id,
            rightDrawerTabActiveKey: 'chatroom',
          },
        })
      })
    })
  }, [
    cancelFocus,
    dispatch,
    eventEmitter,
    globalDispatch,
    handleMeetingUpdate,
    handleMemberJoinRtc,
    handleMemberSipInviteStateChanged,
    handleNameChange,
    neMeeting,
    outEventEmitter,
    roomEndedHandler,
    t,
    unmuteMyAudio,
    unmuteMyVideo,
    waitingRoomDispatch,
  ])

  const removeEventListener = useCallback(() => {
    logger.debug('移除监听事件')
    // eventEmitter?.off(UserEventType.SetLeaveCallback)
    eventEmitter?.off(EventType.MemberAudioMuteChanged)
    eventEmitter?.off(EventType.MemberJoinRtcChannel)
    eventEmitter?.off(EventType.MemberNameChanged)
    eventEmitter?.off(EventType.MemberJoinRoom)
    eventEmitter?.off(EventType.MemberLeaveChatroom)
    eventEmitter?.off(EventType.MemberLeaveRoom)
    eventEmitter?.off(EventType.MemberLeaveRtcChannel)
    eventEmitter?.off(EventType.MemberRoleChanged)
    eventEmitter?.off(EventType.MemberScreenShareStateChanged)
    eventEmitter?.off(EventType.MemberVideoMuteChanged)
    eventEmitter?.off(EventType.MemberWhiteboardStateChanged)
    eventEmitter?.off(EventType.RoomPropertiesChanged)
    eventEmitter?.off(EventType.RoomLockStateChanged)
    eventEmitter?.off(EventType.MemberAudioConnectStateChanged)
    eventEmitter?.off(EventType.MemberPropertiesChanged)
    eventEmitter?.off(EventType.MemberPropertiesDeleted)
    eventEmitter?.off(EventType.RoomPropertiesDeleted)
    eventEmitter?.off(EventType.NetworkReconnect)
    eventEmitter?.off(EventType.RoomEnded)
    eventEmitter?.off(EventType.RtcActiveSpeakerChanged)
    eventEmitter?.off(EventType.ClientBanned)
    eventEmitter?.off(EventType.NetworkReconnectSuccess)
    eventEmitter?.off(EventType.DeviceChange)
    eventEmitter?.off(EventType.RoomLiveStateChanged)
    eventEmitter?.off(EventType.ReceivePassThroughMessage)
    eventEmitter?.off(EventType.roomCloudRecordStateChanged)
    eventEmitter?.off(EventType.NetworkError)
    eventEmitter?.off(EventType.AutoPlayNotAllowed)
    eventEmitter?.off(EventType.roomRemainingSecondsRenewed)
    eventEmitter?.off(EventType.AutoPlayNotAllowed)
    eventEmitter?.off(EventType.meetingStatusChanged)
    eventEmitter?.off(EventType.MemberJoinWaitingRoom)
    eventEmitter?.off(EventType.MemberLeaveWaitingRoom)
    eventEmitter?.off(EventType.WaitingRoomInfoUpdated)
    eventEmitter?.off(EventType.MemberAdmitted)
    eventEmitter?.off(
      EventType.MemberNameChangedInWaitingRoom,
      handleNameChange
    )
    eventEmitter?.off(EventType.MyWaitingRoomStatusChanged)
    eventEmitter?.off(EventType.RoomWatermarkChanged)
    eventEmitter?.off(MeetingEventType.waitingRoomMemberListChange)
    eventEmitter?.off(MeetingEventType.updateWaitingRoomUnReadCount)
    eventEmitter?.off(MeetingEventType.updateMeetingInfo)
    eventEmitter?.off(EventType.RoomLiveBackgroundInfoChanged)
    eventEmitter?.off(EventType.RoomAnnotationEnableChanged)
    eventEmitter?.off(
      EventType.ReceiveScheduledMeetingUpdate,
      handleMeetingUpdate
    )
    eventEmitter?.off(EventType.OnPrivateChatMemberIdSelected)
    eventEmitter?.off(
      EventType.MemberSipInviteStateChanged,
      handleMemberSipInviteStateChanged
    )
    eventEmitter?.off(
      EventType.MemberAppInviteStateChanged,
      handleMemberSipInviteStateChanged
    )
    eventEmitter?.off(EventType.MemberJoinRtcChannel)
    // eventEmitter?.off(EventType.RtcLocalAudioVolumeIndication)
    // eventEmitter?.off(EventType.RtcAudioVolumeIndication)
  }, [
    eventEmitter,
    handleMemberSipInviteStateChanged,
    handleNameChange,
    handleMeetingUpdate,
  ])

  const handleCheckTime = useCallback(
    (time: number, preTime: number) => {
      //5分钟到10分钟，并且上一秒是大于600秒则表示第一次进入10分钟。需要进行提示
      if (preTime > 600 && 300 < time && time <= 600) {
        setTimeTipContent(t('meetingTime10Tips'))
        setShowTimeTip(true)
      } else if (preTime > 300 && 60 < time && time <= 300) {
        //1分钟到5分钟，并且上一秒是大于300秒则表示第一次进入5分钟。需要进行提示
        setTimeTipContent(t('meetingTime5Tips'))
        setShowTimeTip(true)
      } else if (preTime > 60 && 0 < time && time <= 60) {
        setTimeTipContent(t('meetingTime1Tips'))
        setShowTimeTip(true)
      }

      // 离开会议也不在
      if (time <= 0 || !meetingInfoRef.current.meetingNum) {
        remainingTimer.current && clearInterval(remainingTimer.current)
        return
      }
      // 一秒检查一次
      // remainingTimer.current = setTimeout(() => {
      //   remainingTimer.current = null
      //   remainingSeconds.current = Math.max(time - 1, -1)
      //   handleCheckTime(remainingSeconds.current, time)
      // }, 1000)
    },
    [t]
  )

  const handleRemainingTime = useCallback(
    (time: number | undefined) => {
      remainingTimer.current && clearInterval(remainingTimer.current)
      const showTimeTipByGlobalConfig =
        globalConfig?.appConfig?.ROOM_END_TIME_TIP?.enable

      if (
        !time ||
        !showTimeTipByGlobalConfig ||
        !showMeetingRemainingTipRef.current
      ) {
        return
      }

      setShowTimeTip(false)
      remainingSeconds.current = Math.max(time - 1, -1)
      handleCheckTime(remainingSeconds.current, time)
      remainingTimer.current = setInterval(() => {
        const preTime = remainingSeconds.current

        remainingSeconds.current = Math.max(preTime - 1, -1)
        handleCheckTime(remainingSeconds.current, preTime)
      }, 1000)
    },

    [globalConfig?.appConfig?.ROOM_END_TIME_TIP?.enable, handleCheckTime]
  )

  useEffect(() => {
    if (!meetingInfo.remainingSeconds || meetingInfo.remainingSeconds <= 0) {
      return
    }

    handleRemainingTime(meetingInfo.remainingSeconds)
  }, [meetingInfo.remainingSeconds, handleRemainingTime])

  const confirmToReplay = (
    type: 'video' | 'audio' | 'screen' | 'audioSlave',
    isRestricted?: boolean
  ) => {
    if (type === 'audioSlave') {
      setShowReplayAudioSlaveDialog(false)
    } else if (type === 'screen') {
      setShowReplayScreenDialog(false)
    } else {
      setShowReplayDialog(false)
      setShowStartPlayDialog(false)
    }

    memberListRef.current?.forEach((item) => {
      neMeeting?.replayRemoteStream({
        userUuid: item.uuid,
        type,
        isRestricted,
      })
    })
  }

  const confirmUnMuteMyAudio = () => {
    const { localMember, unmuteAudioBySelfPermission, screenUuid } =
      meetingInfoRef.current
    const isHost =
      localMember.role === Role.host || localMember.role === Role.coHost
    const isScreen = !!screenUuid && screenUuid === localMember.uuid

    if (localMember.isAudioOn) {
      return
    }

    // 收到弹窗后未操作，主持人又关闭了全体音频的情况
    // 当前房间不允许自己打开，非主持人，当前非共享用户
    if (
      !unmuteAudioBySelfPermission &&
      !isHost &&
      !isScreen &&
      !isOpenAudioByHostRef.current
    ) {
      setIsShowAudioDialog(false)
      eventEmitter?.emit(EventType.CheckNeedHandsUp, {
        type: 'audio',
        isOpen: true,
      })
      return
    }

    isOpenAudioByHostRef.current = false
    neMeeting
      ?.unmuteLocalAudio()
      .then(() => {
        // 如果是举手状态则放下
        if (localMember.isHandsUp) {
          neMeeting?.sendMemberControl(
            memberAction.handsDown,
            meetingInfoRef.current.localMember.uuid
          )
        }

        dispatch &&
          dispatch({
            type: ActionType.UPDATE_MEMBER,
            data: {
              uuid: localMember.uuid,
              member: {
                isHandsUp: false,
              },
            },
          })
      })
      .catch((e: unknown) => {
        Toast.info(t('participantUnMuteAudioFail'))
        logger.error('muteLocalAudio %o %t', e)
      })
    setIsShowAudioDialog(false)
  }

  const confirmUnMuteMyVideo = () => {
    const { localMember, unmuteVideoBySelfPermission, screenUuid } =
      meetingInfoRef.current
    const isHost =
      localMember.role === Role.host || localMember.role === Role.coHost
    const isScreen = !!screenUuid && screenUuid === localMember.uuid

    if (localMember.isVideoOn) {
      return
    }

    // 收到弹窗后未操作，主持人又关闭了全体视频的情况
    // 当前房间不允许自己打开，非主持人，当前非共享用户
    if (
      !unmuteVideoBySelfPermission &&
      !isHost &&
      !isScreen &&
      !isOpenVideoByHostRef.current
    ) {
      setIsShowVideoDialog(false)
      eventEmitter?.emit(EventType.CheckNeedHandsUp, {
        type: 'video',
        isOpen: true,
      })
      return
    }

    isOpenVideoByHostRef.current = false
    neMeeting
      ?.unmuteLocalVideo()
      .then(() => {
        // 如果是举手状态则放下
        if (localMember.isHandsUp) {
          neMeeting?.sendMemberControl(
            memberAction.handsDown,
            meetingInfoRef.current.localMember.uuid
          )
        }

        dispatch &&
          dispatch({
            type: ActionType.UPDATE_MEMBER,
            data: {
              uuid: localMember.uuid,
              member: {
                isHandsUp: false,
              },
            },
          })
      })
      .catch((e: unknown) => {
        Toast.info(t('participantUnMuteVideoFail'))
        logger.error('muteLocalVideo %o %t', e)
      })
    setIsShowVideoDialog(false)
  }

  const setIsOpenVideoByHost = (isOpen: boolean) => {
    isOpenVideoByHostRef.current = isOpen
  }

  const setIsOpenAudioByHost = (isOpen: boolean) => {
    isOpenAudioByHostRef.current = isOpen
  }

  return {
    joinLoading,
    showReplayDialog,
    showStartPlayDialog,
    showReplayScreenDialog,
    isShowAudioDialog,
    isShowVideoDialog,
    showReplayAudioSlaveDialog,
    showTimeTip,
    setIsOpenVideoByHost,
    setIsShowVideoDialog,
    setIsOpenAudioByHost,
    setIsShowAudioDialog,
    confirmToReplay,
    confirmUnMuteMyVideo,
    confirmUnMuteMyAudio,
    setShowTimeTip,
    timeTipContent,
    networkQuality,
  }
}

/**
 * app的web和h5复用逻辑
 */
import { NERoomMember, NERoomRtcNetworkQualityInfo } from 'neroom-web-sdk'
import { NEWaitingRoomMember } from 'neroom-web-sdk/dist/types/types/interface'
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
  EventType,
  GlobalContext as GlobalContextInterface,
  hostAction,
  MeetingEventType,
  MeetingInfoContextInterface,
  memberAction,
  NEMeetingInfo,
  NEMember,
  RecordState,
  Role,
  UserEventType,
  WatermarkInfo,
} from '../types'
import { NEMeetingLeaveType, NEMeetingStatus } from '../types/type'
import { debounce, getBrowserType, throttle } from '../utils'
import DataReporter from '../utils/DataReporter'
import { Logger } from '../utils/Logger'

const logger = new Logger('Meeting-NeMeeting', true)
const reporter = DataReporter.getInstance()

interface UseEventHandlerInterface {
  joinLoading: boolean | undefined
  showReplayDialog: boolean
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
  confirmToReplay: (type: 'audio' | 'video' | 'audioSlave' | 'screen') => void
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
    online,
  } = useContext<GlobalContextInterface>(GlobalContext)
  const { dispatch: waitingRoomDispatch } = useWaitingRoomContext()
  const { eventEmitter, outEventEmitter } =
    useContext<GlobalContextInterface>(GlobalContext)
  const [leaveCallback, setLeaveCallback] = useState<
    ((reason: NEMeetingLeaveType) => void) | null
  >(null)
  const meetingInfoRef = useRef<NEMeetingInfo>(meetingInfo)
  const memberListRef = useRef<NEMember[]>(memberList)
  const remainingTimer = useRef<null | ReturnType<typeof setTimeout>>(null)
  const hiddenTimeTipTimer = useRef<null | ReturnType<typeof setTimeout>>(null)
  const remainingSeconds = useRef<number>(0)
  const showMeetingRemainingTipRef = useRef<boolean>(false)
  const [timeTipContent, setTimeTipContent] = useState<string>('')
  const [showTimeTip, setShowTimeTip] = useState<boolean>(false)

  meetingInfoRef.current = meetingInfo
  memberListRef.current = memberList
  showMeetingRemainingTipRef.current = !!showMeetingRemainingTip

  const isAlreadyPlayAudioSlaveRef = useRef<boolean>(false)
  const isAlreadyPlayAudioRef = useRef<boolean>(false)
  const [showReplayDialog, setShowReplayDialog] = useState<boolean>(false)
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
  const { t } = useTranslation()
  useEffect(() => {
    console.log('添加监听事件')
    if (meetingInfo.meetingNum) {
      addEventListener()
    }
    return () => {
      console.log('移除监听事件')
      removeEventListener()
      // outEventEmitter?.removeAllListeners()
      // roomEndedHandler()
      remainingTimer.current && clearInterval(remainingTimer.current)
    }
  }, [meetingInfo.meetingNum])

  useEffect(() => {
    if (!meetingInfo.remainingSeconds || meetingInfo.remainingSeconds <= 0) {
      return
    }
    handleRemainingTime(meetingInfo.remainingSeconds)
  }, [meetingInfo.remainingSeconds])

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

  const addEventListener = useCallback(() => {
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
          if (
            meetingInfoRef.current.localMember.isHandsUp &&
            meetingInfoRef.current.audioOff ===
              AttendeeOffType.offNotAllowSelfOn
          ) {
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
      })
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
            member.role.name !== 'screen_sharer'
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
          } else if (beforeRole === Role.coHost && afterRole !== Role.host) {
            Toast.info(t('participantUnassignedCoHost'))
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
        if (dispatch) {
          dispatch({
            type: ActionType.UPDATE_MEMBER,
            data: {
              uuid: member.uuid,
              member: { isSharingScreen: isSharing },
            },
          })
        }

        if (!isSharing) {
          if (
            operator.uuid !== member.uuid &&
            member.uuid === meetingInfoRef.current.localMember.uuid
          ) {
            Toast.info(t('participantHostStoppedShare'))
          }
          reporter.send({
            action_name: 'member_screen_share_stop',
            member_uid: member.uuid,
          })
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
            if (
              meetingInfoRef.current.localMember.isHandsUp &&
              meetingInfoRef.current.videoOff ===
                AttendeeOffType.offNotAllowSelfOn
            ) {
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
          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: member.uuid,
                member: {
                  properties: {
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
      (properties: Record<string, any>) => {
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
          } catch (e) {}
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
    eventEmitter?.on(
      EventType.MemberPropertiesChanged,
      (userUuid: string, properties: Record<string, any>) => {
        console.log('MemberPropertiesChanged', properties)
        logger.debug('onMemberPropertiesChanged: %o %t', properties, userUuid)
        if (properties.handsUp) {
          // handsup 1表示举手，2表示被放下
          const handsUp = properties.handsUp
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
          // 授权
          dispatch &&
            dispatch({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: userUuid,
                member: {
                  properties: {
                    wbDrawable: properties.wbDrawable,
                  },
                },
              },
            })
          // h5 不需要白板画图，先隐藏
          if (userUuid === meetingInfoRef.current.localMember.uuid) {
            // 本端属性修改
            if (properties.wbDrawable.value == '1') {
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
      logger.debug('onRoomEnded: %o %t', reason)
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
      if (waitingRejoinMeeting) {
        return
      }

      // outEventEmitter?.emit(EventType.RoomEnded, reason)
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
      if (localMember.role != Role.host && localMember.role != Role.coHost) {
        langMap[reason] && Toast.info(langMap[reason])
      }
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
      outEventEmitter?.emit(
        EventType.RoomEnded,
        NEMeetingLeaveType.LEAVE_BY_SELF
      )
      try {
        leaveCallback && leaveCallback(NEMeetingLeaveType.LEAVE_BY_SELF)
      } catch (e) {
        logger.warn('leaveCallback failed', e)
      }
      neMeeting?.destroy()
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
          unmuteMyAudio(isMySelf)
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
          unmuteMyAudio(isMySelf)
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
        if (reason !== 5) {
          outEventEmitter?.emit(EventType.RoomEnded, reason)
        }
      } else if (status === 1) {
        outEventEmitter?.emit(
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
      (info: Record<string, any>) => {
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
      EventType.ReceiveScheduledMeetingUpdate,
      handleMeetingUpdate
    )
    eventEmitter?.on(
      EventType.RoomLiveBackgroundInfoChanged,
      (enable: boolean) => {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            enableBlacklist: enable,
          },
        })
      }
    )

    eventEmitter?.on(EventType.OnPrivateChatMemberIdSelected, (id) => {
      // 强制更新
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          privateChatMemberId: id,
          rightDrawerTabActiveKey: 'chatroom',
        },
      })
    })
  }, [])
  const handleMeetingUpdate = useCallback((res) => {
    if (res.data) {
      if (res.data?.type === 200) {
        window.isElectronNative && Toast.warning(t('tokenExpired'), 4000)
      }
    }
  }, [])
  const handleNameChange = useCallback((memberId, name) => {
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
  }, [])

  const removeEventListener = () => {
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
    eventEmitter?.off(
      EventType.ReceiveScheduledMeetingUpdate,
      handleMeetingUpdate
    )
    eventEmitter?.off(EventType.OnPrivateChatMemberIdSelected)
    // eventEmitter?.off(EventType.RtcLocalAudioVolumeIndication)
    // eventEmitter?.off(EventType.RtcAudioVolumeIndication)
  }
  const handleCheckTime = (time: number, preTime: number) => {
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
  }

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
    [globalConfig?.appConfig?.ROOM_END_TIME_TIP?.enable]
  )

  const confirmToReplay = (
    type: 'video' | 'audio' | 'screen' | 'audioSlave'
  ) => {
    if (type === 'audioSlave') {
      setShowReplayAudioSlaveDialog(false)
    } else if (type === 'screen') {
      setShowReplayScreenDialog(false)
    } else {
      setShowReplayDialog(false)
    }
    memberListRef.current?.forEach((item) => {
      neMeeting?.replayRemoteStream({
        userUuid: item.uuid,
        type: 'audio',
      })
    })
  }
  const cancelFocus = () => {
    if (
      meetingInfoRef.current.localMember.uuid ===
      meetingInfoRef.current.focusUuid
    ) {
      Toast.info(t('participantUnassignedActiveSpeaker'))
    }
  }
  const unmuteMyAudio = (isOpenByMySelf = false) => {
    const localMember = meetingInfoRef.current.localMember
    if (localMember.isAudioOn) {
      return
    }
    eventEmitter?.emit(EventType.NeedAudioHandsUp, false)
    // 主持人或者联席主持人直接开声音
    if (localMember.role === Role.host || localMember.role === Role.coHost) {
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
  }
  const unmuteMyVideo = (isMySelf = false) => {
    const localMember = meetingInfoRef.current.localMember
    if (localMember.isVideoOn) {
      return
    }
    eventEmitter?.emit(EventType.NeedVideoHandsUp, false)
    if (
      (localMember.role === Role.host || localMember.role === Role.coHost) &&
      isMySelf
    ) {
      // TODO 需要填写设备id
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
  }
  const roomEndedHandler = (reason = 'OTHER') => {
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
    globalDispatch &&
      globalDispatch({
        type: ActionType.JOIN_LOADING,
        data: false,
      })
    let leaveType: NEMeetingLeaveType = NEMeetingLeaveType[reason]
    if (!leaveType && leaveType !== 0) {
      leaveType = NEMeetingLeaveType.UNKNOWN
    }
    outEventEmitter?.emit(EventType.RoomEnded, leaveType)
    eventEmitter?.removeAllListeners()
    try {
      leaveCallback && leaveCallback(leaveType)
    } catch (e) {
      logger.warn('leaveCallback failed', e)
    }
  }

  const confirmUnMuteMyAudio = () => {
    const { localMember, audioOff, screenUuid } = meetingInfoRef.current
    const isHost =
      localMember.role === Role.host || localMember.role === Role.coHost
    const isScreen = !!screenUuid && screenUuid === localMember.uuid
    if (localMember.isAudioOn) {
      return
    }
    // 收到弹窗后未操作，主持人又关闭了全体音频的情况
    // 当前房间不允许自己打开，非主持人，当前非共享用户
    if (
      audioOff === AttendeeOffType.offNotAllowSelfOn &&
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
      .catch((e: any) => {
        Toast.info(t('participantUnMuteAudioFail'))
        logger.error('muteLocalAudio %o %t', e)
      })
    setIsShowAudioDialog(false)
  }

  const confirmUnMuteMyVideo = () => {
    const { localMember, videoOff, screenUuid } = meetingInfoRef.current
    const isHost =
      localMember.role === Role.host || localMember.role === Role.coHost
    const isScreen = !!screenUuid && screenUuid === localMember.uuid
    if (localMember.isVideoOn) {
      return
    }
    // 收到弹窗后未操作，主持人又关闭了全体视频的情况
    // 当前房间不允许自己打开，非主持人，当前非共享用户
    if (
      videoOff === AttendeeOffType.offNotAllowSelfOn &&
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
      .catch((e: any) => {
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

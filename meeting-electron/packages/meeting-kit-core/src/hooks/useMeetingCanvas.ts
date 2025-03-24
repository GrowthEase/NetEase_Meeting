import { useEffect, useMemo, useRef } from 'react'
import { groupMembersService } from '../components/h5/MeetingCanvas/service'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { ActionType, LayoutTypeEnum, NEMember } from '../types'
import { NEMeetingInviteStatus } from '../types/type'

interface MeetingCanvasProps {
  isSpeaker?: boolean
  isSpeakerLayoutPlacementRight?: boolean
  isAudioMode: boolean
  groupNum: number
  resizableWidth: number
  groupType: 'h5' | 'web'
}

interface MeetingCanvasReturn {
  hideNoVideoMembers: boolean
  memberList: NEMember[]
  canPreSubscribe?: boolean
  groupMembers: NEMember[][]
  handleViewDoubleClick: (member: NEMember) => void
  preSpeakerLayoutInfo: React.MutableRefObject<'top' | 'right'>
  handleUnsubscribeMembers: (
    memberList: NEMember[][],
    activeSpeakerList: string[],
    activeIndex: number,
    mainUuid?: string
  ) => void
  unsubscribeMembersTimerMap: React.MutableRefObject<
    Record<string, null | ReturnType<typeof setTimeout>>
  >
  clearUnsubscribeMembersTimer: (uuid: string) => void
}

export default function useMeetingCanvas(
  data: MeetingCanvasProps
): MeetingCanvasReturn {
  const { isSpeaker, isAudioMode, groupNum, groupType } = data
  const {
    meetingInfo,
    memberList: meetingMemberList,
    inInvitingMemberList: meetingInInvitingMemberList,
    dispatch,
  } = useMeetingInfoContext()
  const { globalConfig, neMeeting } = useGlobalContext()
  const preSpeakerLayoutInfo = useRef<'top' | 'right'>('top')

  const unsubscribeMembersTimerMap = useRef<
    Record<string, null | ReturnType<typeof setTimeout>>
  >({})

  const activeSpeakerListReportIntervalRef = useRef(3000)

  activeSpeakerListReportIntervalRef.current =
    globalConfig?.appConfig.MEETING_CLIENT_CONFIG?.activeSpeakerConfig
      .activeSpeakerListReportInterval || 3000

  const hideNoVideoMembers = useMemo(() => {
    return meetingInfo.localMember.properties?.hideNoVideoMembers?.value === '1'
  }, [meetingInfo.localMember.properties?.hideNoVideoMembers?.value])

  const enableHideMyVideo = useMemo(() => {
    return !!meetingInfo.setting.videoSetting.enableHideMyVideo
  }, [meetingInfo.setting.videoSetting?.enableHideMyVideo])

  const enableHideVideoOffAttendees = useMemo(() => {
    return !!meetingInfo.setting.videoSetting.enableHideVideoOffAttendees
  }, [meetingInfo.setting.videoSetting?.enableHideVideoOffAttendees])

  const inInvitingMemberList = useMemo(() => {
    return meetingInfo.setting.normalSetting.enableShowNotYetJoinedMembers
      ? meetingInInvitingMemberList?.filter((member) => {
          return member.inviteState !== NEMeetingInviteStatus.waitingJoin
        })
      : []
  }, [
    meetingInInvitingMemberList,
    meetingInfo.setting.normalSetting.enableShowNotYetJoinedMembers,
  ])
  const enableVoicePriorityDisplay = useMemo(() => {
    return (
      meetingInfo.setting?.normalSetting?.enableVoicePriorityDisplay !== false
    )
  }, [meetingInfo.setting?.normalSetting?.enableVoicePriorityDisplay])

  const originMemberList = useMemo(() => {
    const _originMemberList = [...meetingMemberList]

    let list: NEMember[] = _originMemberList

    if (isAudioMode) {
      if (enableHideVideoOffAttendees) {
        list = [meetingInfo.localMember]
      } else {
        // 隐藏本端
        if (enableHideMyVideo && _originMemberList.length > 1) {
          const localMember = meetingInfo.localMember

          if (
            meetingInfo.focusUuid !== localMember.uuid &&
            meetingInfo.pinVideoUuid !== localMember.uuid
          ) {
            const index = _originMemberList.findIndex((item) => {
              return item.uuid === localMember.uuid
            })

            if (index > -1) {
              _originMemberList.splice(index, 1)
            }
          }
        }

        list = _originMemberList
      }
    } else {
      if (
        enableHideVideoOffAttendees &&
        (_originMemberList.length > 1 || meetingInfo.screenUuid)
      ) {
        list = _originMemberList.filter((member) => {
          return (
            member.isVideoOn ||
            meetingInfo.focusUuid === member.uuid ||
            meetingInfo.pinVideoUuid === member.uuid ||
            meetingInfo.screenUuid === member.uuid ||
            (meetingInfo.lastActiveSpeakerUuid === member.uuid &&
              member.isAudioOn &&
              enableVoicePriorityDisplay)
          )
        })
      }

      // 如果开启隐藏本端视图 则去除本端
      if (enableHideMyVideo) {
        const localMember = meetingInfo.localMember

        if (
          meetingInfo.focusUuid !== localMember.uuid &&
          meetingInfo.pinVideoUuid !== localMember.uuid &&
          _originMemberList.length > 1
        ) {
          const index = list.findIndex((item) => {
            return item.uuid === localMember.uuid
          })

          if (index > -1) {
            list.splice(index, 1)
          }
        }
      }
    }

    return list
  }, [
    enableHideMyVideo,
    enableHideVideoOffAttendees,
    meetingMemberList,
    meetingInfo.pinVideoUuid,
    meetingInfo.focusUuid,
    meetingInfo.localMember,
    inInvitingMemberList?.length,
    meetingInfo.lastActiveSpeakerUuid,
    enableVoicePriorityDisplay,
    isAudioMode,
  ])

  // 是否能够提前订阅
  const canPreSubscribe = useMemo(() => {
    return (
      globalConfig?.appConfig.MEETING_CLIENT_CONFIG?.activeSpeakerConfig
        .enableVideoPreSubscribe &&
      isSpeaker &&
      !meetingInfo.focusUuid &&
      meetingInfo.setting?.normalSetting?.enableVoicePriorityDisplay !== false
    )
  }, [
    globalConfig?.appConfig,
    isSpeaker,
    meetingInfo.focusUuid,
    meetingInfo.setting?.normalSetting?.enableVoicePriorityDisplay,
  ])

  const memberList = useMemo(() => {
    return inInvitingMemberList
      ? originMemberList.concat(inInvitingMemberList)
      : originMemberList
  }, [originMemberList, inInvitingMemberList])
  // 对成员列表进行排序
  const groupMembers = useMemo(() => {
    const _meetingMemberList = [...originMemberList]

    if (isAudioMode) {
      // 如果是音频模式则所有成员都在一页不用分页;
      const list = inInvitingMemberList
        ? _meetingMemberList.concat(inInvitingMemberList)
        : _meetingMemberList

      return [list]
    } else {
      return groupMembersService({
        memberList: _meetingMemberList,
        inInvitingMemberList: inInvitingMemberList,
        groupNum: isSpeaker ? groupNum : meetingInfo.galleryModeMaxCount ?? 16,
        screenUuid: meetingInfo.screenUuid,
        dualMonitors: meetingInfo.dualMonitors,
        focusUuid: meetingInfo.focusUuid,
        myUuid: meetingInfo.localMember.uuid,
        activeSpeakerUuid: meetingInfo.lastActiveSpeakerUuid || '',
        groupType,
        enableVoicePriorityDisplay,
        enableSortByVoice: !!meetingInfo.enableSortByVoice,
        layout: isSpeaker ? LayoutTypeEnum.Speaker : LayoutTypeEnum.Gallery,
        whiteboardUuid: meetingInfo.whiteboardUuid,
        isWhiteboardTransparent: meetingInfo.isWhiteboardTransparent,
        pinVideoUuid: meetingInfo.pinVideoUuid,
        viewOrder: meetingInfo.remoteViewOrder || meetingInfo.localViewOrder,
        hostUuid: meetingInfo.hostUuid,
        enableHideVideoOffAttendees,
      })
    }
  }, [
    originMemberList,
    inInvitingMemberList,
    meetingInfo.focusUuid,
    meetingInfo.screenUuid,
    meetingInfo.whiteboardUuid,
    meetingInfo.pinVideoUuid,
    isSpeaker,
    meetingInfo.lastActiveSpeakerUuid,
    meetingInfo.isWhiteboardTransparent,
    groupNum,
    isAudioMode,
    meetingInfo.remoteViewOrder,
    meetingInfo.localViewOrder,
    meetingInfo.galleryModeMaxCount,
    meetingInfo.enableSortByVoice,
    meetingInfo.hostUuid,
    groupType,
    meetingInfo.localMember.uuid,
    enableVoicePriorityDisplay,
    enableHideVideoOffAttendees,
    meetingInfo.dualMonitors,
  ])

  function handleViewDoubleClick(member: NEMember) {
    console.warn('>>>>handleViewDoubleClick', member)

    if (member.isSharingWhiteboardView || member.isSharingScreenView) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          pinVideoUuid: '',
        },
      })
      return
    }

    // 如果有焦点用户，且点击的成员不是焦点用户
    if (meetingInfo.focusUuid && member.uuid !== meetingInfo.focusUuid) {
      return
    }

    // 透明白板模式不处理
    if (meetingInfo.whiteboardUuid && meetingInfo.isWhiteboardTransparent) {
      return
    }

    if (member.isVideoOn) {
      if (meetingInfo.pinVideoUuid !== member.uuid) {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            pinVideoUuid: member.uuid,
          },
        })
      } else if (meetingInfo.layout === LayoutTypeEnum.Gallery) {
        // 如果在画廊视图即使是已锁定成员，双击锁定也需要切换到演讲者视图
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            layout: LayoutTypeEnum.Speaker,
            speakerLayoutPlacement: preSpeakerLayoutInfo.current,
          },
        })
      }
    }
  }

  useEffect(() => {
    // 音频模式取消固定视频;
    if (isAudioMode && meetingInfo.pinVideoUuid) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          pinVideoUuid: '',
        },
      })
    }
  }, [isAudioMode, meetingInfo.pinVideoUuid, dispatch])

  function handleUnsubscribeMembers(
    memberList: NEMember[][],
    activeSpeakerList: string[],
    activeIndex: number,
    mainUuid?: string
  ) {
    const currentMemberList = memberList[activeIndex]

    if (currentMemberList) {
      // 获取当前页开启视频的成员uuid
      const currentVideoOnMemberUuids = currentMemberList
        .filter(
          (item) => item.isVideoOn && neMeeting?.localMember?.uuid !== item.uuid
        )
        .map((item) => item.uuid)

      mainUuid && currentVideoOnMemberUuids.push(mainUuid)
      // 所有开启视频的成员
      let allVideoOnMemberUuids = memberList
        .flat()
        .filter(
          (item) => item.isVideoOn && item.uuid != neMeeting?.localMember?.uuid
        )
        .map((item) => item.uuid)

      // 需要把在当前说话者列表的也加入到订阅中。并且去重
      allVideoOnMemberUuids = [...allVideoOnMemberUuids, ...activeSpeakerList]
      allVideoOnMemberUuids = [...new Set(allVideoOnMemberUuids)]
      // 所有不需要订阅视频的成员
      const needUnsubscribeUuids = allVideoOnMemberUuids.filter(
        (item) => !currentVideoOnMemberUuids.includes(item)
      )

      // 需要取消订阅
      needUnsubscribeUuids.forEach((uuid) => {
        neMeeting?.unsubscribeRemoteVideoStream(uuid, 0)
      })
      // 需要恢复订阅
      currentVideoOnMemberUuids.forEach((uuid) => {
        let streamType =
          mainUuid == uuid
            ? 0
            : canPreSubscribe
            ? activeSpeakerList.includes(uuid)
              ? 0
              : 1
            : 1

        if (
          meetingInfo.layout === LayoutTypeEnum.Gallery &&
          currentMemberList.length <= 3
        ) {
          streamType = 0
        }

        if (neMeeting?.subscribeMembersMap[uuid] === streamType) {
          return
        }

        neMeeting?.subscribeRemoteVideoStream(uuid, streamType as 0 | 1)
      })
    }
  }

  function clearUnsubscribeMembersTimer(uuid: string) {
    if (unsubscribeMembersTimerMap.current[uuid]) {
      clearTimeout(unsubscribeMembersTimerMap.current[uuid])
      unsubscribeMembersTimerMap.current[uuid] = null
      delete unsubscribeMembersTimerMap.current[uuid]
    }
  }

  return {
    hideNoVideoMembers,
    memberList,
    canPreSubscribe,
    groupMembers,
    handleViewDoubleClick,
    preSpeakerLayoutInfo,
    handleUnsubscribeMembers,
    unsubscribeMembersTimerMap,
    clearUnsubscribeMembersTimer,
  }
}

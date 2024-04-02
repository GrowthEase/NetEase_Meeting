import { useEffect, useMemo, useRef } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { groupMembersService } from '../components/h5/MeetingCanvas/service'
import { ActionType, LayoutTypeEnum, NEMember } from '../types'
import Toast from '../components/common/toast'
import { useTranslation } from 'react-i18next'

interface MeetingCanvasProps {
  isSpeaker?: boolean
  isSpeakerLayoutPlacementRight?: boolean
  isAudioMode: boolean
  groupNum: number
  resizableWidth: number
}

export default function useMeetingCanvas(data: MeetingCanvasProps) {
  const {
    isSpeaker,
    isSpeakerLayoutPlacementRight,
    isAudioMode,
    groupNum,
    resizableWidth,
  } = data
  const { t } = useTranslation()
  const {
    meetingInfo,
    memberList: originMemberList,
    dispatch,
  } = useMeetingInfoContext()
  const { globalConfig, neMeeting } = useGlobalContext()
  const isMounted = useRef(false)
  const preSpeakerLayoutInfo = useRef<'top' | 'right'>('top')
  const unsubscribeMembersTimerMap = useRef<Record<string, any>>({})
  const toastIdRef = useRef<string>('')

  const hideNoVideoMembers =
    meetingInfo.localMember.properties?.hideNoVideoMembers?.value === '1'

  const memberList = useMemo(() => {
    if (hideNoVideoMembers) {
      const list = originMemberList.filter(
        (item) => item.isVideoOn || item.isSharingScreen
      )
      return list.length > 0 ? list : [meetingInfo.localMember]
    }
    return originMemberList
  }, [hideNoVideoMembers, originMemberList, meetingInfo.localMember])

  // 是否能够提前订阅
  const canPreSubscribe = useMemo(() => {
    return (
      globalConfig?.appConfig.MEETING_CLIENT_CONFIG?.activeSpeakerConfig
        .enableVideoPreSubscribe &&
      isSpeaker &&
      !meetingInfo.focusUuid
    )
  }, [globalConfig?.appConfig, isSpeaker, meetingInfo.focusUuid])

  // 对成员列表进行排序
  const groupMembers = useMemo(() => {
    if (isAudioMode) {
      // 如果是音频模式则所有成员都在一页不用分页;
      return [memberList]
    } else {
      return groupMembersService({
        memberList,
        groupNum: isSpeaker ? groupNum : 16,
        screenUuid: meetingInfo.screenUuid,
        focusUuid: meetingInfo.focusUuid,
        myUuid: meetingInfo.localMember.uuid,
        activeSpeakerUuid: meetingInfo.lastActiveSpeakerUuid || '',
        groupType: 'web',
        enableSortByVoice: !!meetingInfo.enableSortByVoice,
        layout: isSpeaker ? LayoutTypeEnum.Speaker : LayoutTypeEnum.Gallery,
        whiteboardUuid: meetingInfo.whiteboardUuid,
        isWhiteboardTransparent: meetingInfo.isWhiteboardTransparent,
        pinVideoUuid: meetingInfo.pinVideoUuid,
      })
    }
  }, [
    memberList,
    memberList.length,
    meetingInfo.hostUuid,
    meetingInfo.focusUuid,
    meetingInfo.activeSpeakerUuid,
    meetingInfo.screenUuid,
    meetingInfo.whiteboardUuid,
    meetingInfo.layout,
    meetingInfo.pinVideoUuid,
    isSpeaker,
    meetingInfo.lastActiveSpeakerUuid,
    meetingInfo.isWhiteboardTransparent,
    resizableWidth,
    isSpeakerLayoutPlacementRight,
    groupNum,
    isAudioMode,
  ])
  function handleViewDoubleClick(member: NEMember) {
    if (
      member.isVideoOn &&
      !meetingInfo.focusUuid &&
      !meetingInfo.whiteboardUuid &&
      !meetingInfo.screenUuid
    ) {
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
        t('meetingPinViewTip', {
          corner: t('meetingTopLeftCorner'),
        })
      }
    }
  }

  useEffect(() => {
    if (!isMounted.current) {
      return
    }
    if (toastIdRef.current) {
      Toast.destroy(toastIdRef.current)
    }
    if (meetingInfo.pinVideoUuid) {
      toastIdRef.current = Toast.info(
        t('meetingPinViewTip', {
          corner: t('meetingTopLeftCorner'),
        })
      )
    } else {
      toastIdRef.current = Toast.info(t('meetingUnpinViewTip'))
    }
  }, [meetingInfo.pinVideoUuid])

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
  }, [isAudioMode, meetingInfo.pinVideoUuid])

  useEffect(() => {
    isMounted.current = true
  }, [])

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
        if (!unsubscribeMembersTimerMap.current[uuid]) {
          unsubscribeMembersTimerMap.current[uuid] = setTimeout(() => {
            console.warn('取消订阅', uuid, mainUuid == uuid)
            neMeeting?.unsubscribeRemoteVideoStream(uuid, 0)
          }, 5000)
        }
      })
      // 需要恢复订阅
      currentVideoOnMemberUuids.forEach((uuid) => {
        const streamType =
          mainUuid == uuid ? 0 : activeSpeakerList.includes(uuid) ? 0 : 1
        if (neMeeting?.subscribeMembersMap[uuid] === streamType) {
          return
        }
        clearUnsubscribeMembersTimer(uuid)
        neMeeting?.subscribeRemoteVideoStream(uuid, streamType)
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

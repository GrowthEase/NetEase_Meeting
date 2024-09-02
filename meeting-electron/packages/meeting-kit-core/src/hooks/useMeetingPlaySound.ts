import { useCallback, useContext, useEffect, useRef } from 'react'
import {
  EventType,
  GlobalContext as GlobalContextInterface,
  MeetingInfoContextInterface,
  NEMeetingInfo,
} from '../types'
import {
  GlobalContext,
  MeetingInfoContext,
  useGlobalContext,
  useMeetingInfoContext,
} from '../store'
import { NERoomMember } from 'neroom-types'

const joinMeetingTipAudioURL =
  'https://yx-web-nosdn.netease.im/common/ab49193d320f35079cac5f07fd715518/joinTip.MP3'
const leaveMeetingTipAudioURL =
  'https://yx-web-nosdn.netease.im/common/c8c944fbbef29832f5ce86760c2bb580/leaveTip.MP3'

export default function useMeetingPlaySound() {
  const { neMeeting } = useGlobalContext()
  const { meetingInfo } =
    useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const { inInvitingMemberList } = useMeetingInfoContext()
  const meetingInfoRef = useRef<NEMeetingInfo>(meetingInfo)

  const { eventEmitter } = useContext<GlobalContextInterface>(GlobalContext)

  // 同一时间多个成员加入和离开时，保证只有一个播放声音
  const canPlayJoinMeetingSoundRef = useRef<boolean>(true)

  meetingInfoRef.current = meetingInfo

  const handleMemberJoin = useCallback((members: NERoomMember[]) => {
    // 断开音频 不播放声音
    if (members.length && !members[0]?.isAudioConnected) return

    if (
      meetingInfoRef.current?.playSound &&
      canPlayJoinMeetingSoundRef.current
    ) {
      canPlayJoinMeetingSoundRef.current = false
      let joinMeetingTipAudio: HTMLAudioElement | null = new Audio(
        joinMeetingTipAudioURL
      )
      const selectedSpeaker = neMeeting?.getSelectedPlayoutDevice()

      selectedSpeaker && joinMeetingTipAudio?.setSinkId(selectedSpeaker)
      joinMeetingTipAudio.play()
      joinMeetingTipAudio.addEventListener('ended', () => {
        canPlayJoinMeetingSoundRef.current = true
        joinMeetingTipAudio = null
      })
    }
  }, [])

  const handleMemberLeave = useCallback((members: NERoomMember[]) => {
    const isInInvitingMemberList = inInvitingMemberList?.find(
      (item) => item.uuid === members[0].uuid
    )

    // 断开音频 不播放声音
    if (members.length && !members[0]?.isAudioConnected) return

    // 移除邀请中的成员，不播放声音
    if (members.length && members[0]?.isInAppInviting) return

    // 未入会的成员，不播放声音
    if (isInInvitingMemberList) return
    if (
      meetingInfoRef.current?.playSound &&
      canPlayJoinMeetingSoundRef.current
    ) {
      canPlayJoinMeetingSoundRef.current = false
      let leaveMeetingTipAudio: HTMLAudioElement | null = new Audio(
        leaveMeetingTipAudioURL
      )
      const selectedSpeaker = neMeeting?.getSelectedPlayoutDevice()

      selectedSpeaker && leaveMeetingTipAudio?.setSinkId(selectedSpeaker)

      leaveMeetingTipAudio.play()
      leaveMeetingTipAudio.addEventListener('ended', () => {
        canPlayJoinMeetingSoundRef.current = true
        leaveMeetingTipAudio = null
      })
    }
  }, [])

  useEffect(() => {
    eventEmitter?.on(EventType.MemberJoinRoom, handleMemberJoin)
    eventEmitter?.on(EventType.MemberLeaveRoom, handleMemberLeave)

    return () => {
      eventEmitter?.off(EventType.MemberJoinRoom, handleMemberJoin)
      eventEmitter?.off(EventType.MemberLeaveRoom, handleMemberLeave)
    }
  }, [])
  return {}
}

import { useEffect, useState } from 'react'
import { NEMember, Role } from '../types'

interface UseMemberListProps {
  memberList: NEMember[]
  localMember: NEMember
}
export default function useMemberList(data: UseMemberListProps): {
  showMemberList: NEMember[]
} {
  const { memberList, localMember } = data
  const [showMemberList, setShowMemberList] = useState<NEMember[]>([])

  useEffect(() => {
    // 主持人->联席主持人->自己->举手->屏幕共享（白板）>音视频>视频->音频->昵称排序
    const host: NEMember[] = []
    const coHost: NEMember[] = []
    const handsUp: NEMember[] = []
    const sharingWhiteboardOrScreen: NEMember[] = []
    const audioOn: NEMember[] = []
    const videoOn: NEMember[] = []
    const audioAndVideoOn: NEMember[] = []
    const other: NEMember[] = []

    memberList.forEach((member) => {
      if (member.role === Role.host) {
        host.push(member)
      } else if (member.role === Role.coHost) {
        coHost.push(member)
      } else if (member.uuid === localMember.uuid) {
        // 本人永远排在主持和联席主持人之后
        return
      } else if (member.isHandsUp) {
        handsUp.push(member)
      } else if (member.isSharingWhiteboard || member.isSharingScreen) {
        sharingWhiteboardOrScreen.push(member)
      } else if (member.isAudioOn && member.isVideoOn) {
        audioAndVideoOn.push(member)
      } else if (member.isVideoOn) {
        videoOn.push(member)
      } else if (member.isAudioOn) {
        audioOn.push(member)
      } else {
        other.push(member)
      }
    })
    other.sort((a, b) => {
      return a.name.localeCompare(b.name)
    })
    const hostOrCoHostWithMe =
      [...host, ...coHost]?.findIndex(
        (item) => item.uuid === localMember.uuid
      ) > -1
        ? [...host, ...coHost]
        : [...host, ...coHost, localMember]
    const res = [
      ...hostOrCoHostWithMe,
      ...handsUp,
      ...sharingWhiteboardOrScreen,
      ...audioAndVideoOn,
      ...videoOn,
      ...audioOn,
      ...other,
    ]
    setShowMemberList(res)
  }, [memberList, localMember])

  return {
    showMemberList,
  }
}

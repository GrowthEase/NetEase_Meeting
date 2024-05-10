import { NEMemberVolumeInfo } from 'neroom-web-sdk/dist/types/platform/web/type'
import { useEffect, useRef, useState } from 'react'
import { useGlobalContext } from '../store'
import { EventType } from '../types'
import { NERoomMember } from 'neroom-web-sdk'

export default function useActiveSpeakerManager() {
  const { eventEmitter, globalConfig, neMeeting } = useGlobalContext()
  const volumeIndicationsRef = useRef<Array<NEMemberVolumeInfo[]>>([])
  const activeSpeakerListRef = useRef<string[]>([])
  const [activeSpeakerList, setActiveSpeakerList] = useState<string[]>([])

  useEffect(() => {
    const activeSpeakerConfig =
      globalConfig?.appConfig.MEETING_CLIENT_CONFIG?.activeSpeakerConfig
    const handle = (data: NEMemberVolumeInfo[]) => {
      if (activeSpeakerConfig) {
        // 使用队列保存音量信息, 如果长度大于volumeIndicationWindowSize, 则删除最后一个
        data.length > 0 && volumeIndicationsRef.current.push(data)
        if (
          volumeIndicationsRef.current.length >
          activeSpeakerConfig.volumeIndicationWindowSize
        ) {
          volumeIndicationsRef.current.shift()
        }
        updateActiveSpeaker()
      }
    }
    eventEmitter?.on(EventType.RtcAudioVolumeIndication, handle)
    return () => {
      eventEmitter?.off(EventType.RtcAudioVolumeIndication, handle)
    }
  }, [globalConfig?.appConfig])

  useEffect(() => {
    function handleMemberLeaveRoom(members: NERoomMember[]) {
      members.forEach((member) => {
        const index = volumeIndicationsRef.current.findIndex((item) =>
          item.some((i) => i.userUuid === member.uuid)
        )
        if (index > -1) {
          volumeIndicationsRef.current.splice(index, 1)
        }
      })
      // 如果离开房间的成员在正在讲话列表中，则删除对应的成员;
      const newActiveSpeakerList = activeSpeakerListRef.current.filter(
        (user) => {
          return !members.some((member) => member.uuid === user)
        }
      )
      if (newActiveSpeakerList.length !== activeSpeakerListRef.current.length) {
        eventEmitter?.emit(
          EventType.ActiveSpeakerListChanged,
          newActiveSpeakerList
        )
        setActiveSpeakerList(newActiveSpeakerList)
        activeSpeakerListRef.current = newActiveSpeakerList
      }
    }
    eventEmitter?.on(EventType.MemberLeaveRoom, handleMemberLeaveRoom)
    return () => {
      eventEmitter?.off(EventType.MemberLeaveRoom, handleMemberLeaveRoom)
    }
  }, [])

  /// 更新“正在讲话”列表
  /// 1. 计算窗口内每个成员的平均音量；并按照音量从大到小排序
  /// 2. 过滤列表中音量小于阈值、音频关闭的成员
  /// 3. 取前3个成员作为“正在讲话”列表
  /// 4. 与当前“正在讲话”列表比较，找出新增和移除的成员，并对外通知
  function updateActiveSpeaker() {
    const activeSpeakerConfig =
      globalConfig?.appConfig.MEETING_CLIENT_CONFIG?.activeSpeakerConfig
    if (activeSpeakerConfig) {
      const activeSpeakerList = volumeIndicationsRef.current.reduce(
        (acc, cur) => {
          cur.forEach((item) => {
            if (!acc.has(item.userUuid)) {
              acc.set(item.userUuid, [])
            }
            acc.get(item.userUuid)?.push(item.volume)
          })
          return acc
        },
        new Map<string, number[]>()
      )
      // 计算每个成员的平均音量，并进行排序
      const activeSpeakerListWithVolume = Array.from(activeSpeakerList)
        .map(([userUuid, volumeList]) => {
          return {
            userUuid,
            volume: volumeList.reduce((acc, cur) => acc + cur, 0) / 15,
          }
        })
        .sort((a, b) => b.volume - a.volume)

      const activeSpeakerListWithVolumeAndFilterAndMute =
        activeSpeakerListWithVolume.filter((item) => {
          const member = neMeeting?.roomContext?.getMember(item.userUuid)
          return member?.isAudioOn
        })

      const newActiveSpeakerList = activeSpeakerListWithVolumeAndFilterAndMute
        .slice(0, activeSpeakerConfig.maxActiveSpeakerCount) // 服务端配置
        .map((item) => item.userUuid)
      const oldActiveSpeakerList = activeSpeakerListRef.current

      const newActiveSpeakerSet = new Set(newActiveSpeakerList)
      const oldActiveSpeakerSet = new Set(oldActiveSpeakerList)

      const addedActiveSpeakerList = newActiveSpeakerList.filter((user) => {
        const hasUser = !oldActiveSpeakerSet.has(user)
        if (hasUser) {
          eventEmitter?.emit(EventType.ActiveSpeakerActiveChanged, {
            user,
            active: true,
          })
        }
        return hasUser
      })
      const removedActiveSpeakerList = oldActiveSpeakerList.filter((user) => {
        const isRemoveUser = !newActiveSpeakerSet.has(user)
        if (isRemoveUser) {
          eventEmitter?.emit(EventType.ActiveSpeakerActiveChanged, {
            user,
            active: false,
          })
        }
        return isRemoveUser
      })
      activeSpeakerListRef.current = newActiveSpeakerList

      if (
        addedActiveSpeakerList.length > 0 ||
        removedActiveSpeakerList.length > 0 ||
        // 判断新旧两个的首位是否相同，如果相同则不触发事件
        (oldActiveSpeakerList.length > 0 &&
          newActiveSpeakerList.length > 0 &&
          oldActiveSpeakerList[0] !== newActiveSpeakerList[0])
      ) {
        eventEmitter?.emit(
          EventType.ActiveSpeakerListChanged,
          newActiveSpeakerList
        )
        setActiveSpeakerList(newActiveSpeakerList)
      }
      if (newActiveSpeakerList.length > 0) {
        eventEmitter?.emit(EventType.RtcActiveSpeakerChanged, {
          userUuid: newActiveSpeakerList[0],
        })
      }
    }
  }

  return {
    activeSpeakerList,
  }
}

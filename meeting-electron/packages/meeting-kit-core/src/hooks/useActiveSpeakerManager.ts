import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { EventType } from '../types'
import { NERoomMember, NEMemberVolumeInfo } from 'neroom-types'

export default function useActiveSpeakerManager(): {
  activeSpeakerList: string[]
} {
  const { eventEmitter, globalConfig, neMeeting } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()
  const volumeIndicationsRef = useRef<Array<NEMemberVolumeInfo[]>>([])
  const activeSpeakerListRef = useRef<string[]>([])
  const [activeSpeakerList, setActiveSpeakerList] = useState<string[]>([])
  const activeSpeakerTimer = useRef<null | ReturnType<typeof setTimeout>>(null)
  const meetingInfoRef = useRef(meetingInfo)

  meetingInfoRef.current = meetingInfo

  const activeSpeakerListReportIntervalRef = useRef(3000)

  activeSpeakerListReportIntervalRef.current =
    globalConfig?.appConfig.MEETING_CLIENT_CONFIG?.activeSpeakerConfig
      .activeSpeakerListReportInterval || 3000

  const enableVoicePriorityDisplay = useMemo(() => {
    return (
      meetingInfo.setting?.normalSetting?.enableVoicePriorityDisplay !== false
    )
  }, [meetingInfo.setting?.normalSetting?.enableVoicePriorityDisplay])
  /// 更新“正在讲话”列表
  /// 1. 计算窗口内每个成员的平均音量；并按照音量从大到小排序
  /// 2. 过滤列表中音量小于阈值、音频关闭的成员
  /// 3. 取前3个成员作为“正在讲话”列表
  /// 4. 与当前“正在讲话”列表比较，找出新增和移除的成员，并对外通知
  const updateActiveSpeaker = useCallback(() => {
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
        .slice(0, Math.max(activeSpeakerConfig.maxActiveSpeakerCount - 1, 1))
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
    }
  }, [
    meetingInfo.setting?.normalSetting?.enableVoicePriorityDisplay,
    eventEmitter,
    globalConfig?.appConfig.MEETING_CLIENT_CONFIG?.activeSpeakerConfig,
    neMeeting?.roomContext,
  ])

  function handleIntervalTime() {
    activeSpeakerTimer.current && clearInterval(activeSpeakerTimer.current)
    activeSpeakerTimer.current = setInterval(() => {
      eventEmitter?.emit(EventType.RtcActiveSpeakerChanged, {
        userUuid: activeSpeakerListRef.current?.[0] || '',
      })
    }, activeSpeakerListReportIntervalRef.current)
  }

  useEffect(() => {
    // 未开启语音激励不处理
    if (!enableVoicePriorityDisplay) {
      return
    }

    eventEmitter?.emit(EventType.RtcActiveSpeakerChanged, {
      userUuid:
        activeSpeakerListRef.current?.[0] ||
        meetingInfoRef.current.lastActiveSpeakerUuid,
    })
    // 3s更新一次主大画面
    handleIntervalTime()

    return () => {
      if (activeSpeakerTimer.current) {
        clearInterval(activeSpeakerTimer.current)
        activeSpeakerTimer.current = null
      }
    }
  }, [enableVoicePriorityDisplay])

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
  }, [globalConfig?.appConfig, eventEmitter, updateActiveSpeaker])

  useEffect(() => {
    function handleMemberLeaveRoom(members: NERoomMember[]) {
      members.forEach((member) => {
        const index = volumeIndicationsRef.current.findIndex((item) =>
          item.some((i) => i.userUuid === member.uuid)
        )

        if (index > -1) {
          volumeIndicationsRef.current.splice(index, 1)
        }

        // 如果离开的成员正好是当前主画面人员，则需要立即切换不等3s
        if (
          activeSpeakerListRef.current.length > 1 &&
          activeSpeakerListRef.current[0] === member.uuid
        ) {
          if (
            activeSpeakerListRef.current[0] ==
            meetingInfoRef.current.lastActiveSpeakerUuid
          ) {
            eventEmitter?.emit(EventType.RtcActiveSpeakerChanged, {
              userUuid: activeSpeakerListRef.current[1],
            })
            enableVoicePriorityDisplay && handleIntervalTime()
          }
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
  }, [enableVoicePriorityDisplay])

  return {
    activeSpeakerList,
  }
}

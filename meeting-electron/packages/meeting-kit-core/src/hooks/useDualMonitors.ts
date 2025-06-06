import { useEffect, useMemo, useRef, useState } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { ActionType, closeWindow, getWindow, NEMember } from '../kit'

const IPC_EVENT = {
  DUAL_MONITORS_DISPLAY_ADDED: 'DUAL_MONITORS_DISPLAY_ADDED',
  DUAL_MONITORS_DISPLAY_REMOVED: 'DUAL_MONITORS_DISPLAY_REMOVED',
  DUAL_MONITORS_GET_DISPLAY_COUNT: 'DUAL_MONITORS_GET_DISPLAY_COUNT',
  DUAL_MONITORS_WIN_CLOSE: 'DUAL_MONITORS_WIN_CLOSE',
  DUAL_MONITORS_WIN_HIDE: 'DUAL_MONITORS_WIN_HIDE',
  DUAL_MONITORS_WIN_SHOW: 'DUAL_MONITORS_WIN_SHOW',
}

type DualMonitorsProps = {
  isDarkMode: boolean
}

export default function useDualMonitors(props: DualMonitorsProps) {
  const { isDarkMode } = props
  const { neMeeting } = useGlobalContext()
  const { meetingInfo, memberList, dispatch } = useMeetingInfoContext()
  const secondMonitorMemberRef = useRef<NEMember>()
  const contextRef = useRef<{
    view: HTMLElement
    userUuid: string
    sourceType: string
  }>()
  const [displayCount, setDisplayCount] = useState<number>(1)

  meetingInfo.rightDrawerTabActiveKey

  const isDualMonitors = meetingInfo.setting.normalSetting.dualMonitors ?? false

  const inMeeting = !!meetingInfo.meetingNum

  const inWaitingRoom = meetingInfo.inWaitingRoom

  const enableVoicePriorityDisplay = useMemo(() => {
    return (
      meetingInfo.setting?.normalSetting?.enableVoicePriorityDisplay !== false
    )
  }, [meetingInfo.setting?.normalSetting?.enableVoicePriorityDisplay])

  const remoteViewOrderUuid = useMemo(() => {
    if (meetingInfo.remoteViewOrder) {
      return meetingInfo.remoteViewOrder.split(',')[0]
    }

    return undefined
  }, [meetingInfo.remoteViewOrder])

  const secondMonitorMember = useMemo(() => {
    let member: NEMember | undefined

    if (meetingInfo.screenUuid) {
      member = memberList.find((item) => item.uuid === meetingInfo.screenUuid)
    }

    if (!member && meetingInfo.focusUuid) {
      member = memberList.find((item) => item.uuid === meetingInfo.focusUuid)
    }

    if (!member && meetingInfo.pinVideoUuid) {
      member = memberList.find((item) => item.uuid === meetingInfo.pinVideoUuid)
    }

    if (!member && remoteViewOrderUuid) {
      member = memberList.find((item) => item.uuid === remoteViewOrderUuid)
    }

    if (!member && enableVoicePriorityDisplay) {
      member = memberList.find(
        (item) => item.uuid === meetingInfo.lastActiveSpeakerUuid
      )
    }

    if (!member && meetingInfo.hostUuid) {
      member = memberList.find((item) => item.uuid === meetingInfo.hostUuid)
    }

    if (!member) {
      return meetingInfo.localMember
    }

    return member
  }, [
    memberList,
    meetingInfo.screenUuid,
    meetingInfo.layout,
    meetingInfo.lastActiveSpeakerUuid,
    enableVoicePriorityDisplay,
    meetingInfo.localMember,
    meetingInfo.pinVideoUuid,
    meetingInfo.focusUuid,
    meetingInfo.hostUuid,
    remoteViewOrderUuid,
  ])

  secondMonitorMemberRef.current = secondMonitorMember

  function dualMonitorsWindowClose() {
    const dualMonitorsWindow = getWindow('dualMonitorsWindow')

    dualMonitorsWindow?.postMessage(
      {
        event: 'windowClosed',
      },
      dualMonitorsWindow.origin
    )
    window.ipcRenderer?.send(IPC_EVENT.DUAL_MONITORS_WIN_CLOSE)
    closeWindow('dualMonitorsWindow', false)
  }

  useEffect(() => {
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        secondMonitorMember,
      },
    })
  }, [secondMonitorMember])

  useEffect(() => {
    function handleDisplayChanged(event, count) {
      setDisplayCount(count)
    }

    // 打开双屏模式
    if (inMeeting && !inWaitingRoom) {
      window.ipcRenderer
        ?.invoke(IPC_EVENT.DUAL_MONITORS_GET_DISPLAY_COUNT)
        .then((count) => {
          handleDisplayChanged(null, count)
        })

      window.ipcRenderer?.on(
        IPC_EVENT.DUAL_MONITORS_DISPLAY_ADDED,
        handleDisplayChanged
      )

      window.ipcRenderer?.on(
        IPC_EVENT.DUAL_MONITORS_DISPLAY_REMOVED,
        handleDisplayChanged
      )

      return () => {
        setDisplayCount(1)

        window.ipcRenderer?.off(
          IPC_EVENT.DUAL_MONITORS_DISPLAY_ADDED,
          handleDisplayChanged
        )

        window.ipcRenderer?.off(
          IPC_EVENT.DUAL_MONITORS_DISPLAY_REMOVED,
          handleDisplayChanged
        )

        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            dualMonitors: false,
          },
        })

        dualMonitorsWindowClose()
      }
    }
  }, [inMeeting, inWaitingRoom])

  useEffect(() => {
    if (!meetingInfo.dualMonitors) {
      dualMonitorsWindowClose()
    }
  }, [meetingInfo.dualMonitors])

  useEffect(() => {
    if (inMeeting) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          isDarkMode,
        },
      })
    }
  }, [isDarkMode, inMeeting])

  useEffect(() => {
    const dualMonitorsWindow = getWindow('dualMonitorsWindow')

    if (dualMonitorsWindow) {
      dualMonitorsWindow.postMessage(
        {
          event: 'updateData',
          payload: {
            meetingInfo: JSON.parse(JSON.stringify(meetingInfo)),
            memberList: JSON.parse(JSON.stringify(memberList)),
          },
        },
        dualMonitorsWindow.origin
      )
    }
  }, [meetingInfo, memberList])

  function createSecondMonitorRenderer() {
    const member = secondMonitorMemberRef.current

    if (member) {
      const isMySelf = meetingInfo.myUuid === member.uuid
      const win = getWindow('dualMonitorsWindow')
      const type = member.isSharingScreen ? 'screen' : 'video'
      const domId = member.isSharingScreen
        ? `nemeeting-canvas-container-${member.uuid}-screen`
        : `nemeeting-video-container-${member.uuid}-video`
      const viewDom = win?.document.getElementById(domId)

      if (viewDom) {
        if (isMySelf) {
          neMeeting?.rtcController?.setupLocalVideoCanvas?.(viewDom)
        } else {
          if (type === 'screen') {
            neMeeting?.rtcController?.setupRemoteVideoSubStreamCanvas(
              viewDom,
              member.uuid
            )
          } else {
            neMeeting?.rtcController?.setupRemoteVideoCanvas?.(
              viewDom,
              member.uuid
            )
          }
        }

        contextRef.current = {
          view: viewDom,
          userUuid: member.uuid,
          sourceType: type,
        }
      }
    }
  }

  function removeSecondMonitorRenderer() {
    if (contextRef.current) {
      const { view, userUuid, sourceType } = contextRef.current
      const isMySelf = meetingInfo.myUuid === userUuid

      if (isMySelf) {
        neMeeting?.rtcController?.removeLocalVideoCanvas?.(view)
      } else {
        if (sourceType === 'screen') {
          neMeeting?.rtcController?.removeRemoteVideoSubStreamCanvas?.(
            userUuid,
            view
          )
        } else {
          neMeeting?.rtcController?.removeRemoteVideoCanvas?.(userUuid, view)
        }
      }

      contextRef.current = undefined
    }
  }

  useEffect(() => {
    if (meetingInfo.dualMonitors) {
      return () => {
        removeSecondMonitorRenderer()
      }
    }
  }, [meetingInfo.dualMonitors])

  useEffect(() => {
    // 我开始共享屏幕
    if (meetingInfo.screenUuid === meetingInfo.myUuid) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          dualMonitors: false,
        },
      })
      // 我停止共享屏幕
    } else {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          dualMonitors: displayCount > 1 && isDualMonitors,
        },
      })
    }
  }, [meetingInfo.screenUuid, meetingInfo.myUuid, isDualMonitors, displayCount])

  return {
    createSecondMonitorRenderer,
    removeSecondMonitorRenderer,
  }
}

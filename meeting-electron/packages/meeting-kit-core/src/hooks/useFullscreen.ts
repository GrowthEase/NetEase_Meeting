import { useEffect, useMemo, useRef, useState } from 'react'
import { useMeetingInfoContext } from '../store'
import { IPCEvent } from '../app/src/types'
import { ActionType } from '../kit'

// 是否是副屏
const isSecondMonitor = location.href.includes('dualMonitors')

const useFullscreen = () => {
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const [isFullScreen, setIsFullScreen] = useState(
    isSecondMonitor ? meetingInfo.secondMonitorFullScreen : false
  )

  const meetingInfoRef = useRef(meetingInfo)

  meetingInfoRef.current = meetingInfo

  const enterFullscreen = useMemo(() => {
    return meetingInfo.setting.normalSetting.enterFullscreen ?? false
  }, [meetingInfo.setting.normalSetting.enterFullscreen])

  const inMeeting = useMemo(() => {
    return !!meetingInfo.meetingNum
  }, [meetingInfo.meetingNum])

  useEffect(() => {
    function onEnterFullscreen() {
      setIsFullScreen(true)
    }

    function onQuiteFullscreen() {
      setIsFullScreen(false)
    }

    if (inMeeting) {
      if (!isSecondMonitor) {
        enterFullscreen && window.ipcRenderer?.send(IPCEvent.enterFullscreen)
      }

      window.ipcRenderer?.on(IPCEvent.enterFullscreen, onEnterFullscreen)
      window.ipcRenderer?.on(IPCEvent.quiteFullscreen, onQuiteFullscreen)

      return () => {
        window.ipcRenderer?.removeListener(
          IPCEvent.enterFullscreen,
          onEnterFullscreen
        )
        window.ipcRenderer?.removeListener(
          IPCEvent.quiteFullscreen,
          onQuiteFullscreen
        )
      }
    } else {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          secondMonitorFullScreen: undefined,
        },
      })
      setIsFullScreen(undefined)
    }
  }, [inMeeting])

  // 副屏幕全屏逻辑
  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data

      const { secondMonitorFullScreen } = meetingInfoRef.current
      let enterFullscreen =
        meetingInfoRef.current.setting.normalSetting.enterFullscreen

      if (payload && payload.meetingInfo) {
        enterFullscreen =
          payload.meetingInfo.setting.normalSetting.enterFullscreen
      }

      if (isSecondMonitor) {
        if (event === 'windowOpen') {
          if (secondMonitorFullScreen === undefined) {
            if (enterFullscreen) {
              window.ipcRenderer?.send(IPCEvent.enterFullscreen)
            } else {
              window.ipcRenderer?.send(IPCEvent.quiteFullscreen)
            }
          } else {
            if (secondMonitorFullScreen) {
              window.ipcRenderer?.send(IPCEvent.enterFullscreen)
            } else {
              window.ipcRenderer?.send(IPCEvent.quiteFullscreen)
            }
          }
        }
      }
    }

    window.addEventListener('message', handleMessage)
    return () => {
      window.removeEventListener('message', handleMessage)
    }
  }, [])

  useEffect(() => {
    if (isSecondMonitor) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          secondMonitorFullScreen: isFullScreen,
        },
      })
    }
  }, [isFullScreen])

  return { isFullScreen }
}

export default useFullscreen

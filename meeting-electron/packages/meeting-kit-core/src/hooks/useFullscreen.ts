import { useEffect, useMemo, useState } from 'react'
import { useMeetingInfoContext } from '../store'
import { IPCEvent } from '../app/src/types'

const useFullscreen = () => {
  const { meetingInfo } = useMeetingInfoContext()
  const [isFullScreen, setIsFullScreen] = useState(false)

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
      enterFullscreen && window.ipcRenderer?.send(IPCEvent.enterFullscreen)

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
      setIsFullScreen(false)
    }
  }, [inMeeting])

  return { isFullScreen }
}

export default useFullscreen

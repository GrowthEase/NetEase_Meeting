import { useMemo } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { useUpdateEffect } from 'ahooks'

export default function useScreenSharing() {
  const { neMeeting } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()

  const isElectronScreenSharing = useMemo(() => {
    return (
      window.isElectronNative && meetingInfo.myUuid === meetingInfo.screenUuid
    )
  }, [meetingInfo.myUuid, meetingInfo.screenUuid])

  useUpdateEffect(() => {
    if (isElectronScreenSharing) {
      if (meetingInfo.startSystemAudioLoopbackCapture) {
        neMeeting?.rtcController?.startSystemAudioLoopbackCapture?.()
      } else {
        neMeeting?.rtcController?.stopSystemAudioLoopbackCapture?.()
      }
    } else {
      if (!meetingInfo.localMember.isSharingSystemAudio) {
        neMeeting?.rtcController?.stopSystemAudioLoopbackCapture?.()
      }
    }
  }, [isElectronScreenSharing, meetingInfo.startSystemAudioLoopbackCapture])
}

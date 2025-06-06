import { useEffect, useRef, useState } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { getWindow } from '../kit'

const videoDomId = 'nemeeting-preview-video-dom'
const beautyDomId = 'beauty-video-canvas'

const usePreview = () => {
  const { neMeeting } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()
  const [isPreview, setIsPreview] = useState(false)
  const previewRef = useRef<HTMLElement>()
  const meetingInfoRef = useRef(meetingInfo)

  const { localMember } = meetingInfo

  meetingInfoRef.current = meetingInfo

  const startPreview = () => {
    setIsPreview(true)
    const settingWindow = getWindow('settingWindow')

    const view =
      settingWindow?.document.getElementById(videoDomId) ||
      settingWindow?.document.getElementById(beautyDomId)

    if (view) {
      previewRef.current = view
      const isPreviewController =
        meetingInfoRef.current.inWaitingRoom ||
        !meetingInfoRef.current.meetingNum

      if (isPreviewController) {
        neMeeting?.previewController?.setupLocalVideoCanvas(view)
      } else {
        neMeeting?.rtcController?.setupLocalVideoCanvas(view)
      }
    }
  }

  const stopPreview = () => {
    setIsPreview(false)
    const isPreviewController =
      meetingInfoRef.current.inWaitingRoom || !meetingInfoRef.current.meetingNum

    if (isPreviewController) {
      neMeeting?.previewController?.removeLocalVideoCanvas?.(previewRef.current)
    } else {
      neMeeting?.rtcController?.removeLocalVideoCanvas?.(previewRef.current)
    }

    previewRef.current = undefined
  }

  useEffect(() => {
    if (isPreview) {
      if (!localMember.isVideoOn) {
        neMeeting?.rtcController?.enableLocalVideo?.(true)
      }
    } else {
      if (!localMember.isVideoOn) {
        neMeeting?.rtcController?.enableLocalVideo?.(false)
      }
    }
  }, [isPreview, localMember.isVideoOn])

  return { startPreview, stopPreview }
}

export default usePreview

import { useEffect, useRef, useState } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { getWindow } from '../kit'
import RendererManager from '../libs/Renderer/RendererManager'
import { IRenderer } from '../libs/Renderer/IRenderer'

const videoDomId = 'nemeeting-preview-video-dom'
const beautyDomId = 'beauty-video-canvas'

const usePreview = () => {
  const { neMeeting } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()
  const [isPreview, setIsPreview] = useState(false)
  const previewRenderRef = useRef<IRenderer>()
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
      const context = {
        view: view,
        userUuid: meetingInfoRef.current.inWaitingRoom
          ? ''
          : meetingInfoRef.current.myUuid,
        sourceType: 'video',
      }

      previewRenderRef.current = RendererManager.instance.createRenderer(
        context
      )
    }
  }

  const stopPreview = () => {
    setIsPreview(false)
    const context = {
      userUuid: meetingInfoRef.current.inWaitingRoom
        ? ''
        : meetingInfoRef.current.myUuid,
      sourceType: 'video',
    }

    RendererManager.instance.removeRenderer(context, previewRenderRef.current)
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

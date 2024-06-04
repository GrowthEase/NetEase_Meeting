import { MutableRefObject, useContext, useEffect, useMemo, useRef } from 'react'
import { GlobalContext, MeetingInfoContext } from '../store'
import {
  GlobalContext as GlobalContextInterface,
  NEMeetingInfo,
} from '../types'

interface WhiteboardRes {
  viewRef: MutableRefObject<HTMLDivElement | null>
  enableDraw: boolean
  whiteColor: string
  transparentColor: string
  isSetCanvasRef: MutableRefObject<boolean>
  meetingInfoRef: MutableRefObject<NEMeetingInfo | null>
  dealTransparentWhiteboard: () => void
}
export function useWhiteboard(): WhiteboardRes {
  const viewRef = useRef<HTMLDivElement | null>(null)
  const { meetingInfo } = useContext(MeetingInfoContext)
  const { neMeeting } = useContext<GlobalContextInterface>(GlobalContext)

  const enableDraw = useMemo(() => {
    return meetingInfo.whiteboardUuid === meetingInfo.localMember.uuid
  }, [meetingInfo.whiteboardUuid, meetingInfo.localMember.uuid])
  const whiteColor = 'rgba(255, 255, 255, 1)'
  const transparentColor = 'rgba(255, 255, 255, 0)'
  const isSetCanvasRef = useRef(false)
  const meetingInfoRef = useRef<NEMeetingInfo | null>(null)
  meetingInfoRef.current = meetingInfo
  useEffect(() => {
    if (!isSetCanvasRef.current) {
      return
    }
    if (enableDraw) {
      neMeeting?.whiteboardController?.setEnableDraw(true)
    } else {
      neMeeting?.whiteboardController?.setEnableDraw(false)
    }
  }, [enableDraw])

  useEffect(() => {
    if (!isSetCanvasRef.current) {
      return
    }
    if (enableDraw) {
      neMeeting?.whiteboardController?.setEnableDraw(true)
    } else {
      neMeeting?.whiteboardController?.setEnableDraw(false)
    }
  }, [enableDraw])

  useEffect(() => {
    if (meetingInfo.isWhiteboardTransparent) {
      const mainVideoSize = meetingInfo.mainVideoSize

      if (!window.isElectronNative) {
        neMeeting?.whiteboardController?.lockCameraWithContent(
          mainVideoSize.width,
          mainVideoSize.height
        )
      } else {
        iframeDomLockCameraWithContent(
          mainVideoSize.width,
          mainVideoSize.height
        )
      }
    }
  }, [meetingInfo.mainVideoSize.width, meetingInfo.mainVideoSize.height])

  // 处理授权白板
  useEffect(() => {
    if (!isSetCanvasRef.current) {
      return
    }
    if (
      meetingInfo.localMember.properties.wbDrawable?.value == '1' ||
      meetingInfo.whiteboardUuid === meetingInfo.localMember.uuid
    ) {
      neMeeting?.whiteboardController?.setEnableDraw(true)
    } else {
      neMeeting?.whiteboardController?.setEnableDraw(false)
    }
  }, [meetingInfo.localMember.properties])

  // 处理透明属性变更
  useEffect(() => {
    dealTransparentWhiteboard()
  }, [meetingInfoRef.current?.isWhiteboardTransparent])

  // 处理透明白板
  const dealTransparentWhiteboard = () => {
    if (!window.isElectronNative) {
      const whiteboardController = neMeeting?.whiteboardController
      if (meetingInfoRef.current?.isWhiteboardTransparent) {
        whiteboardController?.setCanvasBackgroundColor(transparentColor)
        const mainVideoSize = meetingInfo.mainVideoSize
        whiteboardController?.lockCameraWithContent(
          mainVideoSize.width,
          mainVideoSize.height
        )
      } else {
        whiteboardController?.setCanvasBackgroundColor(whiteColor)
        whiteboardController?.unlockCameraWithContent()
      }
    } else {
      if (meetingInfoRef.current?.isWhiteboardTransparent) {
        iframeDomSetCanvasBackgroundColor(transparentColor)
        const mainVideoSize = meetingInfo.mainVideoSize
        iframeDomLockCameraWithContent(
          mainVideoSize.width,
          mainVideoSize.height
        )
      } else {
        iframeDomSetCanvasBackgroundColor(whiteColor)
        iframeDomUnlockCameraWithContent()
      }
    }
  }

  // 锁定内容
  function iframeDomLockCameraWithContent(width: number, height: number) {
    const iframeDom = document.getElementById(
      'nemeeting-whiteboard-iframe'
    ) as HTMLIFrameElement
    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"lockCameraWithContent","params":[{"height": ${height}, "width": ${width}}],"target":"drawPlugin"}}`,
        '*'
      )
    }
  }

  // 设置背景颜色
  function iframeDomSetCanvasBackgroundColor(color: string) {
    const iframeDom = document.getElementById(
      'nemeeting-whiteboard-iframe'
    ) as HTMLIFrameElement
    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"setAppConfig","params":[{"canvasBgColor": "${color}"}],"target":"drawPlugin"}}`,
        '*'
      )
    }
  }
  function iframeDomUnlockCameraWithContent() {
    const iframeDom = document.getElementById(
      'nemeeting-whiteboard-iframe'
    ) as HTMLIFrameElement
    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"unlockCameraWithContent","params":[],"target":"drawPlugin"}}`,
        '*'
      )
    }
  }

  return {
    viewRef,
    enableDraw,
    whiteColor,
    transparentColor,
    isSetCanvasRef,
    meetingInfoRef,
    dealTransparentWhiteboard,
  }
}

import React, { useContext, useEffect, useMemo, useRef } from 'react'
import {
  GlobalContext as GlobalContextInterface,
  NEMeetingInfo,
} from '../../../../types'
import { GlobalContext, MeetingInfoContext } from '../../../../store'
import './index.less'

interface WhiteboardProps {
  className?: string
  isEnable?: boolean
}
const WhiteBoardView: React.FC<WhiteboardProps> = ({ className, isEnable }) => {
  const isElectronNode = !!window.isElectronNative

  const viewRef = useRef<HTMLDivElement | null>(null)
  const { meetingInfo } = useContext(MeetingInfoContext)
  const meetingInfoRef = useRef<NEMeetingInfo | null>(null)
  meetingInfoRef.current = meetingInfo

  const { neMeeting } = useContext<GlobalContextInterface>(GlobalContext)

  const [whiteboardUrl, setWhiteboardUrl] = React.useState<string>('')

  const enableDraw = useMemo(() => {
    return meetingInfo.whiteboardUuid === meetingInfo.localMember.uuid
  }, [meetingInfo.whiteboardUuid, meetingInfo.localMember.uuid])

  const whiteColor = 'rgba(255, 255, 255, 1)'
  const transparentColor = 'rgba(255, 255, 255, 0)'
  const isSetCanvasRef = useRef(false)

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

  function iframeDomSetColor(color: string) {
    const iframeDom = document.getElementById(
      'nemeeting-whiteboard-iframe'
    ) as HTMLIFrameElement
    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"setColor","params":["${color}"],"target":"drawPlugin"}}`,
        '*'
      )
    }
  }

  // 隐藏上传多媒体文件和上传多媒体文件并转码的入口
  function iframeDomSetUploadPlugin() {
    const iframeDom = document.getElementById(
      'nemeeting-whiteboard-iframe'
    ) as HTMLIFrameElement
    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"addOrSetTool","params":[{"position":"left","insertAfterTool":"image","item":{"tool":"uploadCenter","hint":"上传文档","supportPptToH5":true,"supportDocToPic":true,"supportUploadMedia":false,"supportTransMedia":false}}],"target":"toolCollection"}}`,
        '*'
      )
    }
  }

  useEffect(() => {
    // 添加一个延迟，否则如果入会时候其他端已经开启白板，则执行显示白板的时候工具栏样式有问题
    const whiteboardController = neMeeting?.whiteboardController
    if (!isElectronNode) {
      setTimeout(() => {
        if (viewRef.current) {
          whiteboardController
            ?.setupWhiteboardCanvas(viewRef.current)
            .then(() => {
              isSetCanvasRef.current = true
              whiteboardController?.setEnableDraw(enableDraw)
            })
          // 当前房间属性是开启透明白板
          dealTransparentWhiteboard()
        }
      })
    } else {
      function postMessage(webJsBridge: string) {
        const paramString = webJsBridge
          .replace('WebJSBridge(', '')
          .replace(');', '')
        const iframeDom = document.getElementById(
          'nemeeting-whiteboard-iframe'
        ) as HTMLIFrameElement
        if (iframeDom) {
          iframeDom.contentWindow?.postMessage(paramString, '*')
        }
      }
      whiteboardController?.setupWhiteboardCanvas({
        // @ts-ignore
        onLogin: postMessage,
        // @ts-ignore
        onLogout: postMessage,
        // @ts-ignore
        onAuth: postMessage,
        // @ts-ignore
        onToolConfigChanged: postMessage,
        // @ts-ignore
        onDrawEnableChanged: postMessage,
      })
      window.addEventListener('message', (e) => {
        try {
          const data = JSON.parse(e.data)
          switch (data.action) {
            case 'webPageLoaded':
              // @ts-ignore
              neMeeting?.whiteboardController?.login()
              break
            case 'webGetAuth':
              // @ts-ignore
              neMeeting?.whiteboardController?.auth()
              break
            case 'webJoinWBSucceed':
              dealTransparentWhiteboard()
              // 延迟处理，否则会先闪一下正常白板，再到透明白板
              whiteboardController?.setEnableDraw(enableDraw)
              setTimeout(() => {
                isSetCanvasRef.current = true
                iframeDomSetColor('rgb(224, 32, 32)')
                iframeDomSetUploadPlugin()
              }, 200)
              break
            default:
              break
          }
        } catch {}
      })
      // @ts-ignore
      setWhiteboardUrl(whiteboardController?.getWhiteboardUrl())
    }
  }, [])

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
    if (
      meetingInfo.localMember.properties.wbDrawable?.value == '1' ||
      meetingInfo.whiteboardUuid === meetingInfo.localMember.uuid
    ) {
      neMeeting?.whiteboardController?.setEnableDraw(true)
    } else {
      neMeeting?.whiteboardController?.setEnableDraw(false)
    }
  }, [meetingInfo.localMember.properties])

  useEffect(() => {
    if (meetingInfo.isWhiteboardTransparent) {
      const mainVideoSize = meetingInfo.mainVideoSize

      if (!isElectronNode) {
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

  // 处理透明白板
  const dealTransparentWhiteboard = () => {
    if (!isElectronNode) {
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

  useEffect(() => {
    dealTransparentWhiteboard()
  }, [meetingInfoRef.current?.isWhiteboardTransparent])

  return (
    <div
      className={`nemeeting-whiteboard-wrap ${className || ''}`}
      style={{ zIndex: isEnable ? 12 : -1 }}
    >
      {whiteboardUrl ? (
        <iframe
          style={{ visibility: isEnable ? 'visible' : 'hidden' }}
          id="nemeeting-whiteboard-iframe"
          className={'whiteboard-view'}
          src={whiteboardUrl}
        />
      ) : (
        <div ref={viewRef} className={'whiteboard-view'} />
      )}
    </div>
  )
}

export default React.memo(WhiteBoardView)

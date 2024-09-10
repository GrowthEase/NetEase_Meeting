import React, { useContext, useEffect } from 'react'
import { GlobalContext } from '../../../../store'
import { GlobalContext as GlobalContextInterface } from '../../../../types'
import './index.less'
import { useWhiteboard } from '../../../../hooks/useWhiteboard'

interface WhiteboardProps {
  className?: string
  isEnable?: boolean
  isMainWindow?: boolean
}
const WhiteBoardView: React.FC<WhiteboardProps> = ({
  className,
  isEnable,
  isMainWindow = true,
}) => {
  const isElectronNode = !!window.isElectronNative

  const { neMeeting } = useContext<GlobalContextInterface>(GlobalContext)

  const [whiteboardUrl, setWhiteboardUrl] = React.useState<string>()

  const { viewRef, enableDraw, isSetCanvasRef, dealTransparentWhiteboard } =
    useWhiteboard()

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

  function iframeDomTool() {
    const iframeDom = document.getElementById(
      'nemeeting-whiteboard-iframe'
    ) as HTMLIFrameElement

    if (iframeDom) {
      if (isMainWindow) {
        iframeDom.contentWindow?.postMessage(
          `{"action":"jsDirectCall","param":{"action":"show","params":[{"bottomLeft": {"visible": ${false}}}],"target":"toolCollection"}}`,
          '*'
        )
      } else {
        iframeDom.contentWindow?.postMessage(
          `{"action":"jsDirectCall","param":{"action":"hide","params":[{"bottomLeft": {"visible": ${false}}}],"target":"toolCollection"}}`,
          '*'
        )
      }
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
              whiteboardController?.setEnableDraw(isMainWindow && enableDraw)
              // 当前房间属性是开启透明白板
              dealTransparentWhiteboard()
            })
        }
      })
    } else {
      const postMessage = (webJsBridge: string) => {
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
        onLogin: postMessage,
        onLogout: postMessage,
        onAuth: postMessage,
        onToolConfigChanged: postMessage,
        onDrawEnableChanged: postMessage,
      })
      window.addEventListener('message', (e) => {
        try {
          const data = JSON.parse(e.data)

          switch (data.action) {
            case 'webPageLoaded':
              neMeeting?.whiteboardController?.login?.()
              break
            case 'webGetAuth':
              neMeeting?.whiteboardController?.auth?.()
              break
            case 'webJoinWBSucceed':
              dealTransparentWhiteboard()
              // 延迟处理，否则会先闪一下正常白板，再到透明白板
              neMeeting?.whiteboardController?.setEnableDraw(
                isMainWindow && enableDraw
              )
              iframeDomTool()
              setTimeout(() => {
                isSetCanvasRef.current = true
                iframeDomSetColor('rgb(224, 32, 32)')
                iframeDomSetUploadPlugin()
              }, 200)
              break
            default:
              break
          }
        } catch (error) {
          console.error('error', error)
        }
      })
      const whiteboardUrl = whiteboardController?.getWhiteboardUrl?.()

      setWhiteboardUrl(whiteboardUrl)
    }

    return () => {
      if (!window.isElectronNative) {
        whiteboardController?.resetWhiteboardCanvas()
      }
    }
  }, [])

  // 处理授权白板
  useEffect(() => {
    if (!isSetCanvasRef.current) {
      return
    }

    iframeDomTool()
    neMeeting?.whiteboardController?.setEnableDraw(isMainWindow && enableDraw)
  }, [enableDraw, isMainWindow])

  return (
    <div
      className={`nemeeting-whiteboard-wrap ${className || ''}`}
      style={{ zIndex: isEnable ? 12 : -1 }}
    >
      {isMainWindow ? null : <div className="nemeeting-whiteboard-mask" />}
      {whiteboardUrl ? (
        <iframe
          style={{ visibility: isEnable ? 'visible' : 'hidden' }}
          id="nemeeting-whiteboard-iframe"
          className={`whiteboard-view ${
            isMainWindow ? 'whiteboard-view-main' : 'whiteboard-view-small'
          }`}
          src={whiteboardUrl}
        />
      ) : (
        <div
          ref={viewRef}
          className={`whiteboard-view ${
            isMainWindow ? 'whiteboard-view-main' : 'whiteboard-view-small'
          }`}
        />
      )}
    </div>
  )
}

export default React.memo(WhiteBoardView)

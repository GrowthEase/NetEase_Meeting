import React, { useContext, useEffect } from 'react'
import { GlobalContext } from '../../../../store'
import { GlobalContext as GlobalContextInterface } from '../../../../types'
import './index.less'
import { useWhiteboard } from '../../../../hooks/useWhiteboard'

interface WhiteboardProps {
  className?: string
  isEnable?: boolean
}
const WhiteBoardView: React.FC<WhiteboardProps> = ({ className, isEnable }) => {
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
      const postMessage = (webJsBridge: string) => {
        console.log('--------webJsBridge--------', webJsBridge)
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
        } catch (error) {
          console.error('error', error)
        }
      })
      const whiteboardUrl = whiteboardController?.getWhiteboardUrl?.()

      console.log('--------whiteboardUrl--------', whiteboardUrl)
      setWhiteboardUrl(whiteboardUrl)
    }
  }, [])

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

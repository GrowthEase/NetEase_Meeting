import React, { useContext, useEffect, useRef } from 'react'
import { GlobalContext, useMeetingInfoContext } from '../../../../store'
import {
  EventType,
  GlobalContext as GlobalContextInterface,
} from '../../../../types'
import './index.less'
import { useWhiteboard } from '../../../../hooks/useWhiteboard'
import saveAnnotation from '../../../../utils/saveAnnotation'
import { getLocalStorageSetting } from '../../../../utils'
import i18n from '../../../../locales/i18n'
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

  const { meetingInfo } = useMeetingInfoContext()

  const meetingInfoRef = useRef(meetingInfo)

  meetingInfoRef.current = meetingInfo
  const { neMeeting, eventEmitter } =
    useContext<GlobalContextInterface>(GlobalContext)

  const [whiteboardUrl, setWhiteboardUrl] = React.useState<string>()

  const { viewRef, enableDraw, isSetCanvasRef, dealTransparentWhiteboard } =
    useWhiteboard()

  const logIndexRef = useRef(0)

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
      //console.log('i18n.language: ', i18n.language)
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"addOrSetTool","params":[{"position":"left","insertAfterTool":"image","item":{"tool":"uploadCenter","hint":"${i18n.language.includes("zh") ? "上传文档" :  "upload document"}","supportPptToH5":true,"supportDocToPic":true,"supportUploadMedia":false,"supportTransMedia":false}}],"target":"toolCollection"}}`,
        '*'
      )
      //通知白板删除日志上传的按钮
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"removeTool","params":[{"name": "uploadLog", "position": "left"}],"target":"toolCollection"}}`,
        '*'
      )
      // iframeDom.contentWindow?.postMessage(
      //   `{"action":"jsDirectCall","param":{"action":"setVisibility","params":[{"left": {"visible": ${true}, "exclude": ["uploadLog"] }}],"target":"toolCollection"}}`,
      //   '*'
      // )
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
        console.log('Electron判断是否添加转码后的文档: ', meetingInfoRef.current?.whiteBoradAddDocConfig)
        if (meetingInfoRef.current?.whiteBoradAddDocConfig) {
          meetingInfoRef.current?.whiteBoradAddDocConfig.forEach(config => {
            iframeDom.contentWindow?.postMessage(
              `{"action":"jsDirectCall","param":{"action":"addDoc","params":[${JSON.stringify(config)}],"target":"toolCollection"}}`,
              '*'
            )
          })
        }
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
    function handleWhiteboardMessage(e) {
      try {
        if (typeof e.data !== 'string') {
          return
        }
        const data = JSON.parse(e.data)
        const parentWindow = window.parent
        switch (data.action) {
          case 'webPageLoaded':
            neMeeting?.whiteboardLogin?.()
            break
          case 'webGetAuth':
            neMeeting?.whiteboardAuth?.()
            break
          case 'webJoinWBSucceed':
            dealTransparentWhiteboard()
            // 延迟处理，否则会先闪一下正常白板，再到透明白板
            neMeeting?.setWhiteboardEnableDraw(isMainWindow && enableDraw)
            iframeDomTool()

            // 修复打开白板立即画图，画笔为默认黑色问题。不能延迟设置
            if (!meetingInfoRef.current?.isWhiteboardTransparent) {
              iframeDomSetColor('rgb(224, 32, 32)')
            }
            setTimeout(() => {
              isSetCanvasRef.current = true
              iframeDomSetColor('rgb(224, 32, 32)')
              iframeDomSetUploadPlugin()
            }, 200)
            break
          case 'webLeaveWB':
            console.log('白板离开房间')
            eventEmitter?.emit(
              EventType.WhiteboardLeaveResult, {}
            )
            //双屏场景下
            parentWindow?.postMessage(
              {
                event: EventType.WhiteboardLeaveResult,
                payload: {},
              },
              parentWindow.origin,
            );
            break
          case 'webDirectCallReturn':
            webDirectCallReturnHandler(data)
            break
          case 'webLog':
            console.info(data.param.msg)
            break
          case 'webGetAntiLeechInfo':
            webGetAntiLeechInfoHandler(data.param)
            break
          default:
            break
        }
      } catch (error) {
        console.error('error', error)
      }
    }
    async function webDirectCallReturnHandler(data) {
      const param = data.param
      if (param.funcName === 'exportAsBase64String') {
        console.log('Electron 接收到白板截图的反馈 param: ', param)
        if (!param.result) {
          console.warn('Electron 白板截图失败')
          eventEmitter?.emit(
            EventType.WhiteboardSavePhotoDone, {
              result: 'failed',
              reason: 'exportAsBase64String failed',
              openFileResult: false
            }
          )
          //双屏场景下
          const parentWindow = window.parent;
          parentWindow?.postMessage(
            {
              event: EventType.WhiteboardSavePhotoDone,
              payload: {
                result: 'failed',
                reason: 'exportAsBase64String failed',
                openFileResult: false
              },
            },
            parentWindow.origin,
          );
          return
        }
        const wbData = param.result.content
        let downloadPath: string | undefined
        const setting = getLocalStorageSetting()

        downloadPath = setting?.normalSetting?.downloadPath

        if (!downloadPath) {
          downloadPath = window.ipcRenderer?.sendSync(
            'nemeeting-download-path',
            'get'
          )
        }
        const fileName = `whiteBoard_${Date.now()}.png`
        console.log('Electron 保存截图到路径 downloadPath: ', downloadPath)
        window.ipcRenderer
          ?.invoke('saveAvatarToPath', wbData, downloadPath, fileName)
          .then(({ filePath }) => {
            console.log('Electron 截图保存路径完成: ', filePath)
            //打开这个文件夹
            window.ipcRenderer?.send('nemeeting-open-file', {
              isDir: true,
              filePath,
            })

            window.ipcRenderer?.removeAllListeners('nemeeting-open-file-reply')
            window.ipcRenderer?.once('nemeeting-open-file-reply', (_, exist) => {
              console.log('Electron 打开截图路径的结果 exist: ', exist)
              eventEmitter?.emit(
                EventType.WhiteboardSavePhotoDone, {
                  result: 'sucessed',
                  reason: '',
                  openFileResult: exist
                }
              )
              //双屏场景下
              const parentWindow = window.parent;
              parentWindow?.postMessage(
                {
                  event: EventType.WhiteboardSavePhotoDone,
                  payload: {
                    result: 'sucessed',
                    reason: '',
                    openFileResult: exist
                  },
                },
                parentWindow.origin,
              );
            })
          })
      } else if (param.funcName === 'isClearAvailable') {
        console.log('Electron 判断白板是否有绘制内容的反馈 param: ', param)
        eventEmitter?.emit(
          EventType.IsClearWhiteboardAvailbleResult, param.result
        )
        //双屏场景下
        const parentWindow = window.parent;
        parentWindow?.postMessage(
          {
            event: EventType.IsClearWhiteboardAvailbleResult,
            payload: param.result,
          },
          parentWindow.origin
        )
      }
    }
    async function webGetAntiLeechInfoHandler(param) {
      const { prop, url, seqId } = param

      const iframeDom = document.getElementById(
        'nemeeting-whiteboard-iframe'
      ) as HTMLIFrameElement

      const res = await neMeeting?.getAntiLeechInfo(prop, url)
      if (iframeDom) {
        iframeDom.contentWindow?.postMessage(
          `{"action":"jsSendAntiLeechInfo","param":{"code": 200,"seqId": ${seqId},"url": "${res.url}"}}`,
          '*'
        )
      }
    }
    const whiteboardLeave = () => {
      console.log('whiteboardLeave 离开白板房间')
      if (isElectronNode) {
        const iframeDom = document.getElementById(
          'nemeeting-whiteboard-iframe'
        ) as HTMLIFrameElement
        console.log('Electron 离开白板房间 iframeDom: ', iframeDom)
        if (iframeDom) {
          iframeDom.contentWindow?.postMessage(
            `{"action":"jsLeaveWB","param":{}}`,
            '*'
          )
          // iframeDom.contentWindow?.postMessage(
          //   `{"action":"jsLeaveWB","param":{"seqId":"isClearAvailable"}}`,
          //   '*'
          // )
        }
      } else {
        console.log('web 离开白板房间')
        const result = whiteboardController?.destroy()
        eventEmitter?.emit(
          EventType.WhiteboardLeaveResult, result
        )
      }
    }
    const isClearWhiteboardAvailble = () => {
      console.log('whiteboardSavePhoto 接收到判断白板是否有绘制内容指令')
      if (isElectronNode) {
        const iframeDom = document.getElementById(
          'nemeeting-whiteboard-iframe'
        ) as HTMLIFrameElement
        console.log('Electron 判断白板是否有绘制内容 iframeDom: ', iframeDom)
        if (iframeDom) {
          iframeDom.contentWindow?.postMessage(
            `{"action":"jsDirectCall","param":{"seqId":"isClearAvailable","action":"isClearAvailable","target":"drawPlugin"}}`,
            '*'
          )
        }
      } else {
        console.log('web 判断白板是否有绘制内容')
        const result = whiteboardController?.isClearAvailable()
        eventEmitter?.emit(
          EventType.IsClearWhiteboardAvailbleResult, result
        )
      }
    }

    const whiteboardSavePhoto = () => {
      console.log('whiteboardSavePhoto 接收到白板截图指令')
      if (isElectronNode) {
        const iframeDom = document.getElementById(
          'nemeeting-whiteboard-iframe'
        ) as HTMLIFrameElement
        console.log('Electron 开启截图 iframeDom: ', iframeDom)
        if (iframeDom) {
          iframeDom.contentWindow?.postMessage(
            `{"action":"jsDirectCall","param":{"seqId":"exportAsBase64String","action":"exportAsBase64String","params":[{"type":"png", "content":"clip"}],"target":"drawPlugin"}}`,
            '*'
          )
        }
      } else {
        console.log('web 开启截图')
        const result = whiteboardController?.exportAsBase64String({
          type: "png",
          content: "clip"
        })
        if (!result) {
          console.warn('web白板截图失败')
          eventEmitter?.emit(
            EventType.WhiteboardSavePhotoDone, {
              result: 'failed',
              reason: 'exportAsBase64String failed',
              openFileResult: false
            }
          )
          return
        }
        saveAnnotation({
          screenData: '',
          wbData: result.content,
        })
        eventEmitter?.emit(
          EventType.WhiteboardSavePhotoDone, {
            result: 'sucessed',
            reason: '',
            openFileResult: false
          }
        )
      }
    }
    if (!isElectronNode) {
      setTimeout(() => {
        if (viewRef.current) {
          whiteboardController
            ?.setupWhiteboardCanvas( viewRef.current, {
              whiteBoradAddDocConfig: meetingInfoRef.current?.whiteBoradAddDocConfig,
              whiteBoradContainerAspectRatio: meetingInfoRef.current?.whiteBoradContainerAspectRatio
            })
            .then(() => {
              isSetCanvasRef.current = true
              whiteboardController?.setEnableDraw(isMainWindow && enableDraw)
              // 当前房间属性是开启透明白板
              dealTransparentWhiteboard()
              // 白板日志走IM日志通道
              const whiteboardLogger =
                neMeeting?.whiteboardController?._whiteboard?.logger
              if (whiteboardLogger) {
                whiteboardLogger.dispatcher.on('log', (log) => {
                  const imLogger = neMeeting?.authService?._im?.nim?.logger
                  const cName =
                    neMeeting?.whiteboardController?._whiteboard?.channel || ''
                  imLogger?.log(
                    `[Whiteboard][${cName}][${logIndexRef.current}] ${log.msg}`
                  )
                  logIndexRef.current++
                })
              }
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
      neMeeting?.setupWhiteboardCanvas()
      eventEmitter?.on(EventType.WhiteboardWebJsBridge, postMessage)
      window.addEventListener('message', handleWhiteboardMessage)

      neMeeting?.getWhiteboardUrl().then((url) => {
        setWhiteboardUrl(url)
      })
    }
    console.warn('监听白板截图事件')
    eventEmitter?.on(EventType.WhiteboardSavePhoto, whiteboardSavePhoto)
    eventEmitter?.on(EventType.IsClearWhiteboardAvailble, isClearWhiteboardAvailble)
    eventEmitter?.on(EventType.WhiteboardLeave, whiteboardLeave)
    return () => {
      if (!window.isElectronNative) {
        console.log('resetWhiteboardCanvas>>>')
        neMeeting?.resetWhiteboardCanvas()
        eventEmitter?.off(EventType.WhiteboardSavePhoto, whiteboardSavePhoto)
        eventEmitter?.off(EventType.IsClearWhiteboardAvailble, isClearWhiteboardAvailble)
        eventEmitter?.off(EventType.WhiteboardLeave, whiteboardLeave)
      }else {
        console.warn('off')
        window.removeEventListener('message', handleWhiteboardMessage)
        eventEmitter?.removeAllListeners(EventType.WhiteboardWebJsBridge)
        eventEmitter?.off(EventType.WhiteboardSavePhoto, whiteboardSavePhoto)
        eventEmitter?.off(EventType.IsClearWhiteboardAvailble, isClearWhiteboardAvailble)
        eventEmitter?.off(EventType.WhiteboardLeave, whiteboardLeave)
      }
    }
  }, [])

  // 处理授权白板
  useEffect(() => {
    if (!isSetCanvasRef.current) {
      return
    }

    iframeDomTool()
    neMeeting?.setWhiteboardEnableDraw(isMainWindow && enableDraw)
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

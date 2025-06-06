import React, { useEffect } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { EventType } from '../../../types'
import './index.less'
import { useAnnotation } from '../../../hooks/useAnnotation'
import saveAnnotation, {getAnnotationBase64String} from '../../../utils/saveAnnotation'
import { IPCEvent } from '../../../app/src/types'
import { getLocalStorageSetting } from '../../../utils'

interface AnnotationViewProps {
  className?: string
  isEnable?: boolean
  isMain?: boolean
}
const AnnotationView: React.FC<AnnotationViewProps> = ({
  isEnable,
  isMain = true,
}) => {
  const { neMeeting, eventEmitter, online = true } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()
  const [whiteboardUrl, setWhiteboardUrl] = React.useState<string>()
  const [isSetCanvas, setIsSetCanvas] = React.useState<boolean>(false)
  const [isEditable, setIsEditable] = React.useState<boolean>(false)
  const checkIsClearAvailableCountRef = React.useRef(0)
  const saveAnnotationRef = React.useRef(false)
  //当前为退出屏幕共享二次 确认是否需要保存批注时使用(参考ControlBar/index.tsx文件中的handleSaveShareScreenAndAnnotationPhoto函数)
  const isAnnotationSavePhotoRef = React.useRef(false)
  const isClearAnnotationAvailbleRef = React.useRef(false)
  const annotationSavePhotoRef = React.useRef(false)

  const lockCameraWithContentRef = React.useRef({
    width: 0,
    height: 0,
  })

  useAnnotation(isEditable, isMain)

  function iframeDomClear() {
    const iframeDom = document.getElementById(
      'nemeeting-annotation-iframe'
    ) as HTMLIFrameElement

    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"enableDraw","params":[true],"target":"drawPlugin"}}`,
        '*'
      )
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"seqId":"isClearAvailable","action":"isClearAvailable","params":[],"target":"drawPlugin"}}`,
        '*'
      )
    }
  }

  function iframeDomLockCameraWithContent(width: number, height: number) {
    const iframeDom = document.getElementById(
      'nemeeting-annotation-iframe'
    ) as HTMLIFrameElement

    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"setCameraBound","params":[{"centerX": ${
          width / 2
        }, "centerY": ${
          height / 2
        },"height": ${height}, "width": ${width}}],"target":"drawPlugin"}}`,
        '*'
      )
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"lockCameraWithContent","params":[{"height": ${height}, "width": ${width}}],"target":"drawPlugin"}}`,
        '*'
      )
    }
  }

  function iframeDomLockExportAsBase64String() {
    const iframeDom = document.getElementById(
      'nemeeting-annotation-iframe'
    ) as HTMLIFrameElement

    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"seqId":"exportAsBase64String","action":"exportAsBase64String","params":[{"type":"png", "content":"clip"}],"target":"drawPlugin"}}`,
        '*'
      )
    }
  }

  function iframeDomHideToast() {
    const iframeDom = document.getElementById(
      'nemeeting-annotation-iframe'
    ) as HTMLIFrameElement

    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{,"action":"hideToast","params":[],"target":"whiteboardSDK"}}`,
        '*'
      )
    }
  }

  async function webDirectCallReturnHandler(data) {
    const param = data.param

    if (param.funcName === 'exportAsBase64String') {
      //白板截图的base64
      const wbData = param.result.content
      let screenData: string = ''
      const screenRes =
        meetingInfo.screenUuid === meetingInfo.myUuid
          ? await neMeeting?.takeLocalScreenSnapshot()
          : await neMeeting?.takeRemoteScreenSnapshot(
              meetingInfo.screenUuid
            )

      if (screenRes?.code === 0 && typeof screenRes.data === 'string') {
        screenData = screenRes.data
      }
      //屏幕共享截图的base64
      if (!screenData.includes(';base64,')) {
        screenData = await window.ipcRenderer?.invoke(
          IPCEvent.getImageBase64,
          {
            filePath: screenData,
            isDelete: true,
          }
        )
      }
      console.log('收到白板截图成功的反馈 isAnnotationSavePhotoRef: ', isAnnotationSavePhotoRef.current)
      if (isAnnotationSavePhotoRef.current == true && annotationSavePhotoRef.current == false) {
        //当前为退出屏幕共享二次 确认是否需要保存批注时使用
        try {
          annotationSavePhotoRef.current = true

          // 获取批注和屏幕共享截图合并后的图片base64数据
          const base64String = await getAnnotationBase64String({
            screenData,
            wbData,
          })

          //聊天室默认下载地址，产品需求，批注截图地址下载在同一位置
          let downloadPath: string | undefined
          const setting = getLocalStorageSetting()
          downloadPath = setting?.normalSetting?.downloadPath
          if (!downloadPath) {
            downloadPath = window.ipcRenderer?.sendSync(
              'nemeeting-download-path',
              'get'
            )
          }
          console.log('Electron 保存截图到路径 downloadPath: ', downloadPath)

          //批注截图图片的命令
          const fileName = `annotation_${Date.now()}.png`
          //将base64图片保存到指定的路径中
          window.ipcRenderer
            ?.invoke('saveAvatarToPath', base64String, downloadPath, fileName)
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
                isAnnotationSavePhotoRef.current = false
                //通知图片保存完成，可以关闭屏幕共享了 ControlBar 组件监听
                const parentWindow = window.parent;
                parentWindow?.postMessage(
                  {
                    event: EventType.AnnotationSavePhotoDone,
                    payload: {
                      result: 'sucessed',
                      reason: '',
                      openFileResult: false
                    },
                  },
                  parentWindow.origin,
                );
              })
            })
        } finally {
          isAnnotationSavePhotoRef.current = false
          annotationSavePhotoRef.current = false
        }
      } else if (saveAnnotationRef.current === false) {
        try {
          saveAnnotationRef.current = true
          await saveAnnotation({
            screenData,
            wbData,
          })
        } finally {
          saveAnnotationRef.current = false
        }
      }
    } else if (param.funcName === 'isClearAvailable') {
      if (isClearAnnotationAvailbleRef.current == true) {
        console.log('Electron isClearAvailable 通知结果: ', param.result)
        eventEmitter?.emit(
          EventType.IsClearAnnotationAvailbleResult, param.result
        )
        const parentWindow = window.parent;
        parentWindow?.postMessage(
          {
            event: EventType.IsClearAnnotationAvailbleResult,
            payload: param.result,
          },
          parentWindow.origin,
        );
        isClearAnnotationAvailbleRef.current = false
      }

      if (checkIsClearAvailableCountRef.current > 5) {
        setIsSetCanvas(true)
        return
      }

      const iframeDom = document.getElementById(
        'nemeeting-annotation-iframe'
      ) as HTMLIFrameElement

      if (iframeDom) {
        if (param.result) {
          iframeDom.contentWindow?.postMessage(
            `{"action":"jsDirectCall","param":{"seqId":"clear","action":"clear","params":[],"target":"drawPlugin"}}`,
            '*'
          )
          setIsSetCanvas(true)
        } else {
          checkIsClearAvailableCountRef.current++
          setTimeout(() => {
            iframeDom.contentWindow?.postMessage(
              `{"action":"jsDirectCall","param":{"seqId":"isClearAvailable","action":"isClearAvailable","params":[],"target":"drawPlugin"}}`,
              '*'
            )
          }, 200)
        }
      }
    }
  }

  async function webToolCollectionEventHandler(data) {
    const param = data.param

    if (
      param.name === 'iconClick' &&
      param.toolName === 'custom-saveAnnotation'
    ) {
      iframeDomLockExportAsBase64String()
    }
  }
  // 隐藏上传多媒体文件和上传多媒体文件并转码的入口
  function iframeDomSetUploadPlugin() {
    const iframeDom = document.getElementById(
      'nemeeting-whiteboard-iframe'
    ) as HTMLIFrameElement

    if (iframeDom) {
      //通知白板删除日志上传的按钮
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"removeTool","params":[{"name": "uploadLog", "position": "left"}],"target":"toolCollection"}}`,
        '*'
      )
    }
  }

  useEffect(() => {

    function annotationSavePhoto() {
      console.log('接收到批注截图指令')
      isAnnotationSavePhotoRef.current = true
      iframeDomLockExportAsBase64String()
    }

    function isClearAnnotationAvailble() {
      console.info('Electron 接收判断批注是否有绘制内容的指令')
      isClearAnnotationAvailbleRef.current = true
      const iframeDom = document.getElementById(
        'nemeeting-annotation-iframe'
      ) as HTMLIFrameElement

      console.info('Electron 判断批注是否有绘制内容 iframeDom: ', iframeDom)
      if (iframeDom) {
        iframeDom.contentWindow?.postMessage(
          `{"action":"jsDirectCall","param":{"seqId":"isClearAvailable","action":"isClearAvailable","target":"drawPlugin"}}`,
          '*'
        )
      }
    }

    function postMessage(webJsBridge: string) {
      const paramString = webJsBridge
        .replace('WebJSBridge(', '')
        .replace(');', '')
      const iframeDom = document.getElementById(
        'nemeeting-annotation-iframe'
      ) as HTMLIFrameElement

      if (iframeDom) {
        iframeDom.contentWindow?.postMessage(paramString, '*')
      }
    }

    function listener(e) {
      try {
        if (typeof e.data !== 'string') {
          return
        }
        //console.info('收到系统message消息: ', e)
        const data = JSON.parse(e.data)

        switch (data.action) {
          case 'webPageLoaded':
            neMeeting?.annotationLogin()
            break
          case 'webGetAuth':
            neMeeting?.annotationAuth()
            break
          case 'webJoinWBSucceed':
            iframeDomSetUploadPlugin()
            break
          case 'webDirectCallReturn':
            webDirectCallReturnHandler(data)
            break
          case 'webToolCollectionEvent':
            webToolCollectionEventHandler(data)
            break
          case 'webRoomStateChange':
            data.param.isEditable && setIsEditable(true)
            iframeDomHideToast()
            break
            case 'webLog':
              console.info(data.param.msg)
              break
          default:
            break
        }
      } catch (e) {
        console.log('annotation error', e)
      }
    }

    if (isEnable) {
      window.addEventListener('message', listener)
      neMeeting?.getAnnotationUrl().then((url) => {
        setWhiteboardUrl(url)
      })
      eventEmitter?.on(EventType.RoomAnnotationWebJsBridge, postMessage)
      eventEmitter?.on(EventType.AnnotationSavePhoto, annotationSavePhoto)
      eventEmitter?.on(EventType.IsClearAnnotationAvailble, isClearAnnotationAvailble)
      return () => {
        window.removeEventListener('message', listener)
        eventEmitter?.off(EventType.RoomAnnotationWebJsBridge, postMessage)
        eventEmitter?.off(EventType.AnnotationSavePhoto, annotationSavePhoto)
        eventEmitter?.off(EventType.IsClearAnnotationAvailble, isClearAnnotationAvailble)
      }
    }
  }, [isEnable, eventEmitter, neMeeting])

  useEffect(() => {
    if (isEditable) {
      if (meetingInfo.screenUuid === meetingInfo.myUuid) {
        iframeDomClear()
      } else {
        setIsSetCanvas(true)
      }
    }
  }, [meetingInfo.screenUuid, meetingInfo.myUuid, isEditable])

  useEffect(() => {
    const timer = setInterval(() => {
      const iframeDom = document.getElementById('nemeeting-annotation-iframe')

      if (iframeDom) {
        const viewWidth = iframeDom.clientWidth
        const viewHeight = iframeDom.clientHeight

        if (
          viewHeight === lockCameraWithContentRef.current.height &&
          viewWidth === lockCameraWithContentRef.current.width
        ) {
          return
        }

        lockCameraWithContentRef.current.width = viewWidth
        lockCameraWithContentRef.current.height = viewHeight
        iframeDomLockCameraWithContent(viewWidth, viewHeight)
      }
    }, 500)

    return () => {
      clearInterval(timer)
    }
  }, [])

  useEffect(() => {
    if (
      window.isElectronNative &&
      meetingInfo.screenUuid === meetingInfo.localMember.uuid &&
      isSetCanvas
    ) {
      neMeeting?.startAnnotation()
    }
  }, [
    meetingInfo.screenUuid,
    meetingInfo.localMember.uuid,
    isSetCanvas,
    neMeeting,
  ])

  return whiteboardUrl ? (
    <div className="annotation-view-container">
      <iframe
        style={{
          display:
            isSetCanvas && online && meetingInfo.annotationEnabled
              ? 'block'
              : 'none',
        }}
        id="nemeeting-annotation-iframe"
        className={'annotation-view'}
        src={whiteboardUrl}
      />
    </div>
  ) : null
}

export default React.memo(AnnotationView)

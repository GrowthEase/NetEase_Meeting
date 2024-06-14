import React, { useEffect } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { EventType } from '../../../types'
import './index.less'
import { useAnnotation } from '../../../hooks/useAnnotation'
import saveAnnotation from '../../../utils/saveAnnotation'
import { IPCEvent } from '../../../../app/src/types'

interface AnnotationViewProps {
  className?: string
  isEnable?: boolean
}
const AnnotationView: React.FC<AnnotationViewProps> = ({ isEnable }) => {
  const { neMeeting, eventEmitter, online = true } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()
  const [whiteboardUrl, setWhiteboardUrl] = React.useState<string>()
  const [isSetCanvas, setIsSetCanvas] = React.useState<boolean>(false)
  const [isEditable, setIsEditable] = React.useState<boolean>(false)
  const checkIsClearAvailableCountRef = React.useRef(0)

  const lockCameraWithContentRef = React.useRef({
    width: 0,
    height: 0,
  })

  useAnnotation(isEditable)

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
      const wbData = param.result.content
      let screenData: string = ''
      const screenRes =
        meetingInfo.screenUuid === meetingInfo.myUuid
          ? await neMeeting?.takeLocalScreenSnapshot()
          : await neMeeting?.takeRemoteScreenSnapshot(meetingInfo.screenUuid)

      if (screenRes?.code === 0 && typeof screenRes.data === 'string') {
        screenData = screenRes.data
      }

      if (!screenData.includes(';base64,')) {
        screenData = await window.ipcRenderer?.invoke(IPCEvent.getImageBase64, {
          filePath: screenData,
          isDelete: true,
        })
      }

      saveAnnotation({
        screenData,
        wbData,
      })
    } else if (param.funcName === 'isClearAvailable') {
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

  useEffect(() => {
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

    if (isEnable) {
      window.addEventListener('message', (e) => {
        try {
          const data = JSON.parse(e.data)

          console.log(data)
          switch (data.action) {
            case 'webPageLoaded':
              neMeeting?.annotationLogin()
              break
            case 'webGetAuth':
              neMeeting?.annotationAuth()
              break
            case 'webJoinWBSucceed':
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
            default:
              break
          }
        } catch (e) {
          console.log('annotation error', e)
        }
      })
      neMeeting?.getAnnotationUrl().then((url) => {
        setWhiteboardUrl(url)
      })
      eventEmitter?.on(EventType.RoomAnnotationWebJsBridge, postMessage)
      return () => {
        eventEmitter?.off(EventType.RoomAnnotationWebJsBridge, postMessage)
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

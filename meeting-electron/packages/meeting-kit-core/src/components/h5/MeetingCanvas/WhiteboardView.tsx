import React, { useCallback, useContext, useEffect, useRef } from 'react'
import {
  EventType,
  GlobalContext as GlobalContextInterface,
} from '../../../types'
import { GlobalContext, useMeetingInfoContext } from '../../../store'
import { useWhiteboard } from '../../../hooks/useWhiteboard'
import { useMount } from 'ahooks'

interface WhiteboardProps {
  className?: string
  canEdit?: boolean
}
const WhiteboardView: React.FC<WhiteboardProps> = ({ className, canEdit }) => {
  const { neMeeting, eventEmitter } =
    useContext<GlobalContextInterface>(GlobalContext)
  const { dealTransparentWhiteboard, viewRef, enableDraw, isSetCanvasRef } =
    useWhiteboard()
  const { meetingInfo } = useMeetingInfoContext()
  const meetingInfoRef = useRef(meetingInfo)
  meetingInfoRef.current = meetingInfo
  const logIndexRef = useRef(0)

  const whiteboardLeave = useCallback(() => {
    const result = neMeeting?.whiteboardController?.destroy()

    eventEmitter?.emit(EventType.WhiteboardLeaveResult, result)
  }, [eventEmitter])

  useEffect(() => {
    eventEmitter?.on(EventType.WhiteboardLeave, whiteboardLeave)
    return () => {
      eventEmitter?.off(EventType.WhiteboardLeave, whiteboardLeave)
    }
  }, [whiteboardLeave])
  // 处理授权白板
  useEffect(() => {
    if (!isSetCanvasRef.current) {
      return
    }

    neMeeting?.setWhiteboardEnableDraw(!!canEdit)
  }, [canEdit])

  useMount(() => {
    setTimeout(() => {
      if (viewRef.current) {
        neMeeting?.whiteboardController
          ?.setupWhiteboardCanvas(viewRef.current, {
          whiteBoradAddDocConfig: meetingInfoRef.current?.whiteBoradAddDocConfig,
          whiteBoradContainerAspectRatio: meetingInfoRef.current?.whiteBoradContainerAspectRatio
        }).then(() => {
            neMeeting?.whiteboardController?.setEnableDraw(enableDraw)
            isSetCanvasRef.current = true
            // 当前房间属性是开启透明白板
            dealTransparentWhiteboard()
          })
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
      }
    })
  })

  // 处理授权白板
  // useEffect(() => {
  //   if (!isSetCanvasRef.current) {
  //     return
  //   }

  //   neMeeting?.setWhiteboardEnableDraw(enableDraw)
  // }, [enableDraw])

  return (
    <div className={`whiteboard-wrap ${className}`}>
      <div ref={viewRef} className={'whiteboard-view'}></div>
    </div>
  )
}

export default React.memo(WhiteboardView)

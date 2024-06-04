import React, { useContext, useEffect, useMemo, useRef } from 'react'
import { GlobalContext as GlobalContextInterface } from '../../../types'
import { GlobalContext, MeetingInfoContext } from '../../../store'
import { useWhiteboard } from '../../../hooks/useWhiteboard'

interface WhiteboardProps {
  className?: string
}
const WhiteboardView: React.FC<WhiteboardProps> = ({ className }) => {
  const { neMeeting } = useContext<GlobalContextInterface>(GlobalContext)
  const { dealTransparentWhiteboard, viewRef, enableDraw, isSetCanvasRef } =
    useWhiteboard()
  useEffect(() => {
    setTimeout(() => {
      if (viewRef.current) {
        neMeeting?.whiteboardController
          ?.setupWhiteboardCanvas(viewRef.current)
          .then(() => {
            neMeeting?.whiteboardController?.setEnableDraw(enableDraw)
            isSetCanvasRef.current = true
          })
        // 当前房间属性是开启透明白板
        dealTransparentWhiteboard()
      }
    })
  }, [])

  return (
    <div className={`whiteboard-wrap ${className}`}>
      <div ref={viewRef} className={'whiteboard-view'}></div>
    </div>
  )
}

export default React.memo(WhiteboardView)

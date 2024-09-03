import React, { useContext } from 'react'
import { GlobalContext as GlobalContextInterface } from '../../../types'
import { GlobalContext } from '../../../store'
import { useWhiteboard } from '../../../hooks/useWhiteboard'
import { useMount } from 'ahooks'

interface WhiteboardProps {
  className?: string
}
const WhiteboardView: React.FC<WhiteboardProps> = ({ className }) => {
  const { neMeeting } = useContext<GlobalContextInterface>(GlobalContext)
  const { dealTransparentWhiteboard, viewRef, enableDraw, isSetCanvasRef } =
    useWhiteboard()

  useMount(() => {
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
  })

  return (
    <div className={`whiteboard-wrap ${className}`}>
      <div ref={viewRef} className={'whiteboard-view'}></div>
    </div>
  )
}

export default React.memo(WhiteboardView)

import React, { useContext, useEffect, useMemo, useRef } from 'react'
import { GlobalContext as GlobalContextInterface } from '../../../types'
import { GlobalContext, MeetingInfoContext } from '../../../store'

interface WhiteboardProps {
  className?: string
}
const WhiteboardView: React.FC<WhiteboardProps> = ({ className }) => {
  const viewRef = useRef<HTMLDivElement | null>(null)
  const { meetingInfo } = useContext(MeetingInfoContext)

  const { neMeeting } = useContext<GlobalContextInterface>(GlobalContext)
  // const enableDraw = useMemo(() => {
  //   return meetingInfo.whiteboardUuid === meetingInfo.localMember.uuid
  // }, [meetingInfo.whiteboardUuid])
  useEffect(() => {
    if (viewRef.current) {
      neMeeting?.whiteboardController
        ?.setupWhiteboardCanvas(viewRef.current)
        .then(() => {
          neMeeting?.whiteboardController?.setEnableDraw(false)
        })
    }
  }, [])

  // useEffect(() => {
  //   if (enableDraw) {
  //     neMeeting?.whiteboardController?.setEnableDraw(true)
  //   } else {
  //     neMeeting?.whiteboardController?.setEnableDraw(false)
  //   }
  // }, [enableDraw])

  // useEffect(() => {
  //   if (meetingInfo.localMember.properties.wbDrawable?.value == '1') {
  //     neMeeting?.whiteboardController?.setEnableDraw(true)
  //   } else {
  //     neMeeting?.whiteboardController?.setEnableDraw(false)
  //   }
  // }, [meetingInfo.localMember])
  return (
    <div className={`whiteboard-wrap ${className}`}>
      <div ref={viewRef} className={'whiteboard-view'}></div>
    </div>
  )
}

export default React.memo(WhiteboardView)

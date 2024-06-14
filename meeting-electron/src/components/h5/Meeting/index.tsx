import React from 'react'
import { useMeetingInfoContext } from '../../../store'
import WaitingRoom from '../WaitingRoom'
import MeetingContent from './Meeting'

interface AppProps {
  height: number
  width: number
}
const Meeting: React.FC<AppProps> = ({ width, height }) => {
  const { meetingInfo } = useMeetingInfoContext()

  return meetingInfo?.inWaitingRoom ? (
    meetingInfo.meetingNum ? (
      <WaitingRoom />
    ) : null
  ) : (
    <MeetingContent width={width} height={height} />
  )
}

export default Meeting

import React, { useEffect, useState } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import WaitingRoom from '../WaitingRoom'
import MeetingContent from './Meeting'
import DeviceTest from '../DeviceTest'
import { EventType, UserEventType } from '../../../types/innerType'

interface AppProps {
  height: number
  width: number
}
const Meeting: React.FC<AppProps> = ({ width, height }) => {
  const { meetingInfo } = useMeetingInfoContext()
  const { eventEmitter, outEventEmitter } = useGlobalContext()

  const [openTestDevice, setOpenTestDevice] = useState(false)

  useEffect(() => {
    eventEmitter?.on(EventType.ShowDeviceTest, () => {
      setOpenTestDevice(true)
    })
  }, [eventEmitter])

  function onCancelJoin() {
    setOpenTestDevice(false)
    eventEmitter?.emit(UserEventType.CancelJoin)
  }

  return (
    <>
      {meetingInfo?.inWaitingRoom ? (
        meetingInfo.meetingNum ? (
          <WaitingRoom />
        ) : null
      ) : (
        <MeetingContent width={width} height={height} />
      )}

      {openTestDevice && (
        <DeviceTest
          open={openTestDevice}
          onJoin={() => {
            setOpenTestDevice(false)
            outEventEmitter?.emit(UserEventType.JoinMeetingFromDeviceTest)
          }}
          onCancel={onCancelJoin}
        />
      )}
    </>
  )
}

export default Meeting

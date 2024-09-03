import React, { useEffect, useRef, useState } from 'react'
import classNames from 'classnames'
import './index.less'
import { meetingDuration } from '../../../utils'

interface MeetingDurationProps {
  className?: string
  startTime: number
}
// 会议持续时间
const MeetingDuration: React.FC<MeetingDurationProps> = React.memo(
  ({ startTime, className }: MeetingDurationProps) => {
    const timerRef = useRef<null | ReturnType<typeof setTimeout>>()
    const [durationTime, setDurationTime] = useState('')

    useEffect(() => {
      const _startTime = Math.min(startTime, new Date().getTime())

      setDurationTime(meetingDuration(_startTime))
      timerRef.current = setInterval(() => {
        setDurationTime(meetingDuration(_startTime))
      }, 1000)

      return () => {
        timerRef.current && clearInterval(timerRef.current)
        timerRef.current = undefined
      }
    }, [startTime])

    return (
      <div className={classNames('nemeeting-duration', className)}>
        {durationTime}
      </div>
    )
  }
)

MeetingDuration.displayName = 'MeetingDuration'

export default MeetingDuration

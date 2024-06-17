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
  ({ startTime, className }) => {
    const timerRef = useRef<number | NodeJS.Timeout>()
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
    }, [])

    return (
      <div className={classNames('nemeeting-duration', className)}>
        {durationTime}
      </div>
    )
  }
)

export default MeetingDuration

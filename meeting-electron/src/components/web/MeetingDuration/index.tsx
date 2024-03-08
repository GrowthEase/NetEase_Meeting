import React, { useEffect, useRef, useState } from 'react'
import classNames from 'classnames'
import './index.less'

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
    function meetingDuration(startTime: number): string {
      const now = new Date().getTime()
      const duration = now - startTime
      const hours = Math.floor(duration / (1000 * 60 * 60))
      const minutes = Math.floor((duration % (1000 * 60 * 60)) / (1000 * 60))
      const seconds = Math.floor((duration % (1000 * 60)) / 1000)
      let durationString = ''
      if (hours >= 1) {
        durationString += `${hours.toString().padStart(2, '0')}:`
      }
      durationString += `${minutes.toString().padStart(2, '0')}:${seconds
        .toString()
        .padStart(2, '0')}`
      return durationString
    }

    return (
      <div className={classNames('nemeeting-duration', className)}>
        {durationTime}
      </div>
    )
  }
)

export default MeetingDuration

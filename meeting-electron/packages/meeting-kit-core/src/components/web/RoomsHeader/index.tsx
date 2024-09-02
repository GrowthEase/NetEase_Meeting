import React, { useState, useEffect, useContext } from 'react'
import dayjs from 'dayjs'
import './index.less'
import Network from '../../common/Network'
import { ActionType, MeetingInfoContextInterface } from '../../../types'
import { MeetingInfoContext } from '../../../store'
import MeetingDuration from '../MeetingDuration'
import { getMeetingDisplayId } from '../../../utils'
import { useTranslation } from 'react-i18next'

interface Settings {
  pairingCode: string
  showMeetingTimeEnabled: boolean
  showShareCodeEnabled: boolean
  showMeetingNumEnabled: boolean
  highlightActiveUserEnabled: boolean
}

interface RoomsHeaderProps {
  style?: React.CSSProperties
}

const RoomsHeader: React.FC<RoomsHeaderProps> = ({ style }) => {
  const { meetingInfo, memberList, dispatch } =
    useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const { t } = useTranslation()

  const [dateLabel, setDateLabel] = useState(dayjs().format('MM-DD HH:mm:ss'))

  let settings: Settings | undefined

  try {
    settings = JSON.parse(
      localStorage.getItem('NetEase-Rooms-Settings') || '{}'
    )
  } catch (error) {
    console.error(error)
  }

  useEffect(() => {
    if (meetingInfo.showSpeaker !== settings?.highlightActiveUserEnabled) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          showSpeaker: settings?.highlightActiveUserEnabled,
        },
      })
    }
  }, [meetingInfo.showSpeaker, settings?.highlightActiveUserEnabled, dispatch])

  useEffect(() => {
    setInterval(() => {
      setDateLabel(dayjs().format('MM-DD HH:mm:ss'))
    }, 1000)
  }, [])

  return (
    <div className="rooms-header-container" style={style}>
      <div className="rooms-header-left">
        <div className="rooms-header-item network-item">
          <Network onlyIcon />
        </div>
        {settings?.showMeetingTimeEnabled && (
          <MeetingDuration
            className={'rooms-header-item time-item'}
            startTime={meetingInfo.rtcStartTime}
          />
        )}
        <div className="rooms-header-member">
          <svg className="icon icon-tool iconfont" aria-hidden="true">
            <use xlinkHref="#iconyx-tv-attendeex"></use>
          </svg>
          <span className="member-list-count-label">{memberList.length}</span>
        </div>
        {meetingInfo.liveState === 2 && (
          <div className="rooms-header-item live-item">
            <span className="living-icon" />
            <span>{t('living')}</span>
          </div>
        )}
      </div>

      <div className="rooms-header-center">
        {settings?.showMeetingNumEnabled
          ? `会议 ID：${getMeetingDisplayId(meetingInfo.meetingNum)}`
          : meetingInfo.subject}
      </div>

      <div className="rooms-header-right">
        <div className="rooms-header-item time-item">{dateLabel}</div>
        {settings?.showShareCodeEnabled && (
          <div className="rooms-header-item">
            共享码：{settings?.pairingCode}
          </div>
        )}
      </div>
    </div>
  )
}

export default RoomsHeader

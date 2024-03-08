import { Divider, Popover, Tag } from 'antd'
import React, { useMemo } from 'react'
import { useTranslation } from 'react-i18next'

import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { NEMeetingIdDisplayOption } from '../../../types'
import { copyElementValue } from '../../../utils'
import Toast from '../../common/toast'
import './index.less'

interface MeetingInfoProps {
  className?: string
}

const MeetingInfo: React.FC<MeetingInfoProps> = ({ className }) => {
  const { t } = useTranslation()
  const { meetingInfo } = useMeetingInfoContext()

  const { meetingIdDisplayOption } = useGlobalContext()

  const displayId = useMemo(() => {
    if (meetingInfo?.meetingNum) {
      const id = meetingInfo.meetingNum
      return id.slice(0, 3) + '-' + id.slice(3, 6) + '-' + id.slice(6)
    }
    return ''
  }, [meetingInfo?.meetingNum])

  function handleCopy(value?: string) {
    copyElementValue(value, () => {
      Toast.success(t('copySuccess'))
    })
  }

  return (
    <Popover
      className={className}
      trigger={['hover']}
      arrow={false}
      overlayClassName="meeting-info-popover"
      content={
        <div className="meeting-info-content">
          <div className="meeting-info-title">{meetingInfo.subject}</div>
          <div className="meeting-info-security-title">
            <svg
              className="icon iconfont iconcertification1x"
              aria-hidden="true"
            >
              <use xlinkHref="#iconcertification1x"></use>
            </svg>
            {t('securityInfo')}
          </div>
          <Divider />
          {meetingInfo.shortMeetingNum &&
            meetingIdDisplayOption !==
              NEMeetingIdDisplayOption.DISPLAY_LONG_ID_ONLY && (
              <div className="meeting-info-item">
                <div className="meeting-info-item-title">
                  {t('shortMeetingId')}
                </div>
                <div className="meeting-info-item-content">
                  {meetingInfo.shortMeetingNum}{' '}
                  <Tag color="#EBF2FF" className="custom-tag">
                    {t('internal')}
                  </Tag>
                  <svg
                    className="icon iconfont iconcopy1x"
                    aria-hidden="true"
                    onClick={() => handleCopy(meetingInfo.shortMeetingNum)}
                  >
                    <use xlinkHref="#iconcopy1x"></use>
                  </svg>
                </div>
              </div>
            )}
          {(meetingIdDisplayOption !==
            NEMeetingIdDisplayOption.DISPLAY_SHORT_ID_ONLY ||
            (meetingIdDisplayOption ===
              NEMeetingIdDisplayOption.DISPLAY_SHORT_ID_ONLY &&
              !meetingInfo?.shortMeetingNum)) && (
            <div className="meeting-info-item">
              <div className="meeting-info-item-title">{t('meetingId')}</div>
              <div className="meeting-info-item-content">
                {displayId}{' '}
                <svg
                  className="icon iconfont iconcopy1x"
                  aria-hidden="true"
                  onClick={() => handleCopy(meetingInfo.meetingNum)}
                >
                  <use xlinkHref="#iconcopy1x"></use>
                </svg>
              </div>
            </div>
          )}

          {meetingInfo?.password && (
            <div className="meeting-info-item">
              <div className="meeting-info-item-title">
                {t('meetingPassword')}
              </div>
              <div className="meeting-info-item-content">
                {meetingInfo.password}{' '}
                <svg
                  className="icon iconfont iconcopy1x"
                  aria-hidden="true"
                  onClick={() => handleCopy(meetingInfo.password)}
                >
                  <use xlinkHref="#iconcopy1x"></use>
                </svg>
              </div>
            </div>
          )}
          <div className="meeting-info-item">
            <div className="meeting-info-item-title">{t('host')}</div>
            <div className="meeting-info-item-content">
              {meetingInfo.hostName}
            </div>
          </div>
          <div className="meeting-info-item">
            <div className="meeting-info-item-title">{t('meetingUrl')}</div>
            <div className="meeting-info-item-content">
              {meetingInfo.meetingInviteUrl}
              <svg
                className="icon iconfont iconcopy1x"
                aria-hidden="true"
                onClick={() => handleCopy(meetingInfo.meetingInviteUrl)}
              >
                <use xlinkHref="#iconcopy1x"></use>
              </svg>
            </div>
            {/* <svg
              className="icon iconfont iconcopy1x"
              aria-hidden="true"
              onClick={() => handleCopy(meetingInfo.meetingInviteUrl)}
            >
              <use xlinkHref="#iconcopy1x"></use>
            </svg> */}
          </div>
        </div>
      }
      placement="bottom"
    >
      <div className="nemeeting-info-icon">
        <svg className="icon iconfont icona-45" aria-hidden="true">
          <use xlinkHref="#icona-45"></use>
        </svg>
      </div>
    </Popover>
  )
}
export default MeetingInfo

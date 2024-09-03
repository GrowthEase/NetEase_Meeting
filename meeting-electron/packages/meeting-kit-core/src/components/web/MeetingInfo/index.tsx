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

  const { meetingIdDisplayOption, globalConfig } = useGlobalContext()

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

  function getMeetingInviteUrl() {
    const meetingInviteUrl = meetingInfo.meetingInviteUrl

    if (!meetingInviteUrl) {
      return
    }

    return meetingInviteUrl
    /*
    if (location.origin === 'https://meeting.163.com') {
      return meetingInviteUrl
    } else {
      const urlObj = new URL(meetingInviteUrl)
      const searchParams = new URLSearchParams(urlObj.search)
      const code = searchParams.get('meeting')
      return `https://yiyong-qa.netease.im/yiyong-static/statics/invite/?meeting=${code}`
    }
    */
  }

  return (
    <Popover
      className={className}
      trigger={['hover']}
      arrow={false}
      overlayClassName="nemeeting-info-popover"
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
          {(meetingIdDisplayOption !==
            NEMeetingIdDisplayOption.DISPLAY_SHORT_ID_ONLY ||
            (meetingIdDisplayOption ===
              NEMeetingIdDisplayOption.DISPLAY_SHORT_ID_ONLY &&
              !meetingInfo?.shortMeetingNum)) && (
            <div className="meeting-info-item">
              <div className="meeting-info-item-title">{t('meetingId')}</div>
              <div className="meeting-info-item-content">
                <span className="meeting-info-item-content-display-id">
                  {displayId}
                </span>{' '}
                <svg
                  className="icon iconfont iconcopy1x"
                  aria-hidden="true"
                  onClick={() => handleCopy(meetingInfo.meetingNum)}
                >
                  <use xlinkHref="#iconfuzhi1"></use>
                </svg>
              </div>
            </div>
          )}
          {meetingInfo.shortMeetingNum &&
            meetingIdDisplayOption !==
              NEMeetingIdDisplayOption.DISPLAY_LONG_ID_ONLY && (
              <div className="meeting-info-item">
                <div className="meeting-info-item-title">
                  {t('meetingShortNum')}
                </div>
                <div className="meeting-info-item-content">
                  <span className="meeting-info-item-content-short-meeting-num">
                    {meetingInfo.shortMeetingNum}
                  </span>{' '}
                  <Tag color="#EBF2FF" className="custom-tag">
                    {t('internal')}
                  </Tag>
                  <svg
                    className="icon iconfont iconcopy1x"
                    aria-hidden="true"
                    onClick={() => handleCopy(meetingInfo.shortMeetingNum)}
                  >
                    <use xlinkHref="#iconfuzhi1"></use>
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
                  <use xlinkHref="#iconfuzhi1"></use>
                </svg>
              </div>
            </div>
          )}
          {meetingInfo.hostName ? (
            <div className="meeting-info-item">
              <div className="meeting-info-item-title">{t('host')}</div>
              <div className="meeting-info-item-content">
                {meetingInfo.hostName}
              </div>
            </div>
          ) : null}
          {meetingInfo.meetingInviteUrl ? (
            <div className="meeting-info-item">
              <div className="meeting-info-item-title">
                {t('meetingInviteUrl')}
              </div>
              <div className="meeting-info-item-content meeting-info-item-content-url  nemeeting-info-item-content-sip">
                <span style={{ flex: 1 }}>{meetingInfo.meetingInviteUrl}</span>
                <svg
                  className="icon iconfont iconcopy1x"
                  aria-hidden="true"
                  onClick={() => handleCopy(getMeetingInviteUrl())}
                >
                  <use xlinkHref="#iconfuzhi1"></use>
                </svg>
              </div>
            </div>
          ) : null}
          {meetingInfo?.sipCid && globalConfig?.appConfig.inboundPhoneNumber ? (
            <div className="meeting-info-item">
              <div className="meeting-info-item-title">
                {t('meetingMobileDialInTitle')}
              </div>
              <div className="meeting-info-item-content nemeeting-info-item-content-sip">
                <div>
                  <div>
                    {t('meetingMobileDialInMsg', {
                      phoneNumber: globalConfig?.appConfig.inboundPhoneNumber,
                    })}
                  </div>
                  <div>
                    {t('meetingInputSipNumber', {
                      sipNumber: meetingInfo?.sipCid,
                    })}
                  </div>
                </div>
              </div>
            </div>
          ) : null}
          {meetingInfo?.sipCid ? (
            <div className="meeting-info-item">
              <div className="meeting-info-item-title">
                {t('meetingSipNumber')}
              </div>
              <div className="meeting-info-item-content nemeeting-info-item-content-sip">
                {t('meetingInputSipNumber', {
                  sipNumber: meetingInfo?.sipCid,
                })}
              </div>
            </div>
          ) : null}
          {meetingInfo.maxMembers ? (
            <div className="meeting-info-item">
              <div className="meeting-info-item-title">
                {t('meetingMaxMembers')}
              </div>
              <div className="meeting-info-item-content nemeeting-info-item-content-sip">
                {meetingInfo.maxMembers}
              </div>
            </div>
          ) : null}
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

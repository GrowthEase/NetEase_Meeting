import React, { useState, useEffect, useContext, useMemo } from 'react'
import { MeetingInfoContext, useGlobalContext } from '../../../store'
import { MeetingInfoContextInterface } from '../../../types'
import Toast from '../../common/toast'
import { copyElementValue } from '../../../utils'
import './index.less'
import { NEMeetingIdDisplayOption } from '../../../types/type'
import { useTranslation } from 'react-i18next'

interface MeetingInfoProps {
  visible: boolean
  onClose: () => void
}
const MeetingInfo: React.FC<MeetingInfoProps> = ({
  visible = false,
  onClose,
}) => {
  const [selfShow, setSelfShow] = useState(false)
  const { meetingInfo } =
    useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const { t, i18n: i18next } = useTranslation()
  const i18n = {
    copySuccess: t('copySuccess'),
    shortId: t('shortId'),
    meetingHost: t('host'),
    meetingId: t('meetingId'),
    meetingPassword: t('meetingPassword'),
    meetingInviteUrl: t('meetingInviteUrl'),
  }

  const { meetingIdDisplayOption } = useGlobalContext()

  const displayId = useMemo(() => {
    if (meetingInfo?.meetingNum) {
      const id = meetingInfo.meetingNum
      return id.slice(0, 3) + '-' + id.slice(3, 6) + '-' + id.slice(6)
    }
    return ''
  }, [meetingInfo?.meetingNum])

  useEffect(() => {
    setSelfShow(visible)
  }, [visible])

  const handleCopy = (value: any) => {
    copyElementValue(value, () => {
      Toast.success(i18n.copySuccess)
    })
  }

  const copyItem = (value: any) => {
    return (
      <i
        className="icon-blue icon-copy iconfont iconcopy1x"
        onClick={() => {
          handleCopy(value)
        }}
      ></i>
    )
  }

  return (
    <>
      {selfShow && (
        <div
          className="meeting-info-wrap w-full h-full absolute"
          onClick={(e) => {
            onClose && onClose()
            e.stopPropagation()
          }}
        >
          <div
            id="meetingDiv"
            className="w-full absolute meeting-info-modal"
            onClick={(e) => {
              e.stopPropagation()
            }}
          >
            <div className="meeting-info-content focus:outline-4">
              <div className="meeting-info-content-wrap text-left">
                <div className="drawer-info">
                  <div className="meeting-subject text-xl">
                    {meetingInfo?.subject}
                  </div>
                  <div className="meeting-info-security text-xs">
                    <i className="icon-cert iconfont iconcertification1x"></i>
                    <span>{t('meetingInfoDesc')}</span>
                  </div>
                </div>
                <hr className="border-wrap" />
                <div className="pt-2 meeting-info">
                  {meetingInfo?.shortMeetingNum &&
                    meetingIdDisplayOption !==
                      NEMeetingIdDisplayOption.DISPLAY_LONG_ID_ONLY && (
                      <div className="info-item">
                        <div className="info-item-title">{i18n.shortId}</div>
                        <div className="info-item-content">
                          {meetingInfo?.shortMeetingNum}
                        </div>
                        {copyItem(meetingInfo?.shortMeetingNum)}
                      </div>
                    )}
                  {(meetingIdDisplayOption !==
                    NEMeetingIdDisplayOption.DISPLAY_SHORT_ID_ONLY ||
                    (meetingIdDisplayOption ===
                      NEMeetingIdDisplayOption.DISPLAY_SHORT_ID_ONLY &&
                      !meetingInfo?.shortMeetingNum)) && (
                    <div className="info-item">
                      <div className="info-item-title">{i18n.meetingId}</div>
                      <div className="info-item-content">
                        <span>{displayId}</span>
                        {copyItem(meetingInfo?.meetingNum)}
                      </div>
                    </div>
                  )}

                  {meetingInfo?.password && (
                    <div className="info-item">
                      <div className="info-item-title">
                        {i18n.meetingPassword}
                      </div>
                      <div className="info-item-content">
                        {meetingInfo?.password}
                      </div>
                      {copyItem(meetingInfo?.password)}
                    </div>
                  )}
                  <div className="info-item">
                    <div className="info-item-title">{i18n.meetingHost}</div>
                    <div className="info-item-content">
                      {meetingInfo?.hostName}
                    </div>
                  </div>

                  {meetingInfo?.meetingInviteUrl && (
                    <div className="info-item">
                      <div className="info-item-title">
                        {i18n.meetingInviteUrl}
                      </div>
                      <div className="info-item-content info-item-content-url">
                        {meetingInfo?.meetingInviteUrl}
                        {copyItem(meetingInfo?.meetingInviteUrl)}
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  )
}
export default MeetingInfo

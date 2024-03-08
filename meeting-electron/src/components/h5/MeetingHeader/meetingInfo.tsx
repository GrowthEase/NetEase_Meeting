import React, { useState, useEffect, useContext, useMemo } from 'react'
import { MeetingInfoContext, useGlobalContext } from '../../../store'
import { MeetingInfoContextInterface } from '../../../types'
import Toast from '../../common/toast'
import { copyElementValue } from '../../../utils'
import './index.less'
import { NEMeetingIdDisplayOption } from '../../../types/type'

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
      Toast.success('复制成功')
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
                    <span>会议正加密保护中</span>
                  </div>
                </div>
                <hr className="border-wrap" />
                <div className="pt-2 meeting-info">
                  {meetingInfo?.shortMeetingNum &&
                    meetingIdDisplayOption !==
                      NEMeetingIdDisplayOption.DISPLAY_LONG_ID_ONLY && (
                      <div className="info-item">
                        <div className="info-item-title">会议短号</div>
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
                      <div className="info-item-title">会议ID</div>
                      <div className="info-item-content">
                        <span>{displayId}</span>
                        {copyItem(meetingInfo?.meetingNum)}
                      </div>
                    </div>
                  )}

                  {meetingInfo?.password && (
                    <div className="info-item">
                      <div className="info-item-title">会议密码</div>
                      <div className="info-item-content">
                        {meetingInfo?.password}
                      </div>
                      {copyItem(meetingInfo?.password)}
                    </div>
                  )}
                  <div className="info-item">
                    <div className="info-item-title">主持人</div>
                    <div className="info-item-content">
                      {meetingInfo?.hostName}
                    </div>
                  </div>

                  {/* {meetingInfo?.url && (
                    <>
                      <div>邀请链接</div>
                      <div className="col-span-2">{meetingInfo?.url}</div>
                    </>
                  )} */}
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

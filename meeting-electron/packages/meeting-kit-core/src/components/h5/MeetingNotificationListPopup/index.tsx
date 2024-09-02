import { css } from '@emotion/css'
import { Popup, PopupProps } from 'antd-mobile/es'
import React, { useRef } from 'react'
import { useTranslation } from 'react-i18next'
import { useMeetingInfoContext } from '../../../store'
import MeetingNotificationList, {
  MeetingNotificationListRef,
} from '../../common/Notification/List'
import useMeetingPlugin from '../../../hooks/useMeetingPlugin'
import { useUpdateEffect } from 'ahooks'
import { ActionType } from '../../../types'

const popupBodyCls = css`
  height: 90%;
  border-radius: 8px 8px 0 0;
`

const popupHeaderCls = css`
  height: 40px;
  text-align: center;
  color: #333;
  line-height: 40px;
  font-size: 16px;
  display: flex;
  justify-content: center;
`

const popupLeftCls = css`
  position: absolute;
  left: 10px;
  height: 40px;
  line-height: 40px;
  width: 30px;
  .iconfont {
    font-size: 20px;
  }
`

const popupCloseCls = css`
  position: absolute;
  right: 10px;
  font-size: 16px;
  color: #337eff;
  height: 40px;
  line-height: 40px;
  width: 30px;
`

const pluginContainerCls = css`
  height: calc(100% - 40px);
`

const MeetingNotificationListPopup: React.FC<PopupProps> = (props) => {
  const { t } = useTranslation()
  const { meetingInfo, dispatch } = useMeetingInfoContext()

  const { onClickPlugin } = useMeetingPlugin()

  const meetingNotificationListRef = useRef<MeetingNotificationListRef>(null)

  const onClearAll = () => {
    meetingNotificationListRef.current?.handleClearAll()
  }

  // h5 自动清理通知
  useUpdateEffect(() => {
    if (props.visible) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          notificationMessages: meetingInfo.notificationMessages.map((msg) => {
            return { ...msg, unRead: false }
          }),
        },
      })
    }
  }, [meetingInfo.notificationMessages.length])

  return (
    <Popup bodyClassName={popupBodyCls} {...props}>
      <>
        <div className={popupHeaderCls}>
          {meetingInfo.notificationMessages.length > 0 ? (
            <div className={popupLeftCls} onClick={onClearAll}>
              <svg className="icon iconfont" aria-hidden="true">
                <use xlinkHref="#icontongzhiqingkong"></use>
              </svg>
            </div>
          ) : null}
          {t('notification')}
          <div className={popupCloseCls} onClick={() => props.onClose?.()}>
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconyx-tv-duankai1x"></use>
            </svg>
          </div>
        </div>
        <div className={pluginContainerCls}>
          <MeetingNotificationList
            isH5
            ref={meetingNotificationListRef}
            sessionIds={[]}
            onClick={(action) => {
              if (action?.startsWith('meeting://open_plugin')) {
                onClickPlugin(action, true)
              }
            }}
          />
        </div>
      </>
    </Popup>
  )
}

export default MeetingNotificationListPopup

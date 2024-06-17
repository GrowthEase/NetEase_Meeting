import React, { useEffect, useMemo, useRef } from 'react'
import { Button } from 'antd'

import './index.less'

interface MeetingNotificationGlobalCardProps {
  messageList: any[]
  onClick?: (action: string, message: any) => void
  onClose?: () => void
  showCloseIcon?: boolean
}

const MeetingNotificationGlobalCard: React.FC<
  MeetingNotificationGlobalCardProps
> = (props) => {
  const { messageList, onClick, onClose } = props
  const timerRef = useRef<any>(null)

  const message = useMemo(() => {
    const len = messageList.length

    if (len > 0) {
      return messageList[len - 1]
    } else {
      return null
    }
  }, [messageList])
  const notifyCard = useMemo(() => {
    return message?.data?.data?.notifyCard
  }, [message])

  useEffect(() => {
    // 信息60s后自动消失
    if (message.messageId) {
      const tmpDurationTime = message.data?.data?.timestamp
        ? Date.now() - message.data?.data?.timestamp
        : 0
      const popupDuration =
        message.data?.data?.popupDuration * 1000 || 60000 - tmpDurationTime

      if (popupDuration <= 0) {
        onClose?.()
        return
      }

      if (timerRef.current) {
        clearTimeout(timerRef.current)
      }

      timerRef.current = setTimeout(() => {
        timerRef.current = null
        onClose?.()
      }, popupDuration)
    }
  }, [message.messageId])
  useEffect(() => {
    return () => {
      if (timerRef.current) {
        clearTimeout(timerRef.current)
      }
    }
  }, [])
  return notifyCard ? (
    <div className="notification-global-card-container">
      <div className="nemeeting-notify-header">
        <div className="info">
          {notifyCard.header?.icon ? (
            <img alt="" className="icon" src={notifyCard.header?.icon} />
          ) : null}
          <div className="label">{notifyCard.header?.subject}</div>
        </div>
        {props.showCloseIcon === false ? null : (
          <svg
            className="icon iconfont close-icon"
            onClick={() => props.onClose?.()}
          >
            <use xlinkHref="#iconyx-pc-closex"></use>
          </svg>
        )}
      </div>
      <div className="content">
        <div className="title">{notifyCard.body?.title}</div>
        <div className="description">{notifyCard.body?.content}</div>
      </div>
      <div className="nemeeting-notify-footer-wrapper">
        <div className="nemeeting-notify-footer">
          {notifyCard.popUpCardBottomButton?.map((item) => {
            return (
              <Button
                key={item.name}
                className="nemeeting-notify-footer-btn"
                ghost={item.ghost || item.action === 'meeting://no_more_remind'}
                type="primary"
                onClick={() => {
                  onClick?.(item.action, message)
                }}
              >
                {item.name}
              </Button>
            )
          })}
        </div>

        {notifyCard.footTip && (
          <div className="nemeeting-notify-footer-tip">
            {notifyCard.footTip}
          </div>
        )}
      </div>
    </div>
  ) : null
}

export default MeetingNotificationGlobalCard

import React from 'react'
import { Button } from 'antd'
import { useTranslation } from 'react-i18next'

import './index.less'

interface MeetingNotificationGlobalCardProps {
  notifyCard: any
  onClick?: (action: string) => void
}

const MeetingNotificationGlobalCard: React.FC<
  MeetingNotificationGlobalCardProps
> = (props) => {
  const { notifyCard, onClick } = props

  return (
    <div className="notification-global-card-container">
      <div className="header">
        <div className="info">
          {notifyCard.header?.icon ? (
            <img alt="" className="icon" src={notifyCard.header?.icon} />
          ) : null}
          <div className="label">{notifyCard.header?.subject}</div>
        </div>
        <svg
          className="icon iconfont close-icon"
          onClick={() => window.close()}
        >
          <use xlinkHref="#iconyx-pc-closex"></use>
        </svg>
      </div>
      <div className="content">
        <div className="title">{notifyCard.body?.title}</div>
        <div className="description">{notifyCard.body?.content}</div>
      </div>
      <div className="footer">
        {notifyCard.popUpCardBottomButton?.map((item) => {
          return (
            <Button
              key={item.name}
              className="button"
              ghost={item.action === 'meeting://no_more_remind'}
              type="primary"
              onClick={() => {
                onClick?.(item.action)
                window.close()
              }}
            >
              {item.name}
            </Button>
          )
        })}
      </div>
    </div>
  )
}
export default MeetingNotificationGlobalCard

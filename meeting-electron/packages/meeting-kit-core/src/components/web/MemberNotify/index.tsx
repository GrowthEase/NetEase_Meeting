import { Button } from 'antd'
import classNames from 'classnames'
import React, { forwardRef, useImperativeHandle } from 'react'
import { useTranslation } from 'react-i18next'
import { useGlobalContext } from '../../../store'
import './index.less'
import { NotificationInstance } from 'antd/es/notification/interface'

interface MemberNotifyProps {
  handleViewMsg: () => void
  style?: Record<string, string | number>
  onClose?: () => void
  onNotNotify?: () => void
  notificationApi?: NotificationInstance
}
export interface MemberNotifyRef {
  notify: (memberCount: number) => void
  destroy: () => void
}

const WAITING_ROOM_MEMBER_JOIN_KEY = 'WAITING_ROOM_MEMBER_JOIN_KEY'
const MemberNotify = forwardRef<
  MemberNotifyRef,
  React.PropsWithChildren<MemberNotifyProps>
>((props, ref) => {
  const { handleViewMsg, onClose, onNotNotify, style } = props

  const { notificationApi: notificationApiContext } = useGlobalContext()
  const { t } = useTranslation()

  const notificationApi = props.notificationApi || notificationApiContext

  useImperativeHandle(ref, () => ({
    notify,
    destroy,
  }))

  function notify(memberCount: number) {
    notificationApi?.destroy(WAITING_ROOM_MEMBER_JOIN_KEY)
    notificationApi?.info({
      className: 'nemeeing-waiting-room-notify',
      key: WAITING_ROOM_MEMBER_JOIN_KEY,
      style,
      message: (
        <div className="waiting-room-notify-title">
          <div>{t('attendees')}</div>
          <div className="waiting-room-notify-btn">
            <Button
              size="small"
              style={{ fontSize: '12px', marginRight: '3px', color: '#666' }}
              onClick={() => {
                notificationApi?.destroy(WAITING_ROOM_MEMBER_JOIN_KEY)
                onNotNotify && onNotNotify()
              }}
              type="text"
            >
              {t('notRemindMeAgain')}
            </Button>
            <Button
              size="small"
              style={{ fontSize: '12px' }}
              onClick={() => {
                handleViewMsg()
              }}
              type="primary"
            >
              {t('viewMessage')}
            </Button>
          </div>
        </div>
      ),
      duration: 5,
      closeIcon: (
        <div className="waiting-room-notify-close">
          <svg
            className={classNames('icon iconfont icon-chat')}
            aria-hidden="true"
          >
            <use xlinkHref="#iconcross"></use>
          </svg>
        </div>
      ),
      onClose: onClose,
      icon: (
        <div className="nemeeting-waiting-room-member-manager">
          <svg className="icon iconfont" aria-hidden="true">
            <use xlinkHref="#iconguanlicanhuizhe-mianxing"></use>
          </svg>
        </div>
      ),
      description: (
        <div className="notify-description">
          <span>{t('waitingMemberCount1')}</span>
          <span style={{ color: '#337EFF', margin: '0 4px' }}>
            {memberCount || ''}
          </span>
          <span>{t('waitingMemberCount2')}</span>
        </div>
      ),
    })
  }

  function destroy() {
    notificationApi?.destroy(WAITING_ROOM_MEMBER_JOIN_KEY)
  }

  return <></>
})

MemberNotify.displayName = 'MemberNotify'

export default React.memo(MemberNotify)

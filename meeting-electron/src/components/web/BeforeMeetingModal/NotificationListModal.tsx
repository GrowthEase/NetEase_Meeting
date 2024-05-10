import { ModalProps } from 'antd'
import React from 'react'
import { useTranslation } from 'react-i18next'

import EventEmitter from 'eventemitter3'
import NEMeetingService from '../../../services/NEMeeting'
import Modal from '../../common/Modal'
import MeetingNotificationList from '../../common/Notification/List'
import './index.less'

interface NotificationListModalProps extends ModalProps {
  neMeeting?: NEMeetingService
  eventEmitter?: EventEmitter
  sessionId?: string
  onClick?: (action?: string) => void
}

const NotificationListModal: React.FC<NotificationListModalProps> = ({
  neMeeting,
  sessionId,
  onClick,
  eventEmitter,
  ...restProps
}) => {
  const { t } = useTranslation()

  return (
    <Modal
      title={t('notifyCenter')}
      width={375}
      maskClosable={false}
      rootClassName="chatroom-modal-root"
      footer={null}
      destroyOnClose
      {...restProps}
    >
      <div className="chatroom-content">
        <MeetingNotificationList
          eventEmitter={eventEmitter}
          neMeeting={neMeeting}
          onClick={onClick}
          sessionIds={sessionId ? [sessionId] : []}
        />
      </div>
    </Modal>
  )
}

export default NotificationListModal

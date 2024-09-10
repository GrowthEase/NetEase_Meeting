import { ModalProps } from 'antd';
import React from 'react';
import { useTranslation } from 'react-i18next';

import EventEmitter from 'eventemitter3';
import NEMeetingService from '@meeting-module/services/NEMeeting';
import Modal from '@meeting-module/components/common/Modal';
import MeetingNotificationList from '@meeting-module/components/common/Notification/List';

import './index.less';
import { NEMeetingMessageChannelService } from 'nemeeting-web-sdk';

interface NotificationListModalProps extends ModalProps {
  neMeeting?: NEMeetingService;
  eventEmitter?: EventEmitter;
  sessionId?: string;
  onClick?: (action?: string) => void;
  meetingMessageChannelService?: NEMeetingMessageChannelService;
}

const NotificationListModal: React.FC<NotificationListModalProps> = ({
  neMeeting,
  sessionId,
  onClick,
  eventEmitter,
  meetingMessageChannelService,
  ...restProps
}) => {
  const { t } = useTranslation();

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
          meetingMessageChannelService={meetingMessageChannelService}
          onClick={onClick}
          sessionIds={sessionId ? [sessionId] : []}
        />
      </div>
    </Modal>
  );
};

export default NotificationListModal;

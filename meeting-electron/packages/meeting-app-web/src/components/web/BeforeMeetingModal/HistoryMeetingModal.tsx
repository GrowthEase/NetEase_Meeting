import React, { useEffect, useState } from 'react';

import { ModalProps } from 'antd';
import { NERoomService } from 'neroom-types';
import { useTranslation } from 'react-i18next';

import { EventType } from '@meeting-module//types';
import EventEmitter from 'eventemitter3';
import classNames from 'classnames';
import Modal from '@meeting-module/components/common/Modal';
import HistoryMeeting from './HistoryMeeting';
import { NEPreMeetingService } from 'nemeeting-web-sdk';
import NEMeetingService from '@meeting-module/services/NEMeeting';
import NEContactsService from '@meeting-module/kit/impl/service/meeting_contacts_service';

interface HistoryMeetingProps extends ModalProps {
  roomService?: NERoomService;
  accountId?: string;
  preMeetingService?: NEPreMeetingService;
  meetingId?: number;
  onBack?: () => void;
  eventEmitter: EventEmitter;
  neMeeting?: NEMeetingService;
  meetingContactsService?: NEContactsService;
}

const HistoryMeetingModal: React.FC<HistoryMeetingProps> = ({
  roomService,
  accountId,
  preMeetingService,
  eventEmitter,
  onCancel,
  neMeeting,
  meetingContactsService,
  ...restProps
}) => {
  const { t } = useTranslation();
  const [open, setOpen] = useState<boolean>();
  const [meetingId, setMeetingId] = useState<number | undefined>();
  const [pageMode, setPageMode] = useState<'list' | 'detail'>('list');

  useEffect(() => {
    setMeetingId(restProps.meetingId);
  }, [restProps.meetingId]);

  useEffect(() => {
    setOpen(restProps.open);
  }, [restProps.open]);

  // 监听页面模式变化事件
  useEffect(() => {
    eventEmitter.on(
      EventType.OnHistoryMeetingPageModeChanged,
      (mode: 'list' | 'detail') => {
        setPageMode(mode);
      },
    );
  }, []);

  return (
    <Modal
      title={<span className="modal-title">{t('historyMeeting')}</span>}
      width={375}
      maskClosable={false}
      footer={null}
      wrapClassName={classNames('history-meeting-modal', {
        'history-meeting-modal-detail-wrap': pageMode === 'detail',
      })}
      styles={{
        body: { padding: 0 },
      }}
      onCancel={(e) => {
        onCancel?.(e);
        eventEmitter.emit(EventType.OnHistoryMeetingPageModeChanged, 'list');
      }}
      {...restProps}
      open={open}
    >
      <HistoryMeeting
        open={restProps.open}
        roomService={roomService}
        accountId={accountId}
        meetingContactsService={meetingContactsService}
        preMeetingService={preMeetingService}
        meetingId={meetingId}
        eventEmitter={eventEmitter}
        neMeeting={neMeeting}
        onBack={() => {
          setMeetingId(undefined);
        }}
      />
    </Modal>
  );
};

export default HistoryMeetingModal;

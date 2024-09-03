import Modal from '@meeting-module/components/common/Modal';
import { ModalProps } from 'antd';
import React from 'react';
import { useTranslation } from 'react-i18next';
import Transcription from '.';
import NEPreMeetingService from '@meeting-module/kit/interface/service/pre_meeting_service';
import NEContactsService from '@meeting-module/kit/impl/service/meeting_contacts_service';

interface TranscriptionModalProps extends ModalProps {
  meetingId?: number;
  preMeetingService?: NEPreMeetingService;
  subject?: string;
  meetingContactsService?: NEContactsService;
}

const TranscriptionModal: React.FC<TranscriptionModalProps> = ({
  meetingContactsService,
  ...restProps
}) => {
  const { t } = useTranslation();

  return (
    <Modal
      title={t('transcription')}
      width={375}
      maskClosable={false}
      rootClassName="chatroom-modal-root"
      footer={null}
      destroyOnClose
      {...restProps}
    >
      <div className="nemeeting-app-transcription-content">
        <Transcription
          meetingId={restProps.meetingId}
          meetingContactsService={meetingContactsService}
          preMeetingService={restProps.preMeetingService}
          subject={restProps.subject}
        />
      </div>
    </Modal>
  );
};

export default TranscriptionModal;

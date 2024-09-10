import React from 'react';
import { useTranslation } from 'react-i18next';

import './index.less';
import Modal from '@meeting-module/components/common/Modal';
import FeedbackContent, { FeedbackProps } from './index';

const FeedbackModal: React.FC<FeedbackProps> = ({
  visible,
  onClose,
  meetingId,
  nickname,
  appKey,
  neMeeting,
  loadingChange,
  systemAndManufacturer,
  inMeeting,
}) => {
  const { t } = useTranslation();

  return (
    <Modal
      title={t('feedback')}
      open={visible}
      maskClosable={false}
      footer={null}
      width={375}
      wrapClassName="feedback-modal-wrap"
      onCancel={() => onClose?.()}
      destroyOnClose
    >
      <FeedbackContent
        visible={visible}
        onClose={onClose}
        meetingId={meetingId}
        nickname={nickname}
        appKey={appKey}
        neMeeting={neMeeting}
        loadingChange={loadingChange}
        systemAndManufacturer={systemAndManufacturer}
        inMeeting={inMeeting}
      ></FeedbackContent>
    </Modal>
  );
};

export default FeedbackModal;

import React from 'react';
import NPS from './NPS';

import { useTranslation } from 'react-i18next';
import './index.less';
import { Modal } from 'antd';

interface NPSProps {
  meetingId: string;
  appKey: string;
  nickname: string;
}

interface NPSModalProps extends NPSProps {
  visible: boolean;
  onClose: () => void;
}

const NPSModal: React.FC<NPSModalProps> = ({
  visible,
  onClose,
  meetingId,
  nickname,
  appKey,
}) => {
  const { t } = useTranslation();

  return (
    <>
      {!window.isElectronNative ? (
        <Modal
          title={t('npsTitle')}
          wrapClassName="nps-modal-wrap"
          open={visible}
          maskClosable={false}
          centered={true}
          width={601}
          footer={null}
          destroyOnClose={true}
          onCancel={() => onClose()}
        >
          {visible && (
            <NPS meetingId={meetingId} nickname={nickname} appKey={appKey} />
          )}
        </Modal>
      ) : null}
    </>
  );
};

export default NPSModal;

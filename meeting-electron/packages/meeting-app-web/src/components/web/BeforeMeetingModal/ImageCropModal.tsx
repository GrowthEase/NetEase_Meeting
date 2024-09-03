import React from 'react';

import { ModalProps } from 'antd';
import { useTranslation } from 'react-i18next';
import Modal from '@meeting-module/components/common/Modal';
import './index.less';

import ImageCrop from '@meeting-module/components/common/ImageCrop';
import NEMeetingAccountService from '@meeting-module/kit/interface/service/meeting_account_service';

interface ImageCropModalProps extends ModalProps {
  image: string;
  accountService?: NEMeetingAccountService;
  onUpdate?: () => void;
}

const ImageCropModal: React.FC<ImageCropModalProps> = ({
  accountService,
  image,
  ...restProps
}) => {
  const { t } = useTranslation();

  const i18n = {
    title: t('settingAvatarTitle'),
  };

  return (
    <Modal
      title={i18n.title}
      width={520}
      maskClosable={false}
      destroyOnClose
      getContainer={() => {
        const dom = document.getElementById('ne-web-meeting') as HTMLElement;

        if (dom && dom.style.display !== 'none') {
          return dom;
        }

        return document.body;
      }}
      footer={null}
      {...restProps}
    >
      <div className="before-meeting-modal-content">
        <ImageCrop
          image={image}
          accountService={accountService}
          onCancel={restProps.onCancel}
          onOk={restProps.onUpdate}
        />
      </div>
    </Modal>
  );
};

export default ImageCropModal;

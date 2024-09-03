import React from 'react';
import { Button, ModalProps } from 'antd';
import { useTranslation } from 'react-i18next';
import Modal from '@meeting-module/components/common/Modal';
import browserPng from '../../../../assets/browser.png';
import './index.less';

interface UnSupportBrowserModalProps extends ModalProps {
  onClose: () => void;
}

const UnSupportBrowserModal: React.FC<UnSupportBrowserModalProps> = ({
  ...restProps
}) => {
  const { t } = useTranslation();

  return (
    <>
      <Modal
        title={t('unSupportBrowserTitle')}
        width={634}
        maskClosable={false}
        centered={true}
        wrapClassName="un-support-browser-modal-wrap"
        footer={
          <Button
            onClick={restProps.onClose}
            className="un-support-browser-btn"
            type="primary"
          >
            {t('gotIt')}
          </Button>
        }
        destroyOnClose
        {...restProps}
      >
        <div className="un-support-browser-tip">{t('unSupportBrowserTip')}</div>
        <img className="browser-png" src={browserPng}></img>
      </Modal>
    </>
  );
};

export default UnSupportBrowserModal;

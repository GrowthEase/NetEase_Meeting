import React from 'react'
import { useTranslation } from 'react-i18next'
import Modal from '../Modal'
import FeedbackContent, { FeedbackProps } from './index'
import './index.less'

const FeedbackModal: React.FC<FeedbackProps> = ({ visible, onClose }) => {
  const { t } = useTranslation()

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
      <FeedbackContent visible={visible} onClose={onClose} />
    </Modal>
  )
}

export default FeedbackModal

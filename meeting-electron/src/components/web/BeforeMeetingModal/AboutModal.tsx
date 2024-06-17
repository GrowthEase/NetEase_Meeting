import React from 'react'
import { ModalProps } from 'antd'
import About from './About'
import { useTranslation } from 'react-i18next'

import Modal from '../../common/Modal'

import './index.less'

const AboutModal: React.FC<ModalProps> = ({ ...restProps }) => {
  const { t } = useTranslation()

  return (
    <Modal
      title={t('about')}
      width={375}
      wrapClassName="about-modal-wrap"
      maskClosable={false}
      footer={null}
      {...restProps}
    >
      <About />
    </Modal>
  )
}

export default AboutModal

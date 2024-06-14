import React from 'react'

import { ModalProps } from 'antd'
import { useTranslation } from 'react-i18next'
import Modal from '../../common/Modal'
import './index.less'

import NEMeetingService from '../../../services/NEMeeting'
import ImageCrop from '../../common/ImageCrop'

interface ImageCropModalProps extends ModalProps {
  image: string
  neMeeting?: NEMeetingService
  onUpdate?: (avatar: string) => void
}

const ImageCropModal: React.FC<ImageCropModalProps> = ({
  neMeeting,
  image,
  ...restProps
}) => {
  const { t } = useTranslation()

  const i18n = {
    title: t('settingAvatarTitle'),
  }

  return (
    <Modal
      title={i18n.title}
      width={520}
      maskClosable={false}
      destroyOnClose
      getContainer={() => {
        const dom = document.getElementById('ne-web-meeting') as HTMLElement

        if (dom && dom.style.display !== 'none') {
          return dom
        }

        return document.body
      }}
      footer={null}
      {...restProps}
    >
      <div className="before-meeting-modal-content">
        <ImageCrop
          image={image}
          neMeeting={neMeeting}
          onCancel={restProps.onCancel}
          onOk={restProps.onUpdate}
        />
      </div>
    </Modal>
  )
}

export default ImageCropModal

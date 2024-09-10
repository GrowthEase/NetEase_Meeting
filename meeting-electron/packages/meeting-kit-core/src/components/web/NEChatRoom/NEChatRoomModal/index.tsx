import { ModalProps } from 'antd'
import React from 'react'
import { useTranslation } from 'react-i18next'

import Modal from '../../../common/Modal'
import ChatRoom, { ChatRoomProps } from '..'

import './index.less'

const ChatRoomModal: React.FC<ModalProps & ChatRoomProps> = ({
  meetingId,
  ...restProps
}) => {
  const { t } = useTranslation()

  return (
    <Modal
      title={t('chat')}
      width={375}
      maskClosable={false}
      rootClassName="nemeeting-chat-room-modal-root"
      footer={null}
      destroyOnClose
      {...restProps}
    >
      <div className="nemeeting-chat-room-modal-content">
        <ChatRoom meetingId={meetingId} />
      </div>
    </Modal>
  )
}

export default ChatRoomModal

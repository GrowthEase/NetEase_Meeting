import React from 'react'
import { ModalProps } from 'antd'
import Chatroom from '../Chatroom/Chatroom'
import Modal from '../../common/Modal'
import { NERoomService } from 'neroom-web-sdk'
import { useTranslation } from 'react-i18next'

import './index.less'

interface ChatroomModalProps extends ModalProps {
  roomArchiveId?: string
  roomService?: NERoomService
  accountId?: string
  subject?: string
  startTime?: number
}

const ChatroomModal: React.FC<ChatroomModalProps> = ({
  roomArchiveId,
  roomService,
  accountId,
  subject,
  startTime,
  ...restProps
}) => {
  const { t } = useTranslation()
  const i18n = {
    title: t('chatHistory'),
  }

  return (
    <Modal
      title={i18n.title}
      width={375}
      maskClosable={false}
      rootClassName="chatroom-modal-root"
      footer={null}
      destroyOnClose
      {...restProps}
    >
      {!!roomArchiveId && roomService && (
        <div className="chatroom-content">
          <Chatroom
            roomArchiveId={roomArchiveId}
            roomService={roomService}
            visible={!!roomArchiveId}
            subject={subject}
            startTime={startTime}
            accountId={accountId}
            isViewHistory
          />
        </div>
      )}
    </Modal>
  )
}

export default ChatroomModal

import { ModalProps } from 'antd'
import React from 'react'
import Modal from '../../Modal'
import MeetingPlugin, { MeetingPluginProps } from '../MeetingPlugin'

import './index.less'

interface PluginAppModalProps extends MeetingPluginProps, ModalProps {
  name: string
}

const PluginAppModal: React.FC<PluginAppModalProps> = ({
  name,
  url,
  pluginId,
  isInMeeting,
  roomArchiveId,
  ...restProps
}) => {
  return (
    <Modal
      title={name}
      width={375}
      maskClosable={false}
      rootClassName="nemeeting-plugin-app-modal-root"
      footer={null}
      destroyOnClose
      {...restProps}
    >
      {!!url && (
        <div className="nemeeting-plugin-app-modal-content">
          <MeetingPlugin
            isInMeeting={isInMeeting}
            url={url}
            roomArchiveId={roomArchiveId}
            pluginId={pluginId}
          />
        </div>
      )}
    </Modal>
  )
}

export default PluginAppModal

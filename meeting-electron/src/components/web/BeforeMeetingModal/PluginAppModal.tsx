import { ModalProps } from 'antd'
import React from 'react'
import Modal from '../../common/Modal'

import './index.less'
import MeetingPlugin from '../../common/PlugIn/MeetingPlugin'

interface PluginAppModalProps extends ModalProps {
  pluginInfo: any
  neMeeting: any
}

const PluginAppModal: React.FC<PluginAppModalProps> = ({
  pluginInfo,
  ...restProps
}) => {
  return (
    <Modal
      title={pluginInfo?.name}
      width={375}
      maskClosable={false}
      rootClassName="chatroom-modal-root"
      footer={null}
      destroyOnClose
      {...restProps}
    >
      {!!pluginInfo && (
        <div className="chatroom-content">
          <MeetingPlugin
            isInMeeting={false}
            url={pluginInfo.homeUrl}
            roomArchiveId={pluginInfo.roomArchiveId}
            pluginId={pluginInfo.pluginId}
            neMeeting={restProps.neMeeting}
          />
        </div>
      )}
    </Modal>
  )
}

export default PluginAppModal

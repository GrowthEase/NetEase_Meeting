import React from 'react'
import '@xkit-yx/kit-chatroom-web/es/Chatroom/style/index.css'
import { useTranslation } from 'react-i18next'
import './index.less'
import { Drawer, DrawerProps } from 'antd'
import Chatroom from './Chatroom'
import { useMeetingInfoContext } from '../../../store'

const ChatroomWrap: React.FC<DrawerProps> = (props) => {
  const { t } = useTranslation()
  const { meetingInfo } = useMeetingInfoContext()

  return (
    <Drawer
      title={t('chatRoomTitle')}
      maskStyle={{ opacity: 0 }}
      bodyStyle={{ padding: 0 }}
      rootClassName={`nemeeting-chatroom-drawer ${
        window.ipcRenderer ? 'nemeeting-chatroom-drawer-ele' : ''
      }`}
      width={props.width}
      mask={false}
      maskClosable={false}
      keyboard={false}
      closable={!meetingInfo.isRooms}
      forceRender
      {...props}
    >
      <Chatroom visible={!!props.open} />
    </Drawer>
  )
}

export default React.memo(ChatroomWrap)

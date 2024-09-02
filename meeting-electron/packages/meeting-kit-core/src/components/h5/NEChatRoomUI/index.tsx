import React from 'react'
import { NERoomChatMessage } from '../../../types'
import MessageItem from './MessageItem'

interface NEChatRoomUIProps {
  msgs: NERoomChatMessage[]
  longPressMsg?: NERoomChatMessage
  onRevokeMsg?: (msg: NERoomChatMessage) => void
  onResendMsg?: (msg: NERoomChatMessage) => void
  onAvatarClick?: (msg: NERoomChatMessage) => void
  onLongPress?: (msg?: NERoomChatMessage) => void
}

const NEChatRoomUI: React.FC<NEChatRoomUIProps> = ({
  msgs,
  longPressMsg,
  onRevokeMsg,
  onResendMsg,
  onAvatarClick,
  onLongPress,
}) => {
  return (
    <div className="ne-chatroom-ui">
      {msgs &&
        msgs.map((msg: NERoomChatMessage) => (
          <MessageItem
            key={msg.idClient}
            msg={msg}
            contentDropdown={msg.idClient === longPressMsg?.idClient}
            onResendMsg={onResendMsg}
            onRevokeMsg={onRevokeMsg}
            onAvatarClick={onAvatarClick}
            onLongPress={onLongPress}
          />
        ))}
    </div>
  )
}

export default NEChatRoomUI

import React from 'react'
import dayjs from 'dayjs'
import { NERoomChatMessage } from '../../../types'
import MessageItem from './MessageItem'

import './index.less'

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
        msgs.map((msg: NERoomChatMessage, index) => {
          let time = 0

          if (index === 0) {
            time = msg.time
          } else {
            const prevItem = msgs[index - 1]

            if (msg.time - prevItem.time > 60 * 1000) {
              time = msg.time
            }
          }

          return (
            <>
              {time > 0 ? (
                <div className="nemeeting-chatroom-content-time">
                  {dayjs(time).isSame(dayjs(), 'D')
                    ? dayjs(time).format('HH:mm')
                    : dayjs(time).format('YYYY-MM-DD HH:mm')}
                </div>
              ) : null}
              <MessageItem
                key={msg.idClient}
                msg={msg}
                contentDropdown={msg.idClient === longPressMsg?.idClient}
                onResendMsg={onResendMsg}
                onRevokeMsg={onRevokeMsg}
                onAvatarClick={onAvatarClick}
                onLongPress={onLongPress}
              />
            </>
          )
        })}
    </div>
  )
}

export default NEChatRoomUI

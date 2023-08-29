/* eslint-disable prettier/prettier */
import './index.less'
import React, { useState } from 'react'
import Dialog from '../ui/dialog'
import { NERoomChatMessage } from '../../../types'
interface NEChatRoomUIProps {
  msgs: NERoomChatMessage[]
  resendMsg: () => void
}

const NEChatRoomUI: React.FC<NEChatRoomUIProps> = ({ msgs, resendMsg }) => {
  const [showDialog, setShowDialog] = useState(false)

  function resendTextMsg() {
    resendMsg?.()
    setShowDialog(false)
  }

  return (
    <div className="ne-chatroom-ui">
      <Dialog
        visible={showDialog}
        title=""
        onCancel={() => {
          setShowDialog(false)
        }}
        onConfirm={resendTextMsg}
      >
        确认重发此条消息？
      </Dialog>
      {msgs &&
        msgs.map((msg: NERoomChatMessage, index: number) => (
          <div key={index}>
            {msg?.isMe ? (
              <div className="msg-wrap msg-wrap-self">
                <div className="msg-info msg-info-self">
                  <span className="nickname">{msg.fromNick}</span>
                  <span className="date">{msg.time}</span>
                </div>
                <div className="msg-content-wrap msg-content-self">
                  {msg.type === 'text' ? (
                    <div className="msg-item">
                      {msg.status === 'fail' ? (
                        <i
                          onClick={() => {
                            setShowDialog(true)
                          }}
                          className="iconfont iconSubtract icon-red mr10"
                        ></i>
                      ) : (
                        ''
                      )}
                      <span className="msg-text msg-text-self">{msg.text}</span>
                    </div>
                  ) : (
                    <span className="msg-text msg-text-self msg-text-error">
                      暂不支持该消息类型
                    </span>
                  )}
                </div>
              </div>
            ) : (
              <div className="msg-wrap msg-wrap-other">
                <div className="msg-info msg-info-other">
                  <span className="nickname">{msg.fromNick}</span>
                  <span className="date">{msg.time}</span>
                </div>
                <div className="msg-content-wrap msg-content-other">
                  {msg.type === 'text' ? (
                    <span className="msg-text msg-text-other">{msg.text}</span>
                  ) : (
                    <span className="msg-text msg-text-other msg-text-error">
                      暂不支持该消息类型
                    </span>
                  )}
                </div>
              </div>
            )}
          </div>
        ))}
    </div>
  )
}

export default NEChatRoomUI

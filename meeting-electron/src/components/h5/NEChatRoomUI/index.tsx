/* eslint-disable prettier/prettier */
import './index.less'
import React, { useState } from 'react'
import Dialog from '../ui/dialog'
import { Image, ImageViewer } from 'antd-mobile'
import { NERoomChatMessage } from '../../../types'
interface NEChatRoomUIProps {
  msgs: NERoomChatMessage[]
  resendMsg: () => void
}

const NEChatRoomUI: React.FC<NEChatRoomUIProps> = ({ msgs, resendMsg }) => {
  const [showDialog, setShowDialog] = useState(false)
  const [imageViewerVisibleId, setImageViewerVisibleId] = useState('')

  const addUrlSearch = (url?: string, search?: string): string => {
    if (!url || !search) {
      return url || ''
    }
    const urlObj = new URL(url)
    urlObj.search += (urlObj.search.startsWith('?') ? '&' : '?') + search
    return urlObj.href
  }

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
                <div
                  className={`msg-content-wrap msg-content-other ${
                    msg.type === 'image' ? 'msg-content-wrap-img' : ''
                  }`}
                >
                  {msg.type === 'text' ? (
                    <span className="msg-text msg-text-other">{msg.text}</span>
                  ) : msg.type === 'image' ? (
                    <>
                      <div>
                        <Image
                          className="msg-image"
                          src={addUrlSearch(
                            msg.attach?.url,
                            'download=' + msg.attach?.name
                          )}
                          fit="contain"
                          onClick={() =>
                            setImageViewerVisibleId(msg.idClient || '')
                          }
                        />
                        <ImageViewer
                          image={addUrlSearch(
                            msg.attach?.url,
                            'download=' + msg.attach?.name
                          )}
                          visible={imageViewerVisibleId === msg.idClient}
                          onClose={() => setImageViewerVisibleId('')}
                        />
                      </div>
                    </>
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

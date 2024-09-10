import React, { useEffect, useState, useMemo } from 'react'
import { useTranslation } from 'react-i18next'
import './index.less'
import { useChatRoomContext } from '../../../../hooks/useChatRoom'
import { ActionType, NERoomChatMessage } from '../../../../kit'
import reactStringReplace from 'react-string-replace'
import Emoji from '../../Emoji'
import { IPCEvent } from '../../../../app/src/types'
import { useMeetingInfoContext } from '../../../../store'

type BulletScreenMessageItemProps = {
  message: NERoomChatMessage
}

const BulletScreenMessageItem: React.FC<BulletScreenMessageItemProps> = (
  props
) => {
  const { t } = useTranslation()
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const { message } = props
  const [countdown, setCountdown] = useState(0)

  let content = ''

  if (message.type === 'text') {
    content = message.text
  } else if (message.type === 'image') {
    content = t('imageMsg')
  } else if (message.type === 'file') {
    content = t('fileMsg')
  }

  let nickname = message.fromNick

  if (message.chatroomType === 1) {
    if (message.isMe) {
      nickname = t('chatISaidToWaitingRoom')
    } else {
      nickname = t('chatSaidToWaitingRoom', { userName: message.fromNick })
    }
  }

  if (message.isPrivate) {
    if (message.chatroomType === 1) {
      nickname = `(${t('chatPrivateInWaitingRoom')})`
    } else {
      nickname = `(${t('chatPrivate')})`
    }

    if (message.isMe) {
      nickname = nickname + t('chatISaidTo', { userName: message.toNickname })
    } else {
      nickname = nickname + t('chatSaidToMe', { userName: message.fromNick })
    }
  }

  const style = useMemo(() => {
    if (countdown >= 4) {
      return {
        opacity: 1,
      }
    } else {
      return {
        opacity: countdown > 0 ? countdown / 4 : 0,
      }
    }
  }, [countdown])

  useEffect(() => {
    function countdownTimer() {
      const nowTime = new Date().getTime()
      const time = (nowTime - message.time) / 1000

      const countdown = 8 - time

      setCountdown(8 - time)

      if (countdown < -1) {
        clearInterval(timer)
      }
    }

    const timer = setInterval(countdownTimer, 100)

    return () => {
      clearInterval(timer)
    }
  }, [message.idClient])

  return countdown < -1 ? null : (
    <div
      className="nemeeting-bullet-screen-message-item-wrapper"
      key={message.idClient}
      style={style}
    >
      <div
        className="nemeeting-bullet-screen-message-item"
        onMouseMove={(event) => {
          event.stopPropagation()
        }}
        onClick={(event) => {
          if (meetingInfo.rightDrawerTabActiveKey !== 'chatroom') {
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                rightDrawerTabActiveKey: 'chatroom',
                unReadChatroomMsgCount: 0,
              },
            })
          }

          event.stopPropagation()
        }}
        onWheel={(event) => {
          event.stopPropagation()
        }}
        onMouseEnter={() => {
          window.isChildWindow &&
            window.ipcRenderer?.send(IPCEvent.IgnoreMouseEvents, false)
        }}
        onMouseLeave={() => {
          window.isChildWindow &&
            window.ipcRenderer?.send(IPCEvent.IgnoreMouseEvents, true)
        }}
      >
        <span className="nemeeting-bullet-screen-message-item-box">
          <span className="nemeeting-bullet-screen-message-item-nickname">
            {nickname}：
          </span>
          {reactStringReplace(content, /(\[.*?\])/gi, (match, i) => {
            return <Emoji key={i} emojiKey={match} size={20} />
          })}
        </span>
      </div>
    </div>
  )
}

const BulletScreenMessageList: React.FC = () => {
  const { messages } = useChatRoomContext()

  const messageList = messages
    .filter((item) => ['text', 'image', 'file'].includes(item.type))
    .slice(-10)
    .reverse()
    .map((message) => {
      return (
        <BulletScreenMessageItem message={message} key={message.idClient} />
      )
    })

  return (
    <div className="nemeeting-bullet-screen-message-list">{messageList}</div>
  )
}

export default BulletScreenMessageList

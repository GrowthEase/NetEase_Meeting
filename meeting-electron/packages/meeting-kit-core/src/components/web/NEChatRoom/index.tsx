import React from 'react'
import ChatCardList from './component/ChatCardList'
import ChatTools from './component/ChatTools'
import './index.less'

export type ChatRoomProps = {
  meetingId?: number
}

const ChatRoom: React.FC<ChatRoomProps> = (props) => {
  const { meetingId } = props

  return (
    <div
      className="nemeeting-chatroom-wrapper"
      id="nemeeting-chatroom-wrapper-dom"
    >
      <ChatCardList meetingId={meetingId} />
      <ChatTools meetingId={meetingId} />
    </div>
  )
}

export default ChatRoom

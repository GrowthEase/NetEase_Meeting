import React, { useState } from 'react'
import { Popover } from 'antd'

import './index.less'
import EmojiItem, { emojiMap } from '../../../../common/Emoji'
import { useTranslation } from 'react-i18next'

type ChatEmojiPopoverProps = {
  disabled?: boolean
  children: React.ReactNode
  onClick: (emojiKey: string) => void
}

const ChatEmojiPopover: React.FC<ChatEmojiPopoverProps> = (props) => {
  const { i18n } = useTranslation()
  const { onClick, disabled } = props
  const [emojiPopoverOpen, setEmojiPopoverOpen] = useState(false)

  function renderContent() {
    const emojiKeys = Object.keys(emojiMap)

    return (
      <div className="nemeeting-chat-emoji-wrapper">
        {emojiKeys.map((emojiKey) => {
          return (
            <EmojiItem
              language={i18n.language.split('-')[0]}
              key={emojiKey}
              emojiKey={emojiKey}
              onClick={(emojiKey) => {
                setEmojiPopoverOpen(false)
                onClick(emojiKey)
              }}
            />
          )
        })}
      </div>
    )
  }

  return (
    <Popover
      trigger={['click']}
      placement="top"
      overlayClassName="nemeeting-chat-emoji-popover"
      content={renderContent()}
      arrow={false}
      open={!disabled && emojiPopoverOpen}
      onOpenChange={(open) => {
        setEmojiPopoverOpen(open)
      }}
      getPopupContainer={() =>
        document.getElementById(
          'nemeeting-chatroom-wrapper-dom'
        ) as HTMLDivElement
      }
    >
      {props.children}
    </Popover>
  )
}

export default ChatEmojiPopover

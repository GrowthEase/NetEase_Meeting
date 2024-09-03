import React, { useEffect, useState } from 'react'
import EmojiItem, { emojiMap } from '../../../common/Emoji'
import { useTranslation } from 'react-i18next'
import './index.less'

type ChatEmojiContentProps = {
  onClick: (emojiKey: string) => void
  inputDom: HTMLInputElement | null
  onSendTextMsg: () => void
}

const ChatEmojiContent: React.FC<ChatEmojiContentProps> = (props) => {
  const { onClick, inputDom } = props
  const { t } = useTranslation()
  const [sendDisabled, setSendDisabled] = useState(true)

  const emojiKeys = Object.keys(emojiMap)

  const onDeleteMsg = () => {
    function getLastNodeWithValue() {
      if (props.inputDom) {
        const nodes = Array.from(props.inputDom.childNodes) as HTMLElement[]
        const length = nodes.length

        for (let i = length - 1; i >= 0; i--) {
          if (nodes[i].nodeType === 3 && nodes[i].nodeValue) {
            return nodes[i]
          } else if (nodes[i].nodeName === 'IMG') {
            return nodes[i]
          }
        }
      }
    }

    const lastNode = getLastNodeWithValue()

    if (lastNode) {
      if (lastNode?.nodeType === 3 && lastNode.nodeValue) {
        props.inputDom?.removeChild(lastNode)
        lastNode.nodeValue = lastNode.nodeValue.substring(
          0,
          lastNode.nodeValue.length - 1
        )
        props.inputDom?.appendChild(lastNode)
      } else if (lastNode.nodeName === 'IMG') {
        props.inputDom?.removeChild(lastNode)
      }
    }

    getInputDomContent()
  }

  const getInputDomContent = () => {
    if (!inputDom) {
      return
    }

    const nodes = Array.from(inputDom.childNodes) as HTMLImageElement[]

    let msgStr = ''

    // 需要根据图片节点拆分消息发送
    nodes.forEach((node) => {
      // 文本节点
      if (node.nodeType === 3) {
        msgStr += node.nodeValue
      } else if (node.nodeName === 'IMG') {
        const emojiText = node.getAttribute('data-emoji')

        if (emojiText) {
          msgStr += emojiText
        }
      } else if (node.innerText) {
        // 其他节点
        msgStr += node.innerText
      }
    })

    if (!(msgStr && msgStr.trim())) {
      setSendDisabled(true)
    } else {
      setSendDisabled(false)
    }
  }

  useEffect(() => {
    getInputDomContent()
  }, [])

  return (
    <div className="chat-input-emoji-content">
      {emojiKeys.map((emojiKey) => {
        return (
          <div className="chat-input-emoji-item-wrapper" key={emojiKey}>
            <EmojiItem
              size={30}
              emojiKey={emojiKey}
              onClick={(emojiKey) => {
                onClick?.(emojiKey)
                getInputDomContent()
              }}
            />
          </div>
        )
      })}
      <div className="chat-input-emoji-content-buttons">
        <div
          className="chat-input-emoji-content-button-delete"
          onClick={onDeleteMsg}
        >
          <svg className="icon iconfont" aria-hidden="true">
            <use xlinkHref="#iconshanchu"></use>
          </svg>
        </div>
        <div
          className={`chat-input-emoji-content-button-send ${
            sendDisabled
              ? 'chat-input-emoji-content-button-send-disabled'
              : undefined
          }`}
          onClick={() => !sendDisabled && props.onSendTextMsg()}
        >
          {t('send')}
        </div>
      </div>
    </div>
  )
}

export default ChatEmojiContent

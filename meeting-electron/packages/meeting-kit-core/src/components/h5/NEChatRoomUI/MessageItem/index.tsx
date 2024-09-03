import { LoadingOutlined } from '@ant-design/icons'
import { useLongPress, useUpdateEffect } from 'ahooks'
import { Dropdown, MenuProps, Spin } from 'antd'
import { Image, ImageViewer } from 'antd-mobile/es'

import React, { useEffect, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { NERoomChatMessage } from '../../../../types'
import {
  copyElementValue,
  downloadFile,
  parseFileSize,
} from '../../../../utils'
import UserAvatar from '../../../common/Avatar'
import Modal from '../../../common/Modal'
import Toast from '../../../common/toast'
import getCls from './css'
import Emoji from '../../../common/Emoji'
import reactStringReplace from 'react-string-replace'

function getFileIcon(ext: string) {
  const fileIconMap = {
    pdf: 'iconPDF',
    word: 'iconWord',
    excel: 'iconExcel',
    ppt: 'iconPPT',
    zip: 'iconRAR',
    txt: 'iconwenjian',
    image: 'icontupian2',
    audio: 'iconyinle',
    video: 'iconshipin',
    unknown: 'iconweishibiewenjian',
  }
  const regMap: { [key: string]: RegExp } = {
    pdf: /pdf$/i,
    word: /(doc|docx)$/i,
    excel: /(xls|xlsx)$/i,
    ppt: /(ppt|pptx)$/i,
    txt: /(txt|html)$/i,
    image: /(png|jpg|jpeg|bmp)$/i,
    audio: /(mp3|aac|pcm|wav)$/i,
    video: /(mov|mp4|flv)$/i,
    zip: /(rar|zip|7z|gz|tar|biz)$/i,
  }
  const key =
    Object.keys(regMap).find((key) => regMap[key].test(ext)) || 'unknown'

  return fileIconMap[key]
}

interface MessageItemProps {
  msg: NERoomChatMessage
  contentDropdown?: boolean
  onResendMsg?: (msg: NERoomChatMessage) => void
  onRevokeMsg?: (msg: NERoomChatMessage) => void
  onAvatarClick?: (msg: NERoomChatMessage) => void
  onLongPress?: (msg?: NERoomChatMessage) => void
}

const MessageItem: React.FC<MessageItemProps> = ({
  msg,
  contentDropdown,
  onResendMsg,
  onRevokeMsg,
  onAvatarClick,
  onLongPress,
}) => {
  const {
    messageItemWrapperCls,
    messageItemCls,
    nickLabelCls,
    nickTextCls,
    nickPrivateCls,
    messageItemContentCls,
    textCls,
    imageWrapperCls,
    fileWrapperCls,
    notificationCls,
  } = getCls(msg.isMe || false)

  const { t } = useTranslation()
  const domRef = useRef<HTMLDivElement>(null)
  const [imageViewerVisible, setImageViewerVisible] = useState(false)
  const [dropdownTrigger, setDropdownTrigger] = useState<
    ('click' | 'hover' | 'contextMenu')[]
  >([])

  useLongPress(
    () => {
      if (!imageViewerVisible) {
        onLongPress?.(msg)
      }
    },
    domRef,
    {
      delay: 300,
      onLongPressEnd: () => {
        setTimeout(() => {
          setDropdownTrigger(['click'])
        })
      },
    }
  )

  useEffect(() => {
    if (!contentDropdown) {
      setDropdownTrigger([])
    }
  }, [contentDropdown])

  const addUrlSearch = (url?: string, search?: string): string => {
    if (!url || !search) {
      return url || ''
    }

    if (url.startsWith('blob:')) return url
    const urlObj = new URL(url)

    urlObj.search += (urlObj.search.startsWith('?') ? '&' : '?') + search
    return urlObj.href
  }

  const contentDropdownItems: MenuProps['items'] = [
    {
      key: 'revoke',
      label: <span style={{ width: 100 }}>{t('chatRecall')}</span>,
      onClick: () => {
        onRevokeMsg?.(msg)
      },
      disabled: !(msg.status === 'success' && msg.isMe),
    },
    {
      key: 'copy',
      label: t('globalCopy'),
      disabled: msg.type !== 'text',
      onClick: () => {
        copyElementValue(msg.text, () => {
          Toast.success(t('copySuccess'))
        })
      },
    },
  ].filter((item) => !item.disabled)

  function renderNickLabel() {
    const { isMe, fromNick, toNickname } = msg
    const isWaitingRoom = msg.chatroomType === 1
    let isPrivate = false

    if (msg.custom) {
      try {
        const custom = JSON.parse(msg.custom)

        isPrivate = custom.toAccounts?.length > 0
      } catch (error) {
        console.error('parse custom error', error)
      }
    }

    if (isWaitingRoom) {
      // 等候室私聊
      if (isPrivate) {
        return (
          <div className={nickLabelCls}>
            <div className={nickTextCls}>
              {isMe
                ? t('chatISaidTo', { userName: toNickname })
                : t('chatSaidToMe', { userName: fromNick })}
            </div>
            <div className={nickPrivateCls}>
              ({`${t('chatPrivateInWaitingRoom')}`})
            </div>
          </div>
        )
      } else {
        return (
          <div className={nickLabelCls}>
            <div className={nickTextCls}>
              {isMe
                ? t('chatISaidToWaitingRoom')
                : t('chatSaidToWaitingRoom', { userName: fromNick })}
            </div>
          </div>
        )
      }
    } else {
      if (isPrivate) {
        return (
          <div className={nickLabelCls}>
            <div className={nickTextCls}>
              {isMe
                ? t('chatISaidTo', { userName: toNickname })
                : t('chatSaidToMe', { userName: fromNick })}
            </div>
            <div className={nickPrivateCls}>({`${t('chatPrivate')}`})</div>
          </div>
        )
      } else {
        return (
          <div className={nickLabelCls}>
            <div className={nickTextCls}>{msg.fromNick}</div>
          </div>
        )
      }
    }
  }

  function renderTextMessage() {
    return (
      <div className={textCls}>
        {reactStringReplace(msg.text, /(\[.*?\])/gi, (match, i) => {
          return <Emoji key={i} emojiKey={match} size={20} />
        })}
      </div>
    )
  }

  function renderImageMessage() {
    const file = msg.file

    if (file) {
      return (
        <div className={imageWrapperCls}>
          {msg.status === 'failed' && (
            <svg
              className="icon iconfont error-icon"
              aria-hidden="true"
              onClick={() => onResendMsg?.(msg)}
            >
              <use xlinkHref="#iconfengxiantishi"></use>
            </svg>
          )}
          <Spin
            spinning={msg.status === 'sending'}
            indicator={<LoadingOutlined style={{ fontSize: 24 }} spin />}
          >
            <Image
              src={addUrlSearch(file.url, 'download=' + file.name)}
              fit="contain"
              onClick={() => {
                if (contentDropdown) return
                setImageViewerVisible(true)
              }}
            />
          </Spin>
          <ImageViewer
            image={addUrlSearch(file.url, 'download=' + file.name)}
            visible={imageViewerVisible}
            onClose={() => setImageViewerVisible(false)}
          />
        </div>
      )
    }

    return null
  }

  function renderFileMessage() {
    const file = msg.file

    if (file) {
      const fileExt = '.' + file.ext

      return (
        <div className={fileWrapperCls}>
          {msg.status === 'failed' && (
            <svg
              className="icon iconfont error-icon"
              aria-hidden="true"
              onClick={() => onResendMsg?.(msg)}
            >
              <use xlinkHref="#iconfengxiantishi"></use>
            </svg>
          )}
          <div
            className="file-box"
            onClick={() => {
              const url = addUrlSearch(file.url, 'download=' + file.name)

              downloadFile(url)
            }}
          >
            <Spin
              spinning={msg.status === 'sending'}
              indicator={<LoadingOutlined style={{ fontSize: 24 }} spin />}
            >
              <svg className="icon iconfont file-icon" aria-hidden="true">
                <use xlinkHref={`#${getFileIcon(file.ext)}`}></use>
              </svg>
            </Spin>
            <div className="file-content">
              <div className="file-name-label">
                <div className="file-name-text">
                  {file.name.replace(fileExt, '')}
                </div>
                <div className="file-name-ext">{fileExt}</div>
              </div>
              <div className="file-size">
                {file?.size && parseFileSize(file.size)}
              </div>
            </div>
          </div>
        </div>
      )
    }

    return null
  }

  function renderNotificationMessage() {
    let content = ''

    if (msg.attach?.type === 'deleteChatroomMsg') {
      content =
        (msg.isMe ? t('chatYou') : msg.fromNick) + t('chatRecallAMessage')
    }

    return <div className={notificationCls}>{content}</div>
  }

  function renderMessageContent() {
    switch (msg.type) {
      case 'text':
        return renderTextMessage()
      case 'image':
        return renderImageMessage()
      case 'file':
        return renderFileMessage()
      default:
        return null
    }
  }

  useUpdateEffect(() => {
    if (
      msg.type === 'notification' &&
      msg.attach?.type === 'deleteChatroomMsg' &&
      imageViewerVisible
    ) {
      Modal.warning({
        title: t('messageRecalled'),
        width: 200,
        okText: t('globalSure'),
      })
    }
  }, [msg.type])

  return msg.type === 'notification' ? (
    renderNotificationMessage()
  ) : (
    <div className={messageItemWrapperCls}>
      <UserAvatar
        size={24}
        nickname={msg.fromNick}
        avatar={msg.fromAvatar}
        onClick={() => onAvatarClick?.(msg)}
      />
      <div className={messageItemCls}>
        {renderNickLabel()}
        <div
          className={messageItemContentCls}
          ref={domRef}
          onContextMenuCapture={(e) => {
            if (!imageViewerVisible) {
              e.preventDefault()
            }
          }}
        >
          <Dropdown
            menu={{ items: contentDropdownItems }}
            open={contentDropdown && contentDropdownItems.length > 0}
            onOpenChange={() => {
              onLongPress?.()
            }}
            trigger={dropdownTrigger}
            placement="bottomRight"
          >
            <div />
          </Dropdown>
          {renderMessageContent()}
        </div>
      </div>
    </div>
  )
}

export default MessageItem

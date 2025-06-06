import React, { useEffect, useRef, useState } from 'react'
import dayjs from 'dayjs'
import { NERoomChatMessage } from '../../../types'
import MessageItem from './MessageItem'
import {
  AutoSizer,
  CellMeasurer,
  CellMeasurerCache,
  List,
} from 'react-virtualized'

const cache = new CellMeasurerCache({
  fixedWidth: true,
  minHeight: 84,
})

import './index.less'
import { useTranslation } from 'react-i18next'
import { useUpdateEffect } from 'ahooks'

interface NEChatRoomUIProps {
  msgs: NERoomChatMessage[]
  longPressMsg?: NERoomChatMessage
  onRevokeMsg?: (msg: NERoomChatMessage) => void
  onResendMsg?: (msg: NERoomChatMessage) => void
  onAvatarClick?: (msg: NERoomChatMessage) => void
  onLongPress?: (msg?: NERoomChatMessage) => void
  visible?: boolean
}

const NEChatRoomUI: React.FC<NEChatRoomUIProps> = ({
  msgs,
  longPressMsg,
  onRevokeMsg,
  onResendMsg,
  onAvatarClick,
  onLongPress,
  visible,
}) => {
  const [scrollToIndex, setScrollToIndex] = useState(-1)
  const [virtualListHeight, setVirtualListHeight] = useState<number>()
  const [showToBottom, setShowToBottom] = useState(false)
  const isScrolledToBottomRef = useRef(true)
  const contentWrapperRef = useRef<HTMLDivElement>(null)
  const { t } = useTranslation()

  const handleRowsRendered = ({ startIndex, stopIndex }) => {
    for (let i = startIndex; i <= stopIndex; i++) {
      cache.clear(i, 0)
    }
  }

  const rowRenderer = ({ index, key, parent, style }) => {
    const msg = msgs[index]

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
      <CellMeasurer
        cache={cache}
        columnIndex={0}
        key={key}
        rowIndex={index}
        parent={parent}
      >
        {({ registerChild }) => (
          <div
            ref={registerChild}
            style={style}
            className="ne-h5-virtual-item"
            id={msg.idClient}
          >
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
          </div>
        )}
      </CellMeasurer>
    )
  }

  function scrollToBottom() {
    setTimeout(() => {
      setScrollToIndex(msgs.length - 1)
    })
  }

  /**
   * 虚拟列表滚动处理，滚动到顶部时触发加载更多
   */
  const handleScroll = ({ clientHeight, scrollHeight, scrollTop }) => {
    if (
      clientHeight !== undefined &&
      scrollHeight !== undefined &&
      scrollTop !== undefined
    ) {
      const isScrolledToBottom = scrollHeight - clientHeight <= scrollTop + 10

      isScrolledToBottomRef.current = isScrolledToBottom
      if (isScrolledToBottom) {
        setShowToBottom(false)
      } else {
        setScrollToIndex(-1)
      }
    }
  }

  useUpdateEffect(() => {
    visible && scrollToBottom()
  }, [visible])

  useEffect(() => {
    // 设置高度
    if (contentWrapperRef.current?.clientHeight) {
      setVirtualListHeight(contentWrapperRef.current?.clientHeight)
    }
  }, [])

  useEffect(() => {
    // 设置高度
    if (contentWrapperRef.current?.clientHeight) {
      setVirtualListHeight(contentWrapperRef.current?.clientHeight)
    }

    const latestMessage = msgs[msgs.length - 1]

    // 如果在底部则不显示新消息按钮
    if (isScrolledToBottomRef.current || latestMessage?.isMe) {
      setTimeout(
        () => {
          scrollToBottom()
        },
        latestMessage?.type === 'image' ? 200 : 0
      )
    } else {
      // 如果是自己发送的消息则不显示新消息按钮
      if (msgs.length > 0) {
        if (!latestMessage.isMe) {
          setShowToBottom(true)
        }
      }
    }
  }, [msgs?.[msgs.length - 1]?.idClient])

  return (
    <div className="ne-chatroom-ui" ref={contentWrapperRef}>
      {visible && showToBottom && (
        <div className="ne-chatroom-to-bottom" onClick={() => scrollToBottom()}>
          ↓ {t('newMessage')}
        </div>
      )}
      <AutoSizer>
        {({ width }) => (
          <List
            width={width}
            height={
              virtualListHeight ?? contentWrapperRef.current?.clientHeight
            }
            scrollToAlignment="end"
            rowCount={msgs.length}
            rowHeight={cache.rowHeight}
            scrollToIndex={scrollToIndex}
            rowRenderer={rowRenderer}
            onScroll={handleScroll}
            onRowsRendered={handleRowsRendered}
          />
        )}
      </AutoSizer>
    </div>
  )
}

export default NEChatRoomUI
